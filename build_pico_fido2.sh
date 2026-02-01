#!/bin/bash

VERSION_MAJOR="6"
VERSION_MINOR="6"
NO_EDDSA=0
SUFFIX="${VERSION_MAJOR}.${VERSION_MINOR}"
#if ! [[ -z "${GITHUB_SHA}" ]]; then
#    SUFFIX="${SUFFIX}.${GITHUB_SHA}"
#fi

mkdir -p build_release
mkdir -p release
rm -rf -- release/*
cd build_release

PICO_SDK_PATH="/opt/pico-sdk"
SECURE_BOOT_PKEY="${SECURE_BOOT_PKEY:-../../ec_private_key.pem}"
PICO_PLATFORM="rp2350"
PICO_SDK_TOOLCHAIN="/opt/gcc-arm-none-eabi"

boards=("waveshare_rp2350_one") # See all_boards.txt

# board_dir=${PICO_SDK_PATH}/src/boards/include/boards

for board_name in "${boards[@]}"
do
    rm -rf -- ./*
    PICO_SDK_PATH="${PICO_SDK_PATH}" PICO_TOOLCHAIN_PATH="${PICO_SDK_TOOLCHAIN}" PICO_PLATFORM="${PICO_PLATFORM}" cmake .. \
        -DPICO_BOARD=$board_name \
        -DENABLE_EDDSA=1 \
        -DENABLE_POWER_ON_RESET=1 \ # if you want to support Reset functionality
        -DENABLE_OATH_APP=1 \
        -DENABLE_OTP_APP=1 \
        -DVIDPID=Yubikey5
    make -j4
    mv pico_fido2.uf2 ../release/pico_fido2_$board_name-$SUFFIX.uf2
done
