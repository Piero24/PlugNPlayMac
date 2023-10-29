#!/bin/bash

# test

# bash -c "nohup caffeinate -u -i -d &"
# ps aux -o ppid | grep caffeinate
# launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
# launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
#
# BEFORE STARTING THE SCRIPT WITH launchctl load YOU MAST GIV FULL DISK ACCESS TO /BIN/BASH AND BCLM

# source /usr/local/bin/PlugNPlayMac/PNPMacParam.sh
source /Users/pietrobon/Documents/Developer/GitHub/PlugNPlayMac/personalParam.sh

myPassword=$(getPW)
# ID of the last active caffeinate process (0 at start of the script)
PMSETPID=0
# Flag for know if the script is active
isAlreadyOn=0
# mkdir ~/Mac\ Studio \Setup
parentPath=/usr/local/bin/PlugNPlayMac
# CPU Architecture (Intel: x86_64 --- Apple Silicon: arm64) 
isAppleSilicon=false
architecture=$(uname -m)

if [[ "$architecture" == *"arm64"* ]]; then
    isAppleSilicon=true

elif [[ "$architecture" == *"x86_64"* ]]; then
    isAppleSilicon=false

else
    date_string=$(date +"%d %b %Y - %H:%M")
    echo "$date_string: Problem during the detection of the CPU architecture"
    exit 1

fi

