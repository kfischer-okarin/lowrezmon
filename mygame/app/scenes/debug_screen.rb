module Scenes
  class DebugScreen
    TABS = [:font_preview, :emoji_preview]
    def initialize
      @font = build_pokemini_font
      @fatnumbers_font = build_pokemini_fatnumbers_font
      @current_tab_index = 0
    end

    def update(args)
      update_method = :"update_#{current_tab}"
      send(update_method, args) if respond_to? update_method

      @current_tab_index = (@current_tab_index + 1) % TABS.size if args.inputs.keyboard.key_down.tab
    end

    def render(screen, state)
      render_method = :"render_#{current_tab}"
      send(render_method, screen, state) if respond_to? render_method
    end

    def current_tab
      TABS[@current_tab_index]
    end

    private

    def render_font_preview(screen, state)
      screen.primitives << { x: 0, y: 0, w: 64, h: 64, path: :pixel, r: 255, g: 255, b: 255 }
      y = 58
      [
        'ABCDEFGHIJ',
        'KLMNOPQRST',
        'UVWXYZabcde',
        'fghijklmnopqrs',
        'tuvwxyz0123456',
        '789!@#$%^&*()',
        "[]{}<>`':;,.?-+=|/",
        '\\~ '
      ].each do |line|
        letters = @font.build_label(text: line, x: 0, y: y)
        screen.primitives << letters.map { |letter|
          letter.merge(path: :pixel, r: 200, g: 200, b: 255)
        }
        screen.primitives << letters
        y -= 7
      end

      fat_numbers = @fatnumbers_font.build_label(text: '0123456789', x: 0, y: y)
      screen.primitives << fat_numbers.map { |letter|
        letter.merge(path: :pixel, r: 200, g: 200, b: 255)
      }
      screen.primitives << fat_numbers
    end

    def render_emoji_preview(screen, state)
      number_of_chunks = (SPECIES.size / 16).ceil
      chunk_index = state.tick_count.idiv(60) % number_of_chunks
      chunk_offset = chunk_index * 16
      emojis = SPECIES.values[chunk_offset, 16]

      emojis.each_with_index do |emoji, index|
        x = (index % 4) * 16
        y = 48 - (index.idiv(4) * 16)
        screen.primitives << emoji[:sprite].to_sprite(x: x, y: y)
      end
    end
  end
end
