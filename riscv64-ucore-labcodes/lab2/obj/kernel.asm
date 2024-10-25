
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
ffffffffc020004a:	039010ef          	jal	ra,ffffffffc0201882 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	84650513          	addi	a0,a0,-1978 # ffffffffc0201898 <etext+0x4>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	146010ef          	jal	ra,ffffffffc02011ac <pmm_init>

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
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	306010ef          	jal	ra,ffffffffc02013ac <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	2d0010ef          	jal	ra,ffffffffc02013ac <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	77c50513          	addi	a0,a0,1916 # ffffffffc02018b8 <etext+0x24>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	78650513          	addi	a0,a0,1926 # ffffffffc02018d8 <etext+0x44>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	73658593          	addi	a1,a1,1846 # ffffffffc0201894 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	79250513          	addi	a0,a0,1938 # ffffffffc02018f8 <etext+0x64>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <buddy_s>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	79e50513          	addi	a0,a0,1950 # ffffffffc0201918 <etext+0x84>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	3d258593          	addi	a1,a1,978 # ffffffffc0206558 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	7aa50513          	addi	a0,a0,1962 # ffffffffc0201938 <etext+0xa4>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	7bd58593          	addi	a1,a1,1981 # ffffffffc0206957 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	79c50513          	addi	a0,a0,1948 # ffffffffc0201958 <etext+0xc4>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	7be60613          	addi	a2,a2,1982 # ffffffffc0201988 <etext+0xf4>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	7ca50513          	addi	a0,a0,1994 # ffffffffc02019a0 <etext+0x10c>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	7d260613          	addi	a2,a2,2002 # ffffffffc02019b8 <etext+0x124>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	7ea58593          	addi	a1,a1,2026 # ffffffffc02019d8 <etext+0x144>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	7ea50513          	addi	a0,a0,2026 # ffffffffc02019e0 <etext+0x14c>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	7ec60613          	addi	a2,a2,2028 # ffffffffc02019f0 <etext+0x15c>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	80c58593          	addi	a1,a1,-2036 # ffffffffc0201a18 <etext+0x184>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	7cc50513          	addi	a0,a0,1996 # ffffffffc02019e0 <etext+0x14c>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	80860613          	addi	a2,a2,-2040 # ffffffffc0201a28 <etext+0x194>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	82058593          	addi	a1,a1,-2016 # ffffffffc0201a48 <etext+0x1b4>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	7b050513          	addi	a0,a0,1968 # ffffffffc02019e0 <etext+0x14c>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	7ee50513          	addi	a0,a0,2030 # ffffffffc0201a58 <etext+0x1c4>
kmonitor(struct trapframe *tf) {
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
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	7f450513          	addi	a0,a0,2036 # ffffffffc0201a80 <etext+0x1ec>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	84ec0c13          	addi	s8,s8,-1970 # ffffffffc0201af0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	7fe90913          	addi	s2,s2,2046 # ffffffffc0201aa8 <etext+0x214>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	7fe48493          	addi	s1,s1,2046 # ffffffffc0201ab0 <etext+0x21c>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	7fcb0b13          	addi	s6,s6,2044 # ffffffffc0201ab8 <etext+0x224>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	714a0a13          	addi	s4,s4,1812 # ffffffffc02019d8 <etext+0x144>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	45e010ef          	jal	ra,ffffffffc020172e <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	80ad0d13          	addi	s10,s10,-2038 # ffffffffc0201af0 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	55a010ef          	jal	ra,ffffffffc020184e <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	546010ef          	jal	ra,ffffffffc020184e <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
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
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	526010ef          	jal	ra,ffffffffc020186c <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	4e8010ef          	jal	ra,ffffffffc020186c <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	73a50513          	addi	a0,a0,1850 # ffffffffc0201ad8 <etext+0x244>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	16430313          	addi	t1,t1,356 # ffffffffc0206510 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	75e50513          	addi	a0,a0,1886 # ffffffffc0201b38 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	05050513          	addi	a0,a0,80 # ffffffffc0202440 <commands+0x950>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	3dc010ef          	jal	ra,ffffffffc02017fc <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0e07b923          	sd	zero,242(a5) # ffffffffc0206518 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	72a50513          	addi	a0,a0,1834 # ffffffffc0201b58 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	3b60106f          	j	ffffffffc02017fc <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	3920106f          	j	ffffffffc02017e2 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	3c20106f          	j	ffffffffc0201816 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
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
ffffffffc0200482:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201b78 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	70250513          	addi	a0,a0,1794 # ffffffffc0201b90 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	70c50513          	addi	a0,a0,1804 # ffffffffc0201ba8 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	71650513          	addi	a0,a0,1814 # ffffffffc0201bc0 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	72050513          	addi	a0,a0,1824 # ffffffffc0201bd8 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	72a50513          	addi	a0,a0,1834 # ffffffffc0201bf0 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	73450513          	addi	a0,a0,1844 # ffffffffc0201c08 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	73e50513          	addi	a0,a0,1854 # ffffffffc0201c20 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	74850513          	addi	a0,a0,1864 # ffffffffc0201c38 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	75250513          	addi	a0,a0,1874 # ffffffffc0201c50 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	75c50513          	addi	a0,a0,1884 # ffffffffc0201c68 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	76650513          	addi	a0,a0,1894 # ffffffffc0201c80 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	77050513          	addi	a0,a0,1904 # ffffffffc0201c98 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	77a50513          	addi	a0,a0,1914 # ffffffffc0201cb0 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	78450513          	addi	a0,a0,1924 # ffffffffc0201cc8 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	78e50513          	addi	a0,a0,1934 # ffffffffc0201ce0 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	79850513          	addi	a0,a0,1944 # ffffffffc0201cf8 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	7a250513          	addi	a0,a0,1954 # ffffffffc0201d10 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	7ac50513          	addi	a0,a0,1964 # ffffffffc0201d28 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	7b650513          	addi	a0,a0,1974 # ffffffffc0201d40 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	7c050513          	addi	a0,a0,1984 # ffffffffc0201d58 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	7ca50513          	addi	a0,a0,1994 # ffffffffc0201d70 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	7d450513          	addi	a0,a0,2004 # ffffffffc0201d88 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	7de50513          	addi	a0,a0,2014 # ffffffffc0201da0 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	7e850513          	addi	a0,a0,2024 # ffffffffc0201db8 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	7f250513          	addi	a0,a0,2034 # ffffffffc0201dd0 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	7fc50513          	addi	a0,a0,2044 # ffffffffc0201de8 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	80650513          	addi	a0,a0,-2042 # ffffffffc0201e00 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	81050513          	addi	a0,a0,-2032 # ffffffffc0201e18 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201e30 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	82450513          	addi	a0,a0,-2012 # ffffffffc0201e48 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	82a50513          	addi	a0,a0,-2006 # ffffffffc0201e60 <commands+0x370>
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
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201e78 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201e90 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	83650513          	addi	a0,a0,-1994 # ffffffffc0201ea8 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	83e50513          	addi	a0,a0,-1986 # ffffffffc0201ec0 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	84250513          	addi	a0,a0,-1982 # ffffffffc0201ed8 <commands+0x3e8>
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
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	90870713          	addi	a4,a4,-1784 # ffffffffc0201fb8 <commands+0x4c8>
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
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	88e50513          	addi	a0,a0,-1906 # ffffffffc0201f50 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	86450513          	addi	a0,a0,-1948 # ffffffffc0201f30 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201ef0 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	89050513          	addi	a0,a0,-1904 # ffffffffc0201f70 <commands+0x480>
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
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	88850513          	addi	a0,a0,-1912 # ffffffffc0201f98 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	7f650513          	addi	a0,a0,2038 # ffffffffc0201f10 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	85c50513          	addi	a0,a0,-1956 # ffffffffc0201f88 <commands+0x498>
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
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
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

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
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
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <buddy_system_init>:

static void
buddy_system_init(void)
{
    // 初始化伙伴堆链表数组中的每个free_list头
    for (int i = 0; i < MAX_BUDDY_ORDER + 1; i++)
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	81678793          	addi	a5,a5,-2026 # ffffffffc0206018 <buddy_s+0x8>
ffffffffc020080a:	00006717          	auipc	a4,0x6
ffffffffc020080e:	8fe70713          	addi	a4,a4,-1794 # ffffffffc0206108 <buddy_s+0xf8>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200812:	e79c                	sd	a5,8(a5)
ffffffffc0200814:	e39c                	sd	a5,0(a5)
ffffffffc0200816:	07c1                	addi	a5,a5,16
ffffffffc0200818:	fee79de3          	bne	a5,a4,ffffffffc0200812 <buddy_system_init+0x10>
    {
        list_init(buddy_array + i);
    }
    max_order = 0;
ffffffffc020081c:	00005797          	auipc	a5,0x5
ffffffffc0200820:	7e07aa23          	sw	zero,2036(a5) # ffffffffc0206010 <buddy_s>
    nr_free = 0;
ffffffffc0200824:	00006797          	auipc	a5,0x6
ffffffffc0200828:	8e07a223          	sw	zero,-1820(a5) # ffffffffc0206108 <buddy_s+0xf8>
    return;
}
ffffffffc020082c:	8082                	ret

ffffffffc020082e <buddy_system_nr_free_pages>:

static size_t
buddy_system_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc020082e:	00006517          	auipc	a0,0x6
ffffffffc0200832:	8da56503          	lwu	a0,-1830(a0) # ffffffffc0206108 <buddy_s+0xf8>
ffffffffc0200836:	8082                	ret

ffffffffc0200838 <buddy_system_init_memmap>:
{
ffffffffc0200838:	1141                	addi	sp,sp,-16
ffffffffc020083a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020083c:	c9cd                	beqz	a1,ffffffffc02008ee <buddy_system_init_memmap+0xb6>
    if (n & (n - 1))
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
    for (; p != base + pnum; p++)
ffffffffc0200860:	00259693          	slli	a3,a1,0x2
ffffffffc0200864:	96ae                	add	a3,a3,a1
ffffffffc0200866:	068e                	slli	a3,a3,0x3
ffffffffc0200868:	96aa                	add	a3,a3,a0
ffffffffc020086a:	02a68163          	beq	a3,a0,ffffffffc020088c <buddy_system_init_memmap+0x54>
ffffffffc020086e:	87aa                	mv	a5,a0
        p->property = -1; // 全部初始化为非头页
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
        p->flags = 0;     // 清除所有flag标记
ffffffffc0200878:	0007b423          	sd	zero,8(a5)
        p->property = -1; // 全部初始化为非头页
ffffffffc020087c:	0107a823          	sw	a6,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200880:	0007a023          	sw	zero,0(a5)
    for (; p != base + pnum; p++)
ffffffffc0200884:	02878793          	addi	a5,a5,40
ffffffffc0200888:	fef695e3          	bne	a3,a5,ffffffffc0200872 <buddy_system_init_memmap+0x3a>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc020088c:	02061693          	slli	a3,a2,0x20
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
    list_add(&(buddy_array[max_order]), &(base->page_link)); // 将第一页base插入数组的最后一个链表，作为初始化的最大块的头页
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
    base->property = max_order; // 将第一页base的property设为最大块的2幂
ffffffffc02008bc:	c910                	sw	a2,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008be:	4789                	li	a5,2
ffffffffc02008c0:	00850713          	addi	a4,a0,8
ffffffffc02008c4:	40f7302f          	amoor.d	zero,a5,(a4)
}
ffffffffc02008c8:	60a2                	ld	ra,8(sp)
ffffffffc02008ca:	0141                	addi	sp,sp,16
ffffffffc02008cc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02008ce:	00001697          	auipc	a3,0x1
ffffffffc02008d2:	75268693          	addi	a3,a3,1874 # ffffffffc0202020 <commands+0x530>
ffffffffc02008d6:	00001617          	auipc	a2,0x1
ffffffffc02008da:	71a60613          	addi	a2,a2,1818 # ffffffffc0201ff0 <commands+0x500>
ffffffffc02008de:	09b00593          	li	a1,155
ffffffffc02008e2:	00001517          	auipc	a0,0x1
ffffffffc02008e6:	72650513          	addi	a0,a0,1830 # ffffffffc0202008 <commands+0x518>
ffffffffc02008ea:	ac3ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02008ee:	00001697          	auipc	a3,0x1
ffffffffc02008f2:	6fa68693          	addi	a3,a3,1786 # ffffffffc0201fe8 <commands+0x4f8>
ffffffffc02008f6:	00001617          	auipc	a2,0x1
ffffffffc02008fa:	6fa60613          	addi	a2,a2,1786 # ffffffffc0201ff0 <commands+0x500>
ffffffffc02008fe:	09200593          	li	a1,146
ffffffffc0200902:	00001517          	auipc	a0,0x1
ffffffffc0200906:	70650513          	addi	a0,a0,1798 # ffffffffc0202008 <commands+0x518>
ffffffffc020090a:	aa3ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020090e <buddy_system_free_pages>:
{
ffffffffc020090e:	1101                	addi	sp,sp,-32
ffffffffc0200910:	ec06                	sd	ra,24(sp)
ffffffffc0200912:	e822                	sd	s0,16(sp)
ffffffffc0200914:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200916:	16058563          	beqz	a1,ffffffffc0200a80 <buddy_system_free_pages+0x172>
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc020091a:	4918                	lw	a4,16(a0)
    if (n & (n - 1))
ffffffffc020091c:	fff58793          	addi	a5,a1,-1
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc0200920:	4485                	li	s1,1
ffffffffc0200922:	00e494bb          	sllw	s1,s1,a4
    if (n & (n - 1))
ffffffffc0200926:	8fed                	and	a5,a5,a1
ffffffffc0200928:	842a                	mv	s0,a0
    unsigned int pnum = 1 << (base->property); // 块中页的数目
ffffffffc020092a:	0004861b          	sext.w	a2,s1
    if (n & (n - 1))
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
ffffffffc020094c:	ff05b583          	ld	a1,-16(a1) # ffffffffc0202938 <error_string+0x38>
ffffffffc0200950:	878d                	srai	a5,a5,0x3
ffffffffc0200952:	02b787b3          	mul	a5,a5,a1
    cprintf("BS算法将释放第NO.%d页开始的共%d页\n", page2ppn(base), pnum);
ffffffffc0200956:	00002597          	auipc	a1,0x2
ffffffffc020095a:	fea5b583          	ld	a1,-22(a1) # ffffffffc0202940 <nbase>
ffffffffc020095e:	00001517          	auipc	a0,0x1
ffffffffc0200962:	6ea50513          	addi	a0,a0,1770 # ffffffffc0202048 <commands+0x558>
ffffffffc0200966:	95be                	add	a1,a1,a5
ffffffffc0200968:	f4aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
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
    while (PageProperty(buddy) && left_block->property < max_order)
ffffffffc02009bc:	0016f713          	andi	a4,a3,1
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
    nr_free += pnum;
ffffffffc0200a60:	0f88a783          	lw	a5,248(a7)
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
ffffffffc0200a84:	56868693          	addi	a3,a3,1384 # ffffffffc0201fe8 <commands+0x4f8>
ffffffffc0200a88:	00001617          	auipc	a2,0x1
ffffffffc0200a8c:	56860613          	addi	a2,a2,1384 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200a90:	0ed00593          	li	a1,237
ffffffffc0200a94:	00001517          	auipc	a0,0x1
ffffffffc0200a98:	57450513          	addi	a0,a0,1396 # ffffffffc0202008 <commands+0x518>
ffffffffc0200a9c:	911ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200aa0:	00001697          	auipc	a3,0x1
ffffffffc0200aa4:	59068693          	addi	a3,a3,1424 # ffffffffc0202030 <commands+0x540>
ffffffffc0200aa8:	00001617          	auipc	a2,0x1
ffffffffc0200aac:	54860613          	addi	a2,a2,1352 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200ab0:	0ef00593          	li	a1,239
ffffffffc0200ab4:	00001517          	auipc	a0,0x1
ffffffffc0200ab8:	55450513          	addi	a0,a0,1364 # ffffffffc0202008 <commands+0x518>
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
ffffffffc0200ae4:	0ce7f263          	bgeu	a5,a4,ffffffffc0200ba8 <show_buddy_array.constprop.0+0xe8>
    cprintf("==================显示空闲链表数组==================\n");
ffffffffc0200ae8:	00001517          	auipc	a0,0x1
ffffffffc0200aec:	5d850513          	addi	a0,a0,1496 # ffffffffc02020c0 <commands+0x5d0>
ffffffffc0200af0:	dc2ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = left; i <= right; i++)
ffffffffc0200af4:	00005497          	auipc	s1,0x5
ffffffffc0200af8:	52448493          	addi	s1,s1,1316 # ffffffffc0206018 <buddy_s+0x8>
    bool empty = 1; // 表示空闲链表数组为空
ffffffffc0200afc:	4c05                	li	s8,1
    for (int i = left; i <= right; i++)
ffffffffc0200afe:	4901                	li	s2,0
                cprintf("No.%d的空闲链表有", i);
ffffffffc0200b00:	00001b17          	auipc	s6,0x1
ffffffffc0200b04:	600b0b13          	addi	s6,s6,1536 # ffffffffc0202100 <commands+0x610>
                cprintf("%d页 ", 1 << (p->property));
ffffffffc0200b08:	4a85                	li	s5,1
ffffffffc0200b0a:	00001a17          	auipc	s4,0x1
ffffffffc0200b0e:	60ea0a13          	addi	s4,s4,1550 # ffffffffc0202118 <commands+0x628>
                cprintf("【地址为%p】\n", p);
ffffffffc0200b12:	00001997          	auipc	s3,0x1
ffffffffc0200b16:	60e98993          	addi	s3,s3,1550 # ffffffffc0202120 <commands+0x630>
            if (i != right)
ffffffffc0200b1a:	4cb9                	li	s9,14
                cprintf("\n");
ffffffffc0200b1c:	00002d17          	auipc	s10,0x2
ffffffffc0200b20:	924d0d13          	addi	s10,s10,-1756 # ffffffffc0202440 <commands+0x950>
    for (int i = left; i <= right; i++)
ffffffffc0200b24:	4bbd                	li	s7,15
ffffffffc0200b26:	a029                	j	ffffffffc0200b30 <show_buddy_array.constprop.0+0x70>
ffffffffc0200b28:	2905                	addiw	s2,s2,1
ffffffffc0200b2a:	04c1                	addi	s1,s1,16
ffffffffc0200b2c:	05790263          	beq	s2,s7,ffffffffc0200b70 <show_buddy_array.constprop.0+0xb0>
    return listelm->next;
ffffffffc0200b30:	6480                	ld	s0,8(s1)
        if (list_next(le) != &buddy_array[i])
ffffffffc0200b32:	fe848be3          	beq	s1,s0,ffffffffc0200b28 <show_buddy_array.constprop.0+0x68>
                cprintf("No.%d的空闲链表有", i);
ffffffffc0200b36:	85ca                	mv	a1,s2
ffffffffc0200b38:	855a                	mv	a0,s6
ffffffffc0200b3a:	d78ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("%d页 ", 1 << (p->property));
ffffffffc0200b3e:	ff842583          	lw	a1,-8(s0)
ffffffffc0200b42:	8552                	mv	a0,s4
ffffffffc0200b44:	00ba95bb          	sllw	a1,s5,a1
ffffffffc0200b48:	d6aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
                cprintf("【地址为%p】\n", p);
ffffffffc0200b4c:	fe840593          	addi	a1,s0,-24
ffffffffc0200b50:	854e                	mv	a0,s3
ffffffffc0200b52:	d60ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200b56:	6400                	ld	s0,8(s0)
            while ((le = list_next(le)) != &buddy_array[i])
ffffffffc0200b58:	fc941fe3          	bne	s0,s1,ffffffffc0200b36 <show_buddy_array.constprop.0+0x76>
            empty = 0;
ffffffffc0200b5c:	4c01                	li	s8,0
            if (i != right)
ffffffffc0200b5e:	fd9905e3          	beq	s2,s9,ffffffffc0200b28 <show_buddy_array.constprop.0+0x68>
                cprintf("\n");
ffffffffc0200b62:	856a                	mv	a0,s10
    for (int i = left; i <= right; i++)
ffffffffc0200b64:	2905                	addiw	s2,s2,1
                cprintf("\n");
ffffffffc0200b66:	d4cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    for (int i = left; i <= right; i++)
ffffffffc0200b6a:	04c1                	addi	s1,s1,16
ffffffffc0200b6c:	fd7912e3          	bne	s2,s7,ffffffffc0200b30 <show_buddy_array.constprop.0+0x70>
    if (empty)
ffffffffc0200b70:	020c1563          	bnez	s8,ffffffffc0200b9a <show_buddy_array.constprop.0+0xda>
}
ffffffffc0200b74:	6446                	ld	s0,80(sp)
ffffffffc0200b76:	60e6                	ld	ra,88(sp)
ffffffffc0200b78:	64a6                	ld	s1,72(sp)
ffffffffc0200b7a:	6906                	ld	s2,64(sp)
ffffffffc0200b7c:	79e2                	ld	s3,56(sp)
ffffffffc0200b7e:	7a42                	ld	s4,48(sp)
ffffffffc0200b80:	7aa2                	ld	s5,40(sp)
ffffffffc0200b82:	7b02                	ld	s6,32(sp)
ffffffffc0200b84:	6be2                	ld	s7,24(sp)
ffffffffc0200b86:	6c42                	ld	s8,16(sp)
ffffffffc0200b88:	6ca2                	ld	s9,8(sp)
ffffffffc0200b8a:	6d02                	ld	s10,0(sp)
    cprintf("======================显示完成======================\n\n\n");
