#[
This is the API container for null0 engine
]#

import boxy
import wasm3
import wasm3/wasm3c
import std/options

import ./physfs
import ./imports/graphics

var current_boxy: Boxy
var current_debug: bool

let windowSize* = ivec2(320, 240)
var null0_frame*: int

var null0_export_load:PFunction
var null0_export_update:PFunction
var null0_export_unload:PFunction
var null0_export_buttonDown:PFunction
var null0_export_buttonUp:PFunction


type Button* {.pure.} = enum
  BUTTON_B = 0,
  BUTTON_Y = 1,
  BUTTON_SELECT = 2,
  BUTTON_START = 3,
  BUTTON_UP = 4,
  BUTTON_DOWN = 5,
  BUTTON_LEFT = 6,
  BUTTON_RIGHT = 7,
  BUTTON_A = 8,
  BUTTON_X = 9,
  BUTTON_L = 10,
  BUTTON_R = 11,
  BUTTON_L2 = 12,
  BUTTON_R2 = 13,
  BUTTON_L3 = 14,
  BUTTON_R3 = 15


proc null0Import_trace(runtime: PRuntime; ctx: PImportContext; sp: ptr uint64; mem: pointer): pointer {.cdecl.} =
  proc procImpl(text: cstring) =
    echo text
  var s = sp.stackPtrToUint()
  callHost(procImpl, s, mem)

proc null0_setup_exports(runtime: PRuntime, debug:bool = false) =
  try:
    checkWasmRes m3_FindFunction(null0_export_update.addr, runtime, "update")
  except WasmError as e:
    if debug:
      echo "export update: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_unload.addr, runtime, "unload")
  except WasmError as e:
    if debug:
      echo "export unload: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_load.addr, runtime, "load")
  except WasmError as e:
    if debug:
      echo "export load: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_buttonDown.addr, runtime, "buttonDown")
  except WasmError as e:
    if debug:
      echo "export buttonDown: ", e.msg
  try:
    checkWasmRes m3_FindFunction(null0_export_buttonUp.addr, runtime, "buttonUp")
  except WasmError as e:
    if debug:
      echo "export buttonUp: ", e.msg

proc null0_setup_imports(module: PModule, debug: bool = false) =
  try:
    checkWasmRes m3_LinkRawFunction(module, "*", "trace", "v(*)", null0Import_trace)
  except WasmError as e:
    if debug:
      echo "import trace: ", e.msg
  null0_setup_imports_graphics(module, debug, current_boxy)


proc null0_load*(cartBytes:string, bxy: Boxy, debug:bool = false) =
  current_boxy = bxy
  null0_frame = 0
  current_debug = debug

  var e = physfs.init("null0")
  if e != 1:
    raise newException(IOError, "Could not initialize physfs")
  
  e = physfs.mountMemory(unsafeAddr cartBytes[0], int64 len(cartBytes), none(pointer), cstring "root", cstring "", cint 1)
  if e != 1:
    raise newException(IOError, "Could not mount physfs")
  
  var wasmBytes = readFilePhysfs("main.wasm")

  var env = m3_NewEnvironment()
  var runtime = env.m3_NewRuntime(uint32 uint16.high, nil)
  var module: PModule

  checkWasmRes m3_ParseModule(env, module.addr, cast[ptr uint8](unsafeAddr wasmBytes[0]), uint32 len(wasmBytes))
  checkWasmRes m3_LoadModule(runtime, module)

  null0_setup_imports(module, debug)
  null0_setup_exports(runtime, debug)

  if null0_export_load != nil:
    null0_export_load.call(void)

proc null0_unload*() =
  if null0_export_unload != nil:
    null0_export_unload.call(void)

proc null0_update*() =
  if null0_export_update != nil:
    null0_export_update.call(void, null0_frame)
  inc null0_frame

proc null0_buttonUp*(button: Button, device:int) =
  if current_debug:
    echo "BUTTON UP: " & $button & ": " & $device
  if null0_export_buttonUp != nil:
    null0_export_buttonUp.call(void, ord button, device)

proc null0_buttonDown*(button: Button, device:int) =
  if current_debug:
    echo "BUTTON DOWN: " & $button & ": " & $device
  if null0_export_buttonDown != nil:
    null0_export_buttonDown.call(void, ord button, device)