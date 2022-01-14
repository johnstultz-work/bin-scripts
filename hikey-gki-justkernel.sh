#!/bin/bash

#kernel and module build
docker-kernel-build.sh arm64 "make -j32 Image.gz > /dev/null" && \
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/hisilicon/hi6220-hikey.dtb >  ~/projects/android/hikey/device/linaro/hikey-kernel/Image.gz-dtb-4.19 && \
pushd ~/projects/android/hikey/ && \
rm -rf out/target/product/hikey/ramdisk* && \
docker-android-build.sh hikey make TARGET_KERNEL_USE=4.19 HIKEY_USES_GKI=true -j32  && \
adb reboot bootloader

# flash the board
fastboot flash boot out/target/product/hikey/boot.img && \
fastboot reboot
popd

