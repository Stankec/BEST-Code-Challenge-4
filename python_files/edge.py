import copy
import math

class Edge(object):
	def __init__(self, first_node_id, second_node_id, table = []):
		self.first_node_id = first_node_id
		self.second_node_id = second_node_id
		self.table = None
		self.table_transposed = None
		self.rating_tuples = []
		self.relevance_factor = 1.0

	def add_tuple(self, rating1, rating2):
		self.rating_tuples.append((rating1,rating2))

	"""
	Probably the ugliest set of if-checks in existance...

	"""
	def exists(self,first_node_id,second_node_id):
		if (self.first_node_id == first_node_id) or (self.first_node_id == second_node_id):
			if (self.second_node_id == first_node_id) or (self.second_node_id == second_node_id):
				return True
		else:
			return False

	"""
	Sets the edge probability table, and it's transposed counterpart.

	"""
	def set_table(self,table):
		self.table = [[table[0],1.0 - table[0]],[table[1],1.0 - table[1]]]
		self.table_transposed = [[table[0],table[1]],[1.0- table[0],1.0 - table[1]]]
		
	"""
	Returns the node connected to the caller node via this edge.

	"""
	def get_other_node(self,caller_node_id):
		if caller_node_id == self.first_node_id:
			return self.second_node_id
		else:
			return self.first_node_id
		
	"""
	Calculates the like probability of the connecting node using
	matrix multiplication. 

	"""	
	def calculate_probability(self, caller_node_id, caller_value):
		if caller_node_id == self.first_node_id:
			return self.__mul(caller_value, self.table)
		else:
			return self.__mul(caller_value, self.table_transposed)

	"""
	Calculates the correlation between two nodes using a list of
	ratings. The function used __tanimoto is a variant of the
	cosine correlation. The relevance_factor makes sure that
	movies only watched by a small number of people have
	their probabilities reduced. Otherwise a person could rate
	eg. Lilo & Stitch with a 5, and Texas Chainsaw Massacre with a
	5, and a little kid somewhere would be scarred for life.
	After 9 or more people have rated both movies the relevance_factor
	becomes a number very close to 1, so the probabilities don't change
	as much.

	"""
	def calculate_tanimoto(self):
		val = [1.0,1.0]
		for t in self.rating_tuples:
			r = self.__tanimoto(t[0], t[1])
			val =[val[0] * r, 1.0 - (val[0] * r) ]
			val = normalize(val)
		self.relevance_factor = 1.0 - 1/len(self.rating_tuples)
		self.set_table(val)

	"""
	Matrix and relevance_factor multiplication.

	"""
	def __mul(self,caller_value, table):
		val = [(caller_value[0] * table[0][0] + caller_value[1] * table[1][0])
				,(caller_value[0] * table[0][1] + caller_value[1] * table[1][1]) ]
		normalize(val)
		val = [self.relevance_factor * val[0], self.relevance_factor*val[1]]
		return val

	"""
	The Tanimoto correlation function.

	"""
	def __tanimoto(self,a,b):
		mul = a*b
		return mul / (a*a + b*b - mul)

	def print_edge(self, caller_node_id):
		print(self.rating_tuples)
		if self.first_node_id == caller_node_id:
			print(caller_node_id,"\t---",self.table,"-->",self.second_node_id)
		else:
			print(caller_node_id,"\t---",self.table_transposed,"-->",self.first_node_id)


"""
Normalization, solves the k*(a+b)=1 equation for 1, and then
multiplies the values so that a + b = 1 becomes a true statement.

"""
def normalize(val):
	if (val[0] + val[1]) != 1.0:
		if (math.fabs(0.0 - (val[0] + val[1]))) < 0.001:
			return val
		k = 1.0 / (val[0] + val[1])
		val[0] = val[0] * k
		val[1] = val[1] * k
	return val