UpdateService = require './UpdateService.coffee'
EventService = require './EventService.coffee'
map = require "./map.coffee"
Level = require './Level.coffee'
Player = require './Player.coffee'
RoomOverlay = require './RoomOverlay.coffee'

data = require './Level.json'

EventService.on 'clicked', (s) -> console.log s

module.exports = class Game
  constructor: ->
    @stage = new PIXI.Container()
    player = new Player()
    level = new Level()

    @stage.addChild level._container
    @stage.addChild player._container
    
    EventService.on "proximity", (itemModel, itemInstance) => switch itemModel.name
        when "alarm" then itemInstance.setState "disarmed"
        when "picture" then itemInstance.setState "straight"