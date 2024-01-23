#!/usr/bin/env bash
set -eu

proc_uptime=`cat /proc/uptime | awk -F" " '{print $1}'`
clk_tck=`getconf CLK_TCK`

(
echo "PID|TTY|STAT|TIME|COMMAND";
for pid in `ls -v /proc | grep -E "^[0-9]+$"`; do
    if [ -d /proc/$pid ]; then
        stat=`</proc/$pid/stat`
        pcmd=`head -n 1 /proc/$pid/task/$pid/maps` 
        if  [ -z "$pcmd" ] 
        then
            cmd=`echo "$stat" | awk -F" " '{print $2}'`
        else
            cmd=`echo "$pcmd" | awk -F" " '{print $6}'`
        fi
        state=`echo "$stat" | awk -F" " '{print $3}'`
        tty=`echo "$stat" | awk -F" " '{print $7}'`
        
        utime=`echo "$stat" | awk -F" " '{print $14}'`
        stime=`echo "$stat" | awk -F" " '{print $15}'`
        ttime=$((utime + stime))
        time=$((ttime / clk_tck))

        echo "${pid}|${tty}|${state}|${time}|${cmd}"
    fi
done
) | column -t -s "|"
