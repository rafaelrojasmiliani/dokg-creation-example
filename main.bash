
main(){

    scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
    if [ "$scriptdir" != "$(pwd)" ]; then
        echo "this script must be executed from $scriptdir".
        exit 1
    fi

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
