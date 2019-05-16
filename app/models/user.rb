class User < ApplicationRecord
  include BCrypt
  include UserAuthable
  
  has_paper_trail
  validates :name, uniqueness: {message: I18n.t('user.name_uniqueness_error')}
  enum role: {common: 0, super: 1}
  enum delete_status: {alive: 0, removed: 1}
  scope :by_name, ->(name) {where(name: name)}
  has_many :money_records

  DEFAULT_PASSWORD = '123456'

  def remove!
    update!(delete_status: 'removed', deleted_at: Time.now)
  end

  def password
    @password ||= Password.new(encrypted_password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.encrypted_password = @password
    save
  end

  def access
    Setting.accesses[role]
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
