#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_GETH="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATADIR="${SCRATCH}/geth-data"
rm -rf "${DATADIR}"

$GETH --catalyst --datadir "${DATADIR}" init ../merge-testnets/merge-devnet-1/genesis.json
$GETH --catalyst --http --ws --syncmode full --http.api "engine,eth,web3,net" --datadir "${DATADIR}" --http.corsdomain "*" --networkid=1337402 --bootnodes "enode://6538a7ac0748d24caec2470879d0fa35cbafa62e5d22532a3634119eb9360b28e615d0e960bacfb8d26e3ef646adb64c5a0689ed378ce69efba3f190fa8f26a6@137.184.108.205:30303" --bootnodes "enode://782606f7e2c782cb48fa0b0bdaf31ecb3fc063ae8593357dd0e4482f07367f4551df38b80a82f693f52d5f9f167256675b9e5fe1ec49a2e9eab690181958c2a7@137.184.109.236:30303" --bootnodes "enode://3a514176466fa815ed481ffad09110a2d344f6c9b78c1d14afc351c3a51be33d8072e77939dc03ba44790779b7a1025baf3003f6732430e20cd9b76d953391b3@137.184.97.41:30303" --port 8547 --verbosity 3  console

