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
    rituals = new Rituals level, player

    @stage.addChild level._container
    @stage.addChild player._container
    
    interval = ->
        if level.items.alarm.instance.state is 'ringing' then level.items.alarm.instance.setState 'paused'
        else 
          level.items.alarm.instance.setState 'ringing'
          EventService.trigger 'bubbleBegin', level.items.alarm.model, '**ring**'

    UpdateService.add interval, 250
    
    remaining = 60
      
    timerInterval = ->
      remaining--
      if remaining > 0
        document.getElementById "timeRemaining"
          .textContent = remaining
      else
        UpdateService.remove timerInterval
        UpdateService.remove interval
        level.items.alarm.instance.setState "disarmed"
        document
          .getElementById "lose-state"
          .style.display = "block"
        document
          .getElementById "instructions"
          .style.display = "none"
        (document.getElementsByTagName "canvas")[0]
          .style.display = "none"
    
    UpdateService.add timerInterval, 1000

    EventService.on "proximity", (itemModel, itemInstance) => 
      switch 
      
        #LIGHTSWITCH  
        when itemModel.type is 'lightswitch'
          EventService.trigger 'bubbleBegin', itemModel, '**click**'
          
        #FRONT DOOR    
        when itemModel.name is 'frontdoor' then switch
          when not player.dressed then EventService.trigger 'bubbleBegin', player._container, "Being out and about in your underwear is the stuff of nightmares.", 2500
          when level.items.shower.instance.state is "unused" then EventService.trigger 'bubbleBegin', player._container, "I haven't showered!"
          when level.items.fridge.instance.state isnt "closed" then EventService.trigger 'bubbleBegin', player._container, "I don't have my lunch!"
          when level.items.counter.instance.state isnt "used" then EventService.trigger 'bubbleBegin', player._containeritemModel, "I haven't made my lunch!"
          when level.items.bed.instance.state is "unmade" then EventService.trigger 'bubbleBegin', player._container, "My bed's a mess!"
          when rituals.enabled.everythingStraight and level.items.picture.instance.state isnt "straight" then EventService.trigger 'bubbleBegin', player._container, "Wait, is everything straight?"
          when rituals.enabled.ecoWorrier and level.items.tv.instance.state is "on" then EventService.trigger 'bubbleBegin', player._container, "The TV is on!"
          when rituals.enabled.ecoWorrier and level.rooms[0].instance.lit then EventService.trigger 'bubbleBegin', player._container, "The lights are on!"
          when rituals.enabled.ecoWorrier and level.rooms[1].instance.lit then EventService.trigger 'bubbleBegin', player._container, "The lights are on!"
          when rituals.enabled.ecoWorrier and level.rooms[2].instance.lit then EventService.trigger 'bubbleBegin', player._container, "The lights are on!"
          when rituals.enabled.prideful and not player.hairDone then EventService.trigger 'bubbleBegin', player._container, "I couldn't possibly go out with hair like this!", 2000
          when rituals.enabled.goodNeighbour and level.items.alarm.instance.state isnt "disarmed" then EventService.trigger 'bubbleBegin', player._container, "I don't want to disturb my neighbours!", 2000
          when rituals.enabled.regularBM and not level.items.toilet.instance.used then EventService.trigger 'bubbleBegin', player._container, "I need to poop!", 2000
          else
            document
              .getElementById "win-state"
              .style.display = "block"
            document
              .getElementById "instructions"
              .style.display = "none"
            (document.getElementsByTagName "canvas")[0]
              .style.display = "none"
            UpdateService.remove timerInterval
            EventService.trigger "won"
      
        #LIGHTS OUT
        when rituals.enabled.poorNightVision and not (level.getContainingRoomAt itemModel.position.x).instance.lit
          EventService.trigger 'bubbleBegin', player._container, "It's too dark to see!", 1500
          return
        
        #ALARM NUCLEAR
        when itemModel.name is "alarm" and itemInstance.state isnt 'disarmed'
          itemInstance.setState "disarmed"
          UpdateService.remove interval
          EventService.trigger 'bubbleBegin', itemModel, '**disarmed**'
        
        #ALARM DISARMED  
        when itemModel.name is 'alarm'
          EventService.trigger 'bubbleBegin', player._container, 'Evil thing.'
          
        #LIGHTBULB  
        when itemModel.name is 'lightbulb'
          EventService.trigger 'bubbleBegin', player._container, 'I can\'t reach that.'
          
        #TOILET  
        when itemModel.name is 'toilet'
          player.cleanHands = false
          itemInstance.used = true
          EventService.trigger 'bubbleBegin', itemModel, '**flush**'
          
        #SINK  
        when itemModel.type is 'sink'
          player.cleanHands = true
          player.locked = player._container.position.x
          washing = =>
            EventService.trigger 'bubbleBegin', player._container, "**scrub**", 1250

          UpdateService.add washing, 250
          UpdateService.once (-> 
            UpdateService.remove washing
            itemInstance.setState "used"
            EventService.trigger 'bubbleBegin', player._container, "That's better!", 1500
            player.locked = null
          ), 2500
          
        #MIRROR  
        when itemModel.name is 'mirror'
          if (level.getContainingRoomAt itemModel.position.x).instance.lit
            EventService.trigger 'bubbleBegin', player._container, 'Looking good!'
            player.setHairDone true
          else
            EventService.trigger 'bubbleBegin', player._container, 'I can\'t do my hair in the dark!'
        
        #PICTURE CROOKED 
        when itemModel.name is "picture" and itemInstance.state isnt 'straight'
          itemInstance.setState "straight"
          EventService.trigger 'bubbleBegin', itemModel, '**straightened**'
        
        #PICTURE  
        when itemModel.name is "picture"
          EventService.trigger 'bubbleBegin', itemModel, 'Its prettier straight.'
        
        #TV      
        when itemModel.name is "tv"
          if itemInstance.state is "on"
            itemInstance.setState "off"
            EventService.trigger 'bubbleBegin', itemModel, "**szjum**"
          else
            EventService.trigger 'bubbleBegin', player._container, "What was I even watching?", 1500
            
        #DRESSER
        when itemModel.name is 'dresser' and itemInstance.state is "closed"
          EventService.trigger "bubbleBegin", itemModel, "**creak**", 500
          player.setDressed not player.dressed
          itemInstance.setState "opened"
          UpdateService.once (-> itemInstance.setState "closed"), 500
            
        #SHOWER    
        when itemModel.name is "shower"
          if player.dressed
            EventService.trigger 'bubbleBegin', player._container, "I'll ruin my best shirt!", 2000
          else
            if level.items.fridge.instance.state isnt "unopened"
              if level.items.counter.instance.state is "unused"
                EventService.trigger 'bubbleBegin', player._container, "I'll get my ingredients wet!", 2500
              else
                EventService.trigger 'bubbleBegin', player._container, "I'll get my lunch wet!", 2500
            else
              if itemInstance.state is "unused"
                itemInstance.setState "running"
                player.locked = 40
                player.setHairDone false
                player.cleanHands = true
                EventService.trigger 'bubbleBegin', player._container, "Tra la la", 1500
                
                washing = => EventService.trigger 'bubbleBegin', player._container, "**scrub**", 2500
                UpdateService.add washing, 250
                UpdateService.once (-> 
                    UpdateService.remove washing
                    itemInstance.setState "used"
                    EventService.trigger 'bubbleBegin', player._container, "That's better!", 1500
                    player.locked = null
                  ), 2500
              else
                EventService.trigger 'bubbleBegin', player._container, "One shower is enough.", 1500
        
        #SOFA      
        when itemModel.name is "sofa"
          if player.dressed
            EventService.trigger 'bubbleBegin', player._container, "Re-runs AFTER work!", 1500
          else
            EventService.trigger 'bubbleBegin', player._container, "This is not the time to watch re-runs in my underwear!", 2500
        
        #FRIDGE    
        when itemModel.name is "fridge" 
          player.locked = player._container.position.x
          switch itemInstance.state
            when "unopened"
              if player.dressed
                if level.items.counter.instance.state is "unused"
                  EventService.trigger "bubbleBegin", player._container, "I need this to make my lunch.", 1500
                else
                  EventService.trigger "bubbleBegin", player._container, "That's my lunch!  Mmm.", 1500
              else
                if level.items.counter.instance.state is "unused"
                  EventService.trigger "bubbleBegin", player._container, "I need this to make my lunch. I also need to dress; it's cold!", 2500
                else
                  EventService.trigger "bubbleBegin", player._container, "That's my lunch.  It's freezing, I need to get dressed!", 2500
              itemInstance.setState "opened"
              UpdateService.once (-> 
                  itemInstance.setState "closed"
                  player.locked = null
                  EventService.trigger "bubbleBegin", itemModel, "**slam**", 500
                ), 1000
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
              UpdateService.once (-> 
                  itemInstance.setState "unopened"
                  player.locked = null
                  EventService.trigger "bubbleBegin", itemModel, "**slam**", 500
                ), 1000
        
        #COUNTER    
        when itemModel.name is "counter" then switch itemInstance.state
          when "unused"
            if not player.cleanHands
              EventService.trigger 'bubbleBegin', player._container, "I should wash my hands first.", 2500
              return
            if level.items.fridge.instance.state is "closed"
              player.locked = player._container.position.x
              itemInstance.setState "running"
              EventService.trigger 'bubbleBegin', itemModel, "**slice**", 2500
              chopping = =>
                  EventService.trigger 'bubbleBegin', itemModel, "**chop**", 2500
              UpdateService.add chopping, 250
              UpdateService.once (-> 
                  UpdateService.remove chopping
                  itemInstance.setState "used"
                  player.locked = null
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