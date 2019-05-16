class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def error_msg
    errors.values.first.first
  end
end
