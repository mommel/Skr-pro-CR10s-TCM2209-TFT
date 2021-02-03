#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
DISPLAY="BIGTREE_TFT70_V3_0"
ERR=0
FWFOLDER=${ROOTFOLDER}/Firmware/Display/BIGTREETECH/TouchScreenFirmware/
DISTFOLDER=${ROOTFOLDER}/dist/display/sd/
CREATEDFW=${DISTFOLDER}firmware.bin
mkdir -p ${DISTFOLDER}
[ -f ${CREATEDFW} ] && rm ${CREATEDFW}
BUILDLOGFILE=${DISTFOLDER}build.log.html
BUILDFOLDER=${ROOTFOLDER}/build/

BUILDDATE=$(date '+%d.%m.%Y  %H:%M:%S')
HTML0='<table class="table"><thead><tr><th scope="col">Key</th><th scope="col">Value</th></tr></thead><tbody>'
HTML1='\<tr\>\<td\>'
HTML2='\<\/td\>\<td class=\"configvalue\"\>'
HTML3='\<\/tr\>\<\/td\>'
HTML4='</tbody></table>'
GITHASH=`git log --pretty=format:"%h %ad" -1`
cd ${FWFOLDER}
#echo "Trying fix for tft7"
#cat ${BUILDFOLDER}platformio_ini > ${FWFOLDER}platformio.ini

cat ${BUILDFOLDER}loghead > ${BUILDLOGFILE}
echo "
  <nav class=\"navbar navbar-expand-lg navbar-light bg-light shadow fixed-top\">
    <div class=\"container\">
      <a class=\"navbar-brand\">BuildLog <i>for DISPLAY</i>&nbsp;&nbsp;<b>${DISPLAY}</b></a>
      <div class=\"collapse navbar-collapse\">
        <ul class=\"navbar-nav ml-auto\">
          <li class=\"nav-item active pull-right\">Created on ${BUILDDATE}&nbsp;&nbsp;</li>
        </ul>
      </div>
    </div>
  </nav>
  <div class=\"container page-all\">
" >> ${BUILDLOGFILE}
echo "<div class=\"row\">" >> ${BUILDLOGFILE}
echo "<i>Used following configurations for build</i>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}

# *********  configuration.h  *********
echo "<div class=\"row holder border border-secondary shadow-lg p-3 mb-5 bg-white rounded\">" >> ${BUILDLOGFILE}

echo "<h4>configuration.h</h4>" >> ${BUILDLOGFILE}
echo "${HTML0}" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/TFT/src/User/Configuration.h | sed "s/^.*_CONFIGURATION_H_.*$//" | sed -n '/\/\/.*/!p' | sed '/^[[:blank:]]*#.*/!d' | sed 's/^[[:blank:]]*#define.//' | sed 's/^[[:blank:]]*#/#/' | sed "s/^/${HTML1}/" | sed "s/$/${HTML3}/" | sed "s/ /${HTML2}/" | sed '$ d' >> ${BUILDLOGFILE}
echo "${HTML4}" >> ${BUILDLOGFILE}

echo "<button class=\"btn btn-secondary\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapseCONFH\" aria-expanded=\"false\" aria-controls=\"collapseCONFH\">Show/ Hide original config</button>
<div class=\"collapse\" id=\"collapseCONFH\"><pre class=\"logstyled\">" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/TFT/src/User/Configuration.h | sed "s/\</\&lt\;/g" | sed "s/\>/\&gt\;/g" >> ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}

# *********  config.ini  *********
echo "<div class=\"row holder border border-secondary shadow-lg p-3 mb-5 bg-white rounded\">" >> ${BUILDLOGFILE}

echo "<h4>config.ini</h4>" >> ${BUILDLOGFILE}
echo "${HTML0}" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/TFT/src/User/config.ini | sed '/^$/d' | sed 's/^[[:blank:]]*//' | sed '/^#.*/d' | sed 's/ \/\/.*$/ /g'  | sed "s/^/${HTML1}/" | sed "s/$/${HTML3}/" | sed "s/:/${HTML2}/" >> ${BUILDLOGFILE}
echo "${HTML4}" >> ${BUILDLOGFILE}

echo "<button class=\"btn btn-secondary\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapseCONFi\" aria-expanded=\"false\" aria-controls=\"collapseCONFi\">Show/ Hide original config</button>
<div class=\"collapse\" id=\"collapseCONFi\"><pre class=\"logstyled\">" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/TFT/src/User/config.ini | sed "s/\</\&lt\;/g" | sed "s/\>/\&gt\;/g" >> ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}

# *********  Platform.io  *********
echo "<div class=\"row holder border border-secondary shadow-lg p-3 mb-5 bg-white rounded\">" >> ${BUILDLOGFILE}
echo "<h3>Build Output</h3><h4>from Platform.io</h3>" >> ${BUILDLOGFILE}
echo "<div class=\"logstyled\"><pre>" >> ${BUILDLOGFILE}
platformio run -e ${DISPLAY} | tee -a ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}
if [ $? -eq 0 ]; then
    echo "Build Ok"
    echo "<div><i>Build Ok - ${CREATEDFW}</i></div>" >> ${BUILDLOGFILE}
    FIRMWAREFILE=$(ls ${FWFOLDER}.pio/build/${DISPLAY}/ | grep .bin )
    cp -f ${FWFOLDER}/.pio/build/${DISPLAY}/${FIRMWAREFILE} ${DISTFOLDER}/firmware.bin
    if [ $? -eq 0 ]; then
        echo "Build deployed to dist>display>sd " | tee -a ${BUILDLOGFILE}
    else
        echo "Something went wrong can't copy firmware.bin" | tee -a ${BUILDLOGFILE}
        ERR=2
    fi
    FILESIZE=$(wc -c ${CREATEDFW} | awk '{print $1}')
    echo "<div>${FILESIZE} byte</div>" >> ${BUILDLOGFILE}
    cp -f "${FWFOLDER}TFT/src/User/config.ini" ${DISTFOLDER}
    ERR=$?
    cp -f "${FWFOLDER}/Copy to SD Card root directory to update/Language Packs/language_de.ini" ${DISTFOLDER}
    cp -f "${FWFOLDER}/Copy to SD Card root directory to update/Language Packs/language_en.ini" ${DISTFOLDER}
    cp -Rn "${FWFOLDER}/Copy to SD Card root directory to update/THEME_Unified Menu Material theme/TFT70" ${DISTFOLDER}
    if [ $ERR -eq 0 ]; then
        echo "Build deployed to Build Dist-Display SD "
    else
        echo "Something went wrong can't copy firmware.bin"
        ERR=2
    fi
    if [ $ERR -eq 0 ]; then
        echo "Build deployed to Build Dist-Display SD "
    else
        echo "Something went wrong can't copy firmware.bin"
        ERR=2
    fi
else
    echo "Build failed"
    echo "$?"
    echo "<br /><div>Build failed $?</div>" >> ${BUILDLOGFILE}
    ERR=1
fi

echo "<div class=\"footer fixed-bottom\"><div class=\"text-center p-3\" style=\"background-color: rgba(0, 0, 0, 0.2)\">Version: Git Commithash = ${GITHASH}</div></div>" >> ${BUILDLOGFILE}
cat ${ROOTFOLDER}/build/logfooter >> ${BUILDLOGFILE}
git clean -f
git checkout .
echo "You will find the buildlog here: " ${BUILDLOGFILE}
if [ $ERR -eq 0 ]; then
    exit 0
else
    exit $ERR
fi
