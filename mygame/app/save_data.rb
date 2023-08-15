module SaveData
  class << self
    def load(args)
      new_save_data = {
        won_tournaments: []
      }
      args.state.save_data = parse_save_data_file || new_save_data
    end

    def save(args)
      $gtk.serialize_state('save_data.txt', args.state.save_data)
    end

    private

    def parse_save_data_file
      $gtk.deserialize_state('save_data.txt')
    end
  end
end
