


deps_that_rosdep_cant_find(){
    local __array=$2
    local __result=""
    declare -a unresolved_packages
    for p in $(rosdep keys $1); do 
        if ! $(rosdep resolve $p  >/dev/null 2>&1); then
            __result="$__result $p"
        fi
    done
    eval $__array="'$__result'"
}

main(){

    scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
    if [ "$scriptdir" != "$(pwd)" ]; then
        echo "this script must be executed from $scriptdir".
        exit 1
    fi

    #catkin build || exit 1


    #source devel/setup.bash

#    if [ -f "./rosdep.yaml" ]; then
#        sudo bash -c "echo \"yaml file://$(realpath rosdep.yaml)\" > /etc/ros/rosdep/sources.list.d/10-my-local.list"
#        rosdep update
#    fi
#
#
    mapfile -t desired_packages < ./desired_packages.txt
    req_pack=""
    for package in ${desired_packages[@]}; do
        deps_that_rosdep_cant_find $package result
        req_pack="$req_pack $result"
    done
    req_pack=$(echo "$req_pack" | xargs -n1 | sort -u | xargs)
    
    for pin in ${req_pack}; do
        echo $pin
    done
#
#    echo ${desired_packages[@]}
#
#
#
#
#    for ros_package in ${desired_packages[@]}; do
#        roscd $ros_package
#        #bloom-generate rosdebian --os-name ubuntu --os-version $(lsb_release -cs) --ros-distro $ROS_DISTRO
#        echo ------ $(echo $(pwd)) -----
#    done

    return 0;
}

main
