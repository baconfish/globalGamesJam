EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'

timer = null

module.exports = class BubbleComp
  constructor: ->
    el = document.querySelector '#bubble'

    EventService.on 'bubbleBegin', (player, text, duration) ->
      el.style.visibility = 'visible'
      el.textContent = "#{text}"
      el.style.left = "#{player.position.x+(15*Math.random())}px" 
      el.style.top = "#{player.position.y-(30*Math.random())}px"
      if timer
      	clearTimeout timer
      timer = setTimeout (-> el.style.visibility = 'hidden'), duration or 500
    
    EventService.on 'bubbleEnd', ->
      el.style.visibility = 'hidden'