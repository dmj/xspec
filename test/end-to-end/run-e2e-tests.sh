#!/bin/bash

# This script must be run from the script's directory

# .xspec files directory
CASES_DIR=cases

# XSpec output directory (same as default)
export TEST_DIR=${CASES_DIR}/xspec

# Run test cases
for CASE_FILEPATH in ${CASES_DIR}/*.xspec
do
    CASE_FILENAME=${CASE_FILEPATH##*/}
    CASE_BASENAME=${CASE_FILENAME%.xspec}

    # Generate the report HTML
    if test "${CASE_FILENAME:0:10}" = "schematron"; then
        ../../bin/xspec.sh -j -s ${CASE_FILEPATH} > /dev/null 2>&1
    elif test "${CASE_FILENAME:0:6}" = "xquery"; then
        ../../bin/xspec.sh -j -q ${CASE_FILEPATH} > /dev/null 2>&1
    else
        ../../bin/xspec.sh -j ${CASE_FILEPATH} > /dev/null 2>&1
    fi

    # Compare with the expected HTML
    if java -classpath ${SAXON_CP} net.sf.saxon.Transform -s:${TEST_DIR}/${CASE_BASENAME}-result.html -xsl:processor/html/compare.xsl | grep '^OK: Compared '
        then
            # OK, nothing to do
            :
        else
            echo "FAILED: ${CASE_FILEPATH}"
            exit 1
    fi

    # Compare with the expected JUnit report
    if java -classpath ${SAXON_CP} net.sf.saxon.Transform -s:${TEST_DIR}/${CASE_BASENAME}-junit.xml -xsl:processor/junit/compare.xsl | grep '^OK: Compared '
        then
            # OK, nothing to do
            :
        else
            echo "FAILED: ${CASE_FILEPATH}"
            exit 1
    fi
done
