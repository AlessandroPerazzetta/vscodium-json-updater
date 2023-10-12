#!/bin/bash
NOW=$(date +"%Y%m%d-%H%M")
JSON_FILE='product.json'
SRC_DIR="$(sudo find / -path "*esources/app/$JSON_FILE" -type f -print -quit 2>/dev/null)"

# Check dependencies
deps=("jq")
missingdeps=""
# missingdepsinstall="sudo apt install"
missingdepsinstall=""

OS=$(uname -s | tr A-Z a-z)
case $OS in
  linux)
    source /etc/os-release
    case $ID_LIKE in
      debian|ubuntu|mint)
        missingdepsinstall="sudo apt install"
        ;;

      fedora|rhel|centos)
        missingdepsinstall="sudo yum install"
        ;;
      arch)
        missingdepsinstall="yay -S"
        ;;
      *)
        echo -n "unsupported linux package manager"
        ;;
    esac
  ;;

  darwin)
    missingdepsinstall="brew install"
  ;;

  *)
    echo -n "unsupported OS"
    ;;
esac

for dep in "${deps[@]}"; do
	if ! type $(echo "$dep" | cut -d\| -f1) &> /dev/null; then
		missingdeps=$(echo "$missingdeps$(echo "$dep" | cut -d\| -f1), ")
		missingdepsinstall=$(echo "$missingdepsinstall $(echo "$dep" | cut -d\| -f2)")
	fi
done
if [ -n "$missingdeps" ]; then
	echo "[ERROR] Missing dependencies! ($(echo "$missingdeps" | xargs | sed 's/.$//'))"
	echo "        You can install them using this command:"
	echo "        ----------------------------------------"
	echo "        $missingdepsinstall"
	echo "        ----------------------------------------"
	exit 1
fi

if test -z "$SRC_DIR" 
then
    echo "$JSON_FILE not found, exit!!!"
	exit 0
fi

SRC_FILE=$SRC_DIR
BKP_FILE=$SRC_DIR.$NOW

echo "JSON found at: $SRC_DIR"
echo "Backup $SRC_FILE to $BKP_FILE"
echo "Replacing content on: $SRC_FILE"

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
