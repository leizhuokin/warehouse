#!/bin/bash
#Zookeeper所在节点
#zk_hosts=(node01 node02 node03)
zk_hosts=$(cat /etc/hosts | grep -v "^#" | awk '{print $2}')
#允许通过命令行传递zk所在节点列表
while getopts "h:" opt
do
  case $opt in
    h){
      zk_hosts=$(echo $OPTARG | tr ',' ' ')
     };;
  esac
done
shift $(($OPTIND -1))
#环境检测
for i in $zk_hosts
  do
      ssh "${i}" 'source /etc/profile
      ZOOKEEPER_HOME=${ZOOKEEPER_HOME}
      if [ -z "${ZOOKEEPER_HOME}" ];then
        echo "$(hostname) ZOOKEEPER_HOME not found in your environment"
        exit 1
      fi'
  done
function start_zk() {
  for i in $zk_hosts
  do
      echo "--------- starting zk on ${i} ---------"
      ssh "${i}" "${ZOOKEEPER_HOME}/bin/zkServer.sh start"
  done
}

function stop_zk() {
  for i in $zk_hosts
  do
      echo "--------- stoping zk on ${i} ---------"
      ssh "${i}" "${ZOOKEEPER_HOME}/bin/zkServer.sh stop"
  done
}
function status_zk() {
  for i in $zk_hosts
  do
      echo "--------- zk status on ${i} ---------"
      ssh "${i}" "${ZOOKEEPER_HOME}/bin/zkServer.sh status"
  done
}
function status_jps() {
  for i in $zk_hosts
  do
      echo "--------- zk on ${i} ---------"
      ssh "${i}" "jps | grep QuorumPeerMain"
  done
}

case "$1" in
	start )
		start_zk
		;;
	stop )
		stop_zk
		;;
	restart )
		stop_zk
		start_zk
		;;
	status )
		status_zk
		;;
	jps )
		status_jps
		;;
	* )
		echo "Usage: $0 [-h {hostname1,hostname2}] {start|stop|restart|status|jps}"
		;;
esac
