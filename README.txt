Program : final_metadata_to_sql.sas
Purpose : Import CDISC sample final_metadata and export as sql dump
Note    : The sql dump is intended for processing by d2rq (http://www.d2rq.org) 
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

Examples

Example command for d2rq - to be executed in the d2rq directory;

Make sdtm.ttl containing the data as turtle;

dump-rdf -l %sysfunc(pathname(sqlfile)) -o sdtm.ttl;

Make sdtm-mapping.ttl containing the mapping information;

generate-mapping -l %sysfunc(pathname(sqlfile)) -o sdtm-mapping.ttl;

Make a sample query;

d2r-query -l %sysfunc(pathname(sqlfile)) "SELECT * { ?s ?p ?o } LIMIT 10";

Make a sample query corresponding to a PROC freq;

d2r-query -l %sysfunc(pathname(sqlfile)) @%sysfunc(pathname(rqex1));

Make a sample query corresponding to a PROC summary;

d2r-query -l %sysfunc(pathname(sqlfile)) @%sysfunc(pathname(rqex2));

Make a sample query corresponding to a PROC summary and get the output in turtle;

d2r-query -f ttl -l %sysfunc(pathname(sqlfile)) @%sysfunc(pathname(rqex2));
