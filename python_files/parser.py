import sys
import codecs
import copy
from bayn import Network

movies = codecs.open(sys.argv[1],'r',encoding='mac_roman')
prefs = open(sys.argv[2],'r')
watched = open(sys.argv[3],'r')
	
n = Network()

for line in movies.readlines():
	s = line.split(',')
	
	id = int(s[0])
	if len(s) == 3:
		title = s[-1].strip() +' '+ s[1] 
	else:
		title = s[1].strip()

	n.add_node(title, id=id)

current_user = 1
temp_map = {}

for line in prefs:
	s = line.split(',')
	user_id = int(s[0])
	movie_id = int(s[1])
	rating = int(s[2])
	if current_user != user_id:
		mov_list = copy.copy(list(temp_map))
		while mov_list:
			current_mov = mov_list.pop()
			for m in mov_list:
				n.add_edge(current_mov, m, id=None).add_tuple(temp_map[current_mov],temp_map[m])
		current_user = user_id
		temp_map={}

	temp_map[movie_id] = rating

for line in watched:
	s = line.split(',')
	m = int(s[0])
	r = int(s[1])
	n.set_node_opinion(m, [ (r/5.0), 1 - (r/5.0)])

n.calculate_edge_correlations_tanimoto()
print(n.edge_count)
n.solve()



