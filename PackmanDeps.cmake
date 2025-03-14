# SPDX-FileCopyrightText: Copyright (c) 2024 NVIDIA CORPORATION & AFFILIATES.  All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#

# tell usd-plugin-cmake-utils where to find python
set(PXR_OPENUSD_PYTHON_DIR "${CMAKE_CURRENT_LIST_DIR}/_build/usd-deps/python")

# add the path to OpenUSD to the prefix path
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/_build/usd-deps/usd")

# add the path to find usd-plugin-cmake-utils
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/_build/host-deps/usd-plugin-cmake-utils/cmake")