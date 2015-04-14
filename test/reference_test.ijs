NB. Copyright 2014, Jsoftware Inc.  All rights reserved.
NB. test insert/delete/update vs ref/reference
NB. test left1 join so same tests work for ref/reference

ti=: 3 : 0
jdadminx'test'
)

tc=: 4 : 0
jd'droptable';x
jd'createtable';x;'a int'
jd'insert';x;'a';y
)

tref=: 3 : 0
jd REF,' f a g a'
)

trd=: 3 : 0
;{:{:jd'read f.a from f,f.g'
)

tdata=: 3 : 0
{:"1 jd'read from f,f.g'
)

NB. find the joins based on the individual columns in order to compare
NB. with the results of read
filter =. [: (#~ [: -.@:(+./"1)@:(>|:) +./@:<"1/~) (#~ (2=[:+/2~:/\0,,&0)"1)
getouterjoin =: (([: filter&.:>@:,@:{ (0 , [ #~ =)&.>)"_ 0(;@:) ~.@;) f.

NB. y is the tables used, e.g. 'fg'
testjoins =: 3 : 0
if. REF -: 'ref' do. return. end.
j =. getouterjoin cols =. ([: {:@:{.@:jd 'read from '&,)"0 y
q =. 'read from ',}:@:;@:(,&','&.>)@:({.;2<@({.,'*',{:)\]) y
getj =. [: |:@:>@:({:"1)@:jd q rplc '*'&;
assert j -:&(/:~) getj '='                 NB. outer join
assert ((#~ 0~:{."1)j) -:&(/:~) getj '>'   NB. left join
assert ((#~ 0~:{:"1)j) -:&(/:~) getj '<'   NB. right join
assert ((#~ 0-.@e."1])j) -:&(/:~) getj '-' NB. inner join
)


NB. inserts

NB. insert records to trigger hash resize
it1=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 1 2 3
tref''
jd'insert';'f';'a';4+i.5
jd'insert';'g';'a';|.4+i.5
assert(;~>:i.8)-:tdata''
)

NB. insert records to trigger dat resize
it2=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 1 2 3
tref''
jd'insert';'f';'a';4+i.1000
jd'insert';'g';'a';|.4+i.1000
assert(;~>:i.1003)-:tdata''
)

NB. insert f
it3=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 1 2 3
tref''
jd'insert';'f';'a';5 4
assert (1 2 3 5 4;1 2 3 0 0)-:tdata''
testjoins 'fg'
)

NB. insert g
it4=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 1 2 3
tref''
jd'insert';'g';'a';5 4
assert (1 2 3;1 2 3)-:tdata''
testjoins 'fg'
)

NB. insert g then f
it5=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 1 2 3
tref''
jd'insert';'g';'a';5 4
jd'insert';'f';'a';23 5 4
assert (1 2 3 23 5 4;1 2 3 0 5 4)-:tdata''
testjoins 'fg'
)

NB. updates

NB. update f to not match g
ut1=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 3 2 1
tref''
jd'update';'f';'a=1';'a';5
assert (2 3 5;2 3 0)-:tdata''
testjoins 'fg'
)

NB. update g to not match f
ut2=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 3 2 1
tref''
jd'update';'g';'a=1';'a';5
assert (1 2 3;0 2 3)-:tdata''
testjoins 'fg'
)

NB. update g to not match f - then update f to match
ut3=: 3 : 0
ut2''
jd'update';'f';'a=1';'a';5
assert (2 3 5;2 3 5)-:tdata''
testjoins 'fg'
)

NB. deletes

NB. delete g 
dt1=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 3 2 1
tref''
assert (1 2 3;1 2 3)-:tdata''
testjoins 'fg'
jd'delete';'g';'a=1'
assert (1 2 3;0 2 3)-:tdata''
testjoins 'fg'
jd'delete';'f';'a=2'
assert (1 3;0 3)-:tdata''
testjoins 'fg'
)

NB. table f created with missing row
dt2=: 3 : 0
ti''
'f'tc 1   3
'g'tc 3 2 1
tref''
assert (1 3;1 3)-:tdata''
testjoins 'fg'
)

NB. f row deleted before ref/reference
dt3=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 3 2 1
jd'delete';'f';'a=2'
tref''
assert (1 3;1 3)-:tdata''
testjoins 'fg'
)

NB. f row deleted after ref/reference
dt4=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 3 2 1
tref''
tdata''
jd'delete';'f';'a=2'
assert (1 3;1 3)-:tdata''
testjoins 'fg'
)

NB. multi-table joins (3 tables)
Mt1=: 3 : 0
ti''
'f'tc 1 2 3
'g'tc 3 2 1
'h'tc 1 3 2
tref''
jd REF,' g a h a'
assert (1 2 3;1 2 3;1 2 3) -: {:"1 jd 'read from f,f.g,g.h'
testjoins 'fgh'

jd'update';'f';'a=1';'a';5
assert (2 3 5;2 3 0;2 3 0) -: {:"1 jd 'read from f,f.g,g.h'
testjoins 'fgh'

jd'update';'g';'a=2';'a';7
assert (2 3 5;0 3 0;0 3 0) -: {:"1 jd 'read from f,f.g,g.h'
testjoins 'fgh'

jd'update';'h';'a=3';'a';9
assert (2 3 5;0 3 0;0 0 0) -: {:"1 jd 'read from f,f.g,g.h'
testjoins 'fgh'
)

NB. test multiple cols of different types
mt1=: 3 : 0
ti''
jd'gen test f 3'
jd'gen test g 3'
jd REF,' f int byte byte4 g int byte byte4'
d=. jd'read from f,f.g'
assert ('f.x'jdfrom_jd_ d)-:'g.x'jdfrom_jd_ d
jd'delete';'f';'int=101'
d=. jd'read from f,f.g'
assert ('f.x'jdfrom_jd_ d)-:'g.x'jdfrom_jd_ d
assert 0 2-:'f.x'jdfrom_jd_ d
jd'delete';'g';'int=102'
d=. jd'read from f,f.g'
assert 0 2-:'f.x'jdfrom_jd_ d
assert 0 0-:'g.x'jdfrom_jd_ d
)

REF=: 'reference'
it1''
it2''
it3''
it4''
it5''
ut1''
ut2''
ut3''
dt1''
dt2''
dt3''
dt4''
mt1''
Mt1''