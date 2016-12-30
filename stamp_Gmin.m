function [ new_M ]= stamp_Gmin(old_M, gmin_value, NODES)

%%STAMP_GMIN : stamps entries corresponding to Gmin during Non-Linear DC Analysis
%
%
%        syntax: [new_M]= stamp_GE(old_M, gmin_value, NODES)
%
%        new_M, old_M are the new and old MNA matrices
%        gmin_value is the value of gmin being stamped 
%        NODES is the  vector that gives the mapping of the nodes in the
%        circuit
%        
new_M = old_M ;
No_nodes = length(NODES);
for row_i= 1:length(NODES)
      node_i= row_i ;
      if(node_i > 0)
          new_M(node_i,node_i)= new_M(node_i,node_i) + gmin_value;
      end
end