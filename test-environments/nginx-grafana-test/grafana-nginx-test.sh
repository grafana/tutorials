#!/bin/bash

# shellcheck disable=SC1090

function printValues () {
    MACHINE_IP=$(terraform output -raw instance_ip)

    printf "\n%s:%40s\n\n" "current configuration" "VALID "
    printf "%21b:%40b\n" \
    "ssh access"        "ssh grafana@${MACHINE_IP} " \
    "web login"         "http://${MACHINE_IP} "      \
    "subpath login"     "http://${MACHINE_IP}/grafana\n"
}

# kick off terraform build
terraform init
terraform apply -auto-approve

# print the VM ip + metadata
printValues