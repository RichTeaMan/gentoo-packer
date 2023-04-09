#!/bin/bash

set -e
if [ ! -f resources/stage3*.tar.* ]
then
	cd resources/
	wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230402T170151Z/stage3-amd64-systemd-mergedusr-20230402T170151Z.tar.xz
	cd ..
fi

rm output-gentoo-systemd/ -rf && PACKER_LOG=1 packer build gentoo-systemd.pkr.hcl

