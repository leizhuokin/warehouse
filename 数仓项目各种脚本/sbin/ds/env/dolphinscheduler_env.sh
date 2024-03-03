#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# JAVA_HOME, will use it to start DolphinScheduler server
export JAVA_HOME="/opt/apps/jdk"

# Database related configuration, set database type, username and password
export DATABASE="mysql"
export SPRING_PROFILES_ACTIVE=${DATABASE}
export SPRING_DATASOURCE_URL="jdbc:mysql://node02:3306/dolphinscheduler?useSSL=false&useUnicode=true&characterEncoding=UTF-8"
export SPRING_DATASOURCE_USERNAME=root
export SPRING_DATASOURCE_PASSWORD=123456

# DolphinScheduler server related configuration
export SPRING_CACHE_TYPE=${SPRING_CACHE_TYPE:-none}
export SPRING_JACKSON_TIME_ZONE="Asia/Shanghai"
export MASTER_FETCH_COMMAND_NUM=${MASTER_FETCH_COMMAND_NUM:-10}

# Registry center configuration, determines the type and link of the registry center
export REGISTRY_TYPE=${REGISTRY_TYPE:-zookeeper}
export REGISTRY_ZOOKEEPER_CONNECT_STRING="node01:2181,node02:2181,node03:2181"

# Tasks related configurations, need to change the configuration if you use the related tasks.
export HADOOP_HOME=/opt/apps/hadoop
export HADOOP_CONF_DIR=/opt/apps/hadoop/etc/hadoop
export SPARK_HOME=/opt/apps/spark
#export SPARK_HOME2=${SPARK_HOME2:-/opt/soft/spark2}
#export PYTHON_HOME=${PYTHON_HOME:-/opt/soft/python}
export HIVE_HOME=/opt/apps/hive
#export FLINK_HOME=${FLINK_HOME:-/opt/soft/flink}
export DATAX_HOME=/opt/apps/datax
#export SEATUNNEL_HOME=${SEATUNNEL_HOME:-/opt/soft/seatunnel}
#export CHUNJUN_HOME=${CHUNJUN_HOME:-/opt/soft/chunjun}

export PATH=$HADOOP_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin:$HIVE_HOME/bin:$DATAX_HOME/bin:$PATH
