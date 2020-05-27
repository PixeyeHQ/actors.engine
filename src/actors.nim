{.used.}

import actors/a_engine as engine
import actors/a_runtime as runtime

export engine
export runtime


template start*(this: App, code: untyped): untyped =
  this.start()
  code

proc start*(this: App) {.inline.} =
  engine.platform.start(this.settings.display_size, this.settings.name)


template run*(this: App, code: untyped): untyped =
  var dt {.inject, used.} = 1/this.settings.fps
  var input {.inject, used.} = app.input
  while not engine.platform.shouldQuit():
    ecs.process_operations(lr_ecs_core.int)
    ecs.process_operations()
    code
    engine.platform.updateImpl()
  engine.platform.dispose()

template close*(this: App, code: untyped): untyped =
  code

proc quit*(this: App) =
  engine.platform.release()


#@logs
import parsecfg
from os import fileExists

logSetMask {debug..benchmark}

const have_settings = fileExists("settings.ini")
 
if have_settings:
  var config = loadConfig("settings.ini") 
  log_add config.getSectionValue("log","name")
 
