#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
BOARD="BIGTREE_SKR_PRO"
ERR=0
FWFOLDER=${ROOTFOLDER}/Firmare/Board/Marlin/Marlin_2.0.x-bugfix/
DISTFOLDER=${ROOTFOLDER}/dist/board/sd/
mkdir -p ${DISTFOLDER}
cd ${FWFOLDER}
platformio run -e ${BOARD}
if [ $? -eq 0 ]; then
    echo "Build Ok"
    echo $(dirname $0)
    cp -f ${FWFOLDER}.pio/build/${BOARD}/firmware.bin ${DISTFOLDER}
    if [ $? -eq 0 ]; then
        echo "Build deployed to Build Board-Firmware SD "
    else 
        echo "Something went wrong can't copy firmware.bin"
        ERR=2
    fi
else 
    echo "Build failed"
    echo "$?"
    ERR=1
fi
git clean -f
git checkout .
if [ $ERR -eq 0 ]; then
    exit 0
else
    exit $ERR
fi