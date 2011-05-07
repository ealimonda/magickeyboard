#!/bin/bash
#*******************************************************************************************************************
#*                                     MagicKeyboard :: UpdateRevision                                             *
#*******************************************************************************************************************
#* File:             UpdateRevision.sh                                                                             *
#* Copyright:        (c) 2011 alimonda.com; Emanuele Alimonda                                                      *
#*                   This software is free software: you can redistribute it and/or modify it under the terms of   *
#*                       the GNU General Public License as published by the Free Software Foundation, either       *
#*                       version 3 of the License, or (at your option) any later version.                          *
#*                   This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;    *
#*                       without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. *
#*                   See the GNU General Public License for more details.                                          *
#*                   You should have received a copy of the GNU General Public License along with this program.    *
#*                       If not, see <http://www.gnu.org/licenses/>                                                *
#*******************************************************************************************************************
#* $Id::                                                                               $: SVN Info                 *
#* $Date::                                                                             $: Last modification        *
#* $Author::                                                                           $: Last modification author *
#* $Revision::                                                                         $: SVN Revision             *
#*******************************************************************************************************************

BASEVERNUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${INFOPLIST_FILE}" | sed 's/,/, /g')
REV=$(svnversion -nc | /usr/bin/sed -e 's/^[^:]*://;s/[A-Za-z]//')
SVNDATE=$(LC_ALL=C svn info | awk '/^Last Changed Date:/ {print $4,$5}')
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BASEVERNUM.$REV" "${TARGET_BUILD_DIR}"/${INFOPLIST_PATH}
/usr/libexec/PlistBuddy -c "Set :BuildDateString $SVNDATE" "${TARGET_BUILD_DIR}"/${INFOPLIST_PATH}
