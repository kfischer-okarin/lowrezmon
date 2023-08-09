module SFX
  class << self
    SOUNDS = {
      confirm: {
        input: 'sfx/select.wav',
      },
      cursor_move: {
        input: 'sfx/cursor_move.wav'
      },
      death: {
        input: 'sfx/death.wav'
      },
      hit: {
        input: 'sfx/hit.wav'
      }
    }

    def play(args, sound_id)
      args.audio[:sfx] = { looping: false }.merge SOUNDS[sound_id]
    end
  end
end
