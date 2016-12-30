README file

To execute the Project01 Matlab based Transient Circuit Simulator run the following command

>>SushirdeepCircuitSimulator('benchmark_circuit_name.dat')



Please note that while running the command the current working directory should be changed 
to the directory containing all the extracted Matlab files and the parsed .dat benchmark circuit files
The Transient Simulator  was built using Matlab2015b
The main function file is  SushirdeepCircuitSimulator which loads the circuit file and directs the operation 
to perform Linear Transient Analysis or NonLinear Transient analysis based on the INFO matrix and the LINELEM and NLNELEM 
and the plots and prints the node voltages and branch currents according to the PLOTNV, PLOTBI, PLOTBV, PRINTNV matricies



SushirdeepCircuitSimulator -  main function of the simulator
perform_Linear_Tran -         function for Linear DC and Transient analysis
perform_Non_Linear_Tran -     function for Non Linear DC and Transient analysis
stamp_cap_BE -                function for stamping capacitor using Backward Euler
stamp_cap_FE -                function for stamping capacitor using Forward Euler
stamp_cap_TR -                function for stamping capacitor using Trapezoidal Integration
stamp_cap_dc -                function for stamping capacitor during DC analysis
stamp_cap_MOS -               function for stamping parasitic capacitors in MOSFETS 
stamp_ind_BE -                function for stamping inductor using Backward Euler
stamp_ind_FE -                function for stamping inductor using Forward Euler
stamp_ind_TR -                function for stamping inductor using Trapezoidal Integration
stamp_ind_dc -                function for stamping inductor during DC Analysis
stamp_Gmin -                  function for stamping Gmin during Nonlinear DC solution
stamp_ind_csource-            function for stamping independent current source during DC analysis
stamp_ind_csource_tran-       function for stamping independent current source during Transient analysis
stamp_conductance -           function for stamping conductance
stamp_controlled_vccs-        function for stamping Voltage Controlled Current Source
stamp_controlled_vcvs-        function for stamping Voltage Controlled Voltage Source
stamp_resistance-             function for stamping resistance
stamp_ind_vsource-            function for stamping independent Voltage Source during DC analysis
stamp_ind_vsource_tran-       function for stamping independent Voltage Source during transient analysis
stamp_NMOSFET-                function for stamping NMOSFET 
stamp_PMOSFET-                function for stamping PMOSFET


This also folder contains 7 *.dat files corresponding to 7 *.ckt benchmark files.

Each *.dat file contains parsed information of the corresponding benchmark *.ckt.

The files can be loaded to MATLAB by

	load -mat *.dat

The above line is equivalent to

	cparse_init;
	parser_init;
	[LINELEM, NLNELEM, INFO, NODES, LINNAME, NLNNAME, PRINTNV, PRINTBV, PRINTBI, PLOTNV, PLOTBV, PLOTBI] = parser(file);

If there is any problem with the parser, you could avoid calling the parser by using "load -mat *.dat".