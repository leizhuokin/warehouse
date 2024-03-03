#!/bin/bash

workDir=`dirname $0`
workDir=`cd ${workDir};pwd`

source ${workDir}/env/install_env.sh

workersGroup=(${workers//,/ })
for workerGroup in ${workersGroup[@]}
do
  echo $workerGroup;
  worker=`echo $workerGroup|awk -F':' '{print $1}'`
  workerNames+=($worker)
done

mastersHost=(${masters//,/ })
for master in ${mastersHost[@]}
do
  echo "$master master server is stopping"
	ssh -o StrictHostKeyChecking=no -p $sshPort $master  "cd $installPath/; bash bin/dolphinscheduler-daemon.sh stop master-server;"

done

for worker in ${workerNames[@]}
do
  echo "$worker worker server is stopping"
  ssh -o StrictHostKeyChecking=no -p $sshPort $worker  "cd $installPath/; bash bin/dolphinscheduler-daemon.sh stop worker-server;"
done

ssh -o StrictHostKeyChecking=no -p $sshPort $alertServer  "cd $installPath/; bash bin/dolphinscheduler-daemon.sh stop alert-server;"

apiServersHost=(${apiServers//,/ })
for apiServer in ${apiServersHost[@]}
do
  echo "$apiServer api server is stopping"
  ssh -o StrictHostKeyChecking=no -p $sshPort $apiServer  "cd $installPath/; bash bin/dolphinscheduler-daemon.sh stop api-server;"
done
