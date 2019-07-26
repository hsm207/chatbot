FROM continuumio/miniconda3:4.6.14

RUN conda install -y -c conda-forge jupyter_contrib_nbextensions \
    && jupyter nbextension enable toc2/main

RUN apt-get update \
    && apt-get -y install build-essential \
                          openssh-server

# set up openssh server
# from https://docs.docker.com/engine/examples/running_ssh_service/
RUN mkdir /var/run/sshd
# note the root password you set!
RUN echo 'root:abc123' | chpasswd

# from https://stackoverflow.com/questions/42653676/how-to-configure-debian-sshd-for-remote-debugging-in-a-docker-container
# and https://unix.stackexchange.com/questions/79449/cant-ssh-into-remote-host-with-root-password-incorrect
# note: miniconda uses debian as the OS
RUN sed -i 's/#PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# install rasa
RUN pip install rasa-x==0.19.6.dev233+g0e36884 --extra-index-url https://pypi.rasa.com/simple

VOLUME ["/app"]
WORKDIR /app

# expose port for rasa server
EXPOSE 5005

# expose port for rasa X server
EXPOSE 5002

# expose port for jupyter notebook
EXPOSE 8888
# expose port for ssh
EXPOSE 22

#CMD jupyter notebook --ip 0.0.0.0 --allow-root --port 8888 --no-browser
CMD ["/usr/sbin/sshd", "-D"]