#!/bin/bash
set -e

if [ ! -f $PWD/build/build.sh ] ;then
  echo "Doesn't look like an Android kernel repo build dir"
  exit
fi

if [[ ${LTO} == "" ]]; then
   echo "default LTO"
   LTO=""
else
   echo "using LTO=${LTO}"
fi


rm -rf out/android*
rm -rf ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/*
rm build.config
ln -s common/build.config.db845c build.config
docker-kernel-repo.sh "env LTO=${LTO} build/build.sh"
#docker-kernel-repo.sh build/build.sh

mkdir -p ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/
cp out/android*/dist/* ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/

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
	cp out/android*/dist/Image.gz ~/projects/android/dragonboard/device/linaro/dragonboard-kernel/android-mainline/
fi


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
fastboot flash super out/target/product/db845c/super.img
fastboot reboot

popd

