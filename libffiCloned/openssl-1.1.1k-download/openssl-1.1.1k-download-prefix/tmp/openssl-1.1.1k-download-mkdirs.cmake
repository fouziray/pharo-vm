# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-src"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-build"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix/tmp"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix/src/openssl-1.1.1k-download-stamp"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix/src"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix/src/openssl-1.1.1k-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix/src/openssl-1.1.1k-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/libffiCloned/openssl-1.1.1k-download/openssl-1.1.1k-download-prefix/src/openssl-1.1.1k-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
