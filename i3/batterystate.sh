#!/usr/bin/bash
#  batterybar; displays battery load_state as a bar on i3blocks
#  
#  Copyright 2015 Keftaa <adnan.37h@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

squares="■"


#There are 8 colors that reflect the current battery load_state when 
#discharging

dis_colors_0="#FF0027"
dis_colors_1="#FF3B27"
dis_colors_2="#FFB923"
dis_colors_3="#FFD000"
dis_colors_4="#E4FF00"
dis_colors_5="#ADFF00"
dis_colors_6="#6DFF00"
dis_colors_7="#10BA00"

charging_color="#00AFE3"
full_color="#CFD2DE"
ac_color="#535353"
color="#CFD2DE"
toggle=0
while getopts 1:2:3:4:5:6:7:8:c:f:a:h opt; do
    case "$opt" in
        1) dis_colors_0="$OPTARG";;
        2) dis_colors_1="$OPTARG";;
        3) dis_colors_2="$OPTARG";;
        4) dis_colors_3="$OPTARG";;
        5) dis_colors_4="$OPTARG";;
        6) dis_colors_5="$OPTARG";;
        7) dis_colors_6="$OPTARG";;
        8) dis_colors_7="$OPTARG";;
        c) charging_color="$OPTARG";;
        f) full_color="$OPTARG";;
        a) ac_color="$OPTARG";;
        h) printf "Usage: batterybar [OPTION] color
        When discharging, there are 8 [1-8] levels colors.
        You can specify custom colors, for example:
        
        batterybar -1 red -2 \"#F6F6F6\" -8 green
        
        You can also specify the colors for the charging, AC and
        charged states:
        
        batterybar -c green -f white -a \"#EEEEEE\"\n";
        exit 0;
    esac
done
while true
do
    load_state=$(cat /sys/class/power_supply/BAT0/capacity)
    status=$(cat /sys/class/power_supply/BAT0/status)
    AC=$(cat /sys/class/power_supply/AC/online)
    last_capacity=$(cat /sys/class/power_supply/BAT0/energy_full)
    energy_now=$(cat /sys/class/power_supply/BAT0/energy_now)
    power_now=$(cat /sys/class/power_supply/BAT0/power_now)
    #loading
    if [ $power_now -gt 0 ];
    then
        if [ $AC -gt 0 ];
        then
            remaining_h=$(((last_capacity-energy_now)/power_now))
            remaining_m=$(((last_capacity-energy_now)*60/power_now-60*remaining_h))
        else
            remaining_h=$((energy_now/power_now))
            remaining_m=$((energy_now*60/power_now-60*remaining_h))
        fi

        if [ $remaining_h -lt 10 ];
        then
            remaining_h=0$remaining_h
        fi
        if [ $remaining_m -lt 10 ];
        then
            remaining_m=0$remaining_m
        fi
            remaining=\(${remaining_h}:${remaining_m}\)
    else
        remaining=\(undef\)
	if [ $load_state -gt 90 ]; then
	    status="Full"
        fi
    fi
    if [  $load_state -lt 20  ]; then

        squares=""
    elif [ $load_state -lt 40 ]; then
        squares=""
    elif [ $load_state -lt 60 ]; then
        squares=""
    elif [ $load_state -lt 80 ]; then
        squares=" "
    else 
        squares=""
    fi
    sleep_duration=5
    case "$status" in
    "Charging")
        color="$charging_color"
    ;;
    "Full")
        color="$full_color"
    ;;
    "AC")
       color="$ac_color"
    ;; 
    "Discharging"|"Unknown")
        if [ $load_state -lt 10 ]; then
            sleep_duration=.$((load_state+1))       
            if [ $toggle = 1 ]; then
                toggle=0 
                color=$dis_colors_0
            else
                toggle=1
	        color="#FF0027"
            fi
            if [ $load_state -lt ]; then
                 $HOME/.config/i3/i3lock-wrapper
                 s2disk
            fi        
        elif [ $load_state -lt 20 ]; then
            color=$dis_colors_1
        elif [ $load_state -lt 30 ]; then
            color=$dis_colors_2
        elif [ $load_state -lt 40 ]; then
            color=$dis_colors_3
        elif [ $load_state -lt 60 ]; then
            color=$dis_colors_4
        elif [ $load_state -lt 70 ]; then
            color=$dis_colors_5
        elif [ $load_state -lt 80 ]; then
            color=$dis_colors_6
        else
            color=${dis_colors_7}
        fi
    ;;
    esac

    if [ $status = "Full" ]; then
echo "<span foreground=\"$color\">${squares} $load_state%</span>"
else
    echo "<span foreground=\"$color\">${squares} $load_state% $remaining</span>"
fi
    sleep $sleep_duration
done
