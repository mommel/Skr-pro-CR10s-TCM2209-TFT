#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
echo $SCRIPTFOLDER
cd $SCRIPTFOLDER
CHECK=$(npm ll | grep "UNMET DEPENDENCY")
if [ "${CHECK}" != "" ]; then
  npm install
fi
