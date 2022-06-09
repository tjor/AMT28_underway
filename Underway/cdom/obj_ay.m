function out = obj_ay(ay_obs, ay440, wv, ay_slope) 
	
	out = sum(abs(ay_obs - ay_fun(ay440, wv, ay_slope) ));
	
endfunction