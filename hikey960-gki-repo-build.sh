#!/bin/bash
set -e

if [ ! -f $PWD/build/build.sh ] ;then
  echo "Doesn't look like an Android kernel repo build dir"
  exit
fi

if [[ ${LTO} == "" ]]; then
   echo "default LTO=full"
   LTO=""
else
   echo "using LTO=${LTO}"
fi

rm -rf out/android*
rm -rf ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/5.4/*
rm ./build.config
ln -s common/build.config.hikey960 ./build.config
docker-kernel-repo.sh "env LTO=${LTO} build/build.sh"
#docker-kernel-repo.sh build/build.sh

cp out/android*/dist/* ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/5.4/

if [[ "$1" == "--full" ]]; then
	echo Doing full GKI build test

	rm -rf out/android*
	rm build.config
	ln -s common/build.config.gki.aarch64 build.config
	docker-kernel-repo.sh "env LTO=${LTO} build/build.sh"
	#docker-kernel-repo.sh build/build.sh

	if [ ! -f $PWD/out/android*/dist/Image.gz ] ;then
		gzip out/android*/dist/Image
	fi
	cp out/android*/dist/Image.gz ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/5.4/
fi

cat ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/5.4/Image.gz ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/5.4/hi3660-hikey960.dtb  >  ~/projects/android/hikey/device/linaro/hikey-kernel/hikey960/5.4/Image.gz-dtb

pushd ~/projects/android/hikey/ 
rm -rf out/target/product/hikey960/vendor*
rm -rf out/target/product/hikey960/ramdisk*
set +e
rm `find out/target/product/ | grep .ko`
set -e
docker-android-build.sh hikey960 "make TARGET_KERNEL_USE=5.4 HIKEY_USES_GKI=true -j32"
set +e
adb reboot bootloader
set -e
fastboot flash boot out/target/product/hikey960/boot.img 
#fastboot flash vendor out/target/product/hikey960/vendor.img
fastboot flash super out/target/product/hikey960/super.img
fastboot reboot

popd

