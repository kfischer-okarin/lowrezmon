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

    def fade_out(args, duration: 60)
      bgm = args.audio[:bgm]
      return unless bgm

      bgm[:fade_out_speed] = bgm[:gain] / duration
    end

    def tick(args)
      bgm = args.audio[:bgm]
      if bgm
        bgm[:gain] -= bgm[:fade_out_speed] if bgm[:fade_out_speed]
        stop(args) if bgm[:gain] <= 0
      end
    end
  end
end
