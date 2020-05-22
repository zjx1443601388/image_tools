#/bin/bash

source /root/openstack

while read line; do 
    image_id=`echo $line|awk '{print $1}'`
    image_name=`echo $line|awk '{print $2}'`
    if [ ! -f $image_name ];then 
        echo "begin save " $image_name
        openstack image save  $image_id --file $image_name
        if [ $? == 0 ];then
            echo "save success "$image_name
        else
            echo "faile save " $image_name
            exit 1
        fi
    else
        echo "exist " $image_name
    fi
done<image_list.txt
