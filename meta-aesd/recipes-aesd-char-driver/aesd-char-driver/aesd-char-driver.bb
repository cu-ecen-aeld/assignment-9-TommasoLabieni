# Recipe created by recipetool
# This is the basis of a recipe and may need further editing in order to be fully functional.
# (Feel free to remove these comments when editing.)

# WARNING: the following LICENSE and LIC_FILES_CHKSUM values are best guesses - it is
# your responsibility to verify that the values are complete and correct.
#
# The following license files were not able to be identified and are
# represented as "Unknown" below, you will need to check them yourself:
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://git@github.com/cu-ecen-aeld/assignments-3-and-later-TommasoLabieni.git;protocol=ssh;branch=master \
           file://manage_aesdchar_driver.sh"

# Modify these as desired
PV = "1.0+git${SRCPV}"
SRCREV = "e540083e522dc34e30a8e1fe2cd8c6683c3dadc6"

S = "${WORKDIR}/git/aesd-char-driver"

inherit module

MODULES_INSTALL_TARGET = "install"

EXTRA_OEMAKE:append:task-install = " -C ${STAGING_KERNEL_DIR} M=${S}/aesd-char-driver/"
EXTRA_OEMAKE += "KERNELDIR=${STAGING_KERNEL_DIR} DEBUG=y"

inherit update-rc.d

INITSCRIPT_NAME = "manage_aesdchar_driver.sh"
INITSCRIPT_PACKAGES = "${PN}"

# Updated for aesd
FILES:${PN} += "${bindir}/aesdchar_load"
FILES:${PN} += "${bindir}/aesdchar_unload"
FILES:${PN} += "${sysconfdir}/init.d/manage_aesdchar_driver.sh"

do_install () {
	install -d ${D}${bindir}
	install -m 0755 ${S}/aesdchar_load ${D}${bindir}
	install -m 0755 ${S}/aesdchar_unload ${D}${bindir}

	install -d ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/manage_aesdchar_driver.sh ${D}${sysconfdir}/init.d

	install -d ${D}${base_libdir}/modules/5.15.150-yocto-standard/extra
	install -m 0755 ${S}/aesdchar.ko ${D}${base_libdir}/modules/5.15.150-yocto-standard/extra
}