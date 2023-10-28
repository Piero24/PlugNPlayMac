<div id="top"></div>
<br/>
<br/>


<p align="center">
  <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/logo.png" width="100" height="100">
</p>
<h1 align="center">
    <a href="https://github.com/Piero24/PlugNPlayMac">PlugNPlayMac</a>
</h1>
<p align="center">
    <a href="https://github.com/Piero24/PlugNPlayMac/commits/master">
    <img src="https://img.shields.io/github/last-commit/piero24/PlugNPlayMac">
    </a>
    <a href="https://github.com/Piero24/PlugNPlayMac">
    <img src="https://img.shields.io/badge/Maintained-yes-green.svg">
    </a>
    <a href="https://github.com/Piero24/twitch-stream-viewer/issues">
    <img src="https://img.shields.io/github/issues/piero24/PlugNPlayMac">
    </a>
    <a href="https://github.com/Piero24/PlugNPlayMac/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/piero24/PlugNPlayMac">
    </a>
</p>
<p align="center">
    A script to automate tasks when connect a device to your Mac
    <br/>
    <a href="https://github.com/Piero24/PlugNPlayMac/issues">Report Bug</a>
    •
    <a href="https://github.com/Piero24/PlugNPlayMac/issues">Request Feature</a>
</p>

---

<br/><br/>
<h2 id="itroduction">📔  Itroduction</h2>
<p>
    This is a script that automates tasks when you connect a device to your Mac.
    Let's add some context to the project!
    <br/>
    I have written this shell script to automate tasks when I return home and connect my Mac to an external monitor. Every time I connect my Mac to the monitor, I have to perform several tasks:
    <ul>
        <li>Run <a href="https://github.com/MonitorControl/MonitorControl">MonitorControl</a> to adjust the external monitor's brightness.</li>
        <li>Launch <a href="https://www.elgato.com/us/en/s/downloads">Elgato Stream Deck.</a></li>
        <li>Start <a href="https://www.google.com/drive/download/">Google Drive</a> to access my files.</li>
        <li>Activate <a href="https://apps.apple.com/bg/app/amphetamine/id937984704?mt=12">Amphetamine</a> to prevent my Mac from going to sleep.</li>
        <li>Run <a href="https://github.com/zackelia/bclm">bclm</a> to preserve battery health.</li>
    </ul>
    This process was very frustrating because I had to perform these tasks manually every time. Furthermore, each time I disconnected the monitor, I had to repeat these operations to close all the apps.
    <br/>
    <br/>
    With this script, the apps will open automatically when I connect my home monitor to the MacBook and will close when I disconnect the monitor. Additionally, it recognizes the Wi-Fi network, so it only opens the apps when I connect to a specific home monitor. This ensures that nothing opens if I connect to an external monitor at the office with a similar name.
    <br/>
    <br/>
    <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/Cover.png">
    <br/>
    <br/>
    In addition to this, I have also prepared a shortcut (for the <a href="https://support.apple.com/en-gb/guide/shortcuts-mac/apdf22b0444c/mac">Apple Shortcut app</a>) to enable/disable various functions from the Mac's menu bar. This allows me to control the functions even when I am not at home. While there are apps that perform similar functions, I wanted to minimize the number of applications running constantly in the background. Therefore, I chose to write a script to accomplish all of this.
    <br/>
    <br/>
    I have also opted to replace <a href="https://apps.apple.com/bg/app/amphetamine/id937984704?mt=12">Amphetamine</a> with <a href="https://ss64.com/osx/caffeinate.html">Caffeinate</a>, which is pre-installed on every Mac. Additionally, I replaced <a href="https://github.com/AppHouseKitchen/AlDente-Charge-Limiter">AlDente</a> with <a href="https://github.com/zackelia/bclm">bclm</a>, which has fewer features but is more convenient for my purposes.
</p>


<!--
<h2 id="made-in"><br/>🛠  Built in</h2>
<p>
    Il presente script è stato scritto in <strong>Shell</strong> eccetto <a href="https://github.com/zackelia/bclm">bclm</a> che è stato preso da un repository esterno ed è scritto in <strong> Swift </strong>. 
