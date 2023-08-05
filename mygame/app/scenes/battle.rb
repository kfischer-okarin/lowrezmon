module Scenes
  class Battle
    def initialize(player:, opponent:)
      @player = player
      @opponent = opponent
      @player_emojimon = build_emojimon @player[:emojimons].first
      @opponent_emojimon = build_emojimon @opponent[:emojimons].first
      @line0_letters = []
      @line1_letters = []
      @line_index = 0
      @cutscene = Cutscene.build_empty
      @state = :battle_start
      @font = build_pokemini_font
      @waiting_for_advance_message_since = nil
    end

    def update(args)
      @tick_count = args.tick_count
      unless Cutscene.finished?(@cutscene)
        Cutscene.tick args, @cutscene, handler: self
        return
      end

      if @waiting_for_advance_message_since
        return unless args.inputs.keyboard.key_down.space

        @waiting_for_advance_message_since = nil
        @line0_letters.clear
        @line1_letters.clear
        @line_index = 0
      end

      case @state
      when :battle_start
        queue_message("#{@opponent[:name]} wants to battle!")
        @state = :opponent_sends_emojimon
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
        r: 0xF0, g: 0xD0, b: 0xB0
      }.sprite!
      screen.primitives << @opponent_emojimon[:sprite].to_sprite(x: 40, y: 40)
      screen.primitives << @player_emojimon[:back_sprite].to_sprite(x: 4, y: 19)
      render_window(screen)
    end

    private

    def build_emojimon(emojimon)
      emojimon.merge(SPECIES[emojimon[:species]])
    end

    def render_window(screen)
      screen.primitives << {
        x: 0, y: 18, w: 64, h: 1, path: :pixel,
        r: 0, g: 0, b: 0
      }.sprite!
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 18, path: :pixel,
        r: 0xFC, g: 0xFC, b: 0xFC
      }.sprite!
      screen.primitives << @line0_letters
      screen.primitives << @line1_letters

      return unless @waiting_for_advance_message_since
      return unless (@tick_count - @waiting_for_advance_message_since) % 60 < 30

      screen.primitives << {
        x: 28, y: 0, w: 9, h: 3, path: 'sprites/message_wait_triangle.png',
        r: 0, g: 0, b: 0
      }.sprite!
    end

    def queue_message(message, tick: @tick_count + 1)
      lines = @font.split_into_lines(message, line_w: 62)
      lines.each do |line|
        duration = line.size * 2
        Cutscene.schedule_element @cutscene, tick: tick, type: :message, duration: duration, line: line, line_index: @line_index
        @line_index = 1 - @line_index
        tick += duration
      end
      Cutscene.schedule_element @cutscene, tick: tick, type: :wait_for_advance_message, duration: 1
      tick += 1
      tick
    end

    def queue_state_change(new_state, tick: @tick_count + 1)
      Cutscene.schedule_element @cutscene, tick: tick, type: :state_change, duration: 1, new_state: new_state
    end

    def message_tick(_args, message_element)
      if message_element[:line_index].zero?
        y = 11
        letters_array = @line0_letters
      else
        y = 3
        letters_array = @line1_letters
      end
      letters_array.clear
      char_index = message_element[:elapsed_ticks].idiv 2
      letters_array.concat @font.build_label(text: message_element[:line][0..char_index], x: 1, y: y)
    end

    def state_change_tick(_args, state_change_element)
      @state = state_change_element[:new_state]
    end

    def wait_for_advance_message_tick(_args, _element)
      @waiting_for_advance_message_since = @tick_count
    end
  end
end
