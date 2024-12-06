
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	02650513          	addi	a0,a0,38 # ffffffffc020a058 <buf>
ffffffffc020003a:	00015617          	auipc	a2,0x15
ffffffffc020003e:	58a60613          	addi	a2,a2,1418 # ffffffffc02155c4 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	4ec040ef          	jal	ra,ffffffffc0204536 <memset>

    cons_init();                // init the console
ffffffffc020004e:	4d8000ef          	jal	ra,ffffffffc0200526 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00005597          	auipc	a1,0x5
ffffffffc0200056:	93658593          	addi	a1,a1,-1738 # ffffffffc0204988 <etext>
ffffffffc020005a:	00005517          	auipc	a0,0x5
ffffffffc020005e:	94e50513          	addi	a0,a0,-1714 # ffffffffc02049a8 <etext+0x20>
ffffffffc0200062:	06a000ef          	jal	ra,ffffffffc02000cc <cprintf>

    print_kerninfo();
ffffffffc0200066:	1be000ef          	jal	ra,ffffffffc0200224 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	33a030ef          	jal	ra,ffffffffc02033a4 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	52a000ef          	jal	ra,ffffffffc0200598 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5a4000ef          	jal	ra,ffffffffc0200616 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	4b1000ef          	jal	ra,ffffffffc0200d26 <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	0e6040ef          	jal	ra,ffffffffc0204160 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	424000ef          	jal	ra,ffffffffc02004a2 <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	350010ef          	jal	ra,ffffffffc02013d2 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	44e000ef          	jal	ra,ffffffffc02004d4 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	510000ef          	jal	ra,ffffffffc020059a <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc020008e:	37c040ef          	jal	ra,ffffffffc020440a <cpu_idle>

ffffffffc0200092 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200092:	1141                	addi	sp,sp,-16
ffffffffc0200094:	e022                	sd	s0,0(sp)
ffffffffc0200096:	e406                	sd	ra,8(sp)
ffffffffc0200098:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020009a:	48e000ef          	jal	ra,ffffffffc0200528 <cons_putc>
    (*cnt) ++;
ffffffffc020009e:	401c                	lw	a5,0(s0)
}
ffffffffc02000a0:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc02000a2:	2785                	addiw	a5,a5,1
ffffffffc02000a4:	c01c                	sw	a5,0(s0)
}
ffffffffc02000a6:	6402                	ld	s0,0(sp)
ffffffffc02000a8:	0141                	addi	sp,sp,16
ffffffffc02000aa:	8082                	ret

ffffffffc02000ac <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	1101                	addi	sp,sp,-32
ffffffffc02000ae:	862a                	mv	a2,a0
ffffffffc02000b0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	00000517          	auipc	a0,0x0
ffffffffc02000b6:	fe050513          	addi	a0,a0,-32 # ffffffffc0200092 <cputch>
ffffffffc02000ba:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000bc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000be:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	530040ef          	jal	ra,ffffffffc02045f0 <vprintfmt>
    return cnt;
}
ffffffffc02000c4:	60e2                	ld	ra,24(sp)
ffffffffc02000c6:	4532                	lw	a0,12(sp)
ffffffffc02000c8:	6105                	addi	sp,sp,32
ffffffffc02000ca:	8082                	ret

ffffffffc02000cc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000cc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000ce:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000d2:	8e2a                	mv	t3,a0
ffffffffc02000d4:	f42e                	sd	a1,40(sp)
ffffffffc02000d6:	f832                	sd	a2,48(sp)
ffffffffc02000d8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000da:	00000517          	auipc	a0,0x0
ffffffffc02000de:	fb850513          	addi	a0,a0,-72 # ffffffffc0200092 <cputch>
ffffffffc02000e2:	004c                	addi	a1,sp,4
ffffffffc02000e4:	869a                	mv	a3,t1
ffffffffc02000e6:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000e8:	ec06                	sd	ra,24(sp)
ffffffffc02000ea:	e0ba                	sd	a4,64(sp)
ffffffffc02000ec:	e4be                	sd	a5,72(sp)
ffffffffc02000ee:	e8c2                	sd	a6,80(sp)
ffffffffc02000f0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000f2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000f4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f6:	4fa040ef          	jal	ra,ffffffffc02045f0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000fa:	60e2                	ld	ra,24(sp)
ffffffffc02000fc:	4512                	lw	a0,4(sp)
ffffffffc02000fe:	6125                	addi	sp,sp,96
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200102:	a11d                	j	ffffffffc0200528 <cons_putc>

ffffffffc0200104 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
ffffffffc0200106:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200108:	454000ef          	jal	ra,ffffffffc020055c <cons_getc>
ffffffffc020010c:	dd75                	beqz	a0,ffffffffc0200108 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020010e:	60a2                	ld	ra,8(sp)
ffffffffc0200110:	0141                	addi	sp,sp,16
ffffffffc0200112:	8082                	ret

ffffffffc0200114 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200114:	715d                	addi	sp,sp,-80
ffffffffc0200116:	e486                	sd	ra,72(sp)
ffffffffc0200118:	e0a6                	sd	s1,64(sp)
ffffffffc020011a:	fc4a                	sd	s2,56(sp)
ffffffffc020011c:	f84e                	sd	s3,48(sp)
ffffffffc020011e:	f452                	sd	s4,40(sp)
ffffffffc0200120:	f056                	sd	s5,32(sp)
ffffffffc0200122:	ec5a                	sd	s6,24(sp)
ffffffffc0200124:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0200126:	c901                	beqz	a0,ffffffffc0200136 <readline+0x22>
ffffffffc0200128:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc020012a:	00005517          	auipc	a0,0x5
ffffffffc020012e:	88650513          	addi	a0,a0,-1914 # ffffffffc02049b0 <etext+0x28>
ffffffffc0200132:	f9bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
readline(const char *prompt) {
ffffffffc0200136:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200138:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020013a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020013c:	4aa9                	li	s5,10
ffffffffc020013e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0200140:	0000ab97          	auipc	s7,0xa
ffffffffc0200144:	f18b8b93          	addi	s7,s7,-232 # ffffffffc020a058 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200148:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020014c:	fb9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200150:	00054a63          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200154:	00a95a63          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc0200158:	029a5263          	bge	s4,s1,ffffffffc020017c <readline+0x68>
        c = getchar();
ffffffffc020015c:	fa9ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200160:	fe055ae3          	bgez	a0,ffffffffc0200154 <readline+0x40>
            return NULL;
ffffffffc0200164:	4501                	li	a0,0
ffffffffc0200166:	a091                	j	ffffffffc02001aa <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0200168:	03351463          	bne	a0,s3,ffffffffc0200190 <readline+0x7c>
ffffffffc020016c:	e8a9                	bnez	s1,ffffffffc02001be <readline+0xaa>
        c = getchar();
ffffffffc020016e:	f97ff0ef          	jal	ra,ffffffffc0200104 <getchar>
        if (c < 0) {
ffffffffc0200172:	fe0549e3          	bltz	a0,ffffffffc0200164 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200176:	fea959e3          	bge	s2,a0,ffffffffc0200168 <readline+0x54>
ffffffffc020017a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020017c:	e42a                	sd	a0,8(sp)
ffffffffc020017e:	f85ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i ++] = c;
ffffffffc0200182:	6522                	ld	a0,8(sp)
ffffffffc0200184:	009b87b3          	add	a5,s7,s1
ffffffffc0200188:	2485                	addiw	s1,s1,1
ffffffffc020018a:	00a78023          	sb	a0,0(a5)
ffffffffc020018e:	bf7d                	j	ffffffffc020014c <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0200190:	01550463          	beq	a0,s5,ffffffffc0200198 <readline+0x84>
ffffffffc0200194:	fb651ce3          	bne	a0,s6,ffffffffc020014c <readline+0x38>
            cputchar(c);
ffffffffc0200198:	f6bff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            buf[i] = '\0';
ffffffffc020019c:	0000a517          	auipc	a0,0xa
ffffffffc02001a0:	ebc50513          	addi	a0,a0,-324 # ffffffffc020a058 <buf>
ffffffffc02001a4:	94aa                	add	s1,s1,a0
ffffffffc02001a6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02001aa:	60a6                	ld	ra,72(sp)
ffffffffc02001ac:	6486                	ld	s1,64(sp)
ffffffffc02001ae:	7962                	ld	s2,56(sp)
ffffffffc02001b0:	79c2                	ld	s3,48(sp)
ffffffffc02001b2:	7a22                	ld	s4,40(sp)
ffffffffc02001b4:	7a82                	ld	s5,32(sp)
ffffffffc02001b6:	6b62                	ld	s6,24(sp)
ffffffffc02001b8:	6bc2                	ld	s7,16(sp)
ffffffffc02001ba:	6161                	addi	sp,sp,80
ffffffffc02001bc:	8082                	ret
            cputchar(c);
ffffffffc02001be:	4521                	li	a0,8
ffffffffc02001c0:	f43ff0ef          	jal	ra,ffffffffc0200102 <cputchar>
            i --;
ffffffffc02001c4:	34fd                	addiw	s1,s1,-1
ffffffffc02001c6:	b759                	j	ffffffffc020014c <readline+0x38>

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00015317          	auipc	t1,0x15
ffffffffc02001cc:	36830313          	addi	t1,t1,872 # ffffffffc0215530 <is_panic>
ffffffffc02001d0:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d4:	715d                	addi	sp,sp,-80
ffffffffc02001d6:	ec06                	sd	ra,24(sp)
ffffffffc02001d8:	e822                	sd	s0,16(sp)
ffffffffc02001da:	f436                	sd	a3,40(sp)
ffffffffc02001dc:	f83a                	sd	a4,48(sp)
ffffffffc02001de:	fc3e                	sd	a5,56(sp)
ffffffffc02001e0:	e0c2                	sd	a6,64(sp)
ffffffffc02001e2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001e4:	020e1a63          	bnez	t3,ffffffffc0200218 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02001e8:	4785                	li	a5,1
ffffffffc02001ea:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02001ee:	8432                	mv	s0,a2
ffffffffc02001f0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f2:	862e                	mv	a2,a1
ffffffffc02001f4:	85aa                	mv	a1,a0
ffffffffc02001f6:	00004517          	auipc	a0,0x4
ffffffffc02001fa:	7c250513          	addi	a0,a0,1986 # ffffffffc02049b8 <etext+0x30>
    va_start(ap, fmt);
ffffffffc02001fe:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200200:	ecdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200204:	65a2                	ld	a1,8(sp)
ffffffffc0200206:	8522                	mv	a0,s0
ffffffffc0200208:	ea5ff0ef          	jal	ra,ffffffffc02000ac <vcprintf>
    cprintf("\n");
ffffffffc020020c:	00006517          	auipc	a0,0x6
ffffffffc0200210:	1ec50513          	addi	a0,a0,492 # ffffffffc02063f8 <default_pmm_manager+0x3b8>
ffffffffc0200214:	eb9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200218:	388000ef          	jal	ra,ffffffffc02005a0 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	130000ef          	jal	ra,ffffffffc020034e <kmonitor>
    while (1) {
ffffffffc0200222:	bfed                	j	ffffffffc020021c <__panic+0x54>

ffffffffc0200224 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200224:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	00004517          	auipc	a0,0x4
ffffffffc020022a:	7b250513          	addi	a0,a0,1970 # ffffffffc02049d8 <etext+0x50>
void print_kerninfo(void) {
ffffffffc020022e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200230:	e9dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200234:	00000597          	auipc	a1,0x0
ffffffffc0200238:	dfe58593          	addi	a1,a1,-514 # ffffffffc0200032 <kern_init>
ffffffffc020023c:	00004517          	auipc	a0,0x4
ffffffffc0200240:	7bc50513          	addi	a0,a0,1980 # ffffffffc02049f8 <etext+0x70>
ffffffffc0200244:	e89ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200248:	00004597          	auipc	a1,0x4
ffffffffc020024c:	74058593          	addi	a1,a1,1856 # ffffffffc0204988 <etext>
ffffffffc0200250:	00004517          	auipc	a0,0x4
ffffffffc0200254:	7c850513          	addi	a0,a0,1992 # ffffffffc0204a18 <etext+0x90>
ffffffffc0200258:	e75ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025c:	0000a597          	auipc	a1,0xa
ffffffffc0200260:	dfc58593          	addi	a1,a1,-516 # ffffffffc020a058 <buf>
ffffffffc0200264:	00004517          	auipc	a0,0x4
ffffffffc0200268:	7d450513          	addi	a0,a0,2004 # ffffffffc0204a38 <etext+0xb0>
ffffffffc020026c:	e61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200270:	00015597          	auipc	a1,0x15
ffffffffc0200274:	35458593          	addi	a1,a1,852 # ffffffffc02155c4 <end>
ffffffffc0200278:	00004517          	auipc	a0,0x4
ffffffffc020027c:	7e050513          	addi	a0,a0,2016 # ffffffffc0204a58 <etext+0xd0>
ffffffffc0200280:	e4dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200284:	00015597          	auipc	a1,0x15
ffffffffc0200288:	73f58593          	addi	a1,a1,1855 # ffffffffc02159c3 <end+0x3ff>
ffffffffc020028c:	00000797          	auipc	a5,0x0
ffffffffc0200290:	da678793          	addi	a5,a5,-602 # ffffffffc0200032 <kern_init>
ffffffffc0200294:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00004517          	auipc	a0,0x4
ffffffffc02002aa:	7d250513          	addi	a0,a0,2002 # ffffffffc0204a78 <etext+0xf0>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	bd31                	j	ffffffffc02000cc <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00004617          	auipc	a2,0x4
ffffffffc02002b8:	7f460613          	addi	a2,a2,2036 # ffffffffc0204aa8 <etext+0x120>
ffffffffc02002bc:	04d00593          	li	a1,77
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	80050513          	addi	a0,a0,-2048 # ffffffffc0204ac0 <etext+0x138>
void print_stackframe(void) {
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	effff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002ce:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002d0:	00005617          	auipc	a2,0x5
ffffffffc02002d4:	80860613          	addi	a2,a2,-2040 # ffffffffc0204ad8 <etext+0x150>
ffffffffc02002d8:	00005597          	auipc	a1,0x5
ffffffffc02002dc:	82058593          	addi	a1,a1,-2016 # ffffffffc0204af8 <etext+0x170>
ffffffffc02002e0:	00005517          	auipc	a0,0x5
ffffffffc02002e4:	82050513          	addi	a0,a0,-2016 # ffffffffc0204b00 <etext+0x178>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	de3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc02002ee:	00005617          	auipc	a2,0x5
ffffffffc02002f2:	82260613          	addi	a2,a2,-2014 # ffffffffc0204b10 <etext+0x188>
ffffffffc02002f6:	00005597          	auipc	a1,0x5
ffffffffc02002fa:	84258593          	addi	a1,a1,-1982 # ffffffffc0204b38 <etext+0x1b0>
ffffffffc02002fe:	00005517          	auipc	a0,0x5
ffffffffc0200302:	80250513          	addi	a0,a0,-2046 # ffffffffc0204b00 <etext+0x178>
ffffffffc0200306:	dc7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc020030a:	00005617          	auipc	a2,0x5
ffffffffc020030e:	83e60613          	addi	a2,a2,-1986 # ffffffffc0204b48 <etext+0x1c0>
ffffffffc0200312:	00005597          	auipc	a1,0x5
ffffffffc0200316:	85658593          	addi	a1,a1,-1962 # ffffffffc0204b68 <etext+0x1e0>
ffffffffc020031a:	00004517          	auipc	a0,0x4
ffffffffc020031e:	7e650513          	addi	a0,a0,2022 # ffffffffc0204b00 <etext+0x178>
ffffffffc0200322:	dabff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    }
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200332:	ef3ff0ef          	jal	ra,ffffffffc0200224 <print_kerninfo>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020033e:	1141                	addi	sp,sp,-16
ffffffffc0200340:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200342:	f71ff0ef          	jal	ra,ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200346:	60a2                	ld	ra,8(sp)
ffffffffc0200348:	4501                	li	a0,0
ffffffffc020034a:	0141                	addi	sp,sp,16
ffffffffc020034c:	8082                	ret

ffffffffc020034e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020034e:	7115                	addi	sp,sp,-224
ffffffffc0200350:	ed5e                	sd	s7,152(sp)
ffffffffc0200352:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200354:	00005517          	auipc	a0,0x5
ffffffffc0200358:	82450513          	addi	a0,a0,-2012 # ffffffffc0204b78 <etext+0x1f0>
kmonitor(struct trapframe *tf) {
ffffffffc020035c:	ed86                	sd	ra,216(sp)
ffffffffc020035e:	e9a2                	sd	s0,208(sp)
ffffffffc0200360:	e5a6                	sd	s1,200(sp)
ffffffffc0200362:	e1ca                	sd	s2,192(sp)
ffffffffc0200364:	fd4e                	sd	s3,184(sp)
ffffffffc0200366:	f952                	sd	s4,176(sp)
ffffffffc0200368:	f556                	sd	s5,168(sp)
ffffffffc020036a:	f15a                	sd	s6,160(sp)
ffffffffc020036c:	e962                	sd	s8,144(sp)
ffffffffc020036e:	e566                	sd	s9,136(sp)
ffffffffc0200370:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200372:	d5bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200376:	00005517          	auipc	a0,0x5
ffffffffc020037a:	82a50513          	addi	a0,a0,-2006 # ffffffffc0204ba0 <etext+0x218>
ffffffffc020037e:	d4fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    if (tf != NULL) {
ffffffffc0200382:	000b8563          	beqz	s7,ffffffffc020038c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200386:	855e                	mv	a0,s7
ffffffffc0200388:	476000ef          	jal	ra,ffffffffc02007fe <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020038c:	4501                	li	a0,0
ffffffffc020038e:	4581                	li	a1,0
ffffffffc0200390:	4601                	li	a2,0
ffffffffc0200392:	48a1                	li	a7,8
ffffffffc0200394:	00000073          	ecall
ffffffffc0200398:	00005c17          	auipc	s8,0x5
ffffffffc020039c:	878c0c13          	addi	s8,s8,-1928 # ffffffffc0204c10 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a0:	00005917          	auipc	s2,0x5
ffffffffc02003a4:	82890913          	addi	s2,s2,-2008 # ffffffffc0204bc8 <etext+0x240>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a8:	00005497          	auipc	s1,0x5
ffffffffc02003ac:	82848493          	addi	s1,s1,-2008 # ffffffffc0204bd0 <etext+0x248>
        if (argc == MAXARGS - 1) {
ffffffffc02003b0:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b2:	00005b17          	auipc	s6,0x5
ffffffffc02003b6:	826b0b13          	addi	s6,s6,-2010 # ffffffffc0204bd8 <etext+0x250>
        argv[argc ++] = buf;
ffffffffc02003ba:	00004a17          	auipc	s4,0x4
ffffffffc02003be:	73ea0a13          	addi	s4,s4,1854 # ffffffffc0204af8 <etext+0x170>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c2:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003c4:	854a                	mv	a0,s2
ffffffffc02003c6:	d4fff0ef          	jal	ra,ffffffffc0200114 <readline>
ffffffffc02003ca:	842a                	mv	s0,a0
ffffffffc02003cc:	dd65                	beqz	a0,ffffffffc02003c4 <kmonitor+0x76>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ce:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003d2:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d4:	e1bd                	bnez	a1,ffffffffc020043a <kmonitor+0xec>
    if (argc == 0) {
ffffffffc02003d6:	fe0c87e3          	beqz	s9,ffffffffc02003c4 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003da:	6582                	ld	a1,0(sp)
ffffffffc02003dc:	00005d17          	auipc	s10,0x5
ffffffffc02003e0:	834d0d13          	addi	s10,s10,-1996 # ffffffffc0204c10 <commands>
        argv[argc ++] = buf;
ffffffffc02003e4:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	4401                	li	s0,0
ffffffffc02003e8:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ea:	118040ef          	jal	ra,ffffffffc0204502 <strcmp>
ffffffffc02003ee:	c919                	beqz	a0,ffffffffc0200404 <kmonitor+0xb6>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003f0:	2405                	addiw	s0,s0,1
ffffffffc02003f2:	0b540063          	beq	s0,s5,ffffffffc0200492 <kmonitor+0x144>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f6:	000d3503          	ld	a0,0(s10)
ffffffffc02003fa:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003fc:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003fe:	104040ef          	jal	ra,ffffffffc0204502 <strcmp>
ffffffffc0200402:	f57d                	bnez	a0,ffffffffc02003f0 <kmonitor+0xa2>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200404:	00141793          	slli	a5,s0,0x1
ffffffffc0200408:	97a2                	add	a5,a5,s0
ffffffffc020040a:	078e                	slli	a5,a5,0x3
ffffffffc020040c:	97e2                	add	a5,a5,s8
ffffffffc020040e:	6b9c                	ld	a5,16(a5)
ffffffffc0200410:	865e                	mv	a2,s7
ffffffffc0200412:	002c                	addi	a1,sp,8
ffffffffc0200414:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200418:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020041a:	fa0555e3          	bgez	a0,ffffffffc02003c4 <kmonitor+0x76>
}
ffffffffc020041e:	60ee                	ld	ra,216(sp)
ffffffffc0200420:	644e                	ld	s0,208(sp)
ffffffffc0200422:	64ae                	ld	s1,200(sp)
ffffffffc0200424:	690e                	ld	s2,192(sp)
ffffffffc0200426:	79ea                	ld	s3,184(sp)
ffffffffc0200428:	7a4a                	ld	s4,176(sp)
ffffffffc020042a:	7aaa                	ld	s5,168(sp)
ffffffffc020042c:	7b0a                	ld	s6,160(sp)
ffffffffc020042e:	6bea                	ld	s7,152(sp)
ffffffffc0200430:	6c4a                	ld	s8,144(sp)
ffffffffc0200432:	6caa                	ld	s9,136(sp)
ffffffffc0200434:	6d0a                	ld	s10,128(sp)
ffffffffc0200436:	612d                	addi	sp,sp,224
ffffffffc0200438:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020043a:	8526                	mv	a0,s1
ffffffffc020043c:	0e4040ef          	jal	ra,ffffffffc0204520 <strchr>
ffffffffc0200440:	c901                	beqz	a0,ffffffffc0200450 <kmonitor+0x102>
ffffffffc0200442:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200446:	00040023          	sb	zero,0(s0)
ffffffffc020044a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020044c:	d5c9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc020044e:	b7f5                	j	ffffffffc020043a <kmonitor+0xec>
        if (*buf == '\0') {
ffffffffc0200450:	00044783          	lbu	a5,0(s0)
ffffffffc0200454:	d3c9                	beqz	a5,ffffffffc02003d6 <kmonitor+0x88>
        if (argc == MAXARGS - 1) {
ffffffffc0200456:	033c8963          	beq	s9,s3,ffffffffc0200488 <kmonitor+0x13a>
        argv[argc ++] = buf;
ffffffffc020045a:	003c9793          	slli	a5,s9,0x3
ffffffffc020045e:	0118                	addi	a4,sp,128
ffffffffc0200460:	97ba                	add	a5,a5,a4
ffffffffc0200462:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200466:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020046a:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020046c:	e591                	bnez	a1,ffffffffc0200478 <kmonitor+0x12a>
ffffffffc020046e:	b7b5                	j	ffffffffc02003da <kmonitor+0x8c>
ffffffffc0200470:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200474:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200476:	d1a5                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200478:	8526                	mv	a0,s1
ffffffffc020047a:	0a6040ef          	jal	ra,ffffffffc0204520 <strchr>
ffffffffc020047e:	d96d                	beqz	a0,ffffffffc0200470 <kmonitor+0x122>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200480:	00044583          	lbu	a1,0(s0)
ffffffffc0200484:	d9a9                	beqz	a1,ffffffffc02003d6 <kmonitor+0x88>
ffffffffc0200486:	bf55                	j	ffffffffc020043a <kmonitor+0xec>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200488:	45c1                	li	a1,16
ffffffffc020048a:	855a                	mv	a0,s6
ffffffffc020048c:	c41ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0200490:	b7e9                	j	ffffffffc020045a <kmonitor+0x10c>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200492:	6582                	ld	a1,0(sp)
ffffffffc0200494:	00004517          	auipc	a0,0x4
ffffffffc0200498:	76450513          	addi	a0,a0,1892 # ffffffffc0204bf8 <etext+0x270>
ffffffffc020049c:	c31ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    return 0;
ffffffffc02004a0:	b715                	j	ffffffffc02003c4 <kmonitor+0x76>

ffffffffc02004a2 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02004a4:	00253513          	sltiu	a0,a0,2
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004aa:	03800513          	li	a0,56
ffffffffc02004ae:	8082                	ret

ffffffffc02004b0 <ide_write_secs>:
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc02004b0:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004b4:	0000a517          	auipc	a0,0xa
ffffffffc02004b8:	fa450513          	addi	a0,a0,-92 # ffffffffc020a458 <ide>
                   size_t nsecs) {
ffffffffc02004bc:	1141                	addi	sp,sp,-16
ffffffffc02004be:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c0:	953e                	add	a0,a0,a5
ffffffffc02004c2:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004c6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	080040ef          	jal	ra,ffffffffc0204548 <memcpy>
    return 0;
}
ffffffffc02004cc:	60a2                	ld	ra,8(sp)
ffffffffc02004ce:	4501                	li	a0,0
ffffffffc02004d0:	0141                	addi	sp,sp,16
ffffffffc02004d2:	8082                	ret

ffffffffc02004d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004d4:	67e1                	lui	a5,0x18
ffffffffc02004d6:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02004da:	00015717          	auipc	a4,0x15
ffffffffc02004de:	06f73323          	sd	a5,102(a4) # ffffffffc0215540 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004e2:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004e8:	953e                	add	a0,a0,a5
ffffffffc02004ea:	4601                	li	a2,0
ffffffffc02004ec:	4881                	li	a7,0
ffffffffc02004ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004f2:	02000793          	li	a5,32
ffffffffc02004f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004fa:	00004517          	auipc	a0,0x4
ffffffffc02004fe:	75e50513          	addi	a0,a0,1886 # ffffffffc0204c58 <commands+0x48>
    ticks = 0;
ffffffffc0200502:	00015797          	auipc	a5,0x15
ffffffffc0200506:	0207bb23          	sd	zero,54(a5) # ffffffffc0215538 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020050a:	b6c9                	j	ffffffffc02000cc <cprintf>

ffffffffc020050c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020050c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200510:	00015797          	auipc	a5,0x15
ffffffffc0200514:	0307b783          	ld	a5,48(a5) # ffffffffc0215540 <timebase>
ffffffffc0200518:	953e                	add	a0,a0,a5
ffffffffc020051a:	4581                	li	a1,0
ffffffffc020051c:	4601                	li	a2,0
ffffffffc020051e:	4881                	li	a7,0
ffffffffc0200520:	00000073          	ecall
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200528:	100027f3          	csrr	a5,sstatus
ffffffffc020052c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020052e:	0ff57513          	zext.b	a0,a0
ffffffffc0200532:	e799                	bnez	a5,ffffffffc0200540 <cons_putc+0x18>
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4885                	li	a7,1
ffffffffc020053a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020053e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200540:	1101                	addi	sp,sp,-32
ffffffffc0200542:	ec06                	sd	ra,24(sp)
ffffffffc0200544:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200546:	05a000ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc020054a:	6522                	ld	a0,8(sp)
ffffffffc020054c:	4581                	li	a1,0
ffffffffc020054e:	4601                	li	a2,0
ffffffffc0200550:	4885                	li	a7,1
ffffffffc0200552:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200556:	60e2                	ld	ra,24(sp)
ffffffffc0200558:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020055a:	a081                	j	ffffffffc020059a <intr_enable>

ffffffffc020055c <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020055c:	100027f3          	csrr	a5,sstatus
ffffffffc0200560:	8b89                	andi	a5,a5,2
ffffffffc0200562:	eb89                	bnez	a5,ffffffffc0200574 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200564:	4501                	li	a0,0
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4889                	li	a7,2
ffffffffc020056c:	00000073          	ecall
ffffffffc0200570:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200572:	8082                	ret
int cons_getc(void) {
ffffffffc0200574:	1101                	addi	sp,sp,-32
ffffffffc0200576:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200578:	028000ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc020057c:	4501                	li	a0,0
ffffffffc020057e:	4581                	li	a1,0
ffffffffc0200580:	4601                	li	a2,0
ffffffffc0200582:	4889                	li	a7,2
ffffffffc0200584:	00000073          	ecall
ffffffffc0200588:	2501                	sext.w	a0,a0
ffffffffc020058a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020058c:	00e000ef          	jal	ra,ffffffffc020059a <intr_enable>
}
ffffffffc0200590:	60e2                	ld	ra,24(sp)
ffffffffc0200592:	6522                	ld	a0,8(sp)
ffffffffc0200594:	6105                	addi	sp,sp,32
ffffffffc0200596:	8082                	ret

ffffffffc0200598 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200598:	8082                	ret

ffffffffc020059a <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020059a:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020059e:	8082                	ret

ffffffffc02005a0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005a0:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005a4:	8082                	ret

ffffffffc02005a6 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005a6:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005aa:	1141                	addi	sp,sp,-16
ffffffffc02005ac:	e022                	sd	s0,0(sp)
ffffffffc02005ae:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005b0:	1007f793          	andi	a5,a5,256
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005b4:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005b8:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005ba:	05500613          	li	a2,85
ffffffffc02005be:	c399                	beqz	a5,ffffffffc02005c4 <pgfault_handler+0x1e>
ffffffffc02005c0:	04b00613          	li	a2,75
ffffffffc02005c4:	11843703          	ld	a4,280(s0)
ffffffffc02005c8:	47bd                	li	a5,15
ffffffffc02005ca:	05700693          	li	a3,87
ffffffffc02005ce:	00f70463          	beq	a4,a5,ffffffffc02005d6 <pgfault_handler+0x30>
ffffffffc02005d2:	05200693          	li	a3,82
ffffffffc02005d6:	00004517          	auipc	a0,0x4
ffffffffc02005da:	6a250513          	addi	a0,a0,1698 # ffffffffc0204c78 <commands+0x68>
ffffffffc02005de:	aefff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc02005e2:	00015517          	auipc	a0,0x15
ffffffffc02005e6:	f6653503          	ld	a0,-154(a0) # ffffffffc0215548 <check_mm_struct>
ffffffffc02005ea:	c911                	beqz	a0,ffffffffc02005fe <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc02005ec:	11043603          	ld	a2,272(s0)
ffffffffc02005f0:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc02005f4:	6402                	ld	s0,0(sp)
ffffffffc02005f6:	60a2                	ld	ra,8(sp)
ffffffffc02005f8:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc02005fa:	5010006f          	j	ffffffffc02012fa <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc02005fe:	00004617          	auipc	a2,0x4
ffffffffc0200602:	69a60613          	addi	a2,a2,1690 # ffffffffc0204c98 <commands+0x88>
ffffffffc0200606:	06200593          	li	a1,98
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	6a650513          	addi	a0,a0,1702 # ffffffffc0204cb0 <commands+0xa0>
ffffffffc0200612:	bb7ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200616 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200616:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020061a:	00000797          	auipc	a5,0x0
ffffffffc020061e:	47a78793          	addi	a5,a5,1146 # ffffffffc0200a94 <__alltraps>
ffffffffc0200622:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200626:	000407b7          	lui	a5,0x40
ffffffffc020062a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020062e:	8082                	ret

ffffffffc0200630 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200630:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200632:	1141                	addi	sp,sp,-16
ffffffffc0200634:	e022                	sd	s0,0(sp)
ffffffffc0200636:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200638:	00004517          	auipc	a0,0x4
ffffffffc020063c:	69050513          	addi	a0,a0,1680 # ffffffffc0204cc8 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200640:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200642:	a8bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200646:	640c                	ld	a1,8(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	69850513          	addi	a0,a0,1688 # ffffffffc0204ce0 <commands+0xd0>
ffffffffc0200650:	a7dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200654:	680c                	ld	a1,16(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	6a250513          	addi	a0,a0,1698 # ffffffffc0204cf8 <commands+0xe8>
ffffffffc020065e:	a6fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200662:	6c0c                	ld	a1,24(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	6ac50513          	addi	a0,a0,1708 # ffffffffc0204d10 <commands+0x100>
ffffffffc020066c:	a61ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200670:	700c                	ld	a1,32(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	6b650513          	addi	a0,a0,1718 # ffffffffc0204d28 <commands+0x118>
ffffffffc020067a:	a53ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020067e:	740c                	ld	a1,40(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	6c050513          	addi	a0,a0,1728 # ffffffffc0204d40 <commands+0x130>
ffffffffc0200688:	a45ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020068c:	780c                	ld	a1,48(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	6ca50513          	addi	a0,a0,1738 # ffffffffc0204d58 <commands+0x148>
ffffffffc0200696:	a37ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020069a:	7c0c                	ld	a1,56(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	6d450513          	addi	a0,a0,1748 # ffffffffc0204d70 <commands+0x160>
ffffffffc02006a4:	a29ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006a8:	602c                	ld	a1,64(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	6de50513          	addi	a0,a0,1758 # ffffffffc0204d88 <commands+0x178>
ffffffffc02006b2:	a1bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006b6:	642c                	ld	a1,72(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	6e850513          	addi	a0,a0,1768 # ffffffffc0204da0 <commands+0x190>
ffffffffc02006c0:	a0dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006c4:	682c                	ld	a1,80(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	6f250513          	addi	a0,a0,1778 # ffffffffc0204db8 <commands+0x1a8>
ffffffffc02006ce:	9ffff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006d2:	6c2c                	ld	a1,88(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	6fc50513          	addi	a0,a0,1788 # ffffffffc0204dd0 <commands+0x1c0>
ffffffffc02006dc:	9f1ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006e0:	702c                	ld	a1,96(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	70650513          	addi	a0,a0,1798 # ffffffffc0204de8 <commands+0x1d8>
ffffffffc02006ea:	9e3ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02006ee:	742c                	ld	a1,104(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	71050513          	addi	a0,a0,1808 # ffffffffc0204e00 <commands+0x1f0>
ffffffffc02006f8:	9d5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02006fc:	782c                	ld	a1,112(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	71a50513          	addi	a0,a0,1818 # ffffffffc0204e18 <commands+0x208>
ffffffffc0200706:	9c7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020070a:	7c2c                	ld	a1,120(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	72450513          	addi	a0,a0,1828 # ffffffffc0204e30 <commands+0x220>
ffffffffc0200714:	9b9ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200718:	604c                	ld	a1,128(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	72e50513          	addi	a0,a0,1838 # ffffffffc0204e48 <commands+0x238>
ffffffffc0200722:	9abff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200726:	644c                	ld	a1,136(s0)
ffffffffc0200728:	00004517          	auipc	a0,0x4
ffffffffc020072c:	73850513          	addi	a0,a0,1848 # ffffffffc0204e60 <commands+0x250>
ffffffffc0200730:	99dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200734:	684c                	ld	a1,144(s0)
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	74250513          	addi	a0,a0,1858 # ffffffffc0204e78 <commands+0x268>
ffffffffc020073e:	98fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200742:	6c4c                	ld	a1,152(s0)
ffffffffc0200744:	00004517          	auipc	a0,0x4
ffffffffc0200748:	74c50513          	addi	a0,a0,1868 # ffffffffc0204e90 <commands+0x280>
ffffffffc020074c:	981ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200750:	704c                	ld	a1,160(s0)
ffffffffc0200752:	00004517          	auipc	a0,0x4
ffffffffc0200756:	75650513          	addi	a0,a0,1878 # ffffffffc0204ea8 <commands+0x298>
ffffffffc020075a:	973ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc020075e:	744c                	ld	a1,168(s0)
ffffffffc0200760:	00004517          	auipc	a0,0x4
ffffffffc0200764:	76050513          	addi	a0,a0,1888 # ffffffffc0204ec0 <commands+0x2b0>
ffffffffc0200768:	965ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020076c:	784c                	ld	a1,176(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	76a50513          	addi	a0,a0,1898 # ffffffffc0204ed8 <commands+0x2c8>
ffffffffc0200776:	957ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020077a:	7c4c                	ld	a1,184(s0)
ffffffffc020077c:	00004517          	auipc	a0,0x4
ffffffffc0200780:	77450513          	addi	a0,a0,1908 # ffffffffc0204ef0 <commands+0x2e0>
ffffffffc0200784:	949ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200788:	606c                	ld	a1,192(s0)
ffffffffc020078a:	00004517          	auipc	a0,0x4
ffffffffc020078e:	77e50513          	addi	a0,a0,1918 # ffffffffc0204f08 <commands+0x2f8>
ffffffffc0200792:	93bff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200796:	646c                	ld	a1,200(s0)
ffffffffc0200798:	00004517          	auipc	a0,0x4
ffffffffc020079c:	78850513          	addi	a0,a0,1928 # ffffffffc0204f20 <commands+0x310>
ffffffffc02007a0:	92dff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007a4:	686c                	ld	a1,208(s0)
ffffffffc02007a6:	00004517          	auipc	a0,0x4
ffffffffc02007aa:	79250513          	addi	a0,a0,1938 # ffffffffc0204f38 <commands+0x328>
ffffffffc02007ae:	91fff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007b2:	6c6c                	ld	a1,216(s0)
ffffffffc02007b4:	00004517          	auipc	a0,0x4
ffffffffc02007b8:	79c50513          	addi	a0,a0,1948 # ffffffffc0204f50 <commands+0x340>
ffffffffc02007bc:	911ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007c0:	706c                	ld	a1,224(s0)
ffffffffc02007c2:	00004517          	auipc	a0,0x4
ffffffffc02007c6:	7a650513          	addi	a0,a0,1958 # ffffffffc0204f68 <commands+0x358>
ffffffffc02007ca:	903ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007ce:	746c                	ld	a1,232(s0)
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	7b050513          	addi	a0,a0,1968 # ffffffffc0204f80 <commands+0x370>
ffffffffc02007d8:	8f5ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007dc:	786c                	ld	a1,240(s0)
ffffffffc02007de:	00004517          	auipc	a0,0x4
ffffffffc02007e2:	7ba50513          	addi	a0,a0,1978 # ffffffffc0204f98 <commands+0x388>
ffffffffc02007e6:	8e7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007ea:	7c6c                	ld	a1,248(s0)
}
ffffffffc02007ec:	6402                	ld	s0,0(sp)
ffffffffc02007ee:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007f0:	00004517          	auipc	a0,0x4
ffffffffc02007f4:	7c050513          	addi	a0,a0,1984 # ffffffffc0204fb0 <commands+0x3a0>
}
ffffffffc02007f8:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc02007fa:	8d3ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02007fe <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc02007fe:	1141                	addi	sp,sp,-16
ffffffffc0200800:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200802:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200804:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	7c250513          	addi	a0,a0,1986 # ffffffffc0204fc8 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020080e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200810:	8bdff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200814:	8522                	mv	a0,s0
ffffffffc0200816:	e1bff0ef          	jal	ra,ffffffffc0200630 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020081a:	10043583          	ld	a1,256(s0)
ffffffffc020081e:	00004517          	auipc	a0,0x4
ffffffffc0200822:	7c250513          	addi	a0,a0,1986 # ffffffffc0204fe0 <commands+0x3d0>
ffffffffc0200826:	8a7ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020082a:	10843583          	ld	a1,264(s0)
ffffffffc020082e:	00004517          	auipc	a0,0x4
ffffffffc0200832:	7ca50513          	addi	a0,a0,1994 # ffffffffc0204ff8 <commands+0x3e8>
ffffffffc0200836:	897ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020083a:	11043583          	ld	a1,272(s0)
ffffffffc020083e:	00004517          	auipc	a0,0x4
ffffffffc0200842:	7d250513          	addi	a0,a0,2002 # ffffffffc0205010 <commands+0x400>
ffffffffc0200846:	887ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020084a:	11843583          	ld	a1,280(s0)
}
ffffffffc020084e:	6402                	ld	s0,0(sp)
ffffffffc0200850:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200852:	00004517          	auipc	a0,0x4
ffffffffc0200856:	7d650513          	addi	a0,a0,2006 # ffffffffc0205028 <commands+0x418>
}
ffffffffc020085a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020085c:	871ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0200860 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200860:	11853783          	ld	a5,280(a0)
ffffffffc0200864:	472d                	li	a4,11
ffffffffc0200866:	0786                	slli	a5,a5,0x1
ffffffffc0200868:	8385                	srli	a5,a5,0x1
ffffffffc020086a:	06f76c63          	bltu	a4,a5,ffffffffc02008e2 <interrupt_handler+0x82>
ffffffffc020086e:	00005717          	auipc	a4,0x5
ffffffffc0200872:	88270713          	addi	a4,a4,-1918 # ffffffffc02050f0 <commands+0x4e0>
ffffffffc0200876:	078a                	slli	a5,a5,0x2
ffffffffc0200878:	97ba                	add	a5,a5,a4
ffffffffc020087a:	439c                	lw	a5,0(a5)
ffffffffc020087c:	97ba                	add	a5,a5,a4
ffffffffc020087e:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200880:	00005517          	auipc	a0,0x5
ffffffffc0200884:	82050513          	addi	a0,a0,-2016 # ffffffffc02050a0 <commands+0x490>
ffffffffc0200888:	845ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc020088c:	00004517          	auipc	a0,0x4
ffffffffc0200890:	7f450513          	addi	a0,a0,2036 # ffffffffc0205080 <commands+0x470>
ffffffffc0200894:	839ff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200898:	00004517          	auipc	a0,0x4
ffffffffc020089c:	7a850513          	addi	a0,a0,1960 # ffffffffc0205040 <commands+0x430>
ffffffffc02008a0:	82dff06f          	j	ffffffffc02000cc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205060 <commands+0x450>
ffffffffc02008ac:	821ff06f          	j	ffffffffc02000cc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008b0:	1141                	addi	sp,sp,-16
ffffffffc02008b2:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02008b4:	c59ff0ef          	jal	ra,ffffffffc020050c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008b8:	00015697          	auipc	a3,0x15
ffffffffc02008bc:	c8068693          	addi	a3,a3,-896 # ffffffffc0215538 <ticks>
ffffffffc02008c0:	629c                	ld	a5,0(a3)
ffffffffc02008c2:	06400713          	li	a4,100
ffffffffc02008c6:	0785                	addi	a5,a5,1
ffffffffc02008c8:	02e7f733          	remu	a4,a5,a4
ffffffffc02008cc:	e29c                	sd	a5,0(a3)
ffffffffc02008ce:	cb19                	beqz	a4,ffffffffc02008e4 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008d0:	60a2                	ld	ra,8(sp)
ffffffffc02008d2:	0141                	addi	sp,sp,16
ffffffffc02008d4:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc02008d6:	00004517          	auipc	a0,0x4
ffffffffc02008da:	7fa50513          	addi	a0,a0,2042 # ffffffffc02050d0 <commands+0x4c0>
ffffffffc02008de:	feeff06f          	j	ffffffffc02000cc <cprintf>
            print_trapframe(tf);
ffffffffc02008e2:	bf31                	j	ffffffffc02007fe <print_trapframe>
}
ffffffffc02008e4:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02008e6:	06400593          	li	a1,100
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	7d650513          	addi	a0,a0,2006 # ffffffffc02050c0 <commands+0x4b0>
}
ffffffffc02008f2:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc02008f4:	fd8ff06f          	j	ffffffffc02000cc <cprintf>

ffffffffc02008f8 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc02008f8:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc02008fc:	1101                	addi	sp,sp,-32
ffffffffc02008fe:	e822                	sd	s0,16(sp)
ffffffffc0200900:	ec06                	sd	ra,24(sp)
ffffffffc0200902:	e426                	sd	s1,8(sp)
ffffffffc0200904:	473d                	li	a4,15
ffffffffc0200906:	842a                	mv	s0,a0
ffffffffc0200908:	14f76a63          	bltu	a4,a5,ffffffffc0200a5c <exception_handler+0x164>
ffffffffc020090c:	00005717          	auipc	a4,0x5
ffffffffc0200910:	9cc70713          	addi	a4,a4,-1588 # ffffffffc02052d8 <commands+0x6c8>
ffffffffc0200914:	078a                	slli	a5,a5,0x2
ffffffffc0200916:	97ba                	add	a5,a5,a4
ffffffffc0200918:	439c                	lw	a5,0(a5)
ffffffffc020091a:	97ba                	add	a5,a5,a4
ffffffffc020091c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020091e:	00005517          	auipc	a0,0x5
ffffffffc0200922:	9a250513          	addi	a0,a0,-1630 # ffffffffc02052c0 <commands+0x6b0>
ffffffffc0200926:	fa6ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020092a:	8522                	mv	a0,s0
ffffffffc020092c:	c7bff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc0200930:	84aa                	mv	s1,a0
ffffffffc0200932:	12051b63          	bnez	a0,ffffffffc0200a68 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200936:	60e2                	ld	ra,24(sp)
ffffffffc0200938:	6442                	ld	s0,16(sp)
ffffffffc020093a:	64a2                	ld	s1,8(sp)
ffffffffc020093c:	6105                	addi	sp,sp,32
ffffffffc020093e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200940:	00004517          	auipc	a0,0x4
ffffffffc0200944:	7e050513          	addi	a0,a0,2016 # ffffffffc0205120 <commands+0x510>
}
ffffffffc0200948:	6442                	ld	s0,16(sp)
ffffffffc020094a:	60e2                	ld	ra,24(sp)
ffffffffc020094c:	64a2                	ld	s1,8(sp)
ffffffffc020094e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200950:	f7cff06f          	j	ffffffffc02000cc <cprintf>
ffffffffc0200954:	00004517          	auipc	a0,0x4
ffffffffc0200958:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205140 <commands+0x530>
ffffffffc020095c:	b7f5                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc020095e:	00005517          	auipc	a0,0x5
ffffffffc0200962:	80250513          	addi	a0,a0,-2046 # ffffffffc0205160 <commands+0x550>
ffffffffc0200966:	b7cd                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200968:	00005517          	auipc	a0,0x5
ffffffffc020096c:	81050513          	addi	a0,a0,-2032 # ffffffffc0205178 <commands+0x568>
ffffffffc0200970:	bfe1                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200972:	00005517          	auipc	a0,0x5
ffffffffc0200976:	81650513          	addi	a0,a0,-2026 # ffffffffc0205188 <commands+0x578>
ffffffffc020097a:	b7f9                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020097c:	00005517          	auipc	a0,0x5
ffffffffc0200980:	82c50513          	addi	a0,a0,-2004 # ffffffffc02051a8 <commands+0x598>
ffffffffc0200984:	f48ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200988:	8522                	mv	a0,s0
ffffffffc020098a:	c1dff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc020098e:	84aa                	mv	s1,a0
ffffffffc0200990:	d15d                	beqz	a0,ffffffffc0200936 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200992:	8522                	mv	a0,s0
ffffffffc0200994:	e6bff0ef          	jal	ra,ffffffffc02007fe <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200998:	86a6                	mv	a3,s1
ffffffffc020099a:	00005617          	auipc	a2,0x5
ffffffffc020099e:	82660613          	addi	a2,a2,-2010 # ffffffffc02051c0 <commands+0x5b0>
ffffffffc02009a2:	0b300593          	li	a1,179
ffffffffc02009a6:	00004517          	auipc	a0,0x4
ffffffffc02009aa:	30a50513          	addi	a0,a0,778 # ffffffffc0204cb0 <commands+0xa0>
ffffffffc02009ae:	81bff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009b2:	00005517          	auipc	a0,0x5
ffffffffc02009b6:	82e50513          	addi	a0,a0,-2002 # ffffffffc02051e0 <commands+0x5d0>
ffffffffc02009ba:	b779                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009bc:	00005517          	auipc	a0,0x5
ffffffffc02009c0:	83c50513          	addi	a0,a0,-1988 # ffffffffc02051f8 <commands+0x5e8>
ffffffffc02009c4:	f08ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009c8:	8522                	mv	a0,s0
ffffffffc02009ca:	bddff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc02009ce:	84aa                	mv	s1,a0
ffffffffc02009d0:	d13d                	beqz	a0,ffffffffc0200936 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009d2:	8522                	mv	a0,s0
ffffffffc02009d4:	e2bff0ef          	jal	ra,ffffffffc02007fe <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009d8:	86a6                	mv	a3,s1
ffffffffc02009da:	00004617          	auipc	a2,0x4
ffffffffc02009de:	7e660613          	addi	a2,a2,2022 # ffffffffc02051c0 <commands+0x5b0>
ffffffffc02009e2:	0bd00593          	li	a1,189
ffffffffc02009e6:	00004517          	auipc	a0,0x4
ffffffffc02009ea:	2ca50513          	addi	a0,a0,714 # ffffffffc0204cb0 <commands+0xa0>
ffffffffc02009ee:	fdaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc02009f2:	00005517          	auipc	a0,0x5
ffffffffc02009f6:	81e50513          	addi	a0,a0,-2018 # ffffffffc0205210 <commands+0x600>
ffffffffc02009fa:	b7b9                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	83450513          	addi	a0,a0,-1996 # ffffffffc0205230 <commands+0x620>
ffffffffc0200a04:	b791                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a06:	00005517          	auipc	a0,0x5
ffffffffc0200a0a:	84a50513          	addi	a0,a0,-1974 # ffffffffc0205250 <commands+0x640>
ffffffffc0200a0e:	bf2d                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	86050513          	addi	a0,a0,-1952 # ffffffffc0205270 <commands+0x660>
ffffffffc0200a18:	bf05                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a1a:	00005517          	auipc	a0,0x5
ffffffffc0200a1e:	87650513          	addi	a0,a0,-1930 # ffffffffc0205290 <commands+0x680>
ffffffffc0200a22:	b71d                	j	ffffffffc0200948 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a24:	00005517          	auipc	a0,0x5
ffffffffc0200a28:	88450513          	addi	a0,a0,-1916 # ffffffffc02052a8 <commands+0x698>
ffffffffc0200a2c:	ea0ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a30:	8522                	mv	a0,s0
ffffffffc0200a32:	b75ff0ef          	jal	ra,ffffffffc02005a6 <pgfault_handler>
ffffffffc0200a36:	84aa                	mv	s1,a0
ffffffffc0200a38:	ee050fe3          	beqz	a0,ffffffffc0200936 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a3c:	8522                	mv	a0,s0
ffffffffc0200a3e:	dc1ff0ef          	jal	ra,ffffffffc02007fe <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a42:	86a6                	mv	a3,s1
ffffffffc0200a44:	00004617          	auipc	a2,0x4
ffffffffc0200a48:	77c60613          	addi	a2,a2,1916 # ffffffffc02051c0 <commands+0x5b0>
ffffffffc0200a4c:	0d300593          	li	a1,211
ffffffffc0200a50:	00004517          	auipc	a0,0x4
ffffffffc0200a54:	26050513          	addi	a0,a0,608 # ffffffffc0204cb0 <commands+0xa0>
ffffffffc0200a58:	f70ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
            print_trapframe(tf);
ffffffffc0200a5c:	8522                	mv	a0,s0
}
ffffffffc0200a5e:	6442                	ld	s0,16(sp)
ffffffffc0200a60:	60e2                	ld	ra,24(sp)
ffffffffc0200a62:	64a2                	ld	s1,8(sp)
ffffffffc0200a64:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a66:	bb61                	j	ffffffffc02007fe <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a68:	8522                	mv	a0,s0
ffffffffc0200a6a:	d95ff0ef          	jal	ra,ffffffffc02007fe <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a6e:	86a6                	mv	a3,s1
ffffffffc0200a70:	00004617          	auipc	a2,0x4
ffffffffc0200a74:	75060613          	addi	a2,a2,1872 # ffffffffc02051c0 <commands+0x5b0>
ffffffffc0200a78:	0da00593          	li	a1,218
ffffffffc0200a7c:	00004517          	auipc	a0,0x4
ffffffffc0200a80:	23450513          	addi	a0,a0,564 # ffffffffc0204cb0 <commands+0xa0>
ffffffffc0200a84:	f44ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200a88 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a88:	11853783          	ld	a5,280(a0)
ffffffffc0200a8c:	0007c363          	bltz	a5,ffffffffc0200a92 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a90:	b5a5                	j	ffffffffc02008f8 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a92:	b3f9                	j	ffffffffc0200860 <interrupt_handler>

ffffffffc0200a94 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
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

    move  a0, sp
ffffffffc0200af4:	850a                	mv	a0,sp
    jal trap
ffffffffc0200af6:	f93ff0ef          	jal	ra,ffffffffc0200a88 <trap>

ffffffffc0200afa <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
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
    # go back from supervisor call
    sret
ffffffffc0200b44:	10200073          	sret

ffffffffc0200b48 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b48:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b4a:	bf45                	j	ffffffffc0200afa <__trapret>
	...

ffffffffc0200b4e <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b4e:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200b50:	00004697          	auipc	a3,0x4
ffffffffc0200b54:	7c868693          	addi	a3,a3,1992 # ffffffffc0205318 <commands+0x708>
ffffffffc0200b58:	00004617          	auipc	a2,0x4
ffffffffc0200b5c:	7e060613          	addi	a2,a2,2016 # ffffffffc0205338 <commands+0x728>
ffffffffc0200b60:	07e00593          	li	a1,126
ffffffffc0200b64:	00004517          	auipc	a0,0x4
ffffffffc0200b68:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205350 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200b6c:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200b6e:	e5aff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200b72 <mm_create>:
mm_create(void) {
ffffffffc0200b72:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200b74:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200b78:	e022                	sd	s0,0(sp)
ffffffffc0200b7a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200b7c:	2ea010ef          	jal	ra,ffffffffc0201e66 <kmalloc>
ffffffffc0200b80:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200b82:	c105                	beqz	a0,ffffffffc0200ba2 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b84:	e408                	sd	a0,8(s0)
ffffffffc0200b86:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200b88:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200b8c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200b90:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b94:	00015797          	auipc	a5,0x15
ffffffffc0200b98:	9d47a783          	lw	a5,-1580(a5) # ffffffffc0215568 <swap_init_ok>
ffffffffc0200b9c:	eb81                	bnez	a5,ffffffffc0200bac <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200b9e:	02053423          	sd	zero,40(a0)
}
ffffffffc0200ba2:	60a2                	ld	ra,8(sp)
ffffffffc0200ba4:	8522                	mv	a0,s0
ffffffffc0200ba6:	6402                	ld	s0,0(sp)
ffffffffc0200ba8:	0141                	addi	sp,sp,16
ffffffffc0200baa:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200bac:	761000ef          	jal	ra,ffffffffc0201b0c <swap_init_mm>
}
ffffffffc0200bb0:	60a2                	ld	ra,8(sp)
ffffffffc0200bb2:	8522                	mv	a0,s0
ffffffffc0200bb4:	6402                	ld	s0,0(sp)
ffffffffc0200bb6:	0141                	addi	sp,sp,16
ffffffffc0200bb8:	8082                	ret

ffffffffc0200bba <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bba:	1101                	addi	sp,sp,-32
ffffffffc0200bbc:	e04a                	sd	s2,0(sp)
ffffffffc0200bbe:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bc0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0200bc4:	e822                	sd	s0,16(sp)
ffffffffc0200bc6:	e426                	sd	s1,8(sp)
ffffffffc0200bc8:	ec06                	sd	ra,24(sp)
ffffffffc0200bca:	84ae                	mv	s1,a1
ffffffffc0200bcc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200bce:	298010ef          	jal	ra,ffffffffc0201e66 <kmalloc>
    if (vma != NULL) {
ffffffffc0200bd2:	c509                	beqz	a0,ffffffffc0200bdc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200bd4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200bd8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200bda:	cd00                	sw	s0,24(a0)
}
ffffffffc0200bdc:	60e2                	ld	ra,24(sp)
ffffffffc0200bde:	6442                	ld	s0,16(sp)
ffffffffc0200be0:	64a2                	ld	s1,8(sp)
ffffffffc0200be2:	6902                	ld	s2,0(sp)
ffffffffc0200be4:	6105                	addi	sp,sp,32
ffffffffc0200be6:	8082                	ret

ffffffffc0200be8 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200be8:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200bea:	c505                	beqz	a0,ffffffffc0200c12 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200bec:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200bee:	c501                	beqz	a0,ffffffffc0200bf6 <find_vma+0xe>
ffffffffc0200bf0:	651c                	ld	a5,8(a0)
ffffffffc0200bf2:	02f5f263          	bgeu	a1,a5,ffffffffc0200c16 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200bf6:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200bf8:	00f68d63          	beq	a3,a5,ffffffffc0200c12 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200bfc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c00:	00e5e663          	bltu	a1,a4,ffffffffc0200c0c <find_vma+0x24>
ffffffffc0200c04:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200c08:	00e5ec63          	bltu	a1,a4,ffffffffc0200c20 <find_vma+0x38>
ffffffffc0200c0c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200c0e:	fef697e3          	bne	a3,a5,ffffffffc0200bfc <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200c12:	4501                	li	a0,0
}
ffffffffc0200c14:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200c16:	691c                	ld	a5,16(a0)
ffffffffc0200c18:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200bf6 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200c1c:	ea88                	sd	a0,16(a3)
ffffffffc0200c1e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200c20:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200c24:	ea88                	sd	a0,16(a3)
ffffffffc0200c26:	8082                	ret

ffffffffc0200c28 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c28:	6590                	ld	a2,8(a1)
ffffffffc0200c2a:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200c2e:	1141                	addi	sp,sp,-16
ffffffffc0200c30:	e406                	sd	ra,8(sp)
ffffffffc0200c32:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c34:	01066763          	bltu	a2,a6,ffffffffc0200c42 <insert_vma_struct+0x1a>
ffffffffc0200c38:	a085                	j	ffffffffc0200c98 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c3a:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200c3e:	04e66863          	bltu	a2,a4,ffffffffc0200c8e <insert_vma_struct+0x66>
ffffffffc0200c42:	86be                	mv	a3,a5
ffffffffc0200c44:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200c46:	fef51ae3          	bne	a0,a5,ffffffffc0200c3a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200c4a:	02a68463          	beq	a3,a0,ffffffffc0200c72 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200c4e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c52:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200c56:	08e8f163          	bgeu	a7,a4,ffffffffc0200cd8 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c5a:	04e66f63          	bltu	a2,a4,ffffffffc0200cb8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200c5e:	00f50a63          	beq	a0,a5,ffffffffc0200c72 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200c62:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c66:	05076963          	bltu	a4,a6,ffffffffc0200cb8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200c6a:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200c6e:	02c77363          	bgeu	a4,a2,ffffffffc0200c94 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200c72:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200c74:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200c76:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200c7a:	e390                	sd	a2,0(a5)
ffffffffc0200c7c:	e690                	sd	a2,8(a3)
}
ffffffffc0200c7e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200c80:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200c82:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200c84:	0017079b          	addiw	a5,a4,1
ffffffffc0200c88:	d11c                	sw	a5,32(a0)
}
ffffffffc0200c8a:	0141                	addi	sp,sp,16
ffffffffc0200c8c:	8082                	ret
    if (le_prev != list) {
ffffffffc0200c8e:	fca690e3          	bne	a3,a0,ffffffffc0200c4e <insert_vma_struct+0x26>
ffffffffc0200c92:	bfd1                	j	ffffffffc0200c66 <insert_vma_struct+0x3e>
ffffffffc0200c94:	ebbff0ef          	jal	ra,ffffffffc0200b4e <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200c98:	00004697          	auipc	a3,0x4
ffffffffc0200c9c:	6c868693          	addi	a3,a3,1736 # ffffffffc0205360 <commands+0x750>
ffffffffc0200ca0:	00004617          	auipc	a2,0x4
ffffffffc0200ca4:	69860613          	addi	a2,a2,1688 # ffffffffc0205338 <commands+0x728>
ffffffffc0200ca8:	08500593          	li	a1,133
ffffffffc0200cac:	00004517          	auipc	a0,0x4
ffffffffc0200cb0:	6a450513          	addi	a0,a0,1700 # ffffffffc0205350 <commands+0x740>
ffffffffc0200cb4:	d14ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200cb8:	00004697          	auipc	a3,0x4
ffffffffc0200cbc:	6e868693          	addi	a3,a3,1768 # ffffffffc02053a0 <commands+0x790>
ffffffffc0200cc0:	00004617          	auipc	a2,0x4
ffffffffc0200cc4:	67860613          	addi	a2,a2,1656 # ffffffffc0205338 <commands+0x728>
ffffffffc0200cc8:	07d00593          	li	a1,125
ffffffffc0200ccc:	00004517          	auipc	a0,0x4
ffffffffc0200cd0:	68450513          	addi	a0,a0,1668 # ffffffffc0205350 <commands+0x740>
ffffffffc0200cd4:	cf4ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200cd8:	00004697          	auipc	a3,0x4
ffffffffc0200cdc:	6a868693          	addi	a3,a3,1704 # ffffffffc0205380 <commands+0x770>
ffffffffc0200ce0:	00004617          	auipc	a2,0x4
ffffffffc0200ce4:	65860613          	addi	a2,a2,1624 # ffffffffc0205338 <commands+0x728>
ffffffffc0200ce8:	07c00593          	li	a1,124
ffffffffc0200cec:	00004517          	auipc	a0,0x4
ffffffffc0200cf0:	66450513          	addi	a0,a0,1636 # ffffffffc0205350 <commands+0x740>
ffffffffc0200cf4:	cd4ff0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0200cf8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200cf8:	1141                	addi	sp,sp,-16
ffffffffc0200cfa:	e022                	sd	s0,0(sp)
ffffffffc0200cfc:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200cfe:	6508                	ld	a0,8(a0)
ffffffffc0200d00:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200d02:	00a40c63          	beq	s0,a0,ffffffffc0200d1a <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d06:	6118                	ld	a4,0(a0)
ffffffffc0200d08:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200d0a:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200d0c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200d0e:	e398                	sd	a4,0(a5)
ffffffffc0200d10:	206010ef          	jal	ra,ffffffffc0201f16 <kfree>
    return listelm->next;
ffffffffc0200d14:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200d16:	fea418e3          	bne	s0,a0,ffffffffc0200d06 <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0200d1a:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200d1c:	6402                	ld	s0,0(sp)
ffffffffc0200d1e:	60a2                	ld	ra,8(sp)
ffffffffc0200d20:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0200d22:	1f40106f          	j	ffffffffc0201f16 <kfree>

ffffffffc0200d26 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200d26:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200d28:	03000513          	li	a0,48
vmm_init(void) {
ffffffffc0200d2c:	fc06                	sd	ra,56(sp)
ffffffffc0200d2e:	f822                	sd	s0,48(sp)
ffffffffc0200d30:	f426                	sd	s1,40(sp)
ffffffffc0200d32:	f04a                	sd	s2,32(sp)
ffffffffc0200d34:	ec4e                	sd	s3,24(sp)
ffffffffc0200d36:	e852                	sd	s4,16(sp)
ffffffffc0200d38:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200d3a:	12c010ef          	jal	ra,ffffffffc0201e66 <kmalloc>
    if (mm != NULL) {
ffffffffc0200d3e:	58050e63          	beqz	a0,ffffffffc02012da <vmm_init+0x5b4>
    elm->prev = elm->next = elm;
ffffffffc0200d42:	e508                	sd	a0,8(a0)
ffffffffc0200d44:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200d46:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200d4a:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200d4e:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d52:	00015797          	auipc	a5,0x15
ffffffffc0200d56:	8167a783          	lw	a5,-2026(a5) # ffffffffc0215568 <swap_init_ok>
ffffffffc0200d5a:	84aa                	mv	s1,a0
ffffffffc0200d5c:	e7b9                	bnez	a5,ffffffffc0200daa <vmm_init+0x84>
        else mm->sm_priv = NULL;
ffffffffc0200d5e:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200d62:	03200413          	li	s0,50
ffffffffc0200d66:	a811                	j	ffffffffc0200d7a <vmm_init+0x54>
        vma->vm_start = vm_start;
ffffffffc0200d68:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d6a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d6c:	00052c23          	sw	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200d70:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d72:	8526                	mv	a0,s1
ffffffffc0200d74:	eb5ff0ef          	jal	ra,ffffffffc0200c28 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200d78:	cc05                	beqz	s0,ffffffffc0200db0 <vmm_init+0x8a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d7a:	03000513          	li	a0,48
ffffffffc0200d7e:	0e8010ef          	jal	ra,ffffffffc0201e66 <kmalloc>
ffffffffc0200d82:	85aa                	mv	a1,a0
ffffffffc0200d84:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d88:	f165                	bnez	a0,ffffffffc0200d68 <vmm_init+0x42>
        assert(vma != NULL);
ffffffffc0200d8a:	00005697          	auipc	a3,0x5
ffffffffc0200d8e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0205618 <commands+0xa08>
ffffffffc0200d92:	00004617          	auipc	a2,0x4
ffffffffc0200d96:	5a660613          	addi	a2,a2,1446 # ffffffffc0205338 <commands+0x728>
ffffffffc0200d9a:	0c900593          	li	a1,201
ffffffffc0200d9e:	00004517          	auipc	a0,0x4
ffffffffc0200da2:	5b250513          	addi	a0,a0,1458 # ffffffffc0205350 <commands+0x740>
ffffffffc0200da6:	c22ff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200daa:	563000ef          	jal	ra,ffffffffc0201b0c <swap_init_mm>
ffffffffc0200dae:	bf55                	j	ffffffffc0200d62 <vmm_init+0x3c>
ffffffffc0200db0:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200db4:	1f900913          	li	s2,505
ffffffffc0200db8:	a819                	j	ffffffffc0200dce <vmm_init+0xa8>
        vma->vm_start = vm_start;
ffffffffc0200dba:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200dbc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200dbe:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dc2:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200dc4:	8526                	mv	a0,s1
ffffffffc0200dc6:	e63ff0ef          	jal	ra,ffffffffc0200c28 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200dca:	03240a63          	beq	s0,s2,ffffffffc0200dfe <vmm_init+0xd8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200dce:	03000513          	li	a0,48
ffffffffc0200dd2:	094010ef          	jal	ra,ffffffffc0201e66 <kmalloc>
ffffffffc0200dd6:	85aa                	mv	a1,a0
ffffffffc0200dd8:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200ddc:	fd79                	bnez	a0,ffffffffc0200dba <vmm_init+0x94>
        assert(vma != NULL);
ffffffffc0200dde:	00005697          	auipc	a3,0x5
ffffffffc0200de2:	83a68693          	addi	a3,a3,-1990 # ffffffffc0205618 <commands+0xa08>
ffffffffc0200de6:	00004617          	auipc	a2,0x4
ffffffffc0200dea:	55260613          	addi	a2,a2,1362 # ffffffffc0205338 <commands+0x728>
ffffffffc0200dee:	0cf00593          	li	a1,207
ffffffffc0200df2:	00004517          	auipc	a0,0x4
ffffffffc0200df6:	55e50513          	addi	a0,a0,1374 # ffffffffc0205350 <commands+0x740>
ffffffffc0200dfa:	bceff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return listelm->next;
ffffffffc0200dfe:	649c                	ld	a5,8(s1)
ffffffffc0200e00:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200e02:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200e06:	30f48e63          	beq	s1,a5,ffffffffc0201122 <vmm_init+0x3fc>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200e0a:	fe87b683          	ld	a3,-24(a5)
ffffffffc0200e0e:	ffe70613          	addi	a2,a4,-2
ffffffffc0200e12:	2ad61863          	bne	a2,a3,ffffffffc02010c2 <vmm_init+0x39c>
ffffffffc0200e16:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200e1a:	2ae69463          	bne	a3,a4,ffffffffc02010c2 <vmm_init+0x39c>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200e1e:	0715                	addi	a4,a4,5
ffffffffc0200e20:	679c                	ld	a5,8(a5)
ffffffffc0200e22:	feb712e3          	bne	a4,a1,ffffffffc0200e06 <vmm_init+0xe0>
ffffffffc0200e26:	4a1d                	li	s4,7
ffffffffc0200e28:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e2a:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200e2e:	85a2                	mv	a1,s0
ffffffffc0200e30:	8526                	mv	a0,s1
ffffffffc0200e32:	db7ff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
ffffffffc0200e36:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200e38:	34050563          	beqz	a0,ffffffffc0201182 <vmm_init+0x45c>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200e3c:	00140593          	addi	a1,s0,1
ffffffffc0200e40:	8526                	mv	a0,s1
ffffffffc0200e42:	da7ff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
ffffffffc0200e46:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0200e48:	34050d63          	beqz	a0,ffffffffc02011a2 <vmm_init+0x47c>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200e4c:	85d2                	mv	a1,s4
ffffffffc0200e4e:	8526                	mv	a0,s1
ffffffffc0200e50:	d99ff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0200e54:	36051763          	bnez	a0,ffffffffc02011c2 <vmm_init+0x49c>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200e58:	00340593          	addi	a1,s0,3
ffffffffc0200e5c:	8526                	mv	a0,s1
ffffffffc0200e5e:	d8bff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0200e62:	2e051063          	bnez	a0,ffffffffc0201142 <vmm_init+0x41c>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200e66:	00440593          	addi	a1,s0,4
ffffffffc0200e6a:	8526                	mv	a0,s1
ffffffffc0200e6c:	d7dff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0200e70:	2e051963          	bnez	a0,ffffffffc0201162 <vmm_init+0x43c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200e74:	00893783          	ld	a5,8(s2)
ffffffffc0200e78:	26879563          	bne	a5,s0,ffffffffc02010e2 <vmm_init+0x3bc>
ffffffffc0200e7c:	01093783          	ld	a5,16(s2)
ffffffffc0200e80:	27479163          	bne	a5,s4,ffffffffc02010e2 <vmm_init+0x3bc>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200e84:	0089b783          	ld	a5,8(s3)
ffffffffc0200e88:	26879d63          	bne	a5,s0,ffffffffc0201102 <vmm_init+0x3dc>
ffffffffc0200e8c:	0109b783          	ld	a5,16(s3)
ffffffffc0200e90:	27479963          	bne	a5,s4,ffffffffc0201102 <vmm_init+0x3dc>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e94:	0415                	addi	s0,s0,5
ffffffffc0200e96:	0a15                	addi	s4,s4,5
ffffffffc0200e98:	f9541be3          	bne	s0,s5,ffffffffc0200e2e <vmm_init+0x108>
ffffffffc0200e9c:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e9e:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200ea0:	85a2                	mv	a1,s0
ffffffffc0200ea2:	8526                	mv	a0,s1
ffffffffc0200ea4:	d45ff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
ffffffffc0200ea8:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200eac:	c90d                	beqz	a0,ffffffffc0200ede <vmm_init+0x1b8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200eae:	6914                	ld	a3,16(a0)
ffffffffc0200eb0:	6510                	ld	a2,8(a0)
ffffffffc0200eb2:	00004517          	auipc	a0,0x4
ffffffffc0200eb6:	60e50513          	addi	a0,a0,1550 # ffffffffc02054c0 <commands+0x8b0>
ffffffffc0200eba:	a12ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200ebe:	00004697          	auipc	a3,0x4
ffffffffc0200ec2:	62a68693          	addi	a3,a3,1578 # ffffffffc02054e8 <commands+0x8d8>
ffffffffc0200ec6:	00004617          	auipc	a2,0x4
ffffffffc0200eca:	47260613          	addi	a2,a2,1138 # ffffffffc0205338 <commands+0x728>
ffffffffc0200ece:	0f100593          	li	a1,241
ffffffffc0200ed2:	00004517          	auipc	a0,0x4
ffffffffc0200ed6:	47e50513          	addi	a0,a0,1150 # ffffffffc0205350 <commands+0x740>
ffffffffc0200eda:	aeeff0ef          	jal	ra,ffffffffc02001c8 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200ede:	147d                	addi	s0,s0,-1
ffffffffc0200ee0:	fd2410e3          	bne	s0,s2,ffffffffc0200ea0 <vmm_init+0x17a>
ffffffffc0200ee4:	a801                	j	ffffffffc0200ef4 <vmm_init+0x1ce>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ee6:	6118                	ld	a4,0(a0)
ffffffffc0200ee8:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0200eea:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200eec:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200eee:	e398                	sd	a4,0(a5)
ffffffffc0200ef0:	026010ef          	jal	ra,ffffffffc0201f16 <kfree>
    return listelm->next;
ffffffffc0200ef4:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200ef6:	fea498e3          	bne	s1,a0,ffffffffc0200ee6 <vmm_init+0x1c0>
    kfree(mm); //kfree mm
ffffffffc0200efa:	8526                	mv	a0,s1
ffffffffc0200efc:	01a010ef          	jal	ra,ffffffffc0201f16 <kfree>
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200f00:	00004517          	auipc	a0,0x4
ffffffffc0200f04:	60050513          	addi	a0,a0,1536 # ffffffffc0205500 <commands+0x8f0>
ffffffffc0200f08:	9c4ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200f0c:	0a6020ef          	jal	ra,ffffffffc0202fb2 <nr_free_pages>
ffffffffc0200f10:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200f12:	03000513          	li	a0,48
ffffffffc0200f16:	751000ef          	jal	ra,ffffffffc0201e66 <kmalloc>
ffffffffc0200f1a:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200f1c:	2c050363          	beqz	a0,ffffffffc02011e2 <vmm_init+0x4bc>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f20:	00014797          	auipc	a5,0x14
ffffffffc0200f24:	6487a783          	lw	a5,1608(a5) # ffffffffc0215568 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200f28:	e508                	sd	a0,8(a0)
ffffffffc0200f2a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200f2c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200f30:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200f34:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200f38:	18079263          	bnez	a5,ffffffffc02010bc <vmm_init+0x396>
        else mm->sm_priv = NULL;
ffffffffc0200f3c:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();
    assert(check_mm_struct != NULL);

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f40:	00014917          	auipc	s2,0x14
ffffffffc0200f44:	64093903          	ld	s2,1600(s2) # ffffffffc0215580 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200f48:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200f4c:	00014717          	auipc	a4,0x14
ffffffffc0200f50:	5e873e23          	sd	s0,1532(a4) # ffffffffc0215548 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200f54:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200f58:	36079163          	bnez	a5,ffffffffc02012ba <vmm_init+0x594>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200f5c:	03000513          	li	a0,48
ffffffffc0200f60:	707000ef          	jal	ra,ffffffffc0201e66 <kmalloc>
ffffffffc0200f64:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc0200f66:	2a050263          	beqz	a0,ffffffffc020120a <vmm_init+0x4e4>
        vma->vm_end = vm_end;
ffffffffc0200f6a:	002007b7          	lui	a5,0x200
ffffffffc0200f6e:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc0200f72:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200f74:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f76:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc0200f7a:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200f7c:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc0200f80:	ca9ff0ef          	jal	ra,ffffffffc0200c28 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f84:	10000593          	li	a1,256
ffffffffc0200f88:	8522                	mv	a0,s0
ffffffffc0200f8a:	c5fff0ef          	jal	ra,ffffffffc0200be8 <find_vma>
ffffffffc0200f8e:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f92:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f96:	28a99a63          	bne	s3,a0,ffffffffc020122a <vmm_init+0x504>
        *(char *)(addr + i) = i;
ffffffffc0200f9a:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200f9e:	0785                	addi	a5,a5,1
ffffffffc0200fa0:	fee79de3          	bne	a5,a4,ffffffffc0200f9a <vmm_init+0x274>
        sum += i;
ffffffffc0200fa4:	6705                	lui	a4,0x1
ffffffffc0200fa6:	10000793          	li	a5,256
ffffffffc0200faa:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200fae:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200fb2:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200fb6:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200fb8:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200fba:	fec79ce3          	bne	a5,a2,ffffffffc0200fb2 <vmm_init+0x28c>
    }
    assert(sum == 0);
ffffffffc0200fbe:	28071663          	bnez	a4,ffffffffc020124a <vmm_init+0x524>
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fc2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200fc6:	00014a97          	auipc	s5,0x14
ffffffffc0200fca:	5c2a8a93          	addi	s5,s5,1474 # ffffffffc0215588 <npage>
ffffffffc0200fce:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0200fd2:	078a                	slli	a5,a5,0x2
ffffffffc0200fd4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200fd6:	28c7fa63          	bgeu	a5,a2,ffffffffc020126a <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0200fda:	00006a17          	auipc	s4,0x6
ffffffffc0200fde:	9cea3a03          	ld	s4,-1586(s4) # ffffffffc02069a8 <nbase>
ffffffffc0200fe2:	414787b3          	sub	a5,a5,s4
ffffffffc0200fe6:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0200fe8:	8799                	srai	a5,a5,0x6
ffffffffc0200fea:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0200fec:	00c79713          	slli	a4,a5,0xc
ffffffffc0200ff0:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ff2:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0200ff6:	28c77663          	bgeu	a4,a2,ffffffffc0201282 <vmm_init+0x55c>
ffffffffc0200ffa:	00014997          	auipc	s3,0x14
ffffffffc0200ffe:	5a69b983          	ld	s3,1446(s3) # ffffffffc02155a0 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0201002:	4581                	li	a1,0
ffffffffc0201004:	854a                	mv	a0,s2
ffffffffc0201006:	99b6                	add	s3,s3,a3
ffffffffc0201008:	20a020ef          	jal	ra,ffffffffc0203212 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020100c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201010:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201014:	078a                	slli	a5,a5,0x2
ffffffffc0201016:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201018:	24e7f963          	bgeu	a5,a4,ffffffffc020126a <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc020101c:	00014997          	auipc	s3,0x14
ffffffffc0201020:	57498993          	addi	s3,s3,1396 # ffffffffc0215590 <pages>
ffffffffc0201024:	0009b503          	ld	a0,0(s3)
ffffffffc0201028:	414787b3          	sub	a5,a5,s4
ffffffffc020102c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc020102e:	953e                	add	a0,a0,a5
ffffffffc0201030:	4585                	li	a1,1
ffffffffc0201032:	741010ef          	jal	ra,ffffffffc0202f72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201036:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020103a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020103e:	078a                	slli	a5,a5,0x2
ffffffffc0201040:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201042:	22e7f463          	bgeu	a5,a4,ffffffffc020126a <vmm_init+0x544>
    return &pages[PPN(pa) - nbase];
ffffffffc0201046:	0009b503          	ld	a0,0(s3)
ffffffffc020104a:	414787b3          	sub	a5,a5,s4
ffffffffc020104e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0201050:	4585                	li	a1,1
ffffffffc0201052:	953e                	add	a0,a0,a5
ffffffffc0201054:	71f010ef          	jal	ra,ffffffffc0202f72 <free_pages>
    pgdir[0] = 0;
ffffffffc0201058:	00093023          	sd	zero,0(s2)
    page->ref -= 1;
    return page->ref;
}

static inline void flush_tlb() {
  asm volatile("sfence.vma");
ffffffffc020105c:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201060:	6408                	ld	a0,8(s0)
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0201062:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0201066:	00a40c63          	beq	s0,a0,ffffffffc020107e <vmm_init+0x358>
    __list_del(listelm->prev, listelm->next);
ffffffffc020106a:	6118                	ld	a4,0(a0)
ffffffffc020106c:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020106e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0201070:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201072:	e398                	sd	a4,0(a5)
ffffffffc0201074:	6a3000ef          	jal	ra,ffffffffc0201f16 <kfree>
    return listelm->next;
ffffffffc0201078:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020107a:	fea418e3          	bne	s0,a0,ffffffffc020106a <vmm_init+0x344>
    kfree(mm); //kfree mm
ffffffffc020107e:	8522                	mv	a0,s0
ffffffffc0201080:	697000ef          	jal	ra,ffffffffc0201f16 <kfree>
    mm_destroy(mm);
    check_mm_struct = NULL;
ffffffffc0201084:	00014797          	auipc	a5,0x14
ffffffffc0201088:	4c07b223          	sd	zero,1220(a5) # ffffffffc0215548 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020108c:	727010ef          	jal	ra,ffffffffc0202fb2 <nr_free_pages>
ffffffffc0201090:	20a49563          	bne	s1,a0,ffffffffc020129a <vmm_init+0x574>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0201094:	00004517          	auipc	a0,0x4
ffffffffc0201098:	54c50513          	addi	a0,a0,1356 # ffffffffc02055e0 <commands+0x9d0>
ffffffffc020109c:	830ff0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02010a0:	7442                	ld	s0,48(sp)
ffffffffc02010a2:	70e2                	ld	ra,56(sp)
ffffffffc02010a4:	74a2                	ld	s1,40(sp)
ffffffffc02010a6:	7902                	ld	s2,32(sp)
ffffffffc02010a8:	69e2                	ld	s3,24(sp)
ffffffffc02010aa:	6a42                	ld	s4,16(sp)
ffffffffc02010ac:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010ae:	00004517          	auipc	a0,0x4
ffffffffc02010b2:	55250513          	addi	a0,a0,1362 # ffffffffc0205600 <commands+0x9f0>
}
ffffffffc02010b6:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02010b8:	814ff06f          	j	ffffffffc02000cc <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02010bc:	251000ef          	jal	ra,ffffffffc0201b0c <swap_init_mm>
ffffffffc02010c0:	b541                	j	ffffffffc0200f40 <vmm_init+0x21a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	31668693          	addi	a3,a3,790 # ffffffffc02053d8 <commands+0x7c8>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	26e60613          	addi	a2,a2,622 # ffffffffc0205338 <commands+0x728>
ffffffffc02010d2:	0d800593          	li	a1,216
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	27a50513          	addi	a0,a0,634 # ffffffffc0205350 <commands+0x740>
ffffffffc02010de:	8eaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	37e68693          	addi	a3,a3,894 # ffffffffc0205460 <commands+0x850>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	24e60613          	addi	a2,a2,590 # ffffffffc0205338 <commands+0x728>
ffffffffc02010f2:	0e800593          	li	a1,232
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	25a50513          	addi	a0,a0,602 # ffffffffc0205350 <commands+0x740>
ffffffffc02010fe:	8caff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	38e68693          	addi	a3,a3,910 # ffffffffc0205490 <commands+0x880>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	22e60613          	addi	a2,a2,558 # ffffffffc0205338 <commands+0x728>
ffffffffc0201112:	0e900593          	li	a1,233
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	23a50513          	addi	a0,a0,570 # ffffffffc0205350 <commands+0x740>
ffffffffc020111e:	8aaff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	29e68693          	addi	a3,a3,670 # ffffffffc02053c0 <commands+0x7b0>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	20e60613          	addi	a2,a2,526 # ffffffffc0205338 <commands+0x728>
ffffffffc0201132:	0d600593          	li	a1,214
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	21a50513          	addi	a0,a0,538 # ffffffffc0205350 <commands+0x740>
ffffffffc020113e:	88aff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma4 == NULL);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	2fe68693          	addi	a3,a3,766 # ffffffffc0205440 <commands+0x830>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	1ee60613          	addi	a2,a2,494 # ffffffffc0205338 <commands+0x728>
ffffffffc0201152:	0e400593          	li	a1,228
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	1fa50513          	addi	a0,a0,506 # ffffffffc0205350 <commands+0x740>
ffffffffc020115e:	86aff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma5 == NULL);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	2ee68693          	addi	a3,a3,750 # ffffffffc0205450 <commands+0x840>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	1ce60613          	addi	a2,a2,462 # ffffffffc0205338 <commands+0x728>
ffffffffc0201172:	0e600593          	li	a1,230
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	1da50513          	addi	a0,a0,474 # ffffffffc0205350 <commands+0x740>
ffffffffc020117e:	84aff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma1 != NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	28e68693          	addi	a3,a3,654 # ffffffffc0205410 <commands+0x800>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	1ae60613          	addi	a2,a2,430 # ffffffffc0205338 <commands+0x728>
ffffffffc0201192:	0de00593          	li	a1,222
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	1ba50513          	addi	a0,a0,442 # ffffffffc0205350 <commands+0x740>
ffffffffc020119e:	82aff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma2 != NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	27e68693          	addi	a3,a3,638 # ffffffffc0205420 <commands+0x810>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	18e60613          	addi	a2,a2,398 # ffffffffc0205338 <commands+0x728>
ffffffffc02011b2:	0e000593          	li	a1,224
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	19a50513          	addi	a0,a0,410 # ffffffffc0205350 <commands+0x740>
ffffffffc02011be:	80aff0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert(vma3 == NULL);
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	26e68693          	addi	a3,a3,622 # ffffffffc0205430 <commands+0x820>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	16e60613          	addi	a2,a2,366 # ffffffffc0205338 <commands+0x728>
ffffffffc02011d2:	0e200593          	li	a1,226
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	17a50513          	addi	a0,a0,378 # ffffffffc0205350 <commands+0x740>
ffffffffc02011de:	febfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	44668693          	addi	a3,a3,1094 # ffffffffc0205628 <commands+0xa18>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	14e60613          	addi	a2,a2,334 # ffffffffc0205338 <commands+0x728>
ffffffffc02011f2:	10100593          	li	a1,257
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	15a50513          	addi	a0,a0,346 # ffffffffc0205350 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc02011fe:	00014797          	auipc	a5,0x14
ffffffffc0201202:	3407b523          	sd	zero,842(a5) # ffffffffc0215548 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc0201206:	fc3fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(vma != NULL);
ffffffffc020120a:	00004697          	auipc	a3,0x4
ffffffffc020120e:	40e68693          	addi	a3,a3,1038 # ffffffffc0205618 <commands+0xa08>
ffffffffc0201212:	00004617          	auipc	a2,0x4
ffffffffc0201216:	12660613          	addi	a2,a2,294 # ffffffffc0205338 <commands+0x728>
ffffffffc020121a:	10800593          	li	a1,264
ffffffffc020121e:	00004517          	auipc	a0,0x4
ffffffffc0201222:	13250513          	addi	a0,a0,306 # ffffffffc0205350 <commands+0x740>
ffffffffc0201226:	fa3fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020122a:	00004697          	auipc	a3,0x4
ffffffffc020122e:	30668693          	addi	a3,a3,774 # ffffffffc0205530 <commands+0x920>
ffffffffc0201232:	00004617          	auipc	a2,0x4
ffffffffc0201236:	10660613          	addi	a2,a2,262 # ffffffffc0205338 <commands+0x728>
ffffffffc020123a:	10d00593          	li	a1,269
ffffffffc020123e:	00004517          	auipc	a0,0x4
ffffffffc0201242:	11250513          	addi	a0,a0,274 # ffffffffc0205350 <commands+0x740>
ffffffffc0201246:	f83fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(sum == 0);
ffffffffc020124a:	00004697          	auipc	a3,0x4
ffffffffc020124e:	30668693          	addi	a3,a3,774 # ffffffffc0205550 <commands+0x940>
ffffffffc0201252:	00004617          	auipc	a2,0x4
ffffffffc0201256:	0e660613          	addi	a2,a2,230 # ffffffffc0205338 <commands+0x728>
ffffffffc020125a:	11700593          	li	a1,279
ffffffffc020125e:	00004517          	auipc	a0,0x4
ffffffffc0201262:	0f250513          	addi	a0,a0,242 # ffffffffc0205350 <commands+0x740>
ffffffffc0201266:	f63fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020126a:	00004617          	auipc	a2,0x4
ffffffffc020126e:	2f660613          	addi	a2,a2,758 # ffffffffc0205560 <commands+0x950>
ffffffffc0201272:	06200593          	li	a1,98
ffffffffc0201276:	00004517          	auipc	a0,0x4
ffffffffc020127a:	30a50513          	addi	a0,a0,778 # ffffffffc0205580 <commands+0x970>
ffffffffc020127e:	f4bfe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201282:	00004617          	auipc	a2,0x4
ffffffffc0201286:	30e60613          	addi	a2,a2,782 # ffffffffc0205590 <commands+0x980>
ffffffffc020128a:	06900593          	li	a1,105
ffffffffc020128e:	00004517          	auipc	a0,0x4
ffffffffc0201292:	2f250513          	addi	a0,a0,754 # ffffffffc0205580 <commands+0x970>
ffffffffc0201296:	f33fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020129a:	00004697          	auipc	a3,0x4
ffffffffc020129e:	31e68693          	addi	a3,a3,798 # ffffffffc02055b8 <commands+0x9a8>
ffffffffc02012a2:	00004617          	auipc	a2,0x4
ffffffffc02012a6:	09660613          	addi	a2,a2,150 # ffffffffc0205338 <commands+0x728>
ffffffffc02012aa:	12400593          	li	a1,292
ffffffffc02012ae:	00004517          	auipc	a0,0x4
ffffffffc02012b2:	0a250513          	addi	a0,a0,162 # ffffffffc0205350 <commands+0x740>
ffffffffc02012b6:	f13fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02012ba:	00004697          	auipc	a3,0x4
ffffffffc02012be:	26668693          	addi	a3,a3,614 # ffffffffc0205520 <commands+0x910>
ffffffffc02012c2:	00004617          	auipc	a2,0x4
ffffffffc02012c6:	07660613          	addi	a2,a2,118 # ffffffffc0205338 <commands+0x728>
ffffffffc02012ca:	10500593          	li	a1,261
ffffffffc02012ce:	00004517          	auipc	a0,0x4
ffffffffc02012d2:	08250513          	addi	a0,a0,130 # ffffffffc0205350 <commands+0x740>
ffffffffc02012d6:	ef3fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(mm != NULL);
ffffffffc02012da:	00004697          	auipc	a3,0x4
ffffffffc02012de:	36668693          	addi	a3,a3,870 # ffffffffc0205640 <commands+0xa30>
ffffffffc02012e2:	00004617          	auipc	a2,0x4
ffffffffc02012e6:	05660613          	addi	a2,a2,86 # ffffffffc0205338 <commands+0x728>
ffffffffc02012ea:	0c200593          	li	a1,194
ffffffffc02012ee:	00004517          	auipc	a0,0x4
ffffffffc02012f2:	06250513          	addi	a0,a0,98 # ffffffffc0205350 <commands+0x740>
ffffffffc02012f6:	ed3fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02012fa <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02012fa:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02012fc:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc02012fe:	e822                	sd	s0,16(sp)
ffffffffc0201300:	e426                	sd	s1,8(sp)
ffffffffc0201302:	ec06                	sd	ra,24(sp)
ffffffffc0201304:	e04a                	sd	s2,0(sp)
ffffffffc0201306:	8432                	mv	s0,a2
ffffffffc0201308:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020130a:	8dfff0ef          	jal	ra,ffffffffc0200be8 <find_vma>

    pgfault_num++;
ffffffffc020130e:	00014797          	auipc	a5,0x14
ffffffffc0201312:	2427a783          	lw	a5,578(a5) # ffffffffc0215550 <pgfault_num>
ffffffffc0201316:	2785                	addiw	a5,a5,1
ffffffffc0201318:	00014717          	auipc	a4,0x14
ffffffffc020131c:	22f72c23          	sw	a5,568(a4) # ffffffffc0215550 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201320:	c931                	beqz	a0,ffffffffc0201374 <do_pgfault+0x7a>
ffffffffc0201322:	651c                	ld	a5,8(a0)
ffffffffc0201324:	04f46863          	bltu	s0,a5,ffffffffc0201374 <do_pgfault+0x7a>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201328:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020132a:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020132c:	8b89                	andi	a5,a5,2
ffffffffc020132e:	e39d                	bnez	a5,ffffffffc0201354 <do_pgfault+0x5a>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201330:	75fd                	lui	a1,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201332:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201334:	8c6d                	and	s0,s0,a1
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201336:	4605                	li	a2,1
ffffffffc0201338:	85a2                	mv	a1,s0
ffffffffc020133a:	4b3010ef          	jal	ra,ffffffffc0202fec <get_pte>
ffffffffc020133e:	cd21                	beqz	a0,ffffffffc0201396 <do_pgfault+0x9c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0201340:	610c                	ld	a1,0(a0)
ffffffffc0201342:	c999                	beqz	a1,ffffffffc0201358 <do_pgfault+0x5e>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0201344:	00014797          	auipc	a5,0x14
ffffffffc0201348:	2247a783          	lw	a5,548(a5) # ffffffffc0215568 <swap_init_ok>
ffffffffc020134c:	cf8d                	beqz	a5,ffffffffc0201386 <do_pgfault+0x8c>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc020134e:	02003c23          	sd	zero,56(zero) # 38 <kern_entry-0xffffffffc01fffc8>
ffffffffc0201352:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0201354:	495d                	li	s2,23
ffffffffc0201356:	bfe9                	j	ffffffffc0201330 <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201358:	6c88                	ld	a0,24(s1)
ffffffffc020135a:	864a                	mv	a2,s2
ffffffffc020135c:	85a2                	mv	a1,s0
ffffffffc020135e:	3e7020ef          	jal	ra,ffffffffc0203f44 <pgdir_alloc_page>
ffffffffc0201362:	87aa                	mv	a5,a0
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0201364:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201366:	c3a1                	beqz	a5,ffffffffc02013a6 <do_pgfault+0xac>
failed:
    return ret;
}
ffffffffc0201368:	60e2                	ld	ra,24(sp)
ffffffffc020136a:	6442                	ld	s0,16(sp)
ffffffffc020136c:	64a2                	ld	s1,8(sp)
ffffffffc020136e:	6902                	ld	s2,0(sp)
ffffffffc0201370:	6105                	addi	sp,sp,32
ffffffffc0201372:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201374:	85a2                	mv	a1,s0
ffffffffc0201376:	00004517          	auipc	a0,0x4
ffffffffc020137a:	2da50513          	addi	a0,a0,730 # ffffffffc0205650 <commands+0xa40>
ffffffffc020137e:	d4ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = -E_INVAL;
ffffffffc0201382:	5575                	li	a0,-3
        goto failed;
ffffffffc0201384:	b7d5                	j	ffffffffc0201368 <do_pgfault+0x6e>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201386:	00004517          	auipc	a0,0x4
ffffffffc020138a:	34250513          	addi	a0,a0,834 # ffffffffc02056c8 <commands+0xab8>
ffffffffc020138e:	d3ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201392:	5571                	li	a0,-4
            goto failed;
ffffffffc0201394:	bfd1                	j	ffffffffc0201368 <do_pgfault+0x6e>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201396:	00004517          	auipc	a0,0x4
ffffffffc020139a:	2ea50513          	addi	a0,a0,746 # ffffffffc0205680 <commands+0xa70>
ffffffffc020139e:	d2ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013a2:	5571                	li	a0,-4
        goto failed;
ffffffffc02013a4:	b7d1                	j	ffffffffc0201368 <do_pgfault+0x6e>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02013a6:	00004517          	auipc	a0,0x4
ffffffffc02013aa:	2fa50513          	addi	a0,a0,762 # ffffffffc02056a0 <commands+0xa90>
ffffffffc02013ae:	d1ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    ret = -E_NO_MEM;
ffffffffc02013b2:	5571                	li	a0,-4
            goto failed;
ffffffffc02013b4:	bf55                	j	ffffffffc0201368 <do_pgfault+0x6e>

ffffffffc02013b6 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc02013b6:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc02013b8:	00004617          	auipc	a2,0x4
ffffffffc02013bc:	1a860613          	addi	a2,a2,424 # ffffffffc0205560 <commands+0x950>
ffffffffc02013c0:	06200593          	li	a1,98
ffffffffc02013c4:	00004517          	auipc	a0,0x4
ffffffffc02013c8:	1bc50513          	addi	a0,a0,444 # ffffffffc0205580 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc02013cc:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02013ce:	dfbfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02013d2 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02013d2:	7135                	addi	sp,sp,-160
ffffffffc02013d4:	ed06                	sd	ra,152(sp)
ffffffffc02013d6:	e922                	sd	s0,144(sp)
ffffffffc02013d8:	e526                	sd	s1,136(sp)
ffffffffc02013da:	e14a                	sd	s2,128(sp)
ffffffffc02013dc:	fcce                	sd	s3,120(sp)
ffffffffc02013de:	f8d2                	sd	s4,112(sp)
ffffffffc02013e0:	f4d6                	sd	s5,104(sp)
ffffffffc02013e2:	f0da                	sd	s6,96(sp)
ffffffffc02013e4:	ecde                	sd	s7,88(sp)
ffffffffc02013e6:	e8e2                	sd	s8,80(sp)
ffffffffc02013e8:	e4e6                	sd	s9,72(sp)
ffffffffc02013ea:	e0ea                	sd	s10,64(sp)
ffffffffc02013ec:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02013ee:	40f020ef          	jal	ra,ffffffffc0203ffc <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02013f2:	00014697          	auipc	a3,0x14
ffffffffc02013f6:	1666b683          	ld	a3,358(a3) # ffffffffc0215558 <max_swap_offset>
ffffffffc02013fa:	010007b7          	lui	a5,0x1000
ffffffffc02013fe:	ff968713          	addi	a4,a3,-7
ffffffffc0201402:	17e1                	addi	a5,a5,-8
ffffffffc0201404:	42e7e063          	bltu	a5,a4,ffffffffc0201824 <swap_init+0x452>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0201408:	00009797          	auipc	a5,0x9
ffffffffc020140c:	c0878793          	addi	a5,a5,-1016 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0201410:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0201412:	00014b97          	auipc	s7,0x14
ffffffffc0201416:	14eb8b93          	addi	s7,s7,334 # ffffffffc0215560 <sm>
ffffffffc020141a:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc020141e:	9702                	jalr	a4
ffffffffc0201420:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc0201422:	c10d                	beqz	a0,ffffffffc0201444 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201424:	60ea                	ld	ra,152(sp)
ffffffffc0201426:	644a                	ld	s0,144(sp)
ffffffffc0201428:	64aa                	ld	s1,136(sp)
ffffffffc020142a:	79e6                	ld	s3,120(sp)
ffffffffc020142c:	7a46                	ld	s4,112(sp)
ffffffffc020142e:	7aa6                	ld	s5,104(sp)
ffffffffc0201430:	7b06                	ld	s6,96(sp)
ffffffffc0201432:	6be6                	ld	s7,88(sp)
ffffffffc0201434:	6c46                	ld	s8,80(sp)
ffffffffc0201436:	6ca6                	ld	s9,72(sp)
ffffffffc0201438:	6d06                	ld	s10,64(sp)
ffffffffc020143a:	7de2                	ld	s11,56(sp)
ffffffffc020143c:	854a                	mv	a0,s2
ffffffffc020143e:	690a                	ld	s2,128(sp)
ffffffffc0201440:	610d                	addi	sp,sp,160
ffffffffc0201442:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201444:	000bb783          	ld	a5,0(s7)
ffffffffc0201448:	00004517          	auipc	a0,0x4
ffffffffc020144c:	2d850513          	addi	a0,a0,728 # ffffffffc0205720 <commands+0xb10>
ffffffffc0201450:	00010417          	auipc	s0,0x10
ffffffffc0201454:	0a840413          	addi	s0,s0,168 # ffffffffc02114f8 <free_area>
ffffffffc0201458:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020145a:	4785                	li	a5,1
ffffffffc020145c:	00014717          	auipc	a4,0x14
ffffffffc0201460:	10f72623          	sw	a5,268(a4) # ffffffffc0215568 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201464:	c69fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0201468:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc020146a:	4d01                	li	s10,0
ffffffffc020146c:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020146e:	32878b63          	beq	a5,s0,ffffffffc02017a4 <swap_init+0x3d2>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201472:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201476:	8b09                	andi	a4,a4,2
ffffffffc0201478:	32070863          	beqz	a4,ffffffffc02017a8 <swap_init+0x3d6>
        count ++, total += p->property;
ffffffffc020147c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201480:	679c                	ld	a5,8(a5)
ffffffffc0201482:	2d85                	addiw	s11,s11,1
ffffffffc0201484:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201488:	fe8795e3          	bne	a5,s0,ffffffffc0201472 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc020148c:	84ea                	mv	s1,s10
ffffffffc020148e:	325010ef          	jal	ra,ffffffffc0202fb2 <nr_free_pages>
ffffffffc0201492:	42951163          	bne	a0,s1,ffffffffc02018b4 <swap_init+0x4e2>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0201496:	866a                	mv	a2,s10
ffffffffc0201498:	85ee                	mv	a1,s11
ffffffffc020149a:	00004517          	auipc	a0,0x4
ffffffffc020149e:	2ce50513          	addi	a0,a0,718 # ffffffffc0205768 <commands+0xb58>
ffffffffc02014a2:	c2bfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02014a6:	eccff0ef          	jal	ra,ffffffffc0200b72 <mm_create>
ffffffffc02014aa:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc02014ac:	46050463          	beqz	a0,ffffffffc0201914 <swap_init+0x542>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02014b0:	00014797          	auipc	a5,0x14
ffffffffc02014b4:	09878793          	addi	a5,a5,152 # ffffffffc0215548 <check_mm_struct>
ffffffffc02014b8:	6398                	ld	a4,0(a5)
ffffffffc02014ba:	3c071d63          	bnez	a4,ffffffffc0201894 <swap_init+0x4c2>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02014be:	00014717          	auipc	a4,0x14
ffffffffc02014c2:	0c270713          	addi	a4,a4,194 # ffffffffc0215580 <boot_pgdir>
ffffffffc02014c6:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc02014ca:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc02014cc:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02014d0:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02014d4:	42079063          	bnez	a5,ffffffffc02018f4 <swap_init+0x522>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02014d8:	6599                	lui	a1,0x6
ffffffffc02014da:	460d                	li	a2,3
ffffffffc02014dc:	6505                	lui	a0,0x1
ffffffffc02014de:	edcff0ef          	jal	ra,ffffffffc0200bba <vma_create>
ffffffffc02014e2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02014e4:	52050463          	beqz	a0,ffffffffc0201a0c <swap_init+0x63a>

     insert_vma_struct(mm, vma);
ffffffffc02014e8:	8556                	mv	a0,s5
ffffffffc02014ea:	f3eff0ef          	jal	ra,ffffffffc0200c28 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02014ee:	00004517          	auipc	a0,0x4
ffffffffc02014f2:	2ba50513          	addi	a0,a0,698 # ffffffffc02057a8 <commands+0xb98>
ffffffffc02014f6:	bd7fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02014fa:	018ab503          	ld	a0,24(s5)
ffffffffc02014fe:	4605                	li	a2,1
ffffffffc0201500:	6585                	lui	a1,0x1
ffffffffc0201502:	2eb010ef          	jal	ra,ffffffffc0202fec <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201506:	4c050363          	beqz	a0,ffffffffc02019cc <swap_init+0x5fa>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020150a:	00004517          	auipc	a0,0x4
ffffffffc020150e:	2ee50513          	addi	a0,a0,750 # ffffffffc02057f8 <commands+0xbe8>
ffffffffc0201512:	00010497          	auipc	s1,0x10
ffffffffc0201516:	f6648493          	addi	s1,s1,-154 # ffffffffc0211478 <check_rp>
ffffffffc020151a:	bb3fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020151e:	00010997          	auipc	s3,0x10
ffffffffc0201522:	f7a98993          	addi	s3,s3,-134 # ffffffffc0211498 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201526:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc0201528:	4505                	li	a0,1
ffffffffc020152a:	1b7010ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020152e:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc0201532:	2c050963          	beqz	a0,ffffffffc0201804 <swap_init+0x432>
ffffffffc0201536:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201538:	8b89                	andi	a5,a5,2
ffffffffc020153a:	32079d63          	bnez	a5,ffffffffc0201874 <swap_init+0x4a2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020153e:	0a21                	addi	s4,s4,8
ffffffffc0201540:	ff3a14e3          	bne	s4,s3,ffffffffc0201528 <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0201544:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0201546:	00010a17          	auipc	s4,0x10
ffffffffc020154a:	f32a0a13          	addi	s4,s4,-206 # ffffffffc0211478 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc020154e:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc0201550:	ec3e                	sd	a5,24(sp)
ffffffffc0201552:	641c                	ld	a5,8(s0)
ffffffffc0201554:	e400                	sd	s0,8(s0)
ffffffffc0201556:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0201558:	481c                	lw	a5,16(s0)
ffffffffc020155a:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc020155c:	00010797          	auipc	a5,0x10
ffffffffc0201560:	fa07a623          	sw	zero,-84(a5) # ffffffffc0211508 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0201564:	000a3503          	ld	a0,0(s4)
ffffffffc0201568:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020156a:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc020156c:	207010ef          	jal	ra,ffffffffc0202f72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201570:	ff3a1ae3          	bne	s4,s3,ffffffffc0201564 <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201574:	01042a03          	lw	s4,16(s0)
ffffffffc0201578:	4791                	li	a5,4
ffffffffc020157a:	42fa1963          	bne	s4,a5,ffffffffc02019ac <swap_init+0x5da>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020157e:	00004517          	auipc	a0,0x4
ffffffffc0201582:	30250513          	addi	a0,a0,770 # ffffffffc0205880 <commands+0xc70>
ffffffffc0201586:	b47fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020158a:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020158c:	00014797          	auipc	a5,0x14
ffffffffc0201590:	fc07a223          	sw	zero,-60(a5) # ffffffffc0215550 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0201594:	4629                	li	a2,10
ffffffffc0201596:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc020159a:	00014697          	auipc	a3,0x14
ffffffffc020159e:	fb66a683          	lw	a3,-74(a3) # ffffffffc0215550 <pgfault_num>
ffffffffc02015a2:	4585                	li	a1,1
ffffffffc02015a4:	00014797          	auipc	a5,0x14
ffffffffc02015a8:	fac78793          	addi	a5,a5,-84 # ffffffffc0215550 <pgfault_num>
ffffffffc02015ac:	54b69063          	bne	a3,a1,ffffffffc0201aec <swap_init+0x71a>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02015b0:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc02015b4:	4398                	lw	a4,0(a5)
ffffffffc02015b6:	2701                	sext.w	a4,a4
ffffffffc02015b8:	3cd71a63          	bne	a4,a3,ffffffffc020198c <swap_init+0x5ba>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02015bc:	6689                	lui	a3,0x2
ffffffffc02015be:	462d                	li	a2,11
ffffffffc02015c0:	00c68023          	sb	a2,0(a3) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02015c4:	4398                	lw	a4,0(a5)
ffffffffc02015c6:	4589                	li	a1,2
ffffffffc02015c8:	2701                	sext.w	a4,a4
ffffffffc02015ca:	4ab71163          	bne	a4,a1,ffffffffc0201a6c <swap_init+0x69a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02015ce:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02015d2:	4394                	lw	a3,0(a5)
ffffffffc02015d4:	2681                	sext.w	a3,a3
ffffffffc02015d6:	4ae69b63          	bne	a3,a4,ffffffffc0201a8c <swap_init+0x6ba>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02015da:	668d                	lui	a3,0x3
ffffffffc02015dc:	4631                	li	a2,12
ffffffffc02015de:	00c68023          	sb	a2,0(a3) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc02015e2:	4398                	lw	a4,0(a5)
ffffffffc02015e4:	458d                	li	a1,3
ffffffffc02015e6:	2701                	sext.w	a4,a4
ffffffffc02015e8:	4cb71263          	bne	a4,a1,ffffffffc0201aac <swap_init+0x6da>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02015ec:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02015f0:	4394                	lw	a3,0(a5)
ffffffffc02015f2:	2681                	sext.w	a3,a3
ffffffffc02015f4:	4ce69c63          	bne	a3,a4,ffffffffc0201acc <swap_init+0x6fa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02015f8:	6691                	lui	a3,0x4
ffffffffc02015fa:	4635                	li	a2,13
ffffffffc02015fc:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0201600:	4398                	lw	a4,0(a5)
ffffffffc0201602:	2701                	sext.w	a4,a4
ffffffffc0201604:	43471463          	bne	a4,s4,ffffffffc0201a2c <swap_init+0x65a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201608:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc020160c:	439c                	lw	a5,0(a5)
ffffffffc020160e:	2781                	sext.w	a5,a5
ffffffffc0201610:	42e79e63          	bne	a5,a4,ffffffffc0201a4c <swap_init+0x67a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201614:	481c                	lw	a5,16(s0)
ffffffffc0201616:	2a079f63          	bnez	a5,ffffffffc02018d4 <swap_init+0x502>
ffffffffc020161a:	00010797          	auipc	a5,0x10
ffffffffc020161e:	e7e78793          	addi	a5,a5,-386 # ffffffffc0211498 <swap_in_seq_no>
ffffffffc0201622:	00010717          	auipc	a4,0x10
ffffffffc0201626:	e9e70713          	addi	a4,a4,-354 # ffffffffc02114c0 <swap_out_seq_no>
ffffffffc020162a:	00010617          	auipc	a2,0x10
ffffffffc020162e:	e9660613          	addi	a2,a2,-362 # ffffffffc02114c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201632:	56fd                	li	a3,-1
ffffffffc0201634:	c394                	sw	a3,0(a5)
ffffffffc0201636:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201638:	0791                	addi	a5,a5,4
ffffffffc020163a:	0711                	addi	a4,a4,4
ffffffffc020163c:	fec79ce3          	bne	a5,a2,ffffffffc0201634 <swap_init+0x262>
ffffffffc0201640:	00010717          	auipc	a4,0x10
ffffffffc0201644:	e1870713          	addi	a4,a4,-488 # ffffffffc0211458 <check_ptep>
ffffffffc0201648:	00010697          	auipc	a3,0x10
ffffffffc020164c:	e3068693          	addi	a3,a3,-464 # ffffffffc0211478 <check_rp>
ffffffffc0201650:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc0201652:	00014c17          	auipc	s8,0x14
ffffffffc0201656:	f36c0c13          	addi	s8,s8,-202 # ffffffffc0215588 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020165a:	00014c97          	auipc	s9,0x14
ffffffffc020165e:	f36c8c93          	addi	s9,s9,-202 # ffffffffc0215590 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0201662:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201666:	4601                	li	a2,0
ffffffffc0201668:	855a                	mv	a0,s6
ffffffffc020166a:	e836                	sd	a3,16(sp)
ffffffffc020166c:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc020166e:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0201670:	17d010ef          	jal	ra,ffffffffc0202fec <get_pte>
ffffffffc0201674:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0201676:	65a2                	ld	a1,8(sp)
ffffffffc0201678:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020167a:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc020167c:	1c050063          	beqz	a0,ffffffffc020183c <swap_init+0x46a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0201680:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201682:	0017f613          	andi	a2,a5,1
ffffffffc0201686:	1c060b63          	beqz	a2,ffffffffc020185c <swap_init+0x48a>
    if (PPN(pa) >= npage) {
ffffffffc020168a:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020168e:	078a                	slli	a5,a5,0x2
ffffffffc0201690:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201692:	12c7fd63          	bgeu	a5,a2,ffffffffc02017cc <swap_init+0x3fa>
    return &pages[PPN(pa) - nbase];
ffffffffc0201696:	00005617          	auipc	a2,0x5
ffffffffc020169a:	31260613          	addi	a2,a2,786 # ffffffffc02069a8 <nbase>
ffffffffc020169e:	00063a03          	ld	s4,0(a2)
ffffffffc02016a2:	000cb603          	ld	a2,0(s9)
ffffffffc02016a6:	6288                	ld	a0,0(a3)
ffffffffc02016a8:	414787b3          	sub	a5,a5,s4
ffffffffc02016ac:	079a                	slli	a5,a5,0x6
ffffffffc02016ae:	97b2                	add	a5,a5,a2
ffffffffc02016b0:	12f51a63          	bne	a0,a5,ffffffffc02017e4 <swap_init+0x412>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02016b4:	6785                	lui	a5,0x1
ffffffffc02016b6:	95be                	add	a1,a1,a5
ffffffffc02016b8:	6795                	lui	a5,0x5
ffffffffc02016ba:	0721                	addi	a4,a4,8
ffffffffc02016bc:	06a1                	addi	a3,a3,8
ffffffffc02016be:	faf592e3          	bne	a1,a5,ffffffffc0201662 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02016c2:	00004517          	auipc	a0,0x4
ffffffffc02016c6:	29e50513          	addi	a0,a0,670 # ffffffffc0205960 <commands+0xd50>
ffffffffc02016ca:	a03fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    int ret = sm->check_swap();
ffffffffc02016ce:	000bb783          	ld	a5,0(s7)
ffffffffc02016d2:	7f9c                	ld	a5,56(a5)
ffffffffc02016d4:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02016d6:	30051b63          	bnez	a0,ffffffffc02019ec <swap_init+0x61a>

     nr_free = nr_free_store;
ffffffffc02016da:	77a2                	ld	a5,40(sp)
ffffffffc02016dc:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc02016de:	67e2                	ld	a5,24(sp)
ffffffffc02016e0:	e01c                	sd	a5,0(s0)
ffffffffc02016e2:	7782                	ld	a5,32(sp)
ffffffffc02016e4:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02016e6:	6088                	ld	a0,0(s1)
ffffffffc02016e8:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02016ea:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc02016ec:	087010ef          	jal	ra,ffffffffc0202f72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02016f0:	ff349be3          	bne	s1,s3,ffffffffc02016e6 <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc02016f4:	8556                	mv	a0,s5
ffffffffc02016f6:	e02ff0ef          	jal	ra,ffffffffc0200cf8 <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02016fa:	00014797          	auipc	a5,0x14
ffffffffc02016fe:	e8678793          	addi	a5,a5,-378 # ffffffffc0215580 <boot_pgdir>
ffffffffc0201702:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201704:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201708:	639c                	ld	a5,0(a5)
ffffffffc020170a:	078a                	slli	a5,a5,0x2
ffffffffc020170c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020170e:	0ae7fd63          	bgeu	a5,a4,ffffffffc02017c8 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201712:	414786b3          	sub	a3,a5,s4
ffffffffc0201716:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0201718:	8699                	srai	a3,a3,0x6
ffffffffc020171a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020171c:	00c69793          	slli	a5,a3,0xc
ffffffffc0201720:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0201722:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201726:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201728:	22e7f663          	bgeu	a5,a4,ffffffffc0201954 <swap_init+0x582>
     free_page(pde2page(pd0[0]));
ffffffffc020172c:	00014797          	auipc	a5,0x14
ffffffffc0201730:	e747b783          	ld	a5,-396(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0201734:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201736:	629c                	ld	a5,0(a3)
ffffffffc0201738:	078a                	slli	a5,a5,0x2
ffffffffc020173a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020173c:	08e7f663          	bgeu	a5,a4,ffffffffc02017c8 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc0201740:	414787b3          	sub	a5,a5,s4
ffffffffc0201744:	079a                	slli	a5,a5,0x6
ffffffffc0201746:	953e                	add	a0,a0,a5
ffffffffc0201748:	4585                	li	a1,1
ffffffffc020174a:	029010ef          	jal	ra,ffffffffc0202f72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020174e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201752:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201756:	078a                	slli	a5,a5,0x2
ffffffffc0201758:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020175a:	06e7f763          	bgeu	a5,a4,ffffffffc02017c8 <swap_init+0x3f6>
    return &pages[PPN(pa) - nbase];
ffffffffc020175e:	000cb503          	ld	a0,0(s9)
ffffffffc0201762:	414787b3          	sub	a5,a5,s4
ffffffffc0201766:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0201768:	4585                	li	a1,1
ffffffffc020176a:	953e                	add	a0,a0,a5
ffffffffc020176c:	007010ef          	jal	ra,ffffffffc0202f72 <free_pages>
     pgdir[0] = 0;
ffffffffc0201770:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0201774:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0201778:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020177a:	00878a63          	beq	a5,s0,ffffffffc020178e <swap_init+0x3bc>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020177e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201782:	679c                	ld	a5,8(a5)
ffffffffc0201784:	3dfd                	addiw	s11,s11,-1
ffffffffc0201786:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020178a:	fe879ae3          	bne	a5,s0,ffffffffc020177e <swap_init+0x3ac>
     }
     assert(count==0);
ffffffffc020178e:	1c0d9f63          	bnez	s11,ffffffffc020196c <swap_init+0x59a>
     assert(total==0);
ffffffffc0201792:	1a0d1163          	bnez	s10,ffffffffc0201934 <swap_init+0x562>

     cprintf("check_swap() succeeded!\n");
ffffffffc0201796:	00004517          	auipc	a0,0x4
ffffffffc020179a:	21a50513          	addi	a0,a0,538 # ffffffffc02059b0 <commands+0xda0>
ffffffffc020179e:	92ffe0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc02017a2:	b149                	j	ffffffffc0201424 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc02017a4:	4481                	li	s1,0
ffffffffc02017a6:	b1e5                	j	ffffffffc020148e <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc02017a8:	00004697          	auipc	a3,0x4
ffffffffc02017ac:	f9068693          	addi	a3,a3,-112 # ffffffffc0205738 <commands+0xb28>
ffffffffc02017b0:	00004617          	auipc	a2,0x4
ffffffffc02017b4:	b8860613          	addi	a2,a2,-1144 # ffffffffc0205338 <commands+0x728>
ffffffffc02017b8:	0bd00593          	li	a1,189
ffffffffc02017bc:	00004517          	auipc	a0,0x4
ffffffffc02017c0:	f5450513          	addi	a0,a0,-172 # ffffffffc0205710 <commands+0xb00>
ffffffffc02017c4:	a05fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02017c8:	befff0ef          	jal	ra,ffffffffc02013b6 <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc02017cc:	00004617          	auipc	a2,0x4
ffffffffc02017d0:	d9460613          	addi	a2,a2,-620 # ffffffffc0205560 <commands+0x950>
ffffffffc02017d4:	06200593          	li	a1,98
ffffffffc02017d8:	00004517          	auipc	a0,0x4
ffffffffc02017dc:	da850513          	addi	a0,a0,-600 # ffffffffc0205580 <commands+0x970>
ffffffffc02017e0:	9e9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02017e4:	00004697          	auipc	a3,0x4
ffffffffc02017e8:	15468693          	addi	a3,a3,340 # ffffffffc0205938 <commands+0xd28>
ffffffffc02017ec:	00004617          	auipc	a2,0x4
ffffffffc02017f0:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0205338 <commands+0x728>
ffffffffc02017f4:	0fd00593          	li	a1,253
ffffffffc02017f8:	00004517          	auipc	a0,0x4
ffffffffc02017fc:	f1850513          	addi	a0,a0,-232 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201800:	9c9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201804:	00004697          	auipc	a3,0x4
ffffffffc0201808:	01c68693          	addi	a3,a3,28 # ffffffffc0205820 <commands+0xc10>
ffffffffc020180c:	00004617          	auipc	a2,0x4
ffffffffc0201810:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0205338 <commands+0x728>
ffffffffc0201814:	0dd00593          	li	a1,221
ffffffffc0201818:	00004517          	auipc	a0,0x4
ffffffffc020181c:	ef850513          	addi	a0,a0,-264 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201820:	9a9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201824:	00004617          	auipc	a2,0x4
ffffffffc0201828:	ecc60613          	addi	a2,a2,-308 # ffffffffc02056f0 <commands+0xae0>
ffffffffc020182c:	02a00593          	li	a1,42
ffffffffc0201830:	00004517          	auipc	a0,0x4
ffffffffc0201834:	ee050513          	addi	a0,a0,-288 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201838:	991fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020183c:	00004697          	auipc	a3,0x4
ffffffffc0201840:	0bc68693          	addi	a3,a3,188 # ffffffffc02058f8 <commands+0xce8>
ffffffffc0201844:	00004617          	auipc	a2,0x4
ffffffffc0201848:	af460613          	addi	a2,a2,-1292 # ffffffffc0205338 <commands+0x728>
ffffffffc020184c:	0fc00593          	li	a1,252
ffffffffc0201850:	00004517          	auipc	a0,0x4
ffffffffc0201854:	ec050513          	addi	a0,a0,-320 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201858:	971fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020185c:	00004617          	auipc	a2,0x4
ffffffffc0201860:	0b460613          	addi	a2,a2,180 # ffffffffc0205910 <commands+0xd00>
ffffffffc0201864:	07400593          	li	a1,116
ffffffffc0201868:	00004517          	auipc	a0,0x4
ffffffffc020186c:	d1850513          	addi	a0,a0,-744 # ffffffffc0205580 <commands+0x970>
ffffffffc0201870:	959fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201874:	00004697          	auipc	a3,0x4
ffffffffc0201878:	fc468693          	addi	a3,a3,-60 # ffffffffc0205838 <commands+0xc28>
ffffffffc020187c:	00004617          	auipc	a2,0x4
ffffffffc0201880:	abc60613          	addi	a2,a2,-1348 # ffffffffc0205338 <commands+0x728>
ffffffffc0201884:	0de00593          	li	a1,222
ffffffffc0201888:	00004517          	auipc	a0,0x4
ffffffffc020188c:	e8850513          	addi	a0,a0,-376 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201890:	939fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201894:	00004697          	auipc	a3,0x4
ffffffffc0201898:	efc68693          	addi	a3,a3,-260 # ffffffffc0205790 <commands+0xb80>
ffffffffc020189c:	00004617          	auipc	a2,0x4
ffffffffc02018a0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0205338 <commands+0x728>
ffffffffc02018a4:	0c800593          	li	a1,200
ffffffffc02018a8:	00004517          	auipc	a0,0x4
ffffffffc02018ac:	e6850513          	addi	a0,a0,-408 # ffffffffc0205710 <commands+0xb00>
ffffffffc02018b0:	919fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total == nr_free_pages());
ffffffffc02018b4:	00004697          	auipc	a3,0x4
ffffffffc02018b8:	e9468693          	addi	a3,a3,-364 # ffffffffc0205748 <commands+0xb38>
ffffffffc02018bc:	00004617          	auipc	a2,0x4
ffffffffc02018c0:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0205338 <commands+0x728>
ffffffffc02018c4:	0c000593          	li	a1,192
ffffffffc02018c8:	00004517          	auipc	a0,0x4
ffffffffc02018cc:	e4850513          	addi	a0,a0,-440 # ffffffffc0205710 <commands+0xb00>
ffffffffc02018d0:	8f9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert( nr_free == 0);         
ffffffffc02018d4:	00004697          	auipc	a3,0x4
ffffffffc02018d8:	01468693          	addi	a3,a3,20 # ffffffffc02058e8 <commands+0xcd8>
ffffffffc02018dc:	00004617          	auipc	a2,0x4
ffffffffc02018e0:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0205338 <commands+0x728>
ffffffffc02018e4:	0f400593          	li	a1,244
ffffffffc02018e8:	00004517          	auipc	a0,0x4
ffffffffc02018ec:	e2850513          	addi	a0,a0,-472 # ffffffffc0205710 <commands+0xb00>
ffffffffc02018f0:	8d9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgdir[0] == 0);
ffffffffc02018f4:	00004697          	auipc	a3,0x4
ffffffffc02018f8:	c2c68693          	addi	a3,a3,-980 # ffffffffc0205520 <commands+0x910>
ffffffffc02018fc:	00004617          	auipc	a2,0x4
ffffffffc0201900:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0205338 <commands+0x728>
ffffffffc0201904:	0cd00593          	li	a1,205
ffffffffc0201908:	00004517          	auipc	a0,0x4
ffffffffc020190c:	e0850513          	addi	a0,a0,-504 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201910:	8b9fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(mm != NULL);
ffffffffc0201914:	00004697          	auipc	a3,0x4
ffffffffc0201918:	d2c68693          	addi	a3,a3,-724 # ffffffffc0205640 <commands+0xa30>
ffffffffc020191c:	00004617          	auipc	a2,0x4
ffffffffc0201920:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0205338 <commands+0x728>
ffffffffc0201924:	0c500593          	li	a1,197
ffffffffc0201928:	00004517          	auipc	a0,0x4
ffffffffc020192c:	de850513          	addi	a0,a0,-536 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201930:	899fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(total==0);
ffffffffc0201934:	00004697          	auipc	a3,0x4
ffffffffc0201938:	06c68693          	addi	a3,a3,108 # ffffffffc02059a0 <commands+0xd90>
ffffffffc020193c:	00004617          	auipc	a2,0x4
ffffffffc0201940:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0205338 <commands+0x728>
ffffffffc0201944:	11d00593          	li	a1,285
ffffffffc0201948:	00004517          	auipc	a0,0x4
ffffffffc020194c:	dc850513          	addi	a0,a0,-568 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201950:	879fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0201954:	00004617          	auipc	a2,0x4
ffffffffc0201958:	c3c60613          	addi	a2,a2,-964 # ffffffffc0205590 <commands+0x980>
ffffffffc020195c:	06900593          	li	a1,105
ffffffffc0201960:	00004517          	auipc	a0,0x4
ffffffffc0201964:	c2050513          	addi	a0,a0,-992 # ffffffffc0205580 <commands+0x970>
ffffffffc0201968:	861fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(count==0);
ffffffffc020196c:	00004697          	auipc	a3,0x4
ffffffffc0201970:	02468693          	addi	a3,a3,36 # ffffffffc0205990 <commands+0xd80>
ffffffffc0201974:	00004617          	auipc	a2,0x4
ffffffffc0201978:	9c460613          	addi	a2,a2,-1596 # ffffffffc0205338 <commands+0x728>
ffffffffc020197c:	11c00593          	li	a1,284
ffffffffc0201980:	00004517          	auipc	a0,0x4
ffffffffc0201984:	d9050513          	addi	a0,a0,-624 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201988:	841fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc020198c:	00004697          	auipc	a3,0x4
ffffffffc0201990:	f1c68693          	addi	a3,a3,-228 # ffffffffc02058a8 <commands+0xc98>
ffffffffc0201994:	00004617          	auipc	a2,0x4
ffffffffc0201998:	9a460613          	addi	a2,a2,-1628 # ffffffffc0205338 <commands+0x728>
ffffffffc020199c:	09600593          	li	a1,150
ffffffffc02019a0:	00004517          	auipc	a0,0x4
ffffffffc02019a4:	d7050513          	addi	a0,a0,-656 # ffffffffc0205710 <commands+0xb00>
ffffffffc02019a8:	821fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02019ac:	00004697          	auipc	a3,0x4
ffffffffc02019b0:	eac68693          	addi	a3,a3,-340 # ffffffffc0205858 <commands+0xc48>
ffffffffc02019b4:	00004617          	auipc	a2,0x4
ffffffffc02019b8:	98460613          	addi	a2,a2,-1660 # ffffffffc0205338 <commands+0x728>
ffffffffc02019bc:	0eb00593          	li	a1,235
ffffffffc02019c0:	00004517          	auipc	a0,0x4
ffffffffc02019c4:	d5050513          	addi	a0,a0,-688 # ffffffffc0205710 <commands+0xb00>
ffffffffc02019c8:	801fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02019cc:	00004697          	auipc	a3,0x4
ffffffffc02019d0:	e1468693          	addi	a3,a3,-492 # ffffffffc02057e0 <commands+0xbd0>
ffffffffc02019d4:	00004617          	auipc	a2,0x4
ffffffffc02019d8:	96460613          	addi	a2,a2,-1692 # ffffffffc0205338 <commands+0x728>
ffffffffc02019dc:	0d800593          	li	a1,216
ffffffffc02019e0:	00004517          	auipc	a0,0x4
ffffffffc02019e4:	d3050513          	addi	a0,a0,-720 # ffffffffc0205710 <commands+0xb00>
ffffffffc02019e8:	fe0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(ret==0);
ffffffffc02019ec:	00004697          	auipc	a3,0x4
ffffffffc02019f0:	f9c68693          	addi	a3,a3,-100 # ffffffffc0205988 <commands+0xd78>
ffffffffc02019f4:	00004617          	auipc	a2,0x4
ffffffffc02019f8:	94460613          	addi	a2,a2,-1724 # ffffffffc0205338 <commands+0x728>
ffffffffc02019fc:	10300593          	li	a1,259
ffffffffc0201a00:	00004517          	auipc	a0,0x4
ffffffffc0201a04:	d1050513          	addi	a0,a0,-752 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201a08:	fc0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(vma != NULL);
ffffffffc0201a0c:	00004697          	auipc	a3,0x4
ffffffffc0201a10:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0205618 <commands+0xa08>
ffffffffc0201a14:	00004617          	auipc	a2,0x4
ffffffffc0201a18:	92460613          	addi	a2,a2,-1756 # ffffffffc0205338 <commands+0x728>
ffffffffc0201a1c:	0d000593          	li	a1,208
ffffffffc0201a20:	00004517          	auipc	a0,0x4
ffffffffc0201a24:	cf050513          	addi	a0,a0,-784 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201a28:	fa0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc0201a2c:	00004697          	auipc	a3,0x4
ffffffffc0201a30:	eac68693          	addi	a3,a3,-340 # ffffffffc02058d8 <commands+0xcc8>
ffffffffc0201a34:	00004617          	auipc	a2,0x4
ffffffffc0201a38:	90460613          	addi	a2,a2,-1788 # ffffffffc0205338 <commands+0x728>
ffffffffc0201a3c:	0a000593          	li	a1,160
ffffffffc0201a40:	00004517          	auipc	a0,0x4
ffffffffc0201a44:	cd050513          	addi	a0,a0,-816 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201a48:	f80fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==4);
ffffffffc0201a4c:	00004697          	auipc	a3,0x4
ffffffffc0201a50:	e8c68693          	addi	a3,a3,-372 # ffffffffc02058d8 <commands+0xcc8>
ffffffffc0201a54:	00004617          	auipc	a2,0x4
ffffffffc0201a58:	8e460613          	addi	a2,a2,-1820 # ffffffffc0205338 <commands+0x728>
ffffffffc0201a5c:	0a200593          	li	a1,162
ffffffffc0201a60:	00004517          	auipc	a0,0x4
ffffffffc0201a64:	cb050513          	addi	a0,a0,-848 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201a68:	f60fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc0201a6c:	00004697          	auipc	a3,0x4
ffffffffc0201a70:	e4c68693          	addi	a3,a3,-436 # ffffffffc02058b8 <commands+0xca8>
ffffffffc0201a74:	00004617          	auipc	a2,0x4
ffffffffc0201a78:	8c460613          	addi	a2,a2,-1852 # ffffffffc0205338 <commands+0x728>
ffffffffc0201a7c:	09800593          	li	a1,152
ffffffffc0201a80:	00004517          	auipc	a0,0x4
ffffffffc0201a84:	c9050513          	addi	a0,a0,-880 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201a88:	f40fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==2);
ffffffffc0201a8c:	00004697          	auipc	a3,0x4
ffffffffc0201a90:	e2c68693          	addi	a3,a3,-468 # ffffffffc02058b8 <commands+0xca8>
ffffffffc0201a94:	00004617          	auipc	a2,0x4
ffffffffc0201a98:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205338 <commands+0x728>
ffffffffc0201a9c:	09a00593          	li	a1,154
ffffffffc0201aa0:	00004517          	auipc	a0,0x4
ffffffffc0201aa4:	c7050513          	addi	a0,a0,-912 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201aa8:	f20fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc0201aac:	00004697          	auipc	a3,0x4
ffffffffc0201ab0:	e1c68693          	addi	a3,a3,-484 # ffffffffc02058c8 <commands+0xcb8>
ffffffffc0201ab4:	00004617          	auipc	a2,0x4
ffffffffc0201ab8:	88460613          	addi	a2,a2,-1916 # ffffffffc0205338 <commands+0x728>
ffffffffc0201abc:	09c00593          	li	a1,156
ffffffffc0201ac0:	00004517          	auipc	a0,0x4
ffffffffc0201ac4:	c5050513          	addi	a0,a0,-944 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201ac8:	f00fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==3);
ffffffffc0201acc:	00004697          	auipc	a3,0x4
ffffffffc0201ad0:	dfc68693          	addi	a3,a3,-516 # ffffffffc02058c8 <commands+0xcb8>
ffffffffc0201ad4:	00004617          	auipc	a2,0x4
ffffffffc0201ad8:	86460613          	addi	a2,a2,-1948 # ffffffffc0205338 <commands+0x728>
ffffffffc0201adc:	09e00593          	li	a1,158
ffffffffc0201ae0:	00004517          	auipc	a0,0x4
ffffffffc0201ae4:	c3050513          	addi	a0,a0,-976 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201ae8:	ee0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(pgfault_num==1);
ffffffffc0201aec:	00004697          	auipc	a3,0x4
ffffffffc0201af0:	dbc68693          	addi	a3,a3,-580 # ffffffffc02058a8 <commands+0xc98>
ffffffffc0201af4:	00004617          	auipc	a2,0x4
ffffffffc0201af8:	84460613          	addi	a2,a2,-1980 # ffffffffc0205338 <commands+0x728>
ffffffffc0201afc:	09400593          	li	a1,148
ffffffffc0201b00:	00004517          	auipc	a0,0x4
ffffffffc0201b04:	c1050513          	addi	a0,a0,-1008 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201b08:	ec0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201b0c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0201b0c:	00014797          	auipc	a5,0x14
ffffffffc0201b10:	a547b783          	ld	a5,-1452(a5) # ffffffffc0215560 <sm>
ffffffffc0201b14:	6b9c                	ld	a5,16(a5)
ffffffffc0201b16:	8782                	jr	a5

ffffffffc0201b18 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0201b18:	00014797          	auipc	a5,0x14
ffffffffc0201b1c:	a487b783          	ld	a5,-1464(a5) # ffffffffc0215560 <sm>
ffffffffc0201b20:	739c                	ld	a5,32(a5)
ffffffffc0201b22:	8782                	jr	a5

ffffffffc0201b24 <swap_out>:
{
ffffffffc0201b24:	711d                	addi	sp,sp,-96
ffffffffc0201b26:	ec86                	sd	ra,88(sp)
ffffffffc0201b28:	e8a2                	sd	s0,80(sp)
ffffffffc0201b2a:	e4a6                	sd	s1,72(sp)
ffffffffc0201b2c:	e0ca                	sd	s2,64(sp)
ffffffffc0201b2e:	fc4e                	sd	s3,56(sp)
ffffffffc0201b30:	f852                	sd	s4,48(sp)
ffffffffc0201b32:	f456                	sd	s5,40(sp)
ffffffffc0201b34:	f05a                	sd	s6,32(sp)
ffffffffc0201b36:	ec5e                	sd	s7,24(sp)
ffffffffc0201b38:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0201b3a:	cde9                	beqz	a1,ffffffffc0201c14 <swap_out+0xf0>
ffffffffc0201b3c:	8a2e                	mv	s4,a1
ffffffffc0201b3e:	892a                	mv	s2,a0
ffffffffc0201b40:	8ab2                	mv	s5,a2
ffffffffc0201b42:	4401                	li	s0,0
ffffffffc0201b44:	00014997          	auipc	s3,0x14
ffffffffc0201b48:	a1c98993          	addi	s3,s3,-1508 # ffffffffc0215560 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201b4c:	00004b17          	auipc	s6,0x4
ffffffffc0201b50:	ee4b0b13          	addi	s6,s6,-284 # ffffffffc0205a30 <commands+0xe20>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201b54:	00004b97          	auipc	s7,0x4
ffffffffc0201b58:	ec4b8b93          	addi	s7,s7,-316 # ffffffffc0205a18 <commands+0xe08>
ffffffffc0201b5c:	a825                	j	ffffffffc0201b94 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201b5e:	67a2                	ld	a5,8(sp)
ffffffffc0201b60:	8626                	mv	a2,s1
ffffffffc0201b62:	85a2                	mv	a1,s0
ffffffffc0201b64:	7f94                	ld	a3,56(a5)
ffffffffc0201b66:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0201b68:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0201b6a:	82b1                	srli	a3,a3,0xc
ffffffffc0201b6c:	0685                	addi	a3,a3,1
ffffffffc0201b6e:	d5efe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201b72:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201b74:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201b76:	7d1c                	ld	a5,56(a0)
ffffffffc0201b78:	83b1                	srli	a5,a5,0xc
ffffffffc0201b7a:	0785                	addi	a5,a5,1
ffffffffc0201b7c:	07a2                	slli	a5,a5,0x8
ffffffffc0201b7e:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201b82:	3f0010ef          	jal	ra,ffffffffc0202f72 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201b86:	01893503          	ld	a0,24(s2)
ffffffffc0201b8a:	85a6                	mv	a1,s1
ffffffffc0201b8c:	3b2020ef          	jal	ra,ffffffffc0203f3e <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201b90:	048a0d63          	beq	s4,s0,ffffffffc0201bea <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201b94:	0009b783          	ld	a5,0(s3)
ffffffffc0201b98:	8656                	mv	a2,s5
ffffffffc0201b9a:	002c                	addi	a1,sp,8
ffffffffc0201b9c:	7b9c                	ld	a5,48(a5)
ffffffffc0201b9e:	854a                	mv	a0,s2
ffffffffc0201ba0:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201ba2:	e12d                	bnez	a0,ffffffffc0201c04 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201ba4:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201ba6:	01893503          	ld	a0,24(s2)
ffffffffc0201baa:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201bac:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201bae:	85a6                	mv	a1,s1
ffffffffc0201bb0:	43c010ef          	jal	ra,ffffffffc0202fec <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201bb4:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201bb6:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201bb8:	8b85                	andi	a5,a5,1
ffffffffc0201bba:	cfb9                	beqz	a5,ffffffffc0201c18 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201bbc:	65a2                	ld	a1,8(sp)
ffffffffc0201bbe:	7d9c                	ld	a5,56(a1)
ffffffffc0201bc0:	83b1                	srli	a5,a5,0xc
ffffffffc0201bc2:	0785                	addi	a5,a5,1
ffffffffc0201bc4:	00879513          	slli	a0,a5,0x8
ffffffffc0201bc8:	46c020ef          	jal	ra,ffffffffc0204034 <swapfs_write>
ffffffffc0201bcc:	d949                	beqz	a0,ffffffffc0201b5e <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201bce:	855e                	mv	a0,s7
ffffffffc0201bd0:	cfcfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201bd4:	0009b783          	ld	a5,0(s3)
ffffffffc0201bd8:	6622                	ld	a2,8(sp)
ffffffffc0201bda:	4681                	li	a3,0
ffffffffc0201bdc:	739c                	ld	a5,32(a5)
ffffffffc0201bde:	85a6                	mv	a1,s1
ffffffffc0201be0:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201be2:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201be4:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201be6:	fa8a17e3          	bne	s4,s0,ffffffffc0201b94 <swap_out+0x70>
}
ffffffffc0201bea:	60e6                	ld	ra,88(sp)
ffffffffc0201bec:	8522                	mv	a0,s0
ffffffffc0201bee:	6446                	ld	s0,80(sp)
ffffffffc0201bf0:	64a6                	ld	s1,72(sp)
ffffffffc0201bf2:	6906                	ld	s2,64(sp)
ffffffffc0201bf4:	79e2                	ld	s3,56(sp)
ffffffffc0201bf6:	7a42                	ld	s4,48(sp)
ffffffffc0201bf8:	7aa2                	ld	s5,40(sp)
ffffffffc0201bfa:	7b02                	ld	s6,32(sp)
ffffffffc0201bfc:	6be2                	ld	s7,24(sp)
ffffffffc0201bfe:	6c42                	ld	s8,16(sp)
ffffffffc0201c00:	6125                	addi	sp,sp,96
ffffffffc0201c02:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201c04:	85a2                	mv	a1,s0
ffffffffc0201c06:	00004517          	auipc	a0,0x4
ffffffffc0201c0a:	dca50513          	addi	a0,a0,-566 # ffffffffc02059d0 <commands+0xdc0>
ffffffffc0201c0e:	cbefe0ef          	jal	ra,ffffffffc02000cc <cprintf>
                  break;
ffffffffc0201c12:	bfe1                	j	ffffffffc0201bea <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201c14:	4401                	li	s0,0
ffffffffc0201c16:	bfd1                	j	ffffffffc0201bea <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201c18:	00004697          	auipc	a3,0x4
ffffffffc0201c1c:	de868693          	addi	a3,a3,-536 # ffffffffc0205a00 <commands+0xdf0>
ffffffffc0201c20:	00003617          	auipc	a2,0x3
ffffffffc0201c24:	71860613          	addi	a2,a2,1816 # ffffffffc0205338 <commands+0x728>
ffffffffc0201c28:	06900593          	li	a1,105
ffffffffc0201c2c:	00004517          	auipc	a0,0x4
ffffffffc0201c30:	ae450513          	addi	a0,a0,-1308 # ffffffffc0205710 <commands+0xb00>
ffffffffc0201c34:	d94fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201c38 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201c38:	c94d                	beqz	a0,ffffffffc0201cea <slob_free+0xb2>
{
ffffffffc0201c3a:	1141                	addi	sp,sp,-16
ffffffffc0201c3c:	e022                	sd	s0,0(sp)
ffffffffc0201c3e:	e406                	sd	ra,8(sp)
ffffffffc0201c40:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201c42:	e9c1                	bnez	a1,ffffffffc0201cd2 <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c44:	100027f3          	csrr	a5,sstatus
ffffffffc0201c48:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201c4a:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c4c:	ebd9                	bnez	a5,ffffffffc0201ce2 <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c4e:	00008617          	auipc	a2,0x8
ffffffffc0201c52:	40260613          	addi	a2,a2,1026 # ffffffffc020a050 <slobfree>
ffffffffc0201c56:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c58:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c5a:	679c                	ld	a5,8(a5)
ffffffffc0201c5c:	02877a63          	bgeu	a4,s0,ffffffffc0201c90 <slob_free+0x58>
ffffffffc0201c60:	00f46463          	bltu	s0,a5,ffffffffc0201c68 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c64:	fef76ae3          	bltu	a4,a5,ffffffffc0201c58 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201c68:	400c                	lw	a1,0(s0)
ffffffffc0201c6a:	00459693          	slli	a3,a1,0x4
ffffffffc0201c6e:	96a2                	add	a3,a3,s0
ffffffffc0201c70:	02d78a63          	beq	a5,a3,ffffffffc0201ca4 <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201c74:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc0201c76:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201c78:	00469793          	slli	a5,a3,0x4
ffffffffc0201c7c:	97ba                	add	a5,a5,a4
ffffffffc0201c7e:	02f40e63          	beq	s0,a5,ffffffffc0201cba <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201c82:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc0201c84:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc0201c86:	e129                	bnez	a0,ffffffffc0201cc8 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201c88:	60a2                	ld	ra,8(sp)
ffffffffc0201c8a:	6402                	ld	s0,0(sp)
ffffffffc0201c8c:	0141                	addi	sp,sp,16
ffffffffc0201c8e:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c90:	fcf764e3          	bltu	a4,a5,ffffffffc0201c58 <slob_free+0x20>
ffffffffc0201c94:	fcf472e3          	bgeu	s0,a5,ffffffffc0201c58 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201c98:	400c                	lw	a1,0(s0)
ffffffffc0201c9a:	00459693          	slli	a3,a1,0x4
ffffffffc0201c9e:	96a2                	add	a3,a3,s0
ffffffffc0201ca0:	fcd79ae3          	bne	a5,a3,ffffffffc0201c74 <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc0201ca4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201ca6:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201ca8:	9db5                	addw	a1,a1,a3
ffffffffc0201caa:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201cac:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201cae:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201cb0:	00469793          	slli	a5,a3,0x4
ffffffffc0201cb4:	97ba                	add	a5,a5,a4
ffffffffc0201cb6:	fcf416e3          	bne	s0,a5,ffffffffc0201c82 <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201cba:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201cbc:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201cbe:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201cc0:	9ebd                	addw	a3,a3,a5
ffffffffc0201cc2:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc0201cc4:	e70c                	sd	a1,8(a4)
ffffffffc0201cc6:	d169                	beqz	a0,ffffffffc0201c88 <slob_free+0x50>
}
ffffffffc0201cc8:	6402                	ld	s0,0(sp)
ffffffffc0201cca:	60a2                	ld	ra,8(sp)
ffffffffc0201ccc:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201cce:	8cdfe06f          	j	ffffffffc020059a <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc0201cd2:	25bd                	addiw	a1,a1,15
ffffffffc0201cd4:	8191                	srli	a1,a1,0x4
ffffffffc0201cd6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cd8:	100027f3          	csrr	a5,sstatus
ffffffffc0201cdc:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201cde:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ce0:	d7bd                	beqz	a5,ffffffffc0201c4e <slob_free+0x16>
        intr_disable();
ffffffffc0201ce2:	8bffe0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        return 1;
ffffffffc0201ce6:	4505                	li	a0,1
ffffffffc0201ce8:	b79d                	j	ffffffffc0201c4e <slob_free+0x16>
ffffffffc0201cea:	8082                	ret

ffffffffc0201cec <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201cec:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201cee:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201cf0:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201cf4:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201cf6:	1ea010ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
  if(!page)
ffffffffc0201cfa:	c91d                	beqz	a0,ffffffffc0201d30 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201cfc:	00014697          	auipc	a3,0x14
ffffffffc0201d00:	8946b683          	ld	a3,-1900(a3) # ffffffffc0215590 <pages>
ffffffffc0201d04:	8d15                	sub	a0,a0,a3
ffffffffc0201d06:	8519                	srai	a0,a0,0x6
ffffffffc0201d08:	00005697          	auipc	a3,0x5
ffffffffc0201d0c:	ca06b683          	ld	a3,-864(a3) # ffffffffc02069a8 <nbase>
ffffffffc0201d10:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201d12:	00c51793          	slli	a5,a0,0xc
ffffffffc0201d16:	83b1                	srli	a5,a5,0xc
ffffffffc0201d18:	00014717          	auipc	a4,0x14
ffffffffc0201d1c:	87073703          	ld	a4,-1936(a4) # ffffffffc0215588 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d20:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201d22:	00e7fa63          	bgeu	a5,a4,ffffffffc0201d36 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201d26:	00014697          	auipc	a3,0x14
ffffffffc0201d2a:	87a6b683          	ld	a3,-1926(a3) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0201d2e:	9536                	add	a0,a0,a3
}
ffffffffc0201d30:	60a2                	ld	ra,8(sp)
ffffffffc0201d32:	0141                	addi	sp,sp,16
ffffffffc0201d34:	8082                	ret
ffffffffc0201d36:	86aa                	mv	a3,a0
ffffffffc0201d38:	00004617          	auipc	a2,0x4
ffffffffc0201d3c:	85860613          	addi	a2,a2,-1960 # ffffffffc0205590 <commands+0x980>
ffffffffc0201d40:	06900593          	li	a1,105
ffffffffc0201d44:	00004517          	auipc	a0,0x4
ffffffffc0201d48:	83c50513          	addi	a0,a0,-1988 # ffffffffc0205580 <commands+0x970>
ffffffffc0201d4c:	c7cfe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201d50 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201d50:	1101                	addi	sp,sp,-32
ffffffffc0201d52:	ec06                	sd	ra,24(sp)
ffffffffc0201d54:	e822                	sd	s0,16(sp)
ffffffffc0201d56:	e426                	sd	s1,8(sp)
ffffffffc0201d58:	e04a                	sd	s2,0(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201d5a:	01050713          	addi	a4,a0,16
ffffffffc0201d5e:	6785                	lui	a5,0x1
ffffffffc0201d60:	0cf77363          	bgeu	a4,a5,ffffffffc0201e26 <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201d64:	00f50493          	addi	s1,a0,15
ffffffffc0201d68:	8091                	srli	s1,s1,0x4
ffffffffc0201d6a:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d6c:	10002673          	csrr	a2,sstatus
ffffffffc0201d70:	8a09                	andi	a2,a2,2
ffffffffc0201d72:	e25d                	bnez	a2,ffffffffc0201e18 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201d74:	00008917          	auipc	s2,0x8
ffffffffc0201d78:	2dc90913          	addi	s2,s2,732 # ffffffffc020a050 <slobfree>
ffffffffc0201d7c:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201d80:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d82:	4398                	lw	a4,0(a5)
ffffffffc0201d84:	08975e63          	bge	a4,s1,ffffffffc0201e20 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201d88:	00d78b63          	beq	a5,a3,ffffffffc0201d9e <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201d8c:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d8e:	4018                	lw	a4,0(s0)
ffffffffc0201d90:	02975a63          	bge	a4,s1,ffffffffc0201dc4 <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201d94:	00093683          	ld	a3,0(s2)
ffffffffc0201d98:	87a2                	mv	a5,s0
ffffffffc0201d9a:	fed799e3          	bne	a5,a3,ffffffffc0201d8c <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201d9e:	ee31                	bnez	a2,ffffffffc0201dfa <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201da0:	4501                	li	a0,0
ffffffffc0201da2:	f4bff0ef          	jal	ra,ffffffffc0201cec <__slob_get_free_pages.constprop.0>
ffffffffc0201da6:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201da8:	cd05                	beqz	a0,ffffffffc0201de0 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201daa:	6585                	lui	a1,0x1
ffffffffc0201dac:	e8dff0ef          	jal	ra,ffffffffc0201c38 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db0:	10002673          	csrr	a2,sstatus
ffffffffc0201db4:	8a09                	andi	a2,a2,2
ffffffffc0201db6:	ee05                	bnez	a2,ffffffffc0201dee <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201db8:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201dbc:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201dbe:	4018                	lw	a4,0(s0)
ffffffffc0201dc0:	fc974ae3          	blt	a4,s1,ffffffffc0201d94 <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201dc4:	04e48763          	beq	s1,a4,ffffffffc0201e12 <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201dc8:	00449693          	slli	a3,s1,0x4
ffffffffc0201dcc:	96a2                	add	a3,a3,s0
ffffffffc0201dce:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201dd0:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201dd2:	9f05                	subw	a4,a4,s1
ffffffffc0201dd4:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201dd6:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201dd8:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201dda:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201dde:	e20d                	bnez	a2,ffffffffc0201e00 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201de0:	60e2                	ld	ra,24(sp)
ffffffffc0201de2:	8522                	mv	a0,s0
ffffffffc0201de4:	6442                	ld	s0,16(sp)
ffffffffc0201de6:	64a2                	ld	s1,8(sp)
ffffffffc0201de8:	6902                	ld	s2,0(sp)
ffffffffc0201dea:	6105                	addi	sp,sp,32
ffffffffc0201dec:	8082                	ret
        intr_disable();
ffffffffc0201dee:	fb2fe0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
			cur = slobfree;
ffffffffc0201df2:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201df6:	4605                	li	a2,1
ffffffffc0201df8:	b7d1                	j	ffffffffc0201dbc <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201dfa:	fa0fe0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0201dfe:	b74d                	j	ffffffffc0201da0 <slob_alloc.constprop.0+0x50>
ffffffffc0201e00:	f9afe0ef          	jal	ra,ffffffffc020059a <intr_enable>
}
ffffffffc0201e04:	60e2                	ld	ra,24(sp)
ffffffffc0201e06:	8522                	mv	a0,s0
ffffffffc0201e08:	6442                	ld	s0,16(sp)
ffffffffc0201e0a:	64a2                	ld	s1,8(sp)
ffffffffc0201e0c:	6902                	ld	s2,0(sp)
ffffffffc0201e0e:	6105                	addi	sp,sp,32
ffffffffc0201e10:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201e12:	6418                	ld	a4,8(s0)
ffffffffc0201e14:	e798                	sd	a4,8(a5)
ffffffffc0201e16:	b7d1                	j	ffffffffc0201dda <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201e18:	f88fe0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        return 1;
ffffffffc0201e1c:	4605                	li	a2,1
ffffffffc0201e1e:	bf99                	j	ffffffffc0201d74 <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201e20:	843e                	mv	s0,a5
ffffffffc0201e22:	87b6                	mv	a5,a3
ffffffffc0201e24:	b745                	j	ffffffffc0201dc4 <slob_alloc.constprop.0+0x74>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201e26:	00004697          	auipc	a3,0x4
ffffffffc0201e2a:	c4a68693          	addi	a3,a3,-950 # ffffffffc0205a70 <commands+0xe60>
ffffffffc0201e2e:	00003617          	auipc	a2,0x3
ffffffffc0201e32:	50a60613          	addi	a2,a2,1290 # ffffffffc0205338 <commands+0x728>
ffffffffc0201e36:	06300593          	li	a1,99
ffffffffc0201e3a:	00004517          	auipc	a0,0x4
ffffffffc0201e3e:	c5650513          	addi	a0,a0,-938 # ffffffffc0205a90 <commands+0xe80>
ffffffffc0201e42:	b86fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0201e46 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201e46:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201e48:	00004517          	auipc	a0,0x4
ffffffffc0201e4c:	c6050513          	addi	a0,a0,-928 # ffffffffc0205aa8 <commands+0xe98>
kmalloc_init(void) {
ffffffffc0201e50:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201e52:	a7afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201e56:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201e58:	00004517          	auipc	a0,0x4
ffffffffc0201e5c:	c6850513          	addi	a0,a0,-920 # ffffffffc0205ac0 <commands+0xeb0>
}
ffffffffc0201e60:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201e62:	a6afe06f          	j	ffffffffc02000cc <cprintf>

ffffffffc0201e66 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201e66:	1101                	addi	sp,sp,-32
ffffffffc0201e68:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e6a:	6905                	lui	s2,0x1
{
ffffffffc0201e6c:	e822                	sd	s0,16(sp)
ffffffffc0201e6e:	ec06                	sd	ra,24(sp)
ffffffffc0201e70:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e72:	fef90793          	addi	a5,s2,-17 # fef <kern_entry-0xffffffffc01ff011>
{
ffffffffc0201e76:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e78:	04a7f963          	bgeu	a5,a0,ffffffffc0201eca <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201e7c:	4561                	li	a0,24
ffffffffc0201e7e:	ed3ff0ef          	jal	ra,ffffffffc0201d50 <slob_alloc.constprop.0>
ffffffffc0201e82:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201e84:	c929                	beqz	a0,ffffffffc0201ed6 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201e86:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201e8a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201e8c:	00f95763          	bge	s2,a5,ffffffffc0201e9a <kmalloc+0x34>
ffffffffc0201e90:	6705                	lui	a4,0x1
ffffffffc0201e92:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201e94:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201e96:	fef74ee3          	blt	a4,a5,ffffffffc0201e92 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201e9a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201e9c:	e51ff0ef          	jal	ra,ffffffffc0201cec <__slob_get_free_pages.constprop.0>
ffffffffc0201ea0:	e488                	sd	a0,8(s1)
ffffffffc0201ea2:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201ea4:	c525                	beqz	a0,ffffffffc0201f0c <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ea6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eaa:	8b89                	andi	a5,a5,2
ffffffffc0201eac:	ef8d                	bnez	a5,ffffffffc0201ee6 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201eae:	00013797          	auipc	a5,0x13
ffffffffc0201eb2:	6c278793          	addi	a5,a5,1730 # ffffffffc0215570 <bigblocks>
ffffffffc0201eb6:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201eb8:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201eba:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201ebc:	60e2                	ld	ra,24(sp)
ffffffffc0201ebe:	8522                	mv	a0,s0
ffffffffc0201ec0:	6442                	ld	s0,16(sp)
ffffffffc0201ec2:	64a2                	ld	s1,8(sp)
ffffffffc0201ec4:	6902                	ld	s2,0(sp)
ffffffffc0201ec6:	6105                	addi	sp,sp,32
ffffffffc0201ec8:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201eca:	0541                	addi	a0,a0,16
ffffffffc0201ecc:	e85ff0ef          	jal	ra,ffffffffc0201d50 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201ed0:	01050413          	addi	s0,a0,16
ffffffffc0201ed4:	f565                	bnez	a0,ffffffffc0201ebc <kmalloc+0x56>
ffffffffc0201ed6:	4401                	li	s0,0
}
ffffffffc0201ed8:	60e2                	ld	ra,24(sp)
ffffffffc0201eda:	8522                	mv	a0,s0
ffffffffc0201edc:	6442                	ld	s0,16(sp)
ffffffffc0201ede:	64a2                	ld	s1,8(sp)
ffffffffc0201ee0:	6902                	ld	s2,0(sp)
ffffffffc0201ee2:	6105                	addi	sp,sp,32
ffffffffc0201ee4:	8082                	ret
        intr_disable();
ffffffffc0201ee6:	ebafe0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201eea:	00013797          	auipc	a5,0x13
ffffffffc0201eee:	68678793          	addi	a5,a5,1670 # ffffffffc0215570 <bigblocks>
ffffffffc0201ef2:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201ef4:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201ef6:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201ef8:	ea2fe0ef          	jal	ra,ffffffffc020059a <intr_enable>
		return bb->pages;
ffffffffc0201efc:	6480                	ld	s0,8(s1)
}
ffffffffc0201efe:	60e2                	ld	ra,24(sp)
ffffffffc0201f00:	64a2                	ld	s1,8(sp)
ffffffffc0201f02:	8522                	mv	a0,s0
ffffffffc0201f04:	6442                	ld	s0,16(sp)
ffffffffc0201f06:	6902                	ld	s2,0(sp)
ffffffffc0201f08:	6105                	addi	sp,sp,32
ffffffffc0201f0a:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f0c:	45e1                	li	a1,24
ffffffffc0201f0e:	8526                	mv	a0,s1
ffffffffc0201f10:	d29ff0ef          	jal	ra,ffffffffc0201c38 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201f14:	b765                	j	ffffffffc0201ebc <kmalloc+0x56>

ffffffffc0201f16 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201f16:	c169                	beqz	a0,ffffffffc0201fd8 <kfree+0xc2>
{
ffffffffc0201f18:	1101                	addi	sp,sp,-32
ffffffffc0201f1a:	e822                	sd	s0,16(sp)
ffffffffc0201f1c:	ec06                	sd	ra,24(sp)
ffffffffc0201f1e:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201f20:	03451793          	slli	a5,a0,0x34
ffffffffc0201f24:	842a                	mv	s0,a0
ffffffffc0201f26:	e3d9                	bnez	a5,ffffffffc0201fac <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f28:	100027f3          	csrr	a5,sstatus
ffffffffc0201f2c:	8b89                	andi	a5,a5,2
ffffffffc0201f2e:	e7d9                	bnez	a5,ffffffffc0201fbc <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f30:	00013797          	auipc	a5,0x13
ffffffffc0201f34:	6407b783          	ld	a5,1600(a5) # ffffffffc0215570 <bigblocks>
    return 0;
ffffffffc0201f38:	4601                	li	a2,0
ffffffffc0201f3a:	cbad                	beqz	a5,ffffffffc0201fac <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201f3c:	00013697          	auipc	a3,0x13
ffffffffc0201f40:	63468693          	addi	a3,a3,1588 # ffffffffc0215570 <bigblocks>
ffffffffc0201f44:	a021                	j	ffffffffc0201f4c <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f46:	01048693          	addi	a3,s1,16
ffffffffc0201f4a:	c3a5                	beqz	a5,ffffffffc0201faa <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201f4c:	6798                	ld	a4,8(a5)
ffffffffc0201f4e:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201f50:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201f52:	fe871ae3          	bne	a4,s0,ffffffffc0201f46 <kfree+0x30>
				*last = bb->next;
ffffffffc0201f56:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201f58:	ee2d                	bnez	a2,ffffffffc0201fd2 <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201f5a:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201f5e:	4098                	lw	a4,0(s1)
ffffffffc0201f60:	08f46963          	bltu	s0,a5,ffffffffc0201ff2 <kfree+0xdc>
ffffffffc0201f64:	00013697          	auipc	a3,0x13
ffffffffc0201f68:	63c6b683          	ld	a3,1596(a3) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0201f6c:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201f6e:	8031                	srli	s0,s0,0xc
ffffffffc0201f70:	00013797          	auipc	a5,0x13
ffffffffc0201f74:	6187b783          	ld	a5,1560(a5) # ffffffffc0215588 <npage>
ffffffffc0201f78:	06f47163          	bgeu	s0,a5,ffffffffc0201fda <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f7c:	00005517          	auipc	a0,0x5
ffffffffc0201f80:	a2c53503          	ld	a0,-1492(a0) # ffffffffc02069a8 <nbase>
ffffffffc0201f84:	8c09                	sub	s0,s0,a0
ffffffffc0201f86:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201f88:	00013517          	auipc	a0,0x13
ffffffffc0201f8c:	60853503          	ld	a0,1544(a0) # ffffffffc0215590 <pages>
ffffffffc0201f90:	4585                	li	a1,1
ffffffffc0201f92:	9522                	add	a0,a0,s0
ffffffffc0201f94:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201f98:	7db000ef          	jal	ra,ffffffffc0202f72 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201f9c:	6442                	ld	s0,16(sp)
ffffffffc0201f9e:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201fa0:	8526                	mv	a0,s1
}
ffffffffc0201fa2:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201fa4:	45e1                	li	a1,24
}
ffffffffc0201fa6:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201fa8:	b941                	j	ffffffffc0201c38 <slob_free>
ffffffffc0201faa:	e20d                	bnez	a2,ffffffffc0201fcc <kfree+0xb6>
ffffffffc0201fac:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201fb0:	6442                	ld	s0,16(sp)
ffffffffc0201fb2:	60e2                	ld	ra,24(sp)
ffffffffc0201fb4:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201fb6:	4581                	li	a1,0
}
ffffffffc0201fb8:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201fba:	b9bd                	j	ffffffffc0201c38 <slob_free>
        intr_disable();
ffffffffc0201fbc:	de4fe0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201fc0:	00013797          	auipc	a5,0x13
ffffffffc0201fc4:	5b07b783          	ld	a5,1456(a5) # ffffffffc0215570 <bigblocks>
        return 1;
ffffffffc0201fc8:	4605                	li	a2,1
ffffffffc0201fca:	fbad                	bnez	a5,ffffffffc0201f3c <kfree+0x26>
        intr_enable();
ffffffffc0201fcc:	dcefe0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0201fd0:	bff1                	j	ffffffffc0201fac <kfree+0x96>
ffffffffc0201fd2:	dc8fe0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0201fd6:	b751                	j	ffffffffc0201f5a <kfree+0x44>
ffffffffc0201fd8:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201fda:	00003617          	auipc	a2,0x3
ffffffffc0201fde:	58660613          	addi	a2,a2,1414 # ffffffffc0205560 <commands+0x950>
ffffffffc0201fe2:	06200593          	li	a1,98
ffffffffc0201fe6:	00003517          	auipc	a0,0x3
ffffffffc0201fea:	59a50513          	addi	a0,a0,1434 # ffffffffc0205580 <commands+0x970>
ffffffffc0201fee:	9dafe0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201ff2:	86a2                	mv	a3,s0
ffffffffc0201ff4:	00004617          	auipc	a2,0x4
ffffffffc0201ff8:	aec60613          	addi	a2,a2,-1300 # ffffffffc0205ae0 <commands+0xed0>
ffffffffc0201ffc:	06e00593          	li	a1,110
ffffffffc0202000:	00003517          	auipc	a0,0x3
ffffffffc0202004:	58050513          	addi	a0,a0,1408 # ffffffffc0205580 <commands+0x970>
ffffffffc0202008:	9c0fe0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020200c <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020200c:	0000f797          	auipc	a5,0xf
ffffffffc0202010:	4dc78793          	addi	a5,a5,1244 # ffffffffc02114e8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0202014:	f51c                	sd	a5,40(a0)
ffffffffc0202016:	e79c                	sd	a5,8(a5)
ffffffffc0202018:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020201a:	4501                	li	a0,0
ffffffffc020201c:	8082                	ret

ffffffffc020201e <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc020201e:	4501                	li	a0,0
ffffffffc0202020:	8082                	ret

ffffffffc0202022 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0202022:	4501                	li	a0,0
ffffffffc0202024:	8082                	ret

ffffffffc0202026 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202026:	4501                	li	a0,0
ffffffffc0202028:	8082                	ret

ffffffffc020202a <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc020202a:	711d                	addi	sp,sp,-96
ffffffffc020202c:	fc4e                	sd	s3,56(sp)
ffffffffc020202e:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202030:	00004517          	auipc	a0,0x4
ffffffffc0202034:	ad850513          	addi	a0,a0,-1320 # ffffffffc0205b08 <commands+0xef8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202038:	698d                	lui	s3,0x3
ffffffffc020203a:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc020203c:	e0ca                	sd	s2,64(sp)
ffffffffc020203e:	ec86                	sd	ra,88(sp)
ffffffffc0202040:	e8a2                	sd	s0,80(sp)
ffffffffc0202042:	e4a6                	sd	s1,72(sp)
ffffffffc0202044:	f456                	sd	s5,40(sp)
ffffffffc0202046:	f05a                	sd	s6,32(sp)
ffffffffc0202048:	ec5e                	sd	s7,24(sp)
ffffffffc020204a:	e862                	sd	s8,16(sp)
ffffffffc020204c:	e466                	sd	s9,8(sp)
ffffffffc020204e:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0202050:	87cfe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202054:	01498023          	sb	s4,0(s3) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0202058:	00013917          	auipc	s2,0x13
ffffffffc020205c:	4f892903          	lw	s2,1272(s2) # ffffffffc0215550 <pgfault_num>
ffffffffc0202060:	4791                	li	a5,4
ffffffffc0202062:	14f91e63          	bne	s2,a5,ffffffffc02021be <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202066:	00004517          	auipc	a0,0x4
ffffffffc020206a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0205b48 <commands+0xf38>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020206e:	6a85                	lui	s5,0x1
ffffffffc0202070:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202072:	85afe0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0202076:	00013417          	auipc	s0,0x13
ffffffffc020207a:	4da40413          	addi	s0,s0,1242 # ffffffffc0215550 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020207e:	016a8023          	sb	s6,0(s5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0202082:	4004                	lw	s1,0(s0)
ffffffffc0202084:	2481                	sext.w	s1,s1
ffffffffc0202086:	2b249c63          	bne	s1,s2,ffffffffc020233e <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020208a:	00004517          	auipc	a0,0x4
ffffffffc020208e:	ae650513          	addi	a0,a0,-1306 # ffffffffc0205b70 <commands+0xf60>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202092:	6b91                	lui	s7,0x4
ffffffffc0202094:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202096:	836fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020209a:	018b8023          	sb	s8,0(s7) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020209e:	00042903          	lw	s2,0(s0)
ffffffffc02020a2:	2901                	sext.w	s2,s2
ffffffffc02020a4:	26991d63          	bne	s2,s1,ffffffffc020231e <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02020a8:	00004517          	auipc	a0,0x4
ffffffffc02020ac:	af050513          	addi	a0,a0,-1296 # ffffffffc0205b98 <commands+0xf88>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02020b0:	6c89                	lui	s9,0x2
ffffffffc02020b2:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02020b4:	818fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02020b8:	01ac8023          	sb	s10,0(s9) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02020bc:	401c                	lw	a5,0(s0)
ffffffffc02020be:	2781                	sext.w	a5,a5
ffffffffc02020c0:	23279f63          	bne	a5,s2,ffffffffc02022fe <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02020c4:	00004517          	auipc	a0,0x4
ffffffffc02020c8:	afc50513          	addi	a0,a0,-1284 # ffffffffc0205bc0 <commands+0xfb0>
ffffffffc02020cc:	800fe0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02020d0:	6795                	lui	a5,0x5
ffffffffc02020d2:	4739                	li	a4,14
ffffffffc02020d4:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02020d8:	4004                	lw	s1,0(s0)
ffffffffc02020da:	4795                	li	a5,5
ffffffffc02020dc:	2481                	sext.w	s1,s1
ffffffffc02020de:	20f49063          	bne	s1,a5,ffffffffc02022de <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02020e2:	00004517          	auipc	a0,0x4
ffffffffc02020e6:	ab650513          	addi	a0,a0,-1354 # ffffffffc0205b98 <commands+0xf88>
ffffffffc02020ea:	fe3fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02020ee:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc02020f2:	401c                	lw	a5,0(s0)
ffffffffc02020f4:	2781                	sext.w	a5,a5
ffffffffc02020f6:	1c979463          	bne	a5,s1,ffffffffc02022be <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02020fa:	00004517          	auipc	a0,0x4
ffffffffc02020fe:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0205b48 <commands+0xf38>
ffffffffc0202102:	fcbfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202106:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc020210a:	401c                	lw	a5,0(s0)
ffffffffc020210c:	4719                	li	a4,6
ffffffffc020210e:	2781                	sext.w	a5,a5
ffffffffc0202110:	18e79763          	bne	a5,a4,ffffffffc020229e <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0202114:	00004517          	auipc	a0,0x4
ffffffffc0202118:	a8450513          	addi	a0,a0,-1404 # ffffffffc0205b98 <commands+0xf88>
ffffffffc020211c:	fb1fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202120:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0202124:	401c                	lw	a5,0(s0)
ffffffffc0202126:	471d                	li	a4,7
ffffffffc0202128:	2781                	sext.w	a5,a5
ffffffffc020212a:	14e79a63          	bne	a5,a4,ffffffffc020227e <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020212e:	00004517          	auipc	a0,0x4
ffffffffc0202132:	9da50513          	addi	a0,a0,-1574 # ffffffffc0205b08 <commands+0xef8>
ffffffffc0202136:	f97fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020213a:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc020213e:	401c                	lw	a5,0(s0)
ffffffffc0202140:	4721                	li	a4,8
ffffffffc0202142:	2781                	sext.w	a5,a5
ffffffffc0202144:	10e79d63          	bne	a5,a4,ffffffffc020225e <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0202148:	00004517          	auipc	a0,0x4
ffffffffc020214c:	a2850513          	addi	a0,a0,-1496 # ffffffffc0205b70 <commands+0xf60>
ffffffffc0202150:	f7dfd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202154:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0202158:	401c                	lw	a5,0(s0)
ffffffffc020215a:	4725                	li	a4,9
ffffffffc020215c:	2781                	sext.w	a5,a5
ffffffffc020215e:	0ee79063          	bne	a5,a4,ffffffffc020223e <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0202162:	00004517          	auipc	a0,0x4
ffffffffc0202166:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0205bc0 <commands+0xfb0>
ffffffffc020216a:	f63fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020216e:	6795                	lui	a5,0x5
ffffffffc0202170:	4739                	li	a4,14
ffffffffc0202172:	00e78023          	sb	a4,0(a5) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0202176:	4004                	lw	s1,0(s0)
ffffffffc0202178:	47a9                	li	a5,10
ffffffffc020217a:	2481                	sext.w	s1,s1
ffffffffc020217c:	0af49163          	bne	s1,a5,ffffffffc020221e <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0202180:	00004517          	auipc	a0,0x4
ffffffffc0202184:	9c850513          	addi	a0,a0,-1592 # ffffffffc0205b48 <commands+0xf38>
ffffffffc0202188:	f45fd0ef          	jal	ra,ffffffffc02000cc <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020218c:	6785                	lui	a5,0x1
ffffffffc020218e:	0007c783          	lbu	a5,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202192:	06979663          	bne	a5,s1,ffffffffc02021fe <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0202196:	401c                	lw	a5,0(s0)
ffffffffc0202198:	472d                	li	a4,11
ffffffffc020219a:	2781                	sext.w	a5,a5
ffffffffc020219c:	04e79163          	bne	a5,a4,ffffffffc02021de <_fifo_check_swap+0x1b4>
}
ffffffffc02021a0:	60e6                	ld	ra,88(sp)
ffffffffc02021a2:	6446                	ld	s0,80(sp)
ffffffffc02021a4:	64a6                	ld	s1,72(sp)
ffffffffc02021a6:	6906                	ld	s2,64(sp)
ffffffffc02021a8:	79e2                	ld	s3,56(sp)
ffffffffc02021aa:	7a42                	ld	s4,48(sp)
ffffffffc02021ac:	7aa2                	ld	s5,40(sp)
ffffffffc02021ae:	7b02                	ld	s6,32(sp)
ffffffffc02021b0:	6be2                	ld	s7,24(sp)
ffffffffc02021b2:	6c42                	ld	s8,16(sp)
ffffffffc02021b4:	6ca2                	ld	s9,8(sp)
ffffffffc02021b6:	6d02                	ld	s10,0(sp)
ffffffffc02021b8:	4501                	li	a0,0
ffffffffc02021ba:	6125                	addi	sp,sp,96
ffffffffc02021bc:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02021be:	00003697          	auipc	a3,0x3
ffffffffc02021c2:	71a68693          	addi	a3,a3,1818 # ffffffffc02058d8 <commands+0xcc8>
ffffffffc02021c6:	00003617          	auipc	a2,0x3
ffffffffc02021ca:	17260613          	addi	a2,a2,370 # ffffffffc0205338 <commands+0x728>
ffffffffc02021ce:	05100593          	li	a1,81
ffffffffc02021d2:	00004517          	auipc	a0,0x4
ffffffffc02021d6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205b30 <commands+0xf20>
ffffffffc02021da:	feffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==11);
ffffffffc02021de:	00004697          	auipc	a3,0x4
ffffffffc02021e2:	a9268693          	addi	a3,a3,-1390 # ffffffffc0205c70 <commands+0x1060>
ffffffffc02021e6:	00003617          	auipc	a2,0x3
ffffffffc02021ea:	15260613          	addi	a2,a2,338 # ffffffffc0205338 <commands+0x728>
ffffffffc02021ee:	07300593          	li	a1,115
ffffffffc02021f2:	00004517          	auipc	a0,0x4
ffffffffc02021f6:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205b30 <commands+0xf20>
ffffffffc02021fa:	fcffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02021fe:	00004697          	auipc	a3,0x4
ffffffffc0202202:	a4a68693          	addi	a3,a3,-1462 # ffffffffc0205c48 <commands+0x1038>
ffffffffc0202206:	00003617          	auipc	a2,0x3
ffffffffc020220a:	13260613          	addi	a2,a2,306 # ffffffffc0205338 <commands+0x728>
ffffffffc020220e:	07100593          	li	a1,113
ffffffffc0202212:	00004517          	auipc	a0,0x4
ffffffffc0202216:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020221a:	faffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==10);
ffffffffc020221e:	00004697          	auipc	a3,0x4
ffffffffc0202222:	a1a68693          	addi	a3,a3,-1510 # ffffffffc0205c38 <commands+0x1028>
ffffffffc0202226:	00003617          	auipc	a2,0x3
ffffffffc020222a:	11260613          	addi	a2,a2,274 # ffffffffc0205338 <commands+0x728>
ffffffffc020222e:	06f00593          	li	a1,111
ffffffffc0202232:	00004517          	auipc	a0,0x4
ffffffffc0202236:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020223a:	f8ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==9);
ffffffffc020223e:	00004697          	auipc	a3,0x4
ffffffffc0202242:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0205c28 <commands+0x1018>
ffffffffc0202246:	00003617          	auipc	a2,0x3
ffffffffc020224a:	0f260613          	addi	a2,a2,242 # ffffffffc0205338 <commands+0x728>
ffffffffc020224e:	06c00593          	li	a1,108
ffffffffc0202252:	00004517          	auipc	a0,0x4
ffffffffc0202256:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020225a:	f6ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==8);
ffffffffc020225e:	00004697          	auipc	a3,0x4
ffffffffc0202262:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0205c18 <commands+0x1008>
ffffffffc0202266:	00003617          	auipc	a2,0x3
ffffffffc020226a:	0d260613          	addi	a2,a2,210 # ffffffffc0205338 <commands+0x728>
ffffffffc020226e:	06900593          	li	a1,105
ffffffffc0202272:	00004517          	auipc	a0,0x4
ffffffffc0202276:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020227a:	f4ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==7);
ffffffffc020227e:	00004697          	auipc	a3,0x4
ffffffffc0202282:	98a68693          	addi	a3,a3,-1654 # ffffffffc0205c08 <commands+0xff8>
ffffffffc0202286:	00003617          	auipc	a2,0x3
ffffffffc020228a:	0b260613          	addi	a2,a2,178 # ffffffffc0205338 <commands+0x728>
ffffffffc020228e:	06600593          	li	a1,102
ffffffffc0202292:	00004517          	auipc	a0,0x4
ffffffffc0202296:	89e50513          	addi	a0,a0,-1890 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020229a:	f2ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==6);
ffffffffc020229e:	00004697          	auipc	a3,0x4
ffffffffc02022a2:	95a68693          	addi	a3,a3,-1702 # ffffffffc0205bf8 <commands+0xfe8>
ffffffffc02022a6:	00003617          	auipc	a2,0x3
ffffffffc02022aa:	09260613          	addi	a2,a2,146 # ffffffffc0205338 <commands+0x728>
ffffffffc02022ae:	06300593          	li	a1,99
ffffffffc02022b2:	00004517          	auipc	a0,0x4
ffffffffc02022b6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0205b30 <commands+0xf20>
ffffffffc02022ba:	f0ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc02022be:	00004697          	auipc	a3,0x4
ffffffffc02022c2:	92a68693          	addi	a3,a3,-1750 # ffffffffc0205be8 <commands+0xfd8>
ffffffffc02022c6:	00003617          	auipc	a2,0x3
ffffffffc02022ca:	07260613          	addi	a2,a2,114 # ffffffffc0205338 <commands+0x728>
ffffffffc02022ce:	06000593          	li	a1,96
ffffffffc02022d2:	00004517          	auipc	a0,0x4
ffffffffc02022d6:	85e50513          	addi	a0,a0,-1954 # ffffffffc0205b30 <commands+0xf20>
ffffffffc02022da:	eeffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==5);
ffffffffc02022de:	00004697          	auipc	a3,0x4
ffffffffc02022e2:	90a68693          	addi	a3,a3,-1782 # ffffffffc0205be8 <commands+0xfd8>
ffffffffc02022e6:	00003617          	auipc	a2,0x3
ffffffffc02022ea:	05260613          	addi	a2,a2,82 # ffffffffc0205338 <commands+0x728>
ffffffffc02022ee:	05d00593          	li	a1,93
ffffffffc02022f2:	00004517          	auipc	a0,0x4
ffffffffc02022f6:	83e50513          	addi	a0,a0,-1986 # ffffffffc0205b30 <commands+0xf20>
ffffffffc02022fa:	ecffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc02022fe:	00003697          	auipc	a3,0x3
ffffffffc0202302:	5da68693          	addi	a3,a3,1498 # ffffffffc02058d8 <commands+0xcc8>
ffffffffc0202306:	00003617          	auipc	a2,0x3
ffffffffc020230a:	03260613          	addi	a2,a2,50 # ffffffffc0205338 <commands+0x728>
ffffffffc020230e:	05a00593          	li	a1,90
ffffffffc0202312:	00004517          	auipc	a0,0x4
ffffffffc0202316:	81e50513          	addi	a0,a0,-2018 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020231a:	eaffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc020231e:	00003697          	auipc	a3,0x3
ffffffffc0202322:	5ba68693          	addi	a3,a3,1466 # ffffffffc02058d8 <commands+0xcc8>
ffffffffc0202326:	00003617          	auipc	a2,0x3
ffffffffc020232a:	01260613          	addi	a2,a2,18 # ffffffffc0205338 <commands+0x728>
ffffffffc020232e:	05700593          	li	a1,87
ffffffffc0202332:	00003517          	auipc	a0,0x3
ffffffffc0202336:	7fe50513          	addi	a0,a0,2046 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020233a:	e8ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pgfault_num==4);
ffffffffc020233e:	00003697          	auipc	a3,0x3
ffffffffc0202342:	59a68693          	addi	a3,a3,1434 # ffffffffc02058d8 <commands+0xcc8>
ffffffffc0202346:	00003617          	auipc	a2,0x3
ffffffffc020234a:	ff260613          	addi	a2,a2,-14 # ffffffffc0205338 <commands+0x728>
ffffffffc020234e:	05400593          	li	a1,84
ffffffffc0202352:	00003517          	auipc	a0,0x3
ffffffffc0202356:	7de50513          	addi	a0,a0,2014 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020235a:	e6ffd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020235e <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020235e:	751c                	ld	a5,40(a0)
{
ffffffffc0202360:	1141                	addi	sp,sp,-16
ffffffffc0202362:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0202364:	cf91                	beqz	a5,ffffffffc0202380 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0202366:	ee0d                	bnez	a2,ffffffffc02023a0 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0202368:	679c                	ld	a5,8(a5)
}
ffffffffc020236a:	60a2                	ld	ra,8(sp)
ffffffffc020236c:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc020236e:	6394                	ld	a3,0(a5)
ffffffffc0202370:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0202372:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0202376:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0202378:	e314                	sd	a3,0(a4)
ffffffffc020237a:	e19c                	sd	a5,0(a1)
}
ffffffffc020237c:	0141                	addi	sp,sp,16
ffffffffc020237e:	8082                	ret
         assert(head != NULL);
ffffffffc0202380:	00004697          	auipc	a3,0x4
ffffffffc0202384:	90068693          	addi	a3,a3,-1792 # ffffffffc0205c80 <commands+0x1070>
ffffffffc0202388:	00003617          	auipc	a2,0x3
ffffffffc020238c:	fb060613          	addi	a2,a2,-80 # ffffffffc0205338 <commands+0x728>
ffffffffc0202390:	04100593          	li	a1,65
ffffffffc0202394:	00003517          	auipc	a0,0x3
ffffffffc0202398:	79c50513          	addi	a0,a0,1948 # ffffffffc0205b30 <commands+0xf20>
ffffffffc020239c:	e2dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>
     assert(in_tick==0);
ffffffffc02023a0:	00004697          	auipc	a3,0x4
ffffffffc02023a4:	8f068693          	addi	a3,a3,-1808 # ffffffffc0205c90 <commands+0x1080>
ffffffffc02023a8:	00003617          	auipc	a2,0x3
ffffffffc02023ac:	f9060613          	addi	a2,a2,-112 # ffffffffc0205338 <commands+0x728>
ffffffffc02023b0:	04200593          	li	a1,66
ffffffffc02023b4:	00003517          	auipc	a0,0x3
ffffffffc02023b8:	77c50513          	addi	a0,a0,1916 # ffffffffc0205b30 <commands+0xf20>
ffffffffc02023bc:	e0dfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02023c0 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02023c0:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02023c2:	cb91                	beqz	a5,ffffffffc02023d6 <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02023c4:	6394                	ld	a3,0(a5)
ffffffffc02023c6:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc02023ca:	e398                	sd	a4,0(a5)
ffffffffc02023cc:	e698                	sd	a4,8(a3)
}
ffffffffc02023ce:	4501                	li	a0,0
    elm->next = next;
ffffffffc02023d0:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc02023d2:	f614                	sd	a3,40(a2)
ffffffffc02023d4:	8082                	ret
{
ffffffffc02023d6:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc02023d8:	00004697          	auipc	a3,0x4
ffffffffc02023dc:	8c868693          	addi	a3,a3,-1848 # ffffffffc0205ca0 <commands+0x1090>
ffffffffc02023e0:	00003617          	auipc	a2,0x3
ffffffffc02023e4:	f5860613          	addi	a2,a2,-168 # ffffffffc0205338 <commands+0x728>
ffffffffc02023e8:	03200593          	li	a1,50
ffffffffc02023ec:	00003517          	auipc	a0,0x3
ffffffffc02023f0:	74450513          	addi	a0,a0,1860 # ffffffffc0205b30 <commands+0xf20>
{
ffffffffc02023f4:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02023f6:	dd3fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02023fa <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02023fa:	0000f797          	auipc	a5,0xf
ffffffffc02023fe:	0fe78793          	addi	a5,a5,254 # ffffffffc02114f8 <free_area>
ffffffffc0202402:	e79c                	sd	a5,8(a5)
ffffffffc0202404:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0202406:	0007a823          	sw	zero,16(a5)
}
ffffffffc020240a:	8082                	ret

ffffffffc020240c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020240c:	0000f517          	auipc	a0,0xf
ffffffffc0202410:	0fc56503          	lwu	a0,252(a0) # ffffffffc0211508 <free_area+0x10>
ffffffffc0202414:	8082                	ret

ffffffffc0202416 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0202416:	715d                	addi	sp,sp,-80
ffffffffc0202418:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc020241a:	0000f417          	auipc	s0,0xf
ffffffffc020241e:	0de40413          	addi	s0,s0,222 # ffffffffc02114f8 <free_area>
ffffffffc0202422:	641c                	ld	a5,8(s0)
ffffffffc0202424:	e486                	sd	ra,72(sp)
ffffffffc0202426:	fc26                	sd	s1,56(sp)
ffffffffc0202428:	f84a                	sd	s2,48(sp)
ffffffffc020242a:	f44e                	sd	s3,40(sp)
ffffffffc020242c:	f052                	sd	s4,32(sp)
ffffffffc020242e:	ec56                	sd	s5,24(sp)
ffffffffc0202430:	e85a                	sd	s6,16(sp)
ffffffffc0202432:	e45e                	sd	s7,8(sp)
ffffffffc0202434:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202436:	2a878d63          	beq	a5,s0,ffffffffc02026f0 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc020243a:	4481                	li	s1,0
ffffffffc020243c:	4901                	li	s2,0
ffffffffc020243e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202442:	8b09                	andi	a4,a4,2
ffffffffc0202444:	2a070a63          	beqz	a4,ffffffffc02026f8 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0202448:	ff87a703          	lw	a4,-8(a5)
ffffffffc020244c:	679c                	ld	a5,8(a5)
ffffffffc020244e:	2905                	addiw	s2,s2,1
ffffffffc0202450:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202452:	fe8796e3          	bne	a5,s0,ffffffffc020243e <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0202456:	89a6                	mv	s3,s1
ffffffffc0202458:	35b000ef          	jal	ra,ffffffffc0202fb2 <nr_free_pages>
ffffffffc020245c:	6f351e63          	bne	a0,s3,ffffffffc0202b58 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202460:	4505                	li	a0,1
ffffffffc0202462:	27f000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202466:	8aaa                	mv	s5,a0
ffffffffc0202468:	42050863          	beqz	a0,ffffffffc0202898 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020246c:	4505                	li	a0,1
ffffffffc020246e:	273000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202472:	89aa                	mv	s3,a0
ffffffffc0202474:	70050263          	beqz	a0,ffffffffc0202b78 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202478:	4505                	li	a0,1
ffffffffc020247a:	267000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020247e:	8a2a                	mv	s4,a0
ffffffffc0202480:	48050c63          	beqz	a0,ffffffffc0202918 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202484:	293a8a63          	beq	s5,s3,ffffffffc0202718 <default_check+0x302>
ffffffffc0202488:	28aa8863          	beq	s5,a0,ffffffffc0202718 <default_check+0x302>
ffffffffc020248c:	28a98663          	beq	s3,a0,ffffffffc0202718 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202490:	000aa783          	lw	a5,0(s5)
ffffffffc0202494:	2a079263          	bnez	a5,ffffffffc0202738 <default_check+0x322>
ffffffffc0202498:	0009a783          	lw	a5,0(s3)
ffffffffc020249c:	28079e63          	bnez	a5,ffffffffc0202738 <default_check+0x322>
ffffffffc02024a0:	411c                	lw	a5,0(a0)
ffffffffc02024a2:	28079b63          	bnez	a5,ffffffffc0202738 <default_check+0x322>
    return page - pages + nbase;
ffffffffc02024a6:	00013797          	auipc	a5,0x13
ffffffffc02024aa:	0ea7b783          	ld	a5,234(a5) # ffffffffc0215590 <pages>
ffffffffc02024ae:	40fa8733          	sub	a4,s5,a5
ffffffffc02024b2:	00004617          	auipc	a2,0x4
ffffffffc02024b6:	4f663603          	ld	a2,1270(a2) # ffffffffc02069a8 <nbase>
ffffffffc02024ba:	8719                	srai	a4,a4,0x6
ffffffffc02024bc:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02024be:	00013697          	auipc	a3,0x13
ffffffffc02024c2:	0ca6b683          	ld	a3,202(a3) # ffffffffc0215588 <npage>
ffffffffc02024c6:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02024c8:	0732                	slli	a4,a4,0xc
ffffffffc02024ca:	28d77763          	bgeu	a4,a3,ffffffffc0202758 <default_check+0x342>
    return page - pages + nbase;
ffffffffc02024ce:	40f98733          	sub	a4,s3,a5
ffffffffc02024d2:	8719                	srai	a4,a4,0x6
ffffffffc02024d4:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02024d6:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02024d8:	4cd77063          	bgeu	a4,a3,ffffffffc0202998 <default_check+0x582>
    return page - pages + nbase;
ffffffffc02024dc:	40f507b3          	sub	a5,a0,a5
ffffffffc02024e0:	8799                	srai	a5,a5,0x6
ffffffffc02024e2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02024e4:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02024e6:	30d7f963          	bgeu	a5,a3,ffffffffc02027f8 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc02024ea:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02024ec:	00043c03          	ld	s8,0(s0)
ffffffffc02024f0:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc02024f4:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc02024f8:	e400                	sd	s0,8(s0)
ffffffffc02024fa:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc02024fc:	0000f797          	auipc	a5,0xf
ffffffffc0202500:	0007a623          	sw	zero,12(a5) # ffffffffc0211508 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0202504:	1dd000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202508:	2c051863          	bnez	a0,ffffffffc02027d8 <default_check+0x3c2>
    free_page(p0);
ffffffffc020250c:	4585                	li	a1,1
ffffffffc020250e:	8556                	mv	a0,s5
ffffffffc0202510:	263000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    free_page(p1);
ffffffffc0202514:	4585                	li	a1,1
ffffffffc0202516:	854e                	mv	a0,s3
ffffffffc0202518:	25b000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    free_page(p2);
ffffffffc020251c:	4585                	li	a1,1
ffffffffc020251e:	8552                	mv	a0,s4
ffffffffc0202520:	253000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    assert(nr_free == 3);
ffffffffc0202524:	4818                	lw	a4,16(s0)
ffffffffc0202526:	478d                	li	a5,3
ffffffffc0202528:	28f71863          	bne	a4,a5,ffffffffc02027b8 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020252c:	4505                	li	a0,1
ffffffffc020252e:	1b3000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202532:	89aa                	mv	s3,a0
ffffffffc0202534:	26050263          	beqz	a0,ffffffffc0202798 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202538:	4505                	li	a0,1
ffffffffc020253a:	1a7000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020253e:	8aaa                	mv	s5,a0
ffffffffc0202540:	3a050c63          	beqz	a0,ffffffffc02028f8 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202544:	4505                	li	a0,1
ffffffffc0202546:	19b000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020254a:	8a2a                	mv	s4,a0
ffffffffc020254c:	38050663          	beqz	a0,ffffffffc02028d8 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0202550:	4505                	li	a0,1
ffffffffc0202552:	18f000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202556:	36051163          	bnez	a0,ffffffffc02028b8 <default_check+0x4a2>
    free_page(p0);
ffffffffc020255a:	4585                	li	a1,1
ffffffffc020255c:	854e                	mv	a0,s3
ffffffffc020255e:	215000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0202562:	641c                	ld	a5,8(s0)
ffffffffc0202564:	20878a63          	beq	a5,s0,ffffffffc0202778 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0202568:	4505                	li	a0,1
ffffffffc020256a:	177000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020256e:	30a99563          	bne	s3,a0,ffffffffc0202878 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0202572:	4505                	li	a0,1
ffffffffc0202574:	16d000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202578:	2e051063          	bnez	a0,ffffffffc0202858 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc020257c:	481c                	lw	a5,16(s0)
ffffffffc020257e:	2a079d63          	bnez	a5,ffffffffc0202838 <default_check+0x422>
    free_page(p);
ffffffffc0202582:	854e                	mv	a0,s3
ffffffffc0202584:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0202586:	01843023          	sd	s8,0(s0)
ffffffffc020258a:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc020258e:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0202592:	1e1000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    free_page(p1);
ffffffffc0202596:	4585                	li	a1,1
ffffffffc0202598:	8556                	mv	a0,s5
ffffffffc020259a:	1d9000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    free_page(p2);
ffffffffc020259e:	4585                	li	a1,1
ffffffffc02025a0:	8552                	mv	a0,s4
ffffffffc02025a2:	1d1000ef          	jal	ra,ffffffffc0202f72 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02025a6:	4515                	li	a0,5
ffffffffc02025a8:	139000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc02025ac:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02025ae:	26050563          	beqz	a0,ffffffffc0202818 <default_check+0x402>
ffffffffc02025b2:	651c                	ld	a5,8(a0)
ffffffffc02025b4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02025b6:	8b85                	andi	a5,a5,1
ffffffffc02025b8:	54079063          	bnez	a5,ffffffffc0202af8 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02025bc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02025be:	00043b03          	ld	s6,0(s0)
ffffffffc02025c2:	00843a83          	ld	s5,8(s0)
ffffffffc02025c6:	e000                	sd	s0,0(s0)
ffffffffc02025c8:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02025ca:	117000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc02025ce:	50051563          	bnez	a0,ffffffffc0202ad8 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02025d2:	08098a13          	addi	s4,s3,128
ffffffffc02025d6:	8552                	mv	a0,s4
ffffffffc02025d8:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02025da:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc02025de:	0000f797          	auipc	a5,0xf
ffffffffc02025e2:	f207a523          	sw	zero,-214(a5) # ffffffffc0211508 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02025e6:	18d000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02025ea:	4511                	li	a0,4
ffffffffc02025ec:	0f5000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc02025f0:	4c051463          	bnez	a0,ffffffffc0202ab8 <default_check+0x6a2>
ffffffffc02025f4:	0889b783          	ld	a5,136(s3)
ffffffffc02025f8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02025fa:	8b85                	andi	a5,a5,1
ffffffffc02025fc:	48078e63          	beqz	a5,ffffffffc0202a98 <default_check+0x682>
ffffffffc0202600:	0909a703          	lw	a4,144(s3)
ffffffffc0202604:	478d                	li	a5,3
ffffffffc0202606:	48f71963          	bne	a4,a5,ffffffffc0202a98 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020260a:	450d                	li	a0,3
ffffffffc020260c:	0d5000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202610:	8c2a                	mv	s8,a0
ffffffffc0202612:	46050363          	beqz	a0,ffffffffc0202a78 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc0202616:	4505                	li	a0,1
ffffffffc0202618:	0c9000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020261c:	42051e63          	bnez	a0,ffffffffc0202a58 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0202620:	418a1c63          	bne	s4,s8,ffffffffc0202a38 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0202624:	4585                	li	a1,1
ffffffffc0202626:	854e                	mv	a0,s3
ffffffffc0202628:	14b000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    free_pages(p1, 3);
ffffffffc020262c:	458d                	li	a1,3
ffffffffc020262e:	8552                	mv	a0,s4
ffffffffc0202630:	143000ef          	jal	ra,ffffffffc0202f72 <free_pages>
ffffffffc0202634:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0202638:	04098c13          	addi	s8,s3,64
ffffffffc020263c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020263e:	8b85                	andi	a5,a5,1
ffffffffc0202640:	3c078c63          	beqz	a5,ffffffffc0202a18 <default_check+0x602>
ffffffffc0202644:	0109a703          	lw	a4,16(s3)
ffffffffc0202648:	4785                	li	a5,1
ffffffffc020264a:	3cf71763          	bne	a4,a5,ffffffffc0202a18 <default_check+0x602>
ffffffffc020264e:	008a3783          	ld	a5,8(s4)
ffffffffc0202652:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202654:	8b85                	andi	a5,a5,1
ffffffffc0202656:	3a078163          	beqz	a5,ffffffffc02029f8 <default_check+0x5e2>
ffffffffc020265a:	010a2703          	lw	a4,16(s4)
ffffffffc020265e:	478d                	li	a5,3
ffffffffc0202660:	38f71c63          	bne	a4,a5,ffffffffc02029f8 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202664:	4505                	li	a0,1
ffffffffc0202666:	07b000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020266a:	36a99763          	bne	s3,a0,ffffffffc02029d8 <default_check+0x5c2>
    free_page(p0);
ffffffffc020266e:	4585                	li	a1,1
ffffffffc0202670:	103000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202674:	4509                	li	a0,2
ffffffffc0202676:	06b000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020267a:	32aa1f63          	bne	s4,a0,ffffffffc02029b8 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc020267e:	4589                	li	a1,2
ffffffffc0202680:	0f3000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    free_page(p2);
ffffffffc0202684:	4585                	li	a1,1
ffffffffc0202686:	8562                	mv	a0,s8
ffffffffc0202688:	0eb000ef          	jal	ra,ffffffffc0202f72 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020268c:	4515                	li	a0,5
ffffffffc020268e:	053000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0202692:	89aa                	mv	s3,a0
ffffffffc0202694:	48050263          	beqz	a0,ffffffffc0202b18 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc0202698:	4505                	li	a0,1
ffffffffc020269a:	047000ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020269e:	2c051d63          	bnez	a0,ffffffffc0202978 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02026a2:	481c                	lw	a5,16(s0)
ffffffffc02026a4:	2a079a63          	bnez	a5,ffffffffc0202958 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02026a8:	4595                	li	a1,5
ffffffffc02026aa:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02026ac:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02026b0:	01643023          	sd	s6,0(s0)
ffffffffc02026b4:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02026b8:	0bb000ef          	jal	ra,ffffffffc0202f72 <free_pages>
    return listelm->next;
ffffffffc02026bc:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02026be:	00878963          	beq	a5,s0,ffffffffc02026d0 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02026c2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02026c6:	679c                	ld	a5,8(a5)
ffffffffc02026c8:	397d                	addiw	s2,s2,-1
ffffffffc02026ca:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02026cc:	fe879be3          	bne	a5,s0,ffffffffc02026c2 <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02026d0:	26091463          	bnez	s2,ffffffffc0202938 <default_check+0x522>
    assert(total == 0);
ffffffffc02026d4:	46049263          	bnez	s1,ffffffffc0202b38 <default_check+0x722>
}
ffffffffc02026d8:	60a6                	ld	ra,72(sp)
ffffffffc02026da:	6406                	ld	s0,64(sp)
ffffffffc02026dc:	74e2                	ld	s1,56(sp)
ffffffffc02026de:	7942                	ld	s2,48(sp)
ffffffffc02026e0:	79a2                	ld	s3,40(sp)
ffffffffc02026e2:	7a02                	ld	s4,32(sp)
ffffffffc02026e4:	6ae2                	ld	s5,24(sp)
ffffffffc02026e6:	6b42                	ld	s6,16(sp)
ffffffffc02026e8:	6ba2                	ld	s7,8(sp)
ffffffffc02026ea:	6c02                	ld	s8,0(sp)
ffffffffc02026ec:	6161                	addi	sp,sp,80
ffffffffc02026ee:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02026f0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02026f2:	4481                	li	s1,0
ffffffffc02026f4:	4901                	li	s2,0
ffffffffc02026f6:	b38d                	j	ffffffffc0202458 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc02026f8:	00003697          	auipc	a3,0x3
ffffffffc02026fc:	04068693          	addi	a3,a3,64 # ffffffffc0205738 <commands+0xb28>
ffffffffc0202700:	00003617          	auipc	a2,0x3
ffffffffc0202704:	c3860613          	addi	a2,a2,-968 # ffffffffc0205338 <commands+0x728>
ffffffffc0202708:	0f000593          	li	a1,240
ffffffffc020270c:	00003517          	auipc	a0,0x3
ffffffffc0202710:	5cc50513          	addi	a0,a0,1484 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202714:	ab5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202718:	00003697          	auipc	a3,0x3
ffffffffc020271c:	63868693          	addi	a3,a3,1592 # ffffffffc0205d50 <commands+0x1140>
ffffffffc0202720:	00003617          	auipc	a2,0x3
ffffffffc0202724:	c1860613          	addi	a2,a2,-1000 # ffffffffc0205338 <commands+0x728>
ffffffffc0202728:	0bd00593          	li	a1,189
ffffffffc020272c:	00003517          	auipc	a0,0x3
ffffffffc0202730:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202734:	a95fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202738:	00003697          	auipc	a3,0x3
ffffffffc020273c:	64068693          	addi	a3,a3,1600 # ffffffffc0205d78 <commands+0x1168>
ffffffffc0202740:	00003617          	auipc	a2,0x3
ffffffffc0202744:	bf860613          	addi	a2,a2,-1032 # ffffffffc0205338 <commands+0x728>
ffffffffc0202748:	0be00593          	li	a1,190
ffffffffc020274c:	00003517          	auipc	a0,0x3
ffffffffc0202750:	58c50513          	addi	a0,a0,1420 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202754:	a75fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202758:	00003697          	auipc	a3,0x3
ffffffffc020275c:	66068693          	addi	a3,a3,1632 # ffffffffc0205db8 <commands+0x11a8>
ffffffffc0202760:	00003617          	auipc	a2,0x3
ffffffffc0202764:	bd860613          	addi	a2,a2,-1064 # ffffffffc0205338 <commands+0x728>
ffffffffc0202768:	0c000593          	li	a1,192
ffffffffc020276c:	00003517          	auipc	a0,0x3
ffffffffc0202770:	56c50513          	addi	a0,a0,1388 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202774:	a55fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0202778:	00003697          	auipc	a3,0x3
ffffffffc020277c:	6c868693          	addi	a3,a3,1736 # ffffffffc0205e40 <commands+0x1230>
ffffffffc0202780:	00003617          	auipc	a2,0x3
ffffffffc0202784:	bb860613          	addi	a2,a2,-1096 # ffffffffc0205338 <commands+0x728>
ffffffffc0202788:	0d900593          	li	a1,217
ffffffffc020278c:	00003517          	auipc	a0,0x3
ffffffffc0202790:	54c50513          	addi	a0,a0,1356 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202794:	a35fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202798:	00003697          	auipc	a3,0x3
ffffffffc020279c:	55868693          	addi	a3,a3,1368 # ffffffffc0205cf0 <commands+0x10e0>
ffffffffc02027a0:	00003617          	auipc	a2,0x3
ffffffffc02027a4:	b9860613          	addi	a2,a2,-1128 # ffffffffc0205338 <commands+0x728>
ffffffffc02027a8:	0d200593          	li	a1,210
ffffffffc02027ac:	00003517          	auipc	a0,0x3
ffffffffc02027b0:	52c50513          	addi	a0,a0,1324 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02027b4:	a15fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 3);
ffffffffc02027b8:	00003697          	auipc	a3,0x3
ffffffffc02027bc:	67868693          	addi	a3,a3,1656 # ffffffffc0205e30 <commands+0x1220>
ffffffffc02027c0:	00003617          	auipc	a2,0x3
ffffffffc02027c4:	b7860613          	addi	a2,a2,-1160 # ffffffffc0205338 <commands+0x728>
ffffffffc02027c8:	0d000593          	li	a1,208
ffffffffc02027cc:	00003517          	auipc	a0,0x3
ffffffffc02027d0:	50c50513          	addi	a0,a0,1292 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02027d4:	9f5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02027d8:	00003697          	auipc	a3,0x3
ffffffffc02027dc:	64068693          	addi	a3,a3,1600 # ffffffffc0205e18 <commands+0x1208>
ffffffffc02027e0:	00003617          	auipc	a2,0x3
ffffffffc02027e4:	b5860613          	addi	a2,a2,-1192 # ffffffffc0205338 <commands+0x728>
ffffffffc02027e8:	0cb00593          	li	a1,203
ffffffffc02027ec:	00003517          	auipc	a0,0x3
ffffffffc02027f0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02027f4:	9d5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02027f8:	00003697          	auipc	a3,0x3
ffffffffc02027fc:	60068693          	addi	a3,a3,1536 # ffffffffc0205df8 <commands+0x11e8>
ffffffffc0202800:	00003617          	auipc	a2,0x3
ffffffffc0202804:	b3860613          	addi	a2,a2,-1224 # ffffffffc0205338 <commands+0x728>
ffffffffc0202808:	0c200593          	li	a1,194
ffffffffc020280c:	00003517          	auipc	a0,0x3
ffffffffc0202810:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202814:	9b5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 != NULL);
ffffffffc0202818:	00003697          	auipc	a3,0x3
ffffffffc020281c:	66068693          	addi	a3,a3,1632 # ffffffffc0205e78 <commands+0x1268>
ffffffffc0202820:	00003617          	auipc	a2,0x3
ffffffffc0202824:	b1860613          	addi	a2,a2,-1256 # ffffffffc0205338 <commands+0x728>
ffffffffc0202828:	0f800593          	li	a1,248
ffffffffc020282c:	00003517          	auipc	a0,0x3
ffffffffc0202830:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202834:	995fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0202838:	00003697          	auipc	a3,0x3
ffffffffc020283c:	0b068693          	addi	a3,a3,176 # ffffffffc02058e8 <commands+0xcd8>
ffffffffc0202840:	00003617          	auipc	a2,0x3
ffffffffc0202844:	af860613          	addi	a2,a2,-1288 # ffffffffc0205338 <commands+0x728>
ffffffffc0202848:	0df00593          	li	a1,223
ffffffffc020284c:	00003517          	auipc	a0,0x3
ffffffffc0202850:	48c50513          	addi	a0,a0,1164 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202854:	975fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202858:	00003697          	auipc	a3,0x3
ffffffffc020285c:	5c068693          	addi	a3,a3,1472 # ffffffffc0205e18 <commands+0x1208>
ffffffffc0202860:	00003617          	auipc	a2,0x3
ffffffffc0202864:	ad860613          	addi	a2,a2,-1320 # ffffffffc0205338 <commands+0x728>
ffffffffc0202868:	0dd00593          	li	a1,221
ffffffffc020286c:	00003517          	auipc	a0,0x3
ffffffffc0202870:	46c50513          	addi	a0,a0,1132 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202874:	955fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0202878:	00003697          	auipc	a3,0x3
ffffffffc020287c:	5e068693          	addi	a3,a3,1504 # ffffffffc0205e58 <commands+0x1248>
ffffffffc0202880:	00003617          	auipc	a2,0x3
ffffffffc0202884:	ab860613          	addi	a2,a2,-1352 # ffffffffc0205338 <commands+0x728>
ffffffffc0202888:	0dc00593          	li	a1,220
ffffffffc020288c:	00003517          	auipc	a0,0x3
ffffffffc0202890:	44c50513          	addi	a0,a0,1100 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202894:	935fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0202898:	00003697          	auipc	a3,0x3
ffffffffc020289c:	45868693          	addi	a3,a3,1112 # ffffffffc0205cf0 <commands+0x10e0>
ffffffffc02028a0:	00003617          	auipc	a2,0x3
ffffffffc02028a4:	a9860613          	addi	a2,a2,-1384 # ffffffffc0205338 <commands+0x728>
ffffffffc02028a8:	0b900593          	li	a1,185
ffffffffc02028ac:	00003517          	auipc	a0,0x3
ffffffffc02028b0:	42c50513          	addi	a0,a0,1068 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02028b4:	915fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02028b8:	00003697          	auipc	a3,0x3
ffffffffc02028bc:	56068693          	addi	a3,a3,1376 # ffffffffc0205e18 <commands+0x1208>
ffffffffc02028c0:	00003617          	auipc	a2,0x3
ffffffffc02028c4:	a7860613          	addi	a2,a2,-1416 # ffffffffc0205338 <commands+0x728>
ffffffffc02028c8:	0d600593          	li	a1,214
ffffffffc02028cc:	00003517          	auipc	a0,0x3
ffffffffc02028d0:	40c50513          	addi	a0,a0,1036 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02028d4:	8f5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02028d8:	00003697          	auipc	a3,0x3
ffffffffc02028dc:	45868693          	addi	a3,a3,1112 # ffffffffc0205d30 <commands+0x1120>
ffffffffc02028e0:	00003617          	auipc	a2,0x3
ffffffffc02028e4:	a5860613          	addi	a2,a2,-1448 # ffffffffc0205338 <commands+0x728>
ffffffffc02028e8:	0d400593          	li	a1,212
ffffffffc02028ec:	00003517          	auipc	a0,0x3
ffffffffc02028f0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02028f4:	8d5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02028f8:	00003697          	auipc	a3,0x3
ffffffffc02028fc:	41868693          	addi	a3,a3,1048 # ffffffffc0205d10 <commands+0x1100>
ffffffffc0202900:	00003617          	auipc	a2,0x3
ffffffffc0202904:	a3860613          	addi	a2,a2,-1480 # ffffffffc0205338 <commands+0x728>
ffffffffc0202908:	0d300593          	li	a1,211
ffffffffc020290c:	00003517          	auipc	a0,0x3
ffffffffc0202910:	3cc50513          	addi	a0,a0,972 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202914:	8b5fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202918:	00003697          	auipc	a3,0x3
ffffffffc020291c:	41868693          	addi	a3,a3,1048 # ffffffffc0205d30 <commands+0x1120>
ffffffffc0202920:	00003617          	auipc	a2,0x3
ffffffffc0202924:	a1860613          	addi	a2,a2,-1512 # ffffffffc0205338 <commands+0x728>
ffffffffc0202928:	0bb00593          	li	a1,187
ffffffffc020292c:	00003517          	auipc	a0,0x3
ffffffffc0202930:	3ac50513          	addi	a0,a0,940 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202934:	895fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(count == 0);
ffffffffc0202938:	00003697          	auipc	a3,0x3
ffffffffc020293c:	69068693          	addi	a3,a3,1680 # ffffffffc0205fc8 <commands+0x13b8>
ffffffffc0202940:	00003617          	auipc	a2,0x3
ffffffffc0202944:	9f860613          	addi	a2,a2,-1544 # ffffffffc0205338 <commands+0x728>
ffffffffc0202948:	12500593          	li	a1,293
ffffffffc020294c:	00003517          	auipc	a0,0x3
ffffffffc0202950:	38c50513          	addi	a0,a0,908 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202954:	875fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free == 0);
ffffffffc0202958:	00003697          	auipc	a3,0x3
ffffffffc020295c:	f9068693          	addi	a3,a3,-112 # ffffffffc02058e8 <commands+0xcd8>
ffffffffc0202960:	00003617          	auipc	a2,0x3
ffffffffc0202964:	9d860613          	addi	a2,a2,-1576 # ffffffffc0205338 <commands+0x728>
ffffffffc0202968:	11a00593          	li	a1,282
ffffffffc020296c:	00003517          	auipc	a0,0x3
ffffffffc0202970:	36c50513          	addi	a0,a0,876 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202974:	855fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202978:	00003697          	auipc	a3,0x3
ffffffffc020297c:	4a068693          	addi	a3,a3,1184 # ffffffffc0205e18 <commands+0x1208>
ffffffffc0202980:	00003617          	auipc	a2,0x3
ffffffffc0202984:	9b860613          	addi	a2,a2,-1608 # ffffffffc0205338 <commands+0x728>
ffffffffc0202988:	11800593          	li	a1,280
ffffffffc020298c:	00003517          	auipc	a0,0x3
ffffffffc0202990:	34c50513          	addi	a0,a0,844 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202994:	835fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202998:	00003697          	auipc	a3,0x3
ffffffffc020299c:	44068693          	addi	a3,a3,1088 # ffffffffc0205dd8 <commands+0x11c8>
ffffffffc02029a0:	00003617          	auipc	a2,0x3
ffffffffc02029a4:	99860613          	addi	a2,a2,-1640 # ffffffffc0205338 <commands+0x728>
ffffffffc02029a8:	0c100593          	li	a1,193
ffffffffc02029ac:	00003517          	auipc	a0,0x3
ffffffffc02029b0:	32c50513          	addi	a0,a0,812 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02029b4:	815fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02029b8:	00003697          	auipc	a3,0x3
ffffffffc02029bc:	5d068693          	addi	a3,a3,1488 # ffffffffc0205f88 <commands+0x1378>
ffffffffc02029c0:	00003617          	auipc	a2,0x3
ffffffffc02029c4:	97860613          	addi	a2,a2,-1672 # ffffffffc0205338 <commands+0x728>
ffffffffc02029c8:	11200593          	li	a1,274
ffffffffc02029cc:	00003517          	auipc	a0,0x3
ffffffffc02029d0:	30c50513          	addi	a0,a0,780 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02029d4:	ff4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02029d8:	00003697          	auipc	a3,0x3
ffffffffc02029dc:	59068693          	addi	a3,a3,1424 # ffffffffc0205f68 <commands+0x1358>
ffffffffc02029e0:	00003617          	auipc	a2,0x3
ffffffffc02029e4:	95860613          	addi	a2,a2,-1704 # ffffffffc0205338 <commands+0x728>
ffffffffc02029e8:	11000593          	li	a1,272
ffffffffc02029ec:	00003517          	auipc	a0,0x3
ffffffffc02029f0:	2ec50513          	addi	a0,a0,748 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc02029f4:	fd4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02029f8:	00003697          	auipc	a3,0x3
ffffffffc02029fc:	54868693          	addi	a3,a3,1352 # ffffffffc0205f40 <commands+0x1330>
ffffffffc0202a00:	00003617          	auipc	a2,0x3
ffffffffc0202a04:	93860613          	addi	a2,a2,-1736 # ffffffffc0205338 <commands+0x728>
ffffffffc0202a08:	10e00593          	li	a1,270
ffffffffc0202a0c:	00003517          	auipc	a0,0x3
ffffffffc0202a10:	2cc50513          	addi	a0,a0,716 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202a14:	fb4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202a18:	00003697          	auipc	a3,0x3
ffffffffc0202a1c:	50068693          	addi	a3,a3,1280 # ffffffffc0205f18 <commands+0x1308>
ffffffffc0202a20:	00003617          	auipc	a2,0x3
ffffffffc0202a24:	91860613          	addi	a2,a2,-1768 # ffffffffc0205338 <commands+0x728>
ffffffffc0202a28:	10d00593          	li	a1,269
ffffffffc0202a2c:	00003517          	auipc	a0,0x3
ffffffffc0202a30:	2ac50513          	addi	a0,a0,684 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202a34:	f94fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202a38:	00003697          	auipc	a3,0x3
ffffffffc0202a3c:	4d068693          	addi	a3,a3,1232 # ffffffffc0205f08 <commands+0x12f8>
ffffffffc0202a40:	00003617          	auipc	a2,0x3
ffffffffc0202a44:	8f860613          	addi	a2,a2,-1800 # ffffffffc0205338 <commands+0x728>
ffffffffc0202a48:	10800593          	li	a1,264
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	28c50513          	addi	a0,a0,652 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202a54:	f74fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202a58:	00003697          	auipc	a3,0x3
ffffffffc0202a5c:	3c068693          	addi	a3,a3,960 # ffffffffc0205e18 <commands+0x1208>
ffffffffc0202a60:	00003617          	auipc	a2,0x3
ffffffffc0202a64:	8d860613          	addi	a2,a2,-1832 # ffffffffc0205338 <commands+0x728>
ffffffffc0202a68:	10700593          	li	a1,263
ffffffffc0202a6c:	00003517          	auipc	a0,0x3
ffffffffc0202a70:	26c50513          	addi	a0,a0,620 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202a74:	f54fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202a78:	00003697          	auipc	a3,0x3
ffffffffc0202a7c:	47068693          	addi	a3,a3,1136 # ffffffffc0205ee8 <commands+0x12d8>
ffffffffc0202a80:	00003617          	auipc	a2,0x3
ffffffffc0202a84:	8b860613          	addi	a2,a2,-1864 # ffffffffc0205338 <commands+0x728>
ffffffffc0202a88:	10600593          	li	a1,262
ffffffffc0202a8c:	00003517          	auipc	a0,0x3
ffffffffc0202a90:	24c50513          	addi	a0,a0,588 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202a94:	f34fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202a98:	00003697          	auipc	a3,0x3
ffffffffc0202a9c:	42068693          	addi	a3,a3,1056 # ffffffffc0205eb8 <commands+0x12a8>
ffffffffc0202aa0:	00003617          	auipc	a2,0x3
ffffffffc0202aa4:	89860613          	addi	a2,a2,-1896 # ffffffffc0205338 <commands+0x728>
ffffffffc0202aa8:	10500593          	li	a1,261
ffffffffc0202aac:	00003517          	auipc	a0,0x3
ffffffffc0202ab0:	22c50513          	addi	a0,a0,556 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202ab4:	f14fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202ab8:	00003697          	auipc	a3,0x3
ffffffffc0202abc:	3e868693          	addi	a3,a3,1000 # ffffffffc0205ea0 <commands+0x1290>
ffffffffc0202ac0:	00003617          	auipc	a2,0x3
ffffffffc0202ac4:	87860613          	addi	a2,a2,-1928 # ffffffffc0205338 <commands+0x728>
ffffffffc0202ac8:	10400593          	li	a1,260
ffffffffc0202acc:	00003517          	auipc	a0,0x3
ffffffffc0202ad0:	20c50513          	addi	a0,a0,524 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202ad4:	ef4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202ad8:	00003697          	auipc	a3,0x3
ffffffffc0202adc:	34068693          	addi	a3,a3,832 # ffffffffc0205e18 <commands+0x1208>
ffffffffc0202ae0:	00003617          	auipc	a2,0x3
ffffffffc0202ae4:	85860613          	addi	a2,a2,-1960 # ffffffffc0205338 <commands+0x728>
ffffffffc0202ae8:	0fe00593          	li	a1,254
ffffffffc0202aec:	00003517          	auipc	a0,0x3
ffffffffc0202af0:	1ec50513          	addi	a0,a0,492 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202af4:	ed4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202af8:	00003697          	auipc	a3,0x3
ffffffffc0202afc:	39068693          	addi	a3,a3,912 # ffffffffc0205e88 <commands+0x1278>
ffffffffc0202b00:	00003617          	auipc	a2,0x3
ffffffffc0202b04:	83860613          	addi	a2,a2,-1992 # ffffffffc0205338 <commands+0x728>
ffffffffc0202b08:	0f900593          	li	a1,249
ffffffffc0202b0c:	00003517          	auipc	a0,0x3
ffffffffc0202b10:	1cc50513          	addi	a0,a0,460 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202b14:	eb4fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202b18:	00003697          	auipc	a3,0x3
ffffffffc0202b1c:	49068693          	addi	a3,a3,1168 # ffffffffc0205fa8 <commands+0x1398>
ffffffffc0202b20:	00003617          	auipc	a2,0x3
ffffffffc0202b24:	81860613          	addi	a2,a2,-2024 # ffffffffc0205338 <commands+0x728>
ffffffffc0202b28:	11700593          	li	a1,279
ffffffffc0202b2c:	00003517          	auipc	a0,0x3
ffffffffc0202b30:	1ac50513          	addi	a0,a0,428 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202b34:	e94fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == 0);
ffffffffc0202b38:	00003697          	auipc	a3,0x3
ffffffffc0202b3c:	4a068693          	addi	a3,a3,1184 # ffffffffc0205fd8 <commands+0x13c8>
ffffffffc0202b40:	00002617          	auipc	a2,0x2
ffffffffc0202b44:	7f860613          	addi	a2,a2,2040 # ffffffffc0205338 <commands+0x728>
ffffffffc0202b48:	12600593          	li	a1,294
ffffffffc0202b4c:	00003517          	auipc	a0,0x3
ffffffffc0202b50:	18c50513          	addi	a0,a0,396 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202b54:	e74fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0202b58:	00003697          	auipc	a3,0x3
ffffffffc0202b5c:	bf068693          	addi	a3,a3,-1040 # ffffffffc0205748 <commands+0xb38>
ffffffffc0202b60:	00002617          	auipc	a2,0x2
ffffffffc0202b64:	7d860613          	addi	a2,a2,2008 # ffffffffc0205338 <commands+0x728>
ffffffffc0202b68:	0f300593          	li	a1,243
ffffffffc0202b6c:	00003517          	auipc	a0,0x3
ffffffffc0202b70:	16c50513          	addi	a0,a0,364 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202b74:	e54fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202b78:	00003697          	auipc	a3,0x3
ffffffffc0202b7c:	19868693          	addi	a3,a3,408 # ffffffffc0205d10 <commands+0x1100>
ffffffffc0202b80:	00002617          	auipc	a2,0x2
ffffffffc0202b84:	7b860613          	addi	a2,a2,1976 # ffffffffc0205338 <commands+0x728>
ffffffffc0202b88:	0ba00593          	li	a1,186
ffffffffc0202b8c:	00003517          	auipc	a0,0x3
ffffffffc0202b90:	14c50513          	addi	a0,a0,332 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202b94:	e34fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202b98 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0202b98:	1141                	addi	sp,sp,-16
ffffffffc0202b9a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202b9c:	14058463          	beqz	a1,ffffffffc0202ce4 <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc0202ba0:	00659693          	slli	a3,a1,0x6
ffffffffc0202ba4:	96aa                	add	a3,a3,a0
ffffffffc0202ba6:	87aa                	mv	a5,a0
ffffffffc0202ba8:	02d50263          	beq	a0,a3,ffffffffc0202bcc <default_free_pages+0x34>
ffffffffc0202bac:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202bae:	8b05                	andi	a4,a4,1
ffffffffc0202bb0:	10071a63          	bnez	a4,ffffffffc0202cc4 <default_free_pages+0x12c>
ffffffffc0202bb4:	6798                	ld	a4,8(a5)
ffffffffc0202bb6:	8b09                	andi	a4,a4,2
ffffffffc0202bb8:	10071663          	bnez	a4,ffffffffc0202cc4 <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc0202bbc:	0007b423          	sd	zero,8(a5)
    page->ref = val;
ffffffffc0202bc0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202bc4:	04078793          	addi	a5,a5,64
ffffffffc0202bc8:	fed792e3          	bne	a5,a3,ffffffffc0202bac <default_free_pages+0x14>
    base->property = n;
ffffffffc0202bcc:	2581                	sext.w	a1,a1
ffffffffc0202bce:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0202bd0:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202bd4:	4789                	li	a5,2
ffffffffc0202bd6:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0202bda:	0000f697          	auipc	a3,0xf
ffffffffc0202bde:	91e68693          	addi	a3,a3,-1762 # ffffffffc02114f8 <free_area>
ffffffffc0202be2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202be4:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202be6:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202bea:	9db9                	addw	a1,a1,a4
ffffffffc0202bec:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202bee:	0ad78463          	beq	a5,a3,ffffffffc0202c96 <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc0202bf2:	fe878713          	addi	a4,a5,-24
ffffffffc0202bf6:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202bfa:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202bfc:	00e56a63          	bltu	a0,a4,ffffffffc0202c10 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0202c00:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202c02:	04d70c63          	beq	a4,a3,ffffffffc0202c5a <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc0202c06:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202c08:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202c0c:	fee57ae3          	bgeu	a0,a4,ffffffffc0202c00 <default_free_pages+0x68>
ffffffffc0202c10:	c199                	beqz	a1,ffffffffc0202c16 <default_free_pages+0x7e>
ffffffffc0202c12:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202c16:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0202c18:	e390                	sd	a2,0(a5)
ffffffffc0202c1a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202c1c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202c1e:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0202c20:	00d70d63          	beq	a4,a3,ffffffffc0202c3a <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0202c24:	ff872583          	lw	a1,-8(a4) # ff8 <kern_entry-0xffffffffc01ff008>
        p = le2page(le, page_link);
ffffffffc0202c28:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0202c2c:	02059813          	slli	a6,a1,0x20
ffffffffc0202c30:	01a85793          	srli	a5,a6,0x1a
ffffffffc0202c34:	97b2                	add	a5,a5,a2
ffffffffc0202c36:	02f50c63          	beq	a0,a5,ffffffffc0202c6e <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0202c3a:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0202c3c:	00d78c63          	beq	a5,a3,ffffffffc0202c54 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0202c40:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc0202c42:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0202c46:	02061593          	slli	a1,a2,0x20
ffffffffc0202c4a:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0202c4e:	972a                	add	a4,a4,a0
ffffffffc0202c50:	04e68a63          	beq	a3,a4,ffffffffc0202ca4 <default_free_pages+0x10c>
}
ffffffffc0202c54:	60a2                	ld	ra,8(sp)
ffffffffc0202c56:	0141                	addi	sp,sp,16
ffffffffc0202c58:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202c5a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202c5c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202c5e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202c60:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202c62:	02d70763          	beq	a4,a3,ffffffffc0202c90 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc0202c66:	8832                	mv	a6,a2
ffffffffc0202c68:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202c6a:	87ba                	mv	a5,a4
ffffffffc0202c6c:	bf71                	j	ffffffffc0202c08 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0202c6e:	491c                	lw	a5,16(a0)
ffffffffc0202c70:	9dbd                	addw	a1,a1,a5
ffffffffc0202c72:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202c76:	57f5                	li	a5,-3
ffffffffc0202c78:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202c7c:	01853803          	ld	a6,24(a0)
ffffffffc0202c80:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc0202c82:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0202c84:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc0202c88:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0202c8a:	0105b023          	sd	a6,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0202c8e:	b77d                	j	ffffffffc0202c3c <default_free_pages+0xa4>
ffffffffc0202c90:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202c92:	873e                	mv	a4,a5
ffffffffc0202c94:	bf41                	j	ffffffffc0202c24 <default_free_pages+0x8c>
}
ffffffffc0202c96:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202c98:	e390                	sd	a2,0(a5)
ffffffffc0202c9a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202c9c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202c9e:	ed1c                	sd	a5,24(a0)
ffffffffc0202ca0:	0141                	addi	sp,sp,16
ffffffffc0202ca2:	8082                	ret
            base->property += p->property;
ffffffffc0202ca4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ca8:	ff078693          	addi	a3,a5,-16
ffffffffc0202cac:	9e39                	addw	a2,a2,a4
ffffffffc0202cae:	c910                	sw	a2,16(a0)
ffffffffc0202cb0:	5775                	li	a4,-3
ffffffffc0202cb2:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202cb6:	6398                	ld	a4,0(a5)
ffffffffc0202cb8:	679c                	ld	a5,8(a5)
}
ffffffffc0202cba:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202cbc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202cbe:	e398                	sd	a4,0(a5)
ffffffffc0202cc0:	0141                	addi	sp,sp,16
ffffffffc0202cc2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202cc4:	00003697          	auipc	a3,0x3
ffffffffc0202cc8:	32c68693          	addi	a3,a3,812 # ffffffffc0205ff0 <commands+0x13e0>
ffffffffc0202ccc:	00002617          	auipc	a2,0x2
ffffffffc0202cd0:	66c60613          	addi	a2,a2,1644 # ffffffffc0205338 <commands+0x728>
ffffffffc0202cd4:	08300593          	li	a1,131
ffffffffc0202cd8:	00003517          	auipc	a0,0x3
ffffffffc0202cdc:	00050513          	mv	a0,a0
ffffffffc0202ce0:	ce8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0202ce4:	00003697          	auipc	a3,0x3
ffffffffc0202ce8:	30468693          	addi	a3,a3,772 # ffffffffc0205fe8 <commands+0x13d8>
ffffffffc0202cec:	00002617          	auipc	a2,0x2
ffffffffc0202cf0:	64c60613          	addi	a2,a2,1612 # ffffffffc0205338 <commands+0x728>
ffffffffc0202cf4:	08000593          	li	a1,128
ffffffffc0202cf8:	00003517          	auipc	a0,0x3
ffffffffc0202cfc:	fe050513          	addi	a0,a0,-32 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202d00:	cc8fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202d04 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202d04:	c941                	beqz	a0,ffffffffc0202d94 <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc0202d06:	0000e597          	auipc	a1,0xe
ffffffffc0202d0a:	7f258593          	addi	a1,a1,2034 # ffffffffc02114f8 <free_area>
ffffffffc0202d0e:	0105a803          	lw	a6,16(a1)
ffffffffc0202d12:	872a                	mv	a4,a0
ffffffffc0202d14:	02081793          	slli	a5,a6,0x20
ffffffffc0202d18:	9381                	srli	a5,a5,0x20
ffffffffc0202d1a:	00a7ee63          	bltu	a5,a0,ffffffffc0202d36 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0202d1e:	87ae                	mv	a5,a1
ffffffffc0202d20:	a801                	j	ffffffffc0202d30 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0202d22:	ff87a683          	lw	a3,-8(a5)
ffffffffc0202d26:	02069613          	slli	a2,a3,0x20
ffffffffc0202d2a:	9201                	srli	a2,a2,0x20
ffffffffc0202d2c:	00e67763          	bgeu	a2,a4,ffffffffc0202d3a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0202d30:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0202d32:	feb798e3          	bne	a5,a1,ffffffffc0202d22 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0202d36:	4501                	li	a0,0
}
ffffffffc0202d38:	8082                	ret
    return listelm->prev;
ffffffffc0202d3a:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202d3e:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0202d42:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc0202d46:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0202d4a:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0202d4e:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0202d52:	02c77863          	bgeu	a4,a2,ffffffffc0202d82 <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc0202d56:	071a                	slli	a4,a4,0x6
ffffffffc0202d58:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0202d5a:	41c686bb          	subw	a3,a3,t3
ffffffffc0202d5e:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202d60:	00870613          	addi	a2,a4,8
ffffffffc0202d64:	4689                	li	a3,2
ffffffffc0202d66:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0202d6a:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0202d6e:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc0202d72:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0202d76:	e290                	sd	a2,0(a3)
ffffffffc0202d78:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0202d7c:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0202d7e:	01173c23          	sd	a7,24(a4)
ffffffffc0202d82:	41c8083b          	subw	a6,a6,t3
ffffffffc0202d86:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202d8a:	5775                	li	a4,-3
ffffffffc0202d8c:	17c1                	addi	a5,a5,-16
ffffffffc0202d8e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202d92:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202d94:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202d96:	00003697          	auipc	a3,0x3
ffffffffc0202d9a:	25268693          	addi	a3,a3,594 # ffffffffc0205fe8 <commands+0x13d8>
ffffffffc0202d9e:	00002617          	auipc	a2,0x2
ffffffffc0202da2:	59a60613          	addi	a2,a2,1434 # ffffffffc0205338 <commands+0x728>
ffffffffc0202da6:	06200593          	li	a1,98
ffffffffc0202daa:	00003517          	auipc	a0,0x3
ffffffffc0202dae:	f2e50513          	addi	a0,a0,-210 # ffffffffc0205cd8 <commands+0x10c8>
default_alloc_pages(size_t n) {
ffffffffc0202db2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202db4:	c14fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202db8 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0202db8:	1141                	addi	sp,sp,-16
ffffffffc0202dba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202dbc:	c5f1                	beqz	a1,ffffffffc0202e88 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0202dbe:	00659693          	slli	a3,a1,0x6
ffffffffc0202dc2:	96aa                	add	a3,a3,a0
ffffffffc0202dc4:	87aa                	mv	a5,a0
ffffffffc0202dc6:	00d50f63          	beq	a0,a3,ffffffffc0202de4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202dca:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202dcc:	8b05                	andi	a4,a4,1
ffffffffc0202dce:	cf49                	beqz	a4,ffffffffc0202e68 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0202dd0:	0007a823          	sw	zero,16(a5)
ffffffffc0202dd4:	0007b423          	sd	zero,8(a5)
ffffffffc0202dd8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202ddc:	04078793          	addi	a5,a5,64
ffffffffc0202de0:	fed795e3          	bne	a5,a3,ffffffffc0202dca <default_init_memmap+0x12>
    base->property = n;
ffffffffc0202de4:	2581                	sext.w	a1,a1
ffffffffc0202de6:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202de8:	4789                	li	a5,2
ffffffffc0202dea:	00850713          	addi	a4,a0,8
ffffffffc0202dee:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202df2:	0000e697          	auipc	a3,0xe
ffffffffc0202df6:	70668693          	addi	a3,a3,1798 # ffffffffc02114f8 <free_area>
ffffffffc0202dfa:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202dfc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202dfe:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0202e02:	9db9                	addw	a1,a1,a4
ffffffffc0202e04:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202e06:	04d78a63          	beq	a5,a3,ffffffffc0202e5a <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0202e0a:	fe878713          	addi	a4,a5,-24
ffffffffc0202e0e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202e12:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202e14:	00e56a63          	bltu	a0,a4,ffffffffc0202e28 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0202e18:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202e1a:	02d70263          	beq	a4,a3,ffffffffc0202e3e <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0202e1e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202e20:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0202e24:	fee57ae3          	bgeu	a0,a4,ffffffffc0202e18 <default_init_memmap+0x60>
ffffffffc0202e28:	c199                	beqz	a1,ffffffffc0202e2e <default_init_memmap+0x76>
ffffffffc0202e2a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0202e2e:	6398                	ld	a4,0(a5)
}
ffffffffc0202e30:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202e32:	e390                	sd	a2,0(a5)
ffffffffc0202e34:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202e36:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202e38:	ed18                	sd	a4,24(a0)
ffffffffc0202e3a:	0141                	addi	sp,sp,16
ffffffffc0202e3c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0202e3e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202e40:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0202e42:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0202e44:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0202e46:	00d70663          	beq	a4,a3,ffffffffc0202e52 <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0202e4a:	8832                	mv	a6,a2
ffffffffc0202e4c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0202e4e:	87ba                	mv	a5,a4
ffffffffc0202e50:	bfc1                	j	ffffffffc0202e20 <default_init_memmap+0x68>
}
ffffffffc0202e52:	60a2                	ld	ra,8(sp)
ffffffffc0202e54:	e290                	sd	a2,0(a3)
ffffffffc0202e56:	0141                	addi	sp,sp,16
ffffffffc0202e58:	8082                	ret
ffffffffc0202e5a:	60a2                	ld	ra,8(sp)
ffffffffc0202e5c:	e390                	sd	a2,0(a5)
ffffffffc0202e5e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202e60:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0202e62:	ed1c                	sd	a5,24(a0)
ffffffffc0202e64:	0141                	addi	sp,sp,16
ffffffffc0202e66:	8082                	ret
        assert(PageReserved(p));
ffffffffc0202e68:	00003697          	auipc	a3,0x3
ffffffffc0202e6c:	1b068693          	addi	a3,a3,432 # ffffffffc0206018 <commands+0x1408>
ffffffffc0202e70:	00002617          	auipc	a2,0x2
ffffffffc0202e74:	4c860613          	addi	a2,a2,1224 # ffffffffc0205338 <commands+0x728>
ffffffffc0202e78:	04900593          	li	a1,73
ffffffffc0202e7c:	00003517          	auipc	a0,0x3
ffffffffc0202e80:	e5c50513          	addi	a0,a0,-420 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202e84:	b44fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0202e88:	00003697          	auipc	a3,0x3
ffffffffc0202e8c:	16068693          	addi	a3,a3,352 # ffffffffc0205fe8 <commands+0x13d8>
ffffffffc0202e90:	00002617          	auipc	a2,0x2
ffffffffc0202e94:	4a860613          	addi	a2,a2,1192 # ffffffffc0205338 <commands+0x728>
ffffffffc0202e98:	04600593          	li	a1,70
ffffffffc0202e9c:	00003517          	auipc	a0,0x3
ffffffffc0202ea0:	e3c50513          	addi	a0,a0,-452 # ffffffffc0205cd8 <commands+0x10c8>
ffffffffc0202ea4:	b24fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202ea8 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0202ea8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202eaa:	00002617          	auipc	a2,0x2
ffffffffc0202eae:	6b660613          	addi	a2,a2,1718 # ffffffffc0205560 <commands+0x950>
ffffffffc0202eb2:	06200593          	li	a1,98
ffffffffc0202eb6:	00002517          	auipc	a0,0x2
ffffffffc0202eba:	6ca50513          	addi	a0,a0,1738 # ffffffffc0205580 <commands+0x970>
pa2page(uintptr_t pa) {
ffffffffc0202ebe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202ec0:	b08fd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202ec4 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0202ec4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202ec6:	00003617          	auipc	a2,0x3
ffffffffc0202eca:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0205910 <commands+0xd00>
ffffffffc0202ece:	07400593          	li	a1,116
ffffffffc0202ed2:	00002517          	auipc	a0,0x2
ffffffffc0202ed6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0205580 <commands+0x970>
pte2page(pte_t pte) {
ffffffffc0202eda:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202edc:	aecfd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0202ee0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202ee0:	7139                	addi	sp,sp,-64
ffffffffc0202ee2:	f426                	sd	s1,40(sp)
ffffffffc0202ee4:	f04a                	sd	s2,32(sp)
ffffffffc0202ee6:	ec4e                	sd	s3,24(sp)
ffffffffc0202ee8:	e852                	sd	s4,16(sp)
ffffffffc0202eea:	e456                	sd	s5,8(sp)
ffffffffc0202eec:	e05a                	sd	s6,0(sp)
ffffffffc0202eee:	fc06                	sd	ra,56(sp)
ffffffffc0202ef0:	f822                	sd	s0,48(sp)
ffffffffc0202ef2:	84aa                	mv	s1,a0
ffffffffc0202ef4:	00012917          	auipc	s2,0x12
ffffffffc0202ef8:	6a490913          	addi	s2,s2,1700 # ffffffffc0215598 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202efc:	4a05                	li	s4,1
ffffffffc0202efe:	00012a97          	auipc	s5,0x12
ffffffffc0202f02:	66aa8a93          	addi	s5,s5,1642 # ffffffffc0215568 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202f06:	0005099b          	sext.w	s3,a0
ffffffffc0202f0a:	00012b17          	auipc	s6,0x12
ffffffffc0202f0e:	63eb0b13          	addi	s6,s6,1598 # ffffffffc0215548 <check_mm_struct>
ffffffffc0202f12:	a01d                	j	ffffffffc0202f38 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0202f14:	00093783          	ld	a5,0(s2)
ffffffffc0202f18:	6f9c                	ld	a5,24(a5)
ffffffffc0202f1a:	9782                	jalr	a5
ffffffffc0202f1c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202f1e:	4601                	li	a2,0
ffffffffc0202f20:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202f22:	ec0d                	bnez	s0,ffffffffc0202f5c <alloc_pages+0x7c>
ffffffffc0202f24:	029a6c63          	bltu	s4,s1,ffffffffc0202f5c <alloc_pages+0x7c>
ffffffffc0202f28:	000aa783          	lw	a5,0(s5)
ffffffffc0202f2c:	2781                	sext.w	a5,a5
ffffffffc0202f2e:	c79d                	beqz	a5,ffffffffc0202f5c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202f30:	000b3503          	ld	a0,0(s6)
ffffffffc0202f34:	bf1fe0ef          	jal	ra,ffffffffc0201b24 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f38:	100027f3          	csrr	a5,sstatus
ffffffffc0202f3c:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0202f3e:	8526                	mv	a0,s1
ffffffffc0202f40:	dbf1                	beqz	a5,ffffffffc0202f14 <alloc_pages+0x34>
        intr_disable();
ffffffffc0202f42:	e5efd0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc0202f46:	00093783          	ld	a5,0(s2)
ffffffffc0202f4a:	8526                	mv	a0,s1
ffffffffc0202f4c:	6f9c                	ld	a5,24(a5)
ffffffffc0202f4e:	9782                	jalr	a5
ffffffffc0202f50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202f52:	e48fd0ef          	jal	ra,ffffffffc020059a <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202f56:	4601                	li	a2,0
ffffffffc0202f58:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202f5a:	d469                	beqz	s0,ffffffffc0202f24 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202f5c:	70e2                	ld	ra,56(sp)
ffffffffc0202f5e:	8522                	mv	a0,s0
ffffffffc0202f60:	7442                	ld	s0,48(sp)
ffffffffc0202f62:	74a2                	ld	s1,40(sp)
ffffffffc0202f64:	7902                	ld	s2,32(sp)
ffffffffc0202f66:	69e2                	ld	s3,24(sp)
ffffffffc0202f68:	6a42                	ld	s4,16(sp)
ffffffffc0202f6a:	6aa2                	ld	s5,8(sp)
ffffffffc0202f6c:	6b02                	ld	s6,0(sp)
ffffffffc0202f6e:	6121                	addi	sp,sp,64
ffffffffc0202f70:	8082                	ret

ffffffffc0202f72 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f72:	100027f3          	csrr	a5,sstatus
ffffffffc0202f76:	8b89                	andi	a5,a5,2
ffffffffc0202f78:	e799                	bnez	a5,ffffffffc0202f86 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202f7a:	00012797          	auipc	a5,0x12
ffffffffc0202f7e:	61e7b783          	ld	a5,1566(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0202f82:	739c                	ld	a5,32(a5)
ffffffffc0202f84:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202f86:	1101                	addi	sp,sp,-32
ffffffffc0202f88:	ec06                	sd	ra,24(sp)
ffffffffc0202f8a:	e822                	sd	s0,16(sp)
ffffffffc0202f8c:	e426                	sd	s1,8(sp)
ffffffffc0202f8e:	842a                	mv	s0,a0
ffffffffc0202f90:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202f92:	e0efd0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f96:	00012797          	auipc	a5,0x12
ffffffffc0202f9a:	6027b783          	ld	a5,1538(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0202f9e:	739c                	ld	a5,32(a5)
ffffffffc0202fa0:	85a6                	mv	a1,s1
ffffffffc0202fa2:	8522                	mv	a0,s0
ffffffffc0202fa4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202fa6:	6442                	ld	s0,16(sp)
ffffffffc0202fa8:	60e2                	ld	ra,24(sp)
ffffffffc0202faa:	64a2                	ld	s1,8(sp)
ffffffffc0202fac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202fae:	decfd06f          	j	ffffffffc020059a <intr_enable>

ffffffffc0202fb2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202fb2:	100027f3          	csrr	a5,sstatus
ffffffffc0202fb6:	8b89                	andi	a5,a5,2
ffffffffc0202fb8:	e799                	bnez	a5,ffffffffc0202fc6 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0202fba:	00012797          	auipc	a5,0x12
ffffffffc0202fbe:	5de7b783          	ld	a5,1502(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0202fc2:	779c                	ld	a5,40(a5)
ffffffffc0202fc4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202fc6:	1141                	addi	sp,sp,-16
ffffffffc0202fc8:	e406                	sd	ra,8(sp)
ffffffffc0202fca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202fcc:	dd4fd0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202fd0:	00012797          	auipc	a5,0x12
ffffffffc0202fd4:	5c87b783          	ld	a5,1480(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0202fd8:	779c                	ld	a5,40(a5)
ffffffffc0202fda:	9782                	jalr	a5
ffffffffc0202fdc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202fde:	dbcfd0ef          	jal	ra,ffffffffc020059a <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202fe2:	60a2                	ld	ra,8(sp)
ffffffffc0202fe4:	8522                	mv	a0,s0
ffffffffc0202fe6:	6402                	ld	s0,0(sp)
ffffffffc0202fe8:	0141                	addi	sp,sp,16
ffffffffc0202fea:	8082                	ret

ffffffffc0202fec <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202fec:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202ff0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202ff4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202ff6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202ff8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202ffa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202ffe:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203000:	f04a                	sd	s2,32(sp)
ffffffffc0203002:	ec4e                	sd	s3,24(sp)
ffffffffc0203004:	e852                	sd	s4,16(sp)
ffffffffc0203006:	fc06                	sd	ra,56(sp)
ffffffffc0203008:	f822                	sd	s0,48(sp)
ffffffffc020300a:	e456                	sd	s5,8(sp)
ffffffffc020300c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020300e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0203012:	892e                	mv	s2,a1
ffffffffc0203014:	89b2                	mv	s3,a2
ffffffffc0203016:	00012a17          	auipc	s4,0x12
ffffffffc020301a:	572a0a13          	addi	s4,s4,1394 # ffffffffc0215588 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020301e:	e7b5                	bnez	a5,ffffffffc020308a <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0203020:	12060b63          	beqz	a2,ffffffffc0203156 <get_pte+0x16a>
ffffffffc0203024:	4505                	li	a0,1
ffffffffc0203026:	ebbff0ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc020302a:	842a                	mv	s0,a0
ffffffffc020302c:	12050563          	beqz	a0,ffffffffc0203156 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0203030:	00012b17          	auipc	s6,0x12
ffffffffc0203034:	560b0b13          	addi	s6,s6,1376 # ffffffffc0215590 <pages>
ffffffffc0203038:	000b3503          	ld	a0,0(s6)
ffffffffc020303c:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0203040:	00012a17          	auipc	s4,0x12
ffffffffc0203044:	548a0a13          	addi	s4,s4,1352 # ffffffffc0215588 <npage>
ffffffffc0203048:	40a40533          	sub	a0,s0,a0
ffffffffc020304c:	8519                	srai	a0,a0,0x6
ffffffffc020304e:	9556                	add	a0,a0,s5
ffffffffc0203050:	000a3703          	ld	a4,0(s4)
ffffffffc0203054:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0203058:	4685                	li	a3,1
ffffffffc020305a:	c014                	sw	a3,0(s0)
ffffffffc020305c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020305e:	0532                	slli	a0,a0,0xc
ffffffffc0203060:	14e7f263          	bgeu	a5,a4,ffffffffc02031a4 <get_pte+0x1b8>
ffffffffc0203064:	00012797          	auipc	a5,0x12
ffffffffc0203068:	53c7b783          	ld	a5,1340(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc020306c:	6605                	lui	a2,0x1
ffffffffc020306e:	4581                	li	a1,0
ffffffffc0203070:	953e                	add	a0,a0,a5
ffffffffc0203072:	4c4010ef          	jal	ra,ffffffffc0204536 <memset>
    return page - pages + nbase;
ffffffffc0203076:	000b3683          	ld	a3,0(s6)
ffffffffc020307a:	40d406b3          	sub	a3,s0,a3
ffffffffc020307e:	8699                	srai	a3,a3,0x6
ffffffffc0203080:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203082:	06aa                	slli	a3,a3,0xa
ffffffffc0203084:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0203088:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020308a:	77fd                	lui	a5,0xfffff
ffffffffc020308c:	068a                	slli	a3,a3,0x2
ffffffffc020308e:	000a3703          	ld	a4,0(s4)
ffffffffc0203092:	8efd                	and	a3,a3,a5
ffffffffc0203094:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203098:	0ce7f163          	bgeu	a5,a4,ffffffffc020315a <get_pte+0x16e>
ffffffffc020309c:	00012a97          	auipc	s5,0x12
ffffffffc02030a0:	504a8a93          	addi	s5,s5,1284 # ffffffffc02155a0 <va_pa_offset>
ffffffffc02030a4:	000ab403          	ld	s0,0(s5)
ffffffffc02030a8:	01595793          	srli	a5,s2,0x15
ffffffffc02030ac:	1ff7f793          	andi	a5,a5,511
ffffffffc02030b0:	96a2                	add	a3,a3,s0
ffffffffc02030b2:	00379413          	slli	s0,a5,0x3
ffffffffc02030b6:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc02030b8:	6014                	ld	a3,0(s0)
ffffffffc02030ba:	0016f793          	andi	a5,a3,1
ffffffffc02030be:	e3ad                	bnez	a5,ffffffffc0203120 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02030c0:	08098b63          	beqz	s3,ffffffffc0203156 <get_pte+0x16a>
ffffffffc02030c4:	4505                	li	a0,1
ffffffffc02030c6:	e1bff0ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc02030ca:	84aa                	mv	s1,a0
ffffffffc02030cc:	c549                	beqz	a0,ffffffffc0203156 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02030ce:	00012b17          	auipc	s6,0x12
ffffffffc02030d2:	4c2b0b13          	addi	s6,s6,1218 # ffffffffc0215590 <pages>
ffffffffc02030d6:	000b3503          	ld	a0,0(s6)
ffffffffc02030da:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02030de:	000a3703          	ld	a4,0(s4)
ffffffffc02030e2:	40a48533          	sub	a0,s1,a0
ffffffffc02030e6:	8519                	srai	a0,a0,0x6
ffffffffc02030e8:	954e                	add	a0,a0,s3
ffffffffc02030ea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc02030ee:	4685                	li	a3,1
ffffffffc02030f0:	c094                	sw	a3,0(s1)
ffffffffc02030f2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02030f4:	0532                	slli	a0,a0,0xc
ffffffffc02030f6:	08e7fa63          	bgeu	a5,a4,ffffffffc020318a <get_pte+0x19e>
ffffffffc02030fa:	000ab783          	ld	a5,0(s5)
ffffffffc02030fe:	6605                	lui	a2,0x1
ffffffffc0203100:	4581                	li	a1,0
ffffffffc0203102:	953e                	add	a0,a0,a5
ffffffffc0203104:	432010ef          	jal	ra,ffffffffc0204536 <memset>
    return page - pages + nbase;
ffffffffc0203108:	000b3683          	ld	a3,0(s6)
ffffffffc020310c:	40d486b3          	sub	a3,s1,a3
ffffffffc0203110:	8699                	srai	a3,a3,0x6
ffffffffc0203112:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0203114:	06aa                	slli	a3,a3,0xa
ffffffffc0203116:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020311a:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020311c:	000a3703          	ld	a4,0(s4)
ffffffffc0203120:	068a                	slli	a3,a3,0x2
ffffffffc0203122:	757d                	lui	a0,0xfffff
ffffffffc0203124:	8ee9                	and	a3,a3,a0
ffffffffc0203126:	00c6d793          	srli	a5,a3,0xc
ffffffffc020312a:	04e7f463          	bgeu	a5,a4,ffffffffc0203172 <get_pte+0x186>
ffffffffc020312e:	000ab503          	ld	a0,0(s5)
ffffffffc0203132:	00c95913          	srli	s2,s2,0xc
ffffffffc0203136:	1ff97913          	andi	s2,s2,511
ffffffffc020313a:	96aa                	add	a3,a3,a0
ffffffffc020313c:	00391513          	slli	a0,s2,0x3
ffffffffc0203140:	9536                	add	a0,a0,a3
}
ffffffffc0203142:	70e2                	ld	ra,56(sp)
ffffffffc0203144:	7442                	ld	s0,48(sp)
ffffffffc0203146:	74a2                	ld	s1,40(sp)
ffffffffc0203148:	7902                	ld	s2,32(sp)
ffffffffc020314a:	69e2                	ld	s3,24(sp)
ffffffffc020314c:	6a42                	ld	s4,16(sp)
ffffffffc020314e:	6aa2                	ld	s5,8(sp)
ffffffffc0203150:	6b02                	ld	s6,0(sp)
ffffffffc0203152:	6121                	addi	sp,sp,64
ffffffffc0203154:	8082                	ret
            return NULL;
ffffffffc0203156:	4501                	li	a0,0
ffffffffc0203158:	b7ed                	j	ffffffffc0203142 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020315a:	00002617          	auipc	a2,0x2
ffffffffc020315e:	43660613          	addi	a2,a2,1078 # ffffffffc0205590 <commands+0x980>
ffffffffc0203162:	0e400593          	li	a1,228
ffffffffc0203166:	00003517          	auipc	a0,0x3
ffffffffc020316a:	f1250513          	addi	a0,a0,-238 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc020316e:	85afd0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0203172:	00002617          	auipc	a2,0x2
ffffffffc0203176:	41e60613          	addi	a2,a2,1054 # ffffffffc0205590 <commands+0x980>
ffffffffc020317a:	0ef00593          	li	a1,239
ffffffffc020317e:	00003517          	auipc	a0,0x3
ffffffffc0203182:	efa50513          	addi	a0,a0,-262 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203186:	842fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020318a:	86aa                	mv	a3,a0
ffffffffc020318c:	00002617          	auipc	a2,0x2
ffffffffc0203190:	40460613          	addi	a2,a2,1028 # ffffffffc0205590 <commands+0x980>
ffffffffc0203194:	0ec00593          	li	a1,236
ffffffffc0203198:	00003517          	auipc	a0,0x3
ffffffffc020319c:	ee050513          	addi	a0,a0,-288 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc02031a0:	828fd0ef          	jal	ra,ffffffffc02001c8 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02031a4:	86aa                	mv	a3,a0
ffffffffc02031a6:	00002617          	auipc	a2,0x2
ffffffffc02031aa:	3ea60613          	addi	a2,a2,1002 # ffffffffc0205590 <commands+0x980>
ffffffffc02031ae:	0e100593          	li	a1,225
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	ec650513          	addi	a0,a0,-314 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc02031ba:	80efd0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc02031be <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02031be:	1141                	addi	sp,sp,-16
ffffffffc02031c0:	e022                	sd	s0,0(sp)
ffffffffc02031c2:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02031c4:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02031c6:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02031c8:	e25ff0ef          	jal	ra,ffffffffc0202fec <get_pte>
    if (ptep_store != NULL) {
ffffffffc02031cc:	c011                	beqz	s0,ffffffffc02031d0 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02031ce:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02031d0:	c511                	beqz	a0,ffffffffc02031dc <get_page+0x1e>
ffffffffc02031d2:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02031d4:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02031d6:	0017f713          	andi	a4,a5,1
ffffffffc02031da:	e709                	bnez	a4,ffffffffc02031e4 <get_page+0x26>
}
ffffffffc02031dc:	60a2                	ld	ra,8(sp)
ffffffffc02031de:	6402                	ld	s0,0(sp)
ffffffffc02031e0:	0141                	addi	sp,sp,16
ffffffffc02031e2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02031e4:	078a                	slli	a5,a5,0x2
ffffffffc02031e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031e8:	00012717          	auipc	a4,0x12
ffffffffc02031ec:	3a073703          	ld	a4,928(a4) # ffffffffc0215588 <npage>
ffffffffc02031f0:	00e7ff63          	bgeu	a5,a4,ffffffffc020320e <get_page+0x50>
ffffffffc02031f4:	60a2                	ld	ra,8(sp)
ffffffffc02031f6:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc02031f8:	fff80537          	lui	a0,0xfff80
ffffffffc02031fc:	97aa                	add	a5,a5,a0
ffffffffc02031fe:	079a                	slli	a5,a5,0x6
ffffffffc0203200:	00012517          	auipc	a0,0x12
ffffffffc0203204:	39053503          	ld	a0,912(a0) # ffffffffc0215590 <pages>
ffffffffc0203208:	953e                	add	a0,a0,a5
ffffffffc020320a:	0141                	addi	sp,sp,16
ffffffffc020320c:	8082                	ret
ffffffffc020320e:	c9bff0ef          	jal	ra,ffffffffc0202ea8 <pa2page.part.0>

ffffffffc0203212 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203212:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0203214:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0203216:	ec26                	sd	s1,24(sp)
ffffffffc0203218:	f406                	sd	ra,40(sp)
ffffffffc020321a:	f022                	sd	s0,32(sp)
ffffffffc020321c:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020321e:	dcfff0ef          	jal	ra,ffffffffc0202fec <get_pte>
    if (ptep != NULL) {
ffffffffc0203222:	c511                	beqz	a0,ffffffffc020322e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0203224:	611c                	ld	a5,0(a0)
ffffffffc0203226:	842a                	mv	s0,a0
ffffffffc0203228:	0017f713          	andi	a4,a5,1
ffffffffc020322c:	e711                	bnez	a4,ffffffffc0203238 <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc020322e:	70a2                	ld	ra,40(sp)
ffffffffc0203230:	7402                	ld	s0,32(sp)
ffffffffc0203232:	64e2                	ld	s1,24(sp)
ffffffffc0203234:	6145                	addi	sp,sp,48
ffffffffc0203236:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203238:	078a                	slli	a5,a5,0x2
ffffffffc020323a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020323c:	00012717          	auipc	a4,0x12
ffffffffc0203240:	34c73703          	ld	a4,844(a4) # ffffffffc0215588 <npage>
ffffffffc0203244:	06e7f363          	bgeu	a5,a4,ffffffffc02032aa <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0203248:	fff80537          	lui	a0,0xfff80
ffffffffc020324c:	97aa                	add	a5,a5,a0
ffffffffc020324e:	079a                	slli	a5,a5,0x6
ffffffffc0203250:	00012517          	auipc	a0,0x12
ffffffffc0203254:	34053503          	ld	a0,832(a0) # ffffffffc0215590 <pages>
ffffffffc0203258:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020325a:	411c                	lw	a5,0(a0)
ffffffffc020325c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0203260:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0203262:	cb11                	beqz	a4,ffffffffc0203276 <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0203264:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203268:	12048073          	sfence.vma	s1
}
ffffffffc020326c:	70a2                	ld	ra,40(sp)
ffffffffc020326e:	7402                	ld	s0,32(sp)
ffffffffc0203270:	64e2                	ld	s1,24(sp)
ffffffffc0203272:	6145                	addi	sp,sp,48
ffffffffc0203274:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203276:	100027f3          	csrr	a5,sstatus
ffffffffc020327a:	8b89                	andi	a5,a5,2
ffffffffc020327c:	eb89                	bnez	a5,ffffffffc020328e <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc020327e:	00012797          	auipc	a5,0x12
ffffffffc0203282:	31a7b783          	ld	a5,794(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0203286:	739c                	ld	a5,32(a5)
ffffffffc0203288:	4585                	li	a1,1
ffffffffc020328a:	9782                	jalr	a5
    if (flag) {
ffffffffc020328c:	bfe1                	j	ffffffffc0203264 <page_remove+0x52>
        intr_disable();
ffffffffc020328e:	e42a                	sd	a0,8(sp)
ffffffffc0203290:	b10fd0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc0203294:	00012797          	auipc	a5,0x12
ffffffffc0203298:	3047b783          	ld	a5,772(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc020329c:	739c                	ld	a5,32(a5)
ffffffffc020329e:	6522                	ld	a0,8(sp)
ffffffffc02032a0:	4585                	li	a1,1
ffffffffc02032a2:	9782                	jalr	a5
        intr_enable();
ffffffffc02032a4:	af6fd0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc02032a8:	bf75                	j	ffffffffc0203264 <page_remove+0x52>
ffffffffc02032aa:	bffff0ef          	jal	ra,ffffffffc0202ea8 <pa2page.part.0>

ffffffffc02032ae <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02032ae:	7139                	addi	sp,sp,-64
ffffffffc02032b0:	e852                	sd	s4,16(sp)
ffffffffc02032b2:	8a32                	mv	s4,a2
ffffffffc02032b4:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02032b6:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02032b8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02032ba:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc02032bc:	f426                	sd	s1,40(sp)
ffffffffc02032be:	fc06                	sd	ra,56(sp)
ffffffffc02032c0:	f04a                	sd	s2,32(sp)
ffffffffc02032c2:	ec4e                	sd	s3,24(sp)
ffffffffc02032c4:	e456                	sd	s5,8(sp)
ffffffffc02032c6:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02032c8:	d25ff0ef          	jal	ra,ffffffffc0202fec <get_pte>
    if (ptep == NULL) {
ffffffffc02032cc:	c961                	beqz	a0,ffffffffc020339c <page_insert+0xee>
    page->ref += 1;
ffffffffc02032ce:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02032d0:	611c                	ld	a5,0(a0)
ffffffffc02032d2:	89aa                	mv	s3,a0
ffffffffc02032d4:	0016871b          	addiw	a4,a3,1
ffffffffc02032d8:	c018                	sw	a4,0(s0)
ffffffffc02032da:	0017f713          	andi	a4,a5,1
ffffffffc02032de:	ef05                	bnez	a4,ffffffffc0203316 <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02032e0:	00012717          	auipc	a4,0x12
ffffffffc02032e4:	2b073703          	ld	a4,688(a4) # ffffffffc0215590 <pages>
ffffffffc02032e8:	8c19                	sub	s0,s0,a4
ffffffffc02032ea:	000807b7          	lui	a5,0x80
ffffffffc02032ee:	8419                	srai	s0,s0,0x6
ffffffffc02032f0:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02032f2:	042a                	slli	s0,s0,0xa
ffffffffc02032f4:	8cc1                	or	s1,s1,s0
ffffffffc02032f6:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02032fa:	0099b023          	sd	s1,0(s3) # 80000 <kern_entry-0xffffffffc0180000>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032fe:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc0203302:	4501                	li	a0,0
}
ffffffffc0203304:	70e2                	ld	ra,56(sp)
ffffffffc0203306:	7442                	ld	s0,48(sp)
ffffffffc0203308:	74a2                	ld	s1,40(sp)
ffffffffc020330a:	7902                	ld	s2,32(sp)
ffffffffc020330c:	69e2                	ld	s3,24(sp)
ffffffffc020330e:	6a42                	ld	s4,16(sp)
ffffffffc0203310:	6aa2                	ld	s5,8(sp)
ffffffffc0203312:	6121                	addi	sp,sp,64
ffffffffc0203314:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0203316:	078a                	slli	a5,a5,0x2
ffffffffc0203318:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020331a:	00012717          	auipc	a4,0x12
ffffffffc020331e:	26e73703          	ld	a4,622(a4) # ffffffffc0215588 <npage>
ffffffffc0203322:	06e7ff63          	bgeu	a5,a4,ffffffffc02033a0 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203326:	00012a97          	auipc	s5,0x12
ffffffffc020332a:	26aa8a93          	addi	s5,s5,618 # ffffffffc0215590 <pages>
ffffffffc020332e:	000ab703          	ld	a4,0(s5)
ffffffffc0203332:	fff80937          	lui	s2,0xfff80
ffffffffc0203336:	993e                	add	s2,s2,a5
ffffffffc0203338:	091a                	slli	s2,s2,0x6
ffffffffc020333a:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc020333c:	01240c63          	beq	s0,s2,ffffffffc0203354 <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0203340:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fd6aa3c>
ffffffffc0203344:	fff7869b          	addiw	a3,a5,-1
ffffffffc0203348:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc020334c:	c691                	beqz	a3,ffffffffc0203358 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020334e:	120a0073          	sfence.vma	s4
}
ffffffffc0203352:	bf59                	j	ffffffffc02032e8 <page_insert+0x3a>
ffffffffc0203354:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0203356:	bf49                	j	ffffffffc02032e8 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203358:	100027f3          	csrr	a5,sstatus
ffffffffc020335c:	8b89                	andi	a5,a5,2
ffffffffc020335e:	ef91                	bnez	a5,ffffffffc020337a <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0203360:	00012797          	auipc	a5,0x12
ffffffffc0203364:	2387b783          	ld	a5,568(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0203368:	739c                	ld	a5,32(a5)
ffffffffc020336a:	4585                	li	a1,1
ffffffffc020336c:	854a                	mv	a0,s2
ffffffffc020336e:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0203370:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203374:	120a0073          	sfence.vma	s4
ffffffffc0203378:	bf85                	j	ffffffffc02032e8 <page_insert+0x3a>
        intr_disable();
ffffffffc020337a:	a26fd0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020337e:	00012797          	auipc	a5,0x12
ffffffffc0203382:	21a7b783          	ld	a5,538(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0203386:	739c                	ld	a5,32(a5)
ffffffffc0203388:	4585                	li	a1,1
ffffffffc020338a:	854a                	mv	a0,s2
ffffffffc020338c:	9782                	jalr	a5
        intr_enable();
ffffffffc020338e:	a0cfd0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0203392:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203396:	120a0073          	sfence.vma	s4
ffffffffc020339a:	b7b9                	j	ffffffffc02032e8 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020339c:	5571                	li	a0,-4
ffffffffc020339e:	b79d                	j	ffffffffc0203304 <page_insert+0x56>
ffffffffc02033a0:	b09ff0ef          	jal	ra,ffffffffc0202ea8 <pa2page.part.0>

ffffffffc02033a4 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02033a4:	00003797          	auipc	a5,0x3
ffffffffc02033a8:	c9c78793          	addi	a5,a5,-868 # ffffffffc0206040 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02033ac:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc02033ae:	711d                	addi	sp,sp,-96
ffffffffc02033b0:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02033b2:	00003517          	auipc	a0,0x3
ffffffffc02033b6:	cd650513          	addi	a0,a0,-810 # ffffffffc0206088 <default_pmm_manager+0x48>
    pmm_manager = &default_pmm_manager;
ffffffffc02033ba:	00012b97          	auipc	s7,0x12
ffffffffc02033be:	1deb8b93          	addi	s7,s7,478 # ffffffffc0215598 <pmm_manager>
void pmm_init(void) {
ffffffffc02033c2:	ec86                	sd	ra,88(sp)
ffffffffc02033c4:	e4a6                	sd	s1,72(sp)
ffffffffc02033c6:	fc4e                	sd	s3,56(sp)
ffffffffc02033c8:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02033ca:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02033ce:	e8a2                	sd	s0,80(sp)
ffffffffc02033d0:	e0ca                	sd	s2,64(sp)
ffffffffc02033d2:	f852                	sd	s4,48(sp)
ffffffffc02033d4:	f456                	sd	s5,40(sp)
ffffffffc02033d6:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02033d8:	cf5fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pmm_manager->init();
ffffffffc02033dc:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02033e0:	00012997          	auipc	s3,0x12
ffffffffc02033e4:	1c098993          	addi	s3,s3,448 # ffffffffc02155a0 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02033e8:	00012497          	auipc	s1,0x12
ffffffffc02033ec:	1a048493          	addi	s1,s1,416 # ffffffffc0215588 <npage>
    pmm_manager->init();
ffffffffc02033f0:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02033f2:	00012b17          	auipc	s6,0x12
ffffffffc02033f6:	19eb0b13          	addi	s6,s6,414 # ffffffffc0215590 <pages>
    pmm_manager->init();
ffffffffc02033fa:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02033fc:	57f5                	li	a5,-3
ffffffffc02033fe:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0203400:	00003517          	auipc	a0,0x3
ffffffffc0203404:	ca050513          	addi	a0,a0,-864 # ffffffffc02060a0 <default_pmm_manager+0x60>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203408:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc020340c:	cc1fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203410:	46c5                	li	a3,17
ffffffffc0203412:	06ee                	slli	a3,a3,0x1b
ffffffffc0203414:	40100613          	li	a2,1025
ffffffffc0203418:	07e005b7          	lui	a1,0x7e00
ffffffffc020341c:	16fd                	addi	a3,a3,-1
ffffffffc020341e:	0656                	slli	a2,a2,0x15
ffffffffc0203420:	00003517          	auipc	a0,0x3
ffffffffc0203424:	c9850513          	addi	a0,a0,-872 # ffffffffc02060b8 <default_pmm_manager+0x78>
ffffffffc0203428:	ca5fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020342c:	777d                	lui	a4,0xfffff
ffffffffc020342e:	00013797          	auipc	a5,0x13
ffffffffc0203432:	19578793          	addi	a5,a5,405 # ffffffffc02165c3 <end+0xfff>
ffffffffc0203436:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0203438:	00088737          	lui	a4,0x88
ffffffffc020343c:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020343e:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0203442:	4701                	li	a4,0
ffffffffc0203444:	4585                	li	a1,1
ffffffffc0203446:	fff80837          	lui	a6,0xfff80
ffffffffc020344a:	a019                	j	ffffffffc0203450 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc020344c:	000b3783          	ld	a5,0(s6)
ffffffffc0203450:	00671693          	slli	a3,a4,0x6
ffffffffc0203454:	97b6                	add	a5,a5,a3
ffffffffc0203456:	07a1                	addi	a5,a5,8
ffffffffc0203458:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020345c:	6090                	ld	a2,0(s1)
ffffffffc020345e:	0705                	addi	a4,a4,1
ffffffffc0203460:	010607b3          	add	a5,a2,a6
ffffffffc0203464:	fef764e3          	bltu	a4,a5,ffffffffc020344c <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203468:	000b3503          	ld	a0,0(s6)
ffffffffc020346c:	079a                	slli	a5,a5,0x6
ffffffffc020346e:	c0200737          	lui	a4,0xc0200
ffffffffc0203472:	00f506b3          	add	a3,a0,a5
ffffffffc0203476:	60e6e563          	bltu	a3,a4,ffffffffc0203a80 <pmm_init+0x6dc>
ffffffffc020347a:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc020347e:	4745                	li	a4,17
ffffffffc0203480:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203482:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0203484:	4ae6e563          	bltu	a3,a4,ffffffffc020392e <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203488:	00003517          	auipc	a0,0x3
ffffffffc020348c:	c5850513          	addi	a0,a0,-936 # ffffffffc02060e0 <default_pmm_manager+0xa0>
ffffffffc0203490:	c3dfc0ef          	jal	ra,ffffffffc02000cc <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0203494:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0203498:	00012917          	auipc	s2,0x12
ffffffffc020349c:	0e890913          	addi	s2,s2,232 # ffffffffc0215580 <boot_pgdir>
    pmm_manager->check();
ffffffffc02034a0:	7b9c                	ld	a5,48(a5)
ffffffffc02034a2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02034a4:	00003517          	auipc	a0,0x3
ffffffffc02034a8:	c5450513          	addi	a0,a0,-940 # ffffffffc02060f8 <default_pmm_manager+0xb8>
ffffffffc02034ac:	c21fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02034b0:	00006697          	auipc	a3,0x6
ffffffffc02034b4:	b5068693          	addi	a3,a3,-1200 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc02034b8:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02034bc:	c02007b7          	lui	a5,0xc0200
ffffffffc02034c0:	5cf6ec63          	bltu	a3,a5,ffffffffc0203a98 <pmm_init+0x6f4>
ffffffffc02034c4:	0009b783          	ld	a5,0(s3)
ffffffffc02034c8:	8e9d                	sub	a3,a3,a5
ffffffffc02034ca:	00012797          	auipc	a5,0x12
ffffffffc02034ce:	0ad7b723          	sd	a3,174(a5) # ffffffffc0215578 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02034d2:	100027f3          	csrr	a5,sstatus
ffffffffc02034d6:	8b89                	andi	a5,a5,2
ffffffffc02034d8:	48079263          	bnez	a5,ffffffffc020395c <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02034dc:	000bb783          	ld	a5,0(s7)
ffffffffc02034e0:	779c                	ld	a5,40(a5)
ffffffffc02034e2:	9782                	jalr	a5
ffffffffc02034e4:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02034e6:	6098                	ld	a4,0(s1)
ffffffffc02034e8:	c80007b7          	lui	a5,0xc8000
ffffffffc02034ec:	83b1                	srli	a5,a5,0xc
ffffffffc02034ee:	5ee7e163          	bltu	a5,a4,ffffffffc0203ad0 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02034f2:	00093503          	ld	a0,0(s2)
ffffffffc02034f6:	5a050d63          	beqz	a0,ffffffffc0203ab0 <pmm_init+0x70c>
ffffffffc02034fa:	03451793          	slli	a5,a0,0x34
ffffffffc02034fe:	5a079963          	bnez	a5,ffffffffc0203ab0 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203502:	4601                	li	a2,0
ffffffffc0203504:	4581                	li	a1,0
ffffffffc0203506:	cb9ff0ef          	jal	ra,ffffffffc02031be <get_page>
ffffffffc020350a:	62051563          	bnez	a0,ffffffffc0203b34 <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc020350e:	4505                	li	a0,1
ffffffffc0203510:	9d1ff0ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0203514:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203516:	00093503          	ld	a0,0(s2)
ffffffffc020351a:	4681                	li	a3,0
ffffffffc020351c:	4601                	li	a2,0
ffffffffc020351e:	85d2                	mv	a1,s4
ffffffffc0203520:	d8fff0ef          	jal	ra,ffffffffc02032ae <page_insert>
ffffffffc0203524:	5e051863          	bnez	a0,ffffffffc0203b14 <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203528:	00093503          	ld	a0,0(s2)
ffffffffc020352c:	4601                	li	a2,0
ffffffffc020352e:	4581                	li	a1,0
ffffffffc0203530:	abdff0ef          	jal	ra,ffffffffc0202fec <get_pte>
ffffffffc0203534:	5c050063          	beqz	a0,ffffffffc0203af4 <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0203538:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020353a:	0017f713          	andi	a4,a5,1
ffffffffc020353e:	5a070963          	beqz	a4,ffffffffc0203af0 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0203542:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203544:	078a                	slli	a5,a5,0x2
ffffffffc0203546:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203548:	52e7fa63          	bgeu	a5,a4,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020354c:	000b3683          	ld	a3,0(s6)
ffffffffc0203550:	fff80637          	lui	a2,0xfff80
ffffffffc0203554:	97b2                	add	a5,a5,a2
ffffffffc0203556:	079a                	slli	a5,a5,0x6
ffffffffc0203558:	97b6                	add	a5,a5,a3
ffffffffc020355a:	10fa16e3          	bne	s4,a5,ffffffffc0203e66 <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc020355e:	000a2683          	lw	a3,0(s4)
ffffffffc0203562:	4785                	li	a5,1
ffffffffc0203564:	12f69de3          	bne	a3,a5,ffffffffc0203e9e <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203568:	00093503          	ld	a0,0(s2)
ffffffffc020356c:	77fd                	lui	a5,0xfffff
ffffffffc020356e:	6114                	ld	a3,0(a0)
ffffffffc0203570:	068a                	slli	a3,a3,0x2
ffffffffc0203572:	8efd                	and	a3,a3,a5
ffffffffc0203574:	00c6d613          	srli	a2,a3,0xc
ffffffffc0203578:	10e677e3          	bgeu	a2,a4,ffffffffc0203e86 <pmm_init+0xae2>
ffffffffc020357c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203580:	96e2                	add	a3,a3,s8
ffffffffc0203582:	0006ba83          	ld	s5,0(a3)
ffffffffc0203586:	0a8a                	slli	s5,s5,0x2
ffffffffc0203588:	00fafab3          	and	s5,s5,a5
ffffffffc020358c:	00cad793          	srli	a5,s5,0xc
ffffffffc0203590:	62e7f263          	bgeu	a5,a4,ffffffffc0203bb4 <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203594:	4601                	li	a2,0
ffffffffc0203596:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203598:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020359a:	a53ff0ef          	jal	ra,ffffffffc0202fec <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020359e:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02035a0:	5f551a63          	bne	a0,s5,ffffffffc0203b94 <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc02035a4:	4505                	li	a0,1
ffffffffc02035a6:	93bff0ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc02035aa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02035ac:	00093503          	ld	a0,0(s2)
ffffffffc02035b0:	46d1                	li	a3,20
ffffffffc02035b2:	6605                	lui	a2,0x1
ffffffffc02035b4:	85d6                	mv	a1,s5
ffffffffc02035b6:	cf9ff0ef          	jal	ra,ffffffffc02032ae <page_insert>
ffffffffc02035ba:	58051d63          	bnez	a0,ffffffffc0203b54 <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02035be:	00093503          	ld	a0,0(s2)
ffffffffc02035c2:	4601                	li	a2,0
ffffffffc02035c4:	6585                	lui	a1,0x1
ffffffffc02035c6:	a27ff0ef          	jal	ra,ffffffffc0202fec <get_pte>
ffffffffc02035ca:	0e050ae3          	beqz	a0,ffffffffc0203ebe <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc02035ce:	611c                	ld	a5,0(a0)
ffffffffc02035d0:	0107f713          	andi	a4,a5,16
ffffffffc02035d4:	6e070d63          	beqz	a4,ffffffffc0203cce <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02035d8:	8b91                	andi	a5,a5,4
ffffffffc02035da:	6a078a63          	beqz	a5,ffffffffc0203c8e <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02035de:	00093503          	ld	a0,0(s2)
ffffffffc02035e2:	611c                	ld	a5,0(a0)
ffffffffc02035e4:	8bc1                	andi	a5,a5,16
ffffffffc02035e6:	68078463          	beqz	a5,ffffffffc0203c6e <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02035ea:	000aa703          	lw	a4,0(s5)
ffffffffc02035ee:	4785                	li	a5,1
ffffffffc02035f0:	58f71263          	bne	a4,a5,ffffffffc0203b74 <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02035f4:	4681                	li	a3,0
ffffffffc02035f6:	6605                	lui	a2,0x1
ffffffffc02035f8:	85d2                	mv	a1,s4
ffffffffc02035fa:	cb5ff0ef          	jal	ra,ffffffffc02032ae <page_insert>
ffffffffc02035fe:	62051863          	bnez	a0,ffffffffc0203c2e <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc0203602:	000a2703          	lw	a4,0(s4)
ffffffffc0203606:	4789                	li	a5,2
ffffffffc0203608:	60f71363          	bne	a4,a5,ffffffffc0203c0e <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc020360c:	000aa783          	lw	a5,0(s5)
ffffffffc0203610:	5c079f63          	bnez	a5,ffffffffc0203bee <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203614:	00093503          	ld	a0,0(s2)
ffffffffc0203618:	4601                	li	a2,0
ffffffffc020361a:	6585                	lui	a1,0x1
ffffffffc020361c:	9d1ff0ef          	jal	ra,ffffffffc0202fec <get_pte>
ffffffffc0203620:	5a050763          	beqz	a0,ffffffffc0203bce <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc0203624:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203626:	00177793          	andi	a5,a4,1
ffffffffc020362a:	4c078363          	beqz	a5,ffffffffc0203af0 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020362e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203630:	00271793          	slli	a5,a4,0x2
ffffffffc0203634:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203636:	44d7f363          	bgeu	a5,a3,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020363a:	000b3683          	ld	a3,0(s6)
ffffffffc020363e:	fff80637          	lui	a2,0xfff80
ffffffffc0203642:	97b2                	add	a5,a5,a2
ffffffffc0203644:	079a                	slli	a5,a5,0x6
ffffffffc0203646:	97b6                	add	a5,a5,a3
ffffffffc0203648:	6efa1363          	bne	s4,a5,ffffffffc0203d2e <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc020364c:	8b41                	andi	a4,a4,16
ffffffffc020364e:	6c071063          	bnez	a4,ffffffffc0203d0e <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc0203652:	00093503          	ld	a0,0(s2)
ffffffffc0203656:	4581                	li	a1,0
ffffffffc0203658:	bbbff0ef          	jal	ra,ffffffffc0203212 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020365c:	000a2703          	lw	a4,0(s4)
ffffffffc0203660:	4785                	li	a5,1
ffffffffc0203662:	68f71663          	bne	a4,a5,ffffffffc0203cee <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc0203666:	000aa783          	lw	a5,0(s5)
ffffffffc020366a:	74079e63          	bnez	a5,ffffffffc0203dc6 <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc020366e:	00093503          	ld	a0,0(s2)
ffffffffc0203672:	6585                	lui	a1,0x1
ffffffffc0203674:	b9fff0ef          	jal	ra,ffffffffc0203212 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0203678:	000a2783          	lw	a5,0(s4)
ffffffffc020367c:	72079563          	bnez	a5,ffffffffc0203da6 <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0203680:	000aa783          	lw	a5,0(s5)
ffffffffc0203684:	70079163          	bnez	a5,ffffffffc0203d86 <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203688:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020368c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020368e:	000a3683          	ld	a3,0(s4)
ffffffffc0203692:	068a                	slli	a3,a3,0x2
ffffffffc0203694:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203696:	3ee6f363          	bgeu	a3,a4,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc020369a:	fff807b7          	lui	a5,0xfff80
ffffffffc020369e:	000b3503          	ld	a0,0(s6)
ffffffffc02036a2:	96be                	add	a3,a3,a5
ffffffffc02036a4:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc02036a6:	00d507b3          	add	a5,a0,a3
ffffffffc02036aa:	4390                	lw	a2,0(a5)
ffffffffc02036ac:	4785                	li	a5,1
ffffffffc02036ae:	6af61c63          	bne	a2,a5,ffffffffc0203d66 <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc02036b2:	8699                	srai	a3,a3,0x6
ffffffffc02036b4:	000805b7          	lui	a1,0x80
ffffffffc02036b8:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02036ba:	00c69613          	slli	a2,a3,0xc
ffffffffc02036be:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02036c0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02036c2:	68e67663          	bgeu	a2,a4,ffffffffc0203d4e <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02036c6:	0009b603          	ld	a2,0(s3)
ffffffffc02036ca:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02036cc:	629c                	ld	a5,0(a3)
ffffffffc02036ce:	078a                	slli	a5,a5,0x2
ffffffffc02036d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036d2:	3ae7f563          	bgeu	a5,a4,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02036d6:	8f8d                	sub	a5,a5,a1
ffffffffc02036d8:	079a                	slli	a5,a5,0x6
ffffffffc02036da:	953e                	add	a0,a0,a5
ffffffffc02036dc:	100027f3          	csrr	a5,sstatus
ffffffffc02036e0:	8b89                	andi	a5,a5,2
ffffffffc02036e2:	2c079763          	bnez	a5,ffffffffc02039b0 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02036e6:	000bb783          	ld	a5,0(s7)
ffffffffc02036ea:	4585                	li	a1,1
ffffffffc02036ec:	739c                	ld	a5,32(a5)
ffffffffc02036ee:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02036f4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f6:	078a                	slli	a5,a5,0x2
ffffffffc02036f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fa:	38e7f163          	bgeu	a5,a4,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02036fe:	000b3503          	ld	a0,0(s6)
ffffffffc0203702:	fff80737          	lui	a4,0xfff80
ffffffffc0203706:	97ba                	add	a5,a5,a4
ffffffffc0203708:	079a                	slli	a5,a5,0x6
ffffffffc020370a:	953e                	add	a0,a0,a5
ffffffffc020370c:	100027f3          	csrr	a5,sstatus
ffffffffc0203710:	8b89                	andi	a5,a5,2
ffffffffc0203712:	28079363          	bnez	a5,ffffffffc0203998 <pmm_init+0x5f4>
ffffffffc0203716:	000bb783          	ld	a5,0(s7)
ffffffffc020371a:	4585                	li	a1,1
ffffffffc020371c:	739c                	ld	a5,32(a5)
ffffffffc020371e:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203720:	00093783          	ld	a5,0(s2)
ffffffffc0203724:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fd6aa3c>
  asm volatile("sfence.vma");
ffffffffc0203728:	12000073          	sfence.vma
ffffffffc020372c:	100027f3          	csrr	a5,sstatus
ffffffffc0203730:	8b89                	andi	a5,a5,2
ffffffffc0203732:	24079963          	bnez	a5,ffffffffc0203984 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203736:	000bb783          	ld	a5,0(s7)
ffffffffc020373a:	779c                	ld	a5,40(a5)
ffffffffc020373c:	9782                	jalr	a5
ffffffffc020373e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203740:	71441363          	bne	s0,s4,ffffffffc0203e46 <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0203744:	00003517          	auipc	a0,0x3
ffffffffc0203748:	c9c50513          	addi	a0,a0,-868 # ffffffffc02063e0 <default_pmm_manager+0x3a0>
ffffffffc020374c:	981fc0ef          	jal	ra,ffffffffc02000cc <cprintf>
ffffffffc0203750:	100027f3          	csrr	a5,sstatus
ffffffffc0203754:	8b89                	andi	a5,a5,2
ffffffffc0203756:	20079d63          	bnez	a5,ffffffffc0203970 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc020375a:	000bb783          	ld	a5,0(s7)
ffffffffc020375e:	779c                	ld	a5,40(a5)
ffffffffc0203760:	9782                	jalr	a5
ffffffffc0203762:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203764:	6098                	ld	a4,0(s1)
ffffffffc0203766:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020376a:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020376c:	00c71793          	slli	a5,a4,0xc
ffffffffc0203770:	6a05                	lui	s4,0x1
ffffffffc0203772:	02f47c63          	bgeu	s0,a5,ffffffffc02037aa <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203776:	00c45793          	srli	a5,s0,0xc
ffffffffc020377a:	00093503          	ld	a0,0(s2)
ffffffffc020377e:	2ee7f263          	bgeu	a5,a4,ffffffffc0203a62 <pmm_init+0x6be>
ffffffffc0203782:	0009b583          	ld	a1,0(s3)
ffffffffc0203786:	4601                	li	a2,0
ffffffffc0203788:	95a2                	add	a1,a1,s0
ffffffffc020378a:	863ff0ef          	jal	ra,ffffffffc0202fec <get_pte>
ffffffffc020378e:	2a050a63          	beqz	a0,ffffffffc0203a42 <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203792:	611c                	ld	a5,0(a0)
ffffffffc0203794:	078a                	slli	a5,a5,0x2
ffffffffc0203796:	0157f7b3          	and	a5,a5,s5
ffffffffc020379a:	28879463          	bne	a5,s0,ffffffffc0203a22 <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020379e:	6098                	ld	a4,0(s1)
ffffffffc02037a0:	9452                	add	s0,s0,s4
ffffffffc02037a2:	00c71793          	slli	a5,a4,0xc
ffffffffc02037a6:	fcf468e3          	bltu	s0,a5,ffffffffc0203776 <pmm_init+0x3d2>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02037aa:	00093783          	ld	a5,0(s2)
ffffffffc02037ae:	639c                	ld	a5,0(a5)
ffffffffc02037b0:	66079b63          	bnez	a5,ffffffffc0203e26 <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc02037b4:	4505                	li	a0,1
ffffffffc02037b6:	f2aff0ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc02037ba:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02037bc:	00093503          	ld	a0,0(s2)
ffffffffc02037c0:	4699                	li	a3,6
ffffffffc02037c2:	10000613          	li	a2,256
ffffffffc02037c6:	85d6                	mv	a1,s5
ffffffffc02037c8:	ae7ff0ef          	jal	ra,ffffffffc02032ae <page_insert>
ffffffffc02037cc:	62051d63          	bnez	a0,ffffffffc0203e06 <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc02037d0:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fde9a3c>
ffffffffc02037d4:	4785                	li	a5,1
ffffffffc02037d6:	60f71863          	bne	a4,a5,ffffffffc0203de6 <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02037da:	00093503          	ld	a0,0(s2)
ffffffffc02037de:	6405                	lui	s0,0x1
ffffffffc02037e0:	4699                	li	a3,6
ffffffffc02037e2:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc02037e6:	85d6                	mv	a1,s5
ffffffffc02037e8:	ac7ff0ef          	jal	ra,ffffffffc02032ae <page_insert>
ffffffffc02037ec:	46051163          	bnez	a0,ffffffffc0203c4e <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02037f0:	000aa703          	lw	a4,0(s5)
ffffffffc02037f4:	4789                	li	a5,2
ffffffffc02037f6:	72f71463          	bne	a4,a5,ffffffffc0203f1e <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02037fa:	00003597          	auipc	a1,0x3
ffffffffc02037fe:	d1e58593          	addi	a1,a1,-738 # ffffffffc0206518 <default_pmm_manager+0x4d8>
ffffffffc0203802:	10000513          	li	a0,256
ffffffffc0203806:	4eb000ef          	jal	ra,ffffffffc02044f0 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020380a:	10040593          	addi	a1,s0,256
ffffffffc020380e:	10000513          	li	a0,256
ffffffffc0203812:	4f1000ef          	jal	ra,ffffffffc0204502 <strcmp>
ffffffffc0203816:	6e051463          	bnez	a0,ffffffffc0203efe <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc020381a:	000b3683          	ld	a3,0(s6)
ffffffffc020381e:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0203822:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc0203824:	40da86b3          	sub	a3,s5,a3
ffffffffc0203828:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020382a:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc020382c:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020382e:	8031                	srli	s0,s0,0xc
ffffffffc0203830:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203834:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203836:	50f77c63          	bgeu	a4,a5,ffffffffc0203d4e <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020383a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020383e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203842:	96be                	add	a3,a3,a5
ffffffffc0203844:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203848:	473000ef          	jal	ra,ffffffffc02044ba <strlen>
ffffffffc020384c:	68051963          	bnez	a0,ffffffffc0203ede <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203850:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203854:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203856:	000a3683          	ld	a3,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020385a:	068a                	slli	a3,a3,0x2
ffffffffc020385c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020385e:	20f6ff63          	bgeu	a3,a5,ffffffffc0203a7c <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0203862:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203864:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203866:	4ef47463          	bgeu	s0,a5,ffffffffc0203d4e <pmm_init+0x9aa>
ffffffffc020386a:	0009b403          	ld	s0,0(s3)
ffffffffc020386e:	9436                	add	s0,s0,a3
ffffffffc0203870:	100027f3          	csrr	a5,sstatus
ffffffffc0203874:	8b89                	andi	a5,a5,2
ffffffffc0203876:	18079b63          	bnez	a5,ffffffffc0203a0c <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc020387a:	000bb783          	ld	a5,0(s7)
ffffffffc020387e:	4585                	li	a1,1
ffffffffc0203880:	8556                	mv	a0,s5
ffffffffc0203882:	739c                	ld	a5,32(a5)
ffffffffc0203884:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203886:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203888:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020388a:	078a                	slli	a5,a5,0x2
ffffffffc020388c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020388e:	1ee7f763          	bgeu	a5,a4,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0203892:	000b3503          	ld	a0,0(s6)
ffffffffc0203896:	fff80737          	lui	a4,0xfff80
ffffffffc020389a:	97ba                	add	a5,a5,a4
ffffffffc020389c:	079a                	slli	a5,a5,0x6
ffffffffc020389e:	953e                	add	a0,a0,a5
ffffffffc02038a0:	100027f3          	csrr	a5,sstatus
ffffffffc02038a4:	8b89                	andi	a5,a5,2
ffffffffc02038a6:	14079763          	bnez	a5,ffffffffc02039f4 <pmm_init+0x650>
ffffffffc02038aa:	000bb783          	ld	a5,0(s7)
ffffffffc02038ae:	4585                	li	a1,1
ffffffffc02038b0:	739c                	ld	a5,32(a5)
ffffffffc02038b2:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02038b4:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02038b8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02038ba:	078a                	slli	a5,a5,0x2
ffffffffc02038bc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02038be:	1ae7ff63          	bgeu	a5,a4,ffffffffc0203a7c <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02038c2:	000b3503          	ld	a0,0(s6)
ffffffffc02038c6:	fff80737          	lui	a4,0xfff80
ffffffffc02038ca:	97ba                	add	a5,a5,a4
ffffffffc02038cc:	079a                	slli	a5,a5,0x6
ffffffffc02038ce:	953e                	add	a0,a0,a5
ffffffffc02038d0:	100027f3          	csrr	a5,sstatus
ffffffffc02038d4:	8b89                	andi	a5,a5,2
ffffffffc02038d6:	10079363          	bnez	a5,ffffffffc02039dc <pmm_init+0x638>
ffffffffc02038da:	000bb783          	ld	a5,0(s7)
ffffffffc02038de:	4585                	li	a1,1
ffffffffc02038e0:	739c                	ld	a5,32(a5)
ffffffffc02038e2:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02038e4:	00093783          	ld	a5,0(s2)
ffffffffc02038e8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02038ec:	12000073          	sfence.vma
ffffffffc02038f0:	100027f3          	csrr	a5,sstatus
ffffffffc02038f4:	8b89                	andi	a5,a5,2
ffffffffc02038f6:	0c079963          	bnez	a5,ffffffffc02039c8 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc02038fa:	000bb783          	ld	a5,0(s7)
ffffffffc02038fe:	779c                	ld	a5,40(a5)
ffffffffc0203900:	9782                	jalr	a5
ffffffffc0203902:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203904:	3a8c1563          	bne	s8,s0,ffffffffc0203cae <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0203908:	00003517          	auipc	a0,0x3
ffffffffc020390c:	c8850513          	addi	a0,a0,-888 # ffffffffc0206590 <default_pmm_manager+0x550>
ffffffffc0203910:	fbcfc0ef          	jal	ra,ffffffffc02000cc <cprintf>
}
ffffffffc0203914:	6446                	ld	s0,80(sp)
ffffffffc0203916:	60e6                	ld	ra,88(sp)
ffffffffc0203918:	64a6                	ld	s1,72(sp)
ffffffffc020391a:	6906                	ld	s2,64(sp)
ffffffffc020391c:	79e2                	ld	s3,56(sp)
ffffffffc020391e:	7a42                	ld	s4,48(sp)
ffffffffc0203920:	7aa2                	ld	s5,40(sp)
ffffffffc0203922:	7b02                	ld	s6,32(sp)
ffffffffc0203924:	6be2                	ld	s7,24(sp)
ffffffffc0203926:	6c42                	ld	s8,16(sp)
ffffffffc0203928:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc020392a:	d1cfe06f          	j	ffffffffc0201e46 <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020392e:	6785                	lui	a5,0x1
ffffffffc0203930:	17fd                	addi	a5,a5,-1
ffffffffc0203932:	96be                	add	a3,a3,a5
ffffffffc0203934:	77fd                	lui	a5,0xfffff
ffffffffc0203936:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0203938:	00c7d693          	srli	a3,a5,0xc
ffffffffc020393c:	14c6f063          	bgeu	a3,a2,ffffffffc0203a7c <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0203940:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0203944:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0203946:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc020394a:	6a10                	ld	a2,16(a2)
ffffffffc020394c:	069a                	slli	a3,a3,0x6
ffffffffc020394e:	00c7d593          	srli	a1,a5,0xc
ffffffffc0203952:	9536                	add	a0,a0,a3
ffffffffc0203954:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0203956:	0009b583          	ld	a1,0(s3)
}
ffffffffc020395a:	b63d                	j	ffffffffc0203488 <pmm_init+0xe4>
        intr_disable();
ffffffffc020395c:	c45fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0203960:	000bb783          	ld	a5,0(s7)
ffffffffc0203964:	779c                	ld	a5,40(a5)
ffffffffc0203966:	9782                	jalr	a5
ffffffffc0203968:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020396a:	c31fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc020396e:	bea5                	j	ffffffffc02034e6 <pmm_init+0x142>
        intr_disable();
ffffffffc0203970:	c31fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc0203974:	000bb783          	ld	a5,0(s7)
ffffffffc0203978:	779c                	ld	a5,40(a5)
ffffffffc020397a:	9782                	jalr	a5
ffffffffc020397c:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc020397e:	c1dfc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0203982:	b3cd                	j	ffffffffc0203764 <pmm_init+0x3c0>
        intr_disable();
ffffffffc0203984:	c1dfc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc0203988:	000bb783          	ld	a5,0(s7)
ffffffffc020398c:	779c                	ld	a5,40(a5)
ffffffffc020398e:	9782                	jalr	a5
ffffffffc0203990:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203992:	c09fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0203996:	b36d                	j	ffffffffc0203740 <pmm_init+0x39c>
ffffffffc0203998:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020399a:	c07fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020399e:	000bb783          	ld	a5,0(s7)
ffffffffc02039a2:	6522                	ld	a0,8(sp)
ffffffffc02039a4:	4585                	li	a1,1
ffffffffc02039a6:	739c                	ld	a5,32(a5)
ffffffffc02039a8:	9782                	jalr	a5
        intr_enable();
ffffffffc02039aa:	bf1fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc02039ae:	bb8d                	j	ffffffffc0203720 <pmm_init+0x37c>
ffffffffc02039b0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02039b2:	beffc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc02039b6:	000bb783          	ld	a5,0(s7)
ffffffffc02039ba:	6522                	ld	a0,8(sp)
ffffffffc02039bc:	4585                	li	a1,1
ffffffffc02039be:	739c                	ld	a5,32(a5)
ffffffffc02039c0:	9782                	jalr	a5
        intr_enable();
ffffffffc02039c2:	bd9fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc02039c6:	b32d                	j	ffffffffc02036f0 <pmm_init+0x34c>
        intr_disable();
ffffffffc02039c8:	bd9fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02039cc:	000bb783          	ld	a5,0(s7)
ffffffffc02039d0:	779c                	ld	a5,40(a5)
ffffffffc02039d2:	9782                	jalr	a5
ffffffffc02039d4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02039d6:	bc5fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc02039da:	b72d                	j	ffffffffc0203904 <pmm_init+0x560>
ffffffffc02039dc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02039de:	bc3fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02039e2:	000bb783          	ld	a5,0(s7)
ffffffffc02039e6:	6522                	ld	a0,8(sp)
ffffffffc02039e8:	4585                	li	a1,1
ffffffffc02039ea:	739c                	ld	a5,32(a5)
ffffffffc02039ec:	9782                	jalr	a5
        intr_enable();
ffffffffc02039ee:	badfc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc02039f2:	bdcd                	j	ffffffffc02038e4 <pmm_init+0x540>
ffffffffc02039f4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02039f6:	babfc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc02039fa:	000bb783          	ld	a5,0(s7)
ffffffffc02039fe:	6522                	ld	a0,8(sp)
ffffffffc0203a00:	4585                	li	a1,1
ffffffffc0203a02:	739c                	ld	a5,32(a5)
ffffffffc0203a04:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a06:	b95fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0203a0a:	b56d                	j	ffffffffc02038b4 <pmm_init+0x510>
        intr_disable();
ffffffffc0203a0c:	b95fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
ffffffffc0203a10:	000bb783          	ld	a5,0(s7)
ffffffffc0203a14:	4585                	li	a1,1
ffffffffc0203a16:	8556                	mv	a0,s5
ffffffffc0203a18:	739c                	ld	a5,32(a5)
ffffffffc0203a1a:	9782                	jalr	a5
        intr_enable();
ffffffffc0203a1c:	b7ffc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0203a20:	b59d                	j	ffffffffc0203886 <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203a22:	00003697          	auipc	a3,0x3
ffffffffc0203a26:	a1e68693          	addi	a3,a3,-1506 # ffffffffc0206440 <default_pmm_manager+0x400>
ffffffffc0203a2a:	00002617          	auipc	a2,0x2
ffffffffc0203a2e:	90e60613          	addi	a2,a2,-1778 # ffffffffc0205338 <commands+0x728>
ffffffffc0203a32:	19e00593          	li	a1,414
ffffffffc0203a36:	00002517          	auipc	a0,0x2
ffffffffc0203a3a:	64250513          	addi	a0,a0,1602 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203a3e:	f8afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203a42:	00003697          	auipc	a3,0x3
ffffffffc0203a46:	9be68693          	addi	a3,a3,-1602 # ffffffffc0206400 <default_pmm_manager+0x3c0>
ffffffffc0203a4a:	00002617          	auipc	a2,0x2
ffffffffc0203a4e:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0205338 <commands+0x728>
ffffffffc0203a52:	19d00593          	li	a1,413
ffffffffc0203a56:	00002517          	auipc	a0,0x2
ffffffffc0203a5a:	62250513          	addi	a0,a0,1570 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203a5e:	f6afc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203a62:	86a2                	mv	a3,s0
ffffffffc0203a64:	00002617          	auipc	a2,0x2
ffffffffc0203a68:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0205590 <commands+0x980>
ffffffffc0203a6c:	19d00593          	li	a1,413
ffffffffc0203a70:	00002517          	auipc	a0,0x2
ffffffffc0203a74:	60850513          	addi	a0,a0,1544 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203a78:	f50fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203a7c:	c2cff0ef          	jal	ra,ffffffffc0202ea8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203a80:	00002617          	auipc	a2,0x2
ffffffffc0203a84:	06060613          	addi	a2,a2,96 # ffffffffc0205ae0 <commands+0xed0>
ffffffffc0203a88:	07f00593          	li	a1,127
ffffffffc0203a8c:	00002517          	auipc	a0,0x2
ffffffffc0203a90:	5ec50513          	addi	a0,a0,1516 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203a94:	f34fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203a98:	00002617          	auipc	a2,0x2
ffffffffc0203a9c:	04860613          	addi	a2,a2,72 # ffffffffc0205ae0 <commands+0xed0>
ffffffffc0203aa0:	0c300593          	li	a1,195
ffffffffc0203aa4:	00002517          	auipc	a0,0x2
ffffffffc0203aa8:	5d450513          	addi	a0,a0,1492 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203aac:	f1cfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203ab0:	00002697          	auipc	a3,0x2
ffffffffc0203ab4:	68868693          	addi	a3,a3,1672 # ffffffffc0206138 <default_pmm_manager+0xf8>
ffffffffc0203ab8:	00002617          	auipc	a2,0x2
ffffffffc0203abc:	88060613          	addi	a2,a2,-1920 # ffffffffc0205338 <commands+0x728>
ffffffffc0203ac0:	16100593          	li	a1,353
ffffffffc0203ac4:	00002517          	auipc	a0,0x2
ffffffffc0203ac8:	5b450513          	addi	a0,a0,1460 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203acc:	efcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203ad0:	00002697          	auipc	a3,0x2
ffffffffc0203ad4:	64868693          	addi	a3,a3,1608 # ffffffffc0206118 <default_pmm_manager+0xd8>
ffffffffc0203ad8:	00002617          	auipc	a2,0x2
ffffffffc0203adc:	86060613          	addi	a2,a2,-1952 # ffffffffc0205338 <commands+0x728>
ffffffffc0203ae0:	16000593          	li	a1,352
ffffffffc0203ae4:	00002517          	auipc	a0,0x2
ffffffffc0203ae8:	59450513          	addi	a0,a0,1428 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203aec:	edcfc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc0203af0:	bd4ff0ef          	jal	ra,ffffffffc0202ec4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203af4:	00002697          	auipc	a3,0x2
ffffffffc0203af8:	6d468693          	addi	a3,a3,1748 # ffffffffc02061c8 <default_pmm_manager+0x188>
ffffffffc0203afc:	00002617          	auipc	a2,0x2
ffffffffc0203b00:	83c60613          	addi	a2,a2,-1988 # ffffffffc0205338 <commands+0x728>
ffffffffc0203b04:	16900593          	li	a1,361
ffffffffc0203b08:	00002517          	auipc	a0,0x2
ffffffffc0203b0c:	57050513          	addi	a0,a0,1392 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203b10:	eb8fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203b14:	00002697          	auipc	a3,0x2
ffffffffc0203b18:	68468693          	addi	a3,a3,1668 # ffffffffc0206198 <default_pmm_manager+0x158>
ffffffffc0203b1c:	00002617          	auipc	a2,0x2
ffffffffc0203b20:	81c60613          	addi	a2,a2,-2020 # ffffffffc0205338 <commands+0x728>
ffffffffc0203b24:	16600593          	li	a1,358
ffffffffc0203b28:	00002517          	auipc	a0,0x2
ffffffffc0203b2c:	55050513          	addi	a0,a0,1360 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203b30:	e98fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0203b34:	00002697          	auipc	a3,0x2
ffffffffc0203b38:	63c68693          	addi	a3,a3,1596 # ffffffffc0206170 <default_pmm_manager+0x130>
ffffffffc0203b3c:	00001617          	auipc	a2,0x1
ffffffffc0203b40:	7fc60613          	addi	a2,a2,2044 # ffffffffc0205338 <commands+0x728>
ffffffffc0203b44:	16200593          	li	a1,354
ffffffffc0203b48:	00002517          	auipc	a0,0x2
ffffffffc0203b4c:	53050513          	addi	a0,a0,1328 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203b50:	e78fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203b54:	00002697          	auipc	a3,0x2
ffffffffc0203b58:	6fc68693          	addi	a3,a3,1788 # ffffffffc0206250 <default_pmm_manager+0x210>
ffffffffc0203b5c:	00001617          	auipc	a2,0x1
ffffffffc0203b60:	7dc60613          	addi	a2,a2,2012 # ffffffffc0205338 <commands+0x728>
ffffffffc0203b64:	17200593          	li	a1,370
ffffffffc0203b68:	00002517          	auipc	a0,0x2
ffffffffc0203b6c:	51050513          	addi	a0,a0,1296 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203b70:	e58fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203b74:	00002697          	auipc	a3,0x2
ffffffffc0203b78:	77c68693          	addi	a3,a3,1916 # ffffffffc02062f0 <default_pmm_manager+0x2b0>
ffffffffc0203b7c:	00001617          	auipc	a2,0x1
ffffffffc0203b80:	7bc60613          	addi	a2,a2,1980 # ffffffffc0205338 <commands+0x728>
ffffffffc0203b84:	17700593          	li	a1,375
ffffffffc0203b88:	00002517          	auipc	a0,0x2
ffffffffc0203b8c:	4f050513          	addi	a0,a0,1264 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203b90:	e38fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203b94:	00002697          	auipc	a3,0x2
ffffffffc0203b98:	69468693          	addi	a3,a3,1684 # ffffffffc0206228 <default_pmm_manager+0x1e8>
ffffffffc0203b9c:	00001617          	auipc	a2,0x1
ffffffffc0203ba0:	79c60613          	addi	a2,a2,1948 # ffffffffc0205338 <commands+0x728>
ffffffffc0203ba4:	16f00593          	li	a1,367
ffffffffc0203ba8:	00002517          	auipc	a0,0x2
ffffffffc0203bac:	4d050513          	addi	a0,a0,1232 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203bb0:	e18fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203bb4:	86d6                	mv	a3,s5
ffffffffc0203bb6:	00002617          	auipc	a2,0x2
ffffffffc0203bba:	9da60613          	addi	a2,a2,-1574 # ffffffffc0205590 <commands+0x980>
ffffffffc0203bbe:	16e00593          	li	a1,366
ffffffffc0203bc2:	00002517          	auipc	a0,0x2
ffffffffc0203bc6:	4b650513          	addi	a0,a0,1206 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203bca:	dfefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203bce:	00002697          	auipc	a3,0x2
ffffffffc0203bd2:	6ba68693          	addi	a3,a3,1722 # ffffffffc0206288 <default_pmm_manager+0x248>
ffffffffc0203bd6:	00001617          	auipc	a2,0x1
ffffffffc0203bda:	76260613          	addi	a2,a2,1890 # ffffffffc0205338 <commands+0x728>
ffffffffc0203bde:	17c00593          	li	a1,380
ffffffffc0203be2:	00002517          	auipc	a0,0x2
ffffffffc0203be6:	49650513          	addi	a0,a0,1174 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203bea:	ddefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203bee:	00002697          	auipc	a3,0x2
ffffffffc0203bf2:	76268693          	addi	a3,a3,1890 # ffffffffc0206350 <default_pmm_manager+0x310>
ffffffffc0203bf6:	00001617          	auipc	a2,0x1
ffffffffc0203bfa:	74260613          	addi	a2,a2,1858 # ffffffffc0205338 <commands+0x728>
ffffffffc0203bfe:	17b00593          	li	a1,379
ffffffffc0203c02:	00002517          	auipc	a0,0x2
ffffffffc0203c06:	47650513          	addi	a0,a0,1142 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203c0a:	dbefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203c0e:	00002697          	auipc	a3,0x2
ffffffffc0203c12:	72a68693          	addi	a3,a3,1834 # ffffffffc0206338 <default_pmm_manager+0x2f8>
ffffffffc0203c16:	00001617          	auipc	a2,0x1
ffffffffc0203c1a:	72260613          	addi	a2,a2,1826 # ffffffffc0205338 <commands+0x728>
ffffffffc0203c1e:	17a00593          	li	a1,378
ffffffffc0203c22:	00002517          	auipc	a0,0x2
ffffffffc0203c26:	45650513          	addi	a0,a0,1110 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203c2a:	d9efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203c2e:	00002697          	auipc	a3,0x2
ffffffffc0203c32:	6da68693          	addi	a3,a3,1754 # ffffffffc0206308 <default_pmm_manager+0x2c8>
ffffffffc0203c36:	00001617          	auipc	a2,0x1
ffffffffc0203c3a:	70260613          	addi	a2,a2,1794 # ffffffffc0205338 <commands+0x728>
ffffffffc0203c3e:	17900593          	li	a1,377
ffffffffc0203c42:	00002517          	auipc	a0,0x2
ffffffffc0203c46:	43650513          	addi	a0,a0,1078 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203c4a:	d7efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203c4e:	00003697          	auipc	a3,0x3
ffffffffc0203c52:	87268693          	addi	a3,a3,-1934 # ffffffffc02064c0 <default_pmm_manager+0x480>
ffffffffc0203c56:	00001617          	auipc	a2,0x1
ffffffffc0203c5a:	6e260613          	addi	a2,a2,1762 # ffffffffc0205338 <commands+0x728>
ffffffffc0203c5e:	1a700593          	li	a1,423
ffffffffc0203c62:	00002517          	auipc	a0,0x2
ffffffffc0203c66:	41650513          	addi	a0,a0,1046 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203c6a:	d5efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203c6e:	00002697          	auipc	a3,0x2
ffffffffc0203c72:	66a68693          	addi	a3,a3,1642 # ffffffffc02062d8 <default_pmm_manager+0x298>
ffffffffc0203c76:	00001617          	auipc	a2,0x1
ffffffffc0203c7a:	6c260613          	addi	a2,a2,1730 # ffffffffc0205338 <commands+0x728>
ffffffffc0203c7e:	17600593          	li	a1,374
ffffffffc0203c82:	00002517          	auipc	a0,0x2
ffffffffc0203c86:	3f650513          	addi	a0,a0,1014 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203c8a:	d3efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203c8e:	00002697          	auipc	a3,0x2
ffffffffc0203c92:	63a68693          	addi	a3,a3,1594 # ffffffffc02062c8 <default_pmm_manager+0x288>
ffffffffc0203c96:	00001617          	auipc	a2,0x1
ffffffffc0203c9a:	6a260613          	addi	a2,a2,1698 # ffffffffc0205338 <commands+0x728>
ffffffffc0203c9e:	17500593          	li	a1,373
ffffffffc0203ca2:	00002517          	auipc	a0,0x2
ffffffffc0203ca6:	3d650513          	addi	a0,a0,982 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203caa:	d1efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203cae:	00002697          	auipc	a3,0x2
ffffffffc0203cb2:	71268693          	addi	a3,a3,1810 # ffffffffc02063c0 <default_pmm_manager+0x380>
ffffffffc0203cb6:	00001617          	auipc	a2,0x1
ffffffffc0203cba:	68260613          	addi	a2,a2,1666 # ffffffffc0205338 <commands+0x728>
ffffffffc0203cbe:	1b800593          	li	a1,440
ffffffffc0203cc2:	00002517          	auipc	a0,0x2
ffffffffc0203cc6:	3b650513          	addi	a0,a0,950 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203cca:	cfefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203cce:	00002697          	auipc	a3,0x2
ffffffffc0203cd2:	5ea68693          	addi	a3,a3,1514 # ffffffffc02062b8 <default_pmm_manager+0x278>
ffffffffc0203cd6:	00001617          	auipc	a2,0x1
ffffffffc0203cda:	66260613          	addi	a2,a2,1634 # ffffffffc0205338 <commands+0x728>
ffffffffc0203cde:	17400593          	li	a1,372
ffffffffc0203ce2:	00002517          	auipc	a0,0x2
ffffffffc0203ce6:	39650513          	addi	a0,a0,918 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203cea:	cdefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203cee:	00002697          	auipc	a3,0x2
ffffffffc0203cf2:	52268693          	addi	a3,a3,1314 # ffffffffc0206210 <default_pmm_manager+0x1d0>
ffffffffc0203cf6:	00001617          	auipc	a2,0x1
ffffffffc0203cfa:	64260613          	addi	a2,a2,1602 # ffffffffc0205338 <commands+0x728>
ffffffffc0203cfe:	18100593          	li	a1,385
ffffffffc0203d02:	00002517          	auipc	a0,0x2
ffffffffc0203d06:	37650513          	addi	a0,a0,886 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203d0a:	cbefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203d0e:	00002697          	auipc	a3,0x2
ffffffffc0203d12:	65a68693          	addi	a3,a3,1626 # ffffffffc0206368 <default_pmm_manager+0x328>
ffffffffc0203d16:	00001617          	auipc	a2,0x1
ffffffffc0203d1a:	62260613          	addi	a2,a2,1570 # ffffffffc0205338 <commands+0x728>
ffffffffc0203d1e:	17e00593          	li	a1,382
ffffffffc0203d22:	00002517          	auipc	a0,0x2
ffffffffc0203d26:	35650513          	addi	a0,a0,854 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203d2a:	c9efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203d2e:	00002697          	auipc	a3,0x2
ffffffffc0203d32:	4ca68693          	addi	a3,a3,1226 # ffffffffc02061f8 <default_pmm_manager+0x1b8>
ffffffffc0203d36:	00001617          	auipc	a2,0x1
ffffffffc0203d3a:	60260613          	addi	a2,a2,1538 # ffffffffc0205338 <commands+0x728>
ffffffffc0203d3e:	17d00593          	li	a1,381
ffffffffc0203d42:	00002517          	auipc	a0,0x2
ffffffffc0203d46:	33650513          	addi	a0,a0,822 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203d4a:	c7efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d4e:	00002617          	auipc	a2,0x2
ffffffffc0203d52:	84260613          	addi	a2,a2,-1982 # ffffffffc0205590 <commands+0x980>
ffffffffc0203d56:	06900593          	li	a1,105
ffffffffc0203d5a:	00002517          	auipc	a0,0x2
ffffffffc0203d5e:	82650513          	addi	a0,a0,-2010 # ffffffffc0205580 <commands+0x970>
ffffffffc0203d62:	c66fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203d66:	00002697          	auipc	a3,0x2
ffffffffc0203d6a:	63268693          	addi	a3,a3,1586 # ffffffffc0206398 <default_pmm_manager+0x358>
ffffffffc0203d6e:	00001617          	auipc	a2,0x1
ffffffffc0203d72:	5ca60613          	addi	a2,a2,1482 # ffffffffc0205338 <commands+0x728>
ffffffffc0203d76:	18800593          	li	a1,392
ffffffffc0203d7a:	00002517          	auipc	a0,0x2
ffffffffc0203d7e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203d82:	c46fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203d86:	00002697          	auipc	a3,0x2
ffffffffc0203d8a:	5ca68693          	addi	a3,a3,1482 # ffffffffc0206350 <default_pmm_manager+0x310>
ffffffffc0203d8e:	00001617          	auipc	a2,0x1
ffffffffc0203d92:	5aa60613          	addi	a2,a2,1450 # ffffffffc0205338 <commands+0x728>
ffffffffc0203d96:	18600593          	li	a1,390
ffffffffc0203d9a:	00002517          	auipc	a0,0x2
ffffffffc0203d9e:	2de50513          	addi	a0,a0,734 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203da2:	c26fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203da6:	00002697          	auipc	a3,0x2
ffffffffc0203daa:	5da68693          	addi	a3,a3,1498 # ffffffffc0206380 <default_pmm_manager+0x340>
ffffffffc0203dae:	00001617          	auipc	a2,0x1
ffffffffc0203db2:	58a60613          	addi	a2,a2,1418 # ffffffffc0205338 <commands+0x728>
ffffffffc0203db6:	18500593          	li	a1,389
ffffffffc0203dba:	00002517          	auipc	a0,0x2
ffffffffc0203dbe:	2be50513          	addi	a0,a0,702 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203dc2:	c06fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203dc6:	00002697          	auipc	a3,0x2
ffffffffc0203dca:	58a68693          	addi	a3,a3,1418 # ffffffffc0206350 <default_pmm_manager+0x310>
ffffffffc0203dce:	00001617          	auipc	a2,0x1
ffffffffc0203dd2:	56a60613          	addi	a2,a2,1386 # ffffffffc0205338 <commands+0x728>
ffffffffc0203dd6:	18200593          	li	a1,386
ffffffffc0203dda:	00002517          	auipc	a0,0x2
ffffffffc0203dde:	29e50513          	addi	a0,a0,670 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203de2:	be6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203de6:	00002697          	auipc	a3,0x2
ffffffffc0203dea:	6c268693          	addi	a3,a3,1730 # ffffffffc02064a8 <default_pmm_manager+0x468>
ffffffffc0203dee:	00001617          	auipc	a2,0x1
ffffffffc0203df2:	54a60613          	addi	a2,a2,1354 # ffffffffc0205338 <commands+0x728>
ffffffffc0203df6:	1a600593          	li	a1,422
ffffffffc0203dfa:	00002517          	auipc	a0,0x2
ffffffffc0203dfe:	27e50513          	addi	a0,a0,638 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203e02:	bc6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203e06:	00002697          	auipc	a3,0x2
ffffffffc0203e0a:	66a68693          	addi	a3,a3,1642 # ffffffffc0206470 <default_pmm_manager+0x430>
ffffffffc0203e0e:	00001617          	auipc	a2,0x1
ffffffffc0203e12:	52a60613          	addi	a2,a2,1322 # ffffffffc0205338 <commands+0x728>
ffffffffc0203e16:	1a500593          	li	a1,421
ffffffffc0203e1a:	00002517          	auipc	a0,0x2
ffffffffc0203e1e:	25e50513          	addi	a0,a0,606 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203e22:	ba6fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203e26:	00002697          	auipc	a3,0x2
ffffffffc0203e2a:	63268693          	addi	a3,a3,1586 # ffffffffc0206458 <default_pmm_manager+0x418>
ffffffffc0203e2e:	00001617          	auipc	a2,0x1
ffffffffc0203e32:	50a60613          	addi	a2,a2,1290 # ffffffffc0205338 <commands+0x728>
ffffffffc0203e36:	1a100593          	li	a1,417
ffffffffc0203e3a:	00002517          	auipc	a0,0x2
ffffffffc0203e3e:	23e50513          	addi	a0,a0,574 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203e42:	b86fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203e46:	00002697          	auipc	a3,0x2
ffffffffc0203e4a:	57a68693          	addi	a3,a3,1402 # ffffffffc02063c0 <default_pmm_manager+0x380>
ffffffffc0203e4e:	00001617          	auipc	a2,0x1
ffffffffc0203e52:	4ea60613          	addi	a2,a2,1258 # ffffffffc0205338 <commands+0x728>
ffffffffc0203e56:	19000593          	li	a1,400
ffffffffc0203e5a:	00002517          	auipc	a0,0x2
ffffffffc0203e5e:	21e50513          	addi	a0,a0,542 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203e62:	b66fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203e66:	00002697          	auipc	a3,0x2
ffffffffc0203e6a:	39268693          	addi	a3,a3,914 # ffffffffc02061f8 <default_pmm_manager+0x1b8>
ffffffffc0203e6e:	00001617          	auipc	a2,0x1
ffffffffc0203e72:	4ca60613          	addi	a2,a2,1226 # ffffffffc0205338 <commands+0x728>
ffffffffc0203e76:	16a00593          	li	a1,362
ffffffffc0203e7a:	00002517          	auipc	a0,0x2
ffffffffc0203e7e:	1fe50513          	addi	a0,a0,510 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203e82:	b46fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203e86:	00001617          	auipc	a2,0x1
ffffffffc0203e8a:	70a60613          	addi	a2,a2,1802 # ffffffffc0205590 <commands+0x980>
ffffffffc0203e8e:	16d00593          	li	a1,365
ffffffffc0203e92:	00002517          	auipc	a0,0x2
ffffffffc0203e96:	1e650513          	addi	a0,a0,486 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203e9a:	b2efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203e9e:	00002697          	auipc	a3,0x2
ffffffffc0203ea2:	37268693          	addi	a3,a3,882 # ffffffffc0206210 <default_pmm_manager+0x1d0>
ffffffffc0203ea6:	00001617          	auipc	a2,0x1
ffffffffc0203eaa:	49260613          	addi	a2,a2,1170 # ffffffffc0205338 <commands+0x728>
ffffffffc0203eae:	16b00593          	li	a1,363
ffffffffc0203eb2:	00002517          	auipc	a0,0x2
ffffffffc0203eb6:	1c650513          	addi	a0,a0,454 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203eba:	b0efc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203ebe:	00002697          	auipc	a3,0x2
ffffffffc0203ec2:	3ca68693          	addi	a3,a3,970 # ffffffffc0206288 <default_pmm_manager+0x248>
ffffffffc0203ec6:	00001617          	auipc	a2,0x1
ffffffffc0203eca:	47260613          	addi	a2,a2,1138 # ffffffffc0205338 <commands+0x728>
ffffffffc0203ece:	17300593          	li	a1,371
ffffffffc0203ed2:	00002517          	auipc	a0,0x2
ffffffffc0203ed6:	1a650513          	addi	a0,a0,422 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203eda:	aeefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203ede:	00002697          	auipc	a3,0x2
ffffffffc0203ee2:	68a68693          	addi	a3,a3,1674 # ffffffffc0206568 <default_pmm_manager+0x528>
ffffffffc0203ee6:	00001617          	auipc	a2,0x1
ffffffffc0203eea:	45260613          	addi	a2,a2,1106 # ffffffffc0205338 <commands+0x728>
ffffffffc0203eee:	1af00593          	li	a1,431
ffffffffc0203ef2:	00002517          	auipc	a0,0x2
ffffffffc0203ef6:	18650513          	addi	a0,a0,390 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203efa:	acefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203efe:	00002697          	auipc	a3,0x2
ffffffffc0203f02:	63268693          	addi	a3,a3,1586 # ffffffffc0206530 <default_pmm_manager+0x4f0>
ffffffffc0203f06:	00001617          	auipc	a2,0x1
ffffffffc0203f0a:	43260613          	addi	a2,a2,1074 # ffffffffc0205338 <commands+0x728>
ffffffffc0203f0e:	1ac00593          	li	a1,428
ffffffffc0203f12:	00002517          	auipc	a0,0x2
ffffffffc0203f16:	16650513          	addi	a0,a0,358 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203f1a:	aaefc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203f1e:	00002697          	auipc	a3,0x2
ffffffffc0203f22:	5e268693          	addi	a3,a3,1506 # ffffffffc0206500 <default_pmm_manager+0x4c0>
ffffffffc0203f26:	00001617          	auipc	a2,0x1
ffffffffc0203f2a:	41260613          	addi	a2,a2,1042 # ffffffffc0205338 <commands+0x728>
ffffffffc0203f2e:	1a800593          	li	a1,424
ffffffffc0203f32:	00002517          	auipc	a0,0x2
ffffffffc0203f36:	14650513          	addi	a0,a0,326 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203f3a:	a8efc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0203f3e <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203f3e:	12058073          	sfence.vma	a1
}
ffffffffc0203f42:	8082                	ret

ffffffffc0203f44 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203f44:	7179                	addi	sp,sp,-48
ffffffffc0203f46:	e84a                	sd	s2,16(sp)
ffffffffc0203f48:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203f4a:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203f4c:	f022                	sd	s0,32(sp)
ffffffffc0203f4e:	ec26                	sd	s1,24(sp)
ffffffffc0203f50:	e44e                	sd	s3,8(sp)
ffffffffc0203f52:	f406                	sd	ra,40(sp)
ffffffffc0203f54:	84ae                	mv	s1,a1
ffffffffc0203f56:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203f58:	f89fe0ef          	jal	ra,ffffffffc0202ee0 <alloc_pages>
ffffffffc0203f5c:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203f5e:	cd09                	beqz	a0,ffffffffc0203f78 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203f60:	85aa                	mv	a1,a0
ffffffffc0203f62:	86ce                	mv	a3,s3
ffffffffc0203f64:	8626                	mv	a2,s1
ffffffffc0203f66:	854a                	mv	a0,s2
ffffffffc0203f68:	b46ff0ef          	jal	ra,ffffffffc02032ae <page_insert>
ffffffffc0203f6c:	ed21                	bnez	a0,ffffffffc0203fc4 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203f6e:	00011797          	auipc	a5,0x11
ffffffffc0203f72:	5fa7a783          	lw	a5,1530(a5) # ffffffffc0215568 <swap_init_ok>
ffffffffc0203f76:	eb89                	bnez	a5,ffffffffc0203f88 <pgdir_alloc_page+0x44>
}
ffffffffc0203f78:	70a2                	ld	ra,40(sp)
ffffffffc0203f7a:	8522                	mv	a0,s0
ffffffffc0203f7c:	7402                	ld	s0,32(sp)
ffffffffc0203f7e:	64e2                	ld	s1,24(sp)
ffffffffc0203f80:	6942                	ld	s2,16(sp)
ffffffffc0203f82:	69a2                	ld	s3,8(sp)
ffffffffc0203f84:	6145                	addi	sp,sp,48
ffffffffc0203f86:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203f88:	4681                	li	a3,0
ffffffffc0203f8a:	8622                	mv	a2,s0
ffffffffc0203f8c:	85a6                	mv	a1,s1
ffffffffc0203f8e:	00011517          	auipc	a0,0x11
ffffffffc0203f92:	5ba53503          	ld	a0,1466(a0) # ffffffffc0215548 <check_mm_struct>
ffffffffc0203f96:	b83fd0ef          	jal	ra,ffffffffc0201b18 <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203f9a:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203f9c:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0203f9e:	4785                	li	a5,1
ffffffffc0203fa0:	fcf70ce3          	beq	a4,a5,ffffffffc0203f78 <pgdir_alloc_page+0x34>
ffffffffc0203fa4:	00002697          	auipc	a3,0x2
ffffffffc0203fa8:	60c68693          	addi	a3,a3,1548 # ffffffffc02065b0 <default_pmm_manager+0x570>
ffffffffc0203fac:	00001617          	auipc	a2,0x1
ffffffffc0203fb0:	38c60613          	addi	a2,a2,908 # ffffffffc0205338 <commands+0x728>
ffffffffc0203fb4:	14800593          	li	a1,328
ffffffffc0203fb8:	00002517          	auipc	a0,0x2
ffffffffc0203fbc:	0c050513          	addi	a0,a0,192 # ffffffffc0206078 <default_pmm_manager+0x38>
ffffffffc0203fc0:	a08fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203fc4:	100027f3          	csrr	a5,sstatus
ffffffffc0203fc8:	8b89                	andi	a5,a5,2
ffffffffc0203fca:	eb99                	bnez	a5,ffffffffc0203fe0 <pgdir_alloc_page+0x9c>
        pmm_manager->free_pages(base, n);
ffffffffc0203fcc:	00011797          	auipc	a5,0x11
ffffffffc0203fd0:	5cc7b783          	ld	a5,1484(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0203fd4:	739c                	ld	a5,32(a5)
ffffffffc0203fd6:	8522                	mv	a0,s0
ffffffffc0203fd8:	4585                	li	a1,1
ffffffffc0203fda:	9782                	jalr	a5
            return NULL;
ffffffffc0203fdc:	4401                	li	s0,0
ffffffffc0203fde:	bf69                	j	ffffffffc0203f78 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203fe0:	dc0fc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203fe4:	00011797          	auipc	a5,0x11
ffffffffc0203fe8:	5b47b783          	ld	a5,1460(a5) # ffffffffc0215598 <pmm_manager>
ffffffffc0203fec:	739c                	ld	a5,32(a5)
ffffffffc0203fee:	8522                	mv	a0,s0
ffffffffc0203ff0:	4585                	li	a1,1
ffffffffc0203ff2:	9782                	jalr	a5
            return NULL;
ffffffffc0203ff4:	4401                	li	s0,0
        intr_enable();
ffffffffc0203ff6:	da4fc0ef          	jal	ra,ffffffffc020059a <intr_enable>
ffffffffc0203ffa:	bfbd                	j	ffffffffc0203f78 <pgdir_alloc_page+0x34>

ffffffffc0203ffc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203ffc:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ffe:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204000:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204002:	ca2fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_valid>
ffffffffc0204006:	cd01                	beqz	a0,ffffffffc020401e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204008:	4505                	li	a0,1
ffffffffc020400a:	ca0fc0ef          	jal	ra,ffffffffc02004aa <ide_device_size>
}
ffffffffc020400e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204010:	810d                	srli	a0,a0,0x3
ffffffffc0204012:	00011797          	auipc	a5,0x11
ffffffffc0204016:	54a7b323          	sd	a0,1350(a5) # ffffffffc0215558 <max_swap_offset>
}
ffffffffc020401a:	0141                	addi	sp,sp,16
ffffffffc020401c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc020401e:	00002617          	auipc	a2,0x2
ffffffffc0204022:	5aa60613          	addi	a2,a2,1450 # ffffffffc02065c8 <default_pmm_manager+0x588>
ffffffffc0204026:	45b5                	li	a1,13
ffffffffc0204028:	00002517          	auipc	a0,0x2
ffffffffc020402c:	5c050513          	addi	a0,a0,1472 # ffffffffc02065e8 <default_pmm_manager+0x5a8>
ffffffffc0204030:	998fc0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc0204034 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204034:	1141                	addi	sp,sp,-16
ffffffffc0204036:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204038:	00855793          	srli	a5,a0,0x8
ffffffffc020403c:	cbb1                	beqz	a5,ffffffffc0204090 <swapfs_write+0x5c>
ffffffffc020403e:	00011717          	auipc	a4,0x11
ffffffffc0204042:	51a73703          	ld	a4,1306(a4) # ffffffffc0215558 <max_swap_offset>
ffffffffc0204046:	04e7f563          	bgeu	a5,a4,ffffffffc0204090 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc020404a:	00011617          	auipc	a2,0x11
ffffffffc020404e:	54663603          	ld	a2,1350(a2) # ffffffffc0215590 <pages>
ffffffffc0204052:	8d91                	sub	a1,a1,a2
ffffffffc0204054:	4065d613          	srai	a2,a1,0x6
ffffffffc0204058:	00003717          	auipc	a4,0x3
ffffffffc020405c:	95073703          	ld	a4,-1712(a4) # ffffffffc02069a8 <nbase>
ffffffffc0204060:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204062:	00c61713          	slli	a4,a2,0xc
ffffffffc0204066:	8331                	srli	a4,a4,0xc
ffffffffc0204068:	00011697          	auipc	a3,0x11
ffffffffc020406c:	5206b683          	ld	a3,1312(a3) # ffffffffc0215588 <npage>
ffffffffc0204070:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204074:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204076:	02d77963          	bgeu	a4,a3,ffffffffc02040a8 <swapfs_write+0x74>
}
ffffffffc020407a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020407c:	00011797          	auipc	a5,0x11
ffffffffc0204080:	5247b783          	ld	a5,1316(a5) # ffffffffc02155a0 <va_pa_offset>
ffffffffc0204084:	46a1                	li	a3,8
ffffffffc0204086:	963e                	add	a2,a2,a5
ffffffffc0204088:	4505                	li	a0,1
}
ffffffffc020408a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020408c:	c24fc06f          	j	ffffffffc02004b0 <ide_write_secs>
ffffffffc0204090:	86aa                	mv	a3,a0
ffffffffc0204092:	00002617          	auipc	a2,0x2
ffffffffc0204096:	56e60613          	addi	a2,a2,1390 # ffffffffc0206600 <default_pmm_manager+0x5c0>
ffffffffc020409a:	45e5                	li	a1,25
ffffffffc020409c:	00002517          	auipc	a0,0x2
ffffffffc02040a0:	54c50513          	addi	a0,a0,1356 # ffffffffc02065e8 <default_pmm_manager+0x5a8>
ffffffffc02040a4:	924fc0ef          	jal	ra,ffffffffc02001c8 <__panic>
ffffffffc02040a8:	86b2                	mv	a3,a2
ffffffffc02040aa:	06900593          	li	a1,105
ffffffffc02040ae:	00001617          	auipc	a2,0x1
ffffffffc02040b2:	4e260613          	addi	a2,a2,1250 # ffffffffc0205590 <commands+0x980>
ffffffffc02040b6:	00001517          	auipc	a0,0x1
ffffffffc02040ba:	4ca50513          	addi	a0,a0,1226 # ffffffffc0205580 <commands+0x970>
ffffffffc02040be:	90afc0ef          	jal	ra,ffffffffc02001c8 <__panic>

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
ffffffffc02040ea:	44c000ef          	jal	ra,ffffffffc0204536 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc02040ee:	0b490593          	addi	a1,s2,180
ffffffffc02040f2:	463d                	li	a2,15
ffffffffc02040f4:	8526                	mv	a0,s1
ffffffffc02040f6:	452000ef          	jal	ra,ffffffffc0204548 <memcpy>
ffffffffc02040fa:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02040fc:	85ce                	mv	a1,s3
ffffffffc02040fe:	00002517          	auipc	a0,0x2
ffffffffc0204102:	52250513          	addi	a0,a0,1314 # ffffffffc0206620 <default_pmm_manager+0x5e0>
ffffffffc0204106:	fc7fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020410a:	85a2                	mv	a1,s0
ffffffffc020410c:	00002517          	auipc	a0,0x2
ffffffffc0204110:	53c50513          	addi	a0,a0,1340 # ffffffffc0206648 <default_pmm_manager+0x608>
ffffffffc0204114:	fb9fb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0204118:	00002517          	auipc	a0,0x2
ffffffffc020411c:	54050513          	addi	a0,a0,1344 # ffffffffc0206658 <default_pmm_manager+0x618>
ffffffffc0204120:	fadfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
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
}
ffffffffc0204134:	8082                	ret

ffffffffc0204136 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204136:	7169                	addi	sp,sp,-304
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204138:	12000613          	li	a2,288
ffffffffc020413c:	4581                	li	a1,0
ffffffffc020413e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204140:	f606                	sd	ra,296(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204142:	3f4000ef          	jal	ra,ffffffffc0204536 <memset>
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204146:	100027f3          	csrr	a5,sstatus
}
ffffffffc020414a:	70b2                	ld	ra,296(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020414c:	00011517          	auipc	a0,0x11
ffffffffc0204150:	47452503          	lw	a0,1140(a0) # ffffffffc02155c0 <nr_process>
ffffffffc0204154:	6785                	lui	a5,0x1
    int ret = -E_NO_FREE_PROC;
ffffffffc0204156:	00f52533          	slt	a0,a0,a5
}
ffffffffc020415a:	156d                	addi	a0,a0,-5
ffffffffc020415c:	6155                	addi	sp,sp,304
ffffffffc020415e:	8082                	ret

ffffffffc0204160 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0204160:	7139                	addi	sp,sp,-64
ffffffffc0204162:	f426                	sd	s1,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0204164:	00011797          	auipc	a5,0x11
ffffffffc0204168:	3bc78793          	addi	a5,a5,956 # ffffffffc0215520 <proc_list>
ffffffffc020416c:	fc06                	sd	ra,56(sp)
ffffffffc020416e:	f822                	sd	s0,48(sp)
ffffffffc0204170:	f04a                	sd	s2,32(sp)
ffffffffc0204172:	ec4e                	sd	s3,24(sp)
ffffffffc0204174:	e852                	sd	s4,16(sp)
ffffffffc0204176:	e456                	sd	s5,8(sp)
ffffffffc0204178:	0000d497          	auipc	s1,0xd
ffffffffc020417c:	39848493          	addi	s1,s1,920 # ffffffffc0211510 <hash_list>
ffffffffc0204180:	e79c                	sd	a5,8(a5)
ffffffffc0204182:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204184:	00011717          	auipc	a4,0x11
ffffffffc0204188:	38c70713          	addi	a4,a4,908 # ffffffffc0215510 <name.0>
ffffffffc020418c:	87a6                	mv	a5,s1
ffffffffc020418e:	e79c                	sd	a5,8(a5)
ffffffffc0204190:	e39c                	sd	a5,0(a5)
ffffffffc0204192:	07c1                	addi	a5,a5,16
ffffffffc0204194:	fef71de3          	bne	a4,a5,ffffffffc020418e <proc_init+0x2e>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204198:	0e800513          	li	a0,232
ffffffffc020419c:	ccbfd0ef          	jal	ra,ffffffffc0201e66 <kmalloc>
ffffffffc02041a0:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc02041a2:	1e050863          	beqz	a0,ffffffffc0204392 <proc_init+0x232>
        proc->cr3 = boot_cr3;
ffffffffc02041a6:	00011a97          	auipc	s5,0x11
ffffffffc02041aa:	3d2a8a93          	addi	s5,s5,978 # ffffffffc0215578 <boot_cr3>
ffffffffc02041ae:	000ab783          	ld	a5,0(s5)
        proc->state = PROC_UNINIT;
ffffffffc02041b2:	59fd                	li	s3,-1
ffffffffc02041b4:	1982                	slli	s3,s3,0x20
        proc->cr3 = boot_cr3;
ffffffffc02041b6:	f55c                	sd	a5,168(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041b8:	07000613          	li	a2,112
ffffffffc02041bc:	4581                	li	a1,0
        proc->state = PROC_UNINIT;
ffffffffc02041be:	01353023          	sd	s3,0(a0)
        proc->runs = 0;
ffffffffc02041c2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc02041c6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc02041ca:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;
ffffffffc02041ce:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc02041d2:	02053423          	sd	zero,40(a0)
        proc->tf = NULL;
ffffffffc02041d6:	0a053023          	sd	zero,160(a0)
        proc->flags = 0;
ffffffffc02041da:	0a052823          	sw	zero,176(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02041de:	03050513          	addi	a0,a0,48
ffffffffc02041e2:	354000ef          	jal	ra,ffffffffc0204536 <memset>
        memset(&(proc->name), 0, PROC_NAME_LEN);
ffffffffc02041e6:	463d                	li	a2,15
ffffffffc02041e8:	4581                	li	a1,0
ffffffffc02041ea:	0b440513          	addi	a0,s0,180
ffffffffc02041ee:	348000ef          	jal	ra,ffffffffc0204536 <memset>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02041f2:	00011917          	auipc	s2,0x11
ffffffffc02041f6:	3be90913          	addi	s2,s2,958 # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc02041fa:	07000513          	li	a0,112
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02041fe:	00893023          	sd	s0,0(s2)
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204202:	c65fd0ef          	jal	ra,ffffffffc0201e66 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204206:	07000613          	li	a2,112
ffffffffc020420a:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc020420c:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020420e:	328000ef          	jal	ra,ffffffffc0204536 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0204212:	00093503          	ld	a0,0(s2)
ffffffffc0204216:	85a2                	mv	a1,s0
ffffffffc0204218:	07000613          	li	a2,112
ffffffffc020421c:	03050513          	addi	a0,a0,48
ffffffffc0204220:	340000ef          	jal	ra,ffffffffc0204560 <memcmp>
ffffffffc0204224:	8a2a                	mv	s4,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204226:	453d                	li	a0,15
ffffffffc0204228:	c3ffd0ef          	jal	ra,ffffffffc0201e66 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020422c:	463d                	li	a2,15
ffffffffc020422e:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204230:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204232:	304000ef          	jal	ra,ffffffffc0204536 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0204236:	00093503          	ld	a0,0(s2)
ffffffffc020423a:	463d                	li	a2,15
ffffffffc020423c:	85a2                	mv	a1,s0
ffffffffc020423e:	0b450513          	addi	a0,a0,180
ffffffffc0204242:	31e000ef          	jal	ra,ffffffffc0204560 <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204246:	00093783          	ld	a5,0(s2)
ffffffffc020424a:	000ab703          	ld	a4,0(s5)
ffffffffc020424e:	77d4                	ld	a3,168(a5)
ffffffffc0204250:	0ee68663          	beq	a3,a4,ffffffffc020433c <proc_init+0x1dc>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204254:	4709                	li	a4,2
ffffffffc0204256:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204258:	00003717          	auipc	a4,0x3
ffffffffc020425c:	da870713          	addi	a4,a4,-600 # ffffffffc0207000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204260:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204264:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc0204266:	4705                	li	a4,1
ffffffffc0204268:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020426a:	4641                	li	a2,16
ffffffffc020426c:	4581                	li	a1,0
ffffffffc020426e:	8522                	mv	a0,s0
ffffffffc0204270:	2c6000ef          	jal	ra,ffffffffc0204536 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204274:	463d                	li	a2,15
ffffffffc0204276:	00002597          	auipc	a1,0x2
ffffffffc020427a:	44a58593          	addi	a1,a1,1098 # ffffffffc02066c0 <default_pmm_manager+0x680>
ffffffffc020427e:	8522                	mv	a0,s0
ffffffffc0204280:	2c8000ef          	jal	ra,ffffffffc0204548 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0204284:	00011717          	auipc	a4,0x11
ffffffffc0204288:	33c70713          	addi	a4,a4,828 # ffffffffc02155c0 <nr_process>
ffffffffc020428c:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc020428e:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204292:	4601                	li	a2,0
    nr_process ++;
ffffffffc0204294:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0204296:	00002597          	auipc	a1,0x2
ffffffffc020429a:	43258593          	addi	a1,a1,1074 # ffffffffc02066c8 <default_pmm_manager+0x688>
ffffffffc020429e:	00000517          	auipc	a0,0x0
ffffffffc02042a2:	e2450513          	addi	a0,a0,-476 # ffffffffc02040c2 <init_main>
    nr_process ++;
ffffffffc02042a6:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc02042a8:	00011797          	auipc	a5,0x11
ffffffffc02042ac:	30d7b023          	sd	a3,768(a5) # ffffffffc02155a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02042b0:	e87ff0ef          	jal	ra,ffffffffc0204136 <kernel_thread>
ffffffffc02042b4:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc02042b6:	0ea05e63          	blez	a0,ffffffffc02043b2 <proc_init+0x252>
    if (0 < pid && pid < MAX_PID) {
ffffffffc02042ba:	6789                	lui	a5,0x2
ffffffffc02042bc:	fff5071b          	addiw	a4,a0,-1
ffffffffc02042c0:	17f9                	addi	a5,a5,-2
ffffffffc02042c2:	2501                	sext.w	a0,a0
ffffffffc02042c4:	02e7e363          	bltu	a5,a4,ffffffffc02042ea <proc_init+0x18a>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02042c8:	45a9                	li	a1,10
ffffffffc02042ca:	6a8000ef          	jal	ra,ffffffffc0204972 <hash32>
ffffffffc02042ce:	02051793          	slli	a5,a0,0x20
ffffffffc02042d2:	01c7d693          	srli	a3,a5,0x1c
ffffffffc02042d6:	96a6                	add	a3,a3,s1
ffffffffc02042d8:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02042da:	a029                	j	ffffffffc02042e4 <proc_init+0x184>
            if (proc->pid == pid) {
ffffffffc02042dc:	f2c7a703          	lw	a4,-212(a5) # 1f2c <kern_entry-0xffffffffc01fe0d4>
ffffffffc02042e0:	0a870663          	beq	a4,s0,ffffffffc020438c <proc_init+0x22c>
    return listelm->next;
ffffffffc02042e4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02042e6:	fef69be3          	bne	a3,a5,ffffffffc02042dc <proc_init+0x17c>
    return NULL;
ffffffffc02042ea:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042ec:	0b478493          	addi	s1,a5,180
ffffffffc02042f0:	4641                	li	a2,16
ffffffffc02042f2:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02042f4:	00011417          	auipc	s0,0x11
ffffffffc02042f8:	2c440413          	addi	s0,s0,708 # ffffffffc02155b8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02042fc:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc02042fe:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204300:	236000ef          	jal	ra,ffffffffc0204536 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204304:	463d                	li	a2,15
ffffffffc0204306:	00002597          	auipc	a1,0x2
ffffffffc020430a:	3f258593          	addi	a1,a1,1010 # ffffffffc02066f8 <default_pmm_manager+0x6b8>
ffffffffc020430e:	8526                	mv	a0,s1
ffffffffc0204310:	238000ef          	jal	ra,ffffffffc0204548 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204314:	00093783          	ld	a5,0(s2)
ffffffffc0204318:	cbe9                	beqz	a5,ffffffffc02043ea <proc_init+0x28a>
ffffffffc020431a:	43dc                	lw	a5,4(a5)
ffffffffc020431c:	e7f9                	bnez	a5,ffffffffc02043ea <proc_init+0x28a>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020431e:	601c                	ld	a5,0(s0)
ffffffffc0204320:	c7cd                	beqz	a5,ffffffffc02043ca <proc_init+0x26a>
ffffffffc0204322:	43d8                	lw	a4,4(a5)
ffffffffc0204324:	4785                	li	a5,1
ffffffffc0204326:	0af71263          	bne	a4,a5,ffffffffc02043ca <proc_init+0x26a>
}
ffffffffc020432a:	70e2                	ld	ra,56(sp)
ffffffffc020432c:	7442                	ld	s0,48(sp)
ffffffffc020432e:	74a2                	ld	s1,40(sp)
ffffffffc0204330:	7902                	ld	s2,32(sp)
ffffffffc0204332:	69e2                	ld	s3,24(sp)
ffffffffc0204334:	6a42                	ld	s4,16(sp)
ffffffffc0204336:	6aa2                	ld	s5,8(sp)
ffffffffc0204338:	6121                	addi	sp,sp,64
ffffffffc020433a:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020433c:	73d8                	ld	a4,160(a5)
ffffffffc020433e:	f0071be3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc0204342:	f00a19e3          	bnez	s4,ffffffffc0204254 <proc_init+0xf4>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204346:	6398                	ld	a4,0(a5)
ffffffffc0204348:	f13716e3          	bne	a4,s3,ffffffffc0204254 <proc_init+0xf4>
ffffffffc020434c:	4798                	lw	a4,8(a5)
ffffffffc020434e:	f00713e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204352:	6b98                	ld	a4,16(a5)
ffffffffc0204354:	f00710e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc0204358:	4f98                	lw	a4,24(a5)
ffffffffc020435a:	2701                	sext.w	a4,a4
ffffffffc020435c:	ee071ce3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc0204360:	7398                	ld	a4,32(a5)
ffffffffc0204362:	ee0719e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204366:	7798                	ld	a4,40(a5)
ffffffffc0204368:	ee0716e3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
ffffffffc020436c:	0b07a703          	lw	a4,176(a5)
ffffffffc0204370:	8d59                	or	a0,a0,a4
ffffffffc0204372:	0005071b          	sext.w	a4,a0
ffffffffc0204376:	ec071fe3          	bnez	a4,ffffffffc0204254 <proc_init+0xf4>
        cprintf("alloc_proc() correct!\n");
ffffffffc020437a:	00002517          	auipc	a0,0x2
ffffffffc020437e:	32e50513          	addi	a0,a0,814 # ffffffffc02066a8 <default_pmm_manager+0x668>
ffffffffc0204382:	d4bfb0ef          	jal	ra,ffffffffc02000cc <cprintf>
    idleproc->pid = 0;
ffffffffc0204386:	00093783          	ld	a5,0(s2)
ffffffffc020438a:	b5e9                	j	ffffffffc0204254 <proc_init+0xf4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc020438c:	f2878793          	addi	a5,a5,-216
ffffffffc0204390:	bfb1                	j	ffffffffc02042ec <proc_init+0x18c>
        panic("cannot alloc idleproc.\n");
ffffffffc0204392:	00002617          	auipc	a2,0x2
ffffffffc0204396:	3be60613          	addi	a2,a2,958 # ffffffffc0206750 <default_pmm_manager+0x710>
ffffffffc020439a:	16600593          	li	a1,358
ffffffffc020439e:	00002517          	auipc	a0,0x2
ffffffffc02043a2:	2f250513          	addi	a0,a0,754 # ffffffffc0206690 <default_pmm_manager+0x650>
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc02043a6:	00011797          	auipc	a5,0x11
ffffffffc02043aa:	2007b523          	sd	zero,522(a5) # ffffffffc02155b0 <idleproc>
        panic("cannot alloc idleproc.\n");
ffffffffc02043ae:	e1bfb0ef          	jal	ra,ffffffffc02001c8 <__panic>
        panic("create init_main failed.\n");
ffffffffc02043b2:	00002617          	auipc	a2,0x2
ffffffffc02043b6:	32660613          	addi	a2,a2,806 # ffffffffc02066d8 <default_pmm_manager+0x698>
ffffffffc02043ba:	18600593          	li	a1,390
ffffffffc02043be:	00002517          	auipc	a0,0x2
ffffffffc02043c2:	2d250513          	addi	a0,a0,722 # ffffffffc0206690 <default_pmm_manager+0x650>
ffffffffc02043c6:	e03fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02043ca:	00002697          	auipc	a3,0x2
ffffffffc02043ce:	35e68693          	addi	a3,a3,862 # ffffffffc0206728 <default_pmm_manager+0x6e8>
ffffffffc02043d2:	00001617          	auipc	a2,0x1
ffffffffc02043d6:	f6660613          	addi	a2,a2,-154 # ffffffffc0205338 <commands+0x728>
ffffffffc02043da:	18d00593          	li	a1,397
ffffffffc02043de:	00002517          	auipc	a0,0x2
ffffffffc02043e2:	2b250513          	addi	a0,a0,690 # ffffffffc0206690 <default_pmm_manager+0x650>
ffffffffc02043e6:	de3fb0ef          	jal	ra,ffffffffc02001c8 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02043ea:	00002697          	auipc	a3,0x2
ffffffffc02043ee:	31668693          	addi	a3,a3,790 # ffffffffc0206700 <default_pmm_manager+0x6c0>
ffffffffc02043f2:	00001617          	auipc	a2,0x1
ffffffffc02043f6:	f4660613          	addi	a2,a2,-186 # ffffffffc0205338 <commands+0x728>
ffffffffc02043fa:	18c00593          	li	a1,396
ffffffffc02043fe:	00002517          	auipc	a0,0x2
ffffffffc0204402:	29250513          	addi	a0,a0,658 # ffffffffc0206690 <default_pmm_manager+0x650>
ffffffffc0204406:	dc3fb0ef          	jal	ra,ffffffffc02001c8 <__panic>

ffffffffc020440a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020440a:	1141                	addi	sp,sp,-16
ffffffffc020440c:	e022                	sd	s0,0(sp)
ffffffffc020440e:	e406                	sd	ra,8(sp)
ffffffffc0204410:	00011417          	auipc	s0,0x11
ffffffffc0204414:	19840413          	addi	s0,s0,408 # ffffffffc02155a8 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0204418:	6018                	ld	a4,0(s0)
ffffffffc020441a:	4f1c                	lw	a5,24(a4)
ffffffffc020441c:	2781                	sext.w	a5,a5
ffffffffc020441e:	dff5                	beqz	a5,ffffffffc020441a <cpu_idle+0x10>
            schedule();
ffffffffc0204420:	006000ef          	jal	ra,ffffffffc0204426 <schedule>
ffffffffc0204424:	bfd5                	j	ffffffffc0204418 <cpu_idle+0xe>

ffffffffc0204426 <schedule>:
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    proc->state = PROC_RUNNABLE;
}

void
schedule(void) {
ffffffffc0204426:	1141                	addi	sp,sp,-16
ffffffffc0204428:	e406                	sd	ra,8(sp)
ffffffffc020442a:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020442c:	100027f3          	csrr	a5,sstatus
ffffffffc0204430:	8b89                	andi	a5,a5,2
ffffffffc0204432:	4401                	li	s0,0
ffffffffc0204434:	efbd                	bnez	a5,ffffffffc02044b2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0204436:	00011897          	auipc	a7,0x11
ffffffffc020443a:	1728b883          	ld	a7,370(a7) # ffffffffc02155a8 <current>
ffffffffc020443e:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0204442:	00011517          	auipc	a0,0x11
ffffffffc0204446:	16e53503          	ld	a0,366(a0) # ffffffffc02155b0 <idleproc>
ffffffffc020444a:	04a88e63          	beq	a7,a0,ffffffffc02044a6 <schedule+0x80>
ffffffffc020444e:	0c888693          	addi	a3,a7,200
ffffffffc0204452:	00011617          	auipc	a2,0x11
ffffffffc0204456:	0ce60613          	addi	a2,a2,206 # ffffffffc0215520 <proc_list>
        le = last;
ffffffffc020445a:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020445c:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020445e:	4809                	li	a6,2
ffffffffc0204460:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0204462:	00c78863          	beq	a5,a2,ffffffffc0204472 <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0204466:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc020446a:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020446e:	03070163          	beq	a4,a6,ffffffffc0204490 <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc0204472:	fef697e3          	bne	a3,a5,ffffffffc0204460 <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204476:	ed89                	bnez	a1,ffffffffc0204490 <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204478:	451c                	lw	a5,8(a0)
ffffffffc020447a:	2785                	addiw	a5,a5,1
ffffffffc020447c:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020447e:	00a88463          	beq	a7,a0,ffffffffc0204486 <schedule+0x60>
            proc_run(next);
ffffffffc0204482:	cb3ff0ef          	jal	ra,ffffffffc0204134 <proc_run>
    if (flag) {
ffffffffc0204486:	e819                	bnez	s0,ffffffffc020449c <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204488:	60a2                	ld	ra,8(sp)
ffffffffc020448a:	6402                	ld	s0,0(sp)
ffffffffc020448c:	0141                	addi	sp,sp,16
ffffffffc020448e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204490:	4198                	lw	a4,0(a1)
ffffffffc0204492:	4789                	li	a5,2
ffffffffc0204494:	fef712e3          	bne	a4,a5,ffffffffc0204478 <schedule+0x52>
ffffffffc0204498:	852e                	mv	a0,a1
ffffffffc020449a:	bff9                	j	ffffffffc0204478 <schedule+0x52>
}
ffffffffc020449c:	6402                	ld	s0,0(sp)
ffffffffc020449e:	60a2                	ld	ra,8(sp)
ffffffffc02044a0:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02044a2:	8f8fc06f          	j	ffffffffc020059a <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02044a6:	00011617          	auipc	a2,0x11
ffffffffc02044aa:	07a60613          	addi	a2,a2,122 # ffffffffc0215520 <proc_list>
ffffffffc02044ae:	86b2                	mv	a3,a2
ffffffffc02044b0:	b76d                	j	ffffffffc020445a <schedule+0x34>
        intr_disable();
ffffffffc02044b2:	8eefc0ef          	jal	ra,ffffffffc02005a0 <intr_disable>
        return 1;
ffffffffc02044b6:	4405                	li	s0,1
ffffffffc02044b8:	bfbd                	j	ffffffffc0204436 <schedule+0x10>

ffffffffc02044ba <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02044ba:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc02044be:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc02044c0:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc02044c2:	cb81                	beqz	a5,ffffffffc02044d2 <strlen+0x18>
        cnt ++;
ffffffffc02044c4:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc02044c6:	00a707b3          	add	a5,a4,a0
ffffffffc02044ca:	0007c783          	lbu	a5,0(a5)
ffffffffc02044ce:	fbfd                	bnez	a5,ffffffffc02044c4 <strlen+0xa>
ffffffffc02044d0:	8082                	ret
    }
    return cnt;
}
ffffffffc02044d2:	8082                	ret

ffffffffc02044d4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02044d4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02044d6:	e589                	bnez	a1,ffffffffc02044e0 <strnlen+0xc>
ffffffffc02044d8:	a811                	j	ffffffffc02044ec <strnlen+0x18>
        cnt ++;
ffffffffc02044da:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02044dc:	00f58863          	beq	a1,a5,ffffffffc02044ec <strnlen+0x18>
ffffffffc02044e0:	00f50733          	add	a4,a0,a5
ffffffffc02044e4:	00074703          	lbu	a4,0(a4)
ffffffffc02044e8:	fb6d                	bnez	a4,ffffffffc02044da <strnlen+0x6>
ffffffffc02044ea:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02044ec:	852e                	mv	a0,a1
ffffffffc02044ee:	8082                	ret

ffffffffc02044f0 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02044f0:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02044f2:	0005c703          	lbu	a4,0(a1)
ffffffffc02044f6:	0785                	addi	a5,a5,1
ffffffffc02044f8:	0585                	addi	a1,a1,1
ffffffffc02044fa:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02044fe:	fb75                	bnez	a4,ffffffffc02044f2 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204500:	8082                	ret

ffffffffc0204502 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204502:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204506:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020450a:	cb89                	beqz	a5,ffffffffc020451c <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc020450c:	0505                	addi	a0,a0,1
ffffffffc020450e:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204510:	fee789e3          	beq	a5,a4,ffffffffc0204502 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204514:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204518:	9d19                	subw	a0,a0,a4
ffffffffc020451a:	8082                	ret
ffffffffc020451c:	4501                	li	a0,0
ffffffffc020451e:	bfed                	j	ffffffffc0204518 <strcmp+0x16>

ffffffffc0204520 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204520:	00054783          	lbu	a5,0(a0)
ffffffffc0204524:	c799                	beqz	a5,ffffffffc0204532 <strchr+0x12>
        if (*s == c) {
ffffffffc0204526:	00f58763          	beq	a1,a5,ffffffffc0204534 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020452a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020452e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204530:	fbfd                	bnez	a5,ffffffffc0204526 <strchr+0x6>
    }
    return NULL;
ffffffffc0204532:	4501                	li	a0,0
}
ffffffffc0204534:	8082                	ret

ffffffffc0204536 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204536:	ca01                	beqz	a2,ffffffffc0204546 <memset+0x10>
ffffffffc0204538:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020453a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020453c:	0785                	addi	a5,a5,1
ffffffffc020453e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204542:	fec79de3          	bne	a5,a2,ffffffffc020453c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204546:	8082                	ret

ffffffffc0204548 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204548:	ca19                	beqz	a2,ffffffffc020455e <memcpy+0x16>
ffffffffc020454a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020454c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020454e:	0005c703          	lbu	a4,0(a1)
ffffffffc0204552:	0585                	addi	a1,a1,1
ffffffffc0204554:	0785                	addi	a5,a5,1
ffffffffc0204556:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020455a:	fec59ae3          	bne	a1,a2,ffffffffc020454e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020455e:	8082                	ret

ffffffffc0204560 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204560:	c205                	beqz	a2,ffffffffc0204580 <memcmp+0x20>
ffffffffc0204562:	962e                	add	a2,a2,a1
ffffffffc0204564:	a019                	j	ffffffffc020456a <memcmp+0xa>
ffffffffc0204566:	00c58d63          	beq	a1,a2,ffffffffc0204580 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc020456a:	00054783          	lbu	a5,0(a0)
ffffffffc020456e:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204572:	0505                	addi	a0,a0,1
ffffffffc0204574:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0204576:	fee788e3          	beq	a5,a4,ffffffffc0204566 <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020457a:	40e7853b          	subw	a0,a5,a4
ffffffffc020457e:	8082                	ret
    }
    return 0;
ffffffffc0204580:	4501                	li	a0,0
}
ffffffffc0204582:	8082                	ret

ffffffffc0204584 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204584:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204588:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020458a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020458e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204590:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204594:	f022                	sd	s0,32(sp)
ffffffffc0204596:	ec26                	sd	s1,24(sp)
ffffffffc0204598:	e84a                	sd	s2,16(sp)
ffffffffc020459a:	f406                	sd	ra,40(sp)
ffffffffc020459c:	e44e                	sd	s3,8(sp)
ffffffffc020459e:	84aa                	mv	s1,a0
ffffffffc02045a0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02045a2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02045a6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02045a8:	03067e63          	bgeu	a2,a6,ffffffffc02045e4 <printnum+0x60>
ffffffffc02045ac:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02045ae:	00805763          	blez	s0,ffffffffc02045bc <printnum+0x38>
ffffffffc02045b2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02045b4:	85ca                	mv	a1,s2
ffffffffc02045b6:	854e                	mv	a0,s3
ffffffffc02045b8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02045ba:	fc65                	bnez	s0,ffffffffc02045b2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02045bc:	1a02                	slli	s4,s4,0x20
ffffffffc02045be:	00002797          	auipc	a5,0x2
ffffffffc02045c2:	1aa78793          	addi	a5,a5,426 # ffffffffc0206768 <default_pmm_manager+0x728>
ffffffffc02045c6:	020a5a13          	srli	s4,s4,0x20
ffffffffc02045ca:	9a3e                	add	s4,s4,a5
}
ffffffffc02045cc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02045ce:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02045d2:	70a2                	ld	ra,40(sp)
ffffffffc02045d4:	69a2                	ld	s3,8(sp)
ffffffffc02045d6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02045d8:	85ca                	mv	a1,s2
ffffffffc02045da:	87a6                	mv	a5,s1
}
ffffffffc02045dc:	6942                	ld	s2,16(sp)
ffffffffc02045de:	64e2                	ld	s1,24(sp)
ffffffffc02045e0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02045e2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02045e4:	03065633          	divu	a2,a2,a6
ffffffffc02045e8:	8722                	mv	a4,s0
ffffffffc02045ea:	f9bff0ef          	jal	ra,ffffffffc0204584 <printnum>
ffffffffc02045ee:	b7f9                	j	ffffffffc02045bc <printnum+0x38>

ffffffffc02045f0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02045f0:	7119                	addi	sp,sp,-128
ffffffffc02045f2:	f4a6                	sd	s1,104(sp)
ffffffffc02045f4:	f0ca                	sd	s2,96(sp)
ffffffffc02045f6:	ecce                	sd	s3,88(sp)
ffffffffc02045f8:	e8d2                	sd	s4,80(sp)
ffffffffc02045fa:	e4d6                	sd	s5,72(sp)
ffffffffc02045fc:	e0da                	sd	s6,64(sp)
ffffffffc02045fe:	fc5e                	sd	s7,56(sp)
ffffffffc0204600:	f06a                	sd	s10,32(sp)
ffffffffc0204602:	fc86                	sd	ra,120(sp)
ffffffffc0204604:	f8a2                	sd	s0,112(sp)
ffffffffc0204606:	f862                	sd	s8,48(sp)
ffffffffc0204608:	f466                	sd	s9,40(sp)
ffffffffc020460a:	ec6e                	sd	s11,24(sp)
ffffffffc020460c:	892a                	mv	s2,a0
ffffffffc020460e:	84ae                	mv	s1,a1
ffffffffc0204610:	8d32                	mv	s10,a2
ffffffffc0204612:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204614:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0204618:	5b7d                	li	s6,-1
ffffffffc020461a:	00002a97          	auipc	s5,0x2
ffffffffc020461e:	17aa8a93          	addi	s5,s5,378 # ffffffffc0206794 <default_pmm_manager+0x754>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204622:	00002b97          	auipc	s7,0x2
ffffffffc0204626:	34eb8b93          	addi	s7,s7,846 # ffffffffc0206970 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020462a:	000d4503          	lbu	a0,0(s10)
ffffffffc020462e:	001d0413          	addi	s0,s10,1
ffffffffc0204632:	01350a63          	beq	a0,s3,ffffffffc0204646 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0204636:	c121                	beqz	a0,ffffffffc0204676 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0204638:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020463a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020463c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020463e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204642:	ff351ae3          	bne	a0,s3,ffffffffc0204636 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204646:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020464a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020464e:	4c81                	li	s9,0
ffffffffc0204650:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204652:	5c7d                	li	s8,-1
ffffffffc0204654:	5dfd                	li	s11,-1
ffffffffc0204656:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020465a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020465c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204660:	0ff5f593          	zext.b	a1,a1
ffffffffc0204664:	00140d13          	addi	s10,s0,1
ffffffffc0204668:	04b56263          	bltu	a0,a1,ffffffffc02046ac <vprintfmt+0xbc>
ffffffffc020466c:	058a                	slli	a1,a1,0x2
ffffffffc020466e:	95d6                	add	a1,a1,s5
ffffffffc0204670:	4194                	lw	a3,0(a1)
ffffffffc0204672:	96d6                	add	a3,a3,s5
ffffffffc0204674:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204676:	70e6                	ld	ra,120(sp)
ffffffffc0204678:	7446                	ld	s0,112(sp)
ffffffffc020467a:	74a6                	ld	s1,104(sp)
ffffffffc020467c:	7906                	ld	s2,96(sp)
ffffffffc020467e:	69e6                	ld	s3,88(sp)
ffffffffc0204680:	6a46                	ld	s4,80(sp)
ffffffffc0204682:	6aa6                	ld	s5,72(sp)
ffffffffc0204684:	6b06                	ld	s6,64(sp)
ffffffffc0204686:	7be2                	ld	s7,56(sp)
ffffffffc0204688:	7c42                	ld	s8,48(sp)
ffffffffc020468a:	7ca2                	ld	s9,40(sp)
ffffffffc020468c:	7d02                	ld	s10,32(sp)
ffffffffc020468e:	6de2                	ld	s11,24(sp)
ffffffffc0204690:	6109                	addi	sp,sp,128
ffffffffc0204692:	8082                	ret
            padc = '0';
ffffffffc0204694:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204696:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020469a:	846a                	mv	s0,s10
ffffffffc020469c:	00140d13          	addi	s10,s0,1
ffffffffc02046a0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02046a4:	0ff5f593          	zext.b	a1,a1
ffffffffc02046a8:	fcb572e3          	bgeu	a0,a1,ffffffffc020466c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02046ac:	85a6                	mv	a1,s1
ffffffffc02046ae:	02500513          	li	a0,37
ffffffffc02046b2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02046b4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02046b8:	8d22                	mv	s10,s0
ffffffffc02046ba:	f73788e3          	beq	a5,s3,ffffffffc020462a <vprintfmt+0x3a>
ffffffffc02046be:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02046c2:	1d7d                	addi	s10,s10,-1
ffffffffc02046c4:	ff379de3          	bne	a5,s3,ffffffffc02046be <vprintfmt+0xce>
ffffffffc02046c8:	b78d                	j	ffffffffc020462a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02046ca:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02046ce:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02046d2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02046d4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02046d8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02046dc:	02d86463          	bltu	a6,a3,ffffffffc0204704 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02046e0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02046e4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02046e8:	0186873b          	addw	a4,a3,s8
ffffffffc02046ec:	0017171b          	slliw	a4,a4,0x1
ffffffffc02046f0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02046f2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02046f6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02046f8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02046fc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204700:	fed870e3          	bgeu	a6,a3,ffffffffc02046e0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204704:	f40ddce3          	bgez	s11,ffffffffc020465c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0204708:	8de2                	mv	s11,s8
ffffffffc020470a:	5c7d                	li	s8,-1
ffffffffc020470c:	bf81                	j	ffffffffc020465c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020470e:	fffdc693          	not	a3,s11
ffffffffc0204712:	96fd                	srai	a3,a3,0x3f
ffffffffc0204714:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204718:	00144603          	lbu	a2,1(s0)
ffffffffc020471c:	2d81                	sext.w	s11,s11
ffffffffc020471e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204720:	bf35                	j	ffffffffc020465c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204722:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204726:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020472a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020472c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020472e:	bfd9                	j	ffffffffc0204704 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204730:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204732:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204736:	01174463          	blt	a4,a7,ffffffffc020473e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020473a:	1a088e63          	beqz	a7,ffffffffc02048f6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020473e:	000a3603          	ld	a2,0(s4)
ffffffffc0204742:	46c1                	li	a3,16
ffffffffc0204744:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204746:	2781                	sext.w	a5,a5
ffffffffc0204748:	876e                	mv	a4,s11
ffffffffc020474a:	85a6                	mv	a1,s1
ffffffffc020474c:	854a                	mv	a0,s2
ffffffffc020474e:	e37ff0ef          	jal	ra,ffffffffc0204584 <printnum>
            break;
ffffffffc0204752:	bde1                	j	ffffffffc020462a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204754:	000a2503          	lw	a0,0(s4)
ffffffffc0204758:	85a6                	mv	a1,s1
ffffffffc020475a:	0a21                	addi	s4,s4,8
ffffffffc020475c:	9902                	jalr	s2
            break;
ffffffffc020475e:	b5f1                	j	ffffffffc020462a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204760:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204762:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204766:	01174463          	blt	a4,a7,ffffffffc020476e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020476a:	18088163          	beqz	a7,ffffffffc02048ec <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020476e:	000a3603          	ld	a2,0(s4)
ffffffffc0204772:	46a9                	li	a3,10
ffffffffc0204774:	8a2e                	mv	s4,a1
ffffffffc0204776:	bfc1                	j	ffffffffc0204746 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204778:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020477c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020477e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204780:	bdf1                	j	ffffffffc020465c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204782:	85a6                	mv	a1,s1
ffffffffc0204784:	02500513          	li	a0,37
ffffffffc0204788:	9902                	jalr	s2
            break;
ffffffffc020478a:	b545                	j	ffffffffc020462a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020478c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204790:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204792:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204794:	b5e1                	j	ffffffffc020465c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204796:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204798:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020479c:	01174463          	blt	a4,a7,ffffffffc02047a4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02047a0:	14088163          	beqz	a7,ffffffffc02048e2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02047a4:	000a3603          	ld	a2,0(s4)
ffffffffc02047a8:	46a1                	li	a3,8
ffffffffc02047aa:	8a2e                	mv	s4,a1
ffffffffc02047ac:	bf69                	j	ffffffffc0204746 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02047ae:	03000513          	li	a0,48
ffffffffc02047b2:	85a6                	mv	a1,s1
ffffffffc02047b4:	e03e                	sd	a5,0(sp)
ffffffffc02047b6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02047b8:	85a6                	mv	a1,s1
ffffffffc02047ba:	07800513          	li	a0,120
ffffffffc02047be:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02047c0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02047c2:	6782                	ld	a5,0(sp)
ffffffffc02047c4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02047c6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02047ca:	bfb5                	j	ffffffffc0204746 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02047cc:	000a3403          	ld	s0,0(s4)
ffffffffc02047d0:	008a0713          	addi	a4,s4,8
ffffffffc02047d4:	e03a                	sd	a4,0(sp)
ffffffffc02047d6:	14040263          	beqz	s0,ffffffffc020491a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02047da:	0fb05763          	blez	s11,ffffffffc02048c8 <vprintfmt+0x2d8>
ffffffffc02047de:	02d00693          	li	a3,45
ffffffffc02047e2:	0cd79163          	bne	a5,a3,ffffffffc02048a4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02047e6:	00044783          	lbu	a5,0(s0)
ffffffffc02047ea:	0007851b          	sext.w	a0,a5
ffffffffc02047ee:	cf85                	beqz	a5,ffffffffc0204826 <vprintfmt+0x236>
ffffffffc02047f0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02047f4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02047f8:	000c4563          	bltz	s8,ffffffffc0204802 <vprintfmt+0x212>
ffffffffc02047fc:	3c7d                	addiw	s8,s8,-1
ffffffffc02047fe:	036c0263          	beq	s8,s6,ffffffffc0204822 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204802:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204804:	0e0c8e63          	beqz	s9,ffffffffc0204900 <vprintfmt+0x310>
ffffffffc0204808:	3781                	addiw	a5,a5,-32
ffffffffc020480a:	0ef47b63          	bgeu	s0,a5,ffffffffc0204900 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020480e:	03f00513          	li	a0,63
ffffffffc0204812:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204814:	000a4783          	lbu	a5,0(s4)
ffffffffc0204818:	3dfd                	addiw	s11,s11,-1
ffffffffc020481a:	0a05                	addi	s4,s4,1
ffffffffc020481c:	0007851b          	sext.w	a0,a5
ffffffffc0204820:	ffe1                	bnez	a5,ffffffffc02047f8 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204822:	01b05963          	blez	s11,ffffffffc0204834 <vprintfmt+0x244>
ffffffffc0204826:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204828:	85a6                	mv	a1,s1
ffffffffc020482a:	02000513          	li	a0,32
ffffffffc020482e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204830:	fe0d9be3          	bnez	s11,ffffffffc0204826 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204834:	6a02                	ld	s4,0(sp)
ffffffffc0204836:	bbd5                	j	ffffffffc020462a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204838:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020483a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020483e:	01174463          	blt	a4,a7,ffffffffc0204846 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204842:	08088d63          	beqz	a7,ffffffffc02048dc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204846:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020484a:	0a044d63          	bltz	s0,ffffffffc0204904 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020484e:	8622                	mv	a2,s0
ffffffffc0204850:	8a66                	mv	s4,s9
ffffffffc0204852:	46a9                	li	a3,10
ffffffffc0204854:	bdcd                	j	ffffffffc0204746 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204856:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020485a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020485c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020485e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204862:	8fb5                	xor	a5,a5,a3
ffffffffc0204864:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204868:	02d74163          	blt	a4,a3,ffffffffc020488a <vprintfmt+0x29a>
ffffffffc020486c:	00369793          	slli	a5,a3,0x3
ffffffffc0204870:	97de                	add	a5,a5,s7
ffffffffc0204872:	639c                	ld	a5,0(a5)
ffffffffc0204874:	cb99                	beqz	a5,ffffffffc020488a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204876:	86be                	mv	a3,a5
ffffffffc0204878:	00000617          	auipc	a2,0x0
ffffffffc020487c:	13860613          	addi	a2,a2,312 # ffffffffc02049b0 <etext+0x28>
ffffffffc0204880:	85a6                	mv	a1,s1
ffffffffc0204882:	854a                	mv	a0,s2
ffffffffc0204884:	0ce000ef          	jal	ra,ffffffffc0204952 <printfmt>
ffffffffc0204888:	b34d                	j	ffffffffc020462a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020488a:	00002617          	auipc	a2,0x2
ffffffffc020488e:	efe60613          	addi	a2,a2,-258 # ffffffffc0206788 <default_pmm_manager+0x748>
ffffffffc0204892:	85a6                	mv	a1,s1
ffffffffc0204894:	854a                	mv	a0,s2
ffffffffc0204896:	0bc000ef          	jal	ra,ffffffffc0204952 <printfmt>
ffffffffc020489a:	bb41                	j	ffffffffc020462a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020489c:	00002417          	auipc	s0,0x2
ffffffffc02048a0:	ee440413          	addi	s0,s0,-284 # ffffffffc0206780 <default_pmm_manager+0x740>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02048a4:	85e2                	mv	a1,s8
ffffffffc02048a6:	8522                	mv	a0,s0
ffffffffc02048a8:	e43e                	sd	a5,8(sp)
ffffffffc02048aa:	c2bff0ef          	jal	ra,ffffffffc02044d4 <strnlen>
ffffffffc02048ae:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02048b2:	01b05b63          	blez	s11,ffffffffc02048c8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02048b6:	67a2                	ld	a5,8(sp)
ffffffffc02048b8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02048bc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02048be:	85a6                	mv	a1,s1
ffffffffc02048c0:	8552                	mv	a0,s4
ffffffffc02048c2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02048c4:	fe0d9ce3          	bnez	s11,ffffffffc02048bc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02048c8:	00044783          	lbu	a5,0(s0)
ffffffffc02048cc:	00140a13          	addi	s4,s0,1
ffffffffc02048d0:	0007851b          	sext.w	a0,a5
ffffffffc02048d4:	d3a5                	beqz	a5,ffffffffc0204834 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02048d6:	05e00413          	li	s0,94
ffffffffc02048da:	bf39                	j	ffffffffc02047f8 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02048dc:	000a2403          	lw	s0,0(s4)
ffffffffc02048e0:	b7ad                	j	ffffffffc020484a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02048e2:	000a6603          	lwu	a2,0(s4)
ffffffffc02048e6:	46a1                	li	a3,8
ffffffffc02048e8:	8a2e                	mv	s4,a1
ffffffffc02048ea:	bdb1                	j	ffffffffc0204746 <vprintfmt+0x156>
ffffffffc02048ec:	000a6603          	lwu	a2,0(s4)
ffffffffc02048f0:	46a9                	li	a3,10
ffffffffc02048f2:	8a2e                	mv	s4,a1
ffffffffc02048f4:	bd89                	j	ffffffffc0204746 <vprintfmt+0x156>
ffffffffc02048f6:	000a6603          	lwu	a2,0(s4)
ffffffffc02048fa:	46c1                	li	a3,16
ffffffffc02048fc:	8a2e                	mv	s4,a1
ffffffffc02048fe:	b5a1                	j	ffffffffc0204746 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204900:	9902                	jalr	s2
ffffffffc0204902:	bf09                	j	ffffffffc0204814 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204904:	85a6                	mv	a1,s1
ffffffffc0204906:	02d00513          	li	a0,45
ffffffffc020490a:	e03e                	sd	a5,0(sp)
ffffffffc020490c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020490e:	6782                	ld	a5,0(sp)
ffffffffc0204910:	8a66                	mv	s4,s9
ffffffffc0204912:	40800633          	neg	a2,s0
ffffffffc0204916:	46a9                	li	a3,10
ffffffffc0204918:	b53d                	j	ffffffffc0204746 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020491a:	03b05163          	blez	s11,ffffffffc020493c <vprintfmt+0x34c>
ffffffffc020491e:	02d00693          	li	a3,45
ffffffffc0204922:	f6d79de3          	bne	a5,a3,ffffffffc020489c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0204926:	00002417          	auipc	s0,0x2
ffffffffc020492a:	e5a40413          	addi	s0,s0,-422 # ffffffffc0206780 <default_pmm_manager+0x740>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020492e:	02800793          	li	a5,40
ffffffffc0204932:	02800513          	li	a0,40
ffffffffc0204936:	00140a13          	addi	s4,s0,1
ffffffffc020493a:	bd6d                	j	ffffffffc02047f4 <vprintfmt+0x204>
ffffffffc020493c:	00002a17          	auipc	s4,0x2
ffffffffc0204940:	e45a0a13          	addi	s4,s4,-443 # ffffffffc0206781 <default_pmm_manager+0x741>
ffffffffc0204944:	02800513          	li	a0,40
ffffffffc0204948:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020494c:	05e00413          	li	s0,94
ffffffffc0204950:	b565                	j	ffffffffc02047f8 <vprintfmt+0x208>

ffffffffc0204952 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204952:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204954:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204958:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020495a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020495c:	ec06                	sd	ra,24(sp)
ffffffffc020495e:	f83a                	sd	a4,48(sp)
ffffffffc0204960:	fc3e                	sd	a5,56(sp)
ffffffffc0204962:	e0c2                	sd	a6,64(sp)
ffffffffc0204964:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204966:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204968:	c89ff0ef          	jal	ra,ffffffffc02045f0 <vprintfmt>
}
ffffffffc020496c:	60e2                	ld	ra,24(sp)
ffffffffc020496e:	6161                	addi	sp,sp,80
ffffffffc0204970:	8082                	ret

ffffffffc0204972 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204972:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204976:	2785                	addiw	a5,a5,1
ffffffffc0204978:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc020497c:	02000793          	li	a5,32
ffffffffc0204980:	9f8d                	subw	a5,a5,a1
}
ffffffffc0204982:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204986:	8082                	ret
