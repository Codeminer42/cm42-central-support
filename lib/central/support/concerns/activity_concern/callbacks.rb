module Central
  module Support
    module ActivityConcern
      module Callbacks
        extend ActiveSupport::Concern

        included do
          serialize :subject_changes, Hash

          before_save :parse_changes
        end

        def parse_changes
          if action == 'update'
            self.subject_changes = subject.saved_changes
          elsif action == 'destroy'
            self.subject_changes = subject.attributes
            self.subject_destroyed_type = subject.class.name
            self.subject = nil
          end
        end
      end
    end
  end
end
