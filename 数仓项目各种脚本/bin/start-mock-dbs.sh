#!/bin/bash
source /etc/profile
db_hosts=(node02)
for i in ${db_hosts[*]}; do
  echo "-------start on ${i} mock db service---------"
  ssh "$i" "source /etc/profile;start-mock-db.sh $1"
done
