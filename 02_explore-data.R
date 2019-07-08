# Pckgs ---------------------------------------------------------------------------------------
if (!require("pacman")) {
  install.packages("pacman")
}
library(pacman) # for loading packages
p_load(
  tidyverse, readxl, writexl, here,
  ggmap, ggrepel, lazyeval, hashmap, lubridate, janitor,
  ggpubr,
  PairedData,
  # Specific to AnOVA / 2way ANOVA
  broom, car, # provides many functions that are applied to a fitted regression model
  Rmisc,
  Hmisc,
  lsmeans
)


# Functions -----------------------------------------------------------------------------------
source(here::here("R", "helpers.R"))
source(here::here("R", "ggplot-theme.R"))

# Load Clean data -----------------------------------------------------------------------------
dat2 <- readRDS(file = "dat2.rds")



# w/dplyr ----------------------------------------------------------------------------------
# Ranking -------------------------------------------------------------------------------------
# All C in  order
dat2 %>%
  group_by(COUNTRY_OF_BIRTH) %>%
  tally() %>%
  arrange(desc(n)) %>%
  .$COUNTRY_OF_BIRTH -> topxx
ranking <- dput(topxx) # useful for later in the tables

# All R in  order
dat2 %>%
  group_by(REGION_BIRTH) %>%
  tally() %>%
  arrange(desc(n)) %>%
  .$REGION_BIRTH -> toprr
ranking_R <- dput(toprr) # useful for later in the tables

# only top xx countries
dat2 %>%
  group_by(COUNTRY_OF_BIRTH) %>%
  tally() %>%
  arrange(desc(n)) %>%
  .[1:10, ] %>%
  .$COUNTRY_OF_BIRTH -> top10

dat2 %>%
  group_by(COUNTRY_OF_BIRTH) %>%
  tally() %>%
  arrange(desc(n)) %>%
  .[1:15, ] %>%
  .$COUNTRY_OF_BIRTH -> top15

dat2 %>%
  group_by(COUNTRY_OF_BIRTH) %>%
  tally() %>%
  arrange(desc(n)) %>%
  .[1:100, ] %>%
  .$COUNTRY_OF_BIRTH -> top100

# ((I use them all)) --------------------------------------------------------------------------
colnames(dat2)

# Educ By REGION
t_Reg_Ed_T <- dat2 %>%
  dplyr::group_by(REGION_BIRTH, EDUC_LEVEL) %>%
  dplyr::summarise(
    N_byRegEduc = n(),
    Perc = round(100 * N_byRegEduc / nrow(.), digits = 1),
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T)
  ) %>%
  dplyr::arrange(match(REGION_BIRTH, ranking_R), desc(N_byRegEduc))

t_Reg_Ed_T

# Educ By SPECIAL COUNTRY
t_SpecCou_Ed_T <- dat2 %>%
  dplyr::group_by(SPECIAL_COUNTRY, EDUC_LEVEL) %>%
  dplyr::summarise(
    N_bySpecCouEduc = n(),
    Perc = round(100 * N_bySpecCouEduc / nrow(.), digits = 1),
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T)
  ) %>%
  dplyr::arrange(match(SPECIAL_COUNTRY, c("TravelBan", "OtherMENA", "OtherNonMENA")), desc(N_bySpecCouEduc))

t_SpecCou_Ed_T
# very interesting that they have not been affected in terms of time

# Educ By Country
t_C_Ed_T <- dat2 %>%
  dplyr::group_by(COUNTRY_OF_BIRTH, EDUC_LEVEL) %>%
  dplyr::summarise(
    N_byCountryEduc = n(),
    Perc = round(100 * N_byCountryEduc / nrow(.), digits = 1),
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T)
  ) %>%
  dplyr::arrange(match(COUNTRY_OF_BIRTH, ranking), desc(N_byCountryEduc))

t_C_Ed_T


