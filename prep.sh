#!/bin/bash
set -euo pipefail

if [ "${SCRIPTDIR}" == "" ]
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
        git clone -b merge-interop --recursive https://github.com/ConsenSys/teku
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
        git clone -b merge-f2f https://github.com/sigp/lighthouse.git
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
        git clone -b merge-interop-spec https://github.com/MariusVanDerWijden/go-ethereum.git
        cd go-ethereum
        make geth
        popd
    fi
    echo "Geth executable: $GETH"
fi
