require 'lib/animations.rb'
require 'lib/cutscene.rb'
require 'lib/menu_navigation.rb'
require 'lib/spritesheet_font.rb'
require 'app/battle_system.rb'
require 'app/controls.rb'
require 'app/font.rb'
require 'app/message_window.rb'
require 'app/music.rb'
require 'app/palette.rb'
require 'app/save_data.rb'
require 'app/scenes/battle.rb'
require 'app/scenes/change_emojimon.rb'
require 'app/scenes/debug_screen.rb'
require 'app/scenes/emojimon_list.rb'
require 'app/scenes/main_menu.rb'
require 'app/scenes/team_builder.rb'
require 'app/scenes/title_screen.rb'
require 'app/scenes/tournament.rb'
require 'app/sfx.rb'
require 'app/ui.rb'
require 'app/data.rb'

LOWREZ_ZOOM = 11
LOWREZ_RENDER_SIZE = 64 * LOWREZ_ZOOM
LOWREZ_X_OFFSET = (1280 - LOWREZ_RENDER_SIZE).idiv(2)
LOWREZ_Y_OFFSET = (720 - LOWREZ_RENDER_SIZE).idiv(2)
FRAME_BACKGROUND_COLOR = { r: 50, g: 50, b: 50 }.freeze
SCREEN_BACKGROUND_COLOR = { r: 0, g: 0, b: 0 }.freeze

def tick(args)
  setup(args) if args.tick_count.zero?
  update(args)
  render(args)
  Music.tick(args)
  if $next_scene
    $scene.on_exit(args) if $scene.respond_to?(:on_leave)
    $scene = $next_scene
    $scene.on_enter(args) if $scene.respond_to?(:on_enter)
    $next_scene = nil
  end
end

def setup(args)
  $scene = Scenes::TitleScreen.new(args)
  $scene.on_enter(args) if $scene.respond_to?(:on_enter)
end

def update(args)
  mouse = args.inputs.mouse
  args.state.lowrez_mouse_position = to_lowrez_coordinates(
    x: mouse.x,
    y: mouse.y
  )
  $scene.update(args)

  return if $gtk.production?

  handle_screenshot(args)
  handle_toggle_debug_screen(args)
end

def render(args)
  screen = args.outputs[:screen]
  screen.transient!
  screen.w = 64
  screen.h = 64
  screen.background_color = SCREEN_BACKGROUND_COLOR

  $scene.render(screen, args.state)

  args.outputs.background_color = FRAME_BACKGROUND_COLOR
  args.outputs.primitives << {
    x: LOWREZ_X_OFFSET, y: LOWREZ_Y_OFFSET, w: LOWREZ_RENDER_SIZE, h: LOWREZ_RENDER_SIZE,
    path: :screen
  }.sprite!
  return if $gtk.production?

  render_fps(args)
  render_lowrez_mouse_position(args)
end

def to_lowrez_coordinates(point)
  {
    x: (point.x - LOWREZ_X_OFFSET).idiv(LOWREZ_ZOOM),
    y: (point.y - LOWREZ_Y_OFFSET).idiv(LOWREZ_ZOOM)
  }
end

def render_fps(args)
  args.outputs.primitives << {
    x: 0, y: 720, text: '%d' % $gtk.current_framerate,
    r: 255, g: 255, b: 255
  }.label!
end

def render_lowrez_mouse_position(args)
  args.outputs.primitives << {
    x: 0, y: 700, text: '%d, %d' % [args.state.lowrez_mouse_position.x, args.state.lowrez_mouse_position.y],
    r: 255, g: 255, b: 255
  }.label!
end

def handle_screenshot(args)
  return unless args.inputs.keyboard.key_down.zero

  time = Time.now
  args.outputs.screenshots << {
    x: LOWREZ_X_OFFSET, y: LOWREZ_Y_OFFSET, w: LOWREZ_RENDER_SIZE, h: LOWREZ_RENDER_SIZE,
    # current timestamp
    path: 'screenshots/screenshot_%04d%02d%02d%02d%02d%02d.png' % [time.year, time.month, time.day, time.hour, time.min, time.sec]
  }
end

def handle_toggle_debug_screen(args)
  return unless args.inputs.keyboard.key_down.nine

  if $original_scene
    $next_scene = $original_scene
    $original_scene = nil
  else
    $original_scene = $scene
    $next_scene = Scenes::DebugScreen.new
  end
end

$gtk.reset
