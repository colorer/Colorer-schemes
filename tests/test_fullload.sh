#!/bin/bash

RESULT_DIR="_test"
BASE="base"
if [ "$#" -eq 1 ]; then
    BASE="base-$1"
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
current_date=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "${SCRIPT_DIR}/../_test"

${SCRIPT_DIR}/../bin/colorer -c ${SCRIPT_DIR}/../_build/${BASE}/catalog.xml -ll -el info -eh colorer_${current_date} -ed ${SCRIPT_DIR}/../${RESULT_DIR}