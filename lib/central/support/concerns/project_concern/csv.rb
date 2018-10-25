module Central
  module Support
    module ProjectConcern
      module CSV
        module InstanceMethods
          def csv_filename
            "#{name}-#{Time.now.strftime('%Y%m%d_%I%M')}.csv"
          end
        end

        module Import
          # Populates the stories collection from a CSV string.
          def from_csv(csv_string)
            # Eager load this so that we don't have to make multiple db calls when
            # searching for users by full name from the CSV.
            users = proxy_association.owner.users

            csv = ::CSV.parse(csv_string, headers: true)
            csv.map do |row|
              row_attrs = row.to_hash
              story = build({
                title:        ( row_attrs["Title"] || row_attrs["Story"] || "").truncate(255, omission: '...'),
                story_type:   (row_attrs["Type"] || row_attrs["Story Type"]).downcase,
                requested_by: users.detect {|u| u.name == row["Requested By"]},
                owned_by:     users.detect {|u| u.name == row["Owned By"]},
                accepted_at:  row_attrs["Accepted at"],
                estimate:     row_attrs["Estimate"],
                labels:       row_attrs["Labels"],
                description:  row_attrs["Description"]
              })

              row_state = ( row_attrs["Current State"] || 'unstarted').downcase
              if Story.available_states.include?(row_state.to_sym)
                story.state = row_state
              end
              story.requested_by_name = ( row["Requested By"] || "").truncate(255)
              story.owned_by_name = ( row["Owned By"] || "").truncate(255)
              story.owned_by_initials = ( row["Owned By"] || "" ).split(' ').map { |n| n[0].upcase }.join('')

              row.each do |header, value|
                if header == 'Document' && value.present?
                  story.documents << ::Attachinary::File.new(JSON.parse(value.gsub '=>', ':'))
                end
              end

              tasks = []
              row.each do |header, value|
                tasks << "* #{value}" if header == 'Task' && value
              end
              story.description = "#{story.description}\n\nTasks:\n\n#{tasks.join("\n")}" unless tasks.empty?
              story.project.suppress_notifications = true # otherwise the import will generate massive notifications!
              story.save

              # Generate notes for this story if any are present
              story.notes.from_csv_row(row)

              story
            end
          end
        end
      end
    end
  end
end
