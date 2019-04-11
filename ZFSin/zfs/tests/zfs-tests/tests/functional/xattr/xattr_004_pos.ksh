#!/bin/ksh
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
# Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#

#
# Copyright (c) 2013 by Delphix. All rights reserved.
#

. $STF_SUITE/include/libtest.shlib
. $STF_SUITE/tests/functional/xattr/xattr_common.kshlib

#
# DESCRIPTION:
#
# Creating files on ufs|ext2 and tmpfs, and copying those files to ZFS with
# appropriate cp flags, the xattrs will still be readable.
#
# STRATEGY:
#	1. Create files in ufs|ext2 and tmpfs with xattrs
#       2. Copy those files to zfs
#	3. Ensure the xattrs can be read and written
#	4. Do the same in reverse.
#

# we need to be able to create zvols to hold our test
# ufs|ext2 filesystem.
verify_runnable "global"

# Make sure we clean up properly
function cleanup {

	if [ $( ismounted /tmp/$NEWFS_DEFAULT_FS.$$ $NEWFS_DEFAULT_FS ) ]
	then
		log_must $UMOUNT /tmp/$NEWFS_DEFAULT_FS.$$
		log_must $RM -rf /tmp/$NEWFS_DEFAULT_FS.$$
	fi
}

log_assert "Files from $NEWFS_DEFAULT_FS,tmpfs with xattrs copied to zfs retain xattr info."
log_onexit cleanup

# Create a UFS|EXT2 file system that we can work in
log_must $ZFS create -V128m $TESTPOOL/$TESTFS/zvol
[[ -n "$LINUX" || -n "$OSX" ]] && $SLEEP 1
log_must eval "$ECHO y | $NEWFS $ZVOL_DEVDIR/$TESTPOOL/$TESTFS/zvol > /dev/null 2>&1"

log_must $MKDIR /tmp/$NEWFS_DEFAULT_FS.$$
log_must $MOUNT $ZVOL_DEVDIR/$TESTPOOL/$TESTFS/zvol /tmp/$NEWFS_DEFAULT_FS.$$

# Create files in ufs|ext2 and tmpfs, and set some xattrs on them.
log_must $TOUCH /tmp/$NEWFS_DEFAULT_FS.$$/$NEWFS_DEFAULT_FS-file.$$
log_must $TOUCH /tmp/tmpfs-file.$$

log_must $RUNAT /tmp/$NEWFS_DEFAULT_FS.$$/$NEWFS_DEFAULT_FS-file.$$ $CP /etc/passwd .
log_must $RUNAT /tmp/tmpfs-file.$$ $CP /etc/group .

# copy those files to ZFS
log_must $CP -@ /tmp/$NEWFS_DEFAULT_FS.$$/$NEWFS_DEFAULT_FS-file.$$ $TESTDIR
log_must $CP -@ /tmp/tmpfs-file.$$ $TESTDIR

# ensure the xattr information has been copied correctly
log_must $RUNAT $TESTDIR/$NEWFS_DEFAULT_FS-file.$$ $DIFF passwd /etc/passwd
log_must $RUNAT $TESTDIR/tmpfs-file.$$ $DIFF group /etc/group

log_must $UMOUNT /tmp/$NEWFS_DEFAULT_FS.$$
log_pass "Files from $NEWFS_DEFAULT_FS,tmpfs with xattrs copied to zfs retain xattr info."
