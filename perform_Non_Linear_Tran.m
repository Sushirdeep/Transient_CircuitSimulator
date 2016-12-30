function [ Node_voltage_time, MOSFET_i, t_vect] = perform_Non_Linear_Tran(LINELEM, NLNELEM, INFO, NODES)
 % Performing Non Linear Transient Anaylsis
% Important Matricies to keep in mind LINELEM, NLNELEM, INFO, NODES,
% PRINTNV, PRINTBV, PRINTBI, PLOTNV, PLOTBV, PLOTBI

addpath('parser_scripts');
parser_init ;
No_nodes= length(NODES);
MNA_matrix = zeros(No_nodes, No_nodes);
J_vect= zeros(No_nodes,1);
delta_t = INFO(TSTEP_);
stop_t = INFO(TSTOP_);
t_vect= 0: delta_t: stop_t;
time_points = length(t_vect);
c_1=1 ; c_2=1; c_3=1; 
counter_C=1; v_counter =1; counter_L=1;
cap_count=0;
ind_present =0;
cap_present=0;
vsource_p= 0;

% Stamping the Static Elements that do not change with time
for row_no=1:size(LINELEM,1)
          elem = LINELEM(row_no,:);
          
          if(elem(TYPE_)== R_)
              % Resistor Element
              MNA_matrix = stamp_resistance(MNA_matrix, elem);
              
          elseif(elem(TYPE_)== Y_)
              % Conductance element
              MNA_matrix = stamp_conductance(MNA_matrix, elem);
          end
end

MNA_Matrix_R = MNA_matrix ;

t=0;
iter =1;
% DC Analysis
% Performing Non Linear DC Analysis when time t=0
% Stamping the Linear Elements into the Y matrix

for row_no=1:size(LINELEM,1)
   elem = LINELEM(row_no,:);
   % Resistances and Conductances are already stamped
             
    if(elem(TYPE_)== C_)
        %Stamping Capacitor Element in DC Analysis
        cap_present =1;
        [ MNA_matrix, J_vect, Current_i_dc_cap(c_1,1)]= stamp_cap_dc(MNA_matrix, J_vect, elem);
        c_1=c_1+1;
        cap_count= cap_count+1;
             
    elseif(elem(TYPE_)== L_)
        % Stamping Inductor Element in DC Analysis
         ind_present =1;
         [ MNA_matrix, J_vect, Current_i_dc_ind(c_2,1)]= stamp_ind_dc(MNA_matrix, J_vect, elem) ;
         c_2=c_2+1;
          
          
    elseif(elem(TYPE_)== V_)
        % Stamping Independent Voltage Source in DC Analysis
        [MNA_matrix, J_vect, VSource_i(c_3,1)]= stamp_ind_vsource(MNA_matrix, J_vect, elem);
        c_3= c_3+1;
              
              
    elseif(elem(TYPE_)== I_)
        % Stamping Independent Current Source in DC Analysis
        [J_vect]= stamp_ind_csource(J_vect, elem);
                             
     % End of  If TYPE of elements statements    
    end
          
  % End of  LINELEM array traverse    
end

MNA_Linear_DC = MNA_matrix; 
J_vect_Linear_DC = J_vect;

