/*******************************************************************
| Name       : dar_drop_summary_all_new.sas
| Purpose    : Code to calculate bias from full simulated data 
| SAS Version: 9.4
| Date       : 02072025 
|-------------------------------------------------------------------
| Notes:
| 
*******************************************************************/;

********************************************************************;
*** SECTION 0: SET UP ENVIRONMENT                                ***;
********************************************************************;

%let scenario = dar_drop; /**/
%include "C:/Users/ritzs/OneDrive/Desktop/zEstimands/main/code/analysis_setup.sas";


********************************************************************;
*** SECTION 1: READ AND STACK DATA                               ***;
********************************************************************;

*** LSM FROM TRUE ESTIMATES ***;
data lsm_true;
  set results.&scenario._true_lsm;
run;

*** LSM FROM ESTIMATION METHODS ***;
data lsm_all;
  set results.&scenario._mi1_lsm_part1   (in = in1)
	  results.&scenario._mi1_lsm_part2   (in = in1)
	  results.&scenario._mi2_lsm_part1   (in = in2)
	  results.&scenario._mi2_lsm_part2   (in = in2)
	  results.&scenario._mi3_lsm_part1   (in = in3)
	  results.&scenario._mi3_lsm_part2   (in = in3)
	  results.&scenario._cir_lsm_part1   (in = in4)  
	  results.&scenario._cir_lsm_part2   (in = in4)
	  results.&scenario._cr_lsm_part1    (in = in5)  
	  results.&scenario._cr_lsm_part2    (in = in5)
	  results.&scenario._jtr_lsm_part1   (in = in6)  
	  results.&scenario._jtr_lsm_part2   (in = in6)
;
  if in1 then methodn = 1;
  else if in2 then methodn = 2;
  else if in3 then methodn = 3;
  else if in4 then methodn = 4;
  else if in5 then methodn = 5;
  else if in6 then methodn = 6;


  length method $50;
  select(methodn);
    when (1) method = "Standard MI";
    when (2) method = "Retrieved Dropout - MI (ICE Status)";
    when (3) method = "Retrieved Dropout - MI (ICE Pattern)";
    when (4) method = "Reference-based imputation - CIR";
    when (5) method = "Reference-based imputation - CR";
    when (6) method = "Reference-based imputation - JTR";
    otherwise;
  end;

run;


*** LSM FROM TRUE ESTIMATES ***;
data dif_true;
  set results.&scenario._true_dif;
run;

*** LSM FROM ESTIMATION METHODS ***;
data dif_all;
  set results.&scenario._mi1_dif_part1   (in = in1)
	  results.&scenario._mi1_dif_part2   (in = in1)
	  results.&scenario._mi2_dif_part1   (in = in2)
	  results.&scenario._mi2_dif_part2   (in = in2)
	  results.&scenario._mi3_dif_part1   (in = in3)
	  results.&scenario._mi3_dif_part2   (in = in3)
	  results.&scenario._cir_dif_part1   (in = in4)  
	  results.&scenario._cir_dif_part2   (in = in4)
	  results.&scenario._cr_dif_part1    (in = in5)  
	  results.&scenario._cr_dif_part2    (in = in5)
	  results.&scenario._jtr_dif_part1   (in = in6)  
	  results.&scenario._jtr_dif_part2   (in = in6)
;
  if in1 then methodn = 1;
  else if in2 then methodn = 2;
  else if in3 then methodn = 3;
  else if in4 then methodn = 4;
  else if in5 then methodn = 5;
  else if in6 then methodn = 6;
  

  length method $50;
  select(methodn);
    when (1) method = "Standard MI";
    when (2) method = "Retrieved Dropout - MI (ICE Status)";
    when (3) method = "Retrieved Dropout - MI (ICE Pattern)";
    when (4) method = "Reference based imputation - CIR";
    when (5) method = "Reference based imputation - CR";
    when (6) method = "Reference based imputation - JTR";
    otherwise;
  end;


run;


********************************************************************;
*** SECTION 2: MERGE AND CALCULATE METRICS                      ***;
********************************************************************;

*** LSM DATA ***;
proc sort data = lsm_all;
  by groupn visitn rdrate;
