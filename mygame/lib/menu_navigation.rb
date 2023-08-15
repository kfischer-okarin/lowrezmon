class MenuNavigation
  attr_reader :children, :selected_child, :selected_index

  def initialize(children, selected_index: 0, loop: true, horizontal: false)
    @children = children
    @horizontal = horizontal
    @loop = loop

    @selected_index = 0

    self.selected_index = selected_index
  end

  def selected_index=(value)
    @selection_changed = @selected_index != value
    @selected_index = @loop ? (value % @children.size) : value.clamp(0, @children.size - 1)

    @selected_child = @children[@selected_index]
    @selected_index
  end

  def selection_changed?
    @selection_changed
  end

  def tick(args)
    @selection_changed = false
    keyboard = args.inputs.keyboard.key_down
    controller = args.inputs.controller_one.key_down
    if @horizontal
      if keyboard.left || controller.left
        self.selected_index -= 1
      elsif keyboard.right || controller.right
        self.selected_index += 1
      end
    else
      if keyboard.up || controller.up
        self.selected_index -= 1
      elsif keyboard.down || controller.down
        self.selected_index += 1
      end
    end
  end
end
