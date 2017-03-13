FROM ubuntu:latest

USER root

#install linux utilities
RUN apt-get update; apt-get install -y wget; apt-get install -y ssh; apt-get install -y openssh-server; apt-get install -y openssh-client rsync

#configure ssh
#RUN cat /dev/zero | ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
#RUN cat /dev/zero | ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

#install Java
RUN apt-get install -y openjdk-8-jdk

#install hadoop
RUN wget http://mirrors.sonic.net/apache/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
RUN tar -xzvf hadoop-2.7.3.tar.gz
RUN mv hadoop-2.7.3 /usr/local/hadoop

#configure hadoop
ENV JAVA_HOME readlink -f /usr/bin/java | sed "s:bin/java::"
ENV HADOOP_INSTALL=/usr/local/hadoop
ENV PATH $PATH:$HADOOP_INSTALL/bin
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV HADOOP YARN_HOME $HADOOP INSTALL

RUN sed -i 's/export JAVA_HOME=\${JAVA_HOME}/export JAVA_HOME=\$(readlink -f \/usr\/bin\/java \| sed "s:bin\/java::")/g' /usr/local/hadoop/etc/hadoop/hadoop-env.sh

RUN mkdir -p /home/hadoop/mydata/hdfs/namenode
RUN mkdir -p /home/hadoop/mydata/hdfs/datenode

RUN sed -i 's/<\/configuration>/<property>\n<name>fs.default.name<\/name>\n<value>hdfs:\/\/localhost:9000<\/value>\n<\/property>\n<\/configuration>/g' /usr/local/hadoop/etc/hadoop/core-site.xml
RUN sed -i 's/<\/configuration>/<property>\n<name>yarn.nodemanager.aux-services<\/name>\n<value>mapreduce_shuffle<\/value>\n<\/property>\n<property>\n<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class<\/name>\n<value>org.apache.hadoop.mapred.ShuffleHandler<\/value>\n<\/property>\n<\/configuration>/g' /usr/local/hadoop/etc/hadoop/yarn-site.xml

RUN cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
RUN sed -i 's/<\/configuration>/<property>\n<name>mapreduce.framework.name<\/name>\n<value>yarn<\/value>\n<\/property>\n<\/configuration>/g' /usr/local/hadoop/etc/hadoop/mapred-site.xml

RUN sed -i 's/<\/configuration>/<property>\n<name>dfs.replication<\/name>\n<value>1<\/value>\n<\/property>\n<property>\n<name>dfs.namenode.name.dir<\/name>\n<value>file:\/home\/hadoop\/mydata\/hdfs\/namenode<\/value>\n<\/property>\n<property>\n<name>dfs.datanode.data.dir<\/name>\n<value>file:\/home\/hadoop\/mydata\/hdfs\/datanode<\/value>\n<\/property>\n<\/configuration>/g' /usr/local/hadoop/etc/hadoop/hdfs-site.xml

#install R
RUN echo 'deb http://archive.linux.duke.edu/cran/bin/linux/ubuntu xenial/' >> /etc/apt/sources.list
RUN apt-get install -y r-base

RUN apt-get install -y gdebi-core
RUN wget https://download2.rstudio.org/rstudio-server-1.0.136-amd64.deb
RUN gdebi -nq rstudio-server-1.0.136-amd64.deb

ADD start.sh /etc/start.sh

EXPOSE 8787

CMD ["/etc/start.sh"]
