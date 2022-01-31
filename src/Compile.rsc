module Compile

import AST;
import Resolve;
import IO;
import lang::html5::DOM; // see standard library
import String;

/*
 * Implement a compiler for QL to HTML and Javascript
 *
 * - assume the form is type- and name-correct
 * - separate the compiler in two parts form2html and form2js producing 2 files
 * - use string templates to generate Javascript
 * - use the HTML5Node type and the `str toString(HTML5Node x)` function to format to string
 * - use any client web framework (e.g. Vue, React, jQuery, whatever) you like for event handling
 * - map booleans to checkboxes, strings to textfields, ints to numeric text fields
 * - be sure to generate uneditable widgets for computed questions!
 * - if needed, use the name analysis to link uses to definitions \<div\> whatever \</div\>\n\<p\> hohoho \</p\>
 */

void compile(AForm f) {
  writeFile(f.src[extension="js"].top, form2js(f));
  writeFile(f.src[extension="html"].top, form2html(f));
}

str setDefVal(AType t){
	str def = "";
	switch(t.name){
		case "integer": def = "0";
		case "string": def = "";
		case "boolean": def = "false";
	}
	return def;
}

str setTypeQ(AType t){
	str typ = "";
	switch(t.name){
		case "integer": typ = "number";
		case "string": typ = "text";
		case "boolean": typ = "checkbox";
	}
	return typ;
}

str getFname(str fileN){
	lastIdx = 0;
	for(int i <- [1..size(fileN)]){
		if(fileN[i] == "/"){
			lastIdx = i;
		}
	}
	
	return fileN[lastIdx+1..];
}

str form2html(AForm f) {
  str htmlCode = "\<head\>\n
				 '\<title\>Page Title\</title\>
				 '\</head\>";
  
  for(quest <- f.questions){
  	htmlCode += questions2html(quest,false);
  }
  fname = "<f.src[extension="js"].top>"[23..-1];
  htmlCode += "\<script src=\"<fname>\"\>\</script\>\n";
  return htmlCode;
  //return html(htmlCode);
}

str questions2html(AQuestion q,bool wasIf){

	str htmlCode = "";
	str displ = wasIf ? "none" : "block";
	
	if(q is iff || q is iffelse){
		for(quest <- q.questions){
  			htmlCode += questions2html(quest,true);
 		};
 		if(q is iffelse){
 			for(quest <- q.questions2){
  				htmlCode += questions2html(quest,true);
 			};
 		}
	}
	
	if(q is question){
		htmlCode += "\<div id=\"<q.name.name>Div\" style=\"display: <displ>;\"\>
			   ' \<label for=\"<q.name.name>\"\><q.q>\</label\>
               ' \<input id=\"<q.name.name>\" type=\"<setTypeQ(q.t)>\" name=\"<q.name.name>\" onchange=\"updateQuestionaire(\'<q.name.name>\')\"\>
			   '\</div\>
			   ' 
			   ' 
			   ";
	}
	
	if(q is computed_question){
		htmlCode += "\<div id=\"<q.name.name>Div\" style=\"display: <displ>;\"\>
			   ' \<label for=\"<q.name.name>\"\><q.q>\</label\>
               ' \<input id=\"<q.name.name>\" type=\"<setTypeQ(q.t)>\" name=\"<q.name.name>\" disabled \>
			   '\</div\>
			   ' 
			   ' 
			   ";
	}
	
	return htmlCode;
	//return html(htmlCode);
}

str form2js(AForm f) {
  str jsCode = "";
  
  //base elements of js template
  jsCode += "const venv = new Map()\n 
   			'const questionBank = new Map()\n
   			";
  
  for(quest <- f.questions){
  	jsCode += question2jsInit(quest); //initialise necessary variables
  }
  
  jsCode += baseJSFunctions();
  
  for(quest <- f.questions){
  	jsCode += question2js(quest); //initialise necessary variables
  }
  
  jsCode += "\n}\n";
  return jsCode;
}

