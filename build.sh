#!/bin/sh

set -eu

target() {
    local arch="$1"
    case "${arch}" in
        "x64" | "x86_64" | "amd64" | "")
            echo "x86_64-linux-musl"
            ;;
        "arm32v6")
            echo "armv6-linux-musleabihf"
            ;;
        "arm32v7")
            echo "armv7-linux-musleabihf"
            ;;
        "arm64v8")
            echo "aarch64-linux-musl"
            ;;
        *)
            >&2 echo Unsupported architecture: "${arch}"
            exit 1
            ;;
    esac
}

gcc_config() {
    local arch="$1"
    case "${arch}" in
        "arm32v6")
            echo "--with-arch=armv6"
            ;;
        "arm32v7")
            echo "--with-arch=armv7-a"
            ;;
        "" | *)
            echo ""
            ;;
    esac
}

config_mak() {
    local arch="$1"
    cat > $2 <<-EOF
    TARGET=$(target ${BUILD_ARCH:-""})
    OUTPUT=/usr/local
    GCC_CONFIG=$(gcc_config $arch)
	EOF
}

node_config() {
    local arch="$1"
    case "${arch}" in
        "x64" | "x86_64" | "amd64")
            echo ""
            ;;
        "arm32v6")
            echo "--with-arm-float-abi=hard --with-arm-fpu=vfp"
            ;;
        "arm32v7" | "arm64v8")
            echo "--with-arm-float-abi=hard --with-arm-fpu=neon"
            ;;
        "" | *)
            echo ""
            ;;
    esac
}

call() {
    local func="$1"
    shift
    ${func} "$@"
}

call "$@"
