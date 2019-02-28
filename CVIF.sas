data dane;
  input y x2 x3 x4 case;
  infile cards dsd;
  cards;
  10,	12,	28,	35,	1
  12,	30,	34,	60,	1
  13,	16,	22,	45,	1
  15,	32,	26,	38,	1
  18,	28,	24,	65,	1
  19,	18,	38,	30,	1
  14,	10,	28,	70,	1
  13,	20,	36,	55,	1
  15,	14,	30,	75,	1
  17,	22,	20,	50,	1
  10,	30,	34,	30,	2
  12,	32,	36,	35,	2
  13,	22,	28,	38,	2
  15,	12,	38,	45,	2
  18,	28,	24,	50,	2
  19,	16,	28,	55,	2
  14,	14,	30,	60,	2
  13,	18,	20,	65,	2
  15,	10,	22,	70,	2
  17,	20,	26,	75,	2
  10,	10,	20,	30,	3
  12,	14,	24,	38,	3
  13,	12,	22,	35,	3
  15,	16,	26,	45,	3
  18,	18,	28,	50,	3
  19,	22,	30,	60,	3
  14,	20,	28,	55,	3
  13,	32,	38,	75,	3
  15,	30,	36,	70,	3
  17,	28,	34,	65,	3
  10,	10,	20,	30,	4
  12,	12,	22,	35,	4
  13,	14,	24,	38,	4
  15,	16,	26,	45,	4
  18,	18,	28,	50,	4
  19,	20,	30,	55,	4
  14,	22,	28,	60,	4
  13,	28,	34,	65,	4
  15,	30,	36,	70,	4
  17,	32,	38,	75,	4
  ;
run;

/*ods trace on;*/
proc reg data=dane;
  model y = x2 x3 x4 / tol vif collin;
/*  output out=r predicted=p;*/
  where case=1;
run;
/*ods trace off;*/

proc reg data=dane;
  model y = x2 x3 x4 / tol vif collin;
/*  output out=r predicted=p;*/
  where case=2;
run;

proc reg data=dane;
  model y = x2 x3 x4 / tol vif collin;
/*  output out=r predicted=p;*/
  where case=3;
run;

proc reg data=dane;
  model y = x2 x3 x4 / tol vif collin;
/*  output out=r predicted=p;*/
  where case=4;
run;

%macro jazda; 
  proc sql; drop table r2_all; quit;

  %do i = 1 %to 4;
    %do j = 2 %to 4;
      ods output FitStatistics = fitstats;
      proc reg data=dane;
        model y = x&j;
        where case=&i;
      run;

      data fitstats;
        set fitstats (keep=label2 cvalue2);
        where Label2 = 'R-kwadrat';
        drop Label2;
        case = "case_&i";
        var = "x&j";
        rename cvalue2=R2;
      run;
    
    proc append base=r2_all data=fitstats; run;
    %end;
  %end;
%mend;

%jazda;

proc sort data=r2_all; by var; run;
proc transpose data=r2_all out=r2_all_t;
  by var;
  id case;
  var R2;
run;
