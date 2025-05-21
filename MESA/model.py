"""
Bounded Confidence model for opinion dynamics simulation.
This module contains the BCModel class that implements the model.
"""

from mesa import Model, DataCollector
from agent import Person
import numpy as np
from typing import Dict, Union
# Import from utilities
from utilities import (
    get_mean_opinions,
    get_median_opinions,
    get_opinion_distribution,
    get_mu,
    get_agent_epsilon
)

class BCModel(Model):
    """
    Model class for the Bounded Confidence (BC) model of opinion dynamics.
    
    The model initializes a population of Person agents with random opinions
    and epsilon values as in Lorenz (2010). 

    Agents update their opinions based on other agents' opinions that are within their bounds of confidence.
    """

    def __init__(self, params: Dict[str, Union[int, float]]):
        # Mandatory on Mesa v3
        super().__init__(seed=params.get("seed")) # Setting Mesa's seed

        # Parameter values
        self.num_agents: int = params.get("num_agents")
        self.epsilon_max: float = params.get("epsilon_max")
        self.epsilon_min: float = params.get("epsilon_min")
        self.alpha: int = params.get("alpha")
        self.beta: int = params.get("beta")
        self.mu: float = params.get("mu")
        self.num_runs: int = params.get("num_runs")

        # Setting numpy's seed
        self.np_random = np.random.default_rng(params.get("seed"))

        # Create agents
        for i in range(self.num_agents):
            Person(
                model = self,
                opinion = self.np_random.uniform(0, 1),  # New random opinion each time
                epsilon = self.calculate_epsilon()  # New epsilon each time
                )
        
        # Pickable DataCollector instance
        self.datacollector = DataCollector(
            model_reporters={
                "MeanOpinions": get_mean_opinions,
                "MedianOpinions": get_median_opinions,
                "OpinionDistr": get_opinion_distribution,
                "mu": get_mu
            },
            agent_reporters={
                "epsilon": get_agent_epsilon
            }
        )

    def calculate_epsilon(self) -> float:
        """
        Sample from a scaled Beta(alpha, beta) distribution (Lorenz, 2010).
        """
        x: float = self.np_random.gamma(shape=self.alpha, scale=1.0)
        y: float = self.np_random.gamma(shape=self.beta, scale=1.0)
        beta_sample = x / (x + y)
        return self.epsilon_min + beta_sample * (self.epsilon_max - self.epsilon_min)

    def step(self) -> None:
        
        for _ in range(self.num_runs):
            # Make agents act (assuming a custom method)
            self.agents.shuffle_do("tick")
        
            # Collect results
            self.datacollector.collect(self) 
