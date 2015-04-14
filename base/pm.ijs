NB. Copyright 2014, Jsoftware Inc.  All rights reserved.
coclass'jd'

pmhelp=: 0 : 0
   pmr_jd_''     NB. reports times for last PMMR_jd_ ops
   pmclear_jd_'' NB. clears times
   pmtotal_jd_'' NB. returns total time
   
Non-Jd times can be included.

   pm'name'      NB. start timer
   pmz''         NB. end timer
   pmz_jd_''[doit data[pm_jd_'zxcv'
)

PMMR=: 20 NB. max records kept

pmclear=: 3 : 0
PMN=: PMT=: ''
i.0 0
)

NB. record section start
pm=: 3 : 0
PMNAME=:  y
PMSTART=: 6!:9''
i.0 0
)

NB. record section end
pmz=: 3 : 0
t=. 0>.(#PMN)-<:PMMR
PMN=: t}.PMN,<PMNAME
PMT=: t}.PMT,PMSTART-~6!:9''
i.0 0
)

NB. report jd performance
pmr=: 3 : 0
t=. <.0.5+1000*PMT%6!:8''
(>PMN,<'total'),.8j0":,.t,+/t
)

pmtotal=: 3 : 0
+/<.0.5+1000*PMT%6!:8''
)