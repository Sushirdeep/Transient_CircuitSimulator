function [new_I]= stamp_ind_csource_tran(old_I, D, time)
%STAMP_IND_CSOURCE_TRAN : stamps entries corresponding to an independent
%current source
%
%        syntax: [new_I]= stamp_ind_vsource( old_I, D, time)
%
%
%        
%        new_I, old_I are the new and old current matrices
%        D is the data vector corresponding to the source
%        'new_row' is the row number corresponding to the new source
%         This number has to be returned to the main function so that the
%         row corresponding to this voltage source can be accessed later

global I_N1_ I_N2_ I_ I_TYPE_ I_VALUE_ DC_ AC_ PHASE_ PWL_ PWL_START_V_ I_POINTS_;
% new_M= old_M;
new_I= old_I;
%length_M= length(old_M);
n1= D(I_N1_);
n2= D(I_N2_);

if (D(I_TYPE_)== DC_)
    current_t = D(I_VALUE_);
    if n1>length(new_I), new_I(n1)=0; end;
    if n2>length(new_I), new_I(n2)=0; end;

    if (n1>0), new_I(n1) =  - current_t; end;
    if (n2>0), new_I(n2) =  + current_t; end
    
    
    
    
elseif (D(I_TYPE_)== AC_)
    current_mag_ac= D(I_VALUE_);
    current_phase = D(PHASE_);
elseif (D(I_TYPE_)== PWL_)
    no_points= D(I_POINTS_);
    i_dc= D(I_VALUE_);
    for j=1: no_points
       time_pts(j)= D(I_POINTS_+ ((2*j)-1));
       current_val(j)= D(I_POINTS_ + (2*j));    
        
    end
    % Obtaining the Current Value at time = t
    if (time==0)
        current_t= D(I_VALUE_);
        % Voltage at time t=0
    elseif (time >0 & time <= time_pts(1)) 
        slope= (current_val(1) - i_dc)/(time_pts(1)-0);
        current_t= i_dc + slope * time; 
        
    else
        
        for j=1 : (no_points -1)
            if (time > time_pts(j) & time <= time_pts(j+1))
                slope = (current_val(j+1) - current_val(j))/ (time_pts(j+1) - time_pts(j));
                current_t= current_val(j) + slope * (time - time_pts(j));
                
            elseif (time > time_pts(no_points))
                current_t = current_val(no_points);
            end
        end
        
    end
    
    if n1>length(new_I), new_I(n1)=0; end;
    if n2>length(new_I), new_I(n2)=0; end;

    if (n1>0), new_I(n1) = new_I(n1) - current_t; end;
    if (n2>0), new_I(n2) = new_I(n2) + current_t; end ;
    
end


end

