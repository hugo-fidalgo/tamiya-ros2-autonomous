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

    fuel_world_uri = "https://fuel.gazebosim.org/1.0/openrobotics/worlds/industrial-warehouse"

    rsp = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([os.path.join(get_package_share_directory(package_name), 'launch', 'rsp.launch.py')]),
        launch_arguments={'use_sim_time': 'true'}.items()
    )

    # Include the Gazebo launch file, provided by the ros_gz_sim package

    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([os.path.join(get_package_share_directory('ros_gz_sim'), 'launch', 'gz_sim.launch.py')]),
        launch_arguments={'gz_args' : f'-r {fuel_world_uri}'}.items()
    )

    # Run the spawner node from the ros_gz_sim package.

    spawn_entity = Node(
        package='ros_gz_sim',
        executable='create',
        arguments=['-topic', 'robot_description',
                   '-name', 'tamiya-tt02',
                   '-z', '0.1'],
        output='screen')

    # Run the bridge node so that gazebo can publish and subscribe to the necessary topics

    bridge_node = Node(
        package='ros_gz_bridge',
        executable='parameter_bridge',
        arguments=[
            '/cmd_vel@geometry_msgs/msg/Twist]gz.msgs.Twist',
            '/tf@tf2_msgs/msg/TFMessage[gz.msgs.Pose_V',
            '/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock',
            '/joint_states@sensor_msgs/msg/JointState[gz.msgs.Model',
            '/scan@sensor_msgs/msg/LaserScan[gz.msgs.LaserScan'
        ],
        output='screen'
    )

    rviz_config_file = os.path.join(
        get_package_share_directory(package_name),
        'rviz',
        'sim_view.rviz'
    )

    rviz_node = Node(
        package='rviz2',
        executable='rviz2',
        name='rviz2',
        arguments=['-d', rviz_config_file],
        output='screen'
    )


    # Launch
    return LaunchDescription([
        rsp,
        gazebo,
        spawn_entity,
        bridge_node,
        rviz_node,
    ])