colnames(dat2)
# [1] "YEAR"                          "YEAR_MONTH"                    "TIMEd"
# [4] "TIMEm"                         "TIMEy"                         "ENTIRE_TERM"
# [7] "DECISION_DATE"                 "CASE_RECEIVED_DATE"            "COUNTRY_OF_CITIZENSHIP"
# [10] "CASE_STATUS"                   "COUNTRY_OF_BIRTH"              "CLASS_OF_ADMISSION"
# [13] "FOREIGN_WORKER_INFO_EDUCATION" "FOREIGN_WORKER_INFO_INST"      "EMPLOYER_NAME"
# [16] "EMPLOYER_CITY"                 "EMPLOYER_STATE"                "EMPLOYER_COUNTRY"
# [19] "EMPLOYER_POSTAL_CODE"          "EMPLOYER_NUM_EMPLOYEES"        "EMPLOYER_YR_ESTAB"
# [22] "PW_SOC_CODE"                   "PW_SOC_TITLE"                  "PW_LEVEL_9089"
# [25] "PREVAILING_WAGE"               "JOB_INFO_JOB_TITLE"            "EMPLOYER_DECL_INFO_TITLE"
# [28] "NAICS_US_CODE"                 "NAICS_US_TITLE"                "FOREIGN_WORKER_INFO_CITY"
# [31] "FOREIGN_WORKER_INFO_STATE"     "FW_INFO_POSTAL_CODE"           "WORKSITE"

# USING DPLYR
t_C_Sec_T <- dat2 %>%
  dplyr::group_by(COUNTRY_OF_BIRTH, NAICS_sect) %>%
  dplyr::summarise(
    N_byCountrySect = n(),
    Perc = round(100 * N_byCountrySect / nrow(.), digits = 1),
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T)
  ) %>%
  dplyr::arrange(match(COUNTRY_OF_BIRTH, ranking), desc(N_byCountrySect))

t_C_Sec_T



# USING DPLYR
t_C_status_T <- dat2 %>%
  dplyr::group_by(COUNTRY_OF_BIRTH, CASE_STATUS) %>%
  dplyr::summarise(
    N_byCountryStatus = n(),
    Perc = round(100 * N_byCountryStatus / nrow(.), digits = 1), # perc of cell/all
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T)
  ) %>%
  dplyr::arrange(match(COUNTRY_OF_BIRTH, ranking), desc(N_byCountryStatus))

t_C_status_T
# Very interesting to see
# INDIA	Certified-Expired	 24.5% (of all) !!!! (probably bc the follow up step with USCIS is too long)

# too beg to look but interesting
t_C_job_T <- dat2 %>%
  dplyr::group_by(COUNTRY_OF_BIRTH, PW_SOC_TITLE) %>%
  dplyr::summarise(
    N_byJob = n(),
    Perc = round(100 * N_byJob / nrow(.), digits = 1), # perc of cell/all
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T)
  ) %>%
  dplyr::arrange(match(COUNTRY_OF_BIRTH, ranking), desc(N_byJob))

t_C_job_T
# Very interesting to see
# INDIA	Certified-Expired	 24.5% (of all) !!!! (probably bc the follow up step with USCIS is too long)


# NEXT !!!!!!!!!!!!!!



# STUDY GROUPS TABLES -------------------------------------------------------------------------------

# test difference in means
# R function to compute paired t-test

# t.test(x, y, paired = TRUE, alternative = "two.sided")
# x,y: numeric vectors
# paired: a logical value specifying that we want to compute a paired t-test
# alternative: the alternative hypothesis. Allowed value is one of “two.sided” (default), “greater” or “less”.

# SUMMARY STATS BY GROUP TIME + WAGE BY REGION ...
d1 <- dat2 %>%
  dplyr::group_by(COUNTRY_OF_BIRTH) %>% # , PW_SOC_TITLE) %>%
  dplyr::summarise(
    N = n(),
    # Perc = round(100 * N_byJob / nrow(.), digits = 1), # perc of cell/all
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    sd_TIMEm = sd(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T),
    sd_WAGE = sd(PREVAILING_WAGE, na.rm = TRUE)
  )

d1
# ---> no real diff by REGION (AVGES OUT  the country diff) in Avg TIME but yes in WAGES

