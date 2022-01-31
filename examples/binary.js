const venv = new Map()
 
const questionBank = new Map()

   			venv.set('x_1_10',{variableId:"x_1_10",type:"checkbox",value:false,active:true,default:true})
venv.set('x_1_5',{variableId:"x_1_5",type:"checkbox",value:false,active:true,default:true})
venv.set('x_1_3',{variableId:"x_1_3",type:"checkbox",value:false,active:true,default:true})
venv.set('x_1_2',{variableId:"x_1_2",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_1_2',{variableId:"answer_1_2",type:"number",value:0,active:true,default:true})
venv.set('answer_2_3',{variableId:"answer_2_3",type:"number",value:0,active:true,default:true})
venv.set('x_3_4',{variableId:"x_3_4",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_3_4',{variableId:"answer_3_4",type:"number",value:0,active:true,default:true})
venv.set('answer_4_5',{variableId:"answer_4_5",type:"number",value:0,active:true,default:true})
venv.set('x_5_7',{variableId:"x_5_7",type:"checkbox",value:false,active:true,default:true})
venv.set('x_5_6',{variableId:"x_5_6",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_5_6',{variableId:"answer_5_6",type:"number",value:0,active:true,default:true})
venv.set('answer_6_7',{variableId:"answer_6_7",type:"number",value:0,active:true,default:true})
venv.set('x_7_8',{variableId:"x_7_8",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_7_8',{variableId:"answer_7_8",type:"number",value:0,active:true,default:true})
venv.set('x_8_9',{variableId:"x_8_9",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_8_9',{variableId:"answer_8_9",type:"number",value:0,active:true,default:true})
venv.set('answer_9_10',{variableId:"answer_9_10",type:"number",value:0,active:true,default:true})
venv.set('x_10_15',{variableId:"x_10_15",type:"checkbox",value:false,active:true,default:true})
venv.set('x_10_12',{variableId:"x_10_12",type:"checkbox",value:false,active:true,default:true})
venv.set('x_10_11',{variableId:"x_10_11",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_10_11',{variableId:"answer_10_11",type:"number",value:0,active:true,default:true})
venv.set('answer_11_12',{variableId:"answer_11_12",type:"number",value:0,active:true,default:true})
venv.set('x_12_13',{variableId:"x_12_13",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_12_13',{variableId:"answer_12_13",type:"number",value:0,active:true,default:true})
venv.set('x_13_14',{variableId:"x_13_14",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_13_14',{variableId:"answer_13_14",type:"number",value:0,active:true,default:true})
venv.set('answer_14_15',{variableId:"answer_14_15",type:"number",value:0,active:true,default:true})
venv.set('x_15_17',{variableId:"x_15_17",type:"checkbox",value:false,active:true,default:true})
venv.set('x_15_16',{variableId:"x_15_16",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_15_16',{variableId:"answer_15_16",type:"number",value:0,active:true,default:true})
venv.set('answer_16_17',{variableId:"answer_16_17",type:"number",value:0,active:true,default:true})
venv.set('x_17_18',{variableId:"x_17_18",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_17_18',{variableId:"answer_17_18",type:"number",value:0,active:true,default:true})
venv.set('x_18_19',{variableId:"x_18_19",type:"checkbox",value:false,active:true,default:true})
venv.set('answer_18_19',{variableId:"answer_18_19",type:"number",value:0,active:true,default:true})
venv.set('answer_19_20',{variableId:"answer_19_20",type:"number",value:0,active:true,default:true})

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
if((venv.get('x_1_10').value)){
makeVisible('x_1_5')
makeVisible('x_3_4')
makeVisible('answer_1_2')
makeVisible('answer_3_4')
makeVisible('answer_6_7')
makeVisible('answer_7_8')
makeVisible('answer_8_9')
makeVisible('x_1_2')
makeVisible('x_1_3')
makeVisible('x_5_6')
makeVisible('answer_2_3')
makeVisible('x_5_7')
makeVisible('answer_9_10')
makeVisible('x_7_8')
makeVisible('answer_4_5')
makeVisible('x_8_9')
makeVisible('answer_5_6')
makeInvisible('answer_19_20')
makeInvisible('x_10_15')
makeInvisible('x_17_18')
makeInvisible('x_18_19')
makeInvisible('x_10_11')
makeInvisible('x_12_13')
makeInvisible('x_13_14')
makeInvisible('x_15_16')
makeInvisible('x_10_12')
makeInvisible('x_15_17')
makeInvisible('answer_10_11')
makeInvisible('answer_11_12')
makeInvisible('answer_12_13')
makeInvisible('answer_13_14')
makeInvisible('answer_14_15')
makeInvisible('answer_15_16')
makeInvisible('answer_16_17')
makeInvisible('answer_17_18')
makeInvisible('answer_18_19')
if((venv.get('x_1_5').value)){
makeVisible('x_3_4')
makeVisible('answer_1_2')
makeVisible('answer_2_3')
makeVisible('answer_3_4')
makeVisible('answer_4_5')
makeVisible('x_1_2')
makeVisible('x_1_3')
makeInvisible('x_5_6')
makeInvisible('x_7_8')
makeInvisible('answer_6_7')
makeInvisible('answer_7_8')
makeInvisible('answer_8_9')
makeInvisible('x_5_7')
makeInvisible('answer_9_10')
makeInvisible('x_8_9')
makeInvisible('answer_5_6')
if((venv.get('x_1_3').value)){
makeVisible('answer_1_2')
makeVisible('answer_2_3')
makeVisible('x_1_2')
makeInvisible('x_3_4')
makeInvisible('answer_3_4')
makeInvisible('answer_4_5')
if((venv.get('x_1_2').value)){
makeVisible('answer_1_2')
makeInvisible('answer_2_3')
if(true ){
computation = 1
setComputedQuestion('answer_1_2',computation)
}
}else if(!(venv.get('x_1_2').value)){
makeVisible('answer_2_3')
makeInvisible('answer_1_2')
if(true ){
computation = 2
setComputedQuestion('answer_2_3',computation)
}
}
}else if(!(venv.get('x_1_3').value)){
makeVisible('x_3_4')
makeVisible('answer_3_4')
makeVisible('answer_4_5')
makeInvisible('answer_1_2')
makeInvisible('answer_2_3')
makeInvisible('x_1_2')
if((venv.get('x_3_4').value)){
makeVisible('answer_3_4')
makeInvisible('answer_4_5')
if(true ){
computation = 3
setComputedQuestion('answer_3_4',computation)
}
}else if(!(venv.get('x_3_4').value)){
makeVisible('answer_4_5')
makeInvisible('answer_3_4')
if(true ){
computation = 4
setComputedQuestion('answer_4_5',computation)
}
}
}
}else if(!(venv.get('x_1_5').value)){
makeVisible('x_5_6')
makeVisible('x_7_8')
makeVisible('answer_6_7')
makeVisible('answer_7_8')
makeVisible('answer_8_9')
makeVisible('x_5_7')
makeVisible('answer_9_10')
makeVisible('x_8_9')
makeVisible('answer_5_6')
makeInvisible('x_3_4')
makeInvisible('answer_1_2')
makeInvisible('answer_2_3')
makeInvisible('answer_3_4')
makeInvisible('answer_4_5')
makeInvisible('x_1_2')
makeInvisible('x_1_3')
if((venv.get('x_5_7').value)){
makeVisible('x_5_6')
makeVisible('answer_5_6')
makeVisible('answer_6_7')
makeInvisible('answer_9_10')
makeInvisible('x_7_8')
makeInvisible('x_8_9')
makeInvisible('answer_7_8')
makeInvisible('answer_8_9')
if((venv.get('x_5_6').value)){
makeVisible('answer_5_6')
makeInvisible('answer_6_7')
if(true ){
computation = 5
setComputedQuestion('answer_5_6',computation)
}
}else if(!(venv.get('x_5_6').value)){
makeVisible('answer_6_7')
makeInvisible('answer_5_6')
if(true ){
computation = 6
setComputedQuestion('answer_6_7',computation)
}
}
}else if(!(venv.get('x_5_7').value)){
makeVisible('answer_9_10')
makeVisible('x_7_8')
makeVisible('x_8_9')
makeVisible('answer_7_8')
makeVisible('answer_8_9')
makeInvisible('x_5_6')
makeInvisible('answer_5_6')
makeInvisible('answer_6_7')
if((venv.get('x_7_8').value)){
makeVisible('answer_7_8')
makeInvisible('answer_9_10')
makeInvisible('x_8_9')
makeInvisible('answer_8_9')
if(true ){
computation = 7
setComputedQuestion('answer_7_8',computation)
}
}else if(!(venv.get('x_7_8').value)){
makeVisible('answer_9_10')
makeVisible('x_8_9')
makeVisible('answer_8_9')
makeInvisible('answer_7_8')
if((venv.get('x_8_9').value)){
makeVisible('answer_8_9')
makeInvisible('answer_9_10')
if(true ){
computation = 8
setComputedQuestion('answer_8_9',computation)
}
}else if(!(venv.get('x_8_9').value)){
makeVisible('answer_9_10')
makeInvisible('answer_8_9')
if(true ){
computation = 9
setComputedQuestion('answer_9_10',computation)
}
}
}
}
}
}else if(!(venv.get('x_1_10').value)){
makeVisible('answer_19_20')
makeVisible('x_10_15')
makeVisible('x_17_18')
makeVisible('x_18_19')
makeVisible('x_10_11')
makeVisible('x_12_13')
makeVisible('x_13_14')
makeVisible('x_15_16')
makeVisible('x_10_12')
makeVisible('x_15_17')
makeVisible('answer_10_11')
makeVisible('answer_11_12')
makeVisible('answer_12_13')
makeVisible('answer_13_14')
makeVisible('answer_14_15')
makeVisible('answer_15_16')
makeVisible('answer_16_17')
makeVisible('answer_17_18')
makeVisible('answer_18_19')
makeInvisible('x_1_5')
makeInvisible('x_3_4')
makeInvisible('answer_1_2')
makeInvisible('answer_3_4')
makeInvisible('answer_6_7')
makeInvisible('answer_7_8')
makeInvisible('answer_8_9')
makeInvisible('x_1_2')
makeInvisible('x_1_3')
makeInvisible('x_5_6')
makeInvisible('answer_2_3')
makeInvisible('x_5_7')
makeInvisible('answer_9_10')
makeInvisible('x_7_8')
makeInvisible('answer_4_5')
makeInvisible('x_8_9')
makeInvisible('answer_5_6')
if((venv.get('x_10_15').value)){
makeVisible('x_10_12')
makeVisible('x_10_11')
makeVisible('x_12_13')
makeVisible('x_13_14')
makeVisible('answer_10_11')
makeVisible('answer_11_12')
makeVisible('answer_12_13')
makeVisible('answer_13_14')
makeVisible('answer_14_15')
makeInvisible('answer_19_20')
makeInvisible('x_15_17')
makeInvisible('x_17_18')
makeInvisible('x_18_19')
makeInvisible('x_15_16')
makeInvisible('answer_15_16')
makeInvisible('answer_16_17')
makeInvisible('answer_17_18')
makeInvisible('answer_18_19')
if((venv.get('x_10_12').value)){
makeVisible('x_10_11')
makeVisible('answer_10_11')
makeVisible('answer_11_12')
makeInvisible('x_12_13')
makeInvisible('x_13_14')
makeInvisible('answer_12_13')
makeInvisible('answer_13_14')
makeInvisible('answer_14_15')
if((venv.get('x_10_11').value)){
makeVisible('answer_10_11')
makeInvisible('answer_11_12')
if(true ){
computation = 10
setComputedQuestion('answer_10_11',computation)
}
}else if(!(venv.get('x_10_11').value)){
makeVisible('answer_11_12')
makeInvisible('answer_10_11')
if(true ){
computation = 11
setComputedQuestion('answer_11_12',computation)
}
}
}else if(!(venv.get('x_10_12').value)){
makeVisible('x_12_13')
makeVisible('x_13_14')
makeVisible('answer_12_13')
makeVisible('answer_13_14')
makeVisible('answer_14_15')
makeInvisible('x_10_11')
makeInvisible('answer_10_11')
makeInvisible('answer_11_12')
if((venv.get('x_12_13').value)){
makeVisible('answer_12_13')
makeInvisible('x_13_14')
makeInvisible('answer_13_14')
makeInvisible('answer_14_15')
if(true ){
computation = 12
setComputedQuestion('answer_12_13',computation)
}
}else if(!(venv.get('x_12_13').value)){
makeVisible('x_13_14')
makeVisible('answer_13_14')
makeVisible('answer_14_15')
makeInvisible('answer_12_13')
if((venv.get('x_13_14').value)){
makeVisible('answer_13_14')
makeInvisible('answer_14_15')
if(true ){
computation = 13
setComputedQuestion('answer_13_14',computation)
}
}else if(!(venv.get('x_13_14').value)){
makeVisible('answer_14_15')
makeInvisible('answer_13_14')
if(true ){
computation = 14
setComputedQuestion('answer_14_15',computation)
}
}
}
}
}else if(!(venv.get('x_10_15').value)){
makeVisible('answer_19_20')
makeVisible('x_15_17')
makeVisible('x_17_18')
makeVisible('x_18_19')
makeVisible('x_15_16')
makeVisible('answer_15_16')
makeVisible('answer_16_17')
makeVisible('answer_17_18')
makeVisible('answer_18_19')
makeInvisible('x_10_12')
makeInvisible('x_10_11')
makeInvisible('x_12_13')
makeInvisible('x_13_14')
makeInvisible('answer_10_11')
makeInvisible('answer_11_12')
makeInvisible('answer_12_13')
makeInvisible('answer_13_14')
makeInvisible('answer_14_15')
if((venv.get('x_15_17').value)){
makeVisible('x_15_16')
makeVisible('answer_15_16')
makeVisible('answer_16_17')
makeInvisible('answer_19_20')
makeInvisible('x_17_18')
makeInvisible('x_18_19')
makeInvisible('answer_17_18')
makeInvisible('answer_18_19')
if((venv.get('x_15_16').value)){
makeVisible('answer_15_16')
makeInvisible('answer_16_17')
if(true ){
computation = 15
setComputedQuestion('answer_15_16',computation)
}
}else if(!(venv.get('x_15_16').value)){
makeVisible('answer_16_17')
makeInvisible('answer_15_16')
if(true ){
computation = 16
setComputedQuestion('answer_16_17',computation)
}
}
}else if(!(venv.get('x_15_17').value)){
makeVisible('answer_19_20')
makeVisible('x_17_18')
makeVisible('x_18_19')
makeVisible('answer_17_18')
makeVisible('answer_18_19')
makeInvisible('x_15_16')
makeInvisible('answer_15_16')
makeInvisible('answer_16_17')
if((venv.get('x_17_18').value)){
makeVisible('answer_17_18')
makeInvisible('answer_19_20')
makeInvisible('x_18_19')
makeInvisible('answer_18_19')
if(true ){
computation = 17
setComputedQuestion('answer_17_18',computation)
}
}else if(!(venv.get('x_17_18').value)){
makeVisible('answer_19_20')
makeVisible('x_18_19')
makeVisible('answer_18_19')
makeInvisible('answer_17_18')
if((venv.get('x_18_19').value)){
makeVisible('answer_18_19')
makeInvisible('answer_19_20')
if(true ){
computation = 18
setComputedQuestion('answer_18_19',computation)
}
}else if(!(venv.get('x_18_19').value)){
makeVisible('answer_19_20')
makeInvisible('answer_18_19')
if(true ){
computation = 19
setComputedQuestion('answer_19_20',computation)
}
}
}
}
}
}

}
