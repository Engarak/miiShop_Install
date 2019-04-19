# miiShop_Install
Installer script and EXE for setting up miiShop

##  What's new?
v.0.1 - Install Script for miiShop
+ Simplified install/setup by making a single setup file
+ Version works for new install or upgrade
+ miiShop starts after install/upgrade immediately

## Instructions
1. Download  `miiShop_Install.exe`
2. Open your Downloads folder
3. In the Downloads folder, right-click on `miiShop_Install.exe` and choose *Run as Administrator*
4. When you see the "Welcome to PoSH Server" screen go to http://localhost.8080
5. Reload your own games from your own PC.

## Known issues
+ Windows Smart Screen will show a "Windows protected your PC" window.  If you choose to have this installer run, click the More info link, and then click the *Run anyway* button.  You can choose not to trust this, that's your choice, if you want this installer to run, you'll need to choose to run it anyways, until I get a signature added.
+ If you run this script and a couple windows pop up, then close, and after that, nothing happens.  This usually occurs if you've not run the `miiShop_install.exe` as administrator.  See the Instructions above for how to do this.
+ If you have anything running at port 8080 (bittorrent client, web server, game server, etc.) on the same computer, then this webserver will not work.  If you're unsure how to check if the port is open, google is your friend.
