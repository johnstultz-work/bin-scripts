#!/bin/bash

docker-kernel-build.sh arm64 "make -j32 Image.gz hisilicon/hi3660-hikey960.dtb > /dev/null" && \
cp arch/arm64/boot/dts/hisilicon/hi3660-hikey960.dtb ~/projects/android/hikey/device/linaro/hikey-kernel/hi3660-hikey960.dtb-4.14 && \
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/hisilicon/hi3660-hikey960.dtb >  ~/projects/android/hikey/device/linaro/hikey-kernel/Image.gz-dtb-hikey960-4.14 && \
pushd ~/projects/android/hikey/ && \
docker-android-build.sh hikey960 make TARGET_KERNEL_USE=4.14 -j32  && \
adb reboot bootloader

fastboot flash boot out/target/product/hikey960/boot.img && \
fastboot flash dts out/target/product/hikey960/dt.img && \
fastboot reboot
popd

