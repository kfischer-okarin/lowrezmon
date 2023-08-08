module BattleSystem
  class << self
    def choose_opponent_action(opponent, _player)
      {
        type: :attack,
        attack: opponent.emojimon[:attacks].sample[:id]
      }
    end

    def determine_turn_order(_player, _opponent)
      [:player, :opponent]
    end

    def calc_damage(_attacker, defender, attack)
      base_damage = 3 + rand(3)
      multiplier = Type.damage_multiplier(attack[:type], against_type: defender[:type])
      {
        total_amount: (base_damage * multiplier).to_i,
        multiplier: multiplier
      }
    end
  end
end
