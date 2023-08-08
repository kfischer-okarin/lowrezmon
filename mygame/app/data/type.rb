module Type
  DAMAGE_MULTIPLIERS = {
    sassy: {
      sassy: 1,
      silly: 0.5,
      sexy: 2,
      salty: 1
    },
    silly: {
      sassy: 2,
      silly: 1,
      sexy: 0.5,
      salty: 1
    },
    sexy: {
      sassy: 0.5,
      silly: 2,
      sexy: 1,
      salty: 1
    },
    salty: {
      sassy: 1,
      silly: 1,
      sexy: 1,
      salty: 2
    }
  }
  class << self
    def all
      DAMAGE_MULTIPLIERS.keys
    end

    def calc_damage_multiplier_of(attacking_type, against_type:)
      raise "Unknown type: #{attacking_type}" unless all.include? attacking_type
      raise "Unknown type: #{against_type}" unless all.include? against_type

      DAMAGE_MULTIPLIERS[attacking_type][against_type] || 1
    end

    def all_effective_against(defending_type)
      all.select { |type| damage_multiplier(type, against_type: defending_type) > 1 }
    end
  end
end
