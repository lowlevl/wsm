#!/bin/bash

# Parse config from argument
configFile="$1"
echo -n "" > "$configFile"
shift

if [ "$1" != "" ]
then
  while [ "$#" -gt 0 ]
  do
    varName="$1"
    if [ ! -z "${!varName}" ]
    then
      echo "$varName=${!varName}" >> "$configFile"
    fi
    shift
  done
else
  echo "Error: No such arguments to write to config.."
fi
