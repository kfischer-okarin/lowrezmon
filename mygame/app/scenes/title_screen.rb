module Scenes
  class TitleScreen
    def initialize(args)
      @font = build_pokemini_font
      @cutscene = Cutscene.build_empty
      @state = :title_appearing
      @bg_color = Palette::BLACK
      @bg_dither_color = Palette::DARK_GREY
      @title_background = nil
      @title_top = nil
      @title_bottom = nil
      @flash_overlay = nil
    end

    def update(args)
      unless Cutscene.finished?(@cutscene)
        Cutscene.tick args, @cutscene, handler: self
        return
      end

      case @state
      when :title_appearing
        Cutscene.schedule_element @cutscene, tick: args.tick_count + 1, type: :title_top, duration: 150
        Cutscene.schedule_element @cutscene, tick: args.tick_count + 125, type: :music
        Cutscene.schedule_element @cutscene, tick: args.tick_count + 151, type: :flash, duration: 120
        Cutscene.schedule_element @cutscene, tick: args.tick_count + 151, type: :title_bottom_appears
      when :waiting_for_button
        if Controls.confirm?(args.inputs)
          SFX.play args, :hit
          Cutscene.schedule_element @cutscene, tick: args.tick_count + 1, type: :fade_out, duration: 60
          @state = :go_to_menu
        end
      when :go_to_menu
        $next_scene = Scenes::MainMenu.new args
      end
    end

    def render(screen, state)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: :pixel,
      }.sprite!(@bg_color)
      screen.primitives << {
        x: 0, y: 0, w: 64, h: 64, path: 'sprites/bg_dither.png',
      }.sprite!(@bg_dither_color)

      screen.primitives << @title_background
      screen.primitives << @title_top
      screen.primitives << @title_bottom

      if @state == :waiting_for_button
        if state.tick_count % 60 < 30
          screen.primitives << @font.build_label(text: 'Press SPACE', x: 32, y: 1, alignment_enum: 1, r: 255, g: 255, b: 255)
        end
      end

      screen.primitives << @flash_overlay
    end

    def title_top_tick(_args, element)
      case element[:elapsed_ticks]
      when 0
        @title_top = {
          x: 0, y: 32, w: 64, h: 64,
          path: 'sprites/title_top.png',
          r: 0, g: 0, b: 0
        }.sprite!
        element[:animation] = Animations.lerp(
          @title_top,
          to: { y: 0 },
          duration: element[:duration] - 1
        )
      else
        Animations.perform_tick element[:animation]
        if element[:elapsed_ticks] == element[:duration] - 1
          @title_top.merge!(r: 255, g: 255, b: 255)
          @state = :waiting_for_button
        end
      end
    end

    def music_tick(args, element)
      Music.play args, :main_menu
    end

    def flash_tick(_args, element)
      case element[:elapsed_ticks]
      when 0,1,4,5,8
        @flash_overlay = {
          x: 0, y: 0, w: 64, h: 64,
          path: :pixel,
          r: 255, g: 255, b: 255, a: 255
        }.sprite!
      when 2,3,6,7
        @flash_overlay = {
          x: 0, y: 0, w: 64, h: 64,
          path: :pixel,
          r: 0, g: 0, b: 0, a: 0
        }.sprite!
      when 15
        element[:animation] = Animations.lerp(
          @flash_overlay,
          to: { a: 0 },
          duration: element[:duration] - 6
        )
      else
        Animations.perform_tick element[:animation] if element[:animation]
      end
    end

    def title_bottom_appears_tick(_args, element)
      @title_bottom = {
        x: 0, y: 0, w: 64, h: 64,
        path: 'sprites/title_bottom.png',
      }.sprite!
      @bg_color = Palette::BLACK
      @bg_dither_color = Palette::BLACK
      @title_background = {
        x: 0, y: 0, w: 64, h: 64,
        path: 'sprites/title_bg.png',
      }.sprite!
    end

    def fade_out_tick(args, element)
      case element[:elapsed_ticks]
      when 0
        @flash_overlay = {
          x: 0, y: 0, w: 64, h: 64,
          path: :pixel,
          r: 0, g: 0, b: 0, a: 0
        }.sprite!
      when 1
        element[:animation] = Animations.lerp(
          @flash_overlay,
          to: { a: 255 },
          duration: element[:duration] - 6
        )
      when 2
        @flash_overlay = {
          x: 0, y: 0, w: 64, h: 64,
          path: :pixel,
          r: 0, g: 0, b: 0, a: 0
        }.sprite!
      when 5
        element[:animation] = Animations.lerp(
          @flash_overlay,
          to: { a: 255 },
          duration: element[:duration] - 6
        )
      else
        Animations.perform_tick element[:animation] if element[:animation]
      end
    end
  end
end
