module Scenes
  class EmojimonList
    def initialize(previous_scene:, selected_emoji: nil)
      @previous_scene = previous_scene
      @font = build_pokemini_font
      @fatnumbers_font = build_pokemini_fatnumbers_font
      @emojimons = SPECIES
      @emojimons_menu = MenuNavigation.new(
        SPECIES.keys,
        loop: false,
        selected_index: SPECIES.keys.index(selected_emoji) || 0
      )
    end

    def update(args)
      @emojimons_menu.tick(args)
      @selected_emoji = @emojimons[@emojimons_menu.selected_child]

      if @emojimons_menu.selection_changed?
        SFX.play args, :cursor_move
      end

      if Controls.confirm?(args.inputs)
        SFX.play args, :confirm
        team = args.state.team
        slot = args.state.team_builder.selected_slot
        team[slot] = @emojimons_menu.selected_child

        $next_scene = @previous_scene
      elsif Controls.cancel?(args.inputs)
        SFX.play args, :cancel
        $next_scene = @previous_scene
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
        r: 0xF0, g: 0xD0, b: 0xB0
      }.sprite!

      screen.primitives << @font.build_label(text: @selected_emoji.name, x: 22, y: 54)
      screen.primitives << {x: 22, y: 52, h: 1, w: 16}.solid!

      screen.primitives << @font.build_label(text: "Type", x: 22, y: 44,  r:  60, g: 60, b: 60)
      screen.primitives << type_label(@selected_emoji.type, x: 22, y: 35)

      y = 24
      screen.primitives << @font.build_label(text: "Att.", x: 22, y: y, r:  60, g: 60, b: 60)
      screen.primitives << @fatnumbers_font.build_label(text: "#{@selected_emoji.attack}", x: 52, y: y)
      y -= 8
      screen.primitives << @font.build_label(text: "Def.", x: 22, y: y,  r: 60, g: 60, b: 60)
      screen.primitives << @fatnumbers_font.build_label(text: "#{@selected_emoji.defense}", x: 52, y: y)
      y -= 8
      screen.primitives << @font.build_label(text: "Speed", x: 22, y: y, r: 60, g: 60, b: 60)
      screen.primitives << @fatnumbers_font.build_label(text: "#{@selected_emoji.speed}", x: 52, y: y)



      #emojis and selection box
      screen.primitives << visible_emojies.map.with_index do |emoji, index|
        if @selected_emoji == emoji
          screen.primitives << [
            {x: 0, y: 40 - index * 18, h: 18, w: 18, **Palette::WHITE}.solid!,
            {x: 1, y: 41 - index * 18, h: 16, w: 16, **Palette::WHITE}.solid!
          ]
        end

        emoji[:sprite].to_sprite(x: 1, y: 41 - index * 18)
      end

      # list scrollers
      screen.primitives << {
        x: 6, y: 57, w: 5, h: 3, path: "sprites/message_wait_triangle.png",
        r: 0, g: 0, b: 0, flip_vertically: 1
      }.sprite!
      screen.primitives << {
        x: 6, y: 1, w: 5, h: 3, path: "sprites/message_wait_triangle.png",
        r: 0, g: 0, b: 0
      }.sprite!
    end

    private

    def visible_emojies
      selected = @emojimons_menu.selected_index
      case selected
      when 0
        @emojimons.values.first(3)
      when @emojimons.size - 1
        @emojimons.values.last(3)
      else
        @emojimons.values[selected - 1, 3]
      end
    end

    def type_label(type, x:, y:)
      label = type.to_s.capitalize
      label_w = @font.string_w(label)
      [
        { x: x, y: y, w: label_w + 2, h: 8, path: :pixel }.sprite!(Palette::TYPE_COLOR[type]),
        @font.build_label(text: label, x: x + 1, y: y + 1, **Palette::WHITE)
      ]
    end
  end
end
