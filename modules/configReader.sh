#!/bin/bash

# Parse config from argument
configFile="$1"
if [ -f $configFile ]; then
  while IFS='= ' read varName content
  do
    if [[ ! $varName =~ ^\ *# && -n $varName ]]; then
      content=$(sed 's/\s*$//g' <<< $content)  # Del trailing spaces
      content=$(sed 's/\s*#/#/g' <<< $content) # Del trailing spaces before '#'
      content=$(sed 's/#.*//' <<< $content)    # Del all after '#'
      content="${content%\"*}"                 # Del closing string quotes
      content="${content#\"*}"                 # Del opening string quotes

      declare $varName="$content"
    fi
  done < $configFile
else
  echo "Error: Config file '$configFile' not found."
  exit 1
fi
