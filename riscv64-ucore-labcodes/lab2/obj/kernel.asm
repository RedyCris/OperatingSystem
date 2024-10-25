
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buddy_s>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	51e60613          	addi	a2,a2,1310 # ffffffffc0206558 <end>
ffffffffc0200042:	1141                	addi	sp,sp,-16
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
ffffffffc0200048:	e406                	sd	ra,8(sp)
ffffffffc020004a:	704010ef          	jal	ra,ffffffffc020174e <memset>
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	70e50513          	addi	a0,a0,1806 # ffffffffc0201760 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>
ffffffffc0200066:	012010ef          	jal	ra,ffffffffc0201078 <pmm_init>
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200084:	401c                	lw	a5,0(s0)
ffffffffc0200086:	60a2                	ld	ra,8(sp)
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
ffffffffc02000a4:	c602                	sw	zero,12(sp)
ffffffffc02000a6:	1d2010ef          	jal	ra,ffffffffc0201278 <vprintfmt>
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
ffffffffc02000b2:	711d                	addi	sp,sp,-96
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
ffffffffc02000da:	c202                	sw	zero,4(sp)
ffffffffc02000dc:	19c010ef          	jal	ra,ffffffffc0201278 <vprintfmt>
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
ffffffffc020013a:	1141                	addi	sp,sp,-16
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	64450513          	addi	a0,a0,1604 # ffffffffc0201780 <etext+0x20>
ffffffffc0200144:	e406                	sd	ra,8(sp)
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	64e50513          	addi	a0,a0,1614 # ffffffffc02017a0 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	60258593          	addi	a1,a1,1538 # ffffffffc0201760 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	65a50513          	addi	a0,a0,1626 # ffffffffc02017c0 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buddy_s>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	66650513          	addi	a0,a0,1638 # ffffffffc02017e0 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	3d258593          	addi	a1,a1,978 # ffffffffc0206558 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	67250513          	addi	a0,a0,1650 # ffffffffc0201800 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	7bd58593          	addi	a1,a1,1981 # ffffffffc0206957 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	66450513          	addi	a0,a0,1636 # ffffffffc0201820 <etext+0xc0>
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
ffffffffc02001c8:	1141                	addi	sp,sp,-16
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	68660613          	addi	a2,a2,1670 # ffffffffc0201850 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	69250513          	addi	a0,a0,1682 # ffffffffc0201868 <etext+0x108>
ffffffffc02001de:	e406                	sd	ra,8(sp)
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
ffffffffc02001e4:	1141                	addi	sp,sp,-16
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	69a60613          	addi	a2,a2,1690 # ffffffffc0201880 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	6b258593          	addi	a1,a1,1714 # ffffffffc02018a0 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	6b250513          	addi	a0,a0,1714 # ffffffffc02018a8 <etext+0x148>
ffffffffc02001fe:	e406                	sd	ra,8(sp)
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	6b460613          	addi	a2,a2,1716 # ffffffffc02018b8 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	6d458593          	addi	a1,a1,1748 # ffffffffc02018e0 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	69450513          	addi	a0,a0,1684 # ffffffffc02018a8 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	6d060613          	addi	a2,a2,1744 # ffffffffc02018f0 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	6e858593          	addi	a1,a1,1768 # ffffffffc0201910 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	67850513          	addi	a0,a0,1656 # ffffffffc02018a8 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	6b650513          	addi	a0,a0,1718 # ffffffffc0201920 <etext+0x1c0>
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	6bc50513          	addi	a0,a0,1724 # ffffffffc0201948 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	716c0c13          	addi	s8,s8,1814 # ffffffffc02019b8 <commands>
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	6c690913          	addi	s2,s2,1734 # ffffffffc0201970 <etext+0x210>
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	6c648493          	addi	s1,s1,1734 # ffffffffc0201978 <etext+0x218>
ffffffffc02002ba:	49bd                	li	s3,15
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	6c4b0b13          	addi	s6,s6,1732 # ffffffffc0201980 <etext+0x220>
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	5dca0a13          	addi	s4,s4,1500 # ffffffffc02018a0 <etext+0x140>
ffffffffc02002cc:	4a8d                	li	s5,3
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	32a010ef          	jal	ra,ffffffffc02015fa <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
ffffffffc02002dc:	4c81                	li	s9,0
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	6d2d0d13          	addi	s10,s10,1746 # ffffffffc02019b8 <commands>
ffffffffc02002ee:	8552                	mv	a0,s4
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
ffffffffc02002f4:	426010ef          	jal	ra,ffffffffc020171a <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	412010ef          	jal	ra,ffffffffc020171a <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	3f2010ef          	jal	ra,ffffffffc0201738 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
ffffffffc0200374:	2c85                	addiw	s9,s9,1
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
ffffffffc020037e:	0405                	addi	s0,s0,1
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	3b4010ef          	jal	ra,ffffffffc0201738 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	60250513          	addi	a0,a0,1538 # ffffffffc02019a0 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	16430313          	addi	t1,t1,356 # ffffffffc0206510 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	62650513          	addi	a0,a0,1574 # ffffffffc0201a00 <commands+0x48>
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	ea050513          	addi	a0,a0,-352 # ffffffffc0202290 <commands+0x8d8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200414:	c0102573          	rdtime	a0
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	2a8010ef          	jal	ra,ffffffffc02016c8 <sbi_set_timer>
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0e07b923          	sd	zero,242(a5) # ffffffffc0206518 <ticks>
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	5f250513          	addi	a0,a0,1522 # ffffffffc0201a20 <commands+0x68>
ffffffffc0200436:	0141                	addi	sp,sp,16
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
ffffffffc020043a:	c0102573          	rdtime	a0
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	2820106f          	j	ffffffffc02016c8 <sbi_set_timer>

ffffffffc020044a <cons_init>:
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	25e0106f          	j	ffffffffc02016ae <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
ffffffffc0200454:	28e0106f          	j	ffffffffc02016e2 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	5c250513          	addi	a0,a0,1474 # ffffffffc0201a40 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201a58 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	5d450513          	addi	a0,a0,1492 # ffffffffc0201a70 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	5de50513          	addi	a0,a0,1502 # ffffffffc0201a88 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	5e850513          	addi	a0,a0,1512 # ffffffffc0201aa0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	5f250513          	addi	a0,a0,1522 # ffffffffc0201ab8 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	5fc50513          	addi	a0,a0,1532 # ffffffffc0201ad0 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	60650513          	addi	a0,a0,1542 # ffffffffc0201ae8 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	61050513          	addi	a0,a0,1552 # ffffffffc0201b00 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	61a50513          	addi	a0,a0,1562 # ffffffffc0201b18 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	62450513          	addi	a0,a0,1572 # ffffffffc0201b30 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	62e50513          	addi	a0,a0,1582 # ffffffffc0201b48 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	63850513          	addi	a0,a0,1592 # ffffffffc0201b60 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	64250513          	addi	a0,a0,1602 # ffffffffc0201b78 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	64c50513          	addi	a0,a0,1612 # ffffffffc0201b90 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	65650513          	addi	a0,a0,1622 # ffffffffc0201ba8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	66050513          	addi	a0,a0,1632 # ffffffffc0201bc0 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	66a50513          	addi	a0,a0,1642 # ffffffffc0201bd8 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	67450513          	addi	a0,a0,1652 # ffffffffc0201bf0 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	67e50513          	addi	a0,a0,1662 # ffffffffc0201c08 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	68850513          	addi	a0,a0,1672 # ffffffffc0201c20 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	69250513          	addi	a0,a0,1682 # ffffffffc0201c38 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	69c50513          	addi	a0,a0,1692 # ffffffffc0201c50 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	6a650513          	addi	a0,a0,1702 # ffffffffc0201c68 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	6b050513          	addi	a0,a0,1712 # ffffffffc0201c80 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201c98 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	6c450513          	addi	a0,a0,1732 # ffffffffc0201cb0 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201cc8 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	6d850513          	addi	a0,a0,1752 # ffffffffc0201ce0 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	6e250513          	addi	a0,a0,1762 # ffffffffc0201cf8 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	6ec50513          	addi	a0,a0,1772 # ffffffffc0201d10 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	6f250513          	addi	a0,a0,1778 # ffffffffc0201d28 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	6f650513          	addi	a0,a0,1782 # ffffffffc0201d40 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	6f650513          	addi	a0,a0,1782 # ffffffffc0201d58 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201d70 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	70650513          	addi	a0,a0,1798 # ffffffffc0201d88 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	70a50513          	addi	a0,a0,1802 # ffffffffc0201da0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	7d070713          	addi	a4,a4,2000 # ffffffffc0201e80 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	75650513          	addi	a0,a0,1878 # ffffffffc0201e18 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	72c50513          	addi	a0,a0,1836 # ffffffffc0201df8 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	6e250513          	addi	a0,a0,1762 # ffffffffc0201db8 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	75850513          	addi	a0,a0,1880 # ffffffffc0201e38 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	e2668693          	addi	a3,a3,-474 # ffffffffc0206518 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	75050513          	addi	a0,a0,1872 # ffffffffc0201e60 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	6be50513          	addi	a0,a0,1726 # ffffffffc0201dd8 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	72450513          	addi	a0,a0,1828 # ffffffffc0201e50 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)
ffffffffc02007ae:	850a                	mv	a0,sp
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_system_nr_free_pages>:
free_buddy_t buddy_s;

static size_t buddy_system_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200802:	00006517          	auipc	a0,0x6
ffffffffc0200806:	90656503          	lwu	a0,-1786(a0) # ffffffffc0206108 <buddy_s+0xf8>
ffffffffc020080a:	8082                	ret

ffffffffc020080c <buddy_system_init>:
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息

static void
buddy_system_init(void)
{
    for (int i = 0; i < MAX_BUDDY_ORDER + 1; i++)
ffffffffc020080c:	00006797          	auipc	a5,0x6
ffffffffc0200810:	80c78793          	addi	a5,a5,-2036 # ffffffffc0206018 <buddy_s+0x8>
ffffffffc0200814:	00006717          	auipc	a4,0x6
ffffffffc0200818:	8f470713          	addi	a4,a4,-1804 # ffffffffc0206108 <buddy_s+0xf8>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020081c:	e79c                	sd	a5,8(a5)
ffffffffc020081e:	e39c                	sd	a5,0(a5)
ffffffffc0200820:	07c1                	addi	a5,a5,16
ffffffffc0200822:	fee79de3          	bne	a5,a4,ffffffffc020081c <buddy_system_init+0x10>
    {
        list_init(buddy_array + i);
    }
    max_order = 0;
ffffffffc0200826:	00005797          	auipc	a5,0x5
ffffffffc020082a:	7e07a523          	sw	zero,2026(a5) # ffffffffc0206010 <buddy_s>
    nr_free = 0;
ffffffffc020082e:	00006797          	auipc	a5,0x6
ffffffffc0200832:	8c07ad23          	sw	zero,-1830(a5) # ffffffffc0206108 <buddy_s+0xf8>
    return;
}
ffffffffc0200836:	8082                	ret

ffffffffc0200838 <buddy_system_init_memmap>:

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200838:	1141                	addi	sp,sp,-16
ffffffffc020083a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020083c:	c9cd                	beqz	a1,ffffffffc02008ee <buddy_system_init_memmap+0xb6>
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc020083e:	fff58793          	addi	a5,a1,-1
ffffffffc0200842:	8fed                	and	a5,a5,a1
ffffffffc0200844:	c799                	beqz	a5,ffffffffc0200852 <buddy_system_init_memmap+0x1a>
ffffffffc0200846:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200848:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc020084a:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc020084c:	fdf5                	bnez	a1,ffffffffc0200848 <buddy_system_init_memmap+0x10>
        return res >> 1;
ffffffffc020084e:	0017d593          	srli	a1,a5,0x1
    while (n >> 1)
ffffffffc0200852:	0015d793          	srli	a5,a1,0x1
    unsigned int order = 0;
ffffffffc0200856:	4601                	li	a2,0
    while (n >> 1)
ffffffffc0200858:	c781                	beqz	a5,ffffffffc0200860 <buddy_system_init_memmap+0x28>
ffffffffc020085a:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc020085c:	2605                	addiw	a2,a2,1
    while (n >> 1)
ffffffffc020085e:	fff5                	bnez	a5,ffffffffc020085a <buddy_system_init_memmap+0x22>
    
    size_t pnum = ROUNDDOWN2(n);
    unsigned int order = getOrderOf2(pnum);

   
    for (struct Page *p = base; p != base + pnum; p++) {
ffffffffc0200860:	00259693          	slli	a3,a1,0x2
ffffffffc0200864:	96ae                	add	a3,a3,a1
ffffffffc0200866:	068e                	slli	a3,a3,0x3
ffffffffc0200868:	96aa                	add	a3,a3,a0
ffffffffc020086a:	02a68163          	beq	a3,a0,ffffffffc020088c <buddy_system_init_memmap+0x54>
ffffffffc020086e:	87aa                	mv	a5,a0
        assert(PageReserved(p));
        p->flags = 0;          
        p->property = -1;      
ffffffffc0200870:	587d                	li	a6,-1
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200872:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200874:	8b05                	andi	a4,a4,1
ffffffffc0200876:	cf21                	beqz	a4,ffffffffc02008ce <buddy_system_init_memmap+0x96>
        p->flags = 0;          
ffffffffc0200878:	0007b423          	sd	zero,8(a5)
        p->property = -1;      
ffffffffc020087c:	0107a823          	sw	a6,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200880:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p != base + pnum; p++) {
ffffffffc0200884:	02878793          	addi	a5,a5,40
ffffffffc0200888:	fef695e3          	bne	a3,a5,ffffffffc0200872 <buddy_system_init_memmap+0x3a>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc020088c:	02061693          	slli	a3,a2,0x20
        set_page_ref(p, 0);    
    }

    max_order = order;
