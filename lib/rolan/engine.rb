require 'rolan/value'

module Rolan
  class Engine
    def eval(cxt, ast)
      case ast
      in AST::Binary
        l = eval(cxt, ast.left)
        r = eval(cxt, ast.right)
        l.send(ast.op, r)
      in AST::Int
        Value.int_value ast.value
      in AST::Float
        Value.float_value ast.value
      in AST::String
        Value.string_value ast.value
      end
    end
  end
end

