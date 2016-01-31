# Required by Webpack to include resources in the HTML.
require "./index.sass"

UpdateService = require './UpdateService.coffee'
Game = require './Game.coffee'
LabelComp = do require './LabelComp.coffee'
BubbleComp = do require './BubbleComp.coffee'

game = undefined

renderer = PIXI.autoDetectRenderer 180 * 8, 32 * 8, {antialias:false}
document.body.appendChild renderer.view

PIXI.SCALE_MODES.DEFAULT = PIXI.SCALE_MODES.NEAREST

PIXI.loader
  .add "player", require "url!./dude1.png"
  .add "playernude", require "url!./dude2.png"
  .add "levelBright", require "url!./background_Animation 1_0.png"
  .add "levelBright2", require "url!./background_Animation 1_1.png"
  .add "levelDark", require "url!./background_Animation 1_2.png"
  .add "levelDark2", require "url!./background_Animation 1_3.png"
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