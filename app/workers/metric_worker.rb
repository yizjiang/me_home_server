# encoding: utf-8

module Worker
  class Metric
    include Sidekiq::Worker
    sidekiq_options queue: :metric, backtrace: true

    def record_home_view(payload)
      
    end

    def perform(payload)
      case payload["type"]
      when 'home'
        record_home_view(payload)
      end
    end

  end
end