run;

data lsm_metrics;
  merge lsm_all
        lsm_true;
  by groupn visitn;

  lsm_policy_bias = lsm_policy_est - lsm_true_est;                      *** BIAS OF POLICY LSM ESTIMATES ***;

  lsm_policy_mse  = lsm_policy_se**2 + lsm_policy_bias**2;              *** MEAN SQUARE ERROR ***;
  lsm_policy_hw   = (lsm_policy_upper - lsm_policy_lower) / 2;          *** HALFWIDTH OF POLICY LSM ESTIMATES ***;
  lsm_policy_cic  = lsm_policy_lower < lsm_true_est < lsm_policy_upper; *** CI COVERAGE INDICATOR ***;

run;

proc sort data = lsm_metrics;
  by rdrate sim_run groupn visitn;
run;


*** DIF DATA ***;
proc sort data = dif_all;
  by groupn visitn;
run;

data dif_metrics;
  merge dif_all
        dif_true ;
  by groupn visitn;

  dif_policy_bias = dif_policy_est - dif_true_est;                      *** BIAS OF POLICY DIF ESTIMATES ***;

  dif_policy_mse   = dif_policy_se**2 + dif_policy_bias**2;              *** ROOT MEAN SQUARE ERROR ***;
  dif_policy_hw    = (dif_policy_upper - dif_policy_lower) / 2;          *** HALFWIDTH OF POLICY DIF ESTIMATES ***;
  dif_policy_cic   = dif_policy_lower < dif_true_est < dif_policy_upper; *** CI COVERAGE INDICATOR ***;
  dif_policy_pwr   = dif_policy_upper < 0;                               *** BASIC SUPERIORITY IF UPPER LESS THAN ZERO ***;
  dif_policy_pwr2  = dif_policy_upper < -0.25;                            *** BASIC SUPERIORITY IF UPPER LESS THAN MINUS 0.5 ***;  

run;

proc sort data = dif_all;
  by rdrate sim_run groupn visitn;
run;


********************************************************************;
*** SECTION 3: SUMMARIZE THE LSM METRICS                         ***;
********************************************************************;

*** SUMMARIZE BIAS HALFWIDTH COVERAGE AND ROOT MSE ***;
proc means data = lsm_metrics nway noprint;
  class rdrate methodn method groupn visitn;
  var lsm_policy_bias lsm_policy_hw lsm_policy_cic lsm_policy_mse;
  output out = lsm_summary1 (drop = _type_ _freq_)
    n     (lsm_policy_bias lsm_policy_hw lsm_policy_cic lsm_policy_mse) = lsm_policy_bias_n    lsm_policy_hw_n    lsm_policy_cic_n    lsm_policy_mse_n      
    mean  (lsm_policy_bias lsm_policy_hw lsm_policy_cic lsm_policy_mse) = lsm_policy_bias_mean lsm_policy_hw_mean lsm_policy_cic_mean lsm_policy_mse_mean 
    lclm  (lsm_policy_bias lsm_policy_hw lsm_policy_cic lsm_policy_mse) = lsm_policy_bias_lclm lsm_policy_hw_lclm lsm_policy_cic_lclm lsm_policy_mse_lclm
    uclm  (lsm_policy_bias lsm_policy_hw lsm_policy_cic lsm_policy_mse) = lsm_policy_bias_uclm lsm_policy_hw_uclm lsm_policy_cic_uclm lsm_policy_mse_uclm; 
run;  



*** SUMMARIZE THE MEAN OF MODEL VAR AND THE SD OF THE POINT ESTIMATES ***;
proc means data = lsm_metrics nway noprint;
  class rdrate methodn method groupn visitn;
  var lsm_policy_est lsm_policy_var;
  output out = lsm_summary2 (drop = _type_ _freq_)   
    mean  (lsm_policy_var) = lsm_policy_var_mean       /*** MEAN OF THE MODEL VARIANCE ***/
    std   (lsm_policy_est) = lsm_policy_est_sd;        /*** SD OF THE POINT ESTIMATES ***/
run; 

 

