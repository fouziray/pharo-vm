# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-src"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-build"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix/tmp"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix/src/libpng-1.6.37-download-stamp"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix/src"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix/src/libpng-1.6.37-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix/src/libpng-1.6.37-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libpng-1.6.37-download/libpng-1.6.37-download-prefix/src/libpng-1.6.37-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
