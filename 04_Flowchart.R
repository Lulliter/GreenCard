
# DIsegno FLow chart (???) ---------------------------------------------------------------------
# https://mikeyharper.uk/flowcharts-in-r-using-diagrammer/ FLOWCHART
# https://rstudio-pubs-static.s3.amazonaws.com/90261_ad00e95221e14a33a50f2ebb56d34ab8.html




# Pckgs ---------------------------------------------------------------------------------------
if(!require("pacman")){
	install.packages("pacman")
}
library(pacman) # for loading packages
p_load(DiagrammeR, tidyverse, readxl, janitor, ggrepel)


diagram <- "
sequenceDiagram
  EMPLOYER-->>DOL: files labor certif application
  Note right of EMPLOYER: ETA Form 9089 etc.
  DOL->>EMPLOYER: approves
  EMPLOYER-->>USCIS: files immigrant visa petition
  Note right of DOL: Form I-140 etc.
  USCIS->>EMPLOYER: approves
  opt backlog?
  USCIS->>USCIS: depending on country/visa type: can take 10 years!!!
  end
  EMPLOYER-->>USCIS: files adjustment of status (green card)
  Note right of DOL: Form I-485 etc.
  USCIS->>FOREIGN WORKER: green card

 "

mermaid(diagram)

# cant figure out how to save



# USCIS ---------------------------------------------------------------------------------------

USCIS  <- read_excel("rawdata/USCIS-processingtime.xlsx", trim_ws = TRUE) %>%
	dplyr::filter (Form == "I-485") %>%
	dplyr::select(-Title , - 9) %>%
	clean_names() %>%
	rename( type = classification_or_basis_for_filing )

USCIS$type <- factor (USCIS$type,
							 levels = c("All Other Adjustment of Status", "Based on grant of asylum more than 1 year ago",
							 			  "Based on refugee admission more than 1 year ago", "Employment-based adjustment applications",
							 			  "Family-based adjustment applications"),
							 labels = c("All Other", "Asylum granted",
							 			  "Refugee admission", "Employment-based",
							 			  "Family-based"))

dput(levels(USCIS$type))



# Lne chart -----------------------------------------------------------------------------------
# ---- wide to  Long format
USCIS_Long <- USCIS %>%
	gather(key= "Year" , value = "I_485ProcessingTime",
			 fy_2015:fy_2019,
			 na.rm = FALSE)  %>%
	select(-form)
library(directlabels)
library(ggrepel)
# ---- plot
plot <- USCIS_Long %>%
	mutate(label = if_else(Year == "fy_2019", as.character(type), NA_character_)) %>%
	ggplot() +
	aes(x = Year,  y = I_485ProcessingTime,  color = type) +
	geom_point() +
	geom_line(aes(group = type))  +
	labs(title="USCIS Processing time for Permanent Residence Application (I-485 form)",
		  subtitle = "Since 2015, processing time increased between 30% (Asylum) - and 89% (Employment-Based)",
		  caption = "Source: USCIS",
		  x =NULL, y = "Avg N of months") +
	ggthemes::theme_hc() +
# ylim(0,13 )+
scale_y_continuous ( limits = c( 4, 13) ) +
geom_label_repel(aes(label = label),
					  #nudge_x = 1,
					  na.rm = TRUE) +

theme(legend.position = "none" )   ##  theme(text=element_text(family="Garamond", size=14))
	#facet_wrap((~ type))

plot

ggsave( plot, filename =  "USCIStime.png")

# By the way ----------------------------------------------------------------------------------
USCIS %>%
	group_by(type) %>%
	summarise(diff = (fy_2019 - fy_2015)/fy_2015*100)

# Compared to FY2015,  of processing time have increased between 30% (asylum) - and 89% (Employment-Based)
# A tibble: 5 x 2
# type               diff
# <fct>             <dbl>
# 	1 All Other          77.9
# 2 Asylum granted     28.8
# 3 Refugee admission  57.1
# 4 Employment-based   89.2
# 5 Family-based       77.3
