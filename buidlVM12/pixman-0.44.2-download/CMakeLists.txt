# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.10)

# Use the timestamp of extraction for downloaded archives (silences the
# CMP0135 deprecation warning on CMake >= 3.24; no-op on older CMake).
# This template is configured as a standalone project, so the policy must
# be set here in addition to the top-level CMakeLists.txt.
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
endif()

project(pixman-0.44.2-download NONE)

include(ExternalProject)
ExternalProject_Add(pixman-0.44.2-download
                    URL;https://files.pharo.org/vm/pharo-spur64/Darwin-arm64/third-party/pixman-0.44.2.zip
                    SOURCE_DIR          "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/pixman-0.44.2-src"
                    BINARY_DIR          "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/pixman-0.44.2-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
