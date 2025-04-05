#!/usr/bin/python
#
# moon.py: calculates lunar data for making the poster
#
# Usage: python moon.py
#
# Notes:
#   1. Made using pyephem 3.7.6.0 and python 2.7.10
#   2. I think the calculations are correct, but don't use this
#      package regularly.
#
import datetime
import ephem

# returns lunar age as a fraction of the phase: 0=new, 0.5=full, 1=new
#
def phase_on_day(date):
  nnm = ephem.next_new_moon(date)
  pnm = ephem.previous_new_moon(date)

  lunation = (date-pnm)/(nnm-pnm)

  return lunation


# make the data needed for our calendar
#
def moons_in_year(year):
  moons=[]

  # loop over days in the year:
  #
  date = ephem.Date(datetime.date(year,1,1))
  while date.datetime().year == year:
      y, m, d, h, min, s = date.tuple()
      weekday = (date.datetime()).isoweekday()
      phase = phase_on_day(date)

      # now determine whether the moon is new of full
      label = 0

      nfm = ephem.next_full_moon(date)
      nfm = ephem.localtime(nfm)

      if nfm.day == d and nfm.month == m:
          label = 1             # full

      nnm = ephem.next_new_moon(date)
      nnm = ephem.localtime(nnm)

      if nnm.day == d and nnm.month == m:
          label = 2             # new

      moons.append( (y, m, d, phase, label, weekday) )
      date = ephem.date(date + 1.0)

  return moons


# write data to a nicely-formatted file
#
def write_year(year):
    data = moons_in_year(year)

    thefile = open('data/{0}.dat'.format(year), 'w')

    thefile.write("# [1] = year, [2] = month, [3] = day, [4] = lunar phase,\n")
    thefile.write("# [5] = label (1 = full, 2 = new), \n")
    thefile.write("# [6] = day of week (1 = monday, 7 = sunday) \n")
    thefile.write("# \n")
    thefile.write("# calculated in PST using the pyephem package.\n")
    thefile.write("# \n")

    for item in data:
        thefile.write("%d\t%d\t%d\t%f\t%d\t%d\n" % item)


# for i in range(2015,2026):
#     print i
#     write_year(i)

for i in range(2025,2101):
    print(i)
    write_year(i)


# Local Variables:
# compile-command: "python moon.py"
# End:
