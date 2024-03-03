#!/bin/bash

if [ $# -lt 1 ]
then
    echo "No Args Input..."
    exit ;
fi

hosts=(node01 node02 node03)
function status(){
	for i in ${hosts[*]}
	do
		echo "---------${i}---------"
		ssh $i 'source /etc/profile && ${JAVA_HOME}/bin/jps'
	done
}
case $1 in
"start")
        echo " =================== 启动 zookeeper ==================="
        ssh node01 "source /etc/profile && /opt/apps/zookeeper-3.6.3/bin/zkServer.sh start"
        ssh node02 "source /etc/profile && /opt/apps/zookeeper-3.6.3/bin/zkServer.sh start"
        ssh node03 "source /etc/profile && /opt/apps/zookeeper-3.6.3/bin/zkServer.sh start"
        echo " =================== 启动 hadoop集群 ==================="
        echo " --------------- 启动 hdfs ---------------"
        ssh node01 "source /etc/profile && /opt/apps/hadoop-3.2.2/sbin/start-dfs.sh"
        echo " --------------- 启动 yarn ---------------"
        ssh node02 "source /etc/profile && /opt/apps/hadoop-3.2.2/sbin/start-yarn.sh"
        echo " --------------- 启动 historyserver ---------------"
        ssh node01 "source /etc/profile && /opt/apps/hadoop-3.2.2/bin/mapred --daemon start historyserver"
        echo " =================== 启动 spark集群 ==================="
        ssh node01 "source /etc/profile && /opt/apps/spark-3.2.2/sbin/start-spark.sh"
        echo " =================== 启动 kafka ==================="
        ssh node01 "source /etc/profile && kafka-server-start.sh -daemon /opt/apps/kafka/config/server.properties"
        ssh node02 "source /etc/profile && kafka-server-start.sh -daemon /opt/apps/kafka/config/server.properties"
        ssh node03 "source /etc/profile && kafka-server-start.sh -daemon /opt/apps/kafka/config/server.properties"

	echo "------ 集群启动完成,节点状态如下 ------"
	status
;;
"stop")
	echo " =================== 关闭 kafka ==================="       
       	ssh node01 "source /etc/profile && kafka-server-stop.sh"       
       	ssh node02 "source /etc/profile && kafka-server-stop.sh"       
       	ssh node03 "source /etc/profile && kafka-server-stop.sh"
        echo " =================== 关闭 spark集群 ==================="
        ssh node01 "source /etc/profile && /opt/apps/spark-3.2.2/sbin/stop-spark.sh"
        echo " =================== 关闭 hadoop集群 ==================="
        echo " --------------- 关闭 historyserver ---------------"
        ssh node01 "source /etc/profile && /opt/apps/hadoop-3.2.2/bin/mapred --daemon stop historyserver"
        echo " --------------- 关闭 yarn ---------------"
        ssh node02 "source /etc/profile && /opt/apps/hadoop-3.2.2/sbin/stop-yarn.sh"
        echo " --------------- 关闭 hdfs ---------------"
        ssh node01 "source /etc/profile && /opt/apps/hadoop-3.2.2/sbin/stop-dfs.sh"
        echo " =================== 关闭 zookeeper ==================="
        ssh node01 "source /etc/profile && /opt/apps/zookeeper-3.6.3/bin/zkServer.sh stop"
        ssh node02 "source /etc/profile && /opt/apps/zookeeper-3.6.3/bin/zkServer.sh stop"
        ssh node03 "source /etc/profile && /opt/apps/zookeeper-3.6.3/bin/zkServer.sh stop"
        echo "------ 集群关闭完成,节点状态如下 ------"
	status
;;
*)
    echo "Input Args Error..."
;;
esac
