# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.1)

project(cairo-1.17.4-download NONE)

include(ExternalProject)
ExternalProject_Add(cairo-1.17.4-download
                    URL;https://files.pharo.org/vm/pharo-spur64/Darwin-arm64/third-party/cairo-1.17.4.zip
                    SOURCE_DIR          "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-src"
                    BINARY_DIR          "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
