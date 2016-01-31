EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'

timer = null

module.exports = class BubbleComp
  constructor: ->
    container = document.querySelector '#bubbleContainer'
    bubble = document.querySelector '#bubble'

    EventService.on 'bubbleBegin', (player, text, duration) ->
      container.style.visibility = 'visible'
      bubble.textContent = "#{text}"
      container.style.left = "#{player.position.x+(10*Math.random()-(20*Math.random()))}px" 
      container.style.top = "#{player.position.y+(10*Math.random())-(20*Math.random())}px"
      if timer
      	UpdateService.remove timer
      timer = -> 
        container.style.visibility = 'hidden'
      UpdateService.once timer, duration or 500
    
    EventService.on 'bubbleEnd', ->
      container.style.visibility = 'hidden'
      if timer
      	UpdateService.remove timer