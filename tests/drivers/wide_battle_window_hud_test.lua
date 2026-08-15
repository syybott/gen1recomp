-- Visual proof for WIDE battle HUD regions composited in physical-window
-- space.  Captures the same deterministic battle with the legacy in-canvas
-- placement and the new window placement.  Every capture uses BATTLE SIZE =
-- FILL so the proof matches the target configuration.
--
--   POKEPORT_DRIVER=tests/drivers/wide_battle_window_hud_test.lua \
--     POKEPORT_IDENTITY=wide-window-hud POKEPORT_TOUCH=0 \
--     SHOT_DIR=/tmp/shots love .
return function(game)
  local U = dofile("tests/drivers/util.lua")
  local DIR = os.getenv("SHOT_DIR") or "/tmp/shots"
  local BattleState = require("src.battle.BattleState")
  local Pokemon = require("src.pokemon.Pokemon")

  -- Exercise the real desktop-sized margins instead of a synthetic test
  -- window.  The game keeps its native-pixel FILL scaling inside this mode.
  love.window.setFullscreen(true, "desktop")
  U.wait(30)

  game.save.options.battleLayout = "wide"
  game.save.options.battleBg = "world"
  game.save.options.battleFit = "fill"
  game.save.party = { Pokemon.new(game.data, "MEW", 50) }
  U.teleport(game, "ROUTE_1", 5, 5, "down")
  U.wait(60)

  local battle = BattleState.newWild(game, "PIDGEY", 20,
    { onFinish = function() end })
  game.overworld:pushBattle(battle)
  U.wait(360)

  -- Pin the command screen so every capture compares identical battle state.
  battle.introSlide = 0
  battle.introBalls = nil
  battle.showEnemyTrainer = false
  battle.showPlayerBack = false
  battle.enemySendingOut = false
  battle.sendingOut = false
  battle.phase = "menu"
  battle.menuIndex = 1

  battle.windowHUD = false
  U.wait(3)
  U.shot(game, DIR .. "/wide_window_hud_0_legacy_fill.png")

  battle.windowHUD = true
  U.wait(3)
  U.shot(game, DIR .. "/wide_window_hud_1_window_fill.png")

  battle.phase = "moveSelect"
  battle.moveIndex = 1
  U.wait(3)
  U.shot(game, DIR .. "/wide_window_hud_2_moves_fill.png")

  battle.phase = "messages"
  battle:startMessage({ text = "WIDE HUD IN WINDOW SPACE" })
  U.wait(3)
  U.shot(game, DIR .. "/wide_window_hud_3_message_fill.png")

  U.log("WIDE window-HUD proof captured in " .. DIR)
  U.log("0 is the legacy 304x144 composition; 1-3 use physical-window HUD regions")
  while true do coroutine.yield() end
end
