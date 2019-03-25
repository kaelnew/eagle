class User < ApplicationRecord
  include BCrypt
  include UserAuthable

  validates :name, uniqueness: {message: I18n.t('user.name_uniqueness_error')}

  def password
    @password ||= Password.new(encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
    save
  end

  class << self
    def current
      Thread.current[:current_user]
    end

    def current=(user)
      Thread.current[:current_user] = user
    end
  end
end
