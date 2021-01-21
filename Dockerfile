FROM ubuntu:20.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -yq dist-upgrade \
 && apt-get -o Acquire::ForceIPv4=true install -yq --no-install-recommends \
	locales cmake git build-essential \
    # python-pip \
	python3-pip python3-setuptools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools \
 && python3 -m pip install jupyterlab==0.35.4 bash_kernel==0.7.1 tornado \
 && python3 -m bash_kernel.install

ENV SHELL=/bin/bash \
	NB_USER=jovyan \
	NB_UID=1000 \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8

ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

###################################### ROS #####################################

# install packages
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install --no-install-recommends -y \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init \
    && rosdep update

# install ros packages
ENV ROS_DISTRO noetic
RUN apt-get -o Acquire::ForceIPv4=true update && apt-get -o Acquire::ForceIPv4=true install -y \
    ros-${ROS_DISTRO}-ros-base \
		ros-${ROS_DISTRO}-tf \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install pyyaml rospkg jupyros

# setup entrypoint
COPY ./ros_entrypoint.sh /
RUN chmod a+x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]

RUN mkdir -p /home/jovyan/.ros
RUN chown jovyan.jovyan /home/jovyan/.ros

##################################### COPY #####################################

RUN mkdir ${HOME}/ros-jupyter

# COPY --chown=1000:1000 . ${HOME}/ros-jupyter

##################################### TAIL #####################################

RUN chown ${NB_UID} ${HOME}/ros-jupyter
 
USER ${NB_USER}

WORKDIR ${HOME}/ros-jupyter
