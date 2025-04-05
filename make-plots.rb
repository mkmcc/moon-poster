# make-plots.rb: automatically makes posters for a range of years
#
# Usage: tioga make-plots.rb -l
#
# Notes: requires you to have already run moon.py to generate the data
#
require 'Tioga/FigureMaker'
require './moon.rb'

class MyPlots
  def run
    t.save_dir = 'moon-posters'

    #for i in 2015..2025
    for i in 2036..2100
      puts i
      @year = i

      fig_number = 0
      t.make_pdf(fig_number)

      pdf_name = t.figure_pdf(fig_number)
      dir = File.dirname(pdf_name)
      cmd = "mv #{pdf_name} #{dir}/#{i.to_s}.pdf"
      system(cmd)
    end
  end
end


MyPlots.new.run
