# On-Board Computer (Jetson Nano)

FROM ros:humble-ros-base AS obc

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    ros-humble-ros2-control \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*


# Desktop

FROM osrf/ros:humble-desktop AS dsktp 

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    ros-humble-rplidar-ros \
    ros-humble-ros-gz \
    ros-humble-xacro \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# Set up sudo
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

# Set up entrypoint
COPY entrypoint.sh /entrypoint.sh
COPY config/bashrc /home/$USERNAME/.bashrc
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

USER dev
