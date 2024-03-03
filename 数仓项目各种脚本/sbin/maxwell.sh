#!/bin/bash
#启动方式为 maxwell.sh start 2022-11-13
maxwell_host='node02'
mysql_host='localhost'
mysql_user='root'
mysql_password='123456'
mysql_jdbc_options='useSSL=false&serverTimezone=Asia/Shanghai'
maxwell_log_level='info'
maxwell_producer='kafka'
kafka_topic='dw_topic_db'
kafka_bootstrap_servers='node01:9092,node02:9092,node03:9092'
maxwell_start_date=$2
if [ "${maxwell_start_date}" == "" ];then
  maxwell_start_date=$(date +%F)
fi
function start_maxwell(){
  echo --------- starting maxwell on "${maxwell_host}" ----------
  ssh "${maxwell_host}" "source /etc/profile;"\${MAXWELL_HOME}"/bin/maxwell --log_level='${maxwell_log_level}' --mock_date='${maxwell_start_date}' --producer='${maxwell_producer}' --kafka.bootstrap.servers='${kafka_bootstrap_servers}' --kafka_topic='${kafka_topic}' --host='${mysql_host}' --user='${mysql_user}' --password='${mysql_password}' --jdbc_options='${mysql_jdbc_options}' --daemon"
}

function stop_maxwell(){
  echo --------- stoping maxwell on "${maxwell_host}" ----------
  ssh "${maxwell_host}" "ps -ef | grep com.zendesk.maxwell.Maxwell | grep -v grep | awk '{print \$2}' | xargs kill -9"
}

function status_maxwell(){
  echo --------- maxwell status on "${maxwell_host}" ----------
  ssh "${maxwell_host}" "echo \$(ps -ef | grep com.zendesk.maxwell.Maxwell | grep -v grep | awk '{print \$2}') Maxwell"
}
case $1 in
start)
  start_maxwell
  ;;
stop)
  stop_maxwell
  ;;
restart)
  stop_maxwell
  sleep 3s
  start_maxwell
  ;;
status)
  status_maxwell
  ;;
* )
  echo "Usage: $0 {start|stop|status|restart} [2022-11-13]"
  ;;
esac
