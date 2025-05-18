#!/bin/bash

if [ ! -f "./config.sh" ]; then
    echo "Error: config.sh not found. Please create one based on config.sh.example"
    exit 1
fi

source ./config.sh

REQUIRED_VARS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_DEFAULT_REGION" "INSTANCE_PREFIX" "INSTANCE_COUNT" "INSTANCE_TYPE" "SSH_KEY_NAME")

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set in config.sh"
        exit 1
    fi
done

echo "Configuration validated successfully"
