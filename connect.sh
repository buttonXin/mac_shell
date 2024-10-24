#!/bin/bash


echo "-----start connect-----"
adb devices



func(){
    adb -d tcpip 5555
    adb disconnect
}
echo "wait connect "

#  这里需要sleep 4秒, 时间太短, func里的方法执行时,会导致下面的链接失败.
func & sleep 4

adb -d shell ifconfig 

# ip="$(adb -d shell "ifconfig wlan0 | grep 192.168  | cut -c9- |
#  xargs -n1 | grep addr | xargs -n 1 echo | tr 'addr:' ' '")"
#ip=$(adb -d shell ifconfig wlan0 | awk '/inet addr/{print substr($2,6)}')

ip_str=$(adb -d shell ifconfig | awk '/inet addr/{print substr($2,6)}')

echo "current devices all ip = $ip_str"

echo

# 使用正则表达式提取IP地址并存储到数组中
ips=($(echo "$ip_str" | grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}"))


for ip in "${ips[@]}"; do
    # if [ "$ip" == "127.0.0.1" ]; then
    #     echo "Skipping even number: $ip"
    #     continue
    # fi

    if [[ "$ip" == *.0.1* ]]; then
        echo "Skipping even number: $ip"
        continue
    fi
    echo "current ip =$ip , start connect"
    adb connect $ip:5555
    echo
done

#  上面未连接的情况下 再次使用这个方式进行连接
IP_ADDRESS=$(adb -d shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
echo "The device IP address is: $IP_ADDRESS"
adb connect $IP_ADDRESS:5555


adb devices

echo "如果都没有连接成功,请查看手机与电脑是否在同一网关里"