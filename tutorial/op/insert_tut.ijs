NB. Copyright 2018, Jsoftware Inc.  All rights reserved.

'new'jdadmin'tutorial'
jd'createtable f a int,b byte,b4 byte 4'
jd'insert f';'a';23;'b';'a';'b4';1 4$'abcd'
jd'reads from f'
jd'insert f';'a';24 25;'b';'bc';'b4';2 4$'aaaabbbb'
jd'reads from f'
'unknown'   jdae'insert f';'a';24 25;'xxx';'bc';'b4';2 4$'aaaabbbb'
'missing'   jdae'insert f';'a';2 3 4;'b';'abc'
'count'     jdae'insert f';'a';2 3 4;'b';'ab';'b4';3 2$'a'
'odd number'jdae'insert f';'a';2;'b'
