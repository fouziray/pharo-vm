# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-src"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-build"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix/tmp"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix/src/cairo-1.17.4-download-stamp"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix/src"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix/src/cairo-1.17.4-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix/src/cairo-1.17.4-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/cairo-1.17.4-download/cairo-1.17.4-download-prefix/src/cairo-1.17.4-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
