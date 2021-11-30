#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_TEKU="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATADIR="${SCRATCH}/teku-data"
rm -rf "${DATADIR}"

GENESIS_STATE="../merge-testnets/merge-devnet-2/genesis.ssz"
FINALIZED_STATE="devnet2-state.ssz"
# Set this to "${FINALIZED_STATE}" to use optimistic sync.
STARTING_STATE="${GENESIS_STATE}"
$TEKU --network ../merge-testnets/merge-devnet-2/config.yaml --data-path "${DATADIR}" --initial-state "${STARTING_STATE}" --p2p-discovery-bootnodes "enr:-Iq4QKuNB_wHmWon7hv5HntHiSsyE1a6cUTK1aT7xDSU_hNTLW3R4mowUboCsqYoh1kN9v3ZoSu_WuvW9Aw0tQ0Dxv6GAXxQ7Nv5gmlkgnY0gmlwhLKAlv6Jc2VjcDI1NmsxoQK6S-Cii_KmfFdUJL2TANL3ksaKUnNXvTCv1tLwXs0QgIN1ZHCCIyk" -Xee-endpoint http://localhost:8545

