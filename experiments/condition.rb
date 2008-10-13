# ex:
#   c = Condition.new { |i| i < 0 }
#   c.include?(-1)   # true
#   c === 4          # false

class Condition
  attr_reader :definition

  def initialize(&condition_block)
    @definition = condition_block
  end

  def call(*args)
    definition.call(*args)
  end

  alias :include? :call
  alias :=== :call

  def ==(another)
    another.to_condition.definition == definition
  end

  def add(object)
    unless (include?(object) rescue false)
      old_definition = definition
      @definition = proc { |o| old_definition.call(o) and object.to_condition.include?(o) }
    end
    self
  end
  
  def to_condition
    self
  end
end

class Object
  def to_condition
    Condition.new { |o| o == self }
  end
end

module Enumerable
  def to_condition
    Condition.new { |o| include?(o) }
  end
end



# Extra
#   more informative inspect if ruby2ruby exists
begin
  require 'rubygems'
  require 'ruby2ruby'
rescue LoadError
else
  class Condition
    def initialize_with_inspect(&definition)
      set_inspect_code definition.to_ruby
      initialize_without_inspect(&definition)
    end
    alias :initialize_without_inspect :initialize
    alias :initialize :initialize_with_inspect

    def set_inspect_code(str)
      @inspect = str
    end

    def to_s
      @inspect
    end

    def inspect
      to_s.inspect
    end

    def add_with_inspect(object)
      set_inspect_code "proc { |o|\n #{@inspect}.call(o) and #{object.to_condition.to_s}.call(o) }"
      add_without_inspect(object)
    end
    alias :add_without_inspect :add
    alias :add :add_with_inspect
  end

  class Object
    def to_condition_with_inspect
      c = to_condition_without_inspect
      c.set_inspect_code "proc { |o| o == #{inspect} }"
      c
    end
    alias :to_condition_without_inspect :to_condition
    alias :to_condition :to_condition_with_inspect
  end

  module Enumerable
    def to_condition_with_inspect
      c = to_condition_without_inspect
      c.set_inspect_code "proc { |o| #{inspect}.include?(o) }"
      c
    end
    alias :to_condition_without_inspect :to_condition
    alias :to_condition :to_condition_with_inspect
  end
end


# tests
if $0 == __FILE__
  require 'test/unit'

  class TestCondition < Test::Unit::TestCase
    def setup
      @condition = Condition.new { |i| i < 0 }
    end

    def test_include
      assert @condition.include?(-1)
      assert !@condition.include?(0)
    end

    def test_eq_eq_eq
      assert(@condition === -1)
      assert(!(@condition === 0))
    end

    def test_add_object
      @condition.add(0)
      assert @condition.include?(0)
    end

    def test_add_enumerable
      @condition.add([1,2,3])
      assert @condition.include?(2)
    end
  end
end