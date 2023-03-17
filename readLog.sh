# !/bin/bash                                 # 指定shell类型
# 第三版
# 参数-n的作用是不换行，echo默认换行
echo -n "拖入文件:"    
# 把键盘输入放入变量               
read  file_path    

only_path=true 

egrep -i "(nebula_)" $file_path > ${file_path%/*}/nebula_
# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
# 打开对应的app
open -a "sublime text" ${file_path%/*}/nebula_
open -a "sublime text" $file_path

echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
while  read filter_name ; do
	
	if ($only_path); then
   		open -a "sublime text" $file_path
	fi

	only_path=false
    output_name=$filter_name

	echo "output_name= $output_name"
	output_name2=`echo $output_name | sed 's/[^a-zA-Z0-9]//g'`
	echo "output_name2= $output_name2"
	egrep -i "($filter_name)" $file_path > ${file_path%/*}/$output_name2
	# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
	# 打开对应的app
	open -a "sublime text" ${file_path%/*}/$output_name2
	echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
done

#第三版
#echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#while  read filter_name && read output_name; do
#	#statements
#	if [[ ! -n "$output_name" ]]; then
#    	echo "output_name is empty"
#    	output_name=go
#	fi
#
#	echo "output_name= $output_name"
#	egrep -i "($filter_name)" $file_path > ${file_path%/*}/$output_name
#	# 抽离字符串（将/ 前的str全部保留） {file_path%/*}
#	# 打开对应的app
#	open -a "sublime text" ${file_path%/*}/$output_name
#	echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#done
                            
# 第二版
# 参数-n的作用是不换行，echo默认换行
#echo -n "拖入文件:"    
# 把键盘输入放入变量               
#read  file_path    

#echo -n "Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#read  filter_name

#egrep -i "($filter_name)" $file_path > ${file_path%/*}/go

# 抽离字符串（将/ 前的str全部保留） {file_path%/*}

# 打开对应的app
#open -a "sublime text" ${file_path%/*}/go

# 再次使用过滤规则
#echo -n "Again Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#read  filter_name

#egrep -i "($filter_name)" $file_path > ${file_path%/*}/go

# 抽离字符串（将/ 前的str全部保留） {file_path%/*}

# 打开对应的app
#open -a "sublime text" ${file_path%/*}/go

# echo ${file_path%/*}/go
# 返回一个零退出状态，退出shell程序
# exit 0  



## !/bin/bash                                 # 指定shell类型
# 第一版
## 参数-n的作用是不换行，echo默认换行
#echo -n "拖入文件:"    
## 把键盘输入放入变量               
#read  file_path    
#
#echo -n "Enter 过滤规则 使用 | 分离,如 14532|flutter:"
#read  filter_name
#
#egrep -i "($filter_name)" $file_path > ${file_path%/*}/go
#
## 抽离字符串（将/ 前的str全部保留） {file_path%/*}
#
## 打开对应的app
#open -a "sublime text" ${file_path%/*}/go
#
## echo ${file_path%/*}/go
## 返回一个零退出状态，退出shell程序
#exit 0  






