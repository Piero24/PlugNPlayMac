#!/bin/bash

#
# Start adding the values to the file PNPMacParam.sh
#

clear

# Function to display an error message as a popup
display_error() {
    osascript -e "display dialog \"$1\" buttons \"OK\" default button \"OK\" with title \"Error\""
}

if [ ! -e "/usr/local/bin/PlugNPlayMac/bclm" ]; then

    selectedDisplay=""

    process_lines() {
    local output="$1"

    # Initialize arrays for line numbers and lines
    line_numbers=()
    lines=()

    # Read each line and add it to the arrays, skipping empty or whitespace-only lines
    line_number=1
    while IFS= read -r line; do
        if [[ "$line" =~ [^[:space:]] ]]; then
        line_numbers+=("$line_number")
        lines+=("$line")
        ((line_number++))
        fi
    done <<< "$output"

    for i in "${!line_numbers[@]}"; do
        echo "${line_numbers[i]}) ${lines[i]}"
    done
    }

    # Using the process_lines function with ioreg command output
    output1=$(ioreg -lw0 | grep 'IODisplayEDID' | sed '/[^<]*</s///' | xxd -p -r | strings -10)
    process_lines "$output1"

    echo "Select the number of the display you want to use"

    # Prompt the user to select a line number and print the corresponding value
    while true; do
    read -p "Enter the line number to select or 'exit()' to quit: " user_choice
    if [[ "$user_choice" == "exit()" ]]; then
        echo "Exiting the script."
        exit 1
    fi

    valid_choice=false

    for i in "${!line_numbers[@]}"; do
        if [[ "${line_numbers[i]}" == "$user_choice" ]]; then
        selectedDisplay="${lines[i]}"
        valid_choice=true
        break
        fi
    done

    if $valid_choice; then
        break
    elif ! $valid_choice; then
        echo "Invalid line number. Please try again or enter 'exit()' to quit."
    fi
    done

    # Print the selectedWifi variable outside the loop
    # echo "Selected Display: $selectedDisplay"

    newVariable="listDisplayNames=(${selectedDisplay} )"
    sed -i '' -e "/^listDisplayNames=/s/.*/$newVariable/" ./PNPMacParam.sh

    clear

    selectedWifi=""

    # Using the process_lines function with airport command output
    output2=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID:/ {print $2}')
    process_lines "$output2"

    echo "Select the number of the wifi you want to use"

    # Prompt the user to select a line number and print the corresponding value
    while true; do
    read -p "Enter the line number to select or 'exit()' to quit: " user_choice
    if [[ "$user_choice" == "exit()" ]]; then
        echo "Exiting the script."
        exit 1
    fi

    valid_choice=false

    for i in "${!line_numbers[@]}"; do
        if [[ "${line_numbers[i]}" == "$user_choice" ]]; then
        selectedWifi="${lines[i]}"
        valid_choice=true
        break
        fi
    done

    if $valid_choice; then
        break
    elif ! $valid_choice; then
        echo "Invalid line number. Please try again or enter 'exit()' to quit."
    fi
    done

    # Print the selectedWifi variable outside the loop
    # echo "Selected Wifi: $selectedWifi"

    # variable=$(awk '/^listWifiNames=\(/{print; exit}' ./PNPMacParam.sh)
    # newVariable=$(echo "$variable" | sed 's/)//')
    # newVariable="${newVariable%)}"
    # newVariable="${newVariable}${selectedWifi} )"
    # sed -i '' -e "/^listWifiNames=/s/.*/$newVariable/" ./PNPMacParam.sh

    newVariable="listWifiNames=(${selectedWifi} )"
    sed -i '' -e "/^listWifiNames=/s/.*/$newVariable/" ./PNPMacParam.sh

    clear

    selectedApp="listAppToOpen=("

    while true; do
        echo "Enter the name of an application (type 'exit()' to quit, or 'end()' to display the list):"
        read app_name

        clear

        if [[ "$app_name" == "exit()" ]]; then
        echo "Exiting the script."
        exit 1
        elif [[ $app_name == "end()" ]]; then
            # echo "The list of entered applications:"
            selectedApp="$selectedApp)"
            # echo "$selectedApp"
            break
        else
            selectedApp="$selectedApp\"$app_name\" "
            echo "Application \"$app_name\" added to the list."
        fi
    done

    sed -i '' -e "/^listAppToOpen=/s/.*/$selectedApp/" ./PNPMacParam.sh

    clear

    # Declare the selectedBatteryValue variable
    selectedBatteryValue=""

    echo "Select the number of the battery value you want to use"

    # Prompt the user for an integer between 50 and 95
    while true; do
    read -p "Enter an integer between 50 and 95 or 'exit()' to quit: " user_input

    if [[ "$user_input" == "exit()" ]]; then
        echo "Exiting the script."
        exit 1
    fi

    # Check if the input is a valid integer between 50 and 95
    if [[ "$user_input" =~ ^[0-9]+$ ]] && ((user_input >= 50)) && ((user_input <= 95)); then
        selectedBatteryValue="$user_input"  # Store the selected value in the variable
        break
    else
        echo "Invalid line number. Please try again or enter 'exit()' to quit."
    fi
    done

    # Print the selectedBatteryValue variable
    # echo "Selected Battery Value: $selectedBatteryValue"

    newVariable="batteryValue=${selectedBatteryValue}"
    sed -i '' -e "/^batteryValue=/s/.*/$newVariable/" ./PNPMacParam.sh

    #
    # Start coping the files
    #


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

    sudo mv bclm /usr/local/bin/PlugNPlayMac
    if [ $? -ne 0 ]; then
        display_error "Error moving bclm"
        exit 1
    fi

    echo "All files moved/copied successfully."
fi

if [ ! -e "/usr/local/bin/PlugNPlayMac/com.launch.plug.and.play.mac.plist" ]; then

    chmod +x /usr/local/bin/PlugNPlayMac/PlugNPlayMac.sh
    source /usr/local/bin/PlugNPlayMac/PNPMacParam.sh

    accountUser=$(getUSR)

    echo "Please enter your password for the user $accountUser: "
    read usrpass

    security add-generic-password -s 'PlugNPlayMac' -a "$accountUser" -w "$usrpass"
    myPassword=$(getPW)

    if [[ $myPassword == *"The password doesn't exist yet"* ]]; then
        display_error "$myPassword"
    else
        echo "Password added successfully to Keychain"
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

    echo ".plist file created successfully."

    printf "\n*** NEED FULL DISK ACCESS ***
    1) Open System Settings > Privacy & Security > Full Disk Access
    2) Click on the plus icon at the bottom of the list and digit your password
    3) Press cmd + shift + G and digit /bin
    4) Select bash and click open
    5) Click again on the plus icon at the bottom of the list and digit your password
    6) Press cmd + shift + G and digit /usr/local/bin/PlugNPlayMac
    7) Select blcm and click open
    8) Reboot your Mac
    \n"

else

  # Define the path to the shell script
    shell_script="/usr/local/bin/PlugNPlayMac/PlugNPlayMac.sh"

    # Check if the script exists and is executable
    if [ -x "$shell_script" ]; then
        # Start the shell script
        bash "$shell_script"
    else
        display_error "The shell script '$shell_script' does not exist or is not executable."
        exit 1
    fi

    pkill caffeinate
    launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist

    echo "Done."
fi