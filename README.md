# zbstudio-graphicscodepack
A package for [ZeroBraneStudio](https://studio.zerobrane.com/) to aid graphics programming in Lua (OpenGL, Vulkan etc.). Its content originates from the [Estrela Editor](http://www.luxinia.de/index.php/Estrela/Estrela) from which zbstudio was forked. The installation of this package supercedes the "estrela" configuration that zbstudio used previously.

## Installation

ZeroBraneStudio 1.51 or a version from this [commit](https://github.com/pkulchenko/ZeroBraneStudio/commit/9c8b3f0167361cc7e065e48a5deb9f6c93fd03a4) onwards.

There is two differnt options:

* Install like a regular package, put the lua file and the subdirectory of this repository into zbstudio's package directory
* Put a dummy file into the package directory that simply forwards to the content of this repository:

  `return dofile([[Absolute filepath to graphicscodepack.lua]])`

## Features

### GLSL
This package comes with a spec, api tooltips, and tools for GLSL.

#### GLSLC Tool
Uses [glslc](https://github.com/pixeljetstream/glslc), which makes use of the system's OpenGL driver to compile the files (not recommended anymore, prefer to use GLSLANG, see below)
To make the GLSLC menu working either modify your zbstudio's `cfg/user.lua` and add `path.glslcbin = [[path to glslc.exe (excluded)]]` or set the `GLSLC_BIN_PATH` environment variable.

![glslc inside zbstudio](http://www.luxinia.de/images/estrela_glslc.png).

The GLASM output from glslc is also analyzed and formated by the tool. However, be aware that this is just an intermediate format for NVIDIA and not the actual assembly.

![glslc_glasm](http://www.luxinia.de/uploads/Estrela/Estrelacg.png)

Depending on the shadertype a define is set, e.g. `-D_VERTEX_SHADER_ -D_IDE_`.

#### GLSLANG Tool
Uses the official Khronos [glslangValidator](https://github.com/KhronosGroup/glslang) from the installed [VulkanSDK](https://vulkan.lunarg.com/sdk/home).
To get the GLSLANG menu, modify `cfg/user.lua` and add `path.glslangbin = [[path to glslangValidator.exe (excluded)]]` otherwise `(os.getenv("VULKAN_SDK") and os.getenv("VULKAN_SDK").."/Bin")` is used.

The menu looks similar to the above tool. On success two files are generated `<inputfile>.spv` and `<inputfile>.txt` (humand readable spir-v).
By default shaders are compiled targeting Vulkan 1.1. The tool does support raytracing and mesh shaders.

Depending on the shadertype a define is set, e.g. `-D_VERTEX_SHADER_ -D_IDE_`.

To add project specific include directories:
* put `zbsgfxpack.lua` file in project directory
* return include paths through the lua file: `return { glslang = { includes = { "myIncludeDirectory", ...} } }`

### HLSL
Similar as above is provided for the DirectX HLSL (however not maintained as much as GLSL). 

#### DXC Tool
To get the DXC menu entry, modify `cfg/user.lua` and add `path.dxcbin = [[path to dxc.exe (excluded)]]`

#### FXC Tool
To get the FXC menu entry, modify `cfg/user.lua` and add `path.fxcbin = [[path to fxc.exe (excluded)]]` otherwise `(os.getenv("DXSDK_DIR") and os.getenv("DXSDK_DIR").."/Utilities/bin/x86/")` is used.

Depending on the shadertype a define is set, e.g. `-D_VERTEX_SHADER_ -D_IDE_`.

### Lua
#### Api Files
There is api completion for various lua-ffi bindings:
* [GLFW](http://www.glfw.org) 2 and 3
* OpenGL (glewgl) core + ARB,NV,AMD extensions
* Vulkan
* [ShaderC](https://github.com/google/shaderc) 

#### Interpreter
An interpreter for the [LuaJIT gfx sandbox](https://github.com/pixeljetstream/luajit_gfx_sandbox) is provided, which makes use of the above bindings. It can be used by setting `path.luajitgfxsandbox = [[path to luajit gfx runtime directory]]` in the config file or via `LUAJIT_GFX_SANDBOX_PATH` environment variable. The interpreter does support debugging.

### Tools
#### LuaJIT ffi string to editor api
A tool is provided to turn a LuaJIT ffi C header into an api specification that zbstudio can use. This makes adding auto completion and tooltips for C apis easier. Ensure the ffi header is in the active editor tab when running the tool.

#### Perforce edit/revert
To some basic perforce operations with the current file

#### stringify to C
Surrounds every line of the active editor file by quotes and new line symbol: ```" original content \n"``` 
