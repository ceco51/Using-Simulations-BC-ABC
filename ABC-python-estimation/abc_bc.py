import pyNetLogo as pn
import numpy as np
import os
import pandas as pd
from collections import Counter
import pyabc
from typing import Dict, Union, Tuple

def simulate(max_eps: float, mu: float) -> Dict[str, Union[np.ndarray, float]]:
    """Run the NetLogo model and return the distribution of opinions,
       with its mean and median."""
    netlogo.command("set visualization? false")
    netlogo.command("set seed? false")
    netlogo.command("setup")
    netlogo.command("set number-of-agents 200")
    netlogo.command("set max-eps {}".format(max_eps))
    netlogo.command("set mu {}".format(mu))
    average_simulated = netlogo.repeat_report(["mean-opinion", "median-opinion"], 300, go='go', include_t0=True)
    opinions: numpy.ndarray = netlogo.report("opinion-distr") #just save the last one
    last_mean: float = average_simulated["mean-opinion"].iloc[-1]
    last_median: float = average_simulated["median-opinion"].iloc[-1]
    return {"opinions": opinions,
            "mean_opinions": last_mean,
            "median_opinions": last_median}

uniform_priors: Dict[str, Tuple[float, float]] = dict(
max_eps = (0.10, 0.40),
mu = (0.01, 0.03)
)

priors: pyabc.Distribution = pyabc.Distribution(
**{key: pyabc.RV("uniform", a, b - a) for key, (a, b) in uniform_priors.items()}
)

def simulate_pyabc(parameter: Dict[str, float]) -> Dict[str, Union[np.ndarray, float]]:
    """Wrapper for the simulate function for use with pyabc."""
    res = simulate(**parameter)
    return res

def diff_means(x: Dict[str, float], y: Dict[str, float]) -> float:
    """Calculates the absolute distance between the mean opinion
       values of the simulated (x) and target distributions (y)."""
    return abs(x['mean_opinions'] - y['mean_opinions'])

def diff_medians(x: Dict[str, float], y: Dict[str, float]) -> float:
    """Calculates the absolute distance between the median opinion
       values of the simulated (x) and target distribution (y)."""
    return abs(x['median_opinions'] - y['median_opinions'])

def diff_modes(x: Dict[str, np.ndarray], y: Dict[str, float]) -> float:
    """Calculates the absolute distance between the two modes of
       the simulated (x) and target distribution (y)."""
    opinions = x['opinions']
    rounded_opinions = np.round(opinions, 2)
    counter = Counter(rounded_opinions)
    modes = counter.most_common(2) # Find the two most common values
    (first_mode, _), (second_mode, _) = modes
    diff_first_mode = abs(first_mode - y['first_modal_opinion'])
    diff_second_mode = abs(second_mode - y['second_modal_opinion'])
    return diff_first_mode + diff_second_mode

distance_aggr = pyabc.AggregatedDistance([diff_modes, diff_means, diff_medians])

def launch_abc(JVM_PATH: str,
               PATH_TO_MODEL: str,
               mean: float,
               median: float,
               first_mode: float,
               second_mode: float,
               WRITING_PATH: str,
               num_params: int = 500) -> pyabc.ABCSMC:
    """Launch the ABC - SMC model with given parameters."""
    global netlogo
    netlogo = pn.NetLogoLink(gui=True, jvm_home=JVM_PATH)
    netlogo.load_model(PATH_TO_MODEL)
    abc = pyabc.ABCSMC(simulate_pyabc, priors, distance_aggr, population_size = num_params)
    abc_id =  abc.new(
    "sqlite:///" + WRITING_PATH, {
        "mean_opinions": mean,
        "first_modal_opinion": first_mode,
        "second_modal_opinion": second_mode,
        "median_opinions": median}
    )
    return abc

if __name__ == '__main__':

    JVM_PATH = "C:\\Program Files\\Java\\jdk-22\\bin\\server\\jvm.dll" #place here your path
    PATH_TO_MODEL = "C:\\Users\\User\\Downloads\\bc.nlogo" #place here your path
    WRITING_PATH = os.path.join("C:\\Users\\User\\Desktop\\BC-Model\\Results", "abc_fit.db")
    max_iterations = 10
    terminal_distance = 0.05
    abc_model = launch_abc(
                           JVM_PATH = JVM_PATH,
                           PATH_TO_MODEL = PATH_TO_MODEL,
                           mean = 0.4457425430803015,
                           first_mode = 0.2315039,
                           second_mode = 0.78329658,
                           median = 0.23416140383519368,
                           WRITING_PATH = WRITING_PATH
                           )
    history = abc_model.run(
                            max_nr_populations = max_iterations,
                            minimum_epsilon = terminal_distance
                            )
    approx_posterior = history.get_population_extended()

    #set current working directory
    WHERE_TO_SAVE_CSV = "C:\\Users\\User\\Desktop\\BC-Model\\Results"
    os.chdir(WHERE_TO_SAVE_CSV)

    # Save the abc output DataFrame to the specified directory
    approx_posterior.to_csv('abc_output.csv', index=True)
