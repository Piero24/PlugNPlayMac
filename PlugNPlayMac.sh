#!/bin/bash

# bash -c "nohup caffeinate -u -i -d &"
# ps aux -o ppid | grep caffeinate
# launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
# launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist

# source /usr/local/bin/PlugNPlayMac/PNPMacParam.sh
source /Users/pietrobon/Documents/Developer/GitHub/PlugNPlayMac/personalParam.sh

# Password for usce bclm
myPassword=$(getPW)
# CPU Architecture (Intel: x86_64 --- Apple Silicon: arm64) 
isAppleSilicon=$(detect_cpu_architecture)

date_string=$(date +"%b %d %Y - %H:%M")
echo "$date_string: Start the PlugNPlayMac script"

while true; do

    # Mode
    isDisplayFound=false
    isWifiFound=false
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

    commandSleepStatus='echo $(ioreg -n IODisplayWrangler | grep -i IOPowerManagement | perl -pe '\''s/^.*DevicePowerState"=([0-9]+).*$/\1/'\'')/4 | bc'
    sleepStatus=$(eval "$commandSleepStatus")
    # echo "$sleepStatus"

    # Set isDisplayFound to true if there is a match on the display
    for displayName in "${listDisplayNames[@]}"; do
        if [[ "$currentDisplay" == *"$displayName"* ]]; then
            isDisplayFound=true
            break
        fi
    done

    # Set isWifiFound to true if there is a match on the wifi
    for wifiName in "${listWifiNames[@]}"; do
        if [[ "$currentWifi" == *"$wifiName"* ]]; then
            isWifiFound=true
            break
        fi
    done

    # Set isRunning to false if the sleep is active
    if [ "$sleepStatus" -eq 0 ]; then
        isSleep=true
    fi

    # Get the timestamp of the last user interaction from the idle time
    idle_time_seconds=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')
    idle_time_minutes=$((idle_time_seconds / 60))
    # date_string=$(date +"%b %d %Y - %H:%M")
    # echo "$date_string: Last interaction was $idle_time_seconds seconds ago and $idle_time_minutes minutes ago"

    if [[ $isDisplayFound == true && $isWifiFound == true ]]; then    
        if [[ $isRunning == false && $isSleep == false ]]; then

            # If is passed less than 10 minutes from the last user interaction
            # Needed for prevent the mac start caffeinate when the user is not using the mac
            if [ "$idle_time_minutes" -lt 10 ]; then

                # Launch a nohup caffeinate for run caffeinate in background
                # This prevent the mac to sleep
                # "man caffeinate" for more information
                (nohup caffeinate -u -i -d & wait 2>/dev/null) &
                # save the caffeinate process ID
                PMSETPID=$!

                date_string=$(date +"%b %d %Y - %H:%M")
                echo "$date_string: (S1) Starting caffeinate with ID: $PMSETPID"

                isRunning=true
                isCaffeinate=true
            fi

            # Open each application in the list
            for applicationName in "${listAppToOpen[@]}"; do
                date_string=$(date +"%b %d %Y - %H:%M")
                if ! open -a "$applicationName" 2>&1 | grep -q "Unable to find application named '$applicationName'"; then
                    echo "$date_string: (S1) Starting the APP: $applicationName"
                else
                    notFoundedApp+=("$applicationName")
                    echo "$date_string: (E1) Unable to find the APP: $applicationName"
                fi
            done

            areAppsOpen=true
            batteryResult=0

            if $isAppleSilicon; then
                # At this moment the battery doesn't set the new charge limit
                # on Apple Silicon. This is because the BCLM script doesn't 
                # work on Apple Silicon. 
                date_string=$(date +"%b %d %Y - %H:%M")
                echo "$date_string: (E1) Not done yet for Apple Silicon"

            else

                date_string=$(date +"%b %d %Y - %H:%M")
                
                # More info on BCLM here: https://github.com/zackelia/bclm
                # Overwrite battery value and set the new value for the battery limit
                chmod +x "$parentPath/bclm"
                writtenResult=$(echo $myPassword | sudo -S "$parentPath/bclm" write "$batteryValue")

                if [ $? -eq 0 ]; then
                    echo "$date_string: (S1) Value $batteryValue written successfully"
                fi

                date_string=$(date +"%b %d %Y - %H:%M")
                # Apply the persistence for the new battery limit
                error_message=$(echo "$myPassword" | sudo -S "$parentPath/bclm" persist 2>&1)

                if [ $? -eq 0 ]; then
                    echo ""
                    echo "$date_string: (S1) Persistence has bean activte"
                fi

                # Read the current battery value
                batteryResult="$("$parentPath/bclm" read)"
                echo "$date_string: (S1) Result of bclm read: $batteryResult"
            fi

            if [ "$batteryResult" = "$batteryValue" ]; then
                isBclm=true
            fi

        elif [[ $isRunning == true && $isSleep == true ]]; then
            if [ $isCaffeinate == true ]; then

                # Kill all the caffeinate process
                pkill caffeinate

                date_string=$(date +"%b %d %Y - %H:%M")

                # Check if any instances were killed
                if [ $? -eq 0 ]; then
                    echo "$date_string: (E1) All caffeinate process killed successfully"
                else
                    echo "$date_string: (E1) No caffeinate process found to kill"
                fi

                isCaffeinate=false
            fi

        elif [[ $isRunning == true && $isSleep == false ]]; then
            if [ $isCaffeinate == false ]; then

                 # If is passed less than 10 minutes from the last user interaction
                # Needed for prevent the mac start caffeinate when the user is not using the mac
                if [ "$idle_time_minutes" -lt 10 ]; then

                    (nohup caffeinate -u -i -d & wait 2>/dev/null) &
                    # save the caffeinate process ID
                    PMSETPID=$!

                    date_string=$(date +"%b %d %Y - %H:%M")
                    echo "$date_string: (S2) Starting caffeinate with ID: $PMSETPID"

                    isCaffeinate=true
                fi
            fi
        fi

    elif [ $isDisplayFound == false ]; then
        if [ $isRunning == true ]; then

            # Kill all the caffeinate process
            pkill caffeinate

            date_string=$(date +"%b %d %Y - %H:%M")

            # Check if any instances were killed
            if [ $? -eq 0 ]; then
                echo "$date_string: (E2) All caffeinate process killed successfully"
            else
                echo "$date_string: (E2) No caffeinate process found to kill"
            fi

            isRunning=false
            isCaffeinate=false

            # Close each application in the list
            for applicationName in "${listAppToOpen[@]}"; do
                if [[ "${notFoundedApp[*]}" == *"$applicationName"* ]]; then
                    notFoundedApp=("${notFoundedApp[@]/$applicationName}")
                    date_string=$(date +"%b %d %Y - %H:%M")
                    echo "$date_string: $applicationName (E1) not found"
                else
                    (osascript -e "tell application \"$applicationName\" to quit" & wait) 2>/dev/null
                    date_string=$(date +"%b %d %Y - %H:%M")
                    echo "$date_string: $applicationName (E1) closed correctly"
                fi
            done

            areAppsOpen=false
            batteryResult=0

            if $isAppleSilicon; then
                date_string=$(date +"%b %d %Y - %H:%M")
                echo "$date_string: (E2) Not done yet for Apple Silicon"
            else

                # Remove persistence on the battery for set the default value
                error_message=$(echo $myPassword | sudo -S "$parentPath/bclm" unpersist 2>&1)
                date_string=$(date +"%b %d %Y - %H:%M")

                if [ $? -eq 0 ]; then
                    echo "$date_string: (E1) Persistence has bean disabled"
                fi

                # Write the original value
                writtenResult=$(echo $myPassword | sudo -S "$parentPath/bclm" write 100)
                # Remove the plist file of BCLM for prevent problem with the default value
                rmFile=$(echo $myPassword | sudo -S rm /Library/LaunchDaemons/com.launch.plug.and.play.mac.bclm.plist)

                batteryResult="$("$parentPath/bclm" read)"
                echo "$date_string: (S2) Result of bclm read: $batteryResult"
            fi

            if [ "$batteryResult" = "100" ]; then
                isBclm=false
            fi

        fi
    fi

    sleep $seconds4Delay

done