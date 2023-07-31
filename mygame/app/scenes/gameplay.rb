module Scenes
  class Gameplay
    def update(inputs, state)
    end

    def render(screen, state)
      screen.primitives << build_label(
        x: 32, y: 32, text: 'Hello, Lowrez!', r: 255, g: 255, b: 255,
        alignment_enum: 1, vertical_alignment_enum: 1
      )
    end
  end
end
