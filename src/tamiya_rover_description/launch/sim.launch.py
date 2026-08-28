# Modified version of Josh Newans, from Articulated Robotics, Simulation Launch script

import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource

from launch_ros.actions import Node


def generate_launch_description():


    # Include the robot_state_publisher launch file, provided by our own package.
    # Force sim time to be enabled

    package_name='tamiya_rover_description'

    rsp = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([os.path.join(get_package_share_directory(package_name), 'launch', 'rsp.launch.py')]),
        launch_arguments={'use_sim_time': 'true'}.items()
    )

    # Include the Gazebo launch file, provided by the ros_gz_sim package

    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([os.path.join(get_package_share_directory('ros_gz_sim'), 'launch', 'gz_sim.launch.py')]),
        launch_arguments={'gz_args' : 'empty.sdf -r'}.items()
    )

    # Run the spawner node form the ros_gz_sim package.

    spawn_entity = Node(
        package='ros_gz_sim',
        executable='create',
        arguments=['-topic', 'robot_description',
                   '-name', 'tamiya-tt02',
                   '-z', '0.1'],
        output='screen')


    # Launch
    return LaunchDescription([
        rsp,
        gazebo,
        spawn_entity,
    ])
