#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
BOARD="BIGTREE_SKR_PRO"
ERR=0
FWFOLDER=${ROOTFOLDER}/Firmare/Board/Marlin/Marlin_2.0.x-bugfix/
DISTFOLDER=${ROOTFOLDER}/dist/board/sd/
CREATEDFW=${DISTFOLDER}firmware.bin
mkdir -p ${DISTFOLDER}
[ -f ${CREATEDFW} ] && rm ${CREATEDFW}
BUILDLOGFILE=${DISTFOLDER}/build.log
BUILDDATE=$(date '+%d.%m.%Y  %H:%M:%S')
cd ${FWFOLDER}
printf "=========================================================\r\nBuildLog for Board ${BOARD}\r\n Created on ${BUILDDATE}\r\nVersion: Marlin 2.0 bugfix Git Commithash = " > ${BUILDLOGFILE}
`git log --pretty=format:"%h %ad" -1 >> ${BUILDLOGFILE}`
printf "\r\nUsed following configurations for build\r\n\r\n=========================================================\r\nConfiguration.h\r\n=========================================================\r\n" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/Marlin/Configuration.h | sed -n '/\/\/.*/!p' | sed '/^[[:blank:]]*#.*/!d' | sed 's/^[[:blank:]]*#define.//' | sed 's/^[[:blank:]]*#/ /'  >> ${BUILDLOGFILE}
printf "\r\n=========================================================\r\nConfiguration_adv.h\r\n=========================================================\r\n" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/Marlin/Configuration_adv.h | sed -n '/\/\/.*/!p' | sed '/^[[:blank:]]*#.*/!d' | sed 's/^[[:blank:]]*#define.//' | sed 's/^[[:blank:]]*#/ /' >> ${BUILDLOGFILE}
platformio run -e ${BOARD}
printf "\r\n=========================================================\r\nResult\r\n=========================================================\r\n" >> ${BUILDLOGFILE}    
if [ $? -eq 0 ]; then
    echo "Build Ok"
    echo "Build Ok - ${CREATEDFW} " >> ${BUILDLOGFILE}
    cp -f ${FWFOLDER}.pio/build/${BOARD}/firmware.bin ${DISTFOLDER}
    if [ $? -eq 0 ]; then
        echo "Build deployed to Build Board-Firmware SD "
    else 
        echo "Something went wrong can't copy firmware.bin"
        ERR=2
    fi
    FILESIZE=$(wc -c ${CREATEDFW} | awk '{print $1}')
    echo "${FILESIZE} byte" >> ${BUILDLOGFILE}
else 
    echo "Build failed"
    echo "$?"
    echo "Build failed $? " >> ${BUILDLOGFILE}
    ERR=1
fi
git clean -f
git checkout .
if [ $ERR -eq 0 ]; then
    cat ${BUILDLOGFILE}
    exit 0
else
    exit $ERR
fi