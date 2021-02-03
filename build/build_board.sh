#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
BOARD="BIGTREE_SKR_PRO"
ERR=0
FWFOLDER=${ROOTFOLDER}/Firmware/Board/Marlin/Marlin_2.0.x-bugfix/
DISTFOLDER=${ROOTFOLDER}/dist/board/sd/
CREATEDFW=${DISTFOLDER}firmware.bin
BUILDLOGFILE=${DISTFOLDER}build.log.html
BUILDFOLDER=${ROOTFOLDER}/build/
mkdir -p ${DISTFOLDER}
[ -f ${CREATEDFW}.old ] && rm ${CREATEDFW}.old
[ -f ${CREATEDFW} ] && mv ${CREATEDFW} ${CREATEDFW}.old
[ -f ${BUILDLOGFILE}.old ] && rm ${BUILDLOGFILE}.old
[ -f ${BUILDLOGFILE} ] && mv ${BUILDLOGFILE} ${BUILDLOGFILE}.old
BUILDDATE=$(date '+%d.%m.%Y  %H:%M:%S')
HTML0='<table class="table"><thead><tr><th scope="col">Key</th><th scope="col">Value</th></tr></thead><tbody>'
HTML1='\<tr\>\<td\>'
HTML2='\<\/td\>\<td class=\"configvalue\"\>'
HTML3='\<\/tr\>\<\/td\>'
HTML4='</tbody></table>'
GITHASH=`git log --pretty=format:"%h %ad" -1`

cd ${FWFOLDER}
cat ${BUILDFOLDER}/loghead > ${BUILDLOGFILE}
echo "
  <nav class=\"navbar navbar-expand-lg navbar-light bg-light shadow fixed-top\">
    <div class=\"container\">
      <a class=\"navbar-brand\">BuildLog <i>for BOARD</i>&nbsp;&nbsp;<b>${BOARD}</b></a>
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
cat ${FWFOLDER}/Marlin/Configuration.h | sed "s/^.*_CONFIGURATION_H_.*$//" | sed -n '/\/\/.*/!p' | sed '/^[[:blank:]]*#.*/!d' | sed 's/^[[:blank:]]*#define.//' | sed 's/^[[:blank:]]*#/#/' | sed '/^#.*/d' | sed "s/^/${HTML1}/" | sed "s/$/${HTML3}/" | sed "s/ /${HTML2}/" | sed '$ d' >> ${BUILDLOGFILE}
echo "${HTML4}" >> ${BUILDLOGFILE}

echo "<button class=\"btn btn-secondary\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapseCONFH\" aria-expanded=\"false\" aria-controls=\"collapseCONFH\">Show/ Hide original config</button>
<div class=\"collapse\" id=\"collapseCONFH\"><pre class=\"logstyled\">" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/Marlin/Configuration.h | sed "s/\</\&lt\;/g" | sed "s/\>/\&gt\;/g" >> ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}

# *********  configuration_adv.h  *********
echo "<div class=\"row holder border border-secondary shadow-lg p-3 mb-5 bg-white rounded\">" >> ${BUILDLOGFILE}

echo "<h4>Configuration_adv.h</h4>" >> ${BUILDLOGFILE}
echo "${HTML0}" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/Marlin/Configuration_adv.h | sed "s/^.*_CONFIGURATION_H_.*$//" | sed -n '/\/\/.*/!p' | sed '/^[[:blank:]]*#.*/!d' | sed 's/^[[:blank:]]*#define.//' | sed 's/^[[:blank:]]*#/#/' | sed '/^#.*/d' | sed "s/^/${HTML1}/" | sed "s/$/${HTML3}/" | sed "s/ /${HTML2}/" | sed '$ d' >> ${BUILDLOGFILE}
echo "${HTML4}" >> ${BUILDLOGFILE}

echo "<button class=\"btn btn-secondary\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapseCONFH\" aria-expanded=\"false\" aria-controls=\"collapseCONFH\">Show/ Hide original config</button>
<div class=\"collapse\" id=\"collapseCONFH\"><pre class=\"logstyled\">" >> ${BUILDLOGFILE}
cat ${FWFOLDER}/Marlin/Configuration_adv.h | sed "s/\</\&lt\;/g" | sed "s/\>/\&gt\;/g" >> ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}

# *********  Platform.io  *********
echo "<div class=\"row holder border border-secondary shadow-lg p-3 mb-5 bg-white rounded\">" >> ${BUILDLOGFILE}
echo "<h3>Build Output</h3><h4>from Platform.io</h3>" >> ${BUILDLOGFILE}
echo "<div class=\"logstyled\"><pre>" >> ${BUILDLOGFILE}
platformio run -e ${BOARD} | tee -a ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}
if [ $? -eq 0 ]; then
    echo "Build Ok"
    echo "<div><i>Build Ok - ${CREATEDFW}</i></div>" >> ${BUILDLOGFILE}
    FIRMWAREFILE=$(ls ${FWFOLDER}.pio/build/${BOARD}/ | grep .bin )
    cp -f ${FWFOLDER}/.pio/build/${BOARD}/${FIRMWAREFILE} ${DISTFOLDER}/firmware.bin
    if [ $? -eq 0 ]; then
        echo "Build deployed to dist>board>sd " | tee -a ${BUILDLOGFILE}
    else
        echo "Something went wrong can't copy firmware.bin" | tee -a ${BUILDLOGFILE}
        ERR=2
    fi
    FILESIZE=$(wc -c ${CREATEDFW} | awk '{print $1}')
    echo "<div>${FILESIZE} byte</div>" >> ${BUILDLOGFILE}
    ERR=$?
    if [ $ERR -eq 0 ]; then
        echo "Build deployed to Build Board-Display SD "
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
