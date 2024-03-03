#! /bin/bash
hosts=(node01 node02 node03)
mill=`date "+%N"`
tdate=`date "+%Y-%m-%d %H:%M:%S,${mill:0:3}"`
source /etc/profile
KAFKA_HOME=${KAFKA_HOME}
function init(){
if [ ${KAFKA_HOME} == "" ];then
	echo "KAFKA_HOME 不能为空，需配置环境变量 KAFKA_HOME"
	exit 1;
fi
}
case $1 in
"start"){
    for i in ${hosts[*]}
    do
        smill=`date "+%N"`
		stdate=`date "+%Y-%m-%d %H:%M:%S,${smill:0:3}"`
		echo "[$stdate] INFO [Kafka Broker $i] begins to execute the startup o
peration."
        ssh $i "${KAFKA_HOME}/bin/kafka-server-start.sh -daemon ${KAFKA_HOME}/config/s
erver.properties"
    done
};;
"stop"){
    for i in ${hosts[*]}
    do
        smill=`date "+%N"`
        stdate=`date "+%Y-%m-%d %H:%M:%S,${smill:0:3}"`
        echo "[$stdate] INFO [Kafka Broker $i] begins to execute the shutdown operatio
n."
        ssh $i "${KAFKA_HOME}/bin/kafka-server-stop.sh "
    done
};;
"status"){
    for i in ${hosts[*]}
		do
			smill=`date "+%N"`
			stdate=`date "+%Y-%m-%d %H:%M:%S,${smill:0:3}"`
			ssh $i "echo [$stdate] INFO [Kafka Broker $i] status message i
s :;jps | grep Kafka;" &
			sleep 1
		done
};;
esac
