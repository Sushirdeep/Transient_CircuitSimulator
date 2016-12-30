function [new_M, new_I, new_Ids_row]= stamp_NMOSFET(old_M, old_I, D, Node_voltage_kth_iter)

%%STAMP_NMOSFET_DC : stamps entries corresponding to Linearized MOSFET model during Non-Linear DC Analysis
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


% Type of MOSFET is nMOS
    
Ng= D(M_NG_); % Ng is the Gate node of nMOS
Nd= D(M_ND_); % Nd is the Drain node of nMOS
Ns= D(M_NS_); % Ns is the Source node of nMOS
% The Higher Potential Node gets assigned as Drain

if((Ns > 0)& (Node_voltage_kth_iter(Ns) > Node_voltage_kth_iter(Nd))),  Dummy_var= Nd; Nd= Ns; Ns = Dummy_var; end;

Vth_nmos = D(M_VT_); % Threshold voltage of nMOS
Ln= D(M_L_); % Length of MOSFET
Wn= D(M_W_); % Width of MOSFET
lambda = D(M_LAMBDA_); % Lambda Parameter of the MOSFET
mu= D(M_MU_); % Mobility parameter of MOSFET   
Cox = D(M_COX_); % Gate Oxide Capacitance per unit Area of MOSFET
    
% Computing the Important Voltage differences
if (Ns >0)
   V_gs = Node_voltage_kth_iter(Ng) - Node_voltage_kth_iter(Ns);
   V_ds= Node_voltage_kth_iter(Nd) - Node_voltage_kth_iter(Ns);
    
elseif(Ns <0)
    V_gs = Node_voltage_kth_iter(Ng);
    V_ds= Node_voltage_kth_iter(Nd) ;
end

const_K = mu*Cox*(Wn/Ln);

% Id the Region of Operation and compute the values of gm, gds, ids_k and Ieq



if(V_gs <= Vth_nmos)
    % Cut off
    ids_k=0;
    gm= 0;
    gds= 0;
    
    
    
elseif ((V_gs > Vth_nmos) & (V_ds <= V_gs - Vth_nmos))
    % Linear Region
    ids_k = const_K * (((V_gs - Vth_nmos)*V_ds) - ((0.5)*(V_ds)*(V_ds)))* (1+(lambda*V_ds));
    gm = const_K * (1+(lambda*V_ds))* V_ds ;
    gds = const_K *( (V_gs - Vth_nmos - V_ds) + (2*lambda* (V_gs - Vth_nmos)*V_ds) - ((1.5)*lambda*V_ds*V_ds)) ;
    
    
elseif ((V_gs > Vth_nmos) & (V_ds > V_gs - Vth_nmos))
    % Saturation Region
    ids_k = 0.5 * const_K * (V_gs - Vth_nmos) * (V_gs - Vth_nmos)* (1+ (lambda* V_ds)) ;
    gm = const_K * (V_gs - Vth_nmos) * (1+ (lambda*V_ds));
    gds = 0.5 * const_K * lambda* (V_gs - Vth_nmos)* (V_gs - Vth_nmos);
    
end


% Stamping the NMOS into MNA matrix and J_vect

Ieq = ids_k - (gm*V_gs) - (gds*V_ds) ;

new_M(length_M+1, Ng)= gm ; new_M(length_M+1, Nd)= gds;
if (Ns > 0), new_M(length_M+1, Ns)= - gm - gds ; new_M(Ns, length_M+1)= -1; end;
new_M(Nd, length_M+1) = 1;
new_M(length_M+1, length_M+1)= -1 ;

new_Ids_row = length_M+1;
new_I(length_M+1)= -Ieq;



    


