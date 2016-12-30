 function [ new_M, new_I, new_row]= stamp_ind_BE(old_M, old_I, D, t_step, ind_current)

%STAMP_IND_BE : stamps entries corresponding to a Inductor during Backward
%Euler Transient Analysis
%
%
%        syntax: [new_M, new_I, new_row]= stamp_ind_BE(old_M, old_I, D, t_step, ind_current)
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the elem
%        'new_row' is the row number corresponding to the new element
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later
%        

global L_N1_ L_N2_ L_ L_VALUE_ L_IC_ ;
new_I= old_I;
n1= D(L_N1_);
n2= D(L_N2_);
new_M= old_M;

length_M= length(old_M);
ind_value= D(L_VALUE_);
%ind_init_current = D(L_IC_);

if n1>0, new_M(length_M+1, n1) = 1 ; new_M(n1, length_M+1)= 1; end;
if n2>0, new_M(length_M+1, n2) = -1 ; new_M(n2, length_M+1)= -1; end;
if ((n1>0) | (n2>0)), new_M(length_M+1, length_M+1) = - (ind_value/t_step); end;

new_I(length_M+1)= -(ind_value/t_step)* ind_current ;
new_row = length_M+1;


