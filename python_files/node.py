from edge import Edge
from edge import normalize

class Node(object):
	def __init__(self,id,value,network_reference = None):
		self.value = value
		self.like_probability = None
		self.id = id
		self.edges = {}
		self.network_reference = network_reference

	def add_edge(self, edge):
		self.edges[edge.get_other_node(self.id)] = edge
		return edge

	def get_edge(self, second_node_id):
		return self.edges.get(second_node_id)

	def set_like_probability(self, table):
		self.like_probability = table

	def calculate_like_probabilities(self, temp_map, watched_list):
		for k in self.edges.keys():
			e = self.edges[k]
			target_id = e.get_other_node(self.id)
			if (target_id not in watched_list) and (target_id not in temp_map.keys()):
				target_node = self.network_reference.get_node_by_id(target_id)
				prob = e.calculate_probability(self.id,self.like_probability)
				target_node.set_like_probability(prob)
				temp_map[target_id] = target_node.like_probability
			else:
				pass

	def print_node(self):
		print("ID: ",self.id,"VAL: ", self.value, "EDG: ", len(self.edges))
		print(self.like_probability)
		for e in self.edges.values():
			e.print_edge(self.id)

