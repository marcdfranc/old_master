doCalc = function (flag) {
	Rels = new Array(1,.1,2.54,.423333333333,.0352777777778,.001763888888889,.026458333333333333);
	for (i=0;i<Rels.length;i++)	{
		if (i==flag) {
			givenValue=document.getElementById(flag).value.replace(",",".");
			newVal=eval(givenValue*Rels[i])
			document.getElementById("0").value=newVal;
		}
	 }
	 for (i=1;i<Rels.length;i++) {
		newVal=eval(document.getElementById("0").value/Rels[i]);
		neg=0;
		if (newVal < 0) {
			newVal*=-1;
		  	neg=1;
		}
		j=0;
		while (newVal<1 && newVal>0) {
			j++;
			newVal*=10;
		}
		newVal*=100000;
		newVal=Math.round(newVal);
		newVal/=100000;
		newVal/=Math.pow(10,j);
		newVal="a"+newVal;
		cache=0;
		if (newVal.indexOf("e") != -1) {
			cache=newVal.substr(newVal.indexOf("e"),5);
			newVal=newVal.substring(0,newVal.indexOf("e"));
		}
		dig=new Array;
		for (j=1;j<5;j++){
			dig[j]=newVal.substr(newVal.length-j-1,1);
		}
		if ((eval(newVal.substring(1,newVal.length))!= 
				Math.round(eval(newVal.substring(1,newVal.length))))
				&& (dig[1] == 9) && (dig[2] == 9) && (dig[3] == 9) && (dig[4] == 9)) {
			rest=newVal.substring(newVal.indexOf("."),100).length-1;
			newVal=newVal.substring(1,newVal.length-1);
			newVal="a"+eval(eval(newVal)+Math.pow(10,-rest+2));
		}
		for (j=1;j<5;j++){
			dig[j]=newVal.substr(newVal.length-j-1,1);
		}
	  	if (dig[1] == 0 && dig[2] == 0 && dig[3] == 0 && dig[4] == 0) {
			check=0;
			for (j=0;j<newVal.length-5;j++) {
				if (newVal.substr(j,1)!=0){
					check++;
				}
			}
			if (check>2 && eval(newVal.substring(1,newVal.length)) != 
					Math.round(eval(newVal.substring(1,newVal.length)))) {
				newVal=newVal.substring(0,newVal.length-1);						
			}
		}
		if (cache){
			newVal=newVal+cache;				
		}
		newVal=newVal.substring(1,newVal.length);
		if (neg) {
		  newVal*=-1;				
		}
		document.getElementById(i).value=eval(newVal);
	}
}
	