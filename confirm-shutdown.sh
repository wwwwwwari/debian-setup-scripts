#!/bin/bash
zenity --question --text="Do you want to shut down?" --icon-name="dialog-question-symbolic"
if [ "$?" == "0" ]; then
   sudo shutdown -h now
fi
