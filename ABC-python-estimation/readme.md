Here you can find the python code leveraging on 'pyabc' (https://pyabc.readthedocs.io/en/latest/index.html) to estimate the model 'bc.nlogo' to the target distribution using ABC - Sequential Monte Carlo Algorithm. 

Estimation can take some time. To speed it up:
+ Open the file, and reduce the 'num_params' in 'launch_abc', and/or in 'simulate' run the model for less than 300 iterations
+ Split the exploration of a given 'num_params' in two or more processes on different VM. So far, not parallelized yet, so kinda doing it 'artisanally'.
  + Trivial example. You want to obtain a distribution of 500 parameters. Open in Windows two 'cmd'. Launch the model twice with 'num_params' = 250

How to launch on terminal. Example on windows: python "C:\\Users\\User\\Desktop\\bounded_confidence\\abc_bc.py" 

So far, the output is a dataframe in .csv, saved in a user-specified working directory. This dataframe contains the values obtained in the last iteration of the ABC - SMC Algorithm. In particular, the 'num_params' parameters retained, their weight, and the corresponding summary statistics and terminal distance  