ffffffffc0200b8c:	00001517          	auipc	a0,0x1
ffffffffc0200b90:	5c450513          	addi	a0,a0,1476 # ffffffffc0202150 <commands+0x660>
}
ffffffffc0200b94:	6125                	addi	sp,sp,96
    cprintf("======================显示完成======================\n\n\n");
ffffffffc0200b96:	d1cff06f          	j	ffffffffc02000b2 <cprintf>
        cprintf("无空闲块！！！\n");
ffffffffc0200b9a:	00001517          	auipc	a0,0x1
ffffffffc0200b9e:	59e50513          	addi	a0,a0,1438 # ffffffffc0202138 <commands+0x648>
ffffffffc0200ba2:	d10ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200ba6:	b7f9                	j	ffffffffc0200b74 <show_buddy_array.constprop.0+0xb4>
    assert(left >= 0 && left <= max_order && right >= 0 && right <= max_order);
ffffffffc0200ba8:	00001697          	auipc	a3,0x1
ffffffffc0200bac:	4d068693          	addi	a3,a3,1232 # ffffffffc0202078 <commands+0x588>
ffffffffc0200bb0:	00001617          	auipc	a2,0x1
ffffffffc0200bb4:	44060613          	addi	a2,a2,1088 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200bb8:	06300593          	li	a1,99
ffffffffc0200bbc:	00001517          	auipc	a0,0x1
ffffffffc0200bc0:	44c50513          	addi	a0,a0,1100 # ffffffffc0202008 <commands+0x518>
ffffffffc0200bc4:	fe8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bc8 <buddy_system_check>:

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
buddy_system_check(void)
{
ffffffffc0200bc8:	7179                	addi	sp,sp,-48
ffffffffc0200bca:	f022                	sd	s0,32(sp)
    cprintf("总空闲块数目为：%d\n", nr_free);
ffffffffc0200bcc:	00005417          	auipc	s0,0x5
ffffffffc0200bd0:	44440413          	addi	s0,s0,1092 # ffffffffc0206010 <buddy_s>
ffffffffc0200bd4:	0f842583          	lw	a1,248(s0)
ffffffffc0200bd8:	00001517          	auipc	a0,0x1
ffffffffc0200bdc:	5b850513          	addi	a0,a0,1464 # ffffffffc0202190 <commands+0x6a0>
{
ffffffffc0200be0:	f406                	sd	ra,40(sp)
ffffffffc0200be2:	ec26                	sd	s1,24(sp)
ffffffffc0200be4:	e84a                	sd	s2,16(sp)
ffffffffc0200be6:	e44e                	sd	s3,8(sp)
    cprintf("总空闲块数目为：%d\n", nr_free);
ffffffffc0200be8:	ccaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("首先p0请求5页\n");
ffffffffc0200bec:	00001517          	auipc	a0,0x1
ffffffffc0200bf0:	5c450513          	addi	a0,a0,1476 # ffffffffc02021b0 <commands+0x6c0>
ffffffffc0200bf4:	cbeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p0 = alloc_pages(5);
ffffffffc0200bf8:	4515                	li	a0,5
ffffffffc0200bfa:	534000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200bfe:	892a                	mv	s2,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c00:	ec1ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    cprintf("然后p1请求5页\n");
ffffffffc0200c04:	00001517          	auipc	a0,0x1
ffffffffc0200c08:	5c450513          	addi	a0,a0,1476 # ffffffffc02021c8 <commands+0x6d8>
ffffffffc0200c0c:	ca6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p1 = alloc_pages(5);
ffffffffc0200c10:	4515                	li	a0,5
ffffffffc0200c12:	51c000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200c16:	84aa                	mv	s1,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c18:	ea9ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    cprintf("最后p2请求5页\n");
ffffffffc0200c1c:	00001517          	auipc	a0,0x1
ffffffffc0200c20:	5c450513          	addi	a0,a0,1476 # ffffffffc02021e0 <commands+0x6f0>
ffffffffc0200c24:	c8eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p2 = alloc_pages(5);
ffffffffc0200c28:	4515                	li	a0,5
ffffffffc0200c2a:	504000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200c2e:	89aa                	mv	s3,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200c30:	e91ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    cprintf("p0的虚拟地址0x%016lx.\n", p0);
ffffffffc0200c34:	85ca                	mv	a1,s2
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	5c250513          	addi	a0,a0,1474 # ffffffffc02021f8 <commands+0x708>
ffffffffc0200c3e:	c74ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1的虚拟地址0x%016lx.\n", p1);
ffffffffc0200c42:	85a6                	mv	a1,s1
ffffffffc0200c44:	00001517          	auipc	a0,0x1
ffffffffc0200c48:	5d450513          	addi	a0,a0,1492 # ffffffffc0202218 <commands+0x728>
ffffffffc0200c4c:	c66ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2的虚拟地址0x%016lx.\n", p2);
ffffffffc0200c50:	85ce                	mv	a1,s3
ffffffffc0200c52:	00001517          	auipc	a0,0x1
ffffffffc0200c56:	5e650513          	addi	a0,a0,1510 # ffffffffc0202238 <commands+0x748>
ffffffffc0200c5a:	c58ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c5e:	1e990a63          	beq	s2,s1,ffffffffc0200e52 <buddy_system_check+0x28a>
ffffffffc0200c62:	1f390863          	beq	s2,s3,ffffffffc0200e52 <buddy_system_check+0x28a>
ffffffffc0200c66:	1f348663          	beq	s1,s3,ffffffffc0200e52 <buddy_system_check+0x28a>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c6a:	00092783          	lw	a5,0(s2)
ffffffffc0200c6e:	22079263          	bnez	a5,ffffffffc0200e92 <buddy_system_check+0x2ca>
ffffffffc0200c72:	409c                	lw	a5,0(s1)
ffffffffc0200c74:	20079f63          	bnez	a5,ffffffffc0200e92 <buddy_system_check+0x2ca>
ffffffffc0200c78:	0009a783          	lw	a5,0(s3)
ffffffffc0200c7c:	20079b63          	bnez	a5,ffffffffc0200e92 <buddy_system_check+0x2ca>
ffffffffc0200c80:	00006797          	auipc	a5,0x6
ffffffffc0200c84:	8a87b783          	ld	a5,-1880(a5) # ffffffffc0206528 <pages>
ffffffffc0200c88:	40f90733          	sub	a4,s2,a5
ffffffffc0200c8c:	870d                	srai	a4,a4,0x3
ffffffffc0200c8e:	00002597          	auipc	a1,0x2
ffffffffc0200c92:	caa5b583          	ld	a1,-854(a1) # ffffffffc0202938 <error_string+0x38>
ffffffffc0200c96:	02b70733          	mul	a4,a4,a1
ffffffffc0200c9a:	00002617          	auipc	a2,0x2
ffffffffc0200c9e:	ca663603          	ld	a2,-858(a2) # ffffffffc0202940 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ca2:	00006697          	auipc	a3,0x6
ffffffffc0200ca6:	87e6b683          	ld	a3,-1922(a3) # ffffffffc0206520 <npage>
ffffffffc0200caa:	06b2                	slli	a3,a3,0xc
ffffffffc0200cac:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cae:	0732                	slli	a4,a4,0xc
ffffffffc0200cb0:	2cd77163          	bgeu	a4,a3,ffffffffc0200f72 <buddy_system_check+0x3aa>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cb4:	40f48733          	sub	a4,s1,a5
ffffffffc0200cb8:	870d                	srai	a4,a4,0x3
ffffffffc0200cba:	02b70733          	mul	a4,a4,a1
ffffffffc0200cbe:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cc0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cc2:	1ed77863          	bgeu	a4,a3,ffffffffc0200eb2 <buddy_system_check+0x2ea>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cc6:	40f987b3          	sub	a5,s3,a5
ffffffffc0200cca:	878d                	srai	a5,a5,0x3
ffffffffc0200ccc:	02b787b3          	mul	a5,a5,a1
ffffffffc0200cd0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200cd2:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cd4:	1ed7ff63          	bgeu	a5,a3,ffffffffc0200ed2 <buddy_system_check+0x30a>
    assert(alloc_page() == NULL);
ffffffffc0200cd8:	4505                	li	a0,1
    nr_free = 0;
ffffffffc0200cda:	00005797          	auipc	a5,0x5
ffffffffc0200cde:	4207a723          	sw	zero,1070(a5) # ffffffffc0206108 <buddy_s+0xf8>
    assert(alloc_page() == NULL);
ffffffffc0200ce2:	44c000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200ce6:	20051663          	bnez	a0,ffffffffc0200ef2 <buddy_system_check+0x32a>
    cprintf("释放p0中。。。。。。\n");
ffffffffc0200cea:	00001517          	auipc	a0,0x1
ffffffffc0200cee:	64e50513          	addi	a0,a0,1614 # ffffffffc0202338 <commands+0x848>
ffffffffc0200cf2:	bc0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p0, 5);
ffffffffc0200cf6:	4595                	li	a1,5
ffffffffc0200cf8:	854a                	mv	a0,s2
ffffffffc0200cfa:	472000ef          	jal	ra,ffffffffc020116c <free_pages>
    cprintf("释放p0后，总空闲块数目为：%d\n", nr_free); // 变成了8
ffffffffc0200cfe:	0f842583          	lw	a1,248(s0)
ffffffffc0200d02:	00001517          	auipc	a0,0x1
ffffffffc0200d06:	65650513          	addi	a0,a0,1622 # ffffffffc0202358 <commands+0x868>
ffffffffc0200d0a:	ba8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d0e:	db3ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    cprintf("释放p1中。。。。。。\n");
ffffffffc0200d12:	00001517          	auipc	a0,0x1
ffffffffc0200d16:	67650513          	addi	a0,a0,1654 # ffffffffc0202388 <commands+0x898>
ffffffffc0200d1a:	b98ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p1, 5);
ffffffffc0200d1e:	4595                	li	a1,5
ffffffffc0200d20:	8526                	mv	a0,s1
ffffffffc0200d22:	44a000ef          	jal	ra,ffffffffc020116c <free_pages>
    cprintf("释放p1后，总空闲块数目为：%d\n", nr_free); // 变成了16
