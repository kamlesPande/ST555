*
Programmed by: Kamlesh Pandey
Programmed on: 2022-03-01
Programmed to: Programming for HW #4

Modified by: N/A
Modified on: N/A
Modified to: N/A
;

*Establish librefs and filerefs for incoming files;
x " cd L:\st555\Data";
libname InputDS ".";
filename RawData ".";

*Establish librefs and filerefs for outgoing files;
* For result varification;
x "cd L:\st555\Results";
libname Results ".";

* For my output reports and generaed dataset;
x "cd S:\HW4";
libname HW4 ".";

* Global ODS and OPTIONS setting;
ods noproctitle;
options nodate number;
ods listing close;

* Setting lisitng destinations;
ods pdf file = "HW4 Pandey Lead Report.pdf";
ods pdf exclude all;

* For Utilising pre-defined format for date in later use;
options fmtsearch = (InputDs);

 proc format library = InputDs.Formats fmtlib;
    select Myqtr;
run;

* Creating Macros Years and CompOpts;
%let year     = 1998
      ;
%let CompOpts = noprint
                outbase            outcompare outdiff outnoequal
                method = absolute  criterion = 1E-15
     ;
* Reading raw data in;
data HW4.HW4PandeyLead (drop = _:);
  attrib
        StName      label = "State Name"     length = $2
        Region                               length = $9
        JobID                                length = 8               
        Date                                                    format = date9.
        PolType     label = "Pollutant Name" length = $4
        PolCode     label = "Pollutant Code" length = $8
        Equipment                                               format = dollar11.
        Personnel                                               format = dollar11.
        JobTotal                                                format = dollar11.
  ;  
  infile RawData("LeadProjects.txt") 
          dsd
          truncover
          firstobs=2
  ;
  input StName          :$3.
        _ID             :$5.
        _DateRegion     :$20.
        _POLCodePOLType :$char10.
        _EquipmentCost  :$10.
        _PersonnelCost  :$10.
  ;
  StName    = upcase(StName);
  Region    = propcase(substr(_DateRegion,6));
  JobID     = input(tranwrd(tranwrd(_ID, 'O', '0'), 'l', '1'), 5.); 
  Date      = substr(_DateRegion,1,5);
  PolType   = substr(_POLCodePOLType,2);
  PolCode   = substr(_POLCodePOLType,1,1);
  Equipment = input(compress(_EquipmentCost, '$'), dollar11.);
  Personnel = input(compress(_PersonnelCost, '$'), dollar11.);
  JobTotal  = sum(Equipment, Personnel);
run; 

* SORTING the dataset and generating a sorted daa for later use in PROC COMPARE;
proc sort data = hw4.HW4PandeyLead
          out  = hw4.HW4PandeyLeadSorted;
  by Region StName descending JobTotal ;
run; 

* Save the desc output to HW4 library and drop member column;
*ods trace on;
ods output Position = hw4.HW4PandeyDesc(drop = member);
proc contents data  = hw4.HW4PandeyLeadSorted varnum;
  run;
*ods trace off;

*PROC Compare for Content portion of the data set;
proc compare base = hw4.HW4PandeyLeadSorted compare = Results.hw4dugginslead
  out = hw4.DiffsB &CompOpts;
run;

*PROC Compare for the Description of the data set;
proc compare base = hw4.HW4PandeyDesc compare = results.hw4dugginsdesc
  out = hw4.DiffsA &CompOpts;
run;

* For the reports in pdf destination;
ods pdf exclude none;
title  j = Center '90th Percentile of Total Job Cost By Region and Quarter';
title2 j = Center "Data for &year";
*ods trace on;
ods output summary = hw4.hw4PandeySummary;
proc means data = hw4.HW4PandeyLeadSorted p90;
  class Region Date;
  var JobTotal;
  format date myqtr.;
run;
title;
*ods trace off;

* For graph generation we have to switch on the listing destination;
ods listing;
ods graphics on / imagename = "HW4Pctile90" width = 6in;
proc sgplot data = HW4.hw4PandeySummary;
  hbar region / response           = JobTotal_P90 group = Date 
                groupdisplay       = cluster
                datalabel          = nobs
                datalabelattrs     = (size = 6pt)
                /*datalabelfitpolicy = NONE; */
        ;
  xaxis label          = '90th Percentile of Total Job Cost'
        values         = (0 to 100000 by 20000)
        valuesformat   = dollar8.
        labelattrs     = (size = 10pt)
        grid
        offsetmax      = 0.05
        ;   
  yaxis label          = 'Region'
        labelattrs     = (size = 10pt)
        ;
  keylegend / location = outside position = top
        ;
run;
ods listing close;

* ODS TRACE ON to check the name of the table ;
*ods trace on;
title   j = center 'Frequency of Cleanup by Region and Date';
title2  j = center "Data for &year";
*Considering only rows where _TYPE_ (i.e. region and date ) equal to 11 and keeping region, date and rowpercent columns ;
ods output  CrossTabFreqs = hw4.hw4PandeyFreq(where = ( _type_ eq '11') keep = region date _type_ RowPercent);
proc freq data = hw4.HW4PandeyLeadSorted;
  table region*date / nocol nopercent ;
  format date myqtr.;
run;
*ods trace off;
title;

* Tracing on to find out the table name;
*ods trace on;
ods listing;
ods graphics on / imagename = "HW4RegionPct" width = 6in;
ods output sgplot = hw4.PandeySGPlot;
proc sgplot data = hw4.hw4PandeyFreq;
  vbar region / response = rowpercent group = date
                groupdisplay = cluster
        ;
  keylegend / location = inside position = topright across = 2 opaque
        ;
  xaxis label        = 'Region'
        valueattrs   = (size = 14pt)
        labelattrs   = (size = 16pt)
        ;
  yaxis label        = 'Region Percentage within Pollutant' 
        labelattrs   = (size = 16pt)
        labelpos     = center
        values       = (0.0 to 45.0 by 5.0)
        valuesformat = F5.1
        valueattrs   = (size = 12pt)
        grid
        offsetmax    = 0.05
        gridattrs    = (color = gray88 thickness=3)
        ;
run;

* PROC COMPARE the Graph2 dataset with the HS4DugginsGraph2 base datset;
proc compare base = hw4.PandeySGPlot compare = results.hw4dugginsgraph2
  out = hw4.DiffC &CompOpts;
run;
*ods trace off;
ods pdf close;
ods graphics off;
ods listing;
quit;
