begin
  "hello world".hello_universe
rescue NoMethodError => error #(Creates an error variable and stores the error message in it.)
  
  if error.message.include?("undefined method")
    puts "No Method Error - Try again"
  end
  # puts error.message
  # puts "Something went wrong.  Notify dev team."
end
puts "End of program."