ffffffffc0200d26:	0f842583          	lw	a1,248(s0)
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	67e50513          	addi	a0,a0,1662 # ffffffffc02023a8 <commands+0x8b8>
ffffffffc0200d32:	b80ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d36:	d8bff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    cprintf("释放p2中。。。。。。\n");
ffffffffc0200d3a:	00001517          	auipc	a0,0x1
ffffffffc0200d3e:	69e50513          	addi	a0,a0,1694 # ffffffffc02023d8 <commands+0x8e8>
ffffffffc0200d42:	b70ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    free_pages(p2, 5);
ffffffffc0200d46:	4595                	li	a1,5
ffffffffc0200d48:	854e                	mv	a0,s3
ffffffffc0200d4a:	422000ef          	jal	ra,ffffffffc020116c <free_pages>
    cprintf("释放p2后，总空闲块数目为：%d\n", nr_free); // 变成了24
ffffffffc0200d4e:	0f842583          	lw	a1,248(s0)
ffffffffc0200d52:	00001517          	auipc	a0,0x1
ffffffffc0200d56:	6a650513          	addi	a0,a0,1702 # ffffffffc02023f8 <commands+0x908>
ffffffffc0200d5a:	b58ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d5e:	d63ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    nr_free = 16384;
ffffffffc0200d62:	6791                	lui	a5,0x4
    struct Page *p3 = alloc_pages(16384);
ffffffffc0200d64:	6511                	lui	a0,0x4
    nr_free = 16384;
ffffffffc0200d66:	0ef42c23          	sw	a5,248(s0)
    struct Page *p3 = alloc_pages(16384);
ffffffffc0200d6a:	3c4000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200d6e:	842a                	mv	s0,a0
    cprintf("分配p3之后(16384页)\n");
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	6b850513          	addi	a0,a0,1720 # ffffffffc0202428 <commands+0x938>
ffffffffc0200d78:	b3aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d7c:	d45ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    free_pages(p3, 16384);
ffffffffc0200d80:	6591                	lui	a1,0x4
ffffffffc0200d82:	8522                	mv	a0,s0
ffffffffc0200d84:	3e8000ef          	jal	ra,ffffffffc020116c <free_pages>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200d88:	d39ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>
    basic_check();

    // 一些复杂的操作
    cprintf("==========开始测试一些复杂的例子==========\n");
ffffffffc0200d8c:	00001517          	auipc	a0,0x1
ffffffffc0200d90:	6bc50513          	addi	a0,a0,1724 # ffffffffc0202448 <commands+0x958>
ffffffffc0200d94:	b1eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("首先p0请求5页\n");
ffffffffc0200d98:	00001517          	auipc	a0,0x1
ffffffffc0200d9c:	41850513          	addi	a0,a0,1048 # ffffffffc02021b0 <commands+0x6c0>
ffffffffc0200da0:	b12ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200da4:	4515                	li	a0,5
ffffffffc0200da6:	388000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200daa:	842a                	mv	s0,a0
    assert(p0 != NULL);
ffffffffc0200dac:	1a050363          	beqz	a0,ffffffffc0200f52 <buddy_system_check+0x38a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200db0:	651c                	ld	a5,8(a0)
ffffffffc0200db2:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200db4:	8b85                	andi	a5,a5,1
ffffffffc0200db6:	16079e63          	bnez	a5,ffffffffc0200f32 <buddy_system_check+0x36a>
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200dba:	d07ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("然后p1请求15页\n");
ffffffffc0200dbe:	00001517          	auipc	a0,0x1
ffffffffc0200dc2:	6ea50513          	addi	a0,a0,1770 # ffffffffc02024a8 <commands+0x9b8>
ffffffffc0200dc6:	aecff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p1 = alloc_pages(15);
ffffffffc0200dca:	453d                	li	a0,15
ffffffffc0200dcc:	362000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200dd0:	892a                	mv	s2,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200dd2:	cefff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("最后p2请求21页\n");
ffffffffc0200dd6:	00001517          	auipc	a0,0x1
ffffffffc0200dda:	6ea50513          	addi	a0,a0,1770 # ffffffffc02024c0 <commands+0x9d0>
ffffffffc0200dde:	ad4ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    p2 = alloc_pages(21);
ffffffffc0200de2:	4555                	li	a0,21
ffffffffc0200de4:	34a000ef          	jal	ra,ffffffffc020112e <alloc_pages>
ffffffffc0200de8:	84aa                	mv	s1,a0
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200dea:	cd7ff0ef          	jal	ra,ffffffffc0200ac0 <show_buddy_array.constprop.0>

    cprintf("p0的虚拟地址0x%016lx.\n", p0);
