# OS Installation Tasks
Download LXQt ISO from https://cdimage.debian.org/debian-cd/current-live/amd64/bt-hybrid/ 
Download Unetbootin from https://unetbootin.github.io/ and extract the live ISO to a USB
Go into BIOS (google how) and make the USB boot first
Go into Live Install and check if things are working (wifi won't work - needs LAN)
Aside from wifi issue, if there's no other problem, proceed with installation
# Post-Installation Tasks
## Network Configuration
### Wired Connection Configuration
This part include initial network configuration just so additional packages can be installed from the apt repository

`sudo apt-mark manual xarchiver xinit` to ensure these don't get removed by the following two commands
`sudo apt remove lxqt*` to ensure no network manager is interfering with network configuration
`sudo apt autoremove`
Connect LAN cable to your computer
`sudo nano /etc/apt/sources.list` to use mirror.applebred.net. Ensure nonfree is included
`sudo ip a` to get the wired and wireless interfaces - will assume eth0 and wlan0 below
Add the following to the interfaces file
```
auto eth0
iface eth0 inet static
address 192.168.1.50
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 192.168.1.1

#auto wlan0
iface wlan0 inet static
address 192.168.1.51
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 192.168.1.1
wpa-ssid <ssid>
wpa-psk <password>
```
`sudo ifdown eth0`
`sudo ifup eth0`
Pray to God the static wired connection is up. 
Comment out the lines from `iface eth0 inet static` to the first `dns-nameservers`  
Add `iface eth0 inet dhcp` to before the commented out lines
`sudo ifdown eth0`
`sudo ifup eth0`
Pray to God the DHCP wired connection is up.
### Wi-Fi Connection Configuration
`sudo apt update`
`sudo apt install rfkill`
`sudo nano /etc/systemd/system/rfkill-unblock-all.service`
Add the following to the file
```
[Unit]
Description=RFKill-Unblock All Devices

[Service]
Type=oneshot
ExecStart=/usr/sbin/rfkill unblock all
ExecStop=
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```
`sudo systemctl enable rfkill-unblock-all`
`sudo systemctl start rfkill-unblock-all`
`sudo nano /etc/network/interfaces`
Comment out `auto eth0` and Un-comment `auto wlan0`
Pull out the LAN cable
`sudo ip route` if the 'default' line still contains `eth0` do the two following commands
`sudo ip route del default`
`sudo ip route add default via 192.168.1.1 dev wlan0`
`sudo ifdown wlan0`
`sudo ifup wlan0`
Pray to God the static wi-fi connection is up
Comment out the lines from `iface wlan0 inet static` to the second `dns-nameservers`  
Add `iface wlan0 inet dhcp` to before the commented out lines
`sudo ifdown wlan0`
`sudo ifup wlan0`
Pray to God the DHCP wi-fi connection is up.
`sudo shutdown -r now` to restart (this should boot into CLI)
Pray to God the connection is still working fine
### Common Issues
1. **RTNETLINK answers: Operation not possible due to RF-kill:** you ifup'd a wireless interface before the rfkill-unblock-all service is up and running
2. **RTNETLINK answers: File exists:** you ifup'd a wireless interface before changing the default ip route
2. **During the restart, the boot process gets stuck at Networking for a very long time:** you forgot to comment out `auto eth0` after enabling wi-fi
## Permission Configuration
### Enable Shutdown Without Sudo Password Prompt
This allow sudo shutdown, reboot and poweroff commands without having to enter password, as long as the user is a sudoer.
`sudo nano /etc/sudoers.d/11-power-commands` 
Add the following to the file:
```
%sudo ALL=NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff, /sbin/shutdown
```
`sudo shutdown -r now` to apply the changes (may still need a password one last time)
## Git Configuration and Install
`ssh-keygen -t ed25519 -C "warireku@gmail.com"`
Add the public key on GitHub accordingly.
`mkdir ~/git`
`cd ~/git`
`git clone git@github.com:wwwwwwari/jwaita-jwm-theme.git`
`git clone git@github.com:wwwwwwari/debian-setup-scripts.git`
## Hardware Configuration
### Disabling Laptop Keyboard/Touchpad & Enabling NumLock at Startup

`sudo apt install numlockx`
`xinput list` and remember the IDs of "AT Translated Set 2 keyboard" (under "Virtual core keyboard") and "ELAN ... Touchpad" (under "Virtual core pointer")
`sudo mkdir /opt/custom_scripts`
`sudo cp ~/git/debian-setup-scripts/xinput_commands.sh /opt/custom_scripts`
`sudo chmod +x /opt/custom_scripts/xinput_commands.sh`

`sudo nano /etc/lightdm/lightdm.conf`
Add the following under the already-uncommented `[Seat:*]`:
```
greeter-setup-script=/usr/bin/numlockx on
display-setup-script=/opt/custom_scripts/xinput_commands.sh
```
`sudo shutdown -r now` to apply the changes
### Remove Loud System Beeps
`sudo rmmod pcspkr`
`sudo nano /etc/modprobe.d/blacklist.conf` 
Add the following line at the end of the file:
`blacklist pcspkr`
The changes should apply without a restart
### Common Issues
1. **Laptop keyboard and touchpad aren't disabled:** check if chmod +x is done to the script and that the display-setup-script is under the already uncommented `[Seat:*]` not the commented one above it
## Desktop Configuration
### Package Install & Removal
`sudo apt install lightdm jwm pcmanfm lxterminal geany papirus-icon-theme bibata-cursor-theme libglib2.0-dev adwaita-qt adwaita-qt6 awf-gtk4 wireshark git blackbird-gtk-theme` 
When prompted, select lightdm instead of sddm.
`sudo apt remove goldendict sddm`
`sudo apt autoremove`
## Default Apps Configuration 
The list of configurable alternatives are in /etc/alternatives
`sudo update-alternatives --config x-terminal-emulator` and select the LXTerminal
`sudo update-alternatives --config x-window-manager` and select the JWM
`sudo update-alternatives --config x-cursor-theme`  and select the Bibata Modern Classic theme
`gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark`
`gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark`
`gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic`
`nano /.icon/default/index.theme` and add the following
```
[Icon Theme]
Name=Default
Comment=Default Cursor Theme
Inherits=Bibata-Modern-Classic
```
### GTK2 Theme Setup
`nano ~/.gtkrc-2.0`
Change the value of the following lines:
```
gtk-theme-name="Blackbird"
gtk-icon-theme-name="Papirus-Dark"
gtk-cursor-theme-name="Bibata-Modern-Classic"
```
Check if the theme is applied in programs like pcmanfm
### GTK3 Theme Setup
`nano ~/.config/gtk-3.0/settings.ini`
Change the value of the following lines:
```
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-application-prefer-dark-theme=true
```
`sudo nano /etc/lightdm/lightdm-gtk-greeter.conf `
Add the following lines after the already-uncommented `[greeter]`
```
theme-name=Adwaita-dark
icon-theme-name=Papirus-Dark
cursor-theme-name=Bibata-Modern-Classic
```
Check if the theme is applied in programs like Geany or Mousepad
### GTK4 & Qt Theme Setup
`nano ~/.xsessionrc` and add the following:
```
export GTK_THEME=Adwaita-dark
export QT_STYLE_OVERRIDE=Adwaita-dark
export NO_AT_BRIDGE=1
```
Check if the theme is applied in programs like Wireshark and awf-gtk4
awf-gtk4 maybe removed afterwards if no longer used
## JWM Configuration
### Package Install
Download JWM Kit from <https://sourceforge.net/projects/jwmkit/files/Packages/Debian/>
`sudo dpkg -i <jwmkit.deb>`
`sudo shutdown -r now` should now reboot into lightdm. Select JWM in the top right corner.
After logging into the desktop, JWM should be up and riunning.
`sudo apt install gmrun scrot lxtask intltool libasound2-dev libglib2.0-dev libgtk-3-dev perl`
### JWM Theme Setup
`jwmkit_first_run` and load default config
Copy the cloned Jwaita theme file and buttons to `~/.config/jwm/themes`
Run the JWMKit Settings, go to Appearance and select the Jwaita theme and button (for the latter, needs to flip the toggle at the bottom of the button tab)
### JWM Icon Setup
`cp ~/git/debian-setup-scripts/jwm/icons ~/.config/jwm/icons`
### JWMKit Menu Setup
Select Easy Menu Settings, uncheck No Duplicates and set Terminal to LXTerminal
Click the Properties tab and set the Height to 36
Click the Root Menu in the left panel, and set the icon of Exit to `application-exit-symbolic`
Click the Exit in the left panel, and set the icon of Refresh to `system-reboot-symbolic`, Logout to `system-logout-symbolic`
Add Program items for shutdown with the following commands and icons: 
1. Shutdown: `sudo shutdown -h now` and `system-shutdown-symbolic`
2. Restart: `sudo shutdown -r now` and `system-restart-symbolic`
3. Lock: `dm-tool lock` and  `system-lock-screen-symbolic`
### JWMKit Tray Setup
In the Properties tab, set:
1. Auto-Hide to On
2. Height to 42
In the Items tab:
1. Remove the pager and all the tray buttons except the very first one
2. Edit the icon of the first tray button to `debian-logo`
3. Edit the format of the clock to `%H:%M`
4. Add a spacer as the very last item and change all spacer items' widths to 10
### JWMKit Keys Setup
`mkdir ~/Pictures/screenshots`
In JWMKit Keys, add the following:
1.  Print to `exec:scrot -e 'xclip -selection clipboard -t image/png -i $f' ~/Pictures/screenshots/%Y-%m-%d-%H:%M:%S.png`
2. Alt + Print to `exec:scrot -e 'xclip -selection clipboard -t image/png -i $f' ~/Pictures/screenshots/%Y-%m-%d-%H:%M:%S.png -u`
3. Mod 4 + R to `exec:gmrun`
4. Ctrl + Alt + Delete and Ctrl + Alt + Esc to `exec:lxtask`
5. Shift + Alt + Tab to `Task List Previous`
6. Mod 4 + E to `exec:pcmanfm`
## Locale Setup
### Package Install
`sudo apt install systemd-timesyncd fcitx5-mozc`
### Time Synchronization
`sudo timedatectl set-timezone Asia/Bangkok`
`sudo nano /etc/systemd/timesyncd.conf` and add the following:
```
[Time]
NTP=ntp.ku.ac.th
FallbackNTP=th.pool.ntp.org
```
`sudo systemctl enable systemd-timesyncd`
`sudo systemctl start systemd-timesyncd`
Changes should take place immediately
### Keyboard Configuration
In JWMKit Settings, select Input Method (keyboard icon) and select fcitx5.
In JWMKit Startups, add `/usr/bin/fcitx5`  as a startup program
Run fcitx5 from the Menu - the icon should appear on the tray
Right click the tray icon and select "Configure"
Add "Keyboard - Thai" and "Mozc" by searching and double clicking the entries in the right panel
In the Global Options tab, set
1. Alt + Left Shift as Enumerate Method Forward
2. Alt + ` as Temporarily Switch First and Current Methods
3. Remove keys for everything else
4. Click Apply and Close
In JWMKit Settings, select Mozc Setup, click Edit User Dictionary in the Dictionary tab and add custom dictionary entries as needed.
## Application Setup
### Package Install & Removal
`sudo apt install flatpak snapd notification-daemon galculator evince feh mpv scrot xclip font-manager pavucontrol gpick diffuse gprename simplescreenrecorder transmission-gtk audacious`
`sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`
`sudo flatpak install pinta`
`sudo apt purge myspell* aspell* anthy libxfce4* firefox-esr-l10n* libreoffice-l10n-* hspell* mlterm*`
`sudo apt install hunspell hunspell-en-us`
`sudo apt autoremove`
`sudo apt dist-upgrade`
Download volume icon from <https://github.com/Maato/volumeicon>
### Enabling Volume Icon
Extract the Volume Icon Zip
`sudo ./autogen.sh`
`sudo ./configure`
`sudo  make`
`sudo make install`
In JWMKit Startup, add `/usr/local/bin/volumeicon` as a startup
### Blocking Annoying Spellchecker Packages
`sudo mv ~/git/debian-setup-scripts/apt/preferences.d/11-block-dictionaries /etc/apt/preferences.d/` 
### Enabling Notifications
In JWMKit Startups, add `/usr/lib/notification-daemon-1.0/notification-daemon` as a startup
### Enabling Easy Snap / Flatpak Package Inclusion in the Menu
`sudo cp ~/git/debian-setup-scripts/flatpak_snap_copier.sh /opt/custom_scripts`
`sudo chmod +x /opt/custom_scripts/flatpak_snap_copier.sh`
In JWMKit Startups, add `/opt/custom_scripts/flatpak_snap_copier.sh` as a startup and a restart
Small changes may still be needed for the copied desktop files. For example's Pinta's `@@ %F @@` wouldn't work when launched from JWM's Menu
### Application-Specific Theme Setup
1. **Geany:** download the dark theme from `https://raw.github.com/geany/geany-themes/master/colorschemes/kary-pro-colors-dark.conf` and save it to ~/.config/geany/colorschemes
2. **LXTerminal:** change the pallette to Tango and change the background to #1A1A1A
