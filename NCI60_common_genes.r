#Function for finding common overexpressed & underexpressed genes for different types of genes
#Arguments are the type of genes and False Discovery Rate(as percentage) 
main_function=function(type=c("overexpressed","underexpressed"),fdr_rate){
	#importing ISLR library
	library(ISLR)
	#Finding unique cancer types
	cancer.labels=unique(NCI60$labs)
	#Finding no. cancer types
	n=length(cancer.labels)
	
	#Function for ttest
	mytfunc<-function(x){

	#Finding mean of the input
	xbar<-mean(x)

	#Finding standard deviation of the input
	sd0<-sd(x)

	#Finding length of the input
	n<-length(x)

	#Finding the t statistic using the formula mean*(sqrt(length of data)/(standard deviation)
	tstat<-xbar/(sd0/sqrt(n))

	#Finding the p-value using pt function of student t distribution
	p0<-pt(tstat,n-1)

	#if ((is.na(p0))|(!is.finite(p0))){ 
	#	p0<-pt(tstat, n-1, lower.tail = FALSE)
	#	if ((is.na(p0))|(!is.finite(p0))){
	#		p0=2 * pt(-abs(tstat), n-1)
	#	}
	#}

	#Returning the p-value & 1-pvalue for overexpressed and underexpressed genes.
	c(p0,1-p0)
	}
	
	fdr<-function(v1,Q){
        #Finding the order of input given
		o1<-order(v1)
		
		#Getting the p-values according to the order of the input
        pvec<-v1[o1]
		
		#Finding the length of the input
        m<-length(v1)
		
		#Getting q-values so that we compare them to p-values(generated by the ttest function) & get significant values from the data
        qline<-Q*c(1:m)/m
		
		#Generating Plot
        plot(c(c(1:m),c(1:m)),c(qline,pvec),type="n",xlab="ordering",ylab="pvalue")
        
		#Plot the q-values(you can see that they are linear and the maximum value attained by them is Q(FDR given by the user))
		lines(c(1:m),qline)
        
		#Plotting the p-values of the input
		points(c(1:m),pvec)
        
		#Finding the difference between p-values and q-values
		dv<-pvec-qline
        
		#Finding the values of input for which the above calculated difference is negative
		I1<-(dv<0)
		
        #Finding the maximum p-value for which the above calculated difference is negative(Also discarding missing p-values)
		pmax<-max(pvec[I1],na.rm=T)
		
		#Finding the input values for which the FALSE DISCOVERY RATE will be Q(given by user) according to BENJAMINI-HOTCHBERG FORMULA
        I2<-pvec<=pmax
		
		#Coloring the sequence red for which the FDR is Q
        points(c(1:m)[I2],pvec[I2],col="red")
		
		#Getting the significant input values in order according to the above method
        o1[I2]

	}
	
	#Creating an common genes variable
	answer<-c()
	
	#Creating a loop to find overexpressed or underexpressed genes of a particular cancer type
	for (x in 1:n){
		type <- match.arg(type)
		
		#Getting a based on argument type
		if(type=="overexpressed"){
			a=2
		}
		else{
			a=1
		}
		i=fdr_rate/100
		
		print('x')
		print(x)
		#Getting data for a particular cancer type
		data=NCI60$data[NCI60$labs==cancer.labels[x],]
		
		
		y=as.numeric(sum(NCI60$labs==cancer.labels[x]))
		z=1:y
		n1=length(z)
		
		#Code Block for checking
		#total=total+n1
		
		#For saving all the plots that are generated by the FDR function
		graphics.off()
		name=paste("rplot",cancer.labels[x],"-",type,"-p","-q",fdr_rate,".jpg",sep = "")
		
		#For discarding cancer types with only 1 row of data
		if (n1==1){
			data=t(data)
				print("Only 1 row of data")
		}
		
		#Saving the plots and genes generated by the FDR Function
		else{
			jpeg(name)
				#getting answer as per type(p or (1-p))
				#removing NA values
				answer[[cancer.labels[x]]]=na.omit(try(fdr(apply(data,2,mytfunc)[a,],i)))
				dev.off()
		}
	}
	
	#Only created function to compare 2 cancer types as there were no common genes between 3 cancer types 
	#Creating a function to find common genes between two different cancer types
	common_genes=function(x,y){
		 
		 Reduce(intersect, list(answer[[x]],answer[[y]]))
	 }
	 
	#Loop for generating common genes between all pairs of cancer types
	for(x in 1:14){
		 first=cancer.labels[x]
		 for (y in 1:14){
			 second=cancer.labels[y]
			 name=paste("Common genes for ",first," and ",second)
			 print(name)
			 if(first!=second){
				print(try(common_genes(first,second)))
			 }
		 }
		 
	 }
}