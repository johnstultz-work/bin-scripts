#!/bin/bash

#mkdir ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/pixel3_mainline/
docker-kernel-build.sh arm64 "make -j24 Image.gz qcom/sdm845-blueline.dtb > /dev/null" && \
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/qcom/sdm845-blueline.dtb >  ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/pixel3_mainline/Image.gz-dtb && \
pushd ~/projects/android/dragonboard/ && \
docker-android-build.sh pixel3_mainline make PIXEL3_USES_GKI=false -j32 && \
adb reboot bootloader

fastboot set_active b
fastboot flash boot out/target/product/pixel3_mainline/boot.img && \
#fastboot flash system out/target/product/pixel3_mainline/super.img && \
fastboot reboot
popd

