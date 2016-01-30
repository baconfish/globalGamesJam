Item = require './Item.coffee'
itemModels = require './Level.json'
RoomOverlay = require "./RoomOverlay.coffee"

module.exports = class Level
  constructor: ->
    @_container = new PIXI.Container()
    
    for roomModel in itemModels.rooms
      r = new RoomOverlay roomModel
      @_container.addChild r._container      
    
    items = []
    
    for item in itemModels.items
      i = new Item item
      @_container.addChild i._container
      items.push i