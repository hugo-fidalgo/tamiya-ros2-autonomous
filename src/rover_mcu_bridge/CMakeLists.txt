cmake_minimum_required(VERSION 3.8)
project(rover_mcu_bridge)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(geometry_msgs REQUIRED)

# define the executable target
add_executable(mcu_bridge_node src/mcu_bridge_node.cpp)

# link the requires ROS 2 libraries to the executable
ament_target_dependencies(mcu_bridge_node rclcpp geometry_msgs)

# binary location
install(
  TARGETS mcu_bridge_node
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
