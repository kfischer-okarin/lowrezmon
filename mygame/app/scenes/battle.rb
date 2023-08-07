module Scenes
  class Battle
    def initialize(args, player_trainer:, opponent_trainer:)
      @font = build_pokemini_font
      @fatnumbers_font = build_pokemini_fatnumbers_font

      battle = args.state.battle = args.state.new_entity(:battle)
      player = battle.player = args.state.new_entity(:player)
      player.trainer = player_trainer
      player.emojimon = nil
      player.sprite = nil
      player.stats_display.name_letters = []
      player.stats_display.hp_background = nil
      player.stats_display.hp_bar = nil
      player.stats_display.hp_letters = []

      opponent = battle.opponent = args.state.new_entity(:opponent)
      opponent.trainer = opponent_trainer
      opponent.emojimon = nil
      opponent.sprite = nil
      opponent.stats_display.name_letters = []
      opponent.stats_display.hp_background = nil
      opponent.stats_display.hp_bar = nil

      window = battle.window = args.state.new_entity(:window)
      window.line0_letters = []
      window.line1_letters = []
      window.waiting_for_advance_message_since = nil

      battle.cutscene = Cutscene.build_empty
      battle.state = :battle_start
      battle.queued_states = []
    end

    def update(args)
      @battle = args.state.battle
      @tick_count = args.tick_count
      unless Cutscene.finished?(@battle.cutscene)
        Cutscene.tick args, @battle.cutscene, handler: self
        return
      end

      window = @battle.window
      if window.waiting_for_advance_message_since
        return unless args.inputs.keyboard.key_down.space

        window.waiting_for_advance_message_since = nil
        window.line0_letters.clear
        window.line1_letters.clear
      end

      player = @battle.player
      opponent = @battle.opponent
      case @battle.state
      when :battle_start
        queue_message("#{opponent.trainer[:name]} wants to battle!")
        @battle.state = :opponent_sends_emojimon
        @battle.queued_states = [:player_sends_emojimon, :player_chooses_action]
      when :opponent_sends_emojimon
        opponent.emojimon = build_emojimon opponent.trainer[:emojimons].first
        queue_message("#{opponent.trainer[:name]} sends #{opponent.emojimon[:name]}!")
        queue_opponent_emojimon_appearance
        @battle.state = @battle.queued_states.shift
      when :player_sends_emojimon
        player.emojimon = build_emojimon player.trainer[:emojimons].first
        queue_message("Go, #{player.emojimon[:name]}!")
        queue_player_emojimon_appearance
        @battle.state = @battle.queued_states.shift
      when :player_chooses_action
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
        r: 0xF0, g: 0xD0, b: 0xB0
      }.sprite!
      opponent = @battle.opponent
      screen.primitives << opponent.sprite
      screen.primitives << opponent.stats_display.name_letters
      screen.primitives << opponent.stats_display.hp_background
      screen.primitives << opponent.stats_display.hp_bar
      player = @battle.player
      screen.primitives << player.sprite
      screen.primitives << player.stats_display.name_letters
      screen.primitives << player.stats_display.hp_background
      screen.primitives << player.stats_display.hp_bar
      screen.primitives << player.stats_display.hp_letters
      render_window(screen)
    end

    private

    def build_emojimon(emojimon)
      emojimon.merge(SPECIES[emojimon[:species]])
    end

    def render_window(screen)
      window = @battle.window
      screen.primitives << {
        x: 0, y: 18, w: 64, h: 1, path: :pixel,
        r: 0, g: 0, b: 0
      }.sprite!
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 18, path: :pixel,
        r: 0xFC, g: 0xFC, b: 0xFC
      }.sprite!
      screen.primitives << window.line0_letters
      screen.primitives << window.line1_letters

      return unless window.waiting_for_advance_message_since
      return unless (@tick_count - window.waiting_for_advance_message_since) % 60 < 30

      screen.primitives << {
        x: 28, y: 0, w: 9, h: 3, path: 'sprites/message_wait_triangle.png',
        r: 0, g: 0, b: 0
      }.sprite!
    end

    def queue_message(message, tick: @tick_count + 1)
      lines = @font.split_into_lines(message, line_w: 62)
      raise 'messages more than 2 lines not yet supported' if lines.size > 2

      lines.each_with_index do |line, index|
        duration = line.size * 2
        Cutscene.schedule_element @battle.cutscene, tick: tick, type: :message, duration: duration, line: line, line_index: index
        tick += duration
      end
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :wait_for_advance_message, duration: 1
      tick += 1
      tick
    end

    def queue_opponent_emojimon_appearance(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :opponent_emojimon_appears, duration: 60
    end

    def queue_player_emojimon_appearance(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :player_emojimon_appears, duration: 60
    end

    def message_tick(args, message_element)
      if message_element[:line_index].zero?
        y = 11
        letters_array = @battle.window.line0_letters
      else
        y = 3
        letters_array = @battle.window.line1_letters
      end
      letters_array.clear
      char_index = message_element[:elapsed_ticks].idiv 2
      letters_array.concat @font.build_label(text: message_element[:line][0..char_index], x: 1, y: y)
    end

    def wait_for_advance_message_tick(_args, _element)
      @battle.window.waiting_for_advance_message_since = @tick_count
    end

    def opponent_emojimon_appears_tick(_args, element)
      opponent = @battle.opponent
      case element[:elapsed_ticks]
      when 0
        target_values = opponent.emojimon[:sprite].slice(:h, :tile_h).merge(r: 255, g: 255, b: 255)
        opponent.sprite = opponent.emojimon[:sprite].to_sprite(
          x: 40, y: 40, h: 0, tile_h: 0, r: 0, g: 0, b: 0
        )
        element[:grow_animation] = Animations.lerp(
          opponent.sprite,
          to: target_values,
          duration: 60
        )
      else
        Animations.perform_tick element[:grow_animation]
        refresh_opponent_stats if element[:elapsed_ticks] == 59
      end
    end

    def refresh_opponent_stats
      emojimon = @battle.opponent.emojimon
      stats_display = @battle.opponent.stats_display
      stats_display.name_letters = @font.build_label(text: emojimon[:name], x: 1, y: 57)
      stats_display.hp_background = { x: 1, y: 52, w: 27, h: 3, path: :pixel, r: 0, g: 0, b: 0 }.border!
      bar_w = emojimon[:hp].fdiv(emojimon[:max_hp]) * 25
      stats_display.hp_bar = { x: 2, y: 53, w: bar_w, h: 1, path: :pixel, r: 0xb8, g: 0xf8, b: 0x18 }
    end

    def player_emojimon_appears_tick(_args, element)
      player = @battle.player
      case element[:elapsed_ticks]
      when 0
        target_values = player.emojimon[:back_sprite].slice(:h, :source_h).merge(r: 255, g: 255, b: 255)
        player.sprite = player.emojimon[:back_sprite].to_sprite(
          x: 4, y: 19, h: 0, source: 0, r: 0, g: 0, b: 0
        )
        element[:grow_animation] = Animations.lerp(
          player.sprite,
          to: target_values,
          duration: 60
        )
      else
        Animations.perform_tick element[:grow_animation]
        refresh_player_stats if element[:elapsed_ticks] == 59
      end
    end

    def refresh_player_stats
      emojimon = @battle.player.emojimon
      stats_display = @battle.player.stats_display
      stats_display.name_letters = @font.build_label(text: emojimon[:name], x: 34, y: 32)
      stats_display.hp_background = { x: 34, y: 27, w: 27, h: 3, path: :pixel, r: 0, g: 0, b: 0 }.border!
      bar_w = emojimon[:hp].fdiv(emojimon[:max_hp]) * 25
      stats_display.hp_bar = { x: 35, y: 28, w: bar_w, h: 1, path: :pixel, r: 0xb8, g: 0xf8, b: 0x18 }
      stats_display.hp_letters = @fatnumbers_font.build_label(text: "#{emojimon[:hp]}/#{emojimon[:max_hp]}", x: 34, y: 20)
    end
  end
end
