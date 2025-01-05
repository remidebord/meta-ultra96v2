# meta-ultra96v2

Layer for the Ultra96v2 board with BSP and Apps.

No petalinux required, and based on [meta-avnet](https://github.com/Avnet/meta-avnet) content.

Build performed on Ubuntu 22.04

## Prerequisite
Yocto will require the following packages for build:
```sh
sudo apt install build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit socat texinfo unzip wget xz-utils zstd
```
In addition, you will need to install libtinfo5.
```sh
sudo apt install libtinfo5
```

## Installation

```sh
repo init -u https://github.com/remidebord/meta-ultra96v2.git -m ultra96v2-2023.2.xml
repo sync

cd poky
TEMPLATECONF=meta-ultra96v2/conf/templates/ultra96v2-1 . oe-init-build-env
```

## (deprecated) Installation (Manual)
Install layers.
```sh
mkdir ultra96
cd ultra96/

git clone git://git.yoctoproject.org/poky
cd poky
git checkout langdale

. oe-init-build-env

cd ..
git clone https://github.com/openembedded/meta-openembedded.git
cd meta-openembedded/
git checkout langdale

cd ..
git clone https://github.com/Xilinx/meta-xilinx.git
cd meta-xilinx/
git checkout rel-v2023.2

git clone https://github.com/Xilinx/meta-xilinx-tools.git
cd meta-xilinx-tools/
git checkout rel-v2023.2

cd ..
git clone https://github.com/remidebord/meta-ultra96v2.git

bitbake-layers add-layer ../meta-xilinx/meta-xilinx-core/
bitbake-layers add-layer ../meta-xilinx/meta-xilinx-standalone
bitbake-layers add-layer ../meta-xilinx/meta-xilinx-bsp/
bitbake-layers add-layer ../meta-xilinx-tools/
bitbake-layers add-layer ../meta-openembedded/meta-oe/
bitbake-layers add-layer ../meta-openembedded/meta-python/
bitbake-layers add-layer ../meta-openembedded/meta-networking/
bitbake-layers add-layer ../meta-xilinx/meta-xilinx-vendor/
bitbake-layers add-layer ../meta-ultra96v2/
```

Open the local.conf and add the following (DL_DIR, SSTATE_DIR and TMPDIR should be updated to your needs).
```sh
## Custom

DL_DIR = "/home/red/yocto/downloads/langdale"
SSTATE_DIR = "/home/red/yocto/builds/langdale/ultra96/sstate-cache"
TMPDIR = "/home/red/yocto/builds/langdale/ultra96/tmp"

# Remove useless features added by default
DISTRO_FEATURES:remove = " alsa zeroconf 3g nfc x11"

# Add kernel sources to SDK
TOOLCHAIN_TARGET_TASK:append = " kernel-devsrc"

# Use systemd as init manager
DISTRO_FEATURES:append = " systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"

VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"
# could be replaced with: INIT_MANAGER = "systemd"

# Remove useless services
PACKAGECONFIG:remove_pn-systemd = " backlight hibernate hostnamed localed \
                                    quotacheck vconsole xz randomseed \
                                    nss polkit binfmt resolved utmp idn \
                                    nss-mymachines nss-resolve logind \
                                    timesyncd timedated "

# Board/machine
MACHINE = "ultra96v2"
```

## Build
Start build.
```sh
bitbake core-image-minimal
```

## Flash SD card.

Use the flash.sh script available in `scripts`.
```
sudo ../meta-ultra96v2/scripts/flash.sh /dev/sdb ~/build/ultra96/tmp/deploy/images/ultra96v2/
```

See [How to format SD card for SD boot](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842385/How+to+format+SD+card+for+SD+boot) for more informations.

## Tests

### Ethernet (via USB)

You can have access to Ethernet via USB (will require a USB3 micro-b cable).

First, start USB gadget script.
```sh
./usb_gadget_ethernet.sh
```
Note: script will attribute a default IP (e.g: 192.168.3.1) to usb0 interface.

Connect the USB cable and set a different IP address for the interface (e.g: enxea317c27b0b3) on your computer.
```sh
sudo ip addr add 192.168.3.2/24 dev enxea317c27b0b3
```

You should be able to ping the board.
```sh
ping 192.168.3.1 
```

### WiFi configuration

#### Infrastructure (typical)

First, set the interface up (wlan0).
```sh
ip link set wlan0 up
```

Scan access points availables.
```sh
iw dev wlan0 scan | grep SSID:
```

Once you got the SSID that you want to connect to, create the configuration file with the passphrase.
```sh
wpa_passphrase ssid passphrase > wpa.conf
```

Establish the connection.
```sh
wpa_supplicant -B -iwlan0 -c/home/root/wpa.conf
```

We could obtain an IP address, 
```sh
udhcpc -i wlan0
```
or configure it manually.
```sh
ip addr add 192.168.1.166/24 dev wlan0
```

#### Access point

TODO.

### Echo test (OpenAMP)
Make sure zynqmp_r5_remoteproc driver is loaded.
```sh
lsmod
```

If not loaded, load the driver.
```sh
modprobe zynqmp_r5_remoteproc
```

Load the echo_test firmware on r5 and start it.
```sh
echo image_echo_test > /sys/class/remoteproc/remoteproc0/firmware
echo start > /sys/class/remoteproc/remoteproc0/state
```

Run the test.
```sh
echo_test
```

After test completion, unload the application.
```sh
echo stop > /sys/class/remoteproc/remoteproc0/state