str question2jsInit(AQuestion q){
	str jsCode = "";
	
	if(q is iff || q is iffelse){
		//generate expression here for IF
		for(quest <- q.questions){
  			jsCode += question2jsInit(quest);
 		};
 		if(q is iffelse){
 		//generate expression here for else part (use an else if())
 			for(quest <- q.questions2){
  				jsCode += question2jsInit(quest);
 			};
 		}
	}
	
	if(q is question){
		//for each question generate a value in the map
		jsCode += "venv.set(\'<q.name.name>\',{variableId:\"<q.name.name>\",type:\"<setTypeQ(q.t)>\",value:<setDefVal(q.t)>,active:true,default:true})\n";
	}
	
	if(q is computed_question){
		//for each question generate a value in the map
		jsCode += "venv.set(\'<q.name.name>\',{variableId:\"<q.name.name>\",type:\"<setTypeQ(q.t)>\",value:<setDefVal(q.t)>,active:true,default:true})\n";
	}
	
	return jsCode;
}

str question2js(AQuestion q){
	str jsCode = "";
	set[str] dependencies = {};
	set[str] nestedIf = {};
	set[str] nestedElse = {};
	if(q is iff || q is iffelse){
	
		for(quest <- q.questions){ nestedIf += nestedElements(quest,nestedIf); }
		if(q is iffelse){
			for(quest <- q.questions2){ nestedElse += nestedElements(quest,nestedElse); }
		}
	
		//generate expression here for IF
		dependencies = findDependencies(q.guard,{});
		jsCode += "if(";
		
		//check if dependencies are set with non-default value (generate code for that preceding the actual guard):
		
		str guard = "<generateExpression(q.guard)>";
		jsCode += guard+"){\n"; //finally, at the end of the conjunctions generate actual guard and opening bracket for if block
		
		//make visible all nested elements contained in if case
		for(name <- nestedIf){ jsCode += "makeVisible(\'<name>\')\n"; };
		
		for(name <- nestedElse){ jsCode += "makeInvisible(\'<name>\')\n"; };
		
		for(quest <- q.questions){ jsCode += question2js(quest); };
 		
 		if(q is iffelse){
 			jsCode += "}else if(";
 		
			jsCode += "!"+guard+"){\n"; 
			
			//no need to generate the guard's expression again, so we just use it
 			//generate expression here for else part (use an else if())
			//toggle visibility of divs that hold questions to be made available
			for(name <- nestedElse){ jsCode += "makeVisible(\'<name>\')\n"; };
			
			//make invisible all questions where guard is not met (if-branch)
			for(name <- nestedIf){ jsCode += "makeInvisible(\'<name>\')\n"; };

 			for(quest <- q.questions2){ jsCode += question2js(quest);};
 			
 			jsCode += "}\n";
 		}else{
 		//closing bracket for normal if
 			jsCode += "}else if(";
 			
	
			jsCode += "!"+guard+"){\n"; 
			
			//in case the guard of a normal if-case is not met, then it's questions should be made invisible
			for(name <- nestedIf){ jsCode += "makeInvisible(\'<name>\')\n"; };
			
			jsCode += "}\n";
 		}
 		
 	}
	
	
	if(q is computed_question){
		//for each question generate a value in the map
		set[str] dependenciesCQ = findDependencies(q.e,{});
		jsCode += "if(";
		
		jsCode += "true ){\n";
		
		jsCode += "computation = <generateExpression(q.e)>\n";
		jsCode += "setComputedQuestion(\'<q.name.name>\',computation)\n";
		
		jsCode += "}\n";
	}
	
	return jsCode;
}

str generateExpression(AExpr e){
	str resExpr = "";
	switch(e){
		case ref(AId id): resExpr += "(venv.get(\'<id.name>\').value)"; // get the value from the map of values
		case qStr(str name): resExpr += "<name>";
		case val(int v): resExpr += "<v>";
		case boolVal(bool b): resExpr += "<b>";
		case not(AExpr arg): resExpr += "!<generateExpression(arg)>";
		case mult(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>*<generateExpression(rhs)>)";
		case div(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>/<generateExpression(rhs)>)";
		case plus(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>+<generateExpression(rhs)>)";
		case minus(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>-<generateExpression(rhs)>)";
		case lt(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>\<<generateExpression(rhs)>)";
		case leq(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>\<=<generateExpression(rhs)>)";
		case gt(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>\><generateExpression(rhs)>)";
		case geq(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>\>=<generateExpression(rhs)>)";
		case eq(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>==<generateExpression(rhs)>)";
		case neq(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>!=<generateExpression(rhs)>)";
		case and(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>&&<generateExpression(rhs)>)";
		case or(AExpr lhs,AExpr rhs): resExpr += "(<generateExpression(lhs)>||<generateExpression(rhs)>)";
		
	}
	return resExpr;
}

