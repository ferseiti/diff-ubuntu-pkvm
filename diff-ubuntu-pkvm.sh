#!/bin/bash

# Current remotes are 
# git://kernel.ubuntu.com/ubuntu/ubuntu-xenial.git
# https://github.com/open-power-host-os/linux (branch powerkvm-v3.1.1)

GIT_DIR=$1
BRANCH1=$2
BRANCH2=$3
CUR_DIR=`pwd`

function usage() 
{
	cat <<-EOM
	Usage: $(basename $0) <directory> <branch1> <branch2> 
	EOM

	exit 1
}

function get_git_log()
{
	cd $GIT_DIR
	git checkout $BRANCH1
	git log e2f712dc927e3b9a981ecd86a64d944d0b140322..HEAD --pretty=oneline > $CUR_DIR/$BRANCH1.log
	git branch
	git checkout $BRANCH2
	git log e2f712dc927e3b9a981ecd86a64d944d0b140322..HEAD --pretty=oneline > $CUR_DIR/$BRANCH2.log
	git branch
}

if [ ! -d $1 ]; then
	echo "\"$1\" is not a valid directory"
	usage
	exit 1
else
	if [ -z $2 ] || [ -z $3 ]; then
		usage
		exit 1
	fi
fi

get_git_log