</p>
<br/>
<a href="https://github.com/Piero24/Template-README">Programming Language 1</a> • <a href="https://github.com/Piero24/Template-README/issues">Programming Language 2</a> • <a href="https://github.com/Piero24/Template-README/issues">Programming Language 3</a>

<p align="right"><a href="#top">⇧</a></p>
-->


<h2 id="index"><br/>📋  Index</h2>
<ul>
    <li><h4><a href="#documentation">Documentation</a></h4></li>
    <li><h4><a href="#prerequisites">Prerequisites</a></h4></li>
    <li><h4><a href="#how-to-start">How to Start</a></h4></li>
    <li><h4><a href="#structure-of-the-project">Structure of the Project</a></h4></li>
    <li><h4><a href="#roadmap">Roadmap</a></h4></li>
    <li><h4><a href="#responsible-disclosure">Responsible Disclosure</a></h4></li>
    <li><h4><a href="#report-a-bug">Report a Bug</a></h4></li>
    <li><h4><a href="#maintenance">Maintenance</a></h4></li>
    <li><h4><a href="#license">License</a></h4></li>
    <li><h4><a href="#third-party-licenses">Third Party Licenses</a></h4></li>
</ul>

<p align="right"><a href="#top">⇧</a></p>


<h2 id="documentation"><br/><br/>📚  Documentation</h2>
<p>
    The script consists of 3 .sh files, 1 .swift file, and 1 .plist file. The .plist file is necessary to launch the script at Mac startup. The .swift file is required to limit battery charging. The 3 .sh files contain the script's code.
    <ul>
        <li>
            <strong>PlugNPlayMac.sh</strong> is the main script that runs when the monitor is connected. This script handles the opening of all necessary apps and starts `caffeinate` and `bclm` to limit battery charging.
        </li>
        <br/>
        <li>
            <strong>PNPMacParam.sh</strong> contains configurable settings for the script, such as which apps to open, the names of monitors and Wi-Fi networks that trigger the script, and the battery limit for `bclm`.
        </li>
        <br/>
        <li>
            <strong>PNPMacInstaller.sh</strong> is the installation file (currently responsible for moving files to the correct paths, although some manual steps are required). In future versions, efforts will be made to automate the installation process as much as possible, even though certain functions, such as disk access, may still need to be performed manually.
        </li>
        <br/>
        <li>
            <strong>com.launch.plug.and.play.mac.plist</strong> is responsible for launching the script at Mac startup. In a future version, it will be integrated into the main file, which will automatically write it to the LaunchAgents folder, eliminating the need for manual copying in case it is accidentally deleted.
        </li>
    </ul>
    <br/>
    In case of any errors, you can check the logs in the file <strong>plug.and.play.mac.log</strong> located in the folder <strong>/tmp/plug.and.play.mac.log</strong>.
</p>


<p align="right"><a href="#top">⇧</a></p>


<h2 id="prerequisites"><br/>🧰  Prerequisites</h2>
<p>
    There are no specific dependencies or requirements to be met for using this script.
    The only thing required is to have a Mac with <strong>macOS Ventura</strong> (or higher) installed. Additional requirements may apply to <a href="https://github.com/zackelia/bclm">bclm</a>, so please check the original repository before proceeding with the installation.
    <p>
        <strong>NOTE: </strong> This script has been tested only on <strong>MacBook Pro (13-inch, 2018, Four Thunderbolt 3 ports)</strong> with <strong>macOS Ventura 13.5.1</strong> and <strong>macOS Sonoma 14.0</strong>.
    </p>
    <br/>
    <p align="center">
        <h3  align="center">
            ⚠️ <strong>ATTENTION</strong> ⚠️
        </h3>
        <p  align="center">
            <strong>Currently, bclm works exclusively on Macs with Intel processors and not on Macs with Apple Silicon processors (M1, M2, etc)</strong>. The rest of the functions work without any issues, so Caffeinate and the apps will start as expected, but bclm won't run. As soon as I have access to a Mac with an Apple Silicon processor, I will update the code to support these processors. Otherwise, if anyone would like to contribute, they are welcome to do so.
        </p>
    </p>
</p>

<p align="right"><a href="#top">⇧</a></p>

<h2 id="how-to-start"><br/>⚙️  How to Start</h2>
<p>
    Below is an example of how you can instruct your audience on installing and setting up your app. This template doesn't rely on any external dependencies or services.
