 function [ new_M, new_I, new_row]= stamp_cap_TR(old_M, old_I, D, t_step, Node_vlt, i_cap)

%STAMP_CAP_TR : stamps entries corresponding to a Capacitor during Trapeziodal Transient Analysis
%
%
%        syntax: [new_M, new_I, new_row]= stamp_cap_BE(old_M, old_I, D, t_step, Node_vlt, i_cap)
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the element
%        'new_row' is the row number corresponding to the new element
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later
%        

global C_N1_ C_N2_ C_ C_VALUE_ C_IC_ ;
new_I= old_I;
n1= D(C_N1_);
n2= D(C_N2_);
new_M= old_M;

length_M= length(old_M);
cap_value= D(C_VALUE_);
%cap_init_voltage = D(C_IC_);

if n1>0, new_M(length_M+1, n1) = (2*cap_value)/t_step ; new_M(n1, length_M+1)= 1; end;
if n2>0, new_M(length_M+1, n2) = -(2*cap_value)/t_step ; new_M(n2, length_M+1)= -1; end;
if ((n1>0) | (n2>0)), new_M(length_M+1, length_M+1) = -1; end;
if (n1>0 & n2>0), volt_cap_diff = (Node_vlt(n1)- Node_vlt(n2)); end;
if (n1>0 & n2<=0), volt_cap_diff = Node_vlt(n1); end;
if (n2>0 & n1<=0), volt_cap_diff = - Node_vlt(n2); end;

new_I(length_M+1)= (((2*cap_value)/t_step)* volt_cap_diff) + i_cap ;
new_row = length_M+1;


