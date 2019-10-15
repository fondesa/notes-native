#!/bin/bash

function install_osx() {
    local formulae=()
    # Install GCC if needed.
    if [[ "$CC" == "$CC_GCC" ]]; then
        formulae+=(gcc)
    fi

    # Install LCOV only when the tests are run with coverage.
    # This is optimal since we don't want to install it in jobs which don't use it.
    if [[ "$RUN_TESTS_WITH_COVERAGE" == "true" ]]; then
        formulae+=(lcov)
    fi

    for formula in "${formulae[@]}"; do
        for retry in $(seq 1 3); do
            echo "Upgrading ${formula}"
            brew outdated | grep -q "$formula"
            STATUS="$?"
            if [ "${STATUS}" -ne 0 ]; then
                echo "Already up to date or not installed."
                break
            fi

            brew upgrade "$formula"
            STATUS="$?"
            if [ "${STATUS}" -eq 0 ]; then
                break
            fi
            echo "Attempt ${retry} failed."
            if [ "${retry}" -eq 3 ]; then
                echo "Too many retries. Aborting."
                exit 1
            else
                echo "Retrying..."
            fi
        done
    done

    for formula in "${formulae[@]}"; do
        for retry in $(seq 1 3); do
            echo "Installing ${formula}"
            brew list | grep -q "$formula" || brew install "$formula"
            STATUS="$?"
            if [ "${STATUS}" -eq 0 ]; then
                break
            fi
            echo "Attempt ${retry} failed."
            if [ "${retry}" -eq 3 ]; then
                echo "Too many retries. Aborting."
                exit 1
            else
                echo "Retrying..."
            fi
        done
    done
}

function install_linux() {
    sudo add-apt-repository ppa:jonathonf/gcc-9.2 -y
    sudo apt-get update

    # Install GCC if needed.
    if [[ "$CC" == "$CC_GCC" ]]; then
        sudo apt-get install gcc-9
    fi

    # Install LCOV only when the tests are run with coverage.
    # This is optimal since we don't want to install it in jobs which don't use it.
    if [[ "$RUN_TESTS_WITH_COVERAGE" == "true" ]]; then
        sudo apt-get install lcov
    fi
}

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    install_osx
elif [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    install_linux
fi
