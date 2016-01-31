UpdateService = require './UpdateService.coffee'
EventService = require './EventService.coffee'
Level = require './Level.coffee'
Player = require './Player.coffee'
RoomOverlay = require './RoomOverlay.coffee'
Rituals = require "./Rituals.coffee"

data = require './Level.json'

interval = null

EventService.on 'clicked', (s) -> console.log s

module.exports = class Game
  constructor: ->
    @stage = new PIXI.Container()
    player = new Player()
    level = new Level()
    rituals = new Rituals()

    @stage.addChild level._container
    @stage.addChild player._container
    
    interval = setInterval (->
        if level.items.alarm.instance.state is 'ringing' then level.items.alarm.instance.setState 'paused'
        else 
          level.items.alarm.instance.setState 'ringing'
          EventService.trigger 'bubbleBegin', level.items.alarm.model, '**ring**'
      ), 250
      
    remaining = 60
      
    timerInterval = setInterval (->
      remaining--
      if remaining > 0
        document.getElementById "timeRemaining"
          .textContent = remaining
      else
        clearInterval timerInterval
        document
          .getElementById "lose-state"
          .style.display = "block"
        document
          .getElementById "instructions"
          .style.display = "none"
        (document.getElementsByTagName "canvas")[0]
          .style.display = "none"
    ), 1000
    
    EventService.on "proximity", (itemModel, itemInstance) => switch 
        #ALARM NUCLEAR
        when itemModel.name is "alarm" and itemInstance.state isnt 'disarmed'
          itemInstance.setState "disarmed"
          clearInterval interval
          EventService.trigger 'bubbleBegin', itemModel, '**disarmed**'
        
        #ALARM DISARMED  
        when itemModel.name is 'alarm'
          EventService.trigger 'bubbleBegin', player._container, 'evil thing'
        
        #PICTURE  
        when itemModel.name is "picture" and itemInstance.state isnt 'straight'
          itemInstance.setState "straight"
          EventService.trigger 'bubbleBegin', itemModel, '**straightened**'
        
        #TV      
        when itemModel.name is "tv"
          if itemInstance.state is "on"
            itemInstance.setState "off"
            EventService.trigger 'bubbleBegin', itemModel, "*szjum*"
          else
            EventService.trigger 'bubbleBegin', player._container, "What was I even watching?", 1500
            
        #SHOWER    
        when itemModel.name is "shower"
          if player.dressed
            EventService.trigger 'bubbleBegin', player._container, "I'll ruin my best shirt!", 2000
          else
            console.log level.items.fridge.instance.state
            if level.items.fridge.instance.state isnt "unopened"
              if level.items.counter.instance.state is "unused"
                EventService.trigger 'bubbleBegin', player._container, "I'll get my ingredients wet!", 2500
              else
                EventService.trigger 'bubbleBegin', player._container, "I'll get my lunch wet!", 2500
            else
              if itemInstance.state is "unused"
                itemInstance.setState "running"
                player.locked = 40
                EventService.trigger 'bubbleBegin', player._container, "Tra la la", 1500
                
                washing = setInterval (=>
                  EventService.trigger 'bubbleBegin', player._container, "**scrub**", 2500
                  ), 250
                setTimeout (-> 
                    clearInterval washing
                    itemInstance.setState "used"
                    EventService.trigger 'bubbleBegin', player._container, "That's better!", 1500
                    player.locked = null
                  ), 2500
              else
                EventService.trigger 'bubbleBegin', player._container, "One shower is enough.", 1500
        
        #SOFA      
        when itemModel.name is "sofa"
          if player.dressed
            EventService.trigger 'bubbleBegin', player._container, "Reruns AFTER work!", 1500
          else
            EventService.trigger 'bubbleBegin', player._container, "This is not the time to watch reruns in my underwear!", 2500
        
        #FRIDGE    
        when itemModel.name is "fridge" then switch itemInstance.state
          when "unopened"
            if player.dressed
              if level.items.counter.instance.state is "unused"
                EventService.trigger "bubbleBegin", player._container, "I need this to make my lunch.", 1500
              else
                EventService.trigger "bubbleBegin", player._container, "That's my lunch!  Mmm.", 1500
            else
              if level.items.counter.instance.state is "unused"
                EventService.trigger "bubbleBegin", player._container, "I need this to make my lunch.  I also need to dress; it's cold!", 2500
              else
                EventService.trigger "bubbleBegin", player._container, "That's my lunch.  It's freezing, I need to get dressed!", 2500
            itemInstance.setState "opened"
            setInterval (-> itemInstance.setState "closed"), 1000
          when "closed"
            if player.dressed
              if level.items.counter.instance.state is "unused"
                EventService.trigger "bubbleBegin", player._container, "Putting these ingredients back.", 1500
              else
                EventService.trigger "bubbleBegin", player._container, "Putting my lunch away.", 1500
            else
              if level.items.counter.instance.state is "unused"
                EventService.trigger "bubbleBegin", player._container, "Putting these ingredients back.  Also really cold.", 2500
              else
                EventService.trigger "bubbleBegin", player._container, "Putting my lunch away.  Also really cold.", 2500
            itemInstance.setState "opened"
            setInterval (-> itemInstance.setState "unopened"), 1000
        
        #COUNTER    
        when itemModel.name is "counter" then switch itemInstance.state
          when "unused"
            if level.items.fridge.instance.state is "closed"
              itemInstance.setState "running"
              EventService.trigger 'bubbleBegin', itemModel, "**slice**", 2500
              chopping = setInterval (=>
                  EventService.trigger 'bubbleBegin', itemModel, "**chop**", 2500
                ), 250
              setTimeout (-> 
                  clearInterval chopping
                  itemInstance.setState "used"
                  EventService.trigger 'bubbleBegin', player._container, "I now have my lunch.  And what a lunch it is.", 2500
              ), 2500
            else
              EventService.trigger "bubbleBegin", player._container, "I need some ingredients to make my lunch.", 2000
          when "used"
            EventService.trigger "bubbleBegin", player._container, "I've already made my lunch.", 1500
        
        #BED
        when itemModel.name is "bed"
          if itemInstance.state is "unmade"
            itemInstance.setState "made"
            EventService.trigger 'bubbleBegin', player._container, "Smooth as my moves.", 1500
          else
            EventService.trigger 'bubbleBegin', itemModel, "No jumping on it today.", 2500
        
        #FRONT DOOR    
        when itemModel.name is 'frontdoor' then switch
          when not player.dressed then EventService.trigger 'bubbleBegin', player._container, "Being out and about in your underwear is the stuff of nightmares.", 2500
          when level.items.shower.instance.state is "unused" then EventService.trigger 'bubbleBegin', player._container, "I haven't showered!"
          when level.items.fridge.instance.state isnt "closed" then EventService.trigger 'bubbleBegin', player._container, "I don't have my lunch!"
          when level.items.counter.instance.state isnt "used" then EventService.trigger 'bubbleBegin', player._containeritemModel, "I haven't made my lunch!"
          when level.items.bed.instance.state is "unmade" then EventService.trigger 'bubbleBegin', player._container, "My bed's a mess!"
          else
            document
              .getElementById "win-state"
              .style.display = "block"
            document
              .getElementById "instructions"
              .style.display = "none"
            (document.getElementsByTagName "canvas")[0]
              .style.display = "none"
            clearInterval timerInterval