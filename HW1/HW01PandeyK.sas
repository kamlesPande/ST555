*
Programmed by: Kamlesh Pandey
Programmed on: 2022-01-30
Programmed to: Programming HW #1

;

*Establish librefs and filerefs for incoming files;
x 'cd L:\st555\Data';
libname InputDs "."; 

*Establish librefs and filerefs for outgoing files;
x 'cd S:\ST555';
libname HW1 "." ;

*Global output options;
options nodate number;

*ODS(output delivery system) setting;
ods noproctitle;
ods exclude EngineHost;
ods _all_ close;
* Turing off SAS default lisitng destination so that output can be saved at a particular directory;
ods listing;
ods pdf file = 'HW1 Pandey IPUMSReport.pdf' style=Festival;

* Contents of BasicSales dataset based on thr variable's POSITION on SAS dataset;
title 'Descriptor Information Before Sorting';
proc contents data=InputDS.BasicSales varnum ;
  run;

*Sorting the dataset based on the Region Cust EmpID and descending TotalDue;
proc sort data=InputDS.BasicSales out=HW1.BASICSALES;
  by Region Cust EmpID descending TotalDue;
run;
title;
* Above title statement to discontinue printing of one Title continuously in the report;
title1 'Descriptor Information After Sorting';
*Excluding EngineHost variable from the report;
ods exclude EngineHost;
proc contents data = HW1.BASICSALES varnum; * We have to use the sorted data(HW1.BASICSALES) for our report;
  run;
title1;

* Creating a Format for the later use in PROC Means;
proc format;
  value DueAmount
    low - 200 = "Undeserved"
    200<- 500 = "Normal"
    500<- High = "Over Billed"
;
run;

* Setting titles for PROC Mean Analysis; 
title2 'Selected Numerical Sumamry of Basic Sales';
title3 h=8pt 'by Region, Customer, and Total Due Category';

* Defining footnote for the PROC Mean Analysis;
footnote j=left "Excluding the Company, LLC and Karen's Keepsake Kiosk";
footnote2 j=left "Undeserved = Up to $200, Normal = Up to $500, Over Billed = Over $500";

* PROC MEAN will include the variables that have label as a column in the output table
  Using PROC Means to calculate Min, 1stQuantile, Median, 3rdQuantile,and Max;
proc means data=InputDS.BasicSales nonobs n min q1 median q3 max maxdec=2;
  * Specifying the variables based on which we want to calculate the (min, quantile and max) values of the dataset;
  class Region Cust TotalDue;
  * Variables of focus (Variable on which we want to calculate the statistical analysis);
  var Hours Rate;
  * Setting up the labels and name of the variables;
  label Hours = 'Hours Billed'
        Rate = 'Billing Rate'
        Region = 'Sales Region'
        cust= 'Customer' 
        TotalDue= 'Total Amount Due'
;
  *Formatting the Total Due Amount using the DueAmount format created above;
  format TotalDue DueAmount.;
  *Conditional statement to filter out Customers which are not part of the The Company, LLC & Karen's Keepsake Kiosk;
  where cust not in ('The Company, LLC', "Karen's Keepsake Kiosk");
run;
title2;
title3;
options label;
title4 'Number of Billed Hours by Region and Region by Employee and Region by Amount Billed Classification';
proc freq data= InputDS.BasicSales;
  *Using Table statement to generate a frequency table;
  table Region Region*EmpID Region*TotalDue;
  label Region = 'Sales Region' 
        EmpID = 'Employee ID' 
        TotalDue = 'Total Amount Billed'
;
  format Totaldue DueAmount.;
  * Weight the Freq table of Region by Hours;
  weight hours;
  where cust not in ('The Company, LLC', "Karen's Keepsake Kiosk");
run;

* Closing the footnotes so that it should not carry even after PROC Frequency pages ;
footnote;
footnote2;
* Closing the title4 so that it should not carry even after PROC Frequency pages;
title4; 

title5 'Listing of Billing Amount';
title6 h=8pt 'Including Region and Customer within Region Totals';
*Using the Sorted data for taking advantage of BY-Group processing;
proc print data=HW1.BASICSALES noobs label;
  by Region Cust;
  * ID statement used to print lines based on the unique combined ID of Region and Customer name;
  id Region Cust;
  * Variable list that we want to print;
  var EmpID Date Hours Rate TotalDue;
  * For calcualting the final sum of the records;
  sum hours TotalDue;
  * Addtional labels for better expalnation of the system defined variables;
  attrib Rate label = "Billing Rate" format = dollar4.0
         Totaldue label = "Total Amount Billed" format = dollar11.2
         Date label = "Transaction Date" format = date9.
         Hours label = "Hours Billed"
         Region label = "Sales Region"
         cust label = "Customer"
         EmpID label = "Employee ID"
; 
run;
title5;
title6;
* Closing opened pdf;
ods pdf close;

* Turining on the listing destination;
ods listing;
quit;
