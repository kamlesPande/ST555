*
Programmed by: Kamlesh Pandey
Programmed on: 2022-02-13
Programmed to: Programming for HW #3

Modified by: N/A
Modified on: N/A
Modified to: N/A

;

*Establish librefs and filerefs for incoming files;
x "cd L:\st555\Data\BookData\ClinicalTrialCaseStudy";
libname InputDS ".";
filename RawData ".";

*Establish librefs and filerefs for outgoing files;
* For result varification;
x "cd L:\st555\Results";
libname Results ".";

x "cd S:\HW3";
libname HW3 ".";

* Global ODS and OPTIONS setting;
ods noproctitle;
options nodate number;
ods listing close;


ods pdf file = "HW3 Pandey Baseline Clinical Report.pdf" ;
ods rtf file = "HW3 Pandey Baseline Clinical Report.rtf" style = sapphire;
ods powerpoint file = "HW3 Pandey Baseline Clinical Report.pptx" style= powerpointdark;

* Restricting the lisitng destination to PDF only;
ods rtf exclude none;
ods powerpoint exclude all;
ods pdf exclude none;


* Defining a Macro for labels and length of the dataset;
%let  VarAttrs = 
        Subj        label = "Subject Number"
                    length = 8
        sfReas      label = "Screen Failure Reason"
                    length = $50
        sfStatus    label = "Screen Failure Status (0 =Failed)"
                    length = $1
        BioSex      label = "Biological Sex"
                    length =  $1
        VisitDate   label =  "Visit Date"
                    length  = 8
                    format = mmddyy10.
        failDate    label = "Failure Notification Date"
                    length = 8
                    format = mmddyy10.
        sbp         label = "Systolic Blood Pressure"
                    length = 8
        dbp         label = "Diastolic Blood Pressure"
                    length = 8
        bpUnits     label = "Units (BP)"
                    length  = $5
        pulse       label = "Pulse"
                    length = 8
        pulseUnits  label = "Unit (Pulse)"
                    length  = $9
        position    label = "Position"
                    length = $9
        temp        label = "Temperature"
                    length  = 8
                    format = 5.1
        tempUnits   label = "Unit (Temp)"
                    length = $1
        weight      label = "Weight"
                    length  = 8
        weightUnits label = "Units (Weight)"
                    length  = $2
        pain        label = "Pain Score"
                    length = 8
  ;
*Visit macro;
%let Visit = Baseline ;

*Sort Macro;
%let ValSort =  by DESCENDING sfStatus sfReas DESCENDING VisitDate DESCENDING failDate Subj;

* Compare Macro;
%let CompOpts =  out = work.diff   noprint
                 outbase           outcompare outdiff outnoequal 
                 method = absolute criterion = 1E-10
     ;


* Creating dataset from the site 1 clinical trial raw data;
data  hw3.HW3PandeySite1;
  attrib &VarAttrs;
  infile RawData("Site 1, &Visit Visit.txt") dlm = "09"x dsd firstobs=1;
  input Subj sfReas $ sfStatus $ BioSex $ VisitDate :date9. failDate :date9. sbp
        dbp  bpUnits $ pulse pulseUnits $ position $ temp tempUnits $ 
        weight weightUnits $ pain
  ;
run;

*Sorting Site 1 dataset;
proc sort data =  hw3.HW3PandeySite1 out = hw3.SortedHW3PandeySite1;
    &ValSort;
run;

ods select Position Sortedby; 
title 'Variable-level Attributes and Sort Information: Site 1';
footnote h = 10pt j = left "Prepared by &sysuserid on &sysdate";
proc contents data =  hw3.SortedHW3PandeySite1 varnum;
run;
title;

* Creating dataset from the site 2 clinical trial raw data;

data  hw3.HW3PandeySite2;
  attrib &VarAttrs;
  infile RawData("Site 2, &Visit Visit.csv") dlm = ',' dsd firstobs=1;
  input Subj sfReas $ sfStatus $ BioSex $ VisitDate :ddmmyy10. failDate :ddmmyy10. sbp
        dbp  bpUnits $ pulse pulseUnits $ position $ temp tempUnits $ 
        weight weightUnits $ pain;
  list;
run;

*Sorting Datset 2 and saving in HW3 directory;
proc sort data =  hw3.HW3PandeySite2 out = hw3.SortedHW3PandeySite2;
    &ValSort;
run;

