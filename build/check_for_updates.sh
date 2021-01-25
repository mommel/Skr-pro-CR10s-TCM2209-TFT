#!/bin/bash
SCRIPTFOLDER=$(dirname $0)
cd $SCRIPTFOLDER
cd ..
outofdate=$(git status | grep Firmare)
if ["${outofdate}" != ""] ; then
  git submodule foreach --recursive git clean -f && git checkout . && git pull
fi