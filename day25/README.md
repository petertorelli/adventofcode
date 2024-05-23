I wrote a force-directed plotter in C using GNU plotutils.

Translate the edge names into 0..N integers.

Run the simulation for 300 iterations. By this point two very clear clusters
will appear, very far apart from each other relative to the inter-cluster
edge lengths.

Print out each pair and their distances, sort by distance.

```
% grep Distance output | sort -n -k 8 -r | head -20
Distance between node 1342 and 1256 = 762.821899
Distance between node 1342 and 1256 = 762.821899
Distance between node 1256 and 1342 = 762.821899
Distance between node 1256 and 1342 = 762.821899
Distance between node 278 and 1031 = 748.724548
Distance between node 278 and 1031 = 748.724548
Distance between node 1031 and 278 = 748.724548
Distance between node 1031 and 278 = 748.724548
Distance between node 962 and 1322 = 744.192078
Distance between node 962 and 1322 = 744.192078
Distance between node 1322 and 962 = 744.192078
Distance between node 1322 and 962 = 744.192078
Distance between node 1211 and 1161 = 19.423290
Distance between node 1211 and 1161 = 19.423290
Distance between node 1161 and 1211 = 19.423290
Distance between node 1161 and 1211 = 19.423290
Distance between node 416 and 1338 = 19.114893
Distance between node 416 and 1338 = 19.114893
Distance between node 1338 and 416 = 19.114893
Distance between node 1338 and 416 = 19.114893
```

Pairs are (1342, 1256), (278, 1031), and (962, 1322).

Map the node numbers back to the three letter codes.

Use 'part1.pl' again and snip the node names' edges.

Multiply.

Done.

I forgot how useful `plotutils` can be. Very easy to create animations in
C on linux. MacOS required some fussing to rebuild it since by default
brew and macports do not compile plotutils-2.6 with X. Feh.

Made an mpeg using ffmpeg ... ![](animation.mp4)


