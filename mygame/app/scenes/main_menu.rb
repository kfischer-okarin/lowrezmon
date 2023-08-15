module Scenes
  class MainMenu
    def initialize(args)
      SaveData.load(args)
      @font = build_pokemini_font
      won_tournaments = SaveData.retrieve(args, :won_tournaments)
      @menu = MenuNavigation.new TOURNAMENTS.map_with_index { |tournament, index|
        {
          tournament: tournament,
          label: tournament[:name],
          color: tournament[:color],
          won: won_tournaments.include?(tournament[:name]),
          unlocked: index.zero? || won_tournaments.include?(TOURNAMENTS[index - 1][:name]),
        }
      }
    end

    def update(args)
      @menu.tick(args)

      if @menu.selection_changed?
        SFX.play args, :cursor_move
      end

      if Controls.confirm?(args.inputs)
        if @menu.selected_child[:unlocked]
          SFX.play args, :confirm
          $next_scene = Scenes::Tournament.new args, tournament: @menu.selected_child[:tournament]
        else
          SFX.play args, :cancel
        end
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel
      }.sprite!(Palette::MAIN_MENU_BG_COLOR)

      @menu.children.each_with_index do |item, index|
        y = 50 - (index * 10)
        color = item[:unlocked] ? item[:color] : Palette::DARK_GREY
        screen.primitives << {
          x: 2, y: y, w: 60, h: 9, path: 'sprites/main_menu_button.png',
        }.sprite!(color)
        screen.primitives << @font.build_label(text: item[:label], x: 32, y: y + 1, alignment_enum: 1)
        if @menu.selected_index == index
          if state.tick_count % 60 < 30
            screen.primitives << {
              x: 2, y: y, w: 60, h: 9, path: 'sprites/main_menu_button_select_border.png',
            }
          end
        end
      end

      @menu.children.each_with_index do |item, index|
        if item[:won]
          screen.primitives << {
            x: 3 + (index * 20), y: 4, w: 18, h: 18, path: 'sprites/trophy.png'
          }.sprite!(item[:color])
        end
      end
    end
  end
end
