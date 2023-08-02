require 'strscan'

module Rolan
  Token = Struct.new(:tag, :value, :line, :column)

  class Lexer
    def initialize(src)
      @src = src
      @fib = Fiber.new(&method(:lex))
    end

    def next_token
      @fib.resume
    end

    private

    def emit_raw(token)
      Fiber.yield token
    end

    def emit(tag, val, line, col)
      emit_raw Token.new(tag, val, line, col)
    end

    def lex
      lineno = 1
      s = StringScanner.new('')
      m = :lex_default
      @src.each_line do |line|
        s.string = line
        until s.eos?
          m = send(m, s, lineno)
        end
        lineno += 1
      end
      emit :EOF, nil, lineno, 1
    end

    def lex_default(s, line)
      col = s.pos + 1
      e = ->(tag, val){ emit tag, val, line, col } 
      case
      when s.scan(/#\|/)
        return :lex_comment
      when s.scan(/\s+/), s.scan(/#.*/)
        ;
      when s.scan(/"/)
        @string = Token.new(:LIT_STRING, String.new, line, col)
        return :lex_string
      when s.scan(/(0|[1-9]\d*)\.\d+([eE][+-]?\d+)?/)
        e.(:LIT_FLOAT, Kernel.Float(s.matched))
      when s.scan(/(0|[1-9]\d*)/)
        e.(:LIT_INT, Kernel.Integer(s.matched))
      when s.scan(/./)
        e.(s.matched, s.matched)
      else
        raise Exception, 'must not happen' 
      end
      __method__
    end

    def lex_comment(s, _)
      return :lex_default if s.scan_until(/\|#/)
      s.terminate
      __method__
    end

    ESC = {
      't' => "\t",
      'v' => "\v",
      'n' => "\n",
      'r' => "\r",
      'f' => "\f",
      'b' => "\b",
      'a' => "\a",
      'e' => "\e",
      's' => "\s",
    }

    def lex_string(s, line)
      scanned = s.scan_until(/[\\"]/)
      case s.matched
      when '"'
        @string.value << scanned.delete_suffix('"')
        @string.value.freeze
        emit_raw @string
        return :lex_default
      when '\\'
        case
        when s.scan(/u([\da-fA-F]{4})/), s.scan(/U([\da-fA-F]{8})/)
          @string.value << Kernel.Integer(s[1], 16).chr(Encoding::UTF_8)
        when s.scan(/./)
          @string.value << (ESC[s.matched] || s.matched)
        end
      else
        @string.value << s.rest
        s.terminate
      end
      __method__
    end
  end
end