*** MERGE ALL RESULTS TOGETHER ***;
data lsm_summary;
  merge lsm_summary1
        lsm_summary2;
  by rdrate methodn method groupn visitn;
  
  lsm_policy_se_mean = sqrt(lsm_policy_var_mean);    *** CREATE SE OF AVERAGE MODEL VARIANCE ***;  
  lsm_policy_rmse_mean = sqrt(lsm_policy_mse_mean);  *** CREATE RMSE OF AVERAGE MSE ***;
   
run;



********************************************************************;
*** SECTION 4: SUMMARIZE THE DIF METRICS                         ***;
********************************************************************;

*** SUMMARIZE BIAS HALFWIDTH COVERAGE AND ROOT MSE ***;
proc means data = dif_metrics nway noprint;
  class rdrate methodn method visitn;
  var dif_policy_bias dif_policy_hw dif_policy_cic dif_policy_mse dif_policy_pwr dif_policy_pwr2;
  output out = dif_summary1 (drop = _type_ _freq_)
    n     (dif_policy_bias dif_policy_hw dif_policy_cic dif_policy_mse dif_policy_pwr dif_policy_pwr2) = dif_policy_bias_n    dif_policy_hw_n    dif_policy_cic_n    dif_policy_mse_n    dif_policy_pwr_n    dif_policy_pwr2_n
    mean  (dif_policy_bias dif_policy_hw dif_policy_cic dif_policy_mse dif_policy_pwr dif_policy_pwr2) = dif_policy_bias_mean dif_policy_hw_mean dif_policy_cic_mean dif_policy_mse_mean dif_policy_pwr_mean dif_policy_pwr2_mean
    lclm  (dif_policy_bias dif_policy_hw dif_policy_cic dif_policy_mse dif_policy_pwr dif_policy_pwr2) = dif_policy_bias_lclm dif_policy_hw_lclm dif_policy_cic_lclm dif_policy_mse_lclm dif_policy_pwr_lclm dif_policy_pwr2_lclm
    uclm  (dif_policy_bias dif_policy_hw dif_policy_cic dif_policy_mse dif_policy_pwr dif_policy_pwr2) = dif_policy_bias_uclm dif_policy_hw_uclm dif_policy_cic_uclm dif_policy_mse_uclm dif_policy_pwr_uclm dif_policy_pwr2_uclm; 
run;  




*** SUMMARIZE THE MEAN OF MODEL VAR AND THE SD OF THE POINT ESTIMATES ***;
proc means data = dif_metrics nway noprint;
  class rdrate methodn method visitn;
  var dif_policy_est dif_policy_var;
  output out = dif_summary2 (drop = _type_ _freq_)   
    mean  (dif_policy_var) =  dif_policy_var_mean        /*** MEAN OF THE MODEL VARIANCE ***/
    std   (dif_policy_est) = dif_policy_est_sd;        /*** SD OF THE POINT ESTIMATES ***/
run; 




*** MERGE ALL RESULTS TOGETHER ***;
data dif_summary;
  merge dif_summary1
        dif_summary2;
  by rdrate methodn method visitn;
  
  dif_policy_se_mean = sqrt(dif_policy_var_mean);    *** CREATE SE OF AVERAGE MODEL VARIANCE ***;  
  dif_policy_rmse_mean = sqrt(dif_policy_mse_mean);  *** CREATE RMSE OF AVERAGE MSE ***;

run;


********************************************************************;
*** SECTION 4: OUTPUT TO PERM RESULTS LOCATION                   ***;
********************************************************************;

