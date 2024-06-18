#!/bin/bash
zenity --question --text="Do you want to log out?" --icon-name="dialog-question-symbolic"
if [ "$?" == "0" ]; then
   jwm -exit
fi
