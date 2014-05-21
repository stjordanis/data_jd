NB. Copyright 2014, Jsoftware Inc.  All rights reserved.
coclass 'jdtindex'
coclass deftype 'autoindex'

STATE=: ;:'typ'
makecolfiles=: writestate
shape=: ''

visible =: 0
MAP =: 0$a:
select =: ]

defquery =: 3 : 0
template =. 'name =: 3 : ''(i.Tlen) I.@:(func"_1 _) y'''
template =. template;'namec =: 3 : ''Tlen I.@:(func"_1)&i. Tlen__y'''
template =. template,<'namef =: 2 : ''u I.@:(func"_1) v [ y'''
".&.> template rplc&.> <('name';'func') ,@,. y
EMPTY
)
defqueries 0 :0
qequal        =
qnotequal     ~:
qin           e.
qnotin        -.@e.
qless         <
qlessequal    <:
qgreater      >
qgreaterequal >:
)
qequal =: qin =: #~ (=<.)
qequalc =: qinc =: 3 : 'i. Tlen <. Tlen__y'
qless =: i.@>.
qlessequal =: i.@>:@<.
qgreater =: ".@:('Tlen'"_) (] + i.@-)`(0$0:)@.< >:@<.
qgreaterequal =: ".@:('Tlen'"_) (] + i.@-)`(0$0:)@.< >.
