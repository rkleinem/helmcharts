#!/usr/bin/env python3
"""
Replace defined occurrences of version numbers with new numbers.
"""

import argparse
import functools
import re
import sys
from typing import Any

from ruamel.yaml import YAML

# For structured files (e.g. .toml)  we may specify the 'path' of a field.
# Then, we only try to update the specified field.
# Paths need to be accepted by `nested_get` below (read for details).

# The fields to update in Helmcharts
helmcharts_path = [
    ["version"],
    ["appVersion"],
]
helmcharts_oldver = r"(#)"

helmcharts_parent_path = [
    ["dependencies", "version"]
]
helmcharts_parent_oldver = r"~\s*(#)"

# A list of Chart.yaml files to update. Works like the `tomls` list.
helmcharts: list[tuple[str, list[Any]]] = [
    ("Chart.yaml", helmcharts_path, helmcharts_oldver),
    ("Chart.yaml", helmcharts_parent_path, helmcharts_parent_oldver),
    ("charts/auditor/Chart.yaml", helmcharts_path, helmcharts_oldver),
    ("charts/auditor-collector/Chart.yaml", helmcharts_path, helmcharts_oldver),
    ("charts/auditor-apel/Chart.yaml", helmcharts_path, helmcharts_oldver),
    ("charts/auditor-prometheus/Chart.yaml", [["version"]], helmcharts_oldver),
]


def update_list(lis: list, path: list, old: re.Pattern, new: str) -> list | None:
    ret = []
    changed = False
    for e in lis:
        if isinstance(e, list):
            upd = update_list(e, path, old, new)
            if upd:
                changed = True
            ret.append(upd or e)
        else:
            upd = update_dict(e, path, old, new)
            if upd:
                changed = True
            ret.append(upd or e)
    if changed:
        return ret
    return None


def update_dict(dic: dict, path: list, old: re.Pattern, new: str) -> dict | None:
    if len(path) > 1:
        e = dic[path[0]]
        if isinstance(e, list):
            upd = update_list(e, path[1:], old, new)
            if upd:
                dic[path[0]] = upd
                return dic
        else:
            upd = update_dict(e, path[1:], old, new)
            if upd:
                dic[path[0]] = upd
                return dic
    else:
        m = re.fullmatch(old, dic[path[0]])
        #print(old, dic[path[0]])
        if m:
            dic[path[0]] = m.string[: m.start(1)] + new + m.string[m.end(1) :]
            return dic
        else:
            print(f"Strange version for {path[0]}: {dic[path[0]]}")
    return None


def bump_yaml(fname: str, paths: list, old_version: re.Pattern, new_version: str, dry: bool) -> bool:
    """
    Update a single .yaml file.
    Look for `old_version` and replace by `new_version` in every field
    defined by `paths`.
    """
    print(f"Edit {fname}")
    if not isinstance(paths[0], list):
        paths = [paths]

    with open(fname, "r", encoding="utf-8") as f:
        yaml = YAML().load(f)

    changed = False
    for path in paths:
        upd = update_dict(yaml, path, old_version, new_version)
        if upd:
            changed = True
            yaml = upd

    if changed and not dry:
        with open(fname, "w", encoding="utf-8") as f:
            YAML().dump(yaml, f)

    return changed


def bump_version(old_version: str, new_version: str, dry: bool = False) -> bool:
    """Update all files defined above."""
    changed = False
    for file, path, oldver in helmcharts:
        oldver = oldver.replace("#", old_version)
        changed = bump_yaml(file, path, re.compile(oldver), new_version, dry) or changed
    return changed


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-o", "--old", required=True, help="Old version")
    parser.add_argument("-n", "--new", required=True, help="New version")
    parser.add_argument(
        "-y", "--assumeyes", action="store_true", help="Don't ask for confirmation"
    )
    parser.add_argument(
        "-c", "--check", action="store_true", help="Do a dry run and return non-zero if something would change."
    )
    args = parser.parse_args()

    print(f"Replace version {args.old} with {args.new}.")
    if args.check:
        print("Do a dry run")
    answer = input("Are you sure? (y/N)\n") if not args.assumeyes else "y"

    if answer.lower() == "y":
        changed = bump_version(args.old, args.new, dry=args.check)
    else:
        print("Aborting.")

    print(f"Changes made: {changed}")
    if args.check and changed:
        sys.exit(1)


if __name__ == "__main__":
    main()
