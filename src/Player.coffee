UpdateService = require './UpdateService.coffee'
EventService = require './EventService.coffee'
InteractionManager = require './InteractionManager.coffee'

module.exports = class Player
  constructor: ->
    @_container = new PIXI.Container()
    @_container.interactive = true
    @_container.position.x = 550
    sprite = new PIXI.Sprite PIXI.utils.TextureCache.playernude
    sprite.anchor.x = 0.5
    @_container.addChild sprite
    @_container.position.y = 104
    @_container.click = -> EventService.trigger 'clicked', {s:'something'}
    EventService.on 'objectClicked', (itemModel) ->
      if itemModel.name is 'dresser'
        sprite.texture = PIXI.utils.TextureCache.player
    
    UpdateService.add (time, delta) =>
      if kd.D.isDown()
        sprite.position.x += 5
        sprite.scale.x = 1
      if kd.A.isDown()
        sprite.position.x -= 5
        sprite.scale.x = -1