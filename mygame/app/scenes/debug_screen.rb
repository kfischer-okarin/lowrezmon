module Scenes
  class DebugScreen
    def initialize
      @font = build_pokemini_font
    end

    def update(args)
    end

    def render(screen, state)
      screen.primitives << { x: 0, y: 0, w: 64, h: 64, path: :pixel, r: 255, g: 255, b: 255 }
      [
        'ABCDEFGHIJ',
        'KLMNOPQRST',
        'UVWXYZabcde',
        'fghijklmnopqrs',
        'tuvwxyz0123456',
        '789!@#$%^&*()',
        "[]{}<>`':;,.?-+=|/",
        '\\~ '
      ].each_with_index do |line, index|
        letters = @font.build_label(text: line, x: 0, y: 58 - (index * 7))
        screen.primitives << letters.map { |letter|
          letter.merge(path: :pixel, r: 200, g: 200, b: 255)
        }
        screen.primitives << letters
      end

      # chunk = state.tick_count.idiv(30) % 4
      # i = chunk * 16
      # emojis = SPECIES.values[i, 16]

      # emojis.each.with_index do |e, i|
      #   x = i * 16 % 64
      #   y = i.idiv(4) * 16
      #   screen.primitives << e.merge(
      #     x: x, y: y, w: 16, h: 16,
      #     tile_w: 16, tile_h: 16,
      #     path: "sprites/emojis.png"
      #   ).sprite!
    end
  end
end
