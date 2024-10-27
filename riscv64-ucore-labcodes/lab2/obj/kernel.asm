
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
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <buddy_s>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	51e60613          	addi	a2,a2,1310 # ffffffffc0206558 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	1e0010ef          	jal	ra,ffffffffc020122a <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	6de50513          	addi	a0,a0,1758 # ffffffffc0201730 <etext+0x2>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	138000ef          	jal	ra,ffffffffc0200196 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	019000ef          	jal	ra,ffffffffc020087e <pmm_init>

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
ffffffffc02000a6:	202010ef          	jal	ra,ffffffffc02012a8 <vprintfmt>
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
ffffffffc02000dc:	1cc010ef          	jal	ra,ffffffffc02012a8 <vprintfmt>
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

ffffffffc020013a <__panic>:
ffffffffc020013a:	00006317          	auipc	t1,0x6
ffffffffc020013e:	3d630313          	addi	t1,t1,982 # ffffffffc0206510 <is_panic>
ffffffffc0200142:	00032e03          	lw	t3,0(t1)
ffffffffc0200146:	715d                	addi	sp,sp,-80
ffffffffc0200148:	ec06                	sd	ra,24(sp)
ffffffffc020014a:	e822                	sd	s0,16(sp)
ffffffffc020014c:	f436                	sd	a3,40(sp)
ffffffffc020014e:	f83a                	sd	a4,48(sp)
ffffffffc0200150:	fc3e                	sd	a5,56(sp)
ffffffffc0200152:	e0c2                	sd	a6,64(sp)
ffffffffc0200154:	e4c6                	sd	a7,72(sp)
ffffffffc0200156:	020e1a63          	bnez	t3,ffffffffc020018a <__panic+0x50>
ffffffffc020015a:	4785                	li	a5,1
ffffffffc020015c:	00f32023          	sw	a5,0(t1)
ffffffffc0200160:	8432                	mv	s0,a2
ffffffffc0200162:	103c                	addi	a5,sp,40
ffffffffc0200164:	862e                	mv	a2,a1
ffffffffc0200166:	85aa                	mv	a1,a0
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	5e850513          	addi	a0,a0,1512 # ffffffffc0201750 <etext+0x22>
ffffffffc0200170:	e43e                	sd	a5,8(sp)
ffffffffc0200172:	f41ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200176:	65a2                	ld	a1,8(sp)
ffffffffc0200178:	8522                	mv	a0,s0
ffffffffc020017a:	f19ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201838 <etext+0x10a>
ffffffffc0200186:	f2dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020018a:	2d4000ef          	jal	ra,ffffffffc020045e <intr_disable>
ffffffffc020018e:	4501                	li	a0,0
ffffffffc0200190:	130000ef          	jal	ra,ffffffffc02002c0 <kmonitor>
ffffffffc0200194:	bfed                	j	ffffffffc020018e <__panic+0x54>

ffffffffc0200196 <print_kerninfo>:
ffffffffc0200196:	1141                	addi	sp,sp,-16
ffffffffc0200198:	00001517          	auipc	a0,0x1
ffffffffc020019c:	5d850513          	addi	a0,a0,1496 # ffffffffc0201770 <etext+0x42>
ffffffffc02001a0:	e406                	sd	ra,8(sp)
ffffffffc02001a2:	f11ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001a6:	00000597          	auipc	a1,0x0
ffffffffc02001aa:	e8c58593          	addi	a1,a1,-372 # ffffffffc0200032 <kern_init>
ffffffffc02001ae:	00001517          	auipc	a0,0x1
ffffffffc02001b2:	5e250513          	addi	a0,a0,1506 # ffffffffc0201790 <etext+0x62>
ffffffffc02001b6:	efdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001ba:	00001597          	auipc	a1,0x1
ffffffffc02001be:	57458593          	addi	a1,a1,1396 # ffffffffc020172e <etext>
ffffffffc02001c2:	00001517          	auipc	a0,0x1
ffffffffc02001c6:	5ee50513          	addi	a0,a0,1518 # ffffffffc02017b0 <etext+0x82>
ffffffffc02001ca:	ee9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001ce:	00006597          	auipc	a1,0x6
ffffffffc02001d2:	e4258593          	addi	a1,a1,-446 # ffffffffc0206010 <buddy_s>
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	5fa50513          	addi	a0,a0,1530 # ffffffffc02017d0 <etext+0xa2>
ffffffffc02001de:	ed5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001e2:	00006597          	auipc	a1,0x6
ffffffffc02001e6:	37658593          	addi	a1,a1,886 # ffffffffc0206558 <end>
ffffffffc02001ea:	00001517          	auipc	a0,0x1
ffffffffc02001ee:	60650513          	addi	a0,a0,1542 # ffffffffc02017f0 <etext+0xc2>
ffffffffc02001f2:	ec1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02001f6:	00006597          	auipc	a1,0x6
ffffffffc02001fa:	76158593          	addi	a1,a1,1889 # ffffffffc0206957 <end+0x3ff>
ffffffffc02001fe:	00000797          	auipc	a5,0x0
ffffffffc0200202:	e3478793          	addi	a5,a5,-460 # ffffffffc0200032 <kern_init>
ffffffffc0200206:	40f587b3          	sub	a5,a1,a5
ffffffffc020020a:	43f7d593          	srai	a1,a5,0x3f
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200214:	95be                	add	a1,a1,a5
ffffffffc0200216:	85a9                	srai	a1,a1,0xa
ffffffffc0200218:	00001517          	auipc	a0,0x1
ffffffffc020021c:	5f850513          	addi	a0,a0,1528 # ffffffffc0201810 <etext+0xe2>
ffffffffc0200220:	0141                	addi	sp,sp,16
ffffffffc0200222:	bd41                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200224 <print_stackframe>:
ffffffffc0200224:	1141                	addi	sp,sp,-16
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	61a60613          	addi	a2,a2,1562 # ffffffffc0201840 <etext+0x112>
ffffffffc020022e:	04e00593          	li	a1,78
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	62650513          	addi	a0,a0,1574 # ffffffffc0201858 <etext+0x12a>
ffffffffc020023a:	e406                	sd	ra,8(sp)
ffffffffc020023c:	effff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200240 <mon_help>:
ffffffffc0200240:	1141                	addi	sp,sp,-16
ffffffffc0200242:	00001617          	auipc	a2,0x1
ffffffffc0200246:	62e60613          	addi	a2,a2,1582 # ffffffffc0201870 <etext+0x142>
ffffffffc020024a:	00001597          	auipc	a1,0x1
ffffffffc020024e:	64658593          	addi	a1,a1,1606 # ffffffffc0201890 <etext+0x162>
ffffffffc0200252:	00001517          	auipc	a0,0x1
ffffffffc0200256:	64650513          	addi	a0,a0,1606 # ffffffffc0201898 <etext+0x16a>
ffffffffc020025a:	e406                	sd	ra,8(sp)
ffffffffc020025c:	e57ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200260:	00001617          	auipc	a2,0x1
ffffffffc0200264:	64860613          	addi	a2,a2,1608 # ffffffffc02018a8 <etext+0x17a>
ffffffffc0200268:	00001597          	auipc	a1,0x1
ffffffffc020026c:	66858593          	addi	a1,a1,1640 # ffffffffc02018d0 <etext+0x1a2>
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	62850513          	addi	a0,a0,1576 # ffffffffc0201898 <etext+0x16a>
ffffffffc0200278:	e3bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020027c:	00001617          	auipc	a2,0x1
ffffffffc0200280:	66460613          	addi	a2,a2,1636 # ffffffffc02018e0 <etext+0x1b2>
ffffffffc0200284:	00001597          	auipc	a1,0x1
ffffffffc0200288:	67c58593          	addi	a1,a1,1660 # ffffffffc0201900 <etext+0x1d2>
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	60c50513          	addi	a0,a0,1548 # ffffffffc0201898 <etext+0x16a>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <mon_kerninfo>:
ffffffffc02002a0:	1141                	addi	sp,sp,-16
ffffffffc02002a2:	e406                	sd	ra,8(sp)
ffffffffc02002a4:	ef3ff0ef          	jal	ra,ffffffffc0200196 <print_kerninfo>
ffffffffc02002a8:	60a2                	ld	ra,8(sp)
ffffffffc02002aa:	4501                	li	a0,0
ffffffffc02002ac:	0141                	addi	sp,sp,16
ffffffffc02002ae:	8082                	ret

ffffffffc02002b0 <mon_backtrace>:
ffffffffc02002b0:	1141                	addi	sp,sp,-16
ffffffffc02002b2:	e406                	sd	ra,8(sp)
ffffffffc02002b4:	f71ff0ef          	jal	ra,ffffffffc0200224 <print_stackframe>
ffffffffc02002b8:	60a2                	ld	ra,8(sp)
ffffffffc02002ba:	4501                	li	a0,0
ffffffffc02002bc:	0141                	addi	sp,sp,16
ffffffffc02002be:	8082                	ret

ffffffffc02002c0 <kmonitor>:
ffffffffc02002c0:	7115                	addi	sp,sp,-224
ffffffffc02002c2:	ed5e                	sd	s7,152(sp)
ffffffffc02002c4:	8baa                	mv	s7,a0
ffffffffc02002c6:	00001517          	auipc	a0,0x1
ffffffffc02002ca:	64a50513          	addi	a0,a0,1610 # ffffffffc0201910 <etext+0x1e2>
ffffffffc02002ce:	ed86                	sd	ra,216(sp)
ffffffffc02002d0:	e9a2                	sd	s0,208(sp)
ffffffffc02002d2:	e5a6                	sd	s1,200(sp)
ffffffffc02002d4:	e1ca                	sd	s2,192(sp)
ffffffffc02002d6:	fd4e                	sd	s3,184(sp)
ffffffffc02002d8:	f952                	sd	s4,176(sp)
ffffffffc02002da:	f556                	sd	s5,168(sp)
ffffffffc02002dc:	f15a                	sd	s6,160(sp)
ffffffffc02002de:	e962                	sd	s8,144(sp)
ffffffffc02002e0:	e566                	sd	s9,136(sp)
ffffffffc02002e2:	e16a                	sd	s10,128(sp)
ffffffffc02002e4:	dcfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02002e8:	00001517          	auipc	a0,0x1
ffffffffc02002ec:	65050513          	addi	a0,a0,1616 # ffffffffc0201938 <etext+0x20a>
ffffffffc02002f0:	dc3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02002f4:	000b8563          	beqz	s7,ffffffffc02002fe <kmonitor+0x3e>
ffffffffc02002f8:	855e                	mv	a0,s7
ffffffffc02002fa:	348000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002fe:	00001c17          	auipc	s8,0x1
ffffffffc0200302:	6aac0c13          	addi	s8,s8,1706 # ffffffffc02019a8 <commands>
ffffffffc0200306:	00001917          	auipc	s2,0x1
ffffffffc020030a:	65a90913          	addi	s2,s2,1626 # ffffffffc0201960 <etext+0x232>
ffffffffc020030e:	00001497          	auipc	s1,0x1
ffffffffc0200312:	65a48493          	addi	s1,s1,1626 # ffffffffc0201968 <etext+0x23a>
ffffffffc0200316:	49bd                	li	s3,15
ffffffffc0200318:	00001b17          	auipc	s6,0x1
ffffffffc020031c:	658b0b13          	addi	s6,s6,1624 # ffffffffc0201970 <etext+0x242>
ffffffffc0200320:	00001a17          	auipc	s4,0x1
ffffffffc0200324:	570a0a13          	addi	s4,s4,1392 # ffffffffc0201890 <etext+0x162>
ffffffffc0200328:	4a8d                	li	s5,3
ffffffffc020032a:	854a                	mv	a0,s2
ffffffffc020032c:	2fe010ef          	jal	ra,ffffffffc020162a <readline>
ffffffffc0200330:	842a                	mv	s0,a0
ffffffffc0200332:	dd65                	beqz	a0,ffffffffc020032a <kmonitor+0x6a>
ffffffffc0200334:	00054583          	lbu	a1,0(a0)
ffffffffc0200338:	4c81                	li	s9,0
ffffffffc020033a:	e1bd                	bnez	a1,ffffffffc02003a0 <kmonitor+0xe0>
ffffffffc020033c:	fe0c87e3          	beqz	s9,ffffffffc020032a <kmonitor+0x6a>
ffffffffc0200340:	6582                	ld	a1,0(sp)
ffffffffc0200342:	00001d17          	auipc	s10,0x1
ffffffffc0200346:	666d0d13          	addi	s10,s10,1638 # ffffffffc02019a8 <commands>
ffffffffc020034a:	8552                	mv	a0,s4
ffffffffc020034c:	4401                	li	s0,0
ffffffffc020034e:	0d61                	addi	s10,s10,24
ffffffffc0200350:	6a7000ef          	jal	ra,ffffffffc02011f6 <strcmp>
ffffffffc0200354:	c919                	beqz	a0,ffffffffc020036a <kmonitor+0xaa>
ffffffffc0200356:	2405                	addiw	s0,s0,1
ffffffffc0200358:	0b540063          	beq	s0,s5,ffffffffc02003f8 <kmonitor+0x138>
ffffffffc020035c:	000d3503          	ld	a0,0(s10)
ffffffffc0200360:	6582                	ld	a1,0(sp)
ffffffffc0200362:	0d61                	addi	s10,s10,24
ffffffffc0200364:	693000ef          	jal	ra,ffffffffc02011f6 <strcmp>
ffffffffc0200368:	f57d                	bnez	a0,ffffffffc0200356 <kmonitor+0x96>
ffffffffc020036a:	00141793          	slli	a5,s0,0x1
ffffffffc020036e:	97a2                	add	a5,a5,s0
ffffffffc0200370:	078e                	slli	a5,a5,0x3
ffffffffc0200372:	97e2                	add	a5,a5,s8
ffffffffc0200374:	6b9c                	ld	a5,16(a5)
ffffffffc0200376:	865e                	mv	a2,s7
ffffffffc0200378:	002c                	addi	a1,sp,8
ffffffffc020037a:	fffc851b          	addiw	a0,s9,-1
ffffffffc020037e:	9782                	jalr	a5
ffffffffc0200380:	fa0555e3          	bgez	a0,ffffffffc020032a <kmonitor+0x6a>
ffffffffc0200384:	60ee                	ld	ra,216(sp)
ffffffffc0200386:	644e                	ld	s0,208(sp)
ffffffffc0200388:	64ae                	ld	s1,200(sp)
ffffffffc020038a:	690e                	ld	s2,192(sp)
ffffffffc020038c:	79ea                	ld	s3,184(sp)
ffffffffc020038e:	7a4a                	ld	s4,176(sp)
ffffffffc0200390:	7aaa                	ld	s5,168(sp)
ffffffffc0200392:	7b0a                	ld	s6,160(sp)
ffffffffc0200394:	6bea                	ld	s7,152(sp)
ffffffffc0200396:	6c4a                	ld	s8,144(sp)
ffffffffc0200398:	6caa                	ld	s9,136(sp)
ffffffffc020039a:	6d0a                	ld	s10,128(sp)
ffffffffc020039c:	612d                	addi	sp,sp,224
ffffffffc020039e:	8082                	ret
ffffffffc02003a0:	8526                	mv	a0,s1
ffffffffc02003a2:	673000ef          	jal	ra,ffffffffc0201214 <strchr>
ffffffffc02003a6:	c901                	beqz	a0,ffffffffc02003b6 <kmonitor+0xf6>
ffffffffc02003a8:	00144583          	lbu	a1,1(s0)
ffffffffc02003ac:	00040023          	sb	zero,0(s0)
ffffffffc02003b0:	0405                	addi	s0,s0,1
ffffffffc02003b2:	d5c9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003b4:	b7f5                	j	ffffffffc02003a0 <kmonitor+0xe0>
ffffffffc02003b6:	00044783          	lbu	a5,0(s0)
ffffffffc02003ba:	d3c9                	beqz	a5,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003bc:	033c8963          	beq	s9,s3,ffffffffc02003ee <kmonitor+0x12e>
ffffffffc02003c0:	003c9793          	slli	a5,s9,0x3
ffffffffc02003c4:	0118                	addi	a4,sp,128
ffffffffc02003c6:	97ba                	add	a5,a5,a4
ffffffffc02003c8:	f887b023          	sd	s0,-128(a5)
ffffffffc02003cc:	00044583          	lbu	a1,0(s0)
ffffffffc02003d0:	2c85                	addiw	s9,s9,1
ffffffffc02003d2:	e591                	bnez	a1,ffffffffc02003de <kmonitor+0x11e>
ffffffffc02003d4:	b7b5                	j	ffffffffc0200340 <kmonitor+0x80>
ffffffffc02003d6:	00144583          	lbu	a1,1(s0)
ffffffffc02003da:	0405                	addi	s0,s0,1
ffffffffc02003dc:	d1a5                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003de:	8526                	mv	a0,s1
ffffffffc02003e0:	635000ef          	jal	ra,ffffffffc0201214 <strchr>
ffffffffc02003e4:	d96d                	beqz	a0,ffffffffc02003d6 <kmonitor+0x116>
ffffffffc02003e6:	00044583          	lbu	a1,0(s0)
ffffffffc02003ea:	d9a9                	beqz	a1,ffffffffc020033c <kmonitor+0x7c>
ffffffffc02003ec:	bf55                	j	ffffffffc02003a0 <kmonitor+0xe0>
ffffffffc02003ee:	45c1                	li	a1,16
ffffffffc02003f0:	855a                	mv	a0,s6
ffffffffc02003f2:	cc1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc02003f6:	b7e9                	j	ffffffffc02003c0 <kmonitor+0x100>
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	00001517          	auipc	a0,0x1
ffffffffc02003fe:	59650513          	addi	a0,a0,1430 # ffffffffc0201990 <etext+0x262>
ffffffffc0200402:	cb1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200406:	b715                	j	ffffffffc020032a <kmonitor+0x6a>

