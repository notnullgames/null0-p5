import boxy
import wasm3
import wasm3/wasm3c
import ../physfs

var current_boxy: Boxy

proc readImagePhysfs(filePath: string):Image =
  return decodeImage(readFilePhysfs(filePath))

proc null0_setup_imports_graphics*(module: PModule, debug: bool, bxy: Boxy) =
  current_boxy = bxy