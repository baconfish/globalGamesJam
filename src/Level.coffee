Item = require './Item.coffee'
itemModels = require './Level.json'
RoomOverlay = require "./RoomOverlay.coffee"

module.exports = class Level
  constructor: ->
    @_container = new PIXI.Container()
    
    @rooms = []
    
    for roomModel in itemModels.rooms
      r = new RoomOverlay roomModel
      @_container.addChild r._container      
      @rooms.push 
        model: roomModel
        instance: r
      
    @getContainingRoomAt = (x) ->
      for obj in @rooms
        if x < obj.model.x then continue
        if x > obj.model.x + obj.model.width then continue
        return obj
      null
    
    @items = {}
    for item in itemModels.items
      i = new Item item, this
      @_container.addChild i._container
      @items[item.name] = 
        model: item
        instance: i