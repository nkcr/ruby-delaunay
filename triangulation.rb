#!/usr/bin/ruby
require 'delau.rb'


size = 1000
delaunay = Delau.deltri (0..size).collect{rand(100)}, (0..size).collect{rand(100)}

Shoes.app width: 900, height: 700 do |app|
  xmax = delaunay[:x].max
  ymax = delaunay[:y].max
  xmax = 100
  ymax = 100
  # delaunay[:list].each do |p|
  #   xp = (delaunay[:x][p] + 20) / xmax * app.width - 20
  #   yp = app.height - ((delaunay[:y][p] + 0) / ymax * app.height - 20)
  #   oval left: xp, top: yp, radius: 2
  # end
  (0..delaunay[:v][0].length).each do |p|
    if delaunay[:v][0][p] <= delaunay[:n] && delaunay[:v][1][p] <= delaunay[:n] && delaunay[:v][2][p] <= delaunay[:n] 
      x0 = (delaunay[:x][delaunay[:v][0][p]] + 20) / xmax * app.width - 20
      y0 = app.height - ((delaunay[:y][delaunay[:v][0][p]] + 0) / ymax * app.height - 20)
      x1 = (delaunay[:x][delaunay[:v][1][p]] + 20) / xmax * app.width - 20
      y1 = app.height - ((delaunay[:y][delaunay[:v][1][p]] + 0) / ymax * app.height - 20)
      x2 = (delaunay[:x][delaunay[:v][2][p]] + 20) / xmax * app.width - 20
      y2 = app.height - ((delaunay[:y][delaunay[:v][2][p]] + 0) / ymax * app.height - 20)

      line x0, y0, x1, y1
      line x1, y1, x2, y2
      line x2, y2, x0, y0
    end
  end 
end
