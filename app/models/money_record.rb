class MoneyRecord < ApplicationRecord
  acts_as_taggable

  enum income_flag: {income: 0, outgo: 1}
  enum subject: {personal: 0, other: 1, mixed: 2}
  belongs_to :parent, class_name: :MoneyRecord, foreign_key: :parent_id
  has_many :children, class_name: :MoneyRecord, foreign_key: :parent_id
  scope :happened_at_desc, ->{order(happened_at: :desc)}
  scope :start_at, ->(start_at) {where("happened_at >= ?", start_at)}
  scope :end_at, ->(end_at) {where("happened_at <= ?", end_at)}
  scope :by_subject, ->(subject) {where(subject: subject)}
  alias_attribute :parent_value, :id

  def parent_id
    parent&.id
  end

  def parent_label
    "#{happened_at} #{income_flag_name}#{amount}: #{remark}"
  end

  def happened_at_str
    happened_at.to_s
  end

  def tag_value
    tag_list.first
  end

  def tag_label
    Setting.money_records_tags[tag_list.first]
  end

  def personal_share_ratio
    tmp = amount.to_f
    tmp.zero? ? tmp : personal_share / amount
  end

  class << self
    def tag_formatted_options
      Setting.money_records_tags.collect {|k, v| {label: v, value: k}}
    end

    def subject_formatted_options
      subject_options.collect {|label, value| {label: label, value: value}}
    end

    def tags(records)
      records.collect {|record| record.tag_list.first}.uniq
    end

    def income_flag_label(income_flag)
      I18n.t("activerecord.enums.money_record.income_flag.#{income_flag}")
    end
  end
end
