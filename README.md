# bayes_vote_transfer 
Use bayesian linear regression to find how many voters for each candidates in first round of election, voted for candidate X in second round?  Based on real data from each poll station on Ukrainian presidential election-2019.

What are the assumptions of a model:
* all standart assumptions for bayesian linear regression
* there are different levels of support for each candidates in second round from different group of voters in first round (each group - voters who voted for some candidate) (uniforms as priors)
* turnout modelled for each such group as different parameters, too (student as priors)
* final share of voters of candidate Z in first tour is a multiple of level of support for candidate X from second and turnout for this group of voters

