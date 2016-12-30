function [new_M, new_I, new_row]= stamp_controlled_vccs(old_M, old_I, D)
%STAMP_CONTROLLED_VCVS : stamps entries corresponding to a Voltage
%Controlled Current Source
%
%
%        syntax: [new_M,new_I,new_row]= stamp_controlled_vccs(old_M, old_I, D)
%
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the source
%        'new_row' is the row number corresponding to the new source
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later

global G_N1_ G_N2_ G_CN1_ G_CN2_ G_ G_VALUE_;
new_M= old_M;
new_I= old_I;
length_M= length(old_M);
n1= D(G_N1_);
n2= D(G_N2_);
cn1= D(G_CN1_);
cn2= D(G_CN2_);
value = D(G_VALUE_);

if n1>length_M, new_M(n1,n1)=0; end;
if n2>length_M, new_M(n2,n2)=0; end;
if cn1>length_M, new_M(cn1, cn1)=0; end;
if cn2>length_M, new_M(cn2, cn2)=0; end;

if (n1>0) & (n2>0) & (cn1>0) & (cn2>0)

    new_M(n1,cn1)= new_M(n1,cn1) + value;
    new_M(n1,cn2)= new_M(n1,cn2) - value;
    new_M(n2,cn1)= new_M(n2,cn1) - value;
    new_M(n2,cn2)= new_M(n2,cn2) + value;


end
