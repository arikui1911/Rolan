module Rolan
  module Value
    class Int
      def initialize(value)
        @value = value
      end

      attr_reader :value

      def to_s
        @value.to_s 10
      end

      def +(o) = arith(o, :+)
      def -(o) = arith(o, :-)
      def *(o) = arith(o, :*)
      def /(o) = arith(o, :/)
      def %(o) = arith(o, :%)

      private

      def arith(other, op)
        case other
        when Int
          Value.int_value self.value.send(op, other.value)
        when Float
          Value.float_value self.value.to_f.send(op, other.value)
        else
          raise "#{other}:#{other.class} - not a number"
        end
      end
    end

    def self.int_value(v) = Int.new(v)

    class Float
      def initialize(value)
        @value = value
      end

      attr_reader :value

      def to_s
        @value.to_s
      end

      def +(o) = arith(o, :+)
      def -(o) = arith(o, :-)
      def *(o) = arith(o, :*)
      def /(o) = arith(o, :/)

      private

      def arith(other, op)
        case other
        when Int
          Value.float_value self.value.send(op, other.value.to_f)
        when Float
          Value.float_value self.value.send(op, other.value)
        else
          raise "#{other}:#{other.class} - not a number"
        end
      end
    end

    def self.float_value(v) = Float.new(v)

    class String
      def initialize(value)
        @value = value
      end

      def to_s
        @value
      end
    end

    def self.string_value(v) = String.new(v)
  end
end
