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
    end

    def update(args)
      @state = args.state.select_emojimon

      @emojimon_menu.tick(args)
      SFX.play(args, :cursor_move) if @emojimon_menu.selection_changed?

      if Controls.confirm?(args.inputs)
        SFX.play(args, :confirm)
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel
      }.sprite!(Palette::SELECT_EMOJIMON_BG_COLOR)

      @state.emojimons.each_with_index do |emojimon, index|
        render_emojimon(screen, emojimon, x: 4, y: 42 - (index * 20), selected: index == @emojimon_menu.selected_index)
      end
    end

    def render_emojimon(screen, emojimon, x:, y:, selected: false)
      trainer_emojimon = emojimon
      if selected
        screen.primitives << {
          x: x, y: y, w: 56, h: 20, path: :pixel
        }.sprite!(Palette::SELECTED_COLOR)
      end
      emojimon = SPECIES[emojimon[:species]].merge(emojimon)
      screen.primitives << emojimon[:sprite].to_sprite(x: x + 2, y: y + 2)
      UI.render_stats_display(screen, emojimon, x: x + 24, y: y + 1, with_hp_numbers: true)

      if trainer_emojimon == @state.current_emojimon
        screen.primitives << {
          x: x + 1, y: y + 1, w: 18, h: 18
        }.border!(Palette::CURRENT_EMOJIMON_COLOR)
      end
    end
  end
end
