module Scenes
  class Tournament
    def initialize(args, tournament:)
      @state = :build_team
      @tournament = tournament
      @team_builder = Scenes::TeamBuilder.new(args, previous_scene: self)
      @battle_index = 0
    end

    def update(args)
      case @state
      when :build_team
        $next_scene = @team_builder
        @state = :prepare_player
      when :prepare_player
        @player = {
          name: 'GREEN',
          emojimons: @team_builder.chosen_emojimons
        }
        @state = :start_battle
      when :start_battle
        @battle = Scenes::Battle.new(
          args,
          previous_scene: self,
          player_trainer: @player,
          opponent_trainer: @tournament[:opponents][@battle_index]
        )
        $next_scene = @battle
        @state = :battle_result
      when :battle_result
        if @battle.result == :won
          if @battle_index < @tournament[:opponents].size - 1
            @battle_index += 1
            restore_player_emojimons_health
            @state = :start_battle
          else
            @state = :tournament_won
          end
        else
          @state = :game_over
        end
      end
    end

    def render(screen, state)

    end

    private

    def restore_player_emojimons_health
      @player[:emojimons].each do |emojimon|
        emojimon[:hp] = SPECIES[emojimon[:species]][:max_hp]
      end
    end
  end
end
