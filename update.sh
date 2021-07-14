#!/bin/bash
NOW=$(date +"%Y%m%d-%H%M")
SRC_DIR='/usr/share/codium/resources/app/'
JSON_FILE='product.json'
SRC_FILE=$SRC_DIR$JSON_FILE
BKP_FILE=$SRC_DIR$JSON_FILE.$NOW

if ! [ -x "$(command -v jq)" ]; then
	echo 'Error: jq is not installed.' >&2
	exit 1
fi
sudo -i -- <<EOF
cp $SRC_FILE $BKP_FILE
jq '.extensionsGallery' $BKP_FILE
jq 'del(.extensionsGallery[])' $BKP_FILE | jq '.extensionsGallery |= . + {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "itemUrl": "https://marketplace.visualstudio.com/items"}' > $SRC_FILE
jq '.extensionsGallery ' $SRC_FILE
EOF
