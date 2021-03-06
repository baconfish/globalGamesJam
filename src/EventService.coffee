events = {}
EventService =
  on: (evnt, fn) ->
    if typeof(evnt) isnt 'string' then return console.warning 'Event must be a string.'
    if not events[evnt]? then events[evnt] = []
    events[evnt].push fn
  off: (event, fn) ->
    events[event].splice events[event].indexOf(fn), 1
  trigger: (evnt) ->
    if events[evnt]
      #if data.position.x - Player.position.x < 25 and data.position.x - Player.position.x > -data.width-25
      argscopy = (arg for arg in arguments)
      argscopy.shift()
      e.apply this, argscopy for e in events[evnt]
    
module.exports = EventService