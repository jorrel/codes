#
# http://projecteuler.net/index.php?section=problems&id=5
#
# 2520 is the smallest number that can be divided by each of the
# numbers from 1 to 10 without any remainder.
#
# What is the smallest number that is evenly divisible by all of
# the numbers from 1 to 20?
#

require 'mathn'

#
# lcm(1,2,3,4,5,6,7,8,9,10)   # 2520
# lcm([1,2,3,4,5,6,7,8,9,10]) # 2520
# lcm(1..10)                  # 2520
#
def lcm(*nums)
  nums = nums.collect { |n| n.to_a }.flatten.sort.reverse
  p_facs = []
  primes = Prime.new
  max = nums.first
  while (p = primes.next) and max > p
    while nums.detect { |n| (n % p).zero? }
      p_facs << p
      nums = nums.collect { |n| (n % p).zero? ? n / p : n }
    end
  end
  nums.each { |n| p_facs << n if n > 1 }
  return p_facs.inject(1) { |l, n| l * n }
end

if __FILE__ == $0
  puts lcm(1..20)
end
