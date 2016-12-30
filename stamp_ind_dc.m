function [ new_M, new_I, new_row]= stamp_ind_dc(old_M, old_I, D)
%STAMP_IND_DC : stamps entries corresponding to a Inductor during DC
%analysis
%
%
%        syntax: [new_M, new_I, new_row]= stamp_ind_dc(old_M, old_I, D)
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the elem
%        'new_row' is the row number corresponding to the new source
%         This number has to be returned to the main function so that the
%         row corresponding to this elem can be accessed later
%         new row gives the value of the current in the inductor after DC
%        

global L_N1_ L_N2_ L_ L_VALUE_ L_IC_;
new_I= old_I;
n1= D(L_N1_);
n2= D(L_N2_);
new_M = old_M;

length_M= length(old_M);
new_row = length_M;
ind_value= D(L_VALUE_);
ind_init_current = D(L_IC_);


if isnan(ind_init_current) 
    % If Initial Current in Inductor is 0, Short Circuit is
    % Considered, V=0;
    if n1>length_M, new_M(n1,n1)=0; end;
    if n2>length_M, new_M(n2,n2)=0; end;

    if n1>0, new_M(length_M+1, n1) = 1; new_M(n1, length_M+1)= 1; end;
    if n2>0, new_M(length_M+1, n2) = -1; new_M(n2, length_M+1)= -1; end;
    new_I(length_M+1)= 0;
    new_row = length_M+1;

else
    % If initial current in Inductor is Non-Zero, the 
    %current between the nodes gets added with the existing current  
    if n1>length_M, new_M(n1,n1)=0; end;
    if n2>length_M, new_M(n2,n2)=0; end;

    if n1>0, new_M(length_M+1, n1) = 1; new_M(n1, length_M+1)= 1; end;
    if n2>0, new_M(length_M+1, n2) = -1; new_M(n2, length_M+1)= -1; end;
    new_I(length_M+1)= 0;
    new_row = length_M+1;
    
end

