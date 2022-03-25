# !/bin/sh

# Reset
rm -rf ~/dev/projects/knowledge-share/missing-semester/topic-1-the-shell/tmp

## Exercise 1
echo $SHELL

## Exercise 2
# I changed it from /tmp to ./tmp to avoid issues
mkdir -p ./tmp/missing

## Exercise 3
# man touch

## Exercise 4
touch ./tmp/missing/semester

## Exercise 5
echo "#!/bin/sh" >> ./tmp/missing/semester
echo "curl --head --silent https://missing.csail.mit.edu" >> ./tmp/missing/semester

## Exercise 6
# This breaks because we didn't add the `x` permission

## Exercise 7
# sh is a POSIX-compliant command interpreter (shell).  It is implemented by re-execing as either
# bash(1), dash(1), or zsh(1) as determined by the symbolic link located at /private/var/select/sh.

# With `sh`, I'm executing the code through the `sh` command, for which I have +x permissions
# If I try to run locally, it will check the file's permissions which currently don't have +x permissions
# sh ./tmp/missing/semester

## Exercise 8
# man chmod

## Exercise 9
chmod +x ./tmp/missing/semester

## Exercise 10
./tmp/missing/semester | grep "last-modified" > ./tmp/last-modified.txt

## Exercise 11
# I have a macOS, so I'm skipping