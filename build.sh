#!/bin/bash

TUTORIALS_DIR="tutorials"
OUTPUT_DIR="public"

TEMPLATES_DIR="templates"
PREFIX="https://storage.googleapis.com/grafana-tutorials-staging"

# Create output directory if it doesn't exist.
[ ! -d "${OUTPUT_DIR}" ] && mkdir -p "${OUTPUT_DIR}"

# Build CSS.
sass "${TEMPLATES_DIR}/google-codelab.scss" "${OUTPUT_DIR}/google-codelab.css"

# Build tutorials.
pushd "${TUTORIALS_DIR}" # Needs to run in the directory with the tutorials.
claat export \
    -prefix "${PREFIX}" \
    -f "../${TEMPLATES_DIR}/codelab.html" \
    -o "../${OUTPUT_DIR}" \
    *.md
popd

# Build landing page
go run cmd/claat-landing/main.go  \
    -template "${TEMPLATES_DIR}/landing.html" \
    -codelabs-dir "${OUTPUT_DIR}" \
    -output-dir "${OUTPUT_DIR}" \
    -prefix "${PREFIX}"

cp "${TEMPLATES_DIR}/landing.css" "${OUTPUT_DIR}"
