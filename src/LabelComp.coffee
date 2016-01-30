EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'


module.exports = class LabelComp
  constructor: ->
    el = document.querySelector '#label'
    title = document.querySelector '#title'
    flavour = document.querySelector '#flavour'
    
    currentItem = null

    EventService.on 'mouseOver', (itemModel) ->
      currentItem = itemModel
      el.style.visibility = 'visible'
      title.textContent = "#{itemModel.name}"
      flavour.textContent = "#{itemModel.flavour}"
    
    EventService.on 'mouseOut', (itemModel) ->
      if itemModel is currentItem
        el.style.visibility = 'hidden'
        currentItem = null

    document.addEventListener 'mousemove', (data) ->
      if currentItem?
        el.style.left = "#{data.clientX}px" 
        el.style.top = "#{data.clientY-45}px"