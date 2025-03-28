# Add WiFi/Bluetooth/Ethernet related softwares/drivers
IMAGE_INSTALL:append:ultra96v2 = " bluez5 \
                         wilc3000-fw \
                         wilc \
                         iw \
                         wpa-supplicant \
                         usb-gadget-ethernet \
                         ethtool \
                         net-tools \
                         "

# SSH server
EXTRA_IMAGE_FEATURES:append:ultra96v2 = " ssh-server-openssh"
IMAGE_INSTALL:append:ultra96v2 = " openssh-sftp openssh-sftp-server"

# Misc
IMAGE_INSTALL:append:ultra96v2 = " libftdi \
                         devmem2 \
                         util-linux-lsblk \
                         vim \
                         python3 \
                         binutils \
                         ldd \
			 lrzsz \
                         "

# Debug tweaks (see https://docs.yoctoproject.org/ref-manual/features.html#ref-features-image)
EXTRA_IMAGE_FEATURES:append:ultra96v2 = " debug-tweaks empty-root-password allow-empty-password"

# OpenAMP
IMAGE_INSTALL:append:ultra96v2 = " kernel-module-uio-pdrv-genirq \
                                   kernel-module-virtio-rpmsg-bus \
                                   kernel-module-zynqmp-r5-remoteproc \
                                   "

IMAGE_INSTALL:append:ultra96v2 = " openamp-fw-echo-testd rpmsg-echo-test rpmsg-utils"

KERNEL_MODULE_AUTOLOAD:remove = " kernel-module-zynqmp-r5-remoteproc"

# Mailbox
IMAGE_INSTALL:append:ultra96v2 = " kernel-module-zynqmp-ipi-mailbox-client"
IMAGE_INSTALL:append:ultra96v2 = " openamp-fw-echo-mailbox-testd"

