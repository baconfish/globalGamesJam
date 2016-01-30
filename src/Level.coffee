Item = require './Item.coffee'
itemModels = require './Level.json'

module.exports = class Level
  constructor: ->
    @_container = new PIXI.Container()
    sprite = new PIXI.Sprite PIXI.utils.TextureCache.level
    @_container.addChild sprite
    
    items = []
    
    for item in itemModels.items
      i = new Item item
      @_container.addChild i._container
      items.push i