d2 <- dat2 %>%
  dplyr::group_by(EDUC_LEVEL) %>% # , PW_SOC_TITLE) %>%
  dplyr::summarise(
    N = n(),
    # Perc = round(100 * N_byJob / nrow(.), digits = 1), # perc of cell/all
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    sd_TIMEm = sd(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T),
    sd_WAGE = sd(PREVAILING_WAGE, na.rm = TRUE)
  )

d2
# ---> slight diff by EDUC LEVEL  in Avg TIME but YEEEEEAAAAS  in WAGES


d3 <- dat2 %>%
  dplyr::group_by(SPECIAL_COUNTRY, EDUC_LEVEL) %>% # , PW_SOC_TITLE) %>%
  dplyr::summarise(
    N = n(),
    # Perc = round(100 * N_byJob / nrow(.), digits = 1), # perc of cell/all
    AvgTIMEm = mean(TIMEm, na.rm = TRUE),
    sd_TIMEm = sd(TIMEm, na.rm = TRUE),
    AvgWAGE = mean(PREVAILING_WAGE, na.rm = T),
    sd_WAGE = sd(PREVAILING_WAGE, na.rm = TRUE)
  )

d3
# ---> TravelBan actually the shortest time !!! although with smallest Avg WAGE

# Compute paired samples t-test (BAN OR NOT) ---------------------------------------------------------------
dat2$SPECIAL_COUNTRY <- as.factor(dat2$SPECIAL_COUNTRY)
dat2$BAN_COUN <- dat2$SPECIAL_COUNTRY


# Dummy for Travel Ban Country
dat2$BAN_COUN <- if_else(dat2$SPECIAL_COUNTRY == "TravelBan", "TravelBan", "Other")
dat2$BAN_COUN <- as.factor(dat2$BAN_COUN)
levels(dat2$BAN_COUN)
skimr::n_missing(dat2$BAN_COUN)


# Measn testing  ------------------------------------------------------------------------------
res_t <- t.test(TIMEm ~ BAN_COUN, data = dat2, paired = F)
res_t
# the avg time is signif different but Ban is LOWER !!!!! (5.168018 < 5.852815 )

res_t <- t.test(PREVAILING_WAGE ~ BAN_COUN, data = dat2, paired = F)
res_t
# the avg wage is signif different & Ban is LOWER !! ... maybe diff mix edcu  (75237.95  < 88321.14  )

# #  Groups:   SPECIAL_COUNTRY [3]
# SPECIAL_COUNTRY EDUC_LEVEL            N AvgTIMEm sd_TIMEm AvgWAGE sd_WAGE
# <chr>           <fct>             <int>    <dbl>    <dbl>   <dbl>   <dbl>
# 	1 OtherMENA       None                639     6.57     8.60  59903.  38022.
# 2 OtherMENA       HighSchool_Other   1114     5.11     6.94 119463.  57333.
# 3 OtherMENA       Graduate           2623     5.53     6.39  97572. 122451.
# 4 OtherMENA       PostGraduate       3002     5.38     5.47  92595.  33111.
# 5 OtherNonMENA    None              40652     7.44     8.98  35670.  67007.
# 6 OtherNonMENA    HighSchool_Other  27300     6.40     8.66  80875.  91290.
# 7 OtherNonMENA    Graduate         173409     5.82     7.28  95334. 949635.
# 8 OtherNonMENA    PostGraduate     218628     5.52     6.16  92740. 464211.
# 9 TravelBan       None               1331     5.88     5.22  21050.  13383.
# 10 TravelBan       HighSchool_Other    778     5.08     5.10  98510.  59429.
# 11 TravelBan       Graduate            695     5.08     6.13  83906.  33890.
# 12 TravelBan       PostGraduate       2503     4.84     4.21  93483. 318413.


# Compute paired samples t-test (OBAMA vs TRUMP) ---------------------------------------------------------------
temp <- dat2 %>% filter(ENTIRE_TERM != "MIXED")


table(dat2$ENTIRE_TERM)
res_tr <- t.test(TIMEm ~ ENTIRE_TERM, data = temp, paired = F)
res_tr
# the TIMEm is signif different & OBAMA is HIGHER !! ... maybe diff mix edcu  (75237.95  < 88321.14  )
            # sample estimates:
            #   mean in group OBAMA_cmp     mean in group TRUMP
            # 6.741115                3.872758

