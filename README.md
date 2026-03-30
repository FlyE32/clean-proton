<h1>clean-proton</h1>

<h2>👋 Welcome to clean-proton!</h2>
clean-proton is a friendly, lightweight Bash utility designed specifically for Linux gamers. It helps you find and clear out orphaned, bloated, or tempermental Proton prefixes (compatdata) without the headache of hunting down cryptic AppIDs.

<br><h3>Why use clean-proton?</h3>

<ul>
    <li>Auto-Discovery: No need to hunt for folders. It scans your mounted drives to find Steam libraries automatically.</li>
    <li>Human-Readable: It talks to the Steam Web API to turn those confusing numbers (AppIDs) into actual game titles.</li>
    <li>Near-Instant: Persistent caching remembers your library paths and game names for lightning-fast subsequent runs.</li>
    <li>Safe & Interactive: Pick exactly what you want to remove using an easy multi-select interface.</li>
    <li>Zero-Config: A guided first-run experience gets you up and running in seconds.</li>
</ul>

<br><h3>⚠️WARNING⚠️</h3>
If your steam game is not using steam cloud to back up your save files. Deleting the Proton Prefix **CAN DELETE YOUR SAVE DATA**. If you would like to back up this save data, be sure to do so before deleting the prefix folder.

<br><h3>Installation</h3><br>
Getting started is easy! Just follow these steps:<br>

<ol>
<li>Download dependecies</li>
    
    jq (for reading data)
    curl (to talk to Steam)
    util-linux (to find your drives)  
    
<li>Clone the repo:</li>
    
    git clone https://github.com/FlyE32/clean-proton.git
    cd clean-proton
    
<li>Make it executable:</li>
    
    chmod +x clean-proton.sh        
</ol>

<br>One line install for dependencies and git repo:

Arch:

    pacman -S --needed jq curl util-linux && git clone https://github.com/FlyE32/clean-proton.git && cd clean-proton && chmod +x clean-proton.sh

Debian / Ubuntu / Mint / Pop!_OS:

    apt update && sudo apt install -y jq curl util-linux git && git clone https://github.com/FlyE32/clean-proton.git && cd clean-proton && chmod +x clean-proton.sh

Fedora

    dnf install -y jq curl util-linux git && git clone https://github.com/FlyE32/clean-proton.git && cd clean-proton && chmod +x clean-proton.sh

openSUSE (Tumbleweed/Leap)

    zypper install -y jq curl util-linux git && git clone https://github.com/FlyE32/clean-proton.git && cd clean-proton && chmod +x clean-proton.sh
    
<br><h3>Usage</h3>
Simply launch the script to start the interactive scanner:

    ./clean-proton.sh


<br><h3>Command Line Flags</h3>

|   Flag   |                         Description                         | 
|----------|-------------------------------------------------------------|
|-a <path> | Manually add a specific compatdata directory to your cache. |
|-s	       | Force a fresh scan of all mounted drives for new libraries. |
|-c	       | Clear your local cache file.                                |
|-h	       | Show the help menu.                                         |


<br><h3>Cache Information</h3>
To keep things fast, the script stores your settings and game names in:<br>
<br>~/.clean-proton-cache.txt<br>
<br>The file is simple and human-readable. If you're comfortable, feel free to append your own paths or game mappings directly to the file!

<br><h3>Run it from anywhere</h3>
If you want to run the tool by just typing clean-proton from any folder, move it to your local bin:

    sudo cp clean-proton.sh /usr/local/bin/clean-proton

Use code with caution.

<br><h3>License</h3>
This project is shared under the GPL v3 License. Feel free to use it, tweak it, and share it!
