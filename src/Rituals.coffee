EventService = require "./EventService.coffee"

module.exports = class Rituals
	constructor: (level, player) ->
		@enabled = {}
		
		types = 
			poorNightVision:
				text: "You're scared of the dark."
				install: ->
			everythingStraight:
				text: "You're something of a neat freak."
				install: ->
			ecoWorrier:
				text: "You consider yourself an eco worrier."
				install: ->
			prideful:
				text: "You take pride in your appearance."
				install: ->
	
		addedAtLeastOne = false
		for key, value of types
			if Math.random() > 0.5 then continue
			value.install()
			el = document.createElement "li"
			el.innerText = value.text
			document.getElementById "rituals"
				.appendChild el
			addedAtLeastOne = true
			@enabled[key] = true
		
		if not addedAtLeastOne
			el = document.createElement "li"
			el.innerText = "(none)"
			document.getElementById "rituals"
				.appendChild el
