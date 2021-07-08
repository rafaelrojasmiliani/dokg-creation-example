


check_deps(){
    declare -a unresolved_packages
    for package in $(rosdep keys $1); do 
        if ! rosdep resolve $p  >/dev/null 2>&1; then
            unresolved_packages+=($p)
        else
            echo rospack find $p
        fi
    done
}

main(){

    scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
    if [ "$scriptdir" != "$(pwd)" ]; then
        echo "this script must be executed from $scriptdir".
        exit 1
    fi

    catkin build || exit 1

    source devel/setup.bash

    declare -a extra_dep_array
    while read p; do
        echo "$p"
    done <./desired_packages.txt



    if [ -f "./rosdep.yaml" ]; then
        sudo bash -c "echo \"yaml file://$(realpath rosdep.yaml)\" > /etc/ros/rosdep/sources.list.d/10-my-local.list"
        rosdep update
    fi

    for ros_package_folder in $(find $(pwd) -name package.xml -printf '%h\n'); do
        cd $(realpath $ros_package_folder)
        bloom-generate rosdebian --os-name ubuntu --os-version $(lsb_release -cs) --ros-distro $ROS_DISTRO
    done

    return 0;
}

main
