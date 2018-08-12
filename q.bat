asm86 qtest.asm db m1 ep

asm86 queue.asm db m1 ep

link86 qtest.obj, queue.obj to queue.lnk

loc86 queue.lnk to queue noic reserve(0 to 3ffh)
