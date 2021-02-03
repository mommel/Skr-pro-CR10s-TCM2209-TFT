#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
echo $SCRIPTFOLDER
cd $SCRIPTFOLDER
cd ..
ROOTFOLDER=$(pwd)
ERR=0
if [ "$1" = "" ]; then
    TARGET="board"
else
    TARGET="$1"
fi
if [ "$2" = "" ]; then
    ENV="esp01s_160mhz-2.7.4"
else
    ENV="$2"
fi
FWFOLDER=${ROOTFOLDER}/Firmware/Wifi_ESP-1s/ESP3D/
CONFFILE=${FWFOLDER}esp3d/config.h
DISTFOLDER=${ROOTFOLDER}/dist/wifi/${TARGET}/
CREATEDFW=${DISTFOLDER}firmware.bin
mkdir -p ${DISTFOLDER}
[ -f ${CREATEDFW} ] && rm ${CREATEDFW}
BUILDLOGFILE=${DISTFOLDER}build.log.html
BUILDDATE=$(date '+%d.%m.%Y  %H:%M:%S')
HTML0='<table class="table"><thead><tr><th scope="col">Key</th><th scope="col">Value</th></tr></thead><tbody>'
HTML1='\<tr\>\<td\>'
HTML2='\<\/td\>\<td class=\"configvalue\"\>'
HTML3='\<\/tr\>\<\/td\>'
HTML4='</tbody></table>'
GITHASH=`git log --pretty=format:"%h %ad" -1`
cat ${ROOTFOLDER}/build/loghead > ${BUILDLOGFILE}

echo "
  <nav class=\"navbar navbar-expand-lg navbar-light bg-light shadow fixed-top\">
    <div class=\"container\">
      <a class=\"navbar-brand\">BuildLog <i>for WIFI</i>&nbsp;&nbsp;<b>${TARGET}</b></a>
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
cd ${FWFOLDER}
CONFIGNEW=$CONFFILE.new

REMOVELINESWITH=( "ESP8266_MODEL_NAME" "ESP_MODEL_NUMBER" "ESP_MANUFACTURER_NAME" "ESP_DEFAULT_NAME" "ESP_HOST_NAME" )
INSERTPOS=$(grep -n 'ESP8266_MODEL_NAME' ${CONFFILE} | cut -f1 -d:)
for deletePattern in ${REMOVELINESWITH[@]}; do
    grep -v "${deletePattern}" $CONFFILE > $CONFIGNEW && cat $CONFIGNEW > $CONFFILE
done
LINESCOUNT=$(cat $CONFFILE | wc -l)
LINESTILLEND=$((LINESCOUNT-INSERTPOS+1))
echo "" > $CONFIGNEW
sed "${INSERTPOS}q" $CONFFILE > $CONFIGNEW
echo "#define ESP8266_MODEL_NAME \"SKR_PRO-Wifi\" " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "#define ESP_MODEL_NUMBER \"2.1\" " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "#define ESP_MANUFACTURER_NAME \"InsertScaryNameHere\" " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "#define ESP_DEFAULT_NAME \"SKR-Pro-Wifi-${TARGET}\" " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "#define ESP_HOST_NAME ESP_DEFAULT_NAME " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
sed -e :a -e "\$q;N;${LINESTILLEND},\$D;ba" $CONFFILE | wc -l
sed -e :a -e "\$q;N;${LINESTILLEND},\$D;ba" $CONFFILE >> $CONFIGNEW
cat $CONFIGNEW > $CONFFILE

REMOVELINESWITH=( "DEFAULT_AP_SSID" "DEFAULT_AP_PASSWORD" )
INSERTPOS=$(grep -n 'const char DEFAULT_AP_SSID' ${CONFFILE} | cut -f1 -d:)
for deletePattern in ${REMOVELINESWITH[@]}; do
    grep -v "${deletePattern}" $CONFFILE > $CONFIGNEW && cat $CONFIGNEW > $CONFFILE
