module Scenes
  class Battle
    def initialize(args, player_trainer:, opponent_trainer:)
      @font = build_pokemini_font
      @fatnumbers_font = build_pokemini_fatnumbers_font

      battle = args.state.battle = args.state.new_entity(:battle)
      battle.player_stats_visible = false
      battle.opponent_stats_visible = false

      player = battle.player = args.state.new_entity(:player)
      player.trainer = player_trainer
      player.emojimon = nil
      player.sprite = nil
      player.selected_action = nil

      opponent = battle.opponent = args.state.new_entity(:opponent)
      opponent.trainer = opponent_trainer
      opponent.emojimon = nil
      opponent.sprite = nil
      opponent.selected_action = nil

      message_window = battle.message_window = args.state.new_entity(:message_window)
      message_window.active = false
      message_window.queued_messages = []
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

      cutscene_running = !Cutscene.finished?(@battle.cutscene)
      Cutscene.tick args, @battle.cutscene, handler: self if cutscene_running

      message_window_active = @battle.message_window.active || @battle.message_window.queued_messages.any?
      update_message_window(args) if message_window_active
      return if cutscene_running || message_window_active

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
        queue_message("Go, #{player.emojimon[:name]}!")
        queue_player_emojimon_appearance
        prepare_action_menu
        @battle.state = :go_to_next_queued_state
      when :player_chooses_action
        @action_menu.tick(args)
        if key_down.space
          player.selected_action = @action_menu.selected_child[:action]
          opponent.selected_action = BattleSystem.choose_opponent_action(opponent, player)
          @battle.turn_order = BattleSystem.determine_turn_order(player, opponent)
          queue_next_turn_resolution
          @battle.state = :go_to_next_queued_state
          @battle.queued_states = [:other_turn]
        end
      when :other_turn
        queue_next_turn_resolution
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
      if @battle.opponent_stats_visible
        UI.render_stats_display(screen, opponent.emojimon, x: 1, y: 52, with_hp_numbers: false)
      end
      player = @battle.player
      screen.primitives << player.sprite
      if @battle.player_stats_visible
        UI.render_stats_display(screen, player.emojimon, x: 34, y: 20, with_hp_numbers: true)
      end
      render_window(screen)
    end

    private

    def update_message_window(args)
      message_window = @battle.message_window
      if message_window.active
        return unless message_window.waiting_for_advance_message_since

        if confirm?(args.inputs)
          message_window.active = false
          message_window.waiting_for_advance_message_since = nil
          message_window.line0_letters.clear
          message_window.line1_letters.clear
        end
      else
        next_message_lines = message_window.queued_messages.shift
        tick = @tick_count + 1
        next_message_lines.each_with_index do |line, index|
          duration = line.size * 2
          Cutscene.schedule_element @battle.cutscene, tick: tick, type: :message, duration: duration, line: line, line_index: index
          tick += duration
        end
        Cutscene.schedule_element @battle.cutscene, tick: tick, type: :wait_for_advance_message, duration: 1
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

    def prepare_action_menu
      options = @battle.player.emojimon[:attacks].map_with_index { |attack, index|
        {
          action: { type: :attack, attack: attack[:id] },
          sprite: attack[:sprite],
          rect: { x: 2 + (index * 16), y: 2, w: 14, h: 14 }
        }
      }
      options << {
        action: { type: :exchange },
        sprite: { path: 'sprites/icons/exchange.png' },
        rect: { x: 48, y: 2, w: 14, h: 14 }
      }

      @action_menu = MenuNavigation.new(options, horizontal: true)
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
        render_action_menu(screen)
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

    def render_action_menu(screen)
      @action_menu.children.each do |option|
        bg_color = option.selected ? { r: 0x61, g: 0xa2, b: 0xff } : { r: 0xb2, g: 0xb2, b: 0xb2 }
        screen.primitives << option[:rect].merge(path: 'sprites/icons/background.png').merge!(bg_color)
        screen.primitives << option[:rect].merge(option[:sprite])
      end
    end

    def queue_message(message_string, tick: @tick_count + 1)
      lines = @font.split_into_lines(message_string, line_w: 62)
      @battle.message_window.queued_messages.concat lines.each_slice(2).to_a
      tick + 1
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

    def queue_next_turn_resolution(tick: @tick_count + 1)
      combatant = @battle.turn_order.shift
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
          damage = BattleSystem.calc_damage(player_emojimon, opponent_emojimon, attack)
          queue_message("#{player_emojimon[:name]} uses #{attack[:name]}!", tick: tick)
          queue_player_attack_animation(tick: tick + 20)
          target_hp = (opponent_emojimon[:hp] - damage[:total_amount]).clamp(0, opponent_emojimon[:max_hp])
          after_finished_tick = queue_hp_bar_animation(opponent_emojimon, target_hp, tick: tick + 20)
          queue_effectiveness_message(damage, tick: after_finished_tick)
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
          damage = BattleSystem.calc_damage(opponent_emojimon, player_emojimon, attack)
          queue_message("#{opponent_emojimon[:name]} uses #{attack[:name]}!", tick: tick)
          queue_opponent_attack_animation(tick: tick + 20)
          target_hp = (player_emojimon[:hp] - damage[:total_amount]).clamp(0, player_emojimon[:max_hp])
          after_finished_tick = queue_hp_bar_animation(player_emojimon, target_hp, tick: tick + 20)
          queue_effectiveness_message(damage, tick: after_finished_tick)
        when :exchange
          @battle.state = :player_chooses_action # TODO: Implemennt
        end
        opponent.selected_action = nil
      end
      after_finished_tick
    end

    def queue_effectiveness_message(damage, tick: @tick_count + 1)
      if damage[:multiplier] < 1
        queue_message('It\'s not too effective...', tick: tick)
      elsif damage[:multiplier] > 1
        queue_message('It\'s mega effective!', tick: tick)
      else
        tick
      end
    end

    def queue_player_attack_animation(tick: @tick_count + 1)
      duration = 20
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :shake, target: @battle.opponent.sprite, duration: duration
      tick + duration
    end

    def queue_opponent_attack_animation(tick: @tick_count + 1)
      duration = 20
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :shake, target: @battle.player.sprite, duration: duration
      tick + duration
    end

    def queue_hp_bar_animation(emojimon, target_hp, tick: @tick_count + 1)
      start_hp = emojimon[:hp]
      duration = (target_hp.abs - start_hp.abs).abs * 3
      Cutscene.schedule_element @battle.cutscene,
                                tick: tick,
                                type: :animate_hp,
                                emojimon: emojimon,
                                start_hp: start_hp,
                                target_hp: target_hp,
                                duration: duration

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
        @battle.opponent_stats_visible = true if element[:elapsed_ticks] == element[:duration] - 1
      end
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
        @battle.player_stats_visible = true if element[:elapsed_ticks] == element[:duration] - 1
      end
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

    def animate_hp_tick(_args, element)
      animated_hp = element[:elapsed_ticks].remap(0, element[:duration], element[:start_hp], element[:target_hp]).floor
      element[:emojimon][:hp] = animated_hp
    end
  end
end
