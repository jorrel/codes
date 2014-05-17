module ToAttributeArray
  def to_attribute_array
    values.transpose.map { |v| keys.zip(v).to_h }
  end
end

class Hash
  include ToAttributeArray
end

if __FILE__ == $0
  require 'rspec/autorun'

  describe ToAttributeArray do
    it 'converts hash to attribute array' do
      expect({a: [1, 2, 3], b: [4, 5, 6]}.to_attribute_array).to eq([{a: 1, b: 4}, {a: 2, b: 5}, {a: 3, b: 6}])
    end
  end
end