set[str] findDependencies(AExpr e,set[str] dep){
	set[str] dependencies = {};
	switch(e){
		case ref(AId id): dependencies += {"<id.name>"};
		case not(AExpr arg): dependencies += findDependencies(arg,dependencies);
		case mult(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case div(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case plus(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case minus(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case lt(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case leq(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case gt(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case geq(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case eq(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case neq(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case and(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		case mult(AExpr lhs,AExpr rhs): dependencies += findDependencies(lhs,dependencies)+findDependencies(rhs,dependencies);
		default: ;
		
	}
	dep += dependencies;
	return dep;
}

set[str] nestedElements(AQuestion q,set[str] acc){ // find variable names of all nested elements of some if-statement

	if(q is question || q is computed_question){
		for(quest <- q){
			acc += {q.name.name};
		}
	}
	
	if(q is iff){
		for(quest <- q.questions){
			acc += nestedElements(quest,acc);
		}
	}
	
	if(q is iffelse){
		for(quest <- q.questions){
			acc += nestedElements(quest,acc);
		}
		for(quest <- q.questions2){
			acc += nestedElements(quest,acc);
		}
	}
	
	return acc;
}

str baseJSFunctions(){ // template for base functions needed to manage the events
	str base = "";
	base += "
			' function makeInvisible(question){
			'     document.getElementById(question+\"Div\").style.display = \'none\'
			' }
			' function makeVisible(question){
			'     document.getElementById(question+\"Div\").style.display = \'block\'
			' }
		 	' function getValueDOM(question){
		 	'     return document.getElementById(venv.get(question).variableId).value
		 	' }
		 	' 
		 	' function setQuestion(question){
		 	' 	  
		 	'     input = null
		 	'     if(venv.get(question).type == \"checkbox\"){
		 	' 		  console.log(\"checkbox value = \"+document.getElementById(question).value)
		 	'         if(document.getElementById(question).checked){
		 	'			  input = true
		 	'         }else{
		 	' 			  input = false
		 	'         }
		 	'     }else{
		 	'         input = getValueDOM(question)
		 	'     }
		 	'     venv.set(question,{variableId: venv.get(question).variableId, 
		 	'     	type:venv.get(question).type, 
		 	'     	value:input,
		 	'     	active:venv.get(question).active,
		 	'     	default: false
		 	'     })
		 	' }
		 	'
		 	' function setComputedQuestion(question,computation){
		 	'     input = getValueDOM(question)
		 	'     venv.set(question,{variableId: venv.get(question).variableId, 
		 	'     	type:venv.get(question).type, 
		 	'     	value:input,
		 	'     	active:venv.get(question).active,
		 	'     	default: false
		 	'     })
		 	'     document.getElementById(question).value = computation
		 	' }
		 	' 
		 	' function setActive(question){
		 	'     venv.set(question,{variableId: venv.get(question).variableId, 
		 	'         type:venv.get(question).type,
		 	'         value:venv.get(question).value,
		 	'         active:true, //change its active value to true
		 	'         default: false
		 	'      })
		 	'      document.getElementById(question+\"\").style.display = \"block\"
		 	' }
		 	' 
		 	' function isDefaultValue(variableName){
		 	'    if(!venv.get(variableName).default){ 
		 	'         return false
		 	'     }
		 	'     return true
		 	' }
		 	' 
		 	' function getValue(variableName){
		 	'     return venv.get(questionBank.get(variableName)).value
		 	' }
		 	' 
		 	' // start of update function:
		 	' 
		 	' function updateQuestionaire(question){
		 	'     //setting question to new value using input obtained from event (look for it in the DOM inside the function)
		 	' 	    setQuestion(question)\n";
	return base;
}
