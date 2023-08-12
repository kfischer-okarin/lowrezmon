module Scenes
  class SelectEmojimon
    attr_reader :chosen_emojimon

    def initialize(args, battle_scene:, player_trainer:, current_emojimon:)
      @battle_scene = battle_scene
      @font = build_pokemini_font

      state = args.state.select_emojimon = args.state.new_entity(:select_emojimon)

      state.emojimons = player_trainer[:emojimons].dup
      state.emojimons.delete(current_emojimon)
      state.emojimons.unshift(current_emojimon)
      state.current_emojimon = current_emojimon

      @emojimon_menu = MenuNavigation.new(state.emojimons)
      @chosen_emojimon = nil
      @message_window = MessageWindow.new
      @confirm_menu = MenuNavigation.new([
        { value: :yes, text: 'Yes' },
        { value: :no, text: 'No' }
      ])
      @mode = :select
    end

    def update(args)
      @state = args.state.select_emojimon

      case @mode
      when :select
        @emojimon_menu.tick(args)
        SFX.play(args, :cursor_move) if @emojimon_menu.selection_changed?

        if Controls.confirm?(args.inputs)
          SFX.play(args, :confirm)
          selected_emojimon_data = emojimon_data(@emojimon_menu.selected_child)
          if @emojimon_menu.selected_child[:hp].zero?
            @mode = :invalid_selection
            @message_window.queue_message "#{selected_emojimon_data[:name]} is gone!"
          elsif @emojimon_menu.selected_child == @state.current_emojimon
            @mode = :invalid_selection
            @message_window.queue_message 'Already in battle!'
          else
            @mode = :confirm
            @confirm_menu.selected_index = 0
            @message_window.display_message "Send #{selected_emojimon_data[:name]}?"
          end
        elsif Controls.cancel?(args.inputs)
          if @state.current_emojimon[:hp].zero?
            @mode = :invalid_selection
            @message_window.queue_message 'You must choose one!'
          else
            SFX.play(args, :cancel)
            $next_scene = @battle_scene
          end
        end
      when :confirm
        @confirm_menu.tick(args)
        SFX.play(args, :cursor_move) if @confirm_menu.selection_changed?

        if Controls.confirm?(args.inputs)
          SFX.play(args, :confirm)
          case @confirm_menu.selected_child[:value]
          when :yes
            @chosen_emojimon = @emojimon_menu.selected_child
            $next_scene = @battle_scene
          when :no
            @mode = :select
            @message_window.clear_message
          end
        elsif Controls.cancel?(args.inputs)
          SFX.play(args, :cancel)
          @mode = :select
          @message_window.clear_message
        end
      when :invalid_selection
        @message_window.update(args)
        if !@message_window.active?
          @mode = :select
        end
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel
      }.sprite!(Palette::SELECT_EMOJIMON_BG_COLOR)

      @state.emojimons.each_with_index do |emojimon, index|
        render_emojimon(screen, emojimon, x: 4, y: 42 - (index * 20), selected: index == @emojimon_menu.selected_index)
      end

      if @mode == :confirm || @mode == :invalid_selection
        screen.primitives << {
          x: 0, y: 0, w: 64, h: 64, path: :pixel, r: 0, g: 0, b: 0, a: 100
        }.sprite!
        @message_window.render(screen)
      end
      if @mode == :confirm
        menu_rect = { x: 40, y: 18, w: 24, h: 18 }
        screen.primitives << menu_rect.merge(path: :pixel).sprite!(Palette::WINDOW_BG_COLOR)
        screen.primitives << menu_rect.merge(r: 0, g: 0, b: 0).border!
        @confirm_menu.children.each_with_index do |option, index|
          y = menu_rect.top - 9 - (8 * index)
          if @confirm_menu.selected_index == index
            screen.primitives << {
              x: menu_rect.x + 1,
              y: y,
              w: menu_rect.w - 2,
              h: 8,
              path: :pixel
            }.sprite!(Palette::SELECTED_COLOR)
          end
          screen.primitives << @font.build_label(
            x: menu_rect.x + 2,
            y: y + 1,
            text: option[:text]
          )
        end
      end
    end

    def render_emojimon(screen, emojimon, x:, y:, selected: false)
      trainer_emojimon = emojimon
      if selected
        screen.primitives << {
          x: x, y: y, w: 56, h: 20, path: :pixel
        }.sprite!(Palette::SELECTED_COLOR)
      end
      emojimon = emojimon_data(emojimon).merge(emojimon)
      screen.primitives << emojimon[:sprite].to_sprite(x: x + 2, y: y + 2)
      UI.render_stats_display(screen, emojimon, x: x + 24, y: y + 1, with_hp_numbers: true)

      if trainer_emojimon == @state.current_emojimon
        screen.primitives << {
          x: x + 1, y: y + 1, w: 18, h: 18
        }.border!(Palette::CURRENT_EMOJIMON_COLOR)
      end
    end

    def emojimon_data(emojimon)
      SPECIES[emojimon[:species]]
    end
  end
end
