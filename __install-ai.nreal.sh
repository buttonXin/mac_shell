

func_device(){
	devices_result="$(adb  devices)"

	echo "---$devices_result"
	# 通过空格分割字符串
	array=(${devices_result// /})

	length=${#array[*]}
	# 长度大于2表示已经连接有设备，获取第一个设备就行
	if [ $length -gt 2 ]
	then
		connect_device=${array[1]}
		echo "connect_device  $connect_device \n"	
		
	else
		echo "no devices connected"
	fi
}
func_device

adb -s $connect_device shell pm list packages |grep ai.nreal
echo
echo