ffffffffc0200dee:	85a2                	mv	a1,s0
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	40850513          	addi	a0,a0,1032 # ffffffffc02021f8 <commands+0x708>
ffffffffc0200df8:	abaff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p1的虚拟地址0x%016lx.\n", p1);
ffffffffc0200dfc:	85ca                	mv	a1,s2
ffffffffc0200dfe:	00001517          	auipc	a0,0x1
ffffffffc0200e02:	41a50513          	addi	a0,a0,1050 # ffffffffc0202218 <commands+0x728>
ffffffffc0200e06:	aacff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("p2的虚拟地址0x%016lx.\n", p2);
ffffffffc0200e0a:	85a6                	mv	a1,s1
ffffffffc0200e0c:	00001517          	auipc	a0,0x1
ffffffffc0200e10:	42c50513          	addi	a0,a0,1068 # ffffffffc0202238 <commands+0x748>
ffffffffc0200e14:	a9eff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    // 检查幂次正确
    assert(p0->property == 3 && p1->property == 4 && p2->property == 5);
ffffffffc0200e18:	4818                	lw	a4,16(s0)
ffffffffc0200e1a:	478d                	li	a5,3
ffffffffc0200e1c:	04f71b63          	bne	a4,a5,ffffffffc0200e72 <buddy_system_check+0x2aa>
ffffffffc0200e20:	01092703          	lw	a4,16(s2)
ffffffffc0200e24:	4791                	li	a5,4
ffffffffc0200e26:	04f71663          	bne	a4,a5,ffffffffc0200e72 <buddy_system_check+0x2aa>
ffffffffc0200e2a:	4898                	lw	a4,16(s1)
ffffffffc0200e2c:	4795                	li	a5,5
ffffffffc0200e2e:	04f71263          	bne	a4,a5,ffffffffc0200e72 <buddy_system_check+0x2aa>

    // 暂存p0，删后分配看看能不能找到
    struct Page *temp = p0;

    free_pages(p0, 5);
ffffffffc0200e32:	8522                	mv	a0,s0
ffffffffc0200e34:	4595                	li	a1,5
ffffffffc0200e36:	336000ef          	jal	ra,ffffffffc020116c <free_pages>

    p0 = alloc_pages(5);
ffffffffc0200e3a:	4515                	li	a0,5
ffffffffc0200e3c:	2f2000ef          	jal	ra,ffffffffc020112e <alloc_pages>
    assert(p0 == temp);
ffffffffc0200e40:	0ca41963          	bne	s0,a0,ffffffffc0200f12 <buddy_system_check+0x34a>
    show_buddy_array(0, MAX_BUDDY_ORDER);
}
ffffffffc0200e44:	7402                	ld	s0,32(sp)
ffffffffc0200e46:	70a2                	ld	ra,40(sp)
ffffffffc0200e48:	64e2                	ld	s1,24(sp)
ffffffffc0200e4a:	6942                	ld	s2,16(sp)
ffffffffc0200e4c:	69a2                	ld	s3,8(sp)
ffffffffc0200e4e:	6145                	addi	sp,sp,48
    show_buddy_array(0, MAX_BUDDY_ORDER);
ffffffffc0200e50:	b985                	j	ffffffffc0200ac0 <show_buddy_array.constprop.0>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e52:	00001697          	auipc	a3,0x1
ffffffffc0200e56:	40668693          	addi	a3,a3,1030 # ffffffffc0202258 <commands+0x768>
ffffffffc0200e5a:	00001617          	auipc	a2,0x1
ffffffffc0200e5e:	19660613          	addi	a2,a2,406 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200e62:	13700593          	li	a1,311
ffffffffc0200e66:	00001517          	auipc	a0,0x1
ffffffffc0200e6a:	1a250513          	addi	a0,a0,418 # ffffffffc0202008 <commands+0x518>
ffffffffc0200e6e:	d3eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0->property == 3 && p1->property == 4 && p2->property == 5);
ffffffffc0200e72:	00001697          	auipc	a3,0x1
ffffffffc0200e76:	66668693          	addi	a3,a3,1638 # ffffffffc02024d8 <commands+0x9e8>
ffffffffc0200e7a:	00001617          	auipc	a2,0x1
ffffffffc0200e7e:	17660613          	addi	a2,a2,374 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200e82:	17c00593          	li	a1,380
ffffffffc0200e86:	00001517          	auipc	a0,0x1
ffffffffc0200e8a:	18250513          	addi	a0,a0,386 # ffffffffc0202008 <commands+0x518>
ffffffffc0200e8e:	d1eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e92:	00001697          	auipc	a3,0x1
ffffffffc0200e96:	3ee68693          	addi	a3,a3,1006 # ffffffffc0202280 <commands+0x790>
ffffffffc0200e9a:	00001617          	auipc	a2,0x1
ffffffffc0200e9e:	15660613          	addi	a2,a2,342 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200ea2:	13800593          	li	a1,312
ffffffffc0200ea6:	00001517          	auipc	a0,0x1
ffffffffc0200eaa:	16250513          	addi	a0,a0,354 # ffffffffc0202008 <commands+0x518>
ffffffffc0200eae:	cfeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eb2:	00001697          	auipc	a3,0x1
ffffffffc0200eb6:	42e68693          	addi	a3,a3,1070 # ffffffffc02022e0 <commands+0x7f0>
ffffffffc0200eba:	00001617          	auipc	a2,0x1
ffffffffc0200ebe:	13660613          	addi	a2,a2,310 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200ec2:	13b00593          	li	a1,315
ffffffffc0200ec6:	00001517          	auipc	a0,0x1
ffffffffc0200eca:	14250513          	addi	a0,a0,322 # ffffffffc0202008 <commands+0x518>
ffffffffc0200ece:	cdeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ed2:	00001697          	auipc	a3,0x1
ffffffffc0200ed6:	42e68693          	addi	a3,a3,1070 # ffffffffc0202300 <commands+0x810>
ffffffffc0200eda:	00001617          	auipc	a2,0x1
ffffffffc0200ede:	11660613          	addi	a2,a2,278 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200ee2:	13c00593          	li	a1,316
ffffffffc0200ee6:	00001517          	auipc	a0,0x1
ffffffffc0200eea:	12250513          	addi	a0,a0,290 # ffffffffc0202008 <commands+0x518>
ffffffffc0200eee:	cbeff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef2:	00001697          	auipc	a3,0x1
ffffffffc0200ef6:	42e68693          	addi	a3,a3,1070 # ffffffffc0202320 <commands+0x830>
ffffffffc0200efa:	00001617          	auipc	a2,0x1
ffffffffc0200efe:	0f660613          	addi	a2,a2,246 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200f02:	14200593          	li	a1,322
ffffffffc0200f06:	00001517          	auipc	a0,0x1
ffffffffc0200f0a:	10250513          	addi	a0,a0,258 # ffffffffc0202008 <commands+0x518>
ffffffffc0200f0e:	c9eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 == temp);
ffffffffc0200f12:	00001697          	auipc	a3,0x1
ffffffffc0200f16:	60668693          	addi	a3,a3,1542 # ffffffffc0202518 <commands+0xa28>
ffffffffc0200f1a:	00001617          	auipc	a2,0x1
ffffffffc0200f1e:	0d660613          	addi	a2,a2,214 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200f22:	18400593          	li	a1,388
ffffffffc0200f26:	00001517          	auipc	a0,0x1
ffffffffc0200f2a:	0e250513          	addi	a0,a0,226 # ffffffffc0202008 <commands+0x518>
ffffffffc0200f2e:	c7eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f32:	00001697          	auipc	a3,0x1
ffffffffc0200f36:	55e68693          	addi	a3,a3,1374 # ffffffffc0202490 <commands+0x9a0>
ffffffffc0200f3a:	00001617          	auipc	a2,0x1
ffffffffc0200f3e:	0b660613          	addi	a2,a2,182 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200f42:	16c00593          	li	a1,364
ffffffffc0200f46:	00001517          	auipc	a0,0x1
ffffffffc0200f4a:	0c250513          	addi	a0,a0,194 # ffffffffc0202008 <commands+0x518>
ffffffffc0200f4e:	c5eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200f52:	00001697          	auipc	a3,0x1
ffffffffc0200f56:	52e68693          	addi	a3,a3,1326 # ffffffffc0202480 <commands+0x990>
ffffffffc0200f5a:	00001617          	auipc	a2,0x1
ffffffffc0200f5e:	09660613          	addi	a2,a2,150 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200f62:	16b00593          	li	a1,363
ffffffffc0200f66:	00001517          	auipc	a0,0x1
ffffffffc0200f6a:	0a250513          	addi	a0,a0,162 # ffffffffc0202008 <commands+0x518>
ffffffffc0200f6e:	c3eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f72:	00001697          	auipc	a3,0x1
ffffffffc0200f76:	34e68693          	addi	a3,a3,846 # ffffffffc02022c0 <commands+0x7d0>
ffffffffc0200f7a:	00001617          	auipc	a2,0x1
ffffffffc0200f7e:	07660613          	addi	a2,a2,118 # ffffffffc0201ff0 <commands+0x500>
ffffffffc0200f82:	13a00593          	li	a1,314
ffffffffc0200f86:	00001517          	auipc	a0,0x1
ffffffffc0200f8a:	08250513          	addi	a0,a0,130 # ffffffffc0202008 <commands+0x518>
ffffffffc0200f8e:	c1eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f92 <buddy_system_alloc_pages>:
{
ffffffffc0200f92:	1141                	addi	sp,sp,-16
ffffffffc0200f94:	e406                	sd	ra,8(sp)
    assert(requested_pages > 0);
ffffffffc0200f96:	14050c63          	beqz	a0,ffffffffc02010ee <buddy_system_alloc_pages+0x15c>
    if (requested_pages > nr_free)
ffffffffc0200f9a:	00005817          	auipc	a6,0x5
ffffffffc0200f9e:	07680813          	addi	a6,a6,118 # ffffffffc0206010 <buddy_s>
ffffffffc0200fa2:	0f886783          	lwu	a5,248(a6)
ffffffffc0200fa6:	832a                	mv	t1,a0
ffffffffc0200fa8:	0ea7e063          	bltu	a5,a0,ffffffffc0201088 <buddy_system_alloc_pages+0xf6>
    if (n & (n - 1))
ffffffffc0200fac:	fff50793          	addi	a5,a0,-1
ffffffffc0200fb0:	8fe9                	and	a5,a5,a0
ffffffffc0200fb2:	eff9                	bnez	a5,ffffffffc0201090 <buddy_system_alloc_pages+0xfe>
    while (n >> 1)
ffffffffc0200fb4:	00135793          	srli	a5,t1,0x1
ffffffffc0200fb8:	10078763          	beqz	a5,ffffffffc02010c6 <buddy_system_alloc_pages+0x134>
    unsigned int order = 0;
ffffffffc0200fbc:	4881                	li	a7,0
    while (n >> 1)
ffffffffc0200fbe:	8385                	srli	a5,a5,0x1
        order++;
ffffffffc0200fc0:	2885                	addiw	a7,a7,1
    while (n >> 1)
ffffffffc0200fc2:	fff5                	bnez	a5,ffffffffc0200fbe <buddy_system_alloc_pages+0x2c>
ffffffffc0200fc4:	02089793          	slli	a5,a7,0x20
ffffffffc0200fc8:	01c7de93          	srli	t4,a5,0x1c
ffffffffc0200fcc:	008e8f13          	addi	t5,t4,8
    while (!found)
ffffffffc0200fd0:	2885                	addiw	a7,a7,1
ffffffffc0200fd2:	00489e13          	slli	t3,a7,0x4
ffffffffc0200fd6:	0e21                	addi	t3,t3,8
        if (!list_empty(&(buddy_array[order_of_2])))
ffffffffc0200fd8:	9f42                	add	t5,t5,a6
ffffffffc0200fda:	9e42                	add	t3,t3,a6
    return list->next == list;
ffffffffc0200fdc:	9ec2                	add	t4,t4,a6
ffffffffc0200fde:	0008829b          	sext.w	t0,a7
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，因为是大块分割的，直接加2的n-1次幂就行
ffffffffc0200fe2:	4f85                	li	t6,1
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fe4:	4509                	li	a0,2
ffffffffc0200fe6:	010eb783          	ld	a5,16(t4)
        if (!list_empty(&(buddy_array[order_of_2])))
ffffffffc0200fea:	0aff1b63          	bne	t5,a5,ffffffffc02010a0 <buddy_system_alloc_pages+0x10e>
            for (i = order_of_2 + 1; i <= max_order; ++i)
ffffffffc0200fee:	00082583          	lw	a1,0(a6)
ffffffffc0200ff2:	0915eb63          	bltu	a1,a7,ffffffffc0201088 <buddy_system_alloc_pages+0xf6>
ffffffffc0200ff6:	8772                	mv	a4,t3
ffffffffc0200ff8:	87c6                	mv	a5,a7
ffffffffc0200ffa:	8696                	mv	a3,t0
ffffffffc0200ffc:	a039                	j	ffffffffc020100a <buddy_system_alloc_pages+0x78>
ffffffffc0200ffe:	0785                	addi	a5,a5,1
ffffffffc0201000:	0007869b          	sext.w	a3,a5
ffffffffc0201004:	0741                	addi	a4,a4,16
ffffffffc0201006:	08d5e163          	bltu	a1,a3,ffffffffc0201088 <buddy_system_alloc_pages+0xf6>
                if (!list_empty(&(buddy_array[i])))
ffffffffc020100a:	6710                	ld	a2,8(a4)
ffffffffc020100c:	fec709e3          	beq	a4,a2,ffffffffc0200ffe <buddy_system_alloc_pages+0x6c>
    assert(n > 0 && n <= max_order);
ffffffffc0201010:	cfdd                	beqz	a5,ffffffffc02010ce <buddy_system_alloc_pages+0x13c>
ffffffffc0201012:	1582                	slli	a1,a1,0x20
ffffffffc0201014:	9181                	srli	a1,a1,0x20
ffffffffc0201016:	0af5ec63          	bltu	a1,a5,ffffffffc02010ce <buddy_system_alloc_pages+0x13c>
ffffffffc020101a:	00479613          	slli	a2,a5,0x4
ffffffffc020101e:	9642                	add	a2,a2,a6
ffffffffc0201020:	6a10                	ld	a2,16(a2)
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0201022:	0ee60663          	beq	a2,a4,ffffffffc020110e <buddy_system_alloc_pages+0x17c>
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，因为是大块分割的，直接加2的n-1次幂就行
ffffffffc0201026:	fff6859b          	addiw	a1,a3,-1
ffffffffc020102a:	00bf93bb          	sllw	t2,t6,a1
ffffffffc020102e:	00239713          	slli	a4,t2,0x2
ffffffffc0201032:	971e                	add	a4,a4,t2
ffffffffc0201034:	070e                	slli	a4,a4,0x3
ffffffffc0201036:	1721                	addi	a4,a4,-24
    page_a->property = n - 1;
ffffffffc0201038:	feb62c23          	sw	a1,-8(a2)
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，因为是大块分割的，直接加2的n-1次幂就行
ffffffffc020103c:	9732                	add	a4,a4,a2
    page_b->property = n - 1;
ffffffffc020103e:	cb0c                	sw	a1,16(a4)
ffffffffc0201040:	ff060593          	addi	a1,a2,-16
ffffffffc0201044:	40a5b02f          	amoor.d	zero,a0,(a1)
ffffffffc0201048:	00870593          	addi	a1,a4,8
ffffffffc020104c:	40a5b02f          	amoor.d	zero,a0,(a1)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201050:	00063383          	ld	t2,0(a2)
ffffffffc0201054:	660c                	ld	a1,8(a2)
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
ffffffffc0201056:	17fd                	addi	a5,a5,-1
    __list_add(elm, listelm, listelm->next);
ffffffffc0201058:	0792                	slli	a5,a5,0x4
    prev->next = next;
ffffffffc020105a:	00b3b423          	sd	a1,8(t2)
    next->prev = prev;
ffffffffc020105e:	0075b023          	sd	t2,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
    __list_add(elm, listelm, listelm->next);
ffffffffc0201062:	00f803b3          	add	t2,a6,a5
ffffffffc0201066:	0103b583          	ld	a1,16(t2)
ffffffffc020106a:	07a1                	addi	a5,a5,8
    prev->next = next->prev = elm;
ffffffffc020106c:	00c3b823          	sd	a2,16(t2)
ffffffffc0201070:	97c2                	add	a5,a5,a6
    elm->prev = prev;
ffffffffc0201072:	e21c                	sd	a5,0(a2)
    list_add(&(page_a->page_link), &(page_b->page_link));
ffffffffc0201074:	01870793          	addi	a5,a4,24
    prev->next = next->prev = elm;
ffffffffc0201078:	e19c                	sd	a5,0(a1)
            if (i > max_order)
ffffffffc020107a:	00082383          	lw	t2,0(a6)
ffffffffc020107e:	e61c                	sd	a5,8(a2)
    elm->next = next;
ffffffffc0201080:	f30c                	sd	a1,32(a4)
    elm->prev = prev;
ffffffffc0201082:	ef10                	sd	a2,24(a4)
ffffffffc0201084:	f6d3f1e3          	bgeu	t2,a3,ffffffffc0200fe6 <buddy_system_alloc_pages+0x54>
}
ffffffffc0201088:	60a2                	ld	ra,8(sp)
        return NULL;
