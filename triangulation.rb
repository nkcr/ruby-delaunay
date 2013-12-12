require_relative 'delau.rb'

def merge x,y,v,d
	#
	# Purpose :
	# ---------
	# Merge some points given a merge distance
	#
	# Params :
	# --------
	# 'x'		- List of x-coordinate points
	# 'y'		- List of y-coordinate points
	# 'v'		- List containing delaunay triangle
	# 			- The vertices of triangle n are in v[n][0..2]
	# 'd'		- Merge distance
	# 			- Represents the maximum distance between two 
	# 				points to be merged
	#
	# Outpus:
	# -------
	# 'a'		- todo
	#

	#
	# Let's first itterate over points and each
	# time found the other connected point to then
	# calculate the distance between them.
	# If the distance is bigger than the merge
	# distance we do nothing, otherwise we push the
	# result in an array.
	#
	def gather point,conn,useless,group
		points = conn[point]
		points.each do |a|
			next if useless.include? a
			useless.push(a)
			group.push(a)
			gather a,conn,useless,group
		end
	end

	conn = []
	(0..x.length-1).each do |p|
		connected = []
		v.each_with_index do |a,i|
			a.each_with_index do |b, j|
				next if b != p
				# v1 = p
				v2 = v[(i+1)%3][j]
				v3 = v[(i+2)%3][j]
				connected.push(v2) unless Math.sqrt((x[v2]-x[p])**2 + (y[v2]-y[p])**2) > d
				connected.push(v3) unless Math.sqrt((x[v3]-x[p])**2 + (y[v3]-y[p])**2) > d
			end
		end
		conn.push(connected.uniq.sort)
	end

	groups = []
	useless = []
	conn.each_with_index do |a, i|
		next if useless.include? i || !a.any?
		useless.push(i)
		group = []
		group.push(i)
		a.each do |b|
			next if useless.include? b
			useless.push(b)
			group.push(b)
			gather b,conn,useless,group
		end
		groups.push(group)
	end
	puts "\n\n\n"
	puts conn.to_s
	return groups
end # merge

def draw x,y,v
	Shoes.app do |app|
		v.each_with_index do |a, i|
			a.each do |b|
				v1 = i
				v2 = (i+1)%3
				v3 = (i+2)%3
			end
		end
		# we need only one iteration
		break
	end
end


x = [24, 12, 93, 96, 61, 53, 98, 15, 66, 67, 72, 51, 35, 1, 69, 74, 17, 75, 6, 99, 89, 78, 91, 49, 77, 62, 9, 56, 14, 83, 75, 37, 51, 8, 47, 8, 61, 9, 35, 18, 62, 84, 69, 49, 69, 53, 61, 65, 20, 8, 91, 10, 33, 40, 0, 95, 57, 43, 70, 34, 54, 63, 95, 11, 62, 73, 59, 48, 0, 93, 28, 61, 38, 4, 37, 43, 48, 16, 82, 32, 12, 68, 13, 47, 28, 86, 67, 12, 89, 14, 17, 77, 30, 84, 55, 22, 0, 20, 8, 32, 13] 
y = [10, 12, 39, 10, 38, 99, 2, 92, 16, 69, 40, 68, 19, 66, 40, 92, 98, 41, 19, 56, 60, 33, 95, 16, 11, 6, 66, 57, 83, 95, 45, 70, 89, 85, 31, 98, 60, 59, 25, 73, 7, 41, 73, 88, 70, 63, 72, 22, 85, 62, 8, 58, 11, 75, 49, 28, 69, 47, 41, 19, 67, 51, 13, 41, 5, 75, 79, 98, 13, 92, 62, 98, 78, 53, 91, 39, 68, 61, 33, 48, 21, 56, 63, 38, 5, 36, 97, 3, 75, 38, 10, 46, 70, 23, 11, 65, 90, 6, 95, 59, 68]
x = (0..1000).map{rand(100)}
y = (0..1000).map{rand(100)}

delau = Delau.deltri x,y

puts "\n\n\n"
puts merge(x,y,delau[:v],30).to_s
#draw x,y,delau[:v]
