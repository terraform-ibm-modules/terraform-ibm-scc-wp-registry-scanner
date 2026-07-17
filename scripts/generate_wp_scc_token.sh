#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

LOGFILE="/tmp/scc_wp_get_token.log"
echo "Starting generate_wp_scc_token.sh at $(date)" >> "${LOGFILE}"

# Input parameters arrive as a JSON map on stdin (the external data source
# "query" argument). Secrets must not be passed as program arguments as they
# would be visible in the process table.
eval "$(jq -r '@sh "IAMTOKEN=\(.iam_token) SCC_WP_API=\(.api_url) SCC_WP_INSTANCEID=\(.instance_id) DEBUG=\(.debug)"')"

if [[ -z "${IAMTOKEN}" || "${IAMTOKEN}" == "null" ]]; then
    echo "Error: Got empty IAMTOKEN"
    echo "Error: Got empty IAMTOKEN" >> "${LOGFILE}"
    exit 1
fi

if [[ -z "${SCC_WP_API}" || "${SCC_WP_API}" == "null" ]]; then
    echo "Error: Got empty SCC_WP_API"
    echo "Error: Got empty SCC_WP_API" >> "${LOGFILE}"
    exit 1
fi
echo "Got SCC_WP_API value ${SCC_WP_API}" >> "${LOGFILE}"

if [[ -z "${SCC_WP_INSTANCEID}" || "${SCC_WP_INSTANCEID}" == "null" ]]; then
    echo "Error: Got empty SCC_WP_INSTANCEID"
    echo "Error: Got empty SCC_WP_INSTANCEID" >> "${LOGFILE}"
    exit 1
fi
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
    echo "${RES}" | jq 'if (type == "object" and has("token")) then .token = "***MASKED***" else . end' >> "${LOGFILE}" 2>> "${LOGFILE}" || echo "(response is not valid JSON)" >> "${LOGFILE}"
fi

SCCTOKEN="$(echo "${RES}" | jq -r .token.key)"
if [[ -z "${SCCTOKEN}" || "${SCCTOKEN}" == "null" ]]; then
    echo "Error extracting token from response" >> "${LOGFILE}"
    exit 1
fi

echo "Got token" >> "${LOGFILE}"

jq -n --arg token "${SCCTOKEN}" '{"token": $token}'
