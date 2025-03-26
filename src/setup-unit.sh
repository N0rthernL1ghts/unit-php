#!/usr/bin/env bash

set -eux

main() {
    local unit_opt="/opt/unit/"

    mkdir /rootfs-build/var/lib/unit/state/certs -p

    if [ -d "${unit_opt}/usr/" ]; then
        rsync -ah --progress "${unit_opt}/usr" /rootfs-build/
        rm -rf "${unit_opt}"
        return
    fi

    if [ -f "${unit_opt}/sbin/unitd" ]; then
        mkdir -p /rootfs-build/sbin /rootfs/opt
        mv "${unit_opt}" "/rootfs-build/opt/"
        ln -sf "${unit_opt}/sbin/unitd" /rootfs-build/sbin/unitd
        return
    fi

    echo "Error: Nginx Unit not found in ${unit_opt}" >&2
    ls -al "${unit_opt}"
    return 1
}

main "${@}"
