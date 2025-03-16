FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

#KERNELURI = "git://github.com/remidebord/linux-xlnx.git;protocol=https;name=machine"
#SRCREV_machine = "c2b2663ba85f568d4967819241972d6e00dc4b58"
#KBRANCH="mailbox"

SRC_URI:append:ultra96v2 = " file://avnet-bsp.cfg \
			     file://vitis_kconfig.cfg \
			     file://openamp.cfg \
			     file://mailbox.cfg \
			     file://0001-hwmon-pmbus-Add-support-Infineon-IR38062-IR38063.patch \
			     file://fix_u96v2_pwrseq_simple.patch \
			     "
