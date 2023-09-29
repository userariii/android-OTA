DEVICE=$1
TG_USERNAME=$2
DEVICE_NAME=$3
XDA_THREAD=$4
GHUN=$5
NAME=$6
CUSTOMROM=$7
SMALL_CUSTOMROM=$8
TAG_NAME=$9

FILENAME=$(find out/target/product/$DEVICE/$CUSTOMROM*.zip | cut -d "/" -f 5)
if [ "$SMALL_CUSTOMROM" == "evolution" ]; then
  # Specify the JSON file path
  json_file="out/target/product/$DEVICE/$FILENAME.json"

  # Extract the value of the "datetime" field from JSON file
  DATETIME=$(grep -oP '(?<="datetime": )\d+' "$json_file")
else
  # Extract the value of the datetime field from build.prop using grep and cut
  DATETIME=$(grep "org.$SMALL_CUSTOMROM.build_date_utc=" out/target/product/$DEVICE/system/build.prop | cut -d "=" -f 2)
fi
ID=$(sha256sum out/target/product/$DEVICE/$CUSTOMROM*.zip | cut -d " " -f 1)
FILEHASH=$(md5sum out/target/product/$DEVICE/$CUSTOMROM*.zip | cut -d " " -f 1)
SIZE=$(wc -c out/target/product/$DEVICE/$CUSTOMROM*.zip | awk '{print $1}')
URL=https://github.com/userariii/android-OTA/releases/download/$TAG_NAME/$FILENAME
#URL="https://sourceforge.net/projects/android-ota/files/13/$DEVICE/$FILENAME/download"
#URL="https://gitlab.com/userariii/OTA-builds/-/raw/master/$SMALL_CUSTOMROM/tiramisu/$DEVICE/$FILENAME"
VERSION=$(grep "org.$SMALL_CUSTOMROM.version=" out/target/product/$DEVICE/system/build.prop | cut -d "=" -f 2)
STATUS="Active"
DONATE_URL="https://paypal.me/ariii0129"
NEWS_URL="https://t.me/SD720G_repo"
JSON_FMT='{\n\t"error":false,\n\t"filename":"%s",\n\t"datetime":%s,\n\t"size":%s,\n\t"url":"%s",\n\t"filehash":"%s",\n\t"version":"%s",\n\t"status":"%s",\n\t"id":"%s",\n\t"tg_username":"%s",\n\t"device_name":"%s",\n\t"device":"%s",\n\t"xda_thread":"%s",\n\t"maintainers": [{\n\t\t"main_maintainer":false,\n\t\t"github_username":"%s",\n\t\t"name":"%s"\n\t}],\n\t"donate_url":"%s",\n\t"website_url":"%s",\n\t"news_url":"%s",\n\t"forum_url":"%s"\n}'

DEVICE_JSON="OTA/$SMALL_CUSTOMROM/tiramisu/builds/$DEVICE.json"

if [ -f "$DEVICE_JSON" ]; then
  # Update the values in the existing file
  printf "$JSON_FMT" "$FILENAME" "$DATETIME" "$SIZE" "$URL" "$FILEHASH" "$VERSION" "$STATUS" "$ID" "$TG_USERNAME" "$DEVICE_NAME" "$DEVICE" "$XDA_THREAD" "$GHUN" "$NAME" "$DONATE_URL" "$WEBSITE_URL" "$NEWS_URL" "$XDA_THREAD" > "$DEVICE_JSON"
  echo "$DEVICE_JSON file updated"
else
  # Create a new file with the updated values
  touch $DEVICE_JSON
  printf "$JSON_FMT" "$FILENAME" "$DATETIME" "$SIZE" "$URL" "$FILEHASH" "$VERSION" "$STATUS" "$ID" "$TG_USERNAME" "$DEVICE_NAME" "$DEVICE" "$XDA_THREAD" "$GHUN" "$NAME" "$DONATE_URL" "$WEBSITE_URL" "$NEWS_URL" "$XDA_THREAD" > "$DEVICE_JSON"
  echo "$DEVICE_JSON file created"
fi

BUILD_DATE=$(echo $FILENAME | cut -d "-" -f 3)
BUILD_YEAR=${BUILD_DATE:0:4}
BUILD_MONTH=${BUILD_DATE:4:2}
BUILD_DAY=${BUILD_DATE:6:2}
CHANGELOG=$(echo "Changelog - $BUILD_YEAR/$BUILD_MONTH/$BUILD_DAY\n")

if [ -d "OTA/$SMALL_CUSTOMROM/tiramisu/changelogs/$DEVICE" ]; then
  printf "$CHANGELOG" > "OTA/$SMALL_CUSTOMROM/tiramisu/changelogs/$DEVICE/$FILENAME.txt"
  echo "OTA/$SMALL_CUSTOMROM/tiramisu/changelogs/$DEVICE/$FILENAME.txt created (make sure to update the changelog file)"
else
  mkdir -p "OTA/$SMALL_CUSTOMROM/tiramisu/changelogs/$DEVICE"
  printf "$CHANGELOG" > "OTA/$SMALL_CUSTOMROM/tiramisu/changelogs/$DEVICE/$FILENAME.txt"
  echo "OTA/$SMALL_CUSTOMROM/tiramisu/changelogs/$DEVICE/$FILENAME.txt created (make sure to update the changelog file)"
fi
