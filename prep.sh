#!/bin/bash
set -euo pipefail

if [ "${SCRIPTDIR:-}" == "" ]
then
    export BASEDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
else
    export BASEDIR="${SCRIPTDIR}/.."
fi
export BESU="${BESU:-$BASEDIR/besu/build/install/besu/bin/besu}"
export TEKU="${TEKU:-$BASEDIR/teku/build/install/teku/bin/teku}"
export SCRATCH="${BASEDIR}/tmp"
mkdir -p "${SCRATCH}"

if [ "${NEED_BESU:-false}" == "true" ]
then 
    if [ ! -f "$BESU" ]
    then
        echo "##### Building Besu"
        pushd "${BASEDIR}"
        git clone -b merge https://github.com/hyperledger/besu
        cd besu
        ./gradlew --parallel installDist
        popd
    fi
    echo "Besu executable: $BESU"
fi

if [ "${NEED_TEKU:-false}" == "true" ]
then
    if [ ! -f "$TEKU" ]
    then
        echo "#### Building Teku"
        pushd "${BASEDIR}"
        git clone -b master --recursive https://github.com/ConsenSys/teku
        cd teku
        ./gradlew --parallel installDist
        popd
    fi
    echo "Teku executable: $TEKU"
fi

if [ "${NEED_LIGHTHOUSE:-false}" == "true" ]
then
    if  ! command -v lighthouse &> /dev/null
    then
        echo "#### Building Lighthouse"
        pushd "${BASEDIR}"
        git clone -b kintsugi https://github.com/sigp/lighthouse.git
        cd lighthouse
        make
        popd
    fi
    export LIGHTHOUSE=$(which lighthouse)
    echo "Lighthouse executable: $LIGHTHOUSE"
fi

if [ "${NEED_GETH:-false}" == "true" ]
then
    export GETH="${GETH:-$BASEDIR/go-ethereum/build/bin/geth}"
    if [ ! -f "$GETH" ]
    then
        echo "#### Building Geth"
        pushd "${BASEDIR}"
        git clone -b beacon-ontopof-4399 https://github.com/MariusVanDerWijden/go-ethereum.git
        cd go-ethereum
        make geth
        popd
    fi
    echo "Geth executable: $GETH"
fi

if [ "${NEED_NETHERMIND:-false}" == "true" ]
then
  echo "Check nethermind"
  if ! which dotnet &> /dev/null
  then
    echo "ERROR !!!!!! dotnet is not available but is required for netheremind"
    exit 1
  fi
  echo "Need nethermind"
  if [[ ! -d $BASEDIR/nethermind ]]
  then
    echo "#### Building Nethermind"
    git clone -b themerge_kintsugi --recursive https://github.com/NethermindEth/nethermind.git
    cd nethermind/src/Nethermind
    dotnet build Nethermind.sln -c Release
     # Apparently sometimes you need to do it twice, we'll just go with it...
    dotnet build Nethermind.sln -c Release
  fi
fi

if [ "${NEED_VALTOOLS:-false}" == "true" ]
then
    if ! command -v eth2-val-tools &> /dev/null
    then
        echo "#### Compiling eth2-val-tools"
        GO111MODULE=on go install github.com/protolambda/eth2-val-tools@latest
    fi
    export VALTOOLS=$(which eth2-val-tools)
    echo "eth2-val-tools executable: $VALTOOLS"
fi

if [ "${NEED_NIMBUS:-false}" == "true" ]
then
  export NIMBUS_BN="${NIMBUS_BN:-$BASEDIR/nimbus-eth2/build/nimbus_beacon_node}"
  export NIMBUS_VC="${NIMBUS_VC:-$BASEDIR/nimbus-eth2/build/nimbus_validator_client}"
  if [ ! -f "${NIMBUS_BN}" ]
  then
    echo "#### Building Nimbus"
    pushd "${BASEDIR}"
    git clone -b amphora-merge-interop https://github.com/status-im/nimbus-eth2.git
    cd nimbus-eth2
    make NIMFLAGS="-d:const_preset=mainnet" nimbus_beacon_node nimbus_validator_client
    popd
  fi
fi
