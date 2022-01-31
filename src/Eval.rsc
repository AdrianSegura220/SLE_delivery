module Eval

import AST;
import Resolve;
import IO;

/*
 * Implement big-step semantics for QL
 */
 
// NB: Eval may assume the form is type- and name-correct.


// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input
  = input(str question, Value \value);
  
Value assignDefault(AType t){
  Value toret;
  switch(t.name){
  	case "boolean": toret = vbool(false);
  	
  	case "integer": toret = vint(0);
  	
  	case "vstr" : toret = vstr("");
  
  }
  return toret;
}
  
// produce an environment which for each question has a default value
// (e.g. 0 for int, "" for str etc.)
VEnv initialEnv(AForm f) {
  map[str name, Value \value] tempvenv = ();
  
  // normal questions, assign their value based on the declared type. Reference in the map uses variable name
  for(/AQuestion quest: /question(str q,AId name,AType t) := f){
  	println(name.name);
  	tempvenv[name.name] = assignDefault(t);
  }
 
  // computed questions, assign their value based on the declared type. Reference in the map uses variable name (SAME THING )
  for(/AQuestion quest: /computed_question(str q,AId name,AType t,AExpr e) := f){
    println(name.name);
  	tempvenv[name.name] = assignDefault(t);
  } 
  
  return tempvenv;
}


// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(AForm f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

VEnv evalOnce(AForm f, Input inp, VEnv venv) {

  VEnv temp = venv;
  temp[inp.question] = inp.\value; //check if this is the right thing to do (what I am doing here basically is set the question value to the input)
  
  for(qst <- f.questions){
  	temp = eval(qst,inp,temp);
  }
  
  return temp; 
}

VEnv eval(AQuestion q, Input inp, VEnv venv) {

  VEnv temp = venv;
  
  if(q is iff || q is iffelse){
  	if(eval(q.guard,venv).b){ // check if guard is true (access the expression's evaluation boolean value b)
  		for(qst <- q.questions){
  			temp = eval(qst,inp,temp); //evaluate each question in if's code block
  		}
  	}else{
	  	if(q is iffelse){ // the only case where the else of the iffelse type of question would be triggered
	  		for(qst <- q.questions2){
	  			temp = eval(qst,inp,venv); //evaluate each question in else's code block
	  		}
	  	}
  	}
  }
  
  if(q is computed_question){
  	temp[q.name.name] = eval(q.e,temp); // compute expression for computed_question (might be updated if somehow some input affected the variables from which this c_q depends)
  }
  // evaluate conditions for branching,
  // evaluate inp and computed questions to return updated VEnv
  return temp; 
}

Value eval(AExpr e, VEnv venv) {
  switch (e) {
    case ref(id(str x)): return venv[x];
    
    case qStr(str name): return vstr(name);
    
    case val(int v): return vint(v);
    
    case boolVal(bool b): return vbool(b);
    
    case mult(AExpr lhs, AExpr rhs): return vint(eval(lhs,venv).n * eval(rhs,venv).n);
    
    case div(AExpr lhs, AExpr rhs):
    	if(eval(rhs,venv).n != 0){ // case division by zero
    		return vint(eval(lhs,venv).n / eval(rhs,venv).n);
    	}else{
    		throw "Division by zero detected <e>";
    	}
    
    case plus(AExpr lhs, AExpr rhs): return vint(eval(lhs,venv).n + eval(rhs,venv).n);
    
    case minus(AExpr lhs, AExpr rhs): return vint(eval(lhs,venv).n - eval(rhs,venv).n);
    
    case lt(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).n < eval(rhs,venv).n);

	case leq(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).n <= eval(rhs,venv).n);
	
	case gt(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).n > eval(rhs,venv).n);
	
	case geq(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).n >= eval(rhs,venv).n);
	
	case eq(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).n == eval(rhs,venv).n);
	
	case neq(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).n != eval(rhs,venv).n);
	
	case and(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).b && eval(rhs,venv).b);
	
	case or(AExpr lhs, AExpr rhs): return vbool(eval(lhs,venv).b && eval(rhs,venv).b);
	
	case not(AExpr expr): return vbool(!eval(expr,venv).b);
    // etc.
    default: throw "Unsupported expression <e>";
  }
}