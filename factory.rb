# Factory class provides a way to store in the same objects other different
# predefined objects also as methods.
# Usage:
#   Customer = Factory.new(:name, :address, :zip)
#   => Customer
#
#   joe = Customer.new("Joe Smith", "123 Maple, Anytown NC", 12345)
#   => #<struct Customer name="Joe Smith", address="123 Maple, Anytown NC",
#   zip=12345>
#
#   joe.name
#   joe["name"]
#   joe[:name]
#   joe[0]
#   => "Joe Smith"
class Factory

  include Enumerable

  def self.new(*args, &block)
    Class.new do
      raise ArgumentError, 'wrong number of arguments' if args.empty?
      
      args.each{|arg| self.send(:attr_accessor, arg)}

      define_method :initialize do |*attrebutes|
        raise ArgumentError if attrebutes.length > args.length
        attrebutes.each_with_index do |attrebute, index|
          instance_variable_set("@#{args[index]}", attrebute)
        end
      end

      define_method :[] do |str|
        if str.is_a? Fixnum and str < args.length
          instance_variable_get("@#{args[str]}")
        else
          raise ArgumentError unless str.is_a? Symbol or
           str.is_a? String and args.include? str.to_sym
          instance_variable_get("@#{args[args.index(str.to_sym)]}")
        end
      end

      define_method :== do |object|
        return false unless self.class == object.class and self.hash == object.hash
        return true
      end

      alias :eql? :==
      define_method :length do
        values.size
      end

      alias :size :length

      define_method :each do |&block|
        values.each( &block )
      end

      define_method :each_pair do |&block|
        hash_variables.each( &block )
      end

      self.class_eval(&block) if block_given?
    end
  end
end