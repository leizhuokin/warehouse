#!/bin/bash
function rand(){
  min=$1
  max=$(($2-${min}+1))
  num=$(date +%s%N)
  echo $((${num}%${max}+${min}))
}
rnd=$(rand 1 50)
echo "$rnd"
