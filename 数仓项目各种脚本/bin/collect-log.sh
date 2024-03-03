#!/bin/bash
source /etc/profile
log_hosts=(node01 node02)
JOB_CONF_HOME=${JOB_HOME}/conf
JOB_LOG_HOME=${JOB_HOME}/logs
FLUME_HOME=${FLUME_HOME}
case $1 in
"start"){
	for i in ${log_hosts[*]}
	do
		echo "--------------启动 ${i} 用户行为日志采集器Flume----------------"
		ssh $i "nohup ${FLUME_HOME}/bin/flume-ng agent --conf conf --conf-file ${JOB_CONF_HOME}/flume/file_to_kafka_mock_log.conf --name a1 > ${JOB_LOG_HOME}/collect-mock-log-${i}.log 2>&1 &"
        done
};;
"stop"){
	for i in ${log_hosts[*]}
	do
		echo "--------------停止 ${i} 用户行为日志采集器Flume----------------"
		ssh $i "ps -ef | grep file_to_kafka_mock_log.conf | grep -v grep | awk '{print \$2}' | xargs -n1 kill -9"
	done
};;
"status"){
        for i in ${log_hosts[*]}
        do
                ssh $i "ps -ef | grep file_to_kafka_mock_log.conf | grep -v grep | awk '{print \$2}' | xargs -n1 echo"
        done
};;
* ){
 echo "Useage: collect-log.sh (start|stop|status)"
};;
esac

