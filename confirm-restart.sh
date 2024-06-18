#!/bin/bash
zenity --question --text="Do you want to restart?" --icon-name="dialog-question-symbolic"
if [ "$?" == "0" ]; then
   sudo shutdown -r now
fi
