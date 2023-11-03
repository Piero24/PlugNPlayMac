# List of Wi-Fi names
listWifiNames=("Vodafone-A45682606" "Other Wifi Name")
# List of Display names
listDisplayNames=("LG IPS FULLHD" "Other Display Name")
# List of Apps to open
listAppToOpen=("MonitorControl" "Elgato Stream Deck" "Other App Name")
# Username of the account to use for sudo operation
accountUser="Andrea Pietrobon"
# Max battery level when connected
batteryValue=77








# security add-generic-password -s 'CLI Test'  -a 'armin' -w 'password123'




##########################################################################
#
# DO NOT MODIFY THE CODE BELOW THIS LINE
#
##########################################################################

# Delay in seconds (default 60 seconds)
seconds4Delay=60

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


getPW() {
    # Take the password from apple Keychain for operate the sudo operation

    local my_var
    my_var=$(security find-generic-password -w -s "PlugNPlayMac" -a "$accountUser")
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
