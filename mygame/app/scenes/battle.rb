module Scenes
  class Battle
    def initialize(args, player_trainer:, opponent_trainer:)
      @font = build_pokemini_font

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

      @message_window = MessageWindow.new

      battle.cutscene = Cutscene.build_empty
      battle.state = :battle_start
      battle.queued_states_after_messages = []
      battle.turn_order = nil
    end

    def update(args)
      @battle = args.state.battle
      @tick_count = args.tick_count

      cutscene_was_running = !Cutscene.finished?(@battle.cutscene)
      Cutscene.tick args, @battle.cutscene, handler: self if cutscene_was_running

      message_window_was_active = @message_window.active?
      @message_window.update(args) if message_window_was_active
      return if cutscene_was_running || message_window_was_active

      player = @battle.player
      opponent = @battle.opponent
      case @battle.state
      when :battle_start
        args.audio[:bgm] = {
          input: 'music/they_be_angry.mp3',
          gain: 0.3,
          looping: true
        }
        queue_message("#{opponent.trainer[:name]} wants to battle!")
        player.emojimon = build_emojimon player.trainer[:emojimons].first
        opponent.emojimon = build_emojimon opponent.trainer[:emojimons].first
        @battle.queued_states_after_messages = [:opponent_sends_emojimon, :player_sends_emojimon, :player_chooses_action]
        @battle.state = :go_to_next_state_after_messages
      when :opponent_sends_emojimon
        queue_message("#{opponent.trainer[:name]} sends #{opponent.emojimon[:name]}!")
        queue_opponent_emojimon_appearance
        @battle.state = :go_to_next_state_after_messages
      when :player_sends_emojimon
        queue_message("Go, #{player.emojimon[:name]}!")
        queue_player_emojimon_appearance
        prepare_action_menu
        @battle.state = :go_to_next_state_after_messages
      when :player_chooses_action
        @action_menu.tick(args)
        if @action_menu.selection_changed?
          SFX.play args, :cursor_move
        end
        if Controls.confirm?(args.inputs)
          SFX.play args, :confirm
          if @action_menu.selected_child[:action][:type] == :select_emojimon
            @battle.state = :player_chooses_emojimon
            return
          end

          player.selected_action = @action_menu.selected_child[:action]
          @battle.state = :first_turn
        end
      when :first_turn
        opponent.selected_action = BattleSystem.choose_opponent_action(opponent, player)
        @battle.turn_order = BattleSystem.determine_turn_order(player, opponent)

        queue_next_turn_resolution
        @battle.state = :go_to_next_state_after_messages
      when :second_turn
        queue_next_turn_resolution
        @battle.state = :go_to_next_state_after_messages
      when :opponent_emojimon_dead
        queue_message("#{opponent.emojimon[:name]} disintegrates!")
        queue_opponent_emojimon_death
        if remaining_emojimon_count(opponent).positive?
          opponent.emojimon = build_emojimon BattleSystem.choose_next_opponent_emojimon(opponent, player)
          @battle.queued_states_after_messages = [:opponent_sends_emojimon, :player_chooses_action]
        else
          @battle.queued_states_after_messages = [:battle_won]
        end
        @battle.state = :go_to_next_state_after_messages
      when :player_emojimon_dead
        queue_message("#{player.emojimon[:name]} disintegrates!")
        queue_player_emojimon_death
        case remaining_emojimon_count(player)
        when 0
          @battle.queued_states_after_messages = [:battle_lost]
        when 1
          last_alive_emojimon = player.trainer[:emojimons].find { |emojimon| emojimon[:hp].positive? }
          player.emojimon = build_emojimon last_alive_emojimon
          @battle.queued_states_after_messages = [:player_sends_emojimon, :player_chooses_action]
        else
          @battle.queued_states_after_messages = [:player_chooses_emojimon]
        end
        @battle.state = :go_to_next_state_after_messages
      when :player_chooses_emojimon
        @select_emojimon_scene = Scenes::ChangeEmojimon.new(
          args,
          battle_scene: self,
          player_trainer: player.trainer,
          current_emojimon: player.emojimon[:trainer_emojimon]
        )
        $next_scene = @select_emojimon_scene
        @battle.state = :after_select_emojimon
      when :after_select_emojimon
        if @select_emojimon_scene.chosen_emojimon
          if player.emojimon[:hp].zero?
            player.emojimon = build_emojimon @select_emojimon_scene.chosen_emojimon
            @battle.state = :player_sends_emojimon
            @battle.queued_states_after_messages = [:player_chooses_action]
          else
            player.selected_action = { type: :exchange, new_emojimon: @select_emojimon_scene.chosen_emojimon }
            @battle.state = :first_turn
          end
        else
          @battle.state = :player_chooses_action
        end
      when :battle_won
        queue_message("#{opponent.trainer[:name]} is defeated!")
        # @previous_scene.battle_won
        @battle.queued_states_after_messages = [:return_to_previous_scene]
        @battle.state = :go_to_next_state_after_messages
      when :battle_lost
        queue_message('You were defeated!')
        # @previous_scene.battle_lost
        @battle.queued_states_after_messages = [:return_to_previous_scene]
        @battle.state = :go_to_next_state_after_messages
      when :return_to_previous_scene
        # $next_scene = @previous_scene
      when :go_to_next_state_after_messages
        @battle.state = @battle.queued_states_after_messages.shift
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel
      }.sprite!(Palette::BATTLE_BG_COLOR)
      opponent = @battle.opponent
      screen.primitives << opponent.sprite
      if @battle.opponent_stats_visible
        UI.render_stats_display(screen, opponent.emojimon, x: 1, y: 52, with_hp_numbers: false)
      end
      player = @battle.player
      screen.primitives << player.sprite
      if @battle.player_stats_visible
        UI.render_stats_display(screen, player.emojimon, x: 32, y: 20, with_hp_numbers: true)
      end
      render_window(screen)
    end

    private

    def remaining_emojimon_count(combatant)
      combatant.trainer[:emojimons].count { |emojimon| emojimon[:hp].positive? }
    end

    def build_emojimon(emojimon)
      result = emojimon.merge(SPECIES[emojimon[:species]])
      result[:attacks] ||= []
      result[:attacks] = result[:attacks].map { |attack| ATTACKS[attack].merge(id: attack) }
      result[:trainer_emojimon] = emojimon
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
        action: { type: :select_emojimon },
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
        x: 0, y: 0, w: 64, h: 18, path: :pixel
      }.sprite!(Palette::WINDOW_BG_COLOR)

      if @message_window.active?
        @message_window.render(screen)
      elsif @battle.state == :player_chooses_action
        render_action_menu(screen)
      end
    end

    def render_action_menu(screen)
      @action_menu.children.each_with_index do |option, index|
        bg_color = if index == @action_menu.selected_index
                     Palette::BATTLE_SELECTED_ACTION_COLOR
                   else
                     Palette::BATTLE_UNSELECTED_ACTION_COLOR
                   end
        screen.primitives << option[:rect].merge(path: 'sprites/icons/background.png').merge!(bg_color)
        screen.primitives << option[:rect].merge(option[:sprite])
      end
    end

    def queue_message(message, tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :queue_message, message: message, duration: 1
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
      @battle.queued_states_after_messages = @battle.state == :first_turn ? [:second_turn] : [:player_chooses_action]
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
          after_finished_tick = queue_effectiveness_message(damage, tick: after_finished_tick)
          @battle.queued_states_after_messages = [:opponent_emojimon_dead] if target_hp.zero?
        when :exchange
          queue_message("Come back, #{player_emojimon[:name]}!", tick: tick)
          queue_player_emojimon_retreat
          player.emojimon = build_emojimon action[:new_emojimon]
          @battle.queued_states_after_messages.unshift(:player_sends_emojimon)
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
          after_finished_tick = queue_effectiveness_message(damage, tick: after_finished_tick)
          @battle.queued_states_after_messages = [:player_emojimon_dead] if target_hp.zero?
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
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :play_sfx, id: :hit, duration: 1
      tick + duration
    end

    def queue_opponent_attack_animation(tick: @tick_count + 1)
      duration = 20
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :shake, target: @battle.player.sprite, duration: duration
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :play_sfx, id: :hit, duration: 1
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

    def queue_opponent_emojimon_death(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene,
                                tick: tick,
                                type: :fadeout_sprite,
                                sprite: @battle.opponent.sprite,
                                duration: 60
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :play_sfx, id: :death, duration: 1
    end

    def queue_player_emojimon_death(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene,
                                tick: tick,
                                type: :fadeout_sprite,
                                sprite: @battle.player.sprite,
                                duration: 60
      Cutscene.schedule_element @battle.cutscene, tick: tick, type: :play_sfx, id: :death, duration: 1
    end

    def queue_player_emojimon_retreat(tick: @tick_count + 1)
      Cutscene.schedule_element @battle.cutscene,
                                tick: tick,
                                type: :emojimon_retreat,
                                dx: -30,
                                sprite: @battle.player.sprite,
                                duration: 20
    end

    def queue_message_tick(_args, element)
      @message_window.queue_message element[:message]
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
          duration: element[:duration] - 1
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
          duration: element[:duration] - 1
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
      element[:emojimon][:hp] = element[:elapsed_ticks].remap(
        0, element[:duration],
        element[:start_hp], element[:target_hp]
      ).floor
      element[:emojimon][:trainer_emojimon][:hp] = element[:emojimon][:hp]
    end

    def fadeout_sprite_tick(_args, element)
      sprite = element[:sprite]
      sprite[:a] = element[:elapsed_ticks].remap(
        0, element[:duration],
        255, 0
      ).floor
    end

    def emojimon_retreat_tick(_args, element)
      sprite = element[:sprite]
      element[:original_x] ||= sprite[:x]
      sprite[:x] = element[:elapsed_ticks].remap(
        0, element[:duration],
        element[:original_x],  element[:original_x] + element[:dx]
      ).floor
      if element[:elapsed_ticks] == element[:duration] - 1
        sprite[:a] = 0
      end
    end

    def play_sfx_tick(args, element)
      SFX.play(args, element[:id])
    end
  end
end
