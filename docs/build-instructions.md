## Additional Build Instructions

## Using CMake to Generate Schema Code and Build Files

These samples use `cmake` to drive generation of schema code (for codeful schemas) and building of OpenUSD plugins. The `cmake` infrastructure included here is setup to use pre-packaged OpenUSD builds (as well as some additional dependencies required by some of the plugins). The use of `packman` has been enabled in this repository to pull the relevant OpenUSD and Python packages (22.11 and 3.10 respectively) for a turnkey type solution that builds plugins compatible with NVIDIA Omniverse (106+).

The `cmake` build files are structured in the following way:

- The root `CMakeLists.txt` file, responsible for importing NVIDIA's OpenUSD plugin `cmake` helper, setting up the link between the pulled `packman` packages and the rest of the build commands, and the inclusion of the sub-directories containing OpenUSD plugin code.
- The `PackmanDeps.cmake` file, which setups paths to find `cmake` files to include from the `packman` packages that were pulled down.
- The `NvPxrPlugin.cmake` file from `nvopenusdbuildtools`, which contains helper functions for declaring OpenUSD schemas, plugin targets, and Python plugin targets.
- The individual `CMakeLists.txt` files for the OpenUSD plugins, which use the helper functions provided to build the individual plugins.

This works out of the box for both NVIDIA's customized OpenUSD 22.11 Python 3.10 build (i.e., `nv-usd`) and for stock OpenUSD 24.05 Python 3.10 by running the `build.bat`/`build.sh` files. To see all of the options available, run with the `--help` option. These files will:

- pull down the required `packman` packages from NVIDIA's package repositories (via `scripts/setup.py`)
- configure and build using `cmake`

Feel free to customize this sequence as well as the arguments passed to `cmake` as best suits your organization.


### Integrating your own OpenUSD/Python builds

If you would like to integrate your own build of OpenUSD and Python, you must:

- Change the `build.bat`/`build.sh` file such that the `--build-tools-only` option is passed to `scripts/setup.py` (This will ensure no package for OpenUSD or Python is pulled from the NVIDIA package repository, only the build support tools package)
- Edit the value of `PXR_OPENUSD_PYTHON_DIR` in `PackmanDeps.cmake` to point to the directory hosting the Python installation you want to use
- Edit the line in `PackmanDeps.cmake` that appends to the `CMAKE_PREFIX_PATH` – the value should point to your local OpenUSD build. Editing this will direct `cmake` to look for `pxrConfig.cmake` in your local directory rather than the directory of the pulled OpenUSD package from NVIDIA.


### Using your Built Schemas in Omniverse Kit 106

If you would like to use the example schemas here inside of `kit 106.x` (or use the examples to build your own schemas and use those in `kit`), you must:

- Clone the `kit-app-template` from https://github.com/NVIDIA-Omniverse/kit-app-template
- Follow the instructions to create a sample extension and a sample app in which that extension can be hosted

Once you have an extension created, it's time to host the built schemas in that extension. The easiest way to do this is to source link in the built schemas from this repo into the `target-deps` directory of your app template. This can be done by creating a `usd-plugins.packman.xml` file in the `tools/deps` folder of your app template and placing the following content in:

```xml
<project toolsVersion="5.0">
  <dependency name="usd_plugins" linkPath="../../_build/target-deps/usd_plugins" tags="${config} non-redist">
    <source path="../../../../github_updates/usd-plugin-samples/_install" />
  </dependency>
</project>
```

This tells `packman` to create a symbolic link at `_build/target-deps/usd_plugins` at the root of the `kit-app-template` folder that links to the `_install` directory of this repo (replace the relative source path as needed for your setup as well as the target install folder if you changed `CMAKE_INSTALL_PREFIX`). We also need to tell `kit` to make sure this file is processed when processing the other `packman` files. To do this, open the `repo.toml` file at the root of your `kit-app-template` and add the following under the `repo_build` section:

