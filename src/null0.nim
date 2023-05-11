#[
This is the CLI for null0
]#

import boxy, opengl, windy
import docopt
import std/tables

import ./api
import gamepad

const doc = """
null0 - Runtime for null0 game-engine

Usage:
  null0 --help
  null0 <cart>
  null0 -v <cart>

<cart>   Specify the cart-name (wasm file or zip/directory with main.wasm in it)

Options:
  -h --help               Show this screen.
  -v --verbose            Enable debugging text
"""

let args = docopt(doc, version = "0.0.1")
let cart = $args["<cart>"]

let window = newWindow("null0", windowSize)
makeContextCurrent(window)
loadExtensions()

let bxy = newBoxy()

let ratio = windowSize.x / windowSize.y
var scale = 1.0
var offset = vec2(0, 0)
var vs:Vec2
let ws = windowSize.vec2

# TODO: This map comes from an 8BitDo SN30, but I probably need some kind of mapping system
# TODO: add key maps, too
var buttonMap = {
  cuint 1: BUTTON_B,
  cuint 2: BUTTON_A,
  cuint 3: BUTTON_Y,
  cuint 4: BUTTON_X,
  cuint 5: BUTTON_L,
  cuint 6: BUTTON_R,
  cuint 7: BUTTON_SELECT,
  cuint 8: BUTTON_START
}.toTable


proc onGamepadAttached(device: ptr Gamepad_device; context: pointer) {.cdecl.} =
  var js = device[]
  echo "attached: " & $js.deviceID

proc onGamepadRemoved(device: ptr Gamepad_device; context: pointer) {.cdecl.} =
  var js = device[]
  echo "removed: " & $js.deviceID

proc onButtonDown (device: ptr Gamepad_device; buttonID: cuint; timestamp: cdouble; context: pointer) {.cdecl.} =
  var js = device[]
  if buttonMap.hasKey(buttonID):
    null0_buttonDown(buttonMap[buttonID], int js.deviceID)

proc onButtonUp (device: ptr Gamepad_device; buttonID: cuint; timestamp: cdouble; context: pointer) {.cdecl.} =
  var js = device[]
  if buttonMap.hasKey(buttonID):
    null0_buttonUp(buttonMap[buttonID], int js.deviceID)

proc onAxisMoved (device: ptr Gamepad_device; axisID: cuint; value: cfloat; lastValue: cfloat; timestamp: cdouble; context: pointer) {.cdecl.} =
  var js = device[]
  if axisID == 0:
    if value < -0.5:
      null0_buttonDown(BUTTON_LEFT, int js.deviceID)
    elif value > 0.5:
      null0_buttonDown(BUTTON_RIGHT, int js.deviceID)
    else:
      null0_buttonUp(BUTTON_LEFT, int js.deviceID)
      null0_buttonUp(BUTTON_RIGHT, int js.deviceID)
  if axisID == 1:
    if value < -0.5:
      null0_buttonDown(BUTTON_UP, int js.deviceID)
    elif value > 0.5:
      null0_buttonDown(BUTTON_DOWN, int js.deviceID)
    else:
      null0_buttonUp(BUTTON_UP, int js.deviceID)
      null0_buttonUp(BUTTON_DOWN, int js.deviceID)

const GAMEPAD_POLL_ITERATION_INTERVAL=30
gamepad.deviceAttachFunc(onGamepadAttached)
gamepad.deviceRemoveFunc(onGamepadRemoved)
gamepad.buttonDownFunc(onButtonDown)
gamepad.buttonUpFunc(onButtonUp)
gamepad.axisMoveFunc(onAxisMoved)
gamepad.init()

# TODO: currently only supports cart, but should also support dir
null0_load(readFile(cart), bxy, args["--verbose"])

window.onFrame = proc() =
  vs = window.size.vec2
  if vs.x > (vs.y * ratio):
    scale = vs.y / ws.y
    offset.x = (vs.x - (ws.x * scale)) / 2
    offset.y = 0
  else:
    scale = vs.x / ws.x
    offset.y = (vs.y - (ws.y * scale)) / 2
    offset.x = 0

  bxy.beginFrame(window.size)
  bxy.saveTransform()
  bxy.translate(offset)
  bxy.scale(scale)
  null0_update()
  bxy.restoreTransform()
  bxy.endFrame()
  window.swapBuffers()

var iterationsToNextPoll = GAMEPAD_POLL_ITERATION_INTERVAL
while not window.closeRequested:
  pollEvents()
  dec iterationsToNextPoll
  if iterationsToNextPoll == 0:
    gamepad.detectDevices()
    iterationsToNextPoll = GAMEPAD_POLL_ITERATION_INTERVAL
  gamepad.processEvents();

null0_unload()
