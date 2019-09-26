module Central
  module Support
    module StoryConcern
      module Validations
        extend ActiveSupport::Concern

        included do
          validates :project, presence: true
          validates :title, presence: true

          validates :requested_by_id, belongs_to_project: true
          validates :owned_by_id, belongs_to_project: true

          ESTIMABLE_TYPES = %w[feature].freeze
          STORY_TYPES = %i[feature chore bug release].freeze

          extend Enumerize
          enumerize :story_type, in: STORY_TYPES, predicates: true, scope: true
          validates :story_type, presence: true
          validates :estimate, estimate: true, allow_nil: true

          validate :bug_chore_estimation
        end

        # Returns true or false based on whether the story has been estimated.
        def estimated?
          !estimate.nil?
        end
        alias :estimated :estimated?

        # Returns true if this story can have an estimate made against it
        def estimable?
          feature? && !estimated?
        end
        alias :estimable :estimable?

        def bug_chore_estimation
          if !ESTIMABLE_TYPES.include?(story_type) && estimated?
            errors.add(:estimate, :cant_estimate)
          end
        end
      end
    end
  end
end
