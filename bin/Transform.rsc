module Transform

import Syntax;
import Resolve;
import AST;
import ParseTree;

/* 
 * Transforming QL forms
 */
 
 
/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
AForm flatten(AForm f) {
  f.questions = flatten(f.questions,[]);
  return f; 
}


list[AQuestion] flatten(list[AQuestion] questions,list[AExpr] dependencies){
	list[AQuestion] temp = [];
	for(quest <- questions){
		switch(quest){
			case question(str _,AId _,AType _): temp += rename(dependencies,quest);
			case computed_question(str q,AId name,AType t,AExpr e): temp += rename(dependencies,quest);
			case iff(AExpr guard,list[AQuestion] qsts): temp += flatten(qsts,dependencies+guard);
			case iffelse(AExpr guard, list[AQuestion] qsts, list[AQuestion] qsts2): temp += (flatten(qsts,dependencies+guard)+flatten(qsts2,dependencies+not(guard)));
		}
	}
	
	return temp;
}


AQuestion rename(list[AExpr] dependencies,AQuestion question){
	AExpr check = boolVal(true);
	AQuestion res;
	for(dep <- dependencies){
		check = and(check,dep);
	}

	res = iff(check,[question]);
	return res;
}
/* Rename refactoring:
 *
 * Write a refactoring transformation that consistently renames all occurrences of the same name.
 * Use the results of name resolution to find the equivalence class of a name.
 *
 */
 
 start[Form] rename(start[Form] f, loc useOrDef, str newName, UseDef useDef) {
   set[loc] toRename = {};
   toRename += {useOrDef};
   bool inud = false;
   bool isUse = false;
   for(ud <- useDef){
    	if(ud<1> == useOrDef){
    		inud = true;
    		isUse = false;
    		toRename += {u | <loc u,useOrDef> <- useDef};
    		break;
    	}else{
    		if(ud<0> == useOrDef){
    			inud = true;
    			isUse = true;
    			toRename += {d | <useOrDef,loc d> <- useDef};
    			break;
    		}
    	}
   }
  
   if(!inud){ //case the location to rename is not present
   	return f;
   }
   
   return visit(f){
   		case Id name => [Id]newName
   			when name@\loc in toRename
   }
   
   

 } 
 
 
 

