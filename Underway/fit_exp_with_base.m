function out=fit_exp_with_base(x,t,Y)


	y=exp_with_base(x,t);


	out=sum(abs(Y-y));
	
endfunction	
	
