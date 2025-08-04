/*******************************************************************
| Name       : analysis_plots_all.sas
| Purpose    : Plots from the summary datasets 
|              and macros. 
| SAS Version: 9.4
| Date       : 02072025 
|-------------------------------------------------------------------
| Notes:
|
| 
*******************************************************************/;

********************************************************************;
*** SET UP ENVIRONMENT                                           ***;
********************************************************************;

%include "C:/Users/ritzs/OneDrive/Desktop/zEstimands/main/code/analysis_setup.sas";

*** SET UP HTML AND GRAPHICS FILE ROUTING ***;
filename out "C:/Users/ritzs/OneDrive/Desktop/zEstimands/main/output";

proc format lib = work;
  value rdrate 1 = "1"
               2 = "2"
               3 = "3"
               4 = "4";
       
  value typen 1 = "N = 100 - Simple and RD Approaches"
              2 = "N = 100 - RBI Approaches"
              3 = "N = 200 - Simple and RD Approaches"
              4 = "N = 200 - RBI Approaches"
              5 = "N = 400 - Simple and RD Approaches"
              6 = "N = 400 - RBI Approaches"
             ;                    
run;


********************************************************************;
*** STACK SUMMARY DATA                                           ***;
********************************************************************;

data all_dif;
  set results.dar_drop100_summary_dif_all       (in = in1)
      results.dar_drop200_summary_dif_all       (in = in2)
      results.dar_drop400_summary_dif_all       (in = in3);
;
  if in1 then scenario = 1;
  else if in2 then scenario = 2;
  else if in3 then scenario = 3;

    
  dif_policy_se_mean1 = dif_policy_se_mean;
  dif_policy_rmse_mean1 = dif_policy_rmse_mean;
  dif_policy_hw_mean1 = dif_policy_hw_mean;
  dif_policy_cic_mean1 = dif_policy_cic_mean;
  dif_policy_pwr_mean1 = dif_policy_pwr_mean;
  dif_policy_pwr2_mean1 = dif_policy_pwr2_mean;
  dif_policy_se_bias1 = dif_policy_se_mean1 - dif_policy_est_sd; 
  dif_policy_se_bias2 = dif_policy_se_mean2 - dif_policy_est_sd;
run;

data all_dif_plot;
  set all_dif (in = in1 where = (method in ("Standard MI"  "Retrieved Dropout - MI (ICE Status)"  "Retrieved Dropout - MI (ICE Pattern)")))
      all_dif (in = in2 where = (method in ("Reference based imputation - CIR" "Reference based imputation - CR" "Reference based imputation - JTR")));
  
  
  if in1 then do;
    if scenario = 1 then typen = 1;
    else if scenario = 2 then typen = 3;
    else if scenario = 3 then typen = 5;
  end;
  else if in2 then do;
    if scenario = 1 then typen = 2;
    else if scenario = 2 then typen = 4;
    else if scenario = 3 then typen = 6;
  end;
    
run;


********************************************************************;
*** CREATE ATTRIBUTE MAP FOR METHODS  #8F00FF                        ***;
********************************************************************;
  
data map1;
  array values   [6] $40("Standard MI"  "Retrieved Dropout - MI (ICE Status)"  "Retrieved Dropout - MI (ICE Pattern)"  "Reference based imputation - CIR" "Reference based imputation - CR" "Reference based imputation - JTR");
  array colors   [6] $10("#808080" "#FF8000" "#88E55C" "#54d2d2" "#ffcb00" "#ff6150");
  array patterns [6] $10 ("1"  "20"  "20"  "1"  "1"  "1");
  id = "models";
  do i = 1 to dim(values);
    value       = values[i];
    linecolor   = colors[i];
    linepattern = patterns[i];  
    linethickness = 2;
    output;
  end;
run;  


********************************************************************;
*** MAIN FIGURES                                                 ***;
********************************************************************;

