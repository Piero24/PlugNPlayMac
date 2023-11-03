# Add more displays to the script

<br/>

By adding more displays to the script you will be able to automate this task also when you plag other monitors to your Mac. If when you plug the second monitor you are under the same wifi network con can just add the display name as is explaned below and skip the part of the wifi name. If you are not under the same wifi network you have to add also the wifi name as is explaned below.

## Add displays
1. Connect the macbook to your monitor open the terminal and run the following commands:
    - ```sh
        ioreg -lw0 | grep 'IODisplayEDID' | sed '/[^<]*</s///' | xxd -p -r | strings -10
        ```
        It will return the name of the monitor seen by the Mac. In my case, it is `SECOND DISPLAY`.

2. Open the `PNPMacParam.sh` file and edit the following variables:
    - ```sh
        listDisplayNames=("FIRST DISPLAY")
        ```

    Where `listDisplayNames` are the list of monitors that trigger the script, So in my case, the values are:
    ```sh
        listDisplayNames=("FIRST DISPLAY" "SECOND DISPLAY")
    ```
3. Save exit and restart the script with the command:
```sh 
launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
```

## Add Wifi
1. Connect the macbook to your wifi open the terminal and run the following commands:
    - ```sh
        /Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}'
        ```
        It will return the name of the wifi seen by the Mac. In my case, it is `FIRST WIFI`.

2. Open the `PNPMacParam.sh` file and edit the following variables:
    - ```sh
        listWifiNames=("FIRST WIFI") 
        ```

    Where `listWifiNames` is the list of Wi-Fi networks and `listDisplayNames` are the list of monitors that trigger the script, `listAppToOpen` is the list of apps to open, `batteryValue` is the battery limit for `bclm` (must be less or equal to 100), and `accountUser` is the name of the user account on your Mac. So in my case, the values are:
    ```sh
        listWifiNames=("FIRST WIFI" "SECOND WIFI")
    ```
3. Save exit and restart the script with the command:
```sh 
launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
```