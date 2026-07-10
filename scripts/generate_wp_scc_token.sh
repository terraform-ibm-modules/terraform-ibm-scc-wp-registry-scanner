#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

LOGFILE="/tmp/scc_wp_get_token.log"
echo "Starting get_token.sh at $(date)" >> "${LOGFILE}"
IAMTOKEN="${1}"
if [[ -z "${IAMTOKEN}" ]]; then
    echo "Error: Got empty IAMTOKEN"
    echo "Error: Got empty IAMTOKEN" >> "${LOGFILE}"
    exit 1
fi

echo "Got IAMTOKEN first 15 chars:" >> "${LOGFILE}"
echo "${IAMTOKEN:0:15}" >> "${LOGFILE}"

SCC_WP_API="${2}"
if [[ -z "${SCC_WP_API}" ]]; then
    echo "Error: Got empty SCC_WP_API"
    echo "Error: Got empty SCC_WP_API" >> "${LOGFILE}"
    exit 1
fi
# echo "Got SCC_WP_API value ${SCC_WP_API}"
echo "Got SCC_WP_API value ${SCC_WP_API}" >> "${LOGFILE}"

SCC_WP_INSTANCEID="${3}"
if [[ -z "${SCC_WP_INSTANCEID}" ]]; then
    echo "Error: Got empty SCC_WP_INSTANCEID"
    echo "Error: Got empty SCC_WP_INSTANCEID" >> "${LOGFILE}"
    exit 1
fi
# echo "Got SCC_WP_INSTANCEID value ${SCC_WP_INSTANCEID}"
echo "Got SCC_WP_INSTANCEID value ${SCC_WP_INSTANCEID}" >> "${LOGFILE}"

echo "Getting SCC WP TOKEN" >> "${LOGFILE}"

# shellcheck disable=SC2086
RES=$(curl -H --fail "Authorization: ${IAMTOKEN}" -H "IBMInstanceID: ${SCC_WP_INSTANCEID}" ${SCC_WP_API}/api/token)
# disabled shellcheck error for a sake of code simplicity
# shellcheck disable=SC2181
if [[ $? != "0" ]]; then
    echo "Error: Token generation failed on ${SCC_WP_API}/api/token" >> "${LOGFILE}"
    exit 1
fi
SCCTOKEN="$(echo "${RES}" | jq -r .token.key )"
if [[ -z "${SCCTOKEN}" ]]; then
    echo "Error extracting token from response" >> "${LOGFILE}"
    exit 1
fi

echo "Got response" >> "${LOGFILE}"
echo "${RES}" >> "${LOGFILE}"

echo "{\"token\": \"${SCCTOKEN}\"}"

set +e
