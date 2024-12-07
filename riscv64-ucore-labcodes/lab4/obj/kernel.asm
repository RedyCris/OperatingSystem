
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
ffffffffc020001c:	18029073          	csrw	satp,t0
ffffffffc0200020:	12000073          	sfence.vma
ffffffffc0200024:	c0209137          	lui	sp,0xc0209
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02650513          	addi	a0,a0,38 # ffffffffc020a058 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	58a60613          	addi	a2,a2,1418 # ffffffffc02155c4 <end>
ffffffffc0200042:	1141                	addi	sp,sp,-16
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
ffffffffc0200048:	e406                	sd	ra,8(sp)
ffffffffc020004a:	1c7040ef          	jal	ra,ffffffffc0204a10 <memset>
ffffffffc020004e:	4a6000ef          	jal	ra,ffffffffc02004f4 <cons_init>
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	a0e58593          	addi	a1,a1,-1522 # ffffffffc0204a60 <etext+0x2>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	a2650513          	addi	a0,a0,-1498 # ffffffffc0204a80 <etext+0x22>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200066:	162000ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
ffffffffc020006a:	663010ef          	jal	ra,ffffffffc0201ecc <pmm_init>
ffffffffc020006e:	536000ef          	jal	ra,ffffffffc02005a4 <pic_init>
ffffffffc0200072:	5a4000ef          	jal	ra,ffffffffc0200616 <idt_init>
ffffffffc0200076:	0f7030ef          	jal	ra,ffffffffc020396c <vmm_init>
ffffffffc020007a:	152040ef          	jal	ra,ffffffffc02041cc <proc_init>
ffffffffc020007e:	4e8000ef          	jal	ra,ffffffffc0200566 <ide_init>
ffffffffc0200082:	2bf020ef          	jal	ra,ffffffffc0202b40 <swap_init>
ffffffffc0200086:	41c000ef          	jal	ra,ffffffffc02004a2 <clock_init>
ffffffffc020008a:	50e000ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc020008e:	3e8040ef          	jal	ra,ffffffffc0204476 <cpu_idle>

ffffffffc0200092 <readline>:
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
ffffffffc02000a8:	00005517          	auipc	a0,0x5
ffffffffc02000ac:	9e050513          	addi	a0,a0,-1568 # ffffffffc0204a88 <etext+0x2a>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02000b4:	4481                	li	s1,0
ffffffffc02000b6:	497d                	li	s2,31
ffffffffc02000b8:	49a1                	li	s3,8
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
ffffffffc02000be:	0000ab97          	auipc	s7,0xa
ffffffffc02000c2:	f9ab8b93          	addi	s7,s7,-102 # ffffffffc020a058 <buf>
ffffffffc02000c6:	3fe00a13          	li	s4,1022
ffffffffc02000ca:	0ee000ef          	jal	ra,ffffffffc02001b8 <getchar>
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
ffffffffc02000da:	0de000ef          	jal	ra,ffffffffc02001b8 <getchar>
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
ffffffffc02000ec:	0cc000ef          	jal	ra,ffffffffc02001b8 <getchar>
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
ffffffffc020011a:	0000a517          	auipc	a0,0xa
ffffffffc020011e:	f3e50513          	addi	a0,a0,-194 # ffffffffc020a058 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
ffffffffc0200128:	60a6                	ld	ra,72(sp)
ffffffffc020012a:	6486                	ld	s1,64(sp)
ffffffffc020012c:	7962                	ld	s2,56(sp)
ffffffffc020012e:	79c2                	ld	s3,48(sp)
ffffffffc0200130:	7a22                	ld	s4,40(sp)
ffffffffc0200132:	7a82                	ld	s5,32(sp)
ffffffffc0200134:	6b62                	ld	s6,24(sp)
ffffffffc0200136:	6bc2                	ld	s7,16(sp)
ffffffffc0200138:	6161                	addi	sp,sp,80
ffffffffc020013a:	8082                	ret
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
ffffffffc020014e:	3a8000ef          	jal	ra,ffffffffc02004f6 <cons_putc>
ffffffffc0200152:	401c                	lw	a5,0(s0)
ffffffffc0200154:	60a2                	ld	ra,8(sp)
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
ffffffffc0200170:	ec06                	sd	ra,24(sp)
ffffffffc0200172:	c602                	sw	zero,12(sp)
ffffffffc0200174:	49e040ef          	jal	ra,ffffffffc0204612 <vprintfmt>
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
ffffffffc0200180:	711d                	addi	sp,sp,-96
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
ffffffffc02001a8:	c202                	sw	zero,4(sp)
ffffffffc02001aa:	468040ef          	jal	ra,ffffffffc0204612 <vprintfmt>
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:
ffffffffc02001b6:	a681                	j	ffffffffc02004f6 <cons_putc>

ffffffffc02001b8 <getchar>:
ffffffffc02001b8:	1141                	addi	sp,sp,-16
ffffffffc02001ba:	e406                	sd	ra,8(sp)
ffffffffc02001bc:	36e000ef          	jal	ra,ffffffffc020052a <cons_getc>
ffffffffc02001c0:	dd75                	beqz	a0,ffffffffc02001bc <getchar+0x4>
ffffffffc02001c2:	60a2                	ld	ra,8(sp)
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <print_kerninfo>:
ffffffffc02001c8:	1141                	addi	sp,sp,-16
ffffffffc02001ca:	00005517          	auipc	a0,0x5
ffffffffc02001ce:	8c650513          	addi	a0,a0,-1850 # ffffffffc0204a90 <etext+0x32>
ffffffffc02001d2:	e406                	sd	ra,8(sp)
ffffffffc02001d4:	fadff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02001d8:	00000597          	auipc	a1,0x0
ffffffffc02001dc:	e5a58593          	addi	a1,a1,-422 # ffffffffc0200032 <kern_init>
ffffffffc02001e0:	00005517          	auipc	a0,0x5
ffffffffc02001e4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0204ab0 <etext+0x52>
ffffffffc02001e8:	f99ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02001ec:	00005597          	auipc	a1,0x5
ffffffffc02001f0:	87258593          	addi	a1,a1,-1934 # ffffffffc0204a5e <etext>
ffffffffc02001f4:	00005517          	auipc	a0,0x5
ffffffffc02001f8:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0204ad0 <etext+0x72>
ffffffffc02001fc:	f85ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200200:	0000a597          	auipc	a1,0xa
ffffffffc0200204:	e5858593          	addi	a1,a1,-424 # ffffffffc020a058 <buf>
ffffffffc0200208:	00005517          	auipc	a0,0x5
ffffffffc020020c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0204af0 <etext+0x92>
ffffffffc0200210:	f71ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200214:	00015597          	auipc	a1,0x15
ffffffffc0200218:	3b058593          	addi	a1,a1,944 # ffffffffc02155c4 <end>
ffffffffc020021c:	00005517          	auipc	a0,0x5
ffffffffc0200220:	8f450513          	addi	a0,a0,-1804 # ffffffffc0204b10 <etext+0xb2>
ffffffffc0200224:	f5dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200228:	00015597          	auipc	a1,0x15
ffffffffc020022c:	79b58593          	addi	a1,a1,1947 # ffffffffc02159c3 <end+0x3ff>
ffffffffc0200230:	00000797          	auipc	a5,0x0
ffffffffc0200234:	e0278793          	addi	a5,a5,-510 # ffffffffc0200032 <kern_init>
ffffffffc0200238:	40f587b3          	sub	a5,a1,a5
ffffffffc020023c:	43f7d593          	srai	a1,a5,0x3f
ffffffffc0200240:	60a2                	ld	ra,8(sp)
ffffffffc0200242:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200246:	95be                	add	a1,a1,a5
ffffffffc0200248:	85a9                	srai	a1,a1,0xa
ffffffffc020024a:	00005517          	auipc	a0,0x5
ffffffffc020024e:	8e650513          	addi	a0,a0,-1818 # ffffffffc0204b30 <etext+0xd2>
ffffffffc0200252:	0141                	addi	sp,sp,16
ffffffffc0200254:	b735                	j	ffffffffc0200180 <cprintf>

ffffffffc0200256 <print_stackframe>:
ffffffffc0200256:	1141                	addi	sp,sp,-16
ffffffffc0200258:	00005617          	auipc	a2,0x5
ffffffffc020025c:	90860613          	addi	a2,a2,-1784 # ffffffffc0204b60 <etext+0x102>
ffffffffc0200260:	04d00593          	li	a1,77
ffffffffc0200264:	00005517          	auipc	a0,0x5
ffffffffc0200268:	91450513          	addi	a0,a0,-1772 # ffffffffc0204b78 <etext+0x11a>
ffffffffc020026c:	e406                	sd	ra,8(sp)
ffffffffc020026e:	1d8000ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200272 <mon_help>:
ffffffffc0200272:	1141                	addi	sp,sp,-16
ffffffffc0200274:	00005617          	auipc	a2,0x5
ffffffffc0200278:	91c60613          	addi	a2,a2,-1764 # ffffffffc0204b90 <etext+0x132>
ffffffffc020027c:	00005597          	auipc	a1,0x5
ffffffffc0200280:	93458593          	addi	a1,a1,-1740 # ffffffffc0204bb0 <etext+0x152>
ffffffffc0200284:	00005517          	auipc	a0,0x5
ffffffffc0200288:	93450513          	addi	a0,a0,-1740 # ffffffffc0204bb8 <etext+0x15a>
ffffffffc020028c:	e406                	sd	ra,8(sp)
ffffffffc020028e:	ef3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200292:	00005617          	auipc	a2,0x5
ffffffffc0200296:	93660613          	addi	a2,a2,-1738 # ffffffffc0204bc8 <etext+0x16a>
ffffffffc020029a:	00005597          	auipc	a1,0x5
ffffffffc020029e:	95658593          	addi	a1,a1,-1706 # ffffffffc0204bf0 <etext+0x192>
ffffffffc02002a2:	00005517          	auipc	a0,0x5
ffffffffc02002a6:	91650513          	addi	a0,a0,-1770 # ffffffffc0204bb8 <etext+0x15a>
ffffffffc02002aa:	ed7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ae:	00005617          	auipc	a2,0x5
ffffffffc02002b2:	95260613          	addi	a2,a2,-1710 # ffffffffc0204c00 <etext+0x1a2>
ffffffffc02002b6:	00005597          	auipc	a1,0x5
ffffffffc02002ba:	96a58593          	addi	a1,a1,-1686 # ffffffffc0204c20 <etext+0x1c2>
ffffffffc02002be:	00005517          	auipc	a0,0x5
ffffffffc02002c2:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0204bb8 <etext+0x15a>
ffffffffc02002c6:	ebbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ca:	60a2                	ld	ra,8(sp)
ffffffffc02002cc:	4501                	li	a0,0
ffffffffc02002ce:	0141                	addi	sp,sp,16
ffffffffc02002d0:	8082                	ret

ffffffffc02002d2 <mon_kerninfo>:
ffffffffc02002d2:	1141                	addi	sp,sp,-16
ffffffffc02002d4:	e406                	sd	ra,8(sp)
ffffffffc02002d6:	ef3ff0ef          	jal	ra,ffffffffc02001c8 <print_kerninfo>
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_backtrace>:
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
ffffffffc02002e6:	f71ff0ef          	jal	ra,ffffffffc0200256 <print_stackframe>
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <kmonitor>:
ffffffffc02002f2:	7115                	addi	sp,sp,-224
ffffffffc02002f4:	ed5e                	sd	s7,152(sp)
ffffffffc02002f6:	8baa                	mv	s7,a0
ffffffffc02002f8:	00005517          	auipc	a0,0x5
ffffffffc02002fc:	93850513          	addi	a0,a0,-1736 # ffffffffc0204c30 <etext+0x1d2>
ffffffffc0200300:	ed86                	sd	ra,216(sp)
ffffffffc0200302:	e9a2                	sd	s0,208(sp)
ffffffffc0200304:	e5a6                	sd	s1,200(sp)
ffffffffc0200306:	e1ca                	sd	s2,192(sp)
ffffffffc0200308:	fd4e                	sd	s3,184(sp)
ffffffffc020030a:	f952                	sd	s4,176(sp)
ffffffffc020030c:	f556                	sd	s5,168(sp)
ffffffffc020030e:	f15a                	sd	s6,160(sp)
ffffffffc0200310:	e962                	sd	s8,144(sp)
ffffffffc0200312:	e566                	sd	s9,136(sp)
ffffffffc0200314:	e16a                	sd	s10,128(sp)
ffffffffc0200316:	e6bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020031a:	00005517          	auipc	a0,0x5
ffffffffc020031e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0204c58 <etext+0x1fa>
ffffffffc0200322:	e5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200326:	000b8563          	beqz	s7,ffffffffc0200330 <kmonitor+0x3e>
ffffffffc020032a:	855e                	mv	a0,s7
ffffffffc020032c:	4d0000ef          	jal	ra,ffffffffc02007fc <print_trapframe>
ffffffffc0200330:	4501                	li	a0,0
ffffffffc0200332:	4581                	li	a1,0
ffffffffc0200334:	4601                	li	a2,0
ffffffffc0200336:	48a1                	li	a7,8
ffffffffc0200338:	00000073          	ecall
ffffffffc020033c:	00005c17          	auipc	s8,0x5
ffffffffc0200340:	98cc0c13          	addi	s8,s8,-1652 # ffffffffc0204cc8 <commands>
ffffffffc0200344:	00005917          	auipc	s2,0x5
ffffffffc0200348:	93c90913          	addi	s2,s2,-1732 # ffffffffc0204c80 <etext+0x222>
ffffffffc020034c:	00005497          	auipc	s1,0x5
ffffffffc0200350:	93c48493          	addi	s1,s1,-1732 # ffffffffc0204c88 <etext+0x22a>
ffffffffc0200354:	49bd                	li	s3,15
ffffffffc0200356:	00005b17          	auipc	s6,0x5
ffffffffc020035a:	93ab0b13          	addi	s6,s6,-1734 # ffffffffc0204c90 <etext+0x232>
ffffffffc020035e:	00005a17          	auipc	s4,0x5
ffffffffc0200362:	852a0a13          	addi	s4,s4,-1966 # ffffffffc0204bb0 <etext+0x152>
ffffffffc0200366:	4a8d                	li	s5,3
ffffffffc0200368:	854a                	mv	a0,s2
ffffffffc020036a:	d29ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc020036e:	842a                	mv	s0,a0
ffffffffc0200370:	dd65                	beqz	a0,ffffffffc0200368 <kmonitor+0x76>
ffffffffc0200372:	00054583          	lbu	a1,0(a0)
ffffffffc0200376:	4c81                	li	s9,0
ffffffffc0200378:	e1bd                	bnez	a1,ffffffffc02003de <kmonitor+0xec>
ffffffffc020037a:	fe0c87e3          	beqz	s9,ffffffffc0200368 <kmonitor+0x76>
ffffffffc020037e:	6582                	ld	a1,0(sp)
ffffffffc0200380:	00005d17          	auipc	s10,0x5
ffffffffc0200384:	948d0d13          	addi	s10,s10,-1720 # ffffffffc0204cc8 <commands>
ffffffffc0200388:	8552                	mv	a0,s4
ffffffffc020038a:	4401                	li	s0,0
ffffffffc020038c:	0d61                	addi	s10,s10,24
ffffffffc020038e:	64e040ef          	jal	ra,ffffffffc02049dc <strcmp>
ffffffffc0200392:	c919                	beqz	a0,ffffffffc02003a8 <kmonitor+0xb6>
ffffffffc0200394:	2405                	addiw	s0,s0,1
ffffffffc0200396:	0b540063          	beq	s0,s5,ffffffffc0200436 <kmonitor+0x144>
ffffffffc020039a:	000d3503          	ld	a0,0(s10)
ffffffffc020039e:	6582                	ld	a1,0(sp)
ffffffffc02003a0:	0d61                	addi	s10,s10,24
ffffffffc02003a2:	63a040ef          	jal	ra,ffffffffc02049dc <strcmp>
ffffffffc02003a6:	f57d                	bnez	a0,ffffffffc0200394 <kmonitor+0xa2>
ffffffffc02003a8:	00141793          	slli	a5,s0,0x1
ffffffffc02003ac:	97a2                	add	a5,a5,s0
ffffffffc02003ae:	078e                	slli	a5,a5,0x3
ffffffffc02003b0:	97e2                	add	a5,a5,s8
ffffffffc02003b2:	6b9c                	ld	a5,16(a5)
ffffffffc02003b4:	865e                	mv	a2,s7
ffffffffc02003b6:	002c                	addi	a1,sp,8
ffffffffc02003b8:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003bc:	9782                	jalr	a5
ffffffffc02003be:	fa0555e3          	bgez	a0,ffffffffc0200368 <kmonitor+0x76>
ffffffffc02003c2:	60ee                	ld	ra,216(sp)
ffffffffc02003c4:	644e                	ld	s0,208(sp)
ffffffffc02003c6:	64ae                	ld	s1,200(sp)
ffffffffc02003c8:	690e                	ld	s2,192(sp)
ffffffffc02003ca:	79ea                	ld	s3,184(sp)
ffffffffc02003cc:	7a4a                	ld	s4,176(sp)
ffffffffc02003ce:	7aaa                	ld	s5,168(sp)
ffffffffc02003d0:	7b0a                	ld	s6,160(sp)
ffffffffc02003d2:	6bea                	ld	s7,152(sp)
ffffffffc02003d4:	6c4a                	ld	s8,144(sp)
ffffffffc02003d6:	6caa                	ld	s9,136(sp)
ffffffffc02003d8:	6d0a                	ld	s10,128(sp)
ffffffffc02003da:	612d                	addi	sp,sp,224
ffffffffc02003dc:	8082                	ret
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	61a040ef          	jal	ra,ffffffffc02049fa <strchr>
ffffffffc02003e4:	c901                	beqz	a0,ffffffffc02003f4 <kmonitor+0x102>
ffffffffc02003e6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ea:	00040023          	sb	zero,0(s0)
ffffffffc02003ee:	0405                	addi	s0,s0,1
ffffffffc02003f0:	d5c9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003f2:	b7f5                	j	ffffffffc02003de <kmonitor+0xec>
ffffffffc02003f4:	00044783          	lbu	a5,0(s0)
ffffffffc02003f8:	d3c9                	beqz	a5,ffffffffc020037a <kmonitor+0x88>
ffffffffc02003fa:	033c8963          	beq	s9,s3,ffffffffc020042c <kmonitor+0x13a>
ffffffffc02003fe:	003c9793          	slli	a5,s9,0x3
ffffffffc0200402:	0118                	addi	a4,sp,128
ffffffffc0200404:	97ba                	add	a5,a5,a4
ffffffffc0200406:	f887b023          	sd	s0,-128(a5)
ffffffffc020040a:	00044583          	lbu	a1,0(s0)
ffffffffc020040e:	2c85                	addiw	s9,s9,1
ffffffffc0200410:	e591                	bnez	a1,ffffffffc020041c <kmonitor+0x12a>
ffffffffc0200412:	b7b5                	j	ffffffffc020037e <kmonitor+0x8c>
ffffffffc0200414:	00144583          	lbu	a1,1(s0)
ffffffffc0200418:	0405                	addi	s0,s0,1
ffffffffc020041a:	d1a5                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020041c:	8526                	mv	a0,s1
ffffffffc020041e:	5dc040ef          	jal	ra,ffffffffc02049fa <strchr>
ffffffffc0200422:	d96d                	beqz	a0,ffffffffc0200414 <kmonitor+0x122>
ffffffffc0200424:	00044583          	lbu	a1,0(s0)
ffffffffc0200428:	d9a9                	beqz	a1,ffffffffc020037a <kmonitor+0x88>
ffffffffc020042a:	bf55                	j	ffffffffc02003de <kmonitor+0xec>
ffffffffc020042c:	45c1                	li	a1,16
ffffffffc020042e:	855a                	mv	a0,s6
ffffffffc0200430:	d51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200434:	b7e9                	j	ffffffffc02003fe <kmonitor+0x10c>
ffffffffc0200436:	6582                	ld	a1,0(sp)
ffffffffc0200438:	00005517          	auipc	a0,0x5
ffffffffc020043c:	87850513          	addi	a0,a0,-1928 # ffffffffc0204cb0 <etext+0x252>
ffffffffc0200440:	d41ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200444:	b715                	j	ffffffffc0200368 <kmonitor+0x76>

ffffffffc0200446 <__panic>:
ffffffffc0200446:	00015317          	auipc	t1,0x15
ffffffffc020044a:	0ea30313          	addi	t1,t1,234 # ffffffffc0215530 <is_panic>
ffffffffc020044e:	00032e03          	lw	t3,0(t1)
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	e822                	sd	s0,16(sp)
ffffffffc0200458:	f436                	sd	a3,40(sp)
ffffffffc020045a:	f83a                	sd	a4,48(sp)
ffffffffc020045c:	fc3e                	sd	a5,56(sp)
ffffffffc020045e:	e0c2                	sd	a6,64(sp)
ffffffffc0200460:	e4c6                	sd	a7,72(sp)
ffffffffc0200462:	020e1a63          	bnez	t3,ffffffffc0200496 <__panic+0x50>
ffffffffc0200466:	4785                	li	a5,1
ffffffffc0200468:	00f32023          	sw	a5,0(t1)
ffffffffc020046c:	8432                	mv	s0,a2
ffffffffc020046e:	103c                	addi	a5,sp,40
ffffffffc0200470:	862e                	mv	a2,a1
ffffffffc0200472:	85aa                	mv	a1,a0
ffffffffc0200474:	00005517          	auipc	a0,0x5
ffffffffc0200478:	89c50513          	addi	a0,a0,-1892 # ffffffffc0204d10 <commands+0x48>
ffffffffc020047c:	e43e                	sd	a5,8(sp)
ffffffffc020047e:	d03ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cdbff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
ffffffffc020048a:	00005517          	auipc	a0,0x5
ffffffffc020048e:	7f650513          	addi	a0,a0,2038 # ffffffffc0205c80 <default_pmm_manager+0x4d0>
ffffffffc0200492:	cefff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200496:	108000ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020049a:	4501                	li	a0,0
ffffffffc020049c:	e57ff0ef          	jal	ra,ffffffffc02002f2 <kmonitor>
ffffffffc02004a0:	bfed                	j	ffffffffc020049a <__panic+0x54>

ffffffffc02004a2 <clock_init>:
ffffffffc02004a2:	67e1                	lui	a5,0x18
ffffffffc02004a4:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004a8:	00015717          	auipc	a4,0x15
ffffffffc02004ac:	08f73c23          	sd	a5,152(a4) # ffffffffc0215540 <timebase>
ffffffffc02004b0:	c0102573          	rdtime	a0
ffffffffc02004b4:	4581                	li	a1,0
ffffffffc02004b6:	953e                	add	a0,a0,a5
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4881                	li	a7,0
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	02000793          	li	a5,32
ffffffffc02004c4:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc02004c8:	00005517          	auipc	a0,0x5
ffffffffc02004cc:	86850513          	addi	a0,a0,-1944 # ffffffffc0204d30 <commands+0x68>
ffffffffc02004d0:	00015797          	auipc	a5,0x15
ffffffffc02004d4:	0607b423          	sd	zero,104(a5) # ffffffffc0215538 <ticks>
ffffffffc02004d8:	b165                	j	ffffffffc0200180 <cprintf>

ffffffffc02004da <clock_set_next_event>:
ffffffffc02004da:	c0102573          	rdtime	a0
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	0627b783          	ld	a5,98(a5) # ffffffffc0215540 <timebase>
ffffffffc02004e6:	953e                	add	a0,a0,a5
ffffffffc02004e8:	4581                	li	a1,0
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <cons_init>:
ffffffffc02004f4:	8082                	ret

ffffffffc02004f6 <cons_putc>:
ffffffffc02004f6:	100027f3          	csrr	a5,sstatus
ffffffffc02004fa:	8b89                	andi	a5,a5,2
ffffffffc02004fc:	0ff57513          	zext.b	a0,a0
ffffffffc0200500:	e799                	bnez	a5,ffffffffc020050e <cons_putc+0x18>
ffffffffc0200502:	4581                	li	a1,0
ffffffffc0200504:	4601                	li	a2,0
ffffffffc0200506:	4885                	li	a7,1
ffffffffc0200508:	00000073          	ecall
ffffffffc020050c:	8082                	ret
ffffffffc020050e:	1101                	addi	sp,sp,-32
ffffffffc0200510:	ec06                	sd	ra,24(sp)
ffffffffc0200512:	e42a                	sd	a0,8(sp)
ffffffffc0200514:	08a000ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0200518:	6522                	ld	a0,8(sp)
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4885                	li	a7,1
ffffffffc0200520:	00000073          	ecall
ffffffffc0200524:	60e2                	ld	ra,24(sp)
ffffffffc0200526:	6105                	addi	sp,sp,32
ffffffffc0200528:	a885                	j	ffffffffc0200598 <intr_enable>

ffffffffc020052a <cons_getc>:
ffffffffc020052a:	100027f3          	csrr	a5,sstatus
ffffffffc020052e:	8b89                	andi	a5,a5,2
ffffffffc0200530:	eb89                	bnez	a5,ffffffffc0200542 <cons_getc+0x18>
ffffffffc0200532:	4501                	li	a0,0
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4889                	li	a7,2
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	2501                	sext.w	a0,a0
ffffffffc0200540:	8082                	ret
ffffffffc0200542:	1101                	addi	sp,sp,-32
ffffffffc0200544:	ec06                	sd	ra,24(sp)
ffffffffc0200546:	058000ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020054a:	4501                	li	a0,0
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4889                	li	a7,2
ffffffffc0200552:	00000073          	ecall
ffffffffc0200556:	2501                	sext.w	a0,a0
ffffffffc0200558:	e42a                	sd	a0,8(sp)
ffffffffc020055a:	03e000ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc020055e:	60e2                	ld	ra,24(sp)
ffffffffc0200560:	6522                	ld	a0,8(sp)
ffffffffc0200562:	6105                	addi	sp,sp,32
ffffffffc0200564:	8082                	ret

ffffffffc0200566 <ide_init>:
ffffffffc0200566:	8082                	ret

ffffffffc0200568 <ide_device_valid>:
ffffffffc0200568:	00253513          	sltiu	a0,a0,2
ffffffffc020056c:	8082                	ret

ffffffffc020056e <ide_device_size>:
ffffffffc020056e:	03800513          	li	a0,56
ffffffffc0200572:	8082                	ret

ffffffffc0200574 <ide_write_secs>:
ffffffffc0200574:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200578:	0000a517          	auipc	a0,0xa
ffffffffc020057c:	ee050513          	addi	a0,a0,-288 # ffffffffc020a458 <ide>
ffffffffc0200580:	1141                	addi	sp,sp,-16
ffffffffc0200582:	85b2                	mv	a1,a2
ffffffffc0200584:	953e                	add	a0,a0,a5
ffffffffc0200586:	00969613          	slli	a2,a3,0x9
ffffffffc020058a:	e406                	sd	ra,8(sp)
ffffffffc020058c:	496040ef          	jal	ra,ffffffffc0204a22 <memcpy>
ffffffffc0200590:	60a2                	ld	ra,8(sp)
ffffffffc0200592:	4501                	li	a0,0
ffffffffc0200594:	0141                	addi	sp,sp,16
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <intr_enable>:
ffffffffc0200598:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020059c:	8082                	ret

ffffffffc020059e <intr_disable>:
ffffffffc020059e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005a2:	8082                	ret

ffffffffc02005a4 <pic_init>:
ffffffffc02005a4:	8082                	ret

ffffffffc02005a6 <pgfault_handler>:
ffffffffc02005a6:	10053783          	ld	a5,256(a0)
ffffffffc02005aa:	1141                	addi	sp,sp,-16
ffffffffc02005ac:	e022                	sd	s0,0(sp)
ffffffffc02005ae:	e406                	sd	ra,8(sp)
ffffffffc02005b0:	1007f793          	andi	a5,a5,256
ffffffffc02005b4:	11053583          	ld	a1,272(a0)
ffffffffc02005b8:	842a                	mv	s0,a0
ffffffffc02005ba:	05500613          	li	a2,85
ffffffffc02005be:	c399                	beqz	a5,ffffffffc02005c4 <pgfault_handler+0x1e>
ffffffffc02005c0:	04b00613          	li	a2,75
ffffffffc02005c4:	11843703          	ld	a4,280(s0)
ffffffffc02005c8:	47bd                	li	a5,15
ffffffffc02005ca:	05700693          	li	a3,87
ffffffffc02005ce:	00f70463          	beq	a4,a5,ffffffffc02005d6 <pgfault_handler+0x30>
ffffffffc02005d2:	05200693          	li	a3,82
ffffffffc02005d6:	00004517          	auipc	a0,0x4
ffffffffc02005da:	77a50513          	addi	a0,a0,1914 # ffffffffc0204d50 <commands+0x88>
ffffffffc02005de:	ba3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02005e2:	00015517          	auipc	a0,0x15
ffffffffc02005e6:	fb653503          	ld	a0,-74(a0) # ffffffffc0215598 <check_mm_struct>
ffffffffc02005ea:	c911                	beqz	a0,ffffffffc02005fe <pgfault_handler+0x58>
ffffffffc02005ec:	11043603          	ld	a2,272(s0)
ffffffffc02005f0:	11842583          	lw	a1,280(s0)
ffffffffc02005f4:	6402                	ld	s0,0(sp)
ffffffffc02005f6:	60a2                	ld	ra,8(sp)
ffffffffc02005f8:	0141                	addi	sp,sp,16
ffffffffc02005fa:	1470306f          	j	ffffffffc0203f40 <do_pgfault>
ffffffffc02005fe:	00004617          	auipc	a2,0x4
ffffffffc0200602:	77260613          	addi	a2,a2,1906 # ffffffffc0204d70 <commands+0xa8>
ffffffffc0200606:	06200593          	li	a1,98
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	77e50513          	addi	a0,a0,1918 # ffffffffc0204d88 <commands+0xc0>
ffffffffc0200612:	e35ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200616 <idt_init>:
ffffffffc0200616:	14005073          	csrwi	sscratch,0
ffffffffc020061a:	00000797          	auipc	a5,0x0
ffffffffc020061e:	47a78793          	addi	a5,a5,1146 # ffffffffc0200a94 <__alltraps>
ffffffffc0200622:	10579073          	csrw	stvec,a5
ffffffffc0200626:	000407b7          	lui	a5,0x40
ffffffffc020062a:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc020062e:	8082                	ret

ffffffffc0200630 <print_regs>:
ffffffffc0200630:	610c                	ld	a1,0(a0)
ffffffffc0200632:	1141                	addi	sp,sp,-16
ffffffffc0200634:	e022                	sd	s0,0(sp)
ffffffffc0200636:	842a                	mv	s0,a0
ffffffffc0200638:	00004517          	auipc	a0,0x4
ffffffffc020063c:	76850513          	addi	a0,a0,1896 # ffffffffc0204da0 <commands+0xd8>
ffffffffc0200640:	e406                	sd	ra,8(sp)
ffffffffc0200642:	b3fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200646:	640c                	ld	a1,8(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	77050513          	addi	a0,a0,1904 # ffffffffc0204db8 <commands+0xf0>
ffffffffc0200650:	b31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200654:	680c                	ld	a1,16(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	77a50513          	addi	a0,a0,1914 # ffffffffc0204dd0 <commands+0x108>
ffffffffc020065e:	b23ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200662:	6c0c                	ld	a1,24(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	78450513          	addi	a0,a0,1924 # ffffffffc0204de8 <commands+0x120>
ffffffffc020066c:	b15ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200670:	700c                	ld	a1,32(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	78e50513          	addi	a0,a0,1934 # ffffffffc0204e00 <commands+0x138>
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020067e:	740c                	ld	a1,40(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	79850513          	addi	a0,a0,1944 # ffffffffc0204e18 <commands+0x150>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020068c:	780c                	ld	a1,48(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	7a250513          	addi	a0,a0,1954 # ffffffffc0204e30 <commands+0x168>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020069a:	7c0c                	ld	a1,56(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	7ac50513          	addi	a0,a0,1964 # ffffffffc0204e48 <commands+0x180>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006a8:	602c                	ld	a1,64(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	7b650513          	addi	a0,a0,1974 # ffffffffc0204e60 <commands+0x198>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006b6:	642c                	ld	a1,72(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	7c050513          	addi	a0,a0,1984 # ffffffffc0204e78 <commands+0x1b0>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006c4:	682c                	ld	a1,80(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	7ca50513          	addi	a0,a0,1994 # ffffffffc0204e90 <commands+0x1c8>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006d2:	6c2c                	ld	a1,88(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	7d450513          	addi	a0,a0,2004 # ffffffffc0204ea8 <commands+0x1e0>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006e0:	702c                	ld	a1,96(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	7de50513          	addi	a0,a0,2014 # ffffffffc0204ec0 <commands+0x1f8>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006ee:	742c                	ld	a1,104(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	7e850513          	addi	a0,a0,2024 # ffffffffc0204ed8 <commands+0x210>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02006fc:	782c                	ld	a1,112(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	7f250513          	addi	a0,a0,2034 # ffffffffc0204ef0 <commands+0x228>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020070a:	7c2c                	ld	a1,120(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	7fc50513          	addi	a0,a0,2044 # ffffffffc0204f08 <commands+0x240>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200718:	604c                	ld	a1,128(s0)
ffffffffc020071a:	00005517          	auipc	a0,0x5
ffffffffc020071e:	80650513          	addi	a0,a0,-2042 # ffffffffc0204f20 <commands+0x258>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200726:	644c                	ld	a1,136(s0)
ffffffffc0200728:	00005517          	auipc	a0,0x5
ffffffffc020072c:	81050513          	addi	a0,a0,-2032 # ffffffffc0204f38 <commands+0x270>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200734:	684c                	ld	a1,144(s0)
ffffffffc0200736:	00005517          	auipc	a0,0x5
ffffffffc020073a:	81a50513          	addi	a0,a0,-2022 # ffffffffc0204f50 <commands+0x288>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200742:	6c4c                	ld	a1,152(s0)
ffffffffc0200744:	00005517          	auipc	a0,0x5
ffffffffc0200748:	82450513          	addi	a0,a0,-2012 # ffffffffc0204f68 <commands+0x2a0>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200750:	704c                	ld	a1,160(s0)
ffffffffc0200752:	00005517          	auipc	a0,0x5
ffffffffc0200756:	82e50513          	addi	a0,a0,-2002 # ffffffffc0204f80 <commands+0x2b8>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020075e:	744c                	ld	a1,168(s0)
ffffffffc0200760:	00005517          	auipc	a0,0x5
ffffffffc0200764:	83850513          	addi	a0,a0,-1992 # ffffffffc0204f98 <commands+0x2d0>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020076c:	784c                	ld	a1,176(s0)
ffffffffc020076e:	00005517          	auipc	a0,0x5
ffffffffc0200772:	84250513          	addi	a0,a0,-1982 # ffffffffc0204fb0 <commands+0x2e8>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020077a:	7c4c                	ld	a1,184(s0)
ffffffffc020077c:	00005517          	auipc	a0,0x5
ffffffffc0200780:	84c50513          	addi	a0,a0,-1972 # ffffffffc0204fc8 <commands+0x300>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200788:	606c                	ld	a1,192(s0)
ffffffffc020078a:	00005517          	auipc	a0,0x5
ffffffffc020078e:	85650513          	addi	a0,a0,-1962 # ffffffffc0204fe0 <commands+0x318>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200796:	646c                	ld	a1,200(s0)
ffffffffc0200798:	00005517          	auipc	a0,0x5
ffffffffc020079c:	86050513          	addi	a0,a0,-1952 # ffffffffc0204ff8 <commands+0x330>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02007a4:	686c                	ld	a1,208(s0)
ffffffffc02007a6:	00005517          	auipc	a0,0x5
ffffffffc02007aa:	86a50513          	addi	a0,a0,-1942 # ffffffffc0205010 <commands+0x348>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02007b2:	6c6c                	ld	a1,216(s0)
ffffffffc02007b4:	00005517          	auipc	a0,0x5
ffffffffc02007b8:	87450513          	addi	a0,a0,-1932 # ffffffffc0205028 <commands+0x360>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02007c0:	706c                	ld	a1,224(s0)
ffffffffc02007c2:	00005517          	auipc	a0,0x5
ffffffffc02007c6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0205040 <commands+0x378>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02007ce:	746c                	ld	a1,232(s0)
ffffffffc02007d0:	00005517          	auipc	a0,0x5
ffffffffc02007d4:	88850513          	addi	a0,a0,-1912 # ffffffffc0205058 <commands+0x390>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02007dc:	786c                	ld	a1,240(s0)
ffffffffc02007de:	00005517          	auipc	a0,0x5
ffffffffc02007e2:	89250513          	addi	a0,a0,-1902 # ffffffffc0205070 <commands+0x3a8>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02007ea:	7c6c                	ld	a1,248(s0)
ffffffffc02007ec:	6402                	ld	s0,0(sp)
ffffffffc02007ee:	60a2                	ld	ra,8(sp)
ffffffffc02007f0:	00005517          	auipc	a0,0x5
ffffffffc02007f4:	89850513          	addi	a0,a0,-1896 # ffffffffc0205088 <commands+0x3c0>
ffffffffc02007f8:	0141                	addi	sp,sp,16
ffffffffc02007fa:	b259                	j	ffffffffc0200180 <cprintf>

ffffffffc02007fc <print_trapframe>:
ffffffffc02007fc:	1141                	addi	sp,sp,-16
ffffffffc02007fe:	e022                	sd	s0,0(sp)
ffffffffc0200800:	85aa                	mv	a1,a0
ffffffffc0200802:	842a                	mv	s0,a0
ffffffffc0200804:	00005517          	auipc	a0,0x5
ffffffffc0200808:	89c50513          	addi	a0,a0,-1892 # ffffffffc02050a0 <commands+0x3d8>
ffffffffc020080c:	e406                	sd	ra,8(sp)
ffffffffc020080e:	973ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200812:	8522                	mv	a0,s0
ffffffffc0200814:	e1dff0ef          	jal	ra,ffffffffc0200630 <print_regs>
ffffffffc0200818:	10043583          	ld	a1,256(s0)
ffffffffc020081c:	00005517          	auipc	a0,0x5
ffffffffc0200820:	89c50513          	addi	a0,a0,-1892 # ffffffffc02050b8 <commands+0x3f0>
ffffffffc0200824:	95dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200828:	10843583          	ld	a1,264(s0)
ffffffffc020082c:	00005517          	auipc	a0,0x5
ffffffffc0200830:	8a450513          	addi	a0,a0,-1884 # ffffffffc02050d0 <commands+0x408>
ffffffffc0200834:	94dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200838:	11043583          	ld	a1,272(s0)
ffffffffc020083c:	00005517          	auipc	a0,0x5
ffffffffc0200840:	8ac50513          	addi	a0,a0,-1876 # ffffffffc02050e8 <commands+0x420>
ffffffffc0200844:	93dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200848:	11843583          	ld	a1,280(s0)
ffffffffc020084c:	6402                	ld	s0,0(sp)
ffffffffc020084e:	60a2                	ld	ra,8(sp)
ffffffffc0200850:	00005517          	auipc	a0,0x5
ffffffffc0200854:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205100 <commands+0x438>
ffffffffc0200858:	0141                	addi	sp,sp,16
ffffffffc020085a:	927ff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020085e <interrupt_handler>:
ffffffffc020085e:	11853783          	ld	a5,280(a0)
ffffffffc0200862:	472d                	li	a4,11
ffffffffc0200864:	0786                	slli	a5,a5,0x1
ffffffffc0200866:	8385                	srli	a5,a5,0x1
ffffffffc0200868:	06f76c63          	bltu	a4,a5,ffffffffc02008e0 <interrupt_handler+0x82>
ffffffffc020086c:	00005717          	auipc	a4,0x5
ffffffffc0200870:	95c70713          	addi	a4,a4,-1700 # ffffffffc02051c8 <commands+0x500>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
ffffffffc020087a:	97ba                	add	a5,a5,a4
ffffffffc020087c:	8782                	jr	a5
ffffffffc020087e:	00005517          	auipc	a0,0x5
ffffffffc0200882:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0205178 <commands+0x4b0>
ffffffffc0200886:	8fbff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc020088a:	00005517          	auipc	a0,0x5
ffffffffc020088e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0205158 <commands+0x490>
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0200896:	00005517          	auipc	a0,0x5
ffffffffc020089a:	88250513          	addi	a0,a0,-1918 # ffffffffc0205118 <commands+0x450>
ffffffffc020089e:	8e3ff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc02008a2:	00005517          	auipc	a0,0x5
ffffffffc02008a6:	89650513          	addi	a0,a0,-1898 # ffffffffc0205138 <commands+0x470>
ffffffffc02008aa:	8d7ff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc02008ae:	1141                	addi	sp,sp,-16
ffffffffc02008b0:	e406                	sd	ra,8(sp)
ffffffffc02008b2:	c29ff0ef          	jal	ra,ffffffffc02004da <clock_set_next_event>
ffffffffc02008b6:	00015697          	auipc	a3,0x15
ffffffffc02008ba:	c8268693          	addi	a3,a3,-894 # ffffffffc0215538 <ticks>
ffffffffc02008be:	629c                	ld	a5,0(a3)
ffffffffc02008c0:	06400713          	li	a4,100
ffffffffc02008c4:	0785                	addi	a5,a5,1
ffffffffc02008c6:	02e7f733          	remu	a4,a5,a4
ffffffffc02008ca:	e29c                	sd	a5,0(a3)
ffffffffc02008cc:	cb19                	beqz	a4,ffffffffc02008e2 <interrupt_handler+0x84>
ffffffffc02008ce:	60a2                	ld	ra,8(sp)
ffffffffc02008d0:	0141                	addi	sp,sp,16
ffffffffc02008d2:	8082                	ret
ffffffffc02008d4:	00005517          	auipc	a0,0x5
ffffffffc02008d8:	8d450513          	addi	a0,a0,-1836 # ffffffffc02051a8 <commands+0x4e0>
ffffffffc02008dc:	8a5ff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc02008e0:	bf31                	j	ffffffffc02007fc <print_trapframe>
ffffffffc02008e2:	60a2                	ld	ra,8(sp)
ffffffffc02008e4:	06400593          	li	a1,100
ffffffffc02008e8:	00005517          	auipc	a0,0x5
ffffffffc02008ec:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205198 <commands+0x4d0>
ffffffffc02008f0:	0141                	addi	sp,sp,16
ffffffffc02008f2:	88fff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc02008f6 <exception_handler>:
ffffffffc02008f6:	11853783          	ld	a5,280(a0)
ffffffffc02008fa:	1101                	addi	sp,sp,-32
ffffffffc02008fc:	e822                	sd	s0,16(sp)
ffffffffc02008fe:	ec06                	sd	ra,24(sp)
ffffffffc0200900:	e426                	sd	s1,8(sp)
ffffffffc0200902:	473d                	li	a4,15
ffffffffc0200904:	842a                	mv	s0,a0
ffffffffc0200906:	14f76a63          	bltu	a4,a5,ffffffffc0200a5a <exception_handler+0x164>
ffffffffc020090a:	00005717          	auipc	a4,0x5
ffffffffc020090e:	aa670713          	addi	a4,a4,-1370 # ffffffffc02053b0 <commands+0x6e8>
ffffffffc0200912:	078a                	slli	a5,a5,0x2
ffffffffc0200914:	97ba                	add	a5,a5,a4
ffffffffc0200916:	439c                	lw	a5,0(a5)
ffffffffc0200918:	97ba                	add	a5,a5,a4
ffffffffc020091a:	8782                	jr	a5
ffffffffc020091c:	00005517          	auipc	a0,0x5
ffffffffc0200920:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0205398 <commands+0x6d0>
ffffffffc0200924:	85dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200928:	8522                	mv	a0,s0
ffffffffc020092a:	c7dff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc020092e:	84aa                	mv	s1,a0
ffffffffc0200930:	12051b63          	bnez	a0,ffffffffc0200a66 <exception_handler+0x170>
ffffffffc0200934:	60e2                	ld	ra,24(sp)
ffffffffc0200936:	6442                	ld	s0,16(sp)
ffffffffc0200938:	64a2                	ld	s1,8(sp)
ffffffffc020093a:	6105                	addi	sp,sp,32
ffffffffc020093c:	8082                	ret
ffffffffc020093e:	00005517          	auipc	a0,0x5
ffffffffc0200942:	8ba50513          	addi	a0,a0,-1862 # ffffffffc02051f8 <commands+0x530>
ffffffffc0200946:	6442                	ld	s0,16(sp)
ffffffffc0200948:	60e2                	ld	ra,24(sp)
ffffffffc020094a:	64a2                	ld	s1,8(sp)
ffffffffc020094c:	6105                	addi	sp,sp,32
ffffffffc020094e:	833ff06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0200952:	00005517          	auipc	a0,0x5
ffffffffc0200956:	8c650513          	addi	a0,a0,-1850 # ffffffffc0205218 <commands+0x550>
ffffffffc020095a:	b7f5                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc020095c:	00005517          	auipc	a0,0x5
ffffffffc0200960:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0205238 <commands+0x570>
ffffffffc0200964:	b7cd                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc0200966:	00005517          	auipc	a0,0x5
ffffffffc020096a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0205250 <commands+0x588>
ffffffffc020096e:	bfe1                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc0200970:	00005517          	auipc	a0,0x5
ffffffffc0200974:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205260 <commands+0x598>
ffffffffc0200978:	b7f9                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc020097a:	00005517          	auipc	a0,0x5
ffffffffc020097e:	90650513          	addi	a0,a0,-1786 # ffffffffc0205280 <commands+0x5b8>
ffffffffc0200982:	ffeff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200986:	8522                	mv	a0,s0
ffffffffc0200988:	c1fff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc020098c:	84aa                	mv	s1,a0
ffffffffc020098e:	d15d                	beqz	a0,ffffffffc0200934 <exception_handler+0x3e>
ffffffffc0200990:	8522                	mv	a0,s0
ffffffffc0200992:	e6bff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
ffffffffc0200996:	86a6                	mv	a3,s1
ffffffffc0200998:	00005617          	auipc	a2,0x5
ffffffffc020099c:	90060613          	addi	a2,a2,-1792 # ffffffffc0205298 <commands+0x5d0>
ffffffffc02009a0:	0b300593          	li	a1,179
ffffffffc02009a4:	00004517          	auipc	a0,0x4
ffffffffc02009a8:	3e450513          	addi	a0,a0,996 # ffffffffc0204d88 <commands+0xc0>
ffffffffc02009ac:	a9bff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02009b0:	00005517          	auipc	a0,0x5
ffffffffc02009b4:	90850513          	addi	a0,a0,-1784 # ffffffffc02052b8 <commands+0x5f0>
ffffffffc02009b8:	b779                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc02009ba:	00005517          	auipc	a0,0x5
ffffffffc02009be:	91650513          	addi	a0,a0,-1770 # ffffffffc02052d0 <commands+0x608>
ffffffffc02009c2:	fbeff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02009c6:	8522                	mv	a0,s0
ffffffffc02009c8:	bdfff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc02009cc:	84aa                	mv	s1,a0
ffffffffc02009ce:	d13d                	beqz	a0,ffffffffc0200934 <exception_handler+0x3e>
ffffffffc02009d0:	8522                	mv	a0,s0
ffffffffc02009d2:	e2bff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
ffffffffc02009d6:	86a6                	mv	a3,s1
ffffffffc02009d8:	00005617          	auipc	a2,0x5
ffffffffc02009dc:	8c060613          	addi	a2,a2,-1856 # ffffffffc0205298 <commands+0x5d0>
ffffffffc02009e0:	0bd00593          	li	a1,189
ffffffffc02009e4:	00004517          	auipc	a0,0x4
ffffffffc02009e8:	3a450513          	addi	a0,a0,932 # ffffffffc0204d88 <commands+0xc0>
ffffffffc02009ec:	a5bff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02009f0:	00005517          	auipc	a0,0x5
ffffffffc02009f4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02052e8 <commands+0x620>
ffffffffc02009f8:	b7b9                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc02009fa:	00005517          	auipc	a0,0x5
ffffffffc02009fe:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205308 <commands+0x640>
ffffffffc0200a02:	b791                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc0200a04:	00005517          	auipc	a0,0x5
ffffffffc0200a08:	92450513          	addi	a0,a0,-1756 # ffffffffc0205328 <commands+0x660>
ffffffffc0200a0c:	bf2d                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc0200a0e:	00005517          	auipc	a0,0x5
ffffffffc0200a12:	93a50513          	addi	a0,a0,-1734 # ffffffffc0205348 <commands+0x680>
ffffffffc0200a16:	bf05                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	95050513          	addi	a0,a0,-1712 # ffffffffc0205368 <commands+0x6a0>
ffffffffc0200a20:	b71d                	j	ffffffffc0200946 <exception_handler+0x50>
ffffffffc0200a22:	00005517          	auipc	a0,0x5
ffffffffc0200a26:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205380 <commands+0x6b8>
ffffffffc0200a2a:	f56ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200a2e:	8522                	mv	a0,s0
ffffffffc0200a30:	b77ff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc0200a34:	84aa                	mv	s1,a0
ffffffffc0200a36:	ee050fe3          	beqz	a0,ffffffffc0200934 <exception_handler+0x3e>
ffffffffc0200a3a:	8522                	mv	a0,s0
ffffffffc0200a3c:	dc1ff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
ffffffffc0200a40:	86a6                	mv	a3,s1
ffffffffc0200a42:	00005617          	auipc	a2,0x5
ffffffffc0200a46:	85660613          	addi	a2,a2,-1962 # ffffffffc0205298 <commands+0x5d0>
ffffffffc0200a4a:	0d300593          	li	a1,211
ffffffffc0200a4e:	00004517          	auipc	a0,0x4
ffffffffc0200a52:	33a50513          	addi	a0,a0,826 # ffffffffc0204d88 <commands+0xc0>
ffffffffc0200a56:	9f1ff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200a5a:	8522                	mv	a0,s0
ffffffffc0200a5c:	6442                	ld	s0,16(sp)
ffffffffc0200a5e:	60e2                	ld	ra,24(sp)
ffffffffc0200a60:	64a2                	ld	s1,8(sp)
ffffffffc0200a62:	6105                	addi	sp,sp,32
ffffffffc0200a64:	bb61                	j	ffffffffc02007fc <print_trapframe>
ffffffffc0200a66:	8522                	mv	a0,s0
ffffffffc0200a68:	d95ff0ef          	jal	ra,ffffffffc02007fc <print_trapframe>
ffffffffc0200a6c:	86a6                	mv	a3,s1
ffffffffc0200a6e:	00005617          	auipc	a2,0x5
ffffffffc0200a72:	82a60613          	addi	a2,a2,-2006 # ffffffffc0205298 <commands+0x5d0>
ffffffffc0200a76:	0da00593          	li	a1,218
ffffffffc0200a7a:	00004517          	auipc	a0,0x4
ffffffffc0200a7e:	30e50513          	addi	a0,a0,782 # ffffffffc0204d88 <commands+0xc0>
ffffffffc0200a82:	9c5ff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0200a86 <trap>:
ffffffffc0200a86:	11853783          	ld	a5,280(a0)
ffffffffc0200a8a:	0007c363          	bltz	a5,ffffffffc0200a90 <trap+0xa>
ffffffffc0200a8e:	b5a5                	j	ffffffffc02008f6 <exception_handler>
ffffffffc0200a90:	b3f9                	j	ffffffffc020085e <interrupt_handler>
	...

ffffffffc0200a94 <__alltraps>:
ffffffffc0200a94:	14011073          	csrw	sscratch,sp
ffffffffc0200a98:	712d                	addi	sp,sp,-288
ffffffffc0200a9a:	e406                	sd	ra,8(sp)
ffffffffc0200a9c:	ec0e                	sd	gp,24(sp)
ffffffffc0200a9e:	f012                	sd	tp,32(sp)
ffffffffc0200aa0:	f416                	sd	t0,40(sp)
ffffffffc0200aa2:	f81a                	sd	t1,48(sp)
ffffffffc0200aa4:	fc1e                	sd	t2,56(sp)
ffffffffc0200aa6:	e0a2                	sd	s0,64(sp)
ffffffffc0200aa8:	e4a6                	sd	s1,72(sp)
ffffffffc0200aaa:	e8aa                	sd	a0,80(sp)
ffffffffc0200aac:	ecae                	sd	a1,88(sp)
ffffffffc0200aae:	f0b2                	sd	a2,96(sp)
ffffffffc0200ab0:	f4b6                	sd	a3,104(sp)
ffffffffc0200ab2:	f8ba                	sd	a4,112(sp)
ffffffffc0200ab4:	fcbe                	sd	a5,120(sp)
ffffffffc0200ab6:	e142                	sd	a6,128(sp)
ffffffffc0200ab8:	e546                	sd	a7,136(sp)
ffffffffc0200aba:	e94a                	sd	s2,144(sp)
ffffffffc0200abc:	ed4e                	sd	s3,152(sp)
ffffffffc0200abe:	f152                	sd	s4,160(sp)
ffffffffc0200ac0:	f556                	sd	s5,168(sp)
ffffffffc0200ac2:	f95a                	sd	s6,176(sp)
ffffffffc0200ac4:	fd5e                	sd	s7,184(sp)
ffffffffc0200ac6:	e1e2                	sd	s8,192(sp)
ffffffffc0200ac8:	e5e6                	sd	s9,200(sp)
ffffffffc0200aca:	e9ea                	sd	s10,208(sp)
ffffffffc0200acc:	edee                	sd	s11,216(sp)
ffffffffc0200ace:	f1f2                	sd	t3,224(sp)
ffffffffc0200ad0:	f5f6                	sd	t4,232(sp)
ffffffffc0200ad2:	f9fa                	sd	t5,240(sp)
ffffffffc0200ad4:	fdfe                	sd	t6,248(sp)
ffffffffc0200ad6:	14002473          	csrr	s0,sscratch
ffffffffc0200ada:	100024f3          	csrr	s1,sstatus
ffffffffc0200ade:	14102973          	csrr	s2,sepc
ffffffffc0200ae2:	143029f3          	csrr	s3,stval
ffffffffc0200ae6:	14202a73          	csrr	s4,scause
ffffffffc0200aea:	e822                	sd	s0,16(sp)
ffffffffc0200aec:	e226                	sd	s1,256(sp)
ffffffffc0200aee:	e64a                	sd	s2,264(sp)
ffffffffc0200af0:	ea4e                	sd	s3,272(sp)
ffffffffc0200af2:	ee52                	sd	s4,280(sp)
ffffffffc0200af4:	850a                	mv	a0,sp
ffffffffc0200af6:	f91ff0ef          	jal	ra,ffffffffc0200a86 <trap>

ffffffffc0200afa <__trapret>:
ffffffffc0200afa:	6492                	ld	s1,256(sp)
ffffffffc0200afc:	6932                	ld	s2,264(sp)
ffffffffc0200afe:	10049073          	csrw	sstatus,s1
ffffffffc0200b02:	14191073          	csrw	sepc,s2
ffffffffc0200b06:	60a2                	ld	ra,8(sp)
ffffffffc0200b08:	61e2                	ld	gp,24(sp)
ffffffffc0200b0a:	7202                	ld	tp,32(sp)
ffffffffc0200b0c:	72a2                	ld	t0,40(sp)
ffffffffc0200b0e:	7342                	ld	t1,48(sp)
ffffffffc0200b10:	73e2                	ld	t2,56(sp)
ffffffffc0200b12:	6406                	ld	s0,64(sp)
ffffffffc0200b14:	64a6                	ld	s1,72(sp)
ffffffffc0200b16:	6546                	ld	a0,80(sp)
ffffffffc0200b18:	65e6                	ld	a1,88(sp)
ffffffffc0200b1a:	7606                	ld	a2,96(sp)
ffffffffc0200b1c:	76a6                	ld	a3,104(sp)
ffffffffc0200b1e:	7746                	ld	a4,112(sp)
ffffffffc0200b20:	77e6                	ld	a5,120(sp)
ffffffffc0200b22:	680a                	ld	a6,128(sp)
ffffffffc0200b24:	68aa                	ld	a7,136(sp)
ffffffffc0200b26:	694a                	ld	s2,144(sp)
ffffffffc0200b28:	69ea                	ld	s3,152(sp)
ffffffffc0200b2a:	7a0a                	ld	s4,160(sp)
ffffffffc0200b2c:	7aaa                	ld	s5,168(sp)
ffffffffc0200b2e:	7b4a                	ld	s6,176(sp)
ffffffffc0200b30:	7bea                	ld	s7,184(sp)
ffffffffc0200b32:	6c0e                	ld	s8,192(sp)
ffffffffc0200b34:	6cae                	ld	s9,200(sp)
ffffffffc0200b36:	6d4e                	ld	s10,208(sp)
ffffffffc0200b38:	6dee                	ld	s11,216(sp)
ffffffffc0200b3a:	7e0e                	ld	t3,224(sp)
ffffffffc0200b3c:	7eae                	ld	t4,232(sp)
ffffffffc0200b3e:	7f4e                	ld	t5,240(sp)
ffffffffc0200b40:	7fee                	ld	t6,248(sp)
ffffffffc0200b42:	6142                	ld	sp,16(sp)
ffffffffc0200b44:	10200073          	sret

ffffffffc0200b48 <forkrets>:
ffffffffc0200b48:	812a                	mv	sp,a0
ffffffffc0200b4a:	bf45                	j	ffffffffc0200afa <__trapret>
	...

ffffffffc0200b4e <default_init>:
ffffffffc0200b4e:	00011797          	auipc	a5,0x11
ffffffffc0200b52:	90a78793          	addi	a5,a5,-1782 # ffffffffc0211458 <free_area>
ffffffffc0200b56:	e79c                	sd	a5,8(a5)
ffffffffc0200b58:	e39c                	sd	a5,0(a5)
ffffffffc0200b5a:	0007a823          	sw	zero,16(a5)
ffffffffc0200b5e:	8082                	ret

ffffffffc0200b60 <default_nr_free_pages>:
ffffffffc0200b60:	00011517          	auipc	a0,0x11
ffffffffc0200b64:	90856503          	lwu	a0,-1784(a0) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200b68:	8082                	ret

ffffffffc0200b6a <default_check>:
ffffffffc0200b6a:	715d                	addi	sp,sp,-80
ffffffffc0200b6c:	e0a2                	sd	s0,64(sp)
ffffffffc0200b6e:	00011417          	auipc	s0,0x11
ffffffffc0200b72:	8ea40413          	addi	s0,s0,-1814 # ffffffffc0211458 <free_area>
ffffffffc0200b76:	641c                	ld	a5,8(s0)
ffffffffc0200b78:	e486                	sd	ra,72(sp)
ffffffffc0200b7a:	fc26                	sd	s1,56(sp)
ffffffffc0200b7c:	f84a                	sd	s2,48(sp)
ffffffffc0200b7e:	f44e                	sd	s3,40(sp)
ffffffffc0200b80:	f052                	sd	s4,32(sp)
ffffffffc0200b82:	ec56                	sd	s5,24(sp)
ffffffffc0200b84:	e85a                	sd	s6,16(sp)
ffffffffc0200b86:	e45e                	sd	s7,8(sp)
ffffffffc0200b88:	e062                	sd	s8,0(sp)
ffffffffc0200b8a:	2a878d63          	beq	a5,s0,ffffffffc0200e44 <default_check+0x2da>
ffffffffc0200b8e:	4481                	li	s1,0
ffffffffc0200b90:	4901                	li	s2,0
ffffffffc0200b92:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b96:	8b09                	andi	a4,a4,2
ffffffffc0200b98:	2a070a63          	beqz	a4,ffffffffc0200e4c <default_check+0x2e2>
ffffffffc0200b9c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ba0:	679c                	ld	a5,8(a5)
ffffffffc0200ba2:	2905                	addiw	s2,s2,1
ffffffffc0200ba4:	9cb9                	addw	s1,s1,a4
ffffffffc0200ba6:	fe8796e3          	bne	a5,s0,ffffffffc0200b92 <default_check+0x28>
ffffffffc0200baa:	89a6                	mv	s3,s1
ffffffffc0200bac:	72f000ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0200bb0:	6f351e63          	bne	a0,s3,ffffffffc02012ac <default_check+0x742>
ffffffffc0200bb4:	4505                	li	a0,1
ffffffffc0200bb6:	653000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200bba:	8aaa                	mv	s5,a0
ffffffffc0200bbc:	42050863          	beqz	a0,ffffffffc0200fec <default_check+0x482>
ffffffffc0200bc0:	4505                	li	a0,1
ffffffffc0200bc2:	647000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200bc6:	89aa                	mv	s3,a0
ffffffffc0200bc8:	70050263          	beqz	a0,ffffffffc02012cc <default_check+0x762>
ffffffffc0200bcc:	4505                	li	a0,1
ffffffffc0200bce:	63b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200bd2:	8a2a                	mv	s4,a0
ffffffffc0200bd4:	48050c63          	beqz	a0,ffffffffc020106c <default_check+0x502>
ffffffffc0200bd8:	293a8a63          	beq	s5,s3,ffffffffc0200e6c <default_check+0x302>
ffffffffc0200bdc:	28aa8863          	beq	s5,a0,ffffffffc0200e6c <default_check+0x302>
ffffffffc0200be0:	28a98663          	beq	s3,a0,ffffffffc0200e6c <default_check+0x302>
ffffffffc0200be4:	000aa783          	lw	a5,0(s5)
ffffffffc0200be8:	2a079263          	bnez	a5,ffffffffc0200e8c <default_check+0x322>
ffffffffc0200bec:	0009a783          	lw	a5,0(s3)
ffffffffc0200bf0:	28079e63          	bnez	a5,ffffffffc0200e8c <default_check+0x322>
ffffffffc0200bf4:	411c                	lw	a5,0(a0)
ffffffffc0200bf6:	28079b63          	bnez	a5,ffffffffc0200e8c <default_check+0x322>
ffffffffc0200bfa:	00015797          	auipc	a5,0x15
ffffffffc0200bfe:	96e7b783          	ld	a5,-1682(a5) # ffffffffc0215568 <pages>
ffffffffc0200c02:	40fa8733          	sub	a4,s5,a5
ffffffffc0200c06:	00006617          	auipc	a2,0x6
ffffffffc0200c0a:	e7a63603          	ld	a2,-390(a2) # ffffffffc0206a80 <nbase>
ffffffffc0200c0e:	8719                	srai	a4,a4,0x6
ffffffffc0200c10:	9732                	add	a4,a4,a2
ffffffffc0200c12:	00015697          	auipc	a3,0x15
ffffffffc0200c16:	94e6b683          	ld	a3,-1714(a3) # ffffffffc0215560 <npage>
ffffffffc0200c1a:	06b2                	slli	a3,a3,0xc
ffffffffc0200c1c:	0732                	slli	a4,a4,0xc
ffffffffc0200c1e:	28d77763          	bgeu	a4,a3,ffffffffc0200eac <default_check+0x342>
ffffffffc0200c22:	40f98733          	sub	a4,s3,a5
ffffffffc0200c26:	8719                	srai	a4,a4,0x6
ffffffffc0200c28:	9732                	add	a4,a4,a2
ffffffffc0200c2a:	0732                	slli	a4,a4,0xc
ffffffffc0200c2c:	4cd77063          	bgeu	a4,a3,ffffffffc02010ec <default_check+0x582>
ffffffffc0200c30:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c34:	8799                	srai	a5,a5,0x6
ffffffffc0200c36:	97b2                	add	a5,a5,a2
ffffffffc0200c38:	07b2                	slli	a5,a5,0xc
ffffffffc0200c3a:	30d7f963          	bgeu	a5,a3,ffffffffc0200f4c <default_check+0x3e2>
ffffffffc0200c3e:	4505                	li	a0,1
ffffffffc0200c40:	00043c03          	ld	s8,0(s0)
ffffffffc0200c44:	00843b83          	ld	s7,8(s0)
ffffffffc0200c48:	01042b03          	lw	s6,16(s0)
ffffffffc0200c4c:	e400                	sd	s0,8(s0)
ffffffffc0200c4e:	e000                	sd	s0,0(s0)
ffffffffc0200c50:	00011797          	auipc	a5,0x11
ffffffffc0200c54:	8007ac23          	sw	zero,-2024(a5) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200c58:	5b1000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c5c:	2c051863          	bnez	a0,ffffffffc0200f2c <default_check+0x3c2>
ffffffffc0200c60:	4585                	li	a1,1
ffffffffc0200c62:	8556                	mv	a0,s5
ffffffffc0200c64:	637000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200c68:	4585                	li	a1,1
ffffffffc0200c6a:	854e                	mv	a0,s3
ffffffffc0200c6c:	62f000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200c70:	4585                	li	a1,1
ffffffffc0200c72:	8552                	mv	a0,s4
ffffffffc0200c74:	627000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200c78:	4818                	lw	a4,16(s0)
ffffffffc0200c7a:	478d                	li	a5,3
ffffffffc0200c7c:	28f71863          	bne	a4,a5,ffffffffc0200f0c <default_check+0x3a2>
ffffffffc0200c80:	4505                	li	a0,1
ffffffffc0200c82:	587000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c86:	89aa                	mv	s3,a0
ffffffffc0200c88:	26050263          	beqz	a0,ffffffffc0200eec <default_check+0x382>
ffffffffc0200c8c:	4505                	li	a0,1
ffffffffc0200c8e:	57b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c92:	8aaa                	mv	s5,a0
ffffffffc0200c94:	3a050c63          	beqz	a0,ffffffffc020104c <default_check+0x4e2>
ffffffffc0200c98:	4505                	li	a0,1
ffffffffc0200c9a:	56f000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200c9e:	8a2a                	mv	s4,a0
ffffffffc0200ca0:	38050663          	beqz	a0,ffffffffc020102c <default_check+0x4c2>
ffffffffc0200ca4:	4505                	li	a0,1
ffffffffc0200ca6:	563000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200caa:	36051163          	bnez	a0,ffffffffc020100c <default_check+0x4a2>
ffffffffc0200cae:	4585                	li	a1,1
ffffffffc0200cb0:	854e                	mv	a0,s3
ffffffffc0200cb2:	5e9000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200cb6:	641c                	ld	a5,8(s0)
ffffffffc0200cb8:	20878a63          	beq	a5,s0,ffffffffc0200ecc <default_check+0x362>
ffffffffc0200cbc:	4505                	li	a0,1
ffffffffc0200cbe:	54b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200cc2:	30a99563          	bne	s3,a0,ffffffffc0200fcc <default_check+0x462>
ffffffffc0200cc6:	4505                	li	a0,1
ffffffffc0200cc8:	541000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200ccc:	2e051063          	bnez	a0,ffffffffc0200fac <default_check+0x442>
ffffffffc0200cd0:	481c                	lw	a5,16(s0)
ffffffffc0200cd2:	2a079d63          	bnez	a5,ffffffffc0200f8c <default_check+0x422>
ffffffffc0200cd6:	854e                	mv	a0,s3
ffffffffc0200cd8:	4585                	li	a1,1
ffffffffc0200cda:	01843023          	sd	s8,0(s0)
ffffffffc0200cde:	01743423          	sd	s7,8(s0)
ffffffffc0200ce2:	01642823          	sw	s6,16(s0)
ffffffffc0200ce6:	5b5000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200cea:	4585                	li	a1,1
ffffffffc0200cec:	8556                	mv	a0,s5
ffffffffc0200cee:	5ad000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200cf2:	4585                	li	a1,1
ffffffffc0200cf4:	8552                	mv	a0,s4
ffffffffc0200cf6:	5a5000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200cfa:	4515                	li	a0,5
ffffffffc0200cfc:	50d000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d00:	89aa                	mv	s3,a0
ffffffffc0200d02:	26050563          	beqz	a0,ffffffffc0200f6c <default_check+0x402>
ffffffffc0200d06:	651c                	ld	a5,8(a0)
ffffffffc0200d08:	8385                	srli	a5,a5,0x1
ffffffffc0200d0a:	8b85                	andi	a5,a5,1
ffffffffc0200d0c:	54079063          	bnez	a5,ffffffffc020124c <default_check+0x6e2>
ffffffffc0200d10:	4505                	li	a0,1
ffffffffc0200d12:	00043b03          	ld	s6,0(s0)
ffffffffc0200d16:	00843a83          	ld	s5,8(s0)
ffffffffc0200d1a:	e000                	sd	s0,0(s0)
ffffffffc0200d1c:	e400                	sd	s0,8(s0)
ffffffffc0200d1e:	4eb000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d22:	50051563          	bnez	a0,ffffffffc020122c <default_check+0x6c2>
ffffffffc0200d26:	08098a13          	addi	s4,s3,128
ffffffffc0200d2a:	8552                	mv	a0,s4
ffffffffc0200d2c:	458d                	li	a1,3
ffffffffc0200d2e:	01042b83          	lw	s7,16(s0)
ffffffffc0200d32:	00010797          	auipc	a5,0x10
ffffffffc0200d36:	7207ab23          	sw	zero,1846(a5) # ffffffffc0211468 <free_area+0x10>
ffffffffc0200d3a:	561000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200d3e:	4511                	li	a0,4
ffffffffc0200d40:	4c9000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d44:	4c051463          	bnez	a0,ffffffffc020120c <default_check+0x6a2>
ffffffffc0200d48:	0889b783          	ld	a5,136(s3)
ffffffffc0200d4c:	8385                	srli	a5,a5,0x1
ffffffffc0200d4e:	8b85                	andi	a5,a5,1
ffffffffc0200d50:	48078e63          	beqz	a5,ffffffffc02011ec <default_check+0x682>
ffffffffc0200d54:	0909a703          	lw	a4,144(s3)
ffffffffc0200d58:	478d                	li	a5,3
ffffffffc0200d5a:	48f71963          	bne	a4,a5,ffffffffc02011ec <default_check+0x682>
ffffffffc0200d5e:	450d                	li	a0,3
ffffffffc0200d60:	4a9000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d64:	8c2a                	mv	s8,a0
ffffffffc0200d66:	46050363          	beqz	a0,ffffffffc02011cc <default_check+0x662>
ffffffffc0200d6a:	4505                	li	a0,1
ffffffffc0200d6c:	49d000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200d70:	42051e63          	bnez	a0,ffffffffc02011ac <default_check+0x642>
ffffffffc0200d74:	418a1c63          	bne	s4,s8,ffffffffc020118c <default_check+0x622>
ffffffffc0200d78:	4585                	li	a1,1
ffffffffc0200d7a:	854e                	mv	a0,s3
ffffffffc0200d7c:	51f000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200d80:	458d                	li	a1,3
ffffffffc0200d82:	8552                	mv	a0,s4
ffffffffc0200d84:	517000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200d88:	0089b783          	ld	a5,8(s3)
ffffffffc0200d8c:	04098c13          	addi	s8,s3,64
ffffffffc0200d90:	8385                	srli	a5,a5,0x1
ffffffffc0200d92:	8b85                	andi	a5,a5,1
ffffffffc0200d94:	3c078c63          	beqz	a5,ffffffffc020116c <default_check+0x602>
ffffffffc0200d98:	0109a703          	lw	a4,16(s3)
ffffffffc0200d9c:	4785                	li	a5,1
ffffffffc0200d9e:	3cf71763          	bne	a4,a5,ffffffffc020116c <default_check+0x602>
ffffffffc0200da2:	008a3783          	ld	a5,8(s4)
ffffffffc0200da6:	8385                	srli	a5,a5,0x1
ffffffffc0200da8:	8b85                	andi	a5,a5,1
ffffffffc0200daa:	3a078163          	beqz	a5,ffffffffc020114c <default_check+0x5e2>
ffffffffc0200dae:	010a2703          	lw	a4,16(s4)
ffffffffc0200db2:	478d                	li	a5,3
ffffffffc0200db4:	38f71c63          	bne	a4,a5,ffffffffc020114c <default_check+0x5e2>
ffffffffc0200db8:	4505                	li	a0,1
ffffffffc0200dba:	44f000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200dbe:	36a99763          	bne	s3,a0,ffffffffc020112c <default_check+0x5c2>
ffffffffc0200dc2:	4585                	li	a1,1
ffffffffc0200dc4:	4d7000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200dc8:	4509                	li	a0,2
ffffffffc0200dca:	43f000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200dce:	32aa1f63          	bne	s4,a0,ffffffffc020110c <default_check+0x5a2>
ffffffffc0200dd2:	4589                	li	a1,2
ffffffffc0200dd4:	4c7000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200dd8:	4585                	li	a1,1
ffffffffc0200dda:	8562                	mv	a0,s8
ffffffffc0200ddc:	4bf000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200de0:	4515                	li	a0,5
ffffffffc0200de2:	427000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200de6:	89aa                	mv	s3,a0
ffffffffc0200de8:	48050263          	beqz	a0,ffffffffc020126c <default_check+0x702>
ffffffffc0200dec:	4505                	li	a0,1
ffffffffc0200dee:	41b000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0200df2:	2c051d63          	bnez	a0,ffffffffc02010cc <default_check+0x562>
ffffffffc0200df6:	481c                	lw	a5,16(s0)
ffffffffc0200df8:	2a079a63          	bnez	a5,ffffffffc02010ac <default_check+0x542>
ffffffffc0200dfc:	4595                	li	a1,5
ffffffffc0200dfe:	854e                	mv	a0,s3
ffffffffc0200e00:	01742823          	sw	s7,16(s0)
ffffffffc0200e04:	01643023          	sd	s6,0(s0)
ffffffffc0200e08:	01543423          	sd	s5,8(s0)
ffffffffc0200e0c:	48f000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0200e10:	641c                	ld	a5,8(s0)
ffffffffc0200e12:	00878963          	beq	a5,s0,ffffffffc0200e24 <default_check+0x2ba>
ffffffffc0200e16:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e1a:	679c                	ld	a5,8(a5)
ffffffffc0200e1c:	397d                	addiw	s2,s2,-1
ffffffffc0200e1e:	9c99                	subw	s1,s1,a4
ffffffffc0200e20:	fe879be3          	bne	a5,s0,ffffffffc0200e16 <default_check+0x2ac>
ffffffffc0200e24:	26091463          	bnez	s2,ffffffffc020108c <default_check+0x522>
ffffffffc0200e28:	46049263          	bnez	s1,ffffffffc020128c <default_check+0x722>
ffffffffc0200e2c:	60a6                	ld	ra,72(sp)
ffffffffc0200e2e:	6406                	ld	s0,64(sp)
ffffffffc0200e30:	74e2                	ld	s1,56(sp)
ffffffffc0200e32:	7942                	ld	s2,48(sp)
ffffffffc0200e34:	79a2                	ld	s3,40(sp)
ffffffffc0200e36:	7a02                	ld	s4,32(sp)
ffffffffc0200e38:	6ae2                	ld	s5,24(sp)
ffffffffc0200e3a:	6b42                	ld	s6,16(sp)
ffffffffc0200e3c:	6ba2                	ld	s7,8(sp)
ffffffffc0200e3e:	6c02                	ld	s8,0(sp)
ffffffffc0200e40:	6161                	addi	sp,sp,80
ffffffffc0200e42:	8082                	ret
ffffffffc0200e44:	4981                	li	s3,0
ffffffffc0200e46:	4481                	li	s1,0
ffffffffc0200e48:	4901                	li	s2,0
ffffffffc0200e4a:	b38d                	j	ffffffffc0200bac <default_check+0x42>
ffffffffc0200e4c:	00004697          	auipc	a3,0x4
ffffffffc0200e50:	5a468693          	addi	a3,a3,1444 # ffffffffc02053f0 <commands+0x728>
ffffffffc0200e54:	00004617          	auipc	a2,0x4
ffffffffc0200e58:	5ac60613          	addi	a2,a2,1452 # ffffffffc0205400 <commands+0x738>
ffffffffc0200e5c:	0f000593          	li	a1,240
ffffffffc0200e60:	00004517          	auipc	a0,0x4
ffffffffc0200e64:	5b850513          	addi	a0,a0,1464 # ffffffffc0205418 <commands+0x750>
ffffffffc0200e68:	ddeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200e6c:	00004697          	auipc	a3,0x4
ffffffffc0200e70:	64468693          	addi	a3,a3,1604 # ffffffffc02054b0 <commands+0x7e8>
ffffffffc0200e74:	00004617          	auipc	a2,0x4
ffffffffc0200e78:	58c60613          	addi	a2,a2,1420 # ffffffffc0205400 <commands+0x738>
ffffffffc0200e7c:	0bd00593          	li	a1,189
ffffffffc0200e80:	00004517          	auipc	a0,0x4
ffffffffc0200e84:	59850513          	addi	a0,a0,1432 # ffffffffc0205418 <commands+0x750>
ffffffffc0200e88:	dbeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200e8c:	00004697          	auipc	a3,0x4
ffffffffc0200e90:	64c68693          	addi	a3,a3,1612 # ffffffffc02054d8 <commands+0x810>
ffffffffc0200e94:	00004617          	auipc	a2,0x4
ffffffffc0200e98:	56c60613          	addi	a2,a2,1388 # ffffffffc0205400 <commands+0x738>
ffffffffc0200e9c:	0be00593          	li	a1,190
ffffffffc0200ea0:	00004517          	auipc	a0,0x4
ffffffffc0200ea4:	57850513          	addi	a0,a0,1400 # ffffffffc0205418 <commands+0x750>
ffffffffc0200ea8:	d9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200eac:	00004697          	auipc	a3,0x4
ffffffffc0200eb0:	66c68693          	addi	a3,a3,1644 # ffffffffc0205518 <commands+0x850>
ffffffffc0200eb4:	00004617          	auipc	a2,0x4
ffffffffc0200eb8:	54c60613          	addi	a2,a2,1356 # ffffffffc0205400 <commands+0x738>
ffffffffc0200ebc:	0c000593          	li	a1,192
ffffffffc0200ec0:	00004517          	auipc	a0,0x4
ffffffffc0200ec4:	55850513          	addi	a0,a0,1368 # ffffffffc0205418 <commands+0x750>
ffffffffc0200ec8:	d7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200ecc:	00004697          	auipc	a3,0x4
ffffffffc0200ed0:	6d468693          	addi	a3,a3,1748 # ffffffffc02055a0 <commands+0x8d8>
ffffffffc0200ed4:	00004617          	auipc	a2,0x4
ffffffffc0200ed8:	52c60613          	addi	a2,a2,1324 # ffffffffc0205400 <commands+0x738>
ffffffffc0200edc:	0d900593          	li	a1,217
ffffffffc0200ee0:	00004517          	auipc	a0,0x4
ffffffffc0200ee4:	53850513          	addi	a0,a0,1336 # ffffffffc0205418 <commands+0x750>
ffffffffc0200ee8:	d5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200eec:	00004697          	auipc	a3,0x4
ffffffffc0200ef0:	56468693          	addi	a3,a3,1380 # ffffffffc0205450 <commands+0x788>
ffffffffc0200ef4:	00004617          	auipc	a2,0x4
ffffffffc0200ef8:	50c60613          	addi	a2,a2,1292 # ffffffffc0205400 <commands+0x738>
ffffffffc0200efc:	0d200593          	li	a1,210
ffffffffc0200f00:	00004517          	auipc	a0,0x4
ffffffffc0200f04:	51850513          	addi	a0,a0,1304 # ffffffffc0205418 <commands+0x750>
ffffffffc0200f08:	d3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200f0c:	00004697          	auipc	a3,0x4
ffffffffc0200f10:	68468693          	addi	a3,a3,1668 # ffffffffc0205590 <commands+0x8c8>
ffffffffc0200f14:	00004617          	auipc	a2,0x4
ffffffffc0200f18:	4ec60613          	addi	a2,a2,1260 # ffffffffc0205400 <commands+0x738>
ffffffffc0200f1c:	0d000593          	li	a1,208
ffffffffc0200f20:	00004517          	auipc	a0,0x4
ffffffffc0200f24:	4f850513          	addi	a0,a0,1272 # ffffffffc0205418 <commands+0x750>
ffffffffc0200f28:	d1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200f2c:	00004697          	auipc	a3,0x4
ffffffffc0200f30:	64c68693          	addi	a3,a3,1612 # ffffffffc0205578 <commands+0x8b0>
ffffffffc0200f34:	00004617          	auipc	a2,0x4
ffffffffc0200f38:	4cc60613          	addi	a2,a2,1228 # ffffffffc0205400 <commands+0x738>
ffffffffc0200f3c:	0cb00593          	li	a1,203
ffffffffc0200f40:	00004517          	auipc	a0,0x4
ffffffffc0200f44:	4d850513          	addi	a0,a0,1240 # ffffffffc0205418 <commands+0x750>
ffffffffc0200f48:	cfeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200f4c:	00004697          	auipc	a3,0x4
ffffffffc0200f50:	60c68693          	addi	a3,a3,1548 # ffffffffc0205558 <commands+0x890>
ffffffffc0200f54:	00004617          	auipc	a2,0x4
ffffffffc0200f58:	4ac60613          	addi	a2,a2,1196 # ffffffffc0205400 <commands+0x738>
ffffffffc0200f5c:	0c200593          	li	a1,194
ffffffffc0200f60:	00004517          	auipc	a0,0x4
ffffffffc0200f64:	4b850513          	addi	a0,a0,1208 # ffffffffc0205418 <commands+0x750>
ffffffffc0200f68:	cdeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200f6c:	00004697          	auipc	a3,0x4
ffffffffc0200f70:	67c68693          	addi	a3,a3,1660 # ffffffffc02055e8 <commands+0x920>
ffffffffc0200f74:	00004617          	auipc	a2,0x4
ffffffffc0200f78:	48c60613          	addi	a2,a2,1164 # ffffffffc0205400 <commands+0x738>
ffffffffc0200f7c:	0f800593          	li	a1,248
ffffffffc0200f80:	00004517          	auipc	a0,0x4
ffffffffc0200f84:	49850513          	addi	a0,a0,1176 # ffffffffc0205418 <commands+0x750>
ffffffffc0200f88:	cbeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200f8c:	00004697          	auipc	a3,0x4
ffffffffc0200f90:	64c68693          	addi	a3,a3,1612 # ffffffffc02055d8 <commands+0x910>
ffffffffc0200f94:	00004617          	auipc	a2,0x4
ffffffffc0200f98:	46c60613          	addi	a2,a2,1132 # ffffffffc0205400 <commands+0x738>
ffffffffc0200f9c:	0df00593          	li	a1,223
ffffffffc0200fa0:	00004517          	auipc	a0,0x4
ffffffffc0200fa4:	47850513          	addi	a0,a0,1144 # ffffffffc0205418 <commands+0x750>
ffffffffc0200fa8:	c9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200fac:	00004697          	auipc	a3,0x4
ffffffffc0200fb0:	5cc68693          	addi	a3,a3,1484 # ffffffffc0205578 <commands+0x8b0>
ffffffffc0200fb4:	00004617          	auipc	a2,0x4
ffffffffc0200fb8:	44c60613          	addi	a2,a2,1100 # ffffffffc0205400 <commands+0x738>
ffffffffc0200fbc:	0dd00593          	li	a1,221
ffffffffc0200fc0:	00004517          	auipc	a0,0x4
ffffffffc0200fc4:	45850513          	addi	a0,a0,1112 # ffffffffc0205418 <commands+0x750>
ffffffffc0200fc8:	c7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200fcc:	00004697          	auipc	a3,0x4
ffffffffc0200fd0:	5ec68693          	addi	a3,a3,1516 # ffffffffc02055b8 <commands+0x8f0>
ffffffffc0200fd4:	00004617          	auipc	a2,0x4
ffffffffc0200fd8:	42c60613          	addi	a2,a2,1068 # ffffffffc0205400 <commands+0x738>
ffffffffc0200fdc:	0dc00593          	li	a1,220
ffffffffc0200fe0:	00004517          	auipc	a0,0x4
ffffffffc0200fe4:	43850513          	addi	a0,a0,1080 # ffffffffc0205418 <commands+0x750>
ffffffffc0200fe8:	c5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0200fec:	00004697          	auipc	a3,0x4
ffffffffc0200ff0:	46468693          	addi	a3,a3,1124 # ffffffffc0205450 <commands+0x788>
ffffffffc0200ff4:	00004617          	auipc	a2,0x4
ffffffffc0200ff8:	40c60613          	addi	a2,a2,1036 # ffffffffc0205400 <commands+0x738>
ffffffffc0200ffc:	0b900593          	li	a1,185
ffffffffc0201000:	00004517          	auipc	a0,0x4
ffffffffc0201004:	41850513          	addi	a0,a0,1048 # ffffffffc0205418 <commands+0x750>
ffffffffc0201008:	c3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020100c:	00004697          	auipc	a3,0x4
ffffffffc0201010:	56c68693          	addi	a3,a3,1388 # ffffffffc0205578 <commands+0x8b0>
ffffffffc0201014:	00004617          	auipc	a2,0x4
ffffffffc0201018:	3ec60613          	addi	a2,a2,1004 # ffffffffc0205400 <commands+0x738>
ffffffffc020101c:	0d600593          	li	a1,214
ffffffffc0201020:	00004517          	auipc	a0,0x4
ffffffffc0201024:	3f850513          	addi	a0,a0,1016 # ffffffffc0205418 <commands+0x750>
ffffffffc0201028:	c1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020102c:	00004697          	auipc	a3,0x4
ffffffffc0201030:	46468693          	addi	a3,a3,1124 # ffffffffc0205490 <commands+0x7c8>
ffffffffc0201034:	00004617          	auipc	a2,0x4
ffffffffc0201038:	3cc60613          	addi	a2,a2,972 # ffffffffc0205400 <commands+0x738>
ffffffffc020103c:	0d400593          	li	a1,212
ffffffffc0201040:	00004517          	auipc	a0,0x4
ffffffffc0201044:	3d850513          	addi	a0,a0,984 # ffffffffc0205418 <commands+0x750>
ffffffffc0201048:	bfeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020104c:	00004697          	auipc	a3,0x4
ffffffffc0201050:	42468693          	addi	a3,a3,1060 # ffffffffc0205470 <commands+0x7a8>
ffffffffc0201054:	00004617          	auipc	a2,0x4
ffffffffc0201058:	3ac60613          	addi	a2,a2,940 # ffffffffc0205400 <commands+0x738>
ffffffffc020105c:	0d300593          	li	a1,211
ffffffffc0201060:	00004517          	auipc	a0,0x4
ffffffffc0201064:	3b850513          	addi	a0,a0,952 # ffffffffc0205418 <commands+0x750>
ffffffffc0201068:	bdeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020106c:	00004697          	auipc	a3,0x4
ffffffffc0201070:	42468693          	addi	a3,a3,1060 # ffffffffc0205490 <commands+0x7c8>
ffffffffc0201074:	00004617          	auipc	a2,0x4
ffffffffc0201078:	38c60613          	addi	a2,a2,908 # ffffffffc0205400 <commands+0x738>
ffffffffc020107c:	0bb00593          	li	a1,187
ffffffffc0201080:	00004517          	auipc	a0,0x4
ffffffffc0201084:	39850513          	addi	a0,a0,920 # ffffffffc0205418 <commands+0x750>
ffffffffc0201088:	bbeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020108c:	00004697          	auipc	a3,0x4
ffffffffc0201090:	6ac68693          	addi	a3,a3,1708 # ffffffffc0205738 <commands+0xa70>
ffffffffc0201094:	00004617          	auipc	a2,0x4
ffffffffc0201098:	36c60613          	addi	a2,a2,876 # ffffffffc0205400 <commands+0x738>
ffffffffc020109c:	12500593          	li	a1,293
ffffffffc02010a0:	00004517          	auipc	a0,0x4
ffffffffc02010a4:	37850513          	addi	a0,a0,888 # ffffffffc0205418 <commands+0x750>
ffffffffc02010a8:	b9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02010ac:	00004697          	auipc	a3,0x4
ffffffffc02010b0:	52c68693          	addi	a3,a3,1324 # ffffffffc02055d8 <commands+0x910>
ffffffffc02010b4:	00004617          	auipc	a2,0x4
ffffffffc02010b8:	34c60613          	addi	a2,a2,844 # ffffffffc0205400 <commands+0x738>
ffffffffc02010bc:	11a00593          	li	a1,282
ffffffffc02010c0:	00004517          	auipc	a0,0x4
ffffffffc02010c4:	35850513          	addi	a0,a0,856 # ffffffffc0205418 <commands+0x750>
ffffffffc02010c8:	b7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02010cc:	00004697          	auipc	a3,0x4
ffffffffc02010d0:	4ac68693          	addi	a3,a3,1196 # ffffffffc0205578 <commands+0x8b0>
ffffffffc02010d4:	00004617          	auipc	a2,0x4
ffffffffc02010d8:	32c60613          	addi	a2,a2,812 # ffffffffc0205400 <commands+0x738>
ffffffffc02010dc:	11800593          	li	a1,280
ffffffffc02010e0:	00004517          	auipc	a0,0x4
ffffffffc02010e4:	33850513          	addi	a0,a0,824 # ffffffffc0205418 <commands+0x750>
ffffffffc02010e8:	b5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02010ec:	00004697          	auipc	a3,0x4
ffffffffc02010f0:	44c68693          	addi	a3,a3,1100 # ffffffffc0205538 <commands+0x870>
ffffffffc02010f4:	00004617          	auipc	a2,0x4
ffffffffc02010f8:	30c60613          	addi	a2,a2,780 # ffffffffc0205400 <commands+0x738>
ffffffffc02010fc:	0c100593          	li	a1,193
ffffffffc0201100:	00004517          	auipc	a0,0x4
ffffffffc0201104:	31850513          	addi	a0,a0,792 # ffffffffc0205418 <commands+0x750>
ffffffffc0201108:	b3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020110c:	00004697          	auipc	a3,0x4
ffffffffc0201110:	5ec68693          	addi	a3,a3,1516 # ffffffffc02056f8 <commands+0xa30>
ffffffffc0201114:	00004617          	auipc	a2,0x4
ffffffffc0201118:	2ec60613          	addi	a2,a2,748 # ffffffffc0205400 <commands+0x738>
ffffffffc020111c:	11200593          	li	a1,274
ffffffffc0201120:	00004517          	auipc	a0,0x4
ffffffffc0201124:	2f850513          	addi	a0,a0,760 # ffffffffc0205418 <commands+0x750>
ffffffffc0201128:	b1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020112c:	00004697          	auipc	a3,0x4
ffffffffc0201130:	5ac68693          	addi	a3,a3,1452 # ffffffffc02056d8 <commands+0xa10>
ffffffffc0201134:	00004617          	auipc	a2,0x4
ffffffffc0201138:	2cc60613          	addi	a2,a2,716 # ffffffffc0205400 <commands+0x738>
ffffffffc020113c:	11000593          	li	a1,272
ffffffffc0201140:	00004517          	auipc	a0,0x4
ffffffffc0201144:	2d850513          	addi	a0,a0,728 # ffffffffc0205418 <commands+0x750>
ffffffffc0201148:	afeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020114c:	00004697          	auipc	a3,0x4
ffffffffc0201150:	56468693          	addi	a3,a3,1380 # ffffffffc02056b0 <commands+0x9e8>
ffffffffc0201154:	00004617          	auipc	a2,0x4
ffffffffc0201158:	2ac60613          	addi	a2,a2,684 # ffffffffc0205400 <commands+0x738>
ffffffffc020115c:	10e00593          	li	a1,270
ffffffffc0201160:	00004517          	auipc	a0,0x4
ffffffffc0201164:	2b850513          	addi	a0,a0,696 # ffffffffc0205418 <commands+0x750>
ffffffffc0201168:	adeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020116c:	00004697          	auipc	a3,0x4
ffffffffc0201170:	51c68693          	addi	a3,a3,1308 # ffffffffc0205688 <commands+0x9c0>
ffffffffc0201174:	00004617          	auipc	a2,0x4
ffffffffc0201178:	28c60613          	addi	a2,a2,652 # ffffffffc0205400 <commands+0x738>
ffffffffc020117c:	10d00593          	li	a1,269
ffffffffc0201180:	00004517          	auipc	a0,0x4
ffffffffc0201184:	29850513          	addi	a0,a0,664 # ffffffffc0205418 <commands+0x750>
ffffffffc0201188:	abeff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020118c:	00004697          	auipc	a3,0x4
ffffffffc0201190:	4ec68693          	addi	a3,a3,1260 # ffffffffc0205678 <commands+0x9b0>
ffffffffc0201194:	00004617          	auipc	a2,0x4
ffffffffc0201198:	26c60613          	addi	a2,a2,620 # ffffffffc0205400 <commands+0x738>
ffffffffc020119c:	10800593          	li	a1,264
ffffffffc02011a0:	00004517          	auipc	a0,0x4
ffffffffc02011a4:	27850513          	addi	a0,a0,632 # ffffffffc0205418 <commands+0x750>
ffffffffc02011a8:	a9eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02011ac:	00004697          	auipc	a3,0x4
ffffffffc02011b0:	3cc68693          	addi	a3,a3,972 # ffffffffc0205578 <commands+0x8b0>
ffffffffc02011b4:	00004617          	auipc	a2,0x4
ffffffffc02011b8:	24c60613          	addi	a2,a2,588 # ffffffffc0205400 <commands+0x738>
ffffffffc02011bc:	10700593          	li	a1,263
ffffffffc02011c0:	00004517          	auipc	a0,0x4
ffffffffc02011c4:	25850513          	addi	a0,a0,600 # ffffffffc0205418 <commands+0x750>
ffffffffc02011c8:	a7eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02011cc:	00004697          	auipc	a3,0x4
ffffffffc02011d0:	48c68693          	addi	a3,a3,1164 # ffffffffc0205658 <commands+0x990>
ffffffffc02011d4:	00004617          	auipc	a2,0x4
ffffffffc02011d8:	22c60613          	addi	a2,a2,556 # ffffffffc0205400 <commands+0x738>
ffffffffc02011dc:	10600593          	li	a1,262
ffffffffc02011e0:	00004517          	auipc	a0,0x4
ffffffffc02011e4:	23850513          	addi	a0,a0,568 # ffffffffc0205418 <commands+0x750>
ffffffffc02011e8:	a5eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02011ec:	00004697          	auipc	a3,0x4
ffffffffc02011f0:	43c68693          	addi	a3,a3,1084 # ffffffffc0205628 <commands+0x960>
ffffffffc02011f4:	00004617          	auipc	a2,0x4
ffffffffc02011f8:	20c60613          	addi	a2,a2,524 # ffffffffc0205400 <commands+0x738>
ffffffffc02011fc:	10500593          	li	a1,261
ffffffffc0201200:	00004517          	auipc	a0,0x4
ffffffffc0201204:	21850513          	addi	a0,a0,536 # ffffffffc0205418 <commands+0x750>
ffffffffc0201208:	a3eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020120c:	00004697          	auipc	a3,0x4
ffffffffc0201210:	40468693          	addi	a3,a3,1028 # ffffffffc0205610 <commands+0x948>
ffffffffc0201214:	00004617          	auipc	a2,0x4
ffffffffc0201218:	1ec60613          	addi	a2,a2,492 # ffffffffc0205400 <commands+0x738>
ffffffffc020121c:	10400593          	li	a1,260
ffffffffc0201220:	00004517          	auipc	a0,0x4
ffffffffc0201224:	1f850513          	addi	a0,a0,504 # ffffffffc0205418 <commands+0x750>
ffffffffc0201228:	a1eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020122c:	00004697          	auipc	a3,0x4
ffffffffc0201230:	34c68693          	addi	a3,a3,844 # ffffffffc0205578 <commands+0x8b0>
ffffffffc0201234:	00004617          	auipc	a2,0x4
ffffffffc0201238:	1cc60613          	addi	a2,a2,460 # ffffffffc0205400 <commands+0x738>
ffffffffc020123c:	0fe00593          	li	a1,254
ffffffffc0201240:	00004517          	auipc	a0,0x4
ffffffffc0201244:	1d850513          	addi	a0,a0,472 # ffffffffc0205418 <commands+0x750>
ffffffffc0201248:	9feff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020124c:	00004697          	auipc	a3,0x4
ffffffffc0201250:	3ac68693          	addi	a3,a3,940 # ffffffffc02055f8 <commands+0x930>
ffffffffc0201254:	00004617          	auipc	a2,0x4
ffffffffc0201258:	1ac60613          	addi	a2,a2,428 # ffffffffc0205400 <commands+0x738>
ffffffffc020125c:	0f900593          	li	a1,249
ffffffffc0201260:	00004517          	auipc	a0,0x4
ffffffffc0201264:	1b850513          	addi	a0,a0,440 # ffffffffc0205418 <commands+0x750>
ffffffffc0201268:	9deff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020126c:	00004697          	auipc	a3,0x4
ffffffffc0201270:	4ac68693          	addi	a3,a3,1196 # ffffffffc0205718 <commands+0xa50>
ffffffffc0201274:	00004617          	auipc	a2,0x4
ffffffffc0201278:	18c60613          	addi	a2,a2,396 # ffffffffc0205400 <commands+0x738>
ffffffffc020127c:	11700593          	li	a1,279
ffffffffc0201280:	00004517          	auipc	a0,0x4
ffffffffc0201284:	19850513          	addi	a0,a0,408 # ffffffffc0205418 <commands+0x750>
ffffffffc0201288:	9beff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020128c:	00004697          	auipc	a3,0x4
ffffffffc0201290:	4bc68693          	addi	a3,a3,1212 # ffffffffc0205748 <commands+0xa80>
ffffffffc0201294:	00004617          	auipc	a2,0x4
ffffffffc0201298:	16c60613          	addi	a2,a2,364 # ffffffffc0205400 <commands+0x738>
ffffffffc020129c:	12600593          	li	a1,294
ffffffffc02012a0:	00004517          	auipc	a0,0x4
ffffffffc02012a4:	17850513          	addi	a0,a0,376 # ffffffffc0205418 <commands+0x750>
ffffffffc02012a8:	99eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02012ac:	00004697          	auipc	a3,0x4
ffffffffc02012b0:	18468693          	addi	a3,a3,388 # ffffffffc0205430 <commands+0x768>
ffffffffc02012b4:	00004617          	auipc	a2,0x4
ffffffffc02012b8:	14c60613          	addi	a2,a2,332 # ffffffffc0205400 <commands+0x738>
ffffffffc02012bc:	0f300593          	li	a1,243
ffffffffc02012c0:	00004517          	auipc	a0,0x4
ffffffffc02012c4:	15850513          	addi	a0,a0,344 # ffffffffc0205418 <commands+0x750>
ffffffffc02012c8:	97eff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02012cc:	00004697          	auipc	a3,0x4
ffffffffc02012d0:	1a468693          	addi	a3,a3,420 # ffffffffc0205470 <commands+0x7a8>
ffffffffc02012d4:	00004617          	auipc	a2,0x4
ffffffffc02012d8:	12c60613          	addi	a2,a2,300 # ffffffffc0205400 <commands+0x738>
ffffffffc02012dc:	0ba00593          	li	a1,186
ffffffffc02012e0:	00004517          	auipc	a0,0x4
ffffffffc02012e4:	13850513          	addi	a0,a0,312 # ffffffffc0205418 <commands+0x750>
ffffffffc02012e8:	95eff0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02012ec <default_free_pages>:
ffffffffc02012ec:	1141                	addi	sp,sp,-16
ffffffffc02012ee:	e406                	sd	ra,8(sp)
ffffffffc02012f0:	14058463          	beqz	a1,ffffffffc0201438 <default_free_pages+0x14c>
ffffffffc02012f4:	00659693          	slli	a3,a1,0x6
ffffffffc02012f8:	96aa                	add	a3,a3,a0
ffffffffc02012fa:	87aa                	mv	a5,a0
ffffffffc02012fc:	02d50263          	beq	a0,a3,ffffffffc0201320 <default_free_pages+0x34>
ffffffffc0201300:	6798                	ld	a4,8(a5)
ffffffffc0201302:	8b05                	andi	a4,a4,1
ffffffffc0201304:	10071a63          	bnez	a4,ffffffffc0201418 <default_free_pages+0x12c>
ffffffffc0201308:	6798                	ld	a4,8(a5)
ffffffffc020130a:	8b09                	andi	a4,a4,2
ffffffffc020130c:	10071663          	bnez	a4,ffffffffc0201418 <default_free_pages+0x12c>
ffffffffc0201310:	0007b423          	sd	zero,8(a5)
ffffffffc0201314:	0007a023          	sw	zero,0(a5)
ffffffffc0201318:	04078793          	addi	a5,a5,64
ffffffffc020131c:	fed792e3          	bne	a5,a3,ffffffffc0201300 <default_free_pages+0x14>
ffffffffc0201320:	2581                	sext.w	a1,a1
ffffffffc0201322:	c90c                	sw	a1,16(a0)
ffffffffc0201324:	00850893          	addi	a7,a0,8
ffffffffc0201328:	4789                	li	a5,2
ffffffffc020132a:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc020132e:	00010697          	auipc	a3,0x10
ffffffffc0201332:	12a68693          	addi	a3,a3,298 # ffffffffc0211458 <free_area>
ffffffffc0201336:	4a98                	lw	a4,16(a3)
ffffffffc0201338:	669c                	ld	a5,8(a3)
ffffffffc020133a:	01850613          	addi	a2,a0,24
ffffffffc020133e:	9db9                	addw	a1,a1,a4
ffffffffc0201340:	ca8c                	sw	a1,16(a3)
ffffffffc0201342:	0ad78463          	beq	a5,a3,ffffffffc02013ea <default_free_pages+0xfe>
ffffffffc0201346:	fe878713          	addi	a4,a5,-24
ffffffffc020134a:	0006b803          	ld	a6,0(a3)
ffffffffc020134e:	4581                	li	a1,0
ffffffffc0201350:	00e56a63          	bltu	a0,a4,ffffffffc0201364 <default_free_pages+0x78>
ffffffffc0201354:	6798                	ld	a4,8(a5)
ffffffffc0201356:	04d70c63          	beq	a4,a3,ffffffffc02013ae <default_free_pages+0xc2>
ffffffffc020135a:	87ba                	mv	a5,a4
ffffffffc020135c:	fe878713          	addi	a4,a5,-24
ffffffffc0201360:	fee57ae3          	bgeu	a0,a4,ffffffffc0201354 <default_free_pages+0x68>
ffffffffc0201364:	c199                	beqz	a1,ffffffffc020136a <default_free_pages+0x7e>
ffffffffc0201366:	0106b023          	sd	a6,0(a3)
ffffffffc020136a:	6398                	ld	a4,0(a5)
ffffffffc020136c:	e390                	sd	a2,0(a5)
ffffffffc020136e:	e710                	sd	a2,8(a4)
ffffffffc0201370:	f11c                	sd	a5,32(a0)
ffffffffc0201372:	ed18                	sd	a4,24(a0)
ffffffffc0201374:	00d70d63          	beq	a4,a3,ffffffffc020138e <default_free_pages+0xa2>
ffffffffc0201378:	ff872583          	lw	a1,-8(a4)
ffffffffc020137c:	fe870613          	addi	a2,a4,-24
ffffffffc0201380:	02059813          	slli	a6,a1,0x20
ffffffffc0201384:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201388:	97b2                	add	a5,a5,a2
ffffffffc020138a:	02f50c63          	beq	a0,a5,ffffffffc02013c2 <default_free_pages+0xd6>
ffffffffc020138e:	711c                	ld	a5,32(a0)
ffffffffc0201390:	00d78c63          	beq	a5,a3,ffffffffc02013a8 <default_free_pages+0xbc>
ffffffffc0201394:	4910                	lw	a2,16(a0)
ffffffffc0201396:	fe878693          	addi	a3,a5,-24
ffffffffc020139a:	02061593          	slli	a1,a2,0x20
ffffffffc020139e:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02013a2:	972a                	add	a4,a4,a0
ffffffffc02013a4:	04e68a63          	beq	a3,a4,ffffffffc02013f8 <default_free_pages+0x10c>
ffffffffc02013a8:	60a2                	ld	ra,8(sp)
ffffffffc02013aa:	0141                	addi	sp,sp,16
ffffffffc02013ac:	8082                	ret
ffffffffc02013ae:	e790                	sd	a2,8(a5)
ffffffffc02013b0:	f114                	sd	a3,32(a0)
ffffffffc02013b2:	6798                	ld	a4,8(a5)
ffffffffc02013b4:	ed1c                	sd	a5,24(a0)
ffffffffc02013b6:	02d70763          	beq	a4,a3,ffffffffc02013e4 <default_free_pages+0xf8>
ffffffffc02013ba:	8832                	mv	a6,a2
ffffffffc02013bc:	4585                	li	a1,1
ffffffffc02013be:	87ba                	mv	a5,a4
ffffffffc02013c0:	bf71                	j	ffffffffc020135c <default_free_pages+0x70>
ffffffffc02013c2:	491c                	lw	a5,16(a0)
ffffffffc02013c4:	9dbd                	addw	a1,a1,a5
ffffffffc02013c6:	feb72c23          	sw	a1,-8(a4)
ffffffffc02013ca:	57f5                	li	a5,-3
ffffffffc02013cc:	60f8b02f          	amoand.d	zero,a5,(a7)
ffffffffc02013d0:	01853803          	ld	a6,24(a0)
ffffffffc02013d4:	710c                	ld	a1,32(a0)
ffffffffc02013d6:	8532                	mv	a0,a2
ffffffffc02013d8:	00b83423          	sd	a1,8(a6)
ffffffffc02013dc:	671c                	ld	a5,8(a4)
ffffffffc02013de:	0105b023          	sd	a6,0(a1)
ffffffffc02013e2:	b77d                	j	ffffffffc0201390 <default_free_pages+0xa4>
ffffffffc02013e4:	e290                	sd	a2,0(a3)
ffffffffc02013e6:	873e                	mv	a4,a5
ffffffffc02013e8:	bf41                	j	ffffffffc0201378 <default_free_pages+0x8c>
ffffffffc02013ea:	60a2                	ld	ra,8(sp)
ffffffffc02013ec:	e390                	sd	a2,0(a5)
ffffffffc02013ee:	e790                	sd	a2,8(a5)
ffffffffc02013f0:	f11c                	sd	a5,32(a0)
ffffffffc02013f2:	ed1c                	sd	a5,24(a0)
ffffffffc02013f4:	0141                	addi	sp,sp,16
ffffffffc02013f6:	8082                	ret
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	ff078693          	addi	a3,a5,-16
ffffffffc0201400:	9e39                	addw	a2,a2,a4
ffffffffc0201402:	c910                	sw	a2,16(a0)
ffffffffc0201404:	5775                	li	a4,-3
ffffffffc0201406:	60e6b02f          	amoand.d	zero,a4,(a3)
ffffffffc020140a:	6398                	ld	a4,0(a5)
ffffffffc020140c:	679c                	ld	a5,8(a5)
ffffffffc020140e:	60a2                	ld	ra,8(sp)
ffffffffc0201410:	e71c                	sd	a5,8(a4)
ffffffffc0201412:	e398                	sd	a4,0(a5)
ffffffffc0201414:	0141                	addi	sp,sp,16
ffffffffc0201416:	8082                	ret
ffffffffc0201418:	00004697          	auipc	a3,0x4
ffffffffc020141c:	34868693          	addi	a3,a3,840 # ffffffffc0205760 <commands+0xa98>
ffffffffc0201420:	00004617          	auipc	a2,0x4
ffffffffc0201424:	fe060613          	addi	a2,a2,-32 # ffffffffc0205400 <commands+0x738>
ffffffffc0201428:	08300593          	li	a1,131
ffffffffc020142c:	00004517          	auipc	a0,0x4
ffffffffc0201430:	fec50513          	addi	a0,a0,-20 # ffffffffc0205418 <commands+0x750>
ffffffffc0201434:	812ff0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0201438:	00004697          	auipc	a3,0x4
ffffffffc020143c:	32068693          	addi	a3,a3,800 # ffffffffc0205758 <commands+0xa90>
ffffffffc0201440:	00004617          	auipc	a2,0x4
ffffffffc0201444:	fc060613          	addi	a2,a2,-64 # ffffffffc0205400 <commands+0x738>
ffffffffc0201448:	08000593          	li	a1,128
ffffffffc020144c:	00004517          	auipc	a0,0x4
ffffffffc0201450:	fcc50513          	addi	a0,a0,-52 # ffffffffc0205418 <commands+0x750>
ffffffffc0201454:	ff3fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201458 <default_alloc_pages>:
ffffffffc0201458:	c941                	beqz	a0,ffffffffc02014e8 <default_alloc_pages+0x90>
ffffffffc020145a:	00010597          	auipc	a1,0x10
ffffffffc020145e:	ffe58593          	addi	a1,a1,-2 # ffffffffc0211458 <free_area>
ffffffffc0201462:	0105a803          	lw	a6,16(a1)
ffffffffc0201466:	872a                	mv	a4,a0
ffffffffc0201468:	02081793          	slli	a5,a6,0x20
ffffffffc020146c:	9381                	srli	a5,a5,0x20
ffffffffc020146e:	00a7ee63          	bltu	a5,a0,ffffffffc020148a <default_alloc_pages+0x32>
ffffffffc0201472:	87ae                	mv	a5,a1
ffffffffc0201474:	a801                	j	ffffffffc0201484 <default_alloc_pages+0x2c>
ffffffffc0201476:	ff87a683          	lw	a3,-8(a5)
ffffffffc020147a:	02069613          	slli	a2,a3,0x20
ffffffffc020147e:	9201                	srli	a2,a2,0x20
ffffffffc0201480:	00e67763          	bgeu	a2,a4,ffffffffc020148e <default_alloc_pages+0x36>
ffffffffc0201484:	679c                	ld	a5,8(a5)
ffffffffc0201486:	feb798e3          	bne	a5,a1,ffffffffc0201476 <default_alloc_pages+0x1e>
ffffffffc020148a:	4501                	li	a0,0
ffffffffc020148c:	8082                	ret
ffffffffc020148e:	0007b883          	ld	a7,0(a5)
ffffffffc0201492:	0087b303          	ld	t1,8(a5)
ffffffffc0201496:	fe878513          	addi	a0,a5,-24
ffffffffc020149a:	00070e1b          	sext.w	t3,a4
ffffffffc020149e:	0068b423          	sd	t1,8(a7)
ffffffffc02014a2:	01133023          	sd	a7,0(t1)
ffffffffc02014a6:	02c77863          	bgeu	a4,a2,ffffffffc02014d6 <default_alloc_pages+0x7e>
ffffffffc02014aa:	071a                	slli	a4,a4,0x6
ffffffffc02014ac:	972a                	add	a4,a4,a0
ffffffffc02014ae:	41c686bb          	subw	a3,a3,t3
ffffffffc02014b2:	cb14                	sw	a3,16(a4)
ffffffffc02014b4:	00870613          	addi	a2,a4,8
ffffffffc02014b8:	4689                	li	a3,2
ffffffffc02014ba:	40d6302f          	amoor.d	zero,a3,(a2)
ffffffffc02014be:	0088b683          	ld	a3,8(a7)
ffffffffc02014c2:	01870613          	addi	a2,a4,24
ffffffffc02014c6:	0105a803          	lw	a6,16(a1)
ffffffffc02014ca:	e290                	sd	a2,0(a3)
ffffffffc02014cc:	00c8b423          	sd	a2,8(a7)
ffffffffc02014d0:	f314                	sd	a3,32(a4)
ffffffffc02014d2:	01173c23          	sd	a7,24(a4)
ffffffffc02014d6:	41c8083b          	subw	a6,a6,t3
ffffffffc02014da:	0105a823          	sw	a6,16(a1)
ffffffffc02014de:	5775                	li	a4,-3
ffffffffc02014e0:	17c1                	addi	a5,a5,-16
ffffffffc02014e2:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02014e6:	8082                	ret
ffffffffc02014e8:	1141                	addi	sp,sp,-16
ffffffffc02014ea:	00004697          	auipc	a3,0x4
ffffffffc02014ee:	26e68693          	addi	a3,a3,622 # ffffffffc0205758 <commands+0xa90>
ffffffffc02014f2:	00004617          	auipc	a2,0x4
ffffffffc02014f6:	f0e60613          	addi	a2,a2,-242 # ffffffffc0205400 <commands+0x738>
ffffffffc02014fa:	06200593          	li	a1,98
ffffffffc02014fe:	00004517          	auipc	a0,0x4
ffffffffc0201502:	f1a50513          	addi	a0,a0,-230 # ffffffffc0205418 <commands+0x750>
ffffffffc0201506:	e406                	sd	ra,8(sp)
ffffffffc0201508:	f3ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020150c <default_init_memmap>:
ffffffffc020150c:	1141                	addi	sp,sp,-16
ffffffffc020150e:	e406                	sd	ra,8(sp)
ffffffffc0201510:	c5f1                	beqz	a1,ffffffffc02015dc <default_init_memmap+0xd0>
ffffffffc0201512:	00659693          	slli	a3,a1,0x6
ffffffffc0201516:	96aa                	add	a3,a3,a0
ffffffffc0201518:	87aa                	mv	a5,a0
ffffffffc020151a:	00d50f63          	beq	a0,a3,ffffffffc0201538 <default_init_memmap+0x2c>
ffffffffc020151e:	6798                	ld	a4,8(a5)
ffffffffc0201520:	8b05                	andi	a4,a4,1
ffffffffc0201522:	cf49                	beqz	a4,ffffffffc02015bc <default_init_memmap+0xb0>
ffffffffc0201524:	0007a823          	sw	zero,16(a5)
ffffffffc0201528:	0007b423          	sd	zero,8(a5)
ffffffffc020152c:	0007a023          	sw	zero,0(a5)
ffffffffc0201530:	04078793          	addi	a5,a5,64
ffffffffc0201534:	fed795e3          	bne	a5,a3,ffffffffc020151e <default_init_memmap+0x12>
ffffffffc0201538:	2581                	sext.w	a1,a1
ffffffffc020153a:	c90c                	sw	a1,16(a0)
ffffffffc020153c:	4789                	li	a5,2
ffffffffc020153e:	00850713          	addi	a4,a0,8
ffffffffc0201542:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0201546:	00010697          	auipc	a3,0x10
ffffffffc020154a:	f1268693          	addi	a3,a3,-238 # ffffffffc0211458 <free_area>
ffffffffc020154e:	4a98                	lw	a4,16(a3)
ffffffffc0201550:	669c                	ld	a5,8(a3)
ffffffffc0201552:	01850613          	addi	a2,a0,24
ffffffffc0201556:	9db9                	addw	a1,a1,a4
ffffffffc0201558:	ca8c                	sw	a1,16(a3)
ffffffffc020155a:	04d78a63          	beq	a5,a3,ffffffffc02015ae <default_init_memmap+0xa2>
ffffffffc020155e:	fe878713          	addi	a4,a5,-24
ffffffffc0201562:	0006b803          	ld	a6,0(a3)
ffffffffc0201566:	4581                	li	a1,0
ffffffffc0201568:	00e56a63          	bltu	a0,a4,ffffffffc020157c <default_init_memmap+0x70>
ffffffffc020156c:	6798                	ld	a4,8(a5)
ffffffffc020156e:	02d70263          	beq	a4,a3,ffffffffc0201592 <default_init_memmap+0x86>
ffffffffc0201572:	87ba                	mv	a5,a4
ffffffffc0201574:	fe878713          	addi	a4,a5,-24
ffffffffc0201578:	fee57ae3          	bgeu	a0,a4,ffffffffc020156c <default_init_memmap+0x60>
ffffffffc020157c:	c199                	beqz	a1,ffffffffc0201582 <default_init_memmap+0x76>
ffffffffc020157e:	0106b023          	sd	a6,0(a3)
ffffffffc0201582:	6398                	ld	a4,0(a5)
ffffffffc0201584:	60a2                	ld	ra,8(sp)
ffffffffc0201586:	e390                	sd	a2,0(a5)
ffffffffc0201588:	e710                	sd	a2,8(a4)
ffffffffc020158a:	f11c                	sd	a5,32(a0)
ffffffffc020158c:	ed18                	sd	a4,24(a0)
ffffffffc020158e:	0141                	addi	sp,sp,16
ffffffffc0201590:	8082                	ret
ffffffffc0201592:	e790                	sd	a2,8(a5)
ffffffffc0201594:	f114                	sd	a3,32(a0)
ffffffffc0201596:	6798                	ld	a4,8(a5)
ffffffffc0201598:	ed1c                	sd	a5,24(a0)
ffffffffc020159a:	00d70663          	beq	a4,a3,ffffffffc02015a6 <default_init_memmap+0x9a>
ffffffffc020159e:	8832                	mv	a6,a2
ffffffffc02015a0:	4585                	li	a1,1
ffffffffc02015a2:	87ba                	mv	a5,a4
ffffffffc02015a4:	bfc1                	j	ffffffffc0201574 <default_init_memmap+0x68>
ffffffffc02015a6:	60a2                	ld	ra,8(sp)
ffffffffc02015a8:	e290                	sd	a2,0(a3)
ffffffffc02015aa:	0141                	addi	sp,sp,16
ffffffffc02015ac:	8082                	ret
ffffffffc02015ae:	60a2                	ld	ra,8(sp)
ffffffffc02015b0:	e390                	sd	a2,0(a5)
ffffffffc02015b2:	e790                	sd	a2,8(a5)
ffffffffc02015b4:	f11c                	sd	a5,32(a0)
ffffffffc02015b6:	ed1c                	sd	a5,24(a0)
ffffffffc02015b8:	0141                	addi	sp,sp,16
ffffffffc02015ba:	8082                	ret
ffffffffc02015bc:	00004697          	auipc	a3,0x4
ffffffffc02015c0:	1cc68693          	addi	a3,a3,460 # ffffffffc0205788 <commands+0xac0>
ffffffffc02015c4:	00004617          	auipc	a2,0x4
ffffffffc02015c8:	e3c60613          	addi	a2,a2,-452 # ffffffffc0205400 <commands+0x738>
ffffffffc02015cc:	04900593          	li	a1,73
ffffffffc02015d0:	00004517          	auipc	a0,0x4
ffffffffc02015d4:	e4850513          	addi	a0,a0,-440 # ffffffffc0205418 <commands+0x750>
ffffffffc02015d8:	e6ffe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02015dc:	00004697          	auipc	a3,0x4
ffffffffc02015e0:	17c68693          	addi	a3,a3,380 # ffffffffc0205758 <commands+0xa90>
ffffffffc02015e4:	00004617          	auipc	a2,0x4
ffffffffc02015e8:	e1c60613          	addi	a2,a2,-484 # ffffffffc0205400 <commands+0x738>
ffffffffc02015ec:	04600593          	li	a1,70
ffffffffc02015f0:	00004517          	auipc	a0,0x4
ffffffffc02015f4:	e2850513          	addi	a0,a0,-472 # ffffffffc0205418 <commands+0x750>
ffffffffc02015f8:	e4ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02015fc <slob_free>:
ffffffffc02015fc:	c94d                	beqz	a0,ffffffffc02016ae <slob_free+0xb2>
ffffffffc02015fe:	1141                	addi	sp,sp,-16
ffffffffc0201600:	e022                	sd	s0,0(sp)
ffffffffc0201602:	e406                	sd	ra,8(sp)
ffffffffc0201604:	842a                	mv	s0,a0
ffffffffc0201606:	e9c1                	bnez	a1,ffffffffc0201696 <slob_free+0x9a>
ffffffffc0201608:	100027f3          	csrr	a5,sstatus
ffffffffc020160c:	8b89                	andi	a5,a5,2
ffffffffc020160e:	4501                	li	a0,0
ffffffffc0201610:	ebd9                	bnez	a5,ffffffffc02016a6 <slob_free+0xaa>
ffffffffc0201612:	00009617          	auipc	a2,0x9
ffffffffc0201616:	a3e60613          	addi	a2,a2,-1474 # ffffffffc020a050 <slobfree>
ffffffffc020161a:	621c                	ld	a5,0(a2)
ffffffffc020161c:	873e                	mv	a4,a5
ffffffffc020161e:	679c                	ld	a5,8(a5)
ffffffffc0201620:	02877a63          	bgeu	a4,s0,ffffffffc0201654 <slob_free+0x58>
ffffffffc0201624:	00f46463          	bltu	s0,a5,ffffffffc020162c <slob_free+0x30>
ffffffffc0201628:	fef76ae3          	bltu	a4,a5,ffffffffc020161c <slob_free+0x20>
ffffffffc020162c:	400c                	lw	a1,0(s0)
ffffffffc020162e:	00459693          	slli	a3,a1,0x4
ffffffffc0201632:	96a2                	add	a3,a3,s0
ffffffffc0201634:	02d78a63          	beq	a5,a3,ffffffffc0201668 <slob_free+0x6c>
ffffffffc0201638:	4314                	lw	a3,0(a4)
ffffffffc020163a:	e41c                	sd	a5,8(s0)
ffffffffc020163c:	00469793          	slli	a5,a3,0x4
ffffffffc0201640:	97ba                	add	a5,a5,a4
ffffffffc0201642:	02f40e63          	beq	s0,a5,ffffffffc020167e <slob_free+0x82>
ffffffffc0201646:	e700                	sd	s0,8(a4)
ffffffffc0201648:	e218                	sd	a4,0(a2)
ffffffffc020164a:	e129                	bnez	a0,ffffffffc020168c <slob_free+0x90>
ffffffffc020164c:	60a2                	ld	ra,8(sp)
ffffffffc020164e:	6402                	ld	s0,0(sp)
ffffffffc0201650:	0141                	addi	sp,sp,16
ffffffffc0201652:	8082                	ret
ffffffffc0201654:	fcf764e3          	bltu	a4,a5,ffffffffc020161c <slob_free+0x20>
ffffffffc0201658:	fcf472e3          	bgeu	s0,a5,ffffffffc020161c <slob_free+0x20>
ffffffffc020165c:	400c                	lw	a1,0(s0)
ffffffffc020165e:	00459693          	slli	a3,a1,0x4
ffffffffc0201662:	96a2                	add	a3,a3,s0
ffffffffc0201664:	fcd79ae3          	bne	a5,a3,ffffffffc0201638 <slob_free+0x3c>
ffffffffc0201668:	4394                	lw	a3,0(a5)
ffffffffc020166a:	679c                	ld	a5,8(a5)
ffffffffc020166c:	9db5                	addw	a1,a1,a3
ffffffffc020166e:	c00c                	sw	a1,0(s0)
ffffffffc0201670:	4314                	lw	a3,0(a4)
ffffffffc0201672:	e41c                	sd	a5,8(s0)
ffffffffc0201674:	00469793          	slli	a5,a3,0x4
ffffffffc0201678:	97ba                	add	a5,a5,a4
ffffffffc020167a:	fcf416e3          	bne	s0,a5,ffffffffc0201646 <slob_free+0x4a>
ffffffffc020167e:	401c                	lw	a5,0(s0)
ffffffffc0201680:	640c                	ld	a1,8(s0)
ffffffffc0201682:	e218                	sd	a4,0(a2)
ffffffffc0201684:	9ebd                	addw	a3,a3,a5
ffffffffc0201686:	c314                	sw	a3,0(a4)
ffffffffc0201688:	e70c                	sd	a1,8(a4)
ffffffffc020168a:	d169                	beqz	a0,ffffffffc020164c <slob_free+0x50>
ffffffffc020168c:	6402                	ld	s0,0(sp)
ffffffffc020168e:	60a2                	ld	ra,8(sp)
ffffffffc0201690:	0141                	addi	sp,sp,16
ffffffffc0201692:	f07fe06f          	j	ffffffffc0200598 <intr_enable>
ffffffffc0201696:	25bd                	addiw	a1,a1,15
ffffffffc0201698:	8191                	srli	a1,a1,0x4
ffffffffc020169a:	c10c                	sw	a1,0(a0)
ffffffffc020169c:	100027f3          	csrr	a5,sstatus
ffffffffc02016a0:	8b89                	andi	a5,a5,2
ffffffffc02016a2:	4501                	li	a0,0
ffffffffc02016a4:	d7bd                	beqz	a5,ffffffffc0201612 <slob_free+0x16>
ffffffffc02016a6:	ef9fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02016aa:	4505                	li	a0,1
ffffffffc02016ac:	b79d                	j	ffffffffc0201612 <slob_free+0x16>
ffffffffc02016ae:	8082                	ret

ffffffffc02016b0 <__slob_get_free_pages.constprop.0>:
ffffffffc02016b0:	4785                	li	a5,1
ffffffffc02016b2:	1141                	addi	sp,sp,-16
ffffffffc02016b4:	00a7953b          	sllw	a0,a5,a0
ffffffffc02016b8:	e406                	sd	ra,8(sp)
ffffffffc02016ba:	34e000ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc02016be:	c91d                	beqz	a0,ffffffffc02016f4 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc02016c0:	00014697          	auipc	a3,0x14
ffffffffc02016c4:	ea86b683          	ld	a3,-344(a3) # ffffffffc0215568 <pages>
ffffffffc02016c8:	8d15                	sub	a0,a0,a3
ffffffffc02016ca:	8519                	srai	a0,a0,0x6
ffffffffc02016cc:	00005697          	auipc	a3,0x5
ffffffffc02016d0:	3b46b683          	ld	a3,948(a3) # ffffffffc0206a80 <nbase>
ffffffffc02016d4:	9536                	add	a0,a0,a3
ffffffffc02016d6:	00c51793          	slli	a5,a0,0xc
ffffffffc02016da:	83b1                	srli	a5,a5,0xc
ffffffffc02016dc:	00014717          	auipc	a4,0x14
ffffffffc02016e0:	e8473703          	ld	a4,-380(a4) # ffffffffc0215560 <npage>
ffffffffc02016e4:	0532                	slli	a0,a0,0xc
ffffffffc02016e6:	00e7fa63          	bgeu	a5,a4,ffffffffc02016fa <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02016ea:	00014697          	auipc	a3,0x14
ffffffffc02016ee:	e8e6b683          	ld	a3,-370(a3) # ffffffffc0215578 <va_pa_offset>
ffffffffc02016f2:	9536                	add	a0,a0,a3
ffffffffc02016f4:	60a2                	ld	ra,8(sp)
ffffffffc02016f6:	0141                	addi	sp,sp,16
ffffffffc02016f8:	8082                	ret
ffffffffc02016fa:	86aa                	mv	a3,a0
ffffffffc02016fc:	00004617          	auipc	a2,0x4
ffffffffc0201700:	0ec60613          	addi	a2,a2,236 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0201704:	06900593          	li	a1,105
ffffffffc0201708:	00004517          	auipc	a0,0x4
ffffffffc020170c:	10850513          	addi	a0,a0,264 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0201710:	d37fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201714 <slob_alloc.constprop.0>:
ffffffffc0201714:	1101                	addi	sp,sp,-32
ffffffffc0201716:	ec06                	sd	ra,24(sp)
ffffffffc0201718:	e822                	sd	s0,16(sp)
ffffffffc020171a:	e426                	sd	s1,8(sp)
ffffffffc020171c:	e04a                	sd	s2,0(sp)
ffffffffc020171e:	01050713          	addi	a4,a0,16
ffffffffc0201722:	6785                	lui	a5,0x1
ffffffffc0201724:	0cf77363          	bgeu	a4,a5,ffffffffc02017ea <slob_alloc.constprop.0+0xd6>
ffffffffc0201728:	00f50493          	addi	s1,a0,15
ffffffffc020172c:	8091                	srli	s1,s1,0x4
ffffffffc020172e:	2481                	sext.w	s1,s1
ffffffffc0201730:	10002673          	csrr	a2,sstatus
ffffffffc0201734:	8a09                	andi	a2,a2,2
ffffffffc0201736:	e25d                	bnez	a2,ffffffffc02017dc <slob_alloc.constprop.0+0xc8>
ffffffffc0201738:	00009917          	auipc	s2,0x9
ffffffffc020173c:	91890913          	addi	s2,s2,-1768 # ffffffffc020a050 <slobfree>
ffffffffc0201740:	00093683          	ld	a3,0(s2)
ffffffffc0201744:	669c                	ld	a5,8(a3)
ffffffffc0201746:	4398                	lw	a4,0(a5)
ffffffffc0201748:	08975e63          	bge	a4,s1,ffffffffc02017e4 <slob_alloc.constprop.0+0xd0>
ffffffffc020174c:	00d78b63          	beq	a5,a3,ffffffffc0201762 <slob_alloc.constprop.0+0x4e>
ffffffffc0201750:	6780                	ld	s0,8(a5)
ffffffffc0201752:	4018                	lw	a4,0(s0)
ffffffffc0201754:	02975a63          	bge	a4,s1,ffffffffc0201788 <slob_alloc.constprop.0+0x74>
ffffffffc0201758:	00093683          	ld	a3,0(s2)
ffffffffc020175c:	87a2                	mv	a5,s0
ffffffffc020175e:	fed799e3          	bne	a5,a3,ffffffffc0201750 <slob_alloc.constprop.0+0x3c>
ffffffffc0201762:	ee31                	bnez	a2,ffffffffc02017be <slob_alloc.constprop.0+0xaa>
ffffffffc0201764:	4501                	li	a0,0
ffffffffc0201766:	f4bff0ef          	jal	ra,ffffffffc02016b0 <__slob_get_free_pages.constprop.0>
ffffffffc020176a:	842a                	mv	s0,a0
ffffffffc020176c:	cd05                	beqz	a0,ffffffffc02017a4 <slob_alloc.constprop.0+0x90>
ffffffffc020176e:	6585                	lui	a1,0x1
ffffffffc0201770:	e8dff0ef          	jal	ra,ffffffffc02015fc <slob_free>
ffffffffc0201774:	10002673          	csrr	a2,sstatus
ffffffffc0201778:	8a09                	andi	a2,a2,2
ffffffffc020177a:	ee05                	bnez	a2,ffffffffc02017b2 <slob_alloc.constprop.0+0x9e>
ffffffffc020177c:	00093783          	ld	a5,0(s2)
ffffffffc0201780:	6780                	ld	s0,8(a5)
ffffffffc0201782:	4018                	lw	a4,0(s0)
ffffffffc0201784:	fc974ae3          	blt	a4,s1,ffffffffc0201758 <slob_alloc.constprop.0+0x44>
ffffffffc0201788:	04e48763          	beq	s1,a4,ffffffffc02017d6 <slob_alloc.constprop.0+0xc2>
ffffffffc020178c:	00449693          	slli	a3,s1,0x4
ffffffffc0201790:	96a2                	add	a3,a3,s0
ffffffffc0201792:	e794                	sd	a3,8(a5)
ffffffffc0201794:	640c                	ld	a1,8(s0)
ffffffffc0201796:	9f05                	subw	a4,a4,s1
ffffffffc0201798:	c298                	sw	a4,0(a3)
ffffffffc020179a:	e68c                	sd	a1,8(a3)
ffffffffc020179c:	c004                	sw	s1,0(s0)
ffffffffc020179e:	00f93023          	sd	a5,0(s2)
ffffffffc02017a2:	e20d                	bnez	a2,ffffffffc02017c4 <slob_alloc.constprop.0+0xb0>
ffffffffc02017a4:	60e2                	ld	ra,24(sp)
ffffffffc02017a6:	8522                	mv	a0,s0
ffffffffc02017a8:	6442                	ld	s0,16(sp)
ffffffffc02017aa:	64a2                	ld	s1,8(sp)
ffffffffc02017ac:	6902                	ld	s2,0(sp)
ffffffffc02017ae:	6105                	addi	sp,sp,32
ffffffffc02017b0:	8082                	ret
ffffffffc02017b2:	dedfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02017b6:	00093783          	ld	a5,0(s2)
ffffffffc02017ba:	4605                	li	a2,1
ffffffffc02017bc:	b7d1                	j	ffffffffc0201780 <slob_alloc.constprop.0+0x6c>
ffffffffc02017be:	ddbfe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02017c2:	b74d                	j	ffffffffc0201764 <slob_alloc.constprop.0+0x50>
ffffffffc02017c4:	dd5fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02017c8:	60e2                	ld	ra,24(sp)
ffffffffc02017ca:	8522                	mv	a0,s0
ffffffffc02017cc:	6442                	ld	s0,16(sp)
ffffffffc02017ce:	64a2                	ld	s1,8(sp)
ffffffffc02017d0:	6902                	ld	s2,0(sp)
ffffffffc02017d2:	6105                	addi	sp,sp,32
ffffffffc02017d4:	8082                	ret
ffffffffc02017d6:	6418                	ld	a4,8(s0)
ffffffffc02017d8:	e798                	sd	a4,8(a5)
ffffffffc02017da:	b7d1                	j	ffffffffc020179e <slob_alloc.constprop.0+0x8a>
ffffffffc02017dc:	dc3fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02017e0:	4605                	li	a2,1
ffffffffc02017e2:	bf99                	j	ffffffffc0201738 <slob_alloc.constprop.0+0x24>
ffffffffc02017e4:	843e                	mv	s0,a5
ffffffffc02017e6:	87b6                	mv	a5,a3
ffffffffc02017e8:	b745                	j	ffffffffc0201788 <slob_alloc.constprop.0+0x74>
ffffffffc02017ea:	00004697          	auipc	a3,0x4
ffffffffc02017ee:	03668693          	addi	a3,a3,54 # ffffffffc0205820 <default_pmm_manager+0x70>
ffffffffc02017f2:	00004617          	auipc	a2,0x4
ffffffffc02017f6:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0205400 <commands+0x738>
ffffffffc02017fa:	06300593          	li	a1,99
ffffffffc02017fe:	00004517          	auipc	a0,0x4
ffffffffc0201802:	04250513          	addi	a0,a0,66 # ffffffffc0205840 <default_pmm_manager+0x90>
ffffffffc0201806:	c41fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020180a <kmalloc_init>:
ffffffffc020180a:	1141                	addi	sp,sp,-16
ffffffffc020180c:	00004517          	auipc	a0,0x4
ffffffffc0201810:	04c50513          	addi	a0,a0,76 # ffffffffc0205858 <default_pmm_manager+0xa8>
ffffffffc0201814:	e406                	sd	ra,8(sp)
ffffffffc0201816:	96bfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020181a:	60a2                	ld	ra,8(sp)
ffffffffc020181c:	00004517          	auipc	a0,0x4
ffffffffc0201820:	05450513          	addi	a0,a0,84 # ffffffffc0205870 <default_pmm_manager+0xc0>
ffffffffc0201824:	0141                	addi	sp,sp,16
ffffffffc0201826:	95bfe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc020182a <kmalloc>:
ffffffffc020182a:	1101                	addi	sp,sp,-32
ffffffffc020182c:	e04a                	sd	s2,0(sp)
ffffffffc020182e:	6905                	lui	s2,0x1
ffffffffc0201830:	e822                	sd	s0,16(sp)
ffffffffc0201832:	ec06                	sd	ra,24(sp)
ffffffffc0201834:	e426                	sd	s1,8(sp)
ffffffffc0201836:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
ffffffffc020183a:	842a                	mv	s0,a0
ffffffffc020183c:	04a7f963          	bgeu	a5,a0,ffffffffc020188e <kmalloc+0x64>
ffffffffc0201840:	4561                	li	a0,24
ffffffffc0201842:	ed3ff0ef          	jal	ra,ffffffffc0201714 <slob_alloc.constprop.0>
ffffffffc0201846:	84aa                	mv	s1,a0
ffffffffc0201848:	c929                	beqz	a0,ffffffffc020189a <kmalloc+0x70>
ffffffffc020184a:	0004079b          	sext.w	a5,s0
ffffffffc020184e:	4501                	li	a0,0
ffffffffc0201850:	00f95763          	bge	s2,a5,ffffffffc020185e <kmalloc+0x34>
ffffffffc0201854:	6705                	lui	a4,0x1
ffffffffc0201856:	8785                	srai	a5,a5,0x1
ffffffffc0201858:	2505                	addiw	a0,a0,1
ffffffffc020185a:	fef74ee3          	blt	a4,a5,ffffffffc0201856 <kmalloc+0x2c>
ffffffffc020185e:	c088                	sw	a0,0(s1)
ffffffffc0201860:	e51ff0ef          	jal	ra,ffffffffc02016b0 <__slob_get_free_pages.constprop.0>
ffffffffc0201864:	e488                	sd	a0,8(s1)
ffffffffc0201866:	842a                	mv	s0,a0
ffffffffc0201868:	c525                	beqz	a0,ffffffffc02018d0 <kmalloc+0xa6>
ffffffffc020186a:	100027f3          	csrr	a5,sstatus
ffffffffc020186e:	8b89                	andi	a5,a5,2
ffffffffc0201870:	ef8d                	bnez	a5,ffffffffc02018aa <kmalloc+0x80>
ffffffffc0201872:	00014797          	auipc	a5,0x14
ffffffffc0201876:	cd678793          	addi	a5,a5,-810 # ffffffffc0215548 <bigblocks>
ffffffffc020187a:	6398                	ld	a4,0(a5)
ffffffffc020187c:	e384                	sd	s1,0(a5)
ffffffffc020187e:	e898                	sd	a4,16(s1)
ffffffffc0201880:	60e2                	ld	ra,24(sp)
ffffffffc0201882:	8522                	mv	a0,s0
ffffffffc0201884:	6442                	ld	s0,16(sp)
ffffffffc0201886:	64a2                	ld	s1,8(sp)
ffffffffc0201888:	6902                	ld	s2,0(sp)
ffffffffc020188a:	6105                	addi	sp,sp,32
ffffffffc020188c:	8082                	ret
ffffffffc020188e:	0541                	addi	a0,a0,16
ffffffffc0201890:	e85ff0ef          	jal	ra,ffffffffc0201714 <slob_alloc.constprop.0>
ffffffffc0201894:	01050413          	addi	s0,a0,16
ffffffffc0201898:	f565                	bnez	a0,ffffffffc0201880 <kmalloc+0x56>
ffffffffc020189a:	4401                	li	s0,0
ffffffffc020189c:	60e2                	ld	ra,24(sp)
ffffffffc020189e:	8522                	mv	a0,s0
ffffffffc02018a0:	6442                	ld	s0,16(sp)
ffffffffc02018a2:	64a2                	ld	s1,8(sp)
ffffffffc02018a4:	6902                	ld	s2,0(sp)
ffffffffc02018a6:	6105                	addi	sp,sp,32
ffffffffc02018a8:	8082                	ret
ffffffffc02018aa:	cf5fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02018ae:	00014797          	auipc	a5,0x14
ffffffffc02018b2:	c9a78793          	addi	a5,a5,-870 # ffffffffc0215548 <bigblocks>
ffffffffc02018b6:	6398                	ld	a4,0(a5)
ffffffffc02018b8:	e384                	sd	s1,0(a5)
ffffffffc02018ba:	e898                	sd	a4,16(s1)
ffffffffc02018bc:	cddfe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02018c0:	6480                	ld	s0,8(s1)
ffffffffc02018c2:	60e2                	ld	ra,24(sp)
ffffffffc02018c4:	64a2                	ld	s1,8(sp)
ffffffffc02018c6:	8522                	mv	a0,s0
ffffffffc02018c8:	6442                	ld	s0,16(sp)
ffffffffc02018ca:	6902                	ld	s2,0(sp)
ffffffffc02018cc:	6105                	addi	sp,sp,32
ffffffffc02018ce:	8082                	ret
ffffffffc02018d0:	45e1                	li	a1,24
ffffffffc02018d2:	8526                	mv	a0,s1
ffffffffc02018d4:	d29ff0ef          	jal	ra,ffffffffc02015fc <slob_free>
ffffffffc02018d8:	b765                	j	ffffffffc0201880 <kmalloc+0x56>

ffffffffc02018da <kfree>:
ffffffffc02018da:	c169                	beqz	a0,ffffffffc020199c <kfree+0xc2>
ffffffffc02018dc:	1101                	addi	sp,sp,-32
ffffffffc02018de:	e822                	sd	s0,16(sp)
ffffffffc02018e0:	ec06                	sd	ra,24(sp)
ffffffffc02018e2:	e426                	sd	s1,8(sp)
ffffffffc02018e4:	03451793          	slli	a5,a0,0x34
ffffffffc02018e8:	842a                	mv	s0,a0
ffffffffc02018ea:	e3d9                	bnez	a5,ffffffffc0201970 <kfree+0x96>
ffffffffc02018ec:	100027f3          	csrr	a5,sstatus
ffffffffc02018f0:	8b89                	andi	a5,a5,2
ffffffffc02018f2:	e7d9                	bnez	a5,ffffffffc0201980 <kfree+0xa6>
ffffffffc02018f4:	00014797          	auipc	a5,0x14
ffffffffc02018f8:	c547b783          	ld	a5,-940(a5) # ffffffffc0215548 <bigblocks>
ffffffffc02018fc:	4601                	li	a2,0
ffffffffc02018fe:	cbad                	beqz	a5,ffffffffc0201970 <kfree+0x96>
ffffffffc0201900:	00014697          	auipc	a3,0x14
ffffffffc0201904:	c4868693          	addi	a3,a3,-952 # ffffffffc0215548 <bigblocks>
ffffffffc0201908:	a021                	j	ffffffffc0201910 <kfree+0x36>
ffffffffc020190a:	01048693          	addi	a3,s1,16
ffffffffc020190e:	c3a5                	beqz	a5,ffffffffc020196e <kfree+0x94>
ffffffffc0201910:	6798                	ld	a4,8(a5)
ffffffffc0201912:	84be                	mv	s1,a5
ffffffffc0201914:	6b9c                	ld	a5,16(a5)
ffffffffc0201916:	fe871ae3          	bne	a4,s0,ffffffffc020190a <kfree+0x30>
ffffffffc020191a:	e29c                	sd	a5,0(a3)
ffffffffc020191c:	ee2d                	bnez	a2,ffffffffc0201996 <kfree+0xbc>
ffffffffc020191e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201922:	4098                	lw	a4,0(s1)
ffffffffc0201924:	08f46963          	bltu	s0,a5,ffffffffc02019b6 <kfree+0xdc>
ffffffffc0201928:	00014697          	auipc	a3,0x14
ffffffffc020192c:	c506b683          	ld	a3,-944(a3) # ffffffffc0215578 <va_pa_offset>
ffffffffc0201930:	8c15                	sub	s0,s0,a3
ffffffffc0201932:	8031                	srli	s0,s0,0xc
ffffffffc0201934:	00014797          	auipc	a5,0x14
ffffffffc0201938:	c2c7b783          	ld	a5,-980(a5) # ffffffffc0215560 <npage>
ffffffffc020193c:	06f47163          	bgeu	s0,a5,ffffffffc020199e <kfree+0xc4>
ffffffffc0201940:	00005517          	auipc	a0,0x5
ffffffffc0201944:	14053503          	ld	a0,320(a0) # ffffffffc0206a80 <nbase>
ffffffffc0201948:	8c09                	sub	s0,s0,a0
ffffffffc020194a:	041a                	slli	s0,s0,0x6
ffffffffc020194c:	00014517          	auipc	a0,0x14
ffffffffc0201950:	c1c53503          	ld	a0,-996(a0) # ffffffffc0215568 <pages>
ffffffffc0201954:	4585                	li	a1,1
ffffffffc0201956:	9522                	add	a0,a0,s0
ffffffffc0201958:	00e595bb          	sllw	a1,a1,a4
ffffffffc020195c:	13e000ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0201960:	6442                	ld	s0,16(sp)
ffffffffc0201962:	60e2                	ld	ra,24(sp)
ffffffffc0201964:	8526                	mv	a0,s1
ffffffffc0201966:	64a2                	ld	s1,8(sp)
ffffffffc0201968:	45e1                	li	a1,24
ffffffffc020196a:	6105                	addi	sp,sp,32
ffffffffc020196c:	b941                	j	ffffffffc02015fc <slob_free>
ffffffffc020196e:	e20d                	bnez	a2,ffffffffc0201990 <kfree+0xb6>
ffffffffc0201970:	ff040513          	addi	a0,s0,-16
ffffffffc0201974:	6442                	ld	s0,16(sp)
ffffffffc0201976:	60e2                	ld	ra,24(sp)
ffffffffc0201978:	64a2                	ld	s1,8(sp)
ffffffffc020197a:	4581                	li	a1,0
ffffffffc020197c:	6105                	addi	sp,sp,32
ffffffffc020197e:	b9bd                	j	ffffffffc02015fc <slob_free>
ffffffffc0201980:	c1ffe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201984:	00014797          	auipc	a5,0x14
ffffffffc0201988:	bc47b783          	ld	a5,-1084(a5) # ffffffffc0215548 <bigblocks>
ffffffffc020198c:	4605                	li	a2,1
ffffffffc020198e:	fbad                	bnez	a5,ffffffffc0201900 <kfree+0x26>
ffffffffc0201990:	c09fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201994:	bff1                	j	ffffffffc0201970 <kfree+0x96>
ffffffffc0201996:	c03fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc020199a:	b751                	j	ffffffffc020191e <kfree+0x44>
ffffffffc020199c:	8082                	ret
ffffffffc020199e:	00004617          	auipc	a2,0x4
ffffffffc02019a2:	f1a60613          	addi	a2,a2,-230 # ffffffffc02058b8 <default_pmm_manager+0x108>
ffffffffc02019a6:	06200593          	li	a1,98
ffffffffc02019aa:	00004517          	auipc	a0,0x4
ffffffffc02019ae:	e6650513          	addi	a0,a0,-410 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc02019b2:	a95fe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02019b6:	86a2                	mv	a3,s0
ffffffffc02019b8:	00004617          	auipc	a2,0x4
ffffffffc02019bc:	ed860613          	addi	a2,a2,-296 # ffffffffc0205890 <default_pmm_manager+0xe0>
ffffffffc02019c0:	06e00593          	li	a1,110
ffffffffc02019c4:	00004517          	auipc	a0,0x4
ffffffffc02019c8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc02019cc:	a7bfe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02019d0 <pa2page.part.0>:
ffffffffc02019d0:	1141                	addi	sp,sp,-16
ffffffffc02019d2:	00004617          	auipc	a2,0x4
ffffffffc02019d6:	ee660613          	addi	a2,a2,-282 # ffffffffc02058b8 <default_pmm_manager+0x108>
ffffffffc02019da:	06200593          	li	a1,98
ffffffffc02019de:	00004517          	auipc	a0,0x4
ffffffffc02019e2:	e3250513          	addi	a0,a0,-462 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc02019e6:	e406                	sd	ra,8(sp)
ffffffffc02019e8:	a5ffe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02019ec <pte2page.part.0>:
ffffffffc02019ec:	1141                	addi	sp,sp,-16
ffffffffc02019ee:	00004617          	auipc	a2,0x4
ffffffffc02019f2:	eea60613          	addi	a2,a2,-278 # ffffffffc02058d8 <default_pmm_manager+0x128>
ffffffffc02019f6:	07400593          	li	a1,116
ffffffffc02019fa:	00004517          	auipc	a0,0x4
ffffffffc02019fe:	e1650513          	addi	a0,a0,-490 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0201a02:	e406                	sd	ra,8(sp)
ffffffffc0201a04:	a43fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201a08 <alloc_pages>:
ffffffffc0201a08:	7139                	addi	sp,sp,-64
ffffffffc0201a0a:	f426                	sd	s1,40(sp)
ffffffffc0201a0c:	f04a                	sd	s2,32(sp)
ffffffffc0201a0e:	ec4e                	sd	s3,24(sp)
ffffffffc0201a10:	e852                	sd	s4,16(sp)
ffffffffc0201a12:	e456                	sd	s5,8(sp)
ffffffffc0201a14:	e05a                	sd	s6,0(sp)
ffffffffc0201a16:	fc06                	sd	ra,56(sp)
ffffffffc0201a18:	f822                	sd	s0,48(sp)
ffffffffc0201a1a:	84aa                	mv	s1,a0
ffffffffc0201a1c:	00014917          	auipc	s2,0x14
ffffffffc0201a20:	b5490913          	addi	s2,s2,-1196 # ffffffffc0215570 <pmm_manager>
ffffffffc0201a24:	4a05                	li	s4,1
ffffffffc0201a26:	00014a97          	auipc	s5,0x14
ffffffffc0201a2a:	b6aa8a93          	addi	s5,s5,-1174 # ffffffffc0215590 <swap_init_ok>
ffffffffc0201a2e:	0005099b          	sext.w	s3,a0
ffffffffc0201a32:	00014b17          	auipc	s6,0x14
ffffffffc0201a36:	b66b0b13          	addi	s6,s6,-1178 # ffffffffc0215598 <check_mm_struct>
ffffffffc0201a3a:	a01d                	j	ffffffffc0201a60 <alloc_pages+0x58>
ffffffffc0201a3c:	00093783          	ld	a5,0(s2)
ffffffffc0201a40:	6f9c                	ld	a5,24(a5)
ffffffffc0201a42:	9782                	jalr	a5
ffffffffc0201a44:	842a                	mv	s0,a0
ffffffffc0201a46:	4601                	li	a2,0
ffffffffc0201a48:	85ce                	mv	a1,s3
ffffffffc0201a4a:	ec0d                	bnez	s0,ffffffffc0201a84 <alloc_pages+0x7c>
ffffffffc0201a4c:	029a6c63          	bltu	s4,s1,ffffffffc0201a84 <alloc_pages+0x7c>
ffffffffc0201a50:	000aa783          	lw	a5,0(s5)
ffffffffc0201a54:	2781                	sext.w	a5,a5
ffffffffc0201a56:	c79d                	beqz	a5,ffffffffc0201a84 <alloc_pages+0x7c>
ffffffffc0201a58:	000b3503          	ld	a0,0(s6)
ffffffffc0201a5c:	037010ef          	jal	ra,ffffffffc0203292 <swap_out>
ffffffffc0201a60:	100027f3          	csrr	a5,sstatus
ffffffffc0201a64:	8b89                	andi	a5,a5,2
ffffffffc0201a66:	8526                	mv	a0,s1
ffffffffc0201a68:	dbf1                	beqz	a5,ffffffffc0201a3c <alloc_pages+0x34>
ffffffffc0201a6a:	b35fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201a6e:	00093783          	ld	a5,0(s2)
ffffffffc0201a72:	8526                	mv	a0,s1
ffffffffc0201a74:	6f9c                	ld	a5,24(a5)
ffffffffc0201a76:	9782                	jalr	a5
ffffffffc0201a78:	842a                	mv	s0,a0
ffffffffc0201a7a:	b1ffe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201a7e:	4601                	li	a2,0
ffffffffc0201a80:	85ce                	mv	a1,s3
ffffffffc0201a82:	d469                	beqz	s0,ffffffffc0201a4c <alloc_pages+0x44>
ffffffffc0201a84:	70e2                	ld	ra,56(sp)
ffffffffc0201a86:	8522                	mv	a0,s0
ffffffffc0201a88:	7442                	ld	s0,48(sp)
ffffffffc0201a8a:	74a2                	ld	s1,40(sp)
ffffffffc0201a8c:	7902                	ld	s2,32(sp)
ffffffffc0201a8e:	69e2                	ld	s3,24(sp)
ffffffffc0201a90:	6a42                	ld	s4,16(sp)
ffffffffc0201a92:	6aa2                	ld	s5,8(sp)
ffffffffc0201a94:	6b02                	ld	s6,0(sp)
ffffffffc0201a96:	6121                	addi	sp,sp,64
ffffffffc0201a98:	8082                	ret

ffffffffc0201a9a <free_pages>:
ffffffffc0201a9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a9e:	8b89                	andi	a5,a5,2
ffffffffc0201aa0:	e799                	bnez	a5,ffffffffc0201aae <free_pages+0x14>
ffffffffc0201aa2:	00014797          	auipc	a5,0x14
ffffffffc0201aa6:	ace7b783          	ld	a5,-1330(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201aaa:	739c                	ld	a5,32(a5)
ffffffffc0201aac:	8782                	jr	a5
ffffffffc0201aae:	1101                	addi	sp,sp,-32
ffffffffc0201ab0:	ec06                	sd	ra,24(sp)
ffffffffc0201ab2:	e822                	sd	s0,16(sp)
ffffffffc0201ab4:	e426                	sd	s1,8(sp)
ffffffffc0201ab6:	842a                	mv	s0,a0
ffffffffc0201ab8:	84ae                	mv	s1,a1
ffffffffc0201aba:	ae5fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201abe:	00014797          	auipc	a5,0x14
ffffffffc0201ac2:	ab27b783          	ld	a5,-1358(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201ac6:	739c                	ld	a5,32(a5)
ffffffffc0201ac8:	85a6                	mv	a1,s1
ffffffffc0201aca:	8522                	mv	a0,s0
ffffffffc0201acc:	9782                	jalr	a5
ffffffffc0201ace:	6442                	ld	s0,16(sp)
ffffffffc0201ad0:	60e2                	ld	ra,24(sp)
ffffffffc0201ad2:	64a2                	ld	s1,8(sp)
ffffffffc0201ad4:	6105                	addi	sp,sp,32
ffffffffc0201ad6:	ac3fe06f          	j	ffffffffc0200598 <intr_enable>

ffffffffc0201ada <nr_free_pages>:
ffffffffc0201ada:	100027f3          	csrr	a5,sstatus
ffffffffc0201ade:	8b89                	andi	a5,a5,2
ffffffffc0201ae0:	e799                	bnez	a5,ffffffffc0201aee <nr_free_pages+0x14>
ffffffffc0201ae2:	00014797          	auipc	a5,0x14
ffffffffc0201ae6:	a8e7b783          	ld	a5,-1394(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201aea:	779c                	ld	a5,40(a5)
ffffffffc0201aec:	8782                	jr	a5
ffffffffc0201aee:	1141                	addi	sp,sp,-16
ffffffffc0201af0:	e406                	sd	ra,8(sp)
ffffffffc0201af2:	e022                	sd	s0,0(sp)
ffffffffc0201af4:	aabfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201af8:	00014797          	auipc	a5,0x14
ffffffffc0201afc:	a787b783          	ld	a5,-1416(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201b00:	779c                	ld	a5,40(a5)
ffffffffc0201b02:	9782                	jalr	a5
ffffffffc0201b04:	842a                	mv	s0,a0
ffffffffc0201b06:	a93fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201b0a:	60a2                	ld	ra,8(sp)
ffffffffc0201b0c:	8522                	mv	a0,s0
ffffffffc0201b0e:	6402                	ld	s0,0(sp)
ffffffffc0201b10:	0141                	addi	sp,sp,16
ffffffffc0201b12:	8082                	ret

ffffffffc0201b14 <get_pte>:
ffffffffc0201b14:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201b18:	1ff7f793          	andi	a5,a5,511
ffffffffc0201b1c:	7139                	addi	sp,sp,-64
ffffffffc0201b1e:	078e                	slli	a5,a5,0x3
ffffffffc0201b20:	f426                	sd	s1,40(sp)
ffffffffc0201b22:	00f504b3          	add	s1,a0,a5
ffffffffc0201b26:	6094                	ld	a3,0(s1)
ffffffffc0201b28:	f04a                	sd	s2,32(sp)
ffffffffc0201b2a:	ec4e                	sd	s3,24(sp)
ffffffffc0201b2c:	e852                	sd	s4,16(sp)
ffffffffc0201b2e:	fc06                	sd	ra,56(sp)
ffffffffc0201b30:	f822                	sd	s0,48(sp)
ffffffffc0201b32:	e456                	sd	s5,8(sp)
ffffffffc0201b34:	e05a                	sd	s6,0(sp)
ffffffffc0201b36:	0016f793          	andi	a5,a3,1
ffffffffc0201b3a:	892e                	mv	s2,a1
ffffffffc0201b3c:	89b2                	mv	s3,a2
ffffffffc0201b3e:	00014a17          	auipc	s4,0x14
ffffffffc0201b42:	a22a0a13          	addi	s4,s4,-1502 # ffffffffc0215560 <npage>
ffffffffc0201b46:	e7b5                	bnez	a5,ffffffffc0201bb2 <get_pte+0x9e>
ffffffffc0201b48:	12060b63          	beqz	a2,ffffffffc0201c7e <get_pte+0x16a>
ffffffffc0201b4c:	4505                	li	a0,1
ffffffffc0201b4e:	ebbff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0201b52:	842a                	mv	s0,a0
ffffffffc0201b54:	12050563          	beqz	a0,ffffffffc0201c7e <get_pte+0x16a>
ffffffffc0201b58:	00014b17          	auipc	s6,0x14
ffffffffc0201b5c:	a10b0b13          	addi	s6,s6,-1520 # ffffffffc0215568 <pages>
ffffffffc0201b60:	000b3503          	ld	a0,0(s6)
ffffffffc0201b64:	00080ab7          	lui	s5,0x80
ffffffffc0201b68:	00014a17          	auipc	s4,0x14
ffffffffc0201b6c:	9f8a0a13          	addi	s4,s4,-1544 # ffffffffc0215560 <npage>
ffffffffc0201b70:	40a40533          	sub	a0,s0,a0
ffffffffc0201b74:	8519                	srai	a0,a0,0x6
ffffffffc0201b76:	9556                	add	a0,a0,s5
ffffffffc0201b78:	000a3703          	ld	a4,0(s4)
ffffffffc0201b7c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201b80:	4685                	li	a3,1
ffffffffc0201b82:	c014                	sw	a3,0(s0)
ffffffffc0201b84:	83b1                	srli	a5,a5,0xc
ffffffffc0201b86:	0532                	slli	a0,a0,0xc
ffffffffc0201b88:	14e7f263          	bgeu	a5,a4,ffffffffc0201ccc <get_pte+0x1b8>
ffffffffc0201b8c:	00014797          	auipc	a5,0x14
ffffffffc0201b90:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0201b94:	6605                	lui	a2,0x1
ffffffffc0201b96:	4581                	li	a1,0
ffffffffc0201b98:	953e                	add	a0,a0,a5
ffffffffc0201b9a:	677020ef          	jal	ra,ffffffffc0204a10 <memset>
ffffffffc0201b9e:	000b3683          	ld	a3,0(s6)
ffffffffc0201ba2:	40d406b3          	sub	a3,s0,a3
ffffffffc0201ba6:	8699                	srai	a3,a3,0x6
ffffffffc0201ba8:	96d6                	add	a3,a3,s5
ffffffffc0201baa:	06aa                	slli	a3,a3,0xa
ffffffffc0201bac:	0116e693          	ori	a3,a3,17
ffffffffc0201bb0:	e094                	sd	a3,0(s1)
ffffffffc0201bb2:	77fd                	lui	a5,0xfffff
ffffffffc0201bb4:	068a                	slli	a3,a3,0x2
ffffffffc0201bb6:	000a3703          	ld	a4,0(s4)
ffffffffc0201bba:	8efd                	and	a3,a3,a5
ffffffffc0201bbc:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201bc0:	0ce7f163          	bgeu	a5,a4,ffffffffc0201c82 <get_pte+0x16e>
ffffffffc0201bc4:	00014a97          	auipc	s5,0x14
ffffffffc0201bc8:	9b4a8a93          	addi	s5,s5,-1612 # ffffffffc0215578 <va_pa_offset>
ffffffffc0201bcc:	000ab403          	ld	s0,0(s5)
ffffffffc0201bd0:	01595793          	srli	a5,s2,0x15
ffffffffc0201bd4:	1ff7f793          	andi	a5,a5,511
ffffffffc0201bd8:	96a2                	add	a3,a3,s0
ffffffffc0201bda:	00379413          	slli	s0,a5,0x3
ffffffffc0201bde:	9436                	add	s0,s0,a3
ffffffffc0201be0:	6014                	ld	a3,0(s0)
ffffffffc0201be2:	0016f793          	andi	a5,a3,1
ffffffffc0201be6:	e3ad                	bnez	a5,ffffffffc0201c48 <get_pte+0x134>
ffffffffc0201be8:	08098b63          	beqz	s3,ffffffffc0201c7e <get_pte+0x16a>
ffffffffc0201bec:	4505                	li	a0,1
ffffffffc0201bee:	e1bff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0201bf2:	84aa                	mv	s1,a0
ffffffffc0201bf4:	c549                	beqz	a0,ffffffffc0201c7e <get_pte+0x16a>
ffffffffc0201bf6:	00014b17          	auipc	s6,0x14
ffffffffc0201bfa:	972b0b13          	addi	s6,s6,-1678 # ffffffffc0215568 <pages>
ffffffffc0201bfe:	000b3503          	ld	a0,0(s6)
ffffffffc0201c02:	000809b7          	lui	s3,0x80
ffffffffc0201c06:	000a3703          	ld	a4,0(s4)
ffffffffc0201c0a:	40a48533          	sub	a0,s1,a0
ffffffffc0201c0e:	8519                	srai	a0,a0,0x6
ffffffffc0201c10:	954e                	add	a0,a0,s3
ffffffffc0201c12:	00c51793          	slli	a5,a0,0xc
ffffffffc0201c16:	4685                	li	a3,1
ffffffffc0201c18:	c094                	sw	a3,0(s1)
ffffffffc0201c1a:	83b1                	srli	a5,a5,0xc
ffffffffc0201c1c:	0532                	slli	a0,a0,0xc
ffffffffc0201c1e:	08e7fa63          	bgeu	a5,a4,ffffffffc0201cb2 <get_pte+0x19e>
ffffffffc0201c22:	000ab783          	ld	a5,0(s5)
ffffffffc0201c26:	6605                	lui	a2,0x1
ffffffffc0201c28:	4581                	li	a1,0
ffffffffc0201c2a:	953e                	add	a0,a0,a5
ffffffffc0201c2c:	5e5020ef          	jal	ra,ffffffffc0204a10 <memset>
ffffffffc0201c30:	000b3683          	ld	a3,0(s6)
ffffffffc0201c34:	40d486b3          	sub	a3,s1,a3
ffffffffc0201c38:	8699                	srai	a3,a3,0x6
ffffffffc0201c3a:	96ce                	add	a3,a3,s3
ffffffffc0201c3c:	06aa                	slli	a3,a3,0xa
ffffffffc0201c3e:	0116e693          	ori	a3,a3,17
ffffffffc0201c42:	e014                	sd	a3,0(s0)
ffffffffc0201c44:	000a3703          	ld	a4,0(s4)
ffffffffc0201c48:	068a                	slli	a3,a3,0x2
ffffffffc0201c4a:	757d                	lui	a0,0xfffff
ffffffffc0201c4c:	8ee9                	and	a3,a3,a0
ffffffffc0201c4e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201c52:	04e7f463          	bgeu	a5,a4,ffffffffc0201c9a <get_pte+0x186>
ffffffffc0201c56:	000ab503          	ld	a0,0(s5)
ffffffffc0201c5a:	00c95913          	srli	s2,s2,0xc
ffffffffc0201c5e:	1ff97913          	andi	s2,s2,511
ffffffffc0201c62:	96aa                	add	a3,a3,a0
ffffffffc0201c64:	00391513          	slli	a0,s2,0x3
ffffffffc0201c68:	9536                	add	a0,a0,a3
ffffffffc0201c6a:	70e2                	ld	ra,56(sp)
ffffffffc0201c6c:	7442                	ld	s0,48(sp)
ffffffffc0201c6e:	74a2                	ld	s1,40(sp)
ffffffffc0201c70:	7902                	ld	s2,32(sp)
ffffffffc0201c72:	69e2                	ld	s3,24(sp)
ffffffffc0201c74:	6a42                	ld	s4,16(sp)
ffffffffc0201c76:	6aa2                	ld	s5,8(sp)
ffffffffc0201c78:	6b02                	ld	s6,0(sp)
ffffffffc0201c7a:	6121                	addi	sp,sp,64
ffffffffc0201c7c:	8082                	ret
ffffffffc0201c7e:	4501                	li	a0,0
ffffffffc0201c80:	b7ed                	j	ffffffffc0201c6a <get_pte+0x156>
ffffffffc0201c82:	00004617          	auipc	a2,0x4
ffffffffc0201c86:	b6660613          	addi	a2,a2,-1178 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0201c8a:	0e400593          	li	a1,228
ffffffffc0201c8e:	00004517          	auipc	a0,0x4
ffffffffc0201c92:	c7250513          	addi	a0,a0,-910 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0201c96:	fb0fe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0201c9a:	00004617          	auipc	a2,0x4
ffffffffc0201c9e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0201ca2:	0ef00593          	li	a1,239
ffffffffc0201ca6:	00004517          	auipc	a0,0x4
ffffffffc0201caa:	c5a50513          	addi	a0,a0,-934 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0201cae:	f98fe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0201cb2:	86aa                	mv	a3,a0
ffffffffc0201cb4:	00004617          	auipc	a2,0x4
ffffffffc0201cb8:	b3460613          	addi	a2,a2,-1228 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0201cbc:	0ec00593          	li	a1,236
ffffffffc0201cc0:	00004517          	auipc	a0,0x4
ffffffffc0201cc4:	c4050513          	addi	a0,a0,-960 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0201cc8:	f7efe0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0201ccc:	86aa                	mv	a3,a0
ffffffffc0201cce:	00004617          	auipc	a2,0x4
ffffffffc0201cd2:	b1a60613          	addi	a2,a2,-1254 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0201cd6:	0e100593          	li	a1,225
ffffffffc0201cda:	00004517          	auipc	a0,0x4
ffffffffc0201cde:	c2650513          	addi	a0,a0,-986 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0201ce2:	f64fe0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0201ce6 <get_page>:
ffffffffc0201ce6:	1141                	addi	sp,sp,-16
ffffffffc0201ce8:	e022                	sd	s0,0(sp)
ffffffffc0201cea:	8432                	mv	s0,a2
ffffffffc0201cec:	4601                	li	a2,0
ffffffffc0201cee:	e406                	sd	ra,8(sp)
ffffffffc0201cf0:	e25ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0201cf4:	c011                	beqz	s0,ffffffffc0201cf8 <get_page+0x12>
ffffffffc0201cf6:	e008                	sd	a0,0(s0)
ffffffffc0201cf8:	c511                	beqz	a0,ffffffffc0201d04 <get_page+0x1e>
ffffffffc0201cfa:	611c                	ld	a5,0(a0)
ffffffffc0201cfc:	4501                	li	a0,0
ffffffffc0201cfe:	0017f713          	andi	a4,a5,1
ffffffffc0201d02:	e709                	bnez	a4,ffffffffc0201d0c <get_page+0x26>
ffffffffc0201d04:	60a2                	ld	ra,8(sp)
ffffffffc0201d06:	6402                	ld	s0,0(sp)
ffffffffc0201d08:	0141                	addi	sp,sp,16
ffffffffc0201d0a:	8082                	ret
ffffffffc0201d0c:	078a                	slli	a5,a5,0x2
ffffffffc0201d0e:	83b1                	srli	a5,a5,0xc
ffffffffc0201d10:	00014717          	auipc	a4,0x14
ffffffffc0201d14:	85073703          	ld	a4,-1968(a4) # ffffffffc0215560 <npage>
ffffffffc0201d18:	00e7ff63          	bgeu	a5,a4,ffffffffc0201d36 <get_page+0x50>
ffffffffc0201d1c:	60a2                	ld	ra,8(sp)
ffffffffc0201d1e:	6402                	ld	s0,0(sp)
ffffffffc0201d20:	fff80537          	lui	a0,0xfff80
ffffffffc0201d24:	97aa                	add	a5,a5,a0
ffffffffc0201d26:	079a                	slli	a5,a5,0x6
ffffffffc0201d28:	00014517          	auipc	a0,0x14
ffffffffc0201d2c:	84053503          	ld	a0,-1984(a0) # ffffffffc0215568 <pages>
ffffffffc0201d30:	953e                	add	a0,a0,a5
ffffffffc0201d32:	0141                	addi	sp,sp,16
ffffffffc0201d34:	8082                	ret
ffffffffc0201d36:	c9bff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>

ffffffffc0201d3a <page_remove>:
ffffffffc0201d3a:	7179                	addi	sp,sp,-48
ffffffffc0201d3c:	4601                	li	a2,0
ffffffffc0201d3e:	ec26                	sd	s1,24(sp)
ffffffffc0201d40:	f406                	sd	ra,40(sp)
ffffffffc0201d42:	f022                	sd	s0,32(sp)
ffffffffc0201d44:	84ae                	mv	s1,a1
ffffffffc0201d46:	dcfff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0201d4a:	c511                	beqz	a0,ffffffffc0201d56 <page_remove+0x1c>
ffffffffc0201d4c:	611c                	ld	a5,0(a0)
ffffffffc0201d4e:	842a                	mv	s0,a0
ffffffffc0201d50:	0017f713          	andi	a4,a5,1
ffffffffc0201d54:	e711                	bnez	a4,ffffffffc0201d60 <page_remove+0x26>
ffffffffc0201d56:	70a2                	ld	ra,40(sp)
ffffffffc0201d58:	7402                	ld	s0,32(sp)
ffffffffc0201d5a:	64e2                	ld	s1,24(sp)
ffffffffc0201d5c:	6145                	addi	sp,sp,48
ffffffffc0201d5e:	8082                	ret
ffffffffc0201d60:	078a                	slli	a5,a5,0x2
ffffffffc0201d62:	83b1                	srli	a5,a5,0xc
ffffffffc0201d64:	00013717          	auipc	a4,0x13
ffffffffc0201d68:	7fc73703          	ld	a4,2044(a4) # ffffffffc0215560 <npage>
ffffffffc0201d6c:	06e7f363          	bgeu	a5,a4,ffffffffc0201dd2 <page_remove+0x98>
ffffffffc0201d70:	fff80537          	lui	a0,0xfff80
ffffffffc0201d74:	97aa                	add	a5,a5,a0
ffffffffc0201d76:	079a                	slli	a5,a5,0x6
ffffffffc0201d78:	00013517          	auipc	a0,0x13
ffffffffc0201d7c:	7f053503          	ld	a0,2032(a0) # ffffffffc0215568 <pages>
ffffffffc0201d80:	953e                	add	a0,a0,a5
ffffffffc0201d82:	411c                	lw	a5,0(a0)
ffffffffc0201d84:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201d88:	c118                	sw	a4,0(a0)
ffffffffc0201d8a:	cb11                	beqz	a4,ffffffffc0201d9e <page_remove+0x64>
ffffffffc0201d8c:	00043023          	sd	zero,0(s0)
ffffffffc0201d90:	12048073          	sfence.vma	s1
ffffffffc0201d94:	70a2                	ld	ra,40(sp)
ffffffffc0201d96:	7402                	ld	s0,32(sp)
ffffffffc0201d98:	64e2                	ld	s1,24(sp)
ffffffffc0201d9a:	6145                	addi	sp,sp,48
ffffffffc0201d9c:	8082                	ret
ffffffffc0201d9e:	100027f3          	csrr	a5,sstatus
ffffffffc0201da2:	8b89                	andi	a5,a5,2
ffffffffc0201da4:	eb89                	bnez	a5,ffffffffc0201db6 <page_remove+0x7c>
ffffffffc0201da6:	00013797          	auipc	a5,0x13
ffffffffc0201daa:	7ca7b783          	ld	a5,1994(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201dae:	739c                	ld	a5,32(a5)
ffffffffc0201db0:	4585                	li	a1,1
ffffffffc0201db2:	9782                	jalr	a5
ffffffffc0201db4:	bfe1                	j	ffffffffc0201d8c <page_remove+0x52>
ffffffffc0201db6:	e42a                	sd	a0,8(sp)
ffffffffc0201db8:	fe6fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201dbc:	00013797          	auipc	a5,0x13
ffffffffc0201dc0:	7b47b783          	ld	a5,1972(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201dc4:	739c                	ld	a5,32(a5)
ffffffffc0201dc6:	6522                	ld	a0,8(sp)
ffffffffc0201dc8:	4585                	li	a1,1
ffffffffc0201dca:	9782                	jalr	a5
ffffffffc0201dcc:	fccfe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201dd0:	bf75                	j	ffffffffc0201d8c <page_remove+0x52>
ffffffffc0201dd2:	bffff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>

ffffffffc0201dd6 <page_insert>:
ffffffffc0201dd6:	7139                	addi	sp,sp,-64
ffffffffc0201dd8:	e852                	sd	s4,16(sp)
ffffffffc0201dda:	8a32                	mv	s4,a2
ffffffffc0201ddc:	f822                	sd	s0,48(sp)
ffffffffc0201dde:	4605                	li	a2,1
ffffffffc0201de0:	842e                	mv	s0,a1
ffffffffc0201de2:	85d2                	mv	a1,s4
ffffffffc0201de4:	f426                	sd	s1,40(sp)
ffffffffc0201de6:	fc06                	sd	ra,56(sp)
ffffffffc0201de8:	f04a                	sd	s2,32(sp)
ffffffffc0201dea:	ec4e                	sd	s3,24(sp)
ffffffffc0201dec:	e456                	sd	s5,8(sp)
ffffffffc0201dee:	84b6                	mv	s1,a3
ffffffffc0201df0:	d25ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0201df4:	c961                	beqz	a0,ffffffffc0201ec4 <page_insert+0xee>
ffffffffc0201df6:	4014                	lw	a3,0(s0)
ffffffffc0201df8:	611c                	ld	a5,0(a0)
ffffffffc0201dfa:	89aa                	mv	s3,a0
ffffffffc0201dfc:	0016871b          	addiw	a4,a3,1
ffffffffc0201e00:	c018                	sw	a4,0(s0)
ffffffffc0201e02:	0017f713          	andi	a4,a5,1
ffffffffc0201e06:	ef05                	bnez	a4,ffffffffc0201e3e <page_insert+0x68>
ffffffffc0201e08:	00013717          	auipc	a4,0x13
ffffffffc0201e0c:	76073703          	ld	a4,1888(a4) # ffffffffc0215568 <pages>
ffffffffc0201e10:	8c19                	sub	s0,s0,a4
ffffffffc0201e12:	000807b7          	lui	a5,0x80
ffffffffc0201e16:	8419                	srai	s0,s0,0x6
ffffffffc0201e18:	943e                	add	s0,s0,a5
ffffffffc0201e1a:	042a                	slli	s0,s0,0xa
ffffffffc0201e1c:	8cc1                	or	s1,s1,s0
ffffffffc0201e1e:	0014e493          	ori	s1,s1,1
ffffffffc0201e22:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0201e26:	120a0073          	sfence.vma	s4
ffffffffc0201e2a:	4501                	li	a0,0
ffffffffc0201e2c:	70e2                	ld	ra,56(sp)
ffffffffc0201e2e:	7442                	ld	s0,48(sp)
ffffffffc0201e30:	74a2                	ld	s1,40(sp)
ffffffffc0201e32:	7902                	ld	s2,32(sp)
ffffffffc0201e34:	69e2                	ld	s3,24(sp)
ffffffffc0201e36:	6a42                	ld	s4,16(sp)
ffffffffc0201e38:	6aa2                	ld	s5,8(sp)
ffffffffc0201e3a:	6121                	addi	sp,sp,64
ffffffffc0201e3c:	8082                	ret
ffffffffc0201e3e:	078a                	slli	a5,a5,0x2
ffffffffc0201e40:	83b1                	srli	a5,a5,0xc
ffffffffc0201e42:	00013717          	auipc	a4,0x13
ffffffffc0201e46:	71e73703          	ld	a4,1822(a4) # ffffffffc0215560 <npage>
ffffffffc0201e4a:	06e7ff63          	bgeu	a5,a4,ffffffffc0201ec8 <page_insert+0xf2>
ffffffffc0201e4e:	00013a97          	auipc	s5,0x13
ffffffffc0201e52:	71aa8a93          	addi	s5,s5,1818 # ffffffffc0215568 <pages>
ffffffffc0201e56:	000ab703          	ld	a4,0(s5)
ffffffffc0201e5a:	fff80937          	lui	s2,0xfff80
ffffffffc0201e5e:	993e                	add	s2,s2,a5
ffffffffc0201e60:	091a                	slli	s2,s2,0x6
ffffffffc0201e62:	993a                	add	s2,s2,a4
ffffffffc0201e64:	01240c63          	beq	s0,s2,ffffffffc0201e7c <page_insert+0xa6>
ffffffffc0201e68:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6aa3c>
ffffffffc0201e6c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201e70:	00d92023          	sw	a3,0(s2)
ffffffffc0201e74:	c691                	beqz	a3,ffffffffc0201e80 <page_insert+0xaa>
ffffffffc0201e76:	120a0073          	sfence.vma	s4
ffffffffc0201e7a:	bf59                	j	ffffffffc0201e10 <page_insert+0x3a>
ffffffffc0201e7c:	c014                	sw	a3,0(s0)
ffffffffc0201e7e:	bf49                	j	ffffffffc0201e10 <page_insert+0x3a>
ffffffffc0201e80:	100027f3          	csrr	a5,sstatus
ffffffffc0201e84:	8b89                	andi	a5,a5,2
ffffffffc0201e86:	ef91                	bnez	a5,ffffffffc0201ea2 <page_insert+0xcc>
ffffffffc0201e88:	00013797          	auipc	a5,0x13
ffffffffc0201e8c:	6e87b783          	ld	a5,1768(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201e90:	739c                	ld	a5,32(a5)
ffffffffc0201e92:	4585                	li	a1,1
ffffffffc0201e94:	854a                	mv	a0,s2
ffffffffc0201e96:	9782                	jalr	a5
ffffffffc0201e98:	000ab703          	ld	a4,0(s5)
ffffffffc0201e9c:	120a0073          	sfence.vma	s4
ffffffffc0201ea0:	bf85                	j	ffffffffc0201e10 <page_insert+0x3a>
ffffffffc0201ea2:	efcfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0201ea6:	00013797          	auipc	a5,0x13
ffffffffc0201eaa:	6ca7b783          	ld	a5,1738(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0201eae:	739c                	ld	a5,32(a5)
ffffffffc0201eb0:	4585                	li	a1,1
ffffffffc0201eb2:	854a                	mv	a0,s2
ffffffffc0201eb4:	9782                	jalr	a5
ffffffffc0201eb6:	ee2fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0201eba:	000ab703          	ld	a4,0(s5)
ffffffffc0201ebe:	120a0073          	sfence.vma	s4
ffffffffc0201ec2:	b7b9                	j	ffffffffc0201e10 <page_insert+0x3a>
ffffffffc0201ec4:	5571                	li	a0,-4
ffffffffc0201ec6:	b79d                	j	ffffffffc0201e2c <page_insert+0x56>
ffffffffc0201ec8:	b09ff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>

ffffffffc0201ecc <pmm_init>:
ffffffffc0201ecc:	00004797          	auipc	a5,0x4
ffffffffc0201ed0:	8e478793          	addi	a5,a5,-1820 # ffffffffc02057b0 <default_pmm_manager>
ffffffffc0201ed4:	638c                	ld	a1,0(a5)
ffffffffc0201ed6:	711d                	addi	sp,sp,-96
ffffffffc0201ed8:	ec5e                	sd	s7,24(sp)
ffffffffc0201eda:	00004517          	auipc	a0,0x4
ffffffffc0201ede:	a3650513          	addi	a0,a0,-1482 # ffffffffc0205910 <default_pmm_manager+0x160>
ffffffffc0201ee2:	00013b97          	auipc	s7,0x13
ffffffffc0201ee6:	68eb8b93          	addi	s7,s7,1678 # ffffffffc0215570 <pmm_manager>
ffffffffc0201eea:	ec86                	sd	ra,88(sp)
ffffffffc0201eec:	e4a6                	sd	s1,72(sp)
ffffffffc0201eee:	fc4e                	sd	s3,56(sp)
ffffffffc0201ef0:	f05a                	sd	s6,32(sp)
ffffffffc0201ef2:	00fbb023          	sd	a5,0(s7)
ffffffffc0201ef6:	e8a2                	sd	s0,80(sp)
ffffffffc0201ef8:	e0ca                	sd	s2,64(sp)
ffffffffc0201efa:	f852                	sd	s4,48(sp)
ffffffffc0201efc:	f456                	sd	s5,40(sp)
ffffffffc0201efe:	e862                	sd	s8,16(sp)
ffffffffc0201f00:	a80fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0201f04:	000bb783          	ld	a5,0(s7)
ffffffffc0201f08:	00013997          	auipc	s3,0x13
ffffffffc0201f0c:	67098993          	addi	s3,s3,1648 # ffffffffc0215578 <va_pa_offset>
ffffffffc0201f10:	00013497          	auipc	s1,0x13
ffffffffc0201f14:	65048493          	addi	s1,s1,1616 # ffffffffc0215560 <npage>
ffffffffc0201f18:	679c                	ld	a5,8(a5)
ffffffffc0201f1a:	00013b17          	auipc	s6,0x13
ffffffffc0201f1e:	64eb0b13          	addi	s6,s6,1614 # ffffffffc0215568 <pages>
ffffffffc0201f22:	9782                	jalr	a5
ffffffffc0201f24:	57f5                	li	a5,-3
ffffffffc0201f26:	07fa                	slli	a5,a5,0x1e
ffffffffc0201f28:	00004517          	auipc	a0,0x4
ffffffffc0201f2c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0205928 <default_pmm_manager+0x178>
ffffffffc0201f30:	00f9b023          	sd	a5,0(s3)
ffffffffc0201f34:	a4cfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0201f38:	46c5                	li	a3,17
ffffffffc0201f3a:	06ee                	slli	a3,a3,0x1b
ffffffffc0201f3c:	40100613          	li	a2,1025
ffffffffc0201f40:	07e005b7          	lui	a1,0x7e00
ffffffffc0201f44:	16fd                	addi	a3,a3,-1
ffffffffc0201f46:	0656                	slli	a2,a2,0x15
ffffffffc0201f48:	00004517          	auipc	a0,0x4
ffffffffc0201f4c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0205940 <default_pmm_manager+0x190>
ffffffffc0201f50:	a30fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0201f54:	777d                	lui	a4,0xfffff
ffffffffc0201f56:	00014797          	auipc	a5,0x14
ffffffffc0201f5a:	66d78793          	addi	a5,a5,1645 # ffffffffc02165c3 <end+0xfff>
ffffffffc0201f5e:	8ff9                	and	a5,a5,a4
ffffffffc0201f60:	00088737          	lui	a4,0x88
ffffffffc0201f64:	e098                	sd	a4,0(s1)
ffffffffc0201f66:	00fb3023          	sd	a5,0(s6)
ffffffffc0201f6a:	4701                	li	a4,0
ffffffffc0201f6c:	4585                	li	a1,1
ffffffffc0201f6e:	fff80837          	lui	a6,0xfff80
ffffffffc0201f72:	a019                	j	ffffffffc0201f78 <pmm_init+0xac>
ffffffffc0201f74:	000b3783          	ld	a5,0(s6)
ffffffffc0201f78:	00671693          	slli	a3,a4,0x6
ffffffffc0201f7c:	97b6                	add	a5,a5,a3
ffffffffc0201f7e:	07a1                	addi	a5,a5,8
ffffffffc0201f80:	40b7b02f          	amoor.d	zero,a1,(a5)
ffffffffc0201f84:	6090                	ld	a2,0(s1)
ffffffffc0201f86:	0705                	addi	a4,a4,1
ffffffffc0201f88:	010607b3          	add	a5,a2,a6
ffffffffc0201f8c:	fef764e3          	bltu	a4,a5,ffffffffc0201f74 <pmm_init+0xa8>
ffffffffc0201f90:	000b3503          	ld	a0,0(s6)
ffffffffc0201f94:	079a                	slli	a5,a5,0x6
ffffffffc0201f96:	c0200737          	lui	a4,0xc0200
ffffffffc0201f9a:	00f506b3          	add	a3,a0,a5
ffffffffc0201f9e:	60e6e563          	bltu	a3,a4,ffffffffc02025a8 <pmm_init+0x6dc>
ffffffffc0201fa2:	0009b583          	ld	a1,0(s3)
ffffffffc0201fa6:	4745                	li	a4,17
ffffffffc0201fa8:	076e                	slli	a4,a4,0x1b
ffffffffc0201faa:	8e8d                	sub	a3,a3,a1
ffffffffc0201fac:	4ae6e563          	bltu	a3,a4,ffffffffc0202456 <pmm_init+0x58a>
ffffffffc0201fb0:	00004517          	auipc	a0,0x4
ffffffffc0201fb4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0205968 <default_pmm_manager+0x1b8>
ffffffffc0201fb8:	9c8fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0201fbc:	000bb783          	ld	a5,0(s7)
ffffffffc0201fc0:	00013917          	auipc	s2,0x13
ffffffffc0201fc4:	59890913          	addi	s2,s2,1432 # ffffffffc0215558 <boot_pgdir>
ffffffffc0201fc8:	7b9c                	ld	a5,48(a5)
ffffffffc0201fca:	9782                	jalr	a5
ffffffffc0201fcc:	00004517          	auipc	a0,0x4
ffffffffc0201fd0:	9b450513          	addi	a0,a0,-1612 # ffffffffc0205980 <default_pmm_manager+0x1d0>
ffffffffc0201fd4:	9acfe0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0201fd8:	00007697          	auipc	a3,0x7
ffffffffc0201fdc:	02868693          	addi	a3,a3,40 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201fe0:	00d93023          	sd	a3,0(s2)
ffffffffc0201fe4:	c02007b7          	lui	a5,0xc0200
ffffffffc0201fe8:	5cf6ec63          	bltu	a3,a5,ffffffffc02025c0 <pmm_init+0x6f4>
ffffffffc0201fec:	0009b783          	ld	a5,0(s3)
ffffffffc0201ff0:	8e9d                	sub	a3,a3,a5
ffffffffc0201ff2:	00013797          	auipc	a5,0x13
ffffffffc0201ff6:	54d7bf23          	sd	a3,1374(a5) # ffffffffc0215550 <boot_cr3>
ffffffffc0201ffa:	100027f3          	csrr	a5,sstatus
ffffffffc0201ffe:	8b89                	andi	a5,a5,2
ffffffffc0202000:	48079263          	bnez	a5,ffffffffc0202484 <pmm_init+0x5b8>
ffffffffc0202004:	000bb783          	ld	a5,0(s7)
ffffffffc0202008:	779c                	ld	a5,40(a5)
ffffffffc020200a:	9782                	jalr	a5
ffffffffc020200c:	842a                	mv	s0,a0
ffffffffc020200e:	6098                	ld	a4,0(s1)
ffffffffc0202010:	c80007b7          	lui	a5,0xc8000
ffffffffc0202014:	83b1                	srli	a5,a5,0xc
ffffffffc0202016:	5ee7e163          	bltu	a5,a4,ffffffffc02025f8 <pmm_init+0x72c>
ffffffffc020201a:	00093503          	ld	a0,0(s2)
ffffffffc020201e:	5a050d63          	beqz	a0,ffffffffc02025d8 <pmm_init+0x70c>
ffffffffc0202022:	03451793          	slli	a5,a0,0x34
ffffffffc0202026:	5a079963          	bnez	a5,ffffffffc02025d8 <pmm_init+0x70c>
ffffffffc020202a:	4601                	li	a2,0
ffffffffc020202c:	4581                	li	a1,0
ffffffffc020202e:	cb9ff0ef          	jal	ra,ffffffffc0201ce6 <get_page>
ffffffffc0202032:	62051563          	bnez	a0,ffffffffc020265c <pmm_init+0x790>
ffffffffc0202036:	4505                	li	a0,1
ffffffffc0202038:	9d1ff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc020203c:	8a2a                	mv	s4,a0
ffffffffc020203e:	00093503          	ld	a0,0(s2)
ffffffffc0202042:	4681                	li	a3,0
ffffffffc0202044:	4601                	li	a2,0
ffffffffc0202046:	85d2                	mv	a1,s4
ffffffffc0202048:	d8fff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc020204c:	5e051863          	bnez	a0,ffffffffc020263c <pmm_init+0x770>
ffffffffc0202050:	00093503          	ld	a0,0(s2)
ffffffffc0202054:	4601                	li	a2,0
ffffffffc0202056:	4581                	li	a1,0
ffffffffc0202058:	abdff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc020205c:	5c050063          	beqz	a0,ffffffffc020261c <pmm_init+0x750>
ffffffffc0202060:	611c                	ld	a5,0(a0)
ffffffffc0202062:	0017f713          	andi	a4,a5,1
ffffffffc0202066:	5a070963          	beqz	a4,ffffffffc0202618 <pmm_init+0x74c>
ffffffffc020206a:	6098                	ld	a4,0(s1)
ffffffffc020206c:	078a                	slli	a5,a5,0x2
ffffffffc020206e:	83b1                	srli	a5,a5,0xc
ffffffffc0202070:	52e7fa63          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc0202074:	000b3683          	ld	a3,0(s6)
ffffffffc0202078:	fff80637          	lui	a2,0xfff80
ffffffffc020207c:	97b2                	add	a5,a5,a2
ffffffffc020207e:	079a                	slli	a5,a5,0x6
ffffffffc0202080:	97b6                	add	a5,a5,a3
ffffffffc0202082:	10fa16e3          	bne	s4,a5,ffffffffc020298e <pmm_init+0xac2>
ffffffffc0202086:	000a2683          	lw	a3,0(s4)
ffffffffc020208a:	4785                	li	a5,1
ffffffffc020208c:	12f69de3          	bne	a3,a5,ffffffffc02029c6 <pmm_init+0xafa>
ffffffffc0202090:	00093503          	ld	a0,0(s2)
ffffffffc0202094:	77fd                	lui	a5,0xfffff
ffffffffc0202096:	6114                	ld	a3,0(a0)
ffffffffc0202098:	068a                	slli	a3,a3,0x2
ffffffffc020209a:	8efd                	and	a3,a3,a5
ffffffffc020209c:	00c6d613          	srli	a2,a3,0xc
ffffffffc02020a0:	10e677e3          	bgeu	a2,a4,ffffffffc02029ae <pmm_init+0xae2>
ffffffffc02020a4:	0009bc03          	ld	s8,0(s3)
ffffffffc02020a8:	96e2                	add	a3,a3,s8
ffffffffc02020aa:	0006ba83          	ld	s5,0(a3)
ffffffffc02020ae:	0a8a                	slli	s5,s5,0x2
ffffffffc02020b0:	00fafab3          	and	s5,s5,a5
ffffffffc02020b4:	00cad793          	srli	a5,s5,0xc
ffffffffc02020b8:	62e7f263          	bgeu	a5,a4,ffffffffc02026dc <pmm_init+0x810>
ffffffffc02020bc:	4601                	li	a2,0
ffffffffc02020be:	6585                	lui	a1,0x1
ffffffffc02020c0:	9ae2                	add	s5,s5,s8
ffffffffc02020c2:	a53ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc02020c6:	0aa1                	addi	s5,s5,8
ffffffffc02020c8:	5f551a63          	bne	a0,s5,ffffffffc02026bc <pmm_init+0x7f0>
ffffffffc02020cc:	4505                	li	a0,1
ffffffffc02020ce:	93bff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc02020d2:	8aaa                	mv	s5,a0
ffffffffc02020d4:	00093503          	ld	a0,0(s2)
ffffffffc02020d8:	46d1                	li	a3,20
ffffffffc02020da:	6605                	lui	a2,0x1
ffffffffc02020dc:	85d6                	mv	a1,s5
ffffffffc02020de:	cf9ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc02020e2:	58051d63          	bnez	a0,ffffffffc020267c <pmm_init+0x7b0>
ffffffffc02020e6:	00093503          	ld	a0,0(s2)
ffffffffc02020ea:	4601                	li	a2,0
ffffffffc02020ec:	6585                	lui	a1,0x1
ffffffffc02020ee:	a27ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc02020f2:	0e050ae3          	beqz	a0,ffffffffc02029e6 <pmm_init+0xb1a>
ffffffffc02020f6:	611c                	ld	a5,0(a0)
ffffffffc02020f8:	0107f713          	andi	a4,a5,16
ffffffffc02020fc:	6e070d63          	beqz	a4,ffffffffc02027f6 <pmm_init+0x92a>
ffffffffc0202100:	8b91                	andi	a5,a5,4
ffffffffc0202102:	6a078a63          	beqz	a5,ffffffffc02027b6 <pmm_init+0x8ea>
ffffffffc0202106:	00093503          	ld	a0,0(s2)
ffffffffc020210a:	611c                	ld	a5,0(a0)
ffffffffc020210c:	8bc1                	andi	a5,a5,16
ffffffffc020210e:	68078463          	beqz	a5,ffffffffc0202796 <pmm_init+0x8ca>
ffffffffc0202112:	000aa703          	lw	a4,0(s5)
ffffffffc0202116:	4785                	li	a5,1
ffffffffc0202118:	58f71263          	bne	a4,a5,ffffffffc020269c <pmm_init+0x7d0>
ffffffffc020211c:	4681                	li	a3,0
ffffffffc020211e:	6605                	lui	a2,0x1
ffffffffc0202120:	85d2                	mv	a1,s4
ffffffffc0202122:	cb5ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc0202126:	62051863          	bnez	a0,ffffffffc0202756 <pmm_init+0x88a>
ffffffffc020212a:	000a2703          	lw	a4,0(s4)
ffffffffc020212e:	4789                	li	a5,2
ffffffffc0202130:	60f71363          	bne	a4,a5,ffffffffc0202736 <pmm_init+0x86a>
ffffffffc0202134:	000aa783          	lw	a5,0(s5)
ffffffffc0202138:	5c079f63          	bnez	a5,ffffffffc0202716 <pmm_init+0x84a>
ffffffffc020213c:	00093503          	ld	a0,0(s2)
ffffffffc0202140:	4601                	li	a2,0
ffffffffc0202142:	6585                	lui	a1,0x1
ffffffffc0202144:	9d1ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0202148:	5a050763          	beqz	a0,ffffffffc02026f6 <pmm_init+0x82a>
ffffffffc020214c:	6118                	ld	a4,0(a0)
ffffffffc020214e:	00177793          	andi	a5,a4,1
ffffffffc0202152:	4c078363          	beqz	a5,ffffffffc0202618 <pmm_init+0x74c>
ffffffffc0202156:	6094                	ld	a3,0(s1)
ffffffffc0202158:	00271793          	slli	a5,a4,0x2
ffffffffc020215c:	83b1                	srli	a5,a5,0xc
ffffffffc020215e:	44d7f363          	bgeu	a5,a3,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc0202162:	000b3683          	ld	a3,0(s6)
ffffffffc0202166:	fff80637          	lui	a2,0xfff80
ffffffffc020216a:	97b2                	add	a5,a5,a2
ffffffffc020216c:	079a                	slli	a5,a5,0x6
ffffffffc020216e:	97b6                	add	a5,a5,a3
ffffffffc0202170:	6efa1363          	bne	s4,a5,ffffffffc0202856 <pmm_init+0x98a>
ffffffffc0202174:	8b41                	andi	a4,a4,16
ffffffffc0202176:	6c071063          	bnez	a4,ffffffffc0202836 <pmm_init+0x96a>
ffffffffc020217a:	00093503          	ld	a0,0(s2)
ffffffffc020217e:	4581                	li	a1,0
ffffffffc0202180:	bbbff0ef          	jal	ra,ffffffffc0201d3a <page_remove>
ffffffffc0202184:	000a2703          	lw	a4,0(s4)
ffffffffc0202188:	4785                	li	a5,1
ffffffffc020218a:	68f71663          	bne	a4,a5,ffffffffc0202816 <pmm_init+0x94a>
ffffffffc020218e:	000aa783          	lw	a5,0(s5)
ffffffffc0202192:	74079e63          	bnez	a5,ffffffffc02028ee <pmm_init+0xa22>
ffffffffc0202196:	00093503          	ld	a0,0(s2)
ffffffffc020219a:	6585                	lui	a1,0x1
ffffffffc020219c:	b9fff0ef          	jal	ra,ffffffffc0201d3a <page_remove>
ffffffffc02021a0:	000a2783          	lw	a5,0(s4)
ffffffffc02021a4:	72079563          	bnez	a5,ffffffffc02028ce <pmm_init+0xa02>
ffffffffc02021a8:	000aa783          	lw	a5,0(s5)
ffffffffc02021ac:	70079163          	bnez	a5,ffffffffc02028ae <pmm_init+0x9e2>
ffffffffc02021b0:	00093a03          	ld	s4,0(s2)
ffffffffc02021b4:	6098                	ld	a4,0(s1)
ffffffffc02021b6:	000a3683          	ld	a3,0(s4)
ffffffffc02021ba:	068a                	slli	a3,a3,0x2
ffffffffc02021bc:	82b1                	srli	a3,a3,0xc
ffffffffc02021be:	3ee6f363          	bgeu	a3,a4,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc02021c2:	fff807b7          	lui	a5,0xfff80
ffffffffc02021c6:	000b3503          	ld	a0,0(s6)
ffffffffc02021ca:	96be                	add	a3,a3,a5
ffffffffc02021cc:	069a                	slli	a3,a3,0x6
ffffffffc02021ce:	00d507b3          	add	a5,a0,a3
ffffffffc02021d2:	4390                	lw	a2,0(a5)
ffffffffc02021d4:	4785                	li	a5,1
ffffffffc02021d6:	6af61c63          	bne	a2,a5,ffffffffc020288e <pmm_init+0x9c2>
ffffffffc02021da:	8699                	srai	a3,a3,0x6
ffffffffc02021dc:	000805b7          	lui	a1,0x80
ffffffffc02021e0:	96ae                	add	a3,a3,a1
ffffffffc02021e2:	00c69613          	slli	a2,a3,0xc
ffffffffc02021e6:	8231                	srli	a2,a2,0xc
ffffffffc02021e8:	06b2                	slli	a3,a3,0xc
ffffffffc02021ea:	68e67663          	bgeu	a2,a4,ffffffffc0202876 <pmm_init+0x9aa>
ffffffffc02021ee:	0009b603          	ld	a2,0(s3)
ffffffffc02021f2:	96b2                	add	a3,a3,a2
ffffffffc02021f4:	629c                	ld	a5,0(a3)
ffffffffc02021f6:	078a                	slli	a5,a5,0x2
ffffffffc02021f8:	83b1                	srli	a5,a5,0xc
ffffffffc02021fa:	3ae7f563          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc02021fe:	8f8d                	sub	a5,a5,a1
ffffffffc0202200:	079a                	slli	a5,a5,0x6
ffffffffc0202202:	953e                	add	a0,a0,a5
ffffffffc0202204:	100027f3          	csrr	a5,sstatus
ffffffffc0202208:	8b89                	andi	a5,a5,2
ffffffffc020220a:	2c079763          	bnez	a5,ffffffffc02024d8 <pmm_init+0x60c>
ffffffffc020220e:	000bb783          	ld	a5,0(s7)
ffffffffc0202212:	4585                	li	a1,1
ffffffffc0202214:	739c                	ld	a5,32(a5)
ffffffffc0202216:	9782                	jalr	a5
ffffffffc0202218:	000a3783          	ld	a5,0(s4)
ffffffffc020221c:	6098                	ld	a4,0(s1)
ffffffffc020221e:	078a                	slli	a5,a5,0x2
ffffffffc0202220:	83b1                	srli	a5,a5,0xc
ffffffffc0202222:	38e7f163          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc0202226:	000b3503          	ld	a0,0(s6)
ffffffffc020222a:	fff80737          	lui	a4,0xfff80
ffffffffc020222e:	97ba                	add	a5,a5,a4
ffffffffc0202230:	079a                	slli	a5,a5,0x6
ffffffffc0202232:	953e                	add	a0,a0,a5
ffffffffc0202234:	100027f3          	csrr	a5,sstatus
ffffffffc0202238:	8b89                	andi	a5,a5,2
ffffffffc020223a:	28079363          	bnez	a5,ffffffffc02024c0 <pmm_init+0x5f4>
ffffffffc020223e:	000bb783          	ld	a5,0(s7)
ffffffffc0202242:	4585                	li	a1,1
ffffffffc0202244:	739c                	ld	a5,32(a5)
ffffffffc0202246:	9782                	jalr	a5
ffffffffc0202248:	00093783          	ld	a5,0(s2)
ffffffffc020224c:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6aa3c>
ffffffffc0202250:	12000073          	sfence.vma
ffffffffc0202254:	100027f3          	csrr	a5,sstatus
ffffffffc0202258:	8b89                	andi	a5,a5,2
ffffffffc020225a:	24079963          	bnez	a5,ffffffffc02024ac <pmm_init+0x5e0>
ffffffffc020225e:	000bb783          	ld	a5,0(s7)
ffffffffc0202262:	779c                	ld	a5,40(a5)
ffffffffc0202264:	9782                	jalr	a5
ffffffffc0202266:	8a2a                	mv	s4,a0
ffffffffc0202268:	71441363          	bne	s0,s4,ffffffffc020296e <pmm_init+0xaa2>
ffffffffc020226c:	00004517          	auipc	a0,0x4
ffffffffc0202270:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0205c68 <default_pmm_manager+0x4b8>
ffffffffc0202274:	f0dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202278:	100027f3          	csrr	a5,sstatus
ffffffffc020227c:	8b89                	andi	a5,a5,2
ffffffffc020227e:	20079d63          	bnez	a5,ffffffffc0202498 <pmm_init+0x5cc>
ffffffffc0202282:	000bb783          	ld	a5,0(s7)
ffffffffc0202286:	779c                	ld	a5,40(a5)
ffffffffc0202288:	9782                	jalr	a5
ffffffffc020228a:	8c2a                	mv	s8,a0
ffffffffc020228c:	6098                	ld	a4,0(s1)
ffffffffc020228e:	c0200437          	lui	s0,0xc0200
ffffffffc0202292:	7afd                	lui	s5,0xfffff
ffffffffc0202294:	00c71793          	slli	a5,a4,0xc
ffffffffc0202298:	6a05                	lui	s4,0x1
ffffffffc020229a:	02f47c63          	bgeu	s0,a5,ffffffffc02022d2 <pmm_init+0x406>
ffffffffc020229e:	00c45793          	srli	a5,s0,0xc
ffffffffc02022a2:	00093503          	ld	a0,0(s2)
ffffffffc02022a6:	2ee7f263          	bgeu	a5,a4,ffffffffc020258a <pmm_init+0x6be>
ffffffffc02022aa:	0009b583          	ld	a1,0(s3)
ffffffffc02022ae:	4601                	li	a2,0
ffffffffc02022b0:	95a2                	add	a1,a1,s0
ffffffffc02022b2:	863ff0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc02022b6:	2a050a63          	beqz	a0,ffffffffc020256a <pmm_init+0x69e>
ffffffffc02022ba:	611c                	ld	a5,0(a0)
ffffffffc02022bc:	078a                	slli	a5,a5,0x2
ffffffffc02022be:	0157f7b3          	and	a5,a5,s5
ffffffffc02022c2:	28879463          	bne	a5,s0,ffffffffc020254a <pmm_init+0x67e>
ffffffffc02022c6:	6098                	ld	a4,0(s1)
ffffffffc02022c8:	9452                	add	s0,s0,s4
ffffffffc02022ca:	00c71793          	slli	a5,a4,0xc
ffffffffc02022ce:	fcf468e3          	bltu	s0,a5,ffffffffc020229e <pmm_init+0x3d2>
ffffffffc02022d2:	00093783          	ld	a5,0(s2)
ffffffffc02022d6:	639c                	ld	a5,0(a5)
ffffffffc02022d8:	66079b63          	bnez	a5,ffffffffc020294e <pmm_init+0xa82>
ffffffffc02022dc:	4505                	li	a0,1
ffffffffc02022de:	f2aff0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc02022e2:	8aaa                	mv	s5,a0
ffffffffc02022e4:	00093503          	ld	a0,0(s2)
ffffffffc02022e8:	4699                	li	a3,6
ffffffffc02022ea:	10000613          	li	a2,256
ffffffffc02022ee:	85d6                	mv	a1,s5
ffffffffc02022f0:	ae7ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc02022f4:	62051d63          	bnez	a0,ffffffffc020292e <pmm_init+0xa62>
ffffffffc02022f8:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a3c>
ffffffffc02022fc:	4785                	li	a5,1
ffffffffc02022fe:	60f71863          	bne	a4,a5,ffffffffc020290e <pmm_init+0xa42>
ffffffffc0202302:	00093503          	ld	a0,0(s2)
ffffffffc0202306:	6405                	lui	s0,0x1
ffffffffc0202308:	4699                	li	a3,6
ffffffffc020230a:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc020230e:	85d6                	mv	a1,s5
ffffffffc0202310:	ac7ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc0202314:	46051163          	bnez	a0,ffffffffc0202776 <pmm_init+0x8aa>
ffffffffc0202318:	000aa703          	lw	a4,0(s5)
ffffffffc020231c:	4789                	li	a5,2
ffffffffc020231e:	72f71463          	bne	a4,a5,ffffffffc0202a46 <pmm_init+0xb7a>
ffffffffc0202322:	00004597          	auipc	a1,0x4
ffffffffc0202326:	a7e58593          	addi	a1,a1,-1410 # ffffffffc0205da0 <default_pmm_manager+0x5f0>
ffffffffc020232a:	10000513          	li	a0,256
ffffffffc020232e:	69c020ef          	jal	ra,ffffffffc02049ca <strcpy>
ffffffffc0202332:	10040593          	addi	a1,s0,256
ffffffffc0202336:	10000513          	li	a0,256
ffffffffc020233a:	6a2020ef          	jal	ra,ffffffffc02049dc <strcmp>
ffffffffc020233e:	6e051463          	bnez	a0,ffffffffc0202a26 <pmm_init+0xb5a>
ffffffffc0202342:	000b3683          	ld	a3,0(s6)
ffffffffc0202346:	00080737          	lui	a4,0x80
ffffffffc020234a:	547d                	li	s0,-1
ffffffffc020234c:	40da86b3          	sub	a3,s5,a3
ffffffffc0202350:	8699                	srai	a3,a3,0x6
ffffffffc0202352:	609c                	ld	a5,0(s1)
ffffffffc0202354:	96ba                	add	a3,a3,a4
ffffffffc0202356:	8031                	srli	s0,s0,0xc
ffffffffc0202358:	0086f733          	and	a4,a3,s0
ffffffffc020235c:	06b2                	slli	a3,a3,0xc
ffffffffc020235e:	50f77c63          	bgeu	a4,a5,ffffffffc0202876 <pmm_init+0x9aa>
ffffffffc0202362:	0009b783          	ld	a5,0(s3)
ffffffffc0202366:	10000513          	li	a0,256
ffffffffc020236a:	96be                	add	a3,a3,a5
ffffffffc020236c:	10068023          	sb	zero,256(a3)
ffffffffc0202370:	624020ef          	jal	ra,ffffffffc0204994 <strlen>
ffffffffc0202374:	68051963          	bnez	a0,ffffffffc0202a06 <pmm_init+0xb3a>
ffffffffc0202378:	00093a03          	ld	s4,0(s2)
ffffffffc020237c:	609c                	ld	a5,0(s1)
ffffffffc020237e:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202382:	068a                	slli	a3,a3,0x2
ffffffffc0202384:	82b1                	srli	a3,a3,0xc
ffffffffc0202386:	20f6ff63          	bgeu	a3,a5,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc020238a:	8c75                	and	s0,s0,a3
ffffffffc020238c:	06b2                	slli	a3,a3,0xc
ffffffffc020238e:	4ef47463          	bgeu	s0,a5,ffffffffc0202876 <pmm_init+0x9aa>
ffffffffc0202392:	0009b403          	ld	s0,0(s3)
ffffffffc0202396:	9436                	add	s0,s0,a3
ffffffffc0202398:	100027f3          	csrr	a5,sstatus
ffffffffc020239c:	8b89                	andi	a5,a5,2
ffffffffc020239e:	18079b63          	bnez	a5,ffffffffc0202534 <pmm_init+0x668>
ffffffffc02023a2:	000bb783          	ld	a5,0(s7)
ffffffffc02023a6:	4585                	li	a1,1
ffffffffc02023a8:	8556                	mv	a0,s5
ffffffffc02023aa:	739c                	ld	a5,32(a5)
ffffffffc02023ac:	9782                	jalr	a5
ffffffffc02023ae:	601c                	ld	a5,0(s0)
ffffffffc02023b0:	6098                	ld	a4,0(s1)
ffffffffc02023b2:	078a                	slli	a5,a5,0x2
ffffffffc02023b4:	83b1                	srli	a5,a5,0xc
ffffffffc02023b6:	1ee7f763          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc02023ba:	000b3503          	ld	a0,0(s6)
ffffffffc02023be:	fff80737          	lui	a4,0xfff80
ffffffffc02023c2:	97ba                	add	a5,a5,a4
ffffffffc02023c4:	079a                	slli	a5,a5,0x6
ffffffffc02023c6:	953e                	add	a0,a0,a5
ffffffffc02023c8:	100027f3          	csrr	a5,sstatus
ffffffffc02023cc:	8b89                	andi	a5,a5,2
ffffffffc02023ce:	14079763          	bnez	a5,ffffffffc020251c <pmm_init+0x650>
ffffffffc02023d2:	000bb783          	ld	a5,0(s7)
ffffffffc02023d6:	4585                	li	a1,1
ffffffffc02023d8:	739c                	ld	a5,32(a5)
ffffffffc02023da:	9782                	jalr	a5
ffffffffc02023dc:	000a3783          	ld	a5,0(s4)
ffffffffc02023e0:	6098                	ld	a4,0(s1)
ffffffffc02023e2:	078a                	slli	a5,a5,0x2
ffffffffc02023e4:	83b1                	srli	a5,a5,0xc
ffffffffc02023e6:	1ae7ff63          	bgeu	a5,a4,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc02023ea:	000b3503          	ld	a0,0(s6)
ffffffffc02023ee:	fff80737          	lui	a4,0xfff80
ffffffffc02023f2:	97ba                	add	a5,a5,a4
ffffffffc02023f4:	079a                	slli	a5,a5,0x6
ffffffffc02023f6:	953e                	add	a0,a0,a5
ffffffffc02023f8:	100027f3          	csrr	a5,sstatus
ffffffffc02023fc:	8b89                	andi	a5,a5,2
ffffffffc02023fe:	10079363          	bnez	a5,ffffffffc0202504 <pmm_init+0x638>
ffffffffc0202402:	000bb783          	ld	a5,0(s7)
ffffffffc0202406:	4585                	li	a1,1
ffffffffc0202408:	739c                	ld	a5,32(a5)
ffffffffc020240a:	9782                	jalr	a5
ffffffffc020240c:	00093783          	ld	a5,0(s2)
ffffffffc0202410:	0007b023          	sd	zero,0(a5)
ffffffffc0202414:	12000073          	sfence.vma
ffffffffc0202418:	100027f3          	csrr	a5,sstatus
ffffffffc020241c:	8b89                	andi	a5,a5,2
ffffffffc020241e:	0c079963          	bnez	a5,ffffffffc02024f0 <pmm_init+0x624>
ffffffffc0202422:	000bb783          	ld	a5,0(s7)
ffffffffc0202426:	779c                	ld	a5,40(a5)
ffffffffc0202428:	9782                	jalr	a5
ffffffffc020242a:	842a                	mv	s0,a0
ffffffffc020242c:	3a8c1563          	bne	s8,s0,ffffffffc02027d6 <pmm_init+0x90a>
ffffffffc0202430:	00004517          	auipc	a0,0x4
ffffffffc0202434:	9e850513          	addi	a0,a0,-1560 # ffffffffc0205e18 <default_pmm_manager+0x668>
ffffffffc0202438:	d49fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020243c:	6446                	ld	s0,80(sp)
ffffffffc020243e:	60e6                	ld	ra,88(sp)
ffffffffc0202440:	64a6                	ld	s1,72(sp)
ffffffffc0202442:	6906                	ld	s2,64(sp)
ffffffffc0202444:	79e2                	ld	s3,56(sp)
ffffffffc0202446:	7a42                	ld	s4,48(sp)
ffffffffc0202448:	7aa2                	ld	s5,40(sp)
ffffffffc020244a:	7b02                	ld	s6,32(sp)
ffffffffc020244c:	6be2                	ld	s7,24(sp)
ffffffffc020244e:	6c42                	ld	s8,16(sp)
ffffffffc0202450:	6125                	addi	sp,sp,96
ffffffffc0202452:	bb8ff06f          	j	ffffffffc020180a <kmalloc_init>
ffffffffc0202456:	6785                	lui	a5,0x1
ffffffffc0202458:	17fd                	addi	a5,a5,-1
ffffffffc020245a:	96be                	add	a3,a3,a5
ffffffffc020245c:	77fd                	lui	a5,0xfffff
ffffffffc020245e:	8ff5                	and	a5,a5,a3
ffffffffc0202460:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202464:	14c6f063          	bgeu	a3,a2,ffffffffc02025a4 <pmm_init+0x6d8>
ffffffffc0202468:	000bb603          	ld	a2,0(s7)
ffffffffc020246c:	96c2                	add	a3,a3,a6
ffffffffc020246e:	40f707b3          	sub	a5,a4,a5
ffffffffc0202472:	6a10                	ld	a2,16(a2)
ffffffffc0202474:	069a                	slli	a3,a3,0x6
ffffffffc0202476:	00c7d593          	srli	a1,a5,0xc
ffffffffc020247a:	9536                	add	a0,a0,a3
ffffffffc020247c:	9602                	jalr	a2
ffffffffc020247e:	0009b583          	ld	a1,0(s3)
ffffffffc0202482:	b63d                	j	ffffffffc0201fb0 <pmm_init+0xe4>
ffffffffc0202484:	91afe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0202488:	000bb783          	ld	a5,0(s7)
ffffffffc020248c:	779c                	ld	a5,40(a5)
ffffffffc020248e:	9782                	jalr	a5
ffffffffc0202490:	842a                	mv	s0,a0
ffffffffc0202492:	906fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202496:	bea5                	j	ffffffffc020200e <pmm_init+0x142>
ffffffffc0202498:	906fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020249c:	000bb783          	ld	a5,0(s7)
ffffffffc02024a0:	779c                	ld	a5,40(a5)
ffffffffc02024a2:	9782                	jalr	a5
ffffffffc02024a4:	8c2a                	mv	s8,a0
ffffffffc02024a6:	8f2fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024aa:	b3cd                	j	ffffffffc020228c <pmm_init+0x3c0>
ffffffffc02024ac:	8f2fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02024b0:	000bb783          	ld	a5,0(s7)
ffffffffc02024b4:	779c                	ld	a5,40(a5)
ffffffffc02024b6:	9782                	jalr	a5
ffffffffc02024b8:	8a2a                	mv	s4,a0
ffffffffc02024ba:	8defe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024be:	b36d                	j	ffffffffc0202268 <pmm_init+0x39c>
ffffffffc02024c0:	e42a                	sd	a0,8(sp)
ffffffffc02024c2:	8dcfe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02024c6:	000bb783          	ld	a5,0(s7)
ffffffffc02024ca:	6522                	ld	a0,8(sp)
ffffffffc02024cc:	4585                	li	a1,1
ffffffffc02024ce:	739c                	ld	a5,32(a5)
ffffffffc02024d0:	9782                	jalr	a5
ffffffffc02024d2:	8c6fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024d6:	bb8d                	j	ffffffffc0202248 <pmm_init+0x37c>
ffffffffc02024d8:	e42a                	sd	a0,8(sp)
ffffffffc02024da:	8c4fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02024de:	000bb783          	ld	a5,0(s7)
ffffffffc02024e2:	6522                	ld	a0,8(sp)
ffffffffc02024e4:	4585                	li	a1,1
ffffffffc02024e6:	739c                	ld	a5,32(a5)
ffffffffc02024e8:	9782                	jalr	a5
ffffffffc02024ea:	8aefe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc02024ee:	b32d                	j	ffffffffc0202218 <pmm_init+0x34c>
ffffffffc02024f0:	8aefe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc02024f4:	000bb783          	ld	a5,0(s7)
ffffffffc02024f8:	779c                	ld	a5,40(a5)
ffffffffc02024fa:	9782                	jalr	a5
ffffffffc02024fc:	842a                	mv	s0,a0
ffffffffc02024fe:	89afe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202502:	b72d                	j	ffffffffc020242c <pmm_init+0x560>
ffffffffc0202504:	e42a                	sd	a0,8(sp)
ffffffffc0202506:	898fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020250a:	000bb783          	ld	a5,0(s7)
ffffffffc020250e:	6522                	ld	a0,8(sp)
ffffffffc0202510:	4585                	li	a1,1
ffffffffc0202512:	739c                	ld	a5,32(a5)
ffffffffc0202514:	9782                	jalr	a5
ffffffffc0202516:	882fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc020251a:	bdcd                	j	ffffffffc020240c <pmm_init+0x540>
ffffffffc020251c:	e42a                	sd	a0,8(sp)
ffffffffc020251e:	880fe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0202522:	000bb783          	ld	a5,0(s7)
ffffffffc0202526:	6522                	ld	a0,8(sp)
ffffffffc0202528:	4585                	li	a1,1
ffffffffc020252a:	739c                	ld	a5,32(a5)
ffffffffc020252c:	9782                	jalr	a5
ffffffffc020252e:	86afe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202532:	b56d                	j	ffffffffc02023dc <pmm_init+0x510>
ffffffffc0202534:	86afe0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0202538:	000bb783          	ld	a5,0(s7)
ffffffffc020253c:	4585                	li	a1,1
ffffffffc020253e:	8556                	mv	a0,s5
ffffffffc0202540:	739c                	ld	a5,32(a5)
ffffffffc0202542:	9782                	jalr	a5
ffffffffc0202544:	854fe0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202548:	b59d                	j	ffffffffc02023ae <pmm_init+0x4e2>
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	77e68693          	addi	a3,a3,1918 # ffffffffc0205cc8 <default_pmm_manager+0x518>
ffffffffc0202552:	00003617          	auipc	a2,0x3
ffffffffc0202556:	eae60613          	addi	a2,a2,-338 # ffffffffc0205400 <commands+0x738>
ffffffffc020255a:	19e00593          	li	a1,414
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	3a250513          	addi	a0,a0,930 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202566:	ee1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020256a:	00003697          	auipc	a3,0x3
ffffffffc020256e:	71e68693          	addi	a3,a3,1822 # ffffffffc0205c88 <default_pmm_manager+0x4d8>
ffffffffc0202572:	00003617          	auipc	a2,0x3
ffffffffc0202576:	e8e60613          	addi	a2,a2,-370 # ffffffffc0205400 <commands+0x738>
ffffffffc020257a:	19d00593          	li	a1,413
ffffffffc020257e:	00003517          	auipc	a0,0x3
ffffffffc0202582:	38250513          	addi	a0,a0,898 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202586:	ec1fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020258a:	86a2                	mv	a3,s0
ffffffffc020258c:	00003617          	auipc	a2,0x3
ffffffffc0202590:	25c60613          	addi	a2,a2,604 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0202594:	19d00593          	li	a1,413
ffffffffc0202598:	00003517          	auipc	a0,0x3
ffffffffc020259c:	36850513          	addi	a0,a0,872 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02025a0:	ea7fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025a4:	c2cff0ef          	jal	ra,ffffffffc02019d0 <pa2page.part.0>
ffffffffc02025a8:	00003617          	auipc	a2,0x3
ffffffffc02025ac:	2e860613          	addi	a2,a2,744 # ffffffffc0205890 <default_pmm_manager+0xe0>
ffffffffc02025b0:	07f00593          	li	a1,127
ffffffffc02025b4:	00003517          	auipc	a0,0x3
ffffffffc02025b8:	34c50513          	addi	a0,a0,844 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02025bc:	e8bfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025c0:	00003617          	auipc	a2,0x3
ffffffffc02025c4:	2d060613          	addi	a2,a2,720 # ffffffffc0205890 <default_pmm_manager+0xe0>
ffffffffc02025c8:	0c300593          	li	a1,195
ffffffffc02025cc:	00003517          	auipc	a0,0x3
ffffffffc02025d0:	33450513          	addi	a0,a0,820 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02025d4:	e73fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025d8:	00003697          	auipc	a3,0x3
ffffffffc02025dc:	3e868693          	addi	a3,a3,1000 # ffffffffc02059c0 <default_pmm_manager+0x210>
ffffffffc02025e0:	00003617          	auipc	a2,0x3
ffffffffc02025e4:	e2060613          	addi	a2,a2,-480 # ffffffffc0205400 <commands+0x738>
ffffffffc02025e8:	16100593          	li	a1,353
ffffffffc02025ec:	00003517          	auipc	a0,0x3
ffffffffc02025f0:	31450513          	addi	a0,a0,788 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02025f4:	e53fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02025f8:	00003697          	auipc	a3,0x3
ffffffffc02025fc:	3a868693          	addi	a3,a3,936 # ffffffffc02059a0 <default_pmm_manager+0x1f0>
ffffffffc0202600:	00003617          	auipc	a2,0x3
ffffffffc0202604:	e0060613          	addi	a2,a2,-512 # ffffffffc0205400 <commands+0x738>
ffffffffc0202608:	16000593          	li	a1,352
ffffffffc020260c:	00003517          	auipc	a0,0x3
ffffffffc0202610:	2f450513          	addi	a0,a0,756 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202614:	e33fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202618:	bd4ff0ef          	jal	ra,ffffffffc02019ec <pte2page.part.0>
ffffffffc020261c:	00003697          	auipc	a3,0x3
ffffffffc0202620:	43468693          	addi	a3,a3,1076 # ffffffffc0205a50 <default_pmm_manager+0x2a0>
ffffffffc0202624:	00003617          	auipc	a2,0x3
ffffffffc0202628:	ddc60613          	addi	a2,a2,-548 # ffffffffc0205400 <commands+0x738>
ffffffffc020262c:	16900593          	li	a1,361
ffffffffc0202630:	00003517          	auipc	a0,0x3
ffffffffc0202634:	2d050513          	addi	a0,a0,720 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202638:	e0ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020263c:	00003697          	auipc	a3,0x3
ffffffffc0202640:	3e468693          	addi	a3,a3,996 # ffffffffc0205a20 <default_pmm_manager+0x270>
ffffffffc0202644:	00003617          	auipc	a2,0x3
ffffffffc0202648:	dbc60613          	addi	a2,a2,-580 # ffffffffc0205400 <commands+0x738>
ffffffffc020264c:	16600593          	li	a1,358
ffffffffc0202650:	00003517          	auipc	a0,0x3
ffffffffc0202654:	2b050513          	addi	a0,a0,688 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202658:	deffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020265c:	00003697          	auipc	a3,0x3
ffffffffc0202660:	39c68693          	addi	a3,a3,924 # ffffffffc02059f8 <default_pmm_manager+0x248>
ffffffffc0202664:	00003617          	auipc	a2,0x3
ffffffffc0202668:	d9c60613          	addi	a2,a2,-612 # ffffffffc0205400 <commands+0x738>
ffffffffc020266c:	16200593          	li	a1,354
ffffffffc0202670:	00003517          	auipc	a0,0x3
ffffffffc0202674:	29050513          	addi	a0,a0,656 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202678:	dcffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020267c:	00003697          	auipc	a3,0x3
ffffffffc0202680:	45c68693          	addi	a3,a3,1116 # ffffffffc0205ad8 <default_pmm_manager+0x328>
ffffffffc0202684:	00003617          	auipc	a2,0x3
ffffffffc0202688:	d7c60613          	addi	a2,a2,-644 # ffffffffc0205400 <commands+0x738>
ffffffffc020268c:	17200593          	li	a1,370
ffffffffc0202690:	00003517          	auipc	a0,0x3
ffffffffc0202694:	27050513          	addi	a0,a0,624 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202698:	daffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020269c:	00003697          	auipc	a3,0x3
ffffffffc02026a0:	4dc68693          	addi	a3,a3,1244 # ffffffffc0205b78 <default_pmm_manager+0x3c8>
ffffffffc02026a4:	00003617          	auipc	a2,0x3
ffffffffc02026a8:	d5c60613          	addi	a2,a2,-676 # ffffffffc0205400 <commands+0x738>
ffffffffc02026ac:	17700593          	li	a1,375
ffffffffc02026b0:	00003517          	auipc	a0,0x3
ffffffffc02026b4:	25050513          	addi	a0,a0,592 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02026b8:	d8ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02026bc:	00003697          	auipc	a3,0x3
ffffffffc02026c0:	3f468693          	addi	a3,a3,1012 # ffffffffc0205ab0 <default_pmm_manager+0x300>
ffffffffc02026c4:	00003617          	auipc	a2,0x3
ffffffffc02026c8:	d3c60613          	addi	a2,a2,-708 # ffffffffc0205400 <commands+0x738>
ffffffffc02026cc:	16f00593          	li	a1,367
ffffffffc02026d0:	00003517          	auipc	a0,0x3
ffffffffc02026d4:	23050513          	addi	a0,a0,560 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02026d8:	d6ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02026dc:	86d6                	mv	a3,s5
ffffffffc02026de:	00003617          	auipc	a2,0x3
ffffffffc02026e2:	10a60613          	addi	a2,a2,266 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc02026e6:	16e00593          	li	a1,366
ffffffffc02026ea:	00003517          	auipc	a0,0x3
ffffffffc02026ee:	21650513          	addi	a0,a0,534 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02026f2:	d55fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02026f6:	00003697          	auipc	a3,0x3
ffffffffc02026fa:	41a68693          	addi	a3,a3,1050 # ffffffffc0205b10 <default_pmm_manager+0x360>
ffffffffc02026fe:	00003617          	auipc	a2,0x3
ffffffffc0202702:	d0260613          	addi	a2,a2,-766 # ffffffffc0205400 <commands+0x738>
ffffffffc0202706:	17c00593          	li	a1,380
ffffffffc020270a:	00003517          	auipc	a0,0x3
ffffffffc020270e:	1f650513          	addi	a0,a0,502 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202712:	d35fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202716:	00003697          	auipc	a3,0x3
ffffffffc020271a:	4c268693          	addi	a3,a3,1218 # ffffffffc0205bd8 <default_pmm_manager+0x428>
ffffffffc020271e:	00003617          	auipc	a2,0x3
ffffffffc0202722:	ce260613          	addi	a2,a2,-798 # ffffffffc0205400 <commands+0x738>
ffffffffc0202726:	17b00593          	li	a1,379
ffffffffc020272a:	00003517          	auipc	a0,0x3
ffffffffc020272e:	1d650513          	addi	a0,a0,470 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202732:	d15fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202736:	00003697          	auipc	a3,0x3
ffffffffc020273a:	48a68693          	addi	a3,a3,1162 # ffffffffc0205bc0 <default_pmm_manager+0x410>
ffffffffc020273e:	00003617          	auipc	a2,0x3
ffffffffc0202742:	cc260613          	addi	a2,a2,-830 # ffffffffc0205400 <commands+0x738>
ffffffffc0202746:	17a00593          	li	a1,378
ffffffffc020274a:	00003517          	auipc	a0,0x3
ffffffffc020274e:	1b650513          	addi	a0,a0,438 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202752:	cf5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202756:	00003697          	auipc	a3,0x3
ffffffffc020275a:	43a68693          	addi	a3,a3,1082 # ffffffffc0205b90 <default_pmm_manager+0x3e0>
ffffffffc020275e:	00003617          	auipc	a2,0x3
ffffffffc0202762:	ca260613          	addi	a2,a2,-862 # ffffffffc0205400 <commands+0x738>
ffffffffc0202766:	17900593          	li	a1,377
ffffffffc020276a:	00003517          	auipc	a0,0x3
ffffffffc020276e:	19650513          	addi	a0,a0,406 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202772:	cd5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202776:	00003697          	auipc	a3,0x3
ffffffffc020277a:	5d268693          	addi	a3,a3,1490 # ffffffffc0205d48 <default_pmm_manager+0x598>
ffffffffc020277e:	00003617          	auipc	a2,0x3
ffffffffc0202782:	c8260613          	addi	a2,a2,-894 # ffffffffc0205400 <commands+0x738>
ffffffffc0202786:	1a700593          	li	a1,423
ffffffffc020278a:	00003517          	auipc	a0,0x3
ffffffffc020278e:	17650513          	addi	a0,a0,374 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202792:	cb5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202796:	00003697          	auipc	a3,0x3
ffffffffc020279a:	3ca68693          	addi	a3,a3,970 # ffffffffc0205b60 <default_pmm_manager+0x3b0>
ffffffffc020279e:	00003617          	auipc	a2,0x3
ffffffffc02027a2:	c6260613          	addi	a2,a2,-926 # ffffffffc0205400 <commands+0x738>
ffffffffc02027a6:	17600593          	li	a1,374
ffffffffc02027aa:	00003517          	auipc	a0,0x3
ffffffffc02027ae:	15650513          	addi	a0,a0,342 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02027b2:	c95fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02027b6:	00003697          	auipc	a3,0x3
ffffffffc02027ba:	39a68693          	addi	a3,a3,922 # ffffffffc0205b50 <default_pmm_manager+0x3a0>
ffffffffc02027be:	00003617          	auipc	a2,0x3
ffffffffc02027c2:	c4260613          	addi	a2,a2,-958 # ffffffffc0205400 <commands+0x738>
ffffffffc02027c6:	17500593          	li	a1,373
ffffffffc02027ca:	00003517          	auipc	a0,0x3
ffffffffc02027ce:	13650513          	addi	a0,a0,310 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02027d2:	c75fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02027d6:	00003697          	auipc	a3,0x3
ffffffffc02027da:	47268693          	addi	a3,a3,1138 # ffffffffc0205c48 <default_pmm_manager+0x498>
ffffffffc02027de:	00003617          	auipc	a2,0x3
ffffffffc02027e2:	c2260613          	addi	a2,a2,-990 # ffffffffc0205400 <commands+0x738>
ffffffffc02027e6:	1b800593          	li	a1,440
ffffffffc02027ea:	00003517          	auipc	a0,0x3
ffffffffc02027ee:	11650513          	addi	a0,a0,278 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02027f2:	c55fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02027f6:	00003697          	auipc	a3,0x3
ffffffffc02027fa:	34a68693          	addi	a3,a3,842 # ffffffffc0205b40 <default_pmm_manager+0x390>
ffffffffc02027fe:	00003617          	auipc	a2,0x3
ffffffffc0202802:	c0260613          	addi	a2,a2,-1022 # ffffffffc0205400 <commands+0x738>
ffffffffc0202806:	17400593          	li	a1,372
ffffffffc020280a:	00003517          	auipc	a0,0x3
ffffffffc020280e:	0f650513          	addi	a0,a0,246 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202812:	c35fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202816:	00003697          	auipc	a3,0x3
ffffffffc020281a:	28268693          	addi	a3,a3,642 # ffffffffc0205a98 <default_pmm_manager+0x2e8>
ffffffffc020281e:	00003617          	auipc	a2,0x3
ffffffffc0202822:	be260613          	addi	a2,a2,-1054 # ffffffffc0205400 <commands+0x738>
ffffffffc0202826:	18100593          	li	a1,385
ffffffffc020282a:	00003517          	auipc	a0,0x3
ffffffffc020282e:	0d650513          	addi	a0,a0,214 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202832:	c15fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202836:	00003697          	auipc	a3,0x3
ffffffffc020283a:	3ba68693          	addi	a3,a3,954 # ffffffffc0205bf0 <default_pmm_manager+0x440>
ffffffffc020283e:	00003617          	auipc	a2,0x3
ffffffffc0202842:	bc260613          	addi	a2,a2,-1086 # ffffffffc0205400 <commands+0x738>
ffffffffc0202846:	17e00593          	li	a1,382
ffffffffc020284a:	00003517          	auipc	a0,0x3
ffffffffc020284e:	0b650513          	addi	a0,a0,182 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202852:	bf5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202856:	00003697          	auipc	a3,0x3
ffffffffc020285a:	22a68693          	addi	a3,a3,554 # ffffffffc0205a80 <default_pmm_manager+0x2d0>
ffffffffc020285e:	00003617          	auipc	a2,0x3
ffffffffc0202862:	ba260613          	addi	a2,a2,-1118 # ffffffffc0205400 <commands+0x738>
ffffffffc0202866:	17d00593          	li	a1,381
ffffffffc020286a:	00003517          	auipc	a0,0x3
ffffffffc020286e:	09650513          	addi	a0,a0,150 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202872:	bd5fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202876:	00003617          	auipc	a2,0x3
ffffffffc020287a:	f7260613          	addi	a2,a2,-142 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc020287e:	06900593          	li	a1,105
ffffffffc0202882:	00003517          	auipc	a0,0x3
ffffffffc0202886:	f8e50513          	addi	a0,a0,-114 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc020288a:	bbdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020288e:	00003697          	auipc	a3,0x3
ffffffffc0202892:	39268693          	addi	a3,a3,914 # ffffffffc0205c20 <default_pmm_manager+0x470>
ffffffffc0202896:	00003617          	auipc	a2,0x3
ffffffffc020289a:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0205400 <commands+0x738>
ffffffffc020289e:	18800593          	li	a1,392
ffffffffc02028a2:	00003517          	auipc	a0,0x3
ffffffffc02028a6:	05e50513          	addi	a0,a0,94 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02028aa:	b9dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02028ae:	00003697          	auipc	a3,0x3
ffffffffc02028b2:	32a68693          	addi	a3,a3,810 # ffffffffc0205bd8 <default_pmm_manager+0x428>
ffffffffc02028b6:	00003617          	auipc	a2,0x3
ffffffffc02028ba:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0205400 <commands+0x738>
ffffffffc02028be:	18600593          	li	a1,390
ffffffffc02028c2:	00003517          	auipc	a0,0x3
ffffffffc02028c6:	03e50513          	addi	a0,a0,62 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02028ca:	b7dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02028ce:	00003697          	auipc	a3,0x3
ffffffffc02028d2:	33a68693          	addi	a3,a3,826 # ffffffffc0205c08 <default_pmm_manager+0x458>
ffffffffc02028d6:	00003617          	auipc	a2,0x3
ffffffffc02028da:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0205400 <commands+0x738>
ffffffffc02028de:	18500593          	li	a1,389
ffffffffc02028e2:	00003517          	auipc	a0,0x3
ffffffffc02028e6:	01e50513          	addi	a0,a0,30 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02028ea:	b5dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02028ee:	00003697          	auipc	a3,0x3
ffffffffc02028f2:	2ea68693          	addi	a3,a3,746 # ffffffffc0205bd8 <default_pmm_manager+0x428>
ffffffffc02028f6:	00003617          	auipc	a2,0x3
ffffffffc02028fa:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0205400 <commands+0x738>
ffffffffc02028fe:	18200593          	li	a1,386
ffffffffc0202902:	00003517          	auipc	a0,0x3
ffffffffc0202906:	ffe50513          	addi	a0,a0,-2 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc020290a:	b3dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020290e:	00003697          	auipc	a3,0x3
ffffffffc0202912:	42268693          	addi	a3,a3,1058 # ffffffffc0205d30 <default_pmm_manager+0x580>
ffffffffc0202916:	00003617          	auipc	a2,0x3
ffffffffc020291a:	aea60613          	addi	a2,a2,-1302 # ffffffffc0205400 <commands+0x738>
ffffffffc020291e:	1a600593          	li	a1,422
ffffffffc0202922:	00003517          	auipc	a0,0x3
ffffffffc0202926:	fde50513          	addi	a0,a0,-34 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc020292a:	b1dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020292e:	00003697          	auipc	a3,0x3
ffffffffc0202932:	3ca68693          	addi	a3,a3,970 # ffffffffc0205cf8 <default_pmm_manager+0x548>
ffffffffc0202936:	00003617          	auipc	a2,0x3
ffffffffc020293a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0205400 <commands+0x738>
ffffffffc020293e:	1a500593          	li	a1,421
ffffffffc0202942:	00003517          	auipc	a0,0x3
ffffffffc0202946:	fbe50513          	addi	a0,a0,-66 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc020294a:	afdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020294e:	00003697          	auipc	a3,0x3
ffffffffc0202952:	39268693          	addi	a3,a3,914 # ffffffffc0205ce0 <default_pmm_manager+0x530>
ffffffffc0202956:	00003617          	auipc	a2,0x3
ffffffffc020295a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0205400 <commands+0x738>
ffffffffc020295e:	1a100593          	li	a1,417
ffffffffc0202962:	00003517          	auipc	a0,0x3
ffffffffc0202966:	f9e50513          	addi	a0,a0,-98 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc020296a:	addfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020296e:	00003697          	auipc	a3,0x3
ffffffffc0202972:	2da68693          	addi	a3,a3,730 # ffffffffc0205c48 <default_pmm_manager+0x498>
ffffffffc0202976:	00003617          	auipc	a2,0x3
ffffffffc020297a:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0205400 <commands+0x738>
ffffffffc020297e:	19000593          	li	a1,400
ffffffffc0202982:	00003517          	auipc	a0,0x3
ffffffffc0202986:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc020298a:	abdfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020298e:	00003697          	auipc	a3,0x3
ffffffffc0202992:	0f268693          	addi	a3,a3,242 # ffffffffc0205a80 <default_pmm_manager+0x2d0>
ffffffffc0202996:	00003617          	auipc	a2,0x3
ffffffffc020299a:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0205400 <commands+0x738>
ffffffffc020299e:	16a00593          	li	a1,362
ffffffffc02029a2:	00003517          	auipc	a0,0x3
ffffffffc02029a6:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02029aa:	a9dfd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02029ae:	00003617          	auipc	a2,0x3
ffffffffc02029b2:	e3a60613          	addi	a2,a2,-454 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc02029b6:	16d00593          	li	a1,365
ffffffffc02029ba:	00003517          	auipc	a0,0x3
ffffffffc02029be:	f4650513          	addi	a0,a0,-186 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02029c2:	a85fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02029c6:	00003697          	auipc	a3,0x3
ffffffffc02029ca:	0d268693          	addi	a3,a3,210 # ffffffffc0205a98 <default_pmm_manager+0x2e8>
ffffffffc02029ce:	00003617          	auipc	a2,0x3
ffffffffc02029d2:	a3260613          	addi	a2,a2,-1486 # ffffffffc0205400 <commands+0x738>
ffffffffc02029d6:	16b00593          	li	a1,363
ffffffffc02029da:	00003517          	auipc	a0,0x3
ffffffffc02029de:	f2650513          	addi	a0,a0,-218 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc02029e2:	a65fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02029e6:	00003697          	auipc	a3,0x3
ffffffffc02029ea:	12a68693          	addi	a3,a3,298 # ffffffffc0205b10 <default_pmm_manager+0x360>
ffffffffc02029ee:	00003617          	auipc	a2,0x3
ffffffffc02029f2:	a1260613          	addi	a2,a2,-1518 # ffffffffc0205400 <commands+0x738>
ffffffffc02029f6:	17300593          	li	a1,371
ffffffffc02029fa:	00003517          	auipc	a0,0x3
ffffffffc02029fe:	f0650513          	addi	a0,a0,-250 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202a02:	a45fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202a06:	00003697          	auipc	a3,0x3
ffffffffc0202a0a:	3ea68693          	addi	a3,a3,1002 # ffffffffc0205df0 <default_pmm_manager+0x640>
ffffffffc0202a0e:	00003617          	auipc	a2,0x3
ffffffffc0202a12:	9f260613          	addi	a2,a2,-1550 # ffffffffc0205400 <commands+0x738>
ffffffffc0202a16:	1af00593          	li	a1,431
ffffffffc0202a1a:	00003517          	auipc	a0,0x3
ffffffffc0202a1e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202a22:	a25fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202a26:	00003697          	auipc	a3,0x3
ffffffffc0202a2a:	39268693          	addi	a3,a3,914 # ffffffffc0205db8 <default_pmm_manager+0x608>
ffffffffc0202a2e:	00003617          	auipc	a2,0x3
ffffffffc0202a32:	9d260613          	addi	a2,a2,-1582 # ffffffffc0205400 <commands+0x738>
ffffffffc0202a36:	1ac00593          	li	a1,428
ffffffffc0202a3a:	00003517          	auipc	a0,0x3
ffffffffc0202a3e:	ec650513          	addi	a0,a0,-314 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202a42:	a05fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202a46:	00003697          	auipc	a3,0x3
ffffffffc0202a4a:	34268693          	addi	a3,a3,834 # ffffffffc0205d88 <default_pmm_manager+0x5d8>
ffffffffc0202a4e:	00003617          	auipc	a2,0x3
ffffffffc0202a52:	9b260613          	addi	a2,a2,-1614 # ffffffffc0205400 <commands+0x738>
ffffffffc0202a56:	1a800593          	li	a1,424
ffffffffc0202a5a:	00003517          	auipc	a0,0x3
ffffffffc0202a5e:	ea650513          	addi	a0,a0,-346 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202a62:	9e5fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202a66 <tlb_invalidate>:
ffffffffc0202a66:	12058073          	sfence.vma	a1
ffffffffc0202a6a:	8082                	ret

ffffffffc0202a6c <pgdir_alloc_page>:
ffffffffc0202a6c:	7179                	addi	sp,sp,-48
ffffffffc0202a6e:	e84a                	sd	s2,16(sp)
ffffffffc0202a70:	892a                	mv	s2,a0
ffffffffc0202a72:	4505                	li	a0,1
ffffffffc0202a74:	f022                	sd	s0,32(sp)
ffffffffc0202a76:	ec26                	sd	s1,24(sp)
ffffffffc0202a78:	e44e                	sd	s3,8(sp)
ffffffffc0202a7a:	f406                	sd	ra,40(sp)
ffffffffc0202a7c:	84ae                	mv	s1,a1
ffffffffc0202a7e:	89b2                	mv	s3,a2
ffffffffc0202a80:	f89fe0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0202a84:	842a                	mv	s0,a0
ffffffffc0202a86:	cd09                	beqz	a0,ffffffffc0202aa0 <pgdir_alloc_page+0x34>
ffffffffc0202a88:	85aa                	mv	a1,a0
ffffffffc0202a8a:	86ce                	mv	a3,s3
ffffffffc0202a8c:	8626                	mv	a2,s1
ffffffffc0202a8e:	854a                	mv	a0,s2
ffffffffc0202a90:	b46ff0ef          	jal	ra,ffffffffc0201dd6 <page_insert>
ffffffffc0202a94:	ed21                	bnez	a0,ffffffffc0202aec <pgdir_alloc_page+0x80>
ffffffffc0202a96:	00013797          	auipc	a5,0x13
ffffffffc0202a9a:	afa7a783          	lw	a5,-1286(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0202a9e:	eb89                	bnez	a5,ffffffffc0202ab0 <pgdir_alloc_page+0x44>
ffffffffc0202aa0:	70a2                	ld	ra,40(sp)
ffffffffc0202aa2:	8522                	mv	a0,s0
ffffffffc0202aa4:	7402                	ld	s0,32(sp)
ffffffffc0202aa6:	64e2                	ld	s1,24(sp)
ffffffffc0202aa8:	6942                	ld	s2,16(sp)
ffffffffc0202aaa:	69a2                	ld	s3,8(sp)
ffffffffc0202aac:	6145                	addi	sp,sp,48
ffffffffc0202aae:	8082                	ret
ffffffffc0202ab0:	4681                	li	a3,0
ffffffffc0202ab2:	8622                	mv	a2,s0
ffffffffc0202ab4:	85a6                	mv	a1,s1
ffffffffc0202ab6:	00013517          	auipc	a0,0x13
ffffffffc0202aba:	ae253503          	ld	a0,-1310(a0) # ffffffffc0215598 <check_mm_struct>
ffffffffc0202abe:	7c8000ef          	jal	ra,ffffffffc0203286 <swap_map_swappable>
ffffffffc0202ac2:	4018                	lw	a4,0(s0)
ffffffffc0202ac4:	fc04                	sd	s1,56(s0)
ffffffffc0202ac6:	4785                	li	a5,1
ffffffffc0202ac8:	fcf70ce3          	beq	a4,a5,ffffffffc0202aa0 <pgdir_alloc_page+0x34>
ffffffffc0202acc:	00003697          	auipc	a3,0x3
ffffffffc0202ad0:	36c68693          	addi	a3,a3,876 # ffffffffc0205e38 <default_pmm_manager+0x688>
ffffffffc0202ad4:	00003617          	auipc	a2,0x3
ffffffffc0202ad8:	92c60613          	addi	a2,a2,-1748 # ffffffffc0205400 <commands+0x738>
ffffffffc0202adc:	14800593          	li	a1,328
ffffffffc0202ae0:	00003517          	auipc	a0,0x3
ffffffffc0202ae4:	e2050513          	addi	a0,a0,-480 # ffffffffc0205900 <default_pmm_manager+0x150>
ffffffffc0202ae8:	95ffd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202aec:	100027f3          	csrr	a5,sstatus
ffffffffc0202af0:	8b89                	andi	a5,a5,2
ffffffffc0202af2:	eb99                	bnez	a5,ffffffffc0202b08 <pgdir_alloc_page+0x9c>
ffffffffc0202af4:	00013797          	auipc	a5,0x13
ffffffffc0202af8:	a7c7b783          	ld	a5,-1412(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0202afc:	739c                	ld	a5,32(a5)
ffffffffc0202afe:	8522                	mv	a0,s0
ffffffffc0202b00:	4585                	li	a1,1
ffffffffc0202b02:	9782                	jalr	a5
ffffffffc0202b04:	4401                	li	s0,0
ffffffffc0202b06:	bf69                	j	ffffffffc0202aa0 <pgdir_alloc_page+0x34>
ffffffffc0202b08:	a97fd0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc0202b0c:	00013797          	auipc	a5,0x13
ffffffffc0202b10:	a647b783          	ld	a5,-1436(a5) # ffffffffc0215570 <pmm_manager>
ffffffffc0202b14:	739c                	ld	a5,32(a5)
ffffffffc0202b16:	8522                	mv	a0,s0
ffffffffc0202b18:	4585                	li	a1,1
ffffffffc0202b1a:	9782                	jalr	a5
ffffffffc0202b1c:	4401                	li	s0,0
ffffffffc0202b1e:	a7bfd0ef          	jal	ra,ffffffffc0200598 <intr_enable>
ffffffffc0202b22:	bfbd                	j	ffffffffc0202aa0 <pgdir_alloc_page+0x34>

ffffffffc0202b24 <pa2page.part.0>:
ffffffffc0202b24:	1141                	addi	sp,sp,-16
ffffffffc0202b26:	00003617          	auipc	a2,0x3
ffffffffc0202b2a:	d9260613          	addi	a2,a2,-622 # ffffffffc02058b8 <default_pmm_manager+0x108>
ffffffffc0202b2e:	06200593          	li	a1,98
ffffffffc0202b32:	00003517          	auipc	a0,0x3
ffffffffc0202b36:	cde50513          	addi	a0,a0,-802 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0202b3a:	e406                	sd	ra,8(sp)
ffffffffc0202b3c:	90bfd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0202b40 <swap_init>:
ffffffffc0202b40:	7135                	addi	sp,sp,-160
ffffffffc0202b42:	ed06                	sd	ra,152(sp)
ffffffffc0202b44:	e922                	sd	s0,144(sp)
ffffffffc0202b46:	e526                	sd	s1,136(sp)
ffffffffc0202b48:	e14a                	sd	s2,128(sp)
ffffffffc0202b4a:	fcce                	sd	s3,120(sp)
ffffffffc0202b4c:	f8d2                	sd	s4,112(sp)
ffffffffc0202b4e:	f4d6                	sd	s5,104(sp)
ffffffffc0202b50:	f0da                	sd	s6,96(sp)
ffffffffc0202b52:	ecde                	sd	s7,88(sp)
ffffffffc0202b54:	e8e2                	sd	s8,80(sp)
ffffffffc0202b56:	e4e6                	sd	s9,72(sp)
ffffffffc0202b58:	e0ea                	sd	s10,64(sp)
ffffffffc0202b5a:	fc6e                	sd	s11,56(sp)
ffffffffc0202b5c:	4a0010ef          	jal	ra,ffffffffc0203ffc <swapfs_init>
ffffffffc0202b60:	00013697          	auipc	a3,0x13
ffffffffc0202b64:	a206b683          	ld	a3,-1504(a3) # ffffffffc0215580 <max_swap_offset>
ffffffffc0202b68:	010007b7          	lui	a5,0x1000
ffffffffc0202b6c:	ff968713          	addi	a4,a3,-7
ffffffffc0202b70:	17e1                	addi	a5,a5,-8
ffffffffc0202b72:	42e7e063          	bltu	a5,a4,ffffffffc0202f92 <swap_init+0x452>
ffffffffc0202b76:	00007797          	auipc	a5,0x7
ffffffffc0202b7a:	49a78793          	addi	a5,a5,1178 # ffffffffc020a010 <swap_manager_fifo>
ffffffffc0202b7e:	6798                	ld	a4,8(a5)
ffffffffc0202b80:	00013b97          	auipc	s7,0x13
ffffffffc0202b84:	a08b8b93          	addi	s7,s7,-1528 # ffffffffc0215588 <sm>
ffffffffc0202b88:	00fbb023          	sd	a5,0(s7)
ffffffffc0202b8c:	9702                	jalr	a4
ffffffffc0202b8e:	892a                	mv	s2,a0
ffffffffc0202b90:	c10d                	beqz	a0,ffffffffc0202bb2 <swap_init+0x72>
ffffffffc0202b92:	60ea                	ld	ra,152(sp)
ffffffffc0202b94:	644a                	ld	s0,144(sp)
ffffffffc0202b96:	64aa                	ld	s1,136(sp)
ffffffffc0202b98:	79e6                	ld	s3,120(sp)
ffffffffc0202b9a:	7a46                	ld	s4,112(sp)
ffffffffc0202b9c:	7aa6                	ld	s5,104(sp)
ffffffffc0202b9e:	7b06                	ld	s6,96(sp)
ffffffffc0202ba0:	6be6                	ld	s7,88(sp)
ffffffffc0202ba2:	6c46                	ld	s8,80(sp)
ffffffffc0202ba4:	6ca6                	ld	s9,72(sp)
ffffffffc0202ba6:	6d06                	ld	s10,64(sp)
ffffffffc0202ba8:	7de2                	ld	s11,56(sp)
ffffffffc0202baa:	854a                	mv	a0,s2
ffffffffc0202bac:	690a                	ld	s2,128(sp)
ffffffffc0202bae:	610d                	addi	sp,sp,160
ffffffffc0202bb0:	8082                	ret
ffffffffc0202bb2:	000bb783          	ld	a5,0(s7)
ffffffffc0202bb6:	00003517          	auipc	a0,0x3
ffffffffc0202bba:	2ca50513          	addi	a0,a0,714 # ffffffffc0205e80 <default_pmm_manager+0x6d0>
ffffffffc0202bbe:	0000f417          	auipc	s0,0xf
ffffffffc0202bc2:	89a40413          	addi	s0,s0,-1894 # ffffffffc0211458 <free_area>
ffffffffc0202bc6:	638c                	ld	a1,0(a5)
ffffffffc0202bc8:	4785                	li	a5,1
ffffffffc0202bca:	00013717          	auipc	a4,0x13
ffffffffc0202bce:	9cf72323          	sw	a5,-1594(a4) # ffffffffc0215590 <swap_init_ok>
ffffffffc0202bd2:	daefd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202bd6:	641c                	ld	a5,8(s0)
ffffffffc0202bd8:	4d01                	li	s10,0
ffffffffc0202bda:	4d81                	li	s11,0
ffffffffc0202bdc:	32878b63          	beq	a5,s0,ffffffffc0202f12 <swap_init+0x3d2>
ffffffffc0202be0:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202be4:	8b09                	andi	a4,a4,2
ffffffffc0202be6:	32070863          	beqz	a4,ffffffffc0202f16 <swap_init+0x3d6>
ffffffffc0202bea:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bee:	679c                	ld	a5,8(a5)
ffffffffc0202bf0:	2d85                	addiw	s11,s11,1
ffffffffc0202bf2:	01a70d3b          	addw	s10,a4,s10
ffffffffc0202bf6:	fe8795e3          	bne	a5,s0,ffffffffc0202be0 <swap_init+0xa0>
ffffffffc0202bfa:	84ea                	mv	s1,s10
ffffffffc0202bfc:	edffe0ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0202c00:	42951163          	bne	a0,s1,ffffffffc0203022 <swap_init+0x4e2>
ffffffffc0202c04:	866a                	mv	a2,s10
ffffffffc0202c06:	85ee                	mv	a1,s11
ffffffffc0202c08:	00003517          	auipc	a0,0x3
ffffffffc0202c0c:	29050513          	addi	a0,a0,656 # ffffffffc0205e98 <default_pmm_manager+0x6e8>
ffffffffc0202c10:	d70fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202c14:	3a5000ef          	jal	ra,ffffffffc02037b8 <mm_create>
ffffffffc0202c18:	8aaa                	mv	s5,a0
ffffffffc0202c1a:	46050463          	beqz	a0,ffffffffc0203082 <swap_init+0x542>
ffffffffc0202c1e:	00013797          	auipc	a5,0x13
ffffffffc0202c22:	97a78793          	addi	a5,a5,-1670 # ffffffffc0215598 <check_mm_struct>
ffffffffc0202c26:	6398                	ld	a4,0(a5)
ffffffffc0202c28:	3c071d63          	bnez	a4,ffffffffc0203002 <swap_init+0x4c2>
ffffffffc0202c2c:	00013717          	auipc	a4,0x13
ffffffffc0202c30:	92c70713          	addi	a4,a4,-1748 # ffffffffc0215558 <boot_pgdir>
ffffffffc0202c34:	00073b03          	ld	s6,0(a4)
ffffffffc0202c38:	e388                	sd	a0,0(a5)
ffffffffc0202c3a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c3e:	01653c23          	sd	s6,24(a0)
ffffffffc0202c42:	42079063          	bnez	a5,ffffffffc0203062 <swap_init+0x522>
ffffffffc0202c46:	6599                	lui	a1,0x6
ffffffffc0202c48:	460d                	li	a2,3
ffffffffc0202c4a:	6505                	lui	a0,0x1
ffffffffc0202c4c:	3b5000ef          	jal	ra,ffffffffc0203800 <vma_create>
ffffffffc0202c50:	85aa                	mv	a1,a0
ffffffffc0202c52:	52050463          	beqz	a0,ffffffffc020317a <swap_init+0x63a>
ffffffffc0202c56:	8556                	mv	a0,s5
ffffffffc0202c58:	417000ef          	jal	ra,ffffffffc020386e <insert_vma_struct>
ffffffffc0202c5c:	00003517          	auipc	a0,0x3
ffffffffc0202c60:	2ac50513          	addi	a0,a0,684 # ffffffffc0205f08 <default_pmm_manager+0x758>
ffffffffc0202c64:	d1cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202c68:	018ab503          	ld	a0,24(s5)
ffffffffc0202c6c:	4605                	li	a2,1
ffffffffc0202c6e:	6585                	lui	a1,0x1
ffffffffc0202c70:	ea5fe0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0202c74:	4c050363          	beqz	a0,ffffffffc020313a <swap_init+0x5fa>
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	2e050513          	addi	a0,a0,736 # ffffffffc0205f58 <default_pmm_manager+0x7a8>
ffffffffc0202c80:	0000f497          	auipc	s1,0xf
ffffffffc0202c84:	81048493          	addi	s1,s1,-2032 # ffffffffc0211490 <check_rp>
ffffffffc0202c88:	cf8fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202c8c:	0000f997          	auipc	s3,0xf
ffffffffc0202c90:	82498993          	addi	s3,s3,-2012 # ffffffffc02114b0 <swap_in_seq_no>
ffffffffc0202c94:	8a26                	mv	s4,s1
ffffffffc0202c96:	4505                	li	a0,1
ffffffffc0202c98:	d71fe0ef          	jal	ra,ffffffffc0201a08 <alloc_pages>
ffffffffc0202c9c:	00aa3023          	sd	a0,0(s4)
ffffffffc0202ca0:	2c050963          	beqz	a0,ffffffffc0202f72 <swap_init+0x432>
ffffffffc0202ca4:	651c                	ld	a5,8(a0)
ffffffffc0202ca6:	8b89                	andi	a5,a5,2
ffffffffc0202ca8:	32079d63          	bnez	a5,ffffffffc0202fe2 <swap_init+0x4a2>
ffffffffc0202cac:	0a21                	addi	s4,s4,8
ffffffffc0202cae:	ff3a14e3          	bne	s4,s3,ffffffffc0202c96 <swap_init+0x156>
ffffffffc0202cb2:	601c                	ld	a5,0(s0)
ffffffffc0202cb4:	0000ea17          	auipc	s4,0xe
ffffffffc0202cb8:	7dca0a13          	addi	s4,s4,2012 # ffffffffc0211490 <check_rp>
ffffffffc0202cbc:	e000                	sd	s0,0(s0)
ffffffffc0202cbe:	ec3e                	sd	a5,24(sp)
ffffffffc0202cc0:	641c                	ld	a5,8(s0)
ffffffffc0202cc2:	e400                	sd	s0,8(s0)
ffffffffc0202cc4:	f03e                	sd	a5,32(sp)
ffffffffc0202cc6:	481c                	lw	a5,16(s0)
ffffffffc0202cc8:	f43e                	sd	a5,40(sp)
ffffffffc0202cca:	0000e797          	auipc	a5,0xe
ffffffffc0202cce:	7807af23          	sw	zero,1950(a5) # ffffffffc0211468 <free_area+0x10>
ffffffffc0202cd2:	000a3503          	ld	a0,0(s4)
ffffffffc0202cd6:	4585                	li	a1,1
ffffffffc0202cd8:	0a21                	addi	s4,s4,8
ffffffffc0202cda:	dc1fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0202cde:	ff3a1ae3          	bne	s4,s3,ffffffffc0202cd2 <swap_init+0x192>
ffffffffc0202ce2:	01042a03          	lw	s4,16(s0)
ffffffffc0202ce6:	4791                	li	a5,4
ffffffffc0202ce8:	42fa1963          	bne	s4,a5,ffffffffc020311a <swap_init+0x5da>
ffffffffc0202cec:	00003517          	auipc	a0,0x3
ffffffffc0202cf0:	2f450513          	addi	a0,a0,756 # ffffffffc0205fe0 <default_pmm_manager+0x830>
ffffffffc0202cf4:	c8cfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202cf8:	6705                	lui	a4,0x1
ffffffffc0202cfa:	00013797          	auipc	a5,0x13
ffffffffc0202cfe:	8a07a323          	sw	zero,-1882(a5) # ffffffffc02155a0 <pgfault_num>
ffffffffc0202d02:	4629                	li	a2,10
ffffffffc0202d04:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202d08:	00013697          	auipc	a3,0x13
ffffffffc0202d0c:	8986a683          	lw	a3,-1896(a3) # ffffffffc02155a0 <pgfault_num>
ffffffffc0202d10:	4585                	li	a1,1
ffffffffc0202d12:	00013797          	auipc	a5,0x13
ffffffffc0202d16:	88e78793          	addi	a5,a5,-1906 # ffffffffc02155a0 <pgfault_num>
ffffffffc0202d1a:	54b69063          	bne	a3,a1,ffffffffc020325a <swap_init+0x71a>
ffffffffc0202d1e:	00c70823          	sb	a2,16(a4)
ffffffffc0202d22:	4398                	lw	a4,0(a5)
ffffffffc0202d24:	2701                	sext.w	a4,a4
ffffffffc0202d26:	3cd71a63          	bne	a4,a3,ffffffffc02030fa <swap_init+0x5ba>
ffffffffc0202d2a:	6689                	lui	a3,0x2
ffffffffc0202d2c:	462d                	li	a2,11
ffffffffc0202d2e:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0202d32:	4398                	lw	a4,0(a5)
ffffffffc0202d34:	4589                	li	a1,2
ffffffffc0202d36:	2701                	sext.w	a4,a4
ffffffffc0202d38:	4ab71163          	bne	a4,a1,ffffffffc02031da <swap_init+0x69a>
ffffffffc0202d3c:	00c68823          	sb	a2,16(a3)
ffffffffc0202d40:	4394                	lw	a3,0(a5)
ffffffffc0202d42:	2681                	sext.w	a3,a3
ffffffffc0202d44:	4ae69b63          	bne	a3,a4,ffffffffc02031fa <swap_init+0x6ba>
ffffffffc0202d48:	668d                	lui	a3,0x3
ffffffffc0202d4a:	4631                	li	a2,12
ffffffffc0202d4c:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc0202d50:	4398                	lw	a4,0(a5)
ffffffffc0202d52:	458d                	li	a1,3
ffffffffc0202d54:	2701                	sext.w	a4,a4
ffffffffc0202d56:	4cb71263          	bne	a4,a1,ffffffffc020321a <swap_init+0x6da>
ffffffffc0202d5a:	00c68823          	sb	a2,16(a3)
ffffffffc0202d5e:	4394                	lw	a3,0(a5)
ffffffffc0202d60:	2681                	sext.w	a3,a3
ffffffffc0202d62:	4ce69c63          	bne	a3,a4,ffffffffc020323a <swap_init+0x6fa>
ffffffffc0202d66:	6691                	lui	a3,0x4
ffffffffc0202d68:	4635                	li	a2,13
ffffffffc0202d6a:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0202d6e:	4398                	lw	a4,0(a5)
ffffffffc0202d70:	2701                	sext.w	a4,a4
ffffffffc0202d72:	43471463          	bne	a4,s4,ffffffffc020319a <swap_init+0x65a>
ffffffffc0202d76:	00c68823          	sb	a2,16(a3)
ffffffffc0202d7a:	439c                	lw	a5,0(a5)
ffffffffc0202d7c:	2781                	sext.w	a5,a5
ffffffffc0202d7e:	42e79e63          	bne	a5,a4,ffffffffc02031ba <swap_init+0x67a>
ffffffffc0202d82:	481c                	lw	a5,16(s0)
ffffffffc0202d84:	2a079f63          	bnez	a5,ffffffffc0203042 <swap_init+0x502>
ffffffffc0202d88:	0000e797          	auipc	a5,0xe
ffffffffc0202d8c:	72878793          	addi	a5,a5,1832 # ffffffffc02114b0 <swap_in_seq_no>
ffffffffc0202d90:	0000e717          	auipc	a4,0xe
ffffffffc0202d94:	74870713          	addi	a4,a4,1864 # ffffffffc02114d8 <swap_out_seq_no>
ffffffffc0202d98:	0000e617          	auipc	a2,0xe
ffffffffc0202d9c:	74060613          	addi	a2,a2,1856 # ffffffffc02114d8 <swap_out_seq_no>
ffffffffc0202da0:	56fd                	li	a3,-1
ffffffffc0202da2:	c394                	sw	a3,0(a5)
ffffffffc0202da4:	c314                	sw	a3,0(a4)
ffffffffc0202da6:	0791                	addi	a5,a5,4
ffffffffc0202da8:	0711                	addi	a4,a4,4
ffffffffc0202daa:	fec79ce3          	bne	a5,a2,ffffffffc0202da2 <swap_init+0x262>
ffffffffc0202dae:	0000e717          	auipc	a4,0xe
ffffffffc0202db2:	6c270713          	addi	a4,a4,1730 # ffffffffc0211470 <check_ptep>
ffffffffc0202db6:	0000e697          	auipc	a3,0xe
ffffffffc0202dba:	6da68693          	addi	a3,a3,1754 # ffffffffc0211490 <check_rp>
ffffffffc0202dbe:	6585                	lui	a1,0x1
ffffffffc0202dc0:	00012c17          	auipc	s8,0x12
ffffffffc0202dc4:	7a0c0c13          	addi	s8,s8,1952 # ffffffffc0215560 <npage>
ffffffffc0202dc8:	00012c97          	auipc	s9,0x12
ffffffffc0202dcc:	7a0c8c93          	addi	s9,s9,1952 # ffffffffc0215568 <pages>
ffffffffc0202dd0:	00073023          	sd	zero,0(a4)
ffffffffc0202dd4:	4601                	li	a2,0
ffffffffc0202dd6:	855a                	mv	a0,s6
ffffffffc0202dd8:	e836                	sd	a3,16(sp)
ffffffffc0202dda:	e42e                	sd	a1,8(sp)
ffffffffc0202ddc:	e03a                	sd	a4,0(sp)
ffffffffc0202dde:	d37fe0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0202de2:	6702                	ld	a4,0(sp)
ffffffffc0202de4:	65a2                	ld	a1,8(sp)
ffffffffc0202de6:	66c2                	ld	a3,16(sp)
ffffffffc0202de8:	e308                	sd	a0,0(a4)
ffffffffc0202dea:	1c050063          	beqz	a0,ffffffffc0202faa <swap_init+0x46a>
ffffffffc0202dee:	611c                	ld	a5,0(a0)
ffffffffc0202df0:	0017f613          	andi	a2,a5,1
ffffffffc0202df4:	1c060b63          	beqz	a2,ffffffffc0202fca <swap_init+0x48a>
ffffffffc0202df8:	000c3603          	ld	a2,0(s8)
ffffffffc0202dfc:	078a                	slli	a5,a5,0x2
ffffffffc0202dfe:	83b1                	srli	a5,a5,0xc
ffffffffc0202e00:	12c7fd63          	bgeu	a5,a2,ffffffffc0202f3a <swap_init+0x3fa>
ffffffffc0202e04:	00004617          	auipc	a2,0x4
ffffffffc0202e08:	c7c60613          	addi	a2,a2,-900 # ffffffffc0206a80 <nbase>
ffffffffc0202e0c:	00063a03          	ld	s4,0(a2)
ffffffffc0202e10:	000cb603          	ld	a2,0(s9)
ffffffffc0202e14:	6288                	ld	a0,0(a3)
ffffffffc0202e16:	414787b3          	sub	a5,a5,s4
ffffffffc0202e1a:	079a                	slli	a5,a5,0x6
ffffffffc0202e1c:	97b2                	add	a5,a5,a2
ffffffffc0202e1e:	12f51a63          	bne	a0,a5,ffffffffc0202f52 <swap_init+0x412>
ffffffffc0202e22:	6785                	lui	a5,0x1
ffffffffc0202e24:	95be                	add	a1,a1,a5
ffffffffc0202e26:	6795                	lui	a5,0x5
ffffffffc0202e28:	0721                	addi	a4,a4,8
ffffffffc0202e2a:	06a1                	addi	a3,a3,8
ffffffffc0202e2c:	faf592e3          	bne	a1,a5,ffffffffc0202dd0 <swap_init+0x290>
ffffffffc0202e30:	00003517          	auipc	a0,0x3
ffffffffc0202e34:	25850513          	addi	a0,a0,600 # ffffffffc0206088 <default_pmm_manager+0x8d8>
ffffffffc0202e38:	b48fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202e3c:	000bb783          	ld	a5,0(s7)
ffffffffc0202e40:	7f9c                	ld	a5,56(a5)
ffffffffc0202e42:	9782                	jalr	a5
ffffffffc0202e44:	30051b63          	bnez	a0,ffffffffc020315a <swap_init+0x61a>
ffffffffc0202e48:	77a2                	ld	a5,40(sp)
ffffffffc0202e4a:	c81c                	sw	a5,16(s0)
ffffffffc0202e4c:	67e2                	ld	a5,24(sp)
ffffffffc0202e4e:	e01c                	sd	a5,0(s0)
ffffffffc0202e50:	7782                	ld	a5,32(sp)
ffffffffc0202e52:	e41c                	sd	a5,8(s0)
ffffffffc0202e54:	6088                	ld	a0,0(s1)
ffffffffc0202e56:	4585                	li	a1,1
ffffffffc0202e58:	04a1                	addi	s1,s1,8
ffffffffc0202e5a:	c41fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0202e5e:	ff349be3          	bne	s1,s3,ffffffffc0202e54 <swap_init+0x314>
ffffffffc0202e62:	8556                	mv	a0,s5
ffffffffc0202e64:	2db000ef          	jal	ra,ffffffffc020393e <mm_destroy>
ffffffffc0202e68:	00012797          	auipc	a5,0x12
ffffffffc0202e6c:	6f078793          	addi	a5,a5,1776 # ffffffffc0215558 <boot_pgdir>
ffffffffc0202e70:	639c                	ld	a5,0(a5)
ffffffffc0202e72:	000c3703          	ld	a4,0(s8)
ffffffffc0202e76:	639c                	ld	a5,0(a5)
ffffffffc0202e78:	078a                	slli	a5,a5,0x2
ffffffffc0202e7a:	83b1                	srli	a5,a5,0xc
ffffffffc0202e7c:	0ae7fd63          	bgeu	a5,a4,ffffffffc0202f36 <swap_init+0x3f6>
ffffffffc0202e80:	414786b3          	sub	a3,a5,s4
ffffffffc0202e84:	069a                	slli	a3,a3,0x6
ffffffffc0202e86:	8699                	srai	a3,a3,0x6
ffffffffc0202e88:	96d2                	add	a3,a3,s4
ffffffffc0202e8a:	00c69793          	slli	a5,a3,0xc
ffffffffc0202e8e:	83b1                	srli	a5,a5,0xc
ffffffffc0202e90:	000cb503          	ld	a0,0(s9)
ffffffffc0202e94:	06b2                	slli	a3,a3,0xc
ffffffffc0202e96:	22e7f663          	bgeu	a5,a4,ffffffffc02030c2 <swap_init+0x582>
ffffffffc0202e9a:	00012797          	auipc	a5,0x12
ffffffffc0202e9e:	6de7b783          	ld	a5,1758(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0202ea2:	96be                	add	a3,a3,a5
ffffffffc0202ea4:	629c                	ld	a5,0(a3)
ffffffffc0202ea6:	078a                	slli	a5,a5,0x2
ffffffffc0202ea8:	83b1                	srli	a5,a5,0xc
ffffffffc0202eaa:	08e7f663          	bgeu	a5,a4,ffffffffc0202f36 <swap_init+0x3f6>
ffffffffc0202eae:	414787b3          	sub	a5,a5,s4
ffffffffc0202eb2:	079a                	slli	a5,a5,0x6
ffffffffc0202eb4:	953e                	add	a0,a0,a5
ffffffffc0202eb6:	4585                	li	a1,1
ffffffffc0202eb8:	be3fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0202ebc:	000b3783          	ld	a5,0(s6)
ffffffffc0202ec0:	000c3703          	ld	a4,0(s8)
ffffffffc0202ec4:	078a                	slli	a5,a5,0x2
ffffffffc0202ec6:	83b1                	srli	a5,a5,0xc
ffffffffc0202ec8:	06e7f763          	bgeu	a5,a4,ffffffffc0202f36 <swap_init+0x3f6>
ffffffffc0202ecc:	000cb503          	ld	a0,0(s9)
ffffffffc0202ed0:	414787b3          	sub	a5,a5,s4
ffffffffc0202ed4:	079a                	slli	a5,a5,0x6
ffffffffc0202ed6:	4585                	li	a1,1
ffffffffc0202ed8:	953e                	add	a0,a0,a5
ffffffffc0202eda:	bc1fe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0202ede:	000b3023          	sd	zero,0(s6)
ffffffffc0202ee2:	12000073          	sfence.vma
ffffffffc0202ee6:	641c                	ld	a5,8(s0)
ffffffffc0202ee8:	00878a63          	beq	a5,s0,ffffffffc0202efc <swap_init+0x3bc>
ffffffffc0202eec:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ef0:	679c                	ld	a5,8(a5)
ffffffffc0202ef2:	3dfd                	addiw	s11,s11,-1
ffffffffc0202ef4:	40ed0d3b          	subw	s10,s10,a4
ffffffffc0202ef8:	fe879ae3          	bne	a5,s0,ffffffffc0202eec <swap_init+0x3ac>
ffffffffc0202efc:	1c0d9f63          	bnez	s11,ffffffffc02030da <swap_init+0x59a>
ffffffffc0202f00:	1a0d1163          	bnez	s10,ffffffffc02030a2 <swap_init+0x562>
ffffffffc0202f04:	00003517          	auipc	a0,0x3
ffffffffc0202f08:	1d450513          	addi	a0,a0,468 # ffffffffc02060d8 <default_pmm_manager+0x928>
ffffffffc0202f0c:	a74fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202f10:	b149                	j	ffffffffc0202b92 <swap_init+0x52>
ffffffffc0202f12:	4481                	li	s1,0
ffffffffc0202f14:	b1e5                	j	ffffffffc0202bfc <swap_init+0xbc>
ffffffffc0202f16:	00002697          	auipc	a3,0x2
ffffffffc0202f1a:	4da68693          	addi	a3,a3,1242 # ffffffffc02053f0 <commands+0x728>
ffffffffc0202f1e:	00002617          	auipc	a2,0x2
ffffffffc0202f22:	4e260613          	addi	a2,a2,1250 # ffffffffc0205400 <commands+0x738>
ffffffffc0202f26:	0bd00593          	li	a1,189
ffffffffc0202f2a:	00003517          	auipc	a0,0x3
ffffffffc0202f2e:	f4650513          	addi	a0,a0,-186 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0202f32:	d14fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202f36:	befff0ef          	jal	ra,ffffffffc0202b24 <pa2page.part.0>
ffffffffc0202f3a:	00003617          	auipc	a2,0x3
ffffffffc0202f3e:	97e60613          	addi	a2,a2,-1666 # ffffffffc02058b8 <default_pmm_manager+0x108>
ffffffffc0202f42:	06200593          	li	a1,98
ffffffffc0202f46:	00003517          	auipc	a0,0x3
ffffffffc0202f4a:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0202f4e:	cf8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202f52:	00003697          	auipc	a3,0x3
ffffffffc0202f56:	10e68693          	addi	a3,a3,270 # ffffffffc0206060 <default_pmm_manager+0x8b0>
ffffffffc0202f5a:	00002617          	auipc	a2,0x2
ffffffffc0202f5e:	4a660613          	addi	a2,a2,1190 # ffffffffc0205400 <commands+0x738>
ffffffffc0202f62:	0fd00593          	li	a1,253
ffffffffc0202f66:	00003517          	auipc	a0,0x3
ffffffffc0202f6a:	f0a50513          	addi	a0,a0,-246 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0202f6e:	cd8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202f72:	00003697          	auipc	a3,0x3
ffffffffc0202f76:	00e68693          	addi	a3,a3,14 # ffffffffc0205f80 <default_pmm_manager+0x7d0>
ffffffffc0202f7a:	00002617          	auipc	a2,0x2
ffffffffc0202f7e:	48660613          	addi	a2,a2,1158 # ffffffffc0205400 <commands+0x738>
ffffffffc0202f82:	0dd00593          	li	a1,221
ffffffffc0202f86:	00003517          	auipc	a0,0x3
ffffffffc0202f8a:	eea50513          	addi	a0,a0,-278 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0202f8e:	cb8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202f92:	00003617          	auipc	a2,0x3
ffffffffc0202f96:	ebe60613          	addi	a2,a2,-322 # ffffffffc0205e50 <default_pmm_manager+0x6a0>
ffffffffc0202f9a:	02a00593          	li	a1,42
ffffffffc0202f9e:	00003517          	auipc	a0,0x3
ffffffffc0202fa2:	ed250513          	addi	a0,a0,-302 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0202fa6:	ca0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202faa:	00003697          	auipc	a3,0x3
ffffffffc0202fae:	09e68693          	addi	a3,a3,158 # ffffffffc0206048 <default_pmm_manager+0x898>
ffffffffc0202fb2:	00002617          	auipc	a2,0x2
ffffffffc0202fb6:	44e60613          	addi	a2,a2,1102 # ffffffffc0205400 <commands+0x738>
ffffffffc0202fba:	0fc00593          	li	a1,252
ffffffffc0202fbe:	00003517          	auipc	a0,0x3
ffffffffc0202fc2:	eb250513          	addi	a0,a0,-334 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0202fc6:	c80fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202fca:	00003617          	auipc	a2,0x3
ffffffffc0202fce:	90e60613          	addi	a2,a2,-1778 # ffffffffc02058d8 <default_pmm_manager+0x128>
ffffffffc0202fd2:	07400593          	li	a1,116
ffffffffc0202fd6:	00003517          	auipc	a0,0x3
ffffffffc0202fda:	83a50513          	addi	a0,a0,-1990 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0202fde:	c68fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0202fe2:	00003697          	auipc	a3,0x3
ffffffffc0202fe6:	fb668693          	addi	a3,a3,-74 # ffffffffc0205f98 <default_pmm_manager+0x7e8>
ffffffffc0202fea:	00002617          	auipc	a2,0x2
ffffffffc0202fee:	41660613          	addi	a2,a2,1046 # ffffffffc0205400 <commands+0x738>
ffffffffc0202ff2:	0de00593          	li	a1,222
ffffffffc0202ff6:	00003517          	auipc	a0,0x3
ffffffffc0202ffa:	e7a50513          	addi	a0,a0,-390 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0202ffe:	c48fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203002:	00003697          	auipc	a3,0x3
ffffffffc0203006:	ece68693          	addi	a3,a3,-306 # ffffffffc0205ed0 <default_pmm_manager+0x720>
ffffffffc020300a:	00002617          	auipc	a2,0x2
ffffffffc020300e:	3f660613          	addi	a2,a2,1014 # ffffffffc0205400 <commands+0x738>
ffffffffc0203012:	0c800593          	li	a1,200
ffffffffc0203016:	00003517          	auipc	a0,0x3
ffffffffc020301a:	e5a50513          	addi	a0,a0,-422 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc020301e:	c28fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203022:	00002697          	auipc	a3,0x2
ffffffffc0203026:	40e68693          	addi	a3,a3,1038 # ffffffffc0205430 <commands+0x768>
ffffffffc020302a:	00002617          	auipc	a2,0x2
ffffffffc020302e:	3d660613          	addi	a2,a2,982 # ffffffffc0205400 <commands+0x738>
ffffffffc0203032:	0c000593          	li	a1,192
ffffffffc0203036:	00003517          	auipc	a0,0x3
ffffffffc020303a:	e3a50513          	addi	a0,a0,-454 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc020303e:	c08fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203042:	00002697          	auipc	a3,0x2
ffffffffc0203046:	59668693          	addi	a3,a3,1430 # ffffffffc02055d8 <commands+0x910>
ffffffffc020304a:	00002617          	auipc	a2,0x2
ffffffffc020304e:	3b660613          	addi	a2,a2,950 # ffffffffc0205400 <commands+0x738>
ffffffffc0203052:	0f400593          	li	a1,244
ffffffffc0203056:	00003517          	auipc	a0,0x3
ffffffffc020305a:	e1a50513          	addi	a0,a0,-486 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc020305e:	be8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203062:	00003697          	auipc	a3,0x3
ffffffffc0203066:	e8668693          	addi	a3,a3,-378 # ffffffffc0205ee8 <default_pmm_manager+0x738>
ffffffffc020306a:	00002617          	auipc	a2,0x2
ffffffffc020306e:	39660613          	addi	a2,a2,918 # ffffffffc0205400 <commands+0x738>
ffffffffc0203072:	0cd00593          	li	a1,205
ffffffffc0203076:	00003517          	auipc	a0,0x3
ffffffffc020307a:	dfa50513          	addi	a0,a0,-518 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc020307e:	bc8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203082:	00003697          	auipc	a3,0x3
ffffffffc0203086:	e3e68693          	addi	a3,a3,-450 # ffffffffc0205ec0 <default_pmm_manager+0x710>
ffffffffc020308a:	00002617          	auipc	a2,0x2
ffffffffc020308e:	37660613          	addi	a2,a2,886 # ffffffffc0205400 <commands+0x738>
ffffffffc0203092:	0c500593          	li	a1,197
ffffffffc0203096:	00003517          	auipc	a0,0x3
ffffffffc020309a:	dda50513          	addi	a0,a0,-550 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc020309e:	ba8fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02030a2:	00003697          	auipc	a3,0x3
ffffffffc02030a6:	02668693          	addi	a3,a3,38 # ffffffffc02060c8 <default_pmm_manager+0x918>
ffffffffc02030aa:	00002617          	auipc	a2,0x2
ffffffffc02030ae:	35660613          	addi	a2,a2,854 # ffffffffc0205400 <commands+0x738>
ffffffffc02030b2:	11d00593          	li	a1,285
ffffffffc02030b6:	00003517          	auipc	a0,0x3
ffffffffc02030ba:	dba50513          	addi	a0,a0,-582 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc02030be:	b88fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02030c2:	00002617          	auipc	a2,0x2
ffffffffc02030c6:	72660613          	addi	a2,a2,1830 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc02030ca:	06900593          	li	a1,105
ffffffffc02030ce:	00002517          	auipc	a0,0x2
ffffffffc02030d2:	74250513          	addi	a0,a0,1858 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc02030d6:	b70fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02030da:	00003697          	auipc	a3,0x3
ffffffffc02030de:	fde68693          	addi	a3,a3,-34 # ffffffffc02060b8 <default_pmm_manager+0x908>
ffffffffc02030e2:	00002617          	auipc	a2,0x2
ffffffffc02030e6:	31e60613          	addi	a2,a2,798 # ffffffffc0205400 <commands+0x738>
ffffffffc02030ea:	11c00593          	li	a1,284
ffffffffc02030ee:	00003517          	auipc	a0,0x3
ffffffffc02030f2:	d8250513          	addi	a0,a0,-638 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc02030f6:	b50fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02030fa:	00003697          	auipc	a3,0x3
ffffffffc02030fe:	f0e68693          	addi	a3,a3,-242 # ffffffffc0206008 <default_pmm_manager+0x858>
ffffffffc0203102:	00002617          	auipc	a2,0x2
ffffffffc0203106:	2fe60613          	addi	a2,a2,766 # ffffffffc0205400 <commands+0x738>
ffffffffc020310a:	09600593          	li	a1,150
ffffffffc020310e:	00003517          	auipc	a0,0x3
ffffffffc0203112:	d6250513          	addi	a0,a0,-670 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203116:	b30fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020311a:	00003697          	auipc	a3,0x3
ffffffffc020311e:	e9e68693          	addi	a3,a3,-354 # ffffffffc0205fb8 <default_pmm_manager+0x808>
ffffffffc0203122:	00002617          	auipc	a2,0x2
ffffffffc0203126:	2de60613          	addi	a2,a2,734 # ffffffffc0205400 <commands+0x738>
ffffffffc020312a:	0eb00593          	li	a1,235
ffffffffc020312e:	00003517          	auipc	a0,0x3
ffffffffc0203132:	d4250513          	addi	a0,a0,-702 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203136:	b10fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020313a:	00003697          	auipc	a3,0x3
ffffffffc020313e:	e0668693          	addi	a3,a3,-506 # ffffffffc0205f40 <default_pmm_manager+0x790>
ffffffffc0203142:	00002617          	auipc	a2,0x2
ffffffffc0203146:	2be60613          	addi	a2,a2,702 # ffffffffc0205400 <commands+0x738>
ffffffffc020314a:	0d800593          	li	a1,216
ffffffffc020314e:	00003517          	auipc	a0,0x3
ffffffffc0203152:	d2250513          	addi	a0,a0,-734 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203156:	af0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020315a:	00003697          	auipc	a3,0x3
ffffffffc020315e:	f5668693          	addi	a3,a3,-170 # ffffffffc02060b0 <default_pmm_manager+0x900>
ffffffffc0203162:	00002617          	auipc	a2,0x2
ffffffffc0203166:	29e60613          	addi	a2,a2,670 # ffffffffc0205400 <commands+0x738>
ffffffffc020316a:	10300593          	li	a1,259
ffffffffc020316e:	00003517          	auipc	a0,0x3
ffffffffc0203172:	d0250513          	addi	a0,a0,-766 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203176:	ad0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020317a:	00003697          	auipc	a3,0x3
ffffffffc020317e:	d7e68693          	addi	a3,a3,-642 # ffffffffc0205ef8 <default_pmm_manager+0x748>
ffffffffc0203182:	00002617          	auipc	a2,0x2
ffffffffc0203186:	27e60613          	addi	a2,a2,638 # ffffffffc0205400 <commands+0x738>
ffffffffc020318a:	0d000593          	li	a1,208
ffffffffc020318e:	00003517          	auipc	a0,0x3
ffffffffc0203192:	ce250513          	addi	a0,a0,-798 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203196:	ab0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020319a:	00003697          	auipc	a3,0x3
ffffffffc020319e:	e9e68693          	addi	a3,a3,-354 # ffffffffc0206038 <default_pmm_manager+0x888>
ffffffffc02031a2:	00002617          	auipc	a2,0x2
ffffffffc02031a6:	25e60613          	addi	a2,a2,606 # ffffffffc0205400 <commands+0x738>
ffffffffc02031aa:	0a000593          	li	a1,160
ffffffffc02031ae:	00003517          	auipc	a0,0x3
ffffffffc02031b2:	cc250513          	addi	a0,a0,-830 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc02031b6:	a90fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02031ba:	00003697          	auipc	a3,0x3
ffffffffc02031be:	e7e68693          	addi	a3,a3,-386 # ffffffffc0206038 <default_pmm_manager+0x888>
ffffffffc02031c2:	00002617          	auipc	a2,0x2
ffffffffc02031c6:	23e60613          	addi	a2,a2,574 # ffffffffc0205400 <commands+0x738>
ffffffffc02031ca:	0a200593          	li	a1,162
ffffffffc02031ce:	00003517          	auipc	a0,0x3
ffffffffc02031d2:	ca250513          	addi	a0,a0,-862 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc02031d6:	a70fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02031da:	00003697          	auipc	a3,0x3
ffffffffc02031de:	e3e68693          	addi	a3,a3,-450 # ffffffffc0206018 <default_pmm_manager+0x868>
ffffffffc02031e2:	00002617          	auipc	a2,0x2
ffffffffc02031e6:	21e60613          	addi	a2,a2,542 # ffffffffc0205400 <commands+0x738>
ffffffffc02031ea:	09800593          	li	a1,152
ffffffffc02031ee:	00003517          	auipc	a0,0x3
ffffffffc02031f2:	c8250513          	addi	a0,a0,-894 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc02031f6:	a50fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02031fa:	00003697          	auipc	a3,0x3
ffffffffc02031fe:	e1e68693          	addi	a3,a3,-482 # ffffffffc0206018 <default_pmm_manager+0x868>
ffffffffc0203202:	00002617          	auipc	a2,0x2
ffffffffc0203206:	1fe60613          	addi	a2,a2,510 # ffffffffc0205400 <commands+0x738>
ffffffffc020320a:	09a00593          	li	a1,154
ffffffffc020320e:	00003517          	auipc	a0,0x3
ffffffffc0203212:	c6250513          	addi	a0,a0,-926 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203216:	a30fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020321a:	00003697          	auipc	a3,0x3
ffffffffc020321e:	e0e68693          	addi	a3,a3,-498 # ffffffffc0206028 <default_pmm_manager+0x878>
ffffffffc0203222:	00002617          	auipc	a2,0x2
ffffffffc0203226:	1de60613          	addi	a2,a2,478 # ffffffffc0205400 <commands+0x738>
ffffffffc020322a:	09c00593          	li	a1,156
ffffffffc020322e:	00003517          	auipc	a0,0x3
ffffffffc0203232:	c4250513          	addi	a0,a0,-958 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203236:	a10fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020323a:	00003697          	auipc	a3,0x3
ffffffffc020323e:	dee68693          	addi	a3,a3,-530 # ffffffffc0206028 <default_pmm_manager+0x878>
ffffffffc0203242:	00002617          	auipc	a2,0x2
ffffffffc0203246:	1be60613          	addi	a2,a2,446 # ffffffffc0205400 <commands+0x738>
ffffffffc020324a:	09e00593          	li	a1,158
ffffffffc020324e:	00003517          	auipc	a0,0x3
ffffffffc0203252:	c2250513          	addi	a0,a0,-990 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203256:	9f0fd0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020325a:	00003697          	auipc	a3,0x3
ffffffffc020325e:	dae68693          	addi	a3,a3,-594 # ffffffffc0206008 <default_pmm_manager+0x858>
ffffffffc0203262:	00002617          	auipc	a2,0x2
ffffffffc0203266:	19e60613          	addi	a2,a2,414 # ffffffffc0205400 <commands+0x738>
ffffffffc020326a:	09400593          	li	a1,148
ffffffffc020326e:	00003517          	auipc	a0,0x3
ffffffffc0203272:	c0250513          	addi	a0,a0,-1022 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc0203276:	9d0fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020327a <swap_init_mm>:
ffffffffc020327a:	00012797          	auipc	a5,0x12
ffffffffc020327e:	30e7b783          	ld	a5,782(a5) # ffffffffc0215588 <sm>
ffffffffc0203282:	6b9c                	ld	a5,16(a5)
ffffffffc0203284:	8782                	jr	a5

ffffffffc0203286 <swap_map_swappable>:
ffffffffc0203286:	00012797          	auipc	a5,0x12
ffffffffc020328a:	3027b783          	ld	a5,770(a5) # ffffffffc0215588 <sm>
ffffffffc020328e:	739c                	ld	a5,32(a5)
ffffffffc0203290:	8782                	jr	a5

ffffffffc0203292 <swap_out>:
ffffffffc0203292:	711d                	addi	sp,sp,-96
ffffffffc0203294:	ec86                	sd	ra,88(sp)
ffffffffc0203296:	e8a2                	sd	s0,80(sp)
ffffffffc0203298:	e4a6                	sd	s1,72(sp)
ffffffffc020329a:	e0ca                	sd	s2,64(sp)
ffffffffc020329c:	fc4e                	sd	s3,56(sp)
ffffffffc020329e:	f852                	sd	s4,48(sp)
ffffffffc02032a0:	f456                	sd	s5,40(sp)
ffffffffc02032a2:	f05a                	sd	s6,32(sp)
ffffffffc02032a4:	ec5e                	sd	s7,24(sp)
ffffffffc02032a6:	e862                	sd	s8,16(sp)
ffffffffc02032a8:	cde9                	beqz	a1,ffffffffc0203382 <swap_out+0xf0>
ffffffffc02032aa:	8a2e                	mv	s4,a1
ffffffffc02032ac:	892a                	mv	s2,a0
ffffffffc02032ae:	8ab2                	mv	s5,a2
ffffffffc02032b0:	4401                	li	s0,0
ffffffffc02032b2:	00012997          	auipc	s3,0x12
ffffffffc02032b6:	2d698993          	addi	s3,s3,726 # ffffffffc0215588 <sm>
ffffffffc02032ba:	00003b17          	auipc	s6,0x3
ffffffffc02032be:	e9eb0b13          	addi	s6,s6,-354 # ffffffffc0206158 <default_pmm_manager+0x9a8>
ffffffffc02032c2:	00003b97          	auipc	s7,0x3
ffffffffc02032c6:	e7eb8b93          	addi	s7,s7,-386 # ffffffffc0206140 <default_pmm_manager+0x990>
ffffffffc02032ca:	a825                	j	ffffffffc0203302 <swap_out+0x70>
ffffffffc02032cc:	67a2                	ld	a5,8(sp)
ffffffffc02032ce:	8626                	mv	a2,s1
ffffffffc02032d0:	85a2                	mv	a1,s0
ffffffffc02032d2:	7f94                	ld	a3,56(a5)
ffffffffc02032d4:	855a                	mv	a0,s6
ffffffffc02032d6:	2405                	addiw	s0,s0,1
ffffffffc02032d8:	82b1                	srli	a3,a3,0xc
ffffffffc02032da:	0685                	addi	a3,a3,1
ffffffffc02032dc:	ea5fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02032e0:	6522                	ld	a0,8(sp)
ffffffffc02032e2:	4585                	li	a1,1
ffffffffc02032e4:	7d1c                	ld	a5,56(a0)
ffffffffc02032e6:	83b1                	srli	a5,a5,0xc
ffffffffc02032e8:	0785                	addi	a5,a5,1
ffffffffc02032ea:	07a2                	slli	a5,a5,0x8
ffffffffc02032ec:	00fc3023          	sd	a5,0(s8)
ffffffffc02032f0:	faafe0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc02032f4:	01893503          	ld	a0,24(s2)
ffffffffc02032f8:	85a6                	mv	a1,s1
ffffffffc02032fa:	f6cff0ef          	jal	ra,ffffffffc0202a66 <tlb_invalidate>
ffffffffc02032fe:	048a0d63          	beq	s4,s0,ffffffffc0203358 <swap_out+0xc6>
ffffffffc0203302:	0009b783          	ld	a5,0(s3)
ffffffffc0203306:	8656                	mv	a2,s5
ffffffffc0203308:	002c                	addi	a1,sp,8
ffffffffc020330a:	7b9c                	ld	a5,48(a5)
ffffffffc020330c:	854a                	mv	a0,s2
ffffffffc020330e:	9782                	jalr	a5
ffffffffc0203310:	e12d                	bnez	a0,ffffffffc0203372 <swap_out+0xe0>
ffffffffc0203312:	67a2                	ld	a5,8(sp)
ffffffffc0203314:	01893503          	ld	a0,24(s2)
ffffffffc0203318:	4601                	li	a2,0
ffffffffc020331a:	7f84                	ld	s1,56(a5)
ffffffffc020331c:	85a6                	mv	a1,s1
ffffffffc020331e:	ff6fe0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0203322:	611c                	ld	a5,0(a0)
ffffffffc0203324:	8c2a                	mv	s8,a0
ffffffffc0203326:	8b85                	andi	a5,a5,1
ffffffffc0203328:	cfb9                	beqz	a5,ffffffffc0203386 <swap_out+0xf4>
ffffffffc020332a:	65a2                	ld	a1,8(sp)
ffffffffc020332c:	7d9c                	ld	a5,56(a1)
ffffffffc020332e:	83b1                	srli	a5,a5,0xc
ffffffffc0203330:	0785                	addi	a5,a5,1
ffffffffc0203332:	00879513          	slli	a0,a5,0x8
ffffffffc0203336:	4ff000ef          	jal	ra,ffffffffc0204034 <swapfs_write>
ffffffffc020333a:	d949                	beqz	a0,ffffffffc02032cc <swap_out+0x3a>
ffffffffc020333c:	855e                	mv	a0,s7
ffffffffc020333e:	e43fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203342:	0009b783          	ld	a5,0(s3)
ffffffffc0203346:	6622                	ld	a2,8(sp)
ffffffffc0203348:	4681                	li	a3,0
ffffffffc020334a:	739c                	ld	a5,32(a5)
ffffffffc020334c:	85a6                	mv	a1,s1
ffffffffc020334e:	854a                	mv	a0,s2
ffffffffc0203350:	2405                	addiw	s0,s0,1
ffffffffc0203352:	9782                	jalr	a5
ffffffffc0203354:	fa8a17e3          	bne	s4,s0,ffffffffc0203302 <swap_out+0x70>
ffffffffc0203358:	60e6                	ld	ra,88(sp)
ffffffffc020335a:	8522                	mv	a0,s0
ffffffffc020335c:	6446                	ld	s0,80(sp)
ffffffffc020335e:	64a6                	ld	s1,72(sp)
ffffffffc0203360:	6906                	ld	s2,64(sp)
ffffffffc0203362:	79e2                	ld	s3,56(sp)
ffffffffc0203364:	7a42                	ld	s4,48(sp)
ffffffffc0203366:	7aa2                	ld	s5,40(sp)
ffffffffc0203368:	7b02                	ld	s6,32(sp)
ffffffffc020336a:	6be2                	ld	s7,24(sp)
ffffffffc020336c:	6c42                	ld	s8,16(sp)
ffffffffc020336e:	6125                	addi	sp,sp,96
ffffffffc0203370:	8082                	ret
ffffffffc0203372:	85a2                	mv	a1,s0
ffffffffc0203374:	00003517          	auipc	a0,0x3
ffffffffc0203378:	d8450513          	addi	a0,a0,-636 # ffffffffc02060f8 <default_pmm_manager+0x948>
ffffffffc020337c:	e05fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203380:	bfe1                	j	ffffffffc0203358 <swap_out+0xc6>
ffffffffc0203382:	4401                	li	s0,0
ffffffffc0203384:	bfd1                	j	ffffffffc0203358 <swap_out+0xc6>
ffffffffc0203386:	00003697          	auipc	a3,0x3
ffffffffc020338a:	da268693          	addi	a3,a3,-606 # ffffffffc0206128 <default_pmm_manager+0x978>
ffffffffc020338e:	00002617          	auipc	a2,0x2
ffffffffc0203392:	07260613          	addi	a2,a2,114 # ffffffffc0205400 <commands+0x738>
ffffffffc0203396:	06900593          	li	a1,105
ffffffffc020339a:	00003517          	auipc	a0,0x3
ffffffffc020339e:	ad650513          	addi	a0,a0,-1322 # ffffffffc0205e70 <default_pmm_manager+0x6c0>
ffffffffc02033a2:	8a4fd0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02033a6 <_fifo_init_mm>:
ffffffffc02033a6:	0000e797          	auipc	a5,0xe
ffffffffc02033aa:	15a78793          	addi	a5,a5,346 # ffffffffc0211500 <pra_list_head>
ffffffffc02033ae:	f51c                	sd	a5,40(a0)
ffffffffc02033b0:	e79c                	sd	a5,8(a5)
ffffffffc02033b2:	e39c                	sd	a5,0(a5)
ffffffffc02033b4:	4501                	li	a0,0
ffffffffc02033b6:	8082                	ret

ffffffffc02033b8 <_fifo_init>:
ffffffffc02033b8:	4501                	li	a0,0
ffffffffc02033ba:	8082                	ret

ffffffffc02033bc <_fifo_set_unswappable>:
ffffffffc02033bc:	4501                	li	a0,0
ffffffffc02033be:	8082                	ret

ffffffffc02033c0 <_fifo_tick_event>:
ffffffffc02033c0:	4501                	li	a0,0
ffffffffc02033c2:	8082                	ret

ffffffffc02033c4 <_fifo_check_swap>:
ffffffffc02033c4:	711d                	addi	sp,sp,-96
ffffffffc02033c6:	fc4e                	sd	s3,56(sp)
ffffffffc02033c8:	f852                	sd	s4,48(sp)
ffffffffc02033ca:	00003517          	auipc	a0,0x3
ffffffffc02033ce:	dce50513          	addi	a0,a0,-562 # ffffffffc0206198 <default_pmm_manager+0x9e8>
ffffffffc02033d2:	698d                	lui	s3,0x3
ffffffffc02033d4:	4a31                	li	s4,12
ffffffffc02033d6:	e0ca                	sd	s2,64(sp)
ffffffffc02033d8:	ec86                	sd	ra,88(sp)
ffffffffc02033da:	e8a2                	sd	s0,80(sp)
ffffffffc02033dc:	e4a6                	sd	s1,72(sp)
ffffffffc02033de:	f456                	sd	s5,40(sp)
ffffffffc02033e0:	f05a                	sd	s6,32(sp)
ffffffffc02033e2:	ec5e                	sd	s7,24(sp)
ffffffffc02033e4:	e862                	sd	s8,16(sp)
ffffffffc02033e6:	e466                	sd	s9,8(sp)
ffffffffc02033e8:	e06a                	sd	s10,0(sp)
ffffffffc02033ea:	d97fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02033ee:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
ffffffffc02033f2:	00012917          	auipc	s2,0x12
ffffffffc02033f6:	1ae92903          	lw	s2,430(s2) # ffffffffc02155a0 <pgfault_num>
ffffffffc02033fa:	4791                	li	a5,4
ffffffffc02033fc:	14f91e63          	bne	s2,a5,ffffffffc0203558 <_fifo_check_swap+0x194>
ffffffffc0203400:	00003517          	auipc	a0,0x3
ffffffffc0203404:	dd850513          	addi	a0,a0,-552 # ffffffffc02061d8 <default_pmm_manager+0xa28>
ffffffffc0203408:	6a85                	lui	s5,0x1
ffffffffc020340a:	4b29                	li	s6,10
ffffffffc020340c:	d75fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203410:	00012417          	auipc	s0,0x12
ffffffffc0203414:	19040413          	addi	s0,s0,400 # ffffffffc02155a0 <pgfault_num>
ffffffffc0203418:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020341c:	4004                	lw	s1,0(s0)
ffffffffc020341e:	2481                	sext.w	s1,s1
ffffffffc0203420:	2b249c63          	bne	s1,s2,ffffffffc02036d8 <_fifo_check_swap+0x314>
ffffffffc0203424:	00003517          	auipc	a0,0x3
ffffffffc0203428:	ddc50513          	addi	a0,a0,-548 # ffffffffc0206200 <default_pmm_manager+0xa50>
ffffffffc020342c:	6b91                	lui	s7,0x4
ffffffffc020342e:	4c35                	li	s8,13
ffffffffc0203430:	d51fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203434:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc0203438:	00042903          	lw	s2,0(s0)
ffffffffc020343c:	2901                	sext.w	s2,s2
ffffffffc020343e:	26991d63          	bne	s2,s1,ffffffffc02036b8 <_fifo_check_swap+0x2f4>
ffffffffc0203442:	00003517          	auipc	a0,0x3
ffffffffc0203446:	de650513          	addi	a0,a0,-538 # ffffffffc0206228 <default_pmm_manager+0xa78>
ffffffffc020344a:	6c89                	lui	s9,0x2
ffffffffc020344c:	4d2d                	li	s10,11
ffffffffc020344e:	d33fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203452:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
ffffffffc0203456:	401c                	lw	a5,0(s0)
ffffffffc0203458:	2781                	sext.w	a5,a5
ffffffffc020345a:	23279f63          	bne	a5,s2,ffffffffc0203698 <_fifo_check_swap+0x2d4>
ffffffffc020345e:	00003517          	auipc	a0,0x3
ffffffffc0203462:	df250513          	addi	a0,a0,-526 # ffffffffc0206250 <default_pmm_manager+0xaa0>
ffffffffc0203466:	d1bfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc020346a:	6795                	lui	a5,0x5
ffffffffc020346c:	4739                	li	a4,14
ffffffffc020346e:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc0203472:	4004                	lw	s1,0(s0)
ffffffffc0203474:	4795                	li	a5,5
ffffffffc0203476:	2481                	sext.w	s1,s1
ffffffffc0203478:	20f49063          	bne	s1,a5,ffffffffc0203678 <_fifo_check_swap+0x2b4>
ffffffffc020347c:	00003517          	auipc	a0,0x3
ffffffffc0203480:	dac50513          	addi	a0,a0,-596 # ffffffffc0206228 <default_pmm_manager+0xa78>
ffffffffc0203484:	cfdfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203488:	01ac8023          	sb	s10,0(s9)
ffffffffc020348c:	401c                	lw	a5,0(s0)
ffffffffc020348e:	2781                	sext.w	a5,a5
ffffffffc0203490:	1c979463          	bne	a5,s1,ffffffffc0203658 <_fifo_check_swap+0x294>
ffffffffc0203494:	00003517          	auipc	a0,0x3
ffffffffc0203498:	d4450513          	addi	a0,a0,-700 # ffffffffc02061d8 <default_pmm_manager+0xa28>
ffffffffc020349c:	ce5fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02034a0:	016a8023          	sb	s6,0(s5)
ffffffffc02034a4:	401c                	lw	a5,0(s0)
ffffffffc02034a6:	4719                	li	a4,6
ffffffffc02034a8:	2781                	sext.w	a5,a5
ffffffffc02034aa:	18e79763          	bne	a5,a4,ffffffffc0203638 <_fifo_check_swap+0x274>
ffffffffc02034ae:	00003517          	auipc	a0,0x3
ffffffffc02034b2:	d7a50513          	addi	a0,a0,-646 # ffffffffc0206228 <default_pmm_manager+0xa78>
ffffffffc02034b6:	ccbfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02034ba:	01ac8023          	sb	s10,0(s9)
ffffffffc02034be:	401c                	lw	a5,0(s0)
ffffffffc02034c0:	471d                	li	a4,7
ffffffffc02034c2:	2781                	sext.w	a5,a5
ffffffffc02034c4:	14e79a63          	bne	a5,a4,ffffffffc0203618 <_fifo_check_swap+0x254>
ffffffffc02034c8:	00003517          	auipc	a0,0x3
ffffffffc02034cc:	cd050513          	addi	a0,a0,-816 # ffffffffc0206198 <default_pmm_manager+0x9e8>
ffffffffc02034d0:	cb1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02034d4:	01498023          	sb	s4,0(s3)
ffffffffc02034d8:	401c                	lw	a5,0(s0)
ffffffffc02034da:	4721                	li	a4,8
ffffffffc02034dc:	2781                	sext.w	a5,a5
ffffffffc02034de:	10e79d63          	bne	a5,a4,ffffffffc02035f8 <_fifo_check_swap+0x234>
ffffffffc02034e2:	00003517          	auipc	a0,0x3
ffffffffc02034e6:	d1e50513          	addi	a0,a0,-738 # ffffffffc0206200 <default_pmm_manager+0xa50>
ffffffffc02034ea:	c97fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02034ee:	018b8023          	sb	s8,0(s7)
ffffffffc02034f2:	401c                	lw	a5,0(s0)
ffffffffc02034f4:	4725                	li	a4,9
ffffffffc02034f6:	2781                	sext.w	a5,a5
ffffffffc02034f8:	0ee79063          	bne	a5,a4,ffffffffc02035d8 <_fifo_check_swap+0x214>
ffffffffc02034fc:	00003517          	auipc	a0,0x3
ffffffffc0203500:	d5450513          	addi	a0,a0,-684 # ffffffffc0206250 <default_pmm_manager+0xaa0>
ffffffffc0203504:	c7dfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203508:	6795                	lui	a5,0x5
ffffffffc020350a:	4739                	li	a4,14
ffffffffc020350c:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
ffffffffc0203510:	4004                	lw	s1,0(s0)
ffffffffc0203512:	47a9                	li	a5,10
ffffffffc0203514:	2481                	sext.w	s1,s1
ffffffffc0203516:	0af49163          	bne	s1,a5,ffffffffc02035b8 <_fifo_check_swap+0x1f4>
ffffffffc020351a:	00003517          	auipc	a0,0x3
ffffffffc020351e:	cbe50513          	addi	a0,a0,-834 # ffffffffc02061d8 <default_pmm_manager+0xa28>
ffffffffc0203522:	c5ffc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203526:	6785                	lui	a5,0x1
ffffffffc0203528:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020352c:	06979663          	bne	a5,s1,ffffffffc0203598 <_fifo_check_swap+0x1d4>
ffffffffc0203530:	401c                	lw	a5,0(s0)
ffffffffc0203532:	472d                	li	a4,11
ffffffffc0203534:	2781                	sext.w	a5,a5
ffffffffc0203536:	04e79163          	bne	a5,a4,ffffffffc0203578 <_fifo_check_swap+0x1b4>
ffffffffc020353a:	60e6                	ld	ra,88(sp)
ffffffffc020353c:	6446                	ld	s0,80(sp)
ffffffffc020353e:	64a6                	ld	s1,72(sp)
ffffffffc0203540:	6906                	ld	s2,64(sp)
ffffffffc0203542:	79e2                	ld	s3,56(sp)
ffffffffc0203544:	7a42                	ld	s4,48(sp)
ffffffffc0203546:	7aa2                	ld	s5,40(sp)
ffffffffc0203548:	7b02                	ld	s6,32(sp)
ffffffffc020354a:	6be2                	ld	s7,24(sp)
ffffffffc020354c:	6c42                	ld	s8,16(sp)
ffffffffc020354e:	6ca2                	ld	s9,8(sp)
ffffffffc0203550:	6d02                	ld	s10,0(sp)
ffffffffc0203552:	4501                	li	a0,0
ffffffffc0203554:	6125                	addi	sp,sp,96
ffffffffc0203556:	8082                	ret
ffffffffc0203558:	00003697          	auipc	a3,0x3
ffffffffc020355c:	ae068693          	addi	a3,a3,-1312 # ffffffffc0206038 <default_pmm_manager+0x888>
ffffffffc0203560:	00002617          	auipc	a2,0x2
ffffffffc0203564:	ea060613          	addi	a2,a2,-352 # ffffffffc0205400 <commands+0x738>
ffffffffc0203568:	05100593          	li	a1,81
ffffffffc020356c:	00003517          	auipc	a0,0x3
ffffffffc0203570:	c5450513          	addi	a0,a0,-940 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203574:	ed3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203578:	00003697          	auipc	a3,0x3
ffffffffc020357c:	d8868693          	addi	a3,a3,-632 # ffffffffc0206300 <default_pmm_manager+0xb50>
ffffffffc0203580:	00002617          	auipc	a2,0x2
ffffffffc0203584:	e8060613          	addi	a2,a2,-384 # ffffffffc0205400 <commands+0x738>
ffffffffc0203588:	07300593          	li	a1,115
ffffffffc020358c:	00003517          	auipc	a0,0x3
ffffffffc0203590:	c3450513          	addi	a0,a0,-972 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203594:	eb3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203598:	00003697          	auipc	a3,0x3
ffffffffc020359c:	d4068693          	addi	a3,a3,-704 # ffffffffc02062d8 <default_pmm_manager+0xb28>
ffffffffc02035a0:	00002617          	auipc	a2,0x2
ffffffffc02035a4:	e6060613          	addi	a2,a2,-416 # ffffffffc0205400 <commands+0x738>
ffffffffc02035a8:	07100593          	li	a1,113
ffffffffc02035ac:	00003517          	auipc	a0,0x3
ffffffffc02035b0:	c1450513          	addi	a0,a0,-1004 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc02035b4:	e93fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02035b8:	00003697          	auipc	a3,0x3
ffffffffc02035bc:	d1068693          	addi	a3,a3,-752 # ffffffffc02062c8 <default_pmm_manager+0xb18>
ffffffffc02035c0:	00002617          	auipc	a2,0x2
ffffffffc02035c4:	e4060613          	addi	a2,a2,-448 # ffffffffc0205400 <commands+0x738>
ffffffffc02035c8:	06f00593          	li	a1,111
ffffffffc02035cc:	00003517          	auipc	a0,0x3
ffffffffc02035d0:	bf450513          	addi	a0,a0,-1036 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc02035d4:	e73fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02035d8:	00003697          	auipc	a3,0x3
ffffffffc02035dc:	ce068693          	addi	a3,a3,-800 # ffffffffc02062b8 <default_pmm_manager+0xb08>
ffffffffc02035e0:	00002617          	auipc	a2,0x2
ffffffffc02035e4:	e2060613          	addi	a2,a2,-480 # ffffffffc0205400 <commands+0x738>
ffffffffc02035e8:	06c00593          	li	a1,108
ffffffffc02035ec:	00003517          	auipc	a0,0x3
ffffffffc02035f0:	bd450513          	addi	a0,a0,-1068 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc02035f4:	e53fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02035f8:	00003697          	auipc	a3,0x3
ffffffffc02035fc:	cb068693          	addi	a3,a3,-848 # ffffffffc02062a8 <default_pmm_manager+0xaf8>
ffffffffc0203600:	00002617          	auipc	a2,0x2
ffffffffc0203604:	e0060613          	addi	a2,a2,-512 # ffffffffc0205400 <commands+0x738>
ffffffffc0203608:	06900593          	li	a1,105
ffffffffc020360c:	00003517          	auipc	a0,0x3
ffffffffc0203610:	bb450513          	addi	a0,a0,-1100 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203614:	e33fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203618:	00003697          	auipc	a3,0x3
ffffffffc020361c:	c8068693          	addi	a3,a3,-896 # ffffffffc0206298 <default_pmm_manager+0xae8>
ffffffffc0203620:	00002617          	auipc	a2,0x2
ffffffffc0203624:	de060613          	addi	a2,a2,-544 # ffffffffc0205400 <commands+0x738>
ffffffffc0203628:	06600593          	li	a1,102
ffffffffc020362c:	00003517          	auipc	a0,0x3
ffffffffc0203630:	b9450513          	addi	a0,a0,-1132 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203634:	e13fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203638:	00003697          	auipc	a3,0x3
ffffffffc020363c:	c5068693          	addi	a3,a3,-944 # ffffffffc0206288 <default_pmm_manager+0xad8>
ffffffffc0203640:	00002617          	auipc	a2,0x2
ffffffffc0203644:	dc060613          	addi	a2,a2,-576 # ffffffffc0205400 <commands+0x738>
ffffffffc0203648:	06300593          	li	a1,99
ffffffffc020364c:	00003517          	auipc	a0,0x3
ffffffffc0203650:	b7450513          	addi	a0,a0,-1164 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203654:	df3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203658:	00003697          	auipc	a3,0x3
ffffffffc020365c:	c2068693          	addi	a3,a3,-992 # ffffffffc0206278 <default_pmm_manager+0xac8>
ffffffffc0203660:	00002617          	auipc	a2,0x2
ffffffffc0203664:	da060613          	addi	a2,a2,-608 # ffffffffc0205400 <commands+0x738>
ffffffffc0203668:	06000593          	li	a1,96
ffffffffc020366c:	00003517          	auipc	a0,0x3
ffffffffc0203670:	b5450513          	addi	a0,a0,-1196 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203674:	dd3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203678:	00003697          	auipc	a3,0x3
ffffffffc020367c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0206278 <default_pmm_manager+0xac8>
ffffffffc0203680:	00002617          	auipc	a2,0x2
ffffffffc0203684:	d8060613          	addi	a2,a2,-640 # ffffffffc0205400 <commands+0x738>
ffffffffc0203688:	05d00593          	li	a1,93
ffffffffc020368c:	00003517          	auipc	a0,0x3
ffffffffc0203690:	b3450513          	addi	a0,a0,-1228 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203694:	db3fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203698:	00003697          	auipc	a3,0x3
ffffffffc020369c:	9a068693          	addi	a3,a3,-1632 # ffffffffc0206038 <default_pmm_manager+0x888>
ffffffffc02036a0:	00002617          	auipc	a2,0x2
ffffffffc02036a4:	d6060613          	addi	a2,a2,-672 # ffffffffc0205400 <commands+0x738>
ffffffffc02036a8:	05a00593          	li	a1,90
ffffffffc02036ac:	00003517          	auipc	a0,0x3
ffffffffc02036b0:	b1450513          	addi	a0,a0,-1260 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc02036b4:	d93fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02036b8:	00003697          	auipc	a3,0x3
ffffffffc02036bc:	98068693          	addi	a3,a3,-1664 # ffffffffc0206038 <default_pmm_manager+0x888>
ffffffffc02036c0:	00002617          	auipc	a2,0x2
ffffffffc02036c4:	d4060613          	addi	a2,a2,-704 # ffffffffc0205400 <commands+0x738>
ffffffffc02036c8:	05700593          	li	a1,87
ffffffffc02036cc:	00003517          	auipc	a0,0x3
ffffffffc02036d0:	af450513          	addi	a0,a0,-1292 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc02036d4:	d73fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02036d8:	00003697          	auipc	a3,0x3
ffffffffc02036dc:	96068693          	addi	a3,a3,-1696 # ffffffffc0206038 <default_pmm_manager+0x888>
ffffffffc02036e0:	00002617          	auipc	a2,0x2
ffffffffc02036e4:	d2060613          	addi	a2,a2,-736 # ffffffffc0205400 <commands+0x738>
ffffffffc02036e8:	05400593          	li	a1,84
ffffffffc02036ec:	00003517          	auipc	a0,0x3
ffffffffc02036f0:	ad450513          	addi	a0,a0,-1324 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc02036f4:	d53fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02036f8 <_fifo_swap_out_victim>:
ffffffffc02036f8:	751c                	ld	a5,40(a0)
ffffffffc02036fa:	1141                	addi	sp,sp,-16
ffffffffc02036fc:	e406                	sd	ra,8(sp)
ffffffffc02036fe:	cf91                	beqz	a5,ffffffffc020371a <_fifo_swap_out_victim+0x22>
ffffffffc0203700:	ee0d                	bnez	a2,ffffffffc020373a <_fifo_swap_out_victim+0x42>
ffffffffc0203702:	679c                	ld	a5,8(a5)
ffffffffc0203704:	60a2                	ld	ra,8(sp)
ffffffffc0203706:	4501                	li	a0,0
ffffffffc0203708:	6394                	ld	a3,0(a5)
ffffffffc020370a:	6798                	ld	a4,8(a5)
ffffffffc020370c:	fd878793          	addi	a5,a5,-40
ffffffffc0203710:	e698                	sd	a4,8(a3)
ffffffffc0203712:	e314                	sd	a3,0(a4)
ffffffffc0203714:	e19c                	sd	a5,0(a1)
ffffffffc0203716:	0141                	addi	sp,sp,16
ffffffffc0203718:	8082                	ret
ffffffffc020371a:	00003697          	auipc	a3,0x3
ffffffffc020371e:	bf668693          	addi	a3,a3,-1034 # ffffffffc0206310 <default_pmm_manager+0xb60>
ffffffffc0203722:	00002617          	auipc	a2,0x2
ffffffffc0203726:	cde60613          	addi	a2,a2,-802 # ffffffffc0205400 <commands+0x738>
ffffffffc020372a:	04100593          	li	a1,65
ffffffffc020372e:	00003517          	auipc	a0,0x3
ffffffffc0203732:	a9250513          	addi	a0,a0,-1390 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203736:	d11fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020373a:	00003697          	auipc	a3,0x3
ffffffffc020373e:	be668693          	addi	a3,a3,-1050 # ffffffffc0206320 <default_pmm_manager+0xb70>
ffffffffc0203742:	00002617          	auipc	a2,0x2
ffffffffc0203746:	cbe60613          	addi	a2,a2,-834 # ffffffffc0205400 <commands+0x738>
ffffffffc020374a:	04200593          	li	a1,66
ffffffffc020374e:	00003517          	auipc	a0,0x3
ffffffffc0203752:	a7250513          	addi	a0,a0,-1422 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc0203756:	cf1fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020375a <_fifo_map_swappable>:
ffffffffc020375a:	751c                	ld	a5,40(a0)
ffffffffc020375c:	cb91                	beqz	a5,ffffffffc0203770 <_fifo_map_swappable+0x16>
ffffffffc020375e:	6394                	ld	a3,0(a5)
ffffffffc0203760:	02860713          	addi	a4,a2,40
ffffffffc0203764:	e398                	sd	a4,0(a5)
ffffffffc0203766:	e698                	sd	a4,8(a3)
ffffffffc0203768:	4501                	li	a0,0
ffffffffc020376a:	fa1c                	sd	a5,48(a2)
ffffffffc020376c:	f614                	sd	a3,40(a2)
ffffffffc020376e:	8082                	ret
ffffffffc0203770:	1141                	addi	sp,sp,-16
ffffffffc0203772:	00003697          	auipc	a3,0x3
ffffffffc0203776:	bbe68693          	addi	a3,a3,-1090 # ffffffffc0206330 <default_pmm_manager+0xb80>
ffffffffc020377a:	00002617          	auipc	a2,0x2
ffffffffc020377e:	c8660613          	addi	a2,a2,-890 # ffffffffc0205400 <commands+0x738>
ffffffffc0203782:	03200593          	li	a1,50
ffffffffc0203786:	00003517          	auipc	a0,0x3
ffffffffc020378a:	a3a50513          	addi	a0,a0,-1478 # ffffffffc02061c0 <default_pmm_manager+0xa10>
ffffffffc020378e:	e406                	sd	ra,8(sp)
ffffffffc0203790:	cb7fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203794 <check_vma_overlap.part.0>:
ffffffffc0203794:	1141                	addi	sp,sp,-16
ffffffffc0203796:	00003697          	auipc	a3,0x3
ffffffffc020379a:	bd268693          	addi	a3,a3,-1070 # ffffffffc0206368 <default_pmm_manager+0xbb8>
ffffffffc020379e:	00002617          	auipc	a2,0x2
ffffffffc02037a2:	c6260613          	addi	a2,a2,-926 # ffffffffc0205400 <commands+0x738>
ffffffffc02037a6:	07e00593          	li	a1,126
ffffffffc02037aa:	00003517          	auipc	a0,0x3
ffffffffc02037ae:	bde50513          	addi	a0,a0,-1058 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc02037b2:	e406                	sd	ra,8(sp)
ffffffffc02037b4:	c93fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02037b8 <mm_create>:
ffffffffc02037b8:	1141                	addi	sp,sp,-16
ffffffffc02037ba:	03000513          	li	a0,48
ffffffffc02037be:	e022                	sd	s0,0(sp)
ffffffffc02037c0:	e406                	sd	ra,8(sp)
ffffffffc02037c2:	868fe0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc02037c6:	842a                	mv	s0,a0
ffffffffc02037c8:	c105                	beqz	a0,ffffffffc02037e8 <mm_create+0x30>
ffffffffc02037ca:	e408                	sd	a0,8(s0)
ffffffffc02037cc:	e008                	sd	a0,0(s0)
ffffffffc02037ce:	00053823          	sd	zero,16(a0)
ffffffffc02037d2:	00053c23          	sd	zero,24(a0)
ffffffffc02037d6:	02052023          	sw	zero,32(a0)
ffffffffc02037da:	00012797          	auipc	a5,0x12
ffffffffc02037de:	db67a783          	lw	a5,-586(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc02037e2:	eb81                	bnez	a5,ffffffffc02037f2 <mm_create+0x3a>
ffffffffc02037e4:	02053423          	sd	zero,40(a0)
ffffffffc02037e8:	60a2                	ld	ra,8(sp)
ffffffffc02037ea:	8522                	mv	a0,s0
ffffffffc02037ec:	6402                	ld	s0,0(sp)
ffffffffc02037ee:	0141                	addi	sp,sp,16
ffffffffc02037f0:	8082                	ret
ffffffffc02037f2:	a89ff0ef          	jal	ra,ffffffffc020327a <swap_init_mm>
ffffffffc02037f6:	60a2                	ld	ra,8(sp)
ffffffffc02037f8:	8522                	mv	a0,s0
ffffffffc02037fa:	6402                	ld	s0,0(sp)
ffffffffc02037fc:	0141                	addi	sp,sp,16
ffffffffc02037fe:	8082                	ret

ffffffffc0203800 <vma_create>:
ffffffffc0203800:	1101                	addi	sp,sp,-32
ffffffffc0203802:	e04a                	sd	s2,0(sp)
ffffffffc0203804:	892a                	mv	s2,a0
ffffffffc0203806:	03000513          	li	a0,48
ffffffffc020380a:	e822                	sd	s0,16(sp)
ffffffffc020380c:	e426                	sd	s1,8(sp)
ffffffffc020380e:	ec06                	sd	ra,24(sp)
ffffffffc0203810:	84ae                	mv	s1,a1
ffffffffc0203812:	8432                	mv	s0,a2
ffffffffc0203814:	816fe0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203818:	c509                	beqz	a0,ffffffffc0203822 <vma_create+0x22>
ffffffffc020381a:	01253423          	sd	s2,8(a0)
ffffffffc020381e:	e904                	sd	s1,16(a0)
ffffffffc0203820:	cd00                	sw	s0,24(a0)
ffffffffc0203822:	60e2                	ld	ra,24(sp)
ffffffffc0203824:	6442                	ld	s0,16(sp)
ffffffffc0203826:	64a2                	ld	s1,8(sp)
ffffffffc0203828:	6902                	ld	s2,0(sp)
ffffffffc020382a:	6105                	addi	sp,sp,32
ffffffffc020382c:	8082                	ret

ffffffffc020382e <find_vma>:
ffffffffc020382e:	86aa                	mv	a3,a0
ffffffffc0203830:	c505                	beqz	a0,ffffffffc0203858 <find_vma+0x2a>
ffffffffc0203832:	6908                	ld	a0,16(a0)
ffffffffc0203834:	c501                	beqz	a0,ffffffffc020383c <find_vma+0xe>
ffffffffc0203836:	651c                	ld	a5,8(a0)
ffffffffc0203838:	02f5f263          	bgeu	a1,a5,ffffffffc020385c <find_vma+0x2e>
ffffffffc020383c:	669c                	ld	a5,8(a3)
ffffffffc020383e:	00f68d63          	beq	a3,a5,ffffffffc0203858 <find_vma+0x2a>
ffffffffc0203842:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203846:	00e5e663          	bltu	a1,a4,ffffffffc0203852 <find_vma+0x24>
ffffffffc020384a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020384e:	00e5ec63          	bltu	a1,a4,ffffffffc0203866 <find_vma+0x38>
ffffffffc0203852:	679c                	ld	a5,8(a5)
ffffffffc0203854:	fef697e3          	bne	a3,a5,ffffffffc0203842 <find_vma+0x14>
ffffffffc0203858:	4501                	li	a0,0
ffffffffc020385a:	8082                	ret
ffffffffc020385c:	691c                	ld	a5,16(a0)
ffffffffc020385e:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020383c <find_vma+0xe>
ffffffffc0203862:	ea88                	sd	a0,16(a3)
ffffffffc0203864:	8082                	ret
ffffffffc0203866:	fe078513          	addi	a0,a5,-32
ffffffffc020386a:	ea88                	sd	a0,16(a3)
ffffffffc020386c:	8082                	ret

ffffffffc020386e <insert_vma_struct>:
ffffffffc020386e:	6590                	ld	a2,8(a1)
ffffffffc0203870:	0105b803          	ld	a6,16(a1) # 1010 <kern_entry-0xffffffffc01feff0>
ffffffffc0203874:	1141                	addi	sp,sp,-16
ffffffffc0203876:	e406                	sd	ra,8(sp)
ffffffffc0203878:	87aa                	mv	a5,a0
ffffffffc020387a:	01066763          	bltu	a2,a6,ffffffffc0203888 <insert_vma_struct+0x1a>
ffffffffc020387e:	a085                	j	ffffffffc02038de <insert_vma_struct+0x70>
ffffffffc0203880:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203884:	04e66863          	bltu	a2,a4,ffffffffc02038d4 <insert_vma_struct+0x66>
ffffffffc0203888:	86be                	mv	a3,a5
ffffffffc020388a:	679c                	ld	a5,8(a5)
ffffffffc020388c:	fef51ae3          	bne	a0,a5,ffffffffc0203880 <insert_vma_struct+0x12>
ffffffffc0203890:	02a68463          	beq	a3,a0,ffffffffc02038b8 <insert_vma_struct+0x4a>
ffffffffc0203894:	ff06b703          	ld	a4,-16(a3)
ffffffffc0203898:	fe86b883          	ld	a7,-24(a3)
ffffffffc020389c:	08e8f163          	bgeu	a7,a4,ffffffffc020391e <insert_vma_struct+0xb0>
ffffffffc02038a0:	04e66f63          	bltu	a2,a4,ffffffffc02038fe <insert_vma_struct+0x90>
ffffffffc02038a4:	00f50a63          	beq	a0,a5,ffffffffc02038b8 <insert_vma_struct+0x4a>
ffffffffc02038a8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02038ac:	05076963          	bltu	a4,a6,ffffffffc02038fe <insert_vma_struct+0x90>
ffffffffc02038b0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038b4:	02c77363          	bgeu	a4,a2,ffffffffc02038da <insert_vma_struct+0x6c>
ffffffffc02038b8:	5118                	lw	a4,32(a0)
ffffffffc02038ba:	e188                	sd	a0,0(a1)
ffffffffc02038bc:	02058613          	addi	a2,a1,32
ffffffffc02038c0:	e390                	sd	a2,0(a5)
ffffffffc02038c2:	e690                	sd	a2,8(a3)
ffffffffc02038c4:	60a2                	ld	ra,8(sp)
ffffffffc02038c6:	f59c                	sd	a5,40(a1)
ffffffffc02038c8:	f194                	sd	a3,32(a1)
ffffffffc02038ca:	0017079b          	addiw	a5,a4,1
ffffffffc02038ce:	d11c                	sw	a5,32(a0)
ffffffffc02038d0:	0141                	addi	sp,sp,16
ffffffffc02038d2:	8082                	ret
ffffffffc02038d4:	fca690e3          	bne	a3,a0,ffffffffc0203894 <insert_vma_struct+0x26>
ffffffffc02038d8:	bfd1                	j	ffffffffc02038ac <insert_vma_struct+0x3e>
ffffffffc02038da:	ebbff0ef          	jal	ra,ffffffffc0203794 <check_vma_overlap.part.0>
ffffffffc02038de:	00003697          	auipc	a3,0x3
ffffffffc02038e2:	aba68693          	addi	a3,a3,-1350 # ffffffffc0206398 <default_pmm_manager+0xbe8>
ffffffffc02038e6:	00002617          	auipc	a2,0x2
ffffffffc02038ea:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0205400 <commands+0x738>
ffffffffc02038ee:	08500593          	li	a1,133
ffffffffc02038f2:	00003517          	auipc	a0,0x3
ffffffffc02038f6:	a9650513          	addi	a0,a0,-1386 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc02038fa:	b4dfc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02038fe:	00003697          	auipc	a3,0x3
ffffffffc0203902:	ada68693          	addi	a3,a3,-1318 # ffffffffc02063d8 <default_pmm_manager+0xc28>
ffffffffc0203906:	00002617          	auipc	a2,0x2
ffffffffc020390a:	afa60613          	addi	a2,a2,-1286 # ffffffffc0205400 <commands+0x738>
ffffffffc020390e:	07d00593          	li	a1,125
ffffffffc0203912:	00003517          	auipc	a0,0x3
ffffffffc0203916:	a7650513          	addi	a0,a0,-1418 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc020391a:	b2dfc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc020391e:	00003697          	auipc	a3,0x3
ffffffffc0203922:	a9a68693          	addi	a3,a3,-1382 # ffffffffc02063b8 <default_pmm_manager+0xc08>
ffffffffc0203926:	00002617          	auipc	a2,0x2
ffffffffc020392a:	ada60613          	addi	a2,a2,-1318 # ffffffffc0205400 <commands+0x738>
ffffffffc020392e:	07c00593          	li	a1,124
ffffffffc0203932:	00003517          	auipc	a0,0x3
ffffffffc0203936:	a5650513          	addi	a0,a0,-1450 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc020393a:	b0dfc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc020393e <mm_destroy>:
ffffffffc020393e:	1141                	addi	sp,sp,-16
ffffffffc0203940:	e022                	sd	s0,0(sp)
ffffffffc0203942:	842a                	mv	s0,a0
ffffffffc0203944:	6508                	ld	a0,8(a0)
ffffffffc0203946:	e406                	sd	ra,8(sp)
ffffffffc0203948:	00a40c63          	beq	s0,a0,ffffffffc0203960 <mm_destroy+0x22>
ffffffffc020394c:	6118                	ld	a4,0(a0)
ffffffffc020394e:	651c                	ld	a5,8(a0)
ffffffffc0203950:	1501                	addi	a0,a0,-32
ffffffffc0203952:	e71c                	sd	a5,8(a4)
ffffffffc0203954:	e398                	sd	a4,0(a5)
ffffffffc0203956:	f85fd0ef          	jal	ra,ffffffffc02018da <kfree>
ffffffffc020395a:	6408                	ld	a0,8(s0)
ffffffffc020395c:	fea418e3          	bne	s0,a0,ffffffffc020394c <mm_destroy+0xe>
ffffffffc0203960:	8522                	mv	a0,s0
ffffffffc0203962:	6402                	ld	s0,0(sp)
ffffffffc0203964:	60a2                	ld	ra,8(sp)
ffffffffc0203966:	0141                	addi	sp,sp,16
ffffffffc0203968:	f73fd06f          	j	ffffffffc02018da <kfree>

ffffffffc020396c <vmm_init>:
ffffffffc020396c:	7139                	addi	sp,sp,-64
ffffffffc020396e:	03000513          	li	a0,48
ffffffffc0203972:	fc06                	sd	ra,56(sp)
ffffffffc0203974:	f822                	sd	s0,48(sp)
ffffffffc0203976:	f426                	sd	s1,40(sp)
ffffffffc0203978:	f04a                	sd	s2,32(sp)
ffffffffc020397a:	ec4e                	sd	s3,24(sp)
ffffffffc020397c:	e852                	sd	s4,16(sp)
ffffffffc020397e:	e456                	sd	s5,8(sp)
ffffffffc0203980:	eabfd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203984:	58050e63          	beqz	a0,ffffffffc0203f20 <vmm_init+0x5b4>
ffffffffc0203988:	e508                	sd	a0,8(a0)
ffffffffc020398a:	e108                	sd	a0,0(a0)
ffffffffc020398c:	00053823          	sd	zero,16(a0)
ffffffffc0203990:	00053c23          	sd	zero,24(a0)
ffffffffc0203994:	02052023          	sw	zero,32(a0)
ffffffffc0203998:	00012797          	auipc	a5,0x12
ffffffffc020399c:	bf87a783          	lw	a5,-1032(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc02039a0:	84aa                	mv	s1,a0
ffffffffc02039a2:	e7b9                	bnez	a5,ffffffffc02039f0 <vmm_init+0x84>
ffffffffc02039a4:	02053423          	sd	zero,40(a0)
ffffffffc02039a8:	03200413          	li	s0,50
ffffffffc02039ac:	a811                	j	ffffffffc02039c0 <vmm_init+0x54>
ffffffffc02039ae:	e500                	sd	s0,8(a0)
ffffffffc02039b0:	e91c                	sd	a5,16(a0)
ffffffffc02039b2:	00052c23          	sw	zero,24(a0)
ffffffffc02039b6:	146d                	addi	s0,s0,-5
ffffffffc02039b8:	8526                	mv	a0,s1
ffffffffc02039ba:	eb5ff0ef          	jal	ra,ffffffffc020386e <insert_vma_struct>
ffffffffc02039be:	cc05                	beqz	s0,ffffffffc02039f6 <vmm_init+0x8a>
ffffffffc02039c0:	03000513          	li	a0,48
ffffffffc02039c4:	e67fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc02039c8:	85aa                	mv	a1,a0
ffffffffc02039ca:	00240793          	addi	a5,s0,2
ffffffffc02039ce:	f165                	bnez	a0,ffffffffc02039ae <vmm_init+0x42>
ffffffffc02039d0:	00002697          	auipc	a3,0x2
ffffffffc02039d4:	52868693          	addi	a3,a3,1320 # ffffffffc0205ef8 <default_pmm_manager+0x748>
ffffffffc02039d8:	00002617          	auipc	a2,0x2
ffffffffc02039dc:	a2860613          	addi	a2,a2,-1496 # ffffffffc0205400 <commands+0x738>
ffffffffc02039e0:	0c900593          	li	a1,201
ffffffffc02039e4:	00003517          	auipc	a0,0x3
ffffffffc02039e8:	9a450513          	addi	a0,a0,-1628 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc02039ec:	a5bfc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02039f0:	88bff0ef          	jal	ra,ffffffffc020327a <swap_init_mm>
ffffffffc02039f4:	bf55                	j	ffffffffc02039a8 <vmm_init+0x3c>
ffffffffc02039f6:	03700413          	li	s0,55
ffffffffc02039fa:	1f900913          	li	s2,505
ffffffffc02039fe:	a819                	j	ffffffffc0203a14 <vmm_init+0xa8>
ffffffffc0203a00:	e500                	sd	s0,8(a0)
ffffffffc0203a02:	e91c                	sd	a5,16(a0)
ffffffffc0203a04:	00052c23          	sw	zero,24(a0)
ffffffffc0203a08:	0415                	addi	s0,s0,5
ffffffffc0203a0a:	8526                	mv	a0,s1
ffffffffc0203a0c:	e63ff0ef          	jal	ra,ffffffffc020386e <insert_vma_struct>
ffffffffc0203a10:	03240a63          	beq	s0,s2,ffffffffc0203a44 <vmm_init+0xd8>
ffffffffc0203a14:	03000513          	li	a0,48
ffffffffc0203a18:	e13fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203a1c:	85aa                	mv	a1,a0
ffffffffc0203a1e:	00240793          	addi	a5,s0,2
ffffffffc0203a22:	fd79                	bnez	a0,ffffffffc0203a00 <vmm_init+0x94>
ffffffffc0203a24:	00002697          	auipc	a3,0x2
ffffffffc0203a28:	4d468693          	addi	a3,a3,1236 # ffffffffc0205ef8 <default_pmm_manager+0x748>
ffffffffc0203a2c:	00002617          	auipc	a2,0x2
ffffffffc0203a30:	9d460613          	addi	a2,a2,-1580 # ffffffffc0205400 <commands+0x738>
ffffffffc0203a34:	0cf00593          	li	a1,207
ffffffffc0203a38:	00003517          	auipc	a0,0x3
ffffffffc0203a3c:	95050513          	addi	a0,a0,-1712 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203a40:	a07fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203a44:	649c                	ld	a5,8(s1)
ffffffffc0203a46:	471d                	li	a4,7
ffffffffc0203a48:	1fb00593          	li	a1,507
ffffffffc0203a4c:	30f48e63          	beq	s1,a5,ffffffffc0203d68 <vmm_init+0x3fc>
ffffffffc0203a50:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203a54:	ffe70613          	addi	a2,a4,-2
ffffffffc0203a58:	2ad61863          	bne	a2,a3,ffffffffc0203d08 <vmm_init+0x39c>
ffffffffc0203a5c:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203a60:	2ae69463          	bne	a3,a4,ffffffffc0203d08 <vmm_init+0x39c>
ffffffffc0203a64:	0715                	addi	a4,a4,5
ffffffffc0203a66:	679c                	ld	a5,8(a5)
ffffffffc0203a68:	feb712e3          	bne	a4,a1,ffffffffc0203a4c <vmm_init+0xe0>
ffffffffc0203a6c:	4a1d                	li	s4,7
ffffffffc0203a6e:	4415                	li	s0,5
ffffffffc0203a70:	1f900a93          	li	s5,505
ffffffffc0203a74:	85a2                	mv	a1,s0
ffffffffc0203a76:	8526                	mv	a0,s1
ffffffffc0203a78:	db7ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203a7c:	892a                	mv	s2,a0
ffffffffc0203a7e:	34050563          	beqz	a0,ffffffffc0203dc8 <vmm_init+0x45c>
ffffffffc0203a82:	00140593          	addi	a1,s0,1
ffffffffc0203a86:	8526                	mv	a0,s1
ffffffffc0203a88:	da7ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203a8c:	89aa                	mv	s3,a0
ffffffffc0203a8e:	34050d63          	beqz	a0,ffffffffc0203de8 <vmm_init+0x47c>
ffffffffc0203a92:	85d2                	mv	a1,s4
ffffffffc0203a94:	8526                	mv	a0,s1
ffffffffc0203a96:	d99ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203a9a:	36051763          	bnez	a0,ffffffffc0203e08 <vmm_init+0x49c>
ffffffffc0203a9e:	00340593          	addi	a1,s0,3
ffffffffc0203aa2:	8526                	mv	a0,s1
ffffffffc0203aa4:	d8bff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203aa8:	2e051063          	bnez	a0,ffffffffc0203d88 <vmm_init+0x41c>
ffffffffc0203aac:	00440593          	addi	a1,s0,4
ffffffffc0203ab0:	8526                	mv	a0,s1
ffffffffc0203ab2:	d7dff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203ab6:	2e051963          	bnez	a0,ffffffffc0203da8 <vmm_init+0x43c>
ffffffffc0203aba:	00893783          	ld	a5,8(s2)
ffffffffc0203abe:	26879563          	bne	a5,s0,ffffffffc0203d28 <vmm_init+0x3bc>
ffffffffc0203ac2:	01093783          	ld	a5,16(s2)
ffffffffc0203ac6:	27479163          	bne	a5,s4,ffffffffc0203d28 <vmm_init+0x3bc>
ffffffffc0203aca:	0089b783          	ld	a5,8(s3)
ffffffffc0203ace:	26879d63          	bne	a5,s0,ffffffffc0203d48 <vmm_init+0x3dc>
ffffffffc0203ad2:	0109b783          	ld	a5,16(s3)
ffffffffc0203ad6:	27479963          	bne	a5,s4,ffffffffc0203d48 <vmm_init+0x3dc>
ffffffffc0203ada:	0415                	addi	s0,s0,5
ffffffffc0203adc:	0a15                	addi	s4,s4,5
ffffffffc0203ade:	f9541be3          	bne	s0,s5,ffffffffc0203a74 <vmm_init+0x108>
ffffffffc0203ae2:	4411                	li	s0,4
ffffffffc0203ae4:	597d                	li	s2,-1
ffffffffc0203ae6:	85a2                	mv	a1,s0
ffffffffc0203ae8:	8526                	mv	a0,s1
ffffffffc0203aea:	d45ff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203aee:	0004059b          	sext.w	a1,s0
ffffffffc0203af2:	c90d                	beqz	a0,ffffffffc0203b24 <vmm_init+0x1b8>
ffffffffc0203af4:	6914                	ld	a3,16(a0)
ffffffffc0203af6:	6510                	ld	a2,8(a0)
ffffffffc0203af8:	00003517          	auipc	a0,0x3
ffffffffc0203afc:	a0050513          	addi	a0,a0,-1536 # ffffffffc02064f8 <default_pmm_manager+0xd48>
ffffffffc0203b00:	e80fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203b04:	00003697          	auipc	a3,0x3
ffffffffc0203b08:	a1c68693          	addi	a3,a3,-1508 # ffffffffc0206520 <default_pmm_manager+0xd70>
ffffffffc0203b0c:	00002617          	auipc	a2,0x2
ffffffffc0203b10:	8f460613          	addi	a2,a2,-1804 # ffffffffc0205400 <commands+0x738>
ffffffffc0203b14:	0f100593          	li	a1,241
ffffffffc0203b18:	00003517          	auipc	a0,0x3
ffffffffc0203b1c:	87050513          	addi	a0,a0,-1936 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203b20:	927fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203b24:	147d                	addi	s0,s0,-1
ffffffffc0203b26:	fd2410e3          	bne	s0,s2,ffffffffc0203ae6 <vmm_init+0x17a>
ffffffffc0203b2a:	a801                	j	ffffffffc0203b3a <vmm_init+0x1ce>
ffffffffc0203b2c:	6118                	ld	a4,0(a0)
ffffffffc0203b2e:	651c                	ld	a5,8(a0)
ffffffffc0203b30:	1501                	addi	a0,a0,-32
ffffffffc0203b32:	e71c                	sd	a5,8(a4)
ffffffffc0203b34:	e398                	sd	a4,0(a5)
ffffffffc0203b36:	da5fd0ef          	jal	ra,ffffffffc02018da <kfree>
ffffffffc0203b3a:	6488                	ld	a0,8(s1)
ffffffffc0203b3c:	fea498e3          	bne	s1,a0,ffffffffc0203b2c <vmm_init+0x1c0>
ffffffffc0203b40:	8526                	mv	a0,s1
ffffffffc0203b42:	d99fd0ef          	jal	ra,ffffffffc02018da <kfree>
ffffffffc0203b46:	00003517          	auipc	a0,0x3
ffffffffc0203b4a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0206538 <default_pmm_manager+0xd88>
ffffffffc0203b4e:	e32fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203b52:	f89fd0ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0203b56:	84aa                	mv	s1,a0
ffffffffc0203b58:	03000513          	li	a0,48
ffffffffc0203b5c:	ccffd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203b60:	842a                	mv	s0,a0
ffffffffc0203b62:	2c050363          	beqz	a0,ffffffffc0203e28 <vmm_init+0x4bc>
ffffffffc0203b66:	00012797          	auipc	a5,0x12
ffffffffc0203b6a:	a2a7a783          	lw	a5,-1494(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0203b6e:	e508                	sd	a0,8(a0)
ffffffffc0203b70:	e108                	sd	a0,0(a0)
ffffffffc0203b72:	00053823          	sd	zero,16(a0)
ffffffffc0203b76:	00053c23          	sd	zero,24(a0)
ffffffffc0203b7a:	02052023          	sw	zero,32(a0)
ffffffffc0203b7e:	18079263          	bnez	a5,ffffffffc0203d02 <vmm_init+0x396>
ffffffffc0203b82:	02053423          	sd	zero,40(a0)
ffffffffc0203b86:	00012917          	auipc	s2,0x12
ffffffffc0203b8a:	9d293903          	ld	s2,-1582(s2) # ffffffffc0215558 <boot_pgdir>
ffffffffc0203b8e:	00093783          	ld	a5,0(s2)
ffffffffc0203b92:	00012717          	auipc	a4,0x12
ffffffffc0203b96:	a0873323          	sd	s0,-1530(a4) # ffffffffc0215598 <check_mm_struct>
ffffffffc0203b9a:	01243c23          	sd	s2,24(s0)
ffffffffc0203b9e:	36079163          	bnez	a5,ffffffffc0203f00 <vmm_init+0x594>
ffffffffc0203ba2:	03000513          	li	a0,48
ffffffffc0203ba6:	c85fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc0203baa:	89aa                	mv	s3,a0
ffffffffc0203bac:	2a050263          	beqz	a0,ffffffffc0203e50 <vmm_init+0x4e4>
ffffffffc0203bb0:	002007b7          	lui	a5,0x200
ffffffffc0203bb4:	00f9b823          	sd	a5,16(s3)
ffffffffc0203bb8:	4789                	li	a5,2
ffffffffc0203bba:	85aa                	mv	a1,a0
ffffffffc0203bbc:	00f9ac23          	sw	a5,24(s3)
ffffffffc0203bc0:	8522                	mv	a0,s0
ffffffffc0203bc2:	0009b423          	sd	zero,8(s3)
ffffffffc0203bc6:	ca9ff0ef          	jal	ra,ffffffffc020386e <insert_vma_struct>
ffffffffc0203bca:	10000593          	li	a1,256
ffffffffc0203bce:	8522                	mv	a0,s0
ffffffffc0203bd0:	c5fff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203bd4:	10000793          	li	a5,256
ffffffffc0203bd8:	16400713          	li	a4,356
ffffffffc0203bdc:	28a99a63          	bne	s3,a0,ffffffffc0203e70 <vmm_init+0x504>
ffffffffc0203be0:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
ffffffffc0203be4:	0785                	addi	a5,a5,1
ffffffffc0203be6:	fee79de3          	bne	a5,a4,ffffffffc0203be0 <vmm_init+0x274>
ffffffffc0203bea:	6705                	lui	a4,0x1
ffffffffc0203bec:	10000793          	li	a5,256
ffffffffc0203bf0:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
ffffffffc0203bf4:	16400613          	li	a2,356
ffffffffc0203bf8:	0007c683          	lbu	a3,0(a5)
ffffffffc0203bfc:	0785                	addi	a5,a5,1
ffffffffc0203bfe:	9f15                	subw	a4,a4,a3
ffffffffc0203c00:	fec79ce3          	bne	a5,a2,ffffffffc0203bf8 <vmm_init+0x28c>
ffffffffc0203c04:	28071663          	bnez	a4,ffffffffc0203e90 <vmm_init+0x524>
ffffffffc0203c08:	00093783          	ld	a5,0(s2)
ffffffffc0203c0c:	00012a97          	auipc	s5,0x12
ffffffffc0203c10:	954a8a93          	addi	s5,s5,-1708 # ffffffffc0215560 <npage>
ffffffffc0203c14:	000ab603          	ld	a2,0(s5)
ffffffffc0203c18:	078a                	slli	a5,a5,0x2
ffffffffc0203c1a:	83b1                	srli	a5,a5,0xc
ffffffffc0203c1c:	28c7fa63          	bgeu	a5,a2,ffffffffc0203eb0 <vmm_init+0x544>
ffffffffc0203c20:	00003a17          	auipc	s4,0x3
ffffffffc0203c24:	e60a3a03          	ld	s4,-416(s4) # ffffffffc0206a80 <nbase>
ffffffffc0203c28:	414787b3          	sub	a5,a5,s4
ffffffffc0203c2c:	079a                	slli	a5,a5,0x6
ffffffffc0203c2e:	8799                	srai	a5,a5,0x6
ffffffffc0203c30:	97d2                	add	a5,a5,s4
ffffffffc0203c32:	00c79713          	slli	a4,a5,0xc
ffffffffc0203c36:	8331                	srli	a4,a4,0xc
ffffffffc0203c38:	00c79693          	slli	a3,a5,0xc
ffffffffc0203c3c:	28c77663          	bgeu	a4,a2,ffffffffc0203ec8 <vmm_init+0x55c>
ffffffffc0203c40:	00012997          	auipc	s3,0x12
ffffffffc0203c44:	9389b983          	ld	s3,-1736(s3) # ffffffffc0215578 <va_pa_offset>
ffffffffc0203c48:	4581                	li	a1,0
ffffffffc0203c4a:	854a                	mv	a0,s2
ffffffffc0203c4c:	99b6                	add	s3,s3,a3
ffffffffc0203c4e:	8ecfe0ef          	jal	ra,ffffffffc0201d3a <page_remove>
ffffffffc0203c52:	0009b783          	ld	a5,0(s3)
ffffffffc0203c56:	000ab703          	ld	a4,0(s5)
ffffffffc0203c5a:	078a                	slli	a5,a5,0x2
ffffffffc0203c5c:	83b1                	srli	a5,a5,0xc
ffffffffc0203c5e:	24e7f963          	bgeu	a5,a4,ffffffffc0203eb0 <vmm_init+0x544>
ffffffffc0203c62:	00012997          	auipc	s3,0x12
ffffffffc0203c66:	90698993          	addi	s3,s3,-1786 # ffffffffc0215568 <pages>
ffffffffc0203c6a:	0009b503          	ld	a0,0(s3)
ffffffffc0203c6e:	414787b3          	sub	a5,a5,s4
ffffffffc0203c72:	079a                	slli	a5,a5,0x6
ffffffffc0203c74:	953e                	add	a0,a0,a5
ffffffffc0203c76:	4585                	li	a1,1
ffffffffc0203c78:	e23fd0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0203c7c:	00093783          	ld	a5,0(s2)
ffffffffc0203c80:	000ab703          	ld	a4,0(s5)
ffffffffc0203c84:	078a                	slli	a5,a5,0x2
ffffffffc0203c86:	83b1                	srli	a5,a5,0xc
ffffffffc0203c88:	22e7f463          	bgeu	a5,a4,ffffffffc0203eb0 <vmm_init+0x544>
ffffffffc0203c8c:	0009b503          	ld	a0,0(s3)
ffffffffc0203c90:	414787b3          	sub	a5,a5,s4
ffffffffc0203c94:	079a                	slli	a5,a5,0x6
ffffffffc0203c96:	4585                	li	a1,1
ffffffffc0203c98:	953e                	add	a0,a0,a5
ffffffffc0203c9a:	e01fd0ef          	jal	ra,ffffffffc0201a9a <free_pages>
ffffffffc0203c9e:	00093023          	sd	zero,0(s2)
ffffffffc0203ca2:	12000073          	sfence.vma
ffffffffc0203ca6:	6408                	ld	a0,8(s0)
ffffffffc0203ca8:	00043c23          	sd	zero,24(s0)
ffffffffc0203cac:	00a40c63          	beq	s0,a0,ffffffffc0203cc4 <vmm_init+0x358>
ffffffffc0203cb0:	6118                	ld	a4,0(a0)
ffffffffc0203cb2:	651c                	ld	a5,8(a0)
ffffffffc0203cb4:	1501                	addi	a0,a0,-32
ffffffffc0203cb6:	e71c                	sd	a5,8(a4)
ffffffffc0203cb8:	e398                	sd	a4,0(a5)
ffffffffc0203cba:	c21fd0ef          	jal	ra,ffffffffc02018da <kfree>
ffffffffc0203cbe:	6408                	ld	a0,8(s0)
ffffffffc0203cc0:	fea418e3          	bne	s0,a0,ffffffffc0203cb0 <vmm_init+0x344>
ffffffffc0203cc4:	8522                	mv	a0,s0
ffffffffc0203cc6:	c15fd0ef          	jal	ra,ffffffffc02018da <kfree>
ffffffffc0203cca:	00012797          	auipc	a5,0x12
ffffffffc0203cce:	8c07b723          	sd	zero,-1842(a5) # ffffffffc0215598 <check_mm_struct>
ffffffffc0203cd2:	e09fd0ef          	jal	ra,ffffffffc0201ada <nr_free_pages>
ffffffffc0203cd6:	20a49563          	bne	s1,a0,ffffffffc0203ee0 <vmm_init+0x574>
ffffffffc0203cda:	00003517          	auipc	a0,0x3
ffffffffc0203cde:	8d650513          	addi	a0,a0,-1834 # ffffffffc02065b0 <default_pmm_manager+0xe00>
ffffffffc0203ce2:	c9efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203ce6:	7442                	ld	s0,48(sp)
ffffffffc0203ce8:	70e2                	ld	ra,56(sp)
ffffffffc0203cea:	74a2                	ld	s1,40(sp)
ffffffffc0203cec:	7902                	ld	s2,32(sp)
ffffffffc0203cee:	69e2                	ld	s3,24(sp)
ffffffffc0203cf0:	6a42                	ld	s4,16(sp)
ffffffffc0203cf2:	6aa2                	ld	s5,8(sp)
ffffffffc0203cf4:	00003517          	auipc	a0,0x3
ffffffffc0203cf8:	8dc50513          	addi	a0,a0,-1828 # ffffffffc02065d0 <default_pmm_manager+0xe20>
ffffffffc0203cfc:	6121                	addi	sp,sp,64
ffffffffc0203cfe:	c82fc06f          	j	ffffffffc0200180 <cprintf>
ffffffffc0203d02:	d78ff0ef          	jal	ra,ffffffffc020327a <swap_init_mm>
ffffffffc0203d06:	b541                	j	ffffffffc0203b86 <vmm_init+0x21a>
ffffffffc0203d08:	00002697          	auipc	a3,0x2
ffffffffc0203d0c:	70868693          	addi	a3,a3,1800 # ffffffffc0206410 <default_pmm_manager+0xc60>
ffffffffc0203d10:	00001617          	auipc	a2,0x1
ffffffffc0203d14:	6f060613          	addi	a2,a2,1776 # ffffffffc0205400 <commands+0x738>
ffffffffc0203d18:	0d800593          	li	a1,216
ffffffffc0203d1c:	00002517          	auipc	a0,0x2
ffffffffc0203d20:	66c50513          	addi	a0,a0,1644 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203d24:	f22fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203d28:	00002697          	auipc	a3,0x2
ffffffffc0203d2c:	77068693          	addi	a3,a3,1904 # ffffffffc0206498 <default_pmm_manager+0xce8>
ffffffffc0203d30:	00001617          	auipc	a2,0x1
ffffffffc0203d34:	6d060613          	addi	a2,a2,1744 # ffffffffc0205400 <commands+0x738>
ffffffffc0203d38:	0e800593          	li	a1,232
ffffffffc0203d3c:	00002517          	auipc	a0,0x2
ffffffffc0203d40:	64c50513          	addi	a0,a0,1612 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203d44:	f02fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203d48:	00002697          	auipc	a3,0x2
ffffffffc0203d4c:	78068693          	addi	a3,a3,1920 # ffffffffc02064c8 <default_pmm_manager+0xd18>
ffffffffc0203d50:	00001617          	auipc	a2,0x1
ffffffffc0203d54:	6b060613          	addi	a2,a2,1712 # ffffffffc0205400 <commands+0x738>
ffffffffc0203d58:	0e900593          	li	a1,233
ffffffffc0203d5c:	00002517          	auipc	a0,0x2
ffffffffc0203d60:	62c50513          	addi	a0,a0,1580 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203d64:	ee2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203d68:	00002697          	auipc	a3,0x2
ffffffffc0203d6c:	69068693          	addi	a3,a3,1680 # ffffffffc02063f8 <default_pmm_manager+0xc48>
ffffffffc0203d70:	00001617          	auipc	a2,0x1
ffffffffc0203d74:	69060613          	addi	a2,a2,1680 # ffffffffc0205400 <commands+0x738>
ffffffffc0203d78:	0d600593          	li	a1,214
ffffffffc0203d7c:	00002517          	auipc	a0,0x2
ffffffffc0203d80:	60c50513          	addi	a0,a0,1548 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203d84:	ec2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203d88:	00002697          	auipc	a3,0x2
ffffffffc0203d8c:	6f068693          	addi	a3,a3,1776 # ffffffffc0206478 <default_pmm_manager+0xcc8>
ffffffffc0203d90:	00001617          	auipc	a2,0x1
ffffffffc0203d94:	67060613          	addi	a2,a2,1648 # ffffffffc0205400 <commands+0x738>
ffffffffc0203d98:	0e400593          	li	a1,228
ffffffffc0203d9c:	00002517          	auipc	a0,0x2
ffffffffc0203da0:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203da4:	ea2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203da8:	00002697          	auipc	a3,0x2
ffffffffc0203dac:	6e068693          	addi	a3,a3,1760 # ffffffffc0206488 <default_pmm_manager+0xcd8>
ffffffffc0203db0:	00001617          	auipc	a2,0x1
ffffffffc0203db4:	65060613          	addi	a2,a2,1616 # ffffffffc0205400 <commands+0x738>
ffffffffc0203db8:	0e600593          	li	a1,230
ffffffffc0203dbc:	00002517          	auipc	a0,0x2
ffffffffc0203dc0:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203dc4:	e82fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203dc8:	00002697          	auipc	a3,0x2
ffffffffc0203dcc:	68068693          	addi	a3,a3,1664 # ffffffffc0206448 <default_pmm_manager+0xc98>
ffffffffc0203dd0:	00001617          	auipc	a2,0x1
ffffffffc0203dd4:	63060613          	addi	a2,a2,1584 # ffffffffc0205400 <commands+0x738>
ffffffffc0203dd8:	0de00593          	li	a1,222
ffffffffc0203ddc:	00002517          	auipc	a0,0x2
ffffffffc0203de0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203de4:	e62fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203de8:	00002697          	auipc	a3,0x2
ffffffffc0203dec:	67068693          	addi	a3,a3,1648 # ffffffffc0206458 <default_pmm_manager+0xca8>
ffffffffc0203df0:	00001617          	auipc	a2,0x1
ffffffffc0203df4:	61060613          	addi	a2,a2,1552 # ffffffffc0205400 <commands+0x738>
ffffffffc0203df8:	0e000593          	li	a1,224
ffffffffc0203dfc:	00002517          	auipc	a0,0x2
ffffffffc0203e00:	58c50513          	addi	a0,a0,1420 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203e04:	e42fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203e08:	00002697          	auipc	a3,0x2
ffffffffc0203e0c:	66068693          	addi	a3,a3,1632 # ffffffffc0206468 <default_pmm_manager+0xcb8>
ffffffffc0203e10:	00001617          	auipc	a2,0x1
ffffffffc0203e14:	5f060613          	addi	a2,a2,1520 # ffffffffc0205400 <commands+0x738>
ffffffffc0203e18:	0e200593          	li	a1,226
ffffffffc0203e1c:	00002517          	auipc	a0,0x2
ffffffffc0203e20:	56c50513          	addi	a0,a0,1388 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203e24:	e22fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203e28:	00002697          	auipc	a3,0x2
ffffffffc0203e2c:	7c068693          	addi	a3,a3,1984 # ffffffffc02065e8 <default_pmm_manager+0xe38>
ffffffffc0203e30:	00001617          	auipc	a2,0x1
ffffffffc0203e34:	5d060613          	addi	a2,a2,1488 # ffffffffc0205400 <commands+0x738>
ffffffffc0203e38:	10100593          	li	a1,257
ffffffffc0203e3c:	00002517          	auipc	a0,0x2
ffffffffc0203e40:	54c50513          	addi	a0,a0,1356 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203e44:	00011797          	auipc	a5,0x11
ffffffffc0203e48:	7407ba23          	sd	zero,1876(a5) # ffffffffc0215598 <check_mm_struct>
ffffffffc0203e4c:	dfafc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203e50:	00002697          	auipc	a3,0x2
ffffffffc0203e54:	0a868693          	addi	a3,a3,168 # ffffffffc0205ef8 <default_pmm_manager+0x748>
ffffffffc0203e58:	00001617          	auipc	a2,0x1
ffffffffc0203e5c:	5a860613          	addi	a2,a2,1448 # ffffffffc0205400 <commands+0x738>
ffffffffc0203e60:	10800593          	li	a1,264
ffffffffc0203e64:	00002517          	auipc	a0,0x2
ffffffffc0203e68:	52450513          	addi	a0,a0,1316 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203e6c:	ddafc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203e70:	00002697          	auipc	a3,0x2
ffffffffc0203e74:	6e868693          	addi	a3,a3,1768 # ffffffffc0206558 <default_pmm_manager+0xda8>
ffffffffc0203e78:	00001617          	auipc	a2,0x1
ffffffffc0203e7c:	58860613          	addi	a2,a2,1416 # ffffffffc0205400 <commands+0x738>
ffffffffc0203e80:	10d00593          	li	a1,269
ffffffffc0203e84:	00002517          	auipc	a0,0x2
ffffffffc0203e88:	50450513          	addi	a0,a0,1284 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203e8c:	dbafc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203e90:	00002697          	auipc	a3,0x2
ffffffffc0203e94:	6e868693          	addi	a3,a3,1768 # ffffffffc0206578 <default_pmm_manager+0xdc8>
ffffffffc0203e98:	00001617          	auipc	a2,0x1
ffffffffc0203e9c:	56860613          	addi	a2,a2,1384 # ffffffffc0205400 <commands+0x738>
ffffffffc0203ea0:	11700593          	li	a1,279
ffffffffc0203ea4:	00002517          	auipc	a0,0x2
ffffffffc0203ea8:	4e450513          	addi	a0,a0,1252 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203eac:	d9afc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203eb0:	00002617          	auipc	a2,0x2
ffffffffc0203eb4:	a0860613          	addi	a2,a2,-1528 # ffffffffc02058b8 <default_pmm_manager+0x108>
ffffffffc0203eb8:	06200593          	li	a1,98
ffffffffc0203ebc:	00002517          	auipc	a0,0x2
ffffffffc0203ec0:	95450513          	addi	a0,a0,-1708 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0203ec4:	d82fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203ec8:	00002617          	auipc	a2,0x2
ffffffffc0203ecc:	92060613          	addi	a2,a2,-1760 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc0203ed0:	06900593          	li	a1,105
ffffffffc0203ed4:	00002517          	auipc	a0,0x2
ffffffffc0203ed8:	93c50513          	addi	a0,a0,-1732 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc0203edc:	d6afc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203ee0:	00002697          	auipc	a3,0x2
ffffffffc0203ee4:	6a868693          	addi	a3,a3,1704 # ffffffffc0206588 <default_pmm_manager+0xdd8>
ffffffffc0203ee8:	00001617          	auipc	a2,0x1
ffffffffc0203eec:	51860613          	addi	a2,a2,1304 # ffffffffc0205400 <commands+0x738>
ffffffffc0203ef0:	12400593          	li	a1,292
ffffffffc0203ef4:	00002517          	auipc	a0,0x2
ffffffffc0203ef8:	49450513          	addi	a0,a0,1172 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203efc:	d4afc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203f00:	00002697          	auipc	a3,0x2
ffffffffc0203f04:	fe868693          	addi	a3,a3,-24 # ffffffffc0205ee8 <default_pmm_manager+0x738>
ffffffffc0203f08:	00001617          	auipc	a2,0x1
ffffffffc0203f0c:	4f860613          	addi	a2,a2,1272 # ffffffffc0205400 <commands+0x738>
ffffffffc0203f10:	10500593          	li	a1,261
ffffffffc0203f14:	00002517          	auipc	a0,0x2
ffffffffc0203f18:	47450513          	addi	a0,a0,1140 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203f1c:	d2afc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc0203f20:	00002697          	auipc	a3,0x2
ffffffffc0203f24:	fa068693          	addi	a3,a3,-96 # ffffffffc0205ec0 <default_pmm_manager+0x710>
ffffffffc0203f28:	00001617          	auipc	a2,0x1
ffffffffc0203f2c:	4d860613          	addi	a2,a2,1240 # ffffffffc0205400 <commands+0x738>
ffffffffc0203f30:	0c200593          	li	a1,194
ffffffffc0203f34:	00002517          	auipc	a0,0x2
ffffffffc0203f38:	45450513          	addi	a0,a0,1108 # ffffffffc0206388 <default_pmm_manager+0xbd8>
ffffffffc0203f3c:	d0afc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0203f40 <do_pgfault>:
ffffffffc0203f40:	1101                	addi	sp,sp,-32
ffffffffc0203f42:	85b2                	mv	a1,a2
ffffffffc0203f44:	e822                	sd	s0,16(sp)
ffffffffc0203f46:	e426                	sd	s1,8(sp)
ffffffffc0203f48:	ec06                	sd	ra,24(sp)
ffffffffc0203f4a:	e04a                	sd	s2,0(sp)
ffffffffc0203f4c:	8432                	mv	s0,a2
ffffffffc0203f4e:	84aa                	mv	s1,a0
ffffffffc0203f50:	8dfff0ef          	jal	ra,ffffffffc020382e <find_vma>
ffffffffc0203f54:	00011797          	auipc	a5,0x11
ffffffffc0203f58:	64c7a783          	lw	a5,1612(a5) # ffffffffc02155a0 <pgfault_num>
ffffffffc0203f5c:	2785                	addiw	a5,a5,1
ffffffffc0203f5e:	00011717          	auipc	a4,0x11
ffffffffc0203f62:	64f72123          	sw	a5,1602(a4) # ffffffffc02155a0 <pgfault_num>
ffffffffc0203f66:	c931                	beqz	a0,ffffffffc0203fba <do_pgfault+0x7a>
ffffffffc0203f68:	651c                	ld	a5,8(a0)
ffffffffc0203f6a:	04f46863          	bltu	s0,a5,ffffffffc0203fba <do_pgfault+0x7a>
ffffffffc0203f6e:	4d1c                	lw	a5,24(a0)
ffffffffc0203f70:	4941                	li	s2,16
ffffffffc0203f72:	8b89                	andi	a5,a5,2
ffffffffc0203f74:	e39d                	bnez	a5,ffffffffc0203f9a <do_pgfault+0x5a>
ffffffffc0203f76:	75fd                	lui	a1,0xfffff
ffffffffc0203f78:	6c88                	ld	a0,24(s1)
ffffffffc0203f7a:	8c6d                	and	s0,s0,a1
ffffffffc0203f7c:	4605                	li	a2,1
ffffffffc0203f7e:	85a2                	mv	a1,s0
ffffffffc0203f80:	b95fd0ef          	jal	ra,ffffffffc0201b14 <get_pte>
ffffffffc0203f84:	cd21                	beqz	a0,ffffffffc0203fdc <do_pgfault+0x9c>
ffffffffc0203f86:	610c                	ld	a1,0(a0)
ffffffffc0203f88:	c999                	beqz	a1,ffffffffc0203f9e <do_pgfault+0x5e>
ffffffffc0203f8a:	00011797          	auipc	a5,0x11
ffffffffc0203f8e:	6067a783          	lw	a5,1542(a5) # ffffffffc0215590 <swap_init_ok>
ffffffffc0203f92:	cf8d                	beqz	a5,ffffffffc0203fcc <do_pgfault+0x8c>
ffffffffc0203f94:	02003c23          	sd	zero,56(zero) # 38 <kern_entry-0xffffffffc01fffc8>
ffffffffc0203f98:	9002                	ebreak
ffffffffc0203f9a:	495d                	li	s2,23
ffffffffc0203f9c:	bfe9                	j	ffffffffc0203f76 <do_pgfault+0x36>
ffffffffc0203f9e:	6c88                	ld	a0,24(s1)
ffffffffc0203fa0:	864a                	mv	a2,s2
ffffffffc0203fa2:	85a2                	mv	a1,s0
ffffffffc0203fa4:	ac9fe0ef          	jal	ra,ffffffffc0202a6c <pgdir_alloc_page>
ffffffffc0203fa8:	87aa                	mv	a5,a0
ffffffffc0203faa:	4501                	li	a0,0
ffffffffc0203fac:	c3a1                	beqz	a5,ffffffffc0203fec <do_pgfault+0xac>
ffffffffc0203fae:	60e2                	ld	ra,24(sp)
ffffffffc0203fb0:	6442                	ld	s0,16(sp)
ffffffffc0203fb2:	64a2                	ld	s1,8(sp)
ffffffffc0203fb4:	6902                	ld	s2,0(sp)
ffffffffc0203fb6:	6105                	addi	sp,sp,32
ffffffffc0203fb8:	8082                	ret
ffffffffc0203fba:	85a2                	mv	a1,s0
ffffffffc0203fbc:	00002517          	auipc	a0,0x2
ffffffffc0203fc0:	64450513          	addi	a0,a0,1604 # ffffffffc0206600 <default_pmm_manager+0xe50>
ffffffffc0203fc4:	9bcfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203fc8:	5575                	li	a0,-3
ffffffffc0203fca:	b7d5                	j	ffffffffc0203fae <do_pgfault+0x6e>
ffffffffc0203fcc:	00002517          	auipc	a0,0x2
ffffffffc0203fd0:	6ac50513          	addi	a0,a0,1708 # ffffffffc0206678 <default_pmm_manager+0xec8>
ffffffffc0203fd4:	9acfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203fd8:	5571                	li	a0,-4
ffffffffc0203fda:	bfd1                	j	ffffffffc0203fae <do_pgfault+0x6e>
ffffffffc0203fdc:	00002517          	auipc	a0,0x2
ffffffffc0203fe0:	65450513          	addi	a0,a0,1620 # ffffffffc0206630 <default_pmm_manager+0xe80>
ffffffffc0203fe4:	99cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203fe8:	5571                	li	a0,-4
ffffffffc0203fea:	b7d1                	j	ffffffffc0203fae <do_pgfault+0x6e>
ffffffffc0203fec:	00002517          	auipc	a0,0x2
ffffffffc0203ff0:	66450513          	addi	a0,a0,1636 # ffffffffc0206650 <default_pmm_manager+0xea0>
ffffffffc0203ff4:	98cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203ff8:	5571                	li	a0,-4
ffffffffc0203ffa:	bf55                	j	ffffffffc0203fae <do_pgfault+0x6e>

ffffffffc0203ffc <swapfs_init>:
ffffffffc0203ffc:	1141                	addi	sp,sp,-16
ffffffffc0203ffe:	4505                	li	a0,1
ffffffffc0204000:	e406                	sd	ra,8(sp)
ffffffffc0204002:	d66fc0ef          	jal	ra,ffffffffc0200568 <ide_device_valid>
ffffffffc0204006:	cd01                	beqz	a0,ffffffffc020401e <swapfs_init+0x22>
ffffffffc0204008:	4505                	li	a0,1
ffffffffc020400a:	d64fc0ef          	jal	ra,ffffffffc020056e <ide_device_size>
ffffffffc020400e:	60a2                	ld	ra,8(sp)
ffffffffc0204010:	810d                	srli	a0,a0,0x3
ffffffffc0204012:	00011797          	auipc	a5,0x11
ffffffffc0204016:	56a7b723          	sd	a0,1390(a5) # ffffffffc0215580 <max_swap_offset>
ffffffffc020401a:	0141                	addi	sp,sp,16
ffffffffc020401c:	8082                	ret
ffffffffc020401e:	00002617          	auipc	a2,0x2
ffffffffc0204022:	68260613          	addi	a2,a2,1666 # ffffffffc02066a0 <default_pmm_manager+0xef0>
ffffffffc0204026:	45b5                	li	a1,13
ffffffffc0204028:	00002517          	auipc	a0,0x2
ffffffffc020402c:	69850513          	addi	a0,a0,1688 # ffffffffc02066c0 <default_pmm_manager+0xf10>
ffffffffc0204030:	c16fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204034 <swapfs_write>:
ffffffffc0204034:	1141                	addi	sp,sp,-16
ffffffffc0204036:	e406                	sd	ra,8(sp)
ffffffffc0204038:	00855793          	srli	a5,a0,0x8
ffffffffc020403c:	cbb1                	beqz	a5,ffffffffc0204090 <swapfs_write+0x5c>
ffffffffc020403e:	00011717          	auipc	a4,0x11
ffffffffc0204042:	54273703          	ld	a4,1346(a4) # ffffffffc0215580 <max_swap_offset>
ffffffffc0204046:	04e7f563          	bgeu	a5,a4,ffffffffc0204090 <swapfs_write+0x5c>
ffffffffc020404a:	00011617          	auipc	a2,0x11
ffffffffc020404e:	51e63603          	ld	a2,1310(a2) # ffffffffc0215568 <pages>
ffffffffc0204052:	8d91                	sub	a1,a1,a2
ffffffffc0204054:	4065d613          	srai	a2,a1,0x6
ffffffffc0204058:	00003717          	auipc	a4,0x3
ffffffffc020405c:	a2873703          	ld	a4,-1496(a4) # ffffffffc0206a80 <nbase>
ffffffffc0204060:	963a                	add	a2,a2,a4
ffffffffc0204062:	00c61713          	slli	a4,a2,0xc
ffffffffc0204066:	8331                	srli	a4,a4,0xc
ffffffffc0204068:	00011697          	auipc	a3,0x11
ffffffffc020406c:	4f86b683          	ld	a3,1272(a3) # ffffffffc0215560 <npage>
ffffffffc0204070:	0037959b          	slliw	a1,a5,0x3
ffffffffc0204074:	0632                	slli	a2,a2,0xc
ffffffffc0204076:	02d77963          	bgeu	a4,a3,ffffffffc02040a8 <swapfs_write+0x74>
ffffffffc020407a:	60a2                	ld	ra,8(sp)
ffffffffc020407c:	00011797          	auipc	a5,0x11
ffffffffc0204080:	4fc7b783          	ld	a5,1276(a5) # ffffffffc0215578 <va_pa_offset>
ffffffffc0204084:	46a1                	li	a3,8
ffffffffc0204086:	963e                	add	a2,a2,a5
ffffffffc0204088:	4505                	li	a0,1
ffffffffc020408a:	0141                	addi	sp,sp,16
ffffffffc020408c:	ce8fc06f          	j	ffffffffc0200574 <ide_write_secs>
ffffffffc0204090:	86aa                	mv	a3,a0
ffffffffc0204092:	00002617          	auipc	a2,0x2
ffffffffc0204096:	64660613          	addi	a2,a2,1606 # ffffffffc02066d8 <default_pmm_manager+0xf28>
ffffffffc020409a:	45e5                	li	a1,25
ffffffffc020409c:	00002517          	auipc	a0,0x2
ffffffffc02040a0:	62450513          	addi	a0,a0,1572 # ffffffffc02066c0 <default_pmm_manager+0xf10>
ffffffffc02040a4:	ba2fc0ef          	jal	ra,ffffffffc0200446 <__panic>
ffffffffc02040a8:	86b2                	mv	a3,a2
ffffffffc02040aa:	06900593          	li	a1,105
ffffffffc02040ae:	00001617          	auipc	a2,0x1
ffffffffc02040b2:	73a60613          	addi	a2,a2,1850 # ffffffffc02057e8 <default_pmm_manager+0x38>
ffffffffc02040b6:	00001517          	auipc	a0,0x1
ffffffffc02040ba:	75a50513          	addi	a0,a0,1882 # ffffffffc0205810 <default_pmm_manager+0x60>
ffffffffc02040be:	b88fc0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc02040c2 <init_main>:
    panic("process exit!!.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02040c2:	7179                	addi	sp,sp,-48
ffffffffc02040c4:	ec26                	sd	s1,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc02040c6:	00011497          	auipc	s1,0x11
ffffffffc02040ca:	44a48493          	addi	s1,s1,1098 # ffffffffc0215510 <name.0>
init_main(void *arg) {
ffffffffc02040ce:	f022                	sd	s0,32(sp)
ffffffffc02040d0:	e84a                	sd	s2,16(sp)
ffffffffc02040d2:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040d4:	00011917          	auipc	s2,0x11
ffffffffc02040d8:	4d493903          	ld	s2,1236(s2) # ffffffffc02155a8 <current>
    memset(name, 0, sizeof(name));
ffffffffc02040dc:	4641                	li	a2,16
ffffffffc02040de:	4581                	li	a1,0
ffffffffc02040e0:	8526                	mv	a0,s1
init_main(void *arg) {
ffffffffc02040e2:	f406                	sd	ra,40(sp)
ffffffffc02040e4:	e44e                	sd	s3,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040e6:	00492983          	lw	s3,4(s2)
    memset(name, 0, sizeof(name));
ffffffffc02040ea:	127000ef          	jal	ra,ffffffffc0204a10 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040ee:	0b490593          	addi	a1,s2,180
ffffffffc02040f2:	463d                	li	a2,15
ffffffffc02040f4:	8526                	mv	a0,s1
ffffffffc02040f6:	12d000ef          	jal	ra,ffffffffc0204a22 <memcpy>
ffffffffc02040fa:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040fc:	85ce                	mv	a1,s3
ffffffffc02040fe:	00002517          	auipc	a0,0x2
ffffffffc0204102:	5fa50513          	addi	a0,a0,1530 # ffffffffc02066f8 <default_pmm_manager+0xf48>
ffffffffc0204106:	87afc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020410a:	85a2                	mv	a1,s0
ffffffffc020410c:	00002517          	auipc	a0,0x2
ffffffffc0204110:	61450513          	addi	a0,a0,1556 # ffffffffc0206720 <default_pmm_manager+0xf70>
ffffffffc0204114:	86cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204118:	00002517          	auipc	a0,0x2
ffffffffc020411c:	61850513          	addi	a0,a0,1560 # ffffffffc0206730 <default_pmm_manager+0xf80>
ffffffffc0204120:	860fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0204124:	70a2                	ld	ra,40(sp)
ffffffffc0204126:	7402                	ld	s0,32(sp)
ffffffffc0204128:	64e2                	ld	s1,24(sp)
ffffffffc020412a:	6942                	ld	s2,16(sp)
ffffffffc020412c:	69a2                	ld	s3,8(sp)
ffffffffc020412e:	4501                	li	a0,0
ffffffffc0204130:	6145                	addi	sp,sp,48
ffffffffc0204132:	8082                	ret

ffffffffc0204134 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204134:	7179                	addi	sp,sp,-48
ffffffffc0204136:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204138:	00011917          	auipc	s2,0x11
ffffffffc020413c:	47090913          	addi	s2,s2,1136 # ffffffffc02155a8 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204140:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204142:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204146:	f406                	sd	ra,40(sp)
ffffffffc0204148:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc020414a:	02a48963          	beq	s1,a0,ffffffffc020417c <proc_run+0x48>
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020414e:	100027f3          	csrr	a5,sstatus
ffffffffc0204152:	8b89                	andi	a5,a5,2
        intr_disable();
        return 1;
    }
    return 0;
ffffffffc0204154:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204156:	e3a1                	bnez	a5,ffffffffc0204196 <proc_run+0x62>
            lcr3(next->cr3);//cr3寄存器改为需要运行进程的页目录表
ffffffffc0204158:	755c                	ld	a5,168(a0)

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc020415a:	80000737          	lui	a4,0x80000
            current = proc; //当前进程设为待调度的进程
ffffffffc020415e:	00a93023          	sd	a0,0(s2)
ffffffffc0204162:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0204166:	8fd9                	or	a5,a5,a4
ffffffffc0204168:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));//switch_to进行上下文切换
ffffffffc020416c:	03050593          	addi	a1,a0,48
ffffffffc0204170:	03048513          	addi	a0,s1,48
ffffffffc0204174:	31e000ef          	jal	ra,ffffffffc0204492 <switch_to>
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0204178:	00099863          	bnez	s3,ffffffffc0204188 <proc_run+0x54>
}
ffffffffc020417c:	70a2                	ld	ra,40(sp)
ffffffffc020417e:	7482                	ld	s1,32(sp)
ffffffffc0204180:	6962                	ld	s2,24(sp)
ffffffffc0204182:	69c2                	ld	s3,16(sp)
ffffffffc0204184:	6145                	addi	sp,sp,48
ffffffffc0204186:	8082                	ret
ffffffffc0204188:	70a2                	ld	ra,40(sp)
ffffffffc020418a:	7482                	ld	s1,32(sp)
ffffffffc020418c:	6962                	ld	s2,24(sp)
ffffffffc020418e:	69c2                	ld	s3,16(sp)
ffffffffc0204190:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204192:	c06fc06f          	j	ffffffffc0200598 <intr_enable>
ffffffffc0204196:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204198:	c06fc0ef          	jal	ra,ffffffffc020059e <intr_disable>
        return 1;
ffffffffc020419c:	6522                	ld	a0,8(sp)
ffffffffc020419e:	4985                	li	s3,1
ffffffffc02041a0:	bf65                	j	ffffffffc0204158 <proc_run+0x24>

ffffffffc02041a2 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02041a2:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02041a4:	12000613          	li	a2,288
ffffffffc02041a8:	4581                	li	a1,0
ffffffffc02041aa:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02041ac:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02041ae:	063000ef          	jal	ra,ffffffffc0204a10 <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02041b2:	100027f3          	csrr	a5,sstatus
}
ffffffffc02041b6:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02041b8:	00011517          	auipc	a0,0x11
ffffffffc02041bc:	40852503          	lw	a0,1032(a0) # ffffffffc02155c0 <nr_process>
ffffffffc02041c0:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc02041c2:	00f52533          	slt	a0,a0,a5
}
ffffffffc02041c6:	156d                	addi	a0,a0,-5
ffffffffc02041c8:	6155                	addi	sp,sp,304
ffffffffc02041ca:	8082                	ret

ffffffffc02041cc <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02041cc:	7139                	addi	sp,sp,-64
ffffffffc02041ce:	f426                	sd	s1,40(sp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02041d0:	00011797          	auipc	a5,0x11
ffffffffc02041d4:	35078793          	addi	a5,a5,848 # ffffffffc0215520 <proc_list>
ffffffffc02041d8:	fc06                	sd	ra,56(sp)
ffffffffc02041da:	f822                	sd	s0,48(sp)
ffffffffc02041dc:	f04a                	sd	s2,32(sp)
ffffffffc02041de:	ec4e                	sd	s3,24(sp)
ffffffffc02041e0:	e852                	sd	s4,16(sp)
ffffffffc02041e2:	e456                	sd	s5,8(sp)
ffffffffc02041e4:	0000d497          	auipc	s1,0xd
ffffffffc02041e8:	32c48493          	addi	s1,s1,812 # ffffffffc0211510 <hash_list>
ffffffffc02041ec:	e79c                	sd	a5,8(a5)
ffffffffc02041ee:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc02041f0:	00011717          	auipc	a4,0x11
ffffffffc02041f4:	32070713          	addi	a4,a4,800 # ffffffffc0215510 <name.0>
ffffffffc02041f8:	87a6                	mv	a5,s1
ffffffffc02041fa:	e79c                	sd	a5,8(a5)
ffffffffc02041fc:	e39c                	sd	a5,0(a5)
ffffffffc02041fe:	07c1                	addi	a5,a5,16
ffffffffc0204200:	fef71de3          	bne	a4,a5,ffffffffc02041fa <proc_init+0x2e>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204204:	0e800513          	li	a0,232
ffffffffc0204208:	e22fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
ffffffffc020420c:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc020420e:	1e050863          	beqz	a0,ffffffffc02043fe <proc_init+0x232>
        proc->cr3 = boot_cr3;
ffffffffc0204212:	00011a97          	auipc	s5,0x11
ffffffffc0204216:	33ea8a93          	addi	s5,s5,830 # ffffffffc0215550 <boot_cr3>
ffffffffc020421a:	000ab783          	ld	a5,0(s5)
        proc->state = PROC_UNINIT;
ffffffffc020421e:	59fd                	li	s3,-1
ffffffffc0204220:	1982                	slli	s3,s3,0x20
        proc->cr3 = boot_cr3;
ffffffffc0204222:	f55c                	sd	a5,168(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204224:	07000613          	li	a2,112
ffffffffc0204228:	4581                	li	a1,0
        proc->state = PROC_UNINIT;
ffffffffc020422a:	01353023          	sd	s3,0(a0)
        proc->runs = 0;
ffffffffc020422e:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204232:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204236:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc020423a:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc020423e:	02053423          	sd	zero,40(a0)
        proc->tf = NULL;
ffffffffc0204242:	0a053023          	sd	zero,160(a0)
        proc->flags = 0;
ffffffffc0204246:	0a052823          	sw	zero,176(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc020424a:	03050513          	addi	a0,a0,48
ffffffffc020424e:	7c2000ef          	jal	ra,ffffffffc0204a10 <memset>
        memset(&(proc->name), 0, PROC_NAME_LEN);
ffffffffc0204252:	463d                	li	a2,15
ffffffffc0204254:	4581                	li	a1,0
ffffffffc0204256:	0b440513          	addi	a0,s0,180
ffffffffc020425a:	7b6000ef          	jal	ra,ffffffffc0204a10 <memset>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020425e:	00011917          	auipc	s2,0x11
ffffffffc0204262:	35290913          	addi	s2,s2,850 # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204266:	07000513          	li	a0,112
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020426a:	00893023          	sd	s0,0(s2)
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020426e:	dbcfd0ef          	jal	ra,ffffffffc020182a <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204272:	07000613          	li	a2,112
ffffffffc0204276:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204278:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020427a:	796000ef          	jal	ra,ffffffffc0204a10 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020427e:	00093503          	ld	a0,0(s2)
ffffffffc0204282:	85a2                	mv	a1,s0
ffffffffc0204284:	07000613          	li	a2,112
ffffffffc0204288:	03050513          	addi	a0,a0,48
ffffffffc020428c:	7ae000ef          	jal	ra,ffffffffc0204a3a <memcmp>
ffffffffc0204290:	8a2a                	mv	s4,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204292:	453d                	li	a0,15
ffffffffc0204294:	d96fd0ef          	jal	ra,ffffffffc020182a <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204298:	463d                	li	a2,15
ffffffffc020429a:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020429c:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020429e:	772000ef          	jal	ra,ffffffffc0204a10 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc02042a2:	00093503          	ld	a0,0(s2)
ffffffffc02042a6:	463d                	li	a2,15
ffffffffc02042a8:	85a2                	mv	a1,s0
ffffffffc02042aa:	0b450513          	addi	a0,a0,180
ffffffffc02042ae:	78c000ef          	jal	ra,ffffffffc0204a3a <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02042b2:	00093783          	ld	a5,0(s2)
ffffffffc02042b6:	000ab703          	ld	a4,0(s5)
ffffffffc02042ba:	77d4                	ld	a3,168(a5)
ffffffffc02042bc:	0ee68663          	beq	a3,a4,ffffffffc02043a8 <proc_init+0x1dc>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02042c0:	4709                	li	a4,2
ffffffffc02042c2:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02042c4:	00003717          	auipc	a4,0x3
ffffffffc02042c8:	d3c70713          	addi	a4,a4,-708 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042cc:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02042d0:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02042d2:	4705                	li	a4,1
ffffffffc02042d4:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042d6:	4641                	li	a2,16
ffffffffc02042d8:	4581                	li	a1,0
ffffffffc02042da:	8522                	mv	a0,s0
ffffffffc02042dc:	734000ef          	jal	ra,ffffffffc0204a10 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02042e0:	463d                	li	a2,15
ffffffffc02042e2:	00002597          	auipc	a1,0x2
ffffffffc02042e6:	4b658593          	addi	a1,a1,1206 # ffffffffc0206798 <default_pmm_manager+0xfe8>
ffffffffc02042ea:	8522                	mv	a0,s0
ffffffffc02042ec:	736000ef          	jal	ra,ffffffffc0204a22 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc02042f0:	00011717          	auipc	a4,0x11
ffffffffc02042f4:	2d070713          	addi	a4,a4,720 # ffffffffc02155c0 <nr_process>
ffffffffc02042f8:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc02042fa:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02042fe:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204300:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204302:	00002597          	auipc	a1,0x2
ffffffffc0204306:	49e58593          	addi	a1,a1,1182 # ffffffffc02067a0 <default_pmm_manager+0xff0>
ffffffffc020430a:	00000517          	auipc	a0,0x0
ffffffffc020430e:	db850513          	addi	a0,a0,-584 # ffffffffc02040c2 <init_main>
    nr_process ++;
ffffffffc0204312:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0204314:	00011797          	auipc	a5,0x11
ffffffffc0204318:	28d7ba23          	sd	a3,660(a5) # ffffffffc02155a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc020431c:	e87ff0ef          	jal	ra,ffffffffc02041a2 <kernel_thread>
ffffffffc0204320:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0204322:	0ea05e63          	blez	a0,ffffffffc020441e <proc_init+0x252>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204326:	6789                	lui	a5,0x2
ffffffffc0204328:	fff5071b          	addiw	a4,a0,-1
ffffffffc020432c:	17f9                	addi	a5,a5,-2
ffffffffc020432e:	2501                	sext.w	a0,a0
ffffffffc0204330:	02e7e363          	bltu	a5,a4,ffffffffc0204356 <proc_init+0x18a>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204334:	45a9                	li	a1,10
ffffffffc0204336:	25a000ef          	jal	ra,ffffffffc0204590 <hash32>
ffffffffc020433a:	02051793          	slli	a5,a0,0x20
ffffffffc020433e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204342:	96a6                	add	a3,a3,s1
ffffffffc0204344:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204346:	a029                	j	ffffffffc0204350 <proc_init+0x184>
            if (proc->pid == pid) {
ffffffffc0204348:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc020434c:	0a870663          	beq	a4,s0,ffffffffc02043f8 <proc_init+0x22c>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0204350:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204352:	fef69be3          	bne	a3,a5,ffffffffc0204348 <proc_init+0x17c>
    return NULL;
ffffffffc0204356:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204358:	0b478493          	addi	s1,a5,180
ffffffffc020435c:	4641                	li	a2,16
ffffffffc020435e:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204360:	00011417          	auipc	s0,0x11
ffffffffc0204364:	25840413          	addi	s0,s0,600 # ffffffffc02155b8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204368:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc020436a:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020436c:	6a4000ef          	jal	ra,ffffffffc0204a10 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204370:	463d                	li	a2,15
ffffffffc0204372:	00002597          	auipc	a1,0x2
ffffffffc0204376:	45e58593          	addi	a1,a1,1118 # ffffffffc02067d0 <default_pmm_manager+0x1020>
ffffffffc020437a:	8526                	mv	a0,s1
ffffffffc020437c:	6a6000ef          	jal	ra,ffffffffc0204a22 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204380:	00093783          	ld	a5,0(s2)
ffffffffc0204384:	cbe9                	beqz	a5,ffffffffc0204456 <proc_init+0x28a>
ffffffffc0204386:	43dc                	lw	a5,4(a5)
ffffffffc0204388:	e7f9                	bnez	a5,ffffffffc0204456 <proc_init+0x28a>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020438a:	601c                	ld	a5,0(s0)
ffffffffc020438c:	c7cd                	beqz	a5,ffffffffc0204436 <proc_init+0x26a>
ffffffffc020438e:	43d8                	lw	a4,4(a5)
ffffffffc0204390:	4785                	li	a5,1
ffffffffc0204392:	0af71263          	bne	a4,a5,ffffffffc0204436 <proc_init+0x26a>
}
ffffffffc0204396:	70e2                	ld	ra,56(sp)
ffffffffc0204398:	7442                	ld	s0,48(sp)
ffffffffc020439a:	74a2                	ld	s1,40(sp)
ffffffffc020439c:	7902                	ld	s2,32(sp)
ffffffffc020439e:	69e2                	ld	s3,24(sp)
ffffffffc02043a0:	6a42                	ld	s4,16(sp)
ffffffffc02043a2:	6aa2                	ld	s5,8(sp)
ffffffffc02043a4:	6121                	addi	sp,sp,64
ffffffffc02043a6:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc02043a8:	73d8                	ld	a4,160(a5)
ffffffffc02043aa:	f0071be3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
ffffffffc02043ae:	f00a19e3          	bnez	s4,ffffffffc02042c0 <proc_init+0xf4>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc02043b2:	6398                	ld	a4,0(a5)
ffffffffc02043b4:	f13716e3          	bne	a4,s3,ffffffffc02042c0 <proc_init+0xf4>
ffffffffc02043b8:	4798                	lw	a4,8(a5)
ffffffffc02043ba:	f00713e3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc02043be:	6b98                	ld	a4,16(a5)
ffffffffc02043c0:	f00710e3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
ffffffffc02043c4:	4f98                	lw	a4,24(a5)
ffffffffc02043c6:	2701                	sext.w	a4,a4
ffffffffc02043c8:	ee071ce3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
ffffffffc02043cc:	7398                	ld	a4,32(a5)
ffffffffc02043ce:	ee0719e3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc02043d2:	7798                	ld	a4,40(a5)
ffffffffc02043d4:	ee0716e3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
ffffffffc02043d8:	0b07a703          	lw	a4,176(a5)
ffffffffc02043dc:	8d59                	or	a0,a0,a4
ffffffffc02043de:	0005071b          	sext.w	a4,a0
ffffffffc02043e2:	ec071fe3          	bnez	a4,ffffffffc02042c0 <proc_init+0xf4>
        cprintf("alloc_proc() correct!\n");
ffffffffc02043e6:	00002517          	auipc	a0,0x2
ffffffffc02043ea:	39a50513          	addi	a0,a0,922 # ffffffffc0206780 <default_pmm_manager+0xfd0>
ffffffffc02043ee:	d93fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    idleproc->pid = 0;
ffffffffc02043f2:	00093783          	ld	a5,0(s2)
ffffffffc02043f6:	b5e9                	j	ffffffffc02042c0 <proc_init+0xf4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02043f8:	f2878793          	addi	a5,a5,-216
ffffffffc02043fc:	bfb1                	j	ffffffffc0204358 <proc_init+0x18c>
        panic("cannot alloc idleproc.\n");
ffffffffc02043fe:	00002617          	auipc	a2,0x2
ffffffffc0204402:	42a60613          	addi	a2,a2,1066 # ffffffffc0206828 <default_pmm_manager+0x1078>
ffffffffc0204406:	17000593          	li	a1,368
ffffffffc020440a:	00002517          	auipc	a0,0x2
ffffffffc020440e:	35e50513          	addi	a0,a0,862 # ffffffffc0206768 <default_pmm_manager+0xfb8>
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0204412:	00011797          	auipc	a5,0x11
ffffffffc0204416:	1807bf23          	sd	zero,414(a5) # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
ffffffffc020441a:	82cfc0ef          	jal	ra,ffffffffc0200446 <__panic>
        panic("create init_main failed.\n");
ffffffffc020441e:	00002617          	auipc	a2,0x2
ffffffffc0204422:	39260613          	addi	a2,a2,914 # ffffffffc02067b0 <default_pmm_manager+0x1000>
ffffffffc0204426:	19000593          	li	a1,400
ffffffffc020442a:	00002517          	auipc	a0,0x2
ffffffffc020442e:	33e50513          	addi	a0,a0,830 # ffffffffc0206768 <default_pmm_manager+0xfb8>
ffffffffc0204432:	814fc0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204436:	00002697          	auipc	a3,0x2
ffffffffc020443a:	3ca68693          	addi	a3,a3,970 # ffffffffc0206800 <default_pmm_manager+0x1050>
ffffffffc020443e:	00001617          	auipc	a2,0x1
ffffffffc0204442:	fc260613          	addi	a2,a2,-62 # ffffffffc0205400 <commands+0x738>
ffffffffc0204446:	19700593          	li	a1,407
ffffffffc020444a:	00002517          	auipc	a0,0x2
ffffffffc020444e:	31e50513          	addi	a0,a0,798 # ffffffffc0206768 <default_pmm_manager+0xfb8>
ffffffffc0204452:	ff5fb0ef          	jal	ra,ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204456:	00002697          	auipc	a3,0x2
ffffffffc020445a:	38268693          	addi	a3,a3,898 # ffffffffc02067d8 <default_pmm_manager+0x1028>
ffffffffc020445e:	00001617          	auipc	a2,0x1
ffffffffc0204462:	fa260613          	addi	a2,a2,-94 # ffffffffc0205400 <commands+0x738>
ffffffffc0204466:	19600593          	li	a1,406
ffffffffc020446a:	00002517          	auipc	a0,0x2
ffffffffc020446e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206768 <default_pmm_manager+0xfb8>
ffffffffc0204472:	fd5fb0ef          	jal	ra,ffffffffc0200446 <__panic>

ffffffffc0204476 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0204476:	1141                	addi	sp,sp,-16
ffffffffc0204478:	e022                	sd	s0,0(sp)
ffffffffc020447a:	e406                	sd	ra,8(sp)
ffffffffc020447c:	00011417          	auipc	s0,0x11
ffffffffc0204480:	12c40413          	addi	s0,s0,300 # ffffffffc02155a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204484:	6018                	ld	a4,0(s0)
ffffffffc0204486:	4f1c                	lw	a5,24(a4)
ffffffffc0204488:	2781                	sext.w	a5,a5
ffffffffc020448a:	dff5                	beqz	a5,ffffffffc0204486 <cpu_idle+0x10>
            schedule();
ffffffffc020448c:	070000ef          	jal	ra,ffffffffc02044fc <schedule>
ffffffffc0204490:	bfd5                	j	ffffffffc0204484 <cpu_idle+0xe>

ffffffffc0204492 <switch_to>:
ffffffffc0204492:	00153023          	sd	ra,0(a0)
ffffffffc0204496:	00253423          	sd	sp,8(a0)
ffffffffc020449a:	e900                	sd	s0,16(a0)
ffffffffc020449c:	ed04                	sd	s1,24(a0)
ffffffffc020449e:	03253023          	sd	s2,32(a0)
ffffffffc02044a2:	03353423          	sd	s3,40(a0)
ffffffffc02044a6:	03453823          	sd	s4,48(a0)
ffffffffc02044aa:	03553c23          	sd	s5,56(a0)
ffffffffc02044ae:	05653023          	sd	s6,64(a0)
ffffffffc02044b2:	05753423          	sd	s7,72(a0)
ffffffffc02044b6:	05853823          	sd	s8,80(a0)
ffffffffc02044ba:	05953c23          	sd	s9,88(a0)
ffffffffc02044be:	07a53023          	sd	s10,96(a0)
ffffffffc02044c2:	07b53423          	sd	s11,104(a0)
ffffffffc02044c6:	0005b083          	ld	ra,0(a1)
ffffffffc02044ca:	0085b103          	ld	sp,8(a1)
ffffffffc02044ce:	6980                	ld	s0,16(a1)
ffffffffc02044d0:	6d84                	ld	s1,24(a1)
ffffffffc02044d2:	0205b903          	ld	s2,32(a1)
ffffffffc02044d6:	0285b983          	ld	s3,40(a1)
ffffffffc02044da:	0305ba03          	ld	s4,48(a1)
ffffffffc02044de:	0385ba83          	ld	s5,56(a1)
ffffffffc02044e2:	0405bb03          	ld	s6,64(a1)
ffffffffc02044e6:	0485bb83          	ld	s7,72(a1)
ffffffffc02044ea:	0505bc03          	ld	s8,80(a1)
ffffffffc02044ee:	0585bc83          	ld	s9,88(a1)
ffffffffc02044f2:	0605bd03          	ld	s10,96(a1)
ffffffffc02044f6:	0685bd83          	ld	s11,104(a1)
ffffffffc02044fa:	8082                	ret

ffffffffc02044fc <schedule>:
ffffffffc02044fc:	1141                	addi	sp,sp,-16
ffffffffc02044fe:	e406                	sd	ra,8(sp)
ffffffffc0204500:	e022                	sd	s0,0(sp)
ffffffffc0204502:	100027f3          	csrr	a5,sstatus
ffffffffc0204506:	8b89                	andi	a5,a5,2
ffffffffc0204508:	4401                	li	s0,0
ffffffffc020450a:	efbd                	bnez	a5,ffffffffc0204588 <schedule+0x8c>
ffffffffc020450c:	00011897          	auipc	a7,0x11
ffffffffc0204510:	09c8b883          	ld	a7,156(a7) # ffffffffc02155a8 <current>
ffffffffc0204514:	0008ac23          	sw	zero,24(a7)
ffffffffc0204518:	00011517          	auipc	a0,0x11
ffffffffc020451c:	09853503          	ld	a0,152(a0) # ffffffffc02155b0 <idleproc>
ffffffffc0204520:	04a88e63          	beq	a7,a0,ffffffffc020457c <schedule+0x80>
ffffffffc0204524:	0c888693          	addi	a3,a7,200
ffffffffc0204528:	00011617          	auipc	a2,0x11
ffffffffc020452c:	ff860613          	addi	a2,a2,-8 # ffffffffc0215520 <proc_list>
ffffffffc0204530:	87b6                	mv	a5,a3
ffffffffc0204532:	4581                	li	a1,0
ffffffffc0204534:	4809                	li	a6,2
ffffffffc0204536:	679c                	ld	a5,8(a5)
ffffffffc0204538:	00c78863          	beq	a5,a2,ffffffffc0204548 <schedule+0x4c>
ffffffffc020453c:	f387a703          	lw	a4,-200(a5)
ffffffffc0204540:	f3878593          	addi	a1,a5,-200
ffffffffc0204544:	03070163          	beq	a4,a6,ffffffffc0204566 <schedule+0x6a>
ffffffffc0204548:	fef697e3          	bne	a3,a5,ffffffffc0204536 <schedule+0x3a>
ffffffffc020454c:	ed89                	bnez	a1,ffffffffc0204566 <schedule+0x6a>
ffffffffc020454e:	451c                	lw	a5,8(a0)
ffffffffc0204550:	2785                	addiw	a5,a5,1
ffffffffc0204552:	c51c                	sw	a5,8(a0)
ffffffffc0204554:	00a88463          	beq	a7,a0,ffffffffc020455c <schedule+0x60>
ffffffffc0204558:	bddff0ef          	jal	ra,ffffffffc0204134 <proc_run>
ffffffffc020455c:	e819                	bnez	s0,ffffffffc0204572 <schedule+0x76>
ffffffffc020455e:	60a2                	ld	ra,8(sp)
ffffffffc0204560:	6402                	ld	s0,0(sp)
ffffffffc0204562:	0141                	addi	sp,sp,16
ffffffffc0204564:	8082                	ret
ffffffffc0204566:	4198                	lw	a4,0(a1)
ffffffffc0204568:	4789                	li	a5,2
ffffffffc020456a:	fef712e3          	bne	a4,a5,ffffffffc020454e <schedule+0x52>
ffffffffc020456e:	852e                	mv	a0,a1
ffffffffc0204570:	bff9                	j	ffffffffc020454e <schedule+0x52>
ffffffffc0204572:	6402                	ld	s0,0(sp)
ffffffffc0204574:	60a2                	ld	ra,8(sp)
ffffffffc0204576:	0141                	addi	sp,sp,16
ffffffffc0204578:	820fc06f          	j	ffffffffc0200598 <intr_enable>
ffffffffc020457c:	00011617          	auipc	a2,0x11
ffffffffc0204580:	fa460613          	addi	a2,a2,-92 # ffffffffc0215520 <proc_list>
ffffffffc0204584:	86b2                	mv	a3,a2
ffffffffc0204586:	b76d                	j	ffffffffc0204530 <schedule+0x34>
ffffffffc0204588:	816fc0ef          	jal	ra,ffffffffc020059e <intr_disable>
ffffffffc020458c:	4405                	li	s0,1
ffffffffc020458e:	bfbd                	j	ffffffffc020450c <schedule+0x10>

ffffffffc0204590 <hash32>:
ffffffffc0204590:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204594:	2785                	addiw	a5,a5,1
ffffffffc0204596:	02a7853b          	mulw	a0,a5,a0
ffffffffc020459a:	02000793          	li	a5,32
ffffffffc020459e:	9f8d                	subw	a5,a5,a1
ffffffffc02045a0:	00f5553b          	srlw	a0,a0,a5
ffffffffc02045a4:	8082                	ret

ffffffffc02045a6 <printnum>:
ffffffffc02045a6:	02069813          	slli	a6,a3,0x20
ffffffffc02045aa:	7179                	addi	sp,sp,-48
ffffffffc02045ac:	02085813          	srli	a6,a6,0x20
ffffffffc02045b0:	e052                	sd	s4,0(sp)
ffffffffc02045b2:	03067a33          	remu	s4,a2,a6
ffffffffc02045b6:	f022                	sd	s0,32(sp)
ffffffffc02045b8:	ec26                	sd	s1,24(sp)
ffffffffc02045ba:	e84a                	sd	s2,16(sp)
ffffffffc02045bc:	f406                	sd	ra,40(sp)
ffffffffc02045be:	e44e                	sd	s3,8(sp)
ffffffffc02045c0:	84aa                	mv	s1,a0
ffffffffc02045c2:	892e                	mv	s2,a1
ffffffffc02045c4:	fff7041b          	addiw	s0,a4,-1
ffffffffc02045c8:	2a01                	sext.w	s4,s4
ffffffffc02045ca:	03067e63          	bgeu	a2,a6,ffffffffc0204606 <printnum+0x60>
ffffffffc02045ce:	89be                	mv	s3,a5
ffffffffc02045d0:	00805763          	blez	s0,ffffffffc02045de <printnum+0x38>
ffffffffc02045d4:	347d                	addiw	s0,s0,-1
ffffffffc02045d6:	85ca                	mv	a1,s2
ffffffffc02045d8:	854e                	mv	a0,s3
ffffffffc02045da:	9482                	jalr	s1
ffffffffc02045dc:	fc65                	bnez	s0,ffffffffc02045d4 <printnum+0x2e>
ffffffffc02045de:	1a02                	slli	s4,s4,0x20
ffffffffc02045e0:	00002797          	auipc	a5,0x2
ffffffffc02045e4:	26078793          	addi	a5,a5,608 # ffffffffc0206840 <default_pmm_manager+0x1090>
ffffffffc02045e8:	020a5a13          	srli	s4,s4,0x20
ffffffffc02045ec:	9a3e                	add	s4,s4,a5
ffffffffc02045ee:	7402                	ld	s0,32(sp)
ffffffffc02045f0:	000a4503          	lbu	a0,0(s4)
ffffffffc02045f4:	70a2                	ld	ra,40(sp)
ffffffffc02045f6:	69a2                	ld	s3,8(sp)
ffffffffc02045f8:	6a02                	ld	s4,0(sp)
ffffffffc02045fa:	85ca                	mv	a1,s2
ffffffffc02045fc:	87a6                	mv	a5,s1
ffffffffc02045fe:	6942                	ld	s2,16(sp)
ffffffffc0204600:	64e2                	ld	s1,24(sp)
ffffffffc0204602:	6145                	addi	sp,sp,48
ffffffffc0204604:	8782                	jr	a5
ffffffffc0204606:	03065633          	divu	a2,a2,a6
ffffffffc020460a:	8722                	mv	a4,s0
ffffffffc020460c:	f9bff0ef          	jal	ra,ffffffffc02045a6 <printnum>
ffffffffc0204610:	b7f9                	j	ffffffffc02045de <printnum+0x38>

ffffffffc0204612 <vprintfmt>:
ffffffffc0204612:	7119                	addi	sp,sp,-128
ffffffffc0204614:	f4a6                	sd	s1,104(sp)
ffffffffc0204616:	f0ca                	sd	s2,96(sp)
ffffffffc0204618:	ecce                	sd	s3,88(sp)
ffffffffc020461a:	e8d2                	sd	s4,80(sp)
ffffffffc020461c:	e4d6                	sd	s5,72(sp)
ffffffffc020461e:	e0da                	sd	s6,64(sp)
ffffffffc0204620:	fc5e                	sd	s7,56(sp)
ffffffffc0204622:	f06a                	sd	s10,32(sp)
ffffffffc0204624:	fc86                	sd	ra,120(sp)
ffffffffc0204626:	f8a2                	sd	s0,112(sp)
ffffffffc0204628:	f862                	sd	s8,48(sp)
ffffffffc020462a:	f466                	sd	s9,40(sp)
ffffffffc020462c:	ec6e                	sd	s11,24(sp)
ffffffffc020462e:	892a                	mv	s2,a0
ffffffffc0204630:	84ae                	mv	s1,a1
ffffffffc0204632:	8d32                	mv	s10,a2
ffffffffc0204634:	8a36                	mv	s4,a3
ffffffffc0204636:	02500993          	li	s3,37
ffffffffc020463a:	5b7d                	li	s6,-1
ffffffffc020463c:	00002a97          	auipc	s5,0x2
ffffffffc0204640:	230a8a93          	addi	s5,s5,560 # ffffffffc020686c <default_pmm_manager+0x10bc>
ffffffffc0204644:	00002b97          	auipc	s7,0x2
ffffffffc0204648:	404b8b93          	addi	s7,s7,1028 # ffffffffc0206a48 <error_string>
ffffffffc020464c:	000d4503          	lbu	a0,0(s10)
ffffffffc0204650:	001d0413          	addi	s0,s10,1
ffffffffc0204654:	01350a63          	beq	a0,s3,ffffffffc0204668 <vprintfmt+0x56>
ffffffffc0204658:	c121                	beqz	a0,ffffffffc0204698 <vprintfmt+0x86>
ffffffffc020465a:	85a6                	mv	a1,s1
ffffffffc020465c:	0405                	addi	s0,s0,1
ffffffffc020465e:	9902                	jalr	s2
ffffffffc0204660:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204664:	ff351ae3          	bne	a0,s3,ffffffffc0204658 <vprintfmt+0x46>
ffffffffc0204668:	00044603          	lbu	a2,0(s0)
ffffffffc020466c:	02000793          	li	a5,32
ffffffffc0204670:	4c81                	li	s9,0
ffffffffc0204672:	4881                	li	a7,0
ffffffffc0204674:	5c7d                	li	s8,-1
ffffffffc0204676:	5dfd                	li	s11,-1
ffffffffc0204678:	05500513          	li	a0,85
ffffffffc020467c:	4825                	li	a6,9
ffffffffc020467e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204682:	0ff5f593          	zext.b	a1,a1
ffffffffc0204686:	00140d13          	addi	s10,s0,1
ffffffffc020468a:	04b56263          	bltu	a0,a1,ffffffffc02046ce <vprintfmt+0xbc>
ffffffffc020468e:	058a                	slli	a1,a1,0x2
ffffffffc0204690:	95d6                	add	a1,a1,s5
ffffffffc0204692:	4194                	lw	a3,0(a1)
ffffffffc0204694:	96d6                	add	a3,a3,s5
ffffffffc0204696:	8682                	jr	a3
ffffffffc0204698:	70e6                	ld	ra,120(sp)
ffffffffc020469a:	7446                	ld	s0,112(sp)
ffffffffc020469c:	74a6                	ld	s1,104(sp)
ffffffffc020469e:	7906                	ld	s2,96(sp)
ffffffffc02046a0:	69e6                	ld	s3,88(sp)
ffffffffc02046a2:	6a46                	ld	s4,80(sp)
ffffffffc02046a4:	6aa6                	ld	s5,72(sp)
ffffffffc02046a6:	6b06                	ld	s6,64(sp)
ffffffffc02046a8:	7be2                	ld	s7,56(sp)
ffffffffc02046aa:	7c42                	ld	s8,48(sp)
ffffffffc02046ac:	7ca2                	ld	s9,40(sp)
ffffffffc02046ae:	7d02                	ld	s10,32(sp)
ffffffffc02046b0:	6de2                	ld	s11,24(sp)
ffffffffc02046b2:	6109                	addi	sp,sp,128
ffffffffc02046b4:	8082                	ret
ffffffffc02046b6:	87b2                	mv	a5,a2
ffffffffc02046b8:	00144603          	lbu	a2,1(s0)
ffffffffc02046bc:	846a                	mv	s0,s10
ffffffffc02046be:	00140d13          	addi	s10,s0,1
ffffffffc02046c2:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02046c6:	0ff5f593          	zext.b	a1,a1
ffffffffc02046ca:	fcb572e3          	bgeu	a0,a1,ffffffffc020468e <vprintfmt+0x7c>
ffffffffc02046ce:	85a6                	mv	a1,s1
ffffffffc02046d0:	02500513          	li	a0,37
ffffffffc02046d4:	9902                	jalr	s2
ffffffffc02046d6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02046da:	8d22                	mv	s10,s0
ffffffffc02046dc:	f73788e3          	beq	a5,s3,ffffffffc020464c <vprintfmt+0x3a>
ffffffffc02046e0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02046e4:	1d7d                	addi	s10,s10,-1
ffffffffc02046e6:	ff379de3          	bne	a5,s3,ffffffffc02046e0 <vprintfmt+0xce>
ffffffffc02046ea:	b78d                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc02046ec:	fd060c1b          	addiw	s8,a2,-48
ffffffffc02046f0:	00144603          	lbu	a2,1(s0)
ffffffffc02046f4:	846a                	mv	s0,s10
ffffffffc02046f6:	fd06069b          	addiw	a3,a2,-48
ffffffffc02046fa:	0006059b          	sext.w	a1,a2
ffffffffc02046fe:	02d86463          	bltu	a6,a3,ffffffffc0204726 <vprintfmt+0x114>
ffffffffc0204702:	00144603          	lbu	a2,1(s0)
ffffffffc0204706:	002c169b          	slliw	a3,s8,0x2
ffffffffc020470a:	0186873b          	addw	a4,a3,s8
ffffffffc020470e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204712:	9f2d                	addw	a4,a4,a1
ffffffffc0204714:	fd06069b          	addiw	a3,a2,-48
ffffffffc0204718:	0405                	addi	s0,s0,1
ffffffffc020471a:	fd070c1b          	addiw	s8,a4,-48
ffffffffc020471e:	0006059b          	sext.w	a1,a2
ffffffffc0204722:	fed870e3          	bgeu	a6,a3,ffffffffc0204702 <vprintfmt+0xf0>
ffffffffc0204726:	f40ddce3          	bgez	s11,ffffffffc020467e <vprintfmt+0x6c>
ffffffffc020472a:	8de2                	mv	s11,s8
ffffffffc020472c:	5c7d                	li	s8,-1
ffffffffc020472e:	bf81                	j	ffffffffc020467e <vprintfmt+0x6c>
ffffffffc0204730:	fffdc693          	not	a3,s11
ffffffffc0204734:	96fd                	srai	a3,a3,0x3f
ffffffffc0204736:	00ddfdb3          	and	s11,s11,a3
ffffffffc020473a:	00144603          	lbu	a2,1(s0)
ffffffffc020473e:	2d81                	sext.w	s11,s11
ffffffffc0204740:	846a                	mv	s0,s10
ffffffffc0204742:	bf35                	j	ffffffffc020467e <vprintfmt+0x6c>
ffffffffc0204744:	000a2c03          	lw	s8,0(s4)
ffffffffc0204748:	00144603          	lbu	a2,1(s0)
ffffffffc020474c:	0a21                	addi	s4,s4,8
ffffffffc020474e:	846a                	mv	s0,s10
ffffffffc0204750:	bfd9                	j	ffffffffc0204726 <vprintfmt+0x114>
ffffffffc0204752:	4705                	li	a4,1
ffffffffc0204754:	008a0593          	addi	a1,s4,8
ffffffffc0204758:	01174463          	blt	a4,a7,ffffffffc0204760 <vprintfmt+0x14e>
ffffffffc020475c:	1a088e63          	beqz	a7,ffffffffc0204918 <vprintfmt+0x306>
ffffffffc0204760:	000a3603          	ld	a2,0(s4)
ffffffffc0204764:	46c1                	li	a3,16
ffffffffc0204766:	8a2e                	mv	s4,a1
ffffffffc0204768:	2781                	sext.w	a5,a5
ffffffffc020476a:	876e                	mv	a4,s11
ffffffffc020476c:	85a6                	mv	a1,s1
ffffffffc020476e:	854a                	mv	a0,s2
ffffffffc0204770:	e37ff0ef          	jal	ra,ffffffffc02045a6 <printnum>
ffffffffc0204774:	bde1                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc0204776:	000a2503          	lw	a0,0(s4)
ffffffffc020477a:	85a6                	mv	a1,s1
ffffffffc020477c:	0a21                	addi	s4,s4,8
ffffffffc020477e:	9902                	jalr	s2
ffffffffc0204780:	b5f1                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc0204782:	4705                	li	a4,1
ffffffffc0204784:	008a0593          	addi	a1,s4,8
ffffffffc0204788:	01174463          	blt	a4,a7,ffffffffc0204790 <vprintfmt+0x17e>
ffffffffc020478c:	18088163          	beqz	a7,ffffffffc020490e <vprintfmt+0x2fc>
ffffffffc0204790:	000a3603          	ld	a2,0(s4)
ffffffffc0204794:	46a9                	li	a3,10
ffffffffc0204796:	8a2e                	mv	s4,a1
ffffffffc0204798:	bfc1                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc020479a:	00144603          	lbu	a2,1(s0)
ffffffffc020479e:	4c85                	li	s9,1
ffffffffc02047a0:	846a                	mv	s0,s10
ffffffffc02047a2:	bdf1                	j	ffffffffc020467e <vprintfmt+0x6c>
ffffffffc02047a4:	85a6                	mv	a1,s1
ffffffffc02047a6:	02500513          	li	a0,37
ffffffffc02047aa:	9902                	jalr	s2
ffffffffc02047ac:	b545                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc02047ae:	00144603          	lbu	a2,1(s0)
ffffffffc02047b2:	2885                	addiw	a7,a7,1
ffffffffc02047b4:	846a                	mv	s0,s10
ffffffffc02047b6:	b5e1                	j	ffffffffc020467e <vprintfmt+0x6c>
ffffffffc02047b8:	4705                	li	a4,1
ffffffffc02047ba:	008a0593          	addi	a1,s4,8
ffffffffc02047be:	01174463          	blt	a4,a7,ffffffffc02047c6 <vprintfmt+0x1b4>
ffffffffc02047c2:	14088163          	beqz	a7,ffffffffc0204904 <vprintfmt+0x2f2>
ffffffffc02047c6:	000a3603          	ld	a2,0(s4)
ffffffffc02047ca:	46a1                	li	a3,8
ffffffffc02047cc:	8a2e                	mv	s4,a1
ffffffffc02047ce:	bf69                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc02047d0:	03000513          	li	a0,48
ffffffffc02047d4:	85a6                	mv	a1,s1
ffffffffc02047d6:	e03e                	sd	a5,0(sp)
ffffffffc02047d8:	9902                	jalr	s2
ffffffffc02047da:	85a6                	mv	a1,s1
ffffffffc02047dc:	07800513          	li	a0,120
ffffffffc02047e0:	9902                	jalr	s2
ffffffffc02047e2:	0a21                	addi	s4,s4,8
ffffffffc02047e4:	6782                	ld	a5,0(sp)
ffffffffc02047e6:	46c1                	li	a3,16
ffffffffc02047e8:	ff8a3603          	ld	a2,-8(s4)
ffffffffc02047ec:	bfb5                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc02047ee:	000a3403          	ld	s0,0(s4)
ffffffffc02047f2:	008a0713          	addi	a4,s4,8
ffffffffc02047f6:	e03a                	sd	a4,0(sp)
ffffffffc02047f8:	14040263          	beqz	s0,ffffffffc020493c <vprintfmt+0x32a>
ffffffffc02047fc:	0fb05763          	blez	s11,ffffffffc02048ea <vprintfmt+0x2d8>
ffffffffc0204800:	02d00693          	li	a3,45
ffffffffc0204804:	0cd79163          	bne	a5,a3,ffffffffc02048c6 <vprintfmt+0x2b4>
ffffffffc0204808:	00044783          	lbu	a5,0(s0)
ffffffffc020480c:	0007851b          	sext.w	a0,a5
ffffffffc0204810:	cf85                	beqz	a5,ffffffffc0204848 <vprintfmt+0x236>
ffffffffc0204812:	00140a13          	addi	s4,s0,1
ffffffffc0204816:	05e00413          	li	s0,94
ffffffffc020481a:	000c4563          	bltz	s8,ffffffffc0204824 <vprintfmt+0x212>
ffffffffc020481e:	3c7d                	addiw	s8,s8,-1
ffffffffc0204820:	036c0263          	beq	s8,s6,ffffffffc0204844 <vprintfmt+0x232>
ffffffffc0204824:	85a6                	mv	a1,s1
ffffffffc0204826:	0e0c8e63          	beqz	s9,ffffffffc0204922 <vprintfmt+0x310>
ffffffffc020482a:	3781                	addiw	a5,a5,-32
ffffffffc020482c:	0ef47b63          	bgeu	s0,a5,ffffffffc0204922 <vprintfmt+0x310>
ffffffffc0204830:	03f00513          	li	a0,63
ffffffffc0204834:	9902                	jalr	s2
ffffffffc0204836:	000a4783          	lbu	a5,0(s4)
ffffffffc020483a:	3dfd                	addiw	s11,s11,-1
ffffffffc020483c:	0a05                	addi	s4,s4,1
ffffffffc020483e:	0007851b          	sext.w	a0,a5
ffffffffc0204842:	ffe1                	bnez	a5,ffffffffc020481a <vprintfmt+0x208>
ffffffffc0204844:	01b05963          	blez	s11,ffffffffc0204856 <vprintfmt+0x244>
ffffffffc0204848:	3dfd                	addiw	s11,s11,-1
ffffffffc020484a:	85a6                	mv	a1,s1
ffffffffc020484c:	02000513          	li	a0,32
ffffffffc0204850:	9902                	jalr	s2
ffffffffc0204852:	fe0d9be3          	bnez	s11,ffffffffc0204848 <vprintfmt+0x236>
ffffffffc0204856:	6a02                	ld	s4,0(sp)
ffffffffc0204858:	bbd5                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc020485a:	4705                	li	a4,1
ffffffffc020485c:	008a0c93          	addi	s9,s4,8
ffffffffc0204860:	01174463          	blt	a4,a7,ffffffffc0204868 <vprintfmt+0x256>
ffffffffc0204864:	08088d63          	beqz	a7,ffffffffc02048fe <vprintfmt+0x2ec>
ffffffffc0204868:	000a3403          	ld	s0,0(s4)
ffffffffc020486c:	0a044d63          	bltz	s0,ffffffffc0204926 <vprintfmt+0x314>
ffffffffc0204870:	8622                	mv	a2,s0
ffffffffc0204872:	8a66                	mv	s4,s9
ffffffffc0204874:	46a9                	li	a3,10
ffffffffc0204876:	bdcd                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc0204878:	000a2783          	lw	a5,0(s4)
ffffffffc020487c:	4719                	li	a4,6
ffffffffc020487e:	0a21                	addi	s4,s4,8
ffffffffc0204880:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204884:	8fb5                	xor	a5,a5,a3
ffffffffc0204886:	40d786bb          	subw	a3,a5,a3
ffffffffc020488a:	02d74163          	blt	a4,a3,ffffffffc02048ac <vprintfmt+0x29a>
ffffffffc020488e:	00369793          	slli	a5,a3,0x3
ffffffffc0204892:	97de                	add	a5,a5,s7
ffffffffc0204894:	639c                	ld	a5,0(a5)
ffffffffc0204896:	cb99                	beqz	a5,ffffffffc02048ac <vprintfmt+0x29a>
ffffffffc0204898:	86be                	mv	a3,a5
ffffffffc020489a:	00000617          	auipc	a2,0x0
ffffffffc020489e:	1ee60613          	addi	a2,a2,494 # ffffffffc0204a88 <etext+0x2a>
ffffffffc02048a2:	85a6                	mv	a1,s1
ffffffffc02048a4:	854a                	mv	a0,s2
ffffffffc02048a6:	0ce000ef          	jal	ra,ffffffffc0204974 <printfmt>
ffffffffc02048aa:	b34d                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc02048ac:	00002617          	auipc	a2,0x2
ffffffffc02048b0:	fb460613          	addi	a2,a2,-76 # ffffffffc0206860 <default_pmm_manager+0x10b0>
ffffffffc02048b4:	85a6                	mv	a1,s1
ffffffffc02048b6:	854a                	mv	a0,s2
ffffffffc02048b8:	0bc000ef          	jal	ra,ffffffffc0204974 <printfmt>
ffffffffc02048bc:	bb41                	j	ffffffffc020464c <vprintfmt+0x3a>
ffffffffc02048be:	00002417          	auipc	s0,0x2
ffffffffc02048c2:	f9a40413          	addi	s0,s0,-102 # ffffffffc0206858 <default_pmm_manager+0x10a8>
ffffffffc02048c6:	85e2                	mv	a1,s8
ffffffffc02048c8:	8522                	mv	a0,s0
ffffffffc02048ca:	e43e                	sd	a5,8(sp)
ffffffffc02048cc:	0e2000ef          	jal	ra,ffffffffc02049ae <strnlen>
ffffffffc02048d0:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02048d4:	01b05b63          	blez	s11,ffffffffc02048ea <vprintfmt+0x2d8>
ffffffffc02048d8:	67a2                	ld	a5,8(sp)
ffffffffc02048da:	00078a1b          	sext.w	s4,a5
ffffffffc02048de:	3dfd                	addiw	s11,s11,-1
ffffffffc02048e0:	85a6                	mv	a1,s1
ffffffffc02048e2:	8552                	mv	a0,s4
ffffffffc02048e4:	9902                	jalr	s2
ffffffffc02048e6:	fe0d9ce3          	bnez	s11,ffffffffc02048de <vprintfmt+0x2cc>
ffffffffc02048ea:	00044783          	lbu	a5,0(s0)
ffffffffc02048ee:	00140a13          	addi	s4,s0,1
ffffffffc02048f2:	0007851b          	sext.w	a0,a5
ffffffffc02048f6:	d3a5                	beqz	a5,ffffffffc0204856 <vprintfmt+0x244>
ffffffffc02048f8:	05e00413          	li	s0,94
ffffffffc02048fc:	bf39                	j	ffffffffc020481a <vprintfmt+0x208>
ffffffffc02048fe:	000a2403          	lw	s0,0(s4)
ffffffffc0204902:	b7ad                	j	ffffffffc020486c <vprintfmt+0x25a>
ffffffffc0204904:	000a6603          	lwu	a2,0(s4)
ffffffffc0204908:	46a1                	li	a3,8
ffffffffc020490a:	8a2e                	mv	s4,a1
ffffffffc020490c:	bdb1                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc020490e:	000a6603          	lwu	a2,0(s4)
ffffffffc0204912:	46a9                	li	a3,10
ffffffffc0204914:	8a2e                	mv	s4,a1
ffffffffc0204916:	bd89                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc0204918:	000a6603          	lwu	a2,0(s4)
ffffffffc020491c:	46c1                	li	a3,16
ffffffffc020491e:	8a2e                	mv	s4,a1
ffffffffc0204920:	b5a1                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc0204922:	9902                	jalr	s2
ffffffffc0204924:	bf09                	j	ffffffffc0204836 <vprintfmt+0x224>
ffffffffc0204926:	85a6                	mv	a1,s1
ffffffffc0204928:	02d00513          	li	a0,45
ffffffffc020492c:	e03e                	sd	a5,0(sp)
ffffffffc020492e:	9902                	jalr	s2
ffffffffc0204930:	6782                	ld	a5,0(sp)
ffffffffc0204932:	8a66                	mv	s4,s9
ffffffffc0204934:	40800633          	neg	a2,s0
ffffffffc0204938:	46a9                	li	a3,10
ffffffffc020493a:	b53d                	j	ffffffffc0204768 <vprintfmt+0x156>
ffffffffc020493c:	03b05163          	blez	s11,ffffffffc020495e <vprintfmt+0x34c>
ffffffffc0204940:	02d00693          	li	a3,45
ffffffffc0204944:	f6d79de3          	bne	a5,a3,ffffffffc02048be <vprintfmt+0x2ac>
ffffffffc0204948:	00002417          	auipc	s0,0x2
ffffffffc020494c:	f1040413          	addi	s0,s0,-240 # ffffffffc0206858 <default_pmm_manager+0x10a8>
ffffffffc0204950:	02800793          	li	a5,40
ffffffffc0204954:	02800513          	li	a0,40
ffffffffc0204958:	00140a13          	addi	s4,s0,1
ffffffffc020495c:	bd6d                	j	ffffffffc0204816 <vprintfmt+0x204>
ffffffffc020495e:	00002a17          	auipc	s4,0x2
ffffffffc0204962:	efba0a13          	addi	s4,s4,-261 # ffffffffc0206859 <default_pmm_manager+0x10a9>
ffffffffc0204966:	02800513          	li	a0,40
ffffffffc020496a:	02800793          	li	a5,40
ffffffffc020496e:	05e00413          	li	s0,94
ffffffffc0204972:	b565                	j	ffffffffc020481a <vprintfmt+0x208>

ffffffffc0204974 <printfmt>:
ffffffffc0204974:	715d                	addi	sp,sp,-80
ffffffffc0204976:	02810313          	addi	t1,sp,40
ffffffffc020497a:	f436                	sd	a3,40(sp)
ffffffffc020497c:	869a                	mv	a3,t1
ffffffffc020497e:	ec06                	sd	ra,24(sp)
ffffffffc0204980:	f83a                	sd	a4,48(sp)
ffffffffc0204982:	fc3e                	sd	a5,56(sp)
ffffffffc0204984:	e0c2                	sd	a6,64(sp)
ffffffffc0204986:	e4c6                	sd	a7,72(sp)
ffffffffc0204988:	e41a                	sd	t1,8(sp)
ffffffffc020498a:	c89ff0ef          	jal	ra,ffffffffc0204612 <vprintfmt>
ffffffffc020498e:	60e2                	ld	ra,24(sp)
ffffffffc0204990:	6161                	addi	sp,sp,80
ffffffffc0204992:	8082                	ret

ffffffffc0204994 <strlen>:
ffffffffc0204994:	00054783          	lbu	a5,0(a0)
ffffffffc0204998:	872a                	mv	a4,a0
ffffffffc020499a:	4501                	li	a0,0
ffffffffc020499c:	cb81                	beqz	a5,ffffffffc02049ac <strlen+0x18>
ffffffffc020499e:	0505                	addi	a0,a0,1
ffffffffc02049a0:	00a707b3          	add	a5,a4,a0
ffffffffc02049a4:	0007c783          	lbu	a5,0(a5)
ffffffffc02049a8:	fbfd                	bnez	a5,ffffffffc020499e <strlen+0xa>
ffffffffc02049aa:	8082                	ret
ffffffffc02049ac:	8082                	ret

ffffffffc02049ae <strnlen>:
ffffffffc02049ae:	4781                	li	a5,0
ffffffffc02049b0:	e589                	bnez	a1,ffffffffc02049ba <strnlen+0xc>
ffffffffc02049b2:	a811                	j	ffffffffc02049c6 <strnlen+0x18>
ffffffffc02049b4:	0785                	addi	a5,a5,1
ffffffffc02049b6:	00f58863          	beq	a1,a5,ffffffffc02049c6 <strnlen+0x18>
ffffffffc02049ba:	00f50733          	add	a4,a0,a5
ffffffffc02049be:	00074703          	lbu	a4,0(a4)
ffffffffc02049c2:	fb6d                	bnez	a4,ffffffffc02049b4 <strnlen+0x6>
ffffffffc02049c4:	85be                	mv	a1,a5
ffffffffc02049c6:	852e                	mv	a0,a1
ffffffffc02049c8:	8082                	ret

ffffffffc02049ca <strcpy>:
ffffffffc02049ca:	87aa                	mv	a5,a0
ffffffffc02049cc:	0005c703          	lbu	a4,0(a1)
ffffffffc02049d0:	0785                	addi	a5,a5,1
ffffffffc02049d2:	0585                	addi	a1,a1,1
ffffffffc02049d4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02049d8:	fb75                	bnez	a4,ffffffffc02049cc <strcpy+0x2>
ffffffffc02049da:	8082                	ret

ffffffffc02049dc <strcmp>:
ffffffffc02049dc:	00054783          	lbu	a5,0(a0)
ffffffffc02049e0:	0005c703          	lbu	a4,0(a1)
ffffffffc02049e4:	cb89                	beqz	a5,ffffffffc02049f6 <strcmp+0x1a>
ffffffffc02049e6:	0505                	addi	a0,a0,1
ffffffffc02049e8:	0585                	addi	a1,a1,1
ffffffffc02049ea:	fee789e3          	beq	a5,a4,ffffffffc02049dc <strcmp>
ffffffffc02049ee:	0007851b          	sext.w	a0,a5
ffffffffc02049f2:	9d19                	subw	a0,a0,a4
ffffffffc02049f4:	8082                	ret
ffffffffc02049f6:	4501                	li	a0,0
ffffffffc02049f8:	bfed                	j	ffffffffc02049f2 <strcmp+0x16>

ffffffffc02049fa <strchr>:
ffffffffc02049fa:	00054783          	lbu	a5,0(a0)
ffffffffc02049fe:	c799                	beqz	a5,ffffffffc0204a0c <strchr+0x12>
ffffffffc0204a00:	00f58763          	beq	a1,a5,ffffffffc0204a0e <strchr+0x14>
ffffffffc0204a04:	00154783          	lbu	a5,1(a0)
ffffffffc0204a08:	0505                	addi	a0,a0,1
ffffffffc0204a0a:	fbfd                	bnez	a5,ffffffffc0204a00 <strchr+0x6>
ffffffffc0204a0c:	4501                	li	a0,0
ffffffffc0204a0e:	8082                	ret

ffffffffc0204a10 <memset>:
ffffffffc0204a10:	ca01                	beqz	a2,ffffffffc0204a20 <memset+0x10>
ffffffffc0204a12:	962a                	add	a2,a2,a0
ffffffffc0204a14:	87aa                	mv	a5,a0
ffffffffc0204a16:	0785                	addi	a5,a5,1
ffffffffc0204a18:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0204a1c:	fec79de3          	bne	a5,a2,ffffffffc0204a16 <memset+0x6>
ffffffffc0204a20:	8082                	ret

ffffffffc0204a22 <memcpy>:
ffffffffc0204a22:	ca19                	beqz	a2,ffffffffc0204a38 <memcpy+0x16>
ffffffffc0204a24:	962e                	add	a2,a2,a1
ffffffffc0204a26:	87aa                	mv	a5,a0
ffffffffc0204a28:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a2c:	0585                	addi	a1,a1,1
ffffffffc0204a2e:	0785                	addi	a5,a5,1
ffffffffc0204a30:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204a34:	fec59ae3          	bne	a1,a2,ffffffffc0204a28 <memcpy+0x6>
ffffffffc0204a38:	8082                	ret

ffffffffc0204a3a <memcmp>:
ffffffffc0204a3a:	c205                	beqz	a2,ffffffffc0204a5a <memcmp+0x20>
ffffffffc0204a3c:	962e                	add	a2,a2,a1
ffffffffc0204a3e:	a019                	j	ffffffffc0204a44 <memcmp+0xa>
ffffffffc0204a40:	00c58d63          	beq	a1,a2,ffffffffc0204a5a <memcmp+0x20>
ffffffffc0204a44:	00054783          	lbu	a5,0(a0)
ffffffffc0204a48:	0005c703          	lbu	a4,0(a1)
ffffffffc0204a4c:	0505                	addi	a0,a0,1
ffffffffc0204a4e:	0585                	addi	a1,a1,1
ffffffffc0204a50:	fee788e3          	beq	a5,a4,ffffffffc0204a40 <memcmp+0x6>
ffffffffc0204a54:	40e7853b          	subw	a0,a5,a4
ffffffffc0204a58:	8082                	ret
ffffffffc0204a5a:	4501                	li	a0,0
ffffffffc0204a5c:	8082                	ret
