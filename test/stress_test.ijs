NB. Copyright 2014, Jsoftware Inc.  All rights reserved.
NB. test ref/reference with gen ref2 tables and random deletes/inserts

sortit=: 3 : 0
a=. jd'read from a,a.b'
i=.({."1 a)i.<'a.akey'
akeys=.  /:;{:1{a
v=. (<akeys){each {:"1 a
({."1 a),.v
)


NB. table a 100 delete/insert 
adi=: 3 : 0
a=. ,;{:jd'reads akey from a'
a=. rows{.((#a)?#a){a
for_i. a do.
 n=. jd'read from a where akey=',":i
 jd'delete a';'akey=',":i
 jd'insert a';,n
end.
)

NB. table b 100 delete/insert
bdi=: 3 : 0
a=. ,;{:jd'reads bref from b'
a=. rows{.((#a)?#a){a
for_i. a do.
 n=. jd'read from b where bref=',":i
 jd'delete b';'bref=',":i
 jd'insert b';,n
end.
)

NB. jd'dropdynamic'
NB. jd'reference a aref b bref'
testgen1=: 4 : 0
arows=: y
brows=: <.-:y
jdadminx'test'
jd'gen ref2 a A 0 b B'rplc 'A';(":arows);'B';":brows
if. x-:'reference' do.
 jd'dropdynamic'
 jd'reference a aref b bref'
 assert basedata-: jd'read from a,a.b'
elseif. x-:'ref' do.
 basedata=: jd'read from a,a.b'
elseif. 1 do.
 assert 0
end. 
i.0 0
)

test1=: 3 : 0
for. i.loop do.
 adi''
 assert basedata-:sortit''
 bdi''
 assert basedata-:sortit''
end. 
c=. jdglc_jd_'a jdactive'
assert (#dat__c)-:arows+rows*loop
c=. jdglc_jd_'b jdactive'
assert (#dat__c)-:brows+rows*loop
assert (i.arows)-: /:~,;{:jd'reads akey from a'
assert (i.brows)-: /:~,;{:jd'reads bref from b'
a=. ,each{:"1 jd'read from a,a.b where akey=0'
b=. ,each (0;0;0;'abc defabc d';0)
assert a-:b
) 

test=: 3 : 0
'arows loop rows'=: y
'ref'testgen1 arows
test1''

NB. delete b bref=1 bref=2
NB. verify a,a.b akey=1 or akey=2 default


'reference'testgen1 arows
test1''
assert (jd'reads from a,a.b')-:jd'reads from a,a-b' NB. reference left1 sames as inner when only 1 b match

NB. delete b bref=1 bref=2
NB. verify a,a.b akey=1 or akey=2 defaults
NB. veriry a,a-b akey=1 or akey=2 empty


i.0 0
)

test 20 10 5 NB. 10 rows in table a, 10 loops of 5 deletes/inserts 