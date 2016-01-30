EventService = require './EventService.coffee'

module.exports = class Item
  constructor: (itemModel) ->
    @_container = new PIXI.Container()
    # raw gfx drawing
    gfx = new PIXI.Graphics()
    gfx.beginFill 0xFF0000
    gfx.drawRect itemModel.position.x, itemModel.position.y, itemModel.width, itemModel.height
    gfx.endFill()
    gfx.alpha = 0.0
    @_container.addChild gfx
    
    @setState = undefined
    
    if itemModel.states
      overlaySprite = new PIXI.Sprite()
      @_container.addChild overlaySprite
      
      stateTextures = {}
      for key, value of itemModel.states
        if not value then continue
        stateTextures[key] = new PIXI.Texture PIXI.utils.TextureCache.levelBright2.baseTexture, (new PIXI.Rectangle value.x, value.y, value.width, value.height)
      @setState = (name) -> 
        @state = name
        value = itemModel.states[name]
        tex = stateTextures[name]
        if tex
          overlaySprite.texture = tex
          overlaySprite.position.x = value.x
          overlaySprite.position.y = value.y
          overlaySprite.width = tex.width
          overlaySprite.height = tex.height
          overlaySprite.visible = true
        else
          overlaySprite.visible = false
      @setState itemModel.defaultState
        
    else
      @setState = (name) -> 
        @state = name 
    
    @_container.interactive = true
    @_container.click = =>
      EventService.trigger 'objectClicked', itemModel, this
    @_container.tap = =>
      EventService.trigger 'objectClicked', itemModel, this
    
    @_container.mouseover = -> EventService.trigger 'mouseOver', itemModel
    
    @_container.mouseout = -> EventService.trigger 'mouseOut'