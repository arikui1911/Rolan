require 'test/unit'
require 'rolan/lexer'

class TestLexer < Test::Unit::TestCase
  data(
    'zero literal' => ['0', :LIT_INT, 0],
    'int literal' => ['123', :LIT_INT, 123],
    'float literal with 0' => ['0.123', :LIT_FLOAT, 0.123],
    'float literal' => ['4.56', :LIT_FLOAT, 4.56],
    'E-float' => ['1.23e1', :LIT_FLOAT, 12.3],
    'E-float (+)' => ['1.23e+1', :LIT_FLOAT, 12.3],
    'E-float (-)' => ['1.23e-1', :LIT_FLOAT, 0.123],
    'string literal' => ['"hoge"', :LIT_STRING, 'hoge'],
    's-lit x-esc' => ['"\\x0041"', :LIT_STRING, 'A'],
  )
  def test_lex_token(x)
    src, tag, val = x
    l = Rolan::Lexer.new(src)
    assert_equal(Rolan::Token.new(tag, val, 1, 1), l.next_token)
  end
end

