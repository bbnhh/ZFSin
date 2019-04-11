#!/usr/bin/env ksh
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#

#
# Copyright (c) 2013 by Delphix. All rights reserved.
#

. $STF_SUITE/include/libtest.shlib

ZFS_USER=zfsrbac
USES_NIS=false

# if we're running NIS, turn it off until we clean up
# (it can cause useradd to take a long time, hitting our TIMEOUT)
$SVCS svc:/network/nis/client:default | $GREP online > /dev/null
if [ $? -eq 0 ]
then
  $SVCADM disable svc:/network/nis/client:default
  USES_NIS=true
fi


# create a unique user that we can use to run the tests,
# making sure not to clobber any existing users.
FOUND=""
while [ -z "${FOUND}" ]
do
  USER_EXISTS=$( grep $ZFS_USER /etc/passwd )
  if [ ! -z "${USER_EXISTS}" ]
  then
      ZFS_USER="${ZFS_USER}x"
  else
      FOUND="true"
  fi
done

log_must $MKDIR -p /export/home/$ZFS_USER
log_must $USERADD -c "ZFS Privileges Test User" -d /export/home/$ZFS_USER $ZFS_USER

echo $ZFS_USER > /tmp/zfs-privs-test-user.txt
echo $USES_NIS > /tmp/zfs-privs-test-nis.txt

log_pass
