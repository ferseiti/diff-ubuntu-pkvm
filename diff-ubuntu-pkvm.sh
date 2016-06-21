#!/bin/bash

# Current remotes are 
# git://kernel.ubuntu.com/ubuntu/ubuntu-xenial.git
# https://github.com/open-power-host-os/linux (branch powerkvm-v3.1.1)

BRANCH1=$1
BRANCH2=$2
CUR_DIR=`pwd`

# A lot of temorary files which will be deleted
export TMPDIR=`mktemp -d scratch.XXX --tmpdir`
COMMIT_BRANCH1=`mktemp commit1.XXX --tmpdir`
COMMIT_BRANCH2=`mktemp commit2.XXX --tmpdir`
BRANCH_LOG1=`mktemp branch_log1.XXX --tmpdir`
BRANCH_LOG2=`mktemp branch_log2.XXX --tmpdir`
COMMENTS_BRANCH2=`mktemp comments.XXX --tmpdir`
AUX_FILE=`mktemp aux_file.XXX --tmpdir`

function finish()
{
	rm -rf $TMPDIR
	echo "Temporary directory deleted."
}

function usage() 
{
	cat <<-EOM
	Usage: $(basename $0) <branch1> <branch2> 
	EOM

	exit 1
}

function get_git_log()
{
	MERGE_BASE=`git merge-base $BRANCH1 $BRANCH2`
	git checkout $BRANCH1
	git branch
	git log --pretty=oneline | tr -s " " > $BRANCH_LOG1
	echo "Branch $BRANCH1: log copied."

	git checkout $BRANCH2
	git branch
	git log --grep="\([Cc]ommit\|[Bb]ased\ on\)\ [0-9a-f]\{40\}\ upstream" \
                --grep="[Uu]pstream commit\ [0-9a-f]\{40\}" \
                --invert-grep $MERGE_BASE..HEAD --pretty=oneline | \
                tr -s " " > $BRANCH_LOG2
	echo "Branch $BRANCH2: log copied."
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

# The sed below removes the Linux versions commits from the result.
    fgrep -v -f $AUX_FILE $BRANCH_LOG2 | \
        sed '/[a-f0-9]\{40\}\ Linux\ .\+/d' > diff_commits-all.txt

    git checkout $BRANCH2
    git log --grep="This\ reverts\ commit\ [0-9a-f]\{40\}" $MERGE_BASE..HEAD \
        --pretty=format:%H > $AUX_FILE
    sed ':a;N;$!ba;s/\n/ /g' $AUX_FILE | \
        xargs git show -s > reverts-show
    grep "This\ reverts\ commit\ [0-9a-f]\{40\}" reverts-show | \
         grep -o '[0-9a-f]\{40\}' >> $AUX_FILE
    fgrep -v -f $AUX_FILE diff_commits-all.txt > diff_commits-final.txt
    git show -s `cut -f1 -d' ' diff_commits-final.txt | sed ':a;N;$!ba;s/\n/ /g'` > finalresultshow.txt

    set -e
}

#!/bin/bash

if [ -z $1 ] || [ -z $2 ]; then
	usage
	exit 1
fi

trap finish EXIT

get_git_log
search_commit

if [ $? -eq 0 ]
then
	echo "Finished!"
	echo "Results can be verified in file diff_commits-final.txt"
fi