# Can it be because more were denied? {NOPE}
temp %>%
  dplyr::group_by(ENTIRE_TERM) %>%
  dplyr::summarise(
    N = n(),
    NDeni = sum(CASE_STATUS == "Denied"),
    PercDeni = sum(CASE_STATUS == "Denied") / n() * 100
  )


class(dat2$EDUC_LEVEL)
class(dat2$SPECIAL_COUNTRY)
class(dat2$REGION_BIRTH)
dat2$REGION_BIRTH <- as.factor(dat2$REGION_BIRTH)



# <5000 sample --------------------------------------------------------------------------------

# using function stratified to get a 5000 sample
source(here::here("R", "stratified_samples.R"), echo = T, prompt.echo = "") # ,  spaced = F)
dat_sample <- dat2 %>%
  # Take a sample of <5000
  stratified("COUNTRY_OF_BIRTH", 0.01)

# 1-WAY ANOVA ---------------------------------------------------------------------------------
# Multiple pairwise-comparison between the n>1 groups’ means ANOVA {levels of 1 cat var --> }
# --------------------------------

# ==== Group by group across REGION_BIRTH
# --------One-Way ANOVA F-Test {REGION, TIME}
# Show the levels
levels(dat2$REGION_BIRTH)

# #Test for homogeneity of variances by groups
car::leveneTest(TIMEm ~ REGION_BIRTH, data = dat2)
# Compared to the Bartlet test
bartlett.test(TIMEm ~ REGION_BIRTH, data = dat2)
# SHAPIRO_WILK TEST FOR NORMALITY----
# turn off scientific notaton
options(scipen = 999) #  to turn back on options(scipen = 0)

# Test for normality of each group and store in shapirowilktests
# This uses the broom package to get clean output of the test
dat2 %>%
  group_by(REGION_BIRTH, EDUC_LEVEL) %>%
  # test
  tidy(shapiro.test(.$TIMEm)) # ERROR
dat_sample %>%
  group_by(REGION_BIRTH, EDUC_LEVEL) %>%
  # test
  tidy(shapiro.test(.$TIMEm)) # ERROR

aov1 <- aov(TIMEm ~ REGION_BIRTH, data = dat2)
summary(aov1) # diff between the groups significant at 0.001
# Tukey multiple pairwise-comparisons for post-hoc comparison
TukeyRes <- stats::TukeyHSD(aov1, ordered = F)
# ==== Show table
# OR
# TukeyResTukeyRes[1:1] #
# TukeyRes_df <- as.data.frame(TukeyRes$REGION_BIRTH)
TukeyRes_df <- broom::tidy(TukeyRes) %>%
  dplyr::select(-term) %>%
  arrange(desc(estimate))

# # ==== Display
caption <- "Pairwise-comparison between the TIME means of groups (REGION_BIRTH)"
TukeyRes_df_table <- pander::pandoc.table.return(TukeyRes_df,
  keep.line.breaks = T,
  style = "simple",
  justify = "lrrrr",
  caption = caption,
  split.table = Inf
)
cat(TukeyRes_df_table)

# --------One-Way ANOVA F-Test {REGION, WAGE}
# Show the levels
levels(dat2$REGION_BIRTH)
aov2 <- aov(PREVAILING_WAGE ~ REGION_BIRTH, data = dat2)
summary(aov2) # diff between the groups significant at 0.001

# ANOVA test is significant --> Tukey multiple pairwise-comparisons for post-hoc comparison
TukeyRes2 <- stats::TukeyHSD(aov2, ordered = F)


# ==== Show table
# OR
# TukeyResTukeyRes[1:1] #
# TukeyRes2_df <- as.data.frame(TukeyRes2$REGION_BIRTH) # %>% 	dplyr::arrange(desc(.$diff))
TukeyRes2_df <- broom::tidy(TukeyRes2) %>%
  dplyr::select(-term) %>%
  arrange(desc(estimate))


# # ==== Display
caption <- "Pairwise-comparison between the WAGE means of groups (REGION_BIRTH)"
colnames(TukeyRes2_df)

