# List of Display names
# You can add as many as you want (separated by a space)
# Ex: listDisplayNames=("Display Name" "Other Display Name")
listDisplayNames=()
# List of Wi-Fi names
# You can add as many as you want (separated by a space)
# Ex: listWifiNames=("Wifi Name" "Other Wifi Name") 
listWifiNames=()
# List of Apps to open
# You can add as many as you want (separated by a space)
# Ex: listAppToOpen=("App Name" "Other App Name" "Other App Name")
listAppToOpen=()
# Max battery level when connected (suggest 77)
batteryValue=77

##########################################################################
#
### DON'T MODIFY THE CODE BELOW THIS LINE
#
##########################################################################

# Delay in seconds (default 60 seconds)
seconds4Delay=60

# main script
isRunning=false
# Caffeinate
isCaffeinate=false
# BCLM
isBclm=false
# Apps
areAppsOpen=false

# ID of the last active caffeinate process (0 at start of the script)
PMSETPID=0
# main directory
parentPath=/usr/local/bin/PlugNPlayMac
# App not founded in the Application folder
notFoundedApp=()


getUSR() {
    # Take the full name of the user

    local my_var
    my_var=$(id -F)
    echo "$my_var"
}

# Get the full name of the user
accountUser=$(getUSR)

getPW() {
    # Take the password from Apple Keychain for operating the sudo operation

    local my_var
    my_var=$(security find-generic-password -w -s "PlugNPlayMac" -a "$accountUser" 2>/dev/null)

    if [[ -z $my_var ]]; then
        date_string=$(date +"%b %d %Y - %H:%M")
        echo "$date_string: The password doesn't exist yet"
    fi

    echo "$my_var"
}

detect_cpu_architecture() {

    architecture=$(uname -m)
    local my_var

    if [[ "$architecture" == *"arm64"* ]]; then
        my_var=true
    elif [[ "$architecture" == *"x86_64"* ]]; then
        my_var=false
    else
        date_string=$(date +"%b %d %Y - %H:%M")
        echo "$date_string: Problem during the detection of the CPU architecture"
        exit 1
    fi

    echo "$my_var"
}

log_error() {
    local msg_type="$1"
    local isAppleSilicon="$2"
    local msg_text="$3"
    local date_string=$(date +"%b %d %Y - %H:%M")

    if [ -n "$isAppleSilicon" ]; then
        echo "$date_string: (I$msg_type): $msg_text"
    else
        echo "$date_string: (A$msg_type): $msg_text"
    fi
}