# Estimand Framework
# Treatment Policy Strategy
This repository contains the codes used for Biostatistics Master's Thesis which was used to evaluate anf compare 3 different multiple imputation methods - Standard MI, Retrieved Dropout MI and Reference-based MI in longitudinal clinical trials based on treatment policy strategy in Estimand Framework. The simulated datasets are created using R Version 4.5.1.

The clinical trial chosen for the simulation of data is the PIONEER 1 trial on type 2 diabetes patients who are randomized into treatment arm and control arm in 1:1 ratio. The simulation codes are contained in the file Estimand/code/simulation and the user-defined functions to be used for simulation are in the file Estimand/code/functions

For analysis, SAS Version 9.4 (SAS/STAT 15.3) was used to perform the different MI methods. The codes must be run in the following sequence:-
1. analysis_setup.sas
2. dar_drop_csv.sas
3. dar_drop_data.sas
4. dar_drop_status.sas
5. dar_drop_true.sas
6. dar_drop_mi1_part1.sas
7. dar_drop_mi1_part2.sas
8. dar_drop_mi2_part1.sas
9. dar_drop_mi2_part2.sas
10. dar_drop_mi3_part1.sas
11. dar_drop_mi3_part2.sas
12. rbi_tools.sas
13. dar_drop_cr_part1.sas
14. dar_drop_cr_part2.sas
15. dar_drop_cir_part1.sas
16. dar_drop_cir_part2.sas
17. dar_drop_jtr_part1.sas
18. dar_drop_jtr_part2.sas
19. dar_drop_summary_all.sas
20. analysis_plots_all.sas

The codes are referred from the https://github.com/EIWG-Estimation/TPE-Sim1.git github library. All credits and rights belong to EIWG Estimation sub-team. 