ffffffffc020108a:	4501                	li	a0,0
}
ffffffffc020108c:	0141                	addi	sp,sp,16
ffffffffc020108e:	8082                	ret
ffffffffc0201090:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0201092:	00135313          	srli	t1,t1,0x1
            res = res << 1;
ffffffffc0201096:	0786                	slli	a5,a5,0x1
        while (n)
ffffffffc0201098:	fe031de3          	bnez	t1,ffffffffc0201092 <buddy_system_alloc_pages+0x100>
            res = res << 1;
ffffffffc020109c:	833e                	mv	t1,a5
ffffffffc020109e:	bf19                	j	ffffffffc0200fb4 <buddy_system_alloc_pages+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc02010a0:	6798                	ld	a4,8(a5)
ffffffffc02010a2:	6394                	ld	a3,0(a5)
            allocated_page = le2page(list_next(&(buddy_array[order_of_2])), page_link);
ffffffffc02010a4:	fe878513          	addi	a0,a5,-24 # 3fe8 <kern_entry-0xffffffffc01fc018>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010a8:	17c1                	addi	a5,a5,-16
    prev->next = next;
ffffffffc02010aa:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02010ac:	e314                	sd	a3,0(a4)
ffffffffc02010ae:	5775                	li	a4,-3
ffffffffc02010b0:	60e7b02f          	amoand.d	zero,a4,(a5)
        nr_free -= adjusted_pages;
ffffffffc02010b4:	0f882783          	lw	a5,248(a6)
}
ffffffffc02010b8:	60a2                	ld	ra,8(sp)
        nr_free -= adjusted_pages;
ffffffffc02010ba:	4067833b          	subw	t1,a5,t1
ffffffffc02010be:	0e682c23          	sw	t1,248(a6)
}
ffffffffc02010c2:	0141                	addi	sp,sp,16
ffffffffc02010c4:	8082                	ret
    while (n >> 1)
ffffffffc02010c6:	4f21                	li	t5,8
    unsigned int order = 0;
ffffffffc02010c8:	4881                	li	a7,0
ffffffffc02010ca:	4e81                	li	t4,0
ffffffffc02010cc:	b711                	j	ffffffffc0200fd0 <buddy_system_alloc_pages+0x3e>
    assert(n > 0 && n <= max_order);
