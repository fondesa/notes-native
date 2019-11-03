#!/bin/bash

# The first argument can be ON or OFF to enable or disable the amalgamation.
cmakeAmalgamation=$1

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
projectDir=${scriptDir}/..

if [[ ! -x "$(command -v xcodebuild)" ]]; then
    echo "Xcode must be installed before building the library for iOS."
    exit 1
fi

libName="notesnative"
iosBuildDir=${projectDir}/build/lib/ios
iosFrameworkDir=${iosBuildDir}/framework
iosFrameworkFileName=${libName}.framework
iosUniversalFrameworkDir=${iosFrameworkDir}/universal

function build_universal_framework() {
    local universalFramework=${iosUniversalFrameworkDir}/${iosFrameworkFileName}

    build_framework_for_sdk iphoneos
    build_framework_for_sdk iphonesimulator

    local phoneFramework=${iosFrameworkDir}/iphoneos/${iosFrameworkFileName}
    local simulatorFramework=${iosFrameworkDir}/iphonesimulator/${iosFrameworkFileName}

    rm -rf "${iosUniversalFrameworkDir}"
    mkdir -p "${iosUniversalFrameworkDir}"

    # Copy the files from the iphoneos framework to the universal one.
    cp -r "${phoneFramework}"/. "${universalFramework}"

    # Create the universal framework using the simulator and the phone framework.
    # shellcheck disable=SC2216
    lipo "${simulatorFramework}"/${libName} "${phoneFramework}"/${libName} -create -output "${universalFramework}"/${libName} | echo

    # Change the install name of the framework to avoid absolute paths.
    install_name_tool -id "@rpath/${iosFrameworkFileName}/$libName" "${universalFramework}"/${libName}
}

function build_framework_for_sdk() {
    local sdk=$1

    # The target generated by CMake for ios is "lib-ios".
    (cd "${iosBuildDir}" && xcodebuild -target lib-ios \
        -configuration "Release" \
        -UseModernBuildSystem=NO \
        -sdk "${sdk}" \
        CONFIGURATION_BUILD_DIR="${iosFrameworkDir}"/"${sdk}" \
        clean \
        build)

    # shellcheck disable=SC2181
    if [[ $? != 0 ]]; then
        exit 1
    fi
}

echo "Building iOS shared lib..."

cmake "${projectDir}" -B"${iosBuildDir}" -GXcode \
    -DENABLE_TESTS=OFF \
    -DAMALGAMATION="${cmakeAmalgamation}" \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=9.3

build_universal_framework

libFilePath=${iosUniversalFrameworkDir}/${iosFrameworkFileName}
if [[ "${PREBUILT_LIBS}" ]]; then
    libSymPath=${PREBUILT_LIBS}/${libName}/ios
    echo "Symlinking the iOS library from \"${libFilePath}\" to \"${libSymPath}\""
    mkdir -p "$libSymPath"
    ln -sf "${libFilePath}" "${libSymPath}"
fi