TukeyRes2_df_table <- pander::pandoc.table.return(TukeyRes2_df,
  keep.line.breaks = T,
  style = "simple",
  justify = "lrrrr",
  caption = caption,
  split.table = Inf
)

cat(TukeyRes2_df_table)



# ------------------------------------------------------------------------------------------
# TWO-WAY ANOVA  ------------------------------------------------------------------------------
# https://wlperry.github.io/2017stats/05_6_twowayanova.html
# https://www.zoology.ubc.ca/~schluter/R/fit-model/
# -------------------------------------------------------------------------------------------


# get statistics with `Rmisc`
summary <- summarySE(dat2,
  measurevar = "TIMEm",
  groupvars = c("REGION_BIRTH", "REGION_BIRTH")
)
class(summary)

# PLOT WITH 2 CATEG ????
boxplot(TIMEm ~ REGION_BIRTH:REGION_BIRTH,
  data = dat2, # WHA TI JUST GOT
  xlab = "BOTH",
  ylab = "process length (m)"
)

# This will generate two plots to compare groups according to the
# and examine interactions
# par(mfrow=c(1,3)) could use this to make multiple per page but is not great
interaction.plot(dat2$REGION_BIRTH, dat2$EDUC_LEVEL, dat2$TIMEm)
interaction.plot(dat2$EDUC_LEVEL, dat2$REGION_BIRTH, dat2$TIMEm)

# THE TWO WAY AOV----
# 1/2 {car} -----------------------------------------------------------------------------------------
# Type III is used for unbalanced designs when there are unequal numbers of samples in teh various categories or groups which is an unbalanced design
# Type I, - sequential  SS
# Type II  - tests for each main effect after the other main effect
# Type III - This type tests for the presence of a main effect after the other main effect and interaction
# 					SS(A | B, AB) for factor A.
# 					SS(B | A, AB) for factor B.




# Fit the linear model and conduct ANOVA {WHY ON THE LN MOD ????}
modelI <- lm(TIMEm ~ SPECIAL_COUNTRY * EDUC_LEVEL, data = dat_sample) # <5000 for shapiro test to work

# --------- THIS WILL DO A TYPE I ANOVA
stats::anova(modelI)

# --------- THIS WILL DO A TYPE III ANOVA {car}
# ... bc data is unbalanced here
modelIII <- lm(TIMEm ~ SPECIAL_COUNTRY * EDUC_LEVEL, data = dat_sample) # <5000 for shapiro test to work

# `car`
car::Anova(modelIII, type = 2) # Use type="III" ALWAYS!!!!
car::Anova(modelIII, type = 3, contrasts = list(topic = contr.sum, sys = contr.sum)) # Use type="III" ALWAYS!!!!
summary(modelIII) # Produces r-square, overall p-value, parameter estimates

# ---- CHECKING ASSUMPTIONS
hist(residuals(modelIII)) # should be normal but they are not!!!!
# Graphic test for normal residuals
stats::qqnorm(modelIII$res)
# test for normality—-
shapiro.test(modelIII$res) # OK
# plot of residuals
plot(modelIII, 1) #  The residuals should be unbiased and homoscedastic.


# #Test for homogeneity of variances by groups
car::leveneTest(TIMEm ~ SPECIAL_COUNTRY * EDUC_LEVEL, data = dat2)

# POST HOC ANALYSIS
lsmseason <- pairs(lsmeans::lsmeans(modelIII, "EDUC_LEVEL"), adjust = "bonferroni") ### Means sharing a letter in .group are not significantly different when more than one categorical varaible
# cld(lsmseason,
#     alpha=.05,
#     Letters=letters)

test(lsmseason)

# POST HOC ANALYSIS
lsmseason2 <- pairs(lsmeans(modelIII, "SPECIAL_COUNTRY"), adjust = "bonferroni") ### Means sharing a letter in .group are not significantly different when more than one categorical varaible
# cld(lsmseason,
#     alpha=.05,
#     Letters=letters)

test(lsmseason2)

# 2/2 {stats}----------------------------------------------------------------------------------------
# Comparing means with a two-factor ANOVA SPECIAL_COUNTRY*EDUC_LEVEL
# Model with interaction
aovTWO <- aov(TIMEm ~ SPECIAL_COUNTRY * EDUC_LEVEL, data = dat2)
summary(aovTWO)
# Additional information on model
model.tables(aovTWO)
model.tables(aovTWO, type = "means")
model.tables(aovTWO, type = "effects") # "effects" is default

