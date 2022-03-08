#!/bin/bash
set -euo pipefail

SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_TEKU="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATA_DIR="${SCRATCH}/geku-teku-data-vc"
rm -rf "${DATA_DIR}"

echo "Starting vc"
$TEKU vc \
  --logging debug \
  --log-destination console \
  --Xvalidators-proposer-default-fee-recipient=0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b \
  --beacon-node-api-endpoint http://localhost:5051 \
  --Xinterop-enabled=true \
  --Xinterop-number-of-validators=256 \
  --Xinterop-owned-validator-start-index=0 \
  --Xinterop-owned-validator-count=256 \
  --data-path "${DATA_DIR}"