ffffffffc0200890:	00005797          	auipc	a5,0x5
ffffffffc0200894:	78078793          	addi	a5,a5,1920 # ffffffffc0206010 <buddy_s>
ffffffffc0200898:	01c6d713          	srli	a4,a3,0x1c
ffffffffc020089c:	00e78833          	add	a6,a5,a4
ffffffffc02008a0:	01083683          	ld	a3,16(a6)
    nr_free = pnum;
ffffffffc02008a4:	0eb7ac23          	sw	a1,248(a5)
    max_order = order;
ffffffffc02008a8:	c390                	sw	a2,0(a5)
    list_add(&(buddy_array[max_order]), &(base->page_link));
ffffffffc02008aa:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02008ae:	e28c                	sd	a1,0(a3)
ffffffffc02008b0:	0721                	addi	a4,a4,8
ffffffffc02008b2:	00b83823          	sd	a1,16(a6)
ffffffffc02008b6:	97ba                	add	a5,a5,a4
    elm->next = next;
    elm->prev = prev;
ffffffffc02008b8:	ed1c                	sd	a5,24(a0)
    elm->next = next;
ffffffffc02008ba:	f114                	sd	a3,32(a0)

    
    base->property = max_order;
ffffffffc02008bc:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008be:	4789                	li	a5,2
ffffffffc02008c0:	00850713          	addi	a4,a0,8
ffffffffc02008c4:	40f7302f          	amoor.d	zero,a5,(a4)
    SetPageProperty(base); // 初始化

    return;
}
ffffffffc02008c8:	60a2                	ld	ra,8(sp)
ffffffffc02008ca:	0141                	addi	sp,sp,16
ffffffffc02008cc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02008ce:	00001697          	auipc	a3,0x1
ffffffffc02008d2:	61a68693          	addi	a3,a3,1562 # ffffffffc0201ee8 <commands+0x530>
ffffffffc02008d6:	00001617          	auipc	a2,0x1
ffffffffc02008da:	5e260613          	addi	a2,a2,1506 # ffffffffc0201eb8 <commands+0x500>
ffffffffc02008de:	09c00593          	li	a1,156
ffffffffc02008e2:	00001517          	auipc	a0,0x1
ffffffffc02008e6:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201ed0 <commands+0x518>
ffffffffc02008ea:	ac3ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02008ee:	00001697          	auipc	a3,0x1
ffffffffc02008f2:	5c268693          	addi	a3,a3,1474 # ffffffffc0201eb0 <commands+0x4f8>
ffffffffc02008f6:	00001617          	auipc	a2,0x1
ffffffffc02008fa:	5c260613          	addi	a2,a2,1474 # ffffffffc0201eb8 <commands+0x500>
ffffffffc02008fe:	09400593          	li	a1,148
ffffffffc0200902:	00001517          	auipc	a0,0x1
ffffffffc0200906:	5ce50513          	addi	a0,a0,1486 # ffffffffc0201ed0 <commands+0x518>
ffffffffc020090a:	aa3ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020090e <buddy_system_free_pages>:
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
    return buddy_page;
}

