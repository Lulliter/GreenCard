# https://github.com/favstats/usa_refugee_data

# My graph

pacman::p_load(tidytemplate, ggplot2)

# Historic areas ------------------------------------------------------------------------------
admissions75 <- tidytemplate::load_it("data/admissions75.Rdata")

# year_lab <- paste0("'", stringi::stri_sub(1975:2018, -2 , -1))

year_lab <- seq(1977, 2017, 4)

year_dat <- tibble(fiscal_year = c(seq(1976, 2016, 4)),
						 label = c("Carter I", "Reagan I", "Reagan II",
						 			 "H.W. Bush I", "Clinton I", "Clinton II", "Bush I",
						 			 "Bush II", "Obama I", "Obama II", "Trump I"))

n_refugee_2018 <- admissions75 %>%
	filter(fiscal_year == 2018) %>%
	summarize(n = sum(n)) %>%
	.$n

n_refugee_2002 <- admissions75 %>%
	filter(fiscal_year == 2002) %>%
	summarize(n = sum(n)) %>%
	.$n

n_refugee_1992 <- admissions75 %>%
	filter(fiscal_year == 1992) %>%
	summarize(n = sum(n)) %>%
	.$n

n_refugee_1980 <- admissions75 %>%
	filter(fiscal_year == 1980) %>%
	summarize(n = sum(n)) %>%
	.$n

n_refugee_1975 <- admissions75 %>%
	filter(fiscal_year == 1975) %>%
	summarize(n = sum(n)) %>%
	.$n

admissions75 %>%
	summarize(n = sum(n)) %>%
	.$n


admissions75 %>%
	mutate(region = case_when(
		region == "Former\rSoviet\rUnion" ~ "(Former) Soviet Union",
		region == "Latin America\rCaribbean" ~ "Latin America/Caribbean",
		region == "Near East\rSouth Asia" ~ "Near East/South Asia",
		region == "PSI" ~ "Private Sector Initiative",
		T ~ region
	)) %>%
	ggplot(aes(fiscal_year, n))  +
	geom_vline(data = year_dat, aes(xintercept = fiscal_year + 1), alpha = 0.35) +
	geom_label(data = year_dat, aes(x = fiscal_year + 1, y = 220000, label = label),
				  angle = 0, color = "black") +
	geom_area(aes(fill = region), alpha = 0.9) +
	geom_hline(yintercept = n_refugee_2018,
				  linetype = "dashed", color = "black", alpha = 0.85) +
	annotate("label", x = 1978, y = 115000,
				fill = "lightgrey", alpha = 0.85, label.size = NA,
				label = "End of\n Vietnam War") +
	annotate("label", x = 1984, y = 185000,
				fill = "lightgrey", alpha = 0.85, label.size = NA,
				label = "Refugee Act of 1980") +
	annotate("label", x = 1997, y = 150000,
				fill = "lightgrey", alpha = 0.85, label.size = NA,
				label = "Fall of Soviet Union") +
	annotate("label", x = 2000, y = 105000,
				fill = "lightgrey", alpha = 0.85, label.size = NA,
				label = "Drop after 9/11") +
	annotate("label", x = 2015, y = 110000,
				fill = "lightgrey", alpha = 0.85, label.size = NA,
				label = "Number of Refugees in 2018\n lowest since 1977") +
	theme_minimal() +
	scale_y_continuous(labels = scales::comma) +
	scale_fill_manual("Region", values = qualitative) +
	geom_curve(aes(x = 1977, y = 125000, xend = 1975, yend = n_refugee_1975),
				  arrow = arrow(length = unit(0.03, "npc")), curvature = 0.2) +
	geom_curve(aes(x = 1982, y = 190000, xend = 1980, yend = n_refugee_1980),
				  arrow = arrow(length = unit(0.03, "npc")), curvature = 0.2) +
	geom_curve(aes(x = 1994, y = 150000, xend = 1992, yend = n_refugee_1992),
				  arrow = arrow(length = unit(0.03, "npc")), curvature = 0.2) +
	geom_curve(aes(x = 2000, y = 100000, xend = 2002, yend = n_refugee_2002),
				  arrow = arrow(length = unit(0.03, "npc")), curvature = -0.3) +
	geom_curve(aes(x = 2016, y = 100000, xend = 2018, yend = n_refugee_2018),
				  arrow = arrow(length = unit(0.03, "npc")), curvature = -0.2) +
	theme(plot.title = element_text(size = 13, face = "bold"),
			# plot.subtitle = element_text(size = 11, face = "bold"),
			plot.caption = element_text(size = 10, face = "italic", hjust = 1),
			legend.key.width = unit(3, "line"),
			legend.position = "bottom") +
	scale_x_continuous(breaks = year_lab, labels = year_lab,
							 minor_breaks = seq(1975, 2018, 1)) +
	labs(x = "", y = "Number of Refugees\n",
		  title = "Refugees arriving in the United States of America by Year (1975 - 2018)\n",
		  caption = "\nData: State Department, Office of Admissions - Refugee Processing Center. Total Number of Accepted Refugees since 1975: 3.340.709; Visualization: @favstats")

