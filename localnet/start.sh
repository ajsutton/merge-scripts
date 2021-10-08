#!/bin/bash
set -euo pipefail
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NEED_BESU="true"
NEED_TEKU="true"
NEED_GETH="true"
NEED_LIGHTHOUSE="true"
#NEED_NIMBUS="true"
NEED_VALTOOLS="true"

cd "${SCRIPTDIR}"
source ../prep.sh

rm -rf "${SCRATCH}/localnet"
mkdir -p "${SCRATCH}/localnet"
mkdir -p "${SCRATCH}/localnet/data"
mkdir -p "${SCRATCH}/localnet/data/besu1"
mkdir -p "${SCRATCH}/localnet/data/besu2"

GENESIS_STATE="${SCRATCH}/localnet/genesis.ssz"
TERMINAL_TOTAL_DIFFICULTY=300
export JAVA_OPTS="-Xmx512m"

CONSENSUS_BOOTNODE="enr:-KG4QNndG4nlf0_K6G2NOQ_ifmraOlseY7ZbsDQ0NWk2pmxjE-bi6SQT4UGXIbRXLq3vbvxWuNkxxEgml6h18nCKyvoDhGV0aDKQNJ7Z9jEAAAEBAAAAAAAAAIJpZIJ2NIJpcIR_AAABiXNlY3AyNTZrMaEDLtDQNOGsr_iYx-sZkTPsZha9b9PaHe5pHub_YcbGuZyDdGNwgiMog3VkcIIjKA"
EXECUTION_BOOTNODE="enode://3a514176466fa815ed481ffad09110a2d344f6c9b78c1d14afc351c3a51be33d8072e77939dc03ba44790779b7a1025baf3003f6732430e20cd9b76d953391b3@127.0.0.1:30308"

echo "Generating consensus genesis state..."
eth2-testnet-genesis phase0 \
  --config consensus/phase0.yaml \
  --eth1-block 0xd20a4f7d29f3a524f893485aab52fad41ebcfc7d2095fc704d677417b9169919 \
  --timestamp $(date +%s) \
  --mnemonics consensus/mnemonics.yaml \
  --state-output "${GENESIS_STATE}" \
  --tranches-dir "${SCRATCH}/localnet/validator-pubkeys"

# Create consensus testnet dir
BEACONSPEC_DIR="${SCRATCH}/localnet/beaconspec"
mkdir -p "${BEACONSPEC_DIR}"
cp "${GENESIS_STATE}" "${BEACONSPEC_DIR}/genesis.ssz"
echo "[]" > "${BEACONSPEC_DIR}/boot_enr.yaml"
echo "$CONSENSUS_BOOTNODE" > "${BEACONSPEC_DIR}/boostrap_nodes.txt"
cp consensus/config.yaml "${BEACONSPEC_DIR}/config.yaml"
echo "0" > "${BEACONSPEC_DIR}/deploy_block.txt"

# Make sure keys aren't locked from previous runs. Terrible for slashing but oh well...
find consensus/validator-keys -name '*.lock' -delete

tmux kill-session -t merge-localnet || true


echo "### Node 1 - Geth + Teku"
$GETH --datadir "${SCRATCH}/localnet/data/geth1" init execution/genesis.json
$GETH --datadir "${SCRATCH}/localnet/data/geth1" account import --password "execution/geth/passfile.txt" execution/signer.key
#cat <<EOF > "${SCRATCH}/localnet/startBesu1.sh"
#  $BESU \
#      --config-file execution/besu/config.toml \
#      --data-path \"${SCRATCH}/localnet/data/besu1\" \
#      --p2p-port 30308 \
#      --rpc-http-port=8545 \\
#      --node-private-key-file=execution/signer.key \
#      | tee \"${SCRATCH}/localnet/data/besu1/besu.log\"
#EOF
#chmod a+x "${SCRATCH}/localnet/startBesu1.sh"

tmux new-session -d -s merge-localnet \
  $GETH \
    --catalyst \
    --http \
    --http.port 8545 \
    --http.api "engine,eth,net,admin,web3" \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --allow-insecure-unlock \
    --unlock "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b" \
    --password "execution/geth/passfile.txt" \
    --datadir "${SCRATCH}/localnet/data/geth1" \
    --nodekey "execution/signer.key" \
    --bootnodes "$EXECUTION_BOOTNODE" \
    --port 30308 \
    --syncmode full \
    --mine \
    --networkid 2337002 \
    console \
    \; set-option remain-on-exit on

