#!/bin/bash

# Path to the maintainer info file
maintainer_info_file="./OTA/maintainer_info.txt"

# Prompt user for device codename
read -p "Enter device codename (e.g. PL2, miatoll): " codename

# Prompt user for release tag
read -p "Enter release tag (e.g. Month-YY): " release_tag

# Construct the expected OTA package path
ota_details_dir="out/target/product/${codename}"
file_path=$(ls ${ota_details_dir}/PixelExperience_${codename}-*.zip 2>/dev/null)

# Check if the OTA package exists
if [[ -z "$file_path" ]]; then
  echo "OTA package file not found in ${ota_details_dir}."
  echo "Ensure the file follows the pattern: PixelExperience_${codename}-*.zip"
  exit 1
else
  echo "Found OTA package: $file_path"
fi

# Extract filename from the path
filename=$(basename "$file_path")

# Extract build ID (xxxx) from the filename
build_id=$(echo "$filename" | grep -oP "(?<=PixelExperience_${codename}-13.0-)\d+")

# Construct the download URL
url="https://github.com/userariii/android-OTA/releases/download/${codename}-${release_tag}/$filename"

# Default values
output_dir="./OTA/pixelexperience/tiramisu/builds"
version="thirteen_plus"  # Default version value
datetime=$(grep -oP '^org.pixelexperience.build.date.utc=\K\d+' "${ota_details_dir}/system/build.prop" 2>/dev/null || echo "UNKNOWN")

# Generate file hash using md5sum
md5=$(md5sum "$file_path" | awk '{ print $1 }')

# Generate file hash using sha256sum
id=$(sha256sum "$file_path" | awk '{ print $1 }')

# Get the file size
size=$(stat -c%s "$file_path")

# Define URLs
github_releases_url="$url"
website_url="https://github.com/PixelExperience-LEGACY-edition"
news_url="https://t.me/SD720G_repo"

# Extract maintainer info using awk
device_name=$(awk -F'=' -v codename="$codename" '$0 ~ "\\["codename"\\]" {flag=1; next} /^\[/ {flag=0} flag && $1=="device" {gsub(/"/, "", $2); print $2}' "$maintainer_info_file" | xargs)
maintainer_name=$(awk -F'=' -v codename="$codename" '$0 ~ "\\["codename"\\]" {flag=1; next} /^\[/ {flag=0} flag && $1=="maintainer_name" {gsub(/"/, "", $2); print $2}' "$maintainer_info_file" | xargs)
github_username=$(awk -F'=' -v codename="$codename" '$0 ~ "\\["codename"\\]" {flag=1; next} /^\[/ {flag=0} flag && $1=="github_username" {gsub(/"/, "", $2); print $2}' "$maintainer_info_file" | xargs)
main_maintainer=$(awk -F'=' -v codename="$codename" '$0 ~ "\\["codename"\\]" {flag=1; next} /^\[/ {flag=0} flag && $1=="main_maintainer" {gsub(/"/, "", $2); print $2}' "$maintainer_info_file" | xargs)
donate_url=$(awk -F'=' -v codename="$codename" '$0 ~ "\\["codename"\\]" {flag=1; next} /^\[/ {flag=0} flag && $1=="donate_url" {gsub(/"/, "", $2); print $2}' "$maintainer_info_file" | xargs)
xda_thread=$(awk -F'=' -v codename="$codename" '$0 ~ "\\["codename"\\]" {flag=1; next} /^\[/ {flag=0} flag && $1=="forum_url" {gsub(/"/, "", $2); print $2}' "$maintainer_info_file" | xargs)

# Verify if maintainer info was properly fetched
if [[ -z "$maintainer_name" || -z "$github_username" || -z "$main_maintainer" || -z "$donate_url" || -z "$xda_thread" ]]; then
  echo "Maintainer info for '$codename' not found or incomplete in $maintainer_info_file."
  exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Define the output JSON file path
output_file="${output_dir}/${codename}.json"

# Set status (default to "Active")
status="Active"

# Create the JSON content
json=$(cat <<EOF
{
  "error": false,
  "filename":"$filename",
  "datetime":$datetime,
  "size":$size,
  "url":"$url",
  "filehash":"$md5",
  "version":"$version",
  "status":"$status",
  "id":"$id",
  "device_name":"$device_name",
  "device":"${codename}",
  "xda_thread":"$xda_thread",
  "maintainers": [
    {
      "main_maintainer":"$main_maintainer",
      "github_username":"$github_username",
      "name":"$maintainer_name"
    }
  ],
  "donate_url":"$donate_url",
  "website_url":"$website_url",
  "news_url":"$news_url"
}
EOF
)

# Save the JSON, prettify it if jq is installed
if command -v jq &> /dev/null; then
  echo "$json" | jq '.' > "$output_file"
else
  echo "$json" > "$output_file"
fi

# Confirmation message
echo "JSON has been saved to $output_file"

####### CHANGELOG FILES GENERATION #######

# Define the changelog directory
changelog_dir="./OTA/pixelexperience/tiramisu/changelogs/${codename}"
mkdir -p "$changelog_dir"

# **1. Per-Build Changelog**
changelog_file="${changelog_dir}/${filename}.txt"
echo "Changelogs - $build_id" > "$changelog_file"
echo "Changelog file has been created at $changelog_file"

# **2. Full Changelog (Only Create If Not Exists)**
full_changelog_file="${changelog_dir}/${codename}_full-changelogs.txt"

if [[ ! -f "$full_changelog_file" ]]; then
  echo -e "Build: $filename\nDate: $(date +'%Y-%m-%d %H:%M:%S')\nBuild ID: $build_id\n" > "$full_changelog_file"
  echo "Full changelog created at $full_changelog_file"
else
  echo "Full changelog already exists, skipping update."
fi

# Print contents of the per-build changelog
echo "====== Per-Build Changelog ======"
cat "$changelog_file"
