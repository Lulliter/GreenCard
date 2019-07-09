## Makefile to (re)run the project

# --> FROM R STUDIO (phony targets all and clean are the only targets accessible from RStudio) -----
.PHONY: all clean

all: 05_Analysis.pdf 05_Analysis.html
	echo All files are now up to date

clean:
	rm -f  dat3.Rds gg_static_region.png USCIStime.png  pie.png 05_Analysis.html 05_Analysis.pdf
	# cant re-make dat2.Rds (too long) / GC_flow.png (needs Rstudio button to save)

# --> CALL FROM SHELL ------------------------------------------------------------------------------
		# make clean
		# make all
# --> FROM RSHELL ----------------------------------------------------------------------------------

# STEPS   ------------------------------------------------------------------------------------------

# INGEST & CLEAN (because the files are so large I take don't recreate this!!)
#dat2.Rds: rawdata/Data_FY15.xlsx rawdata/Data_FY16.xlsx rawdata/Data_FY17.xlsx rawdata/Data_FY18.xlsx rawdata/Data_FY19.xlsx
#	Rscript  01_ingest-clean.R


# EXPLORATION & GROUPS' MEANS TESTING
dat3.Rds: dat2.rds R/helpers.R
	Rscript  02_explore-data.R

# GGPLOT CHARTS
gg_static_region.png: dat3.rds
	Rscript  03_HistChart_bis.R

gg_denied_region.png: dat3.rds
	Rscript  03_HistChart_bis.R

# FLOW CHARTS (NOT REALLY bc I need the button in RStudio to reproduce)
#GC_flow.png: dat3.rds
#	Rscript  04_Flowchart.R

# USCIS-processingtime CHARTS
USCIStime.png: rawdata/USCIS-processingtime.xlsx
	Rscript  04_Flowchart.R

# USCIS-processingtime CHARTS
pie.png:
	Rscript  04_Flowchart.R


# Render an HTML report
05_Analysis.html: 05_Analysis.Rmd gg_static_region.png GC_flow.png USCIStime.png pie.png
	Rscript -e 'rmarkdown::render("05_Analysis.Rmd")'

# Render an pdf report
05_Analysis.pdf: 05_Analysis.Rmd gg_static_region.png GC_flow.png USCIStime.png pie.png
	Rscript -e 'rmarkdown::render("05_Analysis.Rmd")'




#  --> EXTRA      ----------------------------------------------------------------------------------
# Automatic Variables
    # $@ refers to the target of the current rule.
    # $^ refers to the dependencies of the current rule.
    # $< refers to the first dependency of the current rule.

# EXE # Generate summary table.
#results.txt : isles.dat abyss.dat last.dat
#	python testzipf.py abyss.dat isles.dat last.dat > results.txt
#  --> becomes:
#results.txt : isles.dat abyss.dat last.dat
#	python testzipf.py $^ > $@