tmux split-window -h -t merge-localnet \
  $TEKU \
    --eth1-endpoints http://127.0.0.1:8545 \
    --ee-fee-recipient-address=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
    --validator-keys "consensus/validator-keys/batch1/teku-keys:consensus/validator-keys/batch1/teku-secrets" \
    --validators-keystore-locking-enabled=false \
    --network=consensus/config.yaml \
    --initial-state "${GENESIS_STATE}" \
    --Xnetwork-merge-total-terminal-difficulty=${TERMINAL_TOTAL_DIFFICULTY} \
    --p2p-private-key-file=consensus/teku/teku.key \
    --p2p-advertised-ip=127.0.0.1 \
    --p2p-port 9000 \
    --Xlog-include-p2p-warnings-enabled \
    --rest-api-enabled \
    --data-path "${SCRATCH}/localnet/data/teku1"


echo "### Node 2 - Besu + Teku"

cat <<EOF > "${SCRATCH}/localnet/startBesu2.sh"
  $BESU \\
    --config-file execution/besu/config.toml \\
    --data-path "${SCRATCH}/localnet/data/besu2" \\
    --p2p-port 30304 \\
    --rpc-http-port=8546 \\
    --bootnodes "${EXECUTION_BOOTNODE}" \\
    | tee "${SCRATCH}/localnet/data/besu2/besu.log"
EOF
chmod a+x "${SCRATCH}/localnet/startBesu2.sh"

tmux split-window -v -f -t %0 "${SCRATCH}/localnet/startBesu2.sh"

tmux split-window -h -t %2 \
  $TEKU \
    --eth1-endpoints http://127.0.0.1:8546 \
    --ee-fee-recipient-address=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 \
    --validator-keys "consensus/validator-keys/batch2/teku-keys:consensus/validator-keys/batch2/teku-secrets" \
    --validators-keystore-locking-enabled=false \
    --network=consensus/config.yaml \
    --initial-state "${GENESIS_STATE}" \
    --Xnetwork-merge-total-terminal-difficulty=${TERMINAL_TOTAL_DIFFICULTY} \
    --p2p-advertised-ip=127.0.0.1 \
    --p2p-port 9001 \
    --Xlog-include-p2p-warnings-enabled \
    --p2p-discovery-bootnodes "${CONSENSUS_BOOTNODE}" \
    --p2p-static-peers "/ip4/127.0.0.1/tcp/9000/p2p/16Uiu2HAmFojnD68tVG9yKjHApYTvyjtnQ2nMbxJpoDNiMPGVdyGP" \
    --rest-api-enabled \
    --rest-api-port 5052 \
    --data-path "${SCRATCH}/localnet/data/teku2"

echo "### Node 3 - Geth + Lighthouse"
$GETH --datadir "${SCRATCH}/localnet/data/geth3" init execution/genesis.json
tmux split-window -v -f -t %2 \
  $GETH \
    --catalyst \
    --http \
    --http.api "engine,eth,net,admin,web3" \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.port 8547 \
    --datadir "${SCRATCH}/localnet/data/geth3" \
    --bootnodes "$EXECUTION_BOOTNODE" \
    --port 30305 \
    --syncmode full \
    --networkid 2337002 \
    console

cat <<EOF > "${SCRATCH}/localnet/startLighthouse1.sh"
  $LIGHTHOUSE \\
    --spec mainnet \\
    --testnet-dir "${BEACONSPEC_DIR}" \\
    beacon_node \\
    --purge-db \\
    --datadir "${SCRATCH}/localnet/data/lighthouse1" \\
    --boot-nodes "${CONSENSUS_BOOTNODE}" \\
    --port 9002 \\
    --enr-address 127.0.0.1 \\
    --enr-tcp-port 9002 \\
    --enr-udp-port 9002 \\
    --dummy-eth1 \\
    --http \\
    --http-port 5053 \\
    --http-allow-sync-stalled \\
    --merge \\
    --execution-endpoints http://127.0.0.1:8547 \\
    --terminal-total-difficulty-override 12C \\
    | tee "${SCRATCH}/localnet/lighthouse1.log"
EOF
chmod a+x "${SCRATCH}/localnet/startLighthouse1.sh"
tmux split-window -h -t %4 "${SCRATCH}/localnet/startLighthouse1.sh"


