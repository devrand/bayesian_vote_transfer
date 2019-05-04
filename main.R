#
# Attempt to solve voter's transfer problem between first and second round of election 
# using detailed data from voting station and bayesian regression 
# (c) @dvrnd, 2019
# see also http://texty.org.ua/pg/article/devrand/read/93486

library(readr)
library(dplyr)

# load data from Ukrainian presidential election-2019, first round 
elections_t1 <- read_delim("data/elections_t1.tsv", 
                           "\t", escape_double = FALSE, trim_ws = TRUE)
# second
elections_t2 <- read_delim("data/elections_t2.tsv", 
                           "\t", escape_double = FALSE, trim_ws = TRUE)


# process the data, first round
df1 <- elections_t1 %>%
  select(1,3, 10:50, ncol(.)) %>%
  mutate(accepted_votes = .[[3]] - .[[4]], reserve = .[[2]] - .[[3]] ) %>%
  select(1,2, 5:ncol(.) ) 

# re-arrange columns
df1 <- df1[, c(1, 2, ncol(df1)-2, ncol(df1)-1, ncol(df1), 3:(ncol(df1)-3)  )]


# process the data, second round
df2 <- elections_t2 %>%
  select(1,3, 10:13, ncol(.)) %>%
  mutate(accepted_votes = .[[3]] - .[[4]]) %>%
  select( c(-4) ) 

# re-arrange columns  
df2 <- df2[, c(1,2, ncol(df2)-1, ncol(df2), 4:(ncol(df2)-2) )]


# joint table
df <- df1 %>%
  inner_join(df2, by=c("№ ВД", "tvo")) 


# use bayesian linear regression
source("model.R")

y_z <- df$ЗеленськийВолодимир.y  # second round's results
y_p <- df$ПорошенкоПетро.y # second round's results


df_all <- df %>%
  select(-1) # %>% 

# data matrix for b. model
data_X  <- df_all %>%
  select(4:(ncol(.)-4) )

# train on sample_size poll stations 
sample_size <- 2000 # starting from 5000 is recommended

set.seed(101)
idx <- sample(1:nrow(data_X), sample_size, replace=FALSE)
fit1 <- do_stan(data_X[idx, ], y_z[idx], y_p[idx],  model, 3000)


collect_results <- function(stan_fit, names){
  rezult <- tibble(name = names)
  rezult$ze <- summary(stan_fit)$summary[ ,'mean'][1:40];
  rezult$por <- summary(stan_fit)$summary[ ,'mean'][41:80];
  rezult$ze_total <- summary(stan_fit)$summary[ ,'mean'][123:162];
  rezult$por_total <- summary(stan_fit)$summary[ ,'mean'][163:202];
  rezult$turnout <- summary(stan_fit)$summary[ ,'mean'][81:120];
  return(rezult)
}

# check results in table
df_rez <- collect_results(fit1, names(data_X))
View(df_rez)



