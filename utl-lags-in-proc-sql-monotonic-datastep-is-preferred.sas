Lags in proc sql monotonic datastep is preferred

github
https://tinyurl.com/y97u63kw
https://github.com/rogerjdeangelis/utl-lags-in-proc-sql-monotonic-datastep-is-preferred

 Slight advantage for sql if you need to aggregate or square lags, dif reg, dif time series

https://tinyurl.com/ybo23cqt
https://communities.sas.com/t5/SAS-Programming/What-alternative-function-in-sql/m-p/498287

This should be a safe use of monotonic?

    Two solutions
        1. Proc sql
        2. datastep

INPUT
=====

 SASHELP.CLASS(keep=name age)

                     |   RULES (SQL)
   NAME       AGE    |   DIF
                     |
   Alfred      14    |       * not in output
   Alice       13    |   -1  13-14 = -1
   Barbara     13    |    0  13-13 =  0
   Carol       14    |    1  14-13 =  1
   Henry       14    |    0
   James       12    |   -2
 ...

EXAMPLE OUTPUT
--------------

 1. Proc sql

   WORK.WANT total obs=18

     NAME       AGE    DIF
                            * alfred missing
     Alice       13     -1
     Barbara     13      0
     Carol       14      1
     Henry       14      0
     James       12     -2

 2. Datastep

  WORK.WANT total obs=19

    NAME       AGE    DIF

    Alfred      14      .   has alfred
    Alice       13     -1
    Barbara     13      0
    Carol       14      1
    Henry       14      0
    James       12     -2

PROCESS
=======

 1. Proc sql

   proc sql;
    create
       table want as
    select
       l.name
      ,l.age
      ,(l.age - r.age) as dif
    from
      (select
          monotonic() as mono
         ,name
         ,age
       from
         sashelp.class
      ) as l,
      (select
          monotonic() as mono
         ,age
       from
         sashelp.class
      ) as r
    having
      (l.mono - r.mono) = 1
   ;quit;

 2. Datstep

   data want;
     set sashelp.class(keep=name age);;
     dif=dif(age);
   run;quit;


OUTPUT
======

see EXAMPLE OUTPUT

