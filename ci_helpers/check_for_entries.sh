#!/bin/bash

# Checks for entries in AUDITOR

TRIES=60

for (( i = TRIES; i; i-- )); do
    # Run curl in the AUDITOR container
    RECORDS=$(kubectl exec -t -n auditor \
        deployments/auditor-auditor-kubernetes-stack \
        --container=auditor \
        -- \
        curl --silent --get 127.0.0.1:8000/records)
    [[ -n $RECORDS ]] && echo $RECORDS
    if jq --slurp --exit-status 'length > 0' <<< "$RECORDS"; then
        exit 0
    fi
    sleep 2
done

exit 1
