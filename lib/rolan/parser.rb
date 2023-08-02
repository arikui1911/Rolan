module Rolan
  module AST
    _ = ->(*a){ Struct.new(:line, :column, *a) }
    Binary = _[:op, :left, :right]
    Int = _[:value]
    Float = _[:value]
    String = _[:value]
  end

  class Parser
    def initialize(lexer)
      @lexer = lexer
      @buf = []
    end

    def parse
      parse_lexp
    end

    private

    def parse_lexp
      left = parse_term()
      t = expect('+', '-', exception: false) or return left
      AST::Binary.new(t.line, t.column, t.tag, left, parse_lexp())
    end

    def parse_term
      left = parse_factor()
      t = expect('*', '/', '%', exception: false) or return left
      AST::Binary.new(t.line, t.column, t.tag, left, parse_term())
    end

    def parse_factor
      expect(
        '(' => ->(_){ parse_lexp().tap{ expect ')' } },
        :INT => ->(t){ AST::Int.new(t.line, t.column, t.value) },
        :FLOAT => ->(t){ AST::Float.new(t.line, t.column, t.value) },
        :STRING => ->(t){ AST::String.new(t.line, t.column, t.value) },
      )
      #t = expect('(', :INT)
      #case t.tag
      #in '('
      #  parse_lexp().tap{ expect ')' }
      #in :INT
      #  AST::Int.new(t.line, t.column, t.value)
      #end
    end

    def next_token
      @buf.empty? ? @lexer.next_token : @buf.pop
    end

    def pushback(t)
      @buf.push(t) if t
      nil
    end

    def expect(*tags, exception: true, **kws)
      tags.concat kws.keys
      t = next_token()
      unless tags.include?(t.tag)
        pushback t
        return nil unless exception
        raise "#{t.line}:#{t.column}: unexpected #{t.tag}:#{t.value.inspect} - want #{tags.join(', ')}"
      end
      kws.key?(t.tag) ? kws[t.tag].call(t) : t
    end
  end
end

