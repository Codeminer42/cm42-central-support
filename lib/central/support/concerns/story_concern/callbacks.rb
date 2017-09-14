module Central
  module Support
    module StoryConcern
      module Callbacks
        extend ActiveSupport::Concern

        included do
          before_validation :set_position_to_last
          before_save :set_started_at
          before_save :set_accepted_at
          before_save :set_delivered_at
          before_save :cache_user_names
          before_destroy { |record| raise ActiveRecord::ReadOnlyRecord if record.readonly? }
        end

        def set_position_to_last
          return true if position
          return true unless project
          last = project.stories.order(position: :desc).first
          self.position = last ? ( last.position + 1 ) : 1
        end

        def set_started_at
          return unless state_changed?
          return unless state == 'started'
          self.started_at = Time.current if started_at.nil?
          if owned_by.nil? && acting_user
            self.owned_by = acting_user
          end
        end

        def set_accepted_at
          return unless state_changed?
          return unless state == 'accepted'
          self.accepted_at = Time.current if accepted_at.nil?
          if started_at
            self.cycle_time = accepted_at - started_at
          end
        end

        def set_delivered_at
          return unless state_changed?
          return unless state == 'delivered'
          self.delivered_at = Time.current if delivered_at.nil?
        end

        def cache_user_names
          self.requested_by_name = requested_by.name unless requested_by.nil?
          if owned_by.present?
            self.owned_by_name     = owned_by.name
            self.owned_by_initials = owned_by.initials
          end
        end
      end
    end
  end
end
