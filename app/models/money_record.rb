class MoneyRecord < ApplicationRecord
  acts_as_taggable

  alias_attribute :value, :id
  enum income_flag: {income: 0, outgo: 1}
  belongs_to :parent, class_name: :MoneyRecord, foreign_key: :parent_id
  has_many :children, class_name: :MoneyRecord, foreign_key: :parent_id
  scope :happened_at_desc, ->{order(happened_at: :desc)}

  def happened_at_str
    happened_at.to_s
  end

  def label
    "#{happened_at} #{income_label}#{amount}: #{remark}"
  end

  def income_label
    income? ? '收入' : '支出'
  end

  def tag_value
    tag_list.first
  end

  def tag_label
    Setting.money_records_tags[tag_list.first]
  end

  class << self
    def all_tags
      Setting.money_records_tags.collect {|k, v| {label: k, value: v}}
    end
  end
end