ffffffffc0200408 <clock_init>:
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200414:	c0102573          	rdtime	a0
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	2d8010ef          	jal	ra,ffffffffc02016f8 <sbi_set_timer>
ffffffffc0200424:	60a2                	ld	ra,8(sp)
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0e07b923          	sd	zero,242(a5) # ffffffffc0206518 <ticks>
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	5c250513          	addi	a0,a0,1474 # ffffffffc02019f0 <commands+0x48>
ffffffffc0200436:	0141                	addi	sp,sp,16
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
ffffffffc020043a:	c0102573          	rdtime	a0
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	2b20106f          	j	ffffffffc02016f8 <sbi_set_timer>

ffffffffc020044a <cons_init>:
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	28e0106f          	j	ffffffffc02016de <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
ffffffffc0200454:	2be0106f          	j	ffffffffc0201712 <sbi_console_getchar>

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
ffffffffc0200482:	59250513          	addi	a0,a0,1426 # ffffffffc0201a10 <commands+0x68>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	59a50513          	addi	a0,a0,1434 # ffffffffc0201a28 <commands+0x80>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	5a450513          	addi	a0,a0,1444 # ffffffffc0201a40 <commands+0x98>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201a58 <commands+0xb0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	5b850513          	addi	a0,a0,1464 # ffffffffc0201a70 <commands+0xc8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	5c250513          	addi	a0,a0,1474 # ffffffffc0201a88 <commands+0xe0>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0201aa0 <commands+0xf8>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	5d650513          	addi	a0,a0,1494 # ffffffffc0201ab8 <commands+0x110>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	5e050513          	addi	a0,a0,1504 # ffffffffc0201ad0 <commands+0x128>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	5ea50513          	addi	a0,a0,1514 # ffffffffc0201ae8 <commands+0x140>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	5f450513          	addi	a0,a0,1524 # ffffffffc0201b00 <commands+0x158>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0201b18 <commands+0x170>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	60850513          	addi	a0,a0,1544 # ffffffffc0201b30 <commands+0x188>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	61250513          	addi	a0,a0,1554 # ffffffffc0201b48 <commands+0x1a0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	61c50513          	addi	a0,a0,1564 # ffffffffc0201b60 <commands+0x1b8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	62650513          	addi	a0,a0,1574 # ffffffffc0201b78 <commands+0x1d0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	63050513          	addi	a0,a0,1584 # ffffffffc0201b90 <commands+0x1e8>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	63a50513          	addi	a0,a0,1594 # ffffffffc0201ba8 <commands+0x200>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	64450513          	addi	a0,a0,1604 # ffffffffc0201bc0 <commands+0x218>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	64e50513          	addi	a0,a0,1614 # ffffffffc0201bd8 <commands+0x230>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	65850513          	addi	a0,a0,1624 # ffffffffc0201bf0 <commands+0x248>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	66250513          	addi	a0,a0,1634 # ffffffffc0201c08 <commands+0x260>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	66c50513          	addi	a0,a0,1644 # ffffffffc0201c20 <commands+0x278>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	67650513          	addi	a0,a0,1654 # ffffffffc0201c38 <commands+0x290>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	68050513          	addi	a0,a0,1664 # ffffffffc0201c50 <commands+0x2a8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	68a50513          	addi	a0,a0,1674 # ffffffffc0201c68 <commands+0x2c0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	69450513          	addi	a0,a0,1684 # ffffffffc0201c80 <commands+0x2d8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	69e50513          	addi	a0,a0,1694 # ffffffffc0201c98 <commands+0x2f0>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	6a850513          	addi	a0,a0,1704 # ffffffffc0201cb0 <commands+0x308>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	6b250513          	addi	a0,a0,1714 # ffffffffc0201cc8 <commands+0x320>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	6bc50513          	addi	a0,a0,1724 # ffffffffc0201ce0 <commands+0x338>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	6c250513          	addi	a0,a0,1730 # ffffffffc0201cf8 <commands+0x350>
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
ffffffffc020064e:	6c650513          	addi	a0,a0,1734 # ffffffffc0201d10 <commands+0x368>
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
ffffffffc0200666:	6c650513          	addi	a0,a0,1734 # ffffffffc0201d28 <commands+0x380>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	6ce50513          	addi	a0,a0,1742 # ffffffffc0201d40 <commands+0x398>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	6d650513          	addi	a0,a0,1750 # ffffffffc0201d58 <commands+0x3b0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	6da50513          	addi	a0,a0,1754 # ffffffffc0201d70 <commands+0x3c8>
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
ffffffffc02006b4:	7a070713          	addi	a4,a4,1952 # ffffffffc0201e50 <commands+0x4a8>
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
ffffffffc02006c6:	72650513          	addi	a0,a0,1830 # ffffffffc0201de8 <commands+0x440>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	6fc50513          	addi	a0,a0,1788 # ffffffffc0201dc8 <commands+0x420>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	6b250513          	addi	a0,a0,1714 # ffffffffc0201d88 <commands+0x3e0>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	72850513          	addi	a0,a0,1832 # ffffffffc0201e08 <commands+0x460>
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
ffffffffc0200714:	72050513          	addi	a0,a0,1824 # ffffffffc0201e30 <commands+0x488>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	68e50513          	addi	a0,a0,1678 # ffffffffc0201da8 <commands+0x400>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	6f450513          	addi	a0,a0,1780 # ffffffffc0201e20 <commands+0x478>
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

