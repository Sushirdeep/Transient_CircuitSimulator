function [new_M, new_I, new_row]= stamp_ind_vsource(old_M, old_I, D)
%STAMP_IND_VSOURCE : stamps entries corresponding to an independent voltage
%source
%
%        syntax: [new_M,new_I,new_row]= stamp_ind_vsource(old_M, old_I, D)
%
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the source
%        'new_row' is the row number corresponding to the new source
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later

global V_N1_ V_N2_ V_ V_TYPE_ V_VALUE_ DC_ AC_ PHASE_ PWL_ PWL_START_V_ V_POINTS_;
new_M= old_M;
new_I= old_I;
length_M= length(old_M);
n1= D(V_N1_);
n2= D(V_N2_);

if (D(V_TYPE_)== DC_)
    voltage_dc = D(V_VALUE_);
elseif (D(V_TYPE_)== AC_)
    voltage_mag_ac= D(V_VALUE_);
    volatge_phase = D(PHASE_);
elseif (D(V_TYPE_)== PWL_)
    voltage_dc= D(V_VALUE_);
    % Voltage at time t=0
    
end

if n1>length_M, new_M(n1,n1)=0; end;
if n2>length_M, new_M(n2,n2)=0; end;

if n1>0, new_M(length_M+1, n1) = 1; new_M(n1, length_M+1)= 1; end;
if n2>0, new_M(length_M+1, n2) = -1; new_M(n2, length_M+1)= -1; end;
new_I(length_M+1)= voltage_dc;
new_row = length_M+1;
