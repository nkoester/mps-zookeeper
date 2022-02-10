#
#
# author: Norman Köster
# date: 23.09.2021
# description: CMake file for mpsZooKeeper.sh
# version: 1.0
#
#
cmake_minimum_required(VERSION 3.20)
PROJECT(mps-zookeeper)
SET(CMAKE_BUILD_TYPE distribution)
SET(BIN_HOME "bin")
SET(COMPLETIONS_HOME "bashcompletions")
set(CMAKE_INSTALL_MESSAGE LAZY)

IF (NOT CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    SET(INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})
    MESSAGE("-- Use given install PREFIX: ${INSTALL_PREFIX}")
ELSEIF (DEFINED ENV{prefix})
    SET(INSTALL_PREFIX $ENV{prefix})
    MESSAGE("-- Found global install PREFIX: ${INSTALL_PREFIX}")
    MESSAGE("---- Set -DCMAKE_INSTALL_PREFIX for using a custom prefix.")
ELSE ()
    SET(INSTALL_PREFIX "/usr/local")
    MESSAGE("-- Use default prefix: ${INSTALL_PREFIX}")
    MESSAGE("---- Set -DCMAKE_INSTALL_PREFIX for using a custom prefix.")
ENDIF()

### Install to destination
FILE(GLOB SCRIPTS LIST_FILES false "${CMAKE_CURRENT_SOURCE_DIR}/src/mpsZooKeeper.sh")
INSTALL(
    FILES ${SCRIPTS}
    PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE
    DESTINATION ${INSTALL_PREFIX}/${BIN_HOME}
)

FILE(GLOB HELPERS LIST_FILES false "${CMAKE_CURRENT_SOURCE_DIR}/src/mpsZooKeeper-helper.sh")
INSTALL(
    FILES ${HELPERS}
    PERMISSIONS OWNER_READ GROUP_READ
    DESTINATION ${INSTALL_PREFIX}/${BIN_HOME}
)

### Install bash completion scrips
FILE(GLOB COMPLETIONS "${CMAKE_CURRENT_SOURCE_DIR}/src/completions-mpsZooKeeper.sh")
INSTALL(
    FILES ${COMPLETIONS}
    PERMISSIONS OWNER_READ GROUP_READ
    DESTINATION ${INSTALL_PREFIX}/${COMPLETIONS_HOME}
)

