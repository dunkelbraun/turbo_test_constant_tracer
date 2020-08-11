# frozen_string_literal: true

class Minitest::Test
  class EventSubscriber
    attr_reader :events

    def update(*payload)
      @events ||= []
      @events << payload
    end
  end

  attr_reader :_event_subscriber

  def event_subscriber
    return _event_subscriber if _event_subscriber

    @event_subscriber ||= EventSubscriber.new
  end
end
