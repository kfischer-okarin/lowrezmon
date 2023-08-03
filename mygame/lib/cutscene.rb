module Cutscene
  class << self
    def build_empty
      {
        scheduled_elements: {},
        active_elements: []
      }
    end

    def schedule_element(cutscene, element)
      scheduled_elements = cutscene[:scheduled_elements]
      tick = element.fetch(:tick)
      scheduled_elements[tick] ||= []
      scheduled_elements[tick] << element.except(:tick)
    end

    def finished?(cutscene)
      cutscene[:scheduled_elements].empty? && cutscene[:active_elements].empty?
    end

    def tick(args, cutscene, handler:)
      active_elements = cutscene[:active_elements]
      elements_starting_now = cutscene[:scheduled_elements].delete(args.tick_count)
      if elements_starting_now
        new_active_elements = elements_starting_now.map { |element|
          {
            element: element.except(:type).merge(elapsed_ticks: 0),
            handler_method: :"#{element[:type]}_tick"
          }
        }
        active_elements.concat new_active_elements
      end

      active_elements.reject! do |active_element|
        element = active_element[:element]
        element[:elapsed_ticks] >= element[:duration]
      end

      active_elements.each do |active_element|
        element = active_element[:element]
        handler.send(active_element[:handler_method], args, element)
        element[:elapsed_ticks] += 1
      end
    end
  end
end
