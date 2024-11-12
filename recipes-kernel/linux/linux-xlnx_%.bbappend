FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:ultra96v2 = " file://avnet-bsp.cfg \
			      file://vitis_kconfig.cfg \
			      file://0001-hwmon-pmbus-Add-support-Infineon-IR38062-IR38063.patch \
			      file://fix_u96v2_pwrseq_simple.patch \
			      "
