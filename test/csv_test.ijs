NB. Copyright 2015, Jsoftware Inc.  All rights reserved.
CSVFOLDER=: '~temp/jd/csv/Ø Ø' NB. note utf8 and blank in path
jddeletefolder_jd_ CSVFOLDER

NB. enum type removed as it is not fully supported
nms =. toupper&.> types =. ;:'boolean int float byte varbyte'
DATA =: <@".;._2 ]0 :0
1 0 1
12 _15 6728637560195710578
0.5 _1.2 6.92857499
LF,TAB,0{a.
'\jkl"';'ABC';256$'1234'
)

jdadminx 'test'
jd 'createtable t'; ; ,&','&.> nms (,' '&,)&.> types
jd 'insert t'; , nms,.DATA
jd'csvwr t.csv t'
jd'csvrd t.csv tx'
assert (jd'reads from t')-:jd'reads from tx'

NB. write just 4 cols and 1 row
jd'csvwr /w a.csv t  BOOLEAN BYTE FLOAT INT *INT=12'
jd'csvrd a.csv a'
assert 2 4-:$jd'reads from a'
assert 12=>{:{:jd'reads from a'

NB. epoch
jdadminx'test'
jd'createtable f'
jd'createcol f ed   edate      _';efs_jd_'1970-11-12'                   ,'2000-01-01T00:00:00,000000000Z',:'2020-11-12'
jd'createcol f edt  edatetime  _';efs_jd_'1970-12-12T10:10:10'          ,'2000-01-01T00:00:00,000000000Z',:'2020-12-12T10:10:10'
jd'createcol f edtm edatetimem _';efs_jd_'1970-12-12T11:11:11.123'      ,'2000-01-01T00:00:00,000000000Z',:'2020-12-12T11:11:11.123'
jd'createcol f edtn edatetimen _';efs_jd_'1970-12-12T12:12:12.123456789','2000-01-01T00:00:00,000000000Z',:'2020-12-12T12:12:12.123456789'

NB. csvcdefs and epoch
jd'csvwr /h1 f.csv f'
a=. dtb each <;._2 fread CSVFOLDER,'f.cdefs'
jd'csvcdefs /replace /h 1 f.csv'
b=. dtb each <;._2 fread CSVFOLDER,'f.cdefs'
assert a-:b

jd'csvwr /h1 f.csv f'
jd'csvrd f.csv fx'
assert (jd'reads from f')-:jd'reads from fx'

jd'csvwr /e f.csv f' NB. write epoch as int
assert 1=+/'iso8601-int' E. fread CSVFOLDER,'f.cdefs'
assert 0=(fread CSVFOLDER,'f.csv')-.TAB,LF,'-0123456789'
jd'droptable fx'
jd'csvrd f.csv fx'
assert (jd'reads from f')-:jd'reads from fx' NB. read epoch as ints

jd'csvwr f.csv f' NB. write epoch as int
d=. deb 0 : 0
1970-11-12                     1970-12-12T10:10:10            1970-12-12T11:11:11.123        1970-12-12T12:12:12.123456789  
2000-01-01T00:00:00,000000000Z 2000-01-01T00:00:00,000000000Z 2000-01-01T00:00:00,000000000Z 2000-01-01T00:00:00,000000000Z 
2020-11-12                     2020-12-12T10:10:10            2020-12-12T11:11:11.123        2020-12-12T12:12:12.123456789  
)   

d=. d rplc ' ';TAB
d fwrite CSVFOLDER,'f.csv'
jd'droptable fx'
jd'csvrd f.csv fx'
assert (jd'reads from f')-:jd'reads from fx'

NB. test epoch extra precision tests
d=. deb 0 : 0
1970-11-12T10:10:10            1970-12-12T10:10:10,123        1970-12-12T11:11:11.1238       1970-12-12T12:12:12.123456789  
2000-01-01T00:00:00,000000000Z 2000-01-01T00:00:00,000000000Z 2000-01-01T00:00:00,000000000Z 2000-01-01T00:00:00,000000000Z 
2020-11-12T10:10:10            2020-12-12T10:10:10,124        2020-12-12T11:11:11.1238       2020-12-12T12:12:12.123456789  
)   

