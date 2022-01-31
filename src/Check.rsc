module Check

import IO;
import AST;
import Resolve;
import Message; // see standard library

data Type
  = tint()
  | tbool()
  | tstr()
  | tunknown()
  ;

// the type environment consisting of defined questions in the form 
alias TEnv = rel[loc def, str name, str label, Type \type];


Type assignType(str t){
	Type typ = tunknown();
	if(t == "boolean"){
		typ = tbool();
	}else{ 
		if(t == "integer"){
			typ = tint();
		}else{
			if(t == "string"){
				typ = tstr();
			}
		}
	}
	return typ;
}

// To avoid recursively traversing the form, use the `visit` construct
// or deep match (e.g., `for (/question(...) := f) {...}` ) 
TEnv collect(AForm f) {
  rel[loc, str, str, Type] tenv = {};
  for(/AQuestion quest: /question(str q,AId name,AType t) := f){
  	tenv += <quest.src,q,name.name,assignType(t.name)>;
  	tenv += <quest.src,name.name,name.name,assignType(t.name)>; // idk lets see (trying to add id types)
  };
  for(/AQuestion quest: /computed_question(str q,AId name,AType t,AExpr e) := f){
  	tenv += <quest.src,q,name.name,assignType(t.name)>;
  	tenv += <quest.src,name.name,name.name,assignType(t.name)>; // idk lets see (trying to add id types)
  };


  //rel[loc, str, str, Type] strngs = { <exp.src,exp.name,exp.name,tstr()> | /AExpr exp := f, exp has name};
  //rel[loc, str, str, Type] refs = { <exp.id.src,exp.id.name,exp.id.name,tstr()> | /AExpr exp := f, exp has id};
  
  // references types:
  
  rel[loc, str, str, Type] refs = {}; 
  for(ten <- tenv){
  	for(/ref(AId id) := f){
  		if(ten<1> == id.name){
  			refs += {<id.src,id.name,id.name,ten<3>>};
  		}
  	}
  }
  
  return tenv+refs; 
}


set[Message] check(AForm f, TEnv tenv, UseDef useDef) {
  RefGraph rg = resolve(f);
  
  set[Message] messages = {};
  for(/ref(AId id) := f){
  	if(id.src notin rg.useDef<0>){
  		messages += {error("Undefined variable",id.src)};
  	}
  }

  // try refactoring the two following loops into one using has case and selecting questions from the form f: f.questions
  map[str,Type] seen = ();
  for(/AQuestion quest: question(str q,AId name,AType t) := f){
  	if(q in seen){
  		if(seen[q] != assignType(t.name)){
  			messages += {error("Multiple declarations for question with different types",name.src)};
  		}else{
  			messages += {warning("Multiple declarations for question",quest.src)}; 		
  		}
  	}else{
  		seen[q] = assignType(t.name);
  	}
  }
  
  map[str,Type] seenCQ = ();
  for(/AQuestion quest: computed_question(str q,AId name,AType t,AExpr e) := f){
  	if(q in seenCQ){
  		if(seenCQ[q] != assignType(t.name)){
  			messages += {error("Multiple declarations for question with different types",name.src)};
  		}else{
  			messages += {warning("Duplicate labels",quest.src)}; 		
  		}
  	}else{
  		seenCQ[q] = assignType(t.name);
  	}
  	messages += check(e,tenv,useDef);
  	if(assignType(t.name) != typeOf(e,tenv,useDef)){
  		messages += {error("Computed question type and assignment must match",name.src)};
  	}
  }
  
  for(qst <- f.questions){
  	messages += check(qst,tenv,useDef);
  }
  
  return messages; 
}

// - produce an error if there are declared questions with the same name but different types.
// - duplicate labels should trigger a warning 
// - the declared type computed questions should match the type of the expression.
set[Message] check(AQuestion q, TEnv tenv, UseDef useDef) {
  set[Message] messages = {};

  //RefGraph rg = resolve(f);
  
  
  if (q is iff){
  	if(typeOf(q.guard,tenv,useDef) != tbool()){
  		messages += {error("Guards must be of type boolean",q.guard.src)};
  	}
  	for(qst <- q.questions){
  		messages += check(qst,tenv,useDef);
  	}
  	return messages;
  }
  
   if (q is iffelse){
  	if(typeOf(q.guard,tenv,useDef) != tbool()){
  		messages += {error("Guards must be of type boolean",q.guard.src)};
  	}
  	for(qst <- q.questions){
  		messages += check(qst,tenv,useDef);
  	}
  	for(qst2 <- q.questions2){
  		messages += check(qst2,tenv,useDef);
  	}
  	return messages;
  }
  
  if(q is computed_question){
  	messages += check(q.e,tenv,useDef);
  	return messages;
  }
  
  //return {};
  return messages; 
}



