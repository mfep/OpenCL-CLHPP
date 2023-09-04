set(CPACK_PACKAGE_VENDOR "khronos")

set(CPACK_PACKAGE_DESCRIPTION "C++ headers for OpenCL development
 C++ headers for OpenCL development
 OpenCL (Open Computing Language) is a multi-vendor open standard for
 general-purpose parallel programming of heterogeneous systems that include
 CPUs, GPUs and other processors.
 .
 This package provides the C++ development header files for the OpenCL API
 as published by The Khronos Group Inc. The corresponding specification and
 documentation can be found on the Khronos website.
")

set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE.txt")

set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

if(NOT CPACK_PACKAGING_INSTALL_PREFIX)
  set(CPACK_PACKAGING_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
endif()

# DEB packaging configuration
if(NOT DEFINED CPACK_DEBIAN_PACKAGE_MAINTAINER)
  set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${CPACK_PACKAGE_VENDOR})
endif()

set(CPACK_DEBIAN_PACKAGE_HOMEPAGE
    "https://github.com/KhronosGroup/OpenCL-CLHPP")

set(CPACK_DEBIAN_PACKAGE_VERSION "${PROJECT_VERSION}")
if(DEFINED LATEST_RELEASE_VERSION)
  # Remove leading "v", if exists
  string(LENGTH "${LATEST_RELEASE_VERSION}" LATEST_RELEASE_VERSION_LENGTH)
  string(SUBSTRING "${LATEST_RELEASE_VERSION}" 0 1 LATEST_RELEASE_VERSION_FRONT)
  if(LATEST_RELEASE_VERSION_FRONT STREQUAL "v")
    string(SUBSTRING "${LATEST_RELEASE_VERSION}" 1 ${LATEST_RELEASE_VERSION_LENGTH} LATEST_RELEASE_VERSION)
  endif()

  string(APPEND CPACK_DEBIAN_PACKAGE_VERSION "~${LATEST_RELEASE_VERSION}")
endif()
set(CPACK_DEBIAN_PACKAGE_RELEASE "1") # debian_revision (because this is a non-native pkg)
set(PACKAGE_VERSION_REVISION "${CPACK_DEBIAN_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_RELEASE}${DEBIAN_VERSION_SUFFIX}")

set(DEBIAN_PACKAGE_NAME "opencl-clhpp-headers")
set(CPACK_DEBIAN_PACKAGE_NAME
    "${DEBIAN_PACKAGE_NAME}"
    CACHE STRING "Package name" FORCE)

set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")

# Dependencies
set(CPACK_DEBIAN_PACKAGE_DEPENDS "opencl-c-headers (>= ${CPACK_DEBIAN_PACKAGE_VERSION})")
set(CPACK_DEBIAN_PACKAGE_BREAKS "opencl-headers (<< ${CPACK_DEBIAN_PACKAGE_VERSION})")
set(CPACK_DEBIAN_PACKAGE_REPLACES "opencl-headers (<< ${CPACK_DEBIAN_PACKAGE_VERSION})")

# Package file name in deb format:
# <PackageName>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
set(CPACK_DEBIAN_FILE_NAME "${DEBIAN_PACKAGE_NAME}_${PACKAGE_VERSION_REVISION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb")

if (NOT CMAKE_SCRIPT_MODE_FILE) # Don't run in script mode

# Configuring pkgconfig

# We need two different instances of OpenCL.pc
# One for installing (cmake --install), which contains CMAKE_INSTALL_PREFIX as prefix
# And another for the Debian development package, which contains CPACK_PACKAGING_INSTALL_PREFIX as prefix

join_paths(OPENCLHPP_INCLUDEDIR_PC "\${prefix}" "${CMAKE_INSTALL_INCLUDEDIR}")

set(pkg_config_location ${CMAKE_INSTALL_DATADIR}/pkgconfig)
set(PKGCONFIG_PREFIX "${CMAKE_INSTALL_PREFIX}")
configure_file(
  OpenCL-CLHPP.pc.in
  ${CMAKE_CURRENT_BINARY_DIR}/pkgconfig_install/OpenCL-CLHPP.pc
  @ONLY)
install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/pkgconfig_install/OpenCL-CLHPP.pc
  DESTINATION ${pkg_config_location}
  COMPONENT pkgconfig_install)

set(PKGCONFIG_PREFIX "${CPACK_PACKAGING_INSTALL_PREFIX}")
configure_file(
  OpenCL-CLHPP.pc.in
  ${CMAKE_CURRENT_BINARY_DIR}/pkgconfig_package/OpenCL-CLHPP.pc
  @ONLY)
# This install component is only needed in the Debian package
install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/pkgconfig_package/OpenCL-CLHPP.pc
  DESTINATION ${pkg_config_location}
  COMPONENT pkgconfig_package
  EXCLUDE_FROM_ALL)

# By using component based packaging, component pkgconfig_install
# can be excluded from the package, and component pkgconfig_package
# can be included.
set(CPACK_DEB_COMPONENT_INSTALL ON)
set(CPACK_COMPONENTS_GROUPING "ALL_COMPONENTS_IN_ONE")

include(CPackComponent)
cpack_add_component(pkgconfig_install)
cpack_add_component(pkgconfig_package)
set(CPACK_COMPONENTS_ALL "Unspecified;pkgconfig_package")

set(CPACK_DEBIAN_PACKAGE_DEBUG ON)

include(CPack)

endif()
