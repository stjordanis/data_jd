NB. Copyright 2017, Jsoftware Inc.  All rights reserved.
coclass 'jdtable'

throw=: 13!:8&101 NB. jd not in our path

CLASS=: <'jdtable'
CHILD=: <'jdcolumn'

NB. =========================================================
Padvar=: 1.5     NB. ratio to increase by on resize

NB. =========================================================
NB. State
STATE=: <;._2 ]0 :0
Tlen
S_ptable
SUBSCR
ROWSMIN
ROWSXTRA
ROWSMULT
)

Tlen=: 0
S_ptable=: 0
SUBSCR=: 0 3$a: NB. see dynamic/base.ijs
ROWSMIN=:  2000
ROWSXTRA=: 0
ROWSMULT=: 1.5

NB. =========================================================
HIDCOL=: <'jdindex'
getvisiblestatic=: #~ 3 :'visible__y *. static__y'@getloc@>^:(*@#)

getdefaultselection=: 3 : 0
f=. PATH,'column_create_order.txt'
n=. NAMES
n=. (-.(<'jd')=2{.each n)#n
if. optionsort +. -.fexist f do.
 /:~n
else. 
 con=. ~.n,~<;._1 ' ',deb jdfread f
 (con e. n)#con
end.
)

setTlen=: 3 : 0
Tlen=: y
writestate''
)

openflag=: 0 NB. old style tests

open=: 3 : 0
openflag=: 1
)

