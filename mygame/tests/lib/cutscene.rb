def test_cutscene(args, assert)
  cutscene = Cutscene.build_empty
  Cutscene.schedule_element cutscene, tick: 1, type: :text, duration: 4, text: 'Hello world!'
  Cutscene.schedule_element cutscene, tick: 2, type: :splash, duration: 2, path: 'particle.png'
  Cutscene.schedule_element cutscene, tick: 2, type: :shake, duration: 1, intensity: 10

  handler = Object.new
  calls = []
  [:text_tick, :splash_tick, :shake_tick].each do |method_name|
    handler.define_singleton_method(method_name) do |_args, element|
      calls << [method_name, element.dup]
    end
  end

  args.tick_count = 0
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! calls, []
  assert.false! Cutscene.finished?(cutscene)

  args.tick_count = 1
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! calls, [
    [:text_tick, { elapsed_ticks: 0, duration: 4, text: 'Hello world!' }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  calls.clear
  args.tick_count = 2
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! calls, [
    [:text_tick, { elapsed_ticks: 1, duration: 4, text: 'Hello world!' }],
    [:splash_tick, { elapsed_ticks: 0, duration: 2, path: 'particle.png' }],
    [:shake_tick, { elapsed_ticks: 0, duration: 1, intensity: 10 }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  calls.clear
  args.tick_count = 3
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! calls, [
    [:text_tick, { elapsed_ticks: 2, duration: 4, text: 'Hello world!' }],
    [:splash_tick, { elapsed_ticks: 1, duration: 2, path: 'particle.png' }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  calls.clear
  args.tick_count = 4
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! calls, [
    [:text_tick, { elapsed_ticks: 3, duration: 4, text: 'Hello world!' }]
  ]
  assert.false! Cutscene.finished?(cutscene)

  calls.clear
  args.tick_count = 5
  Cutscene.tick args, cutscene, handler: handler

  assert.equal! calls, []
  assert.true! Cutscene.finished?(cutscene)
end
