# Required by Webpack to include resources in the HTML.
require "./index.sass"

UpdateService = require './UpdateService.coffee'
Game = require './Game.coffee'
LabelComp = do require './LabelComp.coffee'

game = undefined

renderer = PIXI.autoDetectRenderer window.innerWidth, window.innerHeight, {antialias:false}
document.body.appendChild renderer.view

PIXI.SCALE_MODES.DEFAULT = PIXI.SCALE_MODES.NEAREST

PIXI.loader
  .add "player", require "file!./dude1.png"
  .add "playernude", require "file!./dude2.png"
  .add "levelBright", require "file!./background_Animation 1_0.png"
  .add "levelBright2", require "file!./background_Animation 1_1.png"
  .add "levelDark", require "file!./background_Animation 1_2.png"
  .add "levelDark2", require "file!./background_Animation 1_3.png"
  .load (loader, resources) ->
    for t of resources
      PIXI.Texture.addTextureToCache resources[t].texture, t
    game = new Game()
    animate(0)

animate = (time) ->
  requestAnimationFrame animate
  kd.tick() # kd = keydrown
  renderer.render game.stage
  UpdateService.update(time)