%cost function to retrieve DT
function out=f_Ts(DTs)
global a b refNIR NIR 
global Yt Ysa


ref=find(NIR==refNIR);


 out=sum(abs(     a-Yt*DTs(1) - ( a(ref)-Yt(ref)*DTs(1) )*b./b(ref)     ));   %w/o salinity













