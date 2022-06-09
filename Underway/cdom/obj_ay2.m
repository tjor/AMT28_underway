function out = obj_ay2(ay_obs, ay440, wv, pars) 
	
	out = sum(  abs( ay_obs - ay_fun2(ay440, wv, pars) )  );
	
endfunction