ods select Position Sortedby; 
title 'Variable-level Attributes and Sort Information: Site 2';
proc contents data =  hw3.SortedHW3PandeySite2 varnum;
run;
title;

* Creating dataset from the site 3 clinical trial raw data;
data  hw3.HW3PandeySite3;
  attrib &VarAttrs;
  infile RawData("Site 3, &Visit Visit.dat")  firstobs=1;
  input  Subj 1-7  sfReas $ 8-58 sfStatus $ 59-61 BioSex $ 62-62 
         @63 VisitDate ddmmyy10.  /* Column pointer control*/
         @73 failDate ddmmyy10.   /* Column pointer control*/
         sbp 83-85
         dbp 86-88  
         bpUnits $ 89-94 
         @95 pulse 3. 
         @98 pulseUnits $
         position $ 108-120
         temp 121-123
         tempUnits $ 124-124 
         weight 125-127 
         weightUnits $ 128-131 
         pain 132-132;
  putlog Pulse = ;
run;

*Sorting Datset 3 and saving in HW3 directory;
proc sort data =  hw3.HW3PandeySite3 out = hw3.SortedHW3PandeySite3;
    &ValSort;
run;


ods select Position Sortedby; 
title 'Variable-level Attributes and Sort Information: Site 3';
proc contents data =  hw3.SortedHW3PandeySite3 varnum;
run;
title;
footnote;

*Setting Powerpoint destination;
ods powerpoint exclude none;

* PROC MEAN STATEMENT ;
title             j = center "Selected Summary Statistics on &Visit Measurements";
title2            j = center 'for Patients from Site 1';
footnote  h = 10pt j = left 'Statistic and SAS keyword: Sample size (n), Mean (mean), Standard Deviation (stddev), Median (median), IQR (qrange)';
footnote2 h = 10pt j = left "Prepared by &sysuserid on &sysdate";
proc means data = hw3.HW3PandeySite1 nonobs n mean std median qrange maxdec=1;
  class pain;
  var   weight temp pulse dbp sbp;
run;
title;
footnote;


* PROC FREQ STATEMENTS and FORMAT;
proc format;
  value SysHyper (fuzz = 0 )
        low - < 130 = "Acceptable"
        130  -  high = "High"
  ;
run;
proc format ; 
  value DiaHyper (fuzz= 0)
        low - < 80 = "Acceptable"
        80  - High = "High"
  ;
run; 
ods pdf columns = 2;
title  j = center "Frequency Analysis of &Visit Positions and Pain Measurements by Blood Pressure Status";
title2 j = center 'for Patients from Site 2';
footnote h= 10pt j = left 'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic reaches 80';
footnote2 h = 10pt j= left "Prepared by &sysuserid on &sysdate";
proc freq data = hw3.SortedHW3PandeySite2; 
  table position;  
  table pain*dbp*sbp /nocol norow ;
  format dbp DiaHyper. sbp SysHyper. ; 
run;
title;
footnote;

* Setting destinaion off for powerpoint;
ods powerpoint exclude all;

*PROC PRINT STATEMENT;
ods pdf columns = 1;
title              j = center 'Selected Listing of Patients with a Screen Failure and Hypertension';
title2             j = center 'for patients from Site 3';
footnote  h = 10pt j = left   'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic reaches 80';
footnote2 h = 10pt j = left   'Only patients with a screen failure are included.';
footnote3 h = 10pt j = left   "Prepared by &sysuserid on &sysdate"; 
proc print data = HW3.SortedHW3PandeySite3 label;
  id subj pain ; /*can see that pain and subj are clubbed together in pdf*/
  var visitdate sfStatus sfReas failDate BioSex sbp dbp bpUnits weight weightUnits;
  where sfStatus eq ('0') and (dbp ge 80);
run; 

* Comparing site 1 datasets using PROC COMPARE statement;
proc compare base = HW3.HW3PandeySite1 compare = Results.hw3dugginssite1
     &CompOpts;
run;
    

* Comparing site 2 datasets using PROC COMPARE statement;
proc compare base = HW3.SortedHW3PandeySite2 compare = Results.hw3dugginssite2
     &CompOpts;
run;
    


* Comparing site 3 datasets using PROC COMPARE statement;
proc compare base = HW3.SortedHW3PandeySite3 compare = Results.hw3dugginssite3
     &CompOpts;
run;
    
title;
footnote;
ods pdf close;
ods rtf close;
quit;
