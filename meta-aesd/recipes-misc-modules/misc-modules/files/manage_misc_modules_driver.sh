#!/bin/sh

faulty_module="faulty"
faulty_device="faulty"

hello_module="hello"
hello_device="hello"

mode="664"

function load_faulty_dev()
{
    if test ${#} -ne 1
    then
        echo "Major number required!"
        exit 1
    fi

    major=${1}

    rm -f /dev/${faulty_device}
    mknod /dev/${faulty_device} c $major 0
    chmod $mode  /dev/${faulty_device}

}

function unload_faulty_dev()
{
    rmmod $faulty_module || exit 1

    # Remove stale nodes

    rm -f /dev/${faulty_device}
}

function load_hello_dev()
{
    if test ${#} -ne 1
    then
        echo "Major number required!"
        exit 1
    fi

    major=${1}

    rm -f /dev/${hello_device}
    mknod /dev/${hello_device} c $major 0
    chmod $mode /dev/${hello_device}

}

function unload_hello_dev()
{
    rmmod $hello_module || exit 1

    # Remove stale nodes

    rm -f /dev/${hello_device}
}


if test ${#} -ne 1
then
    echo "Wrong number of parameters"
    exit 1
fi

case ${1} in
"start")
    echo "Running load ldd drivers daemon"

    echo "Load faulty module, exit on failure"
    insmod /lib/modules/$(uname -r)/extra/$faulty_module.ko $* || exit 1
    echo "Get the major number (allocated with allocate_chrdev_region) from /proc/devices"
    major=$(awk "\$2==\"$faulty_module\" {print \$1}" /proc/devices)
    echo "scull major number is: ${major}"

    # load faulty device
    load_faulty_dev "$major"

    echo "Load hello module, exit on failure"
    insmod /lib/modules/$(uname -r)/extra/$hello_module.ko $* || exit 1
    echo "Get the major number (allocated with allocate_chrdev_region) from /proc/devices"
    major=$(awk "\$2==\"$hello_module\" {print \$1}" /proc/devices)
    echo "scull major number is: ${major}"

    # load hello device
    load_hello_dev "$major"


    ;;
"stop")
    echo "Stopping load ldd drivers daemon"

    # unload faulty device
    unload_faulty_dev
    
    # unload hello device
    unload_hello_dev

    ;;
*)
    echo "Invalid option \"${1}\""
    exit 2
    ;;
esac

exit 0