</p>
<br/>


1. Download the latest version of the script from <a href="https://github.com/Piero24/PlugNPlayMac/archive/refs/heads/main.zip">here</a> or clone the repo:
    - ```sh
        git clone https://github.com/Piero24/PlugNPlayMac.git
        ```
2. Connect the macbook to your wifi and monitor open the terminal and run the following commands:
    - ```sh
        ioreg -lw0 | grep 'IODisplayEDID' | sed '/[^<]*</s///' | xxd -p -r | strings -10
        ```
        It will return the name of the monitor seen by the Mac. In my case, it is `LG IPS FULLHD`.
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

4. Add the password to keychain (this is needed for run persistence on bclm and perceive other task):
    - ```sh
        security add-generic-password -s 'PlugNPlayMac'  -a 'MY USERNAME' -w 'MY MACBOOK PASSWORD'
        ```
        `MY USERNAME` is the name of the user account on my Mac and `MY MACBOOK PASSWORD` is the password of my Mac. It will be stored on keychain with the name `PlugNPlayMac` and will be used by the script to run the task.
        
    Alternativelly you can add the password manually on keychain in this way:

    - Open Keychain Access 
        
        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/KeychainAccessIcon.png" width="100" height="100">
    
    - Select Open Keychain Access 
        
        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/OpenedKey.png">
    
    - Add the new password
        
        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/NewPass.png">

5. Open the terminal ad run the installer:
    - ```sh
        /Users/YOUR-NAME/Downloads/PlugNPlayMac-main/PNPMacInstaller.sh
        ```
        Where `YOUR-NAME` is the name of your user account on your Mac.

6. Give the script the Full Disk Access (Mandatory for run it correctly):
    - Open System Settings > Privacy & Security > Full Disk Access
    - Click on the plus icon at the bottom of the list and digit your password
        
        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/BeforeFullDisk.png">

    - Press cmd + shift + G and digit /bin

        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/bin.png">

    - Select bash and click open
    - Click again on the plus icon at the bottom of the list and digit your password
    - Press cmd + shift + G and digit /usr/local/bin/PlugNPlayMac

        <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/bash.png">

    - Select blcm and click open

    This is the final result:

    <img src="https://github.com/Piero24/PlugNPlayMac/blob/main/image/AfterFullDisk.png">

7.  Test the script (the pass it will be required only the first time you run the script):
    - Digit on therminal `/usr/local/bin/PlugNPlayMacPlugNPlayMac.sh` ad enter your password
    - Control + c to exit 

8. Reboot your Mac

