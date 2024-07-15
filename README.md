Mac上总结的一些shell脚本

	请输入

	0 	:再次查看说明;
	a 	:执行 apk-parse.sh 脚本, 打开解析apk的应用
	am 	:adb启动应用的说明,启动到指定的display;
	c 	:执行 connect.sh 脚本, 读取ifconfig连接设备
	connect	:执行 adb connect的操作
	clear	:执行 clear操作
	-c 	:执行 adb logcat -c 
	d 	:查看所有 display 的id; scrcpy --list-display ; scrcpy --display 476 显示对应的屏幕id
	-d	:执行 disconnect
	i 	:执行 install-apk.sh 脚本, 安装apk
	input xxx	:执行 adb shell input text/keyevent  ....
	l 	:执行 laogao_logcat.sh 脚本,读取设备里的logcat并生成文件
	n 	:打开一个新的 Terminal 窗口
	o or open 	: 打开当前文件所在的文件夹
	p 	:新开窗口执行 getprop
	r 	:执行 readLog.sh 脚本, 读取Log文件并进行过滤;
	s 	:执行 scrcpy 脚本
	top	:执行 adb shell top 在新的窗口.
	v	:version 输入包名查看当前应用的versionCode和versionName
	
查看说明输入0,请输入:
