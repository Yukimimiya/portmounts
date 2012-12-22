#!/bin/sh
# portsmount - 
#  a tool for ports developper and beta testers.

# Copyright: 2012 Takeshi Taguchi, 

#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.

PORTSDIR=${PORTSDIR:-/usr/ports}; # CHANGE THIS if needed.
EXCLUDES="\.git \.svn"
VERB=0
while getopts "p:x:v" flag; do
    case $flag in
	\?) OPT_ERROR=1; break;;
	p) PORTSDIR="$OPTARG";;
	x) EXCLUDES="${EXCLUDES} $OPTARG";;
	v) VERB=1;;
    esac
done

shift $(( $OPTIND - 1 ))

if [ $OPT_ERROR ]; then
    echo >2& "usage: $0 [-p PORTSDIR] [-x EXCLUDES ...] [-v] REPOS ..."
    exit 1
fi

for i in "$@"; do
    [ -d "${i}/Mk" ] && mount -t unionfs "${i}/Mk" "${PORTSDIR}/Mk"
    find $i -name Makefile -type f -depth 3 | while read LINE; do
	for j in ${EXCLUDES}; do
	    LINE=`echo "$LINE" | egrep -v -e "${j}"`
	    [ -z "${LINE}" ] && break
	done
	[ -z "${LINE}" ] && continue
	dirname=${LINE%/*}
	portname=${dirname##*/}
	category=${dirname%/*}
	category=${category##*/}
	if [ -d "${PORTSDIR}/${category}" -a \
	    ! -d "${PORTSDIR}/${category}/${portname}" ]; then
		[ ${VERB} ] && echo "New Port: ${category}/${portname}"
		mkdir -p "${PORTSDIR}/${category}/${portname}"
	fi
	[ "x${VERB}" != "x0" ] && echo "Mount: ${dirname} -> ${PORTSDIR}/${category}/${portname}"
	mount -t nullfs "${dirname}" "${PORTSDIR}/${category}/${portname}"
    done
done
