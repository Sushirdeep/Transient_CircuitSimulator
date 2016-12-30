 function [ Node_voltage_time, t_vect] = perform_Linear_Tran(LINELEM, NLNELEM, INFO, NODES)
 % Performing Linear Transient Anaylsis
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


MNA_matrix_R = MNA_matrix;
iter =0;


for t= 0 :delta_t:stop_t
    iter =iter+1; 
  if(t==0)
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
              
          % End of  If statements    
          end
          
          
      % End of  LINELEM array traverse    
      end
      
       % Performing Linear DC Analysis
           
            % After the Stamping Process is completed the System of Linear
            % Equations Yv= J is solved
            Node_voltage = MNA_matrix\ J_vect ;
       
            if (cap_present > 0),capacitor_current = Node_voltage(Current_i_dc_cap(:,1)); end
            if (vsource_p> 0), current_vsource = Node_voltage(VSource_i(:,1)); end
            if (ind_present > 0), ind_current_dc = Node_voltage(Current_i_dc_ind(:,1)); end
       
            Node_voltage_time(:,iter) = Node_voltage(1:No_nodes, 1) ;  
       
            % End of Linear Transient Analysis for DC
                                         
           % Else of  if t=0 condition 
        
   else
        
        % Precompute the Capacitor Currents and Inductor Voltages
        MNA_matrix= MNA_matrix_R;
        % Should Stamp Dynamic elements
        cap_count=0; counter_C=1; counter_L =1; v_counter=1; ind_count=0;
        % Elements that change with time as  Resistors and other static elements are
        %already stamped
        Nd_vlt(:,1)=  Node_voltage_time(:,iter-1);
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
                    [ MNA_matrix, J_vect, Current_i_cap(counter_C,iter-1)]= stamp_cap_TR(MNA_matrix, J_vect, elem, delta_t, Nd_vlt, capacitor_current(cap_count));
                  
                     counter_C= counter_C+1;
                  
                 elseif (INFO(METHOD_) == BE_)
                     [ MNA_matrix, J_vect, Current_i_cap(counter_C,iter-1)]= stamp_cap_BE(MNA_matrix, J_vect, elem, delta_t, Nd_vlt);
                     
                      counter_C= counter_C+1;
                 
                 elseif  (INFO(METHOD_) == FE_)
                     [ MNA_matrix, J_vect, Current_i_cap(counter_C,iter-1)]= stamp_cap_FE(MNA_matrix, J_vect, elem, delta_t, Nd_vlt, capacitor_current(cap_count));
                  
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
                     [ MNA_matrix, J_vect, Current_i_ind(counter_L,iter-1)]= stamp_ind_TR(MNA_matrix, J_vect, elem, delta_t,Nd_vlt, ind_current(ind_count));
                     counter_L= counter_L+1 ;
                   
                 elseif (INFO(METHOD_) == BE_)
                      [ MNA_matrix, J_vect, Current_i_ind(counter_L,iter-1)]= stamp_ind_BE(MNA_matrix, J_vect, elem, delta_t, ind_current(ind_count));
                   counter_L= counter_L+1 ;
                   
                 elseif (INFO(METHOD_) == FE_)
                      [ MNA_matrix, J_vect, Current_i_ind(counter_L,iter-1)]= stamp_ind_FE(MNA_matrix, J_vect, elem, delta_t,Nd_vlt, ind_current(ind_count));
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
        
               
           % After the Stamping Process is completed for time =t the System of Linear
           % Equations Yv= J is solved
           Node_voltage = MNA_matrix\ J_vect ;
       
           Node_voltage_time(:,iter) = Node_voltage(1:No_nodes, 1) ;  
            if(cap_present >0) 
               Cap_current_pos= Current_i_cap(:,1);
               capacitor_current = Node_voltage(Cap_current_pos,1); 
            end
        
        
            if(vsource_p>0)
               Vsource_current_pos = VSource_i(:,1);
               current_vsource = Node_voltage(Vsource_current_pos);
            end
        
  
            if (ind_present >0)
                Ind_current_pos= Current_i_ind(:,1); 
                ind_current = Node_voltage(Ind_current_pos,1) ;
            end        
            
       
     % Ending if t==0 perform DC Analysis else Perfrom Transient Analysis  
   end
    
    % Ending the Time Loop
    
end

% Return the Node_voltage_time matrix