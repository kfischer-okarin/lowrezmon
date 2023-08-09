module BattleSystem
  class << self
    def choose_opponent_action(opponent, _player)
      {
        type: :attack,
        attack: opponent.emojimon[:attacks].sample[:id]
      }
    end

    def choose_next_opponent_emojimon(opponent, _player)
      alive_emojimon = opponent.trainer[:emojimons].select { |emojimon| emojimon[:hp].positive? }
      alive_emojimon.sample
    end

    def determine_turn_order(_player, _opponent)
      [:player, :opponent]
    end

    def calc_damage(_attacker, defender, attack)
      base_damage = 3 + rand(3)
      multiplier = Type.calc_damage_multiplier_of(attack[:type], against_type: defender[:type])
      {
        total_amount: (base_damage * multiplier).to_i,
        multiplier: multiplier
      }
    end
  end
end