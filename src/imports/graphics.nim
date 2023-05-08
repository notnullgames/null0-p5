import boxy
import wasm3
import wasm3/wasm3c

import ../physfs

var current_boxy: Boxy

var null0_screen*: Image
var null0_canvas*: Context

proc readImagePhysfs(filePath: string):Image =
  return decodeImage(readFilePhysfs(filePath))

proc null0_setup_imports_graphics*(module: PModule, debug: bool, bxy: Boxy) =
  current_boxy = bxy
  null0_screen = newImage(320, 240)
  null0_canvas = newContext(null0_screen)
  bxy.addImage("screen", null0_screen)
