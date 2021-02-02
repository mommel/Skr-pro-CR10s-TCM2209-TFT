#!/bin/bash
cd ..
echo "**** Script started ==> $(pwd)/ >> ${0} ****"
CHECK=$(npm ll | grep "UNMET DEPENDENCY")
if [ "${CHECK}" != "" ]; then
  npm install
fi
echo "**** ${0} DONE ****"
