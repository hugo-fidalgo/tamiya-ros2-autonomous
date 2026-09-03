<div align="center">
  
  # [Project Logo]
  **A 1:10 scale ROS 2 Teleoperated Perception Ground Vehicle**
  
  [![ROS @ Humble](https://img.shields.io/badge/ROS2-Humble-blue.svg)](https://docs.ros.org/en/humble/index.html)
  [![Ubuntu 22.04](https://img.shields.io/badge/Ubuntu-22.04-orange.svg)](https://releases.ubuntu.com/22.04/)
  [![C++](https://img.shields.io/badge/C++-14%2B-blue.svg)](https://isocpp.org/)
  
</div>

## System Overview
Polemarchus is a 1:10 scale robotics platform based on the Tamiya TT-02 chassis (A popular introductory Kit Car). The current iteration features a fully verified ROS 2 teleoperation and LiDAR Perception stack in real time over WI-FI. In this repository you will find all the files used for this initial prototype (Firmware; Hardware: Mechanical, Electronics; ROS 2 Software; Docker). 

<div align="center">
  [![Project Demonstration]()]()

  *Click the image above to view the physical system demo.*
</div>

- [System Overview](#system-overview)
- [Mechanical Architecture](#mechanical-architecture)
- [Electrical Architecture](#electrical-architecture)
- [Software Architecture](#software-architecture)
- [Quick Start & Installation](#quick-start--installation)
- [Simulation](#simulation)
- [Future Roadmap](#future-roadmap)

## Mechanical Architecture
The physical platform utilizes an RC racing chassis, with a 3D printed custom designed deck that holds all electronic components and wiring.

* **Chassis:** Tamiya TT-02R
* **Vetronics Deck [SolidWorks Files]:** `hardware/mechanical/solidworks`

<div align="center">
  ![Vetronics Deck](./docs/images/deck_assembly.JPG)
</div>

* **Robot Description:** Full URDF/Xacro representation for simulation purposes. `src/tamiya_rover_description/description`

## Electrical Architecture
This rover utilizes a On-Board computer, running a custom docker container, which communicates over serial with the MicroController Unit.

* **OBC:** Jetson Nano DevKit (2019)
* **MCU:** Arduino Uno R4 WIFI

Below you can find a simplified electronics diagram of the rover's EPS, OBDH and GNC subsystems. It can also be found here: `hardware/schematics/vetronics/vetronics.kicad_sch`

<div align="center">
  ![Electronics Schematic](./docs/images/vetronics_schematic.png)
</div>

There is also a bill of materials of the components used. `hardware/bom/ROS-2_Tamiya_TT-02R_[BOM].xlsx`

The Arduino Uno R4 controls the vehicle's actuators. Developed in C++ via PlatformIO.

* **Serial Ingestion:** Continuously reads and parses comma-separated strings from the Jetson Nano (OBC).

* **PWM translation:** Converts digital commands into microsecond PWM signals to control the Electronic Speec Controller (ESC) and steering servo.

* **Embedded Failsafes:** Integrates a watchdog timer to halt the car in case no commands were sent for more than 500ms.

All logic is documented inline within: `firmware/mcu_firmware/src/main.cpp`

## Software Architecture
The software stack is built entirely on ROS 2 Humble.

* **Control:** Custom ROS 2 Node that subscribes to the `/cmd_vel` topic and sends the correct PWM Signal in microseconds to the MCU. `src/rover_mcu_bridge/src/mcu_bridge_node.cpp`

* **Gazebo Simulation:** Physics simulation using Gazebo which bridges the ROS 2 topics through `ros_gz_bridge`. All programs are initialized by a automated sim.launch.py script. `src/tamiya_rover_description/launch/sim.launch.py`

* **Perception:** Native integration of the RPLIDAR C1 node publishing LaserScan data to RViz.

## Quick Start & Installation