```lua
fetch.packman_target_files_to_pull = [
    "${root}/tools/deps/host-deps.packman.xml",
    "${root}/tools/deps/kit-sdk.packman.xml",
    "${root}/tools/deps/kit-sdk-deps.packman.xml",
    "${root}/tools/deps/usd-plugins.packman.xml"
]
```

We then need to copy the output of our `_install` folder into the `kit` extension directory. We can do this by opening up the `premake5.lua` file for our extension and adding the following:

```lua
-- Copy in the schema output libraries and resources
repo_build.prebuild_copy
{
    { target_deps.."/usd_plugins/**", ext.target_dir }
}
```

Since we source linked in our `_install` directory to `_build/target-deps/usd_plugins`, this copy command copies all of that content into the extension's build target directory.

Next, we have to modify the `extension.toml` file of our sample extension so that it loads the schema libraries. To do that, add the following at the top:

```toml
[core]
# Load at the start, load all schemas with order -100 (with order -1000 the OpenUSD libs are loaded)
order = -100
```

This ensures the extension, when set to load with the application, will load early, which is necessary to make sure our schema libraries are loaded by OpenUSD prior to the `UsdSchemaRegistry` being created. Next, we add the native libraries to load and the Python module for the codeful schema:

```toml
[[native.library]]
"filter:platform"."linux-x86_64"."path" = "lib/${lib_prefix}omniExampleSchema${lib_ext}"
"filter:platform"."windows-x86_64"."path" = "bin/${lib_prefix}omniExampleSchema${lib_ext}"

[[python.module]]
name = "OmniExampleSchema"
```

Finally, we add a dependency to `omni.usd.libs`, which is the extension in `kit` that hosts the OpenUSD libraries:

```toml
[dependencies]
"omni.usd.libs" = {}
```

Now we need to make sure the schemas are registered as plugins with OpenUSD. To do this, we will perform explicit registration via the `__init__.py` file parallel to your `extension.py` file in your `kit` extension by adding the following content (note, the specific path for `pluginsRoot` below will depend on the relative directory structure between your Python file performing the registration and the location of the `plugins` directory copied from the schema build artifacts):

```python
from pxr import Plug

pluginsRoot = os.path.join(os.path.dirname(__file__), '../../plugins')
omniExampleSchemaPath = os.path.join(pluginsRoot, "omniExampleSchema", "resources")
omniExampleCodelessSchemaPath = os.path.join(pluginsRoot, "omniExampleCodelessSchema", "resources")

Plug.Registry().RegisterPlugins(omniExampleSchemaPath)
Plug.Registry().RegisterPlugins(omniExampleCodelessSchemaPath)
```

Now build your extension and app using the `kit-app-template` instructions (usually `repo.bat build` or `./repo.sh build`).

Once the application and extension are built, it's time to make sure our extension gets auto-loaded into the application. This is necessary because plugins need to be registered with OpenUSD as early as possible to ensure the relevant singleton manager picks them up. Launch your application with developer extensions enabled:

**On Linux:**
```bash
./repo.sh launch -d
```

**On Windows:**
```batch
repo.bat launch -d
```

Open the extension manager, find the extension you created, and enable it. Open the extension's properties and select the `Autoload` box at the top. Then close and restart your `kit` application. Alternatively, you can add your extension to the `[dependencies]` section of the `app` configuration. Once restarted, the schemas should be loaded inside of `kit`. To test this, you can open up the scripting window and use the following script:

```python
import OmniExampleSchema
import omni.usd

from pxr import UsdGeom

# Create new mesh prim and apply one of the API schemas to it
stage = omni.usd.get_context().get_stage()
prim = UsdGeom.Mesh.Define(stage, "/World/MyMesh")
OmniExampleSchema.OmniTemperatureDataAPI.Apply(prim.GetPrim())

# Now apply the example codeless schema
prim.GetPrim().ApplyAPI("OmniExampleCodelessOmniSourceFormatMetadataAPI")
```

To verify that the relevant schema properties have been applied to the prim, select the `/World/MyMesh` prim and examine the `Raw USD` properties in the property window. If you'd like these properties to show up in their own respective groups, you would need to add a property window extension to achieve that behavior.