# the broom tidy way ...
tidy(aovTWO)
aovTWO$effects
# Post-hoc test
TukeyHSD(aov1)


# Get an Idea...
boxplot(TIMEm ~ SPECIAL_COUNTRY * EDUC_LEVEL, data = dat2)
# really there is not much


# Visualize Anova (one WAY) -------------------------------------------------------------------


# ggpubr --------------------------------------------------------------------------------------
# ----- PALETTE of 3 divergent colors
cols_div_7 <- c(colorRampPalette(RColorBrewer::brewer.pal(8, "Dark2"))(8)) # [c(1, 4, 8)])
cols_div_7
# ----- PALETTE of 5 sequential values in the blue palette so it is not too clear
cols_blue_seque <- c(colorRampPalette(RColorBrewer::brewer.pal(9, "Blues"))(6)[3:7])
cols_blue_seque



# ggboxplot(dat2, x = "SPECIAL_COUNTRY"*"EDUC_LEVEL", y = "TIMEm",
# 			 color = "REGION_BIRTH",   palette = cols_div_7 ,
# 			 order = ranking_R,
# 			 ylab = "TIMEm", xlab = "REGION_BIRTH")




# Plot weight by group and color by group
# ggdensity(dat2,  x = "TIMEm", # this time is x
# 			 add = "mean", rug = TRUE,
# 			 color = "REGION_BIRTH",   fill ="REGION_BIRTH", palette =  cols_div_7 ,
# 			 order = ranking_R,
# 			 ylab = "TIMEm", xlab = "REGION_BIRTH")


ggboxplot(dat2,
  x = "REGION_BIRTH", y = "TIMEm",
  color = "REGION_BIRTH", palette = cols_div_7,
  order = ranking_R,
  ylab = "TIMEm", xlab = "REGION_BIRTH"
)


# AND WITH PAIRWISE COMPARISON !!!!!
regions <- dput(levels(as.factor(dat2$REGION_BIRTH)))
dput(combn(regions[1:7], 2))


bp <- ggboxplot(dat2,
  x = "REGION_BIRTH", y = "TIMEm",
  color = "REGION_BIRTH", palette = cols_div_7,
  order = ranking_R,
  ylab = "TIME of certif in m", xlab = ""
)
bp
# Add p-values comparing groups

# Specify the comparisons you want
my_comparisons <- list(
  c("SouthAsia", "LatAm & Caribb"),
  c("SouthAsia", "NorthAmerica"),
  c("Europe & CentrAsia", "SouthAsia"),
  c("Europe & CentrAsia", "LatAm & Caribb")
)

bp + stat_compare_means(comparisons = my_comparisons, label = "p.signif") + # Add pairwise comparisons p-value
  stat_compare_means(label.y = 50) # Add global p-value



# Violin plots with box plots inside
# :::::::::::::::::::::::::::::::::::::::::::::::::::
# Change fill color by groups: region

ggviolin(dat2,
  x = "REGION_BIRTH", y = "TIMEm", fill = "REGION_BIRTH",
  palette = cols_div_7
) +
  stat_compare_means(comparisons = my_comparisons, label = "p.signif") + # Add significance levels
  stat_compare_means(label.y = 50)




# Some EXPLOR PLOTS ---------------------------------------------------------------------------

# Generic ggplot graphics configuration I will be using for all my plots
# get_theme <- function() {
# 	return(theme(axis.title = element_text(size = rel(1.5)),
# 					 legend.position = "bottom",
# 					 legend.text = element_text(size = rel(1.5)),
# 					 legend.title = element_text(size=rel(1.5)),
# 					 axis.text = element_text(size=rel(1.5))))
# }

# Avoid scientific notation in plot
options(scipen = 999)

# g <- ggplot(data = dat2, aes(x=YEAR, y = PREVAILING_WAGE))
# g <- g + geom_boxplot(aes(fill=EMPLOYER_STATE)) + coord_cartesian(ylim=c(0,125000))
# g <- g + xlab("YEAR") + ylab("WAGE (USD)") + get_theme()
#
# g

