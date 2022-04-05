 *
Programmed by: Kamlesh Pandey
Programmed on: 2022-03-21
Programmed to: Programming for HW #4

Modified by: N/A
Modified on: N/A
Modified to: N/A
;

* Establish libref and filreref for incoming files;
x "cd L:\st555\Data";
libname InputDS ".";
filename RawData ".";

*Establish librefs and filerefs for outgoing files;
* For result varification;
x "cd L:\st555\Results";
libname Results ".";


* For HW4 dataset;
x "cd S:\HW4";
libname HW4 ".";


*For output reports and generated data set;
x "cd S:\HW5";
libname HW5 ".";
filename HW5 ".";

*Global ODS and Output setting;
ods noproctitle;
options nodate number;
ods exclude all;
ods listing close;

options nobyline;    /*supress the pollutant code title*/

options fmtsearch = (HW4) nodate;
options fmtsearch = (InputDs) nodate;


ods pdf file = "HW5 Pandey Projects Files.pdf" STARTPAGE = never ;
ods pdf exclude all;
* Any macros;
%let CompOpts = noprint
                outbase            outcompare outdiff outnoequal
                method = absolute  criterion = 1E-9
;

%let SortData = Region StName descending JobTotal;

%let Title   =  25th and 75th Percentiles of Total Job Cost;
%let Title2  =  By Region and Controlling for Pollutant = ; 
%let Title3  =  Exluding Records where Region was Unknown (Missing);
%let year    =  1998;
%let ftnote  =  Bars are labeled with the number of jobs contributing to each bar;

* Reading O3Projects raw file from the InputDs;
data HW5.PandeyO3ProjectsRaw (drop = _:) ;
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
  infile RawData("O3Projects.txt") 
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
  if      substr(_POLCodePOLType,1,1) eq '5' then
                                                      PolType   = substr(_POLCodePOLType,2,2);
  if      substr(_POLCodePOLType,1,1) eq '5' then 
                                                      PolCode   = substr(_POLCodePOLType,1,1);
  else if substr(_POLCodePOLType,1,1) ne '5' then 
                                                      PolType   = substr(_POLCodePOLType,1,2);
  Equipment = input(compress(_EquipmentCost, '$'), dollar11.);
  Personnel = input(compress(_PersonnelCost, '$'), dollar11.);
  JobTotal  = sum(Equipment, Personnel);
run;

* SOrting 03 datset for Interleaving;
proc sort data = HW5.PandeyO3ProjectsRaw out = HW5.PandeyO3ProjectsRawSorted;
    by &SortData;
run;

*Reading COProjects raw file from the InputDS;

data HW5.PandeyCOProjectsRaw (drop = _:); 
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
  infile RawData("CoProjects.txt")
        dsd
        truncover
        firstobs = 2
  ;
  input StName          :$3.
        _ID             :$5.
        _DateRegion     :$20.
        _EquipmentCost  :$10.
        _PersonnelCost  :$10.
  ;
  StName    = upcase(StName);
  Region    = propcase(substr(_DateRegion,6));
  JobID     = input(tranwrd(tranwrd(_ID, 'O', '0'), 'l', '1'), 5.); 
  Date      = substr(_DateRegion,1,5);
  Equipment = input(compress(_EquipmentCost, '$'), dollar11.);
  Personnel = input(compress(_PersonnelCost, '$'), dollar11.);
  JobTotal  = sum(Equipment, Personnel);
  PolType   = "CO";
  PolCode   = "3";
run;   

* SOrting COProjects datset for Interleaving;
proc sort data = HW5.PandeyCOProjectsRaw out = HW5.PandeyCOProjectsRawSorted;
  by Region StName descending JobTotal;
run;
  
*Reading SO2Projects raw file from the InputDS;
data HW5.PandeySO2Projects(drop = _:) ;
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
  infile RawData("SO2Projects.txt")
        dsd
        truncover
        firstobs = 2
  ;
  input StName          :$3.
        _ID             :$5.
        _DateRegion     :$20.
        _EquipmentCost  :$10.
        _PersonnelCost  :$10.
  ;
  StName    = upcase(StName);
  Region    = propcase(substr(_DateRegion,6));
  JobID     = input(tranwrd(tranwrd(_ID, 'O', '0'), 'l', '1'), 5.); 
  Date      = substr(_DateRegion,1,5);
  Equipment = input(compress(_EquipmentCost, '$'), dollar11.);
  Personnel = input(compress(_PersonnelCost, '$'), dollar11.);
  JobTotal  = sum(Equipment, Personnel);
  PolType   = "SO2";
  PolCode   = "4";
run;