static void buddy_system_free_pages(struct Page *base, size_t n)
{
ffffffffc020090e:	1101                	addi	sp,sp,-32
ffffffffc0200910:	ec06                	sd	ra,24(sp)
ffffffffc0200912:	e822                	sd	s0,16(sp)
ffffffffc0200914:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200916:	16058563          	beqz	a1,ffffffffc0200a80 <buddy_system_free_pages+0x172>
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc020091a:	4918                	lw	a4,16(a0)
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc020091c:	fff58793          	addi	a5,a1,-1
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc0200920:	4485                	li	s1,1
ffffffffc0200922:	00e494bb          	sllw	s1,s1,a4
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0200926:	8fed                	and	a5,a5,a1
ffffffffc0200928:	842a                	mv	s0,a0
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc020092a:	0004861b          	sext.w	a2,s1
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc020092e:	14079363          	bnez	a5,ffffffffc0200a74 <buddy_system_free_pages+0x166>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200932:	02049793          	slli	a5,s1,0x20
ffffffffc0200936:	9381                	srli	a5,a5,0x20
ffffffffc0200938:	16b79463          	bne	a5,a1,ffffffffc0200aa0 <buddy_system_free_pages+0x192>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020093c:	00006797          	auipc	a5,0x6
ffffffffc0200940:	bec7b783          	ld	a5,-1044(a5) # ffffffffc0206528 <pages>
ffffffffc0200944:	40f407b3          	sub	a5,s0,a5
ffffffffc0200948:	00002597          	auipc	a1,0x2
ffffffffc020094c:	d605b583          	ld	a1,-672(a1) # ffffffffc02026a8 <error_string+0x38>
ffffffffc0200950:	878d                	srai	a5,a5,0x3
ffffffffc0200952:	02b787b3          	mul	a5,a5,a1
    cprintf("buddy system分配释放第NO.%d页开始共%d页\n", page2ppn(base), pnum);
ffffffffc0200956:	00002597          	auipc	a1,0x2
ffffffffc020095a:	d5a5b583          	ld	a1,-678(a1) # ffffffffc02026b0 <nbase>
ffffffffc020095e:	00001517          	auipc	a0,0x1
ffffffffc0200962:	5b250513          	addi	a0,a0,1458 # ffffffffc0201f10 <commands+0x558>
ffffffffc0200966:	95be                	add	a1,a1,a5
ffffffffc0200968:	f4aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *left_block = base; // 放块的头页
    struct Page *buddy = NULL;
    struct Page *tmp = NULL;

    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中
ffffffffc020096c:	4810                	lw	a2,16(s0)
    size_t real_block_size = 1 << block_size;                    // 幂次转换成数
ffffffffc020096e:	4785                	li	a5,1
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算相对于初始化的第一个页的偏移量
ffffffffc0200970:	3fdf1eb7          	lui	t4,0x3fdf1
    size_t real_block_size = 1 << block_size;                    // 幂次转换成数
ffffffffc0200974:	00c7973b          	sllw	a4,a5,a2
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  // sizeof(struct Page)是0x28
ffffffffc0200978:	00271793          	slli	a5,a4,0x2
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算相对于初始化的第一个页的偏移量
ffffffffc020097c:	ce8e8e93          	addi	t4,t4,-792 # 3fdf0ce8 <kern_entry-0xffffffff8040f318>
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  // sizeof(struct Page)是0x28
ffffffffc0200980:	97ba                	add	a5,a5,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0200982:	02061693          	slli	a3,a2,0x20
ffffffffc0200986:	01c6d713          	srli	a4,a3,0x1c
ffffffffc020098a:	00005897          	auipc	a7,0x5
ffffffffc020098e:	68688893          	addi	a7,a7,1670 # ffffffffc0206010 <buddy_s>
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算相对于初始化的第一个页的偏移量
ffffffffc0200992:	01d406b3          	add	a3,s0,t4
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  // sizeof(struct Page)是0x28
ffffffffc0200996:	078e                	slli	a5,a5,0x3
ffffffffc0200998:	00e88533          	add	a0,a7,a4
    size_t buddy_relative_addr = (size_t)relative_block_addr ^ sizeOfPage;      // 异或得到伙伴块的相对地址
ffffffffc020099c:	8fb5                	xor	a5,a5,a3
ffffffffc020099e:	690c                	ld	a1,16(a0)
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
ffffffffc02009a0:	41d787b3          	sub	a5,a5,t4
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009a4:	6794                	ld	a3,8(a5)
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中
ffffffffc02009a6:	01840813          	addi	a6,s0,24
    prev->next = next->prev = elm;
ffffffffc02009aa:	0105b023          	sd	a6,0(a1)
ffffffffc02009ae:	0721                	addi	a4,a4,8
ffffffffc02009b0:	01053823          	sd	a6,16(a0)
ffffffffc02009b4:	9746                	add	a4,a4,a7
ffffffffc02009b6:	8285                	srli	a3,a3,0x1
    elm->prev = prev;
ffffffffc02009b8:	ec18                	sd	a4,24(s0)
    elm->next = next;
ffffffffc02009ba:	f00c                	sd	a1,32(s0)

    // show_buddy_array(0, MAX_BUDDY_ORDER); // test point
    // 当伙伴块空闲，且当前块不为最大块时，执行合并
    buddy = get_buddy(left_block, left_block->property);
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc02009bc:	0016f713          	andi	a4,a3,1
    {
        if (left_block > buddy)
        {                              // 若当前左块为更大块的右块
            left_block->property = -1; // 将左块幂次置为无效
ffffffffc02009c0:	5ffd                	li	t6,-1
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc02009c2:	86a2                	mv	a3,s0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009c4:	4f09                	li	t5,2
    size_t real_block_size = 1 << block_size;                    // 幂次转换成数
ffffffffc02009c6:	4505                	li	a0,1
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc02009c8:	e359                	bnez	a4,ffffffffc0200a4e <buddy_system_free_pages+0x140>
ffffffffc02009ca:	a071                	j	ffffffffc0200a56 <buddy_system_free_pages+0x148>
        if (left_block > buddy)
ffffffffc02009cc:	00d7fc63          	bgeu	a5,a3,ffffffffc02009e4 <buddy_system_free_pages+0xd6>
            left_block->property = -1; // 将左块幂次置为无效
ffffffffc02009d0:	01f6a823          	sw	t6,16(a3)
ffffffffc02009d4:	00840713          	addi	a4,s0,8
ffffffffc02009d8:	41e7302f          	amoor.d	zero,t5,(a4)
            buddy = tmp;
        }
        // 删掉原来链表里的两个小块
        list_del(&(left_block->page_link));
        list_del(&(buddy->page_link));
        left_block->property += 1; // 左快头页设置幂次加一
ffffffffc02009dc:	8736                	mv	a4,a3
ffffffffc02009de:	4b90                	lw	a2,16(a5)
ffffffffc02009e0:	86be                	mv	a3,a5
ffffffffc02009e2:	87ba                	mv	a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc02009e4:	0186b803          	ld	a6,24(a3)
ffffffffc02009e8:	728c                	ld	a1,32(a3)
ffffffffc02009ea:	2605                	addiw	a2,a2,1
    size_t real_block_size = 1 << block_size;                    // 幂次转换成数
ffffffffc02009ec:	00c5173b          	sllw	a4,a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02009f0:	00b83423          	sd	a1,8(a6)
    next->prev = prev;
ffffffffc02009f4:	0105b023          	sd	a6,0(a1)
    __list_del(listelm->prev, listelm->next);
ffffffffc02009f8:	0187b303          	ld	t1,24(a5)
ffffffffc02009fc:	0207b803          	ld	a6,32(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a00:	02061e13          	slli	t3,a2,0x20
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  // sizeof(struct Page)是0x28
ffffffffc0200a04:	00271793          	slli	a5,a4,0x2
    prev->next = next;
ffffffffc0200a08:	01033423          	sd	a6,8(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a0c:	01ce5593          	srli	a1,t3,0x1c
ffffffffc0200a10:	97ba                	add	a5,a5,a4
    next->prev = prev;
ffffffffc0200a12:	00683023          	sd	t1,0(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a16:	00b88e33          	add	t3,a7,a1
ffffffffc0200a1a:	00379713          	slli	a4,a5,0x3
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算相对于初始化的第一个页的偏移量
ffffffffc0200a1e:	01d687b3          	add	a5,a3,t4
ffffffffc0200a22:	010e3303          	ld	t1,16(t3)
    size_t buddy_relative_addr = (size_t)relative_block_addr ^ sizeOfPage;      // 异或得到伙伴块的相对地址
ffffffffc0200a26:	8fb9                	xor	a5,a5,a4
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
ffffffffc0200a28:	41d787b3          	sub	a5,a5,t4
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a2c:	0087b803          	ld	a6,8(a5)
        // cprintf("left_block->property=%d\n", left_block->property); //test point
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
ffffffffc0200a30:	01868713          	addi	a4,a3,24
        left_block->property += 1; // 左快头页设置幂次加一
ffffffffc0200a34:	ca90                	sw	a2,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200a36:	00e33023          	sd	a4,0(t1)
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
ffffffffc0200a3a:	05a1                	addi	a1,a1,8
ffffffffc0200a3c:	00ee3823          	sd	a4,16(t3)
ffffffffc0200a40:	95c6                	add	a1,a1,a7
    elm->next = next;
ffffffffc0200a42:	0266b023          	sd	t1,32(a3)
    elm->prev = prev;
ffffffffc0200a46:	ee8c                	sd	a1,24(a3)
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc0200a48:	00287713          	andi	a4,a6,2
ffffffffc0200a4c:	c709                	beqz	a4,ffffffffc0200a56 <buddy_system_free_pages+0x148>
ffffffffc0200a4e:	0008a703          	lw	a4,0(a7)
ffffffffc0200a52:	f6e66de3          	bltu	a2,a4,ffffffffc02009cc <buddy_system_free_pages+0xbe>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200a56:	4789                	li	a5,2
ffffffffc0200a58:	00868713          	addi	a4,a3,8
ffffffffc0200a5c:	40f7302f          	amoor.d	zero,a5,(a4)

        // 重置buddy开启下一轮循环***
        buddy = get_buddy(left_block, left_block->property);
    }
    SetPageProperty(left_block); // 将回收块的头页设置为空闲
    nr_free += pnum;
ffffffffc0200a60:	0f88a783          	lw	a5,248(a7)
    // show_buddy_array(); // test point

    return;
}
ffffffffc0200a64:	60e2                	ld	ra,24(sp)
ffffffffc0200a66:	6442                	ld	s0,16(sp)
    nr_free += pnum;
ffffffffc0200a68:	9cbd                	addw	s1,s1,a5
ffffffffc0200a6a:	0e98ac23          	sw	s1,248(a7)
}
ffffffffc0200a6e:	64a2                	ld	s1,8(sp)
ffffffffc0200a70:	6105                	addi	sp,sp,32
ffffffffc0200a72:	8082                	ret
ffffffffc0200a74:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200a76:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200a78:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200a7a:	fdf5                	bnez	a1,ffffffffc0200a76 <buddy_system_free_pages+0x168>
            res = res << 1;
ffffffffc0200a7c:	85be                	mv	a1,a5
ffffffffc0200a7e:	bd55                	j	ffffffffc0200932 <buddy_system_free_pages+0x24>
    assert(n > 0);
ffffffffc0200a80:	00001697          	auipc	a3,0x1
ffffffffc0200a84:	43068693          	addi	a3,a3,1072 # ffffffffc0201eb0 <commands+0x4f8>
ffffffffc0200a88:	00001617          	auipc	a2,0x1
ffffffffc0200a8c:	43060613          	addi	a2,a2,1072 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200a90:	0e900593          	li	a1,233
ffffffffc0200a94:	00001517          	auipc	a0,0x1
ffffffffc0200a98:	43c50513          	addi	a0,a0,1084 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200a9c:	911ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200aa0:	00001697          	auipc	a3,0x1
ffffffffc0200aa4:	45868693          	addi	a3,a3,1112 # ffffffffc0201ef8 <commands+0x540>
ffffffffc0200aa8:	00001617          	auipc	a2,0x1
ffffffffc0200aac:	41060613          	addi	a2,a2,1040 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200ab0:	0eb00593          	li	a1,235
ffffffffc0200ab4:	00001517          	auipc	a0,0x1
ffffffffc0200ab8:	41c50513          	addi	a0,a0,1052 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200abc:	8f1ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ac0 <show_buddy_array.constprop.0>:
show_buddy_array(int left, int right) // 左闭右闭
ffffffffc0200ac0:	711d                	addi	sp,sp,-96
ffffffffc0200ac2:	ec86                	sd	ra,88(sp)
ffffffffc0200ac4:	e8a2                	sd	s0,80(sp)
ffffffffc0200ac6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ac8:	e0ca                	sd	s2,64(sp)
ffffffffc0200aca:	fc4e                	sd	s3,56(sp)
ffffffffc0200acc:	f852                	sd	s4,48(sp)
ffffffffc0200ace:	f456                	sd	s5,40(sp)
ffffffffc0200ad0:	f05a                	sd	s6,32(sp)
ffffffffc0200ad2:	ec5e                	sd	s7,24(sp)
ffffffffc0200ad4:	e862                	sd	s8,16(sp)
ffffffffc0200ad6:	e466                	sd	s9,8(sp)
ffffffffc0200ad8:	e06a                	sd	s10,0(sp)
    assert(left >= 0 && left <= max_order && right >= 0 && right <= max_order);
ffffffffc0200ada:	00005717          	auipc	a4,0x5
ffffffffc0200ade:	53672703          	lw	a4,1334(a4) # ffffffffc0206010 <buddy_s>
ffffffffc0200ae2:	47b5                	li	a5,13
ffffffffc0200ae4:	0ce7f363          	bgeu	a5,a4,ffffffffc0200baa <show_buddy_array.constprop.0+0xea>
ffffffffc0200ae8:	00005497          	auipc	s1,0x5
ffffffffc0200aec:	53048493          	addi	s1,s1,1328 # ffffffffc0206018 <buddy_s+0x8>
    bool empty = 1; // 表示空闲链表数组为空
ffffffffc0200af0:	4c05                	li	s8,1
    for (int i = left; i <= right; i++)
ffffffffc0200af2:	4901                	li	s2,0
                cprintf("No.%d的空闲链表有", i);
ffffffffc0200af4:	00001b17          	auipc	s6,0x1
ffffffffc0200af8:	49cb0b13          	addi	s6,s6,1180 # ffffffffc0201f90 <commands+0x5d8>
                cprintf("%d页 ", 1 << (p->property));
ffffffffc0200afc:	4a85                	li	s5,1
ffffffffc0200afe:	00001a17          	auipc	s4,0x1
ffffffffc0200b02:	4aaa0a13          	addi	s4,s4,1194 # ffffffffc0201fa8 <commands+0x5f0>
                cprintf("【地址为%p】\n", p);
ffffffffc0200b06:	00001997          	auipc	s3,0x1
ffffffffc0200b0a:	4aa98993          	addi	s3,s3,1194 # ffffffffc0201fb0 <commands+0x5f8>
            if (i != right)
ffffffffc0200b0e:	4cb9                	li	s9,14
                cprintf("\n");
ffffffffc0200b10:	00001d17          	auipc	s10,0x1
ffffffffc0200b14:	780d0d13          	addi	s10,s10,1920 # ffffffffc0202290 <commands+0x8d8>
    for (int i = left; i <= right; i++)
ffffffffc0200b18:	4bbd                	li	s7,15
ffffffffc0200b1a:	a029                	j	ffffffffc0200b24 <show_buddy_array.constprop.0+0x64>
ffffffffc0200b1c:	2905                	addiw	s2,s2,1
ffffffffc0200b1e:	04c1                	addi	s1,s1,16
ffffffffc0200b20:	05790263          	beq	s2,s7,ffffffffc0200b64 <show_buddy_array.constprop.0+0xa4>
    return listelm->next;
ffffffffc0200b24:	6480                	ld	s0,8(s1)
        if (list_next(le) != &buddy_array[i])
ffffffffc0200b26:	fe848be3          	beq	s1,s0,ffffffffc0200b1c <show_buddy_array.constprop.0+0x5c>
                cprintf("No.%d的空闲链表有", i);
ffffffffc0200b2a:	85ca                	mv	a1,s2
ffffffffc0200b2c:	855a                	mv	a0,s6
ffffffffc0200b2e:	d84ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("%d页 ", 1 << (p->property));
ffffffffc0200b32:	ff842583          	lw	a1,-8(s0)
ffffffffc0200b36:	8552                	mv	a0,s4
ffffffffc0200b38:	00ba95bb          	sllw	a1,s5,a1
ffffffffc0200b3c:	d76ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("【地址为%p】\n", p);
ffffffffc0200b40:	fe840593          	addi	a1,s0,-24
ffffffffc0200b44:	854e                	mv	a0,s3
ffffffffc0200b46:	d6cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200b4a:	6400                	ld	s0,8(s0)
            while ((le = list_next(le)) != &buddy_array[i])
ffffffffc0200b4c:	fc941fe3          	bne	s0,s1,ffffffffc0200b2a <show_buddy_array.constprop.0+0x6a>
            empty = 0;
ffffffffc0200b50:	4c01                	li	s8,0
            if (i != right)
ffffffffc0200b52:	fd9905e3          	beq	s2,s9,ffffffffc0200b1c <show_buddy_array.constprop.0+0x5c>
                cprintf("\n");
ffffffffc0200b56:	856a                	mv	a0,s10
    for (int i = left; i <= right; i++)
ffffffffc0200b58:	2905                	addiw	s2,s2,1
                cprintf("\n");
ffffffffc0200b5a:	d58ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = left; i <= right; i++)
ffffffffc0200b5e:	04c1                	addi	s1,s1,16
ffffffffc0200b60:	fd7912e3          	bne	s2,s7,ffffffffc0200b24 <show_buddy_array.constprop.0+0x64>
    if (empty)
ffffffffc0200b64:	020c1063          	bnez	s8,ffffffffc0200b84 <show_buddy_array.constprop.0+0xc4>
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息
ffffffffc0200b68:	60e6                	ld	ra,88(sp)
ffffffffc0200b6a:	6446                	ld	s0,80(sp)
ffffffffc0200b6c:	64a6                	ld	s1,72(sp)
ffffffffc0200b6e:	6906                	ld	s2,64(sp)
ffffffffc0200b70:	79e2                	ld	s3,56(sp)
ffffffffc0200b72:	7a42                	ld	s4,48(sp)
ffffffffc0200b74:	7aa2                	ld	s5,40(sp)
ffffffffc0200b76:	7b02                	ld	s6,32(sp)
ffffffffc0200b78:	6be2                	ld	s7,24(sp)
ffffffffc0200b7a:	6c42                	ld	s8,16(sp)
ffffffffc0200b7c:	6ca2                	ld	s9,8(sp)
ffffffffc0200b7e:	6d02                	ld	s10,0(sp)
ffffffffc0200b80:	6125                	addi	sp,sp,96
ffffffffc0200b82:	8082                	ret
ffffffffc0200b84:	6446                	ld	s0,80(sp)
ffffffffc0200b86:	60e6                	ld	ra,88(sp)
ffffffffc0200b88:	64a6                	ld	s1,72(sp)
ffffffffc0200b8a:	6906                	ld	s2,64(sp)
ffffffffc0200b8c:	79e2                	ld	s3,56(sp)
ffffffffc0200b8e:	7a42                	ld	s4,48(sp)
ffffffffc0200b90:	7aa2                	ld	s5,40(sp)
ffffffffc0200b92:	7b02                	ld	s6,32(sp)
ffffffffc0200b94:	6be2                	ld	s7,24(sp)
ffffffffc0200b96:	6c42                	ld	s8,16(sp)
ffffffffc0200b98:	6ca2                	ld	s9,8(sp)
ffffffffc0200b9a:	6d02                	ld	s10,0(sp)
        cprintf("无空闲块！！！\n");
ffffffffc0200b9c:	00001517          	auipc	a0,0x1
ffffffffc0200ba0:	42c50513          	addi	a0,a0,1068 # ffffffffc0201fc8 <commands+0x610>
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息
ffffffffc0200ba4:	6125                	addi	sp,sp,96
        cprintf("无空闲块！！！\n");
ffffffffc0200ba6:	d0cff06f          	j	ffffffffc02000b2 <cprintf>
    assert(left >= 0 && left <= max_order && right >= 0 && right <= max_order);
ffffffffc0200baa:	00001697          	auipc	a3,0x1
ffffffffc0200bae:	39e68693          	addi	a3,a3,926 # ffffffffc0201f48 <commands+0x590>
ffffffffc0200bb2:	00001617          	auipc	a2,0x1
ffffffffc0200bb6:	30660613          	addi	a2,a2,774 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200bba:	06a00593          	li	a1,106
ffffffffc0200bbe:	00001517          	auipc	a0,0x1
ffffffffc0200bc2:	31250513          	addi	a0,a0,786 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200bc6:	fe6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bca <buddy_system_check>:



static void
buddy_system_check(void)
{
ffffffffc0200bca:	7179                	addi	sp,sp,-48
ffffffffc0200bcc:	f022                	sd	s0,32(sp)
    cprintf("总空闲块数目为：%d\n", nr_free);
ffffffffc0200bce:	00005417          	auipc	s0,0x5
ffffffffc0200bd2:	44240413          	addi	s0,s0,1090 # ffffffffc0206010 <buddy_s>
ffffffffc0200bd6:	0f842583          	lw	a1,248(s0)
ffffffffc0200bda:	00001517          	auipc	a0,0x1
ffffffffc0200bde:	40650513          	addi	a0,a0,1030 # ffffffffc0201fe0 <commands+0x628>
{
ffffffffc0200be2:	f406                	sd	ra,40(sp)
ffffffffc0200be4:	ec26                	sd	s1,24(sp)
ffffffffc0200be6:	e84a                	sd	s2,16(sp)
ffffffffc0200be8:	e44e                	sd	s3,8(sp)
    cprintf("总空闲块数目为：%d\n", nr_free);
ffffffffc0200bea:	cc8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("首先p0请求5页\n");
ffffffffc0200bee:	00001517          	auipc	a0,0x1
ffffffffc0200bf2:	41250513          	addi	a0,a0,1042 # ffffffffc0202000 <commands+0x648>
ffffffffc0200bf6:	cbcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p0 = alloc_pages(5);
ffffffffc0200bfa:	4515                	li	a0,5
ffffffffc0200bfc:	3fe000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200c00:	892a                	mv	s2,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c02:	ebfff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("然后p1请求5页\n");
ffffffffc0200c06:	00001517          	auipc	a0,0x1
ffffffffc0200c0a:	41250513          	addi	a0,a0,1042 # ffffffffc0202018 <commands+0x660>
ffffffffc0200c0e:	ca4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p1 = alloc_pages(5);
ffffffffc0200c12:	4515                	li	a0,5
ffffffffc0200c14:	3e6000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200c18:	84aa                	mv	s1,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c1a:	ea7ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("最后p2请求5页\n");
ffffffffc0200c1e:	00001517          	auipc	a0,0x1
ffffffffc0200c22:	41250513          	addi	a0,a0,1042 # ffffffffc0202030 <commands+0x678>
ffffffffc0200c26:	c8cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p2 = alloc_pages(5);
ffffffffc0200c2a:	4515                	li	a0,5
ffffffffc0200c2c:	3ce000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200c30:	89aa                	mv	s3,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c32:	e8fff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    // cprintf("p0的物理地址0x%016lx.\n", PADDR(p0)); // 0x8020f318
    cprintf("p0的虚拟地址0x%016lx.\n", p0);
ffffffffc0200c36:	85ca                	mv	a1,s2
ffffffffc0200c38:	00001517          	auipc	a0,0x1
ffffffffc0200c3c:	41050513          	addi	a0,a0,1040 # ffffffffc0202048 <commands+0x690>
ffffffffc0200c40:	c72ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    // cprintf("p1的物理地址0x%016lx.\n", PADDR(p1)); // 0x8020f458,和p0相差0x140=0x28*5
    cprintf("p1的虚拟地址0x%016lx.\n", p1);
ffffffffc0200c44:	85a6                	mv	a1,s1
ffffffffc0200c46:	00001517          	auipc	a0,0x1
ffffffffc0200c4a:	42250513          	addi	a0,a0,1058 # ffffffffc0202068 <commands+0x6b0>
ffffffffc0200c4e:	c64ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    // cprintf("p2的物理地址0x%016lx.\n", PADDR(p2)); // 0x8020f598,和p1相差0x140=0x28*5
    cprintf("p2的虚拟地址0x%016lx.\n", p2);
ffffffffc0200c52:	85ce                	mv	a1,s3
ffffffffc0200c54:	00001517          	auipc	a0,0x1
ffffffffc0200c58:	43450513          	addi	a0,a0,1076 # ffffffffc0202088 <commands+0x6d0>
ffffffffc0200c5c:	c56ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c60:	12990c63          	beq	s2,s1,ffffffffc0200d98 <buddy_system_check+0x1ce>
ffffffffc0200c64:	13390a63          	beq	s2,s3,ffffffffc0200d98 <buddy_system_check+0x1ce>
ffffffffc0200c68:	13348863          	beq	s1,s3,ffffffffc0200d98 <buddy_system_check+0x1ce>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c6c:	00092783          	lw	a5,0(s2)
ffffffffc0200c70:	14079463          	bnez	a5,ffffffffc0200db8 <buddy_system_check+0x1ee>
ffffffffc0200c74:	409c                	lw	a5,0(s1)
ffffffffc0200c76:	14079163          	bnez	a5,ffffffffc0200db8 <buddy_system_check+0x1ee>
ffffffffc0200c7a:	0009a783          	lw	a5,0(s3)
ffffffffc0200c7e:	12079d63          	bnez	a5,ffffffffc0200db8 <buddy_system_check+0x1ee>
ffffffffc0200c82:	00006797          	auipc	a5,0x6
ffffffffc0200c86:	8a67b783          	ld	a5,-1882(a5) # ffffffffc0206528 <pages>
ffffffffc0200c8a:	40f90733          	sub	a4,s2,a5
ffffffffc0200c8e:	870d                	srai	a4,a4,0x3
ffffffffc0200c90:	00002597          	auipc	a1,0x2
ffffffffc0200c94:	a185b583          	ld	a1,-1512(a1) # ffffffffc02026a8 <error_string+0x38>
ffffffffc0200c98:	02b70733          	mul	a4,a4,a1
ffffffffc0200c9c:	00002617          	auipc	a2,0x2
ffffffffc0200ca0:	a1463603          	ld	a2,-1516(a2) # ffffffffc02026b0 <nbase>

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ca4:	00006697          	auipc	a3,0x6
ffffffffc0200ca8:	87c6b683          	ld	a3,-1924(a3) # ffffffffc0206520 <npage>
ffffffffc0200cac:	06b2                	slli	a3,a3,0xc
ffffffffc0200cae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cb0:	0732                	slli	a4,a4,0xc
ffffffffc0200cb2:	12d77363          	bgeu	a4,a3,ffffffffc0200dd8 <buddy_system_check+0x20e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cb6:	40f48733          	sub	a4,s1,a5
ffffffffc0200cba:	870d                	srai	a4,a4,0x3
ffffffffc0200cbc:	02b70733          	mul	a4,a4,a1
ffffffffc0200cc0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cc2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cc4:	12d77a63          	bgeu	a4,a3,ffffffffc0200df8 <buddy_system_check+0x22e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cc8:	40f987b3          	sub	a5,s3,a5
ffffffffc0200ccc:	878d                	srai	a5,a5,0x3
ffffffffc0200cce:	02b787b3          	mul	a5,a5,a1
ffffffffc0200cd2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cd4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cd6:	14d7f163          	bgeu	a5,a3,ffffffffc0200e18 <buddy_system_check+0x24e>

    // 假设空闲块数是0，看看能不能再分配
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);
ffffffffc0200cda:	4505                	li	a0,1
    nr_free = 0;
ffffffffc0200cdc:	00005797          	auipc	a5,0x5
ffffffffc0200ce0:	4207a623          	sw	zero,1068(a5) # ffffffffc0206108 <buddy_s+0xf8>
    assert(alloc_page() == NULL);
ffffffffc0200ce4:	316000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200ce8:	14051863          	bnez	a0,ffffffffc0200e38 <buddy_system_check+0x26e>

    // 清空看nr_free能不能变
    cprintf("释放p0中。。。。。。\n");
ffffffffc0200cec:	00001517          	auipc	a0,0x1
ffffffffc0200cf0:	49c50513          	addi	a0,a0,1180 # ffffffffc0202188 <commands+0x7d0>
ffffffffc0200cf4:	bbeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p0, 5);
ffffffffc0200cf8:	854a                	mv	a0,s2
ffffffffc0200cfa:	4595                	li	a1,5
ffffffffc0200cfc:	33c000ef          	jal	ra,ffffffffc0201038 <free_pages>
    cprintf("释放p0后，总空闲块数目为：%d\n", nr_free); // 变成了8
ffffffffc0200d00:	0f842583          	lw	a1,248(s0)
ffffffffc0200d04:	00001517          	auipc	a0,0x1
ffffffffc0200d08:	4a450513          	addi	a0,a0,1188 # ffffffffc02021a8 <commands+0x7f0>
ffffffffc0200d0c:	ba6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d10:	db1ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("释放p1中。。。。。。\n");
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	4c450513          	addi	a0,a0,1220 # ffffffffc02021d8 <commands+0x820>
ffffffffc0200d1c:	b96ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p1, 5);
ffffffffc0200d20:	8526                	mv	a0,s1
ffffffffc0200d22:	4595                	li	a1,5
ffffffffc0200d24:	314000ef          	jal	ra,ffffffffc0201038 <free_pages>
    cprintf("释放p1后，总空闲块数目为：%d\n", nr_free); // 变成了16
