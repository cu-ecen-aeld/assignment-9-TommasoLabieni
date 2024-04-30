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
    ln -sf ${aesdchar_device}0 /dev/${aesdchar_device}
    
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