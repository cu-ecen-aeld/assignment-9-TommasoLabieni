#!/bin/sh

scull_module="scull"
scull_device="scull"

mode="664"

function load_scull_dev()
{
    if test ${#} -ne 1
    then
        echo "Major number required!"
        exit 1
    fi
    
    major=${1}
    
    rm -f /dev/${scull_device}[0-3]
    mknod /dev/${scull_device}0 c $major 0
    mknod /dev/${scull_device}1 c $major 1
    mknod /dev/${scull_device}2 c $major 2
    mknod /dev/${scull_device}3 c $major 3
    ln -sf ${scull_device}0 /dev/${scull_device}
    chmod $mode  /dev/${scull_device}[0-3]

    rm -f /dev/${scull_device}pipe[0-3]
    mknod /dev/${scull_device}pipe0 c $major 4
    mknod /dev/${scull_device}pipe1 c $major 5
    mknod /dev/${scull_device}pipe2 c $major 6
    mknod /dev/${scull_device}pipe3 c $major 7
    ln -sf ${scull_device}pipe0 /dev/${scull_device}pipe
    chmod $mode  /dev/${scull_device}pipe[0-3]

    rm -f /dev/${scull_device}single
    mknod /dev/${scull_device}single  c $major 8
    chmod $mode  /dev/${scull_device}single

    rm -f /dev/${scull_device}uid
    mknod /dev/${scull_device}uid   c $major 9
    chmod $mode  /dev/${scull_device}uid

    rm -f /dev/${scull_device}wuid
    mknod /dev/${scull_device}wuid  c $major 10
    chmod $mode  /dev/${scull_device}wuid

    rm -f /dev/${scull_device}priv
    mknod /dev/${scull_device}priv  c $major 11
    chmod $mode  /dev/${scull_device}priv

    echo "module: $scull_module loaded."

}

function unload_scull_dev()
{
    rmmod $scull_module $* || exit 1

    rm -f /dev/${scull_device} /dev/${scull_device}[0-3] 
    rm -f /dev/${scull_device}priv
    rm -f /dev/${scull_device}pipe /dev/${scull_device}pipe[0-3]
    rm -f /dev/${scull_device}single
    rm -f /dev/${scull_device}uid
    rm -f /dev/${scull_device}wuid

    echo "module $scull_module unloaded."
}

if test ${#} -ne 1
then
    echo "Wrong number of parameters"
    exit 1
fi

case ${1} in
"start")
    echo "Running load ldd drivers daemon"
    echo "Load scull module, exit on failure"
    insmod /lib/modules/$(uname -r)/extra/$scull_module.ko $* || exit 1
    echo "Get the major number (allocated with allocate_chrdev_region) from /proc/devices"
    major=$(awk "\$2==\"$scull_module\" {print \$1}" /proc/devices)
    echo "scull major number is: ${major}"

    # load scull device
    load_scull_dev "$major"

    ;;
"stop")
    echo "Stopping load ldd drivers daemon"

    # unload scull device
    unload_scull_dev "$major"

    ;;
*)
    echo "Invalid option \"${1}\""
    exit 2
    ;;
esac

exit 0