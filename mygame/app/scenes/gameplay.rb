module Scenes
  class Gameplay
    def update(inputs, state)
    end

    def render(screen, state)
      @font = build_pokemini_font
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
        r: 253, g: 253, b: 230
      }.sprite!
      screen.primitives << {
        x: 40, y: 40, w: 16, h: 16, path: 'sprites/emojis.png',
        source_x: 0, source_y: 0, source_w: 16, source_h: 16
      }.sprite!
      screen.primitives << {
        x: 4, y: 19, w: 23, h: 18, path: 'sprites/blank_emojis.png',
        source_x: 0, source_y: 4, source_w: 16, source_h: 12
      }.sprite!
      # window
      screen.primitives << {
        x: 0, y: 18, w: 64, h: 1, path: :pixel,
        r: 0, g: 0, b: 0
      }.sprite!
      screen.primitives << {
        x: 1, y: 1, w: 62, h: 17, path: :pixel,
        r: 255, g: 255, b: 255
      }.sprite!
      screen.primitives << @font.build_label(text: 'A wild angry', x: 2, y: 10)
      screen.primitives << @font.build_label(text: 'emoji appears!', x: 2, y: 2)
    end
  end
end
