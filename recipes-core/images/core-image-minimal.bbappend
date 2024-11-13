# Add WiFi/Bluetooth/Ethernet related softwares/drivers
IMAGE_INSTALL:append = " bluez5 \
                         wilc3000-fw \
                         wilc \
                         iw \
                         usb-gadget-ethernet \
                         ethtool \
                         net-tools \
                         "

# SSH server
EXTRA_IMAGE_FEATURES:append = " ssh-server-openssh"
IMAGE_INSTALL:append = " openssh-sftp openssh-sftp-server"

# Misc
IMAGE_INSTALL:append = " libftdi \
                         devmem2 \
                         util-linux-lsblk \
                         vim \
                         python3 \
                         binutils \
                         ldd \
                         "

# Debug tweaks (see https://docs.yoctoproject.org/ref-manual/features.html#ref-features-image)
EXTRA_IMAGE_FEATURES:append = " debug-tweaks empty-root-password allow-empty-password"
