module Syntax

extend lang::std::Layout;
extend lang::std::Id;
import IDE;


start syntax Form
  = "form" Id "{" Question* "}";

// TODO: question, computed question, block, if-then-else, if-then
syntax Question
  = "if" "("Expr")" "{" Question* "}"
  | "if" "("Expr")" "{" Question* "}" "else" "{" Question* "}"
  | "\""Str"\"" Id":" Type
  | "\""Str"\"" Id":" Type "=" Expr 
  ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr
  = Id \ "true" \ "false" // true/false are reserved keywords.
  | Str
  | Int
  | Bool
  | bracket "(" Expr ")"
  | "!" Expr
  > 
  left (
  	  left Expr "*" Expr \ "true" \ "false"
  	| left Expr "/" Expr \ "true" \ "false"
  )
  > 
  left (
  	  left Expr "+" Expr \ "true" \ "false"
    | left Expr "-" Expr \ "true" \ "false"
  )
  > 
  non-assoc (
  	  non-assoc Expr "\<" Expr \ "true" \ "false"
  	| non-assoc Expr "\<=" Expr \ "true" \ "false"
  	| non-assoc Expr "\>" Expr \ "true" \ "false"
  	| non-assoc Expr "\>=" Expr \ "true" \ "false"
  )
  > 
  left (
  	  left Expr "==" Expr
  	| left Expr "!=" Expr
  )
  > left Expr "&&" Expr
  >	left Expr "||" Expr
  ;

syntax Type
 = "boolean"
 | "integer"
 | "string"
 ;

lexical Str = [A-Z][\t-\n\r\ A-Z a-z 0-9 _?:()]*;

lexical Int
  = "0"
  | [1-9][0-9]*;

lexical Bool 
= "true"
 | "false"
 ;


  
