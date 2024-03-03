#!/bin/bash

function start_mock_log() {
   source /etc/profile
   start-mock-logs.sh $1
}

function start_mock_db() {
   source /etc/profile
   start-mock-dbs.sh $1
}

# start-mock.sh [log|db] [日期]
# start-mock.sh
# start-mock.sh log
# start-mock.sh db
# start-mock.sh 2022-11-09
# start-mock.sh log 2022-11-09
# start-mock.sh db 2022-11-09

# YYYY-MM-dd  10位
function check_date() {
    dt=$1
    len_dt=${#dt}
    dt=${dt//-/}
    len_dt2=${#dt}
    p=$((${len_dt} - ${len_dt2}))
    if [ 2 -eq $p ] ; then
      tt=`date -d "$1" +"%Y-%m-%d"`
      return $?
    elif [ 8 -eq $len_dt2 ]; then
        tt=`date -d "$1" +"%Y-%m-%d"`
        return $?
    else return 1
    fi
}

case $1 in
""){
  start_mock_log ""
  start_mock_db ""
};;
"log"){
  start_mock_log $2
};;
"db"){
  start_mock_db $2
};;
*){
  check_date $1
  if [ "0" == "$?" ]; then
      start_mock_log $1
      start_mock_db $1
  else
    echo "Usage: start-mock.sh [log|db] [date]"
  fi
};;
esac
