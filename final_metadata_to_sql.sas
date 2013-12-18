/*------------------------------------------------------------------------*\
** Program : final_metadata_to_sql.sas
** Purpose : Import CDISC sample final_metadata and export as sql dump
** Note    : The sql dump is intended for processing by d2rq (http://www.d2rq.org) 
             to transform the data into a turtle (.ttl) file.
                                                                
==== ALSO NEEDED ====
CDISC sample final_metadata can be obtained at
http://www.cdisc.org/sdtm, search for 
"Metadata Submission Guideline (MSG) Package Preface"
If not CDISC member, select Non Members and follow instuctions.
   
The path dirxpt=..\final_metadata\tabulations\sdtm
assumes the archive is unpacked to the current directory.                                                            
==== ALSO NEEDED ====

==== NOTE ====
Use SAS 9.4 (9.3 TS1M2 or later) see http://support.sas.com/kb/48/699.html
Not sure whether this handles all issues, see comment in include_tagset_sqlmod.sas
==== NOTE ====
                                                             
\*------------------------------------------------------------------------*/


options formchar="|----|+|---+=|-/\<>*";
options source source2;
options nocenter;
options msglevel=i;

/* Define tagset in work for exporting data as sql insert formats */
/* Based on http://support.sas.com/rnd/base/ods/odsmarkup/sql.html */

%include "include_tagset_sqlmod.sas";
/* ods path(prepend) work.tmpl(read); */



/* To transfer the data the primary key needs to be defined.
   Here it is provided using a format as lookup from the dataset name.
   Alternatively, the datasets could be sorted, and the primary key
   derived from the sorting order; or the primary key could be defined
   in SAS using PROC SQL / PROC DATASET.
*/
                                                              
proc format;
value $dk
"TA"="STUDYID, ARMCD, TAETORD"
"TE"="STUDYID, ETCD"
"TI"="STUDYID, IETESTCD"
"TS"="STUDYID, TSPARMCD, TSSEQ"
"TV"="STUDYID, VISITNUM, ARMCD"
"DM"="STUDYID, USUBJID"
"SE"="STUDYID, USUBJID, SESTDTC, SEENDTC, TAETORD, ETCD"
"SV"="STUDYID, USUBJID, SVSTDTC, VISITNUM"
"CM"="STUDYID, USUBJID, CMSTDTC, CMENDTC, CMCAT, CMTRT, CMDOSTXT, CMDOSU, CMINDC, CMDOSFRQ"
"EX"="STUDYID, USUBJID, EXSTDTC, EXENDTC, EXTRT, EXDOSE"
"AE"="STUDYID, USUBJID, AEDECOD, AESTDTC"
/* "DS"="STUDYID, USUBJID, DSSTDY, DSSTDTC, DSCAT, DSDECOD" */
"DS"="STUDYID, USUBJID, DSSTDTC, DSCAT, DSDECOD" /* DSSTDY can be missing in the test data MJA 2013-12-16  */
"MH"="STUDYID, USUBJID, MHCAT, MHTERM, MHDTC, MHSTDTC"
"DA"="STUDYID, USUBJID, DATESTCD, DADTC"
"EG"="STUDYID, USUBJID, EGTESTCD, EGDTC, VISITNUM"
"IE"="STUDYID, USUBJID, IETESTCD"
"LB"="STUDYID, USUBJID, LBCAT, LBMETHOD, LBTESTCD, LBDTC, VISITNUM"
"PE"="STUDYID, USUBJID, PETESTCD, PEDTC, VISITNUM"
"QSCG"="STUDYID, USUBJID, QSCAT, QSTESTCD, QSDTC, VISITNUM"
"QSCS"="STUDYID, USUBJID, QSCAT, QSTESTCD, QSDTC, VISITNUM"
"QSMM"="STUDYID, USUBJID, QSCAT, QSTESTCD, QSDTC, VISITNUM"
"SC"="STUDYID, USUBJID, SCTESTCD"
"VS"="STUDYID, USUBJID, VSTESTCD, VSDTC, VISITNUM, VSPOS"
"SUPPAE"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPCM"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPDM"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPEG"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPEX"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPLB"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPQSCG"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPQSCS"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPQSMM"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
"SUPPVS"="STUDYID, RDOMAIN, USUBJID, IDVAR, IDVARVAL, QNAM"
;
run;


%MACRO Import_XPT_export_SQL(dslist=,dirxpt=);

%local ds i n;
%let n=%sysfunc(countw(&dslist,%str( )));
%do i=1 %to &n;

%let ds=%scan(&dslist,&i,%str( ));

libname inxpt xport "&dirxpt./&ds..xpt";
proc copy in=inxpt out=work;
run;
libname inxpt clear;

                                                           
ods tagsets.sqlmod  options(PRIMARYKEYVARLIST="%trim(%qsysfunc(putc(&ds.,$dk.)))");

  proc print data=work.&ds.;
  run;

%end;

%MEND;

filename sqlfile "final_metadata_sdtm.sql";
ods tagsets.sqlmod file=sqlfile;

ods listing exclude all; * no output to listing file;

/*
dslist=TA TE TI TS TV DM SE SV CM EX AE DS MH DA EG IE LB PE QSCG QSCS QSMM
       SC VS SUPPAE SUPPCM SUPPDM SUPPEG SUPPEX SUPPLB SUPPQSCG SUPPQSCS
       SUPPQSMM SUPPVS,
*/                                                            
%Import_XPT_export_SQL(
dslist=DM,
dirxpt=..\external-downloads\CDISC-final-metadata-source\final_metadata\tabulations\sdtm
)

ods listing select all;

ods tagsets.sqlmod close;

filename rqex1 "dm-freq-sex.rq"; /* trick to get pathname below */
filename rqex2 "dm-summary-age.rq";

%put Example command for d2rq - to be executed in the d2rq directory;
%put Make sdtm.ttl containing the data as turtle;
%put dump-rdf -l %sysfunc(pathname(sqlfile)) -o sdtm.ttl;
%put Make sdtm-mapping.ttl containing the mapping information;
%put generate-mapping -l %sysfunc(pathname(sqlfile)) -o sdtm-mapping.ttl;
%put Make a sample query;
%put d2r-query -l %sysfunc(pathname(sqlfile)) "SELECT * { ?s ?p ?o } LIMIT 10";
%put Make a sample query corresponding to a PROC freq;
%put d2r-query -l %sysfunc(pathname(sqlfile)) @%sysfunc(pathname(rqex1));
%put Make a sample query corresponding to a PROC summary;
%put d2r-query -l %sysfunc(pathname(sqlfile)) @%sysfunc(pathname(rqex2));
%put Make a sample query corresponding to a PROC summary and get the output in turtle;
%put d2r-query -f ttl -l %sysfunc(pathname(sqlfile)) @%sysfunc(pathname(rqex2));

/*
proc contents data=work.dm varnum;
run;
*/
                                                            
proc tabulate data=work.dm missing;
class sex;
var age;
table sex, n*f=f5.0 pctn<sex>*f=f6.2;
table age, n*f=f5.0 (mean std)*f=f4.1;
run;

                                                            

