# http://www.rubyquiz.com/quiz153.html

input = STDIN.read

# from active_support
module Enumerable
  def group_by
    inject({}) do |groups, element|
      (groups[yield(element)] ||= []) << element
      groups
    end
  end if RUBY_VERSION < '1.9'
end 

def trace(string, map = {}, length = 1)
  unless length >= (str_length = string.length)
    if length > 1 
      for i in (0...(str_length - length))
        #puts "string[#{i}, #{length}]: #{string[i, length]}"
        str = string[i, length]
        unless str =~ /^\s+$/
          map[str] ||= 0
          map[str] += 1
        end
        i += 1
      end
    end
    trace string, map, length + 1
  end
  if length == 1
    if res = map.select { |k,v| v > 1 }.group_by { |k, v| v }.to_a.sort_by { |k,v| k }.last
      res.last.sort_by { |k, v| k.length }.last.first
    end
  end
end

if output = trace(input)
  STDOUT.write output 
  STDOUT.write "\n"
end