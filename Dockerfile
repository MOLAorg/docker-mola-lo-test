# Use the official ROS Humble base image
FROM ros:humble-ros-core-jammy

# Update the package list
RUN apt-get update

# Install additional ROS packages
RUN apt-get install -y \
    git \
    build-essential \
    cmake \
    python3-colcon-common-extensions \
    ros-humble-mola-common \
    python3-rosdep

# for running MOLA LO tests from mcap files:
RUN apt-get install -y \
    ros-humble-rosbag2-storage-mcap \
    ros-humble-mola-test-datasets

RUN rosdep init && rosdep update

# Set up ROS environment
SHELL ["/bin/bash", "-c"]

# Clone the ROS repository
RUN mkdir -p /ros_ws/src
WORKDIR /ros_ws/src
RUN git clone https://github.com/MOLAorg/mp2p_icp.git --recursive
RUN git clone https://github.com/MOLAorg/mola.git --recursive
RUN git clone https://github.com/MOLAorg/mola_lidar_odometry.git --recursive

# Build the packages
WORKDIR /ros_ws
RUN source /opt/ros/humble/setup.bash && rosdep install --from-paths src --ignore-src -r -y
RUN source /opt/ros/humble/setup.bash && colcon build

# Run tests
RUN source /opt/ros/humble/setup.bash && colcon test --ctest-args tests --packages-select mola_lidar_odometry

RUN source /opt/ros/humble/setup.bash && colcon test-result --all --verbose

# Clean up to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the default command to launch a shell
CMD ["bash"]
