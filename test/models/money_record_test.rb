require 'test_helper'

class MoneyRecordTest < ActiveSupport::TestCase
  test "fields and relations" do
    assert outgo.outgo?
    assert income.income?

    assert outgo.parent_label == "2019-05-07 支出100.0: 存款"
    assert outgo.parent_value == 1

    mrs = outgo.children
    assert income.in?(mrs)
    assert income.parent == outgo

    income.tag_list.add(:invest)
    income.save
    assert davi.money_records.tagged_with(:invest).first == income

    assert income.tag_list.first == 'invest'
  end
end
