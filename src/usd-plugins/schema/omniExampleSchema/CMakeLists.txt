# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../../../_install/omniExampleSchema")
set(CMAKE_INSTALL_BINDIR "bin")
set(CMAKE_INSTALL_LIBDIR "lib")
set(CMAKE_INSTALL_INCLUDEDIR "include")
openusd_schema(omniExampleSchema
    GENERATE_SCHEMA
    SCHEMA_FILE
        "${CMAKE_CURRENT_LIST_DIR}/schema.usda"
)
