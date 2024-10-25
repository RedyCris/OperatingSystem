
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	c02042b7          	lui	t0,0xc0204
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
ffffffffc020001c:	18029073          	csrw	satp,t0
ffffffffc0200020:	12000073          	sfence.vma
ffffffffc0200024:	c0204137          	lui	sp,0xc0204
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00005517          	auipc	a0,0x5
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0205010 <buddy_free_area>
ffffffffc020003a:	00005617          	auipc	a2,0x5
ffffffffc020003e:	52660613          	addi	a2,a2,1318 # ffffffffc0205560 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	25e010ef          	jal	ra,ffffffffc02012a8 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	26e50513          	addi	a0,a0,622 # ffffffffc02012c0 <etext+0x6>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	36d000ef          	jal	ra,ffffffffc0200bd2 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
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
ffffffffc02000a6:	52d000ef          	jal	ra,ffffffffc0200dd2 <vprintfmt>
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
ffffffffc02000b2:	711d                	addi	sp,sp,-96
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0204028 <boot_page_table_sv39+0x28>
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
ffffffffc02000dc:	4f7000ef          	jal	ra,ffffffffc0200dd2 <vprintfmt>
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
ffffffffc0200140:	1a450513          	addi	a0,a0,420 # ffffffffc02012e0 <etext+0x26>
ffffffffc0200144:	e406                	sd	ra,8(sp)
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	1ae50513          	addi	a0,a0,430 # ffffffffc0201300 <etext+0x46>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	15c58593          	addi	a1,a1,348 # ffffffffc02012ba <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	1ba50513          	addi	a0,a0,442 # ffffffffc0201320 <etext+0x66>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200172:	00005597          	auipc	a1,0x5
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0205010 <buddy_free_area>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	1c650513          	addi	a0,a0,454 # ffffffffc0201340 <etext+0x86>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200186:	00005597          	auipc	a1,0x5
ffffffffc020018a:	3da58593          	addi	a1,a1,986 # ffffffffc0205560 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	1d250513          	addi	a0,a0,466 # ffffffffc0201360 <etext+0xa6>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020019a:	00005597          	auipc	a1,0x5
ffffffffc020019e:	7c558593          	addi	a1,a1,1989 # ffffffffc020595f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	1c450513          	addi	a0,a0,452 # ffffffffc0201380 <etext+0xc6>
ffffffffc02001c4:	0141                	addi	sp,sp,16
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
ffffffffc02001c8:	1141                	addi	sp,sp,-16
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	1e660613          	addi	a2,a2,486 # ffffffffc02013b0 <etext+0xf6>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	1f250513          	addi	a0,a0,498 # ffffffffc02013c8 <etext+0x10e>
ffffffffc02001de:	e406                	sd	ra,8(sp)
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
ffffffffc02001e4:	1141                	addi	sp,sp,-16
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	1fa60613          	addi	a2,a2,506 # ffffffffc02013e0 <etext+0x126>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	21258593          	addi	a1,a1,530 # ffffffffc0201400 <etext+0x146>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	21250513          	addi	a0,a0,530 # ffffffffc0201408 <etext+0x14e>
ffffffffc02001fe:	e406                	sd	ra,8(sp)
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	21460613          	addi	a2,a2,532 # ffffffffc0201418 <etext+0x15e>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	23458593          	addi	a1,a1,564 # ffffffffc0201440 <etext+0x186>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	1f450513          	addi	a0,a0,500 # ffffffffc0201408 <etext+0x14e>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	23060613          	addi	a2,a2,560 # ffffffffc0201450 <etext+0x196>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	24858593          	addi	a1,a1,584 # ffffffffc0201470 <etext+0x1b6>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	1d850513          	addi	a0,a0,472 # ffffffffc0201408 <etext+0x14e>
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
ffffffffc020026e:	21650513          	addi	a0,a0,534 # ffffffffc0201480 <etext+0x1c6>
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
ffffffffc0200290:	21c50513          	addi	a0,a0,540 # ffffffffc02014a8 <etext+0x1ee>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	276c0c13          	addi	s8,s8,630 # ffffffffc0201518 <commands>
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	22690913          	addi	s2,s2,550 # ffffffffc02014d0 <etext+0x216>
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	22648493          	addi	s1,s1,550 # ffffffffc02014d8 <etext+0x21e>
ffffffffc02002ba:	49bd                	li	s3,15
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	224b0b13          	addi	s6,s6,548 # ffffffffc02014e0 <etext+0x226>
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	13ca0a13          	addi	s4,s4,316 # ffffffffc0201400 <etext+0x146>
ffffffffc02002cc:	4a8d                	li	s5,3
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	685000ef          	jal	ra,ffffffffc0201154 <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
ffffffffc02002dc:	4c81                	li	s9,0
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	232d0d13          	addi	s10,s10,562 # ffffffffc0201518 <commands>
ffffffffc02002ee:	8552                	mv	a0,s4
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
ffffffffc02002f4:	781000ef          	jal	ra,ffffffffc0201274 <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	76d000ef          	jal	ra,ffffffffc0201274 <strcmp>
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
ffffffffc0200346:	74d000ef          	jal	ra,ffffffffc0201292 <strchr>
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
ffffffffc0200384:	70f000ef          	jal	ra,ffffffffc0201292 <strchr>
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
ffffffffc02003a2:	16250513          	addi	a0,a0,354 # ffffffffc0201500 <etext+0x246>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
ffffffffc02003ac:	00005317          	auipc	t1,0x5
ffffffffc02003b0:	16c30313          	addi	t1,t1,364 # ffffffffc0205518 <is_panic>
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
ffffffffc02003de:	18650513          	addi	a0,a0,390 # ffffffffc0201560 <commands+0x48>
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	fb850513          	addi	a0,a0,-72 # ffffffffc02013a8 <etext+0xee>
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
ffffffffc0200420:	603000ef          	jal	ra,ffffffffc0201222 <sbi_set_timer>
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	00005797          	auipc	a5,0x5
ffffffffc020042a:	0e07bd23          	sd	zero,250(a5) # ffffffffc0205520 <ticks>
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	15250513          	addi	a0,a0,338 # ffffffffc0201580 <commands+0x68>
ffffffffc0200436:	0141                	addi	sp,sp,16
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
ffffffffc020043a:	c0102573          	rdtime	a0
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5dd0006f          	j	ffffffffc0201222 <sbi_set_timer>

ffffffffc020044a <cons_init>:
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	5b90006f          	j	ffffffffc0201208 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
ffffffffc0200454:	5e90006f          	j	ffffffffc020123c <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
ffffffffc0200464:	14005073          	csrwi	sscratch,0
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
ffffffffc0200476:	610c                	ld	a1,0(a0)
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	12250513          	addi	a0,a0,290 # ffffffffc02015a0 <commands+0x88>
ffffffffc0200486:	e406                	sd	ra,8(sp)
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	12a50513          	addi	a0,a0,298 # ffffffffc02015b8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	13450513          	addi	a0,a0,308 # ffffffffc02015d0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	13e50513          	addi	a0,a0,318 # ffffffffc02015e8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	14850513          	addi	a0,a0,328 # ffffffffc0201600 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	15250513          	addi	a0,a0,338 # ffffffffc0201618 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	15c50513          	addi	a0,a0,348 # ffffffffc0201630 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	16650513          	addi	a0,a0,358 # ffffffffc0201648 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	17050513          	addi	a0,a0,368 # ffffffffc0201660 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	17a50513          	addi	a0,a0,378 # ffffffffc0201678 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	18450513          	addi	a0,a0,388 # ffffffffc0201690 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	18e50513          	addi	a0,a0,398 # ffffffffc02016a8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	19850513          	addi	a0,a0,408 # ffffffffc02016c0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	1a250513          	addi	a0,a0,418 # ffffffffc02016d8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	1ac50513          	addi	a0,a0,428 # ffffffffc02016f0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	1b650513          	addi	a0,a0,438 # ffffffffc0201708 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	1c050513          	addi	a0,a0,448 # ffffffffc0201720 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	1ca50513          	addi	a0,a0,458 # ffffffffc0201738 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	1d450513          	addi	a0,a0,468 # ffffffffc0201750 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	1de50513          	addi	a0,a0,478 # ffffffffc0201768 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	1e850513          	addi	a0,a0,488 # ffffffffc0201780 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	1f250513          	addi	a0,a0,498 # ffffffffc0201798 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	1fc50513          	addi	a0,a0,508 # ffffffffc02017b0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	20650513          	addi	a0,a0,518 # ffffffffc02017c8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	21050513          	addi	a0,a0,528 # ffffffffc02017e0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	21a50513          	addi	a0,a0,538 # ffffffffc02017f8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	22450513          	addi	a0,a0,548 # ffffffffc0201810 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	22e50513          	addi	a0,a0,558 # ffffffffc0201828 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	23850513          	addi	a0,a0,568 # ffffffffc0201840 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	24250513          	addi	a0,a0,578 # ffffffffc0201858 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	24c50513          	addi	a0,a0,588 # ffffffffc0201870 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	25250513          	addi	a0,a0,594 # ffffffffc0201888 <commands+0x370>
ffffffffc020063e:	0141                	addi	sp,sp,16
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
ffffffffc0200646:	85aa                	mv	a1,a0
ffffffffc0200648:	842a                	mv	s0,a0
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	25650513          	addi	a0,a0,598 # ffffffffc02018a0 <commands+0x388>
ffffffffc0200652:	e406                	sd	ra,8(sp)
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	25650513          	addi	a0,a0,598 # ffffffffc02018b8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	25e50513          	addi	a0,a0,606 # ffffffffc02018d0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	26650513          	addi	a0,a0,614 # ffffffffc02018e8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020068e:	11843583          	ld	a1,280(s0)
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	26a50513          	addi	a0,a0,618 # ffffffffc0201900 <commands+0x3e8>
ffffffffc020069e:	0141                	addi	sp,sp,16
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	33070713          	addi	a4,a4,816 # ffffffffc02019e0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	2b650513          	addi	a0,a0,694 # ffffffffc0201978 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	28c50513          	addi	a0,a0,652 # ffffffffc0201958 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	24250513          	addi	a0,a0,578 # ffffffffc0201918 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	2b850513          	addi	a0,a0,696 # ffffffffc0201998 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
ffffffffc02006f2:	00005697          	auipc	a3,0x5
ffffffffc02006f6:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205520 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	2b050513          	addi	a0,a0,688 # ffffffffc02019c0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	21e50513          	addi	a0,a0,542 # ffffffffc0201938 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
ffffffffc0200726:	60a2                	ld	ra,8(sp)
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	28450513          	addi	a0,a0,644 # ffffffffc02019b0 <commands+0x498>
ffffffffc0200734:	0141                	addi	sp,sp,16
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
ffffffffc0200746:	8082                	ret
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
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

