module Scenes
  class MainMenu
    def initialize(args)
      @font = build_pokemini_font
      @menu = MenuNavigation.new [
        { label: 'Bronze Cup', id: :bronze_cup, color: { r: 0xC3, g: 0x72, b: 0x00 } }
      ]
    end

    def update(args)
      @menu.tick(args)

      if @menu.selection_changed?
        SFX.play args, :cursor_move
      end

      if Controls.confirm?(args.inputs)
        SFX.play args, :confirm
        $next_scene = Scenes::Battle.new(
          args,
          player_trainer: {
            name: 'GREEN',
            emojimons: [
              { species: :kissy, hp: 26 }
            ]
          },
          opponent_trainer: {
            name: 'VIOLA',
            emojimons: [
              { species: :angry, hp: 26 }
            ]
          }
        )
        # $next_scene = Scenes::Tournament.new args, tournament: @menu.selected_item[:id]
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
      }.sprite!(Palette::MAIN_MENU_BG_COLOR)

      @menu.children.each_with_index do |item, index|
        y = 50 - index * 10
        label_w = @font.string_w(item[:label])
        screen.primitives << {
          x: 2, y: y, w: 60, h: 9, path: 'sprites/main_menu_button.png',
        }.sprite!(item[:color])
        screen.primitives << @font.build_label(text: item[:label], x: 32, y: y + 1, alignment_enum: 1)
        if @menu.selected_index == index
          if state.tick_count % 60 < 30
            screen.primitives << {
              x: 2, y: y, w: 60, h: 9, path: 'sprites/main_menu_button_select_border.png',
            }
          end
        end
      end
    end
  end
end
