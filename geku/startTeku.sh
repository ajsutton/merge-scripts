#!/bin/bash
set -euo pipefail

SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_TEKU="true"
cd "${SCRIPTDIR}"
source ../prep.sh

GENESIS="${SCRATCH}/beku-genesis.ssz"
DATA_DIR="${SCRATCH}/geku-teku-data"
rm -rf "${DATA_DIR}"
rm -rf "${GENESIS}"

$TEKU genesis mock --output-file "${GENESIS}" --network config.yaml --validator-count 256
$TEKU \
  --eth1-endpoints http://127.0.0.1:8545 \
  --Xee-endpoint http://127.0.0.1:8545 \
  --Xvalidators-fee-recipient-address=0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b \
  --Xinterop-enabled=true \
  --Xinterop-number-of-validators=256 \
  --Xinterop-owned-validator-start-index=0 \
  --Xinterop-owned-validator-count=256 \
  --network=config.yaml \
  --p2p-private-key-file=teku.key \
  --rest-api-enabled \
  --initial-state "${GENESIS}" \
  --data-path "${DATA_DIR}"
