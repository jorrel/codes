# Core Classes Extensions for Sudoku
# (mostly to remove dependency of active_support)

class Array
  def none?(&block)
    not any?(&block)
  end

  def uniq_contents?
    size == uniq.size
  end

  def no_dup_of_non_zero_nums?
    map(&:to_i).reject(&:zero?).uniq_contents?
  end
end



# Symbol#to_proc
# from active_support
class Symbol
  def to_proc
     Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end



# Object#tap
class Object
  def tap
    yield self
    self
  end
end



# Object#blank?
# from active_support
class Object
  # An object is blank if it's nil, empty, or a whitespace string.
  # For example, "", "   ", nil, [], and {} are blank.
  #
  # This simplifies
  #   if !address.nil? && !address.empty?
  # to
  #   if !address.blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class NilClass #:nodoc:
  def blank?
    true
  end
end

class FalseClass #:nodoc:
  def blank?
    true
  end
end

class TrueClass #:nodoc:
  def blank?
    false
  end
end

class Array #:nodoc:
  alias_method :blank?, :empty?
end

class Hash #:nodoc:
  alias_method :blank?, :empty?
end

class String #:nodoc:
  def blank?
    self !~ /\S/
  end
end

class Numeric #:nodoc:
  def blank?
    false
  end
end