types = []
###
		text: "Everything must be straight."
		install: ->
	,
		text: "You can't leave any power on."
		install: ->
	,
  	text: "You can't work in a dark room while the lights are out."
  	install: ->
	,
  	text: "You must wash your hands between every action."
  	install: ->
###
module.exports = class Rituals
  constructor: ->
  	addedAtLeastOne = false
  	for value of types
  		if Math.random() > 0.5 then continue
  		el = document.createElement "li"
  		el.innerText = value.text
  		document.getElementById "rituals"
  			.appendChild el
  		addedAtLeastOne = true

  	if not addedAtLeastOne
  		el = document.createElement "li"
  		el.innerText = "(none)"
  		document.getElementById "rituals"
  			.appendChild el
