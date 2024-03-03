#!/bin/bash
#HDFS NameNode所在节点
hdfs_hostname=$(hostname)
yarn_hostname=$(hostname)
#允许通过命令行传递NameNode和ResourceManager所在节点列表
while getopts "n:r:" opt
do
  case $opt in
    n){
      hdfs_hostname=$OPTARG
     };;
    r){
      yarn_hostname=$OPTARG
    };;
  esac
done
#环境检测
#source /etc/profile
#HADOOP_HOME=${HADOOP_HOME}
#if [ -z "${HADOOP_HOME}" ];then
#  echo "HADOOP_HOME not found in your environment"
#  exit 1
#fi
shift $(($OPTIND -1))
opreate=$1
commpnent=$2
workers=""
function start_hdfs() {
  echo --------- starting hdfs ----------
  ssh "${hdfs_hostname}" "source /etc/profile;${HADOOP_HOME}/sbin/start-dfs.sh"
}
function start_yarn() {
  echo --------- starting yarn ----------
  ssh "${yarn_hostname}" "source /etc/profile;${HADOOP_HOME}/sbin/start-yarn.sh"
}
function stop_hdfs() {
  echo --------- stoping hdfs ----------
  ssh "${hdfs_hostname}" "source /etc/profile;${HADOOP_HOME}/sbin/stop-dfs.sh"
}
function stop_yarn() {
  echo --------- stoping yarn ----------
  ssh "${yarn_hostname}" "source /etc/profile;${HADOOP_HOME}/sbin/stop-yarn.sh"
}
function get_workers() {
    workers=$(ssh $hdfs_hostname source /etc/profile;cat ${HADOOP_HOME}/etc/hadoop/workers | grep -v "^#" | awk '{print $1}')
}
function status_jps() {
  get_workers
  for i in $workers
  do
      echo --------- "${i}" ----------
      ssh "${i}" "source /etc/profile;jps | grep -e NameNode -e JournalNode -e DFSZKFailoverController -e DataNode -e ResourceManager -e NodeManager"
  done
}
function start_hadoop() {
    case "$commpnent" in
      hdfs)
        start_hdfs
        ;;
      yarn)
        start_yarn
        ;;
      "")
        start_hdfs
        start_yarn
        ;;
    esac
}
function stop_hadoop() {
    case "$commpnent" in
      hdfs)
        stop_hdfs
        ;;
      yarn)
        stop_yarn
        ;;
      "")
        stop_yarn
        stop_hdfs
        ;;
    esac
}
#获取当前要启动的程序 hdfs,yarn
case "$opreate" in
	start )
		start_hadoop
		;;
	stop )
		stop_hadoop
		;;
	status )
		status_jps
		;;
	restart )
		status_jps
		;;
	* )
		echo "Usage: $0 [-n {nn_hostname}] [-r {rm_hostname}] {start|stop|restart|status} [hdfs|yarn]"
		;;
esac

