#!/bin/bash


echo "-----start connect-----"
adb devices

echo
adb -d shell ifconfig 

# ip="$(adb -d shell "ifconfig wlan0 | grep 192.168  | cut -c9- |
#  xargs -n1 | grep addr | xargs -n 1 echo | tr 'addr:' ' '")"
ip="$(adb -d shell "ifconfig wlan0 | grep 10.2  | cut -c9- |
 xargs -n1 | grep addr | xargs -n 1 echo | tr 'addr:' ' '")"

echo "current devices ip = $ip"

func(){
    adb -d tcpip 5555
    adb disconnect
}

func & sleep 2



echo
adb connect $ip:5555
echo
adb devices