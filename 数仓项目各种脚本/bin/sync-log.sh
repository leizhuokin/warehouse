#!/bin/bash
sync_log_host=(node03)
function start_sync_log() {

  for i in $sync_log_host; do
    echo --------- starting sync log kafka to hdfs on "${i}" ----------
    ssh $i "source /etc/profile;nohup ${FLUME_HOME}/bin/flume-ng agent --conf conf  --conf-file \${JOB_HOME}/conf/flume/kafka_to_hdfs_log.conf --name a1 > \${JOB_HOME}/logs/kafka-to-hdfs-log-${i}.log 2>&1 &"
  done
}

function stop_sync_log() {

  for i in $sync_log_host; do
    echo --------- stoping sync log kafka to hdfs on "${i}" ----------
    ssh $i "ps -ef | grep kafka_to_hdfs_log.conf | grep -v grep | awk '{print \$2}'  | xargs -n1 kill"
  done
}
function status_sync_log() {

  for i in $sync_log_host; do
    echo --------- status sync log kafka to hdfs on "${i}" ----------
    s_id=$(ssh $i "ps -ef | grep kafka_to_hdfs_log.conf | grep -v grep | awk '{print \$2}'")
    if [ "${s_id}" != "" ] ;then
        echo "${s_id} Sync_log"
    else
        echo 'sync log 程序未运行'
    fi
  done
}
case $1 in
start)
  start_sync_log
  ;;
stop)
  stop_sync_log
  ;;
status)
  status_sync_log
  ;;
*)
  echo "Usage $0 (start|stop|status)"
  ;;
esac