ffffffffc02010ce:	00001697          	auipc	a3,0x1
ffffffffc02010d2:	47268693          	addi	a3,a3,1138 # ffffffffc0202540 <commands+0xa50>
ffffffffc02010d6:	00001617          	auipc	a2,0x1
ffffffffc02010da:	f1a60613          	addi	a2,a2,-230 # ffffffffc0201ff0 <commands+0x500>
ffffffffc02010de:	04a00593          	li	a1,74
ffffffffc02010e2:	00001517          	auipc	a0,0x1
ffffffffc02010e6:	f2650513          	addi	a0,a0,-218 # ffffffffc0202008 <commands+0x518>
ffffffffc02010ea:	ac2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(requested_pages > 0);
ffffffffc02010ee:	00001697          	auipc	a3,0x1
ffffffffc02010f2:	43a68693          	addi	a3,a3,1082 # ffffffffc0202528 <commands+0xa38>
ffffffffc02010f6:	00001617          	auipc	a2,0x1
ffffffffc02010fa:	efa60613          	addi	a2,a2,-262 # ffffffffc0201ff0 <commands+0x500>
ffffffffc02010fe:	0ac00593          	li	a1,172
ffffffffc0201102:	00001517          	auipc	a0,0x1
ffffffffc0201106:	f0650513          	addi	a0,a0,-250 # ffffffffc0202008 <commands+0x518>
ffffffffc020110a:	aa2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc020110e:	00001697          	auipc	a3,0x1
ffffffffc0201112:	44a68693          	addi	a3,a3,1098 # ffffffffc0202558 <commands+0xa68>
ffffffffc0201116:	00001617          	auipc	a2,0x1
ffffffffc020111a:	eda60613          	addi	a2,a2,-294 # ffffffffc0201ff0 <commands+0x500>
ffffffffc020111e:	04b00593          	li	a1,75
ffffffffc0201122:	00001517          	auipc	a0,0x1
ffffffffc0201126:	ee650513          	addi	a0,a0,-282 # ffffffffc0202008 <commands+0x518>
ffffffffc020112a:	a82ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020112e <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020112e:	100027f3          	csrr	a5,sstatus
ffffffffc0201132:	8b89                	andi	a5,a5,2
ffffffffc0201134:	e799                	bnez	a5,ffffffffc0201142 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201136:	00005797          	auipc	a5,0x5
ffffffffc020113a:	3fa7b783          	ld	a5,1018(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc020113e:	6f9c                	ld	a5,24(a5)
ffffffffc0201140:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201142:	1141                	addi	sp,sp,-16
ffffffffc0201144:	e406                	sd	ra,8(sp)
ffffffffc0201146:	e022                	sd	s0,0(sp)
ffffffffc0201148:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020114a:	b14ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020114e:	00005797          	auipc	a5,0x5
ffffffffc0201152:	3e27b783          	ld	a5,994(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0201156:	6f9c                	ld	a5,24(a5)
ffffffffc0201158:	8522                	mv	a0,s0
ffffffffc020115a:	9782                	jalr	a5
ffffffffc020115c:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc020115e:	afaff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201162:	60a2                	ld	ra,8(sp)
ffffffffc0201164:	8522                	mv	a0,s0
ffffffffc0201166:	6402                	ld	s0,0(sp)
ffffffffc0201168:	0141                	addi	sp,sp,16
ffffffffc020116a:	8082                	ret

ffffffffc020116c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020116c:	100027f3          	csrr	a5,sstatus
ffffffffc0201170:	8b89                	andi	a5,a5,2
ffffffffc0201172:	e799                	bnez	a5,ffffffffc0201180 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201174:	00005797          	auipc	a5,0x5
ffffffffc0201178:	3bc7b783          	ld	a5,956(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc020117c:	739c                	ld	a5,32(a5)
ffffffffc020117e:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201180:	1101                	addi	sp,sp,-32
ffffffffc0201182:	ec06                	sd	ra,24(sp)
ffffffffc0201184:	e822                	sd	s0,16(sp)
ffffffffc0201186:	e426                	sd	s1,8(sp)
ffffffffc0201188:	842a                	mv	s0,a0
ffffffffc020118a:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020118c:	ad2ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201190:	00005797          	auipc	a5,0x5
ffffffffc0201194:	3a07b783          	ld	a5,928(a5) # ffffffffc0206530 <pmm_manager>
ffffffffc0201198:	739c                	ld	a5,32(a5)
ffffffffc020119a:	85a6                	mv	a1,s1
ffffffffc020119c:	8522                	mv	a0,s0
ffffffffc020119e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02011a0:	6442                	ld	s0,16(sp)
ffffffffc02011a2:	60e2                	ld	ra,24(sp)
ffffffffc02011a4:	64a2                	ld	s1,8(sp)
ffffffffc02011a6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02011a8:	ab0ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc02011ac <pmm_init>:
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc02011ac:	00001797          	auipc	a5,0x1
ffffffffc02011b0:	3e478793          	addi	a5,a5,996 # ffffffffc0202590 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02011b4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02011b6:	1101                	addi	sp,sp,-32
ffffffffc02011b8:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02011ba:	00001517          	auipc	a0,0x1
ffffffffc02011be:	40e50513          	addi	a0,a0,1038 # ffffffffc02025c8 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc02011c2:	00005497          	auipc	s1,0x5
ffffffffc02011c6:	36e48493          	addi	s1,s1,878 # ffffffffc0206530 <pmm_manager>
void pmm_init(void) {
ffffffffc02011ca:	ec06                	sd	ra,24(sp)
ffffffffc02011cc:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager; // 更改为使用 buddy_pmm_manager
ffffffffc02011ce:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02011d0:	ee3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02011d4:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011d6:	00005417          	auipc	s0,0x5
ffffffffc02011da:	37240413          	addi	s0,s0,882 # ffffffffc0206548 <va_pa_offset>
    pmm_manager->init();
ffffffffc02011de:	679c                	ld	a5,8(a5)
ffffffffc02011e0:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011e2:	57f5                	li	a5,-3
ffffffffc02011e4:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02011e6:	00001517          	auipc	a0,0x1
ffffffffc02011ea:	3fa50513          	addi	a0,a0,1018 # ffffffffc02025e0 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011ee:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc02011f0:	ec3fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02011f4:	46c5                	li	a3,17
ffffffffc02011f6:	06ee                	slli	a3,a3,0x1b
ffffffffc02011f8:	40100613          	li	a2,1025
ffffffffc02011fc:	16fd                	addi	a3,a3,-1
ffffffffc02011fe:	07e005b7          	lui	a1,0x7e00
ffffffffc0201202:	0656                	slli	a2,a2,0x15
ffffffffc0201204:	00001517          	auipc	a0,0x1
ffffffffc0201208:	3f450513          	addi	a0,a0,1012 # ffffffffc02025f8 <buddy_pmm_manager+0x68>
ffffffffc020120c:	ea7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201210:	777d                	lui	a4,0xfffff
ffffffffc0201212:	00006797          	auipc	a5,0x6
ffffffffc0201216:	34578793          	addi	a5,a5,837 # ffffffffc0207557 <end+0xfff>
ffffffffc020121a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020121c:	00005517          	auipc	a0,0x5
ffffffffc0201220:	30450513          	addi	a0,a0,772 # ffffffffc0206520 <npage>
ffffffffc0201224:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201228:	00005597          	auipc	a1,0x5
ffffffffc020122c:	30058593          	addi	a1,a1,768 # ffffffffc0206528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201230:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201232:	e19c                	sd	a5,0(a1)
ffffffffc0201234:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201236:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201238:	4885                	li	a7,1
ffffffffc020123a:	fff80837          	lui	a6,0xfff80
ffffffffc020123e:	a011                	j	ffffffffc0201242 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0201240:	619c                	ld	a5,0(a1)
ffffffffc0201242:	97b6                	add	a5,a5,a3
ffffffffc0201244:	07a1                	addi	a5,a5,8
ffffffffc0201246:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020124a:	611c                	ld	a5,0(a0)
ffffffffc020124c:	0705                	addi	a4,a4,1
ffffffffc020124e:	02868693          	addi	a3,a3,40
ffffffffc0201252:	01078633          	add	a2,a5,a6
ffffffffc0201256:	fec765e3          	bltu	a4,a2,ffffffffc0201240 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020125a:	6190                	ld	a2,0(a1)
ffffffffc020125c:	00279713          	slli	a4,a5,0x2
ffffffffc0201260:	973e                	add	a4,a4,a5
ffffffffc0201262:	fec006b7          	lui	a3,0xfec00
ffffffffc0201266:	070e                	slli	a4,a4,0x3
ffffffffc0201268:	96b2                	add	a3,a3,a2
ffffffffc020126a:	96ba                	add	a3,a3,a4
ffffffffc020126c:	c0200737          	lui	a4,0xc0200
ffffffffc0201270:	08e6ef63          	bltu	a3,a4,ffffffffc020130e <pmm_init+0x162>
ffffffffc0201274:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201276:	45c5                	li	a1,17
ffffffffc0201278:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020127a:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020127c:	04b6e863          	bltu	a3,a1,ffffffffc02012cc <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201280:	609c                	ld	a5,0(s1)
ffffffffc0201282:	7b9c                	ld	a5,48(a5)
ffffffffc0201284:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201286:	00001517          	auipc	a0,0x1
ffffffffc020128a:	40a50513          	addi	a0,a0,1034 # ffffffffc0202690 <buddy_pmm_manager+0x100>
ffffffffc020128e:	e25fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201292:	00004597          	auipc	a1,0x4
ffffffffc0201296:	d6e58593          	addi	a1,a1,-658 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020129a:	00005797          	auipc	a5,0x5
ffffffffc020129e:	2ab7b323          	sd	a1,678(a5) # ffffffffc0206540 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012a2:	c02007b7          	lui	a5,0xc0200
ffffffffc02012a6:	08f5e063          	bltu	a1,a5,ffffffffc0201326 <pmm_init+0x17a>
ffffffffc02012aa:	6010                	ld	a2,0(s0)
}
ffffffffc02012ac:	6442                	ld	s0,16(sp)
ffffffffc02012ae:	60e2                	ld	ra,24(sp)
ffffffffc02012b0:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02012b2:	40c58633          	sub	a2,a1,a2
ffffffffc02012b6:	00005797          	auipc	a5,0x5
ffffffffc02012ba:	28c7b123          	sd	a2,642(a5) # ffffffffc0206538 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	3f250513          	addi	a0,a0,1010 # ffffffffc02026b0 <buddy_pmm_manager+0x120>
}
ffffffffc02012c6:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012c8:	debfe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02012cc:	6705                	lui	a4,0x1
ffffffffc02012ce:	177d                	addi	a4,a4,-1
ffffffffc02012d0:	96ba                	add	a3,a3,a4
ffffffffc02012d2:	777d                	lui	a4,0xfffff
ffffffffc02012d4:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02012d6:	00c6d513          	srli	a0,a3,0xc
ffffffffc02012da:	00f57e63          	bgeu	a0,a5,ffffffffc02012f6 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02012de:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02012e0:	982a                	add	a6,a6,a0
ffffffffc02012e2:	00281513          	slli	a0,a6,0x2
ffffffffc02012e6:	9542                	add	a0,a0,a6
ffffffffc02012e8:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02012ea:	8d95                	sub	a1,a1,a3
ffffffffc02012ec:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02012ee:	81b1                	srli	a1,a1,0xc
ffffffffc02012f0:	9532                	add	a0,a0,a2
ffffffffc02012f2:	9782                	jalr	a5
}
ffffffffc02012f4:	b771                	j	ffffffffc0201280 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc02012f6:	00001617          	auipc	a2,0x1
ffffffffc02012fa:	36a60613          	addi	a2,a2,874 # ffffffffc0202660 <buddy_pmm_manager+0xd0>
ffffffffc02012fe:	06b00593          	li	a1,107
ffffffffc0201302:	00001517          	auipc	a0,0x1
ffffffffc0201306:	37e50513          	addi	a0,a0,894 # ffffffffc0202680 <buddy_pmm_manager+0xf0>
ffffffffc020130a:	8a2ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020130e:	00001617          	auipc	a2,0x1
ffffffffc0201312:	31a60613          	addi	a2,a2,794 # ffffffffc0202628 <buddy_pmm_manager+0x98>
ffffffffc0201316:	07500593          	li	a1,117
ffffffffc020131a:	00001517          	auipc	a0,0x1
ffffffffc020131e:	33650513          	addi	a0,a0,822 # ffffffffc0202650 <buddy_pmm_manager+0xc0>
ffffffffc0201322:	88aff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201326:	86ae                	mv	a3,a1
ffffffffc0201328:	00001617          	auipc	a2,0x1
ffffffffc020132c:	30060613          	addi	a2,a2,768 # ffffffffc0202628 <buddy_pmm_manager+0x98>
ffffffffc0201330:	09000593          	li	a1,144
ffffffffc0201334:	00001517          	auipc	a0,0x1
ffffffffc0201338:	31c50513          	addi	a0,a0,796 # ffffffffc0202650 <buddy_pmm_manager+0xc0>
ffffffffc020133c:	870ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201340 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201340:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201344:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201346:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020134a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020134c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201350:	f022                	sd	s0,32(sp)
ffffffffc0201352:	ec26                	sd	s1,24(sp)
ffffffffc0201354:	e84a                	sd	s2,16(sp)
ffffffffc0201356:	f406                	sd	ra,40(sp)
ffffffffc0201358:	e44e                	sd	s3,8(sp)
ffffffffc020135a:	84aa                	mv	s1,a0
ffffffffc020135c:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020135e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201362:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201364:	03067e63          	bgeu	a2,a6,ffffffffc02013a0 <printnum+0x60>
ffffffffc0201368:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020136a:	00805763          	blez	s0,ffffffffc0201378 <printnum+0x38>
ffffffffc020136e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201370:	85ca                	mv	a1,s2
ffffffffc0201372:	854e                	mv	a0,s3
ffffffffc0201374:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201376:	fc65                	bnez	s0,ffffffffc020136e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201378:	1a02                	slli	s4,s4,0x20
ffffffffc020137a:	00001797          	auipc	a5,0x1
ffffffffc020137e:	37678793          	addi	a5,a5,886 # ffffffffc02026f0 <buddy_pmm_manager+0x160>
ffffffffc0201382:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201386:	9a3e                	add	s4,s4,a5
}
ffffffffc0201388:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020138a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020138e:	70a2                	ld	ra,40(sp)
ffffffffc0201390:	69a2                	ld	s3,8(sp)
ffffffffc0201392:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201394:	85ca                	mv	a1,s2
ffffffffc0201396:	87a6                	mv	a5,s1
}
ffffffffc0201398:	6942                	ld	s2,16(sp)
ffffffffc020139a:	64e2                	ld	s1,24(sp)
ffffffffc020139c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020139e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02013a0:	03065633          	divu	a2,a2,a6
ffffffffc02013a4:	8722                	mv	a4,s0
ffffffffc02013a6:	f9bff0ef          	jal	ra,ffffffffc0201340 <printnum>
ffffffffc02013aa:	b7f9                	j	ffffffffc0201378 <printnum+0x38>