d=. d rplc ' ';TAB
d fwrite CSVFOLDER,'f.csv'
jd'droptable fx'
jd'csvrd f.csv fx'
assert (jd'reads from f')-:jd'reads from fx'
r=. jd'csvreport fx'
assert 1=+/'ed   ECEPOCHP    extra precision ignored 2' E. r
assert 1=+/'edt  ECEPOCHP    extra precision ignored 2' E. r
assert 1=+/'edtm ECEPOCHP    extra precision ignored 2' E. r

NB. test epoch bad data
d=. deb 0 : 0
1970-11-12x                    1970-12-12x10:10:10            1970-12-12x11:11:11.123        1970-12-12x12:12:12.123456789  
2000-01-01x00:00:00,000000000Z 2000-01-01x00:00:00,000000000Z 2000-01-01x00:00:00,000000000Z 2000-01-01x00:00:00,000000000Z 
2020-11-12x                    2020-12-12x10:10:10            2020-12-12x11:11:11.123        2020-12-12x12:12:12.123456789  
)   

d=. d rplc ' ';TAB
d fwrite CSVFOLDER,'f.csv'
jd'droptable fx'
jd'csvrd f.csv fx'
r=. jd'csvreport fx'
assert 1=+/'ed   ECEPOCH     bad epoch 3' E. r
assert 1=+/'edt  ECEPOCH     bad epoch 3' E. r
assert 1=+/'edtm ECEPOCH     bad epoch 3' E. r
assert 1=+/'edtn ECEPOCH     bad epoch 3' E. r


NB. test csvdump/csvrestore /e
f=.  jd'reads from f'
fx=. jd'reads from fx'
jddeletefolder_jd_ CSVFOLDER
jd'csvdump'
assert 1=+/'iso8601-char' E. fread CSVFOLDER,'f.cdefs'
assert 0~:(fread CSVFOLDER,'f.csv')-.TAB,LF,'-0123456789'
assert 1=+/'iso8601-char' E. fread CSVFOLDER,'fx.cdefs'
assert 0~:(fread CSVFOLDER,'fx.csv')-.TAB,LF,'-0123456789'
jd'dropdb'
jd'createdb'
jd'csvrestore'
assert f-:jd'reads from f'
assert fx-:jd'reads from fx'

jddeletefolder_jd_ CSVFOLDER
jd'csvdump /e'
assert 1=+/'iso8601-int' E. fread CSVFOLDER,'f.cdefs'
assert 0=(fread CSVFOLDER,'f.csv')-.TAB,LF,'-0123456789'
assert 1=+/'iso8601-int' E. fread CSVFOLDER,'fx.cdefs'
assert 0=(fread CSVFOLDER,'fx.csv')-.TAB,LF,'-0123456789'
jd'dropdb'
jd'createdb'
jd'csvrestore'
assert f-:jd'reads from f'
assert fx-:jd'reads from fx'


NB. Tests for shaped columns
jd 'droptable t'

NB. varbyte shaped not allowed
nms=. nms-.<'VARBYTE'
types=. types-.<'varbyte'
DATA=. }:DATA

jd 'createtable t'; ; ,&','&.> nms (,' ',,&' 3')&.> types NB. shaped varbyte no allowed
jd 'insert t'; , nms,. ,:&.>DATA

NB.! CSTITCH does not work for boolean or varbyte
jd'dropcol t BOOLEAN'
jd'dropcol t VARBYTE'


jd'csvwr q.csv t'
jd'droptable tx'
jd'csvrd q.csv tx'
assert (jd'reads from t')-:jd'reads from tx'

NB. empty tables in dump restore
jdadminx'test'
jd'createtable f'
jd'createcol f a int'
d=. jd'reads from f'
jddeletefolder_jd_ CSVFOLDER
jd'csvdump'
jd'dropdb'
jd'createdb'
jd'csvrestore'
assert d-:jd'reads from f'