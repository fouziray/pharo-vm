# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-src"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-build"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix/tmp"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix/src/libgit2-default-2023-04-14-download-stamp"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix/src"
  "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix/src/libgit2-default-2023-04-14-download-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix/src/libgit2-default-2023-04-14-download-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/faouziray/Documents/XP/Pharo/images/pharoSprint26-06/pharo-local/iceberg/fouziray/pharo-vm/bs/libgit2-default-2023-04-14-download/libgit2-default-2023-04-14-download-prefix/src/libgit2-default-2023-04-14-download-stamp${cfgdir}") # cfgdir has leading slash
endif()
