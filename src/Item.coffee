EventService = require './EventService.coffee'

module.exports = class Item
  constructor: (itemModel) ->
    @_container = new PIXI.Container()
    @_container.position.set itemModel.position.x, itemModel.position.y
    @_container.width = itemModel.width
    @_container.height = itemModel.height
    # raw gfx drawing
    gfx = new PIXI.Graphics()
    gfx.beginFill 0xFF0000
    gfx.drawRect 0, 0, itemModel.width, itemModel.height
    gfx.endFill()
    gfx.alpha = 0.0
    @_container.addChild gfx
    
    @_container.interactive = true
    @_container.click = ->
      EventService.trigger 'objectClicked', itemModel
      console.log "You clicked: #{itemModel.name}."
    
    @_container.mouseover = -> EventService.trigger 'mouseOver', itemModel
    
    @_container.mouseout = -> EventService.trigger 'mouseOut'