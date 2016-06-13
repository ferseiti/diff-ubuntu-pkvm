#!/bin/bash

# Current remotes are 
# git://kernel.ubuntu.com/ubuntu/ubuntu-xenial.git
# https://github.com/open-power-host-os/linux (branch powerkvm-v3.1.1)

GIT_DIR=$1
BRANCH1=$2
BRANCH2=$3
CUR_DIR=`pwd`
COMMIT_BRANCH1=`mktemp commit.XXX`
COMMIT_BRANCH2=`mktemp commit.XXX`
BRANCH_LOG1=`mktemp branch_log.XXX`
BRANCH_LOG2=`mktemp branch_log.XXX`

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
	git log e2f712dc927e3b9a981ecd86a64d944d0b140322..HEAD --pretty=oneline > $CUR_DIR/$BRANCH_LOG1
	git branch

	git checkout $BRANCH2
	git log e2f712dc927e3b9a981ecd86a64d944d0b140322..HEAD --pretty=oneline > $CUR_DIR/$BRANCH_LOG2
	git branch
}

function search_commit()
{
	cut -f1 -d' ' $CUR_DIR/$BRANCH_LOG2 > $CUR_DIR/$COMMIT_BRANCH2
#	while read commit; do
#		fgrep "$commit" $CUR_DIR/$BRANCH1.log
#	done< "$CUR_DIR/commit_$BRANCH1.log"
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
search_commit
cd $CUR_DIR
#rm $COMMIT_BRANCH1 $COMMIT_BRANCH2 $BRANCH_LOG1 $BRANCH_LOG2
