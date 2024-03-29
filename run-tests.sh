#!/bin/bash

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
projectDir=${scriptDir}

testsBuildDir=${projectDir}/build/tests
cmakeAmalgamation=OFF
# Check if the OS is supported.
cmakeOS=$("${projectDir}"/.scripts/get-os.sh)
# shellcheck disable=SC2181
if [[ $? != 0 ]]; then
    echo "This OS \"${cmakeOS}\" can't run the tests."
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
    --coverage=*)
        coverageType="${1#*=}"
        ;;
    --gcov-tool=*)
        gcovTool="${1#*=}"
        ;;
    --amalgamation)
        cmakeAmalgamation=ON
        ;;
    *)
        cat <<EOF
The argument "$1" can't be recognized.
Supported args:
--coverage:
    - raw -> run the tests with coverage generating a Gcov raw report
    - html -> run the tests with coverage generating an HTML report

--amalgamation: links the library to a single header generated from the original ones
EOF
        exit 1
        ;;
    esac
    shift
done

if [[ ! "${coverageType}" ]]; then
    enableCoverage=OFF
    targetName=run-tests
    generateHtmlReport=OFF
elif [[ "${coverageType}" = "html" ]]; then
    enableCoverage=ON
    targetName=coverage-report
    generateHtmlReport=ON
elif [[ "${coverageType}" = "raw" ]]; then
    enableCoverage=ON
    targetName=coverage-report
    generateHtmlReport=OFF
else
    cat <<EOF
The value of "coverage" can't be recognized.
Supported values:
    - raw -> run the tests with coverage generating a Gcov raw report
    - html -> run the tests with coverage generating an HTML report
EOF
    exit 1
fi

if [[ ! "${gcovTool}" ]]; then
    cmake "${projectDir}" -B"${testsBuildDir}" \
        -DCMAKE_C_COMPILER="${CC}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DAMALGAMATION=$cmakeAmalgamation \
        -DENABLE_TESTS=ON \
        -DENABLE_TESTS_COVERAGE=${enableCoverage} \
        -DGENERATE_HTML_REPORT=${generateHtmlReport}
else
    cmake "${projectDir}" -B"${testsBuildDir}" \
        -DCMAKE_C_COMPILER="${CC}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DAMALGAMATION=$cmakeAmalgamation \
        -DENABLE_TESTS=ON \
        -DENABLE_TESTS_COVERAGE=${enableCoverage} \
        -DGENERATE_HTML_REPORT=${generateHtmlReport} \
        -DGCOV_TOOL="${gcovTool}"
fi

(cd "${testsBuildDir}" && make $targetName)