# Lighthouse Validator
mkdir -p "${SCRATCH}/localnet/data/lighthouse1-vc"
cp -rf consensus/validator-keys/batch3/keys "${SCRATCH}/localnet/data/lighthouse1-vc/"
cp -rf consensus/validator-keys/batch3/secrets "${SCRATCH}/localnet/data/lighthouse1-vc/"
tmux split-window -v -t %5 \
  $LIGHTHOUSE \
    --spec mainnet \
    --testnet-dir "${BEACONSPEC_DIR}" \
    vc \
    --beacon-nodes http://127.0.0.1:5053 \
    --init-slashing-protection \
    --validators-dir "${SCRATCH}/localnet/data/lighthouse1-vc/keys" \
    --secrets-dir "${SCRATCH}/localnet/data/lighthouse1-vc/secrets"


echo "### Node 4 - Besu + Lighthouse"
mkdir -p "${SCRATCH}/localnet/data/besu3"
cat <<EOF > "${SCRATCH}/localnet/startBesu3.sh"
  $BESU \\
    --config-file execution/besu/config.toml \\
    --data-path "${SCRATCH}/localnet/data/besu3" \\
    --p2p-port 30318 \\
    --rpc-http-port=8548 \\
    --bootnodes "${EXECUTION_BOOTNODE}" \\
    | tee "${SCRATCH}/localnet/data/besu3/besu.log"
EOF
chmod a+x "${SCRATCH}/localnet/startBesu3.sh"

tmux split-window -v -f -l 75% -t %0 "${SCRATCH}/localnet/startBesu3.sh"

cat <<EOF > "${SCRATCH}/localnet/startLighthouse2.sh"
  $LIGHTHOUSE \\
    --spec mainnet \\
    --testnet-dir "${BEACONSPEC_DIR}" \\
    beacon_node \\
    --purge-db \\
    --datadir "${SCRATCH}/localnet/data/lighthouse2" \\
    --boot-nodes "${CONSENSUS_BOOTNODE}" \\
    --port 9003 \\
    --enr-address 127.0.0.1 \\
    --enr-tcp-port 9003 \\
    --enr-udp-port 9003 \\
    --dummy-eth1 \\
    --http \\
    --http-port 5054 \\
    --http-allow-sync-stalled \\
    --merge \\
    --execution-endpoints http://127.0.0.1:8548 \\
    --terminal-total-difficulty-override 12C \\
  | tee "${SCRATCH}/loalnet/data/lighthouse2.log"
EOF
chmod a+x "${SCRATCH}/localnet/startLighthouse2.sh"
tmux split-window -h -t %7 "${SCRATCH}/localnet/startLighthouse2.sh"

# Lighthouse Validator
mkdir -p "${SCRATCH}/localnet/data/lighthouse2-vc"
cp -rf consensus/validator-keys/batch4/keys "${SCRATCH}/localnet/data/lighthouse2-vc/"
cp -rf consensus/validator-keys/batch4/secrets "${SCRATCH}/localnet/data/lighthouse2-vc/"
tmux split-window -v -t %8 \
  $LIGHTHOUSE \
    --spec mainnet \
    --testnet-dir "${BEACONSPEC_DIR}" \
    vc \
    --beacon-nodes http://127.0.0.1:5054 \
    --init-slashing-protection \
    --validators-dir "${SCRATCH}/localnet/data/lighthouse2-vc/keys" \
    --secrets-dir "${SCRATCH}/localnet/data/lighthouse2-vc/secrets"

# Nimbus currently finds peers but isn't importing any blocks and I'm not sure why.
#echo "### Node 4 - Geth + Nimbus"
#
#$GETH --datadir "${SCRATCH}/localnet/data/geth4" init execution/genesis.json
#tmux split-window -v -t %2 \
#  $GETH \
#    --catalyst \
#    --ws \
#    --http.api "engine,eth" \
#    --ws.port 8548 \
#    --datadir "${SCRATCH}/localnet/data/geth4" \
#    --bootnodes "$EXECUTION_BOOTNODE" \
#    --port 30307 \
#    --syncmode full \
#    --networkid 2337002 \
#    console
#
#tmux split-window -v -t %3 \
#  $NIMBUS_BN \
#    --data-dir="${SCRATCH}/localnet/data/nimbus1" \
#    --network="${BEACONSPEC_DIR}" \
#    --log-file="${SCRATCH}/localnet/data/nimbus1.log" \
#    --tcp-port=9003 \
#    --udp-port=9003 \
#    -b:${CONSENSUS_BOOTNODE} \
#    --web3-url=ws://127.0.0.1:8548/

tmux attach-session -t merge-localnet