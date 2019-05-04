# (c) @dvrnd, Texty.org.ua, 2019

library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())



# Stan model
model <- "
data {
  int<lower=1> n;   // number of observations (poll stations)
  int<lower=0> k;   // number of parameters (candidates)
  matrix[n, k] X;   // data (results of first round)
  vector[n] y_z;      // response Z (second round results for Zelensky)
  vector[n] y_p;      // response P (second round results for Poroshenko)
}

parameters {
  vector<lower = 0, upper = 1>[k] a_z;  //  coefficientsof vote transfer to Z  for each candidate in Ist round
  vector<lower = 0, upper = 1>[k] a_p;  //  coefficients of vote transfer to P ...

  vector<lower = 0, upper = 1>[k] t;  // turnout in second round for voters of each candidate from Ist
  real<lower = 0> sigma_z;       // residuals
  real<lower = 0> sigma_p;       // residuals 
}

transformed parameters {
  vector[k] total_z;
  vector[k] total_p;
  
  // total_x - is a full share of voters transferred to candidate x in second round    
  for(i in 1:k){
    total_z[i] = a_z[i]*t[i]; // support level (diff for each candidate) multiply by turnout, Ze  
    total_p[i] = a_p[i]*t[i]; // the same as above, but for Poroshenko 
  }
}

model {

// priors for turnout, heavy tailed simmetric student
  for(i in 1:k){
    t[i] ~ student_t(1, 0.5, 0.5);
  }

// Likelihood
  y_z ~ normal(X * total_z, sigma_z);  //linear regression
  y_p ~ normal(X * total_p, sigma_p);

}"



# deploy Stan model
do_stan <- function(data_X, y_z, y_p,  model, iterations){

  k <- ncol(data_X) # params
  n <- nrow(data_X) # measurements
  
  # Fit stan model
  fit <- stan(
    model_code = model,
    data = list(
      n = n,
      k = k,
      X = data_X,
      y_z = as.numeric(y_z),
      y_p = as.numeric(y_p)),
    iter = iterations,
    chains = 4);
  
  return(fit);
}

