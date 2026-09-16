# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.1)

project(libssh2-1.10.0-download NONE)

include(ExternalProject)
ExternalProject_Add(libssh2-1.10.0-download
                    URL;https://files.pharo.org/vm/pharo-spur64/Darwin-arm64/third-party/libssh2-1.10.0.zip
                    SOURCE_DIR          "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/libssh2-1.10.0-src"
                    BINARY_DIR          "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/libssh2-1.10.0-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
