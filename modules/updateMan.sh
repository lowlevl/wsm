#!/bin/bash

echo -n "Checking for updates.. "
currentVer=
newVer=$(curl -s https://api.github.com/repos/Thecakeisgit/wSm/releases/latest | grep tag_name | cut -d '"' -f 4)

if [ "$currentVer" == "$newVer" ]; then
  echo "Up-to-date."
else
  echo "Found !"
  echo "$currentVer -> $newVer"
fi

echo -ne "\n"
