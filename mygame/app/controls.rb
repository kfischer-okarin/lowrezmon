module Controls
  class << self
    def confirm?(inputs)
      inputs.keyboard.key_down.space || inputs.controller_one.key_down.a
    end

    def cancel?(inputs)
      inputs.keyboard.key_down.escape || inputs.controller_one.key_down.b
    end
  end
end