data results.&scenario._summary_lsm_all;
  attrib rdrate                   label = "RD Rate"	 
         groupn                   label = "Treatment (N)"
         visitn                   label = "Visit (N)"
         methodn                  label = "Estimation Method (N)"	 
         method                   label = "Estimation Method"	 
         lsm_policy_est_sd		  label = "SD of LSM Estimate"
         lsm_policy_se_mean	      label = "Mean of LSM SE"
         lsm_policy_bias_n		  label = "LSM Bias - N"
         lsm_policy_bias_mean     label = "LSM Bias - Mean"
         lsm_policy_bias_lclm	  label = "LSM Bias - Lower"	  
         lsm_policy_bias_uclm     label = "LSM Bias - Upper"
         lsm_policy_cic_n		  label = "LSM Coverage - N"
         lsm_policy_cic_mean      label = "LSM Coverage - Mean"
         lsm_policy_cic_lclm      label = "LSM Coverage - Lower"
         lsm_policy_cic_uclm      label = "LSM Coverage - Upper"
         lsm_policy_hw_n		  label = "LSM Halfwidth - N"
         lsm_policy_hw_mean		  label = "LSM Halfwidth - Mean"
         lsm_policy_hw_lclm		  label = "LSM Halfwidth - Lower"
         lsm_policy_hw_uclm		  label = "LSM Halfwidth - Upper"
         lsm_policy_mse_n	      label = "LSM Mean Square Error - N"
         lsm_policy_mse_mean	  label = "LSM Mean Square Error - Mean"
         lsm_policy_mse_lclm	  label = "LSM Mean Square Error - Lower"
         lsm_policy_mse_uclm	  label = "LSM Mean Square Error - Upper"
         lsm_policy_rmse_mean     label = "LSM Root of Mean Square Error - Mean";
  set lsm_summary;
run;

data results.&scenario._summary_dif_all;
  attrib rdrate                   label = "RD Rate"	 
         visitn                   label = "Visit (N)"
         methodn                  label = "Estimation Method (N)"	 
         method                   label = "Estimation Method"	 
         dif_policy_est_sd		  label = "SD of Treamtent Effect Estimate"
         dif_policy_se_mean	      label = "Mean of Treamtent Effect SE"
         dif_policy_bias_n		  label = "Treamtent Effect Bias - N"
         dif_policy_bias_mean     label = "Treamtent Effect Bias - Mean"
         dif_policy_bias_lclm	  label = "Treamtent Effect Bias - Lower"	  
         dif_policy_bias_uclm     label = "Treamtent Effect Bias - Upper"
         dif_policy_cic_n		  label = "Treamtent Effect Coverage - N"
         dif_policy_cic_mean      label = "Treamtent Effect Coverage - Mean"
         dif_policy_cic_lclm      label = "Treamtent Effect Coverage - Lower"
         dif_policy_cic_uclm      label = "Treamtent Effect Coverage - Upper"
         dif_policy_hw_n		  label = "Treamtent Effect Halfwidth - N"
         dif_policy_hw_mean		  label = "Treamtent Effect Halfwidth - Mean"
         dif_policy_hw_lclm		  label = "Treamtent Effect Halfwidth - Lower"
         dif_policy_hw_uclm		  label = "Treamtent Effect Halfwidth - Upper"
         dif_policy_mse_n	      label = "Treamtent Effect Mean Square Error - N"
         dif_policy_mse_mean	  label = "Treamtent Effect Mean Square Error - Mean"
         dif_policy_mse_lclm	  label = "Treamtent Effect Mean Square Error - Lower"
         dif_policy_mse_uclm	  label = "Treamtent Effect Mean Square Error - Upper"
         dif_policy_rmse_mean     label = "Treamtent Effect Root of Mean Square Error - Mean"
         dif_policy_pwr_n	      label = "Treamtent Effect Basic Superiority Power - N"
         dif_policy_pwr_mean	  label = "Treamtent Effect Basic Superiority Power - Mean"
         dif_policy_pwr_lclm	  label = "Treamtent Effect Basic Superiority Power - Lower"
         dif_policy_pwr_uclm	  label = "Treamtent Effect Basic Superiority Power - Upper"
         dif_policy_pwr_n	      label = "Treamtent Effect Super Superiority Power - N"
         dif_policy_pwr_mean	  label = "Treamtent Effect Super Superiority Power - Mean"
         dif_policy_pwr_lclm	  label = "Treamtent Effect Super Superiority Power - Lower"
         dif_policy_pwr_uclm	  label = "Treamtent Effect Super Superiority Power - Upper";
  set dif_summary;
run;


********************************************************************;
*** SECTION 5: TIDY UP WORK LIBRARY                              ***;
********************************************************************;

proc datasets lib = work nolist;
  delete lsm: dif:;
quit;
