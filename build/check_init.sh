#!/bin/bash
echo "**** Script started ==> $(pwd)/ >> ${0} ****"
CHECK=$(npm ll | grep "UNMET DEPENDENCY")
if [ "${CHECK}" != "" ]; then
  npm install
fi

[ ! -d "node_modules" ] && npm install
echo "**** ${0} DONE ****"
