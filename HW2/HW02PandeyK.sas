*
Programmed by: Kamlesh Pandey
Programmed on: 2022-02-09
Programmed to: Programming for HW #2

Modified by: N/A
Modified on: N/A
Modified to: N/A

;

*Establish librefs and filerefs for incoming files;
x "cd L:\st555\Data";
libname InputDS ".";
filename RawData ".";

*Establish librefs and filerefs for outgoing files;
x "cd S:\HW2";
libname HW2 ".";


* Global ODS and OPTIONS setting;
ods noproctitle;
options nodate number;


*Closing listing to send output at a destination;
ods listing close ;
ods pdf file = 'HW2 Pandey Basic Sales Report.pdf' style=Journal;
ods rtf file = 'HW2 Pandey Basic Sales Metadata.rtf' style=Sapphire;

* Restricting listing to only rtf file ;
ods pdf exclude all;
ods rtf exclude none;

* Locating the Libraries where SAS should look to find PRE-Defined FORMAT;
options fmtsearch = (InputDS);

* Creating dataset from raw text file of BasicSalesNorth;
data hw2.BasicSalesNorth;

  attrib 
         EmpID    label  = "Employee ID"
         Cust     label =  "Customer" 
         Date     label = "Bill Date"        format = YYMMDD10.
         Region   label = "Customer Region"
         Hours    label = "Hours Billed"     format = 5.2
         Rate     label = "Bill Rate"        format = dollar4.0
         TotalDue label = "Amount Due"       format = dollar9.2 
  ;

  * Matching length of variables as per the Metadatat;
  length Cust $ 45
         EmpID $ 4
         Region $ 5
  ;

  infile RawData("BasicSalesNorth.dat") dlm = '09'x  
         firstobs=11;
  input Cust $ EmpID $ Region $ 
        Hours Date Rate TotalDue;
run;
* Creating dataset from raw text file of BasicSalesSouth;
data hw2.BasicSalesSouth;
  
  attrib 
        EmpID    label = "Emplyee ID"
        Cust     label = "Customer"
        Date     label = "Bill Date"         format = MMDDYY10.   
        Region   label = "Customer Region"
        Hours    label = "Hours Billed"      format=5.2
        Rate     label = "Bill Rate"         format = dollar4.0
        TotalDue label = "Amount Due"        format = dollar9.2
  ;
  infile RawData("BasicSalesSouth.prn") 
         firstobs=12;
  input Cust $ 1-45 EmpID $ 46-49 Region $ 50-54 
        Hours 55-59 Date 60-64 Rate 65-67 TotalDue 68-73;
run;
* Creating dataset from raw text file of BasicSalesEastWest;
data hw2.BasicSalesEastWest;

  attrib 
        EmpID    label = "Employee ID"
        Cust     label = "Customer" 
        Date     label = "Bill Date"         format = DATE9. 
        Region   label = "Customer Region"
        Hours    label = "Hours Billed"      format = 5.2
        Rate     label = "Bill Rate"         format = dollar4.0
        TotalDue label = "Amount Due"        format = dollar9.2
  ;

  * Matching length of variables as per the Metadatat;
  length Cust   $ 45
         EmpID  $ 4
         Region $ 5
  ;
  infile RawData("BasicSalesEastWest.txt") dlm = ','
         firstobs=12;
  input Cust $ EmpID $ 46-49 Region $ 50-53 
        Hours Date Rate TotalDue;
run;

title         j=center "Variable-Level Metadata (Descriptor) Information";
title2 h=10pt j=center "for Records from North Region";

* Selecting only Position table after sorting by variable number;
ods select Position;
proc contents data =  hw2.BasicSalesNorth varnum;
run;
title2;

* Selecting only Position table after sorting by variable number;
ods select Position;
title2 h=10pt j=center "for Records from South Region";
proc contents data =  hw2.BasicSalesSouth varnum;
run;
title2;

* Selecting only Position table after sorting by variable number;
ods select Position;
title2 h=10pt j=center "for Records from East and West Regions";
proc contents data =  hw2.BasicSalesEastWest varnum;
run;
title2;

title;
* Printing FORMAT to RTF destination;
title j=center "BasicAmtDue Format Details";
proc format library = InputDS.Formats fmtlib ;
  select BasicAmtDue;
run;
title;

* As we want to print selective data into PDF file so by ODS statement we are making sure that it should not get printed in RTF file; 
ods rtf exclude all;
ods pdf exclude none;


title            j=center "Five Number Summaries of Hours and Amounts Due Grouped by Employee, Customer, and Region";
footnote h = 8pt j = left "Produced using data from East and West Regions";
* Generating Numeric Summaries;
proc means data = Hw2.BasicSalesEastWest  min  p25 p50 p75 max maxdec=2 nolabels;
  class EmpID Cust Region ;
  format TotalDue BasicAmtDue.; 
  label Hours = "Hours"
        TotalDue = "TotalDue"
        Region = "Customer Region"
  ;
  var Hours TotalDue;
run;
title;
footnote;

title             j = center "Breakdown of Records by Customer and Customer by Quarter";
footnote h = 8pt  j = left "Produced using data from North Region";
proc freq data= Hw2.BasicSalesNorth;
  * NOCOL to suppress the column percentage of each cell and NOROW to suppress the row percentage of each cell;
  table Cust Cust*Date/ nocol norow;
  label Cust = "Customer";
  * Using Pre-defined format to convert dates into Roman format;
  format Date QTRR4.;
run;
title;
footnote;

* Sorting BasicSalesSouth Data for later use in PROC PRINT;
proc sort data = hw2.BasicSalesSouth out = hw2.SortedBasicSalesSouth;
  by Cust descending Date;
run;
title             j=center 'Listing of Selected Billing Records ';
footnote  h = 8pt j=left "Included: Records with an amount due of at least $1,000 or from Frank's Franks with a bill rate of $75 or $150.";
footnote2 h = 8pt j=left "Produced using data from South Region";
proc print data = hw2.SortedBasicSalesSouth noobs label;
  id Cust Date EmpID;
  * Setting FORMAT for TotalDue and Hours;
  format TotalDue dollar10.2
         Hours    5.2
  ;
  sum Hours TotalDue;
  *Statement to select output based on the condition specefied (conditional filter);
  where (TotalDue ge 1000.00) or ((Cust eq "Frank's Franks") and (Rate in (75, 150)));
run;
title;
footnote;
footnote2;
ods listing;
ods pdf close;
ods rtf close;
quit;
