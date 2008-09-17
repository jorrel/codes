#
# Object#rand_hex(bytes = 64)
#
# Generate a random string consisting of hex characters
#
# Insipired by Rails::SecretKeyGenerator (deprecated Aug 27, 2008)
#

begin
  require 'securerandom'
rescue LoadError
end
  
class Object
  if defined?(::SecureRandom)               # ruby 1.9
    def rand_hex(bytes = 64)
      SecureRandom.hex(bytes)
    end
  elsif !File.exists?('/dev/urandom')        # unix random generator
    def rand_hex(bytes = 64)
      File.read('/dev/urandom', bytes).unpack('H*')[0]
    end
  else
    def rand_hex(bytes = 64)                # using SHA as default
      require 'digest/sha2'
      sha = Digest::SHA2.new(bytes * 8)
      sha << (now = Time.now).to_s
      sha << now.usec.to_s
      sha << $$.to_s
      sha << rand.to_s
      sha.hexdigest
    end
  end
end
