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
      player.selected_action = nil

      opponent = battle.opponent = args.state.new_entity(:opponent)
      opponent.trainer = opponent_trainer
      opponent.emojimon = nil
      opponent.sprite = nil
      opponent.stats_display.name_letters = []
      opponent.stats_display.hp_background = nil
      opponent.stats_display.hp_bar = nil
      opponent.selected_action = nil

      message_window = battle.message_window = args.state.new_entity(:message_window)
      message_window.active = false
      message_window.line0_letters = []
      message_window.line1_letters = []
      message_window.waiting_for_advance_message_since = nil

      action_selection = battle.action_selection = args.state.new_entity(:action_selection)
      action_selection.index = 0

      battle.cutscene = Cutscene.build_empty
      battle.state = :battle_start
      battle.queued_states = []
      battle.turn_order = nil
    end

    def update(args)
      @battle = args.state.battle
      @tick_count = args.tick_count
      key_down = args.inputs.keyboard.key_down
      unless Cutscene.finished?(@battle.cutscene)
        Cutscene.tick args, @battle.cutscene, handler: self
        return
      end

      if @battle.message_window.active
        update_message_window(args)
        return
      end

      player = @battle.player
      opponent = @battle.opponent
      case @battle.state
      when :battle_start
        queue_message("#{opponent.trainer[:name]} wants to battle!")
        @battle.queued_states = [:opponent_sends_emojimon, :player_sends_emojimon, :player_chooses_action]
        @battle.state = :go_to_next_queued_state
      when :opponent_sends_emojimon
        opponent.emojimon = build_emojimon opponent.trainer[:emojimons].first
        queue_message("#{opponent.trainer[:name]} sends #{opponent.emojimon[:name]}!")
        queue_opponent_emojimon_appearance
        @battle.state = :go_to_next_queued_state
      when :player_sends_emojimon
        player.emojimon = build_emojimon player.trainer[:emojimons].first
        prepare_action_selection
        queue_message("Go, #{player.emojimon[:name]}!")
        queue_player_emojimon_appearance
        @battle.state = :go_to_next_queued_state
      when :player_chooses_action
        action_selection = @battle.action_selection
        if key_down.left
          action_selection.index = (action_selection.index - 1) % action_selection.options.size
        elsif key_down.right
          action_selection.index = (action_selection.index + 1) % action_selection.options.size
        elsif key_down.space
          player.selected_action = action_selection.options[action_selection.index][:action]
          opponent.selected_action = choose_opponent_action
          @battle.turn_order = determine_turn_order
          queue_turn_resolution_for @battle.turn_order.shift
          @battle.state = :go_to_next_queued_state
          @battle.queued_states = [:other_turn]
        end
      when :other_turn
        queue_turn_resolution_for @battle.turn_order.shift
        @battle.queued_states = [:player_chooses_action]
        @battle.state = :go_to_next_queued_state
      when :go_to_next_queued_state
        @battle.state = @battle.queued_states.shift
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

    def update_message_window(args)
      message_window = @battle.message_window
      return unless message_window.waiting_for_advance_message_since

      if confirm?(args.inputs)
        message_window.active = false
        message_window.waiting_for_advance_message_since = nil
        message_window.line0_letters.clear
        message_window.line1_letters.clear
      end
    end

    def confirm?(inputs)
      inputs.keyboard.key_down.space
    end

    def build_emojimon(emojimon)
      result = emojimon.merge(SPECIES[emojimon[:species]])
      result[:attacks] ||= []
      result[:attacks] = result[:attacks].map { |attack| ATTACKS[attack].merge(id: attack) }
      result
    end

    def prepare_action_selection
      action_selection = @battle.action_selection
      action_selection.index = 0
      action_selection.options = []
      @battle.player.emojimon[:attacks].each_with_index do |attack, index|
        action_selection.options << {
          action: { type: :attack, attack: attack[:id] },
          sprite: attack[:sprite],
          rect: { x: 2 + (index * 16), y: 2, w: 14, h: 14 }
        }
      end
      action_selection.options << {
        action: { type: :exchange },
        sprite: { path: 'sprites/icons/exchange.png' },
        rect: { x: 48, y: 2, w: 14, h: 14 }
      }
    end

    def choose_opponent_action
      {
        type: :attack,
        attack: @battle.opponent.emojimon[:attacks].sample[:id]
      }
    end

    def determine_turn_order
      [:player, :opponent]
    end

    def calc_damage(attacker, defender, attack)
      3 + rand(3)
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

      if @battle.message_window.active
        render_message_window(screen)
      elsif @battle.state == :player_chooses_action
        render_action_selection(screen)
      end
    end

    def render_message_window(screen)
      message_window = @battle.message_window
      screen.primitives << message_window.line0_letters
      screen.primitives << message_window.line1_letters

      return unless message_window.waiting_for_advance_message_since
      return unless (@tick_count - message_window.waiting_for_advance_message_since) % 60 < 30

      screen.primitives << {
        x: 28, y: 0, w: 9, h: 3, path: 'sprites/message_wait_triangle.png',
        r: 0, g: 0, b: 0
      }.sprite!
    end

    def render_action_selection(screen)
      action_selection = @battle.action_selection

      action_selection.options.each_with_index do |option, index|
        bg_color = action_selection.index == index ? { r: 0x61, g: 0xa2, b: 0xff } : { r: 0xb2, g: 0xb2, b: 0xb2 }
        screen.primitives << option[:rect].merge(path: 'sprites/icons/background.png').merge!(bg_color)
        screen.primitives << option[:rect].merge(option[:sprite])
      end
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
      duration = 30
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :opponent_emojimon_appears, duration: duration
      tick + duration
    end

    def queue_player_emojimon_appearance(tick: @tick_count + 1)
      duration = 30
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :player_emojimon_appears, duration: duration
      tick + duration
    end

    def queue_turn_resolution_for(combatant, tick: @tick_count + 1)
      player = @battle.player
      player_emojimon = player.emojimon
      opponent = @battle.opponent
      opponent_emojimon = @battle.opponent.emojimon
      after_finished_tick = nil
      case combatant
      when :player
        action = player.selected_action
        case action[:type]
        when :attack
          attack = ATTACKS[action[:attack]]
          damage = calc_damage(player_emojimon, opponent_emojimon, attack)
          multiplier = Type.damage_multiplier(attack[:type], against_type: opponent_emojimon[:type])
          damage = (damage * multiplier).floor
          queue_message("#{player_emojimon[:name]} uses #{attack[:name]}!", tick: tick)
          queue_player_attack_animation(tick: tick + 20)
          after_finished_tick = queue_hp_bar_animation(opponent, -damage, tick: tick + 20)
          opponent_emojimon[:hp] -= damage

          @battle.state = :other_turn if @battle.turn_order.any?
        when :exchange
          @battle.state = :player_chooses_action # TODO: Implemennt
        end
        player.selected_action = nil
      when :opponent
        action = opponent.selected_action
        after_finished_tick = nil
        case action[:type]
        when :attack
          attack = ATTACKS[action[:attack]]
          damage = calc_damage(opponent_emojimon, player_emojimon, attack)
          multiplier = Type.damage_multiplier(attack[:type], against_type: player_emojimon[:type])
          damage = (damage * multiplier).floor
          queue_message("#{opponent_emojimon[:name]} uses #{attack[:name]}!", tick: tick)
          queue_opponent_attack_animation(tick: tick + 20)
          after_finished_tick = queue_hp_bar_animation(player, -damage, tick: tick + 20, with_hp_numbers: true)
          player_emojimon[:hp] -= damage

          @battle.state = :other_turn if @battle.turn_order.any?
        when :exchange
          @battle.state = :player_chooses_action # TODO: Implemennt
        end
        opponent.selected_action = nil
      end
      after_finished_tick
    end

    def queue_player_attack_animation(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :shake, target: @battle.opponent.sprite, duration: 20
    end

    def queue_opponent_attack_animation(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :shake, target: @battle.player.sprite, duration: 20
    end

    def queue_hp_bar_animation(combatant, delta, tick: @tick_count + 1, with_hp_numbers: false)
      target_hp = (combatant.emojimon[:hp] + delta).clamp(0, combatant.emojimon[:max_hp])
      hp_bar = combatant.stats_display.hp_bar
      target_w = ((target_hp / combatant.emojimon[:max_hp]) * 25).floor
      duration = (hp_bar[:w].abs - target_w.abs) * 2
      Cutscene.schedule_element @battle.cutscene,
                                tick: tick,
                                type: :animate_hp_bar,
                                hp_bar: hp_bar,
                                target_w: target_w,
                                duration: duration

      if with_hp_numbers
        hp_letters = combatant.stats_display.hp_letters
        Cutscene.schedule_element @battle.cutscene,
                                  tick: tick,
                                  type: :animate_hp_letters,
                                  hp_bar: hp_letters,
                                  current_hp: combatant.emojimon[:hp],
                                  max_hp: combatant.emojimon[:max_hp],
                                  target_hp: target_hp,
                                  duration: duration
      end


      tick + duration
    end

    def message_tick(_args, message_element)
      message_window = @battle.message_window
      message_window.active = true
      if message_element[:line_index].zero?
        y = 11
        letters_array = message_window.line0_letters
      else
        y = 3
        letters_array = message_window.line1_letters
      end
      letters_array.clear
      char_index = message_element[:elapsed_ticks].idiv 2
      letters_array.concat @font.build_label(text: message_element[:line][0..char_index], x: 1, y: y)
    end

    def wait_for_advance_message_tick(_args, _element)
      @battle.message_window.waiting_for_advance_message_since = @tick_count
    end

    def opponent_emojimon_appears_tick(_args, element)
      opponent = @battle.opponent
      case element[:elapsed_ticks]
      when 0
        target_values = opponent.emojimon[:sprite].slice(:h).merge(r: 255, g: 255, b: 255)
        opponent.sprite = opponent.emojimon[:sprite].to_sprite(
          x: 40, y: 40, h: 0, r: 0, g: 0, b: 0
        )
        element[:grow_animation] = Animations.lerp(
          opponent.sprite,
          to: target_values,
          duration: element[:duration]
        )
      else
        Animations.perform_tick element[:grow_animation]
        refresh_opponent_stats if element[:elapsed_ticks] == element[:duration] - 1
      end
    end

    def refresh_opponent_stats
      emojimon = @battle.opponent.emojimon
      stats_display = @battle.opponent.stats_display
      stats_display.name_letters = @font.build_label(text: emojimon[:name], x: 1, y: 57)
      stats_display.hp_background = { x: 1, y: 52, w: 27, h: 3, path: :pixel, r: 0, g: 0, b: 0 }.border!
      bar_w = ((emojimon[:hp] / emojimon[:max_hp]) * 25).floor
      stats_display.hp_bar = { x: 2, y: 53, w: bar_w, h: 1, path: :pixel, r: 0xb8, g: 0xf8, b: 0x18 }
    end

    def player_emojimon_appears_tick(_args, element)
      player = @battle.player
      case element[:elapsed_ticks]
      when 0
        target_values = player.emojimon[:back_sprite].slice(:h).merge(r: 255, g: 255, b: 255)
        player.sprite = player.emojimon[:back_sprite].to_sprite(
          x: 4, y: 17, h: 0, r: 0, g: 0, b: 0
        )
        element[:grow_animation] = Animations.lerp(
          player.sprite,
          to: target_values,
          duration: element[:duration]
        )
      else
        Animations.perform_tick element[:grow_animation]
        refresh_player_stats if element[:elapsed_ticks] == element[:duration] - 1
      end
    end

    def refresh_player_stats
      emojimon = @battle.player.emojimon
      stats_display = @battle.player.stats_display
      stats_display.name_letters = @font.build_label(text: emojimon[:name], x: 34, y: 32)
      stats_display.hp_background = { x: 34, y: 27, w: 27, h: 3, path: :pixel, r: 0, g: 0, b: 0 }.border!
      bar_w = ((emojimon[:hp] / emojimon[:max_hp]) * 25).floor
      stats_display.hp_bar = { x: 35, y: 28, w: bar_w, h: 1, path: :pixel, r: 0xb8, g: 0xf8, b: 0x18 }
      stats_display.hp_letters = @fatnumbers_font.build_label(text: "#{emojimon[:hp]}/#{emojimon[:max_hp]}", x: 34, y: 20)
    end

    MAX_SHAKE = 10
    SHAKE_DECAY = 0.01

    def shake_tick(_args, element)
      target = element[:target]
      if element[:elapsed_ticks].zero?
        element[:trauma] = 0.2
        element[:original_x] = target.x
        element[:original_y] = target.y
      end

      max_shake = (element[:trauma]**2) * MAX_SHAKE
      shake_x = max_shake * ((rand * 2) - 1)
      shake_y = max_shake * ((rand * 2) - 1)
      shake_x = shake_x.abs.ceil * shake_x.sign
      shake_y = shake_y.abs.ceil * shake_y.sign
      target.x = element[:original_x] + shake_x
      target.y = element[:original_y] + shake_y
      element[:trauma] = [0, element[:trauma] - SHAKE_DECAY].max

      if element[:elapsed_ticks] == element[:duration] - 1
        target.x = element[:original_x]
        target.y = element[:original_y]
      end
    end

    def animate_hp_bar_tick(_args, element)
      hp_bar = element[:hp_bar]
      element[:animation] ||= Animations.lerp(
        hp_bar,
        to: { w: element[:target_w] },
        duration: element[:duration]
      )
      Animations.perform_tick element[:animation]
    end

    def animate_hp_letters_tick(_args, element)
      hp_letters = element[:hp_bar]
      element[:x] ||= hp_letters.first[:x]
      element[:y] ||= hp_letters.first[:y]
      animated_hp = element[:elapsed_ticks].remap(0, element[:duration], element[:current_hp], element[:target_hp]).floor
      hp_letters.clear
      hp_letters.concat @fatnumbers_font.build_label(text: "#{animated_hp}/#{element[:max_hp]}", x: element[:x], y: element[:y])
    end
  end
end
