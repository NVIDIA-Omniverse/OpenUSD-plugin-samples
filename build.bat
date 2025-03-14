:: Copyright 2023-2024 NVIDIA CORPORATION
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::    http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

@echo off
setlocal enabledelayedexpansion

pushd %~dp0

REM options defining what the script runs
set HELP=false
set CLEAN=false
set USD_FLAVOR=nv-usd
set USD_VER=22.11
set PYTHON_VER=3.10
set CONFIG=release
set HELP_EXIT_CODE=0

set DIRECTORIES_TO_CLEAN=_install _build

REM default arguments for script
:parseargs
if not "%1"=="" (
    if "%1" == "--clean" (
        set CLEAN=true
    )
    if "%1" == "--debug" (
        set CONFIG=debug
    )
    if "%1" == "--relwithdebinfo" (
        set CONFIG=relwithdebinfo
    )
    if "%1" == "--help" (
        set HELP=true
    )
    shift
    goto :parseargs
)

REM requesting how to run the script
if "%HELP%" == "true" (
    echo build.bat [--clean] [--usd-flavor] [--usd-ver] [--python-ver][--debug | --relwithdebinfo] [--help]
    echo --clean: Removes the following directories ^(customize as needed^):
    for %%a in (%DIRECTORIES_TO_CLEAN%) DO (
        echo       %%a
    )
    echo --usd-flavor: The flavor of OpenUSD to use to build ^(options=[nv-usd, openusd], default=nv-usd^)
    echo --usd-ver: The version of OpenUSD to use to build ^(options=[22.11, 24.05], default=22.11^)
    echo --python-ver: The version of Python to use to build ^(options=[3.10, 3.11], default=3.10^)
    echo   note that the three options above must have an availble configuration to pull down
    echo --debug: Performs the steps with a debug configuration instead of release
    echo       ^(default = release^)
    echo --relwithdebinfo: Performs the steps with a relwithdebinfo configuration instead of release
    echo       ^(default = release^)
    echo --help: Display this help message
    exit %HELP_EXIT_CODE%
)

REM should we clean the target directory?
if "%CLEAN%" == "true" (
    for %%a in (%DIRECTORIES_TO_CLEAN%) DO (
        if exist "%~dp0%%a/" (
            rmdir /s /q "%~dp0%%a"
        )
    )

    if !errorlevel! neq 0 (goto :Error)

    goto :Success
)

REM perform a simple build sequence (customize as needed for your environment)

REM pull OpenUSD and Python dependencies as well as some helper cmake scripts
call "%~dp0tools\packman\python.bat" scripts\setup.py --usd-flavor=%USD_FLAVOR% --usd-ver=%USD_VER% --python-ver=%PYTHON_VER% --config=%CONFIG%
if !errorlevel! neq 0 (goto :Error)

REM configure and build using cmake
if "%USD_FLAVOR%" == "nv-usd" (
    cmake -B ./_build/cmake -DNV_USD=ON -T v142
    cmake --build ./_build/cmake --config=%CONFIG% --target=install
)

if NOT "%USD_FLAVOR%" == "nv-usd" (
    cmake -B ./_build/cmake -T v142
    cmake --build ./_build/cmake --config=%CONFIG% --target=install
)

:Success
exit /b 0

:Error
exit /b !errorlevel!