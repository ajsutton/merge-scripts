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

if [ ! -f "$BESU" ]
then
    echo "##### Building Besu"
    pushd "${BASEDIR}"
    git clone -b merge https://github.com/hyperledger/besu
    cd besu
    ./gradlew --parallel installDist
    popd
fi

if [ ! -f "$TEKU" ]
then
    echo "#### Building Teku"
    pushd "${BASEDIR}"
    git clone -b merge-interop --recursive https://github.com/ConsenSys/teku
    cd teku
    ./gradlew --parallel installDist
    popd
fi

echo "Besu executable: $BESU"
echo "Teku executable: $TEKU"
