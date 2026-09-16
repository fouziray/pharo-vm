# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.1)

project(libpng-1.6.37-download NONE)

include(ExternalProject)
ExternalProject_Add(libpng-1.6.37-download
                    URL;https://files.pharo.org/vm/pharo-spur64/Darwin-arm64/third-party/libpng-1.6.37.zip
                    SOURCE_DIR          "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-src"
                    BINARY_DIR          "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