ffffffffc0200802 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200802:	100027f3          	csrr	a5,sstatus
ffffffffc0200806:	8b89                	andi	a5,a5,2
ffffffffc0200808:	e799                	bnez	a5,ffffffffc0200816 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020080a:	00006797          	auipc	a5,0x6
ffffffffc020080e:	d267b783          	ld	a5,-730(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0200812:	6f9c                	ld	a5,24(a5)
ffffffffc0200814:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200816:	1141                	addi	sp,sp,-16
ffffffffc0200818:	e406                	sd	ra,8(sp)
ffffffffc020081a:	e022                	sd	s0,0(sp)
ffffffffc020081c:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020081e:	c41ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200822:	00006797          	auipc	a5,0x6
ffffffffc0200826:	d0e7b783          	ld	a5,-754(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc020082a:	6f9c                	ld	a5,24(a5)
ffffffffc020082c:	8522                	mv	a0,s0
ffffffffc020082e:	9782                	jalr	a5
ffffffffc0200830:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200832:	c27ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200836:	60a2                	ld	ra,8(sp)
ffffffffc0200838:	8522                	mv	a0,s0
ffffffffc020083a:	6402                	ld	s0,0(sp)
ffffffffc020083c:	0141                	addi	sp,sp,16
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200840:	100027f3          	csrr	a5,sstatus
ffffffffc0200844:	8b89                	andi	a5,a5,2
ffffffffc0200846:	e799                	bnez	a5,ffffffffc0200854 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200848:	00006797          	auipc	a5,0x6
ffffffffc020084c:	ce87b783          	ld	a5,-792(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0200850:	739c                	ld	a5,32(a5)
ffffffffc0200852:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200854:	1101                	addi	sp,sp,-32
ffffffffc0200856:	ec06                	sd	ra,24(sp)
ffffffffc0200858:	e822                	sd	s0,16(sp)
ffffffffc020085a:	e426                	sd	s1,8(sp)
ffffffffc020085c:	842a                	mv	s0,a0
ffffffffc020085e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200860:	bffff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200864:	00006797          	auipc	a5,0x6
ffffffffc0200868:	ccc7b783          	ld	a5,-820(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc020086c:	739c                	ld	a5,32(a5)
ffffffffc020086e:	85a6                	mv	a1,s1
ffffffffc0200870:	8522                	mv	a0,s0
ffffffffc0200872:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200874:	6442                	ld	s0,16(sp)
ffffffffc0200876:	60e2                	ld	ra,24(sp)
ffffffffc0200878:	64a2                	ld	s1,8(sp)
ffffffffc020087a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020087c:	bef1                	j	ffffffffc0200458 <intr_enable>

ffffffffc020087e <pmm_init>:
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc020087e:	00002797          	auipc	a5,0x2
ffffffffc0200882:	afa78793          	addi	a5,a5,-1286 # ffffffffc0202378 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200886:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020088c:	00001517          	auipc	a0,0x1
ffffffffc0200890:	5f450513          	addi	a0,a0,1524 # ffffffffc0201e80 <commands+0x4d8>
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc0200894:	00006497          	auipc	s1,0x6
ffffffffc0200898:	c9c48493          	addi	s1,s1,-868 # ffffffffc0206530 <pmm_manager>
void pmm_init(void) {
ffffffffc020089c:	ec06                	sd	ra,24(sp)
ffffffffc020089e:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc02008a0:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02008a2:	811ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02008a6:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008a8:	00006417          	auipc	s0,0x6
ffffffffc02008ac:	ca040413          	addi	s0,s0,-864 # ffffffffc0206548 <va_pa_offset>
    pmm_manager->init();
ffffffffc02008b0:	679c                	ld	a5,8(a5)
ffffffffc02008b2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008b4:	57f5                	li	a5,-3
ffffffffc02008b6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02008b8:	00001517          	auipc	a0,0x1
ffffffffc02008bc:	5e050513          	addi	a0,a0,1504 # ffffffffc0201e98 <commands+0x4f0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02008c0:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02008c2:	ff0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02008c6:	46c5                	li	a3,17
ffffffffc02008c8:	06ee                	slli	a3,a3,0x1b
ffffffffc02008ca:	40100613          	li	a2,1025
ffffffffc02008ce:	16fd                	addi	a3,a3,-1
ffffffffc02008d0:	07e005b7          	lui	a1,0x7e00
ffffffffc02008d4:	0656                	slli	a2,a2,0x15
ffffffffc02008d6:	00001517          	auipc	a0,0x1
ffffffffc02008da:	5da50513          	addi	a0,a0,1498 # ffffffffc0201eb0 <commands+0x508>
ffffffffc02008de:	fd4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02008e2:	777d                	lui	a4,0xfffff
ffffffffc02008e4:	00007797          	auipc	a5,0x7
ffffffffc02008e8:	c7378793          	addi	a5,a5,-909 # ffffffffc0207557 <end+0xfff>
ffffffffc02008ec:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02008ee:	00006517          	auipc	a0,0x6
ffffffffc02008f2:	c3250513          	addi	a0,a0,-974 # ffffffffc0206520 <npage>
ffffffffc02008f6:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02008fa:	00006597          	auipc	a1,0x6
ffffffffc02008fe:	c2e58593          	addi	a1,a1,-978 # ffffffffc0206528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200902:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200904:	e19c                	sd	a5,0(a1)
ffffffffc0200906:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200908:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020090a:	4885                	li	a7,1
ffffffffc020090c:	fff80837          	lui	a6,0xfff80
ffffffffc0200910:	a011                	j	ffffffffc0200914 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200912:	619c                	ld	a5,0(a1)
ffffffffc0200914:	97b6                	add	a5,a5,a3
ffffffffc0200916:	07a1                	addi	a5,a5,8
ffffffffc0200918:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020091c:	611c                	ld	a5,0(a0)
ffffffffc020091e:	0705                	addi	a4,a4,1
ffffffffc0200920:	02868693          	addi	a3,a3,40
ffffffffc0200924:	01078633          	add	a2,a5,a6
ffffffffc0200928:	fec765e3          	bltu	a4,a2,ffffffffc0200912 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020092c:	6190                	ld	a2,0(a1)
ffffffffc020092e:	00279713          	slli	a4,a5,0x2
ffffffffc0200932:	973e                	add	a4,a4,a5
ffffffffc0200934:	fec006b7          	lui	a3,0xfec00
ffffffffc0200938:	070e                	slli	a4,a4,0x3
ffffffffc020093a:	96b2                	add	a3,a3,a2
ffffffffc020093c:	96ba                	add	a3,a3,a4
ffffffffc020093e:	c0200737          	lui	a4,0xc0200
ffffffffc0200942:	08e6ef63          	bltu	a3,a4,ffffffffc02009e0 <pmm_init+0x162>
ffffffffc0200946:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200948:	45c5                	li	a1,17
ffffffffc020094a:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020094c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020094e:	04b6e863          	bltu	a3,a1,ffffffffc020099e <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200952:	609c                	ld	a5,0(s1)
ffffffffc0200954:	7b9c                	ld	a5,48(a5)
ffffffffc0200956:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200958:	00001517          	auipc	a0,0x1
ffffffffc020095c:	5f050513          	addi	a0,a0,1520 # ffffffffc0201f48 <commands+0x5a0>
ffffffffc0200960:	f52ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200964:	00004597          	auipc	a1,0x4
ffffffffc0200968:	69c58593          	addi	a1,a1,1692 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020096c:	00006797          	auipc	a5,0x6
ffffffffc0200970:	bcb7ba23          	sd	a1,-1068(a5) # ffffffffc0206540 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200974:	c02007b7          	lui	a5,0xc0200
ffffffffc0200978:	08f5e063          	bltu	a1,a5,ffffffffc02009f8 <pmm_init+0x17a>
ffffffffc020097c:	6010                	ld	a2,0(s0)
}
ffffffffc020097e:	6442                	ld	s0,16(sp)
ffffffffc0200980:	60e2                	ld	ra,24(sp)
ffffffffc0200982:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200984:	40c58633          	sub	a2,a1,a2
ffffffffc0200988:	00006797          	auipc	a5,0x6
ffffffffc020098c:	bac7b823          	sd	a2,-1104(a5) # ffffffffc0206538 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200990:	00001517          	auipc	a0,0x1
ffffffffc0200994:	5d850513          	addi	a0,a0,1496 # ffffffffc0201f68 <commands+0x5c0>
}
ffffffffc0200998:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020099a:	f18ff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020099e:	6705                	lui	a4,0x1
ffffffffc02009a0:	177d                	addi	a4,a4,-1
ffffffffc02009a2:	96ba                	add	a3,a3,a4
ffffffffc02009a4:	777d                	lui	a4,0xfffff
ffffffffc02009a6:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02009a8:	00c6d513          	srli	a0,a3,0xc
ffffffffc02009ac:	00f57e63          	bgeu	a0,a5,ffffffffc02009c8 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02009b0:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02009b2:	982a                	add	a6,a6,a0
ffffffffc02009b4:	00281513          	slli	a0,a6,0x2
ffffffffc02009b8:	9542                	add	a0,a0,a6
ffffffffc02009ba:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02009bc:	8d95                	sub	a1,a1,a3
ffffffffc02009be:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02009c0:	81b1                	srli	a1,a1,0xc
ffffffffc02009c2:	9532                	add	a0,a0,a2
ffffffffc02009c4:	9782                	jalr	a5
}
ffffffffc02009c6:	b771                	j	ffffffffc0200952 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02009c8:	00001617          	auipc	a2,0x1
ffffffffc02009cc:	55060613          	addi	a2,a2,1360 # ffffffffc0201f18 <commands+0x570>
ffffffffc02009d0:	06b00593          	li	a1,107
ffffffffc02009d4:	00001517          	auipc	a0,0x1
ffffffffc02009d8:	56450513          	addi	a0,a0,1380 # ffffffffc0201f38 <commands+0x590>
ffffffffc02009dc:	f5eff0ef          	jal	ra,ffffffffc020013a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02009e0:	00001617          	auipc	a2,0x1
ffffffffc02009e4:	50060613          	addi	a2,a2,1280 # ffffffffc0201ee0 <commands+0x538>
ffffffffc02009e8:	07600593          	li	a1,118
ffffffffc02009ec:	00001517          	auipc	a0,0x1
ffffffffc02009f0:	51c50513          	addi	a0,a0,1308 # ffffffffc0201f08 <commands+0x560>
ffffffffc02009f4:	f46ff0ef          	jal	ra,ffffffffc020013a <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02009f8:	86ae                	mv	a3,a1
ffffffffc02009fa:	00001617          	auipc	a2,0x1
ffffffffc02009fe:	4e660613          	addi	a2,a2,1254 # ffffffffc0201ee0 <commands+0x538>
ffffffffc0200a02:	09100593          	li	a1,145
ffffffffc0200a06:	00001517          	auipc	a0,0x1
ffffffffc0200a0a:	50250513          	addi	a0,a0,1282 # ffffffffc0201f08 <commands+0x560>
ffffffffc0200a0e:	f2cff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200a12 <buddy_system_nr_free_pages>:
free_buddy_t buddy_s;

static size_t buddy_system_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200a12:	00005517          	auipc	a0,0x5
ffffffffc0200a16:	6f656503          	lwu	a0,1782(a0) # ffffffffc0206108 <buddy_s+0xf8>
ffffffffc0200a1a:	8082                	ret

ffffffffc0200a1c <buddy_system_init>:
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息

static void
buddy_system_init(void)
{
    for (int i = 0; i < MAX_BUDDY_ORDER + 1; i++)
ffffffffc0200a1c:	00005797          	auipc	a5,0x5
ffffffffc0200a20:	5fc78793          	addi	a5,a5,1532 # ffffffffc0206018 <buddy_s+0x8>
ffffffffc0200a24:	00005717          	auipc	a4,0x5
ffffffffc0200a28:	6e470713          	addi	a4,a4,1764 # ffffffffc0206108 <buddy_s+0xf8>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200a2c:	e79c                	sd	a5,8(a5)
ffffffffc0200a2e:	e39c                	sd	a5,0(a5)
ffffffffc0200a30:	07c1                	addi	a5,a5,16
ffffffffc0200a32:	fee79de3          	bne	a5,a4,ffffffffc0200a2c <buddy_system_init+0x10>
    {
        list_init(buddy_array + i);
    }
    max_order = 0;
ffffffffc0200a36:	00005797          	auipc	a5,0x5
ffffffffc0200a3a:	5c07ad23          	sw	zero,1498(a5) # ffffffffc0206010 <buddy_s>
    nr_free = 0;
ffffffffc0200a3e:	00005797          	auipc	a5,0x5
ffffffffc0200a42:	6c07a523          	sw	zero,1738(a5) # ffffffffc0206108 <buddy_s+0xf8>
    return;
}
ffffffffc0200a46:	8082                	ret

ffffffffc0200a48 <buddy_system_init_memmap>:

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200a48:	1141                	addi	sp,sp,-16
ffffffffc0200a4a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a4c:	c9cd                	beqz	a1,ffffffffc0200afe <buddy_system_init_memmap+0xb6>
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0200a4e:	fff58793          	addi	a5,a1,-1
ffffffffc0200a52:	8fed                	and	a5,a5,a1
ffffffffc0200a54:	c799                	beqz	a5,ffffffffc0200a62 <buddy_system_init_memmap+0x1a>
ffffffffc0200a56:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200a58:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200a5a:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200a5c:	fdf5                	bnez	a1,ffffffffc0200a58 <buddy_system_init_memmap+0x10>
        return res >> 1;
ffffffffc0200a5e:	0017d593          	srli	a1,a5,0x1
    while (n >> 1)
ffffffffc0200a62:	0015d793          	srli	a5,a1,0x1
    unsigned int order = 0;
ffffffffc0200a66:	4601                	li	a2,0
    while (n >> 1)
ffffffffc0200a68:	c781                	beqz	a5,ffffffffc0200a70 <buddy_system_init_memmap+0x28>
ffffffffc0200a6a:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200a6c:	2605                	addiw	a2,a2,1
    while (n >> 1)
ffffffffc0200a6e:	fff5                	bnez	a5,ffffffffc0200a6a <buddy_system_init_memmap+0x22>
    
    size_t pnum = ROUNDDOWN2(n);
    unsigned int order = getOrderOf2(pnum);

   
    for (struct Page *p = base; p != base + pnum; p++) {
ffffffffc0200a70:	00259693          	slli	a3,a1,0x2
ffffffffc0200a74:	96ae                	add	a3,a3,a1
ffffffffc0200a76:	068e                	slli	a3,a3,0x3
ffffffffc0200a78:	96aa                	add	a3,a3,a0
ffffffffc0200a7a:	02a68163          	beq	a3,a0,ffffffffc0200a9c <buddy_system_init_memmap+0x54>
ffffffffc0200a7e:	87aa                	mv	a5,a0
        assert(PageReserved(p));
        p->flags = 0;          
        p->property = -1;      
ffffffffc0200a80:	587d                	li	a6,-1
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a82:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200a84:	8b05                	andi	a4,a4,1
ffffffffc0200a86:	cf21                	beqz	a4,ffffffffc0200ade <buddy_system_init_memmap+0x96>
        p->flags = 0;          
ffffffffc0200a88:	0007b423          	sd	zero,8(a5)
        p->property = -1;      
ffffffffc0200a8c:	0107a823          	sw	a6,16(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a90:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p != base + pnum; p++) {
ffffffffc0200a94:	02878793          	addi	a5,a5,40
ffffffffc0200a98:	fef695e3          	bne	a3,a5,ffffffffc0200a82 <buddy_system_init_memmap+0x3a>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a9c:	02061693          	slli	a3,a2,0x20
        set_page_ref(p, 0);    
    }

    max_order = order;
ffffffffc0200aa0:	00005797          	auipc	a5,0x5
ffffffffc0200aa4:	57078793          	addi	a5,a5,1392 # ffffffffc0206010 <buddy_s>
ffffffffc0200aa8:	01c6d713          	srli	a4,a3,0x1c
ffffffffc0200aac:	00e78833          	add	a6,a5,a4
ffffffffc0200ab0:	01083683          	ld	a3,16(a6) # fffffffffff80010 <end+0x3fd79ab8>
    nr_free = pnum;
ffffffffc0200ab4:	0eb7ac23          	sw	a1,248(a5)
    max_order = order;
ffffffffc0200ab8:	c390                	sw	a2,0(a5)
    list_add(&(buddy_array[max_order]), &(base->page_link));
ffffffffc0200aba:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200abe:	e28c                	sd	a1,0(a3)
ffffffffc0200ac0:	0721                	addi	a4,a4,8
ffffffffc0200ac2:	00b83823          	sd	a1,16(a6)
ffffffffc0200ac6:	97ba                	add	a5,a5,a4
    elm->next = next;
    elm->prev = prev;
ffffffffc0200ac8:	ed1c                	sd	a5,24(a0)
    elm->next = next;
ffffffffc0200aca:	f114                	sd	a3,32(a0)

    
    base->property = max_order;
ffffffffc0200acc:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ace:	4789                	li	a5,2
ffffffffc0200ad0:	00850713          	addi	a4,a0,8
ffffffffc0200ad4:	40f7302f          	amoor.d	zero,a5,(a4)
    SetPageProperty(base); // 初始化

    return;
}
ffffffffc0200ad8:	60a2                	ld	ra,8(sp)
ffffffffc0200ada:	0141                	addi	sp,sp,16
ffffffffc0200adc:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200ade:	00001697          	auipc	a3,0x1
ffffffffc0200ae2:	50268693          	addi	a3,a3,1282 # ffffffffc0201fe0 <commands+0x638>
ffffffffc0200ae6:	00001617          	auipc	a2,0x1
ffffffffc0200aea:	4ca60613          	addi	a2,a2,1226 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200aee:	09c00593          	li	a1,156
ffffffffc0200af2:	00001517          	auipc	a0,0x1
ffffffffc0200af6:	4d650513          	addi	a0,a0,1238 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200afa:	e40ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0);
ffffffffc0200afe:	00001697          	auipc	a3,0x1
ffffffffc0200b02:	4aa68693          	addi	a3,a3,1194 # ffffffffc0201fa8 <commands+0x600>
ffffffffc0200b06:	00001617          	auipc	a2,0x1
ffffffffc0200b0a:	4aa60613          	addi	a2,a2,1194 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200b0e:	09400593          	li	a1,148
ffffffffc0200b12:	00001517          	auipc	a0,0x1
ffffffffc0200b16:	4b650513          	addi	a0,a0,1206 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200b1a:	e20ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200b1e <buddy_system_free_pages>:
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
    return buddy_page;
}