ffffffffc0200d28:	0f842583          	lw	a1,248(s0)
ffffffffc0200d2c:	00001517          	auipc	a0,0x1
ffffffffc0200d30:	4cc50513          	addi	a0,a0,1228 # ffffffffc02021f8 <commands+0x840>
ffffffffc0200d34:	b7eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d38:	d89ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("释放p2中。。。。。。\n");
ffffffffc0200d3c:	00001517          	auipc	a0,0x1
ffffffffc0200d40:	4ec50513          	addi	a0,a0,1260 # ffffffffc0202228 <commands+0x870>
ffffffffc0200d44:	b6eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p2, 5);
ffffffffc0200d48:	854e                	mv	a0,s3
ffffffffc0200d4a:	4595                	li	a1,5
ffffffffc0200d4c:	2ec000ef          	jal	ra,ffffffffc0201038 <free_pages>
    cprintf("释放p2后，总空闲块数目为：%d\n", nr_free); // 变成了24
ffffffffc0200d50:	0f842583          	lw	a1,248(s0)
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	4f450513          	addi	a0,a0,1268 # ffffffffc0202248 <commands+0x890>
ffffffffc0200d5c:	b56ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d60:	d61ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    // 分配块全部收回，重置nr_free为最大值
    nr_free = 16384;
ffffffffc0200d64:	6791                	lui	a5,0x4

    struct Page *p3 = alloc_pages(16384);
ffffffffc0200d66:	6511                	lui	a0,0x4
    nr_free = 16384;
ffffffffc0200d68:	0ef42c23          	sw	a5,248(s0)
    struct Page *p3 = alloc_pages(16384);
ffffffffc0200d6c:	28e000ef          	jal	ra,ffffffffc0200ffa <alloc_pages>
ffffffffc0200d70:	842a                	mv	s0,a0
    cprintf("分配p3之后(16384页)\n");
ffffffffc0200d72:	00001517          	auipc	a0,0x1
ffffffffc0200d76:	50650513          	addi	a0,a0,1286 # ffffffffc0202278 <commands+0x8c0>
ffffffffc0200d7a:	b38ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d7e:	d43ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    // 全部回收
    free_pages(p3, 16384);
