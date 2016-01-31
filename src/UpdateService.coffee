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
    toAdd.push {fn, timer, origTimer:timer, once:false}
    return
  once: (fn, timer) -> 
    timer ?= 0
    toAdd.push {fn, timer, origTimer:timer, once:true}
    return
  remove: (fn) ->
    toRemove.push fn
    return
  update: (time) ->
    updatables = updatables.concat toAdd
    toAdd = []
    
    if toRemove.length > 0
      for remover in toRemove
        found = false
        for u, index in updatables
          if u.fn is remover
            updatables.splice index, 1
            found = true
            break
      toRemove = []
        
    delta = time - oldTime
    oldTime = time
    return if paused
    for updatable in updatables
      updatable.timer -= delta
      if updatable.timer < 0
        updatable.timer = updatable.origTimer
        if (toRemove.indexOf updatable.fn) is -1 then updatable.fn(time, delta)
        if updatable.once then UpdateService.remove updatable.fn
    return

module.exports = UpdateService