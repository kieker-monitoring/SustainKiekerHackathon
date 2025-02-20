FROM quay.io/jupyter/minimal-notebook

USER root

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt update && \
    apt install -y openjdk-21-jdk maven plotutils graphviz ghostscript && \
    git clone https://github.com/kieker-monitoring/SustainKiekerHackathon.git && \
    git clone https://github.com/toruseo/UXsim.git && \
    cd SustainKiekerHackathon/collector && \
    mvn clean package -DskipTests=true

RUN mkdir ~/kieker-logs

RUN sed -i 's@/tmp@'"${PWD}"'/kieker-logs@g' ~/SustainKiekerHackathon/res/config.txt

