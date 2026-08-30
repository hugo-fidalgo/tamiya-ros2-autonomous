import os

from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():

    # RPLidar C1 Node
    rplidar_node = Node(
        package='rplidar_ros',
        executable='rplidar_composition',
        name='rplidar_node',
        output='screen',
        parameters=[{
            'serial_port': '/dev/rplidar',
            'serial_baudrate': 460800,
            'frame_id': 'laser_frame',
            'inverted': False,
            'angle_compensate': True,
            'scan_mode': 'Standard'
        }]
    )

    # Arduino MCU Bridge Node
    mcu_bridge_node = Node(
        package='rover_mcu_bridge',
        executable='mcu_bridge_node',
        name='mcu_bridge',
        output='screen'
    )

    return LaunchDescription([
        rplidar_node,
        mcu_bridge_node
    ])
