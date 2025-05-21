"""
Person agent module for the Bounded Confidence Model.
This module contains the Citizen agent class for opinion dynamics simulation.
"""
import numpy as np
from mesa import Agent
from typing import List, Dict, Any

class Person(Agent):
    """
    A Person agent with an opinion that can be influenced by other agents.
    
    This agent implements the Bounded Confidence (BC) model of opinion dynamics,
    where agents only consider opinions of others if they are within their
    bound of confidence (epsilon).
    
    Attributes:
        opinion (float): The agent's current opinion (between 0 and 1)
        epsilon (float): Bound of confidence i.e., how far an opinion can be from own to still exert influence
    """
    def __init__(self, model: Any, opinion: float, epsilon: float):
        super().__init__(model)
        if not 0 <= opinion <= 1:
            raise ValueError("Opinion must be a float between 0 and 1.")
        self.opinion = opinion 
        if not 0 <= epsilon <= 1:
            raise ValueError("Bound of confidence must be a float between 0 and 1.")
        self.epsilon = epsilon
        
    def update_opinion(self) -> None:
        """
        Update the agent's opinion based on the opinions of others within their bound of confidence.
        
        The agent finds all other agents whose opinions are within their bound of confidence
        and updates their own opinion to the mean of those opinions.
        
        If no influencing agents are found, the opinion remains unchanged.
        """
        influencing_agents_opinions: List[float] = [
            agent.opinion for agent in self.model._all_agents
            if (abs(agent.opinion - self.opinion) < self.epsilon) and (agent.unique_id != self.unique_id)
            ]
        # Only update if there are influencing agents
        if influencing_agents_opinions:
            self.opinion = np.mean(influencing_agents_opinions)
    
    def random_opinion_change(self) -> None:
        """
        Randomly change opinion with probability mu (set in the BCModel class, same for each agent).
        
        The agent has a probability mu of changing its opinion to a random value
        between 0 and 1, simulating external influences or individual exploration.
        """
        if np.random.uniform(0, 1) < self.model.mu:
            self.opinion = self.model.np_random.uniform(0, 1)
    
    def tick(self) -> None:
        """
        Execute one step for the agent.
        
        First updates opinion based on others' influence, then potentially
        applies a random opinion change.
        """
        self.update_opinion()
        self.random_opinion_change()