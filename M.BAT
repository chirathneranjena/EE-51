asm86 52test.asm db m1 ep
asm86 key.asm db m1 ep

link86 52test.obj, key.obj, hw8test.obj to keytest.lnk

loc86 keytest.lnk to keytest noic reserve(0 to 3ffh)
