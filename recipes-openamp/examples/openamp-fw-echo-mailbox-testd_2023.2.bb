FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

require openamp-fw.inc

XSCTH_APP = "OpenAMP echo-test"

SRC_URI:append = " file://mailbox_echo.c"

do_configure:prepend:ultra96v2 () {
        cp ${WORKDIR}/mailbox_echo.c ${WORKDIR}/git/lib/sw_apps/openamp_echo_test/src/system/generic/rpmsg-echo.c
}

OPENAMP_FW_NAME = "image_echo_mailbox_test"
