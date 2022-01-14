#!/bin/bash
if [ -z "$1" ]; then
   echo "Please specify the path to fat boot image"
   exit
fi

docker-kernel-build.sh arm64 "make -j32  Image.gz hisilicon/hi6220-hikey.dtb  > /dev/null" && \
cat arch/arm64/boot/Image.gz arch/arm64/boot/dts/hisilicon/hi6220-hikey.dtb > arch/arm64/boot/Image.gz-dtb
#normal quick method

adb reboot bootloader
abootimg -u $1 -k arch/arm64/boot/Image.gz-dtb
fastboot flash boot $1
sleep 1
fastboot reboot
exit

#slower full build (for modules)
cp arch/arm64/boot/Image.gz-dtb ~/projects/android/hikey/device/linaro/hikey-kernel/Image.gz-dtb-4.19 && \
rm -rf ~/projects/android/hikey/device/linaro/hikey-kernel/hikey/4.19/* ./mod;
docker-kernel-build.sh arm64 "make -j32 modules > /dev/null" && \
docker-kernel-build.sh arm64 "make modules_install INSTALL_MOD_PATH=\$\{PWD\}/mod/ " && \
cp `find mod/ | grep .ko` ~/projects/android/hikey/device/linaro/hikey-kernel/hikey/4.19/ && \
pushd ~/projects/android/hikey/ && \
rm `find out/target/product/ | grep .ko` && \
rm -rf out/target/product/hikey/vendor* && \
docker-android-build.sh hikey make -j32  && \
adb reboot bootloader

fastboot flash boot out/target/product/hikey/boot.img && \
fastboot flash vendor out/target/product/hikey/vendor.img && \
sleep 1 &&\
fastboot reboot
popd

