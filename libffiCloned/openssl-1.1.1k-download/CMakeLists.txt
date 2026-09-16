# Distributed under the OSI-approved MIT License.  See accompanying
# file LICENSE or https://github.com/Crascit/DownloadProject for details.

cmake_minimum_required(VERSION 3.1)

project(openssl-1.1.1k-download NONE)

include(ExternalProject)
ExternalProject_Add(openssl-1.1.1k-download
                    URL;https://files.pharo.org/vm/pharo-spur64/Darwin-arm64/third-party/openssl-1.1.1k.zip
                    SOURCE_DIR          "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-src"
                    BINARY_DIR          "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
)
