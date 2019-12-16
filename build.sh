#!/bin/bash

TUTORIALS_DIR="tutorial"
OUTPUT_DIR="public"
LANDING_TEMPLATE="layout/landing.html"
CODELAB_TEMPLATE="layout/codelab.html"
STYLES_DIR="layout/assets"

# Create output directory if it doesn't exist.
[ ! -d "${OUTPUT_DIR}" ] && mkdir -p "${OUTPUT_DIR}"

# Build CSS.
sass "${STYLES_DIR}/google-codelab.scss" "${OUTPUT_DIR}/google-codelab.css"

# Build tutorials.
pushd tutorial # Needs to run in the directory with the tutorials.
claat export -f "../${CODELAB_TEMPLATE}" -o "../${OUTPUT_DIR}" *.md
popd

# Build landing page
go run cmd/claat-landing/main.go  \
    -template "${LANDING_TEMPLATE}"         \
    -codelabs-dir "${TUTORIALS_DIR}" \
    -output-dir "${OUTPUT_DIR}"

cp "${STYLES_DIR}/landing.css" "${OUTPUT_DIR}"
