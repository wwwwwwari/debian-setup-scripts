#!/bin/bash
# quick and dirty script that copies desktop files in snap and flatpak directories to current user's local applications folder
# needed for a Debian/JWM setup as JWMKit's Easy Menu doesn't look for files in these locations
# this requires zenity and jwm
# to use, schedule as cron jobs or as a startup
# Source directory where files are located
source_flatpak_dir="/var/lib/flatpak/exports/share/applications"
source_snap_dir="/var/lib/snapd/desktop/applications"

# Destination directory where files will be copied
destination_dir="$HOME/.local/share/applications"

# Find files in source directory and iterate over them
find "$source_flatpak_dir" -iname "*.desktop" | while read -r file; do
	# do not copy if file exists
	if [ ! -f /path/to/file ]; then
		cp -n "$file" "$destination_dir"
		zenity --notification --text="Copied flatpak file: $file"
	fi
done
find "$source_snap_dir" -iname "*.desktop" | while read -r file; do
	# do not copy if file exists
	if [ ! -f /path/to/file ]; then
		cp -n "$file" "$destination_dir"
		zenity --notification --text="Copied snap file: $file"
	fi
done
jwm -reload
