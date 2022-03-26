# !/usr/bin/env bash

# I didn't want to use a file for this solution
out=""
n=0

# Effectively, we're continuing until "magic-number.sh" returns 1 (error)
until [[ "$?" -ne 0 ]]
do
  let n=$n+1 # alternatively, n=$((n+1))
  # We get both stdout and stderr by redirecting stderr to stdout
  out+="$( ./magic-number.sh 2>&1 )
"
done

# Print them out
echo "$out"
echo "The script ran $n times before encountering an error"

