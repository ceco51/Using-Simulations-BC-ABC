Here you can find the python code leveraging on 'pyabc' (https://pyabc.readthedocs.io/en/latest/index.html) to estimate the model 'bc.nlogo' to the target distribution using ABC - Sequential Monte Carlo Algorithm. 

Estimation can take some time. To speed it up:
+ Open the file, and reduce the 'num_params' in 'launch_abc', and/or in 'simulate' run the model for less than 300 iterations
+ Split the exploration of a given 'num_params' in two or more processes on different VM. So far, not parallelized yet, so kinda doing it 'artisanally'.
+ Trivial example. You want to obtain a distribution of 500 parameters. Open in Windows two 'cmd'. Launch the model twice with 'num_params' = 250

How to launch on terminal. Example on windows: python "C:\\Users\\User\\Desktop\\bounded_confidence\\abc_bc.py" 

So far, the output is a dataframe in .csv, saved in a user-specified working directory. This dataframe contains the values obtained in the last iteration of the ABC - SMC Algorithm. In particular, the 'num_params' parameters retained, their weight, and the corresponding summary statistics and terminal distance  

Possibly an error will be raised by the JVM when launching the script. Just click on "Ok", it should work anyhow.

## Further details and future releases 

Parallel sampling using the default `pyabc` routine encounters significant challenges when the baseline model is implemented in NetLogo. This stems from NetLogo's Java and Scala architecture, which interacts poorly with Python's pickling mechanism — a serialization process required for parallel processing (see, e.g., https://github.com/jpype-project/jpype/issues/935). Pickling problems arise because objects that depend on external or non-Python code often lack the necessary serialization support, leading to failures during inter-process communication.

To address these issues, re-implementing the bounded confidence model in Python ensures all components are handled natively, enabling efficient parallel sampling, whether from the prior or from refined weighted distributions. However, this approach introduces a trade-off: while Python supports seamless parallel computation, replicating the intuitive visualizations of opinion dynamics provided by NetLogo becomes non-trivial. NetLogo's graphical interface remains pedagogically valuable, particularly for demonstrating the fundamentals of agent-based modeling, as users can directly observe how agent interactions drive emergent outcomes.

Looking ahead, we plan to release a version of the bounded confidence model built with MESA (https://mesa.readthedocs.io/stable/). This Python-based ABM framework will combine computational efficiency with improved visualization capabilities, offering a robust alternative that balances pedagogical utility and computational performance. 

