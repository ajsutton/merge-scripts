#!/bin/bash
set -euo pipefail

SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

cd "${SCRIPTDIR}"
source ../prep.sh

GENESIS="${SCRATCH}/beku-genesis.ssz"
rm -rf /tmp/teku
rm -rf "${GENESIS}"

$TEKU genesis mock --output-file "${GENESIS}" --network minimal --Xnetwork-altair-fork-epoch 0 --validator-count 256
$TEKU \
  --eth1-endpoints http://127.0.0.1:8545 \
  --ee-fee-recipient-address=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
  --Xinterop-enabled=true \
  --Xinterop-number-of-validators=256 \
  --Xinterop-owned-validator-start-index=0 \
  --Xinterop-owned-validator-count=256 \
  --network=minimal \
  --Xnetwork-altair-fork-epoch=0 \
  --Xnetwork-merge-fork-epoch=1 \
  --Xnetwork-merge-total-terminal-difficulty=50 \
  --p2p-private-key-file=teku.key \
  --rest-api-enabled \
  --initial-state "${GENESIS}" \
  --data-path /tmp/teku
