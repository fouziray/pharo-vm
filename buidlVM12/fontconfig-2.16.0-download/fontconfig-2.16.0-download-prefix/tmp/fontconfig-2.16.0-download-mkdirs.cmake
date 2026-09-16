# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-src"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-build"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix/tmp"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix/src/fontconfig-2.16.0-download-stamp"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix/src"
  "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix/src/fontconfig-2.16.0-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix/src/fontconfig-2.16.0-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/122/pharo-local/iceberg/fouziray/pharo-vm/buidlVM12/fontconfig-2.16.0-download/fontconfig-2.16.0-download-prefix/src/fontconfig-2.16.0-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