testcreate=: 4 : 0
'cols data alloc'=. 3{.y,3#a:
cols =. ({.~ i.&' ')&.> cutcoldefs toJ cols
vcname_jd_ each cols
if. *@# data do.
  assert. ((2=#@$)*.2={:@$) cols&,.`,:@.((1=#cols)*.2=#)^:(2>#@$) data
end.
)

NB. only old style testall calls have data
create=: 3 : 0
NB. if. 2=#y do. 1+'a' end.
'cols data alloc'=. 3{.y,3#a:
if. 3~:#alloc do. alloc=. ROWSMIN_jdtable_,ROWSMULT_jdtable_,ROWSXTRA_jdtable_ end.
'ROWSMIN ROWSMULT ROWSXTRA'=: 4 1 0>.alloc
writestate''
index=: Create 'jdindex' ;'autoindex' ;$0
InsertCols^:(*@#) cols
cols=. getdefaultselection''
Insert@:(cols&,.`,:@.((1=#cols)*.2=#)^:(2>#@$))^:(*@#) data
)

close =: ]

NB. SECTION col

NB. =========================================================
DeleteCols=: 3 : 0
Drop@> ~. cutnames y
)

NB. =========================================================
InsertCols=: [: InsertCol@> [: cutcoldefs toJ
cutcoldefs=: a: -.~ [: (<@deb;._2~ e.&(',',LF)) ,&LF

InsertCol=: 3 : 0
cutsp =. i.&' ' ({.;}.) ]
'nam typ'=. cutsp y
'typ shape'=. cutsp deb typ
if. ifhash =. typ-:'hash' do.
  'typ shape'=. cutsp }.shape
end.
shape =. ,".shape
if. (<typ) -.@e. DATATYPES do. throw '101 Invalid datatype: ',typ end.
Create nam;typ;shape
if. ifhash do. MakeHashed nam end.
)

NB. y is index of rows to compress out
NB. jdref col marked dirty
Delete=: 3 : 0
 1 update_subscr''
 b=. -.(i.Tlen)e.y
 for_i. i.#CHILDREN do.
  c=. i{CHILDREN
  getloc NAME__c NB. map as required
  if. (<'jdindex')=i{NAMES do.
   continue
  elseif. (<'jd')=2{.each i{NAMES do.
   setdirty__c 1
  elseif. 1 do.
   dat__c=. b#dat__c
  end. 
 end.
 Tlen=: +/b NB. change after all cols are adjusted
 writestate'' NB. Tlen
i.0 0
)

NB. x is _1 insert rules, # update rules, _2 keyindex rules
NB. y is  name,value pairs
NB. return (possibly adjusted) names;values;rows
NB. values are converted to appropriate type
NB. loose scalar extension
NB.  scalars treated as 1 element lists
NB.  byteN - scalars and lists extend to be tables
NB.  byten - overtake OK, but undertake is an error
NB. x is _1 for insert and required rows for update
NB. all conform work is done here - may be duplicated later on
fixpairs=: 4 : 0
'name data pairs - odd number' assert (2<:#y)*.0=2|#y
ns=. ,each(2*i.-:#y){y NB. list of names
duplicate_assert ns
notjd_assert ns
unknown_assert ns-.NAMES
if. x=_1 do. missing_assert ns-.~((<'jd')~:2{.each NAMES)#NAMES end. NB. insert
ns=. vs=. ts=. ''
for_i. i.-:#y do.
 j=. 2*i
 n=. <,;j{y
 FECOL_jd_=: >n
 EUNKNOWN assert n e. NAMES
 ns=. ns,n
 c=. 0{CHILDREN{~NAMES i. n
 ts=. ts,<shape__c
 d=. fixtypex__c >(>:j){y
 if. -.''-:shape__c do.
  'fixpairs: bad shape'assert 'byte'-:typ__c
  if. 0=$$d do. d=. ,d end.
  if. 1=$$d do. d=. ,:d end.
  ESHAPE assert ({:$d)<:shape__c 
  d=. shape__c{."1 d
 end.
 select. typ__c
 case. 'edate' do.
  EPRECISION assert *./(0=(86400*1e9)|d)+._9223372036854775808=d
 case. 'edatetime' do.
  EPRECISION assert *./(0=1e9|d)+._9223372036854775808=d
 case. 'edatetimem' do.
  EPRECISION assert *./(0=1e6|d)+._9223372036854775808=d
 end.
 d=. <d
 vs=. vs,d
 i=. >:i
end.
t=. ;#each vs
ETALLY assert 0=#t-.1,>./t
m=. x>.>./t
if. (1 e.t)*.1<m do. NB. scalar extension
 for_i. i.#vs do.
  d=. >i{vs 
  if. 1=#d do.
   vs=. (<m#d) i}vs
  end.
 end.
end.
t=. ;#each vs
rows=. {.t
'fixpairs: bad count'assert rows=t
if. x>:0 do. ETALLY assert x=rows end.

ESHAPE assert (}.each$each vs)=ts

ns;vs;rows
)

NB. x is rows to add to each col
NB. y is (column names),.(new data)
Insert=: 4 : 0

N=.,&.> {."1 y
dat=. {:"1 y

step0=. getloc@> N
rows=. Tlen
setTlen Tlen+x  NB. 
update_subscr'' NB. mark ref cols dirty

try.
 step0  4 :'Insert__x >y'"0  dat NB. step 0: insert static columns
 1+FORCEREVERT#'a'
catchd.
 FORCEREVERT_jd_=: 0
 NB. this could/should be fixed to repair the table
 NB. needs to jam all columns to have original Tle
 NB. needs to mark dynamic cols dirty
 NB. has to do everything that repair would do
 NB. for now, just mark the db damaged and let repair do the hard work
 setTlen rows NB. original rows
 jddamage'insert failed'
end.
EMPTY
)

NB. =========================================================
NB. Read is found in read.ijs
Readr=: getwhere
Reads=: ({."1 ,: [:tocolumn{:"1)@:Read

NB. Write table to the given csv file.
WriteCsv =: 3 : 0
'file headers nms rws epoch new'=. y
l =. #cols =. getloc@> nms
byte =. (;:'byte enum') e.~ typ =. 3 :'<typ__y'"0 cols
sh1 =. byte }:@]^:[&.> shape =. 3 :'<shape__y'"0 cols
torow =. LF _1} (TAB,~deb)&.>(;@:)
fmt =. [ ` (, '_jdstitch' , [: =&' '`(,:&'_')} ":) @. (0<+/@])
h1 =. ;nms (<@fmt"_ 1 ,/^:(0>.2-~#@$)@:(#:i.))&.> sh1
h2 =. (*/@> sh1) # typ ,&.> byte ((*. *@#) # ' ',":@{:@])&.> shape
f =. jpath file
if. new do. (; <@torow"1 headers {. h1 ,: h2) jdfwrite f end.
t =. 3|>: (;:'varbyte enum') i. typ
if. epoch do.
 et=. (#typ)#0
 seputc=. (2*#typ)$' '
else.
 et=. 5|>: (;:'edate edatetime edatetimem edatetimen')i.typ
 seputc=. ,3 : 'try.sep__y,utc__y,''''catch.'',Z''end.' "0 cols
end. 
ind =. +/\ 0,}:t{1 2 2
rws =. pointer_to_name 'rws'
col =. pointer_to_name@> ; 3 :'ExportMap__y $0'&.> <"0 cols
lib =. LIBJD,' writecsv > n *c x *x *x *c *x x *x'
empty lib cd f;l;t;et;seputc;ind;rws;col
)

NB. SECTION transaction handling

NB. =========================================================
NB. revert database to length y
Revert=: 3 : 0
if. y >: Tlen do. return. end.
setTlen y NB. revert
NB. Revert is handled in the type classes
3 :'Revert__y Tlen'"0  CHILDREN
)

NB. mark subscribers to y cols ('' for all cols) as dirty
NB. x 1 for delete - avoid dirty for left
update_subscr=: 3 : 0
0 update_subscr y
:
for_subs. SUBSCR do.
 if. (''-:y) +. y e. >{: subs do.
  c=. ;{.subs
  if. '^'={.c do.
   'x t c'=. <;._2 c,'.'
   w=. getdb''
   w=. getloc__w t
   w=. getcolloc__w c
   a=. 1 NB. right ref
  else.
   if. x do. continue. end. NB. delete left ref - do not mark dirty
   w=. getcolloc c
   a=. 0 NB. left ref
  end.
  setdirty__w 1
 end.
end.
)

filterbytype =: ] #~ ,@boxopen@[ e.~ 3 :'<typ__y'"0@]

NB. y is a referenced table name. Find the reference columns to it.
FindRef =: 3 : 0
s =. (<'ref') filterbytype getloc@> {."1 SUBSCR
(#~ ({.boxopen y) = 3 : '{.{:subscriptions__y'"0) s
)

getpcol=: 3 : 0
'not pcol table' assert PTM={:NAME
t=. NAMES#~-.(<'jd')=2{.each NAMES
'pcol table with more than 1 col' assert 1=#t
;t
)
