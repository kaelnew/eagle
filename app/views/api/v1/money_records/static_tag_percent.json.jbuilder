json.partial! 'jshared/suc'
json.data do
  json.totals @totals
  json.incomes @incomes
  json.outgos @outgos
end