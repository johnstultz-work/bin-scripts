#!/bin/bash
if [ -z "$1/initrd.img" ]; then
   echo "Please specify the path to initrd/boot image"
   exit
fi

make -j24  zImage qcom-apq8064-asus-nexus7-flo.dtb > /dev/null && \
cat ./arch/arm/boot/zImage ./arch/arm/boot/dts/qcom-apq8064-asus-nexus7-flo.dtb > $1/zImage.dtb && \
abootimg --create $1/boot.img -k $1/zImage.dtb  -r $1/initrd.img  -f $1/bootimg.cfg-mine && \
fastboot flash boot $1/boot.img  && \
fastboot reboot

