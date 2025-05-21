import numpy as np

def get_mean_opinions(model):
    return np.mean([agent.opinion for agent in model._all_agents])

def get_median_opinions(model):
    return np.median([agent.opinion for agent in model._all_agents])

def get_opinion_distribution(model):
    return [agent.opinion for agent in model._all_agents]

def get_mu(model):
    return model.mu

def get_agent_epsilon(agent):
    return agent.epsilon
