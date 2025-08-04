/*******************************************************************
| Name       : analysis_setup.sas
| Purpose    : Code to set up libnames and call utility functions
|              and macros. 
| SAS Version: 9.4
| Date       : 28062025 
|-------------------------------------------------------------------
| Notes:
| 1. setting library names 
| 2. creating a setup file to make macros.
| 
*******************************************************************/;


*** SIMSTUDY LIBNAMES ***;
libname data    "C:/Users/ritzs/OneDrive/Desktop/zEstimands/main/data";
libname results "C:/Users/ritzs/OneDrive/Desktop/zEstimands/main/results"; 


*** MACRO TO TURN OFF ALL AUTOMATIC OUTPUT ***;
%macro ods_off(notes=N);
ods results off;
ods graphics off;
ods select none;
%if &notes.=N %then %do; options nonotes; %end;
%mend;


*** MACRO TO TURN ON ALL AUTOMATIC OUTPUT ***;
%macro ods_on();
ods results on;
ods graphics on;
ods select all;
options notes; 
%mend;

