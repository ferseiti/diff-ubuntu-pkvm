# diff-ubuntu-pkvm
The script compares 2 branches of the kernel.
This specific script was written to compare branch1=ubuntu and
branch2=powerkvm (IBM's), but can be easily adpated for other
repositories.

The branches must exist.
To run the script:
```
$ cd <linux-clone-dir>
$ /path/to/diff-ubuntu-pkvm.sh branch1 branch2
```
The result will be in the same format of a `git log --pretty=oneline`
command output, in the file diff_commits-final.txt.
