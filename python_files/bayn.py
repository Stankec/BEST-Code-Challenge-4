from node import Node
from edge import Edge
from edge import normalize
import operator
import copy
import math

class Network(object):
	def __init__(self):
		self.nodes = {}
		self.node_count = 0
		self.edges = []
		self.edge_count = 0
		self.watched = []
	
	def add_node(self, node, id = None):
		if id is None:
			id = self.node_count
		if id in self.nodes.keys():
			return
		n = Node(id,node,network_reference=self)
		self.nodes[id] = n
		self.node_count += 1
		return id
	
	def add_edge(self, first_node_id, second_node_id, id=None):
		if id is None:
			id = self.edge_count
 
		e = self.nodes[first_node_id].get_edge(second_node_id)

		if e is not None:
			return e

		e = Edge(first_node_id,second_node_id)
		self.edges.append(e)
		self.nodes[first_node_id].add_edge(e)
		self.nodes[second_node_id].add_edge(e)
		self.edge_count += 1
		return e

	def set_node_opinion(self,node_id, opinion_table):
		if node_id not in self.nodes.keys():
			print("No such Node: ", node_id)
			return None
		else:
			self.nodes[node_id].set_like_probability(opinion_table)
			self.watched.append(node_id)

	def set_node_like(self,node_id):
		self.set_node_opinion(node_id, [1,0])

	def set_node_dislike(self,node_id):
		self.set_node_opinion(node_id, [0,1])

	def get_node_by_id(self,id):
		if id in self.nodes.keys():
			return self.nodes[id]
		else:
			return None

	def calculate_edge_correlations_tanimoto(self):
		for e in self.edges:
			e.calculate_tanimoto()

	def solve(self):
		temp_top = {}
		for w in self.watched:
			rem_list=[]
			temp_map={}
			self.nodes[w].calculate_like_probabilities(temp_map,self.watched)
			while((len(temp_map) < 10) and (len(temp_map) < (self.node_count - len(self.watched)))):
				print(len(temp_map))
				key_list= list(temp_map)
				for r in rem_list:
					key_list.remove(r)
				rem_list = list(temp_map)
				if not key_list:
					break
				for k in key_list:
					self.nodes[k].calculate_like_probabilities(temp_map,self.watched)

			for k in temp_map.keys():
				if k not in temp_top.keys():
					temp_top[k]= temp_map[k]
				else:
					val = [temp_top[k][0] * temp_map[k][0],temp_top[k][1]*temp_map[k][1]]
					temp_top[k]=normalize(val) 
		
		s_tup = sorted(temp_top.items(), key=operator.itemgetter(1), reverse=True)
		for i in range(10):
			print(self.nodes[s_tup[i][0]].value)

	def print_network(self):
		print("Node count: ", self.node_count)
		print("Edge count: ", self.edge_count)
		print("Watched: ", self.watched)
		for k in sorted(self.nodes.keys()):
			self.nodes[k].print_node()