done
LINESCOUNT=$(cat $CONFFILE | wc -l)
LINESTILLEND=$((LINESCOUNT-INSERTPOS+1))
echo "" > $CONFIGNEW
sed "${INSERTPOS}q" $CONFFILE >> $CONFIGNEW
WIFIPW=$( cat /dev/urandom | head -c 8 | base64)
echo "const char DEFAULT_AP_SSID []  PROGMEM =       \"SKR_PRO_WIFI-${TARGET}\"; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "const char DEFAULT_AP_PASSWORD [] PROGMEM =    \"${WIFIPW}\"; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
sed -e :a -e "\$q;N;${LINESTILLEND},\$D;ba" $CONFFILE >> $CONFIGNEW
cat $CONFIGNEW > $CONFFILE

REMOVELINESWITH=( "DEFAULT_WEB_PORT" "DEFAULT_DATA_PORT" "DEFAULT_ADMIN_PWD" "DEFAULT_USER_PWD" "DEFAULT_ADMIN_LOGIN" "DEFAULT_USER_LOGIN" )
INSERTPOS=$(grep -n 'DEFAULT_WEB_PORT' ${CONFFILE}  | cut -f1 -d:)
for deletePattern in ${REMOVELINESWITH[@]}; do
    grep -v "${deletePattern}" $CONFFILE > $CONFIGNEW && cat $CONFIGNEW > $CONFFILE
done
LINESCOUNT=$(cat $CONFFILE | wc -l)
LINESTILLEND=$((LINESCOUNT-INSERTPOS+1))
sed "${INSERTPOS}q" $CONFFILE > $CONFIGNEW
ADMPW=$( cat /dev/urandom | head -c 8 | base64)
USERPW=$( cat /dev/urandom | head -c 8 | base64)
echo "const int DEFAULT_WEB_PORT =            443; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "const int DEFAULT_DATA_PORT =           8888; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "const char DEFAULT_ADMIN_PWD []  PROGMEM =  \"${ADMPW}\"; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "const char DEFAULT_USER_PWD []  PROGMEM =   \"${USERPW}\"; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "const char DEFAULT_ADMIN_LOGIN []  PROGMEM =    \"skradm\"; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
echo "const char DEFAULT_USER_LOGIN []  PROGMEM = \"prouser\"; " >> $CONFIGNEW
echo "// replaced for SKR-PRO CR-10" >> $CONFIGNEW
sed -e :a -e "\$q;N;${LINESTILLEND},\$D;ba" $CONFFILE >> $CONFIGNEW
cat $CONFIGNEW > $CONFFILE
echo "<div class=\"logstyled\"><pre>" >> ${BUILDLOGFILE}
cat $CONFFILE >> ${BUILDLOGFILE}
echo "</pre></div>" >> ${BUILDLOGFILE}
# *********  Platform.io  *********
echo "<div class=\"row holder border border-secondary shadow-lg p-3 mb-5 bg-white rounded\">" >> ${BUILDLOGFILE}
echo "<h3>Build Output</h3><h4>from Platform.io</h3>" >> ${BUILDLOGFILE}
echo "<div class=\"logstyled\"><pre>" >> ${BUILDLOGFILE}
if [ "$GETUPLOADPORT" != "" ]; then
    UPLOADPORT=" --upload-port ${GETUPLOADPORT}"
    platformio run  -e ${ENV} -t erase  -t buildfs -t clean ${UPLOADPORT} | tee -a ${BUILDLOGFILE}
    ERR=$?
else
    platformio run -e ${ENV} | tee -a ${BUILDLOGFILE}
    ERR=$?
fi
echo "</pre></div>" >> ${BUILDLOGFILE}
echo "</div>" >> ${BUILDLOGFILE}
if [ $? -eq 0 ]; then
    echo "Build Ok"
    echo "<div><i>Build Ok - ${CREATEDFW}</i></div>" >> ${BUILDLOGFILE}
    FIRMWAREFILE=$(ls ${FWFOLDER}.pioenvs/${ENV}/ | grep .bin )
    cp -f ${FWFOLDER}.pioenvs/${ENV}/${FIRMWAREFILE} ${DISTFOLDER}/firmware.bin
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
