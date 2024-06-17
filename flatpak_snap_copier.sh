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

# Copy files from flatpak desktop dir if not already exists (only check file name so the local ones can be customized)
find "$source_flatpak_dir" -iname "*.desktop" | while read -r file; do
	# do not copy if file exists
	base_name="$(basename ${file})" 
	new_file="$destination_dir/$base_name"
	if [ ! -f "$new_file" ]; then
		cp -n "$file" "$destination_dir"
		chmod +x "$new_file"
		zenity --notification --text="Copied flatpak file: $file"
	fi
done
# Copy files from snap desktop dir if not already exists (only check file name so the local ones can be customized)
find "$source_snap_dir" -iname "*.desktop" | while read -r file; do
	# do not copy if file exists
	base_name="$(basename ${file})" 
	new_file="$destination_dir/$base_name"
	if [ ! -f "$new_file" ]; then
		cp -n "$file" "$destination_dir"
		chmod +x "$new_file"
		zenity --notification --text="Copied snap file: $file"
	fi
done
# remove if outdated
find "$destination_dir" -iname "*.desktop" | while read -r file; do
	base_name="$(basename ${file})" 
	old_flatpak_file="$source_flatpak_dir/$base_name"
	old_snap_file="$source_snap_dir/$base_name"
	if [ ! -f "$old_flatpak_file" ] && [ ! -f "$old_snap_file" ]; then
		rm -f $file
		zenity --notification --text="Deleted outdated desktop file: $file"
	fi
done
jwm -reload
