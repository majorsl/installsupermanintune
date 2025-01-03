#!/bin/bash

# https://github.com/Macjutsu/super

# Path to the super working folder:
SUPER_FOLDER="/Library/Management/super"

# Path to the local property list file:
SUPER_LOCAL_PLIST="${SUPER_FOLDER}/com.macjutsu.super" # No trailing ".plist"

# The name of the Super configuration profile (will not check if left empty:
SUPER_PROFILE="SuperSettings"

# Checks if the Super configuration profile is deployed.
if [ ! -z "$SUPER_PROFILE" ];
then
PROFILES=`profiles -C -v | awk -F: '/attribute: name/{print $NF}' | grep "$SUPER_PROFILE"`
	if [ "$PROFILES" == " $SUPER_PROFILE" ];
		then
		echo "Profile exist"
	else
		echo "Profile does not exist"
		exit 0
	fi
fi

# Report if the super preference file exists.
if [[ -f "${SUPER_FOLDER}/super" ]]; then
	if [[ -f "${SUPER_LOCAL_PLIST}.plist" ]]; then
		super_version_local=$(defaults read "${SUPER_LOCAL_PLIST}" SuperVersion 2> /dev/null)
		[[ $(echo "${super_version_local}" | cut -c 1) -lt 4 ]] && super_version_local=$(grep -m1 -e 'superVERSION=' -e '  Version ' "${SUPER_FOLDER}/super" | cut -d '"' -f 2 | cut -d " " -f 4)
		[[ -n "${super_version_local}" ]] && echo "<result>${super_version_local}</result>"
		[[ -z "${super_version_local}" ]] && echo "<result>No super version number found.</result>"
	else
		echo "<result>No super preference file.</result>"
	fi
else
	echo "<result>Not installed.</result>"
fi

#Script addition to deploy S.U.P.E.R.M.A.N in Microsoft Intune.
#Uses existing script to check for expected version before downloading and installing.
#Run as shell script every day or week from Intune
#by Boris Dreyer
#2024/06/27

# Version to install:
INSTALL_VERSION="5.0.0"

# Hash of downloaded script for security reasons:
HASH_CHECK=730b9f74094f31618f2202a305f8a7d53273eab2aff571b0ff4ce65235f17e6c

# Temporary download folder
SUPER_TEMP="/var/tmp/temp_super"

#Check for expected version
if [ $INSTALL_VERSION = ${super_version_local} ]; then
	exit 0
fi

#Download expected version
mkdir -p $SUPER_TEMP && cd $_
curl -L -O https://raw.githubusercontent.com/Macjutsu/super/$INSTALL_VERSION/super

#Check the downloaded file against expected hash 
if ! echo "$HASH_CHECK  $SUPER_TEMP/super" | shasum -a 256 -c -; then
    echo "Checksum not matching or download failed" >&2
    exit 1
fi

#Install S.U.P.E.R.M.A.N.
chmod a+x $SUPER_TEMP/super
$SUPER_TEMP/super --reset-super --auth-local-account='administratoraccountonhosts' --auth-local-password=administratoraccountonhostspassword

rm -rf $SUPER_TEMP

exit 0
