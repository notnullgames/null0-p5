{.passC: "-Ivendor/gamepad/source".}

{.compile: "vendor/gamepad/source/gamepad/Gamepad_private.c".}

when defined(macosx):
  {.compile: "vendor/gamepad/source/gamepad/Gamepad_macosx.c".}
  {.passL: "-framework IOKit".}

when defined(linux):
  {.compile: "vendor/gamepad/source/gamepad/Gamepad_linux.c".}

when defined(windows):
  {.compile: "vendor/gamepad/source/gamepad/Gamepad_windows_dinput.c".}
  {.compile: "vendor/gamepad/source/gamepad/Gamepad_windows_mm.c".}
  {.passC: "-DFREEGLUT_STATIC -I C:/MinGW/dx9/include".}
  {.passL: "C:/MinGW/dx9/lib/x64/Xinput.lib C:/MinGW/dx9/lib/x64/dinput8.lib C:/MinGW/dx9/lib/x64/dxguid.lib C:/MinGW/WinSDK/Lib/x64/WbemUuid.Lib C:/MinGW/WinSDK/Lib/x64/Ole32.Lib C:/MinGW/WinSDK/Lib/x64/OleAut32.Lib".}

type
  Gamepad_device* {.bycopy.} = object
    deviceID*: cuint
    description*: cstring
    vendorID*: cint
    productID*: cint
    numAxes*: cuint
    numButtons*: cuint
    axisStates*: ptr cfloat
    buttonStates*: ptr bool
    privateData*: pointer
  
  cbAttach = proc (device: ptr Gamepad_device; context: pointer)
  cbButton = proc (device: ptr Gamepad_device; buttonID: cuint; timestamp: cdouble; context: pointer)
  cbAxis = proc (device: ptr Gamepad_device; axisID: cuint; value: cfloat; lastValue: cfloat; timestamp: cdouble; context: pointer)


{.push callconv: cdecl, importc:"Gamepad_$1".}
proc init*()
proc shutdown*()
proc numDevices*(): cuint
proc deviceAtIndex*(deviceIndex: cuint): ptr Gamepad_device
proc detectDevices*()
proc processEvents*()
proc deviceAttachFunc*(callback: cbAttach; context: pointer = nil)
proc deviceRemoveFunc*(callback: cbAttach; context: pointer = nil)
proc buttonDownFunc*(callback: cbButton; context: pointer = nil)
proc buttonUpFunc*(callback: cbButton; context: pointer = nil)
proc axisMoveFunc*(callback: cbAxis; context: pointer = nil)
{.pop.}