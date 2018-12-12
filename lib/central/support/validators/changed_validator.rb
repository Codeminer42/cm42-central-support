class ChangedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.action == 'update' && !value.saved_changes?
      record.errors[attribute] << ( options[:message] || "Record didn't change" )
    end
  end
end
