#!/bin/bash

MONGODB1=`ping -c 1 mongo | head -1  | cut -d "(" -f 2 | cut -d ")" -f 1`

echo "Waiting for startup.."
until curl http://${MONGODB1}:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
  printf '.'
  sleep 2
done

echo curl http://${MONGODB1}:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Started.."

sleep 15

echo SETUP time now: `date +"%T" `
mongo --host ${MONGODB1}:27017 <<EOF
   var cfg = {
        "_id": "rs",
        "version": 1,
        "members": [
            {
                "_id": 0,
                "host": "${MONGODB1}:27017",
                "priority": 1
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
    db.getMongo().setReadPref('nearest');
EOF

echo "rs.isMaster()" > is_master_check
is_master_result=`mongo --host ${MONGODB1} < is_master_check`

expected_result="\"ismaster\" : true"

while true;
do
  if [ "${is_master_result/$expected_result}" = "$is_master_result" ] ; then
    echo "Waiting for Mongod node to assume primary status..."
    sleep 3
    is_master_result=`mongo --host ${MONGODB1} < is_master_check`
    echo ${is_master_result}
  else
    echo "Mongod node is now primary"
    break;
  fi
done

ping 127.0.0.1 > /dev/null
