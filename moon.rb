# moon.rb: makes a poster showing daily moon phases for a year.
#
# Usage: tioga moon.rb -s
#
#        better yet, use accompanying make-plots.rb to automatically
#        make several years' worth of posters
#
# Notes: lunar phase data calculated using the pyephem package by the
#        accompanying script moon.py
#
require 'Tioga/FigureMaker'
require 'Dobjects/Function'

require 'matrix'

class MyPlots

  include Math
  include Tioga
  include FigureConstants

  def t
    @figure_maker
  end

  def initialize
    @figure_maker = FigureMaker.default

    t.save_dir = 'plots'
    t.tex_preview_preamble += "\n\t\\usepackage{GaramondPremierPro}\n"

    # set some colors...
    @bg_color = MidnightBlue
    @fg_color = Cornsilk

    # ... make background a bit darker
    @bg_color = t.rgb_to_hls(@bg_color)
    @bg_color[1] *= 0.75
    @bg_color = t.hls_to_rgb(@bg_color)

    t.def_figure('poster') do
      # year for the plot (can be set externally)
      @year ||= 2015
      @file = 'data/' + @year.to_s + '.dat'

      # preliminaries
      enter_page
      t.fill_color = @bg_color
      t.fill_frame

      make_poster
    end

  end


  def enter_page
    # make individual panels for months square
    #
    $aspect_ratio = (4.0/3.0) / 0.85

    # margins around the edge
    #
    xmargin = 0.01
    ymargin = xmargin / $aspect_ratio

    t.default_frame_left   = xmargin
    t.default_frame_right  = 1.0 - xmargin
    t.default_frame_top    = 1.0 - ymargin
    t.default_frame_bottom = ymargin

    # now calculate the page size
    #
    t.default_page_width  = 72 * 10.5 # 10.5 inches

    t.default_page_height = t.default_page_width * \
      (t.default_frame_right - t.default_frame_left) / \
      (t.default_frame_top - t.default_frame_bottom) * $aspect_ratio

    t.default_enter_page_function
  end


  ##############################################################################
  # overall layout for the poster
  #
  def make_poster
    # main body of the poster
    t.subfigure('top_margin'    => 0.1,
                'bottom_margin' => 0.05) { diagram }

    # title at the top
    t.subfigure('bottom_margin' => 0.9) do
      t.show_text('x' => 0.5, 'y' => 0.5,
                  'alignment' => ALIGNED_AT_MIDHEIGHT,
                  'justification' => CENTERED,
                  'text' => "\\Huge{\\textbf{\\liningfigures{#{@year.to_s}}}}",
                  'scale' => 2.5,
                  'color' => @fg_color)
    end

    # legend at the bottom
    t.subfigure('top_margin' => 0.95) do
      t.show_text('x' => 0.5, 'y' => 1.0,
                  'alignment' => ALIGNED_AT_TOP,
                  'justification' => CENTERED,
                  'text' =>
                  '\\parbox{10in}{
\\centering
f: \\textit{full moon} \\quad
n: \\textit{new moon} \\quad
b: \\textit{blue moon} \\\\*[0.25\\baselineskip]
* denotes \\textit{friday or saturday} \\\\*[0.25\\baselineskip]
calculations done in \\textit{Pacific Standard Time}
}',
                  'scale' => 1.0,
                  'color' => @fg_color)
    end

    # hairline border
    t.stroke_color = @fg_color
    t.stroke_width = 1
    xm = 0.01
    ym = xm/$aspect_ratio
    t.append_points_to_path([xm,   1-xm, 1-xm, xm],
                            [1-ym, 1-ym,   ym, ym])
    t.close_path
    t.stroke
  end
  ##############################################################################


  ##############################################################################
  # utility functions for drawing the moon
  #
  def make_moon_shape(phase)
    # build a rotation matrix
    # (use a full 3D rotation of the terminator, just because)
    #
    beta = phase
    mat = Matrix[ [cos(-beta),   0,   -sin(-beta)],
                  [         0,   1,             0],
                  [sin(-beta),   0,    cos(-beta)] ]


    # make a circle representing the disk of the moon
    #
    npts = 100
    theta = Dvector.new(npts) {|i| 2*PI * i.to_f / (npts-1)}
    theta = theta + PI/2
    x = theta.cos
    y = theta.sin
    z = Dvector.new(npts) {|i| 0.0}


    # terminator is initially the moon-disk, for a phase of 0.  now,
    # rotate the terminator according to the phase of the moon...
    #
    new = project_line(mat, x, y, z)

    # ...take only the visible side (z<0) and sort to make a single
    # line...
    #
    new = new.select{|pt| pt[2] <= 0.0}
    new.sort_by!{|pt| -1.0*pt[1]}
    x2, y2, z2 = ary_to_dvector(new)
    _ = z2                      # annoying ruby warnings...

    # ...and close the terminator to the disk to mark the bright part of
    # the moon
    #
    theta = Dvector.new(npts/2) {|i| 2*PI * i.to_f / (npts-1)}
    if phase > PI
      theta = theta + PI/2
    else
      theta = PI/2 - theta
    end

    x3 = theta.cos
    y3 = theta.sin

    y3, x3 = Function.joint_sort(y3, x3)

    x2 = x2.concat(x3)
    y2 = y2.concat(y3)


    # return 2D paths for the moon disk and terminator
    #
    [x, y, x2, y2]
  end

  def project_point(mat, vec)
    # this notation is annoying, to make a wrapper function for it
    v = mat * Matrix.column_vector(vec)
    v.transpose.to_a.first    # wtf???
  end

  def project_line(mat, xs, ys, zs)
    # convert to a list of 3D points
    threed = Array.new
    xs.each_index do |i|
      threed << [xs[i], ys[i], zs[i]]
    end

    # project each of the points
    threed.map {|pt| project_point(mat, pt)}
  end

  def ary_to_dvector(threed)
    # convert back to separate lists of x and y
    xp = threed.map{|pt| pt[0]}
    yp = threed.map{|pt| pt[1]}
    zp = threed.map{|pt| pt[2]}

    xp = Dvector.new(xp)
    yp = Dvector.new(yp)
    zp = Dvector.new(zp)

    [xp, yp, zp]
  end
  #
  # end "utility" functions
  ##############################################################################


  ##############################################################################
  # functions to make our plot
  #
  def diagram
    # draw each of the twelve months in a 3x4 grid
    #
    for i in 1..12
      r =  (i-1)%3
      c = ((i-1)-r)/3

      t.subfigure('left_margin'   =>  r.to_f/3.0, # three columns...
                  'right_margin'  => (2.0-r)/3.0,
                  'top_margin'    =>  c.to_f/4.0, # ... and four rows
                  'bottom_margin' => (3.0-c)/4.0) do
        draw_month(i)
      end
    end
  end


  # collect data and basic layout for a single month
  #
  def draw_month(month)
    # read in data and keep the day, phase, and label for this month
    # somewhat silly to do this for every month, but who cares?
    #
    y, m, d, phase, label, weekday = Dvector.fancy_read(@file)
    _ = y                       # annoying ruby warnings...

    data = Array.new
    m.each_index do |i|
      if m[i] == month
        data << [d[i], phase[i], label[i], weekday[i]]
      end
    end

    # convert month from integer to string
    #
    month = ['January', 'February', 'March', 'April', 'May',
             'June', 'July', 'August', 'September', 'October',
             'November', 'December'][month-1]


    # now do the messy work of actually drawing the thing
    #
    draw_month_helper(month, data)
  end


  # draw out the moons for a single month
  #
  def draw_month_helper(month, data)
    t.xaxis_type = t.right_edge_type = AXIS_HIDDEN
    t.yaxis_type = t.top_edge_type   = AXIS_HIDDEN

    # shift plot coordinates slightly so that spirals look "centered"
    #
    t.show_plot([-0.925, 1.075, 1, -1]) do
      # start with a label for the month
      t.show_text('x' => 0.0, 'y' => 0.9,
                  'text'          => "\\textsw{#{month}}",
                  'color'         => @fg_color,
                  'scale'         => 2.0,
                  'alignment'     => ALIGNED_AT_TOP,
                  'justification' => RIGHT_JUSTIFIED)

      # now draw a moon for every day
      #
      full = false              # to keep track of blue moons
      data.each do |day, phase, label, weekday|
        if full and label == 1
          label = 'b'
        elsif label == 1
          label = 'f'
          full = true
        elsif label == 2
          label = 'n'
        else
          label = nil
        end
        draw_moon(day, 2*PI*phase, label, weekday)
      end
    end
  end


  # draw a single moon icon
  #
  def draw_moon(day, phase, label, weekday)

    # first get the position to draw the moon.  lay them out in a
    # logarithmic spiral, evenly spaced in distance.
    #
    a     = 0.8                 # overall scale
    b     = 0.1                 # spiral exponent
    ds    = 1.0/5.75            # spacing between moons
    scale = 0.0625              # size of the moon

    s = ds * day                # distance along spiral

    # find position corresponding to s
    #
    theta = -(1.0/b) * log(1.0-(b/a)*s)
    r     = a * exp(-b*theta)

    x0 = r * sin(theta)        # note this is transposed so that theta
    y0 = r * cos(theta)        # reads like a clock


    # paths for the moon disk and bright part
    #
    x, y, x2, y2 = make_moon_shape(phase)

    x  = scale*x  + x0
    x2 = scale*x2 + x0
    y  = scale*y  + y0
    y2 = scale*y2 + y0


    # stroke the disk and fill the bright part
    #
    old_width = t.line_width
    t.line_width = 0.25

    t.fill_color = t.stroke_color = @fg_color

    t.append_points_to_path(x, y)
    t.stroke
    t.discard_path

    t.append_points_to_path(x2, y2)
    t.fill_and_stroke
    t.discard_path

    t.line_width = old_width


    # add label, if any
    #
    t.show_text('at'            => [x0, y0],
                'text'          => "\\textbf{#{label}}",
                'alignment'     => ALIGNED_AT_MIDHEIGHT,
                'justification' => CENTERED,
                'color'         => (label == 'n') ? @fg_color : @bg_color,
                'scale'         => 0.75) if label


    # mark weekends (friday and saturday nights)
    #
    if weekday == 5 || weekday == 6
      x = (r+1.4*scale) * sin(theta-0.05)
      y = (r+1.4*scale) * cos(theta-0.05)

      t.show_marker('at'            => [x, y],
                    'marker'        => Asterisk,
                    'color'         => @fg_color,
                    'scale'         => 0.5)
    end


    # mark the day of the month
    #
    x = (r-0.11) * sin(theta+0.05)
    y = (r-0.11) * cos(theta+0.05)

    t.show_text('at'            => [x, y],
                'text'          => day.to_i.to_s,
                'alignment'     => ALIGNED_AT_MIDHEIGHT,
                'justification' => CENTERED,
                'color'         => @fg_color,
                'scale'         => 0.75)
  end

end

MyPlots.new

# Local Variables:
#   compile-command: "tioga moon.rb -s"
# End:
