
In this quick tutorial I want to show you how to generate a deb package from
scratch that will install a binary executable in the target system.

To do this with a ROS package see [here](https://gist.github.com/awesomebytes/196eab972a94dd8fcdd69adfe3bd1152) and [here](https://bloom.readthedocs.io/en/0.5.10/) and [here](https://github.com/carlosmccosta/ros_development_tools/blob/master/catkin/create_deb_files_for_ros_packages.md)

# Introduction

A `.deb` file is an `ar` archive that contains data. 

Internally, a deb package contains a collection of folders that mimics a
typical Linux file system, such as /usr, /usr/bin, /opt and so on. A file put
in one of those directories will be copied to the same location in the actual
file system during installation.


# Anatomy of a deb package

The most important one is the control file, which stores the
information about the deb package and the program it installs.

## Control File 

On the outside instead, all deb package files follow a specific naming
convention:
```
<name>_<version>-<revision>_<architecture>.deb
```
For example, suppose you want to release your program called hello, version
1.0, built for 64-bit ARM processors. Your deb file name would look something
like 

```
hello_1.0-1_arm64.deb
```

## Making the deb package

We are now ready to generate the package. Make sure you have the dpkg-deb
program installed in your system: this will be used later on to generate the
final archive.

1. Create the working directory:
2. Create the internal folder structure with a `DEBIAN` in the workin directory.
3. Then copy the desired binaries to the corresponding places in the working directory folder structure.
3. Create the control file


And then create the empty control file:

touch helloworld_1.0-1_arm64/DEBIAN/control

4. Fill in the control file

Open the file previously created with your text editor of
choice. The control file is just a list of data fields. For
binary packages there is a minimum set of mandatory ones:

| Mandatory Field | Meaning |
| --------------- | ------- |
| `Package`       | the name of your program|
| `Version` | the versionof your program |
| `Architecture` |  the target architecture |
| `Maintainer` | the name and the email address of the person in charge of the package maintenance | 
| `Description` |  a brief description of the program |

The control file may contain additional useful fields such as the section it
belongs to or the dependency list.

Example fo the pacage `ros-indigo-evarobot-state-publisher`

```
Package: ros-indigo-evarobot-state-publisher
Version: 0.0.6-1trusty-20190604-194528-0800
Architecture: i386
Maintainer: Mehmet Akcakoca <akcakocamehmet@gmail.com>
Installed-Size: 145
Depends: libboost-system1.54.0, libc6 (>= 2.1.3), libgcc1 (>= 1:4.1.1), libstdc++6 (>= 4.1.1), ros-indigo-evarobot-description, ros-indigo-joint-state-publisher, ros-indigo-nav-msgs, ros-indigo-robot-state-publisher, ros-indigo-roscpp, ros-indigo-rospy, ros-indigo-tf
Section: misc
Priority: extra
Homepage: http://ros.org/wiki/evarobot_state_publisher
Description: evarobot_state_publisher provides tf information of Evarobot links.
```

5. Build the deb package

This is done with `dpkg-deb`

```
dpkg-deb --build --root-owner-group <package-dir>
```

**Remark** The flag `--root-owner-group` is **necessary**. I will make package
content owned by the root user and root group. Without such flag, all files and
folders would be owned by your user, which might not exist in the system the
deb package would be installed to.


Taking care of external dependencies

You can automatically generate dependencies for a binary wile using `dpkg-shlibdeps`. 
This co will look for symbols in the binary file and find its dependencies.

```
dpkg-shlibdeps -O path/to/binary/file
```

The `-O` flag will print dependencies on the standard output.

Four files: postinst, preinst, postrm, and prerm are called maintainer scripts.
Such files live inside the DEBIAN directory and, as their names suggest,
preinst and postinst are run before and after installation, while prerm and
postrm are run before and after removal. They must be marked as executables.
Also, remember to set permissions: must be between 0555 and 0775



## `rosdep` `YAML` format


See [here](http://docs.ros.org/en/independent/api/rosdep/html/rosdep_yaml_format.html#rosdep-yaml).


```
ROSDEP_NAME:
    OS_NAME1:
        OS_VERSION1:
            PACKAGE_MANAGER1:
                PACKAGE_ARGUMENTS_A
```



- `ROSDEP_NAME` is the name referred to by manifest files. Examples: `log4cxx` or `gtest`.

- `OS_NAME` is the name of an OS. Examples: ubuntu, osx, fedora, debian, openembedded, or windows.

- `OS_VERSION` (optional) is the name of specific versions in the OS. Examples: lucid or squeeze. If no OS_VERSION is specified, the rule is assumed to apply to all versions.

- `PACKAGE_MANAGER`  is a key to select which package manager to use for this `rosdep`. Examples: apt, pip.

- `PACKAGE_ARGUMEN` is free-form YAML that is be passed to the handler for the specified `PACKAGE_MANAGE`.


Example
```
my_ros_pacakge:
    ubuntu:
        lucid:
            apt:
                packages: [libgsl, vim]
```

- `rosdep resolve [pacakge_name]` 
- `rosdep keys <stacks-and-packages>` list the rosdep keys that the packages depend on
