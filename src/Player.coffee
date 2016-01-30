EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'

module.exports = class Player
  constructor: ->
    @_container = new PIXI.Container()
    @_container.interactive = false
    @_container.position.x = 0
    sprite = new PIXI.Sprite PIXI.utils.TextureCache.playernude
    sprite.anchor.x = 0.5
    @_container.addChild sprite
    @_container.position.y = 104
    target = targetInstance = null
    @_container.click = -> EventService.trigger 'clicked', {s:'something'}
    
    EventService.on 'proximity', (itemModel, itemInstance) ->
      if itemModel.name is 'dresser'
        sprite.texture = PIXI.utils.TextureCache.player
        itemInstance.setState "closed"
        
    EventService.on 'objectClicked', (itemModel, itemInstance) ->
      target = itemModel
      targetInstance = itemInstance
      
    UpdateService.add (time, delta) =>
      if kd.D.isDown()
        @_container.position.x += 5
        sprite.scale.x = 1
        target = null
        return
      if kd.A.isDown()
        @_container.position.x -= 5
        sprite.scale.x = -1
        target = null
        return
      if not target then return
      #to the right of player
      if @_container.position.x > target.position.x+target.width
        @_container.position.x -= 5
        sprite.scale.x = -1
        return
      #to the left of player
      if @_container.position.x < target.position.x
        @_container.position.x += 5
        sprite.scale.x = 1
        return
      EventService.trigger 'proximity', target, targetInstance
      target = null
      
        
