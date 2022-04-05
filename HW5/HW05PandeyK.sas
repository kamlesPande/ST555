 *
Programmed by: Kamlesh Pandey
Programmed on: 2022-03-27
Programmed to: Programming for HW #5

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

options nobyline;                             /*supress the pollutant code title*/
options fmtsearch = (HW4) nodate;             /* To utilize the date informat created in last assignment*/
options fmtsearch = (InputDs) nodate;         /* Using pre-defined informat for PolCode*/


ods pdf file = "HW5 Pandey Projects Files.pdf" STARTPAGE = never ;
ods pdf exclude all;
* Any macros;
%let CompOpts = noprint
                outbase            outcompare outdiff outnoequal
                method = absolute  criterion = 1E-9
;

%let Title    =  25th and 75th Percentiles of Total Job Cost;
%let Title2   =  By Region and Controlling for Pollutant;
%let Title3   =  Exluding Records where Region was Unknown (Missing);
%let ftnote   =  Bars are labeled with the number of jobs contributing to each bar;
%let attribute =          
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
                

* Reading O3Projects raw file from the InputDs;
data HW5.PandeyO3ProjectsRaw (drop = _:)  ;
  attrib &attribute;
 
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

*Reading COProjects raw file from the InputDS;

data HW5.PandeyCOProjectsRaw (drop = _:)  ; 
  attrib &attribute ;
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

  
*Reading SO2Projects raw file from the InputDS;
data HW5.PandeySO2ProjectsRaw (drop = _:) ;
  attrib &attribute;
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


*Reading TSPProjects raw file from the InputDS;
data HW5.PandeyTSPProjectsRaw (drop = _:) ;
  attrib &attribute;
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

*Concat the dataset Vertical ;
data HW5.HW5PandeyProjectsMerged (label = 'Cleaned and Combined EPA Projects Data');
  set HW5.PandeyTSPProjectsRaw HW4.HW4PandeyLead HW5.PandeyCOProjectsRaw HW5.PandeySO2ProjectsRaw HW5.PandeyO3ProjectsRaw;
run;

* Final Sorting of the meged dataset;
proc sort data = HW5.HW5PandeyProjectsMerged out = HW5.HW5PandeyProjects;
  by PolCode Region descending JobTotal descending Date JobID;
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
  by PolCode;
  class Region date ;
  var JobTotal;
  format date MyQtr.;
  where not missing(PolCode);
run;

ods pdf exclude none;
ods exclude none;
ods listing image_dpi = 300;
ods graphics on / 
                 reset
                 width = 6in 
                 imagename = "HW5PandeyPctPlot"
                 scale = on;
title              "&Title";
title2             "&Title2 = #byval1";
title3    h = 8pt  "&Title3";
footnote          j = left   "&ftnote";
proc sgplot data = HW5.HW5Quantile;
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
  format PolCode $PolMap.;
run;

ods pdf close;
ods graphics off;
ods listing;
quit;
