#!/bin/sh
hdfs namenode -format
service ssh start && ssh-keyscan -H 0.0.0.0 >> /root/.ssh/known_hosts && ssh-keyscan -H localhost >> /root/.ssh/known_hosts && $HADOOP_INSTALL/sbin/start-dfs.sh
service ssh start && ssh-keyscan -H 0.0.0.0 >> /root/.ssh/known_hosts && ssh-keyscan -H localhost >> /root/.ssh/known_hosts && $HADOOP_INSTALL/sbin/start-yarn.sh

bash
