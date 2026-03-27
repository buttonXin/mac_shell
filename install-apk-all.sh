#!/bin/bash
#install

# 定义APK所在目录
APK_DIR="/Users/nreal/person-data/apk/preinstalled-apk/"

catch_ctrl_c(){
    trap "echo '检测到 SIGINT, 退出脚本'; exit 0" SIGINT
}

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

# 检查目录是否存在
if [ ! -d "$APK_DIR" ]; then
    echo "错误：目录 $APK_DIR 不存在！"
    exit 1
fi

# 获取所有APK文件
APK_FILES=("$APK_DIR"/*.apk)

# 检查是否有APK文件
if [ ${#APK_FILES[@]} -eq 0 ]; then
    echo "错误：在 $APK_DIR 目录下未找到APK文件！"
    exit 1
fi

# 统计APK数量
APK_COUNT=${#APK_FILES[@]}
echo "找到 $APK_COUNT 个APK文件"


# 遍历并安装每个APK
for ((i=0; i<$APK_COUNT; i++)); do
    apk="${APK_FILES[$i]}"
    
    # 检查文件是否存在（避免通配符未匹配到文件时的问题）
    if [ ! -f "$apk" ]; then
        continue
    fi
    
    echo "[$((i+1))/$APK_COUNT] 正在安装: $(basename "$apk")"
    
     # 获取APK包名
    package_name=$(aapt dump badging "$apk" | grep -o "package: name='[^']*'")
    echo "--->  $package_name" 
    package_name="${package_name#*\'}"  # 去除前缀直到第一个单引号
    package_name="${package_name%\'*}"  # 去除后缀从最后一个单引号开始
    echo "$package_name" 
    
    if [ -z "$package_name" ]; then
        echo "⚠️ 无法获取包名，跳过安装: $(basename "$apk")"
        continue
    fi

    # 检查应用是否已安装
    if adb -s $connect_device shell pm list packages | grep -q "$package_name"; then
        echo "[$((i+1))/$APK_COUNT] ⚠️ 已安装: $package_name - $(basename "$apk")"
        continue
    fi

    # 执行ADB安装
    if adb -s $connect_device install -g -r -t -d "$apk"; then
        echo "[$((i+1))/$APK_COUNT] ✅ 安装成功: $(basename "$apk")"
    else
        echo "[$((i+1))/$APK_COUNT] ❌ 安装失败: $(basename "$apk")"
        exit 1
    fi
    
    echo ""  # 空行分隔每次安装
done

echo "✅ 所有APK安装完成！"





