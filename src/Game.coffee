UpdateService = require './UpdateService.coffee'
EventService = require './EventService.coffee'
Level = require './Level.coffee'
Player = require './Player.coffee'
RoomOverlay = require './RoomOverlay.coffee'

data = require './Level.json'

interval = null

EventService.on 'clicked', (s) -> console.log s

module.exports = class Game
  constructor: ->
    @stage = new PIXI.Container()
    player = new Player()
    level = new Level()

    @stage.addChild level._container
    @stage.addChild player._container
    
    interval = setInterval (->
        if level.items.alarm.instance.state is 'ringing' then level.items.alarm.instance.setState 'paused'
        else 
          level.items.alarm.instance.setState 'ringing'
          EventService.trigger 'bubbleBegin', level.items.alarm.model, '**ring**'
      ), 250
    
    EventService.on "proximity", (itemModel, itemInstance) => switch 
        when itemModel.name is "alarm" and itemInstance.state isnt 'disarmed'
          itemInstance.setState "disarmed"
          clearInterval interval
          EventService.trigger 'bubbleBegin', itemModel, '**disarmed**'
        when itemModel.name is "picture" and itemInstance.state isnt 'straight'
          itemInstance.setState "straight"
          EventService.trigger 'bubbleBegin', itemModel, '**straightened**'
        when itemModel.name is "tv"
          if itemInstance.state is "on"
            itemInstance.setState "off"
            EventService.trigger 'bubbleBegin', itemModel, "*szjum*"
          else
            EventService.trigger 'bubbleBegin', itemModel, "What was I even watching?", 1500
        when itemModel.name is "shower"
          if player.dressed
            EventService.trigger 'bubbleBegin', itemModel, "I'll ruin my best shirt!", 2000
          else
            if itemInstance.state is "unused"
              itemInstance.setState "running"
              player.locked = 40
              EventService.trigger 'bubbleBegin', itemModel, "Tra la la", 1500
              
              washing = setInterval (=>
                EventService.trigger 'bubbleBegin', itemModel, "**scrub**", 2500
                ), 250
              setTimeout (-> 
                  clearInterval washing
                  itemInstance.setState "used"
                  EventService.trigger 'bubbleBegin', itemModel, "That's better!", 1500
                  player.locked = null
                ), 2500
            else
              EventService.trigger 'bubbleBegin', itemModel, "One shower is enough.", 1500
        when itemModel.name is "sofa"
          if player.dressed
            EventService.trigger 'bubbleBegin', itemModel, "Reruns AFTER work!", 1500
          else
            EventService.trigger 'bubbleBegin', itemModel, "This is not the time to watch reruns in my underwear!", 2500
        when itemModel.name is "fridge" then switch itemInstance.state
          when "unopened"
            if player.dressed
              EventService.trigger "bubbleBegin", itemModel, "Mmm!  Lunch.", 1500
            else
              EventService.trigger "bubbleBegin", itemModel, "That's my lunch.  It's freezing, I need to get dressed!", 2500
            itemInstance.setState "opened"
            setInterval (-> itemInstance.setState "closed"), 500
          else EventService.trigger "bubbleBegin", itemModel, "Need to defrost that soon.", 1500
        when itemModel.name is "bed"
          if itemInstance.state is "unmade"
            itemInstance.setState "made"
            EventService.trigger 'bubbleBegin', player._container, "Smooth as my moves.", 1500
          else
            EventService.trigger 'bubbleBegin', itemModel, "No jumping on it today.", 2500
        when itemModel.name is 'frontdoor' then switch
          when not player.dressed then EventService.trigger 'bubbleBegin', itemModel, "Being out and about in your underwear is the stuff of nightmares.", 2500
          when level.items.shower.instance.state is "unused" then EventService.trigger 'bubbleBegin', itemModel, "I haven't showered!"
          when level.items.fridge.instance.state is "unopened" then EventService.trigger 'bubbleBegin', itemModel, "I don't have my lunch!"
          when level.items.bed.instance.state is "unmade" then EventService.trigger 'bubbleBegin', itemModel, "My bed's a mess!"
          else
            document
              .getElementById "win-state"
              .style.display = "block"
            (document.getElementsByTagName "canvas")[0]
              .style.display = "none"