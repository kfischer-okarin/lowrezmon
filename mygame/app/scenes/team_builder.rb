module Scenes
  class TeamBuilder
    attr_reader :chosen_emojimons

    def initialize(args, previous_scene:)
      @previous_scene = previous_scene
      @font = build_pokemini_font
      @fatnumbers_font = build_pokemini_fatnumbers_font

      @team = args.state.team ||= [nil, nil, nil]

      @slots = @team.size.times.map do |i|
        button(x: 2 + i * 20, y: 30, w: 18, h: 18, bgcolor: Palette::WINDOW_BG_COLOR)
      end

      @slots_menu = MenuNavigation.new @slots, horizontal: true

      @go_button = button(x: 23, y: 1, h: 10, w: 18, text: "Go!", color: Palette::WHITE, bgcolor: Palette::BLACK)
      @ui = MenuNavigation.new([@slots_menu, @go_button])
      @chosen_emojimons = nil
    end

    def update(args)
      @ui.tick(args)

      if @ui.selected_child == @slots_menu
        @slots_menu.tick(args)
      end

      if @ui.selection_changed? || @slots_menu.selection_changed?
        SFX.play args, :cursor_move
      end

      if Controls.confirm?(args.inputs)
        SFX.play args, :confirm

        case @ui.selected_child
        when @slots_menu
          args.state.team_builder.selected_slot = @slots_menu.selected_index
          $next_scene = Scenes::EmojimonList.new(previous_scene: self)
        when @go_button
          @chosen_emojimons = args.state.team.map { |emojimon|
            { species: emojimon, hp: SPECIES[emojimon].max_hp }
          }

          $next_scene = @previous_scene
        end
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
        **Palette::BATTLE_BG_COLOR
      }.sprite!

      screen.primitives << @font.build_label(text: "Your team!", x: 8, y: 54)

      if @ui.selected_child == @slots_menu
        selected_slot = @slots_menu.selected_child.rect
        screen.primitives << selected_slot.to_border(
          x: selected_slot.x - 1,
          y: selected_slot.y - 1,
          w: selected_slot.w + 2,
          h: selected_slot.h + 2,
          **Palette::BLACK
        )
      end

      screen.primitives << @slots.map(&:sprite)
      screen.primitives << @team.map.with_index { |name, i|
        next unless name
        emoji = SPECIES[name]
        emoji.sprite.to_sprite(x: 3 + i * 20, y: 31)
      }

      screen.primitives << if @ui.selected_child == @go_button
        button(text: "Go!", color: Palette::WHITE, bgcolor: Palette::BLACK, **@go_button[:rect]).sprite
      else
        button(text: "Go!", bgcolor: Palette::WHITE, color: Palette::BLACK, **@go_button[:rect]).sprite
      end
      # buttons
    end

    private

    def go!
    end

    def button(x:, y:, w:, h:, text: nil, color: Palette::WHITE, bgcolor: Palette::BLACK)
      rect = {x: x, y: y, h: h, w: w}

      {
        rect: rect,
        sprite: [
          rect.to_solid(bgcolor),
          (@font.build_label(text: text, x: x + 2, y: y + 2, **color) if text)
        ].compact
      }
    end
  end
end
