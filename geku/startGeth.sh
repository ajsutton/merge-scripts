#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_GETH="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATADIR="${SCRATCH}/geth-data"
rm -rf "${DATADIR}"

$GETH --catalyst --datadir "${DATADIR}" init execution-genesis.json
$GETH --catalyst --datadir "${DATADIR}" account import geth-key.json
$GETH --catalyst --http --ws --http.api "engine,eth" --datadir "${DATADIR}" --allow-insecure-unlock --unlock "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b" --password "" --bootnodes "" --mine --port 30323 console
