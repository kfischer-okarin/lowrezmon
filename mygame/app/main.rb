require 'app/scenes/gameplay.rb'

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
  $scene = Scenes::Gameplay.new
end

def update(args)
  convert_mouse_position_to_lowrez_coordinates(args)
  $scene.update(args.inputs, args.state)
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
end

def convert_mouse_position_to_lowrez_coordinates(args)
  mouse = args.inputs.mouse
  mouse_position = { x: mouse.x, y: mouse.y }
  state = args.state
  return if mouse_position == state.lowrez_mouse_position

  state.original_mouse_position = mouse_position
  state.lowrez_mouse_position = {
    x: (mouse.x - LOWREZ_X_OFFSET).idiv(LOWREZ_ZOOM),
    y: (mouse.y - LOWREZ_Y_OFFSET).idiv(LOWREZ_ZOOM)
  }
  mouse.x = state.lowrez_mouse_position[:x]
  mouse.y = state.lowrez_mouse_position[:y]
end

def build_label(values)
  { font: 'fonts/lowrez.ttf', size_px: 5 }.label!(values)
end

$gtk.reset
