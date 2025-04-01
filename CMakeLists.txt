# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
cmake_minimum_required(VERSION 3.23.1)

project(usd-plugins CXX)

# include our packman dependencies
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(PackmanDeps)

# include NVIDIA Pixar Plugin build tools that simplify building OpenUSD plugins
include(NvPxrPlugin)

if (PXR_VERSION LESS_EQUAL 2311)
    set(CMAKE_CXX_STANDARD 14)
else()
    set(CMAKE_CXX_STANDARD 17)
endif()

if (NV_USD)
    # if NV_USD is on, we need to compile with the old C++ ABI
    add_compile_definitions(_GLIBCXX_USE_CXX11_ABI=0)
endif()

# set target directories
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/_install")
set(CMAKE_INSTALL_BINDIR "bin")
set(CMAKE_INSTALL_LIBDIR "lib")
set(CMAKE_INSTALL_INCLUDEDIR "include")

add_subdirectory(src/usd-plugins/schema/omniExampleCodelessSchema)
add_subdirectory(src/usd-plugins/schema/omniExampleSchema)
add_subdirectory(src/usd-plugins/schema/omniMetSchema)
