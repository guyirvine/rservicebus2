types = Hash.new(0)
ObjectSpace.each_object do|obj|
  types[obj.class] += 1
end

puts types
