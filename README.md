# bayes_vote_transfer 
Use bayesian linear regression to find how many voters for each candidates in first round of election, voted for candidate X in second round?  Based on real data from each poll station on Ukrainian presidential election-2019.

What are the assumptions of a model:
* all standart assumptions for bayesian linear regression
* there are different levels of support for each candidates in second round from different group of voters in first round (each group - voters who voted for some candidate) (uniforms as priors)
* turnout modelled for each such group as different parameters, too (student as priors)
* final share of voters of candidate Z (from first tour). total_x, in result of candidate X in second is a multiple of level of support for candidate X and turnout for this group of voters.
* finally,  sum of all total_x[i] * turnout[i] * votes_from_first_round[i] = number of votes for X in second round, where i - index of each different group of voters

