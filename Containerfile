FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3
ENV PGVERSION=42.6.0
RUN /bin/sh -c 'nohup $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -b 0.0.0.0  > /dev/null &' && \
    sleep 10 && \
    cd /tmp && \
    curl --location --output postgresql-${PGVERSION}.jar --url https://jdbc.postgresql.org/download/postgresql-${PGVERSION}.jar && \
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="module add --name=org.postgresql --resources=postgresql-${PGVERSION}.jar --dependencies=javax.api,javax.transaction.api" && \
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=postgresql:add(driver-name="postgresql",driver-module-name="org.postgresql",driver-class-name=org.postgresql.Driver)" && \
    $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=postgresqlXA:add(driver-name="postgresqlXA",driver-module-name="org.postgresql",driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)" && \
    rm postgresql-${PGVERSION}.jar