# In this sub-section, I analyze employers with high number of applications. Let's begin by finding out the top 10 employers with the most number of applications in the period 2011-2016.
#
# It might occur that Employer Names takes most of the space leaving almost little for the actual plot. For this purpose, I cut short Employer names to only the first word in their title. An another approach might be reducing the axis.text size for ggplot2.



# Stack plots ---------------------------------------------------------------------------------


# N_ARRIVED  REGION BIRTH per year
# Using     plot_input <- function(df, x_feature, fill_feature, metric,filter = FALSE, ...)
input <- plot_input(dat2, "YEAR", "REGION_BIRTH", "TotalApps", filter = TRUE, Ntop = 10)
# Using    plot_output <- function(df, x_feature,fill_feature,metric, xlabb,ylabb)
g <- plot_output(input, "YEAR", "REGION_BIRTH", "TotalApps", "", "TOTAL NO. of APPLICATIONS") +
  my_theme
# theme(axis.title = element_text(size = rel(1.5)),
# 		axis.text.y = element_text(size=rel(0.85),face="bold"))
g

# TIME REGION BIRTH per year
input <- plot_input(dat2, "YEAR", "REGION_BIRTH", "Time_med_d", filter = TRUE, Ntop = 10)
g2 <- plot_output(input, "YEAR", "REGION_BIRTH", "Time_med_d", "", "Median Time in d") +
  my_theme
g2

# case Status
# case status per year
input <- plot_input(dat2, "YEAR", "CASE_STATUS", "TotalApps", filter = TRUE, Ntop = 10)

# Using    plot_output <- function(df, x_feature,fill_feature,metric, xlabb,ylabb)
g <- plot_output(input, "YEAR", "CASE_STATUS", "TotalApps", "", "TOTAL NO. of APPLICATIONS") +
  my_theme
# theme(axis.title = element_text(size = rel(1.5)),
# 		axis.text.y = element_text(size=rel(0.85),face="bold"))
g

# occupation LEVEL per year
input <- plot_input(dat2, "YEAR", "PW_LEVEL_9089", "Time_med_d", filter = TRUE, Ntop = 10)

g <- plot_output(input, "YEAR", "PW_LEVEL_9089", "Time_med_d", "", "Median Time in d") +
  my_theme
# theme(axis.title = element_text(size = rel(1.5)),
# 		axis.text.y = element_text(size=rel(0.85),face="bold"))
g

dat3 <- dat2
saveRDS(dat3, file = "dat3.Rds")

dat3$NAICS_sect <- as.factor(dat3$NAICS_sect)

levels(dat3$NAICS_sect)
# Class of admission
class <- dat3 %>%
  # dplyr::group_by(.$COUNTRY_OF_BIRTH) %>%
  dplyr::summarise( n = sum(CASE_STATUS %in% c( "Certified-Expired", "Certified" )),
                    Hib = sum(CLASS_OF_ADMISSION %in% c("H-1B")),
                    PercH1B = Hib/n*100 ,
                    PstGR = sum(EDUC_LEVEL == "PostGraduate"),
                    PstGRperc = PstGR/n*100,
                     GR = sum(EDUC_LEVEL == "Graduate"),
                     GRperc = GR/n*100 ,
                    Pultry = sum( grepl("Poultry",JOB_INFO_JOB_TITLE,    ignore.case = T)  ) ,
                    PoultryPerc = Pultry/n*100,
                    Software = sum( grepl("Software",JOB_INFO_JOB_TITLE,    ignore.case = T)  ) ,
                    SoftwarePerc = Software/n*100)




(NAICS_sect <- dat3 %>%
     	group_by(NAICS_sect) %>%
     	tally() %>%   arrange(desc(n)) %>% .[1:50,] %>% .$NAICS_sect)

(JOB_INFO_JOB_TITLE <- dat3 %>%
    group_by(JOB_INFO_JOB_TITLE) %>%
    tally() %>%   arrange(desc(n)) %>% .[1:50,] %>% .$JOB_INFO_JOB_TITLE)
