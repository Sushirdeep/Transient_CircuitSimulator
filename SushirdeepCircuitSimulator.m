function SushirdeepCircuitSimulator(ckt_filename)

% ECEN 751 Project 01
% MATLAB Transient Circuit Simulator
%ckt_filename contains the Matlab  bench_circuit_name
% The Function can be implemented by loading the Circuit dat file




%Adding the parser files
addpath ('parser_scripts');


% Initializing the Parser
cparse_init;
parser_init;
% Loading the Circuit File Netlist into Workspace
%[LINELEM, NLNELEM, INFO, NODES, LINNAME, NLNNAME, PRINTNV, PRINTBV, PRINTBI, PLOTNV, PLOTBV, PLOTBI]= parser('rc_line.ckt');

load (ckt_filename, '-mat');
%The Netlist is Loaded
% Important Matricies to keep in mind LINELEM, NLNELEM, INFO, NODES,
% PRINTNV, PRINTBV, PRINTBI, PLOTNV, PLOTBV, PLOTBI
      
% Determine the Analysis to be Performed from the INFO Method vector
 if (INFO(METHOD_)==DC_)
    %Perform DC Analysis
    volt_node = perform_dc(LINELEM, NLNELEM, INFO, NODES);
      
 elseif (INFO(METHOD_)==AC_)
    %Perform AC Analysis
          
 elseif ((INFO(METHOD_)== FE_) | (INFO(METHOD_)== BE_) | (INFO(METHOD_)== TR_) )
    % Perform Transient Analysis
    % Performing Linear Transient Anaylsis if only Linear Elements
    % are present
    fprintf('Performing Transient Analysis \n');
    if(isempty(NLNELEM))
       [volt_node_tran, time_t] = perform_Linear_Tran(LINELEM, NLNELEM, INFO, NODES);
    else
       [volt_node_tran, current_mos, time_t] = perform_Non_Linear_Tran(LINELEM, NLNELEM, INFO, NODES);
    end
          
 elseif (INFO(METHOD_)== AWE_)
    % Perform Transient or Frequency analysis by AWE
          
 elseif (INFO(METHOD_)== PRIMA_)
    % Perform Transient or Frequency analysis by PRIMA
      
          
 end
      
          
      
      
% Plotting the Node Voltages

if(~isempty(PLOTNV))
   fprintf('Plotting the Node Voltages \n'); 
   figure ;
   for j= 1:size(PLOTNV,1)
      point_k = PLOTNV(j,1);
      hold on;  
      plot(time_t, volt_node_tran(point_k,:)); 
      title('Plot of Node Voltage');
      xlabel('Time');
      ylabel('Voltage of Nodes in PLOTNV');
               
   end
   hold on;
   legend(int2str(PLOTNV(1:end ,1)))
 end
      
      
 %Printing the Node Voltages
 if(~ isempty(PRINTNV))
          
    fprintf('Printing the Node Volatges \n');
    fprintf('The Node Voltages are printed in the format shown below \n');
    fprintf('Node_Voltage_1 Node_Voltage_3 ... time \n');
    fprintf('The following node Voltages are going to be dispayed in command window \n');
    disp(PRINTNV');
          
    V_node_print= [ transpose(volt_node_tran(PRINTNV(1:end),:)) , time_t' ];
    format long;
    %format shortEng;
    disp(V_node_print);
          
 end
 
 
 
 % PLOTBI  = Branch currents to be plotted
 % Column 1 indicates index of corresponding element
 % Column 2 indicates element matrix (1 = LINELEM, 2 = NLNELEM)
 % Plotting the Node Voltages
 if(~ isempty(PLOTBI))
    fprintf('Plotting the Branch Currents \n'); 
    figure ;
    for i=1: size(PLOTBI, 1)
       if (PLOTBI(i,2) == 2)
        % Column 2 indicates element matrix (1 = LINELEM, 2 = NLNELEM)
         MOSFET_No = PLOTBI(i,1);  % Column 1 indicates index of corresponding element
         hold on;  
         plot(time_t, current_mos(MOSFET_No,:)); 
         title('Plot of Branch Current');
         xlabel('Time');
         ylabel('Current of Branches in PLOTBI');             
             
       end
    end
    hold on;
    legend(int2str(PLOTBI(1:end,1)))    
           
          
 end

 