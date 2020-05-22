#!/bin/bash


#virt-rescue检查分区是否正常·
function virt_rescue_fix(){
/usr/bin/expect <<EOF
spawn virt-rescue -a $1
expect "><rescue>"
send "ntfsfix -b -d /dev/sda2\r"
expect "><rescue>"
send "exit\r"
expect eof
EOF
}


#重新建立分区
function fdisk_image(){
echo "
p
d

p
n



+$1
p
t
2
7
p
w
" | fdisk $2
}

#functin push_windows_image(){
#openstack image create --file $1 --container-format bare --disk-format raw --property usage_type='common' --property hw_qemu_guest_agent=yes --property os_distro=windows --property os_type=windows --property os_admin_user=Administrator --property image_type=app --private $2
#
#}

#主函数入口
function main(){
#image_df=`virt-df -h $image_name |grep /dev/sda2 |awk '{print $3}'|awk -F 'G' '{print $1}'`
image_mb=`virt-df $image_name |grep /dev/sda2 |awk '{print $3}'`
image_gb=`echo "scale=1; $image_mb/1000/1000" | bc`
image_df=`echo $image_gb|awk -F '.' '{print $1}'`
image_other=`echo $image_gb|awk -F '.' '{print $2}'`
echo "image_df "$image_df
echo "image_other "$image_other
#11月22日 image_df都加1
if [ $image_other -lt 5 ];then
    image_set_guestfish_size=`expr $image_df + 2`
    image_set_qemu_size=`expr $image_df + 3`
else
    image_set_guestfish_size=`expr $image_df + 3`
    image_set_qemu_size=`expr $image_df + 4`
fi
#zore_num=`echo $image_df |grep "\." |wc -l`
#if [ $zore_num -eq 1 ];then
#    image_df=`echo $image_df |awk -F '.' '{print $1}'`
#    image_set_guestfish_size=`expr $image_df + 2`
#    image_set_qemu_size=`expr $image_df + 3`
#else
#    image_set_guestfish_size=`expr $image_df + 1`
#    image_set_qemu_size=`expr $image_df + 2`
#fi
echo $image_df
echo $image_set_guestfish_size
guestfish -a $image_name <<_EOF_
run
list-filesystems
ntfsresize-size /dev/sda2 ${image_set_guestfish_size}G
_EOF_

echo 11
virt_rescue_fix $image_name

fdisk_image ${image_set_guestfish_size}G $image_name
virt_rescue_fix $image_name
qemu-img resize -f raw $image_name ${image_set_qemu_size}G

}




while read line; do 
    image_name=`echo $line|awk '{print $2}'`
    exist_finish=`grep $image_name sem|wc -l`
    if [[ $exist_finish -eq 0 ]];then
        echo "begin resize " $image_name
        if [ ! -f $image_name ];then
            echo $image_name" is not exist"
            exit 2
        fi 
        main
        echo $image_name >> sem
    else
        echo $image_name" is had resize"
    fi
done<image_list.txt


