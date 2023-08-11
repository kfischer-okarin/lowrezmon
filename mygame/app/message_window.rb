class MessageWindow
  def initialize
    @font = build_pokemini_font
    @queued_messages = []
    @rendered_letters = [[], []]
    @state = { type: :inactive }
  end

  def active?
    @state[:type] != :inactive || @queued_messages.any?
  end

  def queue_message(message_string)
    @queued_messages.concat convert_to_line_letters(message_string)
  end

  def display_message(message_string)
    @rendered_letters = convert_to_line_letters(message_string).first
    @state = { type: :just_diplay_message }
  end

  def clear_message
    @rendered_letters = [[], []]
    @state = { type: :inactive }
  end

  def update(args)
    if @state[:type] == :inactive
      return unless @queued_messages.any?

      @state = {
        type: :message,
        line_letters: @queued_messages.shift,
        elapsed_ticks: 0,
        line_index: 0,
        char_index: 0
      }
    end

    case @state[:type]
    when :message
      if (@state[:elapsed_ticks] % 2).zero?
        current_line_letters = @state[:line_letters][@state[:line_index]]

        if @state[:char_index] >= current_line_letters.size
          if @state[:line_index] == 0 && @state[:line_letters].size == 2
            @state[:line_index] = 1
            @state[:char_index] = 0
            current_line_letters = @state[:line_letters][1]
          else
            @state = { type: :waiting_for_advance_message, elapsed_ticks: 0 }
            return
          end
        end

        current_rendered_letters = @rendered_letters[@state[:line_index]]
        current_rendered_letters << current_line_letters[@state[:char_index]]
        @state[:char_index] += 1
      end
      @state[:elapsed_ticks] += 1
    when :waiting_for_advance_message
      if Controls.confirm?(args.inputs)
        clear_message
        return
      end
      @state[:elapsed_ticks] += 1
    end
  end

  def render(screen)
    screen.primitives << {
      x: 0, y: 18, w: 64, h: 1, path: :pixel,
      r: 0, g: 0, b: 0
    }.sprite!
    screen.primitives << {
      x: 0, y: 0, w: 64, h: 18, path: :pixel
    }.sprite!(Palette::WINDOW_BG_COLOR)

    screen.primitives << @rendered_letters

    return unless @state[:type] == :waiting_for_advance_message

    if @state[:elapsed_ticks] % 60 < 30
      screen.primitives << {
        x: 28, y: 0, w: 9, h: 3, path: 'sprites/message_wait_triangle.png',
        r: 0, g: 0, b: 0
      }.sprite!
    end
  end

  private

  def convert_to_line_letters(message_string)
    lines = @font.split_into_lines(message_string, line_w: 62)
    lines.each_slice(2).map { |line_pair|
      result = [
        @font.build_label(text: line_pair[0], x: 1, y: 11),
      ]
      result << @font.build_label(text: line_pair[1], x: 1, y: 3) if line_pair[1]
      result
    }
  end
end
