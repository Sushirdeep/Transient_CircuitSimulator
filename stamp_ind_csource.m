function [new_I]= stamp_ind_csource(old_I, D)
%STAMP_IND_CSOURCE : stamps entries corresponding to an independent current
%source
%
%        syntax: [new_I]= stamp_ind_csource( old_I, D)
%
%
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the source
%        

global I_N1_ I_N2_ I_ I_TYPE_ I_VALUE_ DC_ AC_ PHASE_ PWL_ PWL_START_I_ I_POINTS_;
new_I= old_I;
n1= D(I_N1_);
n2= D(I_N2_);


if (D(I_TYPE_)== DC_)
    current_dc = D(I_VALUE_);
elseif (D(I_TYPE_)== AC_)
    current_mag_ac= D(I_VALUE_);
    current_phase = D(PHASE_);
elseif (D(I_TYPE_)== PWL_)
    current_dc= D(I_VALUE_);
    % Current at time t=0
    
end


if n1>length(new_I), new_I(n1)=0; end;
if n2>length(new_I), new_I(n2)=0; end;

if (n1>0)
    new_I(n1) = new_I(n1) - current_dc;
end

if (n2>0)
    new_I(n2) = new_I(n2) + current_dc;
end


