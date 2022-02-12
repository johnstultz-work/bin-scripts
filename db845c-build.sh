#!/bin/bash
rm -rf ./mod ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/*.ko && \
mkdir -p ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline && \
docker-kernel-build.sh arm64 "make -j32 Image.gz qcom/sdm845-db845c.dtb > /dev/null" && \
cp arch/arm64/boot/dts/qcom/sdm845-db845c.dtb ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/  && \
cp arch/arm64/boot/Image.gz ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/ && \
pushd ~/projects/android/dragonboard/ && \
rm -rf out/target/product/db845c/vendor* &&\
rm -rf out/target/product/db845c/ramdisk* &&\
docker-android-build.sh db845c make TARGET_KERNEL_USE=mainline DB845C_USES_GKI=false -j32 && \
adb reboot bootloader

fastboot flash boot out/target/product/db845c/boot.img &&\
fastboot flash vendor_boot out/target/product/db845c/vendor_boot.img &&\
fastboot flash super out/target/product/db845c/super.img &&\
fastboot reboot
popd
