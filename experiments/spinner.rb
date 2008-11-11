#
# Command line spinner
#
# result = spin { long_running_method }
#
module Kernel
  def spin
    s = Thread.new { spinner }
    result = yield
    s.kill
    #print "\b"
    $stdout.flush
    result
  end

  def spinner
    a=["-","\\","|","/"]
    n=0
    while 1 do
      print a[n % 4]
      print "\b"
      $stdout.flush
      n+=1
      sleep 0.1
    end
  end
end
