#!/usr/bin/bash

ps aux | grep wlsunset | grep -v swayidle | grep -v restart | grep -v grep | awk '{print $2}' | xargs sudo kill 

nohup wlsunset -l 32.4279 -L 53.6880 >> /dev/null 2<&1 &
