#!/bin/bash

BASEVERNUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${INFOPLIST_FILE}" | sed 's/,/, /g')
REV=$(svnversion -nc | /usr/bin/sed -e 's/^[^:]*://;s/[A-Za-z]//')
SVNDATE=$(LC_ALL=C svn info | awk '/^Last Changed Date:/ {print $4,$5}')
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BASEVERNUM.$REV" "${TARGET_BUILD_DIR}"/${INFOPLIST_PATH}
/usr/libexec/PlistBuddy -c "Set :BuildDateString $SVNDATE" "${TARGET_BUILD_DIR}"/${INFOPLIST_PATH}

