:: Copyright (c) 2023, NVIDIA CORPORATION.  All rights reserved.
::
:: NVIDIA CORPORATION and its licensors retain all intellectual property
:: and proprietary rights in and to this software, related documentation
:: and any modifications thereto.  Any use, reproduction, disclosure or
:: distribution of this software and related documentation without an express
:: license agreement from NVIDIA CORPORATION is strictly prohibited.

@echo off

set CONFIG=release

:parseargs
if not "%1" == "" (
    if "%1" == "debug" (
        set CONFIG=debug
    )
    shift
    goto parseargs
)

echo Setting environment for %CONFIG% configuration...

if not exist %~dp0_venv (
    %~dp0_build\usd-deps\python\python.exe -m venv %~dp0_venv
    call "%~dp0_venv\Scripts\activate.bat"
    pip install PySide2
    pip install PyOpenGL
    pip install warp-lang
) else (
    call "%~dp0_venv\Scripts\activate.bat"
)

set PYTHONPATH=%~dp0_build\usd-deps\nv-usd\%CONFIG%\lib\python;%~dp0_build\target-deps\omni-geospatial;%~dp0_install\windows-x86_64\%CONFIG%\omniWarpSceneIndex
set PATH=%PATH%;%~dp0_build\usd-deps\python;%~dp0_build\usd-deps\nv-usd\%CONFIG%\bin;%~dp0_build\usd-deps\nv-usd\%CONFIG%\lib;%~dp0_build\target-deps\zlib\lib\rt_dynamic\release;%~dp0_install\windows-x86_64\%CONFIG%\edfFileFormat\lib;%~dp0_install\windows-x86_64\%CONFIG%\omniMetProvider\lib;%~dp0_build\target-deps\omni-geospatial\bin;$~dp0_install\windows-x86_64\$CONFIG\omniWarpSceneIndex\lib
set PXR_PLUGINPATH_NAME=%~dp0_install\windows-x86_64\%CONFIG%\omniMetSchema\resources;%~dp0_install\windows-x86_64\%CONFIG%\edfFileFormat\resources;%~dp0_install\windows-x86_64\%CONFIG%\omniMetProvider\resources;%~dp0_build\target-deps\omni-geospatial\plugins\OmniGeospatial\resources;%~dp0_install\windows-x86_64\%CONFIG%\omniGeoSceneIndex\resources;%~dp0_install\windows-x86_64\%CONFIG%\omniMetricsAssembler\resources;%~dp0_install\windows-x86_64\%CONFIG%\omniWarpSceneIndex\resources
set USDIMAGINGGL_ENGINE_ENABLE_SCENE_INDEX=true