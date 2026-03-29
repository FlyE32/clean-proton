#!/bin/bash

#       _                                        _              
#   ___| | ___  __ _ _ __        _ __  _ __ ___ | |_ ___  _ __  
#  / __| |/ _ \/ _` | '_ \ _____| '_ \| '__/ _ \| __/ _ \| '_ \ 
# | (__| |  __/ (_| | | | |_____| |_) | | | (_) | || (_) | | | |
#  \___|_|\___|\__,_|_| |_|     | .__/|_|  \___/ \__\___/|_| |_|
#                               |_|                             

# clean-proton - Steam Proton Prefix Manager
# Copyright (C) 2026 Cameron Rout (Github: FlyE32)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.


# === CONFIGURATION ===
CACHE_FILE="$HOME/.clean-proton-cache.txt"
touch "$CACHE_FILE"



# === DEPENDENCY CHECK ===
for cmd in jq curl findmnt awk; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed. Please install it to continue."
    exit 1
  fi
done



# === FUNCTIONS ===

usage() {
  echo "Usage: clean-proton [OPTIONS]"
  echo "  -a <path>  Add a specific compatdata directory to the cache"
  echo "  -s         Run auto-discovery to find libraries"
  echo "  -c         Clear the cache file and exit"
  echo "  -h         Show this help message"
  exit 0
}

discover_paths() {
  echo "Scanning all mounted drives for 'compatdata'..."
  # Use mount to find real partitions, avoiding the findmnt flag conflict
  mapfile -t MOUNT_POINTS < <(mount | grep -E 'ext4|btrfs|ntfs|fuseblk|xfs' | awk '{print $3}')

  for mount_ptr in "${MOUNT_POINTS[@]}"; do
    mapfile -t FOUND_IN_MOUNT < <(find "$mount_ptr" -type d -iname "compatdata" 2>/dev/null | grep -i "steamapps/compatdata")
    
    for p in "${FOUND_IN_MOUNT[@]}"; do
      [[ "$p" != */ ]] && p="$p/"
      if ! grep -q "PATH|$p" "$CACHE_FILE"; then
        read -p "Found library at $p - Add to cache? [Y/n]: " confirm
        [[ ! "$confirm" =~ ^[Nn]$ ]] && echo "PATH|$p" >> "$CACHE_FILE"
      fi
    done
  done
}

get_game_name() {
  local id=$1
  local cached_name=$(grep "^GAME|${id}|" "$CACHE_FILE" | cut -d'|' -f3)

  if [ -n "$cached_name" ]; then
    echo "$cached_name"
  else
    # Fetch from Steam Store API
    local name=$(curl -s "https://store.steampowered.com/api/appdetails?appids=$id" | jq -r ".\"$id\".data.name")
    
    if [ "$name" == "null" ] || [ -z "$name" ]; then
      name="Unknown Game ($id)"
    fi
    
    echo "GAME|${id}|${name}" >> "$CACHE_FILE"
    echo "$name"
  fi
}



# === FLAG HANDLING ===
while getopts "a:sch" opt; do
  case ${opt} in
    a )
      new_path="${OPTARG/#\~/$HOME}"
      [[ "$new_path" != */ ]] && new_path="$new_path/"
      if [ -d "$new_path" ]; then
        echo "PATH|$new_path" >> "$CACHE_FILE"
        echo "Added $new_path to cache."
      else
        echo "Error: Directory $new_path does not exist."
      fi
      ;;
    s ) discover_paths ;;
    c ) rm -f "$CACHE_FILE"; echo "Cache cleared."; exit 0 ;;
    h ) usage ;;
    * ) usage ;;
  esac
done
shift $((OPTIND -1))



# === INITIALIZATION ===
if ! grep -q "^PATH|" "$CACHE_FILE"; then
  echo "--- clean-proton Setup ---"
  discover_paths

  while ! grep -q "^PATH|" "$CACHE_FILE"; do
    echo -e "\nPlease manually enter a compatdata path (Example: /media/games/SteamLibrary/steamapps/compatdata/)"
    read -p "Path: " user_path
    user_path="${user_path/#\~/$HOME}"
    [[ "$user_path" != */ ]] && user_path="$user_path/"

    if [ -d "$user_path" ] && [[ "$user_path" == *"compatdata/"* ]]; then
      echo "PATH|$user_path" >> "$CACHE_FILE"
      read -p "Add another? [y/N]: " more
      [[ ! "$more" =~ ^[Yy]$ ]] && break
    else
      echo "Invalid directory."
    fi
  done
fi



# === MAIN SCAN ===
DIRS=($(grep "^PATH|" "$CACHE_FILE" | cut -d'|' -f2))
apps=()
i=1

echo "Scanning Steam libraries..."
echo "----------------------------------------------------------------"

for COMPAT_DIR in "${DIRS[@]}"; do
  [ ! -d "$COMPAT_DIR" ] && continue
  for dir in "$COMPAT_DIR"*/; do
    appid=$(basename "$dir")
    [[ ! $appid =~ ^[0-9]+$ ]] && continue

    name=$(get_game_name "$appid")
    printf "[%2d] %-35s | ID: %s\n" "$i" "$name" "$appid"
    apps+=("$COMPAT_DIR|$appid|$name")
    ((i++))
  done
done

echo "----------------------------------------------------------------"
if [ ${#apps[@]} -eq 0 ]; then
  echo "No prefixes found."
  exit 0
fi



# === MULTI-DELETION ===
read -p "Enter index number(s) to REMOVE (Example: 1 3 5) or 'q' to quit: " -a choices
[[ "${choices[0]}" == "q" ]] && exit 0

to_delete=()
for choice in "${choices[@]}"; do
  if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -lt "$i" ] && [ "$choice" -gt 0 ]; then
    to_delete+=("${apps[$((choice-1))]}")
  fi
done

if [ ${#to_delete[@]} -gt 0 ]; then
  echo -e "\n--- DELETION SUMMARY ---"
  for item in "${to_delete[@]}"; do
    echo "Target: $(echo "$item" | cut -d'|' -f3)"
  done
  
  read -p "Confirm deletion of ${#to_delete[@]} folders? [y/N]: " confirm
  if [[ $confirm =~ ^[Yy]$ ]]; then
    for item in "${to_delete[@]}"; do
      path=$(echo "$item" | cut -d'|' -f1)
      id=$(echo "$item" | cut -d'|' -f2)
      rm -rf "$path$id"
      echo "Deleted $id"
    done
    echo "Cleanup finished."
  else
    echo "Aborted."
  fi
fi
