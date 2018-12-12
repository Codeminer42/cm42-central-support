module Central
  module Support
    module UserConcern
      module Associations
        extend ActiveSupport::Concern

        included do
          has_many :enrollments
          has_many :teams, through: :enrollments

          has_many :memberships, dependent: :destroy
          has_many :projects, -> { distinct }, through: :memberships do
            def not_archived
              where(archived_at: nil)
            end
          end
        end
      end
    end
  end
end
