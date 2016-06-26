Contents:

* txtMatrixToBinary -i infile -o outfile

  Use this program to convert a similarity matrix represented as text
  into a binary file that can be directly loaded by the clustering
  programs. The input file simply contains all the matrix values as
  text, that's all. No size needed (it's a square matrix, so it's easy
  for the program reading the binary file to figure out the matrix
  dimensions from the file size).


* generateMatrix -n numberOfObjects -c numberOfClasses [-s sigma] -o outfilePrefix [-rs randomSeed]

  Generate a binary similarity matrix (outfilePrefix.matrix) and a
  ground truth label file (outfilePrefix.labels) corresponding to a
  collection of n objects in c gaussian classes in 2D euclidean
  space. Similarity is inverse distance. The label file is text, with
  all labels in order following the same format as result files from the
  clustering programs (cf. inf.). Also produces a file containing
  first a line with the number of objects and number of classes, then
  all point coordinates (outfilePrefix.coords), one per line, to allow
  creating scatter plots.

  Specifying a random seed allows to re-generate the exact same
  data. If none is given, the current time will be used.


* generateInit -n numberOfObjects -c numberOfClasses -o outfilePrefix [-rs randomSeed]

  Generates a random labels file to use as init for the clustering
  algorithms. Note that if the -rs option is used, the produced labels
  will be exactly the same than what the init sequence of kkmeans or
  kaverages would produce with the same random seed. So in that case
  it's typically simpler to just give the random seed as parameter to
  those programs.


* kaverages -m similarityMatrix (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix [-r] [-rs randomSeed]

  Cluster objects into c classes using the kaverages algorithm. The
  file "outfilePrefix.log" will contain details of execution (loops,
  running time, etc), and "outfilePrefix.labels" will contain labels,
  as text.
  Line 1 : <number of objects> <number of classes>
  Line 2 : labels, separated by spaces

  Optionally, one may specify an init labels file instead of a number
  of classes (if both -c and -l are present, -c is ignored), and
  request that the algorithm run in raw mode (-r switch).

  Specifying a random seed allows to re-generate the exact same init
  data. If none is given, the current time will be used. If init
  labels are given, that option is useless.


* kkmeans -m similarityMatrix  (-c numberOfClasses | -l initLabelsFile) -o outfilePrefix [-rs randomSeed]

  Same as kaverages, but using the kernel k-means algorithm.
  No '-r' option, since that is not relevant here.


* agreement labels1 labels2

  Computes the agreement between two clusterings. The given metrics is
  the precision of each clustering relatve to the other after a
  winner-take-all pairing of labels.
