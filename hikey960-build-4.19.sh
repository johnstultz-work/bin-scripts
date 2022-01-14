#!/bin/bash
set -e

docker-kernel-build.sh arm64 "make -j32 Image.gz hisilicon/hi3660-hikey960.dtb > /dev/null"
cp arch/arm64/boot/dts/hisilicon/hi3660-hikey960.dtb ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/4.19/hi3660-hikey960.dtb
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/hisilicon/hi3660-hikey960.dtb >  ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/4.19/Image.gz-dtb
pushd ~/projects/android/hikey/
docker-android-build.sh hikey960 make TARGET_KERNEL_USE=4.19 -j32 

set +e
adb reboot bootloader
set -e

fastboot flash boot out/target/product/hikey960/boot.img
fastboot flash dts out/target/product/hikey960/dt.img
#fastboot flash vendor out/target/product/hikey960/vendor.img
fastboot flash super out/target/product/hikey960/super.img
if [[ "$1" == "--full" ]]; then
	fastboot flash system out/target/product/hikey960/system.img
fi
fastboot reboot
popd

