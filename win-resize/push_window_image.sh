#/bin/bash



source /root/openstack

while read image_name; do 
    exist_finish=`grep $image_name push_sem|wc -l`
    if [[ $exist_finish -eq 0 ]];then
        echo "begin push "$image_name
        openstack image create --file $image_name --container-format bare --disk-format raw --property usage_type='common' --property hw_qemu_guest_agent=yes --property os_distro=windows --property os_type=windows --property os_admin_user=Administrator --property image_type=app --private ${image_name}"-resize"
        echo $image_name >> push_sem
    else
        echo $image_name "had push"
    fi
done<sem

