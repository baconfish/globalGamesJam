paused = false

updatables = []
oldTime = 0
toRemove = []
toAdd = []
EventService = require './EventService.coffee'

EventService.on 'pause', (state) ->
  paused = not paused
  
UpdateService =
  add: (fn, timer) ->
    timer ?= 0
    toAdd.push {fn, timer, origTimer:timer}
    return
  remove: (fn) ->
    toRemove.push fn
    return
  update: (time) ->
    updatables = updatables.concat toAdd
    if toRemove.length > 0
      for remover in toRemove
        for u, index in updatables
          if u.fn is remover
            updatables.splice index, 1
            break
      toRemove = []
    toAdd = []
        
    delta = time - oldTime
    oldTime = time
    return if paused
    for updatable in updatables
      updatable.timer -= delta
      if updatable.timer < 0
        updatable.timer = updatable.origTimer
        updatable.fn(time, delta)
    return

module.exports = UpdateService