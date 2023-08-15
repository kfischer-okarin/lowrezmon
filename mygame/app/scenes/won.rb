module Scenes
  class Won
    def initialize()
      @font = build_pokemini_font
      @fatnumbers_font = build_pokemini_fatnumbers_font
    end

    def update(args)
      Music.play args, :main_menu

      if Controls.confirm?(args.inputs)
        SFX.play args, :hit
        $next_scene = Scenes::MainMenu.new args
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
        **Palette::BLACK
      }.sprite!

      screen.primitives << {x: 16, y:24, w: 32, h: 32, path: "sprites/cup.png"}.sprite!
      screen.primitives << @font.build_label(text: "You WON!", x: 32, y: 14, alignment_enum: 1, **Palette::WHITE)
      screen.primitives << @font.build_label(text: 'Press SPACE', x: 32, y: 1, alignment_enum: 1, **Palette::WHITE)
    end
  end
end
