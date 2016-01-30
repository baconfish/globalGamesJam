EventService = require './EventService.coffee'
UpdateService = require './UpdateService.coffee'

module.exports = class Player
  constructor: ->
    @_container = new PIXI.Container()
    @_container.interactive = false
    @_container.position.x = 455
    sprite = new PIXI.Sprite PIXI.utils.TextureCache.playernude
    sprite.anchor.x = 0.5
    sprite.scale.x = -1
    @_container.addChild sprite
    @_container.position.y = 104
    target = targetInstance = null
    
    @currentItem = null
    @dressed = false
    @locked = null
    
    @_container.click = -> EventService.trigger 'clicked', {s:'something'}
    
    EventService.on 'proximity', (itemModel, itemInstance) =>
      if itemModel.name is 'dresser' and itemInstance.state is "closed"
        if @dressed
          sprite.texture = PIXI.utils.TextureCache.playernude
          @dressed = false
        else
          sprite.texture = PIXI.utils.TextureCache.player
          @dressed = true
        itemInstance.setState "opened"
        setTimeout (-> itemInstance.setState "closed"), 500
      if itemModel.name is 'lightbulb'
        EventService.trigger 'bubbleBegin', @_container, 'i can\'t reach that'
      if itemModel.name is 'toilet'
        EventService.trigger 'bubbleBegin', itemModel, '**flush**'
      if itemModel.name is 'mirror'
        EventService.trigger 'bubbleBegin', @_container, 'looking good!'
      if itemModel.type is 'lightswitch'
        EventService.trigger 'bubbleBegin', itemModel, '**click**'

        
    EventService.on 'objectClicked', (itemModel, itemInstance) =>
      if @locked isnt null then return
      target = itemModel
      targetInstance = itemInstance
      
    UpdateService.add (time, delta) =>
      if @locked is null
        if kd.H.isDown()
          EventService.trigger 'bubbleBegin', @_container, 'why am i thinking this', 1
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
      else
        if @_container.position.x > @locked + 5
          @_container.position.x -= 5
          sprite.scale.x = -1
          return
        #to the left of player
        if @_container.position.x < @locked - 5
          @_container.position.x += 5
          sprite.scale.x = 1
          return