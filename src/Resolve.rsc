module Resolve

import AST;

/*
 * Name resolution for QL
 */ 


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(AForm f) = <us, ds, us o ds>
  when Use us := uses(f), Def ds := defs(f);

Use uses(AForm f) {
  //rel[loc,str] variableUses = { <i.src,name> | /i:id(str name) := f};
  rel[loc,str] variableUses = { <i.src,id.name> | /i:ref(AId id) := f};
  return variableUses; 
  //before : return {}; 
}

Def defs(AForm f) {
  /* variablesQuestions contains f.name.name because the first .name represents
  	 the part of question(.. or computed_question in AQuestion for the parameter
  	 AId name. Then AId name contains in data AId(...) the result = id(str name) so
  	 name comes from there
  */
  rel[str,loc] variablesQuestions = { <q.name.name,q.src> | /AQuestion q := f, q has name};
  //rel[str,loc] questionStrings = { <quest.q,quest.src> | /AQuestion quest := f, quest has q};
  return variablesQuestions;
  //before : return {}; 
}