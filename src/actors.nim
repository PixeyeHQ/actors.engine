## Created by Pixeye | dev@pixeye.com
##
## The game engine.

{.used.}
{.experimental: "codeReordering".}

import actors/actors_plugins as plugins
import actors/actors_h       
import actors/actors_tools   as tools
import actors/actors_engine  as engine

export tools
export engine
export plugins
export actors_h.LayerId
export actors_h.AppTime

let app* = actors_h.app

proc quit*(self: App) =
  engine.target.release()

proc sleep*(app: App, t: float) =
  var timeCurrent = engine.getTime()
  while timeCurrent - app.time.last < t:
    sleep(0)
    timeCurrent = engine.getTime()

proc metricsBegin()=
  let timer = app.time #ref
  timer.counter.frames += 1
  timer.frames += 1

proc metricsEnd()=
  let timer = app.time #ref
  let counter = app.time.counter.addr #pointer
  if engine.getTime() - timer.seconds > 1.0:
    timer.seconds += 1
    counter.updates_last = counter.updates
    counter.frames_last = counter.frames
    counter.updates = 0
    counter.frames  = 0

proc renderBegin()=
  engine.target.renderBegin()
proc renderEnd() =
  engine.target.renderEnd()
  if app.meta.vsync == 0:
    app.sleep(1/app.meta.fps)

template fixedUpdate(code: untyped): untyped =
    let ms_per_update = MS_PER_UPDATE()
    let timer = app.time #ref
    let timeCurrent = engine.getTime()
    let tdelta = timeCurrent - timer.last
    timer.dt = tdelta
    timer.last = timeCurrent
    timer.lag += tdelta
    while timer.lag >= ms_per_update:
      code
      timer.lag -= ms_per_update
      timer.counter.updates += 1

proc run*(app: App, init: proc(), update: proc(), draw: proc()) =
  var w = engine.target.bootstrap(app)
  let context {.used.} = igCreateContext()
  assert igGlfwInitForOpenGL(w, true)
  assert igOpenGL3Init()
  igStyleColorsCherry()

  init()
  
  while not engine.target.shouldQuit():
    
    metricsBegin()
    engine.target.pollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    fixedUpdate:
      update()

    renderBegin()
    #plugins.render_begin()
    
    draw()
    igRender()

    #plugins.flush()
    igOpenGL3RenderDrawData(igGetDrawData())
    renderEnd()
    #engine.target.render_end()
    
    metricsEnd()
  #plugins.kill()
  engine.target.kill()
    
#plugins.imgui.kill()
#in_engine.target.kill()

#var frame* : int

# proc run*(app: App,init: proc(), update: proc(), draw: proc()) =
#   engine.target.start(app.settings.display_size, app.settings.name)
#   app.time.lag  = 0
#   app.time.last = app.time.current
#   app.vsync(app.settings.vsync)
 
#   #var ms_update = 0f
#   #var ms_render = 0f

#   init()

#   while not engine.target.shouldQuit():
#     app.time.frames += 1
#     app.time.counter.frames += 1
#     frame += 1
#     engine.target.pollEvents()
    
#     #clampUpdate():
#     #  update()
    
#     #igOpenGL3NewFrame()
#     plugins.imgui.renderer_begin()
    
#     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
#     if app.settings.vsync == 1:
#       glClearColor(0.2f, 0.3f, 0.3f, 1.0f)
#     else:
#       glClearColor(0.2f, 0.4f, 0.3f, 1.0f)


#     draw()
    
#     plugins.imgui.flush()
#     renderer_end()
    
#     # echo "msu: ", ms_update
#     # echo "msr: ", ms_render
  
#   plugins.imgui.dispose()
#   engine.target.dispose()



# proc quit*(this: App) =
#   engine.target.release()

# proc sleep*(app: App, t: float) =
#   var time_current = app.getTime()
#   while time_current - app.time.last < t:
#     sleep(0)
#     time_current = app.getTime()

# template renderer_end(): untyped =
#   engine.target.render_end(app.settings.vsync)
#   if app.settings.vsync == 0:
#     app.sleep(1/app.settings.fps)
