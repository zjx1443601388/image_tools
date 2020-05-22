#!/bin/bash

:<<!
2020-05-22: 初稿编辑v1

!
FS_TYPE="xfs"
OS_DISTRO=
BASEDIR=/usr/lib/python2.7/site-packages/diskimage_builder/elements
LOG=/var/log/dib-image-`date "+%Y%m%d"`.log


###centos
function use_help(){
    cat <<EOF
Usage: $0 COMMAND [options]

Options:
    --distro, -d <System version>:             Specify operating system version


Commands:
    dib:                 Diskimagebuiled  tool builed images
    oz:                  OZ tool builed images 
    win-resize:          windows resize tools
EOF

}

#disk-image-create -o centos7.3-trusty-0723-test-v1 -t raw vm centos7
# image_url=http://cloud.centos.org/centos/7/images/
function centos_release() {
    grub_num=`grep GRUB_CMDLINE_LINUX_DEFAULT ${BASEDIR}/bootloader/finalise.d/50-bootloader |wc -l`
    if [ $grub_num -lt 1 ]; then
    sed -i "s/GRUB_CMDLINE_LINUX/GRUB_CMDLINE_LINUX_DEFAULT/g" ${BASEDIR}/bootloader/finalise.d/50-bootloader 
    sed -i 's/^export DIB_RELEASE/#export DIB_RELEASE/g' ${BASEDIR}/centos7/environment.d/10-centos7-distro-name.bash
    fi
    export FS_TYPE=$FS_TYPE
    export DIB_AVOID_PACKAGES_UPDATE=1

    case "$OS_DISTRO" in 
    centos7.2)
        export DIB_RELEASE="GenericCloud-1511"
        ;;
    centos7.3)
        export DIB_RELEASE="GenericCloud-1611"
        ;;
    centos7.4)
        export DIB_RELEASE="GenericCloud-1708"
        ;;
    centos7.5)
        export DIB_RELEASE="GenericCloud-1804_02"
        ;;
    centos7.6)
        export DIB_RELEASE="GenericCloud-1811"
        ;;
    centos7.7)
        export DIB_RELEASE="GenericCloud-1907"
        ;;
    *)
        echo "No such os_distro"
        exit 1
        ;;
    esac
#    echo $DIB_RELEASE
}

###ubuntu

function ubuntu_release() {
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT/GRUB_CMDLINE_LINUX/g" ${BASEDIR}/bootloader/finalise.d/50-bootloader
    export DIB_BOOTLOADER_DEFAULT_CMDLINE="nofb nomodeset"
    
    case "$OS_DISTRO" in
    ubuntu14)
        export DIB_RELEASE="trusty"
        ;;
    ubuntu16)
        export DIB_RELEASE="xenial"
        ;;
    ubuntu18)
        export DIB_RELEASE="bionic"
        ;;
    *)
        echo "No such os_distro"
        exit 1
        ;;
    esac
}

###Debian

function debian_release() {
    sed -i "s/GRUB_CMDLINE_LINUX/GRUB_CMDLINE_LINUX_DEFAULT/g" ${BASEDIR}/bootloader/finalise.d/50-bootloader 
    case "$OS_DISTRO" in 
    debian8)
        export DIB_RELEASE="jessie"
        ;;
    debian9)
        export DIB_RELEASE="stretch"
        ;;
    *)
        echo "No such os_distro"
        exit 1
        ;;
     esac
}

function opensuse_release() {
    export DIB_RELEASE=42.3
}

function dib(){

    SUB_DISTRO=`echo $OS_DISTRO|sed -r "s/[0-9]+\.{0,1}+[0-9]//g"`

    if [[ ${SUB_DISTRO} == "centos" ]];then
        centos_release
        disk-image-create -o ${SUB_DISTRO}-DIB-`date "+%Y%m%d"` -t raw vm centos7 >> $LOG
        printf "`date '+%Y%m%d'` \n" >> $LOG
        qemu-img info ${SUB_DISTRO}-DIB-`date "+%Y%m%d"`
    elif [[ ${SUB_DISTRO} == "ubuntu" ]];then
        ubuntu_release
    elif [[ ${SUB_DISTRO} == "debian" ]];then
        debian_release
    elif [[ ${SUB_DISTRO} == "opensuse" ]];then
        opensuse_release
    else
        echo "Error"
        exit 1
    fi

}

SHORT_OPTS="hd:f:"
LONG_OPTS="help,distro:,file:"
ARGS=$(getopt -o "${SHORT_OPTS}" -l "${LONG_OPTS}" --name "$0" -- "$@") || { usage >&2; exit 2; }

eval set -- "$ARGS"

while [ "$#" -gt 0 ];do
    case "$1" in
    --distro|-d)
         OS_DISTRO="$2"
         shift 2
         ;;
    --file|-f)
         OUTPUT_FILE="$2"
         shift 2
         ;;
    --help|-h)
         use_help
         shift
         exit 0
         ;;
    --)
         shift
         break
         ;;
    *)  
         echo "Error!"
         exit 1
         ;;      
    esac
done

case $1 in
(oz)
        echo oz
        ;;
(dib)
        dib
        ;;

(win-resize)
        echo win-resize
        ;;

(*)
        use_help
        exit 0
        ;;

esac



 
