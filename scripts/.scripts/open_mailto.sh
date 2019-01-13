#!/bin/bash
vivaldi-stable https://mail.google.com/mail?view=cm\&tf=0\&to=$(echo $1 | sed 's/mailto://i' | sed 's/subject/su/i' | sed 's/\?/\&/')
