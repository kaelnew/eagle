class Chart::Pie
  attr_accessor :value, :name

  def initialize(value, name)
    @value = value
    @name = name
  end
end
