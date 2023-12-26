#!/bin/bash

# bash -c "nohup caffeinate -u -i -d &"
# ps aux -o ppid | grep caffeinate
# launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
# launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist


# https://fig.io
# https://ohmyz.sh
# https://stackoverflow.com/questions/27379507/creating-and-writing-into-plist-with-terminal-or-bash-script


source /usr/local/bin/PlugNPlayMac/PNPMacParam.sh

# Password for usce bclm
myPassword=$(getPW)
# CPU Architecture (Intel: x86_64 --- Apple Silicon: arm64) 
isAppleSilicon=$(detect_cpu_architecture)

log_error "" "$isAppleSilicon" "Start the PlugNPlayMac script"

while true; do

    # Mode
    isDisplayFound=false
    isWifiFound=false
    isSleep=false

    # Return the name of the wifi connected to the mac
    commandDetectWifi="/Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}'"
    currentWifi=$(eval "$commandDetectWifi")
    # echo "$currentWifi"

    if $isAppleSilicon; then

        # Get the complete output of system_profiler SPDisplaysDataType
        display_info=$(system_profiler SPDisplaysDataType)
        # Extract display names
        display_names_and_resolutions=$(echo "$display_info" | awk '/Displays:/{p=1; next} p && /^$/{p=0} p && !/^$/ && $1 != "Display" {if ($1 == "Display") name=$2; else if ($1 == "Resolution:") print name, prev_line} {prev_line = $0}')
        # Use sed to remove trailing colons from names, "Display Type:" and leading spaces in lines
        currentDisplay=$(echo "$display_names_and_resolutions" | sed -e 's/:$//' -e 's/Display Type: //' -e 's/^[[:space:]]*//')
        # Print display names and their respective resolutions
        # echo "$currentDisplay"

        # Get the complete output of system_profiler SPDisplaysDataType
        display_info=$(system_profiler SPDisplaysDataType)

        # Count the occurrences of "Display Asleep: Yes" and "Display Asleep: No"
        count_asleep=$(echo "$display_info" | grep -c "Display Asleep: Yes")
        count_awake=$(echo "$display_info" | grep -c "Display Asleep: No")

    else
        # Return the name of the different display connected to the mac
        # If the built in display is connected but close it doesn't appear
        commandDetectDisplay="ioreg -lw0 | grep 'IODisplayEDID' | sed '/[^<]*</s///' | xxd -p -r | strings -10"
        currentDisplay=$(eval "$commandDetectDisplay")
        # echo "$currentDisplay"

        commandSleepStatus='echo $(ioreg -n IODisplayWrangler | grep -i IOPowerManagement | perl -pe '\''s/^.*DevicePowerState"=([0-9]+).*$/\1/'\'')/4 | bc'
        sleepStatus=$(eval "$commandSleepStatus")
        # echo "$sleepStatus"

    fi

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
    if [[ "$sleepStatus" -eq 0 && "$isAppleSilicon" == false ]]; then
        isSleep=true

    elif [[ $count_asleep -gt 0 && $count_awake -eq 0 && "$isAppleSilicon" == true ]]; then
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

                pkill caffeinate
                # Launch a nohup caffeinate for run caffeinate in background
                # This prevent the mac to sleep
                # "man caffeinate" for more information
                (nohup caffeinate -u -i -d & wait 2>/dev/null) &
                # save the caffeinate process ID
                PMSETPID=$!

                log_error "S1" "$isAppleSilicon" "Starting caffeinate with ID: $PMSETPID"

                isRunning=true
                isCaffeinate=true
            fi

            # Open each application in the list
            for applicationName in "${listAppToOpen[@]}"; do
                if ! open -a "$applicationName" 2>&1 | grep -q "Unable to find application named '$applicationName'"; then
                    log_error "S2" "$isAppleSilicon" "Starting the APP: $applicationName"
                else
                    notFoundedApp+=("$applicationName")
                    log_error "E2" "$isAppleSilicon" "Unable to find the APP: $applicationName"
                fi
            done

            areAppsOpen=true
            batteryResult=0

            if [ $isBclm == false ]; then

                # More info on BCLM here: https://github.com/zackelia/bclm
                # Overwrite battery value and set the new value for the battery limit
                chmod +x "$parentPath/bclm"

                if $isAppleSilicon; then
                    #FOR APPLE SILICON THE VALUE MUST BE 80 or 100
                    batteryValue=80
                fi

                # Prompt for the password and provide it to sudo without displaying it
                writtenResult=$(echo "$myPassword" | sudo -S "$parentPath/bclm" write "$batteryValue" 2>&1)

                if [ $? -eq 0 ]; then
                    log_error "S4" "$isAppleSilicon" "Value $batteryValue written successfully"
                fi

                # Apply the persistence for the new battery limit
                error_message=$(echo "$myPassword" | sudo -S "$parentPath/bclm" persist 2>&1)

                if [ $? -eq 0 ]; then
                    log_error "S5" "$isAppleSilicon" "Persistence has bean activte"
                fi

                # Read the current battery value
                batteryResult="$("$parentPath/bclm" read)"
                log_error "S6" "$isAppleSilicon" "Result of bclm read: $batteryResult"

                if [ "$batteryResult" = "$batteryValue" ]; then
                    isBclm=true
                fi
            fi

        elif [[ $isRunning == true && $isSleep == true ]]; then
            if [ $isCaffeinate == true ]; then

                # Kill all the caffeinate process
                pkill caffeinate

                date_string=$(date +"%b %d %Y - %H:%M")

                # Check if any instances were killed
                if [ $? -eq 0 ]; then
                    log_error "S7" "$isAppleSilicon" "All caffeinate process killed successfully"
                else
                    log_error "E7" "$isAppleSilicon" "No caffeinate process found to kill"
                fi
                isCaffeinate=false
            fi

        elif [[ $isRunning == true && $isSleep == false ]]; then
            if [ $isCaffeinate == false ]; then

                 # If is passed less than 10 minutes from the last user interaction
                # Needed for prevent the mac start caffeinate when the user is not using the mac
                if [ "$idle_time_minutes" -lt 10 ]; then

                    pkill caffeinate
                    (nohup caffeinate -u -i -d & wait 2>/dev/null) &
                    # save the caffeinate process ID
                    PMSETPID=$!

                    log_error "S8" "$isAppleSilicon" "Starting caffeinate with ID: $PMSETPID"
                    isCaffeinate=true
                fi
            fi
        fi

    elif [ $isDisplayFound == false ]; then
        if [ $isRunning == true ]; then

            # Kill all the caffeinate process
            pkill caffeinate

            # Check if any instances were killed
            if [ $? -eq 0 ]; then
                log_error "S9" "$isAppleSilicon" "All caffeinate process killed successfully"
            else
                log_error "E9" "$isAppleSilicon" "No caffeinate process found to kill"
            fi

            isRunning=false
            isCaffeinate=false

            # Close each application in the list
            for applicationName in "${listAppToOpen[@]}"; do
                if [[ "${notFoundedApp[*]}" == *"$applicationName"* ]]; then
                    notFoundedApp=("${notFoundedApp[@]/$applicationName}")
                    echo "$date_string: $applicationName (E1) not found"
                    log_error "E10" "$isAppleSilicon" "$applicationName not found"
                else
                    (osascript -e "tell application \"$applicationName\" to quit" & wait) 2>/dev/null
                    log_error "S10" "$isAppleSilicon" "$applicationName closed correctly"
                fi
            done

            areAppsOpen=false
            batteryResult=0

            if [ $isBclm == true ]; then

                 # Remove persistence on the battery for set the default value
                error_message=$(echo $myPassword | sudo -S "$parentPath/bclm" unpersist 2>&1)
                date_string=$(date +"%b %d %Y - %H:%M")

                if [ $? -eq 0 ]; then
                    log_error "S12" "$isAppleSilicon" "Persistence has bean disabled"
                fi

                # Write the original value
                writtenResult=$(echo $myPassword | sudo -S "$parentPath/bclm" write 100)
                # Remove the plist file of BCLM for prevent problem with the default value
                rmFile=$(echo $myPassword | sudo -S rm /Library/LaunchDaemons/com.zackelia.bclm.plist)

                batteryResult="$("$parentPath/bclm" read)"
                log_error "S13" "$isAppleSilicon" "Result of bclm read: $batteryResult"

                if [ "$batteryResult" = "100" ]; then
                    isBclm=false
                fi
            fi
        fi
    fi
    
    sleep $seconds4Delay

done