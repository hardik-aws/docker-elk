FROM amazonlinux:latest
MAINTAINER Hardik Shah <mailtohardiks@gmail.com>

##JAVA & Runtime
RUN yum update && \
	yum install -y java-1.8.0 && \
	yum install -y libcgroup.x86_64 curl which nc && \
	/usr/bin/pip-2.6 install supervisor
RUN python-pip install --upgrade --user awscli
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.121-0.b13.29.amzn1.x86_64
ENV PATH $JAVA_HOME/jre/bin:$PATH
ENV JAVACMD $JAVA_HOME/jre/bin/java

RUN mkdir -p /etc/supervisor/conf.d && \
	echo_supervisord_conf > /etc/supervisor/supervisord.conf
ADD etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

##Repo
RUN rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
ADD etc/yum.repos.d/es.repo /etc/yum.repos.d/es.repo

#Configration files
ADD etc/sysctl.conf /etc/sysctl.conf

##ElsticSerarch
ENV ES_SKIP_SET_KERNEL_PARAMETERS=true
RUN yum install -y elasticsearch && \
	ln -s /etc/elasticsearch/ /usr/share/elasticsearch/config && \
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
ADD etc/elasticsearch/jvm.options /etc/elasticsearch/jvm.options

#Logstash
RUN yum install -y logstash && \
	/usr/share/logstash/bin/system-install
ADD etc/logstash/startup.options /etc/logstash/startup.options
ADD etc/logstash/jvm.option /etc/logstash/jvm.option
ADD etc/logstash/conf.d/logstash.conf /etc/logstash/conf.d/logstash.conf

#Kibana
RUN yum install -y kibana
ADD etc/kibana/kibana.yml /etc/kibana/kibana.yml

##EXPOSE require ports
EXPOSE 9200 5601 5000

##Startup scripts
ADD etc/supervisor/conf.d/elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf
ADD etc/supervisor/conf.d/kibana.conf /etc/supervisor/conf.d/kibana.conf
ADD etc/supervisor/conf.d/logstash.conf /etc/supervisor/conf.d/logstash.conf

##RUN ELK
CMD [ "supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
