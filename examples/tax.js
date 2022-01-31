const venv = new Map()
 
const questionBank = new Map()

   			venv.set('hasBoughtHouse',{variableId:"hasBoughtHouse",type:"checkbox",value:false,active:true,default:true})
venv.set('hasMaintLoan',{variableId:"hasMaintLoan",type:"checkbox",value:false,active:true,default:true})
venv.set('hasSoldHouse',{variableId:"hasSoldHouse",type:"checkbox",value:false,active:true,default:true})
venv.set('sellingPrice',{variableId:"sellingPrice",type:"number",value:0,active:true,default:true})
venv.set('privateDebt',{variableId:"privateDebt",type:"number",value:0,active:true,default:true})
venv.set('valueResidue',{variableId:"valueResidue",type:"number",value:0,active:true,default:true})

 function makeInvisible(question){
     document.getElementById(question+"Div").style.display = 'none'
 }
 function makeVisible(question){
     document.getElementById(question+"Div").style.display = 'block'
 }
 function getValueDOM(question){
     return document.getElementById(venv.get(question).variableId).value
 }
 
 function setQuestion(question){
 	  
     input = null
     if(venv.get(question).type == "checkbox"){
 		  console.log("checkbox value = "+document.getElementById(question).value)
         if(document.getElementById(question).checked){
			  input = true
         }else{
 			  input = false
         }
     }else{
         input = getValueDOM(question)
     }
     venv.set(question,{variableId: venv.get(question).variableId, 
     	type:venv.get(question).type, 
     	value:input,
     	active:venv.get(question).active,
     	default: false
     })
 }

 function setComputedQuestion(question,computation){
     input = getValueDOM(question)
     venv.set(question,{variableId: venv.get(question).variableId, 
     	type:venv.get(question).type, 
     	value:input,
     	active:venv.get(question).active,
     	default: false
     })
     document.getElementById(question).value = computation
 }
 
 function setActive(question){
     venv.set(question,{variableId: venv.get(question).variableId, 
         type:venv.get(question).type,
         value:venv.get(question).value,
         active:true, //change its active value to true
         default: false
      })
      document.getElementById(question+"").style.display = "block"
 }
 
 function isDefaultValue(variableName){
    if(!venv.get(variableName).default){ 
         return false
     }
     return true
 }
 
 function getValue(variableName){
     return venv.get(questionBank.get(variableName)).value
 }
 
 // start of update function:
 
 function updateQuestionaire(question){
     //setting question to new value using input obtained from event (look for it in the DOM inside the function)
 	    setQuestion(question)
if((venv.get('hasSoldHouse').value)){
makeVisible('privateDebt')
makeVisible('sellingPrice')
makeVisible('valueResidue')
if(true ){
computation = ((venv.get('sellingPrice').value)-(venv.get('privateDebt').value))
setComputedQuestion('valueResidue',computation)
}
}else if(!(venv.get('hasSoldHouse').value)){
makeInvisible('privateDebt')
makeInvisible('sellingPrice')
makeInvisible('valueResidue')
}

}
