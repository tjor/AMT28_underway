function out = ay_fun2(ay440, wv, pars) 
	
	out = ay440.*exp(pars(:,1)*(440-wv)) + pars(:,2);#+pars(:,2)
	
endfunction