*** FIG 1 TREATMENT EFFECT BIAS ***;
ods graphics on / reset=all width = 10in height=7in outputfmt=svg imagename="FIG1";
ods html path=out gpath=out file="fig1.html";

proc sgpanel data = all_dif_plot (where = (visitn = 5 and typen in (1 2 3 4 5 6) )) dattrmap=map1;
  panelby typen / rows=3 columns=2 novarname;
  series x=rdrate y=dif_policy_bias_mean / group = method attrid=models;
  title1 "Treatment effect bias";
  rowaxis label = "Bias" values=(-0.10 to 0.04 by 0.02) grid;
  colaxis label = "Missingness scenario" values=(1 to 4 by 1) grid;  
  format rdrate rdrate. typen typen.;
run;


*** FIG 2 TREATMENT EFFECT SD(POINT ESTIMATE) ***;
ods graphics on / reset=all width = 10in height=7in outputfmt=svg imagename="FIG2";
ods html path=out gpath=out file="fig2.html";

proc sgpanel data = all_dif_plot (where = (visitn = 5 and typen in (1 2 3 4 5 6) )) dattrmap=map1;
  panelby typen / rows=3 columns=2 novarname;
  series x=rdrate y=dif_policy_est_sd / group = method attrid=models;
  title1 "SD of treatement effect estimates";
  rowaxis label = "SD of treatment effect estimate" values=(0.1 to 0.3 by 0.01) grid;
  colaxis label = "Missingness scenario" values=(1 to 4 by 1) grid;  
  format rdrate rdrate. typen typen.;
run;


*** FIG 3 TREATMENT EFFECT MODEL SE ***;
ods graphics on / reset=all width = 10in height=7in outputfmt=svg imagename="FIG3";
ods html path=out gpath=out file="fig3.html";

proc sgpanel data = all_dif_plot (where = (visitn = 5 and typen in (1 2 3 4 5 6) )) dattrmap=map1;
  panelby typen / rows=3 columns=2 novarname;
  series x=rdrate y=dif_policy_se_mean2 / group = method attrid=models;
  title1 "Treatment Effect Model SE";
  rowaxis label = "Average Model SE" values=(0.1 to 0.3 by 0.01) grid;
  colaxis label = "Missingness scenario" values=(1 to 4 by 1) grid;  
  format rdrate rdrate. typen typen.;
run;


*** FIG 4 TREATMENT EFFECT CI COVERAGE ***;
ods graphics on / reset=all width = 10in height=7in outputfmt=svg imagename="FIG4";
ods html path=out gpath=out file="fig4.html";

proc sgpanel data = all_dif_plot (where = (visitn = 5 and typen in (1 2 3 4 5 6) )) dattrmap=map1;
  panelby typen / rows=3 columns=2 novarname;
  series x=rdrate y=dif_policy_cic_mean2 / group = method attrid=models;
  title1 "Treatment Effect 95% CI Coverage";
  rowaxis label = "95% CI Coverage" values=(0.85 to 1.00 by 0.02) grid;
  colaxis label = "Missingness scenario" values=(1 to 4 by 1) grid;  
  format rdrate rdrate. typen typen.;
run;

*** FIG 5 TREATMENT EFFECT HALFWIDTH ***;
ods graphics on / reset=all width = 10in height=7in outputfmt=svg imagename="FIG5";
ods html path=out gpath=out file="fig5.html";
proc sgpanel data = all_dif_plot (where = (visitn = 5 and typen in (1 2 3 4 5 6) )) dattrmap=map1;
  panelby typen / rows=3 columns=2 novarname;
  series x=rdrate y=dif_policy_hw_mean2 / group = method attrid=models;
  title1 "Treatment Effect Halfwidth";
  rowaxis label = "CI-Halfwidth" values=(0.20 to 0.60 by 0.025) grid;
  colaxis label = "Missingness scenario" values=(1 to 4 by 1) grid;  
  format rdrate rdrate. typen typen.;
run;






