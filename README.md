# zbstudio-graphicscodepack
A package for [ZeroBraneStudio](https://github.com/pkulchenko/ZeroBraneStudio) to aid graphics programming in Lua (OpenGL, Vulkan etc.). Its content originates from the [Estrela Editor](http://www.luxinia.de/index.php/Estrela/Estrela) from which zbstudio was forked.

## Installation

There is two differnt options:

* Put the contents of this repository into zbstudios' package directory
* Put a dummy file into the package directory that simply forwards to the content of this repository:

  `return dofile([[Absolute filepath to graphicspackage.lua]])`

## Features

### GLSL
This package comes with a spec, api tooltips, and a tool for a basic GLSL compiler: [glslc](https://github.com/pixeljetstream/glslc)

![glslc inside zbstudio](http://www.luxinia.de/images/estrela_glslc.png).

### HLSL
Similar as above is provided for the DirectX HLSL compiler (however not maintained as much as GLSL).

### Lua
There is api completion for various lua-ffi bindings:
* [GLFW](http://www.glfw.org) 2 and 3
* OpenGL (glewgl) core + ARB,NV,AMD extensions
* Vulkan
* [ShaderC](https://github.com/google/shaderc) 

An interpreter for the [LuaJIT gfx sandbox](https://github.com/pixeljetstream/luajit_gfx_sandbox) is provided, which makes use of the above bindings.
