$fib = Hash.new { |h, i| h[i] = (i > 2) ? h[i-1] + h[i-2] : 1 }

#prevents too stack too deep
def fib2(i)
  (500..i).step(500) { |j| $fib[j] } if i > 500  # cache every 500
  $fib[i]
end

puts "fib 300th  : #{$fib[300]}"
puts "fib 9000th : #{fib2(9000)}"
