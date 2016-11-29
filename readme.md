moon-poster:
============
makes a pretty lunar phase poster, useful for planning night hikes

For every day in the year, this poster shows the lunar phase and marks full and new moons, along with friday and saturday nights.
At a glance, you can use it to plan weekend full-moon hikes.

All calculates are done in the local timezone, which is pacific standard time for me.


examples:
---------

below i show an example full poster:

![full poster](./examples/full.png)

and a detail:

![August detail](./examples/detail.png)


usage:
------
Making the poster is a two-step process: first, you must generate the lunar phase data:

    python moon.py

You may need to edit the file to set the time zone or the range of years you want.

Next, you can run tioga to make the poster

    tioga moon.rb -s

Again, you will need to edit the file to set the year.
Alternatively, you can make a bunch of posters all at once:

    tioga make-plots.rb -l


colophon:
---------
The design is a blatant ripoff of something I saw at a friend's house.

I use the [pyephem](http://rhodesmill.org/pyephem/) python package to calculate lunar phases, and the wonderful [tioga](http://tioga.rubyforge.org/doc/) plotting package to lay out and typeset the poster.

The poster is typeset in the *Garamond Premier Pro* font by Robert Slimbach.
This is not included in the repo, so you may need to change the font in order to get it to compile.
