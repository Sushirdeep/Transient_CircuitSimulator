 function [ new_M, new_I, Ndv_rows_added ]= stamp_cap_MOS(old_M, old_I, D, t_step, Node_vlt)

%STAMP_CAP_MOS_BE : stamps entries corresponding to a Capacitor during Backward
%Euler Transient Analysis
%
%
%        syntax: [new_M, new_I, new_row]= stamp_cap_MOS_BE(old_M, old_I, D, t_step, Node_vlt)
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the source
%        'new_row' is the row number corresponding to the new source
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later
% 


global M_TYPE_ M_ND_ M_NG_ M_NS_ M_W_ M_L_ M_LAMBDA_ M_VT_ M_MU_ M_COX_ M_CJ0_ M_ NMOS_ PMOS_ ;
new_M = old_M;
new_I = old_I;
length_M= size(old_M,1);
Ndv_rows_added =0;

Drain = D(M_ND_) ;
Gate = D(M_NG_);
Source = D(M_NS_);
Wdth= D(M_W_);
Lngth = D(M_L_);
lambda = D(M_LAMBDA_);
Vth = D(M_VT_);
mu = D(M_MU_);
Cox = D(M_COX_);
Cjo = D(M_CJ0_);


% Assuming the MOSFET Parasitics Capacitances are linear
% Getting the Value of Cgs
Cgs= (0.5)*Cox*Wdth*Lngth ;
Cgd= (0.5)*Cox*Wdth*Lngth ;
Cd_gnd = Cjo;

row_added =0 ;

% Stamping Cgs
if (Gate > 0)
    length_M =length_M+1 ; row_added =1 ;
    new_M(length_M, Gate) = Cgs/t_step ; 
    new_M( Gate, length_M)= 1;
end;

if (Source>0) 
    if (row_added == 1)
        new_M(length_M, Source) = -Cgs/t_step ;
        new_M(Source, length_M)= -1; 
    else
        length_M = length_M+1;
        new_M(length_M, Source) = -Cgs/t_step ;
        new_M(Source, length_M)= -1; 
    end
end;

if ((Gate > 0) | (Source > 0)), new_M(length_M, length_M) = -1; Ndv_rows_added =Ndv_rows_added+1 ; end;
if ((Gate > 0) & (Source > 0)), volt_cap_diff = (Node_vlt(Gate)- Node_vlt(Source)); end;
if ((Gate > 0) & (Source <= 0)), volt_cap_diff = (Node_vlt(Gate)); end
if ((Source >0) & (Gate<=0)), volt_cap_diff = -(Node_vlt(Source)); end
new_I(length_M)= (Cgs/t_step)* volt_cap_diff ;
new_row(1) = length_M;


% Stamping Cgd 
    
row_added =0 ;
if (Gate > 0)
    length_M =length_M+1 ; row_added =1 ;
    new_M(length_M, Gate) = Cgd/t_step ; 
    new_M( Gate, length_M)= 1;
end;

if (Drain>0) 
    if (row_added == 1)
        new_M(length_M, Drain) = -Cgd/t_step ;
        new_M(Drain, length_M)= -1; 
    else
        length_M = length_M+1;
        new_M(length_M, Drain) = -Cgd/t_step ;
        new_M(Source, length_M)= -1; 
    end
end;

if ((Gate > 0) | (Drain > 0)), new_M(length_M, length_M) = -1; Ndv_rows_added= Ndv_rows_added+1; end;
if ((Gate > 0) & (Drain > 0)), volt_cap_diff = (Node_vlt(Gate)- Node_vlt(Drain)); end;
if ((Gate > 0) & (Drain <= 0)), volt_cap_diff = (Node_vlt(Gate)); end
if ((Drain >0) & (Gate<=0)), volt_cap_diff = -(Node_vlt(Drain)); end
new_I(length_M)= (Cgd/t_step)* volt_cap_diff ;
new_row(2) = length_M;

% Stamping Cd_gnd

if (Drain > 0)
    length_M =length_M+1 ; 
    new_M(length_M, Drain) = Cd_gnd/t_step ; 
    new_M( Drain, length_M)= 1;
    new_M(length_M, length_M) = -1;
    volt_cap_diff = (Node_vlt(Drain));
    new_I(length_M)= (Cd_gnd/t_step)* volt_cap_diff ;
    new_row(3) = length_M;
    Ndv_rows_added= Ndv_rows_added+1;
end


% Cs_gnd exists if the source is not connected to the ground
if (Source >0)
    Cs_gnd =Cjo; 
    % Stamping Cs_gnd
    length_M =length_M+1 ; 
    new_M(length_M, Source) = Cs_gnd/t_step ; 
    new_M( Source, length_M)= 1;
    new_M(length_M, length_M) = -1; 
    volt_cap_diff = (Node_vlt(Source)); 
    new_I(length_M)= (Cs_gnd/t_step)* volt_cap_diff ;
    new_row(4) = length_M;
    Ndv_rows_added= Ndv_rows_added+ 1;
end