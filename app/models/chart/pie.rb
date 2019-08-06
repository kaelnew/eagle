class Chart::Pie
  attr_accessor :value, :name

  def initialize(value, name)
    @value = value
    @name = name
  end

  def add_value_to_name
    @name += " ￥#{@value}"
    self
  end
end
