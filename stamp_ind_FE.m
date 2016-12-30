 function [ new_M, new_I, new_ind_row]= stamp_ind_FE(old_M, old_I, D, t_step, inductor_i)

%STAMP_IND_FE : stamps entries corresponding to a Inductor during Forward
%Euler Transient Analysis
%
%
%        syntax: [new_I, new_ind_current]= stamp_ind_FE( old_I, D, t_step, inductor_i)
%
%        
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the elem
%        'new_ind_current' is the  new inductor current at t+dt which will
%         be used in the next iteration
%         
%        


global L_N1_ L_N2_ L_ L_VALUE_ L_IC_ ;
new_M = old_M;
new_I= old_I;
n1= D(L_N1_);
n2= D(L_N2_);
length_M = length(old_M);
ind_value= D(L_VALUE_);
%ind_init_current = D(L_IC_);

if (n1>0), new_M(n1, length_M+1)= 1; new_M(length_M+1, n1)= 0; end;
if (n2>0), new_M(n2, length_M+1)= -1; new_M(length_M+1, n2)= 0; end;
if((n1>0) | (n2>0)), new_M(length_M+1, length_M+1)=1; end;
if (n1>0 & n2>0), volt_ind = (Node_vlt(n1)- Node_vlt(n2)); end;
if (n1>0 & n2<=0), volt_ind = Node_vlt(n1); end
if (n2>0 & n1<=0), volt_ind = - Node_vlt(n2); end

I_eq = inductor_i + ((t_step/ ind_value)*volt_ind);


if n1>length(new_I), new_I(n1)=0; end;
if n2>length(new_I), new_I(n2)=0; end;

new_I(length_M+1)= I_eq;

new_ind_row = length_M + 1;

