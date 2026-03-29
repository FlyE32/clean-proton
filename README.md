clean-proton

clean-proton is a lightweight Bash utility designed for Linux gamers to manage orphaned, bloated, or problematic Steam Proton compatdata (prefixes). It automatically maps cryptic Steam AppIDs to human-readable game names using the Steam Web API and provides an interactive interface for safe, multi-selection deletion.

Features:

    Auto-Discovery: Scans all mounted drives to find Steam libraries automatically.

    Persistent Caching: Remembers your library paths and game names to ensure near-instant subsequent runs.

    Steam Web API Integration: Fetches accurate game titles directly from Steam.

    Multi-Select Deletion: Remove multiple prefixes at once by entering their index numbers.

    Zero-Config Setup: Guided first-run experience to get you started in seconds.

Installation

    Clone the repository:

    git clone https://github.com/FlyE32/clean-proton.git
    cd clean-proton

    Make the script executable:
    Bash

    chmod +x clean-proton.sh

    Ensure dependencies are installed:

        jq (for JSON parsing)

        curl (for API communication)

        util-linux (for mount detection)

Usage

Simply run the script to start the interactive scanner:

./clean-proton.sh

Command Line Flags
Flag	Description
-a <path>	Manually add a specific compatdata directory to the cache.
-s	Force a re-scan of all mounted drives for new Steam libraries.
-c	Clear the local cache file (~/.clean-proton-cache.txt).
-h	Show the help menu.

Cache Information

The script stores configuration and game name mappings in:
~/.clean-proton-cache.txt

The file format is simple and human-readable:

    PATH|... stores your library locations.

    GAME|AppID|Name stores the cached API results.

You can append information directly to the .clean-proton-cache.txt file if you so choose.

License

This project is licensed under the GPL v3 License (or MIT, depending on your choice). See the LICENSE file for details.

Pro-Tip: Adding to your Path

If you want to run this from anywhere on your Arch system (like clean-proton instead of ./clean-proton.sh), move the script to your local bin:
Bash

sudo cp clean-proton.sh /usr/local/bin/clean-proton

