#!/bin/sh

aesdchar_module="aesdchar"
aesdchar_device="aesdchar"

mode="664"

function load_aesdchar_dev()
{
    if test ${#} -ne 1
    then
        echo "Major number required!"
        exit 1
    fi
    
    major=${1}
    
    rm -f /dev/${aesdchar_device}[0-3]
    mknod /dev/${aesdchar_device}0 c $major 0
    mknod /dev/${aesdchar_device}1 c $major 1
    mknod /dev/${aesdchar_device}2 c $major 2
    mknod /dev/${aesdchar_device}3 c $major 3
    ln -sf ${aesdchar_device}0 /dev/${aesdchar_device}
    chmod $mode  /dev/${aesdchar_device}[0-3]

    rm -f /dev/${aesdchar_device}pipe[0-3]
    mknod /dev/${aesdchar_device}pipe0 c $major 4
    mknod /dev/${aesdchar_device}pipe1 c $major 5
    mknod /dev/${aesdchar_device}pipe2 c $major 6
    mknod /dev/${aesdchar_device}pipe3 c $major 7
    ln -sf ${aesdchar_device}pipe0 /dev/${aesdchar_device}pipe
    chmod $mode  /dev/${aesdchar_device}pipe[0-3]

    rm -f /dev/${aesdchar_device}single
    mknod /dev/${aesdchar_device}single  c $major 8
    chmod $mode  /dev/${aesdchar_device}single

    rm -f /dev/${aesdchar_device}uid
    mknod /dev/${aesdchar_device}uid   c $major 9
    chmod $mode  /dev/${aesdchar_device}uid

    rm -f /dev/${aesdchar_device}wuid
    mknod /dev/${aesdchar_device}wuid  c $major 10
    chmod $mode  /dev/${aesdchar_device}wuid

    rm -f /dev/${aesdchar_device}priv
    mknod /dev/${aesdchar_device}priv  c $major 11
    chmod $mode  /dev/${aesdchar_device}priv

    echo "module: $aesdchar_module loaded."

}

function unload_aesdchar_dev()
{
    rmmod $aesdchar_module $* || exit 1

    rm -f /dev/${aesdchar_device} /dev/${aesdchar_device}[0-3] 
    rm -f /dev/${aesdchar_device}priv
    rm -f /dev/${aesdchar_device}pipe /dev/${aesdchar_device}pipe[0-3]
    rm -f /dev/${aesdchar_device}single
    rm -f /dev/${aesdchar_device}uid
    rm -f /dev/${aesdchar_device}wuid

    echo "module $aesdchar_module unloaded."
}

if test ${#} -ne 1
then
    echo "Wrong number of parameters"
    exit 1
fi

case ${1} in
"start")
    echo "Running load ldd drivers daemon"
    echo "Load aesdchar module, exit on failure"
    insmod /lib/modules/$(uname -r)/extra/$aesdchar_module.ko $* || exit 1
    echo "Get the major number (allocated with allocate_chrdev_region) from /proc/devices"
    major=$(awk "\$2==\"$aesdchar_module\" {print \$1}" /proc/devices)
    echo "aesdchar major number is: ${major}"

    # load aesdchar device
    load_aesdchar_dev "$major"

    ;;
"stop")
    echo "Stopping load ldd drivers daemon"

    # unload aesdchar device
    unload_aesdchar_dev "$major"

    ;;
*)
    echo "Invalid option \"${1}\""
    exit 2
    ;;
esac

exit 0