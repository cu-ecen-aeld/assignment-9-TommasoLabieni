# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
#
# The following license files were not able to be identified and are
# represented as "Unknown" below, you will need to check them yourself:
#   LICENSE
LICENSE = "Unknown"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f098732a73b5f6f3430472f5b094ffdb"

SRC_URI = "git://git@github.com/cu-ecen-aeld/assignment-7-TommasoLabieni.git;protocol=ssh;branch=master \
           file://0001-Include-only-scull-and-misc-modules-drivers.patch \
           file://manage_misc_modules_driver.sh"

# Modify these as desired
PV = "1.0+git${SRCPV}"
SRCREV = "e614c3208e7874962e8340e2f5d8716103a3a4a9"

S = "${WORKDIR}/git"

inherit module

MODULES_INSTALL_TARGET = "install"

EXTRA_OEMAKE:append:task-install = " -C ${STAGING_KERNEL_DIR} M=${S}/misc-modules"
EXTRA_OEMAKE += "KERNELDIR=${STAGING_KERNEL_DIR}"

inherit update-rc.d

INITSCRIPT_NAME = "manage_misc_modules_driver.sh"
INITSCRIPT_PACKAGES = "${PN}"

# Updated for misc-modules
FILES:${PN} += "${sysconfdir}/init.d/manage_misc_modules_driver.sh"

do_install () {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/manage_misc_modules_driver.sh ${D}${sysconfdir}/init.d

	install -d ${D}${base_libdir}/modules/5.15.150-yocto-standard/extra
	install -m 0755 ${S}/misc-modules/faulty.ko ${D}${base_libdir}/modules/5.15.150-yocto-standard/extra
	install -m 0755 ${S}/misc-modules/hello.ko ${D}${base_libdir}/modules/5.15.150-yocto-standard/extra
}