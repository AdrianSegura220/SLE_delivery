module AST
import Syntax;
/*
 * Define Abstract Syntax for QL
 *
 * - complete the following data types
 * - make sure there is an almost one-to-one correspondence with the grammar
 */

data AForm(loc src = |tmp:///|)
  = form(str name, list[AQuestion] questions)
  ; 

data AQuestion(loc src = |tmp:///|)
  = iff(AExpr guard, list[AQuestion] questions)
  | iffelse(AExpr guard, list[AQuestion] questions, list[AQuestion] questions2)
  | question(str q,AId name,AType t)
  | computed_question(str q,AId name,AType t,AExpr e)
  ;

data AExpr(loc src = |tmp:///|)
  = ref(AId id)
  | qStr(str name)
  | val(int v)
  | boolVal(bool b)
  | not(AExpr arg)
  | mult(AExpr lhs, AExpr rhs)
  | div(AExpr lhs, AExpr rhs)
  | plus(AExpr lhs, AExpr rhs)
  | minus(AExpr lhs, AExpr rhs)
  | lt(AExpr lhs, AExpr rhs)
  | leq(AExpr lhs, AExpr rhs)
  | gt(AExpr lhs, AExpr rhs)
  | geq(AExpr lhs, AExpr rhs)
  | eq(AExpr lhs, AExpr rhs)
  | neq(AExpr lhs, AExpr rhs)
  | and(AExpr lhs, AExpr rhs)
  | or(AExpr lhs, AExpr rhs)
  ;

data AType(loc src = |tmp:///|)
 = typeVar(str name)
 ;

data AId(loc src = |tmp:///|)
  = id(str name);
