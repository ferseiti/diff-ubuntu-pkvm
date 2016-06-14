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
	MERGE_BASE=`git merge-base $BRANCH1 $BRANCH2`
	git checkout $BRANCH1
	git log $MERGE_BASE..HEAD --pretty=oneline > $BRANCH_LOG1
	git branch

	git checkout $BRANCH2
	git log $MERGE_BASE..HEAD --pretty=oneline > $BRANCH_LOG2
	git branch
}

# First, the function below will create 2 files.
# One with just the commit hashes and another with only the comment
# header. Then it will run fgrep from each over the log and output the
# difference to diff_commits-final.txt

function search_commit()
{
	set +e
	cut -f1 -d' ' $BRANCH_LOG2 > $COMMIT_BRANCH2
	cut --fields=2- -d' ' $BRANCH_LOG2 > $COMMENTS_BRANCH2
	fgrep -o -f $COMMIT_BRANCH2 $BRANCH_LOG1 > $AUX_FILE
	fgrep -o -f $COMMENTS_BRANCH2 $BRANCH_LOG1 >> $AUX_FILE
	fgrep -v -f $AUX_FILE $BRANCH_LOG2 > $CUR_DIR/diff_commits-final.txt
	set -e
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

# A lot of temorary files which will be deleted
COMMIT_BRANCH1=$CUR_DIR/`mktemp commit.XXX`
COMMIT_BRANCH2=$CUR_DIR/`mktemp commit.XXX`
BRANCH_LOG1=$CUR_DIR/`mktemp branch_log.XXX`
BRANCH_LOG2=$CUR_DIR/`mktemp branch_log.XXX`
COMMENTS_BRANCH2=$CUR_DIR/`mktemp comments.XXX`
AUX_FILE=$CUR_DIR/`mktemp aux_file.XXX`

get_git_log
search_commit
cd $CUR_DIR
rm $COMMIT_BRANCH1 $COMMIT_BRANCH2 $BRANCH_LOG1 $BRANCH_LOG2 \
   $COMMENTS_BRANCH2 $AUX_FILE
