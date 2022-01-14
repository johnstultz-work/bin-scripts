#!/bin/bash

#cleanup
rm -rf ./mod ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/4.19/*  && \
#kernel and module build
docker-kernel-build.sh arm64 "make -j32 Image.gz > /dev/null" && \
cp arch/arm64/boot/dts/hisilicon/hi3660-hikey960.dtb ~/projects/android/hikey/device/linaro/hikey-kernel/hi3660-hikey960.dtb-4.19 && \
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/hisilicon/hi3660-hikey960.dtb >  ~/projects/android/hikey/device/linaro/hikey-kernel/Image.gz-dtb-hikey960-4.19 && \
pushd ~/projects/android/hikey/ && \
rm -rf out/target/product/db845c/ramdisk* && \
docker-android-build.sh hikey960 make TARGET_KERNEL_USE=4.19 HIKEY_USES_GKI=true -j32  && \
adb reboot bootloader

# flash the board
fastboot flash boot out/target/product/hikey960/boot.img && \
fastboot flash dts out/target/product/hikey960/dt.img && \
fastboot reboot
popd

