content = ''
(1..1000).each do
  content += "ASDFGHJKLKJHGFVGHJBGCHVHBKJVJGC BMBNJKHVBJLB\n"
end

(1..30).each do |idx|
  IO.write("./input/#{idx}.txt", content)
end

puts "Finished writing 30 files to input directory."

