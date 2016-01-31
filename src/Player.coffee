EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'

module.exports = class Player
  constructor: ->
    @_container = new PIXI.Container()
    @_container.interactive = false
    @_container.position.x = 455
    
    headTidy = new PIXI.Texture PIXI.utils.TextureCache.player.baseTexture, new PIXI.Rectangle 0, 0, 72, 40
    headMessy = new PIXI.Texture PIXI.utils.TextureCache.playernude.baseTexture, new PIXI.Rectangle 0, 0, 72, 40
    bodyDressed = new PIXI.Texture PIXI.utils.TextureCache.player.baseTexture, new PIXI.Rectangle 0, 40, 72, 112
    bodyNude = new PIXI.Texture PIXI.utils.TextureCache.playernude.baseTexture, new PIXI.Rectangle 0, 40, 72, 112
    
    bodySprite = new PIXI.Sprite bodyNude
    bodySprite.anchor.x = 0.5
    bodySprite.scale.x = -1
    bodySprite.position.y = 40
    @_container.addChild bodySprite
    
    headSprite = new PIXI.Sprite headMessy
    headSprite.anchor.x = 0.5
    headSprite.scale.x = -1
    @_container.addChild headSprite
    
    @hairDone = false
    @setHairDone = (yep) ->
      headSprite.texture = if yep then headTidy else headMessy
      @hairDone = yep
    
    @_container.position.y = 104
    target = targetInstance = null
    
    @currentItem = null
    @dressed = false
    @locked = null
    
    @_container.click = -> EventService.trigger 'clicked', {s:'something'}
    
    @setDressed = (dressed) ->
      @dressed = dressed
      if not @dressed
        bodySprite.texture = bodyNude
      else
        bodySprite.texture = bodyDressed
        
    EventService.on 'objectClicked', (itemModel, itemInstance) =>
      if @locked isnt null then return
      target = itemModel
      targetInstance = itemInstance
      
    UpdateService.add (time, delta) =>
      if @locked is null
        if kd.H.isDown()
          EventService.trigger 'bubbleBegin', @_container, 'why am i thinking this', 1
        if kd.D.isDown()
          if @_container.position.x + 5 < 1440
            @_container.position.x += 5
          bodySprite.scale.x = 1
          headSprite.scale.x = 1
          target = null
          return
        if kd.A.isDown()
          if @_container.position.x - 5 > 0
            @_container.position.x -= 5
          bodySprite.scale.x = -1
          headSprite.scale.x = -1
          target = null
          return
        if not target then return
        #to the right of player
        if @_container.position.x > target.position.x+target.width
          @_container.position.x -= 5
          bodySprite.scale.x = -1
          headSprite.scale.x = -1
          return
        #to the left of player
        if @_container.position.x < target.position.x
          @_container.position.x += 5
          bodySprite.scale.x = 1
          headSprite.scale.x = 1
          return
        EventService.trigger 'proximity', target, targetInstance
        target = null
      else
        if @_container.position.x > @locked + 5
          @_container.position.x -= 5
          bodySprite.scale.x = -1
          headSprite.scale.x = -1
          return
        #to the left of player
        if @_container.position.x < @locked - 5
          @_container.position.x += 5
          bodySprite.scale.x = 1
          headSprite.scale.x = 1
          return