static void buddy_system_free_pages(struct Page *base, size_t n)
{
ffffffffc0200b1e:	1101                	addi	sp,sp,-32
ffffffffc0200b20:	ec06                	sd	ra,24(sp)
ffffffffc0200b22:	e822                	sd	s0,16(sp)
ffffffffc0200b24:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200b26:	16058563          	beqz	a1,ffffffffc0200c90 <buddy_system_free_pages+0x172>
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc0200b2a:	4918                	lw	a4,16(a0)
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0200b2c:	fff58793          	addi	a5,a1,-1
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc0200b30:	4485                	li	s1,1
ffffffffc0200b32:	00e494bb          	sllw	s1,s1,a4
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0200b36:	8fed                	and	a5,a5,a1
ffffffffc0200b38:	842a                	mv	s0,a0
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc0200b3a:	0004861b          	sext.w	a2,s1
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0200b3e:	14079363          	bnez	a5,ffffffffc0200c84 <buddy_system_free_pages+0x166>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200b42:	02049793          	slli	a5,s1,0x20
ffffffffc0200b46:	9381                	srli	a5,a5,0x20
ffffffffc0200b48:	16b79463          	bne	a5,a1,ffffffffc0200cb0 <buddy_system_free_pages+0x192>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b4c:	00006797          	auipc	a5,0x6
ffffffffc0200b50:	9dc7b783          	ld	a5,-1572(a5) # ffffffffc0206528 <pages>
ffffffffc0200b54:	40f407b3          	sub	a5,s0,a5
ffffffffc0200b58:	00002597          	auipc	a1,0x2
ffffffffc0200b5c:	aa85b583          	ld	a1,-1368(a1) # ffffffffc0202600 <nbase+0x8>
ffffffffc0200b60:	878d                	srai	a5,a5,0x3
ffffffffc0200b62:	02b787b3          	mul	a5,a5,a1
    cprintf("buddy system分配释放第NO.%d页开始共%d页\n", page2ppn(base), pnum);
ffffffffc0200b66:	00002597          	auipc	a1,0x2
ffffffffc0200b6a:	a925b583          	ld	a1,-1390(a1) # ffffffffc02025f8 <nbase>
ffffffffc0200b6e:	00001517          	auipc	a0,0x1
ffffffffc0200b72:	49a50513          	addi	a0,a0,1178 # ffffffffc0202008 <commands+0x660>
ffffffffc0200b76:	95be                	add	a1,a1,a5
ffffffffc0200b78:	d3aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *left_block = base; // 放块的头页
    struct Page *buddy = NULL;
    struct Page *tmp = NULL;

    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中
ffffffffc0200b7c:	4810                	lw	a2,16(s0)
    size_t real_block_size = 1 << block_size;                    
ffffffffc0200b7e:	4785                	li	a5,1
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算对于第一个页的偏移量
ffffffffc0200b80:	3fdf1eb7          	lui	t4,0x3fdf1
    size_t real_block_size = 1 << block_size;                    
ffffffffc0200b84:	00c7973b          	sllw	a4,a5,a2
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  
ffffffffc0200b88:	00271793          	slli	a5,a4,0x2
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算对于第一个页的偏移量
ffffffffc0200b8c:	ce8e8e93          	addi	t4,t4,-792 # 3fdf0ce8 <kern_entry-0xffffffff8040f318>
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  
ffffffffc0200b90:	97ba                	add	a5,a5,a4
    __list_add(elm, listelm, listelm->next);
ffffffffc0200b92:	02061693          	slli	a3,a2,0x20
ffffffffc0200b96:	01c6d713          	srli	a4,a3,0x1c
ffffffffc0200b9a:	00005897          	auipc	a7,0x5
ffffffffc0200b9e:	47688893          	addi	a7,a7,1142 # ffffffffc0206010 <buddy_s>
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算对于第一个页的偏移量
ffffffffc0200ba2:	01d406b3          	add	a3,s0,t4
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  
ffffffffc0200ba6:	078e                	slli	a5,a5,0x3
ffffffffc0200ba8:	00e88533          	add	a0,a7,a4
    size_t buddy_relative_addr = (size_t)relative_block_addr ^ sizeOfPage;      // 异或得到伙伴块的相对地址
ffffffffc0200bac:	8fb5                	xor	a5,a5,a3
ffffffffc0200bae:	690c                	ld	a1,16(a0)
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
ffffffffc0200bb0:	41d787b3          	sub	a5,a5,t4
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bb4:	6794                	ld	a3,8(a5)
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中
ffffffffc0200bb6:	01840813          	addi	a6,s0,24
    prev->next = next->prev = elm;
ffffffffc0200bba:	0105b023          	sd	a6,0(a1)
ffffffffc0200bbe:	0721                	addi	a4,a4,8
ffffffffc0200bc0:	01053823          	sd	a6,16(a0)
ffffffffc0200bc4:	9746                	add	a4,a4,a7
ffffffffc0200bc6:	8285                	srli	a3,a3,0x1
    elm->prev = prev;
ffffffffc0200bc8:	ec18                	sd	a4,24(s0)
    elm->next = next;
ffffffffc0200bca:	f00c                	sd	a1,32(s0)

    // show_buddy_array(0, MAX_BUDDY_ORDER); // test point
    // 当伙伴块空闲，且当前块不为最大块时，执行合并
    buddy = get_buddy(left_block, left_block->property);
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc0200bcc:	0016f713          	andi	a4,a3,1
    {
        if (left_block > buddy)
        {                              // 若当前左块为更大块的右块
            left_block->property = -1; // 将左块幂次置为无效
ffffffffc0200bd0:	5ffd                	li	t6,-1
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc0200bd2:	86a2                	mv	a3,s0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200bd4:	4f09                	li	t5,2
    size_t real_block_size = 1 << block_size;                    
ffffffffc0200bd6:	4505                	li	a0,1
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc0200bd8:	e359                	bnez	a4,ffffffffc0200c5e <buddy_system_free_pages+0x140>
ffffffffc0200bda:	a071                	j	ffffffffc0200c66 <buddy_system_free_pages+0x148>
        if (left_block > buddy)
ffffffffc0200bdc:	00d7fc63          	bgeu	a5,a3,ffffffffc0200bf4 <buddy_system_free_pages+0xd6>
            left_block->property = -1; // 将左块幂次置为无效
ffffffffc0200be0:	01f6a823          	sw	t6,16(a3)
ffffffffc0200be4:	00840713          	addi	a4,s0,8
ffffffffc0200be8:	41e7302f          	amoor.d	zero,t5,(a4)
            buddy = tmp;
        }
        // 删掉原来链表里的两个小块
        list_del(&(left_block->page_link));
        list_del(&(buddy->page_link));
        left_block->property += 1; // 左快头页设置幂次加一
ffffffffc0200bec:	8736                	mv	a4,a3
ffffffffc0200bee:	4b90                	lw	a2,16(a5)
ffffffffc0200bf0:	86be                	mv	a3,a5
ffffffffc0200bf2:	87ba                	mv	a5,a4
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bf4:	0186b803          	ld	a6,24(a3)
ffffffffc0200bf8:	728c                	ld	a1,32(a3)
ffffffffc0200bfa:	2605                	addiw	a2,a2,1
    size_t real_block_size = 1 << block_size;                    
ffffffffc0200bfc:	00c5173b          	sllw	a4,a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c00:	00b83423          	sd	a1,8(a6)
    next->prev = prev;
ffffffffc0200c04:	0105b023          	sd	a6,0(a1)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c08:	0187b303          	ld	t1,24(a5)
ffffffffc0200c0c:	0207b803          	ld	a6,32(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c10:	02061e13          	slli	t3,a2,0x20
    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  
ffffffffc0200c14:	00271793          	slli	a5,a4,0x2
    prev->next = next;
ffffffffc0200c18:	01033423          	sd	a6,8(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c1c:	01ce5593          	srli	a1,t3,0x1c
ffffffffc0200c20:	97ba                	add	a5,a5,a4
    next->prev = prev;
ffffffffc0200c22:	00683023          	sd	t1,0(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200c26:	00b88e33          	add	t3,a7,a1
ffffffffc0200c2a:	00379713          	slli	a4,a5,0x3
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算对于第一个页的偏移量
ffffffffc0200c2e:	01d687b3          	add	a5,a3,t4
ffffffffc0200c32:	010e3303          	ld	t1,16(t3)
    size_t buddy_relative_addr = (size_t)relative_block_addr ^ sizeOfPage;      // 异或得到伙伴块的相对地址
ffffffffc0200c36:	8fb9                	xor	a5,a5,a4
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
ffffffffc0200c38:	41d787b3          	sub	a5,a5,t4
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c3c:	0087b803          	ld	a6,8(a5)
        // cprintf("left_block->property=%d\n", left_block->property); //test point
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
ffffffffc0200c40:	01868713          	addi	a4,a3,24
        left_block->property += 1; // 左快头页设置幂次加一
ffffffffc0200c44:	ca90                	sw	a2,16(a3)
    prev->next = next->prev = elm;
ffffffffc0200c46:	00e33023          	sd	a4,0(t1)
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
ffffffffc0200c4a:	05a1                	addi	a1,a1,8
ffffffffc0200c4c:	00ee3823          	sd	a4,16(t3)
ffffffffc0200c50:	95c6                	add	a1,a1,a7
    elm->next = next;
ffffffffc0200c52:	0266b023          	sd	t1,32(a3)
    elm->prev = prev;
ffffffffc0200c56:	ee8c                	sd	a1,24(a3)
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc0200c58:	00287713          	andi	a4,a6,2
ffffffffc0200c5c:	c709                	beqz	a4,ffffffffc0200c66 <buddy_system_free_pages+0x148>
ffffffffc0200c5e:	0008a703          	lw	a4,0(a7)
ffffffffc0200c62:	f6e66de3          	bltu	a2,a4,ffffffffc0200bdc <buddy_system_free_pages+0xbe>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c66:	4789                	li	a5,2
ffffffffc0200c68:	00868713          	addi	a4,a3,8
ffffffffc0200c6c:	40f7302f          	amoor.d	zero,a5,(a4)

        // 重置buddy开启下一轮循环***
        buddy = get_buddy(left_block, left_block->property);
    }
    SetPageProperty(left_block); // 将回收块的头页设置为空闲
    nr_free += pnum;
ffffffffc0200c70:	0f88a783          	lw	a5,248(a7)
    // show_buddy_array(); // test point

    return;
}
ffffffffc0200c74:	60e2                	ld	ra,24(sp)
ffffffffc0200c76:	6442                	ld	s0,16(sp)
    nr_free += pnum;
ffffffffc0200c78:	9cbd                	addw	s1,s1,a5
ffffffffc0200c7a:	0e98ac23          	sw	s1,248(a7)
}
ffffffffc0200c7e:	64a2                	ld	s1,8(sp)
ffffffffc0200c80:	6105                	addi	sp,sp,32
ffffffffc0200c82:	8082                	ret
ffffffffc0200c84:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200c86:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200c88:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0200c8a:	fdf5                	bnez	a1,ffffffffc0200c86 <buddy_system_free_pages+0x168>
            res = res << 1;
ffffffffc0200c8c:	85be                	mv	a1,a5
ffffffffc0200c8e:	bd55                	j	ffffffffc0200b42 <buddy_system_free_pages+0x24>
    assert(n > 0);
ffffffffc0200c90:	00001697          	auipc	a3,0x1
ffffffffc0200c94:	31868693          	addi	a3,a3,792 # ffffffffc0201fa8 <commands+0x600>
ffffffffc0200c98:	00001617          	auipc	a2,0x1
ffffffffc0200c9c:	31860613          	addi	a2,a2,792 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200ca0:	0e900593          	li	a1,233
ffffffffc0200ca4:	00001517          	auipc	a0,0x1
ffffffffc0200ca8:	32450513          	addi	a0,a0,804 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200cac:	c8eff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200cb0:	00001697          	auipc	a3,0x1
ffffffffc0200cb4:	34068693          	addi	a3,a3,832 # ffffffffc0201ff0 <commands+0x648>
ffffffffc0200cb8:	00001617          	auipc	a2,0x1
ffffffffc0200cbc:	2f860613          	addi	a2,a2,760 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200cc0:	0eb00593          	li	a1,235
ffffffffc0200cc4:	00001517          	auipc	a0,0x1
ffffffffc0200cc8:	30450513          	addi	a0,a0,772 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200ccc:	c6eff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200cd0 <show_buddy_array.constprop.0>:
show_buddy_array(int left, int right) // 左闭右闭
ffffffffc0200cd0:	711d                	addi	sp,sp,-96
ffffffffc0200cd2:	ec86                	sd	ra,88(sp)
ffffffffc0200cd4:	e8a2                	sd	s0,80(sp)
ffffffffc0200cd6:	e4a6                	sd	s1,72(sp)
ffffffffc0200cd8:	e0ca                	sd	s2,64(sp)
ffffffffc0200cda:	fc4e                	sd	s3,56(sp)
ffffffffc0200cdc:	f852                	sd	s4,48(sp)
ffffffffc0200cde:	f456                	sd	s5,40(sp)
ffffffffc0200ce0:	f05a                	sd	s6,32(sp)
ffffffffc0200ce2:	ec5e                	sd	s7,24(sp)
ffffffffc0200ce4:	e862                	sd	s8,16(sp)
ffffffffc0200ce6:	e466                	sd	s9,8(sp)
ffffffffc0200ce8:	e06a                	sd	s10,0(sp)
    assert(left >= 0 && left <= max_order && right >= 0 && right <= max_order);
ffffffffc0200cea:	00005717          	auipc	a4,0x5
ffffffffc0200cee:	32672703          	lw	a4,806(a4) # ffffffffc0206010 <buddy_s>
ffffffffc0200cf2:	47b5                	li	a5,13
ffffffffc0200cf4:	0ce7f363          	bgeu	a5,a4,ffffffffc0200dba <show_buddy_array.constprop.0+0xea>
ffffffffc0200cf8:	00005497          	auipc	s1,0x5
ffffffffc0200cfc:	32048493          	addi	s1,s1,800 # ffffffffc0206018 <buddy_s+0x8>
    bool empty = 1; // 表示空闲链表数组为空
ffffffffc0200d00:	4c05                	li	s8,1
    for (int i = left; i <= right; i++)
ffffffffc0200d02:	4901                	li	s2,0
                cprintf("No.%d的空闲链表有", i);
ffffffffc0200d04:	00001b17          	auipc	s6,0x1
ffffffffc0200d08:	384b0b13          	addi	s6,s6,900 # ffffffffc0202088 <commands+0x6e0>
                cprintf("%d页 ", 1 << (p->property));
ffffffffc0200d0c:	4a85                	li	s5,1
ffffffffc0200d0e:	00001a17          	auipc	s4,0x1
ffffffffc0200d12:	392a0a13          	addi	s4,s4,914 # ffffffffc02020a0 <commands+0x6f8>
                cprintf("【地址为%p】\n", p);
ffffffffc0200d16:	00001997          	auipc	s3,0x1
ffffffffc0200d1a:	39298993          	addi	s3,s3,914 # ffffffffc02020a8 <commands+0x700>
            if (i != right)
ffffffffc0200d1e:	4cb9                	li	s9,14
                cprintf("\n");
ffffffffc0200d20:	00001d17          	auipc	s10,0x1
ffffffffc0200d24:	b18d0d13          	addi	s10,s10,-1256 # ffffffffc0201838 <etext+0x10a>
    for (int i = left; i <= right; i++)
ffffffffc0200d28:	4bbd                	li	s7,15
ffffffffc0200d2a:	a029                	j	ffffffffc0200d34 <show_buddy_array.constprop.0+0x64>
ffffffffc0200d2c:	2905                	addiw	s2,s2,1
ffffffffc0200d2e:	04c1                	addi	s1,s1,16
ffffffffc0200d30:	05790263          	beq	s2,s7,ffffffffc0200d74 <show_buddy_array.constprop.0+0xa4>
    return listelm->next;
ffffffffc0200d34:	6480                	ld	s0,8(s1)
        if (list_next(le) != &buddy_array[i])
ffffffffc0200d36:	fe848be3          	beq	s1,s0,ffffffffc0200d2c <show_buddy_array.constprop.0+0x5c>
                cprintf("No.%d的空闲链表有", i);
ffffffffc0200d3a:	85ca                	mv	a1,s2
ffffffffc0200d3c:	855a                	mv	a0,s6
ffffffffc0200d3e:	b74ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("%d页 ", 1 << (p->property));
ffffffffc0200d42:	ff842583          	lw	a1,-8(s0)
ffffffffc0200d46:	8552                	mv	a0,s4
ffffffffc0200d48:	00ba95bb          	sllw	a1,s5,a1
ffffffffc0200d4c:	b66ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("【地址为%p】\n", p);
ffffffffc0200d50:	fe840593          	addi	a1,s0,-24
ffffffffc0200d54:	854e                	mv	a0,s3
ffffffffc0200d56:	b5cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200d5a:	6400                	ld	s0,8(s0)
            while ((le = list_next(le)) != &buddy_array[i])
ffffffffc0200d5c:	fc941fe3          	bne	s0,s1,ffffffffc0200d3a <show_buddy_array.constprop.0+0x6a>
            empty = 0;
ffffffffc0200d60:	4c01                	li	s8,0
            if (i != right)
ffffffffc0200d62:	fd9905e3          	beq	s2,s9,ffffffffc0200d2c <show_buddy_array.constprop.0+0x5c>
                cprintf("\n");
ffffffffc0200d66:	856a                	mv	a0,s10
    for (int i = left; i <= right; i++)
ffffffffc0200d68:	2905                	addiw	s2,s2,1
                cprintf("\n");
ffffffffc0200d6a:	b48ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = left; i <= right; i++)
ffffffffc0200d6e:	04c1                	addi	s1,s1,16
ffffffffc0200d70:	fd7912e3          	bne	s2,s7,ffffffffc0200d34 <show_buddy_array.constprop.0+0x64>
    if (empty)
ffffffffc0200d74:	020c1063          	bnez	s8,ffffffffc0200d94 <show_buddy_array.constprop.0+0xc4>
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息
ffffffffc0200d78:	60e6                	ld	ra,88(sp)
ffffffffc0200d7a:	6446                	ld	s0,80(sp)
ffffffffc0200d7c:	64a6                	ld	s1,72(sp)
ffffffffc0200d7e:	6906                	ld	s2,64(sp)
ffffffffc0200d80:	79e2                	ld	s3,56(sp)
ffffffffc0200d82:	7a42                	ld	s4,48(sp)
ffffffffc0200d84:	7aa2                	ld	s5,40(sp)
ffffffffc0200d86:	7b02                	ld	s6,32(sp)
ffffffffc0200d88:	6be2                	ld	s7,24(sp)
ffffffffc0200d8a:	6c42                	ld	s8,16(sp)
ffffffffc0200d8c:	6ca2                	ld	s9,8(sp)
ffffffffc0200d8e:	6d02                	ld	s10,0(sp)
ffffffffc0200d90:	6125                	addi	sp,sp,96
ffffffffc0200d92:	8082                	ret
ffffffffc0200d94:	6446                	ld	s0,80(sp)
ffffffffc0200d96:	60e6                	ld	ra,88(sp)
ffffffffc0200d98:	64a6                	ld	s1,72(sp)
ffffffffc0200d9a:	6906                	ld	s2,64(sp)
ffffffffc0200d9c:	79e2                	ld	s3,56(sp)
ffffffffc0200d9e:	7a42                	ld	s4,48(sp)
ffffffffc0200da0:	7aa2                	ld	s5,40(sp)
ffffffffc0200da2:	7b02                	ld	s6,32(sp)
ffffffffc0200da4:	6be2                	ld	s7,24(sp)
ffffffffc0200da6:	6c42                	ld	s8,16(sp)
ffffffffc0200da8:	6ca2                	ld	s9,8(sp)
ffffffffc0200daa:	6d02                	ld	s10,0(sp)
        cprintf("无空闲块！！！\n");
ffffffffc0200dac:	00001517          	auipc	a0,0x1
ffffffffc0200db0:	31450513          	addi	a0,a0,788 # ffffffffc02020c0 <commands+0x718>
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息
ffffffffc0200db4:	6125                	addi	sp,sp,96
        cprintf("无空闲块！！！\n");
ffffffffc0200db6:	afcff06f          	j	ffffffffc02000b2 <cprintf>
    assert(left >= 0 && left <= max_order && right >= 0 && right <= max_order);
ffffffffc0200dba:	00001697          	auipc	a3,0x1
ffffffffc0200dbe:	28668693          	addi	a3,a3,646 # ffffffffc0202040 <commands+0x698>
ffffffffc0200dc2:	00001617          	auipc	a2,0x1
ffffffffc0200dc6:	1ee60613          	addi	a2,a2,494 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200dca:	06a00593          	li	a1,106
ffffffffc0200dce:	00001517          	auipc	a0,0x1
ffffffffc0200dd2:	1fa50513          	addi	a0,a0,506 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200dd6:	b64ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0200dda <buddy_system_check>:



static void
buddy_system_check(void)
{
ffffffffc0200dda:	7179                	addi	sp,sp,-48
ffffffffc0200ddc:	f022                	sd	s0,32(sp)
    cprintf("总空闲块数目为：%d\n", nr_free);
ffffffffc0200dde:	00005417          	auipc	s0,0x5
ffffffffc0200de2:	23240413          	addi	s0,s0,562 # ffffffffc0206010 <buddy_s>
ffffffffc0200de6:	0f842583          	lw	a1,248(s0)
ffffffffc0200dea:	00001517          	auipc	a0,0x1
ffffffffc0200dee:	2ee50513          	addi	a0,a0,750 # ffffffffc02020d8 <commands+0x730>
{
ffffffffc0200df2:	f406                	sd	ra,40(sp)
ffffffffc0200df4:	ec26                	sd	s1,24(sp)
ffffffffc0200df6:	e84a                	sd	s2,16(sp)
ffffffffc0200df8:	e44e                	sd	s3,8(sp)
    cprintf("总空闲块数目为：%d\n", nr_free);
ffffffffc0200dfa:	ab8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("首先p0请求5页\n");
ffffffffc0200dfe:	00001517          	auipc	a0,0x1
ffffffffc0200e02:	2fa50513          	addi	a0,a0,762 # ffffffffc02020f8 <commands+0x750>
ffffffffc0200e06:	aacff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p0 = alloc_pages(5);
ffffffffc0200e0a:	4515                	li	a0,5
ffffffffc0200e0c:	9f7ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200e10:	892a                	mv	s2,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200e12:	ebfff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    cprintf("然后p1请求5页\n");
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	2fa50513          	addi	a0,a0,762 # ffffffffc0202110 <commands+0x768>
ffffffffc0200e1e:	a94ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p1 = alloc_pages(5);
ffffffffc0200e22:	4515                	li	a0,5
ffffffffc0200e24:	9dfff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200e28:	84aa                	mv	s1,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200e2a:	ea7ff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    cprintf("最后p2请求5页\n");
ffffffffc0200e2e:	00001517          	auipc	a0,0x1
ffffffffc0200e32:	2fa50513          	addi	a0,a0,762 # ffffffffc0202128 <commands+0x780>
ffffffffc0200e36:	a7cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p2 = alloc_pages(5);
ffffffffc0200e3a:	4515                	li	a0,5
ffffffffc0200e3c:	9c7ff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200e40:	89aa                	mv	s3,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200e42:	e8fff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    cprintf("p0的虚拟地址0x%016lx.\n", p0);// 0x8020f318
ffffffffc0200e46:	85ca                	mv	a1,s2
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	2f850513          	addi	a0,a0,760 # ffffffffc0202140 <commands+0x798>
ffffffffc0200e50:	a62ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1的虚拟地址0x%016lx.\n", p1);// 0x8020f458,和p0相差0x140=0x28*5
ffffffffc0200e54:	85a6                	mv	a1,s1
ffffffffc0200e56:	00001517          	auipc	a0,0x1
ffffffffc0200e5a:	30a50513          	addi	a0,a0,778 # ffffffffc0202160 <commands+0x7b8>
ffffffffc0200e5e:	a54ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2的虚拟地址0x%016lx.\n", p2);// 0x8020f598,和p1相差0x140=0x28*5
ffffffffc0200e62:	85ce                	mv	a1,s3
ffffffffc0200e64:	00001517          	auipc	a0,0x1
ffffffffc0200e68:	31c50513          	addi	a0,a0,796 # ffffffffc0202180 <commands+0x7d8>
ffffffffc0200e6c:	a46ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e70:	10990463          	beq	s2,s1,ffffffffc0200f78 <buddy_system_check+0x19e>
ffffffffc0200e74:	11390263          	beq	s2,s3,ffffffffc0200f78 <buddy_system_check+0x19e>
ffffffffc0200e78:	11348063          	beq	s1,s3,ffffffffc0200f78 <buddy_system_check+0x19e>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e7c:	00092783          	lw	a5,0(s2)
ffffffffc0200e80:	10079c63          	bnez	a5,ffffffffc0200f98 <buddy_system_check+0x1be>
ffffffffc0200e84:	409c                	lw	a5,0(s1)
ffffffffc0200e86:	10079963          	bnez	a5,ffffffffc0200f98 <buddy_system_check+0x1be>
ffffffffc0200e8a:	0009a783          	lw	a5,0(s3)
ffffffffc0200e8e:	10079563          	bnez	a5,ffffffffc0200f98 <buddy_system_check+0x1be>
ffffffffc0200e92:	00005797          	auipc	a5,0x5
ffffffffc0200e96:	6967b783          	ld	a5,1686(a5) # ffffffffc0206528 <pages>
ffffffffc0200e9a:	40f90733          	sub	a4,s2,a5
ffffffffc0200e9e:	870d                	srai	a4,a4,0x3
ffffffffc0200ea0:	00001597          	auipc	a1,0x1
ffffffffc0200ea4:	7605b583          	ld	a1,1888(a1) # ffffffffc0202600 <nbase+0x8>
ffffffffc0200ea8:	02b70733          	mul	a4,a4,a1
ffffffffc0200eac:	00001617          	auipc	a2,0x1
ffffffffc0200eb0:	74c63603          	ld	a2,1868(a2) # ffffffffc02025f8 <nbase>

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200eb4:	00005697          	auipc	a3,0x5
ffffffffc0200eb8:	66c6b683          	ld	a3,1644(a3) # ffffffffc0206520 <npage>
ffffffffc0200ebc:	06b2                	slli	a3,a3,0xc
ffffffffc0200ebe:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ec0:	0732                	slli	a4,a4,0xc
ffffffffc0200ec2:	0ed77b63          	bgeu	a4,a3,ffffffffc0200fb8 <buddy_system_check+0x1de>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ec6:	40f48733          	sub	a4,s1,a5
ffffffffc0200eca:	870d                	srai	a4,a4,0x3
ffffffffc0200ecc:	02b70733          	mul	a4,a4,a1
ffffffffc0200ed0:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ed2:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ed4:	10d77263          	bgeu	a4,a3,ffffffffc0200fd8 <buddy_system_check+0x1fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ed8:	40f987b3          	sub	a5,s3,a5
ffffffffc0200edc:	878d                	srai	a5,a5,0x3
ffffffffc0200ede:	02b787b3          	mul	a5,a5,a1
ffffffffc0200ee2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ee4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ee6:	10d7f963          	bgeu	a5,a3,ffffffffc0200ff8 <buddy_system_check+0x21e>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);
ffffffffc0200eea:	4505                	li	a0,1
    nr_free = 0;
ffffffffc0200eec:	00005797          	auipc	a5,0x5
ffffffffc0200ef0:	2007ae23          	sw	zero,540(a5) # ffffffffc0206108 <buddy_s+0xf8>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	90fff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200ef8:	12051063          	bnez	a0,ffffffffc0201018 <buddy_system_check+0x23e>

    free_pages(p0, 5);
ffffffffc0200efc:	854a                	mv	a0,s2
ffffffffc0200efe:	4595                	li	a1,5
ffffffffc0200f00:	941ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    cprintf("释放p0后，总空闲块数目为：%d\n", nr_free); // 变成了8
ffffffffc0200f04:	0f842583          	lw	a1,248(s0)
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	37850513          	addi	a0,a0,888 # ffffffffc0202280 <commands+0x8d8>
ffffffffc0200f10:	9a2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200f14:	dbdff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    free_pages(p1, 5);
ffffffffc0200f18:	8526                	mv	a0,s1
ffffffffc0200f1a:	4595                	li	a1,5
ffffffffc0200f1c:	925ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    cprintf("释放p1后，总空闲块数目为：%d\n", nr_free); // 变成了16
ffffffffc0200f20:	0f842583          	lw	a1,248(s0)
ffffffffc0200f24:	00001517          	auipc	a0,0x1
ffffffffc0200f28:	38c50513          	addi	a0,a0,908 # ffffffffc02022b0 <commands+0x908>
ffffffffc0200f2c:	986ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200f30:	da1ff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    free_pages(p2, 5);
ffffffffc0200f34:	854e                	mv	a0,s3
ffffffffc0200f36:	4595                	li	a1,5
ffffffffc0200f38:	909ff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    cprintf("释放p2后，总空闲块数目为：%d\n", nr_free); // 变成了24
ffffffffc0200f3c:	0f842583          	lw	a1,248(s0)
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	3a050513          	addi	a0,a0,928 # ffffffffc02022e0 <commands+0x938>
ffffffffc0200f48:	96aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200f4c:	d85ff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    nr_free = 16384;
ffffffffc0200f50:	6791                	lui	a5,0x4

    struct Page *p3 = alloc_pages(16384);
ffffffffc0200f52:	6511                	lui	a0,0x4
    nr_free = 16384;
ffffffffc0200f54:	0ef42c23          	sw	a5,248(s0)
    struct Page *p3 = alloc_pages(16384);
ffffffffc0200f58:	8abff0ef          	jal	ra,ffffffffc0200802 <alloc_pages>
ffffffffc0200f5c:	842a                	mv	s0,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200f5e:	d73ff0ef          	jal	ra,ffffffffc0200cd0 <show_buddy_array.constprop.0>

    // 全部回收
    free_pages(p3, 16384);
ffffffffc0200f62:	8522                	mv	a0,s0
ffffffffc0200f64:	6591                	lui	a1,0x4
ffffffffc0200f66:	8dbff0ef          	jal	ra,ffffffffc0200840 <free_pages>
    show_buddy_array(0, MAX_BUDDY_ORDER);
}
ffffffffc0200f6a:	7402                	ld	s0,32(sp)
ffffffffc0200f6c:	70a2                	ld	ra,40(sp)
ffffffffc0200f6e:	64e2                	ld	s1,24(sp)
ffffffffc0200f70:	6942                	ld	s2,16(sp)
ffffffffc0200f72:	69a2                	ld	s3,8(sp)
ffffffffc0200f74:	6145                	addi	sp,sp,48
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200f76:	bba9                	j	ffffffffc0200cd0 <show_buddy_array.constprop.0>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f78:	00001697          	auipc	a3,0x1
ffffffffc0200f7c:	22868693          	addi	a3,a3,552 # ffffffffc02021a0 <commands+0x7f8>
ffffffffc0200f80:	00001617          	auipc	a2,0x1
ffffffffc0200f84:	03060613          	addi	a2,a2,48 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200f88:	12c00593          	li	a1,300
ffffffffc0200f8c:	00001517          	auipc	a0,0x1
ffffffffc0200f90:	03c50513          	addi	a0,a0,60 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200f94:	9a6ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f98:	00001697          	auipc	a3,0x1
ffffffffc0200f9c:	23068693          	addi	a3,a3,560 # ffffffffc02021c8 <commands+0x820>
ffffffffc0200fa0:	00001617          	auipc	a2,0x1
ffffffffc0200fa4:	01060613          	addi	a2,a2,16 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200fa8:	12d00593          	li	a1,301
ffffffffc0200fac:	00001517          	auipc	a0,0x1
ffffffffc0200fb0:	01c50513          	addi	a0,a0,28 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200fb4:	986ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200fb8:	00001697          	auipc	a3,0x1
ffffffffc0200fbc:	25068693          	addi	a3,a3,592 # ffffffffc0202208 <commands+0x860>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	ff060613          	addi	a2,a2,-16 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200fc8:	12f00593          	li	a1,303
ffffffffc0200fcc:	00001517          	auipc	a0,0x1
ffffffffc0200fd0:	ffc50513          	addi	a0,a0,-4 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200fd4:	966ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fd8:	00001697          	auipc	a3,0x1
ffffffffc0200fdc:	25068693          	addi	a3,a3,592 # ffffffffc0202228 <commands+0x880>
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	fd060613          	addi	a2,a2,-48 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0200fe8:	13000593          	li	a1,304
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	fdc50513          	addi	a0,a0,-36 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0200ff4:	946ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ff8:	00001697          	auipc	a3,0x1
ffffffffc0200ffc:	25068693          	addi	a3,a3,592 # ffffffffc0202248 <commands+0x8a0>
ffffffffc0201000:	00001617          	auipc	a2,0x1
ffffffffc0201004:	fb060613          	addi	a2,a2,-80 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0201008:	13100593          	li	a1,305
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	fbc50513          	addi	a0,a0,-68 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0201014:	926ff0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201018:	00001697          	auipc	a3,0x1
ffffffffc020101c:	25068693          	addi	a3,a3,592 # ffffffffc0202268 <commands+0x8c0>
ffffffffc0201020:	00001617          	auipc	a2,0x1
ffffffffc0201024:	f9060613          	addi	a2,a2,-112 # ffffffffc0201fb0 <commands+0x608>
ffffffffc0201028:	13600593          	li	a1,310
ffffffffc020102c:	00001517          	auipc	a0,0x1
ffffffffc0201030:	f9c50513          	addi	a0,a0,-100 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0201034:	906ff0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc0201038 <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t requested_pages) {
ffffffffc0201038:	1141                	addi	sp,sp,-16
ffffffffc020103a:	e406                	sd	ra,8(sp)
    assert(requested_pages > 0);
ffffffffc020103c:	16050f63          	beqz	a0,ffffffffc02011ba <buddy_system_alloc_pages+0x182>
    if (requested_pages > nr_free) {
ffffffffc0201040:	00005897          	auipc	a7,0x5
ffffffffc0201044:	fd088893          	addi	a7,a7,-48 # ffffffffc0206010 <buddy_s>
ffffffffc0201048:	0f88e783          	lwu	a5,248(a7)
ffffffffc020104c:	882a                	mv	a6,a0
ffffffffc020104e:	10a7e663          	bltu	a5,a0,ffffffffc020115a <buddy_system_alloc_pages+0x122>
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
ffffffffc0201052:	fff50793          	addi	a5,a0,-1
ffffffffc0201056:	8fe9                	and	a5,a5,a0
ffffffffc0201058:	10079563          	bnez	a5,ffffffffc0201162 <buddy_system_alloc_pages+0x12a>
    while (n >> 1)
ffffffffc020105c:	00185793          	srli	a5,a6,0x1
ffffffffc0201060:	10078963          	beqz	a5,ffffffffc0201172 <buddy_system_alloc_pages+0x13a>
    unsigned int order = 0;
ffffffffc0201064:	4701                	li	a4,0
    while (n >> 1)
ffffffffc0201066:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0201068:	2705                	addiw	a4,a4,1
    while (n >> 1)
ffffffffc020106a:	fff5                	bnez	a5,ffffffffc0201066 <buddy_system_alloc_pages+0x2e>
ffffffffc020106c:	02071793          	slli	a5,a4,0x20
ffffffffc0201070:	01c7de13          	srli	t3,a5,0x1c
ffffffffc0201074:	008e0793          	addi	a5,t3,8
    return list->next == list;
ffffffffc0201078:	9e46                	add	t3,t3,a7
ffffffffc020107a:	010e3303          	ld	t1,16(t3)
        if (!list_empty(&(buddy_array[order_of_2]))) {
ffffffffc020107e:	97c6                	add	a5,a5,a7
ffffffffc0201080:	0af31763          	bne	t1,a5,ffffffffc020112e <buddy_system_alloc_pages+0xf6>
            for (int i = order_of_2 + 1; i <= max_order; ++i) {
ffffffffc0201084:	0017059b          	addiw	a1,a4,1
ffffffffc0201088:	00459513          	slli	a0,a1,0x4
ffffffffc020108c:	0521                	addi	a0,a0,8
ffffffffc020108e:	9546                	add	a0,a0,a7
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
ffffffffc0201090:	4f05                	li	t5,1
ffffffffc0201092:	4e89                	li	t4,2
            for (int i = order_of_2 + 1; i <= max_order; ++i) {
ffffffffc0201094:	0008a603          	lw	a2,0(a7)
ffffffffc0201098:	0cb66163          	bltu	a2,a1,ffffffffc020115a <buddy_system_alloc_pages+0x122>
ffffffffc020109c:	87aa                	mv	a5,a0
ffffffffc020109e:	872e                	mv	a4,a1
ffffffffc02010a0:	a039                	j	ffffffffc02010ae <buddy_system_alloc_pages+0x76>
ffffffffc02010a2:	0705                	addi	a4,a4,1
ffffffffc02010a4:	0007069b          	sext.w	a3,a4
ffffffffc02010a8:	07c1                	addi	a5,a5,16
ffffffffc02010aa:	0ad66863          	bltu	a2,a3,ffffffffc020115a <buddy_system_alloc_pages+0x122>
                if (!list_empty(&(buddy_array[i]))) {
ffffffffc02010ae:	6794                	ld	a3,8(a5)
ffffffffc02010b0:	fed789e3          	beq	a5,a3,ffffffffc02010a2 <buddy_system_alloc_pages+0x6a>
    assert(n > 0 && n <= max_order);
ffffffffc02010b4:	c37d                	beqz	a4,ffffffffc020119a <buddy_system_alloc_pages+0x162>
ffffffffc02010b6:	1602                	slli	a2,a2,0x20
ffffffffc02010b8:	9201                	srli	a2,a2,0x20
ffffffffc02010ba:	0ee66063          	bltu	a2,a4,ffffffffc020119a <buddy_system_alloc_pages+0x162>
ffffffffc02010be:	00471693          	slli	a3,a4,0x4
ffffffffc02010c2:	96c6                	add	a3,a3,a7
ffffffffc02010c4:	6a94                	ld	a3,16(a3)
    assert(!list_empty(&(buddy_array[n])));
ffffffffc02010c6:	0af68a63          	beq	a3,a5,ffffffffc020117a <buddy_system_alloc_pages+0x142>
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
ffffffffc02010ca:	fff7061b          	addiw	a2,a4,-1
ffffffffc02010ce:	00cf1fbb          	sllw	t6,t5,a2
ffffffffc02010d2:	002f9793          	slli	a5,t6,0x2
ffffffffc02010d6:	97fe                	add	a5,a5,t6
ffffffffc02010d8:	078e                	slli	a5,a5,0x3
ffffffffc02010da:	17a1                	addi	a5,a5,-24
    page_a->property = n - 1;
ffffffffc02010dc:	fec6ac23          	sw	a2,-8(a3)
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
ffffffffc02010e0:	97b6                	add	a5,a5,a3
    page_b->property = n - 1;
ffffffffc02010e2:	cb90                	sw	a2,16(a5)
ffffffffc02010e4:	ff068613          	addi	a2,a3,-16
ffffffffc02010e8:	41d6302f          	amoor.d	zero,t4,(a2)
ffffffffc02010ec:	00878613          	addi	a2,a5,8 # 4008 <kern_entry-0xffffffffc01fbff8>
ffffffffc02010f0:	41d6302f          	amoor.d	zero,t4,(a2)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010f4:	0006bf83          	ld	t6,0(a3)
ffffffffc02010f8:	6690                	ld	a2,8(a3)
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
ffffffffc02010fa:	177d                	addi	a4,a4,-1
    __list_add(elm, listelm, listelm->next);
ffffffffc02010fc:	0712                	slli	a4,a4,0x4
    prev->next = next;
ffffffffc02010fe:	00cfb423          	sd	a2,8(t6)
    next->prev = prev;
ffffffffc0201102:	01f63023          	sd	t6,0(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201106:	00e88fb3          	add	t6,a7,a4
ffffffffc020110a:	010fb603          	ld	a2,16(t6)
ffffffffc020110e:	0721                	addi	a4,a4,8
    prev->next = next->prev = elm;
ffffffffc0201110:	00dfb823          	sd	a3,16(t6)
ffffffffc0201114:	9746                	add	a4,a4,a7
    elm->prev = prev;
ffffffffc0201116:	e298                	sd	a4,0(a3)
    list_add(&(page_a->page_link), &(page_b->page_link));
ffffffffc0201118:	01878713          	addi	a4,a5,24
    prev->next = next->prev = elm;
ffffffffc020111c:	e218                	sd	a4,0(a2)
ffffffffc020111e:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0201120:	f390                	sd	a2,32(a5)
    elm->prev = prev;
ffffffffc0201122:	ef94                	sd	a3,24(a5)
    return list->next == list;
ffffffffc0201124:	010e3783          	ld	a5,16(t3)
        if (!list_empty(&(buddy_array[order_of_2]))) {
ffffffffc0201128:	f66786e3          	beq	a5,t1,ffffffffc0201094 <buddy_system_alloc_pages+0x5c>
ffffffffc020112c:	833e                	mv	t1,a5
    __list_del(listelm->prev, listelm->next);
ffffffffc020112e:	00033703          	ld	a4,0(t1)
ffffffffc0201132:	00833783          	ld	a5,8(t1)
            allocated_page = le2page(list_next(&(buddy_array[order_of_2])), page_link);
ffffffffc0201136:	fe830513          	addi	a0,t1,-24
    prev->next = next;
ffffffffc020113a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020113c:	e398                	sd	a4,0(a5)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020113e:	57f5                	li	a5,-3
ffffffffc0201140:	ff030713          	addi	a4,t1,-16
ffffffffc0201144:	60f7302f          	amoand.d	zero,a5,(a4)
        nr_free -= adjusted_pages; // 减少可用页数
ffffffffc0201148:	0f88a783          	lw	a5,248(a7)
}
ffffffffc020114c:	60a2                	ld	ra,8(sp)
        nr_free -= adjusted_pages; // 减少可用页数
ffffffffc020114e:	4107883b          	subw	a6,a5,a6
ffffffffc0201152:	0f08ac23          	sw	a6,248(a7)
}
ffffffffc0201156:	0141                	addi	sp,sp,16
ffffffffc0201158:	8082                	ret
ffffffffc020115a:	60a2                	ld	ra,8(sp)
        return NULL; // 如果请求页数大于可用页数，返回NULL
ffffffffc020115c:	4501                	li	a0,0
}
ffffffffc020115e:	0141                	addi	sp,sp,16
ffffffffc0201160:	8082                	ret
ffffffffc0201162:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0201164:	00185813          	srli	a6,a6,0x1
            res = res << 1;
ffffffffc0201168:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc020116a:	fe081de3          	bnez	a6,ffffffffc0201164 <buddy_system_alloc_pages+0x12c>
            res = res << 1;
ffffffffc020116e:	883e                	mv	a6,a5
ffffffffc0201170:	b5f5                	j	ffffffffc020105c <buddy_system_alloc_pages+0x24>
    while (n >> 1)
ffffffffc0201172:	47a1                	li	a5,8
    unsigned int order = 0;
ffffffffc0201174:	4701                	li	a4,0
ffffffffc0201176:	4e01                	li	t3,0
ffffffffc0201178:	b701                	j	ffffffffc0201078 <buddy_system_alloc_pages+0x40>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc020117a:	00001697          	auipc	a3,0x1
ffffffffc020117e:	1c668693          	addi	a3,a3,454 # ffffffffc0202340 <commands+0x998>
ffffffffc0201182:	00001617          	auipc	a2,0x1
ffffffffc0201186:	e2e60613          	addi	a2,a2,-466 # ffffffffc0201fb0 <commands+0x608>
ffffffffc020118a:	05200593          	li	a1,82
ffffffffc020118e:	00001517          	auipc	a0,0x1
ffffffffc0201192:	e3a50513          	addi	a0,a0,-454 # ffffffffc0201fc8 <commands+0x620>
ffffffffc0201196:	fa5fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(n > 0 && n <= max_order);
ffffffffc020119a:	00001697          	auipc	a3,0x1
ffffffffc020119e:	18e68693          	addi	a3,a3,398 # ffffffffc0202328 <commands+0x980>
ffffffffc02011a2:	00001617          	auipc	a2,0x1
ffffffffc02011a6:	e0e60613          	addi	a2,a2,-498 # ffffffffc0201fb0 <commands+0x608>
ffffffffc02011aa:	05100593          	li	a1,81
ffffffffc02011ae:	00001517          	auipc	a0,0x1
ffffffffc02011b2:	e1a50513          	addi	a0,a0,-486 # ffffffffc0201fc8 <commands+0x620>
ffffffffc02011b6:	f85fe0ef          	jal	ra,ffffffffc020013a <__panic>
    assert(requested_pages > 0);
ffffffffc02011ba:	00001697          	auipc	a3,0x1
ffffffffc02011be:	15668693          	addi	a3,a3,342 # ffffffffc0202310 <commands+0x968>
ffffffffc02011c2:	00001617          	auipc	a2,0x1
ffffffffc02011c6:	dee60613          	addi	a2,a2,-530 # ffffffffc0201fb0 <commands+0x608>
ffffffffc02011ca:	0b000593          	li	a1,176
ffffffffc02011ce:	00001517          	auipc	a0,0x1
ffffffffc02011d2:	dfa50513          	addi	a0,a0,-518 # ffffffffc0201fc8 <commands+0x620>
ffffffffc02011d6:	f65fe0ef          	jal	ra,ffffffffc020013a <__panic>

ffffffffc02011da <strnlen>:
ffffffffc02011da:	4781                	li	a5,0
ffffffffc02011dc:	e589                	bnez	a1,ffffffffc02011e6 <strnlen+0xc>
ffffffffc02011de:	a811                	j	ffffffffc02011f2 <strnlen+0x18>
ffffffffc02011e0:	0785                	addi	a5,a5,1
ffffffffc02011e2:	00f58863          	beq	a1,a5,ffffffffc02011f2 <strnlen+0x18>
ffffffffc02011e6:	00f50733          	add	a4,a0,a5
ffffffffc02011ea:	00074703          	lbu	a4,0(a4)
ffffffffc02011ee:	fb6d                	bnez	a4,ffffffffc02011e0 <strnlen+0x6>
ffffffffc02011f0:	85be                	mv	a1,a5
ffffffffc02011f2:	852e                	mv	a0,a1
ffffffffc02011f4:	8082                	ret

ffffffffc02011f6 <strcmp>:
ffffffffc02011f6:	00054783          	lbu	a5,0(a0)
ffffffffc02011fa:	0005c703          	lbu	a4,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
ffffffffc02011fe:	cb89                	beqz	a5,ffffffffc0201210 <strcmp+0x1a>
ffffffffc0201200:	0505                	addi	a0,a0,1
ffffffffc0201202:	0585                	addi	a1,a1,1
ffffffffc0201204:	fee789e3          	beq	a5,a4,ffffffffc02011f6 <strcmp>
ffffffffc0201208:	0007851b          	sext.w	a0,a5
ffffffffc020120c:	9d19                	subw	a0,a0,a4
ffffffffc020120e:	8082                	ret
ffffffffc0201210:	4501                	li	a0,0
ffffffffc0201212:	bfed                	j	ffffffffc020120c <strcmp+0x16>

ffffffffc0201214 <strchr>:
ffffffffc0201214:	00054783          	lbu	a5,0(a0)
ffffffffc0201218:	c799                	beqz	a5,ffffffffc0201226 <strchr+0x12>
ffffffffc020121a:	00f58763          	beq	a1,a5,ffffffffc0201228 <strchr+0x14>
ffffffffc020121e:	00154783          	lbu	a5,1(a0)
ffffffffc0201222:	0505                	addi	a0,a0,1
ffffffffc0201224:	fbfd                	bnez	a5,ffffffffc020121a <strchr+0x6>
ffffffffc0201226:	4501                	li	a0,0
ffffffffc0201228:	8082                	ret

ffffffffc020122a <memset>:
ffffffffc020122a:	ca01                	beqz	a2,ffffffffc020123a <memset+0x10>
ffffffffc020122c:	962a                	add	a2,a2,a0
ffffffffc020122e:	87aa                	mv	a5,a0
ffffffffc0201230:	0785                	addi	a5,a5,1
ffffffffc0201232:	feb78fa3          	sb	a1,-1(a5)
ffffffffc0201236:	fec79de3          	bne	a5,a2,ffffffffc0201230 <memset+0x6>
ffffffffc020123a:	8082                	ret

ffffffffc020123c <printnum>:
ffffffffc020123c:	02069813          	slli	a6,a3,0x20
ffffffffc0201240:	7179                	addi	sp,sp,-48
ffffffffc0201242:	02085813          	srli	a6,a6,0x20
ffffffffc0201246:	e052                	sd	s4,0(sp)
ffffffffc0201248:	03067a33          	remu	s4,a2,a6
ffffffffc020124c:	f022                	sd	s0,32(sp)
ffffffffc020124e:	ec26                	sd	s1,24(sp)
ffffffffc0201250:	e84a                	sd	s2,16(sp)
ffffffffc0201252:	f406                	sd	ra,40(sp)
ffffffffc0201254:	e44e                	sd	s3,8(sp)
ffffffffc0201256:	84aa                	mv	s1,a0
ffffffffc0201258:	892e                	mv	s2,a1
ffffffffc020125a:	fff7041b          	addiw	s0,a4,-1
ffffffffc020125e:	2a01                	sext.w	s4,s4
ffffffffc0201260:	03067e63          	bgeu	a2,a6,ffffffffc020129c <printnum+0x60>
ffffffffc0201264:	89be                	mv	s3,a5
ffffffffc0201266:	00805763          	blez	s0,ffffffffc0201274 <printnum+0x38>
ffffffffc020126a:	347d                	addiw	s0,s0,-1
ffffffffc020126c:	85ca                	mv	a1,s2
ffffffffc020126e:	854e                	mv	a0,s3
ffffffffc0201270:	9482                	jalr	s1
ffffffffc0201272:	fc65                	bnez	s0,ffffffffc020126a <printnum+0x2e>
ffffffffc0201274:	1a02                	slli	s4,s4,0x20
ffffffffc0201276:	00001797          	auipc	a5,0x1
ffffffffc020127a:	13a78793          	addi	a5,a5,314 # ffffffffc02023b0 <buddy_pmm_manager+0x38>
ffffffffc020127e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201282:	9a3e                	add	s4,s4,a5
ffffffffc0201284:	7402                	ld	s0,32(sp)
ffffffffc0201286:	000a4503          	lbu	a0,0(s4)
ffffffffc020128a:	70a2                	ld	ra,40(sp)
ffffffffc020128c:	69a2                	ld	s3,8(sp)
ffffffffc020128e:	6a02                	ld	s4,0(sp)
ffffffffc0201290:	85ca                	mv	a1,s2
ffffffffc0201292:	87a6                	mv	a5,s1
ffffffffc0201294:	6942                	ld	s2,16(sp)
ffffffffc0201296:	64e2                	ld	s1,24(sp)
ffffffffc0201298:	6145                	addi	sp,sp,48
ffffffffc020129a:	8782                	jr	a5
ffffffffc020129c:	03065633          	divu	a2,a2,a6
ffffffffc02012a0:	8722                	mv	a4,s0
ffffffffc02012a2:	f9bff0ef          	jal	ra,ffffffffc020123c <printnum>
ffffffffc02012a6:	b7f9                	j	ffffffffc0201274 <printnum+0x38>

ffffffffc02012a8 <vprintfmt>:
ffffffffc02012a8:	7119                	addi	sp,sp,-128
ffffffffc02012aa:	f4a6                	sd	s1,104(sp)
ffffffffc02012ac:	f0ca                	sd	s2,96(sp)
ffffffffc02012ae:	ecce                	sd	s3,88(sp)
ffffffffc02012b0:	e8d2                	sd	s4,80(sp)
ffffffffc02012b2:	e4d6                	sd	s5,72(sp)
ffffffffc02012b4:	e0da                	sd	s6,64(sp)
ffffffffc02012b6:	fc5e                	sd	s7,56(sp)
ffffffffc02012b8:	f06a                	sd	s10,32(sp)
ffffffffc02012ba:	fc86                	sd	ra,120(sp)
ffffffffc02012bc:	f8a2                	sd	s0,112(sp)
ffffffffc02012be:	f862                	sd	s8,48(sp)
ffffffffc02012c0:	f466                	sd	s9,40(sp)
ffffffffc02012c2:	ec6e                	sd	s11,24(sp)
ffffffffc02012c4:	892a                	mv	s2,a0
ffffffffc02012c6:	84ae                	mv	s1,a1
ffffffffc02012c8:	8d32                	mv	s10,a2
ffffffffc02012ca:	8a36                	mv	s4,a3
ffffffffc02012cc:	02500993          	li	s3,37
ffffffffc02012d0:	5b7d                	li	s6,-1
ffffffffc02012d2:	00001a97          	auipc	s5,0x1
ffffffffc02012d6:	112a8a93          	addi	s5,s5,274 # ffffffffc02023e4 <buddy_pmm_manager+0x6c>
ffffffffc02012da:	00001b97          	auipc	s7,0x1
ffffffffc02012de:	2e6b8b93          	addi	s7,s7,742 # ffffffffc02025c0 <error_string>
ffffffffc02012e2:	000d4503          	lbu	a0,0(s10)
ffffffffc02012e6:	001d0413          	addi	s0,s10,1
ffffffffc02012ea:	01350a63          	beq	a0,s3,ffffffffc02012fe <vprintfmt+0x56>
ffffffffc02012ee:	c121                	beqz	a0,ffffffffc020132e <vprintfmt+0x86>
ffffffffc02012f0:	85a6                	mv	a1,s1
ffffffffc02012f2:	0405                	addi	s0,s0,1
ffffffffc02012f4:	9902                	jalr	s2
ffffffffc02012f6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02012fa:	ff351ae3          	bne	a0,s3,ffffffffc02012ee <vprintfmt+0x46>
ffffffffc02012fe:	00044603          	lbu	a2,0(s0)
ffffffffc0201302:	02000793          	li	a5,32
ffffffffc0201306:	4c81                	li	s9,0
ffffffffc0201308:	4881                	li	a7,0
ffffffffc020130a:	5c7d                	li	s8,-1
ffffffffc020130c:	5dfd                	li	s11,-1
ffffffffc020130e:	05500513          	li	a0,85
ffffffffc0201312:	4825                	li	a6,9
ffffffffc0201314:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201318:	0ff5f593          	zext.b	a1,a1
ffffffffc020131c:	00140d13          	addi	s10,s0,1
ffffffffc0201320:	04b56263          	bltu	a0,a1,ffffffffc0201364 <vprintfmt+0xbc>
ffffffffc0201324:	058a                	slli	a1,a1,0x2
ffffffffc0201326:	95d6                	add	a1,a1,s5
ffffffffc0201328:	4194                	lw	a3,0(a1)
ffffffffc020132a:	96d6                	add	a3,a3,s5
ffffffffc020132c:	8682                	jr	a3
ffffffffc020132e:	70e6                	ld	ra,120(sp)
ffffffffc0201330:	7446                	ld	s0,112(sp)
ffffffffc0201332:	74a6                	ld	s1,104(sp)
ffffffffc0201334:	7906                	ld	s2,96(sp)
ffffffffc0201336:	69e6                	ld	s3,88(sp)
ffffffffc0201338:	6a46                	ld	s4,80(sp)
ffffffffc020133a:	6aa6                	ld	s5,72(sp)
ffffffffc020133c:	6b06                	ld	s6,64(sp)
ffffffffc020133e:	7be2                	ld	s7,56(sp)
ffffffffc0201340:	7c42                	ld	s8,48(sp)
ffffffffc0201342:	7ca2                	ld	s9,40(sp)
ffffffffc0201344:	7d02                	ld	s10,32(sp)
ffffffffc0201346:	6de2                	ld	s11,24(sp)
ffffffffc0201348:	6109                	addi	sp,sp,128
ffffffffc020134a:	8082                	ret
ffffffffc020134c:	87b2                	mv	a5,a2
ffffffffc020134e:	00144603          	lbu	a2,1(s0)
ffffffffc0201352:	846a                	mv	s0,s10
ffffffffc0201354:	00140d13          	addi	s10,s0,1
ffffffffc0201358:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020135c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201360:	fcb572e3          	bgeu	a0,a1,ffffffffc0201324 <vprintfmt+0x7c>
ffffffffc0201364:	85a6                	mv	a1,s1
ffffffffc0201366:	02500513          	li	a0,37
ffffffffc020136a:	9902                	jalr	s2
ffffffffc020136c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201370:	8d22                	mv	s10,s0
ffffffffc0201372:	f73788e3          	beq	a5,s3,ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc0201376:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020137a:	1d7d                	addi	s10,s10,-1
ffffffffc020137c:	ff379de3          	bne	a5,s3,ffffffffc0201376 <vprintfmt+0xce>
ffffffffc0201380:	b78d                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc0201382:	fd060c1b          	addiw	s8,a2,-48
ffffffffc0201386:	00144603          	lbu	a2,1(s0)
ffffffffc020138a:	846a                	mv	s0,s10
ffffffffc020138c:	fd06069b          	addiw	a3,a2,-48
ffffffffc0201390:	0006059b          	sext.w	a1,a2
ffffffffc0201394:	02d86463          	bltu	a6,a3,ffffffffc02013bc <vprintfmt+0x114>
ffffffffc0201398:	00144603          	lbu	a2,1(s0)
ffffffffc020139c:	002c169b          	slliw	a3,s8,0x2
ffffffffc02013a0:	0186873b          	addw	a4,a3,s8
ffffffffc02013a4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013a8:	9f2d                	addw	a4,a4,a1
ffffffffc02013aa:	fd06069b          	addiw	a3,a2,-48
ffffffffc02013ae:	0405                	addi	s0,s0,1
ffffffffc02013b0:	fd070c1b          	addiw	s8,a4,-48
ffffffffc02013b4:	0006059b          	sext.w	a1,a2
ffffffffc02013b8:	fed870e3          	bgeu	a6,a3,ffffffffc0201398 <vprintfmt+0xf0>
ffffffffc02013bc:	f40ddce3          	bgez	s11,ffffffffc0201314 <vprintfmt+0x6c>
ffffffffc02013c0:	8de2                	mv	s11,s8
ffffffffc02013c2:	5c7d                	li	s8,-1
ffffffffc02013c4:	bf81                	j	ffffffffc0201314 <vprintfmt+0x6c>
ffffffffc02013c6:	fffdc693          	not	a3,s11
ffffffffc02013ca:	96fd                	srai	a3,a3,0x3f
ffffffffc02013cc:	00ddfdb3          	and	s11,s11,a3
ffffffffc02013d0:	00144603          	lbu	a2,1(s0)
ffffffffc02013d4:	2d81                	sext.w	s11,s11
ffffffffc02013d6:	846a                	mv	s0,s10
ffffffffc02013d8:	bf35                	j	ffffffffc0201314 <vprintfmt+0x6c>
ffffffffc02013da:	000a2c03          	lw	s8,0(s4)
ffffffffc02013de:	00144603          	lbu	a2,1(s0)
ffffffffc02013e2:	0a21                	addi	s4,s4,8
ffffffffc02013e4:	846a                	mv	s0,s10
ffffffffc02013e6:	bfd9                	j	ffffffffc02013bc <vprintfmt+0x114>
ffffffffc02013e8:	4705                	li	a4,1
ffffffffc02013ea:	008a0593          	addi	a1,s4,8
ffffffffc02013ee:	01174463          	blt	a4,a7,ffffffffc02013f6 <vprintfmt+0x14e>
ffffffffc02013f2:	1a088e63          	beqz	a7,ffffffffc02015ae <vprintfmt+0x306>
ffffffffc02013f6:	000a3603          	ld	a2,0(s4)
ffffffffc02013fa:	46c1                	li	a3,16
ffffffffc02013fc:	8a2e                	mv	s4,a1
ffffffffc02013fe:	2781                	sext.w	a5,a5
ffffffffc0201400:	876e                	mv	a4,s11
ffffffffc0201402:	85a6                	mv	a1,s1
ffffffffc0201404:	854a                	mv	a0,s2
ffffffffc0201406:	e37ff0ef          	jal	ra,ffffffffc020123c <printnum>
ffffffffc020140a:	bde1                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc020140c:	000a2503          	lw	a0,0(s4)
ffffffffc0201410:	85a6                	mv	a1,s1
ffffffffc0201412:	0a21                	addi	s4,s4,8
ffffffffc0201414:	9902                	jalr	s2
ffffffffc0201416:	b5f1                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc0201418:	4705                	li	a4,1
ffffffffc020141a:	008a0593          	addi	a1,s4,8
ffffffffc020141e:	01174463          	blt	a4,a7,ffffffffc0201426 <vprintfmt+0x17e>
ffffffffc0201422:	18088163          	beqz	a7,ffffffffc02015a4 <vprintfmt+0x2fc>
ffffffffc0201426:	000a3603          	ld	a2,0(s4)
ffffffffc020142a:	46a9                	li	a3,10
ffffffffc020142c:	8a2e                	mv	s4,a1
ffffffffc020142e:	bfc1                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc0201430:	00144603          	lbu	a2,1(s0)
ffffffffc0201434:	4c85                	li	s9,1
ffffffffc0201436:	846a                	mv	s0,s10
ffffffffc0201438:	bdf1                	j	ffffffffc0201314 <vprintfmt+0x6c>
ffffffffc020143a:	85a6                	mv	a1,s1
ffffffffc020143c:	02500513          	li	a0,37
ffffffffc0201440:	9902                	jalr	s2
ffffffffc0201442:	b545                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc0201444:	00144603          	lbu	a2,1(s0)
ffffffffc0201448:	2885                	addiw	a7,a7,1
ffffffffc020144a:	846a                	mv	s0,s10
ffffffffc020144c:	b5e1                	j	ffffffffc0201314 <vprintfmt+0x6c>
ffffffffc020144e:	4705                	li	a4,1
ffffffffc0201450:	008a0593          	addi	a1,s4,8
ffffffffc0201454:	01174463          	blt	a4,a7,ffffffffc020145c <vprintfmt+0x1b4>
ffffffffc0201458:	14088163          	beqz	a7,ffffffffc020159a <vprintfmt+0x2f2>
ffffffffc020145c:	000a3603          	ld	a2,0(s4)
ffffffffc0201460:	46a1                	li	a3,8
ffffffffc0201462:	8a2e                	mv	s4,a1
ffffffffc0201464:	bf69                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc0201466:	03000513          	li	a0,48
ffffffffc020146a:	85a6                	mv	a1,s1
ffffffffc020146c:	e03e                	sd	a5,0(sp)
ffffffffc020146e:	9902                	jalr	s2
ffffffffc0201470:	85a6                	mv	a1,s1
ffffffffc0201472:	07800513          	li	a0,120
ffffffffc0201476:	9902                	jalr	s2
ffffffffc0201478:	0a21                	addi	s4,s4,8
ffffffffc020147a:	6782                	ld	a5,0(sp)
ffffffffc020147c:	46c1                	li	a3,16
ffffffffc020147e:	ff8a3603          	ld	a2,-8(s4)
ffffffffc0201482:	bfb5                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc0201484:	000a3403          	ld	s0,0(s4)
ffffffffc0201488:	008a0713          	addi	a4,s4,8
ffffffffc020148c:	e03a                	sd	a4,0(sp)
ffffffffc020148e:	14040263          	beqz	s0,ffffffffc02015d2 <vprintfmt+0x32a>
ffffffffc0201492:	0fb05763          	blez	s11,ffffffffc0201580 <vprintfmt+0x2d8>
ffffffffc0201496:	02d00693          	li	a3,45
ffffffffc020149a:	0cd79163          	bne	a5,a3,ffffffffc020155c <vprintfmt+0x2b4>
ffffffffc020149e:	00044783          	lbu	a5,0(s0)
ffffffffc02014a2:	0007851b          	sext.w	a0,a5
ffffffffc02014a6:	cf85                	beqz	a5,ffffffffc02014de <vprintfmt+0x236>
ffffffffc02014a8:	00140a13          	addi	s4,s0,1
ffffffffc02014ac:	05e00413          	li	s0,94
ffffffffc02014b0:	000c4563          	bltz	s8,ffffffffc02014ba <vprintfmt+0x212>
ffffffffc02014b4:	3c7d                	addiw	s8,s8,-1
ffffffffc02014b6:	036c0263          	beq	s8,s6,ffffffffc02014da <vprintfmt+0x232>
ffffffffc02014ba:	85a6                	mv	a1,s1
ffffffffc02014bc:	0e0c8e63          	beqz	s9,ffffffffc02015b8 <vprintfmt+0x310>
ffffffffc02014c0:	3781                	addiw	a5,a5,-32
ffffffffc02014c2:	0ef47b63          	bgeu	s0,a5,ffffffffc02015b8 <vprintfmt+0x310>
ffffffffc02014c6:	03f00513          	li	a0,63
ffffffffc02014ca:	9902                	jalr	s2
ffffffffc02014cc:	000a4783          	lbu	a5,0(s4)
ffffffffc02014d0:	3dfd                	addiw	s11,s11,-1
ffffffffc02014d2:	0a05                	addi	s4,s4,1
ffffffffc02014d4:	0007851b          	sext.w	a0,a5
ffffffffc02014d8:	ffe1                	bnez	a5,ffffffffc02014b0 <vprintfmt+0x208>
ffffffffc02014da:	01b05963          	blez	s11,ffffffffc02014ec <vprintfmt+0x244>
ffffffffc02014de:	3dfd                	addiw	s11,s11,-1
ffffffffc02014e0:	85a6                	mv	a1,s1
ffffffffc02014e2:	02000513          	li	a0,32
ffffffffc02014e6:	9902                	jalr	s2
ffffffffc02014e8:	fe0d9be3          	bnez	s11,ffffffffc02014de <vprintfmt+0x236>
ffffffffc02014ec:	6a02                	ld	s4,0(sp)
ffffffffc02014ee:	bbd5                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc02014f0:	4705                	li	a4,1
ffffffffc02014f2:	008a0c93          	addi	s9,s4,8
ffffffffc02014f6:	01174463          	blt	a4,a7,ffffffffc02014fe <vprintfmt+0x256>
ffffffffc02014fa:	08088d63          	beqz	a7,ffffffffc0201594 <vprintfmt+0x2ec>
ffffffffc02014fe:	000a3403          	ld	s0,0(s4)
ffffffffc0201502:	0a044d63          	bltz	s0,ffffffffc02015bc <vprintfmt+0x314>
ffffffffc0201506:	8622                	mv	a2,s0
ffffffffc0201508:	8a66                	mv	s4,s9
ffffffffc020150a:	46a9                	li	a3,10
ffffffffc020150c:	bdcd                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc020150e:	000a2783          	lw	a5,0(s4)
ffffffffc0201512:	4719                	li	a4,6
ffffffffc0201514:	0a21                	addi	s4,s4,8
ffffffffc0201516:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020151a:	8fb5                	xor	a5,a5,a3
ffffffffc020151c:	40d786bb          	subw	a3,a5,a3
ffffffffc0201520:	02d74163          	blt	a4,a3,ffffffffc0201542 <vprintfmt+0x29a>
ffffffffc0201524:	00369793          	slli	a5,a3,0x3
ffffffffc0201528:	97de                	add	a5,a5,s7
ffffffffc020152a:	639c                	ld	a5,0(a5)
ffffffffc020152c:	cb99                	beqz	a5,ffffffffc0201542 <vprintfmt+0x29a>
ffffffffc020152e:	86be                	mv	a3,a5
ffffffffc0201530:	00001617          	auipc	a2,0x1
ffffffffc0201534:	eb060613          	addi	a2,a2,-336 # ffffffffc02023e0 <buddy_pmm_manager+0x68>
ffffffffc0201538:	85a6                	mv	a1,s1
ffffffffc020153a:	854a                	mv	a0,s2
ffffffffc020153c:	0ce000ef          	jal	ra,ffffffffc020160a <printfmt>
ffffffffc0201540:	b34d                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc0201542:	00001617          	auipc	a2,0x1
ffffffffc0201546:	e8e60613          	addi	a2,a2,-370 # ffffffffc02023d0 <buddy_pmm_manager+0x58>
ffffffffc020154a:	85a6                	mv	a1,s1
ffffffffc020154c:	854a                	mv	a0,s2
ffffffffc020154e:	0bc000ef          	jal	ra,ffffffffc020160a <printfmt>
ffffffffc0201552:	bb41                	j	ffffffffc02012e2 <vprintfmt+0x3a>
ffffffffc0201554:	00001417          	auipc	s0,0x1
ffffffffc0201558:	e7440413          	addi	s0,s0,-396 # ffffffffc02023c8 <buddy_pmm_manager+0x50>
ffffffffc020155c:	85e2                	mv	a1,s8
ffffffffc020155e:	8522                	mv	a0,s0
ffffffffc0201560:	e43e                	sd	a5,8(sp)
ffffffffc0201562:	c79ff0ef          	jal	ra,ffffffffc02011da <strnlen>
ffffffffc0201566:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020156a:	01b05b63          	blez	s11,ffffffffc0201580 <vprintfmt+0x2d8>
ffffffffc020156e:	67a2                	ld	a5,8(sp)
ffffffffc0201570:	00078a1b          	sext.w	s4,a5
ffffffffc0201574:	3dfd                	addiw	s11,s11,-1
ffffffffc0201576:	85a6                	mv	a1,s1
ffffffffc0201578:	8552                	mv	a0,s4
ffffffffc020157a:	9902                	jalr	s2
ffffffffc020157c:	fe0d9ce3          	bnez	s11,ffffffffc0201574 <vprintfmt+0x2cc>
ffffffffc0201580:	00044783          	lbu	a5,0(s0)
ffffffffc0201584:	00140a13          	addi	s4,s0,1
ffffffffc0201588:	0007851b          	sext.w	a0,a5
ffffffffc020158c:	d3a5                	beqz	a5,ffffffffc02014ec <vprintfmt+0x244>
ffffffffc020158e:	05e00413          	li	s0,94
ffffffffc0201592:	bf39                	j	ffffffffc02014b0 <vprintfmt+0x208>
ffffffffc0201594:	000a2403          	lw	s0,0(s4)
ffffffffc0201598:	b7ad                	j	ffffffffc0201502 <vprintfmt+0x25a>
ffffffffc020159a:	000a6603          	lwu	a2,0(s4)
ffffffffc020159e:	46a1                	li	a3,8
ffffffffc02015a0:	8a2e                	mv	s4,a1
ffffffffc02015a2:	bdb1                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc02015a4:	000a6603          	lwu	a2,0(s4)
ffffffffc02015a8:	46a9                	li	a3,10
ffffffffc02015aa:	8a2e                	mv	s4,a1
ffffffffc02015ac:	bd89                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc02015ae:	000a6603          	lwu	a2,0(s4)
ffffffffc02015b2:	46c1                	li	a3,16
ffffffffc02015b4:	8a2e                	mv	s4,a1
ffffffffc02015b6:	b5a1                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc02015b8:	9902                	jalr	s2
ffffffffc02015ba:	bf09                	j	ffffffffc02014cc <vprintfmt+0x224>
ffffffffc02015bc:	85a6                	mv	a1,s1
ffffffffc02015be:	02d00513          	li	a0,45
ffffffffc02015c2:	e03e                	sd	a5,0(sp)
ffffffffc02015c4:	9902                	jalr	s2
ffffffffc02015c6:	6782                	ld	a5,0(sp)
ffffffffc02015c8:	8a66                	mv	s4,s9
ffffffffc02015ca:	40800633          	neg	a2,s0
ffffffffc02015ce:	46a9                	li	a3,10
ffffffffc02015d0:	b53d                	j	ffffffffc02013fe <vprintfmt+0x156>
ffffffffc02015d2:	03b05163          	blez	s11,ffffffffc02015f4 <vprintfmt+0x34c>
ffffffffc02015d6:	02d00693          	li	a3,45
ffffffffc02015da:	f6d79de3          	bne	a5,a3,ffffffffc0201554 <vprintfmt+0x2ac>
ffffffffc02015de:	00001417          	auipc	s0,0x1
ffffffffc02015e2:	dea40413          	addi	s0,s0,-534 # ffffffffc02023c8 <buddy_pmm_manager+0x50>
ffffffffc02015e6:	02800793          	li	a5,40
ffffffffc02015ea:	02800513          	li	a0,40
ffffffffc02015ee:	00140a13          	addi	s4,s0,1
ffffffffc02015f2:	bd6d                	j	ffffffffc02014ac <vprintfmt+0x204>
ffffffffc02015f4:	00001a17          	auipc	s4,0x1
ffffffffc02015f8:	dd5a0a13          	addi	s4,s4,-555 # ffffffffc02023c9 <buddy_pmm_manager+0x51>
ffffffffc02015fc:	02800513          	li	a0,40
ffffffffc0201600:	02800793          	li	a5,40
ffffffffc0201604:	05e00413          	li	s0,94
ffffffffc0201608:	b565                	j	ffffffffc02014b0 <vprintfmt+0x208>

ffffffffc020160a <printfmt>:
ffffffffc020160a:	715d                	addi	sp,sp,-80
ffffffffc020160c:	02810313          	addi	t1,sp,40
ffffffffc0201610:	f436                	sd	a3,40(sp)
ffffffffc0201612:	869a                	mv	a3,t1
ffffffffc0201614:	ec06                	sd	ra,24(sp)
ffffffffc0201616:	f83a                	sd	a4,48(sp)
ffffffffc0201618:	fc3e                	sd	a5,56(sp)
ffffffffc020161a:	e0c2                	sd	a6,64(sp)
ffffffffc020161c:	e4c6                	sd	a7,72(sp)
ffffffffc020161e:	e41a                	sd	t1,8(sp)
ffffffffc0201620:	c89ff0ef          	jal	ra,ffffffffc02012a8 <vprintfmt>
ffffffffc0201624:	60e2                	ld	ra,24(sp)
ffffffffc0201626:	6161                	addi	sp,sp,80
ffffffffc0201628:	8082                	ret

ffffffffc020162a <readline>:
ffffffffc020162a:	715d                	addi	sp,sp,-80
ffffffffc020162c:	e486                	sd	ra,72(sp)
ffffffffc020162e:	e0a6                	sd	s1,64(sp)
ffffffffc0201630:	fc4a                	sd	s2,56(sp)
ffffffffc0201632:	f84e                	sd	s3,48(sp)
ffffffffc0201634:	f452                	sd	s4,40(sp)
ffffffffc0201636:	f056                	sd	s5,32(sp)
ffffffffc0201638:	ec5a                	sd	s6,24(sp)
ffffffffc020163a:	e85e                	sd	s7,16(sp)
ffffffffc020163c:	c901                	beqz	a0,ffffffffc020164c <readline+0x22>
ffffffffc020163e:	85aa                	mv	a1,a0
ffffffffc0201640:	00001517          	auipc	a0,0x1
ffffffffc0201644:	da050513          	addi	a0,a0,-608 # ffffffffc02023e0 <buddy_pmm_manager+0x68>
ffffffffc0201648:	a6bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020164c:	4481                	li	s1,0
ffffffffc020164e:	497d                	li	s2,31
ffffffffc0201650:	49a1                	li	s3,8
ffffffffc0201652:	4aa9                	li	s5,10
ffffffffc0201654:	4b35                	li	s6,13
ffffffffc0201656:	00005b97          	auipc	s7,0x5
ffffffffc020165a:	abab8b93          	addi	s7,s7,-1350 # ffffffffc0206110 <buf>
ffffffffc020165e:	3fe00a13          	li	s4,1022
ffffffffc0201662:	ac9fe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201666:	00054a63          	bltz	a0,ffffffffc020167a <readline+0x50>
ffffffffc020166a:	00a95a63          	bge	s2,a0,ffffffffc020167e <readline+0x54>
ffffffffc020166e:	029a5263          	bge	s4,s1,ffffffffc0201692 <readline+0x68>
ffffffffc0201672:	ab9fe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201676:	fe055ae3          	bgez	a0,ffffffffc020166a <readline+0x40>
ffffffffc020167a:	4501                	li	a0,0
ffffffffc020167c:	a091                	j	ffffffffc02016c0 <readline+0x96>
ffffffffc020167e:	03351463          	bne	a0,s3,ffffffffc02016a6 <readline+0x7c>
ffffffffc0201682:	e8a9                	bnez	s1,ffffffffc02016d4 <readline+0xaa>
ffffffffc0201684:	aa7fe0ef          	jal	ra,ffffffffc020012a <getchar>
ffffffffc0201688:	fe0549e3          	bltz	a0,ffffffffc020167a <readline+0x50>
ffffffffc020168c:	fea959e3          	bge	s2,a0,ffffffffc020167e <readline+0x54>
ffffffffc0201690:	4481                	li	s1,0
ffffffffc0201692:	e42a                	sd	a0,8(sp)
ffffffffc0201694:	a55fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc0201698:	6522                	ld	a0,8(sp)
ffffffffc020169a:	009b87b3          	add	a5,s7,s1
ffffffffc020169e:	2485                	addiw	s1,s1,1
ffffffffc02016a0:	00a78023          	sb	a0,0(a5)
ffffffffc02016a4:	bf7d                	j	ffffffffc0201662 <readline+0x38>
ffffffffc02016a6:	01550463          	beq	a0,s5,ffffffffc02016ae <readline+0x84>
ffffffffc02016aa:	fb651ce3          	bne	a0,s6,ffffffffc0201662 <readline+0x38>
ffffffffc02016ae:	a3bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc02016b2:	00005517          	auipc	a0,0x5
ffffffffc02016b6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0206110 <buf>
ffffffffc02016ba:	94aa                	add	s1,s1,a0
ffffffffc02016bc:	00048023          	sb	zero,0(s1)
ffffffffc02016c0:	60a6                	ld	ra,72(sp)
ffffffffc02016c2:	6486                	ld	s1,64(sp)
ffffffffc02016c4:	7962                	ld	s2,56(sp)
ffffffffc02016c6:	79c2                	ld	s3,48(sp)
ffffffffc02016c8:	7a22                	ld	s4,40(sp)
ffffffffc02016ca:	7a82                	ld	s5,32(sp)
ffffffffc02016cc:	6b62                	ld	s6,24(sp)
ffffffffc02016ce:	6bc2                	ld	s7,16(sp)
ffffffffc02016d0:	6161                	addi	sp,sp,80
ffffffffc02016d2:	8082                	ret
ffffffffc02016d4:	4521                	li	a0,8
ffffffffc02016d6:	a13fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
ffffffffc02016da:	34fd                	addiw	s1,s1,-1
ffffffffc02016dc:	b759                	j	ffffffffc0201662 <readline+0x38>

ffffffffc02016de <sbi_console_putchar>:
ffffffffc02016de:	4781                	li	a5,0
ffffffffc02016e0:	00005717          	auipc	a4,0x5
ffffffffc02016e4:	92873703          	ld	a4,-1752(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016e8:	88ba                	mv	a7,a4
ffffffffc02016ea:	852a                	mv	a0,a0
ffffffffc02016ec:	85be                	mv	a1,a5
ffffffffc02016ee:	863e                	mv	a2,a5
ffffffffc02016f0:	00000073          	ecall
ffffffffc02016f4:	87aa                	mv	a5,a0
ffffffffc02016f6:	8082                	ret

ffffffffc02016f8 <sbi_set_timer>:
ffffffffc02016f8:	4781                	li	a5,0
ffffffffc02016fa:	00005717          	auipc	a4,0x5
ffffffffc02016fe:	e5673703          	ld	a4,-426(a4) # ffffffffc0206550 <SBI_SET_TIMER>
ffffffffc0201702:	88ba                	mv	a7,a4
ffffffffc0201704:	852a                	mv	a0,a0
ffffffffc0201706:	85be                	mv	a1,a5
ffffffffc0201708:	863e                	mv	a2,a5
ffffffffc020170a:	00000073          	ecall
ffffffffc020170e:	87aa                	mv	a5,a0
ffffffffc0201710:	8082                	ret

ffffffffc0201712 <sbi_console_getchar>:
ffffffffc0201712:	4501                	li	a0,0
ffffffffc0201714:	00005797          	auipc	a5,0x5
ffffffffc0201718:	8ec7b783          	ld	a5,-1812(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020171c:	88be                	mv	a7,a5
ffffffffc020171e:	852a                	mv	a0,a0
ffffffffc0201720:	85aa                	mv	a1,a0
ffffffffc0201722:	862a                	mv	a2,a0
ffffffffc0201724:	00000073          	ecall
ffffffffc0201728:	852a                	mv	a0,a0
ffffffffc020172a:	2501                	sext.w	a0,a0
ffffffffc020172c:	8082                	ret
