# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.15

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/ubuntu/padstone-software

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/ubuntu/padstone-software/bin

# Utility rule file for freertos.

# Include the progress variables for this target.
include CMakeFiles/freertos.dir/progress.make

CMakeFiles/freertos:
	git clone --recursive https://github.com/aws/amazon-freertos /home/ubuntu/padstone-software/freertos
	cd /home/ubuntu/padstone-software/freertos/tools/cbmc/proofs && python3 ./prepare.py

freertos: CMakeFiles/freertos
freertos: CMakeFiles/freertos.dir/build.make

.PHONY : freertos

# Rule to build all files generated by this target.
CMakeFiles/freertos.dir/build: freertos

.PHONY : CMakeFiles/freertos.dir/build

CMakeFiles/freertos.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/freertos.dir/cmake_clean.cmake
.PHONY : CMakeFiles/freertos.dir/clean

CMakeFiles/freertos.dir/depend:
	cd /home/ubuntu/padstone-software/bin && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/ubuntu/padstone-software /home/ubuntu/padstone-software /home/ubuntu/padstone-software/bin /home/ubuntu/padstone-software/bin /home/ubuntu/padstone-software/bin/CMakeFiles/freertos.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/freertos.dir/depend

