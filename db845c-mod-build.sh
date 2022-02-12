#!/bin/bash
set -e

rm -rf ./mod ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/*

if [[ "$1" == "--no-merge" ]]; then
	 echo "not touching the config"
else
	docker-kernel-build.sh arm64 "./scripts/kconfig/merge_config.sh arch/arm64/configs/gki_defconfig arch/arm64/configs/db845c_gki.fragment"
fi

docker-kernel-build.sh arm64 "make -j32 Image.gz qcom/sdm845-db845c.dtb > /dev/null"
docker-kernel-build.sh arm64 "make -j32 modules > /dev/null"
cp arch/arm64/boot/dts/qcom/sdm845-db845c.dtb ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/
docker-kernel-build.sh arm64 "make modules_install INSTALL_MOD_PATH=\$\{PWD\}/mod/ "
cp `find mod/ | grep .ko` ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/
if [[ "$1" == "--full" ]]; then
	echo Doing full GKI build test
	docker-kernel-build.sh arm64 "make gki_defconfig > /dev/null" 
	docker-kernel-build.sh arm64 "make -j32 Image.gz > /dev/null"
fi
cp arch/arm64/boot/Image.gz ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/
pushd ~/projects/android/dragonboard/ 
rm -rf out/target/product/db845c/vendor*
rm -rf out/target/product/db845c/ramdisk*
set +e
rm `find out/target/product/ | grep .ko`
set -e
docker-android-build.sh db845c "make TARGET_KERNEL_USE=mainline -j32"
set +e
adb reboot bootloader
set -e
fastboot flash boot out/target/product/db845c/boot.img 
fastboot flash vendor_boot out/target/product/db845c/vendor_boot.img
fastboot flash super out/target/product/db845c/super.img
fastboot reboot

popd