// Check operand compatibility with operators.
// E.g. for an addition node add(lhs, rhs), 
//   the requirement is that typeOf(lhs) == typeOf(rhs) == tint()
set[Message] check(AExpr e, TEnv tenv, UseDef useDef) {
  set[Message] msgs = {};
  
  switch (e) {
    case ref(AId x):
      msgs += { error("Undeclared question", x.src) | useDef[x.src] == {} };
      
	case mult(AExpr lhs,AExpr rhs):
      msgs += { error("Multiplication must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case div(AExpr lhs,AExpr rhs):
      msgs += { error("Division must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case plus(AExpr lhs,AExpr rhs):
      msgs += { error("Addition must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case minus(AExpr lhs,AExpr rhs):
      msgs += { error("Subtraction must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case lt(AExpr lhs,AExpr rhs):
      msgs += { error("Less-than comparison must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case leq(AExpr lhs,AExpr rhs):
      msgs += { error("Less-than-equal must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case gt(AExpr lhs,AExpr rhs):
      msgs += { error("Greater-than must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case geq(AExpr lhs,AExpr rhs):
      msgs += { error("Greater-than-equal must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case eq(AExpr lhs,AExpr rhs):
      msgs += { error("Equal must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case neq(AExpr lhs,AExpr rhs):
      msgs += { error("Not-equal must use integers", lhs.src) | (typeOf(lhs,tenv,useDef) != tint() || typeOf(rhs,tenv,useDef) != tint()) };
      
	case and(AExpr lhs,AExpr rhs):
      msgs += { error("And operator must use boolean values", lhs.src) | (typeOf(lhs,tenv,useDef) != tbool() || typeOf(rhs,tenv,useDef) != tbool()) };
      
	case not(AExpr exp):
      msgs += { error("Or operator must use a boolean expression", exp.src) | typeOf(exp,tenv,useDef) != tbool() };
      
	case or(AExpr lhs,AExpr rhs):
      msgs += { error("Or operator must use boolean values", lhs.src) | (typeOf(lhs,tenv,useDef) != tbool() || typeOf(rhs,tenv,useDef) != tbool()) };
	
  }
  
  return msgs; 
}

Type typeOf(AExpr e, TEnv tenv, UseDef useDef) {
  switch (e) {
    case ref(id(_, src = loc u)):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
      
      
     case qStr(str _, src = loc u):  
      if (<u, loc d> <- useDef, <d, x, _, Type t> <- tenv) {
        return t;
      }
      
     case val(int _, src = loc u):  return tint();
     
     case boolVal(bool _): return tbool();

	 case not(AExpr arg): return typeOf(arg,tenv,useDef);
	 
	 case mult(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef)){
	 		return typeOf(lhs,tenv,useDef);
	 	}else{
	 		return tunknown();
	 	}
	 	
	 	
	 case div(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef)){
	 		return typeOf(lhs,tenv,useDef);
	 	}else{
	 		return tunknown();
	 	}

	 case plus(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef)){
	 		return typeOf(lhs,tenv,useDef);
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case minus(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef)){
	 		return typeOf(lhs,tenv,useDef);
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case lt(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && typeOf(rhs,tenv,useDef) == tint()){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case leq(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && typeOf(rhs,tenv,useDef) == tint()){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case gt(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && typeOf(rhs,tenv,useDef) == tint()){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case geq(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && typeOf(rhs,tenv,useDef) == tint()){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case eq(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && (typeOf(rhs,tenv,useDef) == tint() || typeOf(rhs,tenv,useDef) == tbool())){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case neq(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && (typeOf(rhs,tenv,useDef) == tint() || typeOf(rhs,tenv,useDef) == tbool())){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case and(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && typeOf(rhs,tenv,useDef) == tbool()){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 	
	 case or(AExpr lhs, AExpr rhs):
	 	if(typeOf(lhs,tenv,useDef) == typeOf(rhs,tenv,useDef) && typeOf(rhs,tenv,useDef) == tbool()){
	 		return tbool();
	 	}else{
	 		return tunknown();
	 	}
	 default: return tunknown();
  }
  return tunknown(); 
}

/* 
 * Pattern-based dispatch style:
 * 
 * Type typeOf(ref(id(_, src = loc u)), TEnv tenv, UseDef useDef) = t
 *   when <u, loc d> <- useDef, <d, x, _, Type t> <- tenv
 *
 * ... etc.
 * 
 * default Type typeOf(AExpr _, TEnv _, UseDef _) = tunknown();
 *
 */
 
 

