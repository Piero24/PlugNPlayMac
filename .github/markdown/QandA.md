# Q&A

<details>
<summary>1) Where can I find the <img align="center" src="https://help.apple.com/assets/645D5D228BE0233D28263F4B/645D5D258BE0233D28263F5A/en_US/d230a25cb974f8908871af04caad89a1.png" width="25" > Shortcut for control the script and what can I do with it ?
</summary>
<br/>

> 👉  You can get the PlagNPlayMac shortcut from this <a href="https://www.icloud.com/shortcuts/f17d6b70db3a417799a35f1b0b684540">link</a> or you can create it manually.

<hr>
<br/>
</details>

<details>
<summary>2) How can I start and stop the automation of the script ?</summary>
<br/>

You can easilly stop the automation of the script by running the following command on the terminal:
```sh 
    launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
```

for restart it:

```sh
launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
```
<hr>
<br/>
</details>

<details>
<summary>3) Accidentally I have insert the wrong password how can I change it?</summary>
<br/>

> If you have insert the wrong password and you want to  <a href="https://github.com/Piero24/PlugNPlayMac/blob/main/.github/markdown/alternativePasss.md">change it</a>

<hr>
<br/>
</details>

<details>
<summary>4) How can I add more displays to the script ? I need to run the script when I am home and when I am at work</summary>
<br/>

> For add more displays to the script <a href="https://github.com/Piero24/PlugNPlayMac/blob/main/.github/markdown/alternativePasss.md">here</a>

<hr>
<br/>
</details>

<details>
<summary>5) How can I change the battery level ?</summary>
<br/>

1. Open the `PNPMacParam.sh` file and edit the following variables:
2. Change the value of batteryValue with the one in range 50-95 (100 only if you don't want to have the battery limit)
3. Save exit and restart the script with the command:
```sh 
launchctl unload /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
launchctl load /Library/LaunchAgents/com.launch.plug.and.play.mac.plist
```

**NOTE:** The `batteryValue` of <a href="https://github.com/zackelia/bclm">bclm</a> as mentioned it will be 3 point greather then the value setted in the script. So if you set `batteryValue=77` the battery limit will be 80.

<hr>
<br/>
</details>

<details>

<summary>6) Somthing don't work what I have to do ?</summary>
<br/>

If somthing you can try to find a solution by checking the log file `/private/tmp/plug.and.play.mac.log`

If the problem is not correlated to a wrong password or a wrong name of the display you can open an issue <a href="https://github.com/Piero24/PlugNPlayMac/issues">here</a> and post the result of the log file. 

<hr>
<br/>
</details>

<details>
<summary>7) How can I completelly erease the script and all the file correlated ?</summary>

### You Can't.
> Just kidding 😂 of corse you can delete it.

You can do it by deleting the following files:
- `/Library/LaunchAgents/com.launch.plug.and.play.mac.plist`

- `/usr/local/bin/PlugNPlayMac` (DELETE THE ENTIRE FOLDER)

- Remember to remove bash and bclm from `System Settings > Privacy & Security > Full Disk Access`

<hr>
<br/>
</details>

<!-- <details>
<summary>X) </summary>
<br/>

> Text <a href="">here</a>

<hr>
<br/>
</details> -->