% Performing Non-Linear DC Analysis using  gmin stepping
% Stamping Gmin elements in Non-Linear DC Anaylsis
% Gmin is stamped to all nodes except ground node
%Initialising Gmin
 Gmin =1 ;
 G_initial_loop =1;   
 limit_convergence = 1000;
 
 % Gmin Loop
 while (Gmin > ((10)^(-10))) 
       v_vect= length(J_vect) + size(NLNELEM,1); 
       icount = 1;
       converged = 0 ; 
       convergence_fail = 0;
       while ((~ converged) & (~convergence_fail))
            if (icount> limit_convergence)
                convergence_fail=1;
                break ;
            end
            MNA_matrix= MNA_Linear_DC ;
            J_vect = J_vect_Linear_DC;
            [MNA_matrix]= stamp_Gmin(MNA_matrix, Gmin, NODES);
            % Update the Linear Problem
            % Stamp the Linearised model for the MOSFET
            Mos_count =0 ; nmos_count= 0; pmos_count= 0;
            % Stamping the Non-Linear Elements into the Y matrix
            for row_no=1:size(NLNELEM,1) 
                elem = NLNELEM(row_no,:);
                %MOSFETS
                Mos_count= Mos_count +1 ; 
                %Stamp the  linearised model of the MOSFET 
                if ((icount== 1) & (G_initial_loop ==1)) 
                    Node_voltage_k(:,1)=zeros(v_vect,1) ; 
                    
                elseif((icount == 1) & (G_initial_loop ==0)) 
                    Node_voltage_k(:,1)= NodeVolt_final(:,1) ;  
                                          
                end
            if(((elem(TYPE_)== M_) & (elem(M_TYPE_)== NMOS_)))
              [MNA_matrix, J_vect, V_row(Mos_count,1)]= stamp_NMOSFET(MNA_matrix, J_vect, elem, Node_voltage_k(:,1));
                                  
            elseif(((elem(TYPE_)== M_) & (elem(M_TYPE_)== PMOS_)))
              [MNA_matrix, J_vect, V_row(Mos_count,1)]= stamp_PMOSFET(MNA_matrix, J_vect, elem, Node_voltage_k(:,1));
          
             % End of if TYPE == MOSFET  
            end
   
            % End of NLNELEM Array Traverse
            end
            
             % Solving the Linearised Circuit
             icount = icount+1 ;
             % Equations Jacobian * delta_v =  I_vect is solved
             Node_voltage_soln(:,1) = MNA_matrix\ J_vect ;    
             diff_vect = Node_voltage_soln(:,1)- Node_voltage_k(:,1);
             if (norm(diff_vect,2)< (10^(-8))), converged_iter =icount ; converged =1 ; end;
             Node_voltage_k(:, 1)= Node_voltage_soln(:,1);
             
       % End of NR Convergence Loop
       end
        G_initial_loop = 0;
        % Reduce Gmin
         Gmin= Gmin/5 ;
         if(converged == 1)
         NodeVolt_final = Node_voltage_k(:,1);
         end
       
 % End of Gmin While Loop      
 end
 
 
 
 % Non Linear DC Solution is the Converged Value when
 % Gmin < 10^(-10)
 Node_voltage_time(:,iter)= NodeVolt_final(1:No_nodes,1);
 if (~isempty(NLNELEM)), mos_current_dc = NodeVolt_final(V_row(:,1)) ;  MOSFET_i(:,1)= mos_current_dc; end;
 if (cap_present > 0),capacitor_current = NodeVolt_final(Current_i_dc_cap(:,1)); end ;
 if (ind_present > 0), ind_current_dc = NodeVolt_final(Current_i_dc_ind(:,1)); end ;
 if (vsource_p> 0), current_vsource = NodeVolt_final(VSource_i(:,1)); end ;
           
 %End of Non-Linear DC Anaylsis

 % Start of Non Linear Transient Anaylsis
 
 while(t <= stop_t)
     t = t + delta_t ;
     iter = iter + 1;
     % Transient Time Loop
     % Construct the MNA_matrix and J_vect
     MNA_matrix = MNA_Matrix_R ;
     J_vect= zeros(No_nodes,1);
     
     
     %Add the Linear Elements into MNA matrix and J_vect like Capacitor,
     %Inductor, Voltage Source and Current Source
     cap_count=0; counter_C=1; counter_L =1; v_counter=1; ind_count=0;
        
     Node_vlt_prev_t(:,1)=  Node_voltage_time(:,iter-1);
     
     for row_no=1:size(LINELEM,1)
         
         elem = LINELEM(row_no,:);
           
         % The Values of R does not change during time t
         if(elem(TYPE_)== C_)
           % Stamp the Trapeziodal Euler Model for the Capacitor
            if ((iter==2) & isnan(elem(C_IC_)))
               cap_count= cap_count+1 ;
               capacitor_current(cap_count,1) = 0;
               else
               cap_count= cap_count+1 ;
            end
                 
            if (INFO(METHOD_)== TR_)
               [ MNA_matrix, J_vect, Current_i_cap(counter_C,iter-1)]= stamp_cap_TR(MNA_matrix, J_vect, elem, delta_t, Node_vlt_prev_t, capacitor_current(cap_count));
               counter_C= counter_C+1;
                  
            elseif (INFO(METHOD_) == BE_)
               [ MNA_matrix, J_vect, Current_i_cap(counter_C,iter-1)]= stamp_cap_BE(MNA_matrix, J_vect, elem, delta_t, Node_vlt_prev_t);                     
                counter_C= counter_C+1;
                 
            elseif  (INFO(METHOD_) == FE_)
               [ MNA_matrix, J_vect, Current_i_cap(counter_C,iter-1)]= stamp_cap_FE(MNA_matrix, J_vect, elem, delta_t, Node_vlt_prev_t, capacitor_current(cap_count));                  
               counter_C= counter_C+1;
                       
            end
                 
         elseif(elem(TYPE_)== L_)
            % Stamp the Trapeziodal Euler Model for the Inductor
            if ((iter==2) & isnan(elem(L_IC_)))
              ind_count= ind_count+1 ;
              ind_current(ind_count,1)= ind_current_dc(ind_count,1) ;
                     
            else
              ind_count= ind_count+1 ;
            end
                 
            if (INFO(METHOD_) == TR_) 
              [ MNA_matrix, J_vect, Current_i_ind(counter_L,iter-1)]= stamp_ind_TR(MNA_matrix, J_vect, elem, delta_t, Node_vlt_prev_t, ind_current(ind_count));
              counter_L= counter_L+1 ;
                   
            elseif (INFO(METHOD_) == BE_)
              [ MNA_matrix, J_vect, Current_i_ind(counter_L,iter-1)]= stamp_ind_BE(MNA_matrix, J_vect, elem, delta_t, ind_current(ind_count));
              counter_L= counter_L+1 ;
                   
            elseif (INFO(METHOD_) == FE_)
              [ MNA_matrix, J_vect, Current_i_ind(counter_L,iter-1)]= stamp_ind_FE(MNA_matrix, J_vect, elem, delta_t, Node_vlt_prev_t, ind_current(ind_count));
              counter_L= counter_L+1 ;
            end
                 
         elseif(elem(TYPE_)== V_)
            % Stamp the Independent Voltage Source model
            [MNA_matrix, J_vect, VSource_i(v_counter,1)] = stamp_ind_vsource_tran(MNA_matrix, J_vect, elem, t); 
            v_counter = v_counter+1;
                    
             
         elseif(elem(TYPE_)== I_ )
            % Stamp the Independent Current Source Model
            J_vect = stamp_ind_csource_tran(J_vect, elem, t);

         end

     end
     
     Parasitics_add= 0;
     % Stamping the MOSFET Parasatics Capacitances
     % The MOSFET Parasitics Capacitances are assumed to be linear
     for row_no=1:size(NLNELEM,1)
         elem =  NLNELEM(row_no,:);
         if(elem(TYPE_) == M_)
           % Stamp_MOSFET Capacitances
           [ MNA_matrix, J_vect, row_MOS_Cap]= stamp_cap_MOS(MNA_matrix, J_vect, elem, delta_t, Node_vlt_prev_t);
         end  
         Parasitics_add = Parasitics_add+ row_MOS_Cap ;
           % The Numbers of Rows added is saved in row_MOS_Cap 
      end
     % End of Stamping the Linear
     % Save the MNA Matrix after adding the Linear Elements
     MNA_Linear_Tran = MNA_matrix;
     J_vect_Linear_Tran = J_vect;
     
     v_vect = length(MNA_matrix)+ size(NLNELEM,1) ;
     Node_voltage_NR(:,1)= zeros(v_vect, 1);
     
     % Perform Newton Raphson Iteration
     limit_convergence = 1000;
     jcount = 1;
     converged_NR = 0 ; 
     converge_fail = 0;
     while ((~ converged_NR) & (~converge_fail))
            if (jcount> limit_convergence)
                converge_fail=1;
                break ;
            end
            MNA_matrix= MNA_Linear_Tran ;
            J_vect = J_vect_Linear_Tran ;
            % Update the Linear Problem
            % Stamp the Linearised model for the MOSFET
            Mos_count =0 ; nmos_count= 0; pmos_count= 0;
            % Stamping the Non-Linear Elements into the Y matrix
            for row_no=1:size(NLNELEM,1) 
                elem = NLNELEM(row_no,:);
                %MOSFETS
                Mos_count= Mos_count +1 ; 
                %Stamp the  linearised model of the MOSFET 
                if (jcount== 1)  
                   Node_voltage_NR(1:No_nodes,1) = Node_vlt_prev_t(1:No_nodes,1) ;                                           
                end
                
                if(((elem(TYPE_)== M_) & (elem(M_TYPE_)== NMOS_)))
                  [MNA_matrix, J_vect, V_row(Mos_count,1)]= stamp_NMOSFET(MNA_matrix, J_vect, elem, Node_voltage_NR(:,1));
                                  
                elseif(((elem(TYPE_)== M_) & (elem(M_TYPE_)== PMOS_)))
                  [MNA_matrix, J_vect, V_row(Mos_count,1)]= stamp_PMOSFET(MNA_matrix, J_vect, elem, Node_voltage_NR(:,1));
          
                  % End of if TYPE == MOSFET  
                end
   
             % End of NLNELEM Array Traverse
            end
            %Solve the Linearised Circuit
             jcount = jcount+1 ;
             % Equations Jacobian * delta_v =  I_vect is solved
             Node_voltage_solnNR(:,1) = MNA_matrix\ J_vect ;    
             diff_vect = Node_voltage_solnNR(:,1)- Node_voltage_NR(:,1);
             if (norm(diff_vect,2)< (10^(-8))), converged_iter =jcount ; converged_NR= 1 ; end;
             Node_voltage_NR(:, 1)= Node_voltage_solnNR(:,1);
     
     
             
             % End of Newton Raphson Iteration Loop
     end
     
     %Obtain the converged Solution
     if (converged_NR==1)
         Node_volt_final = Node_voltage_NR ;
         Node_voltage_time(:,iter) = Node_voltage_NR(1:No_nodes,1);
     end
     % Current Assignments
     if(cap_present >0) 
       Cap_current_pos= Current_i_cap(:,1);
       capacitor_current = Node_volt_final(Cap_current_pos,1); 
     end
           
     if(vsource_p>0)
       Vsource_current_pos = VSource_i(:,1);
       current_vsource = Node_volt_final(Vsource_current_pos);
     end
     
     
     if (ind_present >0)
       Ind_current_pos= Current_i_ind(:,1); 
       ind_current = Node_volt_final(Ind_current_pos,1) ;
     end
     
     if (~isempty(NLNELEM))
         mos_current = Node_volt_final(V_row(:,1)) ;
         MOSFET_i(:, iter)= mos_current ;
     end;
         

    
     
  % End of Transient Loop   
 end
