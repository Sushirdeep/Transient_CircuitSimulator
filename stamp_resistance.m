function [new_M]= stamp_resistance(old_M, D)
% STAMP_RESISTANCE: Stamps resistance into MNA matrix
%    syntax: [new_M]= stamp_resistance(old_M, D)
%    new_M, old_M are the new and old MNA matricies
%    D is the data vector corresponding to the resistance


global R_N1_ R_N2_ R_ R_VALUE_;
new_M = old_M;
n1 = D(R_N1_);
n2 = D(R_N2_);

if n1>length(new_M), new_M(n1,n1)=0; end;
if n2>length(new_M), new_M(n2,n2)=0; end;

value= D(R_VALUE_);

if(n1>0) & (n2>0)
    new_M(n1,n1)= new_M(n1,n1) + (1/value) ;
    new_M(n1,n2)= new_M(n1,n2) - (1/value) ;
    new_M(n2,n1)= new_M(n2,n1) - (1/value) ;
    new_M(n2,n2)= new_M(n2,n2) + (1/value) ;
elseif (n1<0)
    new_M(n2,n2)= new_M(n2,n2) + (1/value) ;
elseif (n2<0)
    new_M(n1,n1)= new_M(n1,n1) + (1/value) ;
end
