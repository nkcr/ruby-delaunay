require 'delau.rb'

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

	def gather point,conn,useless,group
		#
		# Purpose :
		# --------
		# Subroutine,
		# Recursive function. Given a point finds
		# the other point connected to him based in the
		# conn list.
		#
		# Params :
		# --------
		# 'point'		- The point, based on the conn list
		# 'conn'		- List containing all the points connected
		# 					  to a point
		# 					- Connections to point n is in conn[n]
		# 					- The list is redundant
		# 'useless'	- List of points already processed
		# 'group'		- List containing a group of points
		# 					- The points in group satisfies the merge distance 
		#
		points = conn[point]
		points.each do |a|
			next if useless.include? a
			useless.push(a)
			group.push(a)
			gather a,conn,useless,group
		end
	end

	#
	# Let's first itterate over points and each
	# time found the other connected point to then
	# calculate the distance between them.
	# If the distance is bigger than the merge
	# distance we do nothing, otherwise we push the
	# result in a list 'connected' and finally push
	# the list in 'conn' list.
	# 'conn'		- list containing all the points connected
	# 						to a point
	# 					- Connections to point n is in conn[n]
	# 					- The list is redundant
	# 					- [ [...], ...]
	# 					- The points satisfies the merge distance
	# 'groups'	- List containing groups of points group
	# 					- The list is non-redundant
	# 					- [[...], ...]
	#
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
		puts "a: #{a}"
		next if useless.include?(i) || !a.any?
		puts "not next"
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

def draw x,y,v, groups=[]
	#
	# Purpose :
	# --------
	# Draw a delaunay triangulation and
	# show merge circles if given
	#
	# Params :
	# -------
	# 'x'				- List of x-coordinate points
	# 'y' 			- List of y-coordinate points
	# 'v'				- List of vertex triangle
	# 					- Verte of n triangle is v[0..2][n]
	# 'groups'	- List containing groups of points group
	# 					- [ [...], ...]
	#
	Shoes.app width: 1200, height: 700 do |app|
		background "#FFFFFF"
		width = 1210; height = 710
		xoffset = 20; yoffset = 20
		wratio = width/100 ; hratio = height/100
		r = 10
		#
		# Points
		#
		x.each_with_index do |a, i|
			oval a*wratio+xoffset-r, y[i]*hratio+yoffset-r, radius: r
		end
		#
		# Groups 
		#
		fill rgb(0, 0.6, 0.9, 0.1)
    stroke rgb(0, 0.6, 0.9)
    strokewidth 0.25
		groups.each do |a|
			xp = 0; yp = 0;
			a.each do |b|
				xp = xp + x[b]
				yp = yp + y[b]
				fill rgb(0.9, 0.2, 0.2, 0.5)
				oval x[b]*wratio+xoffset, y[b]*hratio+yoffset, radius: 6
				fill rgb(0, 0.6, 0.9, 0.1)
			end
			xp = (xp / a.length)*wratio+xoffset
			yp = (yp / a.length)*hratio+yoffset
			r = Math.sqrt((wratio+0)**2 + (hratio+0)**2)*a.length
			oval xp-r, yp-r, radius: r
		end
		#
		# Triangles
		#
		v[0].each_with_index do |a,i|
			v0 = a
			v1 = v[1][i]
			v2 = v[2][i]
			next if v0 > x.length-4 || v1 > x.length-4 || v2 > x.length-4
			line x[v0]*wratio+xoffset, y[v0]*hratio+yoffset, x[v1]*wratio+xoffset, y[v1]*hratio+yoffset
			line x[v1]*wratio+xoffset, y[v1]*hratio+yoffset, x[v2]*wratio+xoffset, y[v2]*hratio+yoffset
			line x[v2]*wratio+xoffset, y[v2]*hratio+yoffset, x[v0]*wratio+xoffset, y[v0]*hratio+yoffset
		end
	end
end


x = [24, 12, 93, 96, 61, 53, 98, 15, 66, 67, 72, 51, 35, 1, 69, 74, 17, 75, 6, 99, 89, 78, 91, 49, 77, 62, 9, 56, 14, 83, 75, 37, 51, 8, 47, 8, 61, 9, 35, 18, 62, 84, 69, 49, 69, 53, 61, 65, 20, 8, 91, 10, 33, 40, 0, 95, 57, 43, 70, 34, 54, 63, 95, 11, 62, 73, 59, 48, 0, 93, 28, 61, 38, 4, 37, 43, 48, 16, 82, 32, 12, 68, 13, 47, 28, 86, 67, 12, 89, 14, 17, 77, 30, 84, 55, 22, 0, 20, 8, 32, 13] 
y = [10, 12, 39, 10, 38, 99, 2, 92, 16, 69, 40, 68, 19, 66, 40, 92, 98, 41, 19, 56, 60, 33, 95, 16, 11, 6, 66, 57, 83, 95, 45, 70, 89, 85, 31, 98, 60, 59, 25, 73, 7, 41, 73, 88, 70, 63, 72, 22, 85, 62, 8, 58, 11, 75, 49, 28, 69, 47, 41, 19, 67, 51, 13, 41, 5, 75, 79, 98, 13, 92, 62, 98, 78, 53, 91, 39, 68, 61, 33, 48, 21, 56, 63, 38, 5, 36, 97, 3, 75, 38, 10, 46, 70, 23, 11, 65, 90, 6, 95, 59, 68]
x = (0..100).map{rand(100)}
y = (0..100).map{rand(100)}

delau = Delau.deltri x,y

# puts "\n\n\n"
groups = merge(x,y,delau[:v],5)
draw(x,y,delau[:v], groups)

# test : 120sec with 10'000 points and d = 30 (recursive)
