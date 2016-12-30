function Node_voltage = perform_dc(LINELEM, NLNELEM, INFO, NODES)
% Performing DC Analysis on the  Circuit
% Important Matricies to keep in mind LINELEM, NLNELEM, INFO, NODES,
% PRINTNV, PRINTBV, PRINTBI, PLOTNV, PLOTBV, PLOTBI
addpath('parser_scripts');
parser_init ;
No_nodes= max(NODES);
MNA_matrix = zeros(No_nodes, No_nodes);
J_vect= zeros(No_nodes,1);
% Stamping the  Linear Elements onto the Y matrix (MNA Matrix) and
      % J_vector
      for row_no=1:size(LINELEM,1)
          elem = LINELEM(row_no,:);
          if(elem(TYPE_)== R_)
              % Resistor Element
              MNA_matrix = stamp_resistance(MNA_matrix, elem);
              
          elseif(elem(TYPE_)== Y_)
              % Conductance element
              MNA_matrix = stamp_conductance(MNA_matrix, elem);
              
          elseif(elem(TYPE_)== C_)
              % Capacitor Element DC
              [ MNA_matrix, J_vect, V_node_row]= stamp_cap_dc(MNA_matrix, J_vect, elem);
              
          elseif(elem(TYPE_)== L_)
              % Inductor Element DC
              [ MNA_matrix, J_vect, V_node_row]= stamp_ind_dc(MNA_matrix, J_vect, elem) 
              
          elseif(elem(TYPE_)== V_)
              % Stamping Independent Voltage Source
              [MNA_matrix, J_vect, V_node_row]= stamp_ind_vsource(MNA_matrix, J_vect, elem);
              
          elseif(elem(TYPE_)== I_)
              % Stamping Independent Current Source
              [J_vect]= stamp_ind_csource(J_vect, elem);
              
          elseif(elem(TYPE_)== E_)
              % Stamping Voltage Controlled Voltage Source
               [MNA_matrix, J_vect, V_node_row]= stamp_controlled_vcvs(MNA_matrix, J_vect, elem);
           
          elseif(elem(TYPE_)== G_)
               % Stamping Voltage Controlled Current Source
               [MNA_matrix, J_vect, V_node_row]= stamp_controlled_vccs(MNA_matrix, J_vect, elem);
          
          elseif(elem(TYPE_)== F_)
               % Stamping Current Controlled Current Source
               [MNA_matrix, J_vect, V_node_row]= stamp_controlled_cccs(MNA_matrix, J_vect, elem);
               
          elseif(elem(TYPE_)== H_)
              % Stamping Current Controlled Voltage Source
               [MNA_matrix, J_vect, V_node_row]= stamp_controlled_ccvs(MNA_matrix, J_vect, elem);
               
              
          % End of  If statements    
          end
          
          
      % End of  LINELEM array traverse    
      end
      
      
      % Stamping the Non-Linear Elements
       for row_no=1:size(NLNELEM,1)
           
           elem = NLNELEM(row_no,:);

               
           if(elem(TYPE)== M_)
               %MOSFETS
            
               
           % Ending the if Statements    
           end
           
       %Ending the traverse of NLNELEM Array 
       end
       
       % After the Stamping Process is completed the System of Linear
       % Equations Yv= J is solved
       Node_voltage = MNA_matrix\ J_vect ;