ggsave(filename = "images/refugee75.png", height = 7, width = 13)




# ## Animated ---------------------------------------------------------------------------------

# 1/2 data ------------------------------------------------------------------------------------
refugee_dat <- read_excel("data/refugee_dat.xls", skip = 1) %>%
	#drop_na(X__1) %>%
	drop_na("...1") %>%
	rename(cntry = "...1") %>%
	select(-Religion, -"...9", -"...15", - Total) %>%
	filter(!(str_detect(cntry, "Total|Data"))) %>%
	gather(year, n, -cntry) %>%
	mutate(year = str_replace(year, "CY ", "") %>% as.numeric)

refugee_dat %>% group_by(cntry) %>% tally() %>% arrange(desc(nn)) %>% .[1:10,] %>% .$cntry -> top10

year_dat <- tibble(year = c(2005, 2009, 2013, 2017), label = c("Bush II", "Obama I", "Obama II", "Trump I"))

qualitative <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6','#6a3d9a')

n_refugee_total <- refugee_dat %>% use_series(n) %>% sum

refugee_dat %>%
	filter(str_detect(cntry, "Burma"))


read_excel("data/refugee_dat.xls", skip = 1) %>%
	tidyr::fill(X__1) %>%
	# filter(X__1 == "Burma") %>%
	rename(religion = Religion, cntry = X__1) %>%
	drop_na(religion) %>%
	# filter(!(str_detect(cntry, "Total|Data"))) %>%

	# group_by(religion, year) %>%
	# mutate(n = sum(n)) %>%
	mutate(religion_cat = case_when(
		str_detect(religion, "Moslem|Ahmadiyya") ~ "Muslim",
		str_detect(religion, "Christ|Baptist|Chald|Coptic|Greek|Jehovah|Lutheran|Mennonite|Orthodox|Pentecostalist|Protestant|Uniate|Adventist|Cath|Meth|Old Believer") ~ "Christian",
		str_detect(religion, "Atheist|No Religion") ~ "Atheist/No Religion",
		religion == "Hindu" ~ "Hindu",
		T ~ "Other/Unknown"
	)) %>%
	select(-X__2, -X__3, -Total, -religion) %>%
	gather(year, n, -religion_cat, -cntry) %>%
	mutate(year = str_replace(year, "CY ", "") %>% as.numeric) %>%
	group_by(religion_cat, cntry, year) %>%
	summarise(n = sum(n)) %>%
	ungroup() %>%
	filter(religion_cat == "Christian", year %in% 2016:2018) %>%
	arrange(desc(n)) %>%
	group_by(year) %>%
	mutate(total = sum(n)) %>%
	arrange(year)


# 2/2 plot ------------------------------------------------------------------------------------

library(gganimate)
load("R/refugee_dat.Rdata")
gg_refugee <- refugee_dat %>%
	filter(cntry %in% top10) %>%
	ggplot(aes(year, n, color = cntry)) +
	geom_vline(data = year_dat, aes(xintercept = year), alpha = 0.15) +
	geom_label(data = year_dat, aes(x = year, y = 22000, label = label),
				  angle = 0, color = "black") +
	geom_line() +
	geom_segment(aes(xend = 2018, yend = n), alpha = 0.5) +
	geom_point() +
	geom_text(aes(x = 2019, label = cntry)) +
	theme_minimal() +
	scale_color_manual("Country", values = qualitative) +
	theme(plot.title = element_text(size = 13, face = "bold"),
			plot.subtitle = element_text(size = 12, face = "bold"),
			plot.caption = element_text(size = 10),
			legend.position = "bottom") +
	scale_x_continuous(breaks = 2002:2018, labels = 2002:2018,
							 minor_breaks = seq(2002, 2018, 1)) +
	labs(x = "", y = "Number of Refugees\n",
		  title = "Refugees arriving in the United States of America by Year (2002 - 2018)", subtitle = "Top 10 Origin Countries\n",
		  caption = "Data: Department of State, Office of Admissions - Refugee Processing Center\nfavstats.eu; @favstats")  +
	guides(color = F, text = F) +
	#transition_reveal(cntry, year, keep_last = T)
	transition_reveal( along = year,   keep_last = T)

gg_refugee %>% animate(
	nframes = 500, fps = 15, width = 1000, height = 600, detail = 1
)

anim_save("images/gg_refugee.gif")
