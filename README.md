# meta-ultra96v2

Layer for the Ultra96v2 board with BSP and Apps.

No petalinux required, and based on [meta-avnet](https://github.com/Avnet/meta-avnet) content.

Build performed on Ubuntu 22.04

## Manual installation
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

## Automatic installation
TODO: use a manifest.

## Build
Start build.
```sh
bitbake core-image-minimal
```

## Flash SD card.

Use the flash.sh script available in `scripts`.
```
../meta-ultra96v2/scripts/flash.sh /dev/sdc ~/yocto/builds/langdale/ultra96/tmp/deploy/images/ultra96v2/
```

See [How to format SD card for SD boot](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842385/How+to+format+SD+card+for+SD+boot) for more informations.

## WiFi configuration

TODO.