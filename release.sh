#!/bin/bash
set -e
# get variables from config
. ./release_config.cfg
# build android app
phonegap build android
# go to android platform folder
cd platforms/android/
# create release apk
ant release
# got to bin
cd bin/
# sign the apk with the defined keystore
echo $pass | jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$key" "$unsigned_apk" "$name"
# verify the sign
jarsigner -verify -verbose -certs "$unsigned_apk"
# rm old apk if exists
if [ -f $apk_name ]; then
    echo "Delete old apk file."
    rm "$apk_name"
fi
# verify and export the final apk in bin directory
zipalign -v 4 "$unsigned_apk" "$apk_name"
