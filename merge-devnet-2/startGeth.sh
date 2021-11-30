#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_GETH="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATADIR="${SCRATCH}/geth-data"
rm -rf "${DATADIR}"

$GETH --catalyst --datadir "${DATADIR}" init ../merge-testnets/merge-devnet-2/genesis.json
$GETH --catalyst --http --ws --syncmode full --http.api "engine,eth,web3,net" --datadir "${DATADIR}" --http.corsdomain "*" --networkid=1337502 \
  --bootnodes "enode://d2da684e8dd9746a520d4e37eb43a94c18756b3b17c251b0fa172ad253a07b26d6bf4b0ec09025ea2d4f6e607df7a2e7f96b57d03bed3dcca38198eb53981a0e@137.184.104.103:30303" \
  --port 8547 --verbosity 3  console

