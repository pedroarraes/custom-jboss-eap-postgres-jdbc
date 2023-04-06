# How to customize  Red Hat JBoss EAP image to install Postgresql JDBC Drivers
This smart-start describes how create a a custom JBoss EAP image and install Postgresql JDBC drivers. For this tutorial we used a Red Hat Container Image, you need a Runtimes Subscription to execute, but, as a alternative you can use a Wildfly Community Image, not supported to Red Hat.

## Requeriments
* Red Hat Subscription
* podman
* VSCode or any text editor

## Summary
* [Authentication on Red Hat Registry Image](#authentication-on-red-hat-registry-image)
* [Building custom image image](#building-custom-image-image)
* [Undertanding Containerfile](#undertanding-containerfile)


## Authentication on Red Hat Registry Image
To pull Red Hat JBoss EAP image is necessary be authenticated. To login at registry use podman.
```bash
$ podman login -u <your-user> registry.redhat.io
```
```console
Password: 
Login Succeeded!
```

## Building custom image image
To build custom image use podman
```bash
$ cd custom-jboss-eap-postgres-jdbc/
$ podman build . -t jboss74-postgresql-jdbc:v1
```
```console
STEP 1/3: FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3
Trying to pull registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3...
Getting image source signatures
Checking if image destination supports signatures
Copying blob 4015a8249bc6 done  
Copying blob c4877503c8d2 done  
Copying config be2dbd5abd done  
Writing manifest to image destination
Storing signatures
STEP 2/3: ENV PGVERSION=42.6.0
--> 5d9923d8643
STEP 3/3: RUN /bin/sh -c 'nohup $JBOSS_HOME/bin/standalone.sh -c standalone-openshift.xml -b 0.0.0.0  > /dev/null &' &&     sleep 10 &&     cd /tmp &&     curl --location --output postgresql-${PGVERSION}.jar --url https://jdbc.postgresql.org/download/postgresql-${PGVERSION}.jar &&     $JBOSS_HOME/bin/jboss-cli.sh --connect --command="module add --name=org.postgresql --resources=postgresql-${PGVERSION}.jar --dependencies=javax.api,javax.transaction.api" &&     $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=postgresql:add(driver-name="postgresql",driver-module-name="org.postgresql",driver-class-name=org.postgresql.Driver)" &&     $JBOSS_HOME/bin/jboss-cli.sh --connect --command="/subsystem=datasources/jdbc-driver=postgresqlXA:add(driver-name="postgresqlXA",driver-module-name="org.postgresql",driver-xa-datasource-class-name=org.postgresql.xa.PGXADataSource)" &&     rm postgresql-${PGVERSION}.jar
Formatter ##CONSOLE-FORMATTER## is not defined
WARNING: An illegal reflective access operation has occurred
WARNING: Illegal reflective access by org.wildfly.extension.elytron.SSLDefinitions (jar:file:/opt/jboss/container/wildfly/s2i/galleon/galleon-m2-repository/org/wildfly/core/wildfly-elytron-integration/15.0.25.Final-redhat-00001/wildfly-elytron-integration-15.0.25.Final-redhat-00001.jar!/) to method com.sun.net.ssl.internal.ssl.Provider.isFIPS()
WARNING: Please consider reporting this to the maintainers of org.wildfly.extension.elytron.SSLDefinitions
WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
WARNING: All illegal access operations will be denied in a future release
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 1056k  100 1056k    0     0   719k      0  0:00:01  0:00:01 --:--:--  720k
{"outcome" => "success"}
{"outcome" => "success"}
COMMIT jboss74-postgresql-jdbc:v1
--> dff6546c124
Successfully tagged localhost/jboss74-postgresql-jdbc:v1
dff6546c124411a3870a76e3f016d8fb40a775bf2095e787b8a303bbe789e638
```
```bash
$ podman images
```
```console
REPOSITORY                                                      TAG         IMAGE ID      CREATED             SIZE
localhost/jboss74-postgresql-jdbc                               v1          dff6546c1244  About a minute ago  1.04 GB
registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8  7.4.10-3    be2dbd5abda1  2 weeks ago         1 GB
```
## Undertanding Containerfile
Below containerfile.
```dockerfile
FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:7.4.10-3 (1)
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
```
* (1) Original container image.
* (2) Starts JBoss EAP and opens manager port.
* (3) Waiting 10 seconds starts JBoss EAP.
* (4) Downloads Postgresql JDBC drivers.
* (5) Installs ojdbc as a JBoss EAP module.
* (6) Installs Postgresql JDBC driver.
* (7) Installs Postgresql JDBC XA driver.