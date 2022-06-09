function out = ay_fun(ay440, wv, ay_slope) 
	
	out = ay440.*exp(ay_slope.*(440-wv)) ;
	
endfunction