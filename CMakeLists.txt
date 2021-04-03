cmake_minimum_required(VERSION 3.0)

include(GNUInstallDirs)

project(
  tidysh
  VERSION 0.0.2
  HOMEPAGE_URL https://github.com/montag451/tidysh
  DESCRIPTION "A small shell library to improve error handling in shell scripts"
  LANGUAGES NONE
  )

install(FILES tidy.sh DESTINATION "${CMAKE_INSTALL_LIBDIR}/tidysh")

set(CPACK_GENERATOR DEB RPM)
set(CPACK_PACKAGE_CONTACT montag451@laposte.net)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE all)
set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
set(CPACK_RPM_PACKAGE_ARCHITECTURE noarch)
include (CPack)
