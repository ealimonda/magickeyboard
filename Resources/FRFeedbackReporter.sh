#!/bin/sh

#*******************************************************************************************************************
#*                                     MagicKeyboard :: FeedbackReporter                                           *
#*******************************************************************************************************************
#* File:             FRFeedbackReporter.sh                                                                         *
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

pwd
system_profiler SPLogsDataType|grep -A 30 'class AppleMultitouchDevice,'|grep -B 25 '| }'