ffffffffc0200802 <buddy_init>:
#define free_list(order) (buddy_free_area.free_list[order])
#define nr_free(order) (buddy_free_area.nr_free[order])

static void
buddy_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200802:	00005717          	auipc	a4,0x5
ffffffffc0200806:	8be70713          	addi	a4,a4,-1858 # ffffffffc02050c0 <buddy_free_area+0xb0>
ffffffffc020080a:	00005797          	auipc	a5,0x5
ffffffffc020080e:	80678793          	addi	a5,a5,-2042 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200812:	86ba                	mv	a3,a4
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200814:	e79c                	sd	a5,8(a5)
ffffffffc0200816:	e39c                	sd	a5,0(a5)
        list_init(&free_list(i));
        nr_free(i) = 0;
ffffffffc0200818:	00073023          	sd	zero,0(a4)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020081c:	07c1                	addi	a5,a5,16
ffffffffc020081e:	0721                	addi	a4,a4,8
ffffffffc0200820:	fed79ae3          	bne	a5,a3,ffffffffc0200814 <buddy_init+0x12>
    }
}
ffffffffc0200824:	8082                	ret

ffffffffc0200826 <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
    int order = 0;
    size_t block_size = 1;

    // 查找合适的块
    while (block_size < n) {
ffffffffc0200826:	4785                	li	a5,1
    int order = 0;
ffffffffc0200828:	4801                	li	a6,0
    while (block_size < n) {
ffffffffc020082a:	00a7f963          	bgeu	a5,a0,ffffffffc020083c <buddy_alloc_pages+0x16>
        block_size *= 2;
ffffffffc020082e:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc0200830:	2805                	addiw	a6,a6,1
    while (block_size < n) {
ffffffffc0200832:	fea7eee3          	bltu	a5,a0,ffffffffc020082e <buddy_alloc_pages+0x8>
    }
    
    if (order > MAX_ORDER) {
ffffffffc0200836:	47a9                	li	a5,10
ffffffffc0200838:	0307c363          	blt	a5,a6,ffffffffc020085e <buddy_alloc_pages+0x38>
ffffffffc020083c:	00004317          	auipc	t1,0x4
ffffffffc0200840:	7d430313          	addi	t1,t1,2004 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200844:	00481e93          	slli	t4,a6,0x4
ffffffffc0200848:	01d307b3          	add	a5,t1,t4
    int order = 0;
ffffffffc020084c:	86c2                	mv	a3,a6
        return NULL;  // 请求的块大小超过最大块
    }

    int curr_order = order;
    while (curr_order <= MAX_ORDER && list_empty(&free_list(curr_order))) {
ffffffffc020084e:	472d                	li	a4,11
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc0200850:	6790                	ld	a2,8(a5)
ffffffffc0200852:	00f61863          	bne	a2,a5,ffffffffc0200862 <buddy_alloc_pages+0x3c>
        curr_order++;
ffffffffc0200856:	2685                	addiw	a3,a3,1
    while (curr_order <= MAX_ORDER && list_empty(&free_list(curr_order))) {
ffffffffc0200858:	07c1                	addi	a5,a5,16
ffffffffc020085a:	fee69be3          	bne	a3,a4,ffffffffc0200850 <buddy_alloc_pages+0x2a>
        return NULL;  // 请求的块大小超过最大块
ffffffffc020085e:	4501                	li	a0,0
    list_del(&(page->page_link));
    nr_free(order)--;

    ClearPageProperty(page);
    return page;
}
ffffffffc0200860:	8082                	ret
    while (curr_order > order) {
ffffffffc0200862:	06d85e63          	bge	a6,a3,ffffffffc02008de <buddy_alloc_pages+0xb8>
        nr_free(curr_order)--;
ffffffffc0200866:	01668793          	addi	a5,a3,22
ffffffffc020086a:	078e                	slli	a5,a5,0x3
ffffffffc020086c:	0156851b          	addiw	a0,a3,21
ffffffffc0200870:	fff68593          	addi	a1,a3,-1
ffffffffc0200874:	979a                	add	a5,a5,t1
ffffffffc0200876:	050e                	slli	a0,a0,0x3
ffffffffc0200878:	0592                	slli	a1,a1,0x4
ffffffffc020087a:	6398                	ld	a4,0(a5)
ffffffffc020087c:	951a                	add	a0,a0,t1
ffffffffc020087e:	959a                	add	a1,a1,t1
        struct Page *buddy = p + (1 << curr_order);
ffffffffc0200880:	4285                	li	t0,1
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200882:	4f89                	li	t6,2
ffffffffc0200884:	a011                	j	ffffffffc0200888 <buddy_alloc_pages+0x62>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200886:	6d90                	ld	a2,24(a1)
        curr_order--;
ffffffffc0200888:	fff6889b          	addiw	a7,a3,-1
    __list_del(listelm->prev, listelm->next);
ffffffffc020088c:	00063e03          	ld	t3,0(a2)
ffffffffc0200890:	6614                	ld	a3,8(a2)
        struct Page *buddy = p + (1 << curr_order);
ffffffffc0200892:	01129f3b          	sllw	t5,t0,a7
ffffffffc0200896:	002f1793          	slli	a5,t5,0x2
ffffffffc020089a:	97fa                	add	a5,a5,t5
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020089c:	00de3423          	sd	a3,8(t3)
ffffffffc02008a0:	078e                	slli	a5,a5,0x3
    next->prev = prev;
ffffffffc02008a2:	01c6b023          	sd	t3,0(a3)
        nr_free(curr_order)--;
ffffffffc02008a6:	177d                	addi	a4,a4,-1
        struct Page *buddy = p + (1 << curr_order);
ffffffffc02008a8:	17a1                	addi	a5,a5,-24
        nr_free(curr_order)--;
ffffffffc02008aa:	e518                	sd	a4,8(a0)
        struct Page *buddy = p + (1 << curr_order);
ffffffffc02008ac:	97b2                	add	a5,a5,a2
        curr_order--;
ffffffffc02008ae:	0008869b          	sext.w	a3,a7
        buddy->property = curr_order;
ffffffffc02008b2:	0117a823          	sw	a7,16(a5)
ffffffffc02008b6:	00878713          	addi	a4,a5,8
ffffffffc02008ba:	41f7302f          	amoor.d	zero,t6,(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008be:	6590                	ld	a2,8(a1)
        nr_free(curr_order)++;
ffffffffc02008c0:	6118                	ld	a4,0(a0)
        list_add(&free_list(curr_order), &(buddy->page_link));
ffffffffc02008c2:	01878893          	addi	a7,a5,24
    prev->next = next->prev = elm;
ffffffffc02008c6:	01163023          	sd	a7,0(a2)
ffffffffc02008ca:	0115b423          	sd	a7,8(a1)
    elm->prev = prev;
ffffffffc02008ce:	ef8c                	sd	a1,24(a5)
    elm->next = next;
ffffffffc02008d0:	f390                	sd	a2,32(a5)
        nr_free(curr_order)++;
ffffffffc02008d2:	0705                	addi	a4,a4,1
ffffffffc02008d4:	e118                	sd	a4,0(a0)
    while (curr_order > order) {
ffffffffc02008d6:	15c1                	addi	a1,a1,-16
ffffffffc02008d8:	1561                	addi	a0,a0,-8
ffffffffc02008da:	fad816e3          	bne	a6,a3,ffffffffc0200886 <buddy_alloc_pages+0x60>
    return listelm->next;
ffffffffc02008de:	9e9a                	add	t4,t4,t1
ffffffffc02008e0:	008eb783          	ld	a5,8(t4)
    nr_free(order)--;
ffffffffc02008e4:	0859                	addi	a6,a6,22
ffffffffc02008e6:	080e                	slli	a6,a6,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc02008e8:	6390                	ld	a2,0(a5)
ffffffffc02008ea:	6794                	ld	a3,8(a5)
ffffffffc02008ec:	981a                	add	a6,a6,t1
ffffffffc02008ee:	00083703          	ld	a4,0(a6)
    prev->next = next;
ffffffffc02008f2:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02008f4:	e290                	sd	a2,0(a3)
ffffffffc02008f6:	177d                	addi	a4,a4,-1
    struct Page *page = le2page(list_next(&free_list(order)), page_link);
ffffffffc02008f8:	fe878513          	addi	a0,a5,-24
    nr_free(order)--;
ffffffffc02008fc:	00e83023          	sd	a4,0(a6)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200900:	17c1                	addi	a5,a5,-16
ffffffffc0200902:	5775                	li	a4,-3
ffffffffc0200904:	60e7b02f          	amoand.d	zero,a4,(a5)
    return page;
ffffffffc0200908:	8082                	ret

ffffffffc020090a <buddy_free_pages>:

static void
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020090a:	1141                	addi	sp,sp,-16
ffffffffc020090c:	e422                	sd	s0,8(sp)
    int order = 0;
    size_t block_size = 1;

    while (block_size < n) {
ffffffffc020090e:	4785                	li	a5,1
ffffffffc0200910:	0cb7fd63          	bgeu	a5,a1,ffffffffc02009ea <buddy_free_pages+0xe0>
ffffffffc0200914:	00850713          	addi	a4,a0,8
    int order = 0;
ffffffffc0200918:	4681                	li	a3,0
        block_size *= 2;
ffffffffc020091a:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc020091c:	2685                	addiw	a3,a3,1
    while (block_size < n) {
ffffffffc020091e:	feb7eee3          	bltu	a5,a1,ffffffffc020091a <buddy_free_pages+0x10>
    }

    base->property = order;
ffffffffc0200922:	c914                	sw	a3,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200924:	4789                	li	a5,2
ffffffffc0200926:	40f7302f          	amoor.d	zero,a5,(a4)
    SetPageProperty(base);

    // 合并相邻的伙伴块
    while (order < MAX_ORDER) {
ffffffffc020092a:	47a5                	li	a5,9
ffffffffc020092c:	0cd7c863          	blt	a5,a3,ffffffffc02009fc <buddy_free_pages+0xf2>
ffffffffc0200930:	0166881b          	addiw	a6,a3,22
ffffffffc0200934:	00004f17          	auipc	t5,0x4
ffffffffc0200938:	6dcf0f13          	addi	t5,t5,1756 # ffffffffc0205010 <buddy_free_area>
ffffffffc020093c:	080e                	slli	a6,a6,0x3
ffffffffc020093e:	987a                	add	a6,a6,t5
ffffffffc0200940:	00001f97          	auipc	t6,0x1
ffffffffc0200944:	560fbf83          	ld	t6,1376(t6) # ffffffffc0201ea0 <error_string+0x38>
        struct Page *buddy = base + (base - mem_start) / (1 << order) % 2 * (1 << order) - (base - mem_start) % (2 * (1 << order));
ffffffffc0200948:	4e85                	li	t4,1
ffffffffc020094a:	4e09                	li	t3,2
    while (order < MAX_ORDER) {
ffffffffc020094c:	42a9                	li	t0,10
ffffffffc020094e:	a025                	j	ffffffffc0200976 <buddy_free_pages+0x6c>
        
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc0200950:	4b98                	lw	a4,16(a5)
ffffffffc0200952:	06d71663          	bne	a4,a3,ffffffffc02009be <buddy_free_pages+0xb4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200956:	6f90                	ld	a2,24(a5)
ffffffffc0200958:	7398                	ld	a4,32(a5)
        
        if (buddy < base) {
            base = buddy;
        }
        
        order++;
ffffffffc020095a:	0008869b          	sext.w	a3,a7
    prev->next = next;
ffffffffc020095e:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200960:	e310                	sd	a2,0(a4)
        nr_free(order)--;
ffffffffc0200962:	00783023          	sd	t2,0(a6)
        if (buddy < base) {
ffffffffc0200966:	00a7f363          	bgeu	a5,a0,ffffffffc020096c <buddy_free_pages+0x62>
ffffffffc020096a:	853e                	mv	a0,a5
        base->property = order;
ffffffffc020096c:	01152823          	sw	a7,16(a0)
    while (order < MAX_ORDER) {
ffffffffc0200970:	0821                	addi	a6,a6,8
ffffffffc0200972:	06568963          	beq	a3,t0,ffffffffc02009e4 <buddy_free_pages+0xda>
        struct Page *buddy = base + (base - mem_start) / (1 << order) % 2 * (1 << order) - (base - mem_start) % (2 * (1 << order));
ffffffffc0200976:	40355613          	srai	a2,a0,0x3
ffffffffc020097a:	03f60633          	mul	a2,a2,t6
ffffffffc020097e:	00de97bb          	sllw	a5,t4,a3
ffffffffc0200982:	00de143b          	sllw	s0,t3,a3
ffffffffc0200986:	85be                	mv	a1,a5
        nr_free(order)--;
ffffffffc0200988:	00083303          	ld	t1,0(a6)
        order++;
ffffffffc020098c:	0016889b          	addiw	a7,a3,1
        nr_free(order)--;
ffffffffc0200990:	fff30393          	addi	t2,t1,-1
        struct Page *buddy = base + (base - mem_start) / (1 << order) % 2 * (1 << order) - (base - mem_start) % (2 * (1 << order));
ffffffffc0200994:	02f64733          	div	a4,a2,a5
ffffffffc0200998:	02866633          	rem	a2,a2,s0
ffffffffc020099c:	03f75413          	srli	s0,a4,0x3f
ffffffffc02009a0:	9722                	add	a4,a4,s0
ffffffffc02009a2:	00177793          	andi	a5,a4,1
ffffffffc02009a6:	8f81                	sub	a5,a5,s0
ffffffffc02009a8:	02b787b3          	mul	a5,a5,a1
ffffffffc02009ac:	8f91                	sub	a5,a5,a2
ffffffffc02009ae:	00279713          	slli	a4,a5,0x2
ffffffffc02009b2:	97ba                	add	a5,a5,a4
ffffffffc02009b4:	078e                	slli	a5,a5,0x3
ffffffffc02009b6:	97aa                	add	a5,a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009b8:	6798                	ld	a4,8(a5)
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc02009ba:	8b09                	andi	a4,a4,2
ffffffffc02009bc:	fb51                	bnez	a4,ffffffffc0200950 <buddy_free_pages+0x46>
ffffffffc02009be:	01668793          	addi	a5,a3,22
    __list_add(elm, listelm, listelm->next);
ffffffffc02009c2:	0692                	slli	a3,a3,0x4
ffffffffc02009c4:	96fa                	add	a3,a3,t5
ffffffffc02009c6:	6698                	ld	a4,8(a3)
    }

    list_add(&free_list(order), &(base->page_link));
ffffffffc02009c8:	01850613          	addi	a2,a0,24
    nr_free(order)++;
}
ffffffffc02009cc:	6422                	ld	s0,8(sp)
    prev->next = next->prev = elm;
ffffffffc02009ce:	e310                	sd	a2,0(a4)
ffffffffc02009d0:	e690                	sd	a2,8(a3)
    nr_free(order)++;
ffffffffc02009d2:	078e                	slli	a5,a5,0x3
    elm->next = next;
ffffffffc02009d4:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc02009d6:	ed14                	sd	a3,24(a0)
ffffffffc02009d8:	9f3e                	add	t5,t5,a5
ffffffffc02009da:	0305                	addi	t1,t1,1
ffffffffc02009dc:	006f3023          	sd	t1,0(t5)
}
ffffffffc02009e0:	0141                	addi	sp,sp,16
ffffffffc02009e2:	8082                	ret
    nr_free(order)++;
ffffffffc02009e4:	100f3303          	ld	t1,256(t5)
ffffffffc02009e8:	bfd9                	j	ffffffffc02009be <buddy_free_pages+0xb4>
    base->property = order;
ffffffffc02009ea:	00052823          	sw	zero,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009ee:	4789                	li	a5,2
ffffffffc02009f0:	00850713          	addi	a4,a0,8
ffffffffc02009f4:	40f7302f          	amoor.d	zero,a5,(a4)
    int order = 0;
ffffffffc02009f8:	4681                	li	a3,0
ffffffffc02009fa:	bf1d                	j	ffffffffc0200930 <buddy_free_pages+0x26>
    nr_free(order)++;
ffffffffc02009fc:	01668793          	addi	a5,a3,22
ffffffffc0200a00:	00004f17          	auipc	t5,0x4
ffffffffc0200a04:	610f0f13          	addi	t5,t5,1552 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200a08:	00379713          	slli	a4,a5,0x3
ffffffffc0200a0c:	977a                	add	a4,a4,t5
ffffffffc0200a0e:	00073303          	ld	t1,0(a4)
ffffffffc0200a12:	bf45                	j	ffffffffc02009c2 <buddy_free_pages+0xb8>

ffffffffc0200a14 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a14:	00004697          	auipc	a3,0x4
ffffffffc0200a18:	6ac68693          	addi	a3,a3,1708 # ffffffffc02050c0 <buddy_free_area+0xb0>
ffffffffc0200a1c:	4781                	li	a5,0
    size_t total = 0;
ffffffffc0200a1e:	4501                	li	a0,0
        total += nr_free(i) * (1 << i);
ffffffffc0200a20:	4805                	li	a6,1
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a22:	45ad                	li	a1,11
        total += nr_free(i) * (1 << i);
ffffffffc0200a24:	6290                	ld	a2,0(a3)
ffffffffc0200a26:	00f8173b          	sllw	a4,a6,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a2a:	2785                	addiw	a5,a5,1
        total += nr_free(i) * (1 << i);
ffffffffc0200a2c:	02c70733          	mul	a4,a4,a2
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a30:	06a1                	addi	a3,a3,8
        total += nr_free(i) * (1 << i);
ffffffffc0200a32:	953a                	add	a0,a0,a4
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a34:	feb798e3          	bne	a5,a1,ffffffffc0200a24 <buddy_nr_free_pages+0x10>
    }
    return total;
}
ffffffffc0200a38:	8082                	ret

ffffffffc0200a3a <buddy_basic_check>:

static void
buddy_basic_check(void) {
ffffffffc0200a3a:	1101                	addi	sp,sp,-32
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200a3c:	4505                	li	a0,1
buddy_basic_check(void) {
ffffffffc0200a3e:	ec06                	sd	ra,24(sp)
ffffffffc0200a40:	e822                	sd	s0,16(sp)
ffffffffc0200a42:	e426                	sd	s1,8(sp)
ffffffffc0200a44:	e04a                	sd	s2,0(sp)
    assert((p0 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200a46:	de1ff0ef          	jal	ra,ffffffffc0200826 <buddy_alloc_pages>
ffffffffc0200a4a:	c13d                	beqz	a0,ffffffffc0200ab0 <buddy_basic_check+0x76>
ffffffffc0200a4c:	892a                	mv	s2,a0
    assert((p1 = buddy_alloc_pages(2)) != NULL);
ffffffffc0200a4e:	4509                	li	a0,2
ffffffffc0200a50:	dd7ff0ef          	jal	ra,ffffffffc0200826 <buddy_alloc_pages>
ffffffffc0200a54:	84aa                	mv	s1,a0
ffffffffc0200a56:	cd4d                	beqz	a0,ffffffffc0200b10 <buddy_basic_check+0xd6>
    assert((p2 = buddy_alloc_pages(3)) != NULL);
ffffffffc0200a58:	450d                	li	a0,3
ffffffffc0200a5a:	dcdff0ef          	jal	ra,ffffffffc0200826 <buddy_alloc_pages>
ffffffffc0200a5e:	842a                	mv	s0,a0
ffffffffc0200a60:	c941                	beqz	a0,ffffffffc0200af0 <buddy_basic_check+0xb6>
    buddy_free_pages(p0, 1);
ffffffffc0200a62:	4585                	li	a1,1
ffffffffc0200a64:	854a                	mv	a0,s2
ffffffffc0200a66:	ea5ff0ef          	jal	ra,ffffffffc020090a <buddy_free_pages>
    buddy_free_pages(p1, 2);
ffffffffc0200a6a:	4589                	li	a1,2
ffffffffc0200a6c:	8526                	mv	a0,s1
ffffffffc0200a6e:	e9dff0ef          	jal	ra,ffffffffc020090a <buddy_free_pages>
    buddy_free_pages(p2, 3);
ffffffffc0200a72:	8522                	mv	a0,s0
ffffffffc0200a74:	458d                	li	a1,3
ffffffffc0200a76:	e95ff0ef          	jal	ra,ffffffffc020090a <buddy_free_pages>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a7a:	00004697          	auipc	a3,0x4
ffffffffc0200a7e:	64668693          	addi	a3,a3,1606 # ffffffffc02050c0 <buddy_free_area+0xb0>
    size_t total = 0;
ffffffffc0200a82:	4601                	li	a2,0
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a84:	4781                	li	a5,0
        total += nr_free(i) * (1 << i);
ffffffffc0200a86:	4805                	li	a6,1
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a88:	452d                	li	a0,11
        total += nr_free(i) * (1 << i);
ffffffffc0200a8a:	628c                	ld	a1,0(a3)
ffffffffc0200a8c:	00f8173b          	sllw	a4,a6,a5
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a90:	2785                	addiw	a5,a5,1
        total += nr_free(i) * (1 << i);
ffffffffc0200a92:	02b70733          	mul	a4,a4,a1
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a96:	06a1                	addi	a3,a3,8
        total += nr_free(i) * (1 << i);
ffffffffc0200a98:	963a                	add	a2,a2,a4
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200a9a:	fea798e3          	bne	a5,a0,ffffffffc0200a8a <buddy_basic_check+0x50>
    assert(buddy_nr_free_pages() == 6);
ffffffffc0200a9e:	4799                	li	a5,6
ffffffffc0200aa0:	02f61863          	bne	a2,a5,ffffffffc0200ad0 <buddy_basic_check+0x96>
}
ffffffffc0200aa4:	60e2                	ld	ra,24(sp)
ffffffffc0200aa6:	6442                	ld	s0,16(sp)
ffffffffc0200aa8:	64a2                	ld	s1,8(sp)
ffffffffc0200aaa:	6902                	ld	s2,0(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
ffffffffc0200aae:	8082                	ret
    assert((p0 = buddy_alloc_pages(1)) != NULL);
ffffffffc0200ab0:	00001697          	auipc	a3,0x1
ffffffffc0200ab4:	f6068693          	addi	a3,a3,-160 # ffffffffc0201a10 <commands+0x4f8>
ffffffffc0200ab8:	00001617          	auipc	a2,0x1
ffffffffc0200abc:	f8060613          	addi	a2,a2,-128 # ffffffffc0201a38 <commands+0x520>
ffffffffc0200ac0:	09600593          	li	a1,150
ffffffffc0200ac4:	00001517          	auipc	a0,0x1
ffffffffc0200ac8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0201a50 <commands+0x538>
ffffffffc0200acc:	8e1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(buddy_nr_free_pages() == 6);
ffffffffc0200ad0:	00001697          	auipc	a3,0x1
ffffffffc0200ad4:	fe868693          	addi	a3,a3,-24 # ffffffffc0201ab8 <commands+0x5a0>
ffffffffc0200ad8:	00001617          	auipc	a2,0x1
ffffffffc0200adc:	f6060613          	addi	a2,a2,-160 # ffffffffc0201a38 <commands+0x520>
ffffffffc0200ae0:	09c00593          	li	a1,156
ffffffffc0200ae4:	00001517          	auipc	a0,0x1
ffffffffc0200ae8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0201a50 <commands+0x538>
ffffffffc0200aec:	8c1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = buddy_alloc_pages(3)) != NULL);
ffffffffc0200af0:	00001697          	auipc	a3,0x1
ffffffffc0200af4:	fa068693          	addi	a3,a3,-96 # ffffffffc0201a90 <commands+0x578>
ffffffffc0200af8:	00001617          	auipc	a2,0x1
ffffffffc0200afc:	f4060613          	addi	a2,a2,-192 # ffffffffc0201a38 <commands+0x520>
ffffffffc0200b00:	09800593          	li	a1,152
ffffffffc0200b04:	00001517          	auipc	a0,0x1
ffffffffc0200b08:	f4c50513          	addi	a0,a0,-180 # ffffffffc0201a50 <commands+0x538>
ffffffffc0200b0c:	8a1ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = buddy_alloc_pages(2)) != NULL);
ffffffffc0200b10:	00001697          	auipc	a3,0x1
ffffffffc0200b14:	f5868693          	addi	a3,a3,-168 # ffffffffc0201a68 <commands+0x550>
ffffffffc0200b18:	00001617          	auipc	a2,0x1
ffffffffc0200b1c:	f2060613          	addi	a2,a2,-224 # ffffffffc0201a38 <commands+0x520>
ffffffffc0200b20:	09700593          	li	a1,151
ffffffffc0200b24:	00001517          	auipc	a0,0x1
ffffffffc0200b28:	f2c50513          	addi	a0,a0,-212 # ffffffffc0201a50 <commands+0x538>
ffffffffc0200b2c:	881ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b30 <buddy_init_memmap>:
    assert(n > 0);
ffffffffc0200b30:	c1c1                	beqz	a1,ffffffffc0200bb0 <buddy_init_memmap+0x80>
ffffffffc0200b32:	00004897          	auipc	a7,0x4
ffffffffc0200b36:	4de88893          	addi	a7,a7,1246 # ffffffffc0205010 <buddy_free_area>
ffffffffc0200b3a:	4f85                	li	t6,1
ffffffffc0200b3c:	4f09                	li	t5,2
        order = 0;
ffffffffc0200b3e:	4781                	li	a5,0
        while (block_size * 2 <= n) {
ffffffffc0200b40:	4709                	li	a4,2
ffffffffc0200b42:	07f58063          	beq	a1,t6,ffffffffc0200ba2 <buddy_init_memmap+0x72>
            order++;
ffffffffc0200b46:	86ba                	mv	a3,a4
        while (block_size * 2 <= n) {
ffffffffc0200b48:	0706                	slli	a4,a4,0x1
            order++;
ffffffffc0200b4a:	2785                	addiw	a5,a5,1
        while (block_size * 2 <= n) {
ffffffffc0200b4c:	fee5fde3          	bgeu	a1,a4,ffffffffc0200b46 <buddy_init_memmap+0x16>
        base += block_size;
ffffffffc0200b50:	00269713          	slli	a4,a3,0x2
        list_add(&free_list(order), &(p->page_link));
ffffffffc0200b54:	00479613          	slli	a2,a5,0x4
        base += block_size;
ffffffffc0200b58:	9736                	add	a4,a4,a3
        p->property = order;
ffffffffc0200b5a:	0007881b          	sext.w	a6,a5
        list_add(&free_list(order), &(p->page_link));
ffffffffc0200b5e:	00c88eb3          	add	t4,a7,a2
        base += block_size;
ffffffffc0200b62:	070e                	slli	a4,a4,0x3
        p->property = order;
ffffffffc0200b64:	01052823          	sw	a6,16(a0)
ffffffffc0200b68:	00850813          	addi	a6,a0,8
ffffffffc0200b6c:	41e8302f          	amoor.d	zero,t5,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b70:	9646                	add	a2,a2,a7
        nr_free(order)++;
ffffffffc0200b72:	07d9                	addi	a5,a5,22
ffffffffc0200b74:	00863303          	ld	t1,8(a2)
ffffffffc0200b78:	078e                	slli	a5,a5,0x3
ffffffffc0200b7a:	97c6                	add	a5,a5,a7
ffffffffc0200b7c:	0007b803          	ld	a6,0(a5)
        list_add(&free_list(order), &(p->page_link));
ffffffffc0200b80:	01850e13          	addi	t3,a0,24
    prev->next = next->prev = elm;
ffffffffc0200b84:	01c33023          	sd	t3,0(t1)
ffffffffc0200b88:	01c63423          	sd	t3,8(a2)
    elm->next = next;
ffffffffc0200b8c:	02653023          	sd	t1,32(a0)
    elm->prev = prev;
ffffffffc0200b90:	01d53c23          	sd	t4,24(a0)
        nr_free(order)++;
ffffffffc0200b94:	00180613          	addi	a2,a6,1
ffffffffc0200b98:	e390                	sd	a2,0(a5)
        n -= block_size;
ffffffffc0200b9a:	8d95                	sub	a1,a1,a3
        base += block_size;
ffffffffc0200b9c:	953a                	add	a0,a0,a4
    while (n > 0) {
ffffffffc0200b9e:	f1c5                	bnez	a1,ffffffffc0200b3e <buddy_init_memmap+0xe>
ffffffffc0200ba0:	8082                	ret
        size_t block_size = 1;
ffffffffc0200ba2:	4685                	li	a3,1
        while (block_size * 2 <= n) {
ffffffffc0200ba4:	02800713          	li	a4,40
ffffffffc0200ba8:	8ec6                	mv	t4,a7
ffffffffc0200baa:	4801                	li	a6,0
ffffffffc0200bac:	4601                	li	a2,0
ffffffffc0200bae:	bf5d                	j	ffffffffc0200b64 <buddy_init_memmap+0x34>
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200bb0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200bb2:	00001697          	auipc	a3,0x1
ffffffffc0200bb6:	f2668693          	addi	a3,a3,-218 # ffffffffc0201ad8 <commands+0x5c0>
ffffffffc0200bba:	00001617          	auipc	a2,0x1
ffffffffc0200bbe:	e7e60613          	addi	a2,a2,-386 # ffffffffc0201a38 <commands+0x520>
ffffffffc0200bc2:	45f5                	li	a1,29
ffffffffc0200bc4:	00001517          	auipc	a0,0x1
ffffffffc0200bc8:	e8c50513          	addi	a0,a0,-372 # ffffffffc0201a50 <commands+0x538>
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200bcc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200bce:	fdeff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bd2 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc0200bd2:	00001797          	auipc	a5,0x1
ffffffffc0200bd6:	f2678793          	addi	a5,a5,-218 # ffffffffc0201af8 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200bda:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200bdc:	1101                	addi	sp,sp,-32
ffffffffc0200bde:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200be0:	00001517          	auipc	a0,0x1
ffffffffc0200be4:	f5050513          	addi	a0,a0,-176 # ffffffffc0201b30 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc0200be8:	00005497          	auipc	s1,0x5
ffffffffc0200bec:	95048493          	addi	s1,s1,-1712 # ffffffffc0205538 <pmm_manager>
void pmm_init(void) {
ffffffffc0200bf0:	ec06                	sd	ra,24(sp)
ffffffffc0200bf2:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc0200bf4:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200bf6:	cbcff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200bfa:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200bfc:	00005417          	auipc	s0,0x5
ffffffffc0200c00:	95440413          	addi	s0,s0,-1708 # ffffffffc0205550 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200c04:	679c                	ld	a5,8(a5)
ffffffffc0200c06:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c08:	57f5                	li	a5,-3
ffffffffc0200c0a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200c0c:	00001517          	auipc	a0,0x1
ffffffffc0200c10:	f3c50513          	addi	a0,a0,-196 # ffffffffc0201b48 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c14:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200c16:	c9cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200c1a:	46c5                	li	a3,17
ffffffffc0200c1c:	06ee                	slli	a3,a3,0x1b
ffffffffc0200c1e:	40100613          	li	a2,1025
ffffffffc0200c22:	16fd                	addi	a3,a3,-1
ffffffffc0200c24:	07e005b7          	lui	a1,0x7e00
ffffffffc0200c28:	0656                	slli	a2,a2,0x15
ffffffffc0200c2a:	00001517          	auipc	a0,0x1
ffffffffc0200c2e:	f3650513          	addi	a0,a0,-202 # ffffffffc0201b60 <buddy_pmm_manager+0x68>
ffffffffc0200c32:	c80ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c36:	777d                	lui	a4,0xfffff
ffffffffc0200c38:	00006797          	auipc	a5,0x6
ffffffffc0200c3c:	92778793          	addi	a5,a5,-1753 # ffffffffc020655f <end+0xfff>
ffffffffc0200c40:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200c42:	00005517          	auipc	a0,0x5
ffffffffc0200c46:	8e650513          	addi	a0,a0,-1818 # ffffffffc0205528 <npage>
ffffffffc0200c4a:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c4e:	00005597          	auipc	a1,0x5
ffffffffc0200c52:	8e258593          	addi	a1,a1,-1822 # ffffffffc0205530 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200c56:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c58:	e19c                	sd	a5,0(a1)
ffffffffc0200c5a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200c5c:	4701                	li	a4,0
ffffffffc0200c5e:	4885                	li	a7,1
ffffffffc0200c60:	fff80837          	lui	a6,0xfff80
ffffffffc0200c64:	a011                	j	ffffffffc0200c68 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200c66:	619c                	ld	a5,0(a1)
ffffffffc0200c68:	97b6                	add	a5,a5,a3
ffffffffc0200c6a:	07a1                	addi	a5,a5,8
ffffffffc0200c6c:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200c70:	611c                	ld	a5,0(a0)
ffffffffc0200c72:	0705                	addi	a4,a4,1
ffffffffc0200c74:	02868693          	addi	a3,a3,40
ffffffffc0200c78:	01078633          	add	a2,a5,a6
ffffffffc0200c7c:	fec765e3          	bltu	a4,a2,ffffffffc0200c66 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200c80:	6190                	ld	a2,0(a1)
ffffffffc0200c82:	00279713          	slli	a4,a5,0x2
ffffffffc0200c86:	973e                	add	a4,a4,a5
ffffffffc0200c88:	fec006b7          	lui	a3,0xfec00
ffffffffc0200c8c:	070e                	slli	a4,a4,0x3
ffffffffc0200c8e:	96b2                	add	a3,a3,a2
ffffffffc0200c90:	96ba                	add	a3,a3,a4
ffffffffc0200c92:	c0200737          	lui	a4,0xc0200
ffffffffc0200c96:	08e6ef63          	bltu	a3,a4,ffffffffc0200d34 <pmm_init+0x162>
ffffffffc0200c9a:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200c9c:	45c5                	li	a1,17
ffffffffc0200c9e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ca0:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200ca2:	04b6e863          	bltu	a3,a1,ffffffffc0200cf2 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200ca6:	609c                	ld	a5,0(s1)
ffffffffc0200ca8:	7b9c                	ld	a5,48(a5)
ffffffffc0200caa:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200cac:	00001517          	auipc	a0,0x1
ffffffffc0200cb0:	f4c50513          	addi	a0,a0,-180 # ffffffffc0201bf8 <buddy_pmm_manager+0x100>
ffffffffc0200cb4:	bfeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200cb8:	00003597          	auipc	a1,0x3
ffffffffc0200cbc:	34858593          	addi	a1,a1,840 # ffffffffc0204000 <boot_page_table_sv39>
ffffffffc0200cc0:	00005797          	auipc	a5,0x5
ffffffffc0200cc4:	88b7b423          	sd	a1,-1912(a5) # ffffffffc0205548 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200cc8:	c02007b7          	lui	a5,0xc0200
ffffffffc0200ccc:	08f5e063          	bltu	a1,a5,ffffffffc0200d4c <pmm_init+0x17a>
ffffffffc0200cd0:	6010                	ld	a2,0(s0)
}
ffffffffc0200cd2:	6442                	ld	s0,16(sp)
ffffffffc0200cd4:	60e2                	ld	ra,24(sp)
ffffffffc0200cd6:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200cd8:	40c58633          	sub	a2,a1,a2
ffffffffc0200cdc:	00005797          	auipc	a5,0x5
ffffffffc0200ce0:	86c7b223          	sd	a2,-1948(a5) # ffffffffc0205540 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ce4:	00001517          	auipc	a0,0x1
ffffffffc0200ce8:	f3450513          	addi	a0,a0,-204 # ffffffffc0201c18 <buddy_pmm_manager+0x120>
}
ffffffffc0200cec:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200cee:	bc4ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200cf2:	6705                	lui	a4,0x1
ffffffffc0200cf4:	177d                	addi	a4,a4,-1
ffffffffc0200cf6:	96ba                	add	a3,a3,a4
ffffffffc0200cf8:	777d                	lui	a4,0xfffff
ffffffffc0200cfa:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200cfc:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200d00:	00f57e63          	bgeu	a0,a5,ffffffffc0200d1c <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200d04:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200d06:	982a                	add	a6,a6,a0
ffffffffc0200d08:	00281513          	slli	a0,a6,0x2
ffffffffc0200d0c:	9542                	add	a0,a0,a6
ffffffffc0200d0e:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200d10:	8d95                	sub	a1,a1,a3
ffffffffc0200d12:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200d14:	81b1                	srli	a1,a1,0xc
ffffffffc0200d16:	9532                	add	a0,a0,a2
ffffffffc0200d18:	9782                	jalr	a5
}
ffffffffc0200d1a:	b771                	j	ffffffffc0200ca6 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	eac60613          	addi	a2,a2,-340 # ffffffffc0201bc8 <buddy_pmm_manager+0xd0>
ffffffffc0200d24:	06b00593          	li	a1,107
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	ec050513          	addi	a0,a0,-320 # ffffffffc0201be8 <buddy_pmm_manager+0xf0>
ffffffffc0200d30:	e7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200d34:	00001617          	auipc	a2,0x1
ffffffffc0200d38:	e5c60613          	addi	a2,a2,-420 # ffffffffc0201b90 <buddy_pmm_manager+0x98>
ffffffffc0200d3c:	07500593          	li	a1,117
ffffffffc0200d40:	00001517          	auipc	a0,0x1
ffffffffc0200d44:	e7850513          	addi	a0,a0,-392 # ffffffffc0201bb8 <buddy_pmm_manager+0xc0>
ffffffffc0200d48:	e64ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d4c:	86ae                	mv	a3,a1
ffffffffc0200d4e:	00001617          	auipc	a2,0x1
ffffffffc0200d52:	e4260613          	addi	a2,a2,-446 # ffffffffc0201b90 <buddy_pmm_manager+0x98>
ffffffffc0200d56:	09000593          	li	a1,144
ffffffffc0200d5a:	00001517          	auipc	a0,0x1
ffffffffc0200d5e:	e5e50513          	addi	a0,a0,-418 # ffffffffc0201bb8 <buddy_pmm_manager+0xc0>
ffffffffc0200d62:	e4aff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d66 <printnum>:
ffffffffc0200d66:	02069813          	slli	a6,a3,0x20
ffffffffc0200d6a:	7179                	addi	sp,sp,-48
ffffffffc0200d6c:	02085813          	srli	a6,a6,0x20
ffffffffc0200d70:	e052                	sd	s4,0(sp)
ffffffffc0200d72:	03067a33          	remu	s4,a2,a6
ffffffffc0200d76:	f022                	sd	s0,32(sp)
ffffffffc0200d78:	ec26                	sd	s1,24(sp)
ffffffffc0200d7a:	e84a                	sd	s2,16(sp)
ffffffffc0200d7c:	f406                	sd	ra,40(sp)
ffffffffc0200d7e:	e44e                	sd	s3,8(sp)
ffffffffc0200d80:	84aa                	mv	s1,a0
ffffffffc0200d82:	892e                	mv	s2,a1
ffffffffc0200d84:	fff7041b          	addiw	s0,a4,-1
ffffffffc0200d88:	2a01                	sext.w	s4,s4
ffffffffc0200d8a:	03067e63          	bgeu	a2,a6,ffffffffc0200dc6 <printnum+0x60>
ffffffffc0200d8e:	89be                	mv	s3,a5
ffffffffc0200d90:	00805763          	blez	s0,ffffffffc0200d9e <printnum+0x38>
ffffffffc0200d94:	347d                	addiw	s0,s0,-1
ffffffffc0200d96:	85ca                	mv	a1,s2
ffffffffc0200d98:	854e                	mv	a0,s3
ffffffffc0200d9a:	9482                	jalr	s1
ffffffffc0200d9c:	fc65                	bnez	s0,ffffffffc0200d94 <printnum+0x2e>
ffffffffc0200d9e:	1a02                	slli	s4,s4,0x20
ffffffffc0200da0:	00001797          	auipc	a5,0x1
ffffffffc0200da4:	eb878793          	addi	a5,a5,-328 # ffffffffc0201c58 <buddy_pmm_manager+0x160>
ffffffffc0200da8:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200dac:	9a3e                	add	s4,s4,a5
ffffffffc0200dae:	7402                	ld	s0,32(sp)
ffffffffc0200db0:	000a4503          	lbu	a0,0(s4)
ffffffffc0200db4:	70a2                	ld	ra,40(sp)
ffffffffc0200db6:	69a2                	ld	s3,8(sp)
ffffffffc0200db8:	6a02                	ld	s4,0(sp)
ffffffffc0200dba:	85ca                	mv	a1,s2
ffffffffc0200dbc:	87a6                	mv	a5,s1
ffffffffc0200dbe:	6942                	ld	s2,16(sp)
ffffffffc0200dc0:	64e2                	ld	s1,24(sp)
ffffffffc0200dc2:	6145                	addi	sp,sp,48
ffffffffc0200dc4:	8782                	jr	a5
ffffffffc0200dc6:	03065633          	divu	a2,a2,a6
ffffffffc0200dca:	8722                	mv	a4,s0
ffffffffc0200dcc:	f9bff0ef          	jal	ra,ffffffffc0200d66 <printnum>
ffffffffc0200dd0:	b7f9                	j	ffffffffc0200d9e <printnum+0x38>

ffffffffc0200dd2 <vprintfmt>:
ffffffffc0200dd2:	7119                	addi	sp,sp,-128
ffffffffc0200dd4:	f4a6                	sd	s1,104(sp)
ffffffffc0200dd6:	f0ca                	sd	s2,96(sp)
ffffffffc0200dd8:	ecce                	sd	s3,88(sp)
ffffffffc0200dda:	e8d2                	sd	s4,80(sp)
ffffffffc0200ddc:	e4d6                	sd	s5,72(sp)
ffffffffc0200dde:	e0da                	sd	s6,64(sp)
ffffffffc0200de0:	fc5e                	sd	s7,56(sp)
ffffffffc0200de2:	f06a                	sd	s10,32(sp)
ffffffffc0200de4:	fc86                	sd	ra,120(sp)
ffffffffc0200de6:	f8a2                	sd	s0,112(sp)
ffffffffc0200de8:	f862                	sd	s8,48(sp)
ffffffffc0200dea:	f466                	sd	s9,40(sp)
ffffffffc0200dec:	ec6e                	sd	s11,24(sp)
ffffffffc0200dee:	892a                	mv	s2,a0
ffffffffc0200df0:	84ae                	mv	s1,a1
ffffffffc0200df2:	8d32                	mv	s10,a2
ffffffffc0200df4:	8a36                	mv	s4,a3
ffffffffc0200df6:	02500993          	li	s3,37
ffffffffc0200dfa:	5b7d                	li	s6,-1
ffffffffc0200dfc:	00001a97          	auipc	s5,0x1
ffffffffc0200e00:	e90a8a93          	addi	s5,s5,-368 # ffffffffc0201c8c <buddy_pmm_manager+0x194>
ffffffffc0200e04:	00001b97          	auipc	s7,0x1
ffffffffc0200e08:	064b8b93          	addi	s7,s7,100 # ffffffffc0201e68 <error_string>
ffffffffc0200e0c:	000d4503          	lbu	a0,0(s10)
ffffffffc0200e10:	001d0413          	addi	s0,s10,1
ffffffffc0200e14:	01350a63          	beq	a0,s3,ffffffffc0200e28 <vprintfmt+0x56>
ffffffffc0200e18:	c121                	beqz	a0,ffffffffc0200e58 <vprintfmt+0x86>
ffffffffc0200e1a:	85a6                	mv	a1,s1
ffffffffc0200e1c:	0405                	addi	s0,s0,1
ffffffffc0200e1e:	9902                	jalr	s2
ffffffffc0200e20:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200e24:	ff351ae3          	bne	a0,s3,ffffffffc0200e18 <vprintfmt+0x46>
ffffffffc0200e28:	00044603          	lbu	a2,0(s0)
ffffffffc0200e2c:	02000793          	li	a5,32
ffffffffc0200e30:	4c81                	li	s9,0
ffffffffc0200e32:	4881                	li	a7,0
ffffffffc0200e34:	5c7d                	li	s8,-1
ffffffffc0200e36:	5dfd                	li	s11,-1
ffffffffc0200e38:	05500513          	li	a0,85
ffffffffc0200e3c:	4825                	li	a6,9
ffffffffc0200e3e:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e42:	0ff5f593          	zext.b	a1,a1
ffffffffc0200e46:	00140d13          	addi	s10,s0,1
ffffffffc0200e4a:	04b56263          	bltu	a0,a1,ffffffffc0200e8e <vprintfmt+0xbc>
ffffffffc0200e4e:	058a                	slli	a1,a1,0x2
ffffffffc0200e50:	95d6                	add	a1,a1,s5
ffffffffc0200e52:	4194                	lw	a3,0(a1)
ffffffffc0200e54:	96d6                	add	a3,a3,s5
ffffffffc0200e56:	8682                	jr	a3
ffffffffc0200e58:	70e6                	ld	ra,120(sp)
ffffffffc0200e5a:	7446                	ld	s0,112(sp)
ffffffffc0200e5c:	74a6                	ld	s1,104(sp)
ffffffffc0200e5e:	7906                	ld	s2,96(sp)
ffffffffc0200e60:	69e6                	ld	s3,88(sp)
ffffffffc0200e62:	6a46                	ld	s4,80(sp)
ffffffffc0200e64:	6aa6                	ld	s5,72(sp)
ffffffffc0200e66:	6b06                	ld	s6,64(sp)
ffffffffc0200e68:	7be2                	ld	s7,56(sp)
ffffffffc0200e6a:	7c42                	ld	s8,48(sp)
ffffffffc0200e6c:	7ca2                	ld	s9,40(sp)
ffffffffc0200e6e:	7d02                	ld	s10,32(sp)
ffffffffc0200e70:	6de2                	ld	s11,24(sp)
ffffffffc0200e72:	6109                	addi	sp,sp,128
ffffffffc0200e74:	8082                	ret
ffffffffc0200e76:	87b2                	mv	a5,a2
ffffffffc0200e78:	00144603          	lbu	a2,1(s0)
ffffffffc0200e7c:	846a                	mv	s0,s10
ffffffffc0200e7e:	00140d13          	addi	s10,s0,1
ffffffffc0200e82:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e86:	0ff5f593          	zext.b	a1,a1
ffffffffc0200e8a:	fcb572e3          	bgeu	a0,a1,ffffffffc0200e4e <vprintfmt+0x7c>
ffffffffc0200e8e:	85a6                	mv	a1,s1
ffffffffc0200e90:	02500513          	li	a0,37
ffffffffc0200e94:	9902                	jalr	s2
ffffffffc0200e96:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200e9a:	8d22                	mv	s10,s0
ffffffffc0200e9c:	f73788e3          	beq	a5,s3,ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc0200ea0:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200ea4:	1d7d                	addi	s10,s10,-1
ffffffffc0200ea6:	ff379de3          	bne	a5,s3,ffffffffc0200ea0 <vprintfmt+0xce>
ffffffffc0200eaa:	b78d                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc0200eac:	fd060c1b          	addiw	s8,a2,-48
ffffffffc0200eb0:	00144603          	lbu	a2,1(s0)
ffffffffc0200eb4:	846a                	mv	s0,s10
ffffffffc0200eb6:	fd06069b          	addiw	a3,a2,-48
ffffffffc0200eba:	0006059b          	sext.w	a1,a2
ffffffffc0200ebe:	02d86463          	bltu	a6,a3,ffffffffc0200ee6 <vprintfmt+0x114>
ffffffffc0200ec2:	00144603          	lbu	a2,1(s0)
ffffffffc0200ec6:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200eca:	0186873b          	addw	a4,a3,s8
ffffffffc0200ece:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200ed2:	9f2d                	addw	a4,a4,a1
ffffffffc0200ed4:	fd06069b          	addiw	a3,a2,-48
ffffffffc0200ed8:	0405                	addi	s0,s0,1
ffffffffc0200eda:	fd070c1b          	addiw	s8,a4,-48
ffffffffc0200ede:	0006059b          	sext.w	a1,a2
ffffffffc0200ee2:	fed870e3          	bgeu	a6,a3,ffffffffc0200ec2 <vprintfmt+0xf0>
ffffffffc0200ee6:	f40ddce3          	bgez	s11,ffffffffc0200e3e <vprintfmt+0x6c>
ffffffffc0200eea:	8de2                	mv	s11,s8
ffffffffc0200eec:	5c7d                	li	s8,-1
ffffffffc0200eee:	bf81                	j	ffffffffc0200e3e <vprintfmt+0x6c>
ffffffffc0200ef0:	fffdc693          	not	a3,s11
ffffffffc0200ef4:	96fd                	srai	a3,a3,0x3f
ffffffffc0200ef6:	00ddfdb3          	and	s11,s11,a3
ffffffffc0200efa:	00144603          	lbu	a2,1(s0)
ffffffffc0200efe:	2d81                	sext.w	s11,s11
ffffffffc0200f00:	846a                	mv	s0,s10
ffffffffc0200f02:	bf35                	j	ffffffffc0200e3e <vprintfmt+0x6c>
ffffffffc0200f04:	000a2c03          	lw	s8,0(s4)
ffffffffc0200f08:	00144603          	lbu	a2,1(s0)
ffffffffc0200f0c:	0a21                	addi	s4,s4,8
ffffffffc0200f0e:	846a                	mv	s0,s10
ffffffffc0200f10:	bfd9                	j	ffffffffc0200ee6 <vprintfmt+0x114>
ffffffffc0200f12:	4705                	li	a4,1
ffffffffc0200f14:	008a0593          	addi	a1,s4,8
ffffffffc0200f18:	01174463          	blt	a4,a7,ffffffffc0200f20 <vprintfmt+0x14e>
ffffffffc0200f1c:	1a088e63          	beqz	a7,ffffffffc02010d8 <vprintfmt+0x306>
ffffffffc0200f20:	000a3603          	ld	a2,0(s4)
ffffffffc0200f24:	46c1                	li	a3,16
ffffffffc0200f26:	8a2e                	mv	s4,a1
ffffffffc0200f28:	2781                	sext.w	a5,a5
ffffffffc0200f2a:	876e                	mv	a4,s11
ffffffffc0200f2c:	85a6                	mv	a1,s1
ffffffffc0200f2e:	854a                	mv	a0,s2
ffffffffc0200f30:	e37ff0ef          	jal	ra,ffffffffc0200d66 <printnum>
ffffffffc0200f34:	bde1                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc0200f36:	000a2503          	lw	a0,0(s4)
ffffffffc0200f3a:	85a6                	mv	a1,s1
ffffffffc0200f3c:	0a21                	addi	s4,s4,8
ffffffffc0200f3e:	9902                	jalr	s2
ffffffffc0200f40:	b5f1                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc0200f42:	4705                	li	a4,1
ffffffffc0200f44:	008a0593          	addi	a1,s4,8
ffffffffc0200f48:	01174463          	blt	a4,a7,ffffffffc0200f50 <vprintfmt+0x17e>
ffffffffc0200f4c:	18088163          	beqz	a7,ffffffffc02010ce <vprintfmt+0x2fc>
ffffffffc0200f50:	000a3603          	ld	a2,0(s4)
ffffffffc0200f54:	46a9                	li	a3,10
ffffffffc0200f56:	8a2e                	mv	s4,a1
ffffffffc0200f58:	bfc1                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc0200f5a:	00144603          	lbu	a2,1(s0)
ffffffffc0200f5e:	4c85                	li	s9,1
ffffffffc0200f60:	846a                	mv	s0,s10
ffffffffc0200f62:	bdf1                	j	ffffffffc0200e3e <vprintfmt+0x6c>
ffffffffc0200f64:	85a6                	mv	a1,s1
ffffffffc0200f66:	02500513          	li	a0,37
ffffffffc0200f6a:	9902                	jalr	s2
ffffffffc0200f6c:	b545                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc0200f6e:	00144603          	lbu	a2,1(s0)
ffffffffc0200f72:	2885                	addiw	a7,a7,1
ffffffffc0200f74:	846a                	mv	s0,s10
ffffffffc0200f76:	b5e1                	j	ffffffffc0200e3e <vprintfmt+0x6c>
ffffffffc0200f78:	4705                	li	a4,1
ffffffffc0200f7a:	008a0593          	addi	a1,s4,8
ffffffffc0200f7e:	01174463          	blt	a4,a7,ffffffffc0200f86 <vprintfmt+0x1b4>
ffffffffc0200f82:	14088163          	beqz	a7,ffffffffc02010c4 <vprintfmt+0x2f2>
ffffffffc0200f86:	000a3603          	ld	a2,0(s4)
ffffffffc0200f8a:	46a1                	li	a3,8
ffffffffc0200f8c:	8a2e                	mv	s4,a1
ffffffffc0200f8e:	bf69                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc0200f90:	03000513          	li	a0,48
ffffffffc0200f94:	85a6                	mv	a1,s1
ffffffffc0200f96:	e03e                	sd	a5,0(sp)
ffffffffc0200f98:	9902                	jalr	s2
ffffffffc0200f9a:	85a6                	mv	a1,s1
ffffffffc0200f9c:	07800513          	li	a0,120
ffffffffc0200fa0:	9902                	jalr	s2
ffffffffc0200fa2:	0a21                	addi	s4,s4,8
ffffffffc0200fa4:	6782                	ld	a5,0(sp)
ffffffffc0200fa6:	46c1                	li	a3,16
ffffffffc0200fa8:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0200fac:	bfb5                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc0200fae:	000a3403          	ld	s0,0(s4)
ffffffffc0200fb2:	008a0713          	addi	a4,s4,8
ffffffffc0200fb6:	e03a                	sd	a4,0(sp)
ffffffffc0200fb8:	14040263          	beqz	s0,ffffffffc02010fc <vprintfmt+0x32a>
ffffffffc0200fbc:	0fb05763          	blez	s11,ffffffffc02010aa <vprintfmt+0x2d8>
ffffffffc0200fc0:	02d00693          	li	a3,45
ffffffffc0200fc4:	0cd79163          	bne	a5,a3,ffffffffc0201086 <vprintfmt+0x2b4>
ffffffffc0200fc8:	00044783          	lbu	a5,0(s0)
ffffffffc0200fcc:	0007851b          	sext.w	a0,a5
ffffffffc0200fd0:	cf85                	beqz	a5,ffffffffc0201008 <vprintfmt+0x236>
ffffffffc0200fd2:	00140a13          	addi	s4,s0,1
ffffffffc0200fd6:	05e00413          	li	s0,94
ffffffffc0200fda:	000c4563          	bltz	s8,ffffffffc0200fe4 <vprintfmt+0x212>
ffffffffc0200fde:	3c7d                	addiw	s8,s8,-1
ffffffffc0200fe0:	036c0263          	beq	s8,s6,ffffffffc0201004 <vprintfmt+0x232>
ffffffffc0200fe4:	85a6                	mv	a1,s1
ffffffffc0200fe6:	0e0c8e63          	beqz	s9,ffffffffc02010e2 <vprintfmt+0x310>
ffffffffc0200fea:	3781                	addiw	a5,a5,-32
ffffffffc0200fec:	0ef47b63          	bgeu	s0,a5,ffffffffc02010e2 <vprintfmt+0x310>
ffffffffc0200ff0:	03f00513          	li	a0,63
ffffffffc0200ff4:	9902                	jalr	s2
ffffffffc0200ff6:	000a4783          	lbu	a5,0(s4)
ffffffffc0200ffa:	3dfd                	addiw	s11,s11,-1
ffffffffc0200ffc:	0a05                	addi	s4,s4,1
ffffffffc0200ffe:	0007851b          	sext.w	a0,a5
ffffffffc0201002:	ffe1                	bnez	a5,ffffffffc0200fda <vprintfmt+0x208>
ffffffffc0201004:	01b05963          	blez	s11,ffffffffc0201016 <vprintfmt+0x244>
ffffffffc0201008:	3dfd                	addiw	s11,s11,-1
ffffffffc020100a:	85a6                	mv	a1,s1
ffffffffc020100c:	02000513          	li	a0,32
ffffffffc0201010:	9902                	jalr	s2
ffffffffc0201012:	fe0d9be3          	bnez	s11,ffffffffc0201008 <vprintfmt+0x236>
ffffffffc0201016:	6a02                	ld	s4,0(sp)
ffffffffc0201018:	bbd5                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc020101a:	4705                	li	a4,1
ffffffffc020101c:	008a0c93          	addi	s9,s4,8
ffffffffc0201020:	01174463          	blt	a4,a7,ffffffffc0201028 <vprintfmt+0x256>
ffffffffc0201024:	08088d63          	beqz	a7,ffffffffc02010be <vprintfmt+0x2ec>
ffffffffc0201028:	000a3403          	ld	s0,0(s4)
ffffffffc020102c:	0a044d63          	bltz	s0,ffffffffc02010e6 <vprintfmt+0x314>
ffffffffc0201030:	8622                	mv	a2,s0
ffffffffc0201032:	8a66                	mv	s4,s9
ffffffffc0201034:	46a9                	li	a3,10
ffffffffc0201036:	bdcd                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc0201038:	000a2783          	lw	a5,0(s4)
ffffffffc020103c:	4719                	li	a4,6
ffffffffc020103e:	0a21                	addi	s4,s4,8
ffffffffc0201040:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201044:	8fb5                	xor	a5,a5,a3
ffffffffc0201046:	40d786bb          	subw	a3,a5,a3
ffffffffc020104a:	02d74163          	blt	a4,a3,ffffffffc020106c <vprintfmt+0x29a>
ffffffffc020104e:	00369793          	slli	a5,a3,0x3
ffffffffc0201052:	97de                	add	a5,a5,s7
ffffffffc0201054:	639c                	ld	a5,0(a5)
ffffffffc0201056:	cb99                	beqz	a5,ffffffffc020106c <vprintfmt+0x29a>
ffffffffc0201058:	86be                	mv	a3,a5
ffffffffc020105a:	00001617          	auipc	a2,0x1
ffffffffc020105e:	c2e60613          	addi	a2,a2,-978 # ffffffffc0201c88 <buddy_pmm_manager+0x190>
ffffffffc0201062:	85a6                	mv	a1,s1
ffffffffc0201064:	854a                	mv	a0,s2
ffffffffc0201066:	0ce000ef          	jal	ra,ffffffffc0201134 <printfmt>
ffffffffc020106a:	b34d                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc020106c:	00001617          	auipc	a2,0x1
ffffffffc0201070:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0201c78 <buddy_pmm_manager+0x180>
ffffffffc0201074:	85a6                	mv	a1,s1
ffffffffc0201076:	854a                	mv	a0,s2
ffffffffc0201078:	0bc000ef          	jal	ra,ffffffffc0201134 <printfmt>
ffffffffc020107c:	bb41                	j	ffffffffc0200e0c <vprintfmt+0x3a>
ffffffffc020107e:	00001417          	auipc	s0,0x1
ffffffffc0201082:	bf240413          	addi	s0,s0,-1038 # ffffffffc0201c70 <buddy_pmm_manager+0x178>
ffffffffc0201086:	85e2                	mv	a1,s8
ffffffffc0201088:	8522                	mv	a0,s0
ffffffffc020108a:	e43e                	sd	a5,8(sp)
ffffffffc020108c:	1cc000ef          	jal	ra,ffffffffc0201258 <strnlen>
ffffffffc0201090:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201094:	01b05b63          	blez	s11,ffffffffc02010aa <vprintfmt+0x2d8>
ffffffffc0201098:	67a2                	ld	a5,8(sp)
ffffffffc020109a:	00078a1b          	sext.w	s4,a5
ffffffffc020109e:	3dfd                	addiw	s11,s11,-1
ffffffffc02010a0:	85a6                	mv	a1,s1
ffffffffc02010a2:	8552                	mv	a0,s4
ffffffffc02010a4:	9902                	jalr	s2
ffffffffc02010a6:	fe0d9ce3          	bnez	s11,ffffffffc020109e <vprintfmt+0x2cc>
ffffffffc02010aa:	00044783          	lbu	a5,0(s0)
ffffffffc02010ae:	00140a13          	addi	s4,s0,1
ffffffffc02010b2:	0007851b          	sext.w	a0,a5
ffffffffc02010b6:	d3a5                	beqz	a5,ffffffffc0201016 <vprintfmt+0x244>
ffffffffc02010b8:	05e00413          	li	s0,94
ffffffffc02010bc:	bf39                	j	ffffffffc0200fda <vprintfmt+0x208>
ffffffffc02010be:	000a2403          	lw	s0,0(s4)
ffffffffc02010c2:	b7ad                	j	ffffffffc020102c <vprintfmt+0x25a>
ffffffffc02010c4:	000a6603          	lwu	a2,0(s4)
ffffffffc02010c8:	46a1                	li	a3,8
ffffffffc02010ca:	8a2e                	mv	s4,a1
ffffffffc02010cc:	bdb1                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc02010ce:	000a6603          	lwu	a2,0(s4)
ffffffffc02010d2:	46a9                	li	a3,10
ffffffffc02010d4:	8a2e                	mv	s4,a1
ffffffffc02010d6:	bd89                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc02010d8:	000a6603          	lwu	a2,0(s4)
ffffffffc02010dc:	46c1                	li	a3,16
ffffffffc02010de:	8a2e                	mv	s4,a1
ffffffffc02010e0:	b5a1                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc02010e2:	9902                	jalr	s2
ffffffffc02010e4:	bf09                	j	ffffffffc0200ff6 <vprintfmt+0x224>
ffffffffc02010e6:	85a6                	mv	a1,s1
ffffffffc02010e8:	02d00513          	li	a0,45
ffffffffc02010ec:	e03e                	sd	a5,0(sp)
ffffffffc02010ee:	9902                	jalr	s2
ffffffffc02010f0:	6782                	ld	a5,0(sp)
ffffffffc02010f2:	8a66                	mv	s4,s9
ffffffffc02010f4:	40800633          	neg	a2,s0
ffffffffc02010f8:	46a9                	li	a3,10
ffffffffc02010fa:	b53d                	j	ffffffffc0200f28 <vprintfmt+0x156>
ffffffffc02010fc:	03b05163          	blez	s11,ffffffffc020111e <vprintfmt+0x34c>
ffffffffc0201100:	02d00693          	li	a3,45
ffffffffc0201104:	f6d79de3          	bne	a5,a3,ffffffffc020107e <vprintfmt+0x2ac>
ffffffffc0201108:	00001417          	auipc	s0,0x1
ffffffffc020110c:	b6840413          	addi	s0,s0,-1176 # ffffffffc0201c70 <buddy_pmm_manager+0x178>
ffffffffc0201110:	02800793          	li	a5,40
ffffffffc0201114:	02800513          	li	a0,40
ffffffffc0201118:	00140a13          	addi	s4,s0,1
ffffffffc020111c:	bd6d                	j	ffffffffc0200fd6 <vprintfmt+0x204>
ffffffffc020111e:	00001a17          	auipc	s4,0x1
ffffffffc0201122:	b53a0a13          	addi	s4,s4,-1197 # ffffffffc0201c71 <buddy_pmm_manager+0x179>
ffffffffc0201126:	02800513          	li	a0,40
ffffffffc020112a:	02800793          	li	a5,40
ffffffffc020112e:	05e00413          	li	s0,94
ffffffffc0201132:	b565                	j	ffffffffc0200fda <vprintfmt+0x208>

ffffffffc0201134 <printfmt>:
ffffffffc0201134:	715d                	addi	sp,sp,-80
ffffffffc0201136:	02810313          	addi	t1,sp,40
ffffffffc020113a:	f436                	sd	a3,40(sp)
ffffffffc020113c:	869a                	mv	a3,t1
ffffffffc020113e:	ec06                	sd	ra,24(sp)
ffffffffc0201140:	f83a                	sd	a4,48(sp)
ffffffffc0201142:	fc3e                	sd	a5,56(sp)
ffffffffc0201144:	e0c2                	sd	a6,64(sp)
ffffffffc0201146:	e4c6                	sd	a7,72(sp)
ffffffffc0201148:	e41a                	sd	t1,8(sp)
ffffffffc020114a:	c89ff0ef          	jal	ra,ffffffffc0200dd2 <vprintfmt>
ffffffffc020114e:	60e2                	ld	ra,24(sp)
ffffffffc0201150:	6161                	addi	sp,sp,80
ffffffffc0201152:	8082                	ret

ffffffffc0201154 <readline>:
ffffffffc0201154:	715d                	addi	sp,sp,-80
ffffffffc0201156:	e486                	sd	ra,72(sp)
ffffffffc0201158:	e0a6                	sd	s1,64(sp)
ffffffffc020115a:	fc4a                	sd	s2,56(sp)
ffffffffc020115c:	f84e                	sd	s3,48(sp)
ffffffffc020115e:	f452                	sd	s4,40(sp)
ffffffffc0201160:	f056                	sd	s5,32(sp)
ffffffffc0201162:	ec5a                	sd	s6,24(sp)
ffffffffc0201164:	e85e                	sd	s7,16(sp)
ffffffffc0201166:	c901                	beqz	a0,ffffffffc0201176 <readline+0x22>
ffffffffc0201168:	85aa                	mv	a1,a0
ffffffffc020116a:	00001517          	auipc	a0,0x1
ffffffffc020116e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0201c88 <buddy_pmm_manager+0x190>
ffffffffc0201172:	f41fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0201176:	4481                	li	s1,0
ffffffffc0201178:	497d                	li	s2,31
ffffffffc020117a:	49a1                	li	s3,8
ffffffffc020117c:	4aa9                	li	s5,10
ffffffffc020117e:	4b35                	li	s6,13
ffffffffc0201180:	00004b97          	auipc	s7,0x4
ffffffffc0201184:	f98b8b93          	addi	s7,s7,-104 # ffffffffc0205118 <buf>
ffffffffc0201188:	3fe00a13          	li	s4,1022
ffffffffc020118c:	f9ffe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201190:	00054a63          	bltz	a0,ffffffffc02011a4 <readline+0x50>
ffffffffc0201194:	00a95a63          	bge	s2,a0,ffffffffc02011a8 <readline+0x54>
ffffffffc0201198:	029a5263          	bge	s4,s1,ffffffffc02011bc <readline+0x68>
ffffffffc020119c:	f8ffe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc02011a0:	fe055ae3          	bgez	a0,ffffffffc0201194 <readline+0x40>
ffffffffc02011a4:	4501                	li	a0,0
ffffffffc02011a6:	a091                	j	ffffffffc02011ea <readline+0x96>
ffffffffc02011a8:	03351463          	bne	a0,s3,ffffffffc02011d0 <readline+0x7c>
ffffffffc02011ac:	e8a9                	bnez	s1,ffffffffc02011fe <readline+0xaa>
ffffffffc02011ae:	f7dfe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc02011b2:	fe0549e3          	bltz	a0,ffffffffc02011a4 <readline+0x50>
ffffffffc02011b6:	fea959e3          	bge	s2,a0,ffffffffc02011a8 <readline+0x54>
ffffffffc02011ba:	4481                	li	s1,0
ffffffffc02011bc:	e42a                	sd	a0,8(sp)
ffffffffc02011be:	f2bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc02011c2:	6522                	ld	a0,8(sp)
ffffffffc02011c4:	009b87b3          	add	a5,s7,s1
ffffffffc02011c8:	2485                	addiw	s1,s1,1
ffffffffc02011ca:	00a78023          	sb	a0,0(a5)
ffffffffc02011ce:	bf7d                	j	ffffffffc020118c <readline+0x38>
ffffffffc02011d0:	01550463          	beq	a0,s5,ffffffffc02011d8 <readline+0x84>
ffffffffc02011d4:	fb651ce3          	bne	a0,s6,ffffffffc020118c <readline+0x38>
ffffffffc02011d8:	f11fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	f3c50513          	addi	a0,a0,-196 # ffffffffc0205118 <buf>
ffffffffc02011e4:	94aa                	add	s1,s1,a0
ffffffffc02011e6:	00048023          	sb	zero,0(s1)
ffffffffc02011ea:	60a6                	ld	ra,72(sp)
ffffffffc02011ec:	6486                	ld	s1,64(sp)
ffffffffc02011ee:	7962                	ld	s2,56(sp)
ffffffffc02011f0:	79c2                	ld	s3,48(sp)
ffffffffc02011f2:	7a22                	ld	s4,40(sp)
ffffffffc02011f4:	7a82                	ld	s5,32(sp)
ffffffffc02011f6:	6b62                	ld	s6,24(sp)
ffffffffc02011f8:	6bc2                	ld	s7,16(sp)
ffffffffc02011fa:	6161                	addi	sp,sp,80
ffffffffc02011fc:	8082                	ret
ffffffffc02011fe:	4521                	li	a0,8
ffffffffc0201200:	ee9fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201204:	34fd                	addiw	s1,s1,-1
ffffffffc0201206:	b759                	j	ffffffffc020118c <readline+0x38>

ffffffffc0201208 <sbi_console_putchar>:
ffffffffc0201208:	4781                	li	a5,0
ffffffffc020120a:	00004717          	auipc	a4,0x4
ffffffffc020120e:	dfe73703          	ld	a4,-514(a4) # ffffffffc0205008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201212:	88ba                	mv	a7,a4
ffffffffc0201214:	852a                	mv	a0,a0
ffffffffc0201216:	85be                	mv	a1,a5
ffffffffc0201218:	863e                	mv	a2,a5
ffffffffc020121a:	00000073          	ecall
ffffffffc020121e:	87aa                	mv	a5,a0
ffffffffc0201220:	8082                	ret

ffffffffc0201222 <sbi_set_timer>:
ffffffffc0201222:	4781                	li	a5,0
ffffffffc0201224:	00004717          	auipc	a4,0x4
ffffffffc0201228:	33473703          	ld	a4,820(a4) # ffffffffc0205558 <SBI_SET_TIMER>
ffffffffc020122c:	88ba                	mv	a7,a4
ffffffffc020122e:	852a                	mv	a0,a0
ffffffffc0201230:	85be                	mv	a1,a5
ffffffffc0201232:	863e                	mv	a2,a5
ffffffffc0201234:	00000073          	ecall
ffffffffc0201238:	87aa                	mv	a5,a0
ffffffffc020123a:	8082                	ret

ffffffffc020123c <sbi_console_getchar>:
ffffffffc020123c:	4501                	li	a0,0
ffffffffc020123e:	00004797          	auipc	a5,0x4
ffffffffc0201242:	dc27b783          	ld	a5,-574(a5) # ffffffffc0205000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201246:	88be                	mv	a7,a5
ffffffffc0201248:	852a                	mv	a0,a0
ffffffffc020124a:	85aa                	mv	a1,a0
ffffffffc020124c:	862a                	mv	a2,a0
ffffffffc020124e:	00000073          	ecall
ffffffffc0201252:	852a                	mv	a0,a0
ffffffffc0201254:	2501                	sext.w	a0,a0
ffffffffc0201256:	8082                	ret

ffffffffc0201258 <strnlen>:
ffffffffc0201258:	4781                	li	a5,0
ffffffffc020125a:	e589                	bnez	a1,ffffffffc0201264 <strnlen+0xc>
ffffffffc020125c:	a811                	j	ffffffffc0201270 <strnlen+0x18>
ffffffffc020125e:	0785                	addi	a5,a5,1
ffffffffc0201260:	00f58863          	beq	a1,a5,ffffffffc0201270 <strnlen+0x18>
ffffffffc0201264:	00f50733          	add	a4,a0,a5
ffffffffc0201268:	00074703          	lbu	a4,0(a4)
ffffffffc020126c:	fb6d                	bnez	a4,ffffffffc020125e <strnlen+0x6>
ffffffffc020126e:	85be                	mv	a1,a5
ffffffffc0201270:	852e                	mv	a0,a1
ffffffffc0201272:	8082                	ret

ffffffffc0201274 <strcmp>:
ffffffffc0201274:	00054783          	lbu	a5,0(a0)
ffffffffc0201278:	0005c703          	lbu	a4,0(a1)
ffffffffc020127c:	cb89                	beqz	a5,ffffffffc020128e <strcmp+0x1a>
ffffffffc020127e:	0505                	addi	a0,a0,1
ffffffffc0201280:	0585                	addi	a1,a1,1
ffffffffc0201282:	fee789e3          	beq	a5,a4,ffffffffc0201274 <strcmp>
ffffffffc0201286:	0007851b          	sext.w	a0,a5
ffffffffc020128a:	9d19                	subw	a0,a0,a4
ffffffffc020128c:	8082                	ret
ffffffffc020128e:	4501                	li	a0,0
ffffffffc0201290:	bfed                	j	ffffffffc020128a <strcmp+0x16>

ffffffffc0201292 <strchr>:
ffffffffc0201292:	00054783          	lbu	a5,0(a0)
ffffffffc0201296:	c799                	beqz	a5,ffffffffc02012a4 <strchr+0x12>
ffffffffc0201298:	00f58763          	beq	a1,a5,ffffffffc02012a6 <strchr+0x14>
ffffffffc020129c:	00154783          	lbu	a5,1(a0)
ffffffffc02012a0:	0505                	addi	a0,a0,1
ffffffffc02012a2:	fbfd                	bnez	a5,ffffffffc0201298 <strchr+0x6>
ffffffffc02012a4:	4501                	li	a0,0
ffffffffc02012a6:	8082                	ret

ffffffffc02012a8 <memset>:
ffffffffc02012a8:	ca01                	beqz	a2,ffffffffc02012b8 <memset+0x10>
ffffffffc02012aa:	962a                	add	a2,a2,a0
ffffffffc02012ac:	87aa                	mv	a5,a0
ffffffffc02012ae:	0785                	addi	a5,a5,1
ffffffffc02012b0:	feb78fa3          	sb	a1,-1(a5)
ffffffffc02012b4:	fec79de3          	bne	a5,a2,ffffffffc02012ae <memset+0x6>
ffffffffc02012b8:	8082                	ret
