#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
echo $SCRIPTFOLDER
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
ERR=0
FWFOLDER=${ROOTFOLDER}/Firmare/Wifi_ESP-1s/ESP3D/
DISTFOLDER=${ROOTFOLDER}/dist/wifi/
mkdir -p ${DISTFOLDER}
cd ${FWFOLDER}
if [ "$1" != "" ]
then
    ENV=$1
else
    ENV="esp01s_160mhz-2.7.4"
fi

if [ "$4" != "" ]
then
    UPLOADPORT=" --upload-port ${4}"
else
    GETUPLOADPORT=$(pio device list | grep wch)
    if [ "${GETUPLOADPORT}" != "" ]
    then
        UPLOADPORT=" --upload-port ${GETUPLOADPORT}"
    fi
fi

if [ "$4" == "YES" ]
then
    platformio run  -e ${ENV} -t clean ${UPLOADPORT}
    platformio run  -e ${ENV} -t erase ${UPLOADPORT}
fi

platformio run -e ${ENV}
if [ $? -eq 0 ]; then
    ERR=$?
fi

if [ "$3" == "YES" ]
then
    platformio run  -e ${ENV} -t buildfs ${UPLOADPORT}
fi

if [ "$2" == "YES" ]
then
    platformio run  -e ${ENV} -t upload ${UPLOADPORT}    
fi

cp -f ${FWFOLDER}.pioenvs/${ENV}/firmware.bin ${DISTFOLDER}
echo "done"
git clean -f
git checkout .
if [ $ERR -eq 0 ]; then
    exit 0
else
    exit $ERR
fi