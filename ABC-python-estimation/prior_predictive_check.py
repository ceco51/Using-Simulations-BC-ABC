import pyNetLogo as pn
import numpy as np
import pyabc
from typing import Dict, Union, Tuple, List
import matplotlib.pyplot as plt
import seaborn as sns

def simulate(max_eps: float, mu: float) -> Dict[str, Union[np.ndarray, float]]:
    """Run the NetLogo model and return the distribution of opinions,
       with its mean and median."""
    netlogo.command("set visualization? false")
    netlogo.command("set seed? false")
    netlogo.command("setup")
    netlogo.command("set number-of-agents 200")
    netlogo.command("set mu {}".format(mu))
    netlogo.command("set max-eps {}".format(max_eps))
    average_simulated = netlogo.repeat_report(["mean-opinion", "median-opinion"], 300, go='go', include_t0=True)
    opinions: numpy.ndarray = netlogo.report("opinion-distr") #just save the last one
    last_mean: float = average_simulated["mean-opinion"].iloc[-1]
    last_median: float = average_simulated["median-opinion"].iloc[-1]
    return {"opinions": opinions,
            "mean_opinions": last_mean,
            "median_opinions": last_median}

def sample_from_priors(uniform_priors: Dict[str, Tuple[float, float]], extractions: int):
    """
    Generate a list of parameter samples from uniform priors.

    Args:
        uniform_priors (dict): Dictionary of parameter names and their (lower, upper) bounds.
        extractions (int): Number of samples to generate.

    Returns:
        list[dict]: A list of dictionaries with sampled parameters.
    """
    return [
        {param: np.random.uniform(bounds[0], bounds[1]) for param, bounds in uniform_priors.items()}
        for _ in range(extractions)
    ]


if __name__ == '__main__':

    # Load the NetLogo model in Python
    JVM_PATH = "C:\\Program Files\\Java\\jdk-22\\bin\\server\\jvm.dll" #place here your path
    PATH_TO_MODEL = "C:\\Users\\User\\Downloads\\bc.nlogo" #place here your path
    netlogo = pn.NetLogoLink(gui=True, jvm_home=JVM_PATH)
    netlogo.load_model(PATH_TO_MODEL)

    # Provide data for functions 
    uniform_priors = dict(
        max_eps = (0.10, 0.40),
        mu = (0.01, 0.03)
    )
    extractions = 1000
    # Sample priors 
    sampled_dicts = sample_from_priors(uniform_priors, extractions)
    # Simulate the model with the sampled priors (so far, not in parallel. See main readme.md)
    predictions_from_priors = [simulate(**sample_dict) for sample_dict in sampled_dicts]

    # Extract and plot KDE of simulated equilibrium opinion distributions predicted by priors 
    opinions_from_prior = [pred['opinions'] for pred in predictions_from_priors]
    kde_results = []
    for values in opinions_from_prior:
        kde = sns.kdeplot(values, bw_adjust=0.5, clip = (0,1)).get_lines()[0].get_data()
        kde_results.append(kde)
        plt.clf()  # Clear the plot
    color_opinions = "dimgrey"
    plt.figure(figsize=(10, 6))
    for kde in kde_results:
        plt.plot(kde[0], kde[1], color=color_opinions, alpha=0.17)
    plt.show()
 
