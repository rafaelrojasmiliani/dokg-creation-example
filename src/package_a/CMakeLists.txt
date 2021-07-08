cmake_minimum_required(VERSION 3.0.2)
project(package_a)


find_package(catkin REQUIRED COMPONENTS
  roscpp
  rospy
)

find_package(Eigen3 REQUIRED)


catkin_package()


include_directories(
  ${catkin_INCLUDE_DIRS}
  ${Eigen3_INCLUDE_DIRS}
)
















