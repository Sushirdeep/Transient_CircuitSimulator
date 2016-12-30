function [new_M, new_I, new_Ids_row]= stamp_PMOSFET(old_M, old_I, D, Node_voltage_kth_iter)

%%STAMP_PMOSFET : stamps entries corresponding to Linearized PMOSFET model during Non-Linear DC Analysis
%
%
%        syntax: [new_M, new_I, new_Ids]= stamp_MOSFET_dc(old_M,old_I, D, Node_voltage_kth_iter, old_Ids)
%
%        new_M, old_M are the new and old MNA matrices
%        new_I, old_I are the new and old I vectors  
%        D is the element being stamped
%        Node_voltage_kth_iter is the voltage after k-1 iterations or the
%        volatge values obtained from previous iteration
%        old_Ids is the current after k-1 iterations or the value of current
%        from previous iterations
%        


global M_TYPE_ M_ND_ M_NG_ M_NS_ M_W_ M_L_ M_LAMBDA_ M_VT_ M_MU_ M_COX_ M_CJ0_ M_ NMOS_ PMOS_ ;

new_M = old_M;
new_I = old_I;
length_M= size(old_M,1);
% Type of MOSFET is PMOS  
Pg= D(M_NG_); % Pg is the Gate node of pMOS
Pd= D(M_ND_); % Pd is the Drain node of pMOS
Ps= D(M_NS_); % Ps is the Source node of pMOS
% The Higher Potential Node gets assigned as Source
 
if( Node_voltage_kth_iter(Pd) > Node_voltage_kth_iter(Ps) ),  Dummy_var= Pd; Pd= Ps; Ps = Dummy_var; end;
Vth_pmos = D(M_VT_); % Threshold voltage of pMOS
Lp= D(M_L_); % Length of MOSFET
Wp= D(M_W_); % Width of MOSFET
lambda =  D(M_LAMBDA_); % Lambda Parameter of the MOSFET
mu= D(M_MU_); % Mobility parameter of MOSFET
Cox = D(M_COX_); % Gate Oxide Capacitance per unit Area of MOSFET


% Computing the Important Voltage differences
V_sg = Node_voltage_kth_iter(Ps) - Node_voltage_kth_iter(Pg);
V_sd= Node_voltage_kth_iter(Ps) - Node_voltage_kth_iter(Pd);

const_K = mu*Cox*(Wp/Lp) ;

% Identifying the Region of Operation of the PMOSFET
if (V_sg <= (-Vth_pmos))
    %Cut-off Region
    isd_k= 0;
    gm= 0;
    gsd= 0;
    
    
    
elseif((V_sg > (-Vth_pmos)) & (V_sd <= (V_sg - (-Vth_pmos))))
    %Linear Region of Operation
    isd_k= const_K * (((V_sg - (-Vth_pmos))*V_sd) - (0.5* V_sd * V_sd)) * (1+ (lambda*V_sd));
    gm= const_K * (1+ (lambda*V_sd)) * V_sd ;
    gsd= const_K * ((V_sg - (-Vth_pmos) - V_sd) + (2*lambda*V_sd*(V_sg - (-Vth_pmos))) - (1.5*lambda*V_sd*V_sd)) ;
    
    
elseif((V_sg > (-Vth_pmos)) & (V_sd > (V_sg - (-Vth_pmos))))
    %Saturation Region of Operation
    isd_k= 0.5* const_K * (V_sg - (-Vth_pmos)) * (V_sg - (-Vth_pmos))* (1+ (lambda*V_sd));
    gm= const_K * (V_sg - (-Vth_pmos)) * (1+(lambda*V_sd)) ;
    gsd= 0.5* lambda* const_K * (V_sg - (-Vth_pmos))* (V_sg - (-Vth_pmos));
    
end

% End of Regions of Operations check
% Stamping the PMOS into MNA matrix and J_vect


% Identifying the Region of Operation of the MOSFET
new_M(length_M+1, Pg)= -gm ; new_M(length_M+1, Pd)= -gsd; new_M(length_M+1, Ps)= gm+gsd ; new_M(length_M+1, length_M+1)= - 1;
new_M(Ps, length_M+1)= 1; new_M(Pd, length_M+1)= -1;
Ieq = isd_k - (gm*V_sg) - (gsd*V_sd) ;


new_Ids_row= length_M+1;
new_I(length_M+1)= - Ieq;