9. Open terminal and digit `launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist``

Done! Now the script will run automatically when you connect your Mac to the monitor and will close when you disconnect it. Additionally, you can use the shortcut to enable/disable various functions from the Mac's menu bar.

<p align="right"><a href="#top">⇧</a></p>


---
  

<h2 id="roadmap"><br/><br/>🛫  Roadmap</h2>

- [x] Switch from AlDente to bclm
- [ ] Add bclm support for Apple Silicon (whenever I have access to a Mac with an Apple Silicon processor)
- [ ] Bug Fixing
- [ ] Switch to Swift
- [ ] Reduce anutomate the procedure for the installation
- [ ] Add AutoUpdate


<p>
    See the 
    <a href="https://github.com/Piero24/PlugNPlayMac/issues">open issues</a>
    for a full list of proposed features (and known issues).
</p>

<p align="right"><a href="#top">⇧</a></p>


<h3 id="responsible-disclosure"><br/>📮  Responsible Disclosure</h3>
<p>
    We assume no responsibility for an improper use of this code and everything related to it. We do not assume any responsibility for damage caused to people and / or objects in the use of the code.
</p>
<strong>
    By using this code even in a small part, the developers are declined from any responsibility.
</strong>
<br/>
<br/>
<p>
    It is possible to have more information by viewing the following links: 
    <a href="#code-of-conduct"><strong>Code of conduct</strong></a>
     • 
    <a href="#license"><strong>License</strong></a>
</p>

<p align="right"><a href="#top">⇧</a></p>


<h3 id="report-a-bug"><br/>🐛  Bug and Feature</h3>
<p>
    To <strong>report a bug</strong> or to request the implementation of <strong>new features</strong>, it is strongly recommended to use the <a href="https://github.com/Piero24/PlugNPlayMac/issues"><strong>ISSUES tool from Github »</strong></a>
</p>
<p>
    Here you may already find the answer to the problem you have encountered, in case it has already happened to other people. Otherwise you can report the bugs found.
</p>
<strong>
    ATTENTION: To speed up the resolution of problems, it is recommended to answer all the questions present in the request phase in an exhaustive manner.
</strong>
<br/>
<br/>
<p>
    (Even in the phase of requests for the implementation of new functions, we ask you to better specify the reasons for the request and what final result you want to obtain).
</p>
<p align="right"><a href="#top">⇧</a></p>


<h3 id="maintenance"><br/>🔧  Maintenance</h3>
<p>
    There are currently no parts of the code under maintenance. You can quickly check the <a href="#top">status of the project</a> at the top of the page.
</p>
<p>
    This section details which parts of the code are under maintenance and for what reason.
</p>

<h4 id="changelog"><br/>📟  Changelog</h4>
<p>
    Here you can find all the information regarding the fixes and implementations that took place in the various program reviews.
</p>
<a href="https://github.com/Piero24/PlugNPlayMac/blob/main/CHANGELOG.md"><strong>Explore the changelog docs</strong></a>
<br/>

<p align="right"><a href="#top">⇧</a></p>
  
 --- 

<h2 id="license"><br/>🔍  License</h2>
<strong>MIT LICENSE</strong>
<br/>
<i>Copyright (c) 2023 Andrea Pietrobon</i>
<br/>
<br/>
<i>Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction.</i>
<br/>
<br/>
<i>Preamble</i>
<br/>
<i>The GNU General Public License is a free, copyleft license for software and other kinds of works.</i>
<br/>
<a href="https://github.com/Piero24/PlugNPlayMac/blob/main/LICENSE"><strong>License Documentation »</strong></a>
<br/>
<br/>


<h3 id="authors-and-copyright"><br/>✏️  Authors and Copyright</h3>
<br/>
<p>
    👨🏽‍💻: <strong>Pietrobon Andrea</strong>
    <br/>
    🌐: <a href="https://www.pietrobonandrea.com">pietrobonandrea.com</a>
    <br/>
    <img src="https://assets.stickpng.com/thumbs/580b57fcd9996e24bc43c53e.png" width="30" height="30" align="center">:
    <a href="https://twitter.com/pietrobonandrea">@PietrobonAndrea</a>
    <br/>
    🗄: <a href="https://github.com/Piero24/PlugNPlayMac">PlugNPlayMac</a>
</p>
<br/>
<p>
    My name is <strong>Pietrobon Andrea</strong>, a computer engineering student at the 
    <img src="https://upload.wikimedia.org/wikipedia/it/thumb/5/53/Logo_Università_Padova.svg/800px-Logo_Università_Padova.svg.png"  width="26" height="26" align="center"> 
    University of Padua (🇮🇹).
</p>
<p>
    My passion turns towards <strong>AI</strong> and <strong>ML</strong>.
    I have learned and worked in different sectors that have allowed me to gain skills in different fields, such as IT and industrial design.
    To find out more, visit my <a href="https://www.pietrobonandrea.com">
    <strong>website »</strong></a>
</p>

<p align="right"><a href="#top">⇧</a></p>


<h3 id="third-party-licenses"><br/>📌  Third Party Licenses</h3>

In the event that the software uses third-party components for its operation, 
<br/>
the individual licenses are indicated in the following section.
<br/>
<br/>
<strong>Software list:</strong>
<br/>
<table align="center">
  <tr  align="center">
    <th>Software</th>
    <th>License owner</th> 
    <th>License type</th> 
  </tr>
  <tr  align="center">
    <td><a href="https://github.com/zackelia/bclm">bclm</a></td>
    <td><a href="https://github.com/zackelia">zackelia</a></td> 
    <td><a href="https://github.com/zackelia/bclm/blob/main/LICENSE">MIT</a></td>
  </tr>
</table>

<p align="right"><a href="#top">⇧</a></p>


---
> *<p align="center"> Copyrright (C) by Pietrobon Andrea <br/> Released date: **Nov-01-2023***
