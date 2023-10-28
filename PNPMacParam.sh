# List of Wi-Fi names
listWifiNames=("Wifi Name" "Other Wifi Name") 
# List of Display names
listDisplayNames=("Display Name" "Other Display Name")
# List of Apps to open
listAppToOpen=("App Name" "Other App Name" "Other App Name")
# Max battery level when connected
batteryValue=77
# Delay in seconds (default 60 seconds)
seconds4Delay=60
# Username of the account to use for sudo operation
accountUser="MY USERNAME"

# security add-generic-password -s 'CLI Test'  -a 'armin' -w 'password123'


getPW() {
    # Take the password from apple Keychain for operate the sudo operation
    # 
    local my_var
    my_var=$(security find-generic-password -w -s "PlugNPlayMac" -a "$accountUser")
    echo "$my_var"
}