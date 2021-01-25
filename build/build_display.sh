#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
echo $SCRIPTFOLDER
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
DISPLAY="BIGTREE_TFT70_V3_0"
ERR=0
FWFOLDER=${ROOTFOLDER}/Firmare/Display/BIGTREETECH-TouchScreenFirmware/
DISTFOLDER=${ROOTFOLDER}/dist/display/sd/
mkdir -p ${DISTFOLDER}
cd ${FWFOLDER}
platformio run -e ${DISPLAY}
if [ $? -eq 0 ]; then
    echo "Build Ok"
    FIRMWAREFILE=$(ls ${FWFOLDER}.pio/build/${DISPLAY}/ | grep .bin )
    cp -f ${FWFOLDER}/.pio/build/${DISPLAY}/${FIRMWAREFILE} ${DISTFOLDER}/firmware.bin
    ERR=$?
    cp -f "${FWFOLDER}TFT/src/User/config.ini" ${DISTFOLDER}
    cp -f "${FWFOLDER}/Copy to SD Card root directory to update/Language Packs/language_de.ini" ${DISTFOLDER}
    cp -f "${FWFOLDER}/Copy to SD Card root directory to update/Language Packs/language_en.ini" ${DISTFOLDER}
    cp -Rn "${FWFOLDER}/Copy to SD Card root directory to update/THEME_Unified Menu Material theme/TFT70" ${DISTFOLDER}
    if [ $ERR -eq 0 ]; then
        echo "Build deployed to Build Board-Display SD "
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