ffffffffc02013ac <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02013ac:	7119                	addi	sp,sp,-128
ffffffffc02013ae:	f4a6                	sd	s1,104(sp)
ffffffffc02013b0:	f0ca                	sd	s2,96(sp)
ffffffffc02013b2:	ecce                	sd	s3,88(sp)
ffffffffc02013b4:	e8d2                	sd	s4,80(sp)
ffffffffc02013b6:	e4d6                	sd	s5,72(sp)
ffffffffc02013b8:	e0da                	sd	s6,64(sp)
ffffffffc02013ba:	fc5e                	sd	s7,56(sp)
ffffffffc02013bc:	f06a                	sd	s10,32(sp)
ffffffffc02013be:	fc86                	sd	ra,120(sp)
ffffffffc02013c0:	f8a2                	sd	s0,112(sp)
ffffffffc02013c2:	f862                	sd	s8,48(sp)
ffffffffc02013c4:	f466                	sd	s9,40(sp)
ffffffffc02013c6:	ec6e                	sd	s11,24(sp)
ffffffffc02013c8:	892a                	mv	s2,a0
ffffffffc02013ca:	84ae                	mv	s1,a1
ffffffffc02013cc:	8d32                	mv	s10,a2
ffffffffc02013ce:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013d0:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013d4:	5b7d                	li	s6,-1
ffffffffc02013d6:	00001a97          	auipc	s5,0x1
ffffffffc02013da:	34ea8a93          	addi	s5,s5,846 # ffffffffc0202724 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013de:	00001b97          	auipc	s7,0x1
ffffffffc02013e2:	522b8b93          	addi	s7,s7,1314 # ffffffffc0202900 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013e6:	000d4503          	lbu	a0,0(s10)
ffffffffc02013ea:	001d0413          	addi	s0,s10,1
ffffffffc02013ee:	01350a63          	beq	a0,s3,ffffffffc0201402 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02013f2:	c121                	beqz	a0,ffffffffc0201432 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02013f4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013f6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013f8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013fa:	fff44503          	lbu	a0,-1(s0)
ffffffffc02013fe:	ff351ae3          	bne	a0,s3,ffffffffc02013f2 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201402:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201406:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020140a:	4c81                	li	s9,0
ffffffffc020140c:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020140e:	5c7d                	li	s8,-1
ffffffffc0201410:	5dfd                	li	s11,-1
ffffffffc0201412:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201416:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201418:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020141c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201420:	00140d13          	addi	s10,s0,1
ffffffffc0201424:	04b56263          	bltu	a0,a1,ffffffffc0201468 <vprintfmt+0xbc>
ffffffffc0201428:	058a                	slli	a1,a1,0x2
ffffffffc020142a:	95d6                	add	a1,a1,s5
ffffffffc020142c:	4194                	lw	a3,0(a1)
ffffffffc020142e:	96d6                	add	a3,a3,s5
ffffffffc0201430:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201432:	70e6                	ld	ra,120(sp)
ffffffffc0201434:	7446                	ld	s0,112(sp)
ffffffffc0201436:	74a6                	ld	s1,104(sp)
ffffffffc0201438:	7906                	ld	s2,96(sp)
ffffffffc020143a:	69e6                	ld	s3,88(sp)
ffffffffc020143c:	6a46                	ld	s4,80(sp)
ffffffffc020143e:	6aa6                	ld	s5,72(sp)
ffffffffc0201440:	6b06                	ld	s6,64(sp)
ffffffffc0201442:	7be2                	ld	s7,56(sp)
ffffffffc0201444:	7c42                	ld	s8,48(sp)
ffffffffc0201446:	7ca2                	ld	s9,40(sp)
ffffffffc0201448:	7d02                	ld	s10,32(sp)
ffffffffc020144a:	6de2                	ld	s11,24(sp)
ffffffffc020144c:	6109                	addi	sp,sp,128
ffffffffc020144e:	8082                	ret
            padc = '0';
ffffffffc0201450:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0201452:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201456:	846a                	mv	s0,s10
ffffffffc0201458:	00140d13          	addi	s10,s0,1
ffffffffc020145c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201460:	0ff5f593          	zext.b	a1,a1
ffffffffc0201464:	fcb572e3          	bgeu	a0,a1,ffffffffc0201428 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201468:	85a6                	mv	a1,s1
ffffffffc020146a:	02500513          	li	a0,37
ffffffffc020146e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201470:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201474:	8d22                	mv	s10,s0
ffffffffc0201476:	f73788e3          	beq	a5,s3,ffffffffc02013e6 <vprintfmt+0x3a>
ffffffffc020147a:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020147e:	1d7d                	addi	s10,s10,-1
ffffffffc0201480:	ff379de3          	bne	a5,s3,ffffffffc020147a <vprintfmt+0xce>
ffffffffc0201484:	b78d                	j	ffffffffc02013e6 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0201486:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020148a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020148e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201490:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201494:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201498:	02d86463          	bltu	a6,a3,ffffffffc02014c0 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc020149c:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02014a0:	002c169b          	slliw	a3,s8,0x2
ffffffffc02014a4:	0186873b          	addw	a4,a3,s8
ffffffffc02014a8:	0017171b          	slliw	a4,a4,0x1
ffffffffc02014ac:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02014ae:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02014b2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02014b4:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02014b8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02014bc:	fed870e3          	bgeu	a6,a3,ffffffffc020149c <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02014c0:	f40ddce3          	bgez	s11,ffffffffc0201418 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02014c4:	8de2                	mv	s11,s8
ffffffffc02014c6:	5c7d                	li	s8,-1
ffffffffc02014c8:	bf81                	j	ffffffffc0201418 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02014ca:	fffdc693          	not	a3,s11
ffffffffc02014ce:	96fd                	srai	a3,a3,0x3f
ffffffffc02014d0:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014d4:	00144603          	lbu	a2,1(s0)
ffffffffc02014d8:	2d81                	sext.w	s11,s11
ffffffffc02014da:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014dc:	bf35                	j	ffffffffc0201418 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02014de:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014e2:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02014e6:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014e8:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02014ea:	bfd9                	j	ffffffffc02014c0 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02014ec:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014ee:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014f2:	01174463          	blt	a4,a7,ffffffffc02014fa <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02014f6:	1a088e63          	beqz	a7,ffffffffc02016b2 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02014fa:	000a3603          	ld	a2,0(s4)
ffffffffc02014fe:	46c1                	li	a3,16
ffffffffc0201500:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201502:	2781                	sext.w	a5,a5
ffffffffc0201504:	876e                	mv	a4,s11
ffffffffc0201506:	85a6                	mv	a1,s1
ffffffffc0201508:	854a                	mv	a0,s2
ffffffffc020150a:	e37ff0ef          	jal	ra,ffffffffc0201340 <printnum>
            break;
ffffffffc020150e:	bde1                	j	ffffffffc02013e6 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201510:	000a2503          	lw	a0,0(s4)
ffffffffc0201514:	85a6                	mv	a1,s1
ffffffffc0201516:	0a21                	addi	s4,s4,8
ffffffffc0201518:	9902                	jalr	s2
            break;
ffffffffc020151a:	b5f1                	j	ffffffffc02013e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020151c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020151e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201522:	01174463          	blt	a4,a7,ffffffffc020152a <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201526:	18088163          	beqz	a7,ffffffffc02016a8 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020152a:	000a3603          	ld	a2,0(s4)
ffffffffc020152e:	46a9                	li	a3,10
ffffffffc0201530:	8a2e                	mv	s4,a1
ffffffffc0201532:	bfc1                	j	ffffffffc0201502 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201534:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201538:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020153a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020153c:	bdf1                	j	ffffffffc0201418 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020153e:	85a6                	mv	a1,s1
ffffffffc0201540:	02500513          	li	a0,37
ffffffffc0201544:	9902                	jalr	s2
            break;
ffffffffc0201546:	b545                	j	ffffffffc02013e6 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201548:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc020154c:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020154e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201550:	b5e1                	j	ffffffffc0201418 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0201552:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201554:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201558:	01174463          	blt	a4,a7,ffffffffc0201560 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc020155c:	14088163          	beqz	a7,ffffffffc020169e <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0201560:	000a3603          	ld	a2,0(s4)
ffffffffc0201564:	46a1                	li	a3,8
ffffffffc0201566:	8a2e                	mv	s4,a1
ffffffffc0201568:	bf69                	j	ffffffffc0201502 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020156a:	03000513          	li	a0,48
ffffffffc020156e:	85a6                	mv	a1,s1
ffffffffc0201570:	e03e                	sd	a5,0(sp)
ffffffffc0201572:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201574:	85a6                	mv	a1,s1
ffffffffc0201576:	07800513          	li	a0,120
ffffffffc020157a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020157c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020157e:	6782                	ld	a5,0(sp)
ffffffffc0201580:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201582:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0201586:	bfb5                	j	ffffffffc0201502 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201588:	000a3403          	ld	s0,0(s4)
ffffffffc020158c:	008a0713          	addi	a4,s4,8
ffffffffc0201590:	e03a                	sd	a4,0(sp)
ffffffffc0201592:	14040263          	beqz	s0,ffffffffc02016d6 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0201596:	0fb05763          	blez	s11,ffffffffc0201684 <vprintfmt+0x2d8>
ffffffffc020159a:	02d00693          	li	a3,45
ffffffffc020159e:	0cd79163          	bne	a5,a3,ffffffffc0201660 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015a2:	00044783          	lbu	a5,0(s0)
ffffffffc02015a6:	0007851b          	sext.w	a0,a5
ffffffffc02015aa:	cf85                	beqz	a5,ffffffffc02015e2 <vprintfmt+0x236>
ffffffffc02015ac:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015b0:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015b4:	000c4563          	bltz	s8,ffffffffc02015be <vprintfmt+0x212>
ffffffffc02015b8:	3c7d                	addiw	s8,s8,-1
ffffffffc02015ba:	036c0263          	beq	s8,s6,ffffffffc02015de <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02015be:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015c0:	0e0c8e63          	beqz	s9,ffffffffc02016bc <vprintfmt+0x310>
ffffffffc02015c4:	3781                	addiw	a5,a5,-32
ffffffffc02015c6:	0ef47b63          	bgeu	s0,a5,ffffffffc02016bc <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02015ca:	03f00513          	li	a0,63
ffffffffc02015ce:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015d0:	000a4783          	lbu	a5,0(s4)
ffffffffc02015d4:	3dfd                	addiw	s11,s11,-1
ffffffffc02015d6:	0a05                	addi	s4,s4,1
ffffffffc02015d8:	0007851b          	sext.w	a0,a5
ffffffffc02015dc:	ffe1                	bnez	a5,ffffffffc02015b4 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02015de:	01b05963          	blez	s11,ffffffffc02015f0 <vprintfmt+0x244>
ffffffffc02015e2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02015e4:	85a6                	mv	a1,s1
ffffffffc02015e6:	02000513          	li	a0,32
ffffffffc02015ea:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02015ec:	fe0d9be3          	bnez	s11,ffffffffc02015e2 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02015f0:	6a02                	ld	s4,0(sp)
ffffffffc02015f2:	bbd5                	j	ffffffffc02013e6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02015f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02015f6:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02015fa:	01174463          	blt	a4,a7,ffffffffc0201602 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02015fe:	08088d63          	beqz	a7,ffffffffc0201698 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201602:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201606:	0a044d63          	bltz	s0,ffffffffc02016c0 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020160a:	8622                	mv	a2,s0
ffffffffc020160c:	8a66                	mv	s4,s9
ffffffffc020160e:	46a9                	li	a3,10
ffffffffc0201610:	bdcd                	j	ffffffffc0201502 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201612:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201616:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201618:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020161a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020161e:	8fb5                	xor	a5,a5,a3
ffffffffc0201620:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201624:	02d74163          	blt	a4,a3,ffffffffc0201646 <vprintfmt+0x29a>
ffffffffc0201628:	00369793          	slli	a5,a3,0x3
ffffffffc020162c:	97de                	add	a5,a5,s7
ffffffffc020162e:	639c                	ld	a5,0(a5)
ffffffffc0201630:	cb99                	beqz	a5,ffffffffc0201646 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201632:	86be                	mv	a3,a5
ffffffffc0201634:	00001617          	auipc	a2,0x1
ffffffffc0201638:	0ec60613          	addi	a2,a2,236 # ffffffffc0202720 <buddy_pmm_manager+0x190>
ffffffffc020163c:	85a6                	mv	a1,s1
ffffffffc020163e:	854a                	mv	a0,s2
ffffffffc0201640:	0ce000ef          	jal	ra,ffffffffc020170e <printfmt>
ffffffffc0201644:	b34d                	j	ffffffffc02013e6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201646:	00001617          	auipc	a2,0x1
ffffffffc020164a:	0ca60613          	addi	a2,a2,202 # ffffffffc0202710 <buddy_pmm_manager+0x180>
ffffffffc020164e:	85a6                	mv	a1,s1
ffffffffc0201650:	854a                	mv	a0,s2
ffffffffc0201652:	0bc000ef          	jal	ra,ffffffffc020170e <printfmt>
ffffffffc0201656:	bb41                	j	ffffffffc02013e6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201658:	00001417          	auipc	s0,0x1
ffffffffc020165c:	0b040413          	addi	s0,s0,176 # ffffffffc0202708 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201660:	85e2                	mv	a1,s8
ffffffffc0201662:	8522                	mv	a0,s0
ffffffffc0201664:	e43e                	sd	a5,8(sp)
ffffffffc0201666:	1cc000ef          	jal	ra,ffffffffc0201832 <strnlen>
ffffffffc020166a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020166e:	01b05b63          	blez	s11,ffffffffc0201684 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201672:	67a2                	ld	a5,8(sp)
ffffffffc0201674:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201678:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020167a:	85a6                	mv	a1,s1
ffffffffc020167c:	8552                	mv	a0,s4
ffffffffc020167e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201680:	fe0d9ce3          	bnez	s11,ffffffffc0201678 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201684:	00044783          	lbu	a5,0(s0)
ffffffffc0201688:	00140a13          	addi	s4,s0,1
ffffffffc020168c:	0007851b          	sext.w	a0,a5
ffffffffc0201690:	d3a5                	beqz	a5,ffffffffc02015f0 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201692:	05e00413          	li	s0,94
ffffffffc0201696:	bf39                	j	ffffffffc02015b4 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0201698:	000a2403          	lw	s0,0(s4)
ffffffffc020169c:	b7ad                	j	ffffffffc0201606 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc020169e:	000a6603          	lwu	a2,0(s4)
ffffffffc02016a2:	46a1                	li	a3,8
ffffffffc02016a4:	8a2e                	mv	s4,a1
ffffffffc02016a6:	bdb1                	j	ffffffffc0201502 <vprintfmt+0x156>
ffffffffc02016a8:	000a6603          	lwu	a2,0(s4)
ffffffffc02016ac:	46a9                	li	a3,10
ffffffffc02016ae:	8a2e                	mv	s4,a1
ffffffffc02016b0:	bd89                	j	ffffffffc0201502 <vprintfmt+0x156>
ffffffffc02016b2:	000a6603          	lwu	a2,0(s4)
ffffffffc02016b6:	46c1                	li	a3,16
ffffffffc02016b8:	8a2e                	mv	s4,a1
ffffffffc02016ba:	b5a1                	j	ffffffffc0201502 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02016bc:	9902                	jalr	s2
ffffffffc02016be:	bf09                	j	ffffffffc02015d0 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02016c0:	85a6                	mv	a1,s1
ffffffffc02016c2:	02d00513          	li	a0,45
ffffffffc02016c6:	e03e                	sd	a5,0(sp)
ffffffffc02016c8:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02016ca:	6782                	ld	a5,0(sp)
ffffffffc02016cc:	8a66                	mv	s4,s9
ffffffffc02016ce:	40800633          	neg	a2,s0
ffffffffc02016d2:	46a9                	li	a3,10
ffffffffc02016d4:	b53d                	j	ffffffffc0201502 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02016d6:	03b05163          	blez	s11,ffffffffc02016f8 <vprintfmt+0x34c>
ffffffffc02016da:	02d00693          	li	a3,45
ffffffffc02016de:	f6d79de3          	bne	a5,a3,ffffffffc0201658 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02016e2:	00001417          	auipc	s0,0x1
ffffffffc02016e6:	02640413          	addi	s0,s0,38 # ffffffffc0202708 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ea:	02800793          	li	a5,40
ffffffffc02016ee:	02800513          	li	a0,40
ffffffffc02016f2:	00140a13          	addi	s4,s0,1
ffffffffc02016f6:	bd6d                	j	ffffffffc02015b0 <vprintfmt+0x204>
ffffffffc02016f8:	00001a17          	auipc	s4,0x1
ffffffffc02016fc:	011a0a13          	addi	s4,s4,17 # ffffffffc0202709 <buddy_pmm_manager+0x179>
ffffffffc0201700:	02800513          	li	a0,40
ffffffffc0201704:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201708:	05e00413          	li	s0,94
ffffffffc020170c:	b565                	j	ffffffffc02015b4 <vprintfmt+0x208>

