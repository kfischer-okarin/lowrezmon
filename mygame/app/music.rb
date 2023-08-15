module Music
  class << self
    def play(args, track_id)
      case track_id
      when :main_menu
        file = 'music/colosseum.mp3'
        return if args.audio[:bgm]&.input == file

        args.audio[:bgm] = {
          input: file,
          gain: 0.4,
          looping: true
        }
      when :battle
        file = 'music/they_be_angry.mp3'
        return if args.audio[:bgm]&.input == file

        args.audio[:bgm] = {
          input: file,
          gain: 0.4,
          looping: true
        }
      end
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
