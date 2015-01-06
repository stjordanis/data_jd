NB. Copyright 2014, Jsoftware Inc.  All rights reserved.

NB. Jd epochdt (epoch datetime) is nanoseconds from 2000-01-01
NB. utilities convert between epochdt and iso 8601 extended format

efs_jd_ '2000-01-01' NB. epochdt 0 is 2000-01-01
efs_jd_ '2105'       NB. nanoseconds from 2000 to 2105
efs_jd_ '1970-01-01' NB. negative for nanoseconds before 2000
assert 'assertion failure'-:efs_jd_ etx '1700'   NB. before 1800 is invalid
assert 'assertion failure'-:efs_jd_ etx '2300'   NB. after  2200 is invalid

efsx_jd_ '1700'  NB. canonical invalid date rather than error
efsx_jd_ '2300'  NB. canonical invalid date rather than error
efsx_jd_ '????'  NB. canonical invalid date rather than error

sfe_jd_ efs_jd_ '1970'

NB. iso 8601 examples
NB. -T:.,+- decorators required and validated
NB. . or , separates seconds from nanoseconds
a=: ><;._2 [ 0 : 0
2014-10-11T12:13:14.123456789+05:30
2014-10-11T12:13:14,123456789+05
2014-10-11T12:13:14.123456789
2014-10-11T12:13:14.123456789
2014-10-11T12:13:14.123
2014-10-11T12:13:14
2014-10-11T12:13
2014-10-11T12:13
2014-10-11T12+05
2014-10-11T12
2014-10-11
2014
)

[e=: efs_jd_ a NB. convert iso 8601 to epochdt

sfe_jd_ e NB. convert epochdt to iso 8601

(sfe_jd_ e),.' ',.a NB. epochdt converted to 8601 , original 8601

[eo=: eofs_jd_ a NB. convert iso 8061 to epochdt and also get utc offset in minutes
(":|:>eo),.' ',.a NB. epochdt , utc offset , original 8601

assert eo-:466364594123456789 466362794123456789 466344794123456789 466344794123456789 466344794123000000 466344794000000000 466344780000000000 466344780000000000 466362000000000000 466344000000000000 466300800000000000 441849600000000000;330 300 0 0 0 0 0 0 300 0 0 0

'. n'sfe_jd_ e NB. . instead of , elide Z and nano
'. m'sfe_jd_ e NB. milli

NB. there are 4 epochdt col types - epochdt values are ints
NB. edatetimen yyyy-mm-ddThh:mm:ss,nnnnnnnnn
NB. edatetimem yyyy-mm-ddThh:mm:ss,nnn
NB. edatetime  yyyy-mm-ddThh:mm:ss
NB. edate      yyyy-mm-dd

NB. inserted data can be in iso 8601 format or in epochdt ints
NB. inserted data is validated to not have extra precision
NB. read of epochdt data is formatted to iso 8601 (unless reads with /e)

NB. edatetimen nano
jdadminx'test'
jd'createtable f a edatetimen' NB. epoch with nanos
jd'insert f a';a               NB. conversion done in Jd
jd'insert f a';efs_jd_'2016'   NB. conversion done in client
jd'insert f a';'2017'
jd'reads from f'
jd'reads from f where a="2014"'
jd'reads from f where a in ("2014","2017")'
d=. (":efs_jd_ '2014',:'2017')rplc ' ',','
jd'reads from f where a in (',d,')'
jd'reads from f where a>"2014-10-11T12:13:14"'
[efs_jd_ '2014-10-11T12:13:14'
jd'reads from f where a>466344794000000000'
jd'reads /e from f' NB. epoch int rather than formatted to iso 8601
jd'get f a'         NB. raw column data

NB. edatetimem milli
jdadminx'test'
jd'createtable f a edatetimem' NB. epoch with milli
jd'insert f a';'2014-10-11T12:13:14'
jd'insert f a';'2014-10-11T12:13:14,123'
'domain error'-:jd etx 'insert f a';'2014-10-11T12:13:14,123456' NB. extra precision is an error
'domain error'-:jd etx 'insert f a';efs_jd_ '2014-10-11T12:13:14,123456'
jd'reads from f'

NB. edatetime
jdadminx'test'
jd'createtable f a edatetime' NB. epoch with nano
jd'insert f a';'2014-10-11T12:13:14'
'domain error'-:jd etx 'insert f a';'2014-10-11T12:13:14,123' NB. extra precision is an error
'domain error'-:jd etx 'insert f a';efs_jd_'2014-10-11T12:13:14,123'
'domain error'-:jd etx 'insert f a';'2014-10-11T12:13:14,123',:'2014'

NB. edate
jdadminx'test'
jd'createtable f a edate'
jd'insert f a';'2014-10-11',:'2015-01-01'
'domain error'-:jd etx 'insert f a';'2015-10-11T12:13:14' NB. extra precision is an error
'domain error'-:jd etx 'insert f a';efs_jd_ '2015-10-11T12:13:14'
jd'reads from f where a>"2014-10-11T10:11:11"' NB. extra precision allowed in where clause
jd'reads from f'

NB. by year from temp col derived from edatetimen col
jdadminx'test'
jd'createtable f a edatetimen'
'a b'=: efs_jd_ '2014-09-10',:'2016-10-11'
d=. <.(b-a)%10
m=. a+d*i.10 NB. 10 random between a and b
jd'insert f a';m
jd'reads from f'
jd'createcol f b int _';>:i.10

NB. readtc creates temp col of year from epochdt to sum by
jd'readtc :::f_year=: 4{."1 sfe_jd_ f_a::: sum b by year from f'

NB. by year from permanent year col
jd'createcol f y byte 4';4{."1 sfe_jd_ jd'get f a' NB. column of year
jd'reads from f'
jd'reads sum b by y from f'


NB. get epochdt time and utc offset
[a=: eofs_jd_ '2014-01-02T03:04:05+05:30',:'2014-02-03T10:11:12-05:30'

jdadminx'test'
jd'createtable f a edatetimen, a_offset int'
jd'insert f';,(;:'a a_offset'),.a
[a=: jd'reads from f'

NB. csv
jdadminx'test'
CSVFOLDER=: F=: jpath'~temp/jd/csv/junk/'
jdcreatefolder_jd_ F

a=: 0 : 0
2014-01-02T03:04:05+05:30
2014-02-03T10:11:12,123456789-05:30
)

adef=: 0 : 0
1 dt8601 byte 36
options TAB LF NO \ 0
)

(toJ a) fwrite F,'a.csv'
adef fwrite F,'a.cdefs'

jd'csvrd a.csv c'
[a=. jd'reads from c'
[e=: eofs_jd_ jd'get c dt8601'
jd'createcol c dta edatetimen _';>{.e
jd'createcol c offset int _';>{:e
jd'reads from c'