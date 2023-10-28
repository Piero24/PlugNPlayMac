#!/bin/bash

# Function to display an error message as a popup
display_error() {
    osascript -e "display dialog \"$1\" buttons \"OK\" default button \"OK\" with title \"Error\""
}

# Make the directory for the PlugNPlayMac files
sudo mkdir /usr/local/bin/PlugNPlayMac
if [ $? -ne 0 ]; then
    display_error "Error creating PlugNPlayMac directory"
    exit 1
fi

# Move files to /usr/local/bin/PlugNPlayMac
sudo mv PlugNPlayMac.sh /usr/local/bin/PlugNPlayMac
if [ $? -ne 0 ]; then
    display_error "Error moving PlugNPlayMac.sh"
    exit 1
fi

sudo mv PNPMacParam.sh /usr/local/bin/PlugNPlayMac
if [ $? -ne 0 ]; then
    display_error "Error moving PNPMacParam.sh"
    exit 1
fi

# Copy the plist file to /Library/LaunchAgents
sudo cp com.launch.plug.and.play.mac.plist /Library/LaunchAgents
if [ $? -ne 0 ]; then
    display_error "Error copying com.launch.plug.and.play.mac.plist"
    exit 1
fi

# Move the plist file to /usr/local/bin/PlugNPlayMac
sudo mv com.launch.plug.and.play.mac.plist /usr/local/bin/PlugNPlayMac
if [ $? -ne 0 ]; then
    display_error "Error moving com.launch.plug.and.play.mac.plist"
    exit 1
fi

echo "All files moved/copied successfully."

chmod +x /usr/local/bin/PlugNPlayMac/PlugNPlayMac.sh

printf "\nLAST STEPS:\n\n"

printf "1) Digit on therminal /usr/local/bin/PlugNPlayMacPlugNPlayMac.sh ad enter your password
2) control + c to exit
3) Open System Settings > Privacy & Security > Full Disk Access
4) Click on the plus icon at the bottom of the list and digit your password
5) Press cmd + shift + G and digit /bin
6) Select bash and click open
7) Click again on the plus icon at the bottom of the list and digit your password
8) Press cmd + shift + G and digit /usr/local/bin/PlugNPlayMac
9) Select blcm and click open
10) Reboot your Mac
11) Open terminal and digit launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist\n"