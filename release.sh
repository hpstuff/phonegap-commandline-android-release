#!/bin/bash
set -e
dir=$(pwd)
file="$dir/release_config.cfg"
# get variables from config
if [ ! -f $file ]; then
    echo "#Release Config file" > $file
else
    echo "Load config"
    . $file
fi
# build android app
phonegap build android
# go to android platform folder
cd platforms/android/
# create release apk
ant release
# got to bin
cd bin/
# check and fill variables
while [ -z "$key" ]; do
    echo "Enter the path to keystore: "
    read key
    if [ $key ]; then
        echo "key=$key" >> $file
    fi
done
while [ -z "$pass" ]; do
    echo "Enter the pass for keystore: "
    read pass
    if [ $pass ]; then
        echo "pass=$pass" >> $file
    fi
done
while [ -z "$unsigned_apk" ]; do
    echo "Enter the name of unsigned released apk (MyApp-release-unsigned.apk): "
    read unsigned_apk
    if [ $unsigned_apk ]; then
        echo "unsigned_apk=$unsigned_apk" >> $file
    fi
done
while [ -z "$name" ]; do
    echo "Enter the app name that is used in keystore: "
    read name
    if [ $name ]; then
        echo "name=$name" >> $file
    fi
done
# sign the apk with the defined keystore
echo $pass | jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$key" "$unsigned_apk" "$name"
# verify the sign
jarsigner -verify -verbose -certs "$unsigned_apk"
#check variabl apk_name
while [ -z "$apk_name" ]; do
    echo "Enter the name for your apk (MyApp.apk): "
    read apk_name
    if [ $apk_name ]; then
        echo "apk_name=$apk_name" >> $file
    fi
done
# rm old apk if exists
if [ -f $apk_name ]; then
    echo "Delete old apk file."
    rm "$apk_name"
fi
# verify and export the final apk in bin directory
zipalign -v 4 "$unsigned_apk" "$apk_name"
