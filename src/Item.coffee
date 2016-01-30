EventService = require './EventService.coffee'

module.exports = class Item
  constructor: (itemModel, levelInstance) ->
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
        stateTextures[key] = 
          bright: new PIXI.Texture PIXI.utils.TextureCache.levelBright2.baseTexture, (new PIXI.Rectangle value.x, value.y, value.width, value.height)
          dark: new PIXI.Texture PIXI.utils.TextureCache.levelDark2.baseTexture, (new PIXI.Rectangle value.x, value.y, value.width, value.height)
      @setState = (name) -> 
        @state = name
        value = itemModel.states[name]
        tex = stateTextures[name]
        if tex
          lit = levelInstance.getContainingRoomAt itemModel.position.x
            .instance
            .lit
          overlaySprite.texture = if lit then tex.bright else tex.dark
          overlaySprite.position.x = value.x
          overlaySprite.position.y = value.y
          overlaySprite.width = overlaySprite.texture.width
          overlaySprite.height = overlaySprite.texture.height
          overlaySprite.visible = true
        else
          overlaySprite.visible = false
      @setState itemModel.defaultState
      EventService.on "lightSwitched", =>
        @setState @state
        
    else
      @setState = (name) -> 
        @state = name 
    
    @_container.interactive = true
    @_container.click = =>
      EventService.trigger 'objectClicked', itemModel, this
    @_container.tap = =>
      EventService.trigger 'objectClicked', itemModel, this
    
    @_container.mouseover = -> EventService.trigger 'mouseOver', itemModel
    
    @_container.mouseout = -> EventService.trigger 'mouseOut', itemModel