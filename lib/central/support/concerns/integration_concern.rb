module Central
  module Support
    module IntegrationConcern
      extend ActiveSupport::Concern

      included do
        VALID_INTEGRATIONS = ['mattermost','slack']

        belongs_to :project
        validates :project, presence: true
        validates :kind, inclusion: { in: VALID_INTEGRATIONS }, presence: true
        validates :data, presence: true
      end
    end
  end
end