* SOrting SO2Projects datset for Interleaving;
proc sort data = HW5.PandeySO2Projects out = HW5.PandeySO2ProjectsSorted;
  by Region StName descending JobTotal;
run;

*Reading TSPProjects raw file from the InputDS;
data HW5.PandeyTSPProjects(drop = _:) ;
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
  infile RawData("TSPProjects.txt")
        dsd
        truncover
        firstobs = 2
  ;
  input StName          :$3.
        _ID             :$5.
        _DateRegion     :$20.
        _EquipmentCost  :$10.
        _PersonnelCost  :$10.
  ;
  StName    = upcase(StName);
  if      substr(_DateRegion,1,1) eq '1' then 
                                                  Region    = propcase(substr(_DateRegion,6));
  if      substr(_DateRegion,1,1) eq '1' then 
                                                  Date      = substr(_DateRegion,1,5);
  else if substr(_DateRegion,1,1) ne '1' then
                                                  Region    = propcase(substr(_DateRegion,1));                 
  JobID     = input(tranwrd(tranwrd(_ID, 'O', '0'), 'l', '1'), 5.); 
  
  Equipment = input(compress(_EquipmentCost, '$'), dollar11.);
  Personnel = input(compress(_PersonnelCost, '$'), dollar11.);
  JobTotal  = sum(Equipment, Personnel);
  PolType   = "TSP";
  PolCode   = "1";
run;

* SOrting TSSProjects datset for Interleaving;
proc sort data = HW5.PandeyTSPProjects out = HW5.PandeyTSPProjectsSorted;
  by Region StName descending JobTotal;
run;

*Interleaving the dataset Vertical + Grouping by Pollutant code;
data HW5.HW5PandeyProjectsMerged (label = 'Cleaned and Combined EPA Projects Data');
  set HW5.PandeyTSPProjectsSorted HW4.HW4PandeyLead HW5.PandeyCOProjectsRawSorted HW5.PandeySO2ProjectsSorted HW5.PandeyO3ProjectsRawSorted;
  by Region StName descending JobTotal;
run;


* Final Sorting of the meged dataset;
proc sort data = HW5.HW5PandeyProjectsMerged out = HW5.HW5PandeyProjects;
  by PolCode Region descending JobTotal descending Date;
run;

*Validation of content of the final dataset;
proc compare base = HW5.HW5PandeyProjects compare = results.HW5DugginsProjects
  out  = hw5.content_diif &CompOpts;
run;

* Creating descriptor of the final dataset;
*ods trace on;
ods output position = HW5.HW5PandeyProjectsDesc (drop = member);
proc contents data = HW5.HW5PandeyProjects varnum;
  run;
*ods trace off;

* Validating the descriptor portion of the dataset;
proc compare base = HW5.HW5PandeyProjectsDesc compare = results.HW5DugginsProjectsdesc
  out = hw5.desc_diff &CompOpts;
run;

* Generating the Requested Graphs;
ods output summary = HW5.HW5Quantile;
proc means data = hw5.HW5PandeyProjects p25 p75;
  class Region date PolCode ;
  var JobTotal;
  format date MyQtr.;
run;

ods pdf exclude none;
ods exclude none;
ods listing image_dpi = 300;

ods graphics on / 
                 reset
                 width = 6in 
                 imagename = "HW5PandeyBonusPlot"
                 scale = on;
title              "25th and 75th Percentiles of Total Job Cost";
title2             "By Region and Controlling for Pollutant = #byval1";
title3    h = 8pt  "&Title3";
footnote          j = left   "&ftnote";
proc sgplot data = HW5.HW5Quantile;
  *format PolCode PolMap.;
  *where PolCode eq "1";
  
  styleattrs datacolors      = (cx1b9e77 cxd95f02 cx7570b3 cxe7298a);
  vbar region / response     = JobTotal_P75  group = date 
                datalabel    = nobs datalabelattrs  = (size = 7pt) 
                groupdisplay = cluster 
                outlineattrs = (color=black thickness=1) name = "P_75Plot"
  ;
  vbar region / response     = JobTotal_P25  group = date 
                fillattrs    = (color = CX4F4F4F) groupdisplay = cluster 
                outlineattrs = (color = black thickness=1) name = "P_25Plot"
  ;
  keylegend "P_75Plot"/ location = outside position = top opaque;
  xaxis display      = (nolabel);
  yaxis grid
        gridattrs    =  (thickness = 3 color = grayCC)
        valuesformat =  dollar7.
        display      =  (nolabel)
  ;
  by PolCode;
  *format PolCode PolMap.;
run;

ods pdf close;
ods graphics off;
quit;
