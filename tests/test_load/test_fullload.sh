#!/bin/bash

RESULT_DIR="_test"
BASE="base"
if [ "$#" -eq 1 ]; then
    BASE="base-$1"
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
current_date=$(date +"%Y-%m-%d_%H-%M-%S")
ROOT_LEVEL="../.."
LOG_FILE=${SCRIPT_DIR}/${ROOT_LEVEL}/${RESULT_DIR}/colorer_${current_date}.log 

mkdir -p "${SCRIPT_DIR}/${ROOT_LEVEL}/_test"

${SCRIPT_DIR}/${ROOT_LEVEL}/bin/colorer -c ${SCRIPT_DIR}/${ROOT_LEVEL}/_build/${BASE}/catalog.xml -ll -el info -eh colorer_${current_date} -ed ${SCRIPT_DIR}/${ROOT_LEVEL}/${RESULT_DIR}

# checking for new errors
grep -v -F -f ${SCRIPT_DIR}/ignored_error.txt ${LOG_FILE}

if [ $? -eq 1 ]; then
  echo "✅ Success: there are no unknown errors in the log."
else
  echo "❌ Error: unknown errors were found in the log file!"
  echo "Found lines:"
  grep --color=auto -F -f ${SCRIPT_DIR}/ignored_error.txt ${LOG_FILE}
  exit 1
fi