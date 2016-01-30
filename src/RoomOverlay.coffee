EventService = require './EventService.coffee'

module.exports = class RoomOverlay
  OFFALPHA = 0.8
  constructor: (@roomModel) ->
    @_container = new PIXI.Container()
    @_container.position.x = @roomModel.x
    gfx = new PIXI.Graphics()
    gfx.beginFill 0x000000
    gfx.drawRect 0, 0, @roomModel.width, 256
    gfx.endFill()
    gfx.alpha = OFFALPHA
    @_container.addChild gfx
    
    EventService.on 'objectClicked', (itemModel) =>
      if itemModel.name is @roomModel.switch
        gfx.alpha = if gfx.alpha is OFFALPHA then 0 else OFFALPHA