Perl solutions to the [Advent of Code 2019](https://adventofcode.com/)
---

Here are my solutions to the Advent of Code 2019, written in Perl. It
was a lot of fun to figure all the solutions by myself; especially the
harder ones (16.2, 18, 22, I'm looking at you!). Kudos to Eric Wastl
for designing those puzzles.

I'm pretty sure that most of my solutions could be optimized: I didn't
spent too much time thinking on the simple problems.

My codes are definitely **not** optimized for readability, and
comments and fairly rare; sorry about that; I didn't plan to release
them on github initially. I'll probably do better next year ;)

My codes are written as Perl module: after working on the first few
problems, it seemed like it would be useful to reuse in the second
part of each module functions from the first part. It also seemed that
functions written in the previous days would be useful for the next
ones. Well, it then turned out that not so much; having the Intcode
computer as a separate module is enough... So here I am, with 50 `.pm`
which could have been 50 `.pl`!


I'm especially happy with the following solutions:

 - Day 25, for which I drew a pretty [map](adventofcode25-map.pdf) of
   the ship. The code itself is not particularly good, but I like the
   map!
   
 - Day 22 (part 2): I was stuck on that one for a while. I made small
   progresses and eventually figured it out; it was very
   satisfying. The [code](C22_2.pm) contains some explanations, but if
   you haven't tried it yourself, I recommend that you do!
   
 - Day 18: That's a funny one, because a somewhat obvious solution
   pops in mind quickly: Dijkstra. However, the keys make it slightly
   tricky, and using the grid as the graph to explore it way too
   expensive. I eventually figured out that I needed to compute a
   smaller graph, and store keys as power of 2. +1!
   
 - Day 16 (part 2): The last one I completed. I really had a hard time
   on that one. I tried to extract mathematical formulas to compute
   the numbers, and reduce them to something easily computable,
   without success... Until I figured that all factors formed a
   triangular matrix of 0s and 1s...
   

