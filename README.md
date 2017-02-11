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
This package comes with a spec, api tooltips, and a tool for a basic GLSL compiler: [glslc](https://github.com/pixeljetstream/glslc)
To make the GLSL menu working either modify your zbstudio's `cfg/user.lua` and add `path.glslcbin = [[path to glslc.exe (excluded)]]` or set the `GLSLC_BIN_PATH` environment variable.

![glslc inside zbstudio](http://www.luxinia.de/images/estrela_glslc.png).

The GLASM output from glslc is also analyzed and formated by the tool. However, be aware that this is just an intermediate format for NVIDIA and not the actual assembly.

![glslc_glasm](http://www.luxinia.de/uploads/Estrela/Estrelacg.png)

### HLSL/DX
Similar as above is provided for the DirectX HLSL compiler (however not maintained as much as GLSL). Similar to GLSL modify `cfg/user.lua` and add `path.fxcbin = [[path to fxc.exe (excluded)]]` otherwise `(os.getenv("DXSDK_DIR") and os.getenv("DXSDK_DIR").."/Utilities/bin/x86/")` is used.

### Lua
There is api completion for various lua-ffi bindings:
* [GLFW](http://www.glfw.org) 2 and 3
* OpenGL (glewgl) core + ARB,NV,AMD extensions
* Vulkan
* [ShaderC](https://github.com/google/shaderc) 

An interpreter for the [LuaJIT gfx sandbox](https://github.com/pixeljetstream/luajit_gfx_sandbox) is provided, which makes use of the above bindings. It can be used by setting `path.luajitgfxsandbox = [[path to luajit gfx runtime directory]]` in the config file or via `LUAJIT_GFX_SANDBOX_PATH` environment variable. The interpreter does support debugging.