while true; do

    isDisplayFound=false;
    isWifiFound=false;
    isSleep=false

    # Return the name of the different display connected to the mac
    # If the built in display is connected but close it doesn't appear
    commandDetectDisplay="ioreg -lw0 | grep 'IODisplayEDID' | sed '/[^<]*</s///' | xxd -p -r | strings -10"
    currentDisplay=$(eval "$commandDetectDisplay")
    # echo "$currentDisplay"

    # Return the name of the wifi connected to the mac
    commandDetectWifi="/Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}'"
    currentWifi=$(eval "$commandDetectWifi")
    # echo "$currentWifi"
    
    # Return the curret battery percentage
    # commandDetectBattery="pmset -g batt | grep -Eo \"\\d+%\" | cut -d% -f1"
	# currentBattery=$(eval "$commandDetectBattery")
    # echo "$currentBattery"

    # Iterate through the list of display names
    # Set isDisplayFound to true if there is a match on the display
    for displayName in "${listDisplayNames[@]}"; do
        if [[ "$currentDisplay" == *"$displayName"* ]]; then
            isDisplayFound=true
            break
        fi
    done

    # Iterate through the list of wifi names
    # Set isWifiFound to true if there is a match on the wifi
    for wifiName in "${listWifiNames[@]}"; do
        if [[ "$currentWifi" == *"$wifiName"* ]]; then
            isWifiFound=true
            break
        fi
    done

    # If the script is not already active but the display is connected and the mac connected to the wifi
    if [[ $isAlreadyOn -eq 0 && $isDisplayFound == true && $isWifiFound == true ]]; then

        # Launch a nohup caffeinate for run caffeinate in background
        # This prevent the mac to sleep
        # "man caffeinate" for more information
        (nohup caffeinate -u -i -d & wait 2>/dev/null) &
        # save the caffeinate process ID
        PMSETPID=$!
        # kill $PMSETPID
		
		isAlreadyOn=1;

        date_string=$(date +"%d %b %Y - %H:%M")
        echo "$date_string: Starting caffeinate with ID: $PMSETPID"

        # Open each application in the list
        for applicationName in "${listAppToOpen[@]}"; do
            ate_string=$(date +"%d %b %Y - %H:%M")
            if ! open -a "$applicationName" 2>&1 | grep -q "Unable to find application named '$applicationName'"; then
                echo "$date_string: Starting the APP: $applicationName"
            else
                echo "$date_string: Unable to find the APP: $applicationName"
            fi
        done

        if $isAppleSilicon; then
            # At this moment the battery doesn't set the new charge limit
            # on Apple Silicon. This is because the BCLM script doesn't 
            # work on Apple Silicon. 
            echo "$date_string: Not done yet for Apple Silicon"
        else
            # More info on BCLM here: https://github.com/zackelia/bclm
            # Overwrite battery value and set the new value for the battery limit
            echo $myPassword | sudo -S chmod +x "$parentPath/bclm"
            echo $myPassword | sudo -S "$parentPath/bclm" write "$batteryValue"
            # Apply the persistence for the new battery limit
            error_message=$(echo "$myPassword" | sudo -S "$parentPath/bclm" persist 2>&1)

            date_string=$(date +"%d %b %Y - %H:%M")

            if [ $? -eq 0 ]; then
                echo ""
                echo "$date_string: Persistence has bean activte"
            fi

            # Read the current battery value
            result="$("$parentPath/bclm" read)"
            echo "$date_string: Result of bclm read: $result"
        fi

    fi
    
    # If the script is already active but the display isn't connected
    if [[ $isAlreadyOn -eq 1 && $isDisplayFound == false ]]; then

        isAlreadyOn=0;

        # Kill all the caffeinate process
        pkill caffeinate

        date_string=$(date +"%d %b %Y - %H:%M")

        # Check if any instances were killed
        if [ $? -eq 0 ]; then
            echo "$date_string: All caffeinate process killed successfully"
        else
            echo "$date_string: No caffeinate process found to kill"
        fi

        # Close each application in the list
        for applicationName in "${listAppToOpen[@]}"; do
            (osascript -e "tell application \"$applicationName\" to quit" & wait) 2>/dev/null
            date_string=$(date +"%d %b %Y - %H:%M")
            echo "$date_string: $applicationName closed correctly"
        done

        if $isAppleSilicon; then
            echo "$date_string: Not done yet for Apple Silicon"
        else

            # Remove persistence on the battery for set the default value
            error_message=$(echo $myPassword | sudo -S "$parentPath/bclm" unpersist 2>&1)
            date_string=$(date +"%d %b %Y - %H:%M")

            if [ $? -eq 0 ]; then
                echo "$date_string: Persistence has bean disabled"
            fi

			# Write the original value
            echo $myPassword | sudo -S "$parentPath/bclm" write 100
			# Remove the plist file of BCLM for prevent problem with the default value
            echo $myPassword | sudo -S rm /Library/LaunchDaemons/com.launch.plug.and.play.mac.bclm.plist
        fi
    fi

    # This part untill the "sleep $seconds4Delay" is only for precaution. In case the mac
    # After receiving the sleep command from the menu bar don't goes correctly in sleep mode.
    # It will kill caffeinate in case of problem for help the mac to go in sleep mode correctly.

    # Check if the display is in sleep mode
    # If yes, kill the caffeinate process and set the sleep flag to true
    if system_profiler SPDisplaysDataType | grep -q "Display Asleep: Yes"; then
        isSleep=true
        sleep 30
        pkill caffeinate

        date_string=$(date +"%d %b %Y - %H:%M")
        
        if [ $? -eq 0 ]; then
            echo "$date_string: All caffeinate process killed successfully"
        else
            echo "$date_string: No caffeinate process found to kill"
        fi

    fi
    
    # Costantly check if the display is in sleep mode.
    while [ "$isSleep" == true ]; do
        # When the status change from sleep to awake, start a new caffeinate process
        if ! system_profiler SPDisplaysDataType | grep -q "Display Asleep: Yes"; then
            isSleep=false
            (nohup caffeinate -u -i -d & wait 2>/dev/null) &
            # save the caffeinate process ID
            PMSETPID=$!

            date_string=$(date +"%d %b %Y - %H:%M")
            echo "$date_string: Starting caffeinate with ID: $PMSETPID"

        else 
            sleep 30

        fi
    done

    sleep $seconds4Delay

    # Get the creation date of a file
    creation_date=$(GetFileInfo -d /private/tmp/plug.and.play.mac.log | cut -d ' ' -f 1)

    # Get the current date
    current_date=$(date +"%m/%d/%Y")

    # Convert the dates to timestamps using the 'date' command
    timestamp1=$(date -j -f "%m/%d/%Y" "$creation_date" "+%s" 2>/dev/null)
    timestamp2=$(date -jf "%m/%d/%Y" "$current_date" "+%s")

    date_string=$(date +"%d %b %Y - %H:%M")

    if [ -n "$timestamp1" ] && [ -n "$timestamp2" ]; then
        # Calculate the time difference in seconds
        difference=$((timestamp2 - timestamp1))

        # Calculate the number of days in the time difference
        days_difference=$((difference / 86400))  # 86400 seconds in a day

        if [ "$days_difference" -ge 10 ]; then
            # Delete the log file
            rm /private/tmp/plug.and.play.mac.log
            echo "$date_string: Log file deleted"
        fi
    else
        echo "$date_string:Date conversion error"
    fi

done