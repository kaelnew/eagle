require 'test_helper'

class MoneyRecordTest < ActiveSupport::TestCase
  test "fields and relations" do
    assert outgo.outgo?
    assert income.income?

    assert outgo.label == "2019-05-07 支出100.0: 存款"
    assert outgo.value == 1

    mrs = outgo.children
    assert income.in?(mrs)
    assert income.parent == outgo

    income.tag_list.add(:invest)
    income.save
    assert davi.money_records.tagged_with(:invest).first == outgo

    assert income.tag_list.first == 'invest'
  end
end
