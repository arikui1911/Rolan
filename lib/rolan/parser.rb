module Rolan
  module AST
    _ = ->(*a){ Struct.new(:line, :column, *a) }
    Stmts = _[:children]
    Call = _[:name, :args]
    Binary = _[:op, :left, :right]
    Int = _[:value]
    Float = _[:value]
    String = _[:value]
    Ident = _[:name]
  end

  class Parser
    def initialize(lexer)
      @lexer = lexer
      @buf = []
      @last = nil
    end

    def parse
      parse_stmts :EOF
    end

    private

    def parse_stmts(terminator)
      buf = []
      loop do
        expect(terminator, exception: false) and break
        buf << parse_stmt
      end
      AST::Stmts.new(1, 1, buf).tap{|x|
        x.line, x.column = x.children.first.line, x.children.first.column unless x.children.empty?
      }
    end

    def parse_stmt
      expect(
        :IDENT => ->(ident){
          expect(
            '=' => ->(_){
              lexp = parse_lexp()
              expect ';'
              AST::Let.new(ident.line, ident.col, ident.value, lexp)
            },
            '(' => ->(_){
              args = parse_args()
              expect ';'
              AST::Call.new(ident.line, ident.column, ident.value, args)
            },
            ';' => ->(_){ AST::Ident.new(ident.line, ident.column, ident.value) },
          )
        }
      ) do
        parse_lexp().tap{ expect ';' }
      end
    end

    def parse_args
      expect(')', exception: false) and return []
      buf = [parse_lexp()]
      loop do
        expect(
          ',' => ->(_){ buf << parse_lexp() },
          ')' => ->(_){ raise StopIteration },
        )
      end
      buf
    end

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
        :IDENT => ->(t){ AST::Ident.new(t.line, t.column, t.value) },
      )
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
      # 1) expected tag
      if tags.include?(t.tag)
        return(kws.key?(t.tag) ? kws[t.tag].call(t) : t)
      end
      # 2) unexpected tag
      pushback t
      case
      when block_given?
        return yield(t)
      when exception
        raise "#{t.line}:#{t.column}: unexpected #{t.tag}:#{t.value.inspect} - want #{tags.join(', ')}"
      end
    end
  end
end

