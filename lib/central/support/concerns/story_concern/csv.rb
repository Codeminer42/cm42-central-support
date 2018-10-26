module Central
  module Support
    module StoryConcern
      module CSV
        extend ActiveSupport::Concern

        included do
          CSV_HEADERS = [
            "Id", "Story","Labels","Iteration","Iteration Start","Iteration End",
            "Story Type","Estimate","Current State","Started At", "Created at","Accepted at",
            "Deadline","Requested By","Owned By","Description","URL"
          ]

          # Returns an array, in the correct order, of the headers to be added to
          # a CSV render of a list of stories
          def self.csv_headers
            CSV_HEADERS
          end

          has_many :notes, -> { order(:created_at) }, dependent: :destroy do
            # Creates a collection of rows on this story from a CSV::Row instance
            # Each 'Note' field in the CSV will usually be in the following format:
            #
            #   "This is the note body text (Note Author - Dec 25, 2011)"
            #
            # This method will attempt to set the user and created_at timestamps
            # according to the values in the parens.  If the parens are missing, or
            # their contents cannot be matched or parsed, user and created_at will
            # not be set.
            def from_csv_row(row)
              # Ensure no email notifications get sent during CSV import
              project = proxy_association.owner.project
              project.suppress_notifications

              # Each row can have muliple Note headers.  Extract any of them from
              # this row.
              notes = []
              row.each do |header, value|
                if %w{Note Comment}.include?(header) && value
                  next if value.blank? || value =~ /^Commit by/
                  value.gsub!("\n", "")
                  next unless matches = /(.*)\((.*) - (.*)\)$/.match(value)
                  next if matches[1].strip.blank?
                  note = build(note: matches[1].strip,
                    user: project.users.find_by_username(matches[2]),
                    user_name: matches[2],
                    created_at: matches[3])
                  notes << note
                end
              end
              notes
            end
          end
        end

        def to_csv(number_of_extra_columns)
          [
            id,                       # Id
            title,                    # Story
            labels,                   # Labels
            nil,                      # Iteration
            nil,                      # Iteration Start
            nil,                      # Iteration End
            story_type,               # Story Type
            estimate,                 # Estimate
            state,                    # Current State
            started_at,               # Started at
            created_at,               # Created at
            accepted_at,              # Accepted at
            nil,                      # Deadline
            requested_by_name,        # Requested By
            owned_by_name,            # Owned By
            description,              # Description
            nil                       # URL
          ].concat(extra_columns(number_of_extra_columns))
        end

        private

        def extra_columns(number_of_extra_columns)
          [
            fill_columns_with(notes, number_of_extra_columns[:notes]),
            fill_columns_with(documents, number_of_extra_columns[:documents]),
            fill_columns_with(tasks, number_of_extra_columns[:tasks]).flatten
          ].flatten
        end

        def fill_columns_with(values, number_of_extra_columns)
          columns = []

          (0...number_of_extra_columns).each do |i|
            columns << values[i].try(:to_csv)
          end

          columns
        end
      end
    end
  end
end
