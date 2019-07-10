# Project Title

"Employment-based green card process getting longer to complete" 

Study based on DOL/OFLC and USCIS data to vrify whether the Trump administration has slowed down the green card application process for foreign workers?

## Author

**Luisa M. Mimmi**  

<!-- ## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
 -->
 
## Project Structure
The analysis can be reproduced running in sequence the R scripts `01_*`:`04_*` which will generate the charts `gg_*` and clean daata files `dat*.Rds`. Then `05_Analysis.Rmd` should compile the article as html and PDF. 
In alternative, use `makefile` executing in terminal the command `make all`. 

	├── 01_ingest-clean.R
	├── 02_explore-data.R
	├── 03_certification-charts.R
	├── 04_flowchart.R
	├── 05_Analysis.Rmd
	├── 05_Analysis.html
	├── 05_Analysis.md
	├── 05_Analysis.pdf
	├── GC_flow.png
	├── GreenCard.Rproj
	├── R/
	├── dat2.rds
	├── dat3.Rds
	├── gg_USCIStime.png
	├── gg_denied_region.png
	├── gg_pie.png
	├── gg_static_region.png
	├── gg_top15country.png
	├── gg_top2.png
	├── makefile
	├── rawdata/
 
## Acknowledgments
Below are the sources of datasets, R code chunks, and other interesting articles that served as inputs or inspiration for this analysis.

##### Data
+ [OFLC Disclosure Data: Labor Certifications for Permanent Residents](https://www.foreignlaborcert.doleta.gov/performancedata.cfm)
+ [USCIS: Processing time averages 2015-2019](https://egov.uscis.gov/processing-times/historic-pt)
+ [Migration Policy Institute: Refugees and Asylees](https://www.migrationpolicy.org/article/refugees-and-asylees-united-states#Adjusting_to_Lawful_Permanent_Resident_Status)


##### Reference
+ [National Law Review: on USCIS Reports on Lagging Processing Times](https://www.natlawreview.com/article/uscis-reports-lagging-processing-times)
+ [CATO Institute: on Immigration Wait Times and Green Card Backlogs](https://www.cato.org/publications/policy-analysis/immigration-wait-times-quotas-have-doubled-green-card-backlogs-are-long#full)

##### Inspiring open source R projects
+ [Bill Perry: Two-way ANOVA in R](https://wlperry.github.io/2017stats/05_6_twowayanova.html)
+ [Sharan Naribole: Data Exploration on H-1B Visa dataset](https://github.com/sharan-naribole/H1B_visa_eda)
+ [Fabio Votta: article on refugees and great data viz](https://favstats.eu/post/exploring_us_refugee_data/)
+ [Paul Williamson: Custom `crosstab` function](http://rstudio-pubs-static.s3.amazonaws.com/6975_c4943349b6174f448104a5513fed59a9.html)
