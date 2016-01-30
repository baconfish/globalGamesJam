events = {}
EventService =
  on: (evnt, fn) ->
    if typeof(evnt) isnt 'string' then return console.warning 'Event must be a string.'
    if not events[evnt]? then events[evnt] = []
    events[evnt].push fn
  off: (event, fn) ->
    events[event].splice events[event].indexOf(fn), 1
  trigger: (evnt, data) ->
    if events[evnt]
      e(data) for e in events[evnt]
    
module.exports = EventService