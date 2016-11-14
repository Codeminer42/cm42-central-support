module Central
  module Support
    module ProjectConcern
      module Attributes
        extend ActiveSupport::Concern

        included do
          attr_writer :suppress_notifications
        end

        def suppress_notifications
          @suppress_notifications || false
        end

        def to_s
          name
        end

        def iteration_service(since: nil, current_time: nil)
          @iteration_service ||= Central::Support::IterationService.new(self, since: since, current_time: since)
        end
      end
    end
  end
end
