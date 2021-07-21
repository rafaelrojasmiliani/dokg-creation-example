


deps_that_rosdep_cant_find(){
    # Find all the packages that
    # a package depedns on and that
    # rosdep cannot find
    local __array=$2
    local __result=""
    declare -a unresolved_packages
    for p in $(pack_deps $1); do 
        if ! $(rosdep resolve $p  >/dev/null 2>&1); then
            __result="$__result $p"
        fi
    done
    eval $__array="'$__result'"
}

pack_deps(){
    rosdep keys $1
}

get_pack_deps_not_installed_with_apt(){

    local __result=""

    for p in $(rosdep keys $1); do
        if $(rospack find $p >/dev/null 2>&1); then
            addr=$(rospack find $p 2>/dev/null)
            if [[ $addr != "/opt/ros"* ]]; then
                __result="$__result $p"
            fi
#        else
#            __result="$__result $p"
        fi
    done

    echo $__result


}

get_pack_to_produce_deb(){

    local __result=$(get_pack_deps_not_installed_with_apt)

}



main(){

    tem_rosdep_yaml="temp_rosdep.yaml"
    temp_rosdep_list="/etc/ros/rosdep/sources.list.d/99-temp.list"


    scriptdir=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
    if [ "$scriptdir" != "$(pwd)" ]; then
        echo "this script must be executed from $scriptdir".
        exit 1
    fi

    catkin build || exit 1


    source devel/setup.bash

    if [ -f "./rosdep.yaml" ]; then
        sudo bash -c "echo \"yaml file://$(realpath rosdep.yaml)\" > /etc/ros/rosdep/sources.list.d/10-my-local.list"
        rosdep update
    fi
#
#
    mapfile -t desired_packages < ./desired_packages.txt
    req_pack=""
    for package in ${desired_packages[@]}; do
        req_pack="$req_pack $package"
        req_pack="$req_pack $(get_pack_deps_not_installed_with_apt $package)"
    done
    req_pack=$(echo "$req_pack" | xargs -n1 | sort -u | xargs)

    rm $tem_rosdep_yaml 2>/dev/null
    echo --- > $tem_rosdep_yaml 
    for p in $req_pack; do
        envsubst <<EOF >> $tem_rosdep_yaml
$p:
    ubuntu:
        apt: [$(echo $p | sed 's/_/-/g' | sed 's/\(.*\)/ros-'$(lsb_release -cs)'-\1/' )]
EOF
    done

    sudo bash -c "echo \"yaml file://$(realpath $tem_rosdep_yaml)\" > $temp_rosdep_list"
    rosdep update
    

    


    for p in $req_pack; do
        roscd $p
        bloom-generate rosdebian --os-name ubuntu --os-version $(lsb_release -cs) --ros-distro $ROS_DISTRO
        fakeroot debian/rules "binary --parallel"
    done

    return 0;
}

main
