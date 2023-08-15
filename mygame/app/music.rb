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
        file = 'music/they_be_angry_loop.ogg'
        return if args.audio[:bgm]&.input == file

        args.audio[:bgm] = {
          input: file,
          gain: 0.4,
          looping: true,
          paused: true,
          start_at_tick: args.tick_count + 160
        }

        args.audio[:bgm_intro] = {
          input: 'music/they_be_angry_intro.ogg',
          gain: 0.4
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

        if bgm[:paused] && bgm[:start_at_tick] <= args.tick_count
          bgm[:paused] = false
        end
      end
    end
  end
end
