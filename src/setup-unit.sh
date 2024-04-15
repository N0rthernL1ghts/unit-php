#!/usr/bin/env bash

set -eux

main() {
    local unitOpt="/opt/unit/"

    mkdir /rootfs-build/var/lib/unit/state/certs -p

    if [ -d "${unitOpt}/usr/" ]; then
        rsync -ah --progress "${unitOpt}/usr" /rootfs-build/
        rm -rf "${unitOpt}"
        return
    fi

    if [ -f "${unitOpt}/sbin/unitd" ]; then
        mkdir -p /rootfs-build/sbin /rootfs/opt
        mv "${unitOpt}" "/rootfs-build/opt/"
        ln -sf "${unitOpt}/sbin/unitd" /rootfs-build/sbin/unitd
        return
    fi

    echo "Error: Nginx Unit not found in ${unitOpt}" >&2
    ls -al "${unitOpt}"
    return 1
}

main "${@}"
