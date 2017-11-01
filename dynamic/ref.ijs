NB. Copyright 2014, Jsoftware Inc.  All rights reserved.
coclass 'jdtref'
coinsert 'jddbase'
coinsert 'jdtindex'

0 : 0
ref has only dat and supports only left1 join
#dat is Tlen or 0 if dirty
join sets dat if required by dirty
Subscription 0 has referencing columns
Subscription 1 has referenced column

delete left - leaves dirty as is
delete right - sets dirty
insert left/right - sets dirty
update left/right col in reference - sets dirty
)

typ =: 'ref'
MAP =: <'dat'
STATE=: STATE_jddbase_,'dirty';'left'
dirty=: 1
left=: 0  NB. left1 vs left1/left/innder

opentyp =: ]

NB. y 0 or 1
setdirty=: 3 : 0
if. dirty=y do. return. end.
if. y do. dat=: 0#2 end.
dirty=: y
writestate''
)

NB. create with empty mapped file
dynamicinit=: 3 : 0
y=. 'dat'
jdcreatejmf (PATH,y);HS_jmf_
jdmap (y,Cloc);PATH,y
(y)=: i.0
writestate''
)

getmapsize=: 3 : 0
try.
  msize_jmf_ 6 pick (({."1 mappings_jmf_) i. <y,Cloc){mappings_jmf_
catch.
  0
end.
)

NB. left1 join - set dat column
setdat=: 3 : 0
if. -.dirty do. return. end.
if. left do.
 setdatleft''
else.
 setdatleft1''
end.
)

setdatleft1=: 3 : 0
d=. getdb''
cola=. ;{.1{subscriptions
colb=. ;{.0{subscriptions
if. 1=#;{:1{subscriptions do. NB. single col
 a=. jdgl cola,' ', ;;{:1{subscriptions
 b=. jdgl colb,' ', ;;{:0{subscriptions
 ac=. #dat__a 
 bc=. #dat__b
 if. (bc*8)>getmapsize'dat' do.
  resizemap 'dat' ; bc*8
 end.
 dat=: dat__a i: dat__b NB. i:
else. NB. multiple col
 a=. stitch 1{subscriptions
 b=. stitch 0{subscriptions
 ac=. #a 
 bc=. #b
 if. (bc*8)>getmapsize'dat' do.
  resizemap 'dat' ; bc*8
 end.
 dat=: a i: b
end. 
dat=: _1 ((dat=ac)#i.#dat)}dat
setdirty 0
)

NB. setdat for left join
NB. option /left determines if dat is left or left
NB. inner derives from left dropping last rows with -1
NB. left1 derives from left by selecting only last row values
NB. left1 and inner can be easily and efficiently derived from left join dat
datleft=: 4 : 0
if. 1=$$x do.
 r=. y =/ x
else.
 r=. (<"1 y) =/ <"1 x
end.
s=. +/r
left=. s#i.#x
none=. (s=0)#i.#x
c=. (#x)*#y
right=. (,|:r)#c$i.#y
left=. left,none
right=. right,(#none)#_1
(_1,left),:_1,right
)

setdatleft=: 3 : 0
d=. getdb''
cola=. ;{.1{subscriptions
colb=. ;{.0{subscriptions
if. 1=#;{:1{subscriptions do. NB. single col
 a=. jdgl cola,' ', ;;{:1{subscriptions
 b=. jdgl colb,' ', ;;{:0{subscriptions
 r=. dat__b datleft dat__a 
else. NB. multiple col
 a=. stitch 1{subscriptions
 b=. stitch 0{subscriptions
 r=. b datleft a
end.
size=. 8**/$r
if. size>getmapsize'dat' do. resizemap 'dat' ; size end.
dat=: r
setdirty 0
)

NB. dat may be out of date - ensure it is current
select =: 3 : 0
setdat''
y{dat
)

getreferenced=: 3 : 0
getloc '^.^.',>{.{:subscriptions
)

NB. fix join based on where result
NB. where_stuff fixr joindata 
fixr=: 4 : 0
select. #x
case. 0 do. y
case. 1 do. ,._1 _1
case.   do.
 x=. }.x NB. remove leading _1 for nulls as we don't keep nulls
 _1,.(#"1~ e.&x@:{:)^:(*@#x) y NB.remove based on r
end.  
)

default_join =: 3 : 0
setdat''
'l r' =. y
'Tl Tr' =. ([:getloc '^.^.'&,)&.> {."1 subscriptions
'join - should not happen' assert 0=#l
if. left do.
 NB. derive left1 from left
 last=. ({.dat)i:i.Tlen__Tl
 r fixr last{"1 dat
else.
 r fixr _1 ,. (i.Tlen__Tl) ,: dat
end.
)

right_join=: outer_join=: 3 : 0
'right-join and outer-join not supported'assert 0
)

left_join=: 3 : 0
'left join requires ref built with /left'assert left
setdat''
'l r' =. y
'Tl Tr' =. ([:getloc '^.^.'&,)&.> {."1 subscriptions
'join - should not happen' assert 0=#l
r fixr dat
)

inner_join=: 3 : 0
'inner join requires ref built with /left'assert left
setdat''
'l r' =. y
'Tl Tr' =. ([:getloc '^.^.'&,)&.> {."1 subscriptions
'join - should not happen' assert 0=#l
r fixr (1,_1~:}.{:dat)#"1 dat
)
