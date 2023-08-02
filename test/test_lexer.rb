require 'test/unit'
require 'rolan/lexer'

class TestLexer < Test::Unit::TestCase
  data(
    'zero literal' => ['0', :INT, 0],
    'int literal' => ['123', :INT, 123],
    'float literal with 0' => ['0.123', :FLOAT, 0.123],
    'float literal' => ['4.56', :FLOAT, 4.56],
    'E-float' => ['1.23e1', :FLOAT, 12.3],
    'E-float (+)' => ['1.23e+1', :FLOAT, 12.3],
    'E-float (-)' => ['1.23e-1', :FLOAT, 0.123],
    'string literal' => ['"hoge"', :STRING, 'hoge'],
    's-lit u-esc' => ['"\\u0041"', :STRING, 'A'],
  )
  def test_lex_token(x)
    src, tag, val = x
    l = Rolan::Lexer.new(src)
    assert_equal(Rolan::Token.new(tag, val, 1, 1), l.next_token)
  end
end

