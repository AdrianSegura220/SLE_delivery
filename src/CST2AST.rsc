module CST2AST

import Syntax;
import AST;

import ParseTree;
import String;

/*
 * Implement a mapping from concrete syntax trees (CSTs) to abstract syntax trees (ASTs)
 *
 * - Use switch to do case distinction with concrete patterns (like in Hack your JS) 
 * - Map regular CST arguments (e.g., *, +, ?) to lists 
 *   (NB: you can iterate over * / + arguments using `<-` in comprehensions or for-loops).
 * - Map lexical nodes to Rascal primitive types (bool, int, str)
 * - See the ref example on how to obtain and propagate source locations.
 */
 
bool toBool(str bVal){
	return bVal == "true" ? true : false;
}
 
AForm cst2ast(start[Form] f)
 = cst2ast(f.top)
 ;
 
AForm cst2ast(fo: (Form) `form <Id id> { <Question* qs>}`)
 = form("<id>", [cst2ast(q) | Question q <- qs], src=fo@\loc)
;

AQuestion cst2ast(quest: (Question) `"<Str s>" <Id id> : <Type t>`)
 = question("<s>",cst2ast(id),cst2ast(t),src=quest@\loc)
;

AQuestion cst2ast(quest: (Question) `"<Str s>" <Id id> : <Type t> = <Expr e>`)
 = computed_question("<s>",cst2ast(id),cst2ast(t),cst2ast(e),src=quest@\loc)
;

AQuestion cst2ast(quest: (Question) `if (<Expr e>) {<Question* qs>}`)
 = iff(cst2ast(e), [cst2ast(q) | Question q <- qs],src=quest@\loc)
;

AQuestion cst2ast(quest: (Question) `if (<Expr e>) {<Question* qs>} else {<Question* qss>}`)
 = iffelse(cst2ast(e), [cst2ast(q) | Question q <- qs], [cst2ast(q1) | Question q1 <- qss],src=quest@\loc)
;

AExpr cst2ast(ex: (Expr) `<Id id>`)
 = ref(cst2ast(id),src=ex@\loc)
;

AExpr cst2ast(ex: (Expr) `<Str s>`)
 = qStr("<s>",src=ex@\loc)
;

AExpr cst2ast(ex: (Expr) `<Int s>`)
 = \val(toInt("<s>"),src=ex@\loc)
;

AExpr cst2ast(ex: (Expr) `<Bool s>`)
 = boolVal(toBool("<s>"),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `(<Expr e>)`)
 = cst2ast(e)
 // before::  = cst2ast(e,src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `! <Expr e>`)
 = not(cst2ast(e),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> * <Expr rhs>`)
 = mult(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> / <Expr rhs>`)
 = div(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> + <Expr rhs>`)
 = plus(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> - <Expr rhs>`)
 = minus(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> \<= <Expr rhs>`)
 = leq(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> \< <Expr rhs>`)
 = lt(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> \> <Expr rhs>`)
 = gt(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> \>= <Expr rhs>`)
 = geq(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> == <Expr rhs>`)
 = eq(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> != <Expr rhs>`)
 = neq(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> && <Expr rhs>`)
 = and(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AExpr cst2ast(ex:(Expr) `<Expr lhs> || <Expr rhs>`)
 = or(cst2ast(lhs),cst2ast(rhs),src=ex@\loc)
;

AType cst2ast(ex:(Type) `<Type t>`)
 = typeVar("<t>",src=ex@\loc)
;

AId cst2ast(aid:(Id) `<Id i>`)
 = id("<i>",src=aid@\loc)
;
 
 /*

AForm cst2ast(start[Form] sf) {
  Form f = sf.top; // remove layout before and after form
  return form("", [], src=f@\loc); 
}

AQuestion cst2ast(Question q) {
  throw "Not yet implemented";
}

AExpr cst2ast(Expr e) {
  switch (e) {
    case (Expr)`<Id x>`: return ref(id("<x>", src=x@\loc), src=x@\loc);
    
    // etc.
    
    default: throw "Unhandled expression: <e>";
  }
}

AType cst2ast(Type t) {
  throw "Not yet implemented";
}

*/
