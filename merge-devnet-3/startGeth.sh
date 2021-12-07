#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_GETH="true"
cd "${SCRIPTDIR}"
source ../prep.sh

DATADIR="${SCRATCH}/geth-data"
rm -rf "${DATADIR}"

$GETH --catalyst --datadir "${DATADIR}" init ../merge-testnets/merge-devnet-3/genesis.json
$GETH --catalyst --http --ws --syncmode full --http.api "engine,eth,web3,net" --datadir "${DATADIR}" --http.corsdomain "*" --networkid=1337602 \
  --bootnodes "enode://6b457d42e6301acfae11dc785b43346e195ad0974b394922b842adea5aeb4c55b02410607ba21e4a03ba53e7656091e2f990034ce3f8bad4d0cca1c6398bdbb8@137.184.55.117:30303" \
  --bootnodes "enode://588ef56694223ce3212d7c56e5b6f3e8ba46a9c29522fdc6fef15657f505a7314b9bd32f2d53c4564bc6b9259c3d5c79fc96257eff9cd489004c4d9cbb3c0707@137.184.203.157:30303" \
  --bootnodes "enode://46b2ecd18c24463413b7328e9a59c72d955874ad5ddb9cd9659d322bedd2758a6cefb8378e2309a028bd3cdf2beca0b18c3457f03e772f35d0cd06c37ce75eee@137.184.213.208:30303" \
  --port 8547 --verbosity 3  console

