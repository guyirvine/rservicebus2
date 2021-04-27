class TablePut
end

class TableGet
  attr_reader :id
  def initialize(id)
    @id = id
  end
end
