%cost function to retrieve DT
function out = f_Ts(DTs)

global a b i_refNIR i_NIR 
global Yt Ysa


i_ref = find(i_NIR == i_refNIR);

# DTs is \DeltaT
out = sum(abs(     a - Yt*DTs(1) - ( a(i_ref) - Yt(i_ref)*DTs(1) )*b./b(i_ref)     )); # eq 6 in Slade et al., 2010;   %w/o salinity













