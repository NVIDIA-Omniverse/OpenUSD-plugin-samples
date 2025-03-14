# SPDX-FileCopyrightText: Copyright (c) 2023-2024 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
"""
Script encapsulating setup logic for the samples.
"""
import argparse
import logging
import os
import platform
import subprocess

def _get_platform_arch():
    """
    Retrieves the platform and architecture.
    """
    platform_host = platform.system().lower()
    arch = platform.machine()
    if arch == "AMD64":
        arch = "x86_64"

    if platform_host == "darwin":
        platform_host = "macos"

    return "-".join([platform_host, arch])

def _setup_dependencies(usd_flavor: str, usd_ver: str, python_ver: str, config: str, build_tools_only: bool, use_new_abi: bool=False):
    """
    Downloads selected dependency packages from NVIDIA based on the provided information.

    Args:
        usd_flavor: The flavor of OpenUSD to build with (e.g., nv-usd, openusd).
        usd_ver: The version of OpenUSD to build with.
        python_ver: The version of Python that accompanies the OpenUSD build to build with.
        config: The configuration that will be built.
        build_tools_only: True to only pull the build tools (skip pulling OpenUSD and Python).
    """
    if not build_tools_only:
        logging.getLogger("usd-plugin-samples").info(f"Pulling dependencies for {usd_flavor} {usd_ver} Python {python_ver}...")

        # select the version of OpenUSD to pull down
        platform_arch = _get_platform_arch()
        platform_abi_tag = platform_arch
        if use_new_abi and platform.system().lower() == "linux":
            platform_abi_tag = platform_abi_tag.replace("linux", "manylinux_2_35")

        usd_python_version = f"{usd_ver}+{python_ver}"
        template_path = os.path.join("templates", "packman", usd_flavor, usd_python_version, "usd-deps.packman.xml")
        if not os.path.exists(template_path):
            raise RuntimeError(f"Requested OpenUSD flavor {usd_flavor} {usd_ver} Python {python_ver} not currently supported")

        if os.name == "nt":
            packman_exe = ".\\tools\\packman\\packman.cmd"
        else:
            packman_exe = "./tools/packman/packman"

        packman_command_line = [
            packman_exe,
            "pull",
            template_path,
            "-p",
            platform_arch,
            "--token",
            f"platform_target_abi={platform_abi_tag}",
            "--token",
            f"config={config}"
        ]

        subprocess.run(packman_command_line, check=True)

    packman_command_line = [
        f"{packman_exe}",
        "pull",
        f"deps/host-deps.packman.xml",
        "-p",
        platform_arch,
        "--token",
        f"platform_target_abi={platform_abi_tag}",
        "--token",
        f"config={config}"
    ]

    subprocess.run(packman_command_line, check=True)

if __name__ == "__main__":

    configs = [
        "debug",
        "Debug",
        "relwithdebinfo",
        "RelWithDebInfo",
        "release",
        "Release"
    ]

    logging.getLogger("usd-plugin-samples").info("Invoking setup")

    parser = argparse.ArgumentParser()

    logging.basicConfig(level=logging.INFO)

    parser.add_argument(
        "--usd-flavor",
        dest="usd_flavor",
        required=False,
        choices=["nv-usd", "openusd"],
        default=None,
        help="The flavor of OpenUSD to build with (e.g., nv-usd, openusd)."
    )

    parser.add_argument(
        "--usd-ver",
        dest="usd_ver",
        required=False,
        default=None,
        help="The version of the OpenUSD build to build with."
    )

    parser.add_argument(
        "--python-ver",
        dest="python_ver",
        required=False,
        default=None,
        help="The version of Python that accompanies the OpenUSD build to build with."
    )

    parser.add_argument(
        "--config",
        dest="config",
        required=False,
        default="RelWithDebInfo",
        choices=configs,
        help="The build configuration to buid."
    )

    parser.add_argument(
        "--build-tools-only",
        dest="build_tools_only",
        required=False,
        action="store_true",
        help="Skips the acquisition of the OpenUSD and Python packages and only pulls down the build tools."
    )

    args = parser.parse_args()

    # pull down reqs for building
    # this includes:
    # 1. The OpenUSD version requested
    # 2. The python version requested
    # 3. NVIDIA build tools for cmake helpers
    _setup_dependencies(args.usd_flavor, args.usd_ver, args.python_ver, args.config, args.build_tools_only)
