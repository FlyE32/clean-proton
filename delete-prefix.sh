#!/bin/bash

# List of directories to scan, add another line to scan that directory
DIRS=(
    "/home/cam/.steam/steam/steamapps/compatdata/"
    "/media/games/SteamLibrary/steamapps/compatdata/"
    "/media/linux-storage/SteamLibrary/steamapps/compatdata/"
)

# Array to store prefix data
apps=()
i=1

echo "Scanning Steam libraries for Proton prefixes..."
echo "----------------------------------------------------------------"

for COMPAT_DIR in "${DIRS[@]}"; do
    # Skip if directory doesn't exist
    if [ ! -d "$COMPAT_DIR" ]; then
        continue
    fi

    echo "Checking: $COMPAT_DIR"

    for dir in "$COMPAT_DIR"*/; do
        # Extract AppID from folder name
        appid=$(basename "$dir")
        
        # Ensure it's a numeric AppID (skips things like 'shadercache')
        if ! [[ $appid =~ ^[0-9]+$ ]]; then continue; fi

        # Fetch game name via Steam API
        name=$(curl -s "https://store.steampowered.com/api/appdetails?appids=$appid" | jq -r ".\"$appid\".data.name")

        # Fallback for hidden or unknown IDs
        if [ "$name" == "null" ] || [ -z "$name" ]; then
            name="Unknown Game (AppID: $appid)"
        fi

        # Print with index and store full path for deletion
        printf "[%2d] %-30s | Path: %s\n" "$i" "$name" "$COMPAT_DIR"
        apps+=("$COMPAT_DIR|$appid|$name")
        ((i++))
    done
done

echo "----------------------------------------------------------------"

if [ ${#apps[@]} -eq 0 ]; then
    echo "No prefixes found. Check if your drives are mounted."
    exit 0
fi

read -p "Enter the index number to REMOVE (or 'q' to quit): " choice

# Validate selection
if [[ $choice =~ ^[0-9]+$ ]] && [ "$choice" -lt "$i" ] && [ "$choice" -gt 0 ]; then
    # Parse the stored data
    selected_data=${apps[$((choice-1))]}
    final_path=$(echo "$selected_data" | cut -d'|' -f1)
    final_id=$(echo "$selected_data" | cut -d'|' -f2)
    final_name=$(echo "$selected_data" | cut -d'|' -f3)

    echo -e "\nTARGET: $final_name ($final_id)"
    echo "LOCATION: $final_path$final_id"
    read -p "Confirm deletion? [y/N]: " confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$final_path$final_id"
        echo "Successfully removed the proton prefix folder for $final_name."
    else
        echo "Aborted."
    fi
else
    echo "Exiting."
fi
