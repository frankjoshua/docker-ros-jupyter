#!/bin/bash

ARCH_NAME=$(dpkg-architecture -q DEB_BUILD_ARCH)

if [[ $ARCH_NAME == "arm64" ]]; 
then
ARCH_NAME="aarch64"
fi

if [[ $ARCH_NAME == "amd64" ]]; 
then
ARCH_NAME="x86_64"
fi


echo $ARCH_NAME