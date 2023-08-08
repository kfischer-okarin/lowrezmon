module UI
  class << self
    def font
      @font ||= build_pokemini_font
    end

    def fatnumbers_font
      @fatnumbers_font ||= build_pokemini_fatnumbers_font
    end

    def render_stats_display(outputs, emojimon, x:, y:, with_hp_numbers:)
      if with_hp_numbers
        outputs.primitives << fatnumbers_font.build_label(text: "#{emojimon[:hp]}/#{emojimon[:max_hp]}", x: x, y: y)
        y += 7
      end

      bar_max_w = 25
      outputs.primitives << { x: x, y: y, w: bar_max_w + 2, h: 3, path: :pixel, r: 0, g: 0, b: 0 }.border!
      y += 1

      bar_w = ((emojimon[:hp] / emojimon[:max_hp]) * bar_max_w).floor
      outputs.primitives << { x: x + 1, y: y, w: bar_w, h: 1, path: :pixel, r: 0xb8, g: 0xf8, b: 0x18 }
      y += 4

      outputs.primitives << font.build_label(text: emojimon[:name], x: x, y: y)
    end
  end
end
