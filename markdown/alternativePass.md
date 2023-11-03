# Change the password on keychain

<br/>


If you have insert the wrong password and you want to change it, you can do it in this way:
- Open the **Keychain Access** App <img align="center" src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/KeychainAccessIcon.png" width="100" height="100">

- Select Open Keychain Access <img align="center" src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/OpenedKey.png">

- Search the name **PlugNPlayMac** on the search bar
- Double click on the name **PlugNPlayMac**
- Click on the **Show password** checkbox
- Insert the password (the same that you use for login on your mac)
- Change the password with the new one
- Click on **Save Changes**
- Close the **Keychain Access** App

<br/>
<br/>

### NOTE:
If you want to delete the password from keychain, you can do it in this way:
As mentioned [here](https://apple.stackexchange.com/a/344380/460842) there is a bug on macOS that doesn't allow to delete the password from keychain if you have searched it on the search bar. So, if you want to delete the password, you have to do remove the name **PlugNPlayMac** from the search bar and then searching it manually.










2. Connect the macbook to your wifi and monitor open the terminal and run the following commands:
    - ```sh
        ioreg -lw0 | grep 'IODisplayEDID' | sed '/[^<]*</s///' | xxd -p -r | strings -10
        ```
        It will return the name of the monitor seen by the Mac. In my case, it is `LG IPS FULLHD`.
        <!--
        LP13--------2
        A0A00AAA00AA000AA
        LG IPS FULLHD
        -->
    - ```sh
        /Sy*/L*/Priv*/Apple8*/V*/C*/R*/airport -I | awk '/ SSID:/ {print $2}'
        ```
        It will return the name of the wifi seen by the Mac. In my case, it is `Home-Wifi-Name`.

3. Open the `PNPMacParam.sh` file and edit the following variables:
    - ```sh
        listWifiNames=("Wifi Name" "Other Wifi Name") 
        ```
    - ```sh
        listDisplayNames=("Display Name" "Other Display Name")
        ```
    - ```sh
        listAppToOpen=("App Name" "Other App Name")
        ```
    - ```sh
        batteryValue=77
        ```
    - ```sh
        accountUser="User Name"
        ```
    Where `listWifiNames` is the list of Wi-Fi networks and `listDisplayNames` are the list of monitors that trigger the script, `listAppToOpen` is the list of apps to open, `batteryValue` is the battery limit for `bclm` (must be less or equal to 100), and `accountUser` is the name of the user account on your Mac. So in my case, the values are:
    ```sh
        listWifiNames=("Home-Wifi-Name")
        listDisplayNames=("LG IPS FULLHD")
        listAppToOpen=("MonitorControl" "Elgato Stream Deck")
        batteryValue=77
        accountUser="MY USERNAME"
    ```
    Where `Home-Wifi-Name`and `LG IPS FULLHD` are the values founded before, `MonitorControl` and `Elgato Stream Deck` are the apps to open, `77` is the battery limit for `bclm`, and `MY USERNAME` is the name of the user account on my Mac. You can add as mach wifi, monitor, and app you want.
 

    **NOTE:** The `batteryValue` of <a href="https://github.com/zackelia/bclm">bclm</a> as mentioned it will be 3 point greather then the value setted in the script. So if you set `batteryValue=77` the battery limit will be 80.




3. Give the script the Full Disk Access (Mandatory for run it correctly):
    - Open System Settings > Privacy & Security > Full Disk Access
    - Add /bin/bash and /usr/local/bin/PlugNPlayMac/blcm to the list
    - Click on the plus icon at the bottom of the list and digit your password
        
        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/BeforeFullDisk.png">

    - Press cmd + shift + G and digit /bin

        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/bin.png">

    - Select bash and click open
    - Click again on the plus icon at the bottom of the list and digit your password
    - Press cmd + shift + G and digit /usr/local/bin/PlugNPlayMac

        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/bash.png">

    - Select blcm and click open

    - This is the final result:

        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/AfterFullDisk.png">