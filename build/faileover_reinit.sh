#!/bin/bash
echo "**** Script started ==> $(pwd)/ >> ${0} ****"
rm -rf "./node_modules"
npm install
echo "**** ${0} DONE ****"
