function [new_M, new_I, new_row]= stamp_ind_vsource_tran(old_M, old_I, D, time)
%STAMP_IND_VSOURCE_TRAN : stamps entries corresponding to an independent voltage
%source for Transient Anaylsis
%
%        syntax: [new_M,new_I,new_row]= stamp_ind_vsource(old_M, old_I, D, time)
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
    voltage_t = D(V_VALUE_);
elseif (D(V_TYPE_)== AC_)
    voltage_mag_ac= D(V_VALUE_);
    volatge_phase = D(PHASE_);
elseif (D(V_TYPE_)== PWL_)
    no_points= D(V_POINTS_);
    v_dc= D(V_VALUE_);
    for j=1: no_points
       time_pts(j)= D(V_POINTS_+ ((2*j)-1));
       volt_val(j)= D(V_POINTS_ + (2*j));    
        
    end
    % Obtaining the Voltage Value at time = t
    if (time==0)
        voltage_t= D(V_VALUE_);
        % Voltage at time t=0
    elseif (time >0 & time <= time_pts(1)) 
        slope= (volt_val(1) - v_dc)/(time_pts(1)-0);
        voltage_t= v_dc + slope * time; 
        
    
    elseif (time > time_pts(no_points))
         voltage_t = volt_val(no_points);
            
    else
        
        for j= 1:no_points
            if (time > time_pts(j) & time <= time_pts(j+1))
                slope = (volt_val(j+1) - volt_val(j))/ (time_pts(j+1) - time_pts(j));
                voltage_t= volt_val(j) + slope * (time - time_pts(j));
                            
            end
        
        end
    
    end
    
end

if n1>length_M, new_M(n1,n1)=0; end;
if n2>length_M, new_M(n2,n2)=0; end;

if n1>0, new_M(length_M+1, n1) = 1; new_M(n1, length_M+1)= 1; end;
if n2>0, new_M(length_M+1, n2) = -1; new_M(n2, length_M+1)= -1; end;
new_I(length_M+1)= voltage_t;
new_row = length_M+1;
