#!/bin/bash
# Builds the OpenFlux Go core (https://github.com/Kingofthedivanich/OpenFlux-WebGui)
# as an iOS static library and installs it (plus the cgo-generated header)
# into Lib/, ready for the Xcode project to link.
#
# Usage: ./build-openflux.sh /path/to/OpenFlux-WebGui
# Needs: Go (version from that repo's go.mod), Xcode command line tools.
set -e

SRC="${1:?usage: $0 /path/to/OpenFlux-WebGui}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR/Lib"
LIBRARY_NAME="liboflux"

XCODE_PATH="${XCODE_PATH:-/Applications/Xcode.app}"
DEVELOPER_DIR="$XCODE_PATH/Contents/Developer"
SDK_PATH="$DEVELOPER_DIR/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"
CLANG="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

if [ ! -d "$SDK_PATH" ]; then
    echo "SDK not found: $SDK_PATH" >&2
    exit 1
fi
if [ ! -f "$CLANG" ]; then
    echo "Compiler not found: $CLANG" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

export GOARCH=arm64
export GOOS=ios
export CGO_ENABLED=1
export SDK_PATH="$SDK_PATH"
export CC="$CLANG -isysroot $SDK_PATH -arch arm64 -miphoneos-version-min=13.0"
export CXX="${CLANG}++ -isysroot $SDK_PATH -arch arm64 -miphoneos-version-min=13.0"
export CGO_CFLAGS="-isysroot $SDK_PATH -arch arm64 -miphoneos-version-min=13.0"
export CGO_LDFLAGS="-isysroot $SDK_PATH -arch arm64 -miphoneos-version-min=13.0"

echo "Building for iOS (arm64) from $SRC..."

if (
    cd "$SRC"
    go build \
        -buildmode=c-archive \
        -ldflags="-w" \
        -trimpath \
        -o "$OUT_DIR/$LIBRARY_NAME.a" \
        ./cmd/openflux
); then
    # Header liboflux.h is generated automatically by cgo from //export directives.
    commit="$(git -C "$SRC" rev-parse HEAD)"
    printf 'OpenFlux %s\n%s\n' "$commit" "$(go version)" > "$SCRIPT_DIR/openflux-version.txt"
    echo "Build complete: $OUT_DIR/$LIBRARY_NAME.a (from $commit)"
    ls -lh "$OUT_DIR/$LIBRARY_NAME.a"
else
    echo "Build failed" >&2
    exit 1
fi
