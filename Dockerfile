FROM ubuntu:22.04

# For installation prompts
ENV DEBIAN_FRONTEND noninteractive 

RUN locale  # check for UTF-8 \
    apt update && apt install locales \
    locale-gen en_US en_US.UTF-8 \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    export LANG=en_US.UTF-8 \
    locale  # verify settings

# ROS2 Stuff
RUN apt update && apt install -y software-properties-common curl
RUN add-apt-repository -y universe
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" > /etc/apt/sources.list.d/ros2.list
RUN apt update && apt upgrade -y && apt install -y ros-dev-tools ros-iron-desktop ros-iron-ros-base

# Development user
RUN apt update && apt-get install -y sudo
RUN adduser --disabled-password --gecos '' dev
RUN adduser dev sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER dev
WORKDIR /home/dev

# VSCode
RUN sudo apt update && sudo apt install -y wget gpg apt-transport-https
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
RUN rm -f packages.microsoft.gpg
RUN sudo apt-get update && sudo apt install -y code

# Entrypoint and CMD
COPY ./ros_entrypoint.sh .
RUN sudo chmod +x ros_entrypoint.sh
RUN echo "source ~/ros_entrypoint.sh" >> .bashrc
ENTRYPOINT ["/home/dev/ros_entrypoint.sh"]
CMD ["bash"]