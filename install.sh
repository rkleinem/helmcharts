#!/bin/bash
set -e

SOURCE=.
VALUES=""
CERTS=ci_certs
RUN=1

function usage {
cat << EOF
Usage: $0 [options] [args]

Options:
    -c dir: A directory for certificates. ($CERTS)
    -f file: A file containing chart values ($VALUES)
    -p dir/file: Package to install ($SOURCE)
    -d: Dry run
    -A: Don't run APEL reporter
    -h: Show help
EOF
}

while getopts "c:f:p:dAh" opt; do
    case $opt in
        c) CERTS="$OPTARG" ;;
        f) VALUES="$OPTARG" ;;
        p) SOURCE="$OPTARG" ;;
        d) RUN=0 ;;
        A) IGNORE_APEL=1 ;;
        h) usage
           exit 0 ;;
        *) usage
           exit 1 ;;
    esac
done
shift $((OPTIND-1))

# AUDITOR certs
CA="$CERTS"/rootCA.pem
AUDITOR_CRT="$CERTS"/auditor.pem
AUDITOR_KEY="$CERTS"/auditor.key
COLL_CRT="$CERTS"/collector.pem
COLL_KEY="$CERTS"/collector.key
PROM_CRT="$CERTS"/prometheus.pem
PROM_KEY="$CERTS"/prometheus.key
RPRT_CRT="$CERTS"/reporter.pem
RPRT_KEY="$CERTS"/reporter.key

# APEL certs
APEL_CA="$CERTS"/apel_ca.pem
APEL_CRT="$CERTS"/apel.key
APEL_KEY="$CERTS"/apel.pem

# Check for APEL certs
if (( IGNORE_APEL == 0 )); then
if [[ ! ( -f $APEL_CA && -f $APEL_CRT && -f $APEL_KEY ) ]]; then
    echo "Cannot find APEL certificates"
    exit 1
fi
fi

# Check for AUDITOR certs
if [[ -f $CA ]]; then
    if [[ ! ( -f $CA && -f $AUDITOR_CRT && -f $AUDITOR_KEY && -f $PROM_CRT && -f $PROM_KEY ) ]]; then
        echo "We need all certificate files for AUDITOR:"
        for f in $CA $AUDITOR_CRT $AUDITOR_KEY $PROM_CRT $PROM_KEY; do
            echo "   ${f}"
        done
        exit 1
    fi
    USE_AUDITOR_CERTS=1
fi

CMD=(helm install --create-namespace --namespace auditor auditor "$SOURCE")
CMD+=(--set global.certs.useFiles=false)
if (( IGNORE_APEL == 0 )); then
    CMD+=(--set-file apelReporter.apelcerts.apelclient_ca="$APEL_CA")
    CMD+=(--set-file apelReporter.apelcerts.apelclient_cert="$APEL_CRT")
    CMD+=(--set-file apelReporter.apelcerts.apelclient_key="$APEL_KEY")
fi
if (( $USE_AUDITOR_CERTS )); then
    CMD+=(--set-file global.certs.ca_cert="$CA")
    CMD+=(--set-file auditor.certs.auditor_cert="$AUDITOR_CRT")
    CMD+=(--set-file auditor.certs.auditor_key="$AUDITOR_KEY")
    CMD+=(--set-file collector.certs.collector_cert="$COLL_CRT")
    CMD+=(--set-file collector.certs.collector_key="$COLL_KEY")
    CMD+=(--set-file prometheus.certs.prom_cert="$PROM_CRT")
    CMD+=(--set-file prometheus.certs.prom_key="$PROM_KEY")
    CMD+=(--set-file apelReporter.auditorcerts.reporter_cert="$RPRT_CRT")
    CMD+=(--set-file apelReporter.auditorcerts.reporter_key="$RPRT_KEY")
fi
if [[ -n $VALUES ]]; then
    CMD+=(--values values.yaml)
fi
CMD+=("$@")  # Pass through any additional args

echo "Running command: ${CMD[@]}"
(( RUN )) && "${CMD[@]}"