ffffffffc020170e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020170e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201710:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201714:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201716:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201718:	ec06                	sd	ra,24(sp)
ffffffffc020171a:	f83a                	sd	a4,48(sp)
ffffffffc020171c:	fc3e                	sd	a5,56(sp)
ffffffffc020171e:	e0c2                	sd	a6,64(sp)
ffffffffc0201720:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201722:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201724:	c89ff0ef          	jal	ra,ffffffffc02013ac <vprintfmt>
}
ffffffffc0201728:	60e2                	ld	ra,24(sp)
ffffffffc020172a:	6161                	addi	sp,sp,80
ffffffffc020172c:	8082                	ret

ffffffffc020172e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020172e:	715d                	addi	sp,sp,-80
ffffffffc0201730:	e486                	sd	ra,72(sp)
ffffffffc0201732:	e0a6                	sd	s1,64(sp)
ffffffffc0201734:	fc4a                	sd	s2,56(sp)
ffffffffc0201736:	f84e                	sd	s3,48(sp)
ffffffffc0201738:	f452                	sd	s4,40(sp)
ffffffffc020173a:	f056                	sd	s5,32(sp)
ffffffffc020173c:	ec5a                	sd	s6,24(sp)
ffffffffc020173e:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0201740:	c901                	beqz	a0,ffffffffc0201750 <readline+0x22>
ffffffffc0201742:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201744:	00001517          	auipc	a0,0x1
ffffffffc0201748:	fdc50513          	addi	a0,a0,-36 # ffffffffc0202720 <buddy_pmm_manager+0x190>
ffffffffc020174c:	967fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc0201750:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201752:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201754:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201756:	4aa9                	li	s5,10
ffffffffc0201758:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020175a:	00005b97          	auipc	s7,0x5
ffffffffc020175e:	9b6b8b93          	addi	s7,s7,-1610 # ffffffffc0206110 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201762:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201766:	9c5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020176a:	00054a63          	bltz	a0,ffffffffc020177e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020176e:	00a95a63          	bge	s2,a0,ffffffffc0201782 <readline+0x54>
ffffffffc0201772:	029a5263          	bge	s4,s1,ffffffffc0201796 <readline+0x68>
        c = getchar();
ffffffffc0201776:	9b5fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020177a:	fe055ae3          	bgez	a0,ffffffffc020176e <readline+0x40>
            return NULL;
ffffffffc020177e:	4501                	li	a0,0
ffffffffc0201780:	a091                	j	ffffffffc02017c4 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201782:	03351463          	bne	a0,s3,ffffffffc02017aa <readline+0x7c>
ffffffffc0201786:	e8a9                	bnez	s1,ffffffffc02017d8 <readline+0xaa>
        c = getchar();
ffffffffc0201788:	9a3fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc020178c:	fe0549e3          	bltz	a0,ffffffffc020177e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201790:	fea959e3          	bge	s2,a0,ffffffffc0201782 <readline+0x54>
ffffffffc0201794:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201796:	e42a                	sd	a0,8(sp)
ffffffffc0201798:	951fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc020179c:	6522                	ld	a0,8(sp)
ffffffffc020179e:	009b87b3          	add	a5,s7,s1
ffffffffc02017a2:	2485                	addiw	s1,s1,1
ffffffffc02017a4:	00a78023          	sb	a0,0(a5)
ffffffffc02017a8:	bf7d                	j	ffffffffc0201766 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02017aa:	01550463          	beq	a0,s5,ffffffffc02017b2 <readline+0x84>
ffffffffc02017ae:	fb651ce3          	bne	a0,s6,ffffffffc0201766 <readline+0x38>
            cputchar(c);
ffffffffc02017b2:	937fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02017b6:	00005517          	auipc	a0,0x5
ffffffffc02017ba:	95a50513          	addi	a0,a0,-1702 # ffffffffc0206110 <buf>
ffffffffc02017be:	94aa                	add	s1,s1,a0
ffffffffc02017c0:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02017c4:	60a6                	ld	ra,72(sp)
ffffffffc02017c6:	6486                	ld	s1,64(sp)
ffffffffc02017c8:	7962                	ld	s2,56(sp)
ffffffffc02017ca:	79c2                	ld	s3,48(sp)
ffffffffc02017cc:	7a22                	ld	s4,40(sp)
ffffffffc02017ce:	7a82                	ld	s5,32(sp)
ffffffffc02017d0:	6b62                	ld	s6,24(sp)
ffffffffc02017d2:	6bc2                	ld	s7,16(sp)
ffffffffc02017d4:	6161                	addi	sp,sp,80
ffffffffc02017d6:	8082                	ret
            cputchar(c);
ffffffffc02017d8:	4521                	li	a0,8
ffffffffc02017da:	90ffe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02017de:	34fd                	addiw	s1,s1,-1
ffffffffc02017e0:	b759                	j	ffffffffc0201766 <readline+0x38>

ffffffffc02017e2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02017e2:	4781                	li	a5,0
ffffffffc02017e4:	00005717          	auipc	a4,0x5
ffffffffc02017e8:	82473703          	ld	a4,-2012(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc02017ec:	88ba                	mv	a7,a4
ffffffffc02017ee:	852a                	mv	a0,a0
ffffffffc02017f0:	85be                	mv	a1,a5
ffffffffc02017f2:	863e                	mv	a2,a5
ffffffffc02017f4:	00000073          	ecall
ffffffffc02017f8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02017fa:	8082                	ret

ffffffffc02017fc <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02017fc:	4781                	li	a5,0
ffffffffc02017fe:	00005717          	auipc	a4,0x5
ffffffffc0201802:	d5273703          	ld	a4,-686(a4) # ffffffffc0206550 <SBI_SET_TIMER>
ffffffffc0201806:	88ba                	mv	a7,a4
ffffffffc0201808:	852a                	mv	a0,a0
ffffffffc020180a:	85be                	mv	a1,a5
ffffffffc020180c:	863e                	mv	a2,a5
ffffffffc020180e:	00000073          	ecall
ffffffffc0201812:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201814:	8082                	ret

ffffffffc0201816 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201816:	4501                	li	a0,0
ffffffffc0201818:	00004797          	auipc	a5,0x4
ffffffffc020181c:	7e87b783          	ld	a5,2024(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201820:	88be                	mv	a7,a5
ffffffffc0201822:	852a                	mv	a0,a0
ffffffffc0201824:	85aa                	mv	a1,a0
ffffffffc0201826:	862a                	mv	a2,a0
ffffffffc0201828:	00000073          	ecall
ffffffffc020182c:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020182e:	2501                	sext.w	a0,a0
ffffffffc0201830:	8082                	ret

ffffffffc0201832 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201832:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201834:	e589                	bnez	a1,ffffffffc020183e <strnlen+0xc>
ffffffffc0201836:	a811                	j	ffffffffc020184a <strnlen+0x18>
        cnt ++;
ffffffffc0201838:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020183a:	00f58863          	beq	a1,a5,ffffffffc020184a <strnlen+0x18>
ffffffffc020183e:	00f50733          	add	a4,a0,a5
ffffffffc0201842:	00074703          	lbu	a4,0(a4)
ffffffffc0201846:	fb6d                	bnez	a4,ffffffffc0201838 <strnlen+0x6>
ffffffffc0201848:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020184a:	852e                	mv	a0,a1
ffffffffc020184c:	8082                	ret

ffffffffc020184e <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020184e:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201852:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201856:	cb89                	beqz	a5,ffffffffc0201868 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201858:	0505                	addi	a0,a0,1
ffffffffc020185a:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020185c:	fee789e3          	beq	a5,a4,ffffffffc020184e <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201860:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201864:	9d19                	subw	a0,a0,a4
ffffffffc0201866:	8082                	ret
ffffffffc0201868:	4501                	li	a0,0
ffffffffc020186a:	bfed                	j	ffffffffc0201864 <strcmp+0x16>

ffffffffc020186c <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020186c:	00054783          	lbu	a5,0(a0)
ffffffffc0201870:	c799                	beqz	a5,ffffffffc020187e <strchr+0x12>
        if (*s == c) {
ffffffffc0201872:	00f58763          	beq	a1,a5,ffffffffc0201880 <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201876:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020187a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020187c:	fbfd                	bnez	a5,ffffffffc0201872 <strchr+0x6>
    }
    return NULL;
ffffffffc020187e:	4501                	li	a0,0
}
ffffffffc0201880:	8082                	ret

ffffffffc0201882 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201882:	ca01                	beqz	a2,ffffffffc0201892 <memset+0x10>
ffffffffc0201884:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201886:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201888:	0785                	addi	a5,a5,1
ffffffffc020188a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020188e:	fec79de3          	bne	a5,a2,ffffffffc0201888 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201892:	8082                	ret
