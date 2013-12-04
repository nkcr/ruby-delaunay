delaunay
========

Compute a delaunay triangulation.  
The algorithm combines features of both the Watson and 
Lawson procedures.  
Algorithm of complexity O(n^5/4).  
 
Instructions :  
Just use the require statement in your file like
'require delau.rb'  then call 'Delau.deltri' with your
params :  

    'x'       - list of x coordinates
    'y'       - list of y coordinates
    'params'  - hash of optional params
              'n'     - number of points to be trianguled
              'list'  - list of points to be trianguled
                      - can be used to compute a subset of points
