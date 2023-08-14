module Music
  class << self
    TRACKS = {
      main_menu: {
        input: 'music/colosseum.mp3',
        gain: 0.4
      },
      battle: {
        input: 'music/they_be_angry.mp3',
        gain: 0.4
      }
    }

    def play(args, track_id)
      return if args.audio[:bgm]&.input == TRACKS[track_id][:input]

      args.audio[:bgm] = { looping: true }.merge TRACKS[track_id]
    end

    def stop(args)
      args.audio.delete :bgm
    end
  end
end
