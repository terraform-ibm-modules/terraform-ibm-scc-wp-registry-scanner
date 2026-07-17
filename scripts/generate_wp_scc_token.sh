#!/bin/bash

# Exit if any of the intermediate steps fail
set -Eeuo pipefail

LOGFILE="/tmp/scc_wp_get_token.log"
echo "Starting generate_wp_scc_token.sh at $(date)" >> "${LOGFILE}"
trap 'echo "Error at line $LINENO" >> "${LOGFILE}"' ERR

# Input parameters arrive as a JSON map on stdin (the external data source
# "query" argument). Secrets must not be passed as program arguments as they
# would be visible in the process table.
INPUT="$(cat)"
IAMTOKEN="$(jq -r '.iam_token // empty' <<< "${INPUT}")"
SCC_WP_API="$(jq -r '.api_url // empty' <<< "${INPUT}")"
SCC_WP_INSTANCEID="$(jq -r '.instance_id // empty' <<< "${INPUT}")"
DEBUG="$(jq -r '.debug // empty' <<< "${INPUT}")"

# exits reporting the input name passed as $1 if its value passed as $2 is empty
check_not_empty() {
    if [[ -z "${2}" ]]; then
        echo "Error: Got empty ${1}"
        echo "Error: Got empty ${1}" >> "${LOGFILE}"
        exit 1
    fi
}

check_not_empty "IAMTOKEN" "${IAMTOKEN}"

check_not_empty "SCC_WP_API" "${SCC_WP_API}"
echo "Got SCC_WP_API value ${SCC_WP_API}" >> "${LOGFILE}"

check_not_empty "SCC_WP_INSTANCEID" "${SCC_WP_INSTANCEID}"
echo "Got SCC_WP_INSTANCEID value ${SCC_WP_INSTANCEID}" >> "${LOGFILE}"

echo "Getting SCC WP TOKEN" >> "${LOGFILE}"

# the Authorization header is passed on curl stdin (-H @-) so the token does
# not show up in the curl process arguments either
if ! RES=$(printf 'Authorization: %s\n' "${IAMTOKEN}" | curl --fail -sS -H @- -H "IBMInstanceID: ${SCC_WP_INSTANCEID}" "${SCC_WP_API}/api/token"); then
    echo "Error: Token generation failed on ${SCC_WP_API}/api/token" >> "${LOGFILE}"
    exit 1
fi

# the raw response is only logged in debug mode, and always with the token
# masked, so the secret never reaches the filesystem
if [[ "${DEBUG}" == "true" ]]; then
    echo "Got response (token masked):" >> "${LOGFILE}"
    jq 'if (type == "object" and has("token")) then .token = "***MASKED***" else . end' <<< "${RES}" >> "${LOGFILE}" 2>> "${LOGFILE}" || echo "(response is not valid JSON)" >> "${LOGFILE}"
fi

SCCTOKEN="$(jq -r '.token.key // empty' <<< "${RES}")"
check_not_empty "SCCTOKEN in the API response" "${SCCTOKEN}"

echo "Got token" >> "${LOGFILE}"

jq -n --arg token "${SCCTOKEN}" '{"token": $token}'
