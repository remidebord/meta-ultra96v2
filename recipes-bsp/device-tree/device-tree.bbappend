FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:ultra96v2 = " file://system-bsp.dtsi \
							 file://openamp.dtsi \
						   "

# Remove avnet-ultra96-rev1 dependency
YAML_DT_BOARD_FLAGS:u96v2-sbc ?= "{BOARD template}"

do_configure:append:ultra96v2 () {
	echo '#include "system-bsp.dtsi"' >> ${DT_FILES_PATH}/system-top.dts
	echo '#include "openamp.dtsi"' >> ${DT_FILES_PATH}/system-top.dts
}
