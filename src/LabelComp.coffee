EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'


module.exports = class LabelComp
  constructor: ->
    el = document.querySelector '#label'

    EventService.on 'mouseOver', (itemModel) ->
      el.style.visibility = 'visible'
      el.textContent = "#{itemModel.name}\n#{itemModel.flavour}"
    
    EventService.on 'mouseOut', ->
      el.style.visibility = 'hidden'

    document.addEventListener 'mousemove', (data) ->
      el.style.left = "#{data.clientX}px" 
      el.style.top = "#{data.clientY-45}px"