ffffffffc0200d82:	8522                	mv	a0,s0
ffffffffc0200d84:	6591                	lui	a1,0x4
ffffffffc0200d86:	2b2000ef          	jal	ra,ffffffffc0201038 <free_pages>
    show_buddy_array(0, MAX_BUDDY_ORDER);
}
ffffffffc0200d8a:	7402                	ld	s0,32(sp)
ffffffffc0200d8c:	70a2                	ld	ra,40(sp)
ffffffffc0200d8e:	64e2                	ld	s1,24(sp)
ffffffffc0200d90:	6942                	ld	s2,16(sp)
ffffffffc0200d92:	69a2                	ld	s3,8(sp)
ffffffffc0200d94:	6145                	addi	sp,sp,48
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d96:	b32d                	j	ffffffffc0200ac0 <show_buddy_array.constprop.0>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d98:	00001697          	auipc	a3,0x1
ffffffffc0200d9c:	31068693          	addi	a3,a3,784 # ffffffffc02020a8 <commands+0x6f0>
ffffffffc0200da0:	00001617          	auipc	a2,0x1
ffffffffc0200da4:	11860613          	addi	a2,a2,280 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200da8:	12f00593          	li	a1,303
ffffffffc0200dac:	00001517          	auipc	a0,0x1
ffffffffc0200db0:	12450513          	addi	a0,a0,292 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200db4:	df8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200db8:	00001697          	auipc	a3,0x1
ffffffffc0200dbc:	31868693          	addi	a3,a3,792 # ffffffffc02020d0 <commands+0x718>
ffffffffc0200dc0:	00001617          	auipc	a2,0x1
ffffffffc0200dc4:	0f860613          	addi	a2,a2,248 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200dc8:	13000593          	li	a1,304
ffffffffc0200dcc:	00001517          	auipc	a0,0x1
ffffffffc0200dd0:	10450513          	addi	a0,a0,260 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200dd4:	dd8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200dd8:	00001697          	auipc	a3,0x1
ffffffffc0200ddc:	33868693          	addi	a3,a3,824 # ffffffffc0202110 <commands+0x758>
ffffffffc0200de0:	00001617          	auipc	a2,0x1
ffffffffc0200de4:	0d860613          	addi	a2,a2,216 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200de8:	13200593          	li	a1,306
ffffffffc0200dec:	00001517          	auipc	a0,0x1
ffffffffc0200df0:	0e450513          	addi	a0,a0,228 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200df4:	db8ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200df8:	00001697          	auipc	a3,0x1
ffffffffc0200dfc:	33868693          	addi	a3,a3,824 # ffffffffc0202130 <commands+0x778>
ffffffffc0200e00:	00001617          	auipc	a2,0x1
ffffffffc0200e04:	0b860613          	addi	a2,a2,184 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200e08:	13300593          	li	a1,307
ffffffffc0200e0c:	00001517          	auipc	a0,0x1
ffffffffc0200e10:	0c450513          	addi	a0,a0,196 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200e14:	d98ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200e18:	00001697          	auipc	a3,0x1
ffffffffc0200e1c:	33868693          	addi	a3,a3,824 # ffffffffc0202150 <commands+0x798>
ffffffffc0200e20:	00001617          	auipc	a2,0x1
ffffffffc0200e24:	09860613          	addi	a2,a2,152 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200e28:	13400593          	li	a1,308
ffffffffc0200e2c:	00001517          	auipc	a0,0x1
ffffffffc0200e30:	0a450513          	addi	a0,a0,164 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200e34:	d78ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e38:	00001697          	auipc	a3,0x1
ffffffffc0200e3c:	33868693          	addi	a3,a3,824 # ffffffffc0202170 <commands+0x7b8>
ffffffffc0200e40:	00001617          	auipc	a2,0x1
ffffffffc0200e44:	07860613          	addi	a2,a2,120 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200e48:	13a00593          	li	a1,314
ffffffffc0200e4c:	00001517          	auipc	a0,0x1
ffffffffc0200e50:	08450513          	addi	a0,a0,132 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200e54:	d58ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e58 <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t requested_pages) {
ffffffffc0200e58:	1141                	addi	sp,sp,-16
ffffffffc0200e5a:	e406                	sd	ra,8(sp)
    assert(requested_pages > 0);
ffffffffc0200e5c:	16050f63          	beqz	a0,ffffffffc0200fda <buddy_system_alloc_pages+0x182>
    if (requested_pages > nr_free) {
ffffffffc0200e60:	00005897          	auipc	a7,0x5
ffffffffc0200e64:	1b088893          	addi	a7,a7,432 # ffffffffc0206010 <buddy_s>
ffffffffc0200e68:	0f88e783          	lwu	a5,248(a7)
ffffffffc0200e6c:	882a                	mv	a6,a0
ffffffffc0200e6e:	10a7e663          	bltu	a5,a0,ffffffffc0200f7a <buddy_system_alloc_pages+0x122>
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0200e72:	fff50793          	addi	a5,a0,-1
ffffffffc0200e76:	8fe9                	and	a5,a5,a0
ffffffffc0200e78:	10079563          	bnez	a5,ffffffffc0200f82 <buddy_system_alloc_pages+0x12a>
    while (n >> 1)
ffffffffc0200e7c:	00185793          	srli	a5,a6,0x1
ffffffffc0200e80:	10078963          	beqz	a5,ffffffffc0200f92 <buddy_system_alloc_pages+0x13a>
    unsigned int order = 0;
ffffffffc0200e84:	4701                	li	a4,0
    while (n >> 1)
ffffffffc0200e86:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200e88:	2705                	addiw	a4,a4,1
    while (n >> 1)
ffffffffc0200e8a:	fff5                	bnez	a5,ffffffffc0200e86 <buddy_system_alloc_pages+0x2e>
ffffffffc0200e8c:	02071793          	slli	a5,a4,0x20
ffffffffc0200e90:	01c7de13          	srli	t3,a5,0x1c
ffffffffc0200e94:	008e0793          	addi	a5,t3,8
    return list->next == list;
ffffffffc0200e98:	9e46                	add	t3,t3,a7
ffffffffc0200e9a:	010e3303          	ld	t1,16(t3)
        if (!list_empty(&(buddy_array[order_of_2]))) {
ffffffffc0200e9e:	97c6                	add	a5,a5,a7
ffffffffc0200ea0:	0af31763          	bne	t1,a5,ffffffffc0200f4e <buddy_system_alloc_pages+0xf6>
            for (int i = order_of_2 + 1; i <= max_order; ++i) {
ffffffffc0200ea4:	0017059b          	addiw	a1,a4,1
ffffffffc0200ea8:	00459513          	slli	a0,a1,0x4
ffffffffc0200eac:	0521                	addi	a0,a0,8
ffffffffc0200eae:	9546                	add	a0,a0,a7
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
ffffffffc0200eb0:	4f05                	li	t5,1
ffffffffc0200eb2:	4e89                	li	t4,2
            for (int i = order_of_2 + 1; i <= max_order; ++i) {
ffffffffc0200eb4:	0008a603          	lw	a2,0(a7)
ffffffffc0200eb8:	0cb66163          	bltu	a2,a1,ffffffffc0200f7a <buddy_system_alloc_pages+0x122>
ffffffffc0200ebc:	87aa                	mv	a5,a0
ffffffffc0200ebe:	872e                	mv	a4,a1
ffffffffc0200ec0:	a039                	j	ffffffffc0200ece <buddy_system_alloc_pages+0x76>
ffffffffc0200ec2:	0705                	addi	a4,a4,1
ffffffffc0200ec4:	0007069b          	sext.w	a3,a4
ffffffffc0200ec8:	07c1                	addi	a5,a5,16
ffffffffc0200eca:	0ad66863          	bltu	a2,a3,ffffffffc0200f7a <buddy_system_alloc_pages+0x122>
                if (!list_empty(&(buddy_array[i]))) {
ffffffffc0200ece:	6794                	ld	a3,8(a5)
ffffffffc0200ed0:	fed789e3          	beq	a5,a3,ffffffffc0200ec2 <buddy_system_alloc_pages+0x6a>
    assert(n > 0 && n <= max_order);
ffffffffc0200ed4:	c37d                	beqz	a4,ffffffffc0200fba <buddy_system_alloc_pages+0x162>
ffffffffc0200ed6:	1602                	slli	a2,a2,0x20
ffffffffc0200ed8:	9201                	srli	a2,a2,0x20
ffffffffc0200eda:	0ee66063          	bltu	a2,a4,ffffffffc0200fba <buddy_system_alloc_pages+0x162>
ffffffffc0200ede:	00471693          	slli	a3,a4,0x4
ffffffffc0200ee2:	96c6                	add	a3,a3,a7
ffffffffc0200ee4:	6a94                	ld	a3,16(a3)
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0200ee6:	0af68a63          	beq	a3,a5,ffffffffc0200f9a <buddy_system_alloc_pages+0x142>
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
ffffffffc0200eea:	fff7061b          	addiw	a2,a4,-1
ffffffffc0200eee:	00cf1fbb          	sllw	t6,t5,a2
ffffffffc0200ef2:	002f9793          	slli	a5,t6,0x2
ffffffffc0200ef6:	97fe                	add	a5,a5,t6
ffffffffc0200ef8:	078e                	slli	a5,a5,0x3
ffffffffc0200efa:	17a1                	addi	a5,a5,-24
    page_a->property = n - 1;
ffffffffc0200efc:	fec6ac23          	sw	a2,-8(a3)
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
ffffffffc0200f00:	97b6                	add	a5,a5,a3
    page_b->property = n - 1;
ffffffffc0200f02:	cb90                	sw	a2,16(a5)
ffffffffc0200f04:	ff068613          	addi	a2,a3,-16
ffffffffc0200f08:	41d6302f          	amoor.d	zero,t4,(a2)
ffffffffc0200f0c:	00878613          	addi	a2,a5,8 # 4008 <kern_entry-0xffffffffc01fbff8>
ffffffffc0200f10:	41d6302f          	amoor.d	zero,t4,(a2)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f14:	0006bf83          	ld	t6,0(a3)
ffffffffc0200f18:	6690                	ld	a2,8(a3)
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
ffffffffc0200f1a:	177d                	addi	a4,a4,-1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f1c:	0712                	slli	a4,a4,0x4
    prev->next = next;
ffffffffc0200f1e:	00cfb423          	sd	a2,8(t6)
    next->prev = prev;
ffffffffc0200f22:	01f63023          	sd	t6,0(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f26:	00e88fb3          	add	t6,a7,a4
ffffffffc0200f2a:	010fb603          	ld	a2,16(t6)
ffffffffc0200f2e:	0721                	addi	a4,a4,8
    prev->next = next->prev = elm;
ffffffffc0200f30:	00dfb823          	sd	a3,16(t6)
ffffffffc0200f34:	9746                	add	a4,a4,a7
    elm->prev = prev;
ffffffffc0200f36:	e298                	sd	a4,0(a3)
    list_add(&(page_a->page_link), &(page_b->page_link));
ffffffffc0200f38:	01878713          	addi	a4,a5,24
    prev->next = next->prev = elm;
ffffffffc0200f3c:	e218                	sd	a4,0(a2)
ffffffffc0200f3e:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0200f40:	f390                	sd	a2,32(a5)
    elm->prev = prev;
ffffffffc0200f42:	ef94                	sd	a3,24(a5)
    return list->next == list;
ffffffffc0200f44:	010e3783          	ld	a5,16(t3)
        if (!list_empty(&(buddy_array[order_of_2]))) {
ffffffffc0200f48:	f66786e3          	beq	a5,t1,ffffffffc0200eb4 <buddy_system_alloc_pages+0x5c>
ffffffffc0200f4c:	833e                	mv	t1,a5
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f4e:	00033703          	ld	a4,0(t1)
ffffffffc0200f52:	00833783          	ld	a5,8(t1)
            allocated_page = le2page(list_next(&(buddy_array[order_of_2])), page_link);
ffffffffc0200f56:	fe830513          	addi	a0,t1,-24
    prev->next = next;
ffffffffc0200f5a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200f5c:	e398                	sd	a4,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200f5e:	57f5                	li	a5,-3
ffffffffc0200f60:	ff030713          	addi	a4,t1,-16
ffffffffc0200f64:	60f7302f          	amoand.d	zero,a5,(a4)
        nr_free -= adjusted_pages; // 减少可用页数
ffffffffc0200f68:	0f88a783          	lw	a5,248(a7)
}
ffffffffc0200f6c:	60a2                	ld	ra,8(sp)
        nr_free -= adjusted_pages; // 减少可用页数
ffffffffc0200f6e:	4107883b          	subw	a6,a5,a6
ffffffffc0200f72:	0f08ac23          	sw	a6,248(a7)
}
ffffffffc0200f76:	0141                	addi	sp,sp,16
ffffffffc0200f78:	8082                	ret
ffffffffc0200f7a:	60a2                	ld	ra,8(sp)
        return NULL; // 如果请求页数大于可用页数，返回NULL
ffffffffc0200f7c:	4501                	li	a0,0
}
ffffffffc0200f7e:	0141                	addi	sp,sp,16
ffffffffc0200f80:	8082                	ret
ffffffffc0200f82:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200f84:	00185813          	srli	a6,a6,0x1
            res = res << 1;
ffffffffc0200f88:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200f8a:	fe081de3          	bnez	a6,ffffffffc0200f84 <buddy_system_alloc_pages+0x12c>
            res = res << 1;
ffffffffc0200f8e:	883e                	mv	a6,a5
ffffffffc0200f90:	b5f5                	j	ffffffffc0200e7c <buddy_system_alloc_pages+0x24>
    while (n >> 1)
ffffffffc0200f92:	47a1                	li	a5,8
    unsigned int order = 0;
ffffffffc0200f94:	4701                	li	a4,0
ffffffffc0200f96:	4e01                	li	t3,0
ffffffffc0200f98:	b701                	j	ffffffffc0200e98 <buddy_system_alloc_pages+0x40>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0200f9a:	00001697          	auipc	a3,0x1
ffffffffc0200f9e:	32e68693          	addi	a3,a3,814 # ffffffffc02022c8 <commands+0x910>
ffffffffc0200fa2:	00001617          	auipc	a2,0x1
ffffffffc0200fa6:	f1660613          	addi	a2,a2,-234 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200faa:	05200593          	li	a1,82
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	f2250513          	addi	a0,a0,-222 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200fb6:	bf6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0 && n <= max_order);
ffffffffc0200fba:	00001697          	auipc	a3,0x1
ffffffffc0200fbe:	2f668693          	addi	a3,a3,758 # ffffffffc02022b0 <commands+0x8f8>
ffffffffc0200fc2:	00001617          	auipc	a2,0x1
ffffffffc0200fc6:	ef660613          	addi	a2,a2,-266 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200fca:	05100593          	li	a1,81
ffffffffc0200fce:	00001517          	auipc	a0,0x1
ffffffffc0200fd2:	f0250513          	addi	a0,a0,-254 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200fd6:	bd6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(requested_pages > 0);
ffffffffc0200fda:	00001697          	auipc	a3,0x1
ffffffffc0200fde:	2be68693          	addi	a3,a3,702 # ffffffffc0202298 <commands+0x8e0>
ffffffffc0200fe2:	00001617          	auipc	a2,0x1
ffffffffc0200fe6:	ed660613          	addi	a2,a2,-298 # ffffffffc0201eb8 <commands+0x500>
ffffffffc0200fea:	0b000593          	li	a1,176
ffffffffc0200fee:	00001517          	auipc	a0,0x1
ffffffffc0200ff2:	ee250513          	addi	a0,a0,-286 # ffffffffc0201ed0 <commands+0x518>
ffffffffc0200ff6:	bb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200ffa <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0200ffe:	8b89                	andi	a5,a5,2
ffffffffc0201000:	e799                	bnez	a5,ffffffffc020100e <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201002:	00005797          	auipc	a5,0x5
ffffffffc0201006:	52e7b783          	ld	a5,1326(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc020100a:	6f9c                	ld	a5,24(a5)
ffffffffc020100c:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc020100e:	1141                	addi	sp,sp,-16
ffffffffc0201010:	e406                	sd	ra,8(sp)
ffffffffc0201012:	e022                	sd	s0,0(sp)
ffffffffc0201014:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201016:	c48ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020101a:	00005797          	auipc	a5,0x5
ffffffffc020101e:	5167b783          	ld	a5,1302(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0201022:	6f9c                	ld	a5,24(a5)
ffffffffc0201024:	8522                	mv	a0,s0
ffffffffc0201026:	9782                	jalr	a5
ffffffffc0201028:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020102a:	c2eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020102e:	60a2                	ld	ra,8(sp)
ffffffffc0201030:	8522                	mv	a0,s0
ffffffffc0201032:	6402                	ld	s0,0(sp)
ffffffffc0201034:	0141                	addi	sp,sp,16
ffffffffc0201036:	8082                	ret

ffffffffc0201038 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201038:	100027f3          	csrr	a5,sstatus
ffffffffc020103c:	8b89                	andi	a5,a5,2
ffffffffc020103e:	e799                	bnez	a5,ffffffffc020104c <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201040:	00005797          	auipc	a5,0x5
ffffffffc0201044:	4f07b783          	ld	a5,1264(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0201048:	739c                	ld	a5,32(a5)
ffffffffc020104a:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc020104c:	1101                	addi	sp,sp,-32
ffffffffc020104e:	ec06                	sd	ra,24(sp)
ffffffffc0201050:	e822                	sd	s0,16(sp)
ffffffffc0201052:	e426                	sd	s1,8(sp)
ffffffffc0201054:	842a                	mv	s0,a0
ffffffffc0201056:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201058:	c06ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020105c:	00005797          	auipc	a5,0x5
ffffffffc0201060:	4d47b783          	ld	a5,1236(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0201064:	739c                	ld	a5,32(a5)
ffffffffc0201066:	85a6                	mv	a1,s1
ffffffffc0201068:	8522                	mv	a0,s0
ffffffffc020106a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020106c:	6442                	ld	s0,16(sp)
ffffffffc020106e:	60e2                	ld	ra,24(sp)
ffffffffc0201070:	64a2                	ld	s1,8(sp)
ffffffffc0201072:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201074:	be4ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201078 <pmm_init>:
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc0201078:	00001797          	auipc	a5,0x1
ffffffffc020107c:	28878793          	addi	a5,a5,648 # ffffffffc0202300 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201080:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201082:	1101                	addi	sp,sp,-32
ffffffffc0201084:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201086:	00001517          	auipc	a0,0x1
ffffffffc020108a:	2b250513          	addi	a0,a0,690 # ffffffffc0202338 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc020108e:	00005497          	auipc	s1,0x5
ffffffffc0201092:	4a248493          	addi	s1,s1,1186 # ffffffffc0206530 <pmm_manager>
void pmm_init(void) {
ffffffffc0201096:	ec06                	sd	ra,24(sp)
ffffffffc0201098:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc020109a:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020109c:	816ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02010a0:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010a2:	00005417          	auipc	s0,0x5
ffffffffc02010a6:	4a640413          	addi	s0,s0,1190 # ffffffffc0206548 <va_pa_offset>
    pmm_manager->init();
ffffffffc02010aa:	679c                	ld	a5,8(a5)
ffffffffc02010ac:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010ae:	57f5                	li	a5,-3
ffffffffc02010b0:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02010b2:	00001517          	auipc	a0,0x1
ffffffffc02010b6:	29e50513          	addi	a0,a0,670 # ffffffffc0202350 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02010ba:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02010bc:	ff7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02010c0:	46c5                	li	a3,17
ffffffffc02010c2:	06ee                	slli	a3,a3,0x1b
ffffffffc02010c4:	40100613          	li	a2,1025
ffffffffc02010c8:	16fd                	addi	a3,a3,-1
ffffffffc02010ca:	07e005b7          	lui	a1,0x7e00
ffffffffc02010ce:	0656                	slli	a2,a2,0x15
ffffffffc02010d0:	00001517          	auipc	a0,0x1
ffffffffc02010d4:	29850513          	addi	a0,a0,664 # ffffffffc0202368 <buddy_pmm_manager+0x68>
ffffffffc02010d8:	fdbfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010dc:	777d                	lui	a4,0xfffff
ffffffffc02010de:	00006797          	auipc	a5,0x6
ffffffffc02010e2:	47978793          	addi	a5,a5,1145 # ffffffffc0207557 <end+0xfff>
ffffffffc02010e6:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02010e8:	00005517          	auipc	a0,0x5
ffffffffc02010ec:	43850513          	addi	a0,a0,1080 # ffffffffc0206520 <npage>
ffffffffc02010f0:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010f4:	00005597          	auipc	a1,0x5
ffffffffc02010f8:	43458593          	addi	a1,a1,1076 # ffffffffc0206528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02010fc:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02010fe:	e19c                	sd	a5,0(a1)
ffffffffc0201100:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201102:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201104:	4885                	li	a7,1
ffffffffc0201106:	fff80837          	lui	a6,0xfff80
ffffffffc020110a:	a011                	j	ffffffffc020110e <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020110c:	619c                	ld	a5,0(a1)
ffffffffc020110e:	97b6                	add	a5,a5,a3
ffffffffc0201110:	07a1                	addi	a5,a5,8
ffffffffc0201112:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201116:	611c                	ld	a5,0(a0)
ffffffffc0201118:	0705                	addi	a4,a4,1
ffffffffc020111a:	02868693          	addi	a3,a3,40
ffffffffc020111e:	01078633          	add	a2,a5,a6
ffffffffc0201122:	fec765e3          	bltu	a4,a2,ffffffffc020110c <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201126:	6190                	ld	a2,0(a1)
ffffffffc0201128:	00279713          	slli	a4,a5,0x2
ffffffffc020112c:	973e                	add	a4,a4,a5
ffffffffc020112e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201132:	070e                	slli	a4,a4,0x3
ffffffffc0201134:	96b2                	add	a3,a3,a2
ffffffffc0201136:	96ba                	add	a3,a3,a4
ffffffffc0201138:	c0200737          	lui	a4,0xc0200
ffffffffc020113c:	08e6ef63          	bltu	a3,a4,ffffffffc02011da <pmm_init+0x162>
ffffffffc0201140:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201142:	45c5                	li	a1,17
ffffffffc0201144:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201146:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201148:	04b6e863          	bltu	a3,a1,ffffffffc0201198 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020114c:	609c                	ld	a5,0(s1)
ffffffffc020114e:	7b9c                	ld	a5,48(a5)
ffffffffc0201150:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201152:	00001517          	auipc	a0,0x1
ffffffffc0201156:	2ae50513          	addi	a0,a0,686 # ffffffffc0202400 <buddy_pmm_manager+0x100>
ffffffffc020115a:	f59fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020115e:	00004597          	auipc	a1,0x4
ffffffffc0201162:	ea258593          	addi	a1,a1,-350 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201166:	00005797          	auipc	a5,0x5
ffffffffc020116a:	3cb7bd23          	sd	a1,986(a5) # ffffffffc0206540 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020116e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201172:	08f5e063          	bltu	a1,a5,ffffffffc02011f2 <pmm_init+0x17a>
ffffffffc0201176:	6010                	ld	a2,0(s0)
}
ffffffffc0201178:	6442                	ld	s0,16(sp)
ffffffffc020117a:	60e2                	ld	ra,24(sp)
ffffffffc020117c:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc020117e:	40c58633          	sub	a2,a1,a2
ffffffffc0201182:	00005797          	auipc	a5,0x5
ffffffffc0201186:	3ac7bb23          	sd	a2,950(a5) # ffffffffc0206538 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020118a:	00001517          	auipc	a0,0x1
ffffffffc020118e:	29650513          	addi	a0,a0,662 # ffffffffc0202420 <buddy_pmm_manager+0x120>
}
ffffffffc0201192:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201194:	f1ffe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201198:	6705                	lui	a4,0x1
ffffffffc020119a:	177d                	addi	a4,a4,-1
ffffffffc020119c:	96ba                	add	a3,a3,a4
ffffffffc020119e:	777d                	lui	a4,0xfffff
ffffffffc02011a0:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02011a2:	00c6d513          	srli	a0,a3,0xc
ffffffffc02011a6:	00f57e63          	bgeu	a0,a5,ffffffffc02011c2 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02011aa:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02011ac:	982a                	add	a6,a6,a0
ffffffffc02011ae:	00281513          	slli	a0,a6,0x2
ffffffffc02011b2:	9542                	add	a0,a0,a6
ffffffffc02011b4:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02011b6:	8d95                	sub	a1,a1,a3
ffffffffc02011b8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02011ba:	81b1                	srli	a1,a1,0xc
ffffffffc02011bc:	9532                	add	a0,a0,a2
ffffffffc02011be:	9782                	jalr	a5
}
ffffffffc02011c0:	b771                	j	ffffffffc020114c <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02011c2:	00001617          	auipc	a2,0x1
ffffffffc02011c6:	20e60613          	addi	a2,a2,526 # ffffffffc02023d0 <buddy_pmm_manager+0xd0>
ffffffffc02011ca:	06b00593          	li	a1,107
ffffffffc02011ce:	00001517          	auipc	a0,0x1
ffffffffc02011d2:	22250513          	addi	a0,a0,546 # ffffffffc02023f0 <buddy_pmm_manager+0xf0>
ffffffffc02011d6:	9d6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011da:	00001617          	auipc	a2,0x1
ffffffffc02011de:	1be60613          	addi	a2,a2,446 # ffffffffc0202398 <buddy_pmm_manager+0x98>
ffffffffc02011e2:	07500593          	li	a1,117
ffffffffc02011e6:	00001517          	auipc	a0,0x1
ffffffffc02011ea:	1da50513          	addi	a0,a0,474 # ffffffffc02023c0 <buddy_pmm_manager+0xc0>
ffffffffc02011ee:	9beff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02011f2:	86ae                	mv	a3,a1
ffffffffc02011f4:	00001617          	auipc	a2,0x1
ffffffffc02011f8:	1a460613          	addi	a2,a2,420 # ffffffffc0202398 <buddy_pmm_manager+0x98>
ffffffffc02011fc:	09000593          	li	a1,144
ffffffffc0201200:	00001517          	auipc	a0,0x1
ffffffffc0201204:	1c050513          	addi	a0,a0,448 # ffffffffc02023c0 <buddy_pmm_manager+0xc0>
ffffffffc0201208:	9a4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020120c <printnum>:
ffffffffc020120c:	02069813          	slli	a6,a3,0x20
ffffffffc0201210:	7179                	addi	sp,sp,-48
ffffffffc0201212:	02085813          	srli	a6,a6,0x20
ffffffffc0201216:	e052                	sd	s4,0(sp)
ffffffffc0201218:	03067a33          	remu	s4,a2,a6
ffffffffc020121c:	f022                	sd	s0,32(sp)
ffffffffc020121e:	ec26                	sd	s1,24(sp)
ffffffffc0201220:	e84a                	sd	s2,16(sp)
ffffffffc0201222:	f406                	sd	ra,40(sp)
ffffffffc0201224:	e44e                	sd	s3,8(sp)
ffffffffc0201226:	84aa                	mv	s1,a0
ffffffffc0201228:	892e                	mv	s2,a1
ffffffffc020122a:	fff7041b          	addiw	s0,a4,-1
ffffffffc020122e:	2a01                	sext.w	s4,s4
ffffffffc0201230:	03067e63          	bgeu	a2,a6,ffffffffc020126c <printnum+0x60>
ffffffffc0201234:	89be                	mv	s3,a5
ffffffffc0201236:	00805763          	blez	s0,ffffffffc0201244 <printnum+0x38>
ffffffffc020123a:	347d                	addiw	s0,s0,-1
ffffffffc020123c:	85ca                	mv	a1,s2
ffffffffc020123e:	854e                	mv	a0,s3
ffffffffc0201240:	9482                	jalr	s1
ffffffffc0201242:	fc65                	bnez	s0,ffffffffc020123a <printnum+0x2e>
ffffffffc0201244:	1a02                	slli	s4,s4,0x20
ffffffffc0201246:	00001797          	auipc	a5,0x1
ffffffffc020124a:	21a78793          	addi	a5,a5,538 # ffffffffc0202460 <buddy_pmm_manager+0x160>
ffffffffc020124e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201252:	9a3e                	add	s4,s4,a5
ffffffffc0201254:	7402                	ld	s0,32(sp)
ffffffffc0201256:	000a4503          	lbu	a0,0(s4)
ffffffffc020125a:	70a2                	ld	ra,40(sp)
ffffffffc020125c:	69a2                	ld	s3,8(sp)
ffffffffc020125e:	6a02                	ld	s4,0(sp)
ffffffffc0201260:	85ca                	mv	a1,s2
ffffffffc0201262:	87a6                	mv	a5,s1
ffffffffc0201264:	6942                	ld	s2,16(sp)
ffffffffc0201266:	64e2                	ld	s1,24(sp)
ffffffffc0201268:	6145                	addi	sp,sp,48
ffffffffc020126a:	8782                	jr	a5
ffffffffc020126c:	03065633          	divu	a2,a2,a6
ffffffffc0201270:	8722                	mv	a4,s0
ffffffffc0201272:	f9bff0ef          	jal	ra,ffffffffc020120c <printnum>
ffffffffc0201276:	b7f9                	j	ffffffffc0201244 <printnum+0x38>

ffffffffc0201278 <vprintfmt>:
ffffffffc0201278:	7119                	addi	sp,sp,-128
ffffffffc020127a:	f4a6                	sd	s1,104(sp)
ffffffffc020127c:	f0ca                	sd	s2,96(sp)
ffffffffc020127e:	ecce                	sd	s3,88(sp)
ffffffffc0201280:	e8d2                	sd	s4,80(sp)
ffffffffc0201282:	e4d6                	sd	s5,72(sp)
ffffffffc0201284:	e0da                	sd	s6,64(sp)
ffffffffc0201286:	fc5e                	sd	s7,56(sp)
ffffffffc0201288:	f06a                	sd	s10,32(sp)
ffffffffc020128a:	fc86                	sd	ra,120(sp)
ffffffffc020128c:	f8a2                	sd	s0,112(sp)
ffffffffc020128e:	f862                	sd	s8,48(sp)
ffffffffc0201290:	f466                	sd	s9,40(sp)
ffffffffc0201292:	ec6e                	sd	s11,24(sp)
ffffffffc0201294:	892a                	mv	s2,a0
ffffffffc0201296:	84ae                	mv	s1,a1
ffffffffc0201298:	8d32                	mv	s10,a2
ffffffffc020129a:	8a36                	mv	s4,a3
ffffffffc020129c:	02500993          	li	s3,37
ffffffffc02012a0:	5b7d                	li	s6,-1
ffffffffc02012a2:	00001a97          	auipc	s5,0x1
ffffffffc02012a6:	1f2a8a93          	addi	s5,s5,498 # ffffffffc0202494 <buddy_pmm_manager+0x194>
ffffffffc02012aa:	00001b97          	auipc	s7,0x1
ffffffffc02012ae:	3c6b8b93          	addi	s7,s7,966 # ffffffffc0202670 <error_string>
ffffffffc02012b2:	000d4503          	lbu	a0,0(s10)
ffffffffc02012b6:	001d0413          	addi	s0,s10,1
ffffffffc02012ba:	01350a63          	beq	a0,s3,ffffffffc02012ce <vprintfmt+0x56>
ffffffffc02012be:	c121                	beqz	a0,ffffffffc02012fe <vprintfmt+0x86>
ffffffffc02012c0:	85a6                	mv	a1,s1
ffffffffc02012c2:	0405                	addi	s0,s0,1
ffffffffc02012c4:	9902                	jalr	s2
ffffffffc02012c6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012ca:	ff351ae3          	bne	a0,s3,ffffffffc02012be <vprintfmt+0x46>
ffffffffc02012ce:	00044603          	lbu	a2,0(s0)
ffffffffc02012d2:	02000793          	li	a5,32
ffffffffc02012d6:	4c81                	li	s9,0
ffffffffc02012d8:	4881                	li	a7,0
ffffffffc02012da:	5c7d                	li	s8,-1
ffffffffc02012dc:	5dfd                	li	s11,-1
ffffffffc02012de:	05500513          	li	a0,85
ffffffffc02012e2:	4825                	li	a6,9
ffffffffc02012e4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02012e8:	0ff5f593          	zext.b	a1,a1
ffffffffc02012ec:	00140d13          	addi	s10,s0,1
ffffffffc02012f0:	04b56263          	bltu	a0,a1,ffffffffc0201334 <vprintfmt+0xbc>
ffffffffc02012f4:	058a                	slli	a1,a1,0x2
ffffffffc02012f6:	95d6                	add	a1,a1,s5
ffffffffc02012f8:	4194                	lw	a3,0(a1)
ffffffffc02012fa:	96d6                	add	a3,a3,s5
ffffffffc02012fc:	8682                	jr	a3
ffffffffc02012fe:	70e6                	ld	ra,120(sp)
ffffffffc0201300:	7446                	ld	s0,112(sp)
ffffffffc0201302:	74a6                	ld	s1,104(sp)
ffffffffc0201304:	7906                	ld	s2,96(sp)
ffffffffc0201306:	69e6                	ld	s3,88(sp)
ffffffffc0201308:	6a46                	ld	s4,80(sp)
ffffffffc020130a:	6aa6                	ld	s5,72(sp)
ffffffffc020130c:	6b06                	ld	s6,64(sp)
ffffffffc020130e:	7be2                	ld	s7,56(sp)
ffffffffc0201310:	7c42                	ld	s8,48(sp)
ffffffffc0201312:	7ca2                	ld	s9,40(sp)
ffffffffc0201314:	7d02                	ld	s10,32(sp)
ffffffffc0201316:	6de2                	ld	s11,24(sp)
ffffffffc0201318:	6109                	addi	sp,sp,128
ffffffffc020131a:	8082                	ret
ffffffffc020131c:	87b2                	mv	a5,a2
ffffffffc020131e:	00144603          	lbu	a2,1(s0)
ffffffffc0201322:	846a                	mv	s0,s10
ffffffffc0201324:	00140d13          	addi	s10,s0,1
ffffffffc0201328:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020132c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201330:	fcb572e3          	bgeu	a0,a1,ffffffffc02012f4 <vprintfmt+0x7c>
ffffffffc0201334:	85a6                	mv	a1,s1
ffffffffc0201336:	02500513          	li	a0,37
ffffffffc020133a:	9902                	jalr	s2
ffffffffc020133c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201340:	8d22                	mv	s10,s0
ffffffffc0201342:	f73788e3          	beq	a5,s3,ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc0201346:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020134a:	1d7d                	addi	s10,s10,-1
ffffffffc020134c:	ff379de3          	bne	a5,s3,ffffffffc0201346 <vprintfmt+0xce>
ffffffffc0201350:	b78d                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc0201352:	fd060c1b          	addiw	s8,a2,-48
ffffffffc0201356:	00144603          	lbu	a2,1(s0)
ffffffffc020135a:	846a                	mv	s0,s10
ffffffffc020135c:	fd06069b          	addiw	a3,a2,-48
ffffffffc0201360:	0006059b          	sext.w	a1,a2
ffffffffc0201364:	02d86463          	bltu	a6,a3,ffffffffc020138c <vprintfmt+0x114>
ffffffffc0201368:	00144603          	lbu	a2,1(s0)
ffffffffc020136c:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201370:	0186873b          	addw	a4,a3,s8
ffffffffc0201374:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201378:	9f2d                	addw	a4,a4,a1
ffffffffc020137a:	fd06069b          	addiw	a3,a2,-48
ffffffffc020137e:	0405                	addi	s0,s0,1
ffffffffc0201380:	fd070c1b          	addiw	s8,a4,-48
ffffffffc0201384:	0006059b          	sext.w	a1,a2
ffffffffc0201388:	fed870e3          	bgeu	a6,a3,ffffffffc0201368 <vprintfmt+0xf0>
ffffffffc020138c:	f40ddce3          	bgez	s11,ffffffffc02012e4 <vprintfmt+0x6c>
ffffffffc0201390:	8de2                	mv	s11,s8
ffffffffc0201392:	5c7d                	li	s8,-1
ffffffffc0201394:	bf81                	j	ffffffffc02012e4 <vprintfmt+0x6c>
ffffffffc0201396:	fffdc693          	not	a3,s11
ffffffffc020139a:	96fd                	srai	a3,a3,0x3f
ffffffffc020139c:	00ddfdb3          	and	s11,s11,a3
ffffffffc02013a0:	00144603          	lbu	a2,1(s0)
ffffffffc02013a4:	2d81                	sext.w	s11,s11
ffffffffc02013a6:	846a                	mv	s0,s10
ffffffffc02013a8:	bf35                	j	ffffffffc02012e4 <vprintfmt+0x6c>
ffffffffc02013aa:	000a2c03          	lw	s8,0(s4)
ffffffffc02013ae:	00144603          	lbu	a2,1(s0)
ffffffffc02013b2:	0a21                	addi	s4,s4,8
ffffffffc02013b4:	846a                	mv	s0,s10
ffffffffc02013b6:	bfd9                	j	ffffffffc020138c <vprintfmt+0x114>
ffffffffc02013b8:	4705                	li	a4,1
ffffffffc02013ba:	008a0593          	addi	a1,s4,8
ffffffffc02013be:	01174463          	blt	a4,a7,ffffffffc02013c6 <vprintfmt+0x14e>
ffffffffc02013c2:	1a088e63          	beqz	a7,ffffffffc020157e <vprintfmt+0x306>
ffffffffc02013c6:	000a3603          	ld	a2,0(s4)
ffffffffc02013ca:	46c1                	li	a3,16
ffffffffc02013cc:	8a2e                	mv	s4,a1
ffffffffc02013ce:	2781                	sext.w	a5,a5
ffffffffc02013d0:	876e                	mv	a4,s11
ffffffffc02013d2:	85a6                	mv	a1,s1
ffffffffc02013d4:	854a                	mv	a0,s2
ffffffffc02013d6:	e37ff0ef          	jal	ra,ffffffffc020120c <printnum>
ffffffffc02013da:	bde1                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc02013dc:	000a2503          	lw	a0,0(s4)
ffffffffc02013e0:	85a6                	mv	a1,s1
ffffffffc02013e2:	0a21                	addi	s4,s4,8
ffffffffc02013e4:	9902                	jalr	s2
ffffffffc02013e6:	b5f1                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc02013e8:	4705                	li	a4,1
ffffffffc02013ea:	008a0593          	addi	a1,s4,8
ffffffffc02013ee:	01174463          	blt	a4,a7,ffffffffc02013f6 <vprintfmt+0x17e>
ffffffffc02013f2:	18088163          	beqz	a7,ffffffffc0201574 <vprintfmt+0x2fc>
ffffffffc02013f6:	000a3603          	ld	a2,0(s4)
ffffffffc02013fa:	46a9                	li	a3,10
ffffffffc02013fc:	8a2e                	mv	s4,a1
ffffffffc02013fe:	bfc1                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc0201400:	00144603          	lbu	a2,1(s0)
ffffffffc0201404:	4c85                	li	s9,1
ffffffffc0201406:	846a                	mv	s0,s10
ffffffffc0201408:	bdf1                	j	ffffffffc02012e4 <vprintfmt+0x6c>
ffffffffc020140a:	85a6                	mv	a1,s1
ffffffffc020140c:	02500513          	li	a0,37
ffffffffc0201410:	9902                	jalr	s2
ffffffffc0201412:	b545                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc0201414:	00144603          	lbu	a2,1(s0)
ffffffffc0201418:	2885                	addiw	a7,a7,1
ffffffffc020141a:	846a                	mv	s0,s10
ffffffffc020141c:	b5e1                	j	ffffffffc02012e4 <vprintfmt+0x6c>
ffffffffc020141e:	4705                	li	a4,1
ffffffffc0201420:	008a0593          	addi	a1,s4,8
ffffffffc0201424:	01174463          	blt	a4,a7,ffffffffc020142c <vprintfmt+0x1b4>
ffffffffc0201428:	14088163          	beqz	a7,ffffffffc020156a <vprintfmt+0x2f2>
ffffffffc020142c:	000a3603          	ld	a2,0(s4)
ffffffffc0201430:	46a1                	li	a3,8
ffffffffc0201432:	8a2e                	mv	s4,a1
ffffffffc0201434:	bf69                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc0201436:	03000513          	li	a0,48
ffffffffc020143a:	85a6                	mv	a1,s1
ffffffffc020143c:	e03e                	sd	a5,0(sp)
ffffffffc020143e:	9902                	jalr	s2
ffffffffc0201440:	85a6                	mv	a1,s1
ffffffffc0201442:	07800513          	li	a0,120
ffffffffc0201446:	9902                	jalr	s2
ffffffffc0201448:	0a21                	addi	s4,s4,8
ffffffffc020144a:	6782                	ld	a5,0(sp)
ffffffffc020144c:	46c1                	li	a3,16
ffffffffc020144e:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0201452:	bfb5                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc0201454:	000a3403          	ld	s0,0(s4)
ffffffffc0201458:	008a0713          	addi	a4,s4,8
ffffffffc020145c:	e03a                	sd	a4,0(sp)
ffffffffc020145e:	14040263          	beqz	s0,ffffffffc02015a2 <vprintfmt+0x32a>
ffffffffc0201462:	0fb05763          	blez	s11,ffffffffc0201550 <vprintfmt+0x2d8>
ffffffffc0201466:	02d00693          	li	a3,45
ffffffffc020146a:	0cd79163          	bne	a5,a3,ffffffffc020152c <vprintfmt+0x2b4>
ffffffffc020146e:	00044783          	lbu	a5,0(s0)
ffffffffc0201472:	0007851b          	sext.w	a0,a5
ffffffffc0201476:	cf85                	beqz	a5,ffffffffc02014ae <vprintfmt+0x236>
ffffffffc0201478:	00140a13          	addi	s4,s0,1
ffffffffc020147c:	05e00413          	li	s0,94
ffffffffc0201480:	000c4563          	bltz	s8,ffffffffc020148a <vprintfmt+0x212>
ffffffffc0201484:	3c7d                	addiw	s8,s8,-1
ffffffffc0201486:	036c0263          	beq	s8,s6,ffffffffc02014aa <vprintfmt+0x232>
ffffffffc020148a:	85a6                	mv	a1,s1
ffffffffc020148c:	0e0c8e63          	beqz	s9,ffffffffc0201588 <vprintfmt+0x310>
ffffffffc0201490:	3781                	addiw	a5,a5,-32
ffffffffc0201492:	0ef47b63          	bgeu	s0,a5,ffffffffc0201588 <vprintfmt+0x310>
ffffffffc0201496:	03f00513          	li	a0,63
ffffffffc020149a:	9902                	jalr	s2
ffffffffc020149c:	000a4783          	lbu	a5,0(s4)
ffffffffc02014a0:	3dfd                	addiw	s11,s11,-1
ffffffffc02014a2:	0a05                	addi	s4,s4,1
ffffffffc02014a4:	0007851b          	sext.w	a0,a5
ffffffffc02014a8:	ffe1                	bnez	a5,ffffffffc0201480 <vprintfmt+0x208>
ffffffffc02014aa:	01b05963          	blez	s11,ffffffffc02014bc <vprintfmt+0x244>
ffffffffc02014ae:	3dfd                	addiw	s11,s11,-1
ffffffffc02014b0:	85a6                	mv	a1,s1
ffffffffc02014b2:	02000513          	li	a0,32
ffffffffc02014b6:	9902                	jalr	s2
ffffffffc02014b8:	fe0d9be3          	bnez	s11,ffffffffc02014ae <vprintfmt+0x236>
ffffffffc02014bc:	6a02                	ld	s4,0(sp)
ffffffffc02014be:	bbd5                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc02014c0:	4705                	li	a4,1
ffffffffc02014c2:	008a0c93          	addi	s9,s4,8
ffffffffc02014c6:	01174463          	blt	a4,a7,ffffffffc02014ce <vprintfmt+0x256>
ffffffffc02014ca:	08088d63          	beqz	a7,ffffffffc0201564 <vprintfmt+0x2ec>
ffffffffc02014ce:	000a3403          	ld	s0,0(s4)
ffffffffc02014d2:	0a044d63          	bltz	s0,ffffffffc020158c <vprintfmt+0x314>
ffffffffc02014d6:	8622                	mv	a2,s0
ffffffffc02014d8:	8a66                	mv	s4,s9
ffffffffc02014da:	46a9                	li	a3,10
ffffffffc02014dc:	bdcd                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc02014de:	000a2783          	lw	a5,0(s4)
ffffffffc02014e2:	4719                	li	a4,6
ffffffffc02014e4:	0a21                	addi	s4,s4,8
ffffffffc02014e6:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02014ea:	8fb5                	xor	a5,a5,a3
ffffffffc02014ec:	40d786bb          	subw	a3,a5,a3
ffffffffc02014f0:	02d74163          	blt	a4,a3,ffffffffc0201512 <vprintfmt+0x29a>
ffffffffc02014f4:	00369793          	slli	a5,a3,0x3
ffffffffc02014f8:	97de                	add	a5,a5,s7
ffffffffc02014fa:	639c                	ld	a5,0(a5)
ffffffffc02014fc:	cb99                	beqz	a5,ffffffffc0201512 <vprintfmt+0x29a>
ffffffffc02014fe:	86be                	mv	a3,a5
ffffffffc0201500:	00001617          	auipc	a2,0x1
ffffffffc0201504:	f9060613          	addi	a2,a2,-112 # ffffffffc0202490 <buddy_pmm_manager+0x190>
ffffffffc0201508:	85a6                	mv	a1,s1
ffffffffc020150a:	854a                	mv	a0,s2
ffffffffc020150c:	0ce000ef          	jal	ra,ffffffffc02015da <printfmt>
ffffffffc0201510:	b34d                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc0201512:	00001617          	auipc	a2,0x1
ffffffffc0201516:	f6e60613          	addi	a2,a2,-146 # ffffffffc0202480 <buddy_pmm_manager+0x180>
ffffffffc020151a:	85a6                	mv	a1,s1
ffffffffc020151c:	854a                	mv	a0,s2
ffffffffc020151e:	0bc000ef          	jal	ra,ffffffffc02015da <printfmt>
ffffffffc0201522:	bb41                	j	ffffffffc02012b2 <vprintfmt+0x3a>
ffffffffc0201524:	00001417          	auipc	s0,0x1
ffffffffc0201528:	f5440413          	addi	s0,s0,-172 # ffffffffc0202478 <buddy_pmm_manager+0x178>
ffffffffc020152c:	85e2                	mv	a1,s8
ffffffffc020152e:	8522                	mv	a0,s0
ffffffffc0201530:	e43e                	sd	a5,8(sp)
ffffffffc0201532:	1cc000ef          	jal	ra,ffffffffc02016fe <strnlen>
ffffffffc0201536:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020153a:	01b05b63          	blez	s11,ffffffffc0201550 <vprintfmt+0x2d8>
ffffffffc020153e:	67a2                	ld	a5,8(sp)
ffffffffc0201540:	00078a1b          	sext.w	s4,a5
ffffffffc0201544:	3dfd                	addiw	s11,s11,-1
ffffffffc0201546:	85a6                	mv	a1,s1
ffffffffc0201548:	8552                	mv	a0,s4
ffffffffc020154a:	9902                	jalr	s2
ffffffffc020154c:	fe0d9ce3          	bnez	s11,ffffffffc0201544 <vprintfmt+0x2cc>
ffffffffc0201550:	00044783          	lbu	a5,0(s0)
ffffffffc0201554:	00140a13          	addi	s4,s0,1
ffffffffc0201558:	0007851b          	sext.w	a0,a5
ffffffffc020155c:	d3a5                	beqz	a5,ffffffffc02014bc <vprintfmt+0x244>
ffffffffc020155e:	05e00413          	li	s0,94
ffffffffc0201562:	bf39                	j	ffffffffc0201480 <vprintfmt+0x208>
ffffffffc0201564:	000a2403          	lw	s0,0(s4)
ffffffffc0201568:	b7ad                	j	ffffffffc02014d2 <vprintfmt+0x25a>
ffffffffc020156a:	000a6603          	lwu	a2,0(s4)
ffffffffc020156e:	46a1                	li	a3,8
ffffffffc0201570:	8a2e                	mv	s4,a1
ffffffffc0201572:	bdb1                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc0201574:	000a6603          	lwu	a2,0(s4)
ffffffffc0201578:	46a9                	li	a3,10
ffffffffc020157a:	8a2e                	mv	s4,a1
ffffffffc020157c:	bd89                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc020157e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201582:	46c1                	li	a3,16
ffffffffc0201584:	8a2e                	mv	s4,a1
ffffffffc0201586:	b5a1                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc0201588:	9902                	jalr	s2
ffffffffc020158a:	bf09                	j	ffffffffc020149c <vprintfmt+0x224>
ffffffffc020158c:	85a6                	mv	a1,s1
ffffffffc020158e:	02d00513          	li	a0,45
ffffffffc0201592:	e03e                	sd	a5,0(sp)
ffffffffc0201594:	9902                	jalr	s2
ffffffffc0201596:	6782                	ld	a5,0(sp)
ffffffffc0201598:	8a66                	mv	s4,s9
ffffffffc020159a:	40800633          	neg	a2,s0
ffffffffc020159e:	46a9                	li	a3,10
ffffffffc02015a0:	b53d                	j	ffffffffc02013ce <vprintfmt+0x156>
ffffffffc02015a2:	03b05163          	blez	s11,ffffffffc02015c4 <vprintfmt+0x34c>
ffffffffc02015a6:	02d00693          	li	a3,45
ffffffffc02015aa:	f6d79de3          	bne	a5,a3,ffffffffc0201524 <vprintfmt+0x2ac>
ffffffffc02015ae:	00001417          	auipc	s0,0x1
ffffffffc02015b2:	eca40413          	addi	s0,s0,-310 # ffffffffc0202478 <buddy_pmm_manager+0x178>
ffffffffc02015b6:	02800793          	li	a5,40
ffffffffc02015ba:	02800513          	li	a0,40
ffffffffc02015be:	00140a13          	addi	s4,s0,1
ffffffffc02015c2:	bd6d                	j	ffffffffc020147c <vprintfmt+0x204>
ffffffffc02015c4:	00001a17          	auipc	s4,0x1
ffffffffc02015c8:	eb5a0a13          	addi	s4,s4,-331 # ffffffffc0202479 <buddy_pmm_manager+0x179>
ffffffffc02015cc:	02800513          	li	a0,40
ffffffffc02015d0:	02800793          	li	a5,40
ffffffffc02015d4:	05e00413          	li	s0,94
ffffffffc02015d8:	b565                	j	ffffffffc0201480 <vprintfmt+0x208>

ffffffffc02015da <printfmt>:
ffffffffc02015da:	715d                	addi	sp,sp,-80
ffffffffc02015dc:	02810313          	addi	t1,sp,40
ffffffffc02015e0:	f436                	sd	a3,40(sp)
ffffffffc02015e2:	869a                	mv	a3,t1
ffffffffc02015e4:	ec06                	sd	ra,24(sp)
ffffffffc02015e6:	f83a                	sd	a4,48(sp)
ffffffffc02015e8:	fc3e                	sd	a5,56(sp)
ffffffffc02015ea:	e0c2                	sd	a6,64(sp)
ffffffffc02015ec:	e4c6                	sd	a7,72(sp)
ffffffffc02015ee:	e41a                	sd	t1,8(sp)
ffffffffc02015f0:	c89ff0ef          	jal	ra,ffffffffc0201278 <vprintfmt>
ffffffffc02015f4:	60e2                	ld	ra,24(sp)
ffffffffc02015f6:	6161                	addi	sp,sp,80
ffffffffc02015f8:	8082                	ret

ffffffffc02015fa <readline>:
ffffffffc02015fa:	715d                	addi	sp,sp,-80
ffffffffc02015fc:	e486                	sd	ra,72(sp)
ffffffffc02015fe:	e0a6                	sd	s1,64(sp)
ffffffffc0201600:	fc4a                	sd	s2,56(sp)
ffffffffc0201602:	f84e                	sd	s3,48(sp)
ffffffffc0201604:	f452                	sd	s4,40(sp)
ffffffffc0201606:	f056                	sd	s5,32(sp)
ffffffffc0201608:	ec5a                	sd	s6,24(sp)
ffffffffc020160a:	e85e                	sd	s7,16(sp)
ffffffffc020160c:	c901                	beqz	a0,ffffffffc020161c <readline+0x22>
ffffffffc020160e:	85aa                	mv	a1,a0
ffffffffc0201610:	00001517          	auipc	a0,0x1
ffffffffc0201614:	e8050513          	addi	a0,a0,-384 # ffffffffc0202490 <buddy_pmm_manager+0x190>
ffffffffc0201618:	a9bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020161c:	4481                	li	s1,0
ffffffffc020161e:	497d                	li	s2,31
ffffffffc0201620:	49a1                	li	s3,8
ffffffffc0201622:	4aa9                	li	s5,10
ffffffffc0201624:	4b35                	li	s6,13
ffffffffc0201626:	00005b97          	auipc	s7,0x5
ffffffffc020162a:	aeab8b93          	addi	s7,s7,-1302 # ffffffffc0206110 <buf>
ffffffffc020162e:	3fe00a13          	li	s4,1022
ffffffffc0201632:	af9fe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201636:	00054a63          	bltz	a0,ffffffffc020164a <readline+0x50>
ffffffffc020163a:	00a95a63          	bge	s2,a0,ffffffffc020164e <readline+0x54>
ffffffffc020163e:	029a5263          	bge	s4,s1,ffffffffc0201662 <readline+0x68>
ffffffffc0201642:	ae9fe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201646:	fe055ae3          	bgez	a0,ffffffffc020163a <readline+0x40>
ffffffffc020164a:	4501                	li	a0,0
ffffffffc020164c:	a091                	j	ffffffffc0201690 <readline+0x96>
ffffffffc020164e:	03351463          	bne	a0,s3,ffffffffc0201676 <readline+0x7c>
ffffffffc0201652:	e8a9                	bnez	s1,ffffffffc02016a4 <readline+0xaa>
ffffffffc0201654:	ad7fe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201658:	fe0549e3          	bltz	a0,ffffffffc020164a <readline+0x50>
ffffffffc020165c:	fea959e3          	bge	s2,a0,ffffffffc020164e <readline+0x54>
ffffffffc0201660:	4481                	li	s1,0
ffffffffc0201662:	e42a                	sd	a0,8(sp)
ffffffffc0201664:	a85fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201668:	6522                	ld	a0,8(sp)
ffffffffc020166a:	009b87b3          	add	a5,s7,s1
ffffffffc020166e:	2485                	addiw	s1,s1,1
ffffffffc0201670:	00a78023          	sb	a0,0(a5)
ffffffffc0201674:	bf7d                	j	ffffffffc0201632 <readline+0x38>
ffffffffc0201676:	01550463          	beq	a0,s5,ffffffffc020167e <readline+0x84>
ffffffffc020167a:	fb651ce3          	bne	a0,s6,ffffffffc0201632 <readline+0x38>
ffffffffc020167e:	a6bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201682:	00005517          	auipc	a0,0x5
ffffffffc0201686:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0206110 <buf>
ffffffffc020168a:	94aa                	add	s1,s1,a0
ffffffffc020168c:	00048023          	sb	zero,0(s1)
ffffffffc0201690:	60a6                	ld	ra,72(sp)
ffffffffc0201692:	6486                	ld	s1,64(sp)
ffffffffc0201694:	7962                	ld	s2,56(sp)
ffffffffc0201696:	79c2                	ld	s3,48(sp)
ffffffffc0201698:	7a22                	ld	s4,40(sp)
ffffffffc020169a:	7a82                	ld	s5,32(sp)
ffffffffc020169c:	6b62                	ld	s6,24(sp)
ffffffffc020169e:	6bc2                	ld	s7,16(sp)
ffffffffc02016a0:	6161                	addi	sp,sp,80
ffffffffc02016a2:	8082                	ret
ffffffffc02016a4:	4521                	li	a0,8
ffffffffc02016a6:	a43fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc02016aa:	34fd                	addiw	s1,s1,-1
ffffffffc02016ac:	b759                	j	ffffffffc0201632 <readline+0x38>

ffffffffc02016ae <sbi_console_putchar>:
ffffffffc02016ae:	4781                	li	a5,0
ffffffffc02016b0:	00005717          	auipc	a4,0x5
ffffffffc02016b4:	95873703          	ld	a4,-1704(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016b8:	88ba                	mv	a7,a4
ffffffffc02016ba:	852a                	mv	a0,a0
ffffffffc02016bc:	85be                	mv	a1,a5
ffffffffc02016be:	863e                	mv	a2,a5
ffffffffc02016c0:	00000073          	ecall
ffffffffc02016c4:	87aa                	mv	a5,a0
ffffffffc02016c6:	8082                	ret

ffffffffc02016c8 <sbi_set_timer>:
ffffffffc02016c8:	4781                	li	a5,0
ffffffffc02016ca:	00005717          	auipc	a4,0x5
ffffffffc02016ce:	e8673703          	ld	a4,-378(a4) # ffffffffc0206550 <SBI_SET_TIMER>
ffffffffc02016d2:	88ba                	mv	a7,a4
ffffffffc02016d4:	852a                	mv	a0,a0
ffffffffc02016d6:	85be                	mv	a1,a5
ffffffffc02016d8:	863e                	mv	a2,a5
ffffffffc02016da:	00000073          	ecall
ffffffffc02016de:	87aa                	mv	a5,a0
ffffffffc02016e0:	8082                	ret

ffffffffc02016e2 <sbi_console_getchar>:
ffffffffc02016e2:	4501                	li	a0,0
ffffffffc02016e4:	00005797          	auipc	a5,0x5
ffffffffc02016e8:	91c7b783          	ld	a5,-1764(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc02016ec:	88be                	mv	a7,a5
ffffffffc02016ee:	852a                	mv	a0,a0
ffffffffc02016f0:	85aa                	mv	a1,a0
ffffffffc02016f2:	862a                	mv	a2,a0
ffffffffc02016f4:	00000073          	ecall
ffffffffc02016f8:	852a                	mv	a0,a0
ffffffffc02016fa:	2501                	sext.w	a0,a0
ffffffffc02016fc:	8082                	ret

ffffffffc02016fe <strnlen>:
ffffffffc02016fe:	4781                	li	a5,0
ffffffffc0201700:	e589                	bnez	a1,ffffffffc020170a <strnlen+0xc>
ffffffffc0201702:	a811                	j	ffffffffc0201716 <strnlen+0x18>
ffffffffc0201704:	0785                	addi	a5,a5,1
ffffffffc0201706:	00f58863          	beq	a1,a5,ffffffffc0201716 <strnlen+0x18>
ffffffffc020170a:	00f50733          	add	a4,a0,a5
ffffffffc020170e:	00074703          	lbu	a4,0(a4)
ffffffffc0201712:	fb6d                	bnez	a4,ffffffffc0201704 <strnlen+0x6>
ffffffffc0201714:	85be                	mv	a1,a5
ffffffffc0201716:	852e                	mv	a0,a1
ffffffffc0201718:	8082                	ret

ffffffffc020171a <strcmp>:
ffffffffc020171a:	00054783          	lbu	a5,0(a0)
ffffffffc020171e:	0005c703          	lbu	a4,0(a1)
ffffffffc0201722:	cb89                	beqz	a5,ffffffffc0201734 <strcmp+0x1a>
ffffffffc0201724:	0505                	addi	a0,a0,1
ffffffffc0201726:	0585                	addi	a1,a1,1
ffffffffc0201728:	fee789e3          	beq	a5,a4,ffffffffc020171a <strcmp>
ffffffffc020172c:	0007851b          	sext.w	a0,a5
ffffffffc0201730:	9d19                	subw	a0,a0,a4
ffffffffc0201732:	8082                	ret
ffffffffc0201734:	4501                	li	a0,0
ffffffffc0201736:	bfed                	j	ffffffffc0201730 <strcmp+0x16>

ffffffffc0201738 <strchr>:
ffffffffc0201738:	00054783          	lbu	a5,0(a0)
ffffffffc020173c:	c799                	beqz	a5,ffffffffc020174a <strchr+0x12>
ffffffffc020173e:	00f58763          	beq	a1,a5,ffffffffc020174c <strchr+0x14>
ffffffffc0201742:	00154783          	lbu	a5,1(a0)
ffffffffc0201746:	0505                	addi	a0,a0,1
ffffffffc0201748:	fbfd                	bnez	a5,ffffffffc020173e <strchr+0x6>
ffffffffc020174a:	4501                	li	a0,0
ffffffffc020174c:	8082                	ret

ffffffffc020174e <memset>:
ffffffffc020174e:	ca01                	beqz	a2,ffffffffc020175e <memset+0x10>
ffffffffc0201750:	962a                	add	a2,a2,a0
ffffffffc0201752:	87aa                	mv	a5,a0
ffffffffc0201754:	0785                	addi	a5,a5,1
ffffffffc0201756:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020175a:	fec79de3          	bne	a5,a2,ffffffffc0201754 <memset+0x6>
ffffffffc020175e:	8082                	ret
