#!/usr/bin/env bash
set -euo pipefail

secure_rand() {
  local max=$1
  local num
  while true; do
    num=$(openssl rand -hex 4)
    num=$((16#$num))
    local limit=$(( (2**32 / (max + 1)) * (max + 1) ))
    if (( num < limit )); then
      echo $(( num % (max + 1) ))
      return
    fi
  done
}

numbers=(1 2 3 4 5 6 7 8 9 10)

# Fisher–Yates shuffle using secure randomness

for ((i=${#numbers[@]}-1; i>0; i--)); do
  j=$(secure_rand "$i")
  temp=${numbers[i]}
  numbers[i]=${numbers[j]}
  numbers[j]=$temp
done

printf "%s\n" "${numbers[@]}"
