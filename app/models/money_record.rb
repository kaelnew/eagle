class MoneyRecord < ApplicationRecord
  acts_as_taggable

  alias_attribute :value, :id
  enum income_flag: {income: 0, outgo: 1}
  belongs_to :parent, class_name: :MoneyRecord, foreign_key: :parent_id
  has_many :children, class_name: :MoneyRecord, foreign_key: :parent_id
  scope :happened_at_desc, ->{order(happened_at: :desc)}
  scope :start_at, ->(start_at) {where("happened_at >= ?", start_at)}
  scope :end_at, ->(end_at) {where("happened_at <= ?", end_at)}

  def happened_at_str
    happened_at.to_s
  end

  def label
    "#{happened_at} #{income_label}#{amount}: #{remark}"
  end

  def parent_id
    parent&.id
  end

  def income_label
    income? ? I18n.t('money_record.income') : I18n.t('money_record.outgo')
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

    def tags(records)
      records.collect {|record| record.tag_list.first}.uniq
    end
  end
end
