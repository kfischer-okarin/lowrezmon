require 'lib/animations.rb'
require 'lib/cutscene.rb'
require 'lib/spritesheet_font.rb'
require 'app/font.rb'
require 'app/scenes/battle.rb'

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
end

def setup(_args)
  $scene = Scenes::Battle.new
end

def update(args)
  mouse = args.inputs.mouse
  args.state.lowrez_mouse_position = to_lowrez_coordinates(
    x: mouse.x,
    y: mouse.y
  )
  $scene.update(args)
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
  handle_screenshot(args)
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

def handle_screenshot(args)
  return unless args.inputs.keyboard.key_down.zero

  time = Time.now
  args.outputs.screenshots << {
    x: LOWREZ_X_OFFSET, y: LOWREZ_Y_OFFSET, w: LOWREZ_RENDER_SIZE, h: LOWREZ_RENDER_SIZE,
    # current timestamp
    path: 'screenshots/screenshot_%04d%02d%02d%02d%02d%02d.png' % [time.year, time.month, time.day, time.hour, time.min, time.sec]
  }
end

def build_label(values)
  { font: 'fonts/lowrez.ttf', size_px: 5 }.label!(values)
end

$gtk.reset
