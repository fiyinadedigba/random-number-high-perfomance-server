#!/usr/bin/env bash

set -euo pipefail

# Initialize the array
numbers=(1 2 3 4 5 6 7 8 9 10)

# Fisher-Yates shuffle approach
for ((i=${#numbers[@]}-1; i>0; i--)); do
  j=$((RANDOM % (i + 1)))
  
  # Swap
  temp=${numbers[i]}
  numbers[i]=${numbers[j]}
  numbers[j]=$temp
done

# Print result
printf "%s\n" "${numbers[@]}"
