#! /bin/bash
#hosts=(node01 node02 node03)
kafka_hosts=$(cat /etc/hosts | grep -v "^#" | awk '{print $2}')
#允许通过命令行传递zk所在节点列表
while getopts "h:" opt
  do
    case $opt in
       h){
          kafka_hosts=$(echo $OPTARG | tr ',' ' ')
         };;
    esac
  done
shift $(($OPTIND -1))
#环境检测
for i in $kafka_hosts
  do
    ssh "${i}" 'source /etc/profile
    KAFKA_HOME=${KAFKA_HOME}
    if [ -z "${KAFKA_HOME}" ];then
      echo "$(hostname) KAFKA_HOME not found in your environment"
      exit 1
    fi'
  done
function status_kafka() {
    for i in $kafka_hosts
    do
        echo --------- status  Kafka on "${i}" ----------
        ssh $i "echo INFO [Kafka Broker $i] status message is :;jps | grep Kafka;" &
        sleep 1
    done
}
function start_kafka() {
    for i in $kafka_hosts
    do
        echo --------- starting  Kafka on "${i}" ----------
        ssh $i 'source /etc/profile;${KAFKA_HOME}/bin/kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties'
    done
}
function stop_kafka() {
    for i in ${kafka_hosts[*]}
    do
        echo --------- stoping  Kafka on "${i}" ----------
        ssh $i 'source /etc/profile;${KAFKA_HOME}/bin/kafka-server-stop.sh'
    done
}
case $1 in
"start"){
    start_kafka
    };;
"stop"){
    stop_kafka
    };;
"status"){
        status_kafka
    };;
    * )
        echo "Usage: $0 [-h {hostname1,hostname2}] {start|stop|status}"
    ;;
esac
