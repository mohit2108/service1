FROM python:3

RUN apt-get update && apt-get install -y \
    software-properties-common
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip

# Add All Files to /app folder
ADD . /app

# Change working directory to folder we created
WORKDIR /app

# Automated install of remaining requirements
RUN pip install -r requirements.txt

ENV FLASK_APP /app/service1.py
EXPOSE 5000

# Following statements are Splunk specific and can be used for monitoring
RUN mkdir -p /opt/splunk

RUN chown -R 1001:1001 /opt/splunk/

WORKDIR /opt/splunk
# Download and unzip Splunk Universal Forwarder
RUN curl -o splunkforwarder.tgz https://repo1.uhc.com/artifactory/generic-local/monitoring/splunk/latest/splunkforwarder.tgz
RUN tar xvzf splunkforwarder.tgz

# Download and unzip Splunk Universal Forwarder outputs app
WORKDIR /opt/splunk/splunkforwarder/etc/apps
RUN curl -o optum_phi_ose_outputs.tgz   https://repo1.uhc.com/artifactory/generic-local/monitoring/splunk/latest/optum_phi_ose_outputs.tgz
RUN tar xvzf optum_phi_ose_outputs.tgz

# COPY inputs.conf into the image
COPY /config/inputs.conf /opt/splunk/splunkforwarder/etc/system/local/


#RUN  jar xf /com/optum/app.jar /com/optum/BOOT-INF/classes/inputs.conf
RUN chmod -R 777 /opt/splunk
COPY /target/classes/run.sh /opt/splunk/
RUN chmod -R 777 /opt/splunk/run.sh
RUN cp /opt/splunk/splunkforwarder/etc/splunk-launch.conf.default /opt/splunk/splunkforwarder/etc/splunk-launch.conf

ENV SPLUNK_HOME "/opt/splunk/splunkforwarder"

RUN mkdir /app

RUN chmod 0777 /app

# Dynatrace - Can be used for monitoring

ARG DT_PAAS_URL="https://dtsaas-test.uhc.com/e/378296cc-b9ec-458c-ab10-cdeb14288958/api"
ARG DT_PAAS_TOKEN="dt0c01.RE4N3Q4JDZHIO7IW7DLA6KMM"
   ARG DT_ONEAGENT_OPTIONS="flavor=default&include=java"
ENV DT_HOME="/opt/dynatrace/oneagent"
USER root
RUN echo "$DT_PAAS_URL/v1/deployment/installer/agent/unix/paas/latest?Api-Token=$DT_PAAS_TOKEN&$DT_ONEAGENT_OPTIONS"
RUN mkdir -p "$DT_HOME" && \
           curl -k -o "$DT_HOME/oneagent.zip" "$DT_PAAS_URL/v1/deployment/installer/agent/unix/paas/latest?Api-Token=$DT_PAAS_TOKEN&$DT_ONEAGENT_OPTIONS" && \
           unzip -d "$DT_HOME" "$DT_HOME/oneagent.zip" && \
           rm "$DT_HOME/oneagent.zip"

ENV LD_PRELOAD="/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so"

WORKDIR /app

RUN chmod -R 777 /opt/splunk

ENTRYPOINT [ "/opt/splunk/run.sh" ]

CMD flask run --host=0.0.0.0
