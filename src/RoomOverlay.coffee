EventService = require './EventService.coffee'

module.exports = class RoomOverlay
  OFFALPHA = 0.8
  constructor: (@roomModel) ->
    @_container = new PIXI.Container()
    sprite = new PIXI.Sprite PIXI.utils.TextureCache.levelDark
    
    mask = new PIXI.Graphics()
    mask.beginFill 0x000000
    mask.drawRect @roomModel.x, 0, @roomModel.width, sprite.height
    mask.endFill()
  
    sprite.mask = mask
    @_container.addChild mask
    @_container.addChild sprite
    
    @lit = false
    
    EventService.on 'proximity', (itemModel) =>
      if itemModel.name is @roomModel.switch
        sprite.texture = if @lit then PIXI.utils.TextureCache.levelDark else PIXI.utils.TextureCache.levelBright
        @lit = not @lit
        EventService.trigger "lightSwitched"