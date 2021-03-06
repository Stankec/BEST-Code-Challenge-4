from node import Node
from edge import Edge
from edge import normalize
import operator
import copy
import math

"""
The network module is the main interface of the Bayes network.
By using the functions described here you can create nodes, edges 
and calculate the user preferences.

To use the network you need to:
1. Create the network object
2. Add nodes to the network
3. Add edges to the network
4. Add rating tuples to the edges; the recommended way is this:
>>> n.add_edge(first_node_id,second_node_id).add_tuple(value1,value2)
5. Set user opinions for known nodes
6. Calculate edge probabilities
7. Call the solve() function, which returns the top ten most probable node
values, sorted from most to least probable.

I recommended looking at parser.py for an example of class usage.

"""
class Network(object):
	def __init__(self):
		self.nodes = {}
		self.node_count = 0
		self.edges = []
		self.edge_count = 0
		self.watched = []

	def add_node(self, value, id = None):
		if id is None:
			id = self.node_count
		if id in self.nodes.keys():
			return
		n = Node(id,value,network_reference=self)
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

	"""
	Helper functions for quick testing 
	of user preferences. When using for real use 
	the set_node_opinion function.
	"""
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

	"""
	Quick algorithm explanation:
	For every watched movie calculate the like probabilites of
	adjacent nodes, cull all movies with a probability of user like
	less then 0.1(The probability values have been scaled, for smaller 
	databases this number should be smaller. The maximum recommended value is 
	0.5, but only for very large user-bases.) Then go into a while loop, which 
	repeats until all movies in the database are stored in the hash map, or 
	until the hash map has 10 values, or until all possible movies have been
	queried for this watched movie. Cull and repeat the while loop.	After 
	exiting the while loop, multiply the old values for stored movies with the
	new ones and normalize,this gives us the final movie preference 
	probabilites. Repeat that for every movie watched. Then sort the outer hash
	map and print out the top 10 films, or all films which satisfy the cull 
	criteria(pref > 0.1), whichever number is smaller. More details can be 
	found in the /doc folder, where the algorithm is explained thoroughly.
	
	"""
	def solve(self):
		temp_top = {}
		for w in self.watched:
			rem_list=[]
			temp_map={}
			self.nodes[w].calculate_like_probabilities(temp_map,self.watched)
			self.__cull(temp_map)
			while((len(temp_map) < 10) and (len(temp_map) < (self.node_count - len(self.watched)))):
				key_list= list(temp_map)
				for r in rem_list:
					key_list.remove(r)
				rem_list = list(temp_map)
				if not key_list:
					break
				for k in key_list:
					self.nodes[k].calculate_like_probabilities(temp_map,self.watched)
				self.__cull(temp_map)

			for k in temp_map.keys():
				if k not in temp_top.keys():
					temp_top[k]= temp_map[k]
				else:
					val = [temp_top[k][0] * temp_map[k][0],temp_top[k][1]*temp_map[k][1]]
					temp_top[k]=normalize(val) 
		
		s_tup = sorted(temp_top.items(), key=operator.itemgetter(1), reverse=True)
		length = len(s_tup) if (len(s_tup) < 10) else 10
		for i in range(length):
			print(self.nodes[s_tup[i][0]].value)

	def __cull(self, temp_map):
		key_list = list(temp_map)
		for k in key_list:
			if temp_map[k][0] < 0.1:
				del temp_map[k]

	def print_network(self):
		print("Node count: ", self.node_count)
		print("Edge count: ", self.edge_count)
		print("Watched: ", self.watched)
		for k in sorted(self.nodes.keys()):
			self.nodes[k].print_node()
