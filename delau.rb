#!/usr/bin/ruby
#
# Compute a delaunay triangulation.
# The algorithm combines features of both the Watson and 
# Lawson procedures.
# Algorithm of complexity O(n^5/4)
# 
# Instructions :
# Just use the require statement in your file like
# 'require delau.rb'  then call 'Delau.deltri' with your
# params :
#   'x'       - list of x coordinates
#   'y'       - list of y coordinates
#   'params'  - hash of optional params
#             'n'     - number of points to be trianguled
#             'list'  - list of points to be trianguled
#                     - can be used to compute a subset of points
#     
#
module Delau
  extend self
  def self.deltri(x,y,params={})
    #
    # Set default variables
    #
    defaults = {
      n: x.length-1,
      list: [*0..x.length-1],
    }
    params = defaults.merge(params)
    n = params[:n]
    list = params[:list]
    #
    # Init some variables
    #
    e = Array.new(3) {Array.new()}
    v = Array.new(3) {Array.new()}
    numpts = x.length-1
    numtri = 0
    stack = []
    bin = []
    #
    # Start by normalize coords so then
    # stay under 1
    #
    xmin = x[list[0]]
    xmax = xmin
    ymin = y[list[0]]
    ymax = ymin
    (1..n).each do |i|
      p = list[i]
      xmin = [xmin, x[p]].min
      xmax = [xmax, x[p]].max
      ymin = [ymin, y[p]].min
      ymax = [ymax, y[p]].max
    end
    dmax = [xmax-xmin,ymax-ymin].max
    #
    # Normalize x-y coord of points
    #
    fact = 1.0/dmax
    (0..n).each do |i|
      p = list[i]
      x[p] = (x[p]-xmin).to_f*fact
      y[p] = (y[p]-ymin).to_f*fact
    end

    delaunay = delaun(numpts,n,x,y,list,bin,stack,v,e,numtri)

    (0..n).each do |i|
      p = list[i]
      x[p] = x[p]*dmax+xmin
      y[p] = y[p]*dmax+ymin
    end

    puts "_____ X, Y _____"
    puts x.to_s
    puts "_Y_"
    puts y.to_s
    puts "_____ V, E _____"
    puts v.to_s
    puts "_E_"
    puts e.to_s

    return {x: x,y: y,list: list,v: v,e: e, n: n}
  end

  private

  def delaun numpts,n,x,y,list,bin,stack,v,e,numtri=0
    #
    # Create SuperTriangle
    #
    v1 = numpts+1
    v2 = numpts+2
    v3 = numpts+3
    v[0][0] = v1
    v[1][0] = v2
    v[2][0] = v3
    e[0][0] = -1
    e[1][0] = -1
    e[2][0] = -1

    x[v1] = -100
    y[v1] = 0
    x[v2] = 100
    y[v2] = 0
    x[v3] = 0
    y[v3] = 100
    #
    # Iterate over list until n
    #
    numtri = 0
    (0..n).each do |i|
      puts "Tour n #{i}"
      p = list[i]
      xp = x[p]
      yp = y[p]
      #
      # Find triangle which encloses p
      #
      t = triloc xp,yp,x,y,v,e,numtri
      #
      # Create 2 new triangles from p and change t
      # We always use p as first vertex
      #
      a = e[0][t]
      b = e[1][t] 
      c = e[2][t] 
      v1 = v[0][t]
      v2 = v[1][t]
      v3 = v[2][t]
      v[0][t] = p
      v[1][t] = v1
      v[2][t] = v2
      e[0][t] = numtri+2
      e[1][t] = a
      e[2][t] = numtri+1
      #
      # Create new triangles
      #
      numtri = numtri+1
      v[0][numtri] = p
      v[1][numtri] = v2
      v[2][numtri] = v3
      e[0][numtri] = t
      e[1][numtri] = b
      e[2][numtri] = numtri+1
      numtri = numtri+1
      v[0][numtri] = p
      v[1][numtri] = v3
      v[2][numtri] = v1
      e[0][numtri] = numtri-1
      e[1][numtri] = c
      e[2][numtri] = t
      #
      # Put each edge of triangle t on stack
      # Add triangle in LIFO procedure (las-in/first-out)
      # store triangles on left side of each edge
      #
      if a != -1
        stack.push(t)
      end
      if b != -1
        e[edg(b,t,e)][b] = numtri-1
        stack.push(numtri-1)
      end
      if c != -1
        e[edg(c,t,e)][c] = numtri
        stack.push(numtri)
      end
      #
      # Loop over stack
      #
      while stack.length > 0
        l = stack.pop()
        r = e[1][l]
        #
        # Check if new point is in circomcircle for triangle r
        #
        erl = edg(r,l,e)
        era = (erl+1)%3
        erb = (era+1)%3
        v1 = v[erl][r]
        v2 = v[era][r]
        v3 = v[erb][r]
        #if false
        if swap x[v1],y[v1],x[v2],y[v2],x[v3],y[v3],xp,yp
          #
          # New point is inside a circumcircle
          # Swap diagonal for convex quad formed by p-v2-v3-v1
          #
          a = e[era][r]
          b = e[erb][r]
          c = e[2][l]
          #
          # Update vertex and adjajency list for triangle l
          #
          v[2][l] = v3
          e[1][l] = a
          e[2][l] = r
          #
          # Update vertex and adjacency list for triangle r
          #
          v[0][r] = p
          v[1][r] = v3
          v[2][r] = v1
          e[0][r] = l
          e[1][r] = b
          e[2][r] = c
          #
          # Puts edge l-a and r-b on stack
          #
          if a != -1
            e[edg(a,r,e)][a] = l
            stack.push(l)
          end
          if b != -1
            stack.push(r)
          end
          if c != -1
            e[edg(c,l,e)][c] = r
          end
        end # if swap
      end # while stack
    end # iteration over points
    #
    # Check consistency of triangulation
    #
    if numtri+1 != 2*(n+1)+1
      puts "Error in subroutine delau"
      puts "Incorrect number of triangle formed"
      puts "numtri=#{numtri} and should be #{2*n+1}"
    end
    #
    # Remove all triangles containing supertriangle vertices
    # find first triangles to be deleted (triangle t)
    # Update adjacency lists for triangles adjacent to t
    #
    t = nil
    goto = false
    (0..numtri).each do |t2|
      t = t2
      if v[0][t2] > numpts || v[1][t2] > numpts || v[2][t2] > numpts
        (0..2).each do |i|
          a = e[i][t2]
          if a != -1
            e[edg(a,t2,e)][a] = -1
          end
        end
        goto = true
      end
      break if goto
    end
    tstr = t+1
    tstop = numtri
    numtri = t-1
    #
    # Remove triangles
    #
    (tstr..tstop).each do |t|
      if v[0][t] > numpts || v[1][t] > numpts || v[2][t] > numpts
        (0..2).each do |i|
          a = e[i][t]
          if a != -1
            e[edg(a,t,e)][a] = -1
          end
        end
      else
        #
        # triangle t is not to be deleted
        # put triangle t in place of triangle numtri
        # update adjacency lists for triangles adjacent to t
        #
        numtri = numtri+1
        (0..2).each do |i|
          a = e[i][t]
          e[i][numtri] = a
          v[i][numtri] = v[i][t]
          if a != -1
            e[edg(a,t,e)][a] = numtri
          end
        end # each 0..2
      end # if > numpts
    end # each tstr..tstop
  return {x: x,y: y,list: list,v: v,e: e}
  end

  def triloc xp,yp,x,y,v,e,numtri
    t = numtri
    previous = []
    previous.push(t)
    cont = true
    while cont
      cont = false
      (1..3).each do |i|
        v1 = v[i-1][t]
        v2 = v[i%3][t]
        if (y[v1]-yp)*(x[v2]-xp) > (x[v1]-xp)*(y[v2]-yp)
          t = e[i-1][t]
          #raise "Error in triloc.\n current t=#{t}.\n Points=#{previous}.\n e=#{e}\n v=#{v}\n x=#{x}\n y=#{y}" if previous.include?(t)
          return t if previous.include?(t)
          previous.push(t)
          cont = true
        end
        break if cont
      end
    end
    return t
  end

  #
  # Give the number (0..2) in the adjency array (of l) of
  # the triangle who is adjency from l to k
  #
  def edg l,k,e
    (0..2).each do |i|
      if e[i][l] == k
        return i
      end
    end
    raise "Not adjacent triangle"
  end

  #
  #
  #
  def swap x1,y1,x2,y2,x3,y3,xp,yp
    x13 = x1-x3
    y13 = y1-y3
    x23 = x2-x3
    y23 = y2-y3
    x1p = x1-xp
    y1p = y1-yp
    x2p = x2-xp
    y2p = y2-yp
    cosa = x13*x23+y13*y23
    cosb = x2p*x1p+y1p*y2p
    if (cosa >= 0) && (cosb >= 0)
      return false
    elsif (cosa < 0) && (cosb < 0)
      return true 
    else
      sina = x13*y23-x23*y13
      sinb = x2p*y1p-x1p*y2p
      if (sina*cosb+sinb*cosa) < 0
        return true
      else
        return false
      end
    end
  end # swap
end