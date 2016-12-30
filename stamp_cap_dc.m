function [ new_M, new_I, new_row]= stamp_cap_dc(old_M, old_I, D)
%STAMP_CAP_DC : stamps entries corresponding to a Capacitor during DC
%analysis
%
%
%        syntax: [new_M, new_I, new_row]= stamp_cap_dc(old_M, old_I, D)
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the source
%        'new_row' is the row number corresponding to the new source
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later
%        

global C_N1_ C_N2_ C_ C_VALUE_ C_IC_;
new_I= old_I;
n1= D(C_N1_);
n2= D(C_N2_);
new_M= old_M;

length_M= length(old_M);
new_row= length_M;
cap_value= D(C_VALUE_);
cap_init_voltage = D(C_IC_);


if isnan(cap_init_voltage) 
    % If Initial Voltage stored in Capacitor is 0, Open Circuit is
    % Considered, I=0
    if n1>length(new_I), new_I(n1)=0; end;
    if n2>length(new_I), new_I(n2)=0; end;
    
    if (n1>0) & (n2>0)
        new_I(n1) = new_I(n1) - 0;
        new_I(n2) = new_I(n2) + 0;
    elseif (n1<0)
        new_I(n2) = new_I(n2) + 0;
    elseif (n2<0)
        new_I(n1) = new_I(n1) + 0;
    end
else
    % If initial Volatge stored in Capacitor is Non-Zero, the 
    %Voltage difference between the nodes is decided by the initial charge stored , V= V_initial 
    if n1>length_M, new_M(n1,n1)=0; end;
    if n2>length_M, new_M(n2,n2)=0; end;

    if n1>0, new_M(length_M+1, n1) = 1; new_M(n1, length_M+1)= 1; end;
    if n2>0, new_M(length_M+1, n2) = -1; new_M(n2, length_M+1)= -1; end;
    new_I(length_M+1)= cap_init_voltage;
    new_row = length_M+1;
    
end

