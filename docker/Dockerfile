FROM quay.io/jupyter/minimal-notebook

USER root

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN apt update && \
    apt install -y openjdk-21-jdk maven plotutils graphviz ghostscript vim

USER jovyan

RUN git clone https://github.com/kieker-monitoring/SustainKiekerHackathon.git --branch main --depth 1 && \
    git clone https://github.com/toruseo/UXsim.git --branch v1.7.3 --depth 1 && \
    cd SustainKiekerHackathon/collector && \
    mvn clean package -DskipTests=true

RUN ln -s /home/jovyan/SustainKiekerHackathon/notebooks/README.ipynb /home/jovyan/README.ipynb

RUN ln -s /home/jovyan/SustainKiekerHackathon /home/jovyan/Hackathon

RUN mkdir ~/.ssh ~/kieker-logs

RUN sed -i 's@/tmp@'"${PWD}"'/kieker-logs@g' ~/SustainKiekerHackathon/res/config.txt

RUN echo 'export PYTHONPATH=/home/jovyan/SustainKiekerHackathon/python:$PYTHONPATH' >> /home/jovyan/.bashrc

RUN cd ~/SustainKiekerHackathon && unzip ./tools/trace-analysis-2.0.2.zip

RUN cd ~/SustainKiekerHackathon && git pull

RUN pip install -r ~/Hackathon/res/requirements.txt

RUN pip install build

RUN pip install --index-url https://test.pypi.org/simple/ --no-deps kieker-for-jupyter