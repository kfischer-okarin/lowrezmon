def test_cutscene(args, assert)
  cutscene = Cutscene.build_empty
  Cutscene.schedule_element cutscene, tick: 1, type: :text, duration: 4, text: 'Hello world!'
  Cutscene.schedule_element cutscene, tick: 2, type: :splash, duration: 2, path: 'particle.png'
  Cutscene.schedule_element cutscene, tick: 2, type: :shake, duration: 1, intensity: 10
  handler = CutsceneTests::Handler.new :text_tick, :splash_tick, :shake_tick

  args.tick_count = 0
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, []
  assert.false! Cutscene.finished?(cutscene)

  handler.calls.clear
  args.tick_count = 1
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, [
    [:text_tick, { elapsed_ticks: 0, duration: 4, text: 'Hello world!' }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  handler.calls.clear
  args.tick_count = 2
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, [
    [:text_tick, { elapsed_ticks: 1, duration: 4, text: 'Hello world!' }],
    [:splash_tick, { elapsed_ticks: 0, duration: 2, path: 'particle.png' }],
    [:shake_tick, { elapsed_ticks: 0, duration: 1, intensity: 10 }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  handler.calls.clear
  args.tick_count = 3
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, [
    [:text_tick, { elapsed_ticks: 2, duration: 4, text: 'Hello world!' }],
    [:splash_tick, { elapsed_ticks: 1, duration: 2, path: 'particle.png' }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  handler.calls.clear
  args.tick_count = 4
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, [
    [:text_tick, { elapsed_ticks: 3, duration: 4, text: 'Hello world!' }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  handler.calls.clear
  args.tick_count = 5
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, []
  assert.true! Cutscene.finished?(cutscene)
end

def test_cutscene_element_without_duration_has_duration_1(args, assert)
  cutscene = Cutscene.build_empty
  Cutscene.schedule_element cutscene, tick: 1, type: :some_element
  handler = CutsceneTests::Handler.new :some_element_tick

  args.tick_count = 1
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, [
    [:some_element_tick, { elapsed_ticks: 0, duration: 1 }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  handler.calls.clear
  args.tick_count = 2
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! handler.calls, []
  assert.true! Cutscene.finished?(cutscene)
end

module CutsceneTests
  class Handler
    attr_reader :calls

    def initialize(*methods)
      @calls = []
      methods.each do |method_name|
        define_singleton_method(method_name) do |_args, element|
          @calls << [method_name, element.dup]
        end
      end
    end
  end
end
