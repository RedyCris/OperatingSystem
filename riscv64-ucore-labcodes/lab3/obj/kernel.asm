
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


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53660613          	addi	a2,a2,1334 # ffffffffc0211570 <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	7d1030ef          	jal	ra,ffffffffc020401a <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	49a58593          	addi	a1,a1,1178 # ffffffffc02044e8 <etext+0x2>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	4b250513          	addi	a0,a0,1202 # ffffffffc0204508 <etext+0x22>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0fc000ef          	jal	ra,ffffffffc020015e <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	769020ef          	jal	ra,ffffffffc0202fce <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	423000ef          	jal	ra,ffffffffc0200c90 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	35e000ef          	jal	ra,ffffffffc02003d0 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	2c0010ef          	jal	ra,ffffffffc0201336 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	3ac000ef          	jal	ra,ffffffffc0200426 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3f0000ef          	jal	ra,ffffffffc0200478 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	002040ef          	jal	ra,ffffffffc02040b0 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	7cd030ef          	jal	ra,ffffffffc02040b0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a661                	j	ffffffffc0200478 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	3b6000ef          	jal	ra,ffffffffc02004ac <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200102:	00011317          	auipc	t1,0x11
ffffffffc0200106:	3f630313          	addi	t1,t1,1014 # ffffffffc02114f8 <is_panic>
ffffffffc020010a:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020010e:	715d                	addi	sp,sp,-80
ffffffffc0200110:	ec06                	sd	ra,24(sp)
ffffffffc0200112:	e822                	sd	s0,16(sp)
ffffffffc0200114:	f436                	sd	a3,40(sp)
ffffffffc0200116:	f83a                	sd	a4,48(sp)
ffffffffc0200118:	fc3e                	sd	a5,56(sp)
ffffffffc020011a:	e0c2                	sd	a6,64(sp)
ffffffffc020011c:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020011e:	020e1a63          	bnez	t3,ffffffffc0200152 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200122:	4785                	li	a5,1
ffffffffc0200124:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200128:	8432                	mv	s0,a2
ffffffffc020012a:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020012c:	862e                	mv	a2,a1
ffffffffc020012e:	85aa                	mv	a1,a0
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	3e050513          	addi	a0,a0,992 # ffffffffc0204510 <etext+0x2a>
    va_start(ap, fmt);
ffffffffc0200138:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020013a:	f81ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc020013e:	65a2                	ld	a1,8(sp)
ffffffffc0200140:	8522                	mv	a0,s0
ffffffffc0200142:	f59ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc0200146:	00006517          	auipc	a0,0x6
ffffffffc020014a:	e6250513          	addi	a0,a0,-414 # ffffffffc0205fa8 <default_pmm_manager+0x678>
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200152:	39c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200156:	4501                	li	a0,0
ffffffffc0200158:	130000ef          	jal	ra,ffffffffc0200288 <kmonitor>
    while (1) {
ffffffffc020015c:	bfed                	j	ffffffffc0200156 <__panic+0x54>

ffffffffc020015e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020015e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200160:	00004517          	auipc	a0,0x4
ffffffffc0200164:	3d050513          	addi	a0,a0,976 # ffffffffc0204530 <etext+0x4a>
void print_kerninfo(void) {
ffffffffc0200168:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020016a:	f51ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020016e:	00000597          	auipc	a1,0x0
ffffffffc0200172:	ec458593          	addi	a1,a1,-316 # ffffffffc0200032 <kern_init>
ffffffffc0200176:	00004517          	auipc	a0,0x4
ffffffffc020017a:	3da50513          	addi	a0,a0,986 # ffffffffc0204550 <etext+0x6a>
ffffffffc020017e:	f3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200182:	00004597          	auipc	a1,0x4
ffffffffc0200186:	36458593          	addi	a1,a1,868 # ffffffffc02044e6 <etext>
ffffffffc020018a:	00004517          	auipc	a0,0x4
ffffffffc020018e:	3e650513          	addi	a0,a0,998 # ffffffffc0204570 <etext+0x8a>
ffffffffc0200192:	f29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200196:	0000a597          	auipc	a1,0xa
ffffffffc020019a:	eaa58593          	addi	a1,a1,-342 # ffffffffc020a040 <ide>
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	3f250513          	addi	a0,a0,1010 # ffffffffc0204590 <etext+0xaa>
ffffffffc02001a6:	f15ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc02001aa:	00011597          	auipc	a1,0x11
ffffffffc02001ae:	3c658593          	addi	a1,a1,966 # ffffffffc0211570 <end>
ffffffffc02001b2:	00004517          	auipc	a0,0x4
ffffffffc02001b6:	3fe50513          	addi	a0,a0,1022 # ffffffffc02045b0 <etext+0xca>
ffffffffc02001ba:	f01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001be:	00011597          	auipc	a1,0x11
ffffffffc02001c2:	7b158593          	addi	a1,a1,1969 # ffffffffc021196f <end+0x3ff>
ffffffffc02001c6:	00000797          	auipc	a5,0x0
ffffffffc02001ca:	e6c78793          	addi	a5,a5,-404 # ffffffffc0200032 <kern_init>
ffffffffc02001ce:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001d6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001dc:	95be                	add	a1,a1,a5
ffffffffc02001de:	85a9                	srai	a1,a1,0xa
ffffffffc02001e0:	00004517          	auipc	a0,0x4
ffffffffc02001e4:	3f050513          	addi	a0,a0,1008 # ffffffffc02045d0 <etext+0xea>
}
ffffffffc02001e8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ea:	bdc1                	j	ffffffffc02000ba <cprintf>

ffffffffc02001ec <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	41260613          	addi	a2,a2,1042 # ffffffffc0204600 <etext+0x11a>
ffffffffc02001f6:	04e00593          	li	a1,78
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	41e50513          	addi	a0,a0,1054 # ffffffffc0204618 <etext+0x132>
void print_stackframe(void) {
ffffffffc0200202:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200204:	effff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200208 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020a:	00004617          	auipc	a2,0x4
ffffffffc020020e:	42660613          	addi	a2,a2,1062 # ffffffffc0204630 <etext+0x14a>
ffffffffc0200212:	00004597          	auipc	a1,0x4
ffffffffc0200216:	43e58593          	addi	a1,a1,1086 # ffffffffc0204650 <etext+0x16a>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	43e50513          	addi	a0,a0,1086 # ffffffffc0204658 <etext+0x172>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00004617          	auipc	a2,0x4
ffffffffc020022c:	44060613          	addi	a2,a2,1088 # ffffffffc0204668 <etext+0x182>
ffffffffc0200230:	00004597          	auipc	a1,0x4
ffffffffc0200234:	46058593          	addi	a1,a1,1120 # ffffffffc0204690 <etext+0x1aa>
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	42050513          	addi	a0,a0,1056 # ffffffffc0204658 <etext+0x172>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200244:	00004617          	auipc	a2,0x4
ffffffffc0200248:	45c60613          	addi	a2,a2,1116 # ffffffffc02046a0 <etext+0x1ba>
ffffffffc020024c:	00004597          	auipc	a1,0x4
ffffffffc0200250:	47458593          	addi	a1,a1,1140 # ffffffffc02046c0 <etext+0x1da>
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	40450513          	addi	a0,a0,1028 # ffffffffc0204658 <etext+0x172>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200260:	60a2                	ld	ra,8(sp)
ffffffffc0200262:	4501                	li	a0,0
ffffffffc0200264:	0141                	addi	sp,sp,16
ffffffffc0200266:	8082                	ret

ffffffffc0200268 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200268:	1141                	addi	sp,sp,-16
ffffffffc020026a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020026c:	ef3ff0ef          	jal	ra,ffffffffc020015e <print_kerninfo>
    return 0;
}
ffffffffc0200270:	60a2                	ld	ra,8(sp)
ffffffffc0200272:	4501                	li	a0,0
ffffffffc0200274:	0141                	addi	sp,sp,16
ffffffffc0200276:	8082                	ret

ffffffffc0200278 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200278:	1141                	addi	sp,sp,-16
ffffffffc020027a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020027c:	f71ff0ef          	jal	ra,ffffffffc02001ec <print_stackframe>
    return 0;
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
ffffffffc0200282:	4501                	li	a0,0
ffffffffc0200284:	0141                	addi	sp,sp,16
ffffffffc0200286:	8082                	ret

ffffffffc0200288 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200288:	7115                	addi	sp,sp,-224
ffffffffc020028a:	ed5e                	sd	s7,152(sp)
ffffffffc020028c:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	00004517          	auipc	a0,0x4
ffffffffc0200292:	44250513          	addi	a0,a0,1090 # ffffffffc02046d0 <etext+0x1ea>
kmonitor(struct trapframe *tf) {
ffffffffc0200296:	ed86                	sd	ra,216(sp)
ffffffffc0200298:	e9a2                	sd	s0,208(sp)
ffffffffc020029a:	e5a6                	sd	s1,200(sp)
ffffffffc020029c:	e1ca                	sd	s2,192(sp)
ffffffffc020029e:	fd4e                	sd	s3,184(sp)
ffffffffc02002a0:	f952                	sd	s4,176(sp)
ffffffffc02002a2:	f556                	sd	s5,168(sp)
ffffffffc02002a4:	f15a                	sd	s6,160(sp)
ffffffffc02002a6:	e962                	sd	s8,144(sp)
ffffffffc02002a8:	e566                	sd	s9,136(sp)
ffffffffc02002aa:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ac:	e0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002b0:	00004517          	auipc	a0,0x4
ffffffffc02002b4:	44850513          	addi	a0,a0,1096 # ffffffffc02046f8 <etext+0x212>
ffffffffc02002b8:	e03ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002bc:	000b8563          	beqz	s7,ffffffffc02002c6 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002c0:	855e                	mv	a0,s7
ffffffffc02002c2:	48c000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc02002c6:	00004c17          	auipc	s8,0x4
ffffffffc02002ca:	49ac0c13          	addi	s8,s8,1178 # ffffffffc0204760 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc02002ce:	00005917          	auipc	s2,0x5
ffffffffc02002d2:	20290913          	addi	s2,s2,514 # ffffffffc02054d0 <commands+0xd70>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d6:	00004497          	auipc	s1,0x4
ffffffffc02002da:	44a48493          	addi	s1,s1,1098 # ffffffffc0204720 <etext+0x23a>
        if (argc == MAXARGS - 1) {
ffffffffc02002de:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002e0:	00004b17          	auipc	s6,0x4
ffffffffc02002e4:	448b0b13          	addi	s6,s6,1096 # ffffffffc0204728 <etext+0x242>
        argv[argc ++] = buf;
ffffffffc02002e8:	00004a17          	auipc	s4,0x4
ffffffffc02002ec:	368a0a13          	addi	s4,s4,872 # ffffffffc0204650 <etext+0x16a>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc02002f2:	854a                	mv	a0,s2
ffffffffc02002f4:	13e040ef          	jal	ra,ffffffffc0204432 <readline>
ffffffffc02002f8:	842a                	mv	s0,a0
ffffffffc02002fa:	dd65                	beqz	a0,ffffffffc02002f2 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fc:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200300:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200302:	e1bd                	bnez	a1,ffffffffc0200368 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc0200304:	fe0c87e3          	beqz	s9,ffffffffc02002f2 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	6582                	ld	a1,0(sp)
ffffffffc020030a:	00004d17          	auipc	s10,0x4
ffffffffc020030e:	456d0d13          	addi	s10,s10,1110 # ffffffffc0204760 <commands>
        argv[argc ++] = buf;
ffffffffc0200312:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200314:	4401                	li	s0,0
ffffffffc0200316:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	4cf030ef          	jal	ra,ffffffffc0203fe6 <strcmp>
ffffffffc020031c:	c919                	beqz	a0,ffffffffc0200332 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020031e:	2405                	addiw	s0,s0,1
ffffffffc0200320:	0b540063          	beq	s0,s5,ffffffffc02003c0 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200324:	000d3503          	ld	a0,0(s10)
ffffffffc0200328:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020032a:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020032c:	4bb030ef          	jal	ra,ffffffffc0203fe6 <strcmp>
ffffffffc0200330:	f57d                	bnez	a0,ffffffffc020031e <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200332:	00141793          	slli	a5,s0,0x1
ffffffffc0200336:	97a2                	add	a5,a5,s0
ffffffffc0200338:	078e                	slli	a5,a5,0x3
ffffffffc020033a:	97e2                	add	a5,a5,s8
ffffffffc020033c:	6b9c                	ld	a5,16(a5)
ffffffffc020033e:	865e                	mv	a2,s7
ffffffffc0200340:	002c                	addi	a1,sp,8
ffffffffc0200342:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200346:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200348:	fa0555e3          	bgez	a0,ffffffffc02002f2 <kmonitor+0x6a>
}
ffffffffc020034c:	60ee                	ld	ra,216(sp)
ffffffffc020034e:	644e                	ld	s0,208(sp)
ffffffffc0200350:	64ae                	ld	s1,200(sp)
ffffffffc0200352:	690e                	ld	s2,192(sp)
ffffffffc0200354:	79ea                	ld	s3,184(sp)
ffffffffc0200356:	7a4a                	ld	s4,176(sp)
ffffffffc0200358:	7aaa                	ld	s5,168(sp)
ffffffffc020035a:	7b0a                	ld	s6,160(sp)
ffffffffc020035c:	6bea                	ld	s7,152(sp)
ffffffffc020035e:	6c4a                	ld	s8,144(sp)
ffffffffc0200360:	6caa                	ld	s9,136(sp)
ffffffffc0200362:	6d0a                	ld	s10,128(sp)
ffffffffc0200364:	612d                	addi	sp,sp,224
ffffffffc0200366:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200368:	8526                	mv	a0,s1
ffffffffc020036a:	49b030ef          	jal	ra,ffffffffc0204004 <strchr>
ffffffffc020036e:	c901                	beqz	a0,ffffffffc020037e <kmonitor+0xf6>
ffffffffc0200370:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200374:	00040023          	sb	zero,0(s0)
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	d5c9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc020037c:	b7f5                	j	ffffffffc0200368 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020037e:	00044783          	lbu	a5,0(s0)
ffffffffc0200382:	d3c9                	beqz	a5,ffffffffc0200304 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200384:	033c8963          	beq	s9,s3,ffffffffc02003b6 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200388:	003c9793          	slli	a5,s9,0x3
ffffffffc020038c:	0118                	addi	a4,sp,128
ffffffffc020038e:	97ba                	add	a5,a5,a4
ffffffffc0200390:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200394:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200398:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020039a:	e591                	bnez	a1,ffffffffc02003a6 <kmonitor+0x11e>
ffffffffc020039c:	b7b5                	j	ffffffffc0200308 <kmonitor+0x80>
ffffffffc020039e:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003a2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a4:	d1a5                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003a6:	8526                	mv	a0,s1
ffffffffc02003a8:	45d030ef          	jal	ra,ffffffffc0204004 <strchr>
ffffffffc02003ac:	d96d                	beqz	a0,ffffffffc020039e <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ae:	00044583          	lbu	a1,0(s0)
ffffffffc02003b2:	d9a9                	beqz	a1,ffffffffc0200304 <kmonitor+0x7c>
ffffffffc02003b4:	bf55                	j	ffffffffc0200368 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003b6:	45c1                	li	a1,16
ffffffffc02003b8:	855a                	mv	a0,s6
ffffffffc02003ba:	d01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003be:	b7e9                	j	ffffffffc0200388 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	00004517          	auipc	a0,0x4
ffffffffc02003c6:	38650513          	addi	a0,a0,902 # ffffffffc0204748 <etext+0x262>
ffffffffc02003ca:	cf1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003ce:	b715                	j	ffffffffc02002f2 <kmonitor+0x6a>

ffffffffc02003d0 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02003d0:	8082                	ret

ffffffffc02003d2 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02003d2:	00253513          	sltiu	a0,a0,2
ffffffffc02003d6:	8082                	ret

ffffffffc02003d8 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02003d8:	03800513          	li	a0,56
ffffffffc02003dc:	8082                	ret

ffffffffc02003de <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003de:	0000a797          	auipc	a5,0xa
ffffffffc02003e2:	c6278793          	addi	a5,a5,-926 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02003e6:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02003ea:	1141                	addi	sp,sp,-16
ffffffffc02003ec:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003ee:	95be                	add	a1,a1,a5
ffffffffc02003f0:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02003f4:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02003f6:	437030ef          	jal	ra,ffffffffc020402c <memcpy>
    return 0;
}
ffffffffc02003fa:	60a2                	ld	ra,8(sp)
ffffffffc02003fc:	4501                	li	a0,0
ffffffffc02003fe:	0141                	addi	sp,sp,16
ffffffffc0200400:	8082                	ret

ffffffffc0200402 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc0200402:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200406:	0000a517          	auipc	a0,0xa
ffffffffc020040a:	c3a50513          	addi	a0,a0,-966 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc020040e:	1141                	addi	sp,sp,-16
ffffffffc0200410:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200412:	953e                	add	a0,a0,a5
ffffffffc0200414:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200418:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020041a:	413030ef          	jal	ra,ffffffffc020402c <memcpy>
    return 0;
}
ffffffffc020041e:	60a2                	ld	ra,8(sp)
ffffffffc0200420:	4501                	li	a0,0
ffffffffc0200422:	0141                	addi	sp,sp,16
ffffffffc0200424:	8082                	ret

ffffffffc0200426 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200426:	67e1                	lui	a5,0x18
ffffffffc0200428:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020042c:	00011717          	auipc	a4,0x11
ffffffffc0200430:	0cf73e23          	sd	a5,220(a4) # ffffffffc0211508 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200434:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200438:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043a:	953e                	add	a0,a0,a5
ffffffffc020043c:	4601                	li	a2,0
ffffffffc020043e:	4881                	li	a7,0
ffffffffc0200440:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200444:	02000793          	li	a5,32
ffffffffc0200448:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	00004517          	auipc	a0,0x4
ffffffffc0200450:	35c50513          	addi	a0,a0,860 # ffffffffc02047a8 <commands+0x48>
    ticks = 0;
ffffffffc0200454:	00011797          	auipc	a5,0x11
ffffffffc0200458:	0a07b623          	sd	zero,172(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020045c:	b9b9                	j	ffffffffc02000ba <cprintf>

ffffffffc020045e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020045e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200462:	00011797          	auipc	a5,0x11
ffffffffc0200466:	0a67b783          	ld	a5,166(a5) # ffffffffc0211508 <timebase>
ffffffffc020046a:	953e                	add	a0,a0,a5
ffffffffc020046c:	4581                	li	a1,0
ffffffffc020046e:	4601                	li	a2,0
ffffffffc0200470:	4881                	li	a7,0
ffffffffc0200472:	00000073          	ecall
ffffffffc0200476:	8082                	ret

ffffffffc0200478 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200478:	100027f3          	csrr	a5,sstatus
ffffffffc020047c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020047e:	0ff57513          	zext.b	a0,a0
ffffffffc0200482:	e799                	bnez	a5,ffffffffc0200490 <cons_putc+0x18>
ffffffffc0200484:	4581                	li	a1,0
ffffffffc0200486:	4601                	li	a2,0
ffffffffc0200488:	4885                	li	a7,1
ffffffffc020048a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020048e:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200490:	1101                	addi	sp,sp,-32
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200496:	058000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020049a:	6522                	ld	a0,8(sp)
ffffffffc020049c:	4581                	li	a1,0
ffffffffc020049e:	4601                	li	a2,0
ffffffffc02004a0:	4885                	li	a7,1
ffffffffc02004a2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004a6:	60e2                	ld	ra,24(sp)
ffffffffc02004a8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004aa:	a83d                	j	ffffffffc02004e8 <intr_enable>

ffffffffc02004ac <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ac:	100027f3          	csrr	a5,sstatus
ffffffffc02004b0:	8b89                	andi	a5,a5,2
ffffffffc02004b2:	eb89                	bnez	a5,ffffffffc02004c4 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004b4:	4501                	li	a0,0
ffffffffc02004b6:	4581                	li	a1,0
ffffffffc02004b8:	4601                	li	a2,0
ffffffffc02004ba:	4889                	li	a7,2
ffffffffc02004bc:	00000073          	ecall
ffffffffc02004c0:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02004c2:	8082                	ret
int cons_getc(void) {
ffffffffc02004c4:	1101                	addi	sp,sp,-32
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02004c8:	026000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02004cc:	4501                	li	a0,0
ffffffffc02004ce:	4581                	li	a1,0
ffffffffc02004d0:	4601                	li	a2,0
ffffffffc02004d2:	4889                	li	a7,2
ffffffffc02004d4:	00000073          	ecall
ffffffffc02004d8:	2501                	sext.w	a0,a0
ffffffffc02004da:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02004dc:	00c000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc02004e0:	60e2                	ld	ra,24(sp)
ffffffffc02004e2:	6522                	ld	a0,8(sp)
ffffffffc02004e4:	6105                	addi	sp,sp,32
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	2a450513          	addi	a0,a0,676 # ffffffffc02047c8 <commands+0x68>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	fe053503          	ld	a0,-32(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	5210006f          	j	ffffffffc0201268 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	29c60613          	addi	a2,a2,668 # ffffffffc02047e8 <commands+0x88>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	2a850513          	addi	a0,a0,680 # ffffffffc0204800 <commands+0xa0>
ffffffffc0200560:	ba3ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	28e50513          	addi	a0,a0,654 # ffffffffc0204818 <commands+0xb8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	29650513          	addi	a0,a0,662 # ffffffffc0204830 <commands+0xd0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	2a050513          	addi	a0,a0,672 # ffffffffc0204848 <commands+0xe8>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	2aa50513          	addi	a0,a0,682 # ffffffffc0204860 <commands+0x100>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	2b450513          	addi	a0,a0,692 # ffffffffc0204878 <commands+0x118>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	2be50513          	addi	a0,a0,702 # ffffffffc0204890 <commands+0x130>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	2c850513          	addi	a0,a0,712 # ffffffffc02048a8 <commands+0x148>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	2d250513          	addi	a0,a0,722 # ffffffffc02048c0 <commands+0x160>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	2dc50513          	addi	a0,a0,732 # ffffffffc02048d8 <commands+0x178>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	2e650513          	addi	a0,a0,742 # ffffffffc02048f0 <commands+0x190>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	2f050513          	addi	a0,a0,752 # ffffffffc0204908 <commands+0x1a8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	2fa50513          	addi	a0,a0,762 # ffffffffc0204920 <commands+0x1c0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	30450513          	addi	a0,a0,772 # ffffffffc0204938 <commands+0x1d8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	30e50513          	addi	a0,a0,782 # ffffffffc0204950 <commands+0x1f0>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	31850513          	addi	a0,a0,792 # ffffffffc0204968 <commands+0x208>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	32250513          	addi	a0,a0,802 # ffffffffc0204980 <commands+0x220>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	32c50513          	addi	a0,a0,812 # ffffffffc0204998 <commands+0x238>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	33650513          	addi	a0,a0,822 # ffffffffc02049b0 <commands+0x250>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	34050513          	addi	a0,a0,832 # ffffffffc02049c8 <commands+0x268>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	34a50513          	addi	a0,a0,842 # ffffffffc02049e0 <commands+0x280>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	35450513          	addi	a0,a0,852 # ffffffffc02049f8 <commands+0x298>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	35e50513          	addi	a0,a0,862 # ffffffffc0204a10 <commands+0x2b0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	36850513          	addi	a0,a0,872 # ffffffffc0204a28 <commands+0x2c8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	37250513          	addi	a0,a0,882 # ffffffffc0204a40 <commands+0x2e0>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	37c50513          	addi	a0,a0,892 # ffffffffc0204a58 <commands+0x2f8>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	38650513          	addi	a0,a0,902 # ffffffffc0204a70 <commands+0x310>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	39050513          	addi	a0,a0,912 # ffffffffc0204a88 <commands+0x328>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	39a50513          	addi	a0,a0,922 # ffffffffc0204aa0 <commands+0x340>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	3a450513          	addi	a0,a0,932 # ffffffffc0204ab8 <commands+0x358>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	3ae50513          	addi	a0,a0,942 # ffffffffc0204ad0 <commands+0x370>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	3b850513          	addi	a0,a0,952 # ffffffffc0204ae8 <commands+0x388>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	3be50513          	addi	a0,a0,958 # ffffffffc0204b00 <commands+0x3a0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	3c250513          	addi	a0,a0,962 # ffffffffc0204b18 <commands+0x3b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	3c250513          	addi	a0,a0,962 # ffffffffc0204b30 <commands+0x3d0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	3ca50513          	addi	a0,a0,970 # ffffffffc0204b48 <commands+0x3e8>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	3d250513          	addi	a0,a0,978 # ffffffffc0204b60 <commands+0x400>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	3d650513          	addi	a0,a0,982 # ffffffffc0204b78 <commands+0x418>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	48270713          	addi	a4,a4,1154 # ffffffffc0204c40 <commands+0x4e0>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	42050513          	addi	a0,a0,1056 # ffffffffc0204bf0 <commands+0x490>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	3f450513          	addi	a0,a0,1012 # ffffffffc0204bd0 <commands+0x470>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	3a850513          	addi	a0,a0,936 # ffffffffc0204b90 <commands+0x430>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	3bc50513          	addi	a0,a0,956 # ffffffffc0204bb0 <commands+0x450>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c5bff0ef          	jal	ra,ffffffffc020045e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	3fa50513          	addi	a0,a0,1018 # ffffffffc0204c20 <commands+0x4c0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	3d650513          	addi	a0,a0,982 # ffffffffc0204c10 <commands+0x4b0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	5cc70713          	addi	a4,a4,1484 # ffffffffc0204e28 <commands+0x6c8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	5a250513          	addi	a0,a0,1442 # ffffffffc0204e10 <commands+0x6b0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	3e050513          	addi	a0,a0,992 # ffffffffc0204c70 <commands+0x510>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	3ec50513          	addi	a0,a0,1004 # ffffffffc0204c90 <commands+0x530>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	40250513          	addi	a0,a0,1026 # ffffffffc0204cb0 <commands+0x550>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	41050513          	addi	a0,a0,1040 # ffffffffc0204cc8 <commands+0x568>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	41650513          	addi	a0,a0,1046 # ffffffffc0204cd8 <commands+0x578>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	42c50513          	addi	a0,a0,1068 # ffffffffc0204cf8 <commands+0x598>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	42660613          	addi	a2,a2,1062 # ffffffffc0204d10 <commands+0x5b0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	f0a50513          	addi	a0,a0,-246 # ffffffffc0204800 <commands+0xa0>
ffffffffc02008fe:	805ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	42e50513          	addi	a0,a0,1070 # ffffffffc0204d30 <commands+0x5d0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	43c50513          	addi	a0,a0,1084 # ffffffffc0204d48 <commands+0x5e8>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	3e660613          	addi	a2,a2,998 # ffffffffc0204d10 <commands+0x5b0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	eca50513          	addi	a0,a0,-310 # ffffffffc0204800 <commands+0xa0>
ffffffffc020093e:	fc4ff0ef          	jal	ra,ffffffffc0200102 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	41e50513          	addi	a0,a0,1054 # ffffffffc0204d60 <commands+0x600>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	43450513          	addi	a0,a0,1076 # ffffffffc0204d80 <commands+0x620>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	44a50513          	addi	a0,a0,1098 # ffffffffc0204da0 <commands+0x640>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	46050513          	addi	a0,a0,1120 # ffffffffc0204dc0 <commands+0x660>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	47650513          	addi	a0,a0,1142 # ffffffffc0204de0 <commands+0x680>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	48450513          	addi	a0,a0,1156 # ffffffffc0204df8 <commands+0x698>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	37c60613          	addi	a2,a2,892 # ffffffffc0204d10 <commands+0x5b0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	e6050513          	addi	a0,a0,-416 # ffffffffc0204800 <commands+0xa0>
ffffffffc02009a8:	f5aff0ef          	jal	ra,ffffffffc0200102 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	35060613          	addi	a2,a2,848 # ffffffffc0204d10 <commands+0x5b0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	e3450513          	addi	a0,a0,-460 # ffffffffc0204800 <commands+0xa0>
ffffffffc02009d4:	f2eff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ab0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0200ab2:	00004697          	auipc	a3,0x4
ffffffffc0200ab6:	3b668693          	addi	a3,a3,950 # ffffffffc0204e68 <commands+0x708>
ffffffffc0200aba:	00004617          	auipc	a2,0x4
ffffffffc0200abe:	3ce60613          	addi	a2,a2,974 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200ac2:	07d00593          	li	a1,125
ffffffffc0200ac6:	00004517          	auipc	a0,0x4
ffffffffc0200aca:	3da50513          	addi	a0,a0,986 # ffffffffc0204ea0 <commands+0x740>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0200ace:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0200ad0:	e32ff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200ad4 <mm_create>:
mm_create(void) {
ffffffffc0200ad4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ad6:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0200ada:	e022                	sd	s0,0(sp)
ffffffffc0200adc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200ade:	1b2030ef          	jal	ra,ffffffffc0203c90 <kmalloc>
ffffffffc0200ae2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ae4:	c105                	beqz	a0,ffffffffc0200b04 <mm_create+0x30>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae6:	e408                	sd	a0,8(s0)
ffffffffc0200ae8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0200aea:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200aee:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200af2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200af6:	00011797          	auipc	a5,0x11
ffffffffc0200afa:	a3a7a783          	lw	a5,-1478(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200afe:	eb81                	bnez	a5,ffffffffc0200b0e <mm_create+0x3a>
        else mm->sm_priv = NULL;
ffffffffc0200b00:	02053423          	sd	zero,40(a0)
}
ffffffffc0200b04:	60a2                	ld	ra,8(sp)
ffffffffc0200b06:	8522                	mv	a0,s0
ffffffffc0200b08:	6402                	ld	s0,0(sp)
ffffffffc0200b0a:	0141                	addi	sp,sp,16
ffffffffc0200b0c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200b0e:	693000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
}
ffffffffc0200b12:	60a2                	ld	ra,8(sp)
ffffffffc0200b14:	8522                	mv	a0,s0
ffffffffc0200b16:	6402                	ld	s0,0(sp)
ffffffffc0200b18:	0141                	addi	sp,sp,16
ffffffffc0200b1a:	8082                	ret

ffffffffc0200b1c <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b1c:	1101                	addi	sp,sp,-32
ffffffffc0200b1e:	e04a                	sd	s2,0(sp)
ffffffffc0200b20:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b22:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0200b26:	e822                	sd	s0,16(sp)
ffffffffc0200b28:	e426                	sd	s1,8(sp)
ffffffffc0200b2a:	ec06                	sd	ra,24(sp)
ffffffffc0200b2c:	84ae                	mv	s1,a1
ffffffffc0200b2e:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200b30:	160030ef          	jal	ra,ffffffffc0203c90 <kmalloc>
    if (vma != NULL) {
ffffffffc0200b34:	c509                	beqz	a0,ffffffffc0200b3e <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0200b36:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200b3a:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200b3c:	ed00                	sd	s0,24(a0)
}
ffffffffc0200b3e:	60e2                	ld	ra,24(sp)
ffffffffc0200b40:	6442                	ld	s0,16(sp)
ffffffffc0200b42:	64a2                	ld	s1,8(sp)
ffffffffc0200b44:	6902                	ld	s2,0(sp)
ffffffffc0200b46:	6105                	addi	sp,sp,32
ffffffffc0200b48:	8082                	ret

ffffffffc0200b4a <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0200b4a:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc0200b4c:	c505                	beqz	a0,ffffffffc0200b74 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0200b4e:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b50:	c501                	beqz	a0,ffffffffc0200b58 <find_vma+0xe>
ffffffffc0200b52:	651c                	ld	a5,8(a0)
ffffffffc0200b54:	02f5f263          	bgeu	a1,a5,ffffffffc0200b78 <find_vma+0x2e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b58:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc0200b5a:	00f68d63          	beq	a3,a5,ffffffffc0200b74 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0200b5e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b62:	00e5e663          	bltu	a1,a4,ffffffffc0200b6e <find_vma+0x24>
ffffffffc0200b66:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200b6a:	00e5ec63          	bltu	a1,a4,ffffffffc0200b82 <find_vma+0x38>
ffffffffc0200b6e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0200b70:	fef697e3          	bne	a3,a5,ffffffffc0200b5e <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0200b74:	4501                	li	a0,0
}
ffffffffc0200b76:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0200b78:	691c                	ld	a5,16(a0)
ffffffffc0200b7a:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0200b58 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0200b7e:	ea88                	sd	a0,16(a3)
ffffffffc0200b80:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0200b82:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0200b86:	ea88                	sd	a0,16(a3)
ffffffffc0200b88:	8082                	ret

ffffffffc0200b8a <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b8a:	6590                	ld	a2,8(a1)
ffffffffc0200b8c:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0200b90:	1141                	addi	sp,sp,-16
ffffffffc0200b92:	e406                	sd	ra,8(sp)
ffffffffc0200b94:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200b96:	01066763          	bltu	a2,a6,ffffffffc0200ba4 <insert_vma_struct+0x1a>
ffffffffc0200b9a:	a085                	j	ffffffffc0200bfa <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200b9c:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200ba0:	04e66863          	bltu	a2,a4,ffffffffc0200bf0 <insert_vma_struct+0x66>
ffffffffc0200ba4:	86be                	mv	a3,a5
ffffffffc0200ba6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0200ba8:	fef51ae3          	bne	a0,a5,ffffffffc0200b9c <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0200bac:	02a68463          	beq	a3,a0,ffffffffc0200bd4 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0200bb0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200bb4:	fe86b883          	ld	a7,-24(a3)
ffffffffc0200bb8:	08e8f163          	bgeu	a7,a4,ffffffffc0200c3a <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bbc:	04e66f63          	bltu	a2,a4,ffffffffc0200c1a <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc0200bc0:	00f50a63          	beq	a0,a5,ffffffffc0200bd4 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0200bc4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200bc8:	05076963          	bltu	a4,a6,ffffffffc0200c1a <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc0200bcc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0200bd0:	02c77363          	bgeu	a4,a2,ffffffffc0200bf6 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0200bd4:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0200bd6:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0200bd8:	02058613          	addi	a2,a1,32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200bdc:	e390                	sd	a2,0(a5)
ffffffffc0200bde:	e690                	sd	a2,8(a3)
}
ffffffffc0200be0:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200be2:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0200be4:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0200be6:	0017079b          	addiw	a5,a4,1
ffffffffc0200bea:	d11c                	sw	a5,32(a0)
}
ffffffffc0200bec:	0141                	addi	sp,sp,16
ffffffffc0200bee:	8082                	ret
    if (le_prev != list) {
ffffffffc0200bf0:	fca690e3          	bne	a3,a0,ffffffffc0200bb0 <insert_vma_struct+0x26>
ffffffffc0200bf4:	bfd1                	j	ffffffffc0200bc8 <insert_vma_struct+0x3e>
ffffffffc0200bf6:	ebbff0ef          	jal	ra,ffffffffc0200ab0 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0200bfa:	00004697          	auipc	a3,0x4
ffffffffc0200bfe:	2b668693          	addi	a3,a3,694 # ffffffffc0204eb0 <commands+0x750>
ffffffffc0200c02:	00004617          	auipc	a2,0x4
ffffffffc0200c06:	28660613          	addi	a2,a2,646 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200c0a:	08400593          	li	a1,132
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	29250513          	addi	a0,a0,658 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0200c16:	cecff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0200c1a:	00004697          	auipc	a3,0x4
ffffffffc0200c1e:	2d668693          	addi	a3,a3,726 # ffffffffc0204ef0 <commands+0x790>
ffffffffc0200c22:	00004617          	auipc	a2,0x4
ffffffffc0200c26:	26660613          	addi	a2,a2,614 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200c2a:	07c00593          	li	a1,124
ffffffffc0200c2e:	00004517          	auipc	a0,0x4
ffffffffc0200c32:	27250513          	addi	a0,a0,626 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0200c36:	cccff0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0200c3a:	00004697          	auipc	a3,0x4
ffffffffc0200c3e:	29668693          	addi	a3,a3,662 # ffffffffc0204ed0 <commands+0x770>
ffffffffc0200c42:	00004617          	auipc	a2,0x4
ffffffffc0200c46:	24660613          	addi	a2,a2,582 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200c4a:	07b00593          	li	a1,123
ffffffffc0200c4e:	00004517          	auipc	a0,0x4
ffffffffc0200c52:	25250513          	addi	a0,a0,594 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0200c56:	cacff0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0200c5a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0200c5a:	1141                	addi	sp,sp,-16
ffffffffc0200c5c:	e022                	sd	s0,0(sp)
ffffffffc0200c5e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0200c60:	6508                	ld	a0,8(a0)
ffffffffc0200c62:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0200c64:	00a40e63          	beq	s0,a0,ffffffffc0200c80 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200c68:	6118                	ld	a4,0(a0)
ffffffffc0200c6a:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200c6c:	03000593          	li	a1,48
ffffffffc0200c70:	1501                	addi	a0,a0,-32
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200c72:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200c74:	e398                	sd	a4,0(a5)
ffffffffc0200c76:	0d4030ef          	jal	ra,ffffffffc0203d4a <kfree>
    return listelm->next;
ffffffffc0200c7a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200c7c:	fea416e3          	bne	s0,a0,ffffffffc0200c68 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c80:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0200c82:	6402                	ld	s0,0(sp)
ffffffffc0200c84:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c86:	03000593          	li	a1,48
}
ffffffffc0200c8a:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200c8c:	0be0306f          	j	ffffffffc0203d4a <kfree>

ffffffffc0200c90 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0200c90:	715d                	addi	sp,sp,-80
ffffffffc0200c92:	e486                	sd	ra,72(sp)
ffffffffc0200c94:	f44e                	sd	s3,40(sp)
ffffffffc0200c96:	f052                	sd	s4,32(sp)
ffffffffc0200c98:	e0a2                	sd	s0,64(sp)
ffffffffc0200c9a:	fc26                	sd	s1,56(sp)
ffffffffc0200c9c:	f84a                	sd	s2,48(sp)
ffffffffc0200c9e:	ec56                	sd	s5,24(sp)
ffffffffc0200ca0:	e85a                	sd	s6,16(sp)
ffffffffc0200ca2:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200ca4:	707010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc0200ca8:	89aa                	mv	s3,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200caa:	701010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc0200cae:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200cb0:	03000513          	li	a0,48
ffffffffc0200cb4:	7dd020ef          	jal	ra,ffffffffc0203c90 <kmalloc>
    if (mm != NULL) {
ffffffffc0200cb8:	56050863          	beqz	a0,ffffffffc0201228 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc0200cbc:	e508                	sd	a0,8(a0)
ffffffffc0200cbe:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200cc0:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200cc4:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200cc8:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ccc:	00011797          	auipc	a5,0x11
ffffffffc0200cd0:	8647a783          	lw	a5,-1948(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0200cd4:	84aa                	mv	s1,a0
ffffffffc0200cd6:	e7b9                	bnez	a5,ffffffffc0200d24 <vmm_init+0x94>
        else mm->sm_priv = NULL;
ffffffffc0200cd8:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc0200cdc:	03200413          	li	s0,50
ffffffffc0200ce0:	a811                	j	ffffffffc0200cf4 <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc0200ce2:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200ce4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200ce6:	00053c23          	sd	zero,24(a0)
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0200cea:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200cec:	8526                	mv	a0,s1
ffffffffc0200cee:	e9dff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0200cf2:	cc05                	beqz	s0,ffffffffc0200d2a <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200cf4:	03000513          	li	a0,48
ffffffffc0200cf8:	799020ef          	jal	ra,ffffffffc0203c90 <kmalloc>
ffffffffc0200cfc:	85aa                	mv	a1,a0
ffffffffc0200cfe:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d02:	f165                	bnez	a0,ffffffffc0200ce2 <vmm_init+0x52>
        assert(vma != NULL);
ffffffffc0200d04:	00004697          	auipc	a3,0x4
ffffffffc0200d08:	43c68693          	addi	a3,a3,1084 # ffffffffc0205140 <commands+0x9e0>
ffffffffc0200d0c:	00004617          	auipc	a2,0x4
ffffffffc0200d10:	17c60613          	addi	a2,a2,380 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200d14:	0ce00593          	li	a1,206
ffffffffc0200d18:	00004517          	auipc	a0,0x4
ffffffffc0200d1c:	18850513          	addi	a0,a0,392 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0200d20:	be2ff0ef          	jal	ra,ffffffffc0200102 <__panic>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200d24:	47d000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
ffffffffc0200d28:	bf55                	j	ffffffffc0200cdc <vmm_init+0x4c>
ffffffffc0200d2a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d2e:	1f900913          	li	s2,505
ffffffffc0200d32:	a819                	j	ffffffffc0200d48 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc0200d34:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0200d36:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0200d38:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d3c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0200d3e:	8526                	mv	a0,s1
ffffffffc0200d40:	e4bff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0200d44:	03240a63          	beq	s0,s2,ffffffffc0200d78 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200d48:	03000513          	li	a0,48
ffffffffc0200d4c:	745020ef          	jal	ra,ffffffffc0203c90 <kmalloc>
ffffffffc0200d50:	85aa                	mv	a1,a0
ffffffffc0200d52:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0200d56:	fd79                	bnez	a0,ffffffffc0200d34 <vmm_init+0xa4>
        assert(vma != NULL);
ffffffffc0200d58:	00004697          	auipc	a3,0x4
ffffffffc0200d5c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205140 <commands+0x9e0>
ffffffffc0200d60:	00004617          	auipc	a2,0x4
ffffffffc0200d64:	12860613          	addi	a2,a2,296 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200d68:	0d400593          	li	a1,212
ffffffffc0200d6c:	00004517          	auipc	a0,0x4
ffffffffc0200d70:	13450513          	addi	a0,a0,308 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0200d74:	b8eff0ef          	jal	ra,ffffffffc0200102 <__panic>
    return listelm->next;
ffffffffc0200d78:	649c                	ld	a5,8(s1)
ffffffffc0200d7a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0200d7c:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0200d80:	2ef48463          	beq	s1,a5,ffffffffc0201068 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0200d84:	fe87b603          	ld	a2,-24(a5)
ffffffffc0200d88:	ffe70693          	addi	a3,a4,-2
ffffffffc0200d8c:	26d61e63          	bne	a2,a3,ffffffffc0201008 <vmm_init+0x378>
ffffffffc0200d90:	ff07b683          	ld	a3,-16(a5)
ffffffffc0200d94:	26e69a63          	bne	a3,a4,ffffffffc0201008 <vmm_init+0x378>
    for (i = 1; i <= step2; i ++) {
ffffffffc0200d98:	0715                	addi	a4,a4,5
ffffffffc0200d9a:	679c                	ld	a5,8(a5)
ffffffffc0200d9c:	feb712e3          	bne	a4,a1,ffffffffc0200d80 <vmm_init+0xf0>
ffffffffc0200da0:	4b1d                	li	s6,7
ffffffffc0200da2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200da4:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0200da8:	85a2                	mv	a1,s0
ffffffffc0200daa:	8526                	mv	a0,s1
ffffffffc0200dac:	d9fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200db0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc0200db2:	2c050b63          	beqz	a0,ffffffffc0201088 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0200db6:	00140593          	addi	a1,s0,1
ffffffffc0200dba:	8526                	mv	a0,s1
ffffffffc0200dbc:	d8fff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200dc0:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0200dc2:	2e050363          	beqz	a0,ffffffffc02010a8 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0200dc6:	85da                	mv	a1,s6
ffffffffc0200dc8:	8526                	mv	a0,s1
ffffffffc0200dca:	d81ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma3 == NULL);
ffffffffc0200dce:	2e051d63          	bnez	a0,ffffffffc02010c8 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0200dd2:	00340593          	addi	a1,s0,3
ffffffffc0200dd6:	8526                	mv	a0,s1
ffffffffc0200dd8:	d73ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma4 == NULL);
ffffffffc0200ddc:	30051663          	bnez	a0,ffffffffc02010e8 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0200de0:	00440593          	addi	a1,s0,4
ffffffffc0200de4:	8526                	mv	a0,s1
ffffffffc0200de6:	d65ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
        assert(vma5 == NULL);
ffffffffc0200dea:	30051f63          	bnez	a0,ffffffffc0201108 <vmm_init+0x478>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0200dee:	00893783          	ld	a5,8(s2)
ffffffffc0200df2:	24879b63          	bne	a5,s0,ffffffffc0201048 <vmm_init+0x3b8>
ffffffffc0200df6:	01093783          	ld	a5,16(s2)
ffffffffc0200dfa:	25679763          	bne	a5,s6,ffffffffc0201048 <vmm_init+0x3b8>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0200dfe:	008ab783          	ld	a5,8(s5)
ffffffffc0200e02:	22879363          	bne	a5,s0,ffffffffc0201028 <vmm_init+0x398>
ffffffffc0200e06:	010ab783          	ld	a5,16(s5)
ffffffffc0200e0a:	21679f63          	bne	a5,s6,ffffffffc0201028 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0200e0e:	0415                	addi	s0,s0,5
ffffffffc0200e10:	0b15                	addi	s6,s6,5
ffffffffc0200e12:	f9741be3          	bne	s0,s7,ffffffffc0200da8 <vmm_init+0x118>
ffffffffc0200e16:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0200e18:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0200e1a:	85a2                	mv	a1,s0
ffffffffc0200e1c:	8526                	mv	a0,s1
ffffffffc0200e1e:	d2dff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200e22:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0200e26:	c90d                	beqz	a0,ffffffffc0200e58 <vmm_init+0x1c8>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0200e28:	6914                	ld	a3,16(a0)
ffffffffc0200e2a:	6510                	ld	a2,8(a0)
ffffffffc0200e2c:	00004517          	auipc	a0,0x4
ffffffffc0200e30:	1e450513          	addi	a0,a0,484 # ffffffffc0205010 <commands+0x8b0>
ffffffffc0200e34:	a86ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0200e38:	00004697          	auipc	a3,0x4
ffffffffc0200e3c:	20068693          	addi	a3,a3,512 # ffffffffc0205038 <commands+0x8d8>
ffffffffc0200e40:	00004617          	auipc	a2,0x4
ffffffffc0200e44:	04860613          	addi	a2,a2,72 # ffffffffc0204e88 <commands+0x728>
ffffffffc0200e48:	0f600593          	li	a1,246
ffffffffc0200e4c:	00004517          	auipc	a0,0x4
ffffffffc0200e50:	05450513          	addi	a0,a0,84 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0200e54:	aaeff0ef          	jal	ra,ffffffffc0200102 <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0200e58:	147d                	addi	s0,s0,-1
ffffffffc0200e5a:	fd2410e3          	bne	s0,s2,ffffffffc0200e1a <vmm_init+0x18a>
ffffffffc0200e5e:	a811                	j	ffffffffc0200e72 <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e60:	6118                	ld	a4,0(a0)
ffffffffc0200e62:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200e64:	03000593          	li	a1,48
ffffffffc0200e68:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200e6a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200e6c:	e398                	sd	a4,0(a5)
ffffffffc0200e6e:	6dd020ef          	jal	ra,ffffffffc0203d4a <kfree>
    return listelm->next;
ffffffffc0200e72:	6488                	ld	a0,8(s1)
    while ((le = list_next(list)) != list) {
ffffffffc0200e74:	fea496e3          	bne	s1,a0,ffffffffc0200e60 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200e78:	03000593          	li	a1,48
ffffffffc0200e7c:	8526                	mv	a0,s1
ffffffffc0200e7e:	6cd020ef          	jal	ra,ffffffffc0203d4a <kfree>
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200e82:	529010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc0200e86:	3caa1163          	bne	s4,a0,ffffffffc0201248 <vmm_init+0x5b8>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0200e8a:	00004517          	auipc	a0,0x4
ffffffffc0200e8e:	1ee50513          	addi	a0,a0,494 # ffffffffc0205078 <commands+0x918>
ffffffffc0200e92:	a28ff0ef          	jal	ra,ffffffffc02000ba <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0200e96:	515010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc0200e9a:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0200e9c:	03000513          	li	a0,48
ffffffffc0200ea0:	5f1020ef          	jal	ra,ffffffffc0203c90 <kmalloc>
ffffffffc0200ea4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0200ea6:	2a050163          	beqz	a0,ffffffffc0201148 <vmm_init+0x4b8>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200eaa:	00010797          	auipc	a5,0x10
ffffffffc0200eae:	6867a783          	lw	a5,1670(a5) # ffffffffc0211530 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc0200eb2:	e508                	sd	a0,8(a0)
ffffffffc0200eb4:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0200eb6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0200eba:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0200ebe:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0200ec2:	14079063          	bnez	a5,ffffffffc0201002 <vmm_init+0x372>
        else mm->sm_priv = NULL;
ffffffffc0200ec6:	02053423          	sd	zero,40(a0)

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200eca:	00010917          	auipc	s2,0x10
ffffffffc0200ece:	67e93903          	ld	s2,1662(s2) # ffffffffc0211548 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc0200ed2:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc0200ed6:	00010717          	auipc	a4,0x10
ffffffffc0200eda:	62873d23          	sd	s0,1594(a4) # ffffffffc0211510 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0200ede:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc0200ee2:	24079363          	bnez	a5,ffffffffc0201128 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0200ee6:	03000513          	li	a0,48
ffffffffc0200eea:	5a7020ef          	jal	ra,ffffffffc0203c90 <kmalloc>
ffffffffc0200eee:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0200ef0:	28050063          	beqz	a0,ffffffffc0201170 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc0200ef4:	002007b7          	lui	a5,0x200
ffffffffc0200ef8:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0200efc:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0200efe:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0200f00:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f04:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0200f06:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0200f0a:	c81ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f0e:	10000593          	li	a1,256
ffffffffc0200f12:	8522                	mv	a0,s0
ffffffffc0200f14:	c37ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>
ffffffffc0200f18:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0200f1c:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0200f20:	26aa1863          	bne	s4,a0,ffffffffc0201190 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0200f24:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i ++) {
ffffffffc0200f28:	0785                	addi	a5,a5,1
ffffffffc0200f2a:	fee79de3          	bne	a5,a4,ffffffffc0200f24 <vmm_init+0x294>
        sum += i;
ffffffffc0200f2e:	6705                	lui	a4,0x1
ffffffffc0200f30:	10000793          	li	a5,256
ffffffffc0200f34:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0200f38:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0200f3c:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0200f40:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0200f42:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0200f44:	fec79ce3          	bne	a5,a2,ffffffffc0200f3c <vmm_init+0x2ac>
    }
    assert(sum == 0);
ffffffffc0200f48:	26071463          	bnez	a4,ffffffffc02011b0 <vmm_init+0x520>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0200f4c:	4581                	li	a1,0
ffffffffc0200f4e:	854a                	mv	a0,s2
ffffffffc0200f50:	6e5010ef          	jal	ra,ffffffffc0202e34 <page_remove>
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f54:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0200f58:	00010717          	auipc	a4,0x10
ffffffffc0200f5c:	5f873703          	ld	a4,1528(a4) # ffffffffc0211550 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0200f60:	078a                	slli	a5,a5,0x2
ffffffffc0200f62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0200f64:	26e7f663          	bgeu	a5,a4,ffffffffc02011d0 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f68:	00005717          	auipc	a4,0x5
ffffffffc0200f6c:	4f873703          	ld	a4,1272(a4) # ffffffffc0206460 <nbase>
ffffffffc0200f70:	8f99                	sub	a5,a5,a4
ffffffffc0200f72:	00279713          	slli	a4,a5,0x2
ffffffffc0200f76:	97ba                	add	a5,a5,a4
ffffffffc0200f78:	0792                	slli	a5,a5,0x4

    free_page(pde2page(pgdir[0]));
ffffffffc0200f7a:	00010517          	auipc	a0,0x10
ffffffffc0200f7e:	5de53503          	ld	a0,1502(a0) # ffffffffc0211558 <pages>
ffffffffc0200f82:	953e                	add	a0,a0,a5
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	3e5010ef          	jal	ra,ffffffffc0202b6a <free_pages>
    return listelm->next;
ffffffffc0200f8a:	6408                	ld	a0,8(s0)

    pgdir[0] = 0;
ffffffffc0200f8c:	00093023          	sd	zero,0(s2)

    mm->pgdir = NULL;
ffffffffc0200f90:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200f94:	00a40e63          	beq	s0,a0,ffffffffc0200fb0 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200f98:	6118                	ld	a4,0(a0)
ffffffffc0200f9a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0200f9c:	03000593          	li	a1,48
ffffffffc0200fa0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0200fa2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200fa4:	e398                	sd	a4,0(a5)
ffffffffc0200fa6:	5a5020ef          	jal	ra,ffffffffc0203d4a <kfree>
    return listelm->next;
ffffffffc0200faa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0200fac:	fea416e3          	bne	s0,a0,ffffffffc0200f98 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0200fb0:	03000593          	li	a1,48
ffffffffc0200fb4:	8522                	mv	a0,s0
ffffffffc0200fb6:	595020ef          	jal	ra,ffffffffc0203d4a <kfree>
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0200fba:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0200fbc:	00010797          	auipc	a5,0x10
ffffffffc0200fc0:	5407ba23          	sd	zero,1364(a5) # ffffffffc0211510 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fc4:	3e7010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc0200fc8:	22a49063          	bne	s1,a0,ffffffffc02011e8 <vmm_init+0x558>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0200fcc:	00004517          	auipc	a0,0x4
ffffffffc0200fd0:	13c50513          	addi	a0,a0,316 # ffffffffc0205108 <commands+0x9a8>
ffffffffc0200fd4:	8e6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fd8:	3d3010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0200fdc:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0200fde:	22a99563          	bne	s3,a0,ffffffffc0201208 <vmm_init+0x578>
}
ffffffffc0200fe2:	6406                	ld	s0,64(sp)
ffffffffc0200fe4:	60a6                	ld	ra,72(sp)
ffffffffc0200fe6:	74e2                	ld	s1,56(sp)
ffffffffc0200fe8:	7942                	ld	s2,48(sp)
ffffffffc0200fea:	79a2                	ld	s3,40(sp)
ffffffffc0200fec:	7a02                	ld	s4,32(sp)
ffffffffc0200fee:	6ae2                	ld	s5,24(sp)
ffffffffc0200ff0:	6b42                	ld	s6,16(sp)
ffffffffc0200ff2:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ff4:	00004517          	auipc	a0,0x4
ffffffffc0200ff8:	13450513          	addi	a0,a0,308 # ffffffffc0205128 <commands+0x9c8>
}
ffffffffc0200ffc:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0200ffe:	8bcff06f          	j	ffffffffc02000ba <cprintf>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0201002:	19f000ef          	jal	ra,ffffffffc02019a0 <swap_init_mm>
ffffffffc0201006:	b5d1                	j	ffffffffc0200eca <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0201008:	00004697          	auipc	a3,0x4
ffffffffc020100c:	f2068693          	addi	a3,a3,-224 # ffffffffc0204f28 <commands+0x7c8>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	e7860613          	addi	a2,a2,-392 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201018:	0dd00593          	li	a1,221
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	e8450513          	addi	a0,a0,-380 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201024:	8deff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0201028:	00004697          	auipc	a3,0x4
ffffffffc020102c:	fb868693          	addi	a3,a3,-72 # ffffffffc0204fe0 <commands+0x880>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	e5860613          	addi	a2,a2,-424 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201038:	0ee00593          	li	a1,238
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	e6450513          	addi	a0,a0,-412 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201044:	8beff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0201048:	00004697          	auipc	a3,0x4
ffffffffc020104c:	f6868693          	addi	a3,a3,-152 # ffffffffc0204fb0 <commands+0x850>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	e3860613          	addi	a2,a2,-456 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201058:	0ed00593          	li	a1,237
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	e4450513          	addi	a0,a0,-444 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201064:	89eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	ea868693          	addi	a3,a3,-344 # ffffffffc0204f10 <commands+0x7b0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	e1860613          	addi	a2,a2,-488 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201078:	0db00593          	li	a1,219
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	e2450513          	addi	a0,a0,-476 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201084:	87eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma1 != NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	ed868693          	addi	a3,a3,-296 # ffffffffc0204f60 <commands+0x800>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	df860613          	addi	a2,a2,-520 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201098:	0e300593          	li	a1,227
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	e0450513          	addi	a0,a0,-508 # ffffffffc0204ea0 <commands+0x740>
ffffffffc02010a4:	85eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma2 != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	ec868693          	addi	a3,a3,-312 # ffffffffc0204f70 <commands+0x810>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	dd860613          	addi	a2,a2,-552 # ffffffffc0204e88 <commands+0x728>
ffffffffc02010b8:	0e500593          	li	a1,229
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	de450513          	addi	a0,a0,-540 # ffffffffc0204ea0 <commands+0x740>
ffffffffc02010c4:	83eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma3 == NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	eb868693          	addi	a3,a3,-328 # ffffffffc0204f80 <commands+0x820>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	db860613          	addi	a2,a2,-584 # ffffffffc0204e88 <commands+0x728>
ffffffffc02010d8:	0e700593          	li	a1,231
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	dc450513          	addi	a0,a0,-572 # ffffffffc0204ea0 <commands+0x740>
ffffffffc02010e4:	81eff0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma4 == NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	ea868693          	addi	a3,a3,-344 # ffffffffc0204f90 <commands+0x830>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	d9860613          	addi	a2,a2,-616 # ffffffffc0204e88 <commands+0x728>
ffffffffc02010f8:	0e900593          	li	a1,233
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	da450513          	addi	a0,a0,-604 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201104:	ffffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert(vma5 == NULL);
ffffffffc0201108:	00004697          	auipc	a3,0x4
ffffffffc020110c:	e9868693          	addi	a3,a3,-360 # ffffffffc0204fa0 <commands+0x840>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	d7860613          	addi	a2,a2,-648 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201118:	0eb00593          	li	a1,235
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	d8450513          	addi	a0,a0,-636 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201124:	fdffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	f7068693          	addi	a3,a3,-144 # ffffffffc0205098 <commands+0x938>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	d5860613          	addi	a2,a2,-680 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201138:	10d00593          	li	a1,269
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	d6450513          	addi	a0,a0,-668 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201144:	fbffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	00868693          	addi	a3,a3,8 # ffffffffc0205150 <commands+0x9f0>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	d3860613          	addi	a2,a2,-712 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201158:	10a00593          	li	a1,266
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	d4450513          	addi	a0,a0,-700 # ffffffffc0204ea0 <commands+0x740>
    check_mm_struct = mm_create();
ffffffffc0201164:	00010797          	auipc	a5,0x10
ffffffffc0201168:	3a07b623          	sd	zero,940(a5) # ffffffffc0211510 <check_mm_struct>
    assert(check_mm_struct != NULL);
ffffffffc020116c:	f97fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(vma != NULL);
ffffffffc0201170:	00004697          	auipc	a3,0x4
ffffffffc0201174:	fd068693          	addi	a3,a3,-48 # ffffffffc0205140 <commands+0x9e0>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	d1060613          	addi	a2,a2,-752 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201180:	11100593          	li	a1,273
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	d1c50513          	addi	a0,a0,-740 # ffffffffc0204ea0 <commands+0x740>
ffffffffc020118c:	f77fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0201190:	00004697          	auipc	a3,0x4
ffffffffc0201194:	f1868693          	addi	a3,a3,-232 # ffffffffc02050a8 <commands+0x948>
ffffffffc0201198:	00004617          	auipc	a2,0x4
ffffffffc020119c:	cf060613          	addi	a2,a2,-784 # ffffffffc0204e88 <commands+0x728>
ffffffffc02011a0:	11600593          	li	a1,278
ffffffffc02011a4:	00004517          	auipc	a0,0x4
ffffffffc02011a8:	cfc50513          	addi	a0,a0,-772 # ffffffffc0204ea0 <commands+0x740>
ffffffffc02011ac:	f57fe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(sum == 0);
ffffffffc02011b0:	00004697          	auipc	a3,0x4
ffffffffc02011b4:	f1868693          	addi	a3,a3,-232 # ffffffffc02050c8 <commands+0x968>
ffffffffc02011b8:	00004617          	auipc	a2,0x4
ffffffffc02011bc:	cd060613          	addi	a2,a2,-816 # ffffffffc0204e88 <commands+0x728>
ffffffffc02011c0:	12000593          	li	a1,288
ffffffffc02011c4:	00004517          	auipc	a0,0x4
ffffffffc02011c8:	cdc50513          	addi	a0,a0,-804 # ffffffffc0204ea0 <commands+0x740>
ffffffffc02011cc:	f37fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	f0860613          	addi	a2,a2,-248 # ffffffffc02050d8 <commands+0x978>
ffffffffc02011d8:	06500593          	li	a1,101
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	f1c50513          	addi	a0,a0,-228 # ffffffffc02050f8 <commands+0x998>
ffffffffc02011e4:	f1ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	e6868693          	addi	a3,a3,-408 # ffffffffc0205050 <commands+0x8f0>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	c9860613          	addi	a2,a2,-872 # ffffffffc0204e88 <commands+0x728>
ffffffffc02011f8:	12e00593          	li	a1,302
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	ca450513          	addi	a0,a0,-860 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201204:	efffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	e4868693          	addi	a3,a3,-440 # ffffffffc0205050 <commands+0x8f0>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	c7860613          	addi	a2,a2,-904 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201218:	0bd00593          	li	a1,189
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	c8450513          	addi	a0,a0,-892 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201224:	edffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(mm != NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	f4068693          	addi	a3,a3,-192 # ffffffffc0205168 <commands+0xa08>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	c5860613          	addi	a2,a2,-936 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201238:	0c700593          	li	a1,199
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	c6450513          	addi	a0,a0,-924 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201244:	ebffe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	e0868693          	addi	a3,a3,-504 # ffffffffc0205050 <commands+0x8f0>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	c3860613          	addi	a2,a2,-968 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201258:	0fb00593          	li	a1,251
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	c4450513          	addi	a0,a0,-956 # ffffffffc0204ea0 <commands+0x740>
ffffffffc0201264:	e9ffe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201268 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201268:	7179                	addi	sp,sp,-48
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020126a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020126c:	f022                	sd	s0,32(sp)
ffffffffc020126e:	ec26                	sd	s1,24(sp)
ffffffffc0201270:	f406                	sd	ra,40(sp)
ffffffffc0201272:	e84a                	sd	s2,16(sp)
ffffffffc0201274:	8432                	mv	s0,a2
ffffffffc0201276:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201278:	8d3ff0ef          	jal	ra,ffffffffc0200b4a <find_vma>

    pgfault_num++;
ffffffffc020127c:	00010797          	auipc	a5,0x10
ffffffffc0201280:	29c7a783          	lw	a5,668(a5) # ffffffffc0211518 <pgfault_num>
ffffffffc0201284:	2785                	addiw	a5,a5,1
ffffffffc0201286:	00010717          	auipc	a4,0x10
ffffffffc020128a:	28f72923          	sw	a5,658(a4) # ffffffffc0211518 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc020128e:	c159                	beqz	a0,ffffffffc0201314 <do_pgfault+0xac>
ffffffffc0201290:	651c                	ld	a5,8(a0)
ffffffffc0201292:	08f46163          	bltu	s0,a5,ffffffffc0201314 <do_pgfault+0xac>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0201296:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0201298:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020129a:	8b89                	andi	a5,a5,2
ffffffffc020129c:	ebb1                	bnez	a5,ffffffffc02012f0 <do_pgfault+0x88>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc020129e:	75fd                	lui	a1,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a0:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02012a2:	8c6d                	and	s0,s0,a1
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc02012a4:	85a2                	mv	a1,s0
ffffffffc02012a6:	4605                	li	a2,1
ffffffffc02012a8:	13d010ef          	jal	ra,ffffffffc0202be4 <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc02012ac:	610c                	ld	a1,0(a0)
ffffffffc02012ae:	c1b9                	beqz	a1,ffffffffc02012f4 <do_pgfault+0x8c>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02012b0:	00010797          	auipc	a5,0x10
ffffffffc02012b4:	2807a783          	lw	a5,640(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc02012b8:	c7bd                	beqz	a5,ffffffffc0201326 <do_pgfault+0xbe>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page); 
ffffffffc02012ba:	85a2                	mv	a1,s0
ffffffffc02012bc:	0030                	addi	a2,sp,8
ffffffffc02012be:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02012c0:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page); 
ffffffffc02012c2:	00b000ef          	jal	ra,ffffffffc0201acc <swap_in>

            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm); //更新页表，插入新的页表项
ffffffffc02012c6:	65a2                	ld	a1,8(sp)
ffffffffc02012c8:	6c88                	ld	a0,24(s1)
ffffffffc02012ca:	86ca                	mv	a3,s2
ffffffffc02012cc:	8622                	mv	a2,s0
ffffffffc02012ce:	401010ef          	jal	ra,ffffffffc0202ece <page_insert>

            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1); //标记这个页面将来是可以再换出的
ffffffffc02012d2:	6622                	ld	a2,8(sp)
ffffffffc02012d4:	4685                	li	a3,1
ffffffffc02012d6:	85a2                	mv	a1,s0
ffffffffc02012d8:	8526                	mv	a0,s1
ffffffffc02012da:	6d2000ef          	jal	ra,ffffffffc02019ac <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc02012de:	67a2                	ld	a5,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc02012e0:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc02012e2:	e3a0                	sd	s0,64(a5)
failed:
    return ret;
}
ffffffffc02012e4:	70a2                	ld	ra,40(sp)
ffffffffc02012e6:	7402                	ld	s0,32(sp)
ffffffffc02012e8:	64e2                	ld	s1,24(sp)
ffffffffc02012ea:	6942                	ld	s2,16(sp)
ffffffffc02012ec:	6145                	addi	sp,sp,48
ffffffffc02012ee:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc02012f0:	4959                	li	s2,22
ffffffffc02012f2:	b775                	j	ffffffffc020129e <do_pgfault+0x36>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc02012f4:	6c88                	ld	a0,24(s1)
ffffffffc02012f6:	864a                	mv	a2,s2
ffffffffc02012f8:	85a2                	mv	a1,s0
ffffffffc02012fa:	0df020ef          	jal	ra,ffffffffc0203bd8 <pgdir_alloc_page>
ffffffffc02012fe:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0201300:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201302:	f3ed                	bnez	a5,ffffffffc02012e4 <do_pgfault+0x7c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201304:	00004517          	auipc	a0,0x4
ffffffffc0201308:	ea450513          	addi	a0,a0,-348 # ffffffffc02051a8 <commands+0xa48>
ffffffffc020130c:	daffe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201310:	5571                	li	a0,-4
            goto failed;
ffffffffc0201312:	bfc9                	j	ffffffffc02012e4 <do_pgfault+0x7c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0201314:	85a2                	mv	a1,s0
ffffffffc0201316:	00004517          	auipc	a0,0x4
ffffffffc020131a:	e6250513          	addi	a0,a0,-414 # ffffffffc0205178 <commands+0xa18>
ffffffffc020131e:	d9dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0201322:	5575                	li	a0,-3
        goto failed;
ffffffffc0201324:	b7c1                	j	ffffffffc02012e4 <do_pgfault+0x7c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0201326:	00004517          	auipc	a0,0x4
ffffffffc020132a:	eaa50513          	addi	a0,a0,-342 # ffffffffc02051d0 <commands+0xa70>
ffffffffc020132e:	d8dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0201332:	5571                	li	a0,-4
            goto failed;
ffffffffc0201334:	bf45                	j	ffffffffc02012e4 <do_pgfault+0x7c>

ffffffffc0201336 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0201336:	7135                	addi	sp,sp,-160
ffffffffc0201338:	ed06                	sd	ra,152(sp)
ffffffffc020133a:	e922                	sd	s0,144(sp)
ffffffffc020133c:	e526                	sd	s1,136(sp)
ffffffffc020133e:	e14a                	sd	s2,128(sp)
ffffffffc0201340:	fcce                	sd	s3,120(sp)
ffffffffc0201342:	f8d2                	sd	s4,112(sp)
ffffffffc0201344:	f4d6                	sd	s5,104(sp)
ffffffffc0201346:	f0da                	sd	s6,96(sp)
ffffffffc0201348:	ecde                	sd	s7,88(sp)
ffffffffc020134a:	e8e2                	sd	s8,80(sp)
ffffffffc020134c:	e4e6                	sd	s9,72(sp)
ffffffffc020134e:	e0ea                	sd	s10,64(sp)
ffffffffc0201350:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0201352:	2e1020ef          	jal	ra,ffffffffc0203e32 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0201356:	00010697          	auipc	a3,0x10
ffffffffc020135a:	1ca6b683          	ld	a3,458(a3) # ffffffffc0211520 <max_swap_offset>
ffffffffc020135e:	010007b7          	lui	a5,0x1000
ffffffffc0201362:	ff968713          	addi	a4,a3,-7
ffffffffc0201366:	17e1                	addi	a5,a5,-8
ffffffffc0201368:	3ee7e063          	bltu	a5,a4,ffffffffc0201748 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru;//use lru Page Replacement Algorithm
ffffffffc020136c:	00009797          	auipc	a5,0x9
ffffffffc0201370:	c9478793          	addi	a5,a5,-876 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc0201374:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use lru Page Replacement Algorithm
ffffffffc0201376:	00010b17          	auipc	s6,0x10
ffffffffc020137a:	1b2b0b13          	addi	s6,s6,434 # ffffffffc0211528 <sm>
ffffffffc020137e:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0201382:	9702                	jalr	a4
ffffffffc0201384:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0201386:	c10d                	beqz	a0,ffffffffc02013a8 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0201388:	60ea                	ld	ra,152(sp)
ffffffffc020138a:	644a                	ld	s0,144(sp)
ffffffffc020138c:	64aa                	ld	s1,136(sp)
ffffffffc020138e:	690a                	ld	s2,128(sp)
ffffffffc0201390:	7a46                	ld	s4,112(sp)
ffffffffc0201392:	7aa6                	ld	s5,104(sp)
ffffffffc0201394:	7b06                	ld	s6,96(sp)
ffffffffc0201396:	6be6                	ld	s7,88(sp)
ffffffffc0201398:	6c46                	ld	s8,80(sp)
ffffffffc020139a:	6ca6                	ld	s9,72(sp)
ffffffffc020139c:	6d06                	ld	s10,64(sp)
ffffffffc020139e:	7de2                	ld	s11,56(sp)
ffffffffc02013a0:	854e                	mv	a0,s3
ffffffffc02013a2:	79e6                	ld	s3,120(sp)
ffffffffc02013a4:	610d                	addi	sp,sp,160
ffffffffc02013a6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013a8:	000b3783          	ld	a5,0(s6)
ffffffffc02013ac:	00004517          	auipc	a0,0x4
ffffffffc02013b0:	e7c50513          	addi	a0,a0,-388 # ffffffffc0205228 <commands+0xac8>
ffffffffc02013b4:	00010497          	auipc	s1,0x10
ffffffffc02013b8:	d2c48493          	addi	s1,s1,-724 # ffffffffc02110e0 <free_area>
ffffffffc02013bc:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02013be:	4785                	li	a5,1
ffffffffc02013c0:	00010717          	auipc	a4,0x10
ffffffffc02013c4:	16f72823          	sw	a5,368(a4) # ffffffffc0211530 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02013c8:	cf3fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02013cc:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02013ce:	4401                	li	s0,0
ffffffffc02013d0:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013d2:	2c978163          	beq	a5,s1,ffffffffc0201694 <swap_init+0x35e>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013d6:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013da:	8b09                	andi	a4,a4,2
ffffffffc02013dc:	2a070e63          	beqz	a4,ffffffffc0201698 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc02013e0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013e4:	679c                	ld	a5,8(a5)
ffffffffc02013e6:	2d05                	addiw	s10,s10,1
ffffffffc02013e8:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02013ea:	fe9796e3          	bne	a5,s1,ffffffffc02013d6 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc02013ee:	8922                	mv	s2,s0
ffffffffc02013f0:	7ba010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc02013f4:	47251663          	bne	a0,s2,ffffffffc0201860 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02013f8:	8622                	mv	a2,s0
ffffffffc02013fa:	85ea                	mv	a1,s10
ffffffffc02013fc:	00004517          	auipc	a0,0x4
ffffffffc0201400:	e7450513          	addi	a0,a0,-396 # ffffffffc0205270 <commands+0xb10>
ffffffffc0201404:	cb7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0201408:	eccff0ef          	jal	ra,ffffffffc0200ad4 <mm_create>
ffffffffc020140c:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc020140e:	52050963          	beqz	a0,ffffffffc0201940 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0201412:	00010797          	auipc	a5,0x10
ffffffffc0201416:	0fe78793          	addi	a5,a5,254 # ffffffffc0211510 <check_mm_struct>
ffffffffc020141a:	6398                	ld	a4,0(a5)
ffffffffc020141c:	54071263          	bnez	a4,ffffffffc0201960 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0201420:	00010b97          	auipc	s7,0x10
ffffffffc0201424:	128bbb83          	ld	s7,296(s7) # ffffffffc0211548 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0201428:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc020142c:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020142e:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0201432:	3c071763          	bnez	a4,ffffffffc0201800 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0201436:	6599                	lui	a1,0x6
ffffffffc0201438:	460d                	li	a2,3
ffffffffc020143a:	6505                	lui	a0,0x1
ffffffffc020143c:	ee0ff0ef          	jal	ra,ffffffffc0200b1c <vma_create>
ffffffffc0201440:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0201442:	3c050f63          	beqz	a0,ffffffffc0201820 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0201446:	8556                	mv	a0,s5
ffffffffc0201448:	f42ff0ef          	jal	ra,ffffffffc0200b8a <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020144c:	00004517          	auipc	a0,0x4
ffffffffc0201450:	e6450513          	addi	a0,a0,-412 # ffffffffc02052b0 <commands+0xb50>
ffffffffc0201454:	c67fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0201458:	018ab503          	ld	a0,24(s5)
ffffffffc020145c:	4605                	li	a2,1
ffffffffc020145e:	6585                	lui	a1,0x1
ffffffffc0201460:	784010ef          	jal	ra,ffffffffc0202be4 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0201464:	3c050e63          	beqz	a0,ffffffffc0201840 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201468:	00004517          	auipc	a0,0x4
ffffffffc020146c:	e9850513          	addi	a0,a0,-360 # ffffffffc0205300 <commands+0xba0>
ffffffffc0201470:	00010917          	auipc	s2,0x10
ffffffffc0201474:	bf090913          	addi	s2,s2,-1040 # ffffffffc0211060 <check_rp>
ffffffffc0201478:	c43fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020147c:	00010a17          	auipc	s4,0x10
ffffffffc0201480:	c04a0a13          	addi	s4,s4,-1020 # ffffffffc0211080 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0201484:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0201486:	4505                	li	a0,1
ffffffffc0201488:	650010ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc020148c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0201490:	28050c63          	beqz	a0,ffffffffc0201728 <swap_init+0x3f2>
ffffffffc0201494:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0201496:	8b89                	andi	a5,a5,2
ffffffffc0201498:	26079863          	bnez	a5,ffffffffc0201708 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020149c:	0c21                	addi	s8,s8,8
ffffffffc020149e:	ff4c14e3          	bne	s8,s4,ffffffffc0201486 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02014a2:	609c                	ld	a5,0(s1)
ffffffffc02014a4:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc02014a8:	e084                	sd	s1,0(s1)
ffffffffc02014aa:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc02014ac:	489c                	lw	a5,16(s1)
ffffffffc02014ae:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc02014b0:	00010c17          	auipc	s8,0x10
ffffffffc02014b4:	bb0c0c13          	addi	s8,s8,-1104 # ffffffffc0211060 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc02014b8:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02014ba:	00010797          	auipc	a5,0x10
ffffffffc02014be:	c207ab23          	sw	zero,-970(a5) # ffffffffc02110f0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02014c2:	000c3503          	ld	a0,0(s8)
ffffffffc02014c6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014c8:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc02014ca:	6a0010ef          	jal	ra,ffffffffc0202b6a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02014ce:	ff4c1ae3          	bne	s8,s4,ffffffffc02014c2 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02014d2:	0104ac03          	lw	s8,16(s1)
ffffffffc02014d6:	4791                	li	a5,4
ffffffffc02014d8:	4afc1463          	bne	s8,a5,ffffffffc0201980 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	eac50513          	addi	a0,a0,-340 # ffffffffc0205388 <commands+0xc28>
ffffffffc02014e4:	bd7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014e8:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02014ea:	00010797          	auipc	a5,0x10
ffffffffc02014ee:	0207a723          	sw	zero,46(a5) # ffffffffc0211518 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02014f2:	4529                	li	a0,10
ffffffffc02014f4:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02014f8:	00010597          	auipc	a1,0x10
ffffffffc02014fc:	0205a583          	lw	a1,32(a1) # ffffffffc0211518 <pgfault_num>
ffffffffc0201500:	4805                	li	a6,1
ffffffffc0201502:	00010797          	auipc	a5,0x10
ffffffffc0201506:	01678793          	addi	a5,a5,22 # ffffffffc0211518 <pgfault_num>
ffffffffc020150a:	3f059b63          	bne	a1,a6,ffffffffc0201900 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020150e:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0201512:	4390                	lw	a2,0(a5)
ffffffffc0201514:	2601                	sext.w	a2,a2
ffffffffc0201516:	40b61563          	bne	a2,a1,ffffffffc0201920 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc020151a:	6589                	lui	a1,0x2
ffffffffc020151c:	452d                	li	a0,11
ffffffffc020151e:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0201522:	4390                	lw	a2,0(a5)
ffffffffc0201524:	4809                	li	a6,2
ffffffffc0201526:	2601                	sext.w	a2,a2
ffffffffc0201528:	35061c63          	bne	a2,a6,ffffffffc0201880 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020152c:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0201530:	438c                	lw	a1,0(a5)
ffffffffc0201532:	2581                	sext.w	a1,a1
ffffffffc0201534:	36c59663          	bne	a1,a2,ffffffffc02018a0 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0201538:	658d                	lui	a1,0x3
ffffffffc020153a:	4531                	li	a0,12
ffffffffc020153c:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0201540:	4390                	lw	a2,0(a5)
ffffffffc0201542:	480d                	li	a6,3
ffffffffc0201544:	2601                	sext.w	a2,a2
ffffffffc0201546:	37061d63          	bne	a2,a6,ffffffffc02018c0 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc020154a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc020154e:	438c                	lw	a1,0(a5)
ffffffffc0201550:	2581                	sext.w	a1,a1
ffffffffc0201552:	38c59763          	bne	a1,a2,ffffffffc02018e0 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0201556:	6591                	lui	a1,0x4
ffffffffc0201558:	4535                	li	a0,13
ffffffffc020155a:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc020155e:	4390                	lw	a2,0(a5)
ffffffffc0201560:	2601                	sext.w	a2,a2
ffffffffc0201562:	21861f63          	bne	a2,s8,ffffffffc0201780 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0201566:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc020156a:	439c                	lw	a5,0(a5)
ffffffffc020156c:	2781                	sext.w	a5,a5
ffffffffc020156e:	22c79963          	bne	a5,a2,ffffffffc02017a0 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0201572:	489c                	lw	a5,16(s1)
ffffffffc0201574:	24079663          	bnez	a5,ffffffffc02017c0 <swap_init+0x48a>
ffffffffc0201578:	00010797          	auipc	a5,0x10
ffffffffc020157c:	b0878793          	addi	a5,a5,-1272 # ffffffffc0211080 <swap_in_seq_no>
ffffffffc0201580:	00010617          	auipc	a2,0x10
ffffffffc0201584:	b2860613          	addi	a2,a2,-1240 # ffffffffc02110a8 <swap_out_seq_no>
ffffffffc0201588:	00010517          	auipc	a0,0x10
ffffffffc020158c:	b2050513          	addi	a0,a0,-1248 # ffffffffc02110a8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0201590:	55fd                	li	a1,-1
ffffffffc0201592:	c38c                	sw	a1,0(a5)
ffffffffc0201594:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0201596:	0791                	addi	a5,a5,4
ffffffffc0201598:	0611                	addi	a2,a2,4
ffffffffc020159a:	fef51ce3          	bne	a0,a5,ffffffffc0201592 <swap_init+0x25c>
ffffffffc020159e:	00010817          	auipc	a6,0x10
ffffffffc02015a2:	aa280813          	addi	a6,a6,-1374 # ffffffffc0211040 <check_ptep>
ffffffffc02015a6:	00010897          	auipc	a7,0x10
ffffffffc02015aa:	aba88893          	addi	a7,a7,-1350 # ffffffffc0211060 <check_rp>
ffffffffc02015ae:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc02015b0:	00010c97          	auipc	s9,0x10
ffffffffc02015b4:	fa8c8c93          	addi	s9,s9,-88 # ffffffffc0211558 <pages>
ffffffffc02015b8:	00005c17          	auipc	s8,0x5
ffffffffc02015bc:	ea8c0c13          	addi	s8,s8,-344 # ffffffffc0206460 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02015c0:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015c4:	4601                	li	a2,0
ffffffffc02015c6:	855e                	mv	a0,s7
ffffffffc02015c8:	ec46                	sd	a7,24(sp)
ffffffffc02015ca:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc02015cc:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015ce:	616010ef          	jal	ra,ffffffffc0202be4 <get_pte>
ffffffffc02015d2:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02015d4:	65c2                	ld	a1,16(sp)
ffffffffc02015d6:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02015d8:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc02015dc:	00010317          	auipc	t1,0x10
ffffffffc02015e0:	f7430313          	addi	t1,t1,-140 # ffffffffc0211550 <npage>
ffffffffc02015e4:	16050e63          	beqz	a0,ffffffffc0201760 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02015e8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02015ea:	0017f613          	andi	a2,a5,1
ffffffffc02015ee:	0e060563          	beqz	a2,ffffffffc02016d8 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc02015f2:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02015f6:	078a                	slli	a5,a5,0x2
ffffffffc02015f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015fa:	0ec7fb63          	bgeu	a5,a2,ffffffffc02016f0 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc02015fe:	000c3603          	ld	a2,0(s8)
ffffffffc0201602:	000cb503          	ld	a0,0(s9)
ffffffffc0201606:	0008bf03          	ld	t5,0(a7)
ffffffffc020160a:	8f91                	sub	a5,a5,a2
ffffffffc020160c:	00279613          	slli	a2,a5,0x2
ffffffffc0201610:	97b2                	add	a5,a5,a2
ffffffffc0201612:	0792                	slli	a5,a5,0x4
ffffffffc0201614:	97aa                	add	a5,a5,a0
ffffffffc0201616:	0aff1163          	bne	t5,a5,ffffffffc02016b8 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020161a:	6785                	lui	a5,0x1
ffffffffc020161c:	95be                	add	a1,a1,a5
ffffffffc020161e:	6795                	lui	a5,0x5
ffffffffc0201620:	0821                	addi	a6,a6,8
ffffffffc0201622:	08a1                	addi	a7,a7,8
ffffffffc0201624:	f8f59ee3          	bne	a1,a5,ffffffffc02015c0 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0201628:	00004517          	auipc	a0,0x4
ffffffffc020162c:	e4050513          	addi	a0,a0,-448 # ffffffffc0205468 <commands+0xd08>
ffffffffc0201630:	a8bfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0201634:	000b3783          	ld	a5,0(s6)
ffffffffc0201638:	7f9c                	ld	a5,56(a5)
ffffffffc020163a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020163c:	1a051263          	bnez	a0,ffffffffc02017e0 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0201640:	00093503          	ld	a0,0(s2)
ffffffffc0201644:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0201646:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0201648:	522010ef          	jal	ra,ffffffffc0202b6a <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020164c:	ff491ae3          	bne	s2,s4,ffffffffc0201640 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0201650:	8556                	mv	a0,s5
ffffffffc0201652:	e08ff0ef          	jal	ra,ffffffffc0200c5a <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0201656:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0201658:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc020165c:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc020165e:	7782                	ld	a5,32(sp)
ffffffffc0201660:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201662:	009d8a63          	beq	s11,s1,ffffffffc0201676 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0201666:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc020166a:	008dbd83          	ld	s11,8(s11)
ffffffffc020166e:	3d7d                	addiw	s10,s10,-1
ffffffffc0201670:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201672:	fe9d9ae3          	bne	s11,s1,ffffffffc0201666 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0201676:	8622                	mv	a2,s0
ffffffffc0201678:	85ea                	mv	a1,s10
ffffffffc020167a:	00004517          	auipc	a0,0x4
ffffffffc020167e:	e1e50513          	addi	a0,a0,-482 # ffffffffc0205498 <commands+0xd38>
ffffffffc0201682:	a39fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0201686:	00004517          	auipc	a0,0x4
ffffffffc020168a:	e3250513          	addi	a0,a0,-462 # ffffffffc02054b8 <commands+0xd58>
ffffffffc020168e:	a2dfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201692:	b9dd                	j	ffffffffc0201388 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0201694:	4901                	li	s2,0
ffffffffc0201696:	bba9                	j	ffffffffc02013f0 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0201698:	00004697          	auipc	a3,0x4
ffffffffc020169c:	ba868693          	addi	a3,a3,-1112 # ffffffffc0205240 <commands+0xae0>
ffffffffc02016a0:	00003617          	auipc	a2,0x3
ffffffffc02016a4:	7e860613          	addi	a2,a2,2024 # ffffffffc0204e88 <commands+0x728>
ffffffffc02016a8:	0bb00593          	li	a1,187
ffffffffc02016ac:	00004517          	auipc	a0,0x4
ffffffffc02016b0:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0205218 <commands+0xab8>
ffffffffc02016b4:	a4ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02016b8:	00004697          	auipc	a3,0x4
ffffffffc02016bc:	d8868693          	addi	a3,a3,-632 # ffffffffc0205440 <commands+0xce0>
ffffffffc02016c0:	00003617          	auipc	a2,0x3
ffffffffc02016c4:	7c860613          	addi	a2,a2,1992 # ffffffffc0204e88 <commands+0x728>
ffffffffc02016c8:	0fb00593          	li	a1,251
ffffffffc02016cc:	00004517          	auipc	a0,0x4
ffffffffc02016d0:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0205218 <commands+0xab8>
ffffffffc02016d4:	a2ffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02016d8:	00004617          	auipc	a2,0x4
ffffffffc02016dc:	d4060613          	addi	a2,a2,-704 # ffffffffc0205418 <commands+0xcb8>
ffffffffc02016e0:	07000593          	li	a1,112
ffffffffc02016e4:	00004517          	auipc	a0,0x4
ffffffffc02016e8:	a1450513          	addi	a0,a0,-1516 # ffffffffc02050f8 <commands+0x998>
ffffffffc02016ec:	a17fe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02016f0:	00004617          	auipc	a2,0x4
ffffffffc02016f4:	9e860613          	addi	a2,a2,-1560 # ffffffffc02050d8 <commands+0x978>
ffffffffc02016f8:	06500593          	li	a1,101
ffffffffc02016fc:	00004517          	auipc	a0,0x4
ffffffffc0201700:	9fc50513          	addi	a0,a0,-1540 # ffffffffc02050f8 <commands+0x998>
ffffffffc0201704:	9fffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0201708:	00004697          	auipc	a3,0x4
ffffffffc020170c:	c3868693          	addi	a3,a3,-968 # ffffffffc0205340 <commands+0xbe0>
ffffffffc0201710:	00003617          	auipc	a2,0x3
ffffffffc0201714:	77860613          	addi	a2,a2,1912 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201718:	0dc00593          	li	a1,220
ffffffffc020171c:	00004517          	auipc	a0,0x4
ffffffffc0201720:	afc50513          	addi	a0,a0,-1284 # ffffffffc0205218 <commands+0xab8>
ffffffffc0201724:	9dffe0ef          	jal	ra,ffffffffc0200102 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0201728:	00004697          	auipc	a3,0x4
ffffffffc020172c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0205328 <commands+0xbc8>
ffffffffc0201730:	00003617          	auipc	a2,0x3
ffffffffc0201734:	75860613          	addi	a2,a2,1880 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201738:	0db00593          	li	a1,219
ffffffffc020173c:	00004517          	auipc	a0,0x4
ffffffffc0201740:	adc50513          	addi	a0,a0,-1316 # ffffffffc0205218 <commands+0xab8>
ffffffffc0201744:	9bffe0ef          	jal	ra,ffffffffc0200102 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0201748:	00004617          	auipc	a2,0x4
ffffffffc020174c:	ab060613          	addi	a2,a2,-1360 # ffffffffc02051f8 <commands+0xa98>
ffffffffc0201750:	02800593          	li	a1,40
ffffffffc0201754:	00004517          	auipc	a0,0x4
ffffffffc0201758:	ac450513          	addi	a0,a0,-1340 # ffffffffc0205218 <commands+0xab8>
ffffffffc020175c:	9a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0201760:	00004697          	auipc	a3,0x4
ffffffffc0201764:	ca068693          	addi	a3,a3,-864 # ffffffffc0205400 <commands+0xca0>
ffffffffc0201768:	00003617          	auipc	a2,0x3
ffffffffc020176c:	72060613          	addi	a2,a2,1824 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201770:	0fa00593          	li	a1,250
ffffffffc0201774:	00004517          	auipc	a0,0x4
ffffffffc0201778:	aa450513          	addi	a0,a0,-1372 # ffffffffc0205218 <commands+0xab8>
ffffffffc020177c:	987fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc0201780:	00004697          	auipc	a3,0x4
ffffffffc0201784:	c6068693          	addi	a3,a3,-928 # ffffffffc02053e0 <commands+0xc80>
ffffffffc0201788:	00003617          	auipc	a2,0x3
ffffffffc020178c:	70060613          	addi	a2,a2,1792 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201790:	09e00593          	li	a1,158
ffffffffc0201794:	00004517          	auipc	a0,0x4
ffffffffc0201798:	a8450513          	addi	a0,a0,-1404 # ffffffffc0205218 <commands+0xab8>
ffffffffc020179c:	967fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==4);
ffffffffc02017a0:	00004697          	auipc	a3,0x4
ffffffffc02017a4:	c4068693          	addi	a3,a3,-960 # ffffffffc02053e0 <commands+0xc80>
ffffffffc02017a8:	00003617          	auipc	a2,0x3
ffffffffc02017ac:	6e060613          	addi	a2,a2,1760 # ffffffffc0204e88 <commands+0x728>
ffffffffc02017b0:	0a000593          	li	a1,160
ffffffffc02017b4:	00004517          	auipc	a0,0x4
ffffffffc02017b8:	a6450513          	addi	a0,a0,-1436 # ffffffffc0205218 <commands+0xab8>
ffffffffc02017bc:	947fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert( nr_free == 0);         
ffffffffc02017c0:	00004697          	auipc	a3,0x4
ffffffffc02017c4:	c3068693          	addi	a3,a3,-976 # ffffffffc02053f0 <commands+0xc90>
ffffffffc02017c8:	00003617          	auipc	a2,0x3
ffffffffc02017cc:	6c060613          	addi	a2,a2,1728 # ffffffffc0204e88 <commands+0x728>
ffffffffc02017d0:	0f200593          	li	a1,242
ffffffffc02017d4:	00004517          	auipc	a0,0x4
ffffffffc02017d8:	a4450513          	addi	a0,a0,-1468 # ffffffffc0205218 <commands+0xab8>
ffffffffc02017dc:	927fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(ret==0);
ffffffffc02017e0:	00004697          	auipc	a3,0x4
ffffffffc02017e4:	cb068693          	addi	a3,a3,-848 # ffffffffc0205490 <commands+0xd30>
ffffffffc02017e8:	00003617          	auipc	a2,0x3
ffffffffc02017ec:	6a060613          	addi	a2,a2,1696 # ffffffffc0204e88 <commands+0x728>
ffffffffc02017f0:	10100593          	li	a1,257
ffffffffc02017f4:	00004517          	auipc	a0,0x4
ffffffffc02017f8:	a2450513          	addi	a0,a0,-1500 # ffffffffc0205218 <commands+0xab8>
ffffffffc02017fc:	907fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0201800:	00004697          	auipc	a3,0x4
ffffffffc0201804:	89868693          	addi	a3,a3,-1896 # ffffffffc0205098 <commands+0x938>
ffffffffc0201808:	00003617          	auipc	a2,0x3
ffffffffc020180c:	68060613          	addi	a2,a2,1664 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201810:	0cb00593          	li	a1,203
ffffffffc0201814:	00004517          	auipc	a0,0x4
ffffffffc0201818:	a0450513          	addi	a0,a0,-1532 # ffffffffc0205218 <commands+0xab8>
ffffffffc020181c:	8e7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(vma != NULL);
ffffffffc0201820:	00004697          	auipc	a3,0x4
ffffffffc0201824:	92068693          	addi	a3,a3,-1760 # ffffffffc0205140 <commands+0x9e0>
ffffffffc0201828:	00003617          	auipc	a2,0x3
ffffffffc020182c:	66060613          	addi	a2,a2,1632 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201830:	0ce00593          	li	a1,206
ffffffffc0201834:	00004517          	auipc	a0,0x4
ffffffffc0201838:	9e450513          	addi	a0,a0,-1564 # ffffffffc0205218 <commands+0xab8>
ffffffffc020183c:	8c7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0201840:	00004697          	auipc	a3,0x4
ffffffffc0201844:	aa868693          	addi	a3,a3,-1368 # ffffffffc02052e8 <commands+0xb88>
ffffffffc0201848:	00003617          	auipc	a2,0x3
ffffffffc020184c:	64060613          	addi	a2,a2,1600 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201850:	0d600593          	li	a1,214
ffffffffc0201854:	00004517          	auipc	a0,0x4
ffffffffc0201858:	9c450513          	addi	a0,a0,-1596 # ffffffffc0205218 <commands+0xab8>
ffffffffc020185c:	8a7fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(total == nr_free_pages());
ffffffffc0201860:	00004697          	auipc	a3,0x4
ffffffffc0201864:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205250 <commands+0xaf0>
ffffffffc0201868:	00003617          	auipc	a2,0x3
ffffffffc020186c:	62060613          	addi	a2,a2,1568 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201870:	0be00593          	li	a1,190
ffffffffc0201874:	00004517          	auipc	a0,0x4
ffffffffc0201878:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205218 <commands+0xab8>
ffffffffc020187c:	887fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc0201880:	00004697          	auipc	a3,0x4
ffffffffc0201884:	b4068693          	addi	a3,a3,-1216 # ffffffffc02053c0 <commands+0xc60>
ffffffffc0201888:	00003617          	auipc	a2,0x3
ffffffffc020188c:	60060613          	addi	a2,a2,1536 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201890:	09600593          	li	a1,150
ffffffffc0201894:	00004517          	auipc	a0,0x4
ffffffffc0201898:	98450513          	addi	a0,a0,-1660 # ffffffffc0205218 <commands+0xab8>
ffffffffc020189c:	867fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==2);
ffffffffc02018a0:	00004697          	auipc	a3,0x4
ffffffffc02018a4:	b2068693          	addi	a3,a3,-1248 # ffffffffc02053c0 <commands+0xc60>
ffffffffc02018a8:	00003617          	auipc	a2,0x3
ffffffffc02018ac:	5e060613          	addi	a2,a2,1504 # ffffffffc0204e88 <commands+0x728>
ffffffffc02018b0:	09800593          	li	a1,152
ffffffffc02018b4:	00004517          	auipc	a0,0x4
ffffffffc02018b8:	96450513          	addi	a0,a0,-1692 # ffffffffc0205218 <commands+0xab8>
ffffffffc02018bc:	847fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018c0:	00004697          	auipc	a3,0x4
ffffffffc02018c4:	b1068693          	addi	a3,a3,-1264 # ffffffffc02053d0 <commands+0xc70>
ffffffffc02018c8:	00003617          	auipc	a2,0x3
ffffffffc02018cc:	5c060613          	addi	a2,a2,1472 # ffffffffc0204e88 <commands+0x728>
ffffffffc02018d0:	09a00593          	li	a1,154
ffffffffc02018d4:	00004517          	auipc	a0,0x4
ffffffffc02018d8:	94450513          	addi	a0,a0,-1724 # ffffffffc0205218 <commands+0xab8>
ffffffffc02018dc:	827fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==3);
ffffffffc02018e0:	00004697          	auipc	a3,0x4
ffffffffc02018e4:	af068693          	addi	a3,a3,-1296 # ffffffffc02053d0 <commands+0xc70>
ffffffffc02018e8:	00003617          	auipc	a2,0x3
ffffffffc02018ec:	5a060613          	addi	a2,a2,1440 # ffffffffc0204e88 <commands+0x728>
ffffffffc02018f0:	09c00593          	li	a1,156
ffffffffc02018f4:	00004517          	auipc	a0,0x4
ffffffffc02018f8:	92450513          	addi	a0,a0,-1756 # ffffffffc0205218 <commands+0xab8>
ffffffffc02018fc:	807fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201900:	00004697          	auipc	a3,0x4
ffffffffc0201904:	ab068693          	addi	a3,a3,-1360 # ffffffffc02053b0 <commands+0xc50>
ffffffffc0201908:	00003617          	auipc	a2,0x3
ffffffffc020190c:	58060613          	addi	a2,a2,1408 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201910:	09200593          	li	a1,146
ffffffffc0201914:	00004517          	auipc	a0,0x4
ffffffffc0201918:	90450513          	addi	a0,a0,-1788 # ffffffffc0205218 <commands+0xab8>
ffffffffc020191c:	fe6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(pgfault_num==1);
ffffffffc0201920:	00004697          	auipc	a3,0x4
ffffffffc0201924:	a9068693          	addi	a3,a3,-1392 # ffffffffc02053b0 <commands+0xc50>
ffffffffc0201928:	00003617          	auipc	a2,0x3
ffffffffc020192c:	56060613          	addi	a2,a2,1376 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201930:	09400593          	li	a1,148
ffffffffc0201934:	00004517          	auipc	a0,0x4
ffffffffc0201938:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205218 <commands+0xab8>
ffffffffc020193c:	fc6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(mm != NULL);
ffffffffc0201940:	00004697          	auipc	a3,0x4
ffffffffc0201944:	82868693          	addi	a3,a3,-2008 # ffffffffc0205168 <commands+0xa08>
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	54060613          	addi	a2,a2,1344 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201950:	0c300593          	li	a1,195
ffffffffc0201954:	00004517          	auipc	a0,0x4
ffffffffc0201958:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205218 <commands+0xab8>
ffffffffc020195c:	fa6fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0201960:	00004697          	auipc	a3,0x4
ffffffffc0201964:	93868693          	addi	a3,a3,-1736 # ffffffffc0205298 <commands+0xb38>
ffffffffc0201968:	00003617          	auipc	a2,0x3
ffffffffc020196c:	52060613          	addi	a2,a2,1312 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201970:	0c600593          	li	a1,198
ffffffffc0201974:	00004517          	auipc	a0,0x4
ffffffffc0201978:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205218 <commands+0xab8>
ffffffffc020197c:	f86fe0ef          	jal	ra,ffffffffc0200102 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0201980:	00004697          	auipc	a3,0x4
ffffffffc0201984:	9e068693          	addi	a3,a3,-1568 # ffffffffc0205360 <commands+0xc00>
ffffffffc0201988:	00003617          	auipc	a2,0x3
ffffffffc020198c:	50060613          	addi	a2,a2,1280 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201990:	0e900593          	li	a1,233
ffffffffc0201994:	00004517          	auipc	a0,0x4
ffffffffc0201998:	88450513          	addi	a0,a0,-1916 # ffffffffc0205218 <commands+0xab8>
ffffffffc020199c:	f66fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02019a0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc02019a0:	00010797          	auipc	a5,0x10
ffffffffc02019a4:	b887b783          	ld	a5,-1144(a5) # ffffffffc0211528 <sm>
ffffffffc02019a8:	6b9c                	ld	a5,16(a5)
ffffffffc02019aa:	8782                	jr	a5

ffffffffc02019ac <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc02019ac:	00010797          	auipc	a5,0x10
ffffffffc02019b0:	b7c7b783          	ld	a5,-1156(a5) # ffffffffc0211528 <sm>
ffffffffc02019b4:	739c                	ld	a5,32(a5)
ffffffffc02019b6:	8782                	jr	a5

ffffffffc02019b8 <swap_out>:
{
ffffffffc02019b8:	711d                	addi	sp,sp,-96
ffffffffc02019ba:	ec86                	sd	ra,88(sp)
ffffffffc02019bc:	e8a2                	sd	s0,80(sp)
ffffffffc02019be:	e4a6                	sd	s1,72(sp)
ffffffffc02019c0:	e0ca                	sd	s2,64(sp)
ffffffffc02019c2:	fc4e                	sd	s3,56(sp)
ffffffffc02019c4:	f852                	sd	s4,48(sp)
ffffffffc02019c6:	f456                	sd	s5,40(sp)
ffffffffc02019c8:	f05a                	sd	s6,32(sp)
ffffffffc02019ca:	ec5e                	sd	s7,24(sp)
ffffffffc02019cc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02019ce:	cde9                	beqz	a1,ffffffffc0201aa8 <swap_out+0xf0>
ffffffffc02019d0:	8a2e                	mv	s4,a1
ffffffffc02019d2:	892a                	mv	s2,a0
ffffffffc02019d4:	8ab2                	mv	s5,a2
ffffffffc02019d6:	4401                	li	s0,0
ffffffffc02019d8:	00010997          	auipc	s3,0x10
ffffffffc02019dc:	b5098993          	addi	s3,s3,-1200 # ffffffffc0211528 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019e0:	00004b17          	auipc	s6,0x4
ffffffffc02019e4:	b58b0b13          	addi	s6,s6,-1192 # ffffffffc0205538 <commands+0xdd8>
                    cprintf("SWAP: failed to save\n");
ffffffffc02019e8:	00004b97          	auipc	s7,0x4
ffffffffc02019ec:	b38b8b93          	addi	s7,s7,-1224 # ffffffffc0205520 <commands+0xdc0>
ffffffffc02019f0:	a825                	j	ffffffffc0201a28 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019f2:	67a2                	ld	a5,8(sp)
ffffffffc02019f4:	8626                	mv	a2,s1
ffffffffc02019f6:	85a2                	mv	a1,s0
ffffffffc02019f8:	63b4                	ld	a3,64(a5)
ffffffffc02019fa:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02019fc:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02019fe:	82b1                	srli	a3,a3,0xc
ffffffffc0201a00:	0685                	addi	a3,a3,1
ffffffffc0201a02:	eb8fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a06:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0201a08:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0201a0a:	613c                	ld	a5,64(a0)
ffffffffc0201a0c:	83b1                	srli	a5,a5,0xc
ffffffffc0201a0e:	0785                	addi	a5,a5,1
ffffffffc0201a10:	07a2                	slli	a5,a5,0x8
ffffffffc0201a12:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0201a16:	154010ef          	jal	ra,ffffffffc0202b6a <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0201a1a:	01893503          	ld	a0,24(s2)
ffffffffc0201a1e:	85a6                	mv	a1,s1
ffffffffc0201a20:	1b2020ef          	jal	ra,ffffffffc0203bd2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0201a24:	048a0d63          	beq	s4,s0,ffffffffc0201a7e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0201a28:	0009b783          	ld	a5,0(s3)
ffffffffc0201a2c:	8656                	mv	a2,s5
ffffffffc0201a2e:	002c                	addi	a1,sp,8
ffffffffc0201a30:	7b9c                	ld	a5,48(a5)
ffffffffc0201a32:	854a                	mv	a0,s2
ffffffffc0201a34:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0201a36:	e12d                	bnez	a0,ffffffffc0201a98 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0201a38:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a3a:	01893503          	ld	a0,24(s2)
ffffffffc0201a3e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0201a40:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a42:	85a6                	mv	a1,s1
ffffffffc0201a44:	1a0010ef          	jal	ra,ffffffffc0202be4 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a48:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0201a4a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0201a4c:	8b85                	andi	a5,a5,1
ffffffffc0201a4e:	cfb9                	beqz	a5,ffffffffc0201aac <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0201a50:	65a2                	ld	a1,8(sp)
ffffffffc0201a52:	61bc                	ld	a5,64(a1)
ffffffffc0201a54:	83b1                	srli	a5,a5,0xc
ffffffffc0201a56:	0785                	addi	a5,a5,1
ffffffffc0201a58:	00879513          	slli	a0,a5,0x8
ffffffffc0201a5c:	4a8020ef          	jal	ra,ffffffffc0203f04 <swapfs_write>
ffffffffc0201a60:	d949                	beqz	a0,ffffffffc02019f2 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0201a62:	855e                	mv	a0,s7
ffffffffc0201a64:	e56fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a68:	0009b783          	ld	a5,0(s3)
ffffffffc0201a6c:	6622                	ld	a2,8(sp)
ffffffffc0201a6e:	4681                	li	a3,0
ffffffffc0201a70:	739c                	ld	a5,32(a5)
ffffffffc0201a72:	85a6                	mv	a1,s1
ffffffffc0201a74:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0201a76:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0201a78:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0201a7a:	fa8a17e3          	bne	s4,s0,ffffffffc0201a28 <swap_out+0x70>
}
ffffffffc0201a7e:	60e6                	ld	ra,88(sp)
ffffffffc0201a80:	8522                	mv	a0,s0
ffffffffc0201a82:	6446                	ld	s0,80(sp)
ffffffffc0201a84:	64a6                	ld	s1,72(sp)
ffffffffc0201a86:	6906                	ld	s2,64(sp)
ffffffffc0201a88:	79e2                	ld	s3,56(sp)
ffffffffc0201a8a:	7a42                	ld	s4,48(sp)
ffffffffc0201a8c:	7aa2                	ld	s5,40(sp)
ffffffffc0201a8e:	7b02                	ld	s6,32(sp)
ffffffffc0201a90:	6be2                	ld	s7,24(sp)
ffffffffc0201a92:	6c42                	ld	s8,16(sp)
ffffffffc0201a94:	6125                	addi	sp,sp,96
ffffffffc0201a96:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0201a98:	85a2                	mv	a1,s0
ffffffffc0201a9a:	00004517          	auipc	a0,0x4
ffffffffc0201a9e:	a3e50513          	addi	a0,a0,-1474 # ffffffffc02054d8 <commands+0xd78>
ffffffffc0201aa2:	e18fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0201aa6:	bfe1                	j	ffffffffc0201a7e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0201aa8:	4401                	li	s0,0
ffffffffc0201aaa:	bfd1                	j	ffffffffc0201a7e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0201aac:	00004697          	auipc	a3,0x4
ffffffffc0201ab0:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205508 <commands+0xda8>
ffffffffc0201ab4:	00003617          	auipc	a2,0x3
ffffffffc0201ab8:	3d460613          	addi	a2,a2,980 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201abc:	06700593          	li	a1,103
ffffffffc0201ac0:	00003517          	auipc	a0,0x3
ffffffffc0201ac4:	75850513          	addi	a0,a0,1880 # ffffffffc0205218 <commands+0xab8>
ffffffffc0201ac8:	e3afe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201acc <swap_in>:
{
ffffffffc0201acc:	7179                	addi	sp,sp,-48
ffffffffc0201ace:	e84a                	sd	s2,16(sp)
ffffffffc0201ad0:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0201ad2:	4505                	li	a0,1
{
ffffffffc0201ad4:	ec26                	sd	s1,24(sp)
ffffffffc0201ad6:	e44e                	sd	s3,8(sp)
ffffffffc0201ad8:	f406                	sd	ra,40(sp)
ffffffffc0201ada:	f022                	sd	s0,32(sp)
ffffffffc0201adc:	84ae                	mv	s1,a1
ffffffffc0201ade:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0201ae0:	7f9000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
     assert(result!=NULL);
ffffffffc0201ae4:	c129                	beqz	a0,ffffffffc0201b26 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0201ae6:	842a                	mv	s0,a0
ffffffffc0201ae8:	01893503          	ld	a0,24(s2)
ffffffffc0201aec:	4601                	li	a2,0
ffffffffc0201aee:	85a6                	mv	a1,s1
ffffffffc0201af0:	0f4010ef          	jal	ra,ffffffffc0202be4 <get_pte>
ffffffffc0201af4:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0201af6:	6108                	ld	a0,0(a0)
ffffffffc0201af8:	85a2                	mv	a1,s0
ffffffffc0201afa:	370020ef          	jal	ra,ffffffffc0203e6a <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0201afe:	00093583          	ld	a1,0(s2)
ffffffffc0201b02:	8626                	mv	a2,s1
ffffffffc0201b04:	00004517          	auipc	a0,0x4
ffffffffc0201b08:	a8450513          	addi	a0,a0,-1404 # ffffffffc0205588 <commands+0xe28>
ffffffffc0201b0c:	81a1                	srli	a1,a1,0x8
ffffffffc0201b0e:	dacfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0201b12:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0201b14:	0089b023          	sd	s0,0(s3)
}
ffffffffc0201b18:	7402                	ld	s0,32(sp)
ffffffffc0201b1a:	64e2                	ld	s1,24(sp)
ffffffffc0201b1c:	6942                	ld	s2,16(sp)
ffffffffc0201b1e:	69a2                	ld	s3,8(sp)
ffffffffc0201b20:	4501                	li	a0,0
ffffffffc0201b22:	6145                	addi	sp,sp,48
ffffffffc0201b24:	8082                	ret
     assert(result!=NULL);
ffffffffc0201b26:	00004697          	auipc	a3,0x4
ffffffffc0201b2a:	a5268693          	addi	a3,a3,-1454 # ffffffffc0205578 <commands+0xe18>
ffffffffc0201b2e:	00003617          	auipc	a2,0x3
ffffffffc0201b32:	35a60613          	addi	a2,a2,858 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201b36:	07d00593          	li	a1,125
ffffffffc0201b3a:	00003517          	auipc	a0,0x3
ffffffffc0201b3e:	6de50513          	addi	a0,a0,1758 # ffffffffc0205218 <commands+0xab8>
ffffffffc0201b42:	dc0fe0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0201b46 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc0201b46:	0000f797          	auipc	a5,0xf
ffffffffc0201b4a:	59a78793          	addi	a5,a5,1434 # ffffffffc02110e0 <free_area>
ffffffffc0201b4e:	e79c                	sd	a5,8(a5)
ffffffffc0201b50:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0201b52:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201b56:	8082                	ret

ffffffffc0201b58 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0201b58:	0000f517          	auipc	a0,0xf
ffffffffc0201b5c:	59856503          	lwu	a0,1432(a0) # ffffffffc02110f0 <free_area+0x10>
ffffffffc0201b60:	8082                	ret

ffffffffc0201b62 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0201b62:	715d                	addi	sp,sp,-80
ffffffffc0201b64:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0201b66:	0000f417          	auipc	s0,0xf
ffffffffc0201b6a:	57a40413          	addi	s0,s0,1402 # ffffffffc02110e0 <free_area>
ffffffffc0201b6e:	641c                	ld	a5,8(s0)
ffffffffc0201b70:	e486                	sd	ra,72(sp)
ffffffffc0201b72:	fc26                	sd	s1,56(sp)
ffffffffc0201b74:	f84a                	sd	s2,48(sp)
ffffffffc0201b76:	f44e                	sd	s3,40(sp)
ffffffffc0201b78:	f052                	sd	s4,32(sp)
ffffffffc0201b7a:	ec56                	sd	s5,24(sp)
ffffffffc0201b7c:	e85a                	sd	s6,16(sp)
ffffffffc0201b7e:	e45e                	sd	s7,8(sp)
ffffffffc0201b80:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b82:	2c878763          	beq	a5,s0,ffffffffc0201e50 <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0201b86:	4481                	li	s1,0
ffffffffc0201b88:	4901                	li	s2,0
ffffffffc0201b8a:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0201b8e:	8b09                	andi	a4,a4,2
ffffffffc0201b90:	2c070463          	beqz	a4,ffffffffc0201e58 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0201b94:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201b98:	679c                	ld	a5,8(a5)
ffffffffc0201b9a:	2905                	addiw	s2,s2,1
ffffffffc0201b9c:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201b9e:	fe8796e3          	bne	a5,s0,ffffffffc0201b8a <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0201ba2:	89a6                	mv	s3,s1
ffffffffc0201ba4:	006010ef          	jal	ra,ffffffffc0202baa <nr_free_pages>
ffffffffc0201ba8:	71351863          	bne	a0,s3,ffffffffc02022b8 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201bac:	4505                	li	a0,1
ffffffffc0201bae:	72b000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201bb2:	8a2a                	mv	s4,a0
ffffffffc0201bb4:	44050263          	beqz	a0,ffffffffc0201ff8 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201bb8:	4505                	li	a0,1
ffffffffc0201bba:	71f000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201bbe:	89aa                	mv	s3,a0
ffffffffc0201bc0:	70050c63          	beqz	a0,ffffffffc02022d8 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201bc4:	4505                	li	a0,1
ffffffffc0201bc6:	713000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201bca:	8aaa                	mv	s5,a0
ffffffffc0201bcc:	4a050663          	beqz	a0,ffffffffc0202078 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201bd0:	2b3a0463          	beq	s4,s3,ffffffffc0201e78 <default_check+0x316>
ffffffffc0201bd4:	2aaa0263          	beq	s4,a0,ffffffffc0201e78 <default_check+0x316>
ffffffffc0201bd8:	2aa98063          	beq	s3,a0,ffffffffc0201e78 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201bdc:	000a2783          	lw	a5,0(s4)
ffffffffc0201be0:	2a079c63          	bnez	a5,ffffffffc0201e98 <default_check+0x336>
ffffffffc0201be4:	0009a783          	lw	a5,0(s3)
ffffffffc0201be8:	2a079863          	bnez	a5,ffffffffc0201e98 <default_check+0x336>
ffffffffc0201bec:	411c                	lw	a5,0(a0)
ffffffffc0201bee:	2a079563          	bnez	a5,ffffffffc0201e98 <default_check+0x336>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201bf2:	00010797          	auipc	a5,0x10
ffffffffc0201bf6:	9667b783          	ld	a5,-1690(a5) # ffffffffc0211558 <pages>
ffffffffc0201bfa:	40fa0733          	sub	a4,s4,a5
ffffffffc0201bfe:	8711                	srai	a4,a4,0x4
ffffffffc0201c00:	00005597          	auipc	a1,0x5
ffffffffc0201c04:	8585b583          	ld	a1,-1960(a1) # ffffffffc0206458 <error_string+0x38>
ffffffffc0201c08:	02b70733          	mul	a4,a4,a1
ffffffffc0201c0c:	00005617          	auipc	a2,0x5
ffffffffc0201c10:	85463603          	ld	a2,-1964(a2) # ffffffffc0206460 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201c14:	00010697          	auipc	a3,0x10
ffffffffc0201c18:	93c6b683          	ld	a3,-1732(a3) # ffffffffc0211550 <npage>
ffffffffc0201c1c:	06b2                	slli	a3,a3,0xc
ffffffffc0201c1e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c20:	0732                	slli	a4,a4,0xc
ffffffffc0201c22:	28d77b63          	bgeu	a4,a3,ffffffffc0201eb8 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c26:	40f98733          	sub	a4,s3,a5
ffffffffc0201c2a:	8711                	srai	a4,a4,0x4
ffffffffc0201c2c:	02b70733          	mul	a4,a4,a1
ffffffffc0201c30:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c32:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201c34:	4cd77263          	bgeu	a4,a3,ffffffffc02020f8 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201c38:	40f507b3          	sub	a5,a0,a5
ffffffffc0201c3c:	8791                	srai	a5,a5,0x4
ffffffffc0201c3e:	02b787b3          	mul	a5,a5,a1
ffffffffc0201c42:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c44:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201c46:	30d7f963          	bgeu	a5,a3,ffffffffc0201f58 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0201c4a:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201c4c:	00043c03          	ld	s8,0(s0)
ffffffffc0201c50:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0201c54:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0201c58:	e400                	sd	s0,8(s0)
ffffffffc0201c5a:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0201c5c:	0000f797          	auipc	a5,0xf
ffffffffc0201c60:	4807aa23          	sw	zero,1172(a5) # ffffffffc02110f0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201c64:	675000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201c68:	2c051863          	bnez	a0,ffffffffc0201f38 <default_check+0x3d6>
    free_page(p0);
ffffffffc0201c6c:	4585                	li	a1,1
ffffffffc0201c6e:	8552                	mv	a0,s4
ffffffffc0201c70:	6fb000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    free_page(p1);
ffffffffc0201c74:	4585                	li	a1,1
ffffffffc0201c76:	854e                	mv	a0,s3
ffffffffc0201c78:	6f3000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    free_page(p2);
ffffffffc0201c7c:	4585                	li	a1,1
ffffffffc0201c7e:	8556                	mv	a0,s5
ffffffffc0201c80:	6eb000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    assert(nr_free == 3);
ffffffffc0201c84:	4818                	lw	a4,16(s0)
ffffffffc0201c86:	478d                	li	a5,3
ffffffffc0201c88:	28f71863          	bne	a4,a5,ffffffffc0201f18 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201c8c:	4505                	li	a0,1
ffffffffc0201c8e:	64b000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201c92:	89aa                	mv	s3,a0
ffffffffc0201c94:	26050263          	beqz	a0,ffffffffc0201ef8 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201c98:	4505                	li	a0,1
ffffffffc0201c9a:	63f000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201c9e:	8aaa                	mv	s5,a0
ffffffffc0201ca0:	3a050c63          	beqz	a0,ffffffffc0202058 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201ca4:	4505                	li	a0,1
ffffffffc0201ca6:	633000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201caa:	8a2a                	mv	s4,a0
ffffffffc0201cac:	38050663          	beqz	a0,ffffffffc0202038 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0201cb0:	4505                	li	a0,1
ffffffffc0201cb2:	627000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201cb6:	36051163          	bnez	a0,ffffffffc0202018 <default_check+0x4b6>
    free_page(p0);
ffffffffc0201cba:	4585                	li	a1,1
ffffffffc0201cbc:	854e                	mv	a0,s3
ffffffffc0201cbe:	6ad000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201cc2:	641c                	ld	a5,8(s0)
ffffffffc0201cc4:	20878a63          	beq	a5,s0,ffffffffc0201ed8 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0201cc8:	4505                	li	a0,1
ffffffffc0201cca:	60f000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201cce:	30a99563          	bne	s3,a0,ffffffffc0201fd8 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0201cd2:	4505                	li	a0,1
ffffffffc0201cd4:	605000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201cd8:	2e051063          	bnez	a0,ffffffffc0201fb8 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0201cdc:	481c                	lw	a5,16(s0)
ffffffffc0201cde:	2a079d63          	bnez	a5,ffffffffc0201f98 <default_check+0x436>
    free_page(p);
ffffffffc0201ce2:	854e                	mv	a0,s3
ffffffffc0201ce4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201ce6:	01843023          	sd	s8,0(s0)
ffffffffc0201cea:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0201cee:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0201cf2:	679000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    free_page(p1);
ffffffffc0201cf6:	4585                	li	a1,1
ffffffffc0201cf8:	8556                	mv	a0,s5
ffffffffc0201cfa:	671000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    free_page(p2);
ffffffffc0201cfe:	4585                	li	a1,1
ffffffffc0201d00:	8552                	mv	a0,s4
ffffffffc0201d02:	669000ef          	jal	ra,ffffffffc0202b6a <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201d06:	4515                	li	a0,5
ffffffffc0201d08:	5d1000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201d0c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201d0e:	26050563          	beqz	a0,ffffffffc0201f78 <default_check+0x416>
ffffffffc0201d12:	651c                	ld	a5,8(a0)
ffffffffc0201d14:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0201d16:	8b85                	andi	a5,a5,1
ffffffffc0201d18:	54079063          	bnez	a5,ffffffffc0202258 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201d1c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201d1e:	00043b03          	ld	s6,0(s0)
ffffffffc0201d22:	00843a83          	ld	s5,8(s0)
ffffffffc0201d26:	e000                	sd	s0,0(s0)
ffffffffc0201d28:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0201d2a:	5af000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201d2e:	50051563          	bnez	a0,ffffffffc0202238 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201d32:	0a098a13          	addi	s4,s3,160
ffffffffc0201d36:	8552                	mv	a0,s4
ffffffffc0201d38:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201d3a:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201d3e:	0000f797          	auipc	a5,0xf
ffffffffc0201d42:	3a07a923          	sw	zero,946(a5) # ffffffffc02110f0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201d46:	625000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201d4a:	4511                	li	a0,4
ffffffffc0201d4c:	58d000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201d50:	4c051463          	bnez	a0,ffffffffc0202218 <default_check+0x6b6>
ffffffffc0201d54:	0a89b783          	ld	a5,168(s3)
ffffffffc0201d58:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201d5a:	8b85                	andi	a5,a5,1
ffffffffc0201d5c:	48078e63          	beqz	a5,ffffffffc02021f8 <default_check+0x696>
ffffffffc0201d60:	0b89a703          	lw	a4,184(s3)
ffffffffc0201d64:	478d                	li	a5,3
ffffffffc0201d66:	48f71963          	bne	a4,a5,ffffffffc02021f8 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201d6a:	450d                	li	a0,3
ffffffffc0201d6c:	56d000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201d70:	8c2a                	mv	s8,a0
ffffffffc0201d72:	46050363          	beqz	a0,ffffffffc02021d8 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0201d76:	4505                	li	a0,1
ffffffffc0201d78:	561000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201d7c:	42051e63          	bnez	a0,ffffffffc02021b8 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0201d80:	418a1c63          	bne	s4,s8,ffffffffc0202198 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201d84:	4585                	li	a1,1
ffffffffc0201d86:	854e                	mv	a0,s3
ffffffffc0201d88:	5e3000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    free_pages(p1, 3);
ffffffffc0201d8c:	458d                	li	a1,3
ffffffffc0201d8e:	8552                	mv	a0,s4
ffffffffc0201d90:	5db000ef          	jal	ra,ffffffffc0202b6a <free_pages>
ffffffffc0201d94:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201d98:	05098c13          	addi	s8,s3,80
ffffffffc0201d9c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201d9e:	8b85                	andi	a5,a5,1
ffffffffc0201da0:	3c078c63          	beqz	a5,ffffffffc0202178 <default_check+0x616>
ffffffffc0201da4:	0189a703          	lw	a4,24(s3)
ffffffffc0201da8:	4785                	li	a5,1
ffffffffc0201daa:	3cf71763          	bne	a4,a5,ffffffffc0202178 <default_check+0x616>
ffffffffc0201dae:	008a3783          	ld	a5,8(s4)
ffffffffc0201db2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201db4:	8b85                	andi	a5,a5,1
ffffffffc0201db6:	3a078163          	beqz	a5,ffffffffc0202158 <default_check+0x5f6>
ffffffffc0201dba:	018a2703          	lw	a4,24(s4)
ffffffffc0201dbe:	478d                	li	a5,3
ffffffffc0201dc0:	38f71c63          	bne	a4,a5,ffffffffc0202158 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201dc4:	4505                	li	a0,1
ffffffffc0201dc6:	513000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201dca:	36a99763          	bne	s3,a0,ffffffffc0202138 <default_check+0x5d6>
    free_page(p0);
ffffffffc0201dce:	4585                	li	a1,1
ffffffffc0201dd0:	59b000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201dd4:	4509                	li	a0,2
ffffffffc0201dd6:	503000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201dda:	32aa1f63          	bne	s4,a0,ffffffffc0202118 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0201dde:	4589                	li	a1,2
ffffffffc0201de0:	58b000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    free_page(p2);
ffffffffc0201de4:	4585                	li	a1,1
ffffffffc0201de6:	8562                	mv	a0,s8
ffffffffc0201de8:	583000ef          	jal	ra,ffffffffc0202b6a <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201dec:	4515                	li	a0,5
ffffffffc0201dee:	4eb000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201df2:	89aa                	mv	s3,a0
ffffffffc0201df4:	48050263          	beqz	a0,ffffffffc0202278 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0201df8:	4505                	li	a0,1
ffffffffc0201dfa:	4df000ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0201dfe:	2c051d63          	bnez	a0,ffffffffc02020d8 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0201e02:	481c                	lw	a5,16(s0)
ffffffffc0201e04:	2a079a63          	bnez	a5,ffffffffc02020b8 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201e08:	4595                	li	a1,5
ffffffffc0201e0a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201e0c:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0201e10:	01643023          	sd	s6,0(s0)
ffffffffc0201e14:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0201e18:	553000ef          	jal	ra,ffffffffc0202b6a <free_pages>
    return listelm->next;
ffffffffc0201e1c:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e1e:	00878963          	beq	a5,s0,ffffffffc0201e30 <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201e22:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201e26:	679c                	ld	a5,8(a5)
ffffffffc0201e28:	397d                	addiw	s2,s2,-1
ffffffffc0201e2a:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e2c:	fe879be3          	bne	a5,s0,ffffffffc0201e22 <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0201e30:	26091463          	bnez	s2,ffffffffc0202098 <default_check+0x536>
    assert(total == 0);
ffffffffc0201e34:	46049263          	bnez	s1,ffffffffc0202298 <default_check+0x736>
}
ffffffffc0201e38:	60a6                	ld	ra,72(sp)
ffffffffc0201e3a:	6406                	ld	s0,64(sp)
ffffffffc0201e3c:	74e2                	ld	s1,56(sp)
ffffffffc0201e3e:	7942                	ld	s2,48(sp)
ffffffffc0201e40:	79a2                	ld	s3,40(sp)
ffffffffc0201e42:	7a02                	ld	s4,32(sp)
ffffffffc0201e44:	6ae2                	ld	s5,24(sp)
ffffffffc0201e46:	6b42                	ld	s6,16(sp)
ffffffffc0201e48:	6ba2                	ld	s7,8(sp)
ffffffffc0201e4a:	6c02                	ld	s8,0(sp)
ffffffffc0201e4c:	6161                	addi	sp,sp,80
ffffffffc0201e4e:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201e50:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201e52:	4481                	li	s1,0
ffffffffc0201e54:	4901                	li	s2,0
ffffffffc0201e56:	b3b9                	j	ffffffffc0201ba4 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201e58:	00003697          	auipc	a3,0x3
ffffffffc0201e5c:	3e868693          	addi	a3,a3,1000 # ffffffffc0205240 <commands+0xae0>
ffffffffc0201e60:	00003617          	auipc	a2,0x3
ffffffffc0201e64:	02860613          	addi	a2,a2,40 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201e68:	0f000593          	li	a1,240
ffffffffc0201e6c:	00003517          	auipc	a0,0x3
ffffffffc0201e70:	75c50513          	addi	a0,a0,1884 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201e74:	a8efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201e78:	00003697          	auipc	a3,0x3
ffffffffc0201e7c:	7c868693          	addi	a3,a3,1992 # ffffffffc0205640 <commands+0xee0>
ffffffffc0201e80:	00003617          	auipc	a2,0x3
ffffffffc0201e84:	00860613          	addi	a2,a2,8 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201e88:	0bd00593          	li	a1,189
ffffffffc0201e8c:	00003517          	auipc	a0,0x3
ffffffffc0201e90:	73c50513          	addi	a0,a0,1852 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201e94:	a6efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201e98:	00003697          	auipc	a3,0x3
ffffffffc0201e9c:	7d068693          	addi	a3,a3,2000 # ffffffffc0205668 <commands+0xf08>
ffffffffc0201ea0:	00003617          	auipc	a2,0x3
ffffffffc0201ea4:	fe860613          	addi	a2,a2,-24 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201ea8:	0be00593          	li	a1,190
ffffffffc0201eac:	00003517          	auipc	a0,0x3
ffffffffc0201eb0:	71c50513          	addi	a0,a0,1820 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201eb4:	a4efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201eb8:	00003697          	auipc	a3,0x3
ffffffffc0201ebc:	7f068693          	addi	a3,a3,2032 # ffffffffc02056a8 <commands+0xf48>
ffffffffc0201ec0:	00003617          	auipc	a2,0x3
ffffffffc0201ec4:	fc860613          	addi	a2,a2,-56 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201ec8:	0c000593          	li	a1,192
ffffffffc0201ecc:	00003517          	auipc	a0,0x3
ffffffffc0201ed0:	6fc50513          	addi	a0,a0,1788 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201ed4:	a2efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201ed8:	00004697          	auipc	a3,0x4
ffffffffc0201edc:	85868693          	addi	a3,a3,-1960 # ffffffffc0205730 <commands+0xfd0>
ffffffffc0201ee0:	00003617          	auipc	a2,0x3
ffffffffc0201ee4:	fa860613          	addi	a2,a2,-88 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201ee8:	0d900593          	li	a1,217
ffffffffc0201eec:	00003517          	auipc	a0,0x3
ffffffffc0201ef0:	6dc50513          	addi	a0,a0,1756 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201ef4:	a0efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201ef8:	00003697          	auipc	a3,0x3
ffffffffc0201efc:	6e868693          	addi	a3,a3,1768 # ffffffffc02055e0 <commands+0xe80>
ffffffffc0201f00:	00003617          	auipc	a2,0x3
ffffffffc0201f04:	f8860613          	addi	a2,a2,-120 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201f08:	0d200593          	li	a1,210
ffffffffc0201f0c:	00003517          	auipc	a0,0x3
ffffffffc0201f10:	6bc50513          	addi	a0,a0,1724 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201f14:	9eefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 3);
ffffffffc0201f18:	00004697          	auipc	a3,0x4
ffffffffc0201f1c:	80868693          	addi	a3,a3,-2040 # ffffffffc0205720 <commands+0xfc0>
ffffffffc0201f20:	00003617          	auipc	a2,0x3
ffffffffc0201f24:	f6860613          	addi	a2,a2,-152 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201f28:	0d000593          	li	a1,208
ffffffffc0201f2c:	00003517          	auipc	a0,0x3
ffffffffc0201f30:	69c50513          	addi	a0,a0,1692 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201f34:	9cefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201f38:	00003697          	auipc	a3,0x3
ffffffffc0201f3c:	7d068693          	addi	a3,a3,2000 # ffffffffc0205708 <commands+0xfa8>
ffffffffc0201f40:	00003617          	auipc	a2,0x3
ffffffffc0201f44:	f4860613          	addi	a2,a2,-184 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201f48:	0cb00593          	li	a1,203
ffffffffc0201f4c:	00003517          	auipc	a0,0x3
ffffffffc0201f50:	67c50513          	addi	a0,a0,1660 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201f54:	9aefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201f58:	00003697          	auipc	a3,0x3
ffffffffc0201f5c:	79068693          	addi	a3,a3,1936 # ffffffffc02056e8 <commands+0xf88>
ffffffffc0201f60:	00003617          	auipc	a2,0x3
ffffffffc0201f64:	f2860613          	addi	a2,a2,-216 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201f68:	0c200593          	li	a1,194
ffffffffc0201f6c:	00003517          	auipc	a0,0x3
ffffffffc0201f70:	65c50513          	addi	a0,a0,1628 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201f74:	98efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 != NULL);
ffffffffc0201f78:	00003697          	auipc	a3,0x3
ffffffffc0201f7c:	7f068693          	addi	a3,a3,2032 # ffffffffc0205768 <commands+0x1008>
ffffffffc0201f80:	00003617          	auipc	a2,0x3
ffffffffc0201f84:	f0860613          	addi	a2,a2,-248 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201f88:	0f800593          	li	a1,248
ffffffffc0201f8c:	00003517          	auipc	a0,0x3
ffffffffc0201f90:	63c50513          	addi	a0,a0,1596 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201f94:	96efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc0201f98:	00003697          	auipc	a3,0x3
ffffffffc0201f9c:	45868693          	addi	a3,a3,1112 # ffffffffc02053f0 <commands+0xc90>
ffffffffc0201fa0:	00003617          	auipc	a2,0x3
ffffffffc0201fa4:	ee860613          	addi	a2,a2,-280 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201fa8:	0df00593          	li	a1,223
ffffffffc0201fac:	00003517          	auipc	a0,0x3
ffffffffc0201fb0:	61c50513          	addi	a0,a0,1564 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201fb4:	94efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201fb8:	00003697          	auipc	a3,0x3
ffffffffc0201fbc:	75068693          	addi	a3,a3,1872 # ffffffffc0205708 <commands+0xfa8>
ffffffffc0201fc0:	00003617          	auipc	a2,0x3
ffffffffc0201fc4:	ec860613          	addi	a2,a2,-312 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201fc8:	0dd00593          	li	a1,221
ffffffffc0201fcc:	00003517          	auipc	a0,0x3
ffffffffc0201fd0:	5fc50513          	addi	a0,a0,1532 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201fd4:	92efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201fd8:	00003697          	auipc	a3,0x3
ffffffffc0201fdc:	77068693          	addi	a3,a3,1904 # ffffffffc0205748 <commands+0xfe8>
ffffffffc0201fe0:	00003617          	auipc	a2,0x3
ffffffffc0201fe4:	ea860613          	addi	a2,a2,-344 # ffffffffc0204e88 <commands+0x728>
ffffffffc0201fe8:	0dc00593          	li	a1,220
ffffffffc0201fec:	00003517          	auipc	a0,0x3
ffffffffc0201ff0:	5dc50513          	addi	a0,a0,1500 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0201ff4:	90efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201ff8:	00003697          	auipc	a3,0x3
ffffffffc0201ffc:	5e868693          	addi	a3,a3,1512 # ffffffffc02055e0 <commands+0xe80>
ffffffffc0202000:	00003617          	auipc	a2,0x3
ffffffffc0202004:	e8860613          	addi	a2,a2,-376 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202008:	0b900593          	li	a1,185
ffffffffc020200c:	00003517          	auipc	a0,0x3
ffffffffc0202010:	5bc50513          	addi	a0,a0,1468 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202014:	8eefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202018:	00003697          	auipc	a3,0x3
ffffffffc020201c:	6f068693          	addi	a3,a3,1776 # ffffffffc0205708 <commands+0xfa8>
ffffffffc0202020:	00003617          	auipc	a2,0x3
ffffffffc0202024:	e6860613          	addi	a2,a2,-408 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202028:	0d600593          	li	a1,214
ffffffffc020202c:	00003517          	auipc	a0,0x3
ffffffffc0202030:	59c50513          	addi	a0,a0,1436 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202034:	8cefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202038:	00003697          	auipc	a3,0x3
ffffffffc020203c:	5e868693          	addi	a3,a3,1512 # ffffffffc0205620 <commands+0xec0>
ffffffffc0202040:	00003617          	auipc	a2,0x3
ffffffffc0202044:	e4860613          	addi	a2,a2,-440 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202048:	0d400593          	li	a1,212
ffffffffc020204c:	00003517          	auipc	a0,0x3
ffffffffc0202050:	57c50513          	addi	a0,a0,1404 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202054:	8aefe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0202058:	00003697          	auipc	a3,0x3
ffffffffc020205c:	5a868693          	addi	a3,a3,1448 # ffffffffc0205600 <commands+0xea0>
ffffffffc0202060:	00003617          	auipc	a2,0x3
ffffffffc0202064:	e2860613          	addi	a2,a2,-472 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202068:	0d300593          	li	a1,211
ffffffffc020206c:	00003517          	auipc	a0,0x3
ffffffffc0202070:	55c50513          	addi	a0,a0,1372 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202074:	88efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0202078:	00003697          	auipc	a3,0x3
ffffffffc020207c:	5a868693          	addi	a3,a3,1448 # ffffffffc0205620 <commands+0xec0>
ffffffffc0202080:	00003617          	auipc	a2,0x3
ffffffffc0202084:	e0860613          	addi	a2,a2,-504 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202088:	0bb00593          	li	a1,187
ffffffffc020208c:	00003517          	auipc	a0,0x3
ffffffffc0202090:	53c50513          	addi	a0,a0,1340 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202094:	86efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(count == 0);
ffffffffc0202098:	00004697          	auipc	a3,0x4
ffffffffc020209c:	82068693          	addi	a3,a3,-2016 # ffffffffc02058b8 <commands+0x1158>
ffffffffc02020a0:	00003617          	auipc	a2,0x3
ffffffffc02020a4:	de860613          	addi	a2,a2,-536 # ffffffffc0204e88 <commands+0x728>
ffffffffc02020a8:	12500593          	li	a1,293
ffffffffc02020ac:	00003517          	auipc	a0,0x3
ffffffffc02020b0:	51c50513          	addi	a0,a0,1308 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02020b4:	84efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free == 0);
ffffffffc02020b8:	00003697          	auipc	a3,0x3
ffffffffc02020bc:	33868693          	addi	a3,a3,824 # ffffffffc02053f0 <commands+0xc90>
ffffffffc02020c0:	00003617          	auipc	a2,0x3
ffffffffc02020c4:	dc860613          	addi	a2,a2,-568 # ffffffffc0204e88 <commands+0x728>
ffffffffc02020c8:	11a00593          	li	a1,282
ffffffffc02020cc:	00003517          	auipc	a0,0x3
ffffffffc02020d0:	4fc50513          	addi	a0,a0,1276 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02020d4:	82efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02020d8:	00003697          	auipc	a3,0x3
ffffffffc02020dc:	63068693          	addi	a3,a3,1584 # ffffffffc0205708 <commands+0xfa8>
ffffffffc02020e0:	00003617          	auipc	a2,0x3
ffffffffc02020e4:	da860613          	addi	a2,a2,-600 # ffffffffc0204e88 <commands+0x728>
ffffffffc02020e8:	11800593          	li	a1,280
ffffffffc02020ec:	00003517          	auipc	a0,0x3
ffffffffc02020f0:	4dc50513          	addi	a0,a0,1244 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02020f4:	80efe0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02020f8:	00003697          	auipc	a3,0x3
ffffffffc02020fc:	5d068693          	addi	a3,a3,1488 # ffffffffc02056c8 <commands+0xf68>
ffffffffc0202100:	00003617          	auipc	a2,0x3
ffffffffc0202104:	d8860613          	addi	a2,a2,-632 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202108:	0c100593          	li	a1,193
ffffffffc020210c:	00003517          	auipc	a0,0x3
ffffffffc0202110:	4bc50513          	addi	a0,a0,1212 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202114:	feffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202118:	00003697          	auipc	a3,0x3
ffffffffc020211c:	76068693          	addi	a3,a3,1888 # ffffffffc0205878 <commands+0x1118>
ffffffffc0202120:	00003617          	auipc	a2,0x3
ffffffffc0202124:	d6860613          	addi	a2,a2,-664 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202128:	11200593          	li	a1,274
ffffffffc020212c:	00003517          	auipc	a0,0x3
ffffffffc0202130:	49c50513          	addi	a0,a0,1180 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202134:	fcffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202138:	00003697          	auipc	a3,0x3
ffffffffc020213c:	72068693          	addi	a3,a3,1824 # ffffffffc0205858 <commands+0x10f8>
ffffffffc0202140:	00003617          	auipc	a2,0x3
ffffffffc0202144:	d4860613          	addi	a2,a2,-696 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202148:	11000593          	li	a1,272
ffffffffc020214c:	00003517          	auipc	a0,0x3
ffffffffc0202150:	47c50513          	addi	a0,a0,1148 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202154:	faffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202158:	00003697          	auipc	a3,0x3
ffffffffc020215c:	6d868693          	addi	a3,a3,1752 # ffffffffc0205830 <commands+0x10d0>
ffffffffc0202160:	00003617          	auipc	a2,0x3
ffffffffc0202164:	d2860613          	addi	a2,a2,-728 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202168:	10e00593          	li	a1,270
ffffffffc020216c:	00003517          	auipc	a0,0x3
ffffffffc0202170:	45c50513          	addi	a0,a0,1116 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202174:	f8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202178:	00003697          	auipc	a3,0x3
ffffffffc020217c:	69068693          	addi	a3,a3,1680 # ffffffffc0205808 <commands+0x10a8>
ffffffffc0202180:	00003617          	auipc	a2,0x3
ffffffffc0202184:	d0860613          	addi	a2,a2,-760 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202188:	10d00593          	li	a1,269
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	43c50513          	addi	a0,a0,1084 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202194:	f6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0202198:	00003697          	auipc	a3,0x3
ffffffffc020219c:	66068693          	addi	a3,a3,1632 # ffffffffc02057f8 <commands+0x1098>
ffffffffc02021a0:	00003617          	auipc	a2,0x3
ffffffffc02021a4:	ce860613          	addi	a2,a2,-792 # ffffffffc0204e88 <commands+0x728>
ffffffffc02021a8:	10800593          	li	a1,264
ffffffffc02021ac:	00003517          	auipc	a0,0x3
ffffffffc02021b0:	41c50513          	addi	a0,a0,1052 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02021b4:	f4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02021b8:	00003697          	auipc	a3,0x3
ffffffffc02021bc:	55068693          	addi	a3,a3,1360 # ffffffffc0205708 <commands+0xfa8>
ffffffffc02021c0:	00003617          	auipc	a2,0x3
ffffffffc02021c4:	cc860613          	addi	a2,a2,-824 # ffffffffc0204e88 <commands+0x728>
ffffffffc02021c8:	10700593          	li	a1,263
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	3fc50513          	addi	a0,a0,1020 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02021d4:	f2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	60068693          	addi	a3,a3,1536 # ffffffffc02057d8 <commands+0x1078>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	ca860613          	addi	a2,a2,-856 # ffffffffc0204e88 <commands+0x728>
ffffffffc02021e8:	10600593          	li	a1,262
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	3dc50513          	addi	a0,a0,988 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02021f4:	f0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02021f8:	00003697          	auipc	a3,0x3
ffffffffc02021fc:	5b068693          	addi	a3,a3,1456 # ffffffffc02057a8 <commands+0x1048>
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	c8860613          	addi	a2,a2,-888 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202208:	10500593          	li	a1,261
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	3bc50513          	addi	a0,a0,956 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202214:	eeffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0202218:	00003697          	auipc	a3,0x3
ffffffffc020221c:	57868693          	addi	a3,a3,1400 # ffffffffc0205790 <commands+0x1030>
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	c6860613          	addi	a2,a2,-920 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202228:	10400593          	li	a1,260
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	39c50513          	addi	a0,a0,924 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202234:	ecffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0202238:	00003697          	auipc	a3,0x3
ffffffffc020223c:	4d068693          	addi	a3,a3,1232 # ffffffffc0205708 <commands+0xfa8>
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	c4860613          	addi	a2,a2,-952 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202248:	0fe00593          	li	a1,254
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	37c50513          	addi	a0,a0,892 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202254:	eaffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(!PageProperty(p0));
ffffffffc0202258:	00003697          	auipc	a3,0x3
ffffffffc020225c:	52068693          	addi	a3,a3,1312 # ffffffffc0205778 <commands+0x1018>
ffffffffc0202260:	00003617          	auipc	a2,0x3
ffffffffc0202264:	c2860613          	addi	a2,a2,-984 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202268:	0f900593          	li	a1,249
ffffffffc020226c:	00003517          	auipc	a0,0x3
ffffffffc0202270:	35c50513          	addi	a0,a0,860 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202274:	e8ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202278:	00003697          	auipc	a3,0x3
ffffffffc020227c:	62068693          	addi	a3,a3,1568 # ffffffffc0205898 <commands+0x1138>
ffffffffc0202280:	00003617          	auipc	a2,0x3
ffffffffc0202284:	c0860613          	addi	a2,a2,-1016 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202288:	11700593          	li	a1,279
ffffffffc020228c:	00003517          	auipc	a0,0x3
ffffffffc0202290:	33c50513          	addi	a0,a0,828 # ffffffffc02055c8 <commands+0xe68>
ffffffffc0202294:	e6ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == 0);
ffffffffc0202298:	00003697          	auipc	a3,0x3
ffffffffc020229c:	63068693          	addi	a3,a3,1584 # ffffffffc02058c8 <commands+0x1168>
ffffffffc02022a0:	00003617          	auipc	a2,0x3
ffffffffc02022a4:	be860613          	addi	a2,a2,-1048 # ffffffffc0204e88 <commands+0x728>
ffffffffc02022a8:	12600593          	li	a1,294
ffffffffc02022ac:	00003517          	auipc	a0,0x3
ffffffffc02022b0:	31c50513          	addi	a0,a0,796 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02022b4:	e4ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(total == nr_free_pages());
ffffffffc02022b8:	00003697          	auipc	a3,0x3
ffffffffc02022bc:	f9868693          	addi	a3,a3,-104 # ffffffffc0205250 <commands+0xaf0>
ffffffffc02022c0:	00003617          	auipc	a2,0x3
ffffffffc02022c4:	bc860613          	addi	a2,a2,-1080 # ffffffffc0204e88 <commands+0x728>
ffffffffc02022c8:	0f300593          	li	a1,243
ffffffffc02022cc:	00003517          	auipc	a0,0x3
ffffffffc02022d0:	2fc50513          	addi	a0,a0,764 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02022d4:	e2ffd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02022d8:	00003697          	auipc	a3,0x3
ffffffffc02022dc:	32868693          	addi	a3,a3,808 # ffffffffc0205600 <commands+0xea0>
ffffffffc02022e0:	00003617          	auipc	a2,0x3
ffffffffc02022e4:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204e88 <commands+0x728>
ffffffffc02022e8:	0ba00593          	li	a1,186
ffffffffc02022ec:	00003517          	auipc	a0,0x3
ffffffffc02022f0:	2dc50513          	addi	a0,a0,732 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02022f4:	e0ffd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc02022f8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02022f8:	1141                	addi	sp,sp,-16
ffffffffc02022fa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02022fc:	14058a63          	beqz	a1,ffffffffc0202450 <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0202300:	00259693          	slli	a3,a1,0x2
ffffffffc0202304:	96ae                	add	a3,a3,a1
ffffffffc0202306:	0692                	slli	a3,a3,0x4
ffffffffc0202308:	96aa                	add	a3,a3,a0
ffffffffc020230a:	87aa                	mv	a5,a0
ffffffffc020230c:	02d50263          	beq	a0,a3,ffffffffc0202330 <default_free_pages+0x38>
ffffffffc0202310:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202312:	8b05                	andi	a4,a4,1
ffffffffc0202314:	10071e63          	bnez	a4,ffffffffc0202430 <default_free_pages+0x138>
ffffffffc0202318:	6798                	ld	a4,8(a5)
ffffffffc020231a:	8b09                	andi	a4,a4,2
ffffffffc020231c:	10071a63          	bnez	a4,ffffffffc0202430 <default_free_pages+0x138>
        p->flags = 0;
ffffffffc0202320:	0007b423          	sd	zero,8(a5)
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202324:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202328:	05078793          	addi	a5,a5,80
ffffffffc020232c:	fed792e3          	bne	a5,a3,ffffffffc0202310 <default_free_pages+0x18>
    base->property = n;
ffffffffc0202330:	2581                	sext.w	a1,a1
ffffffffc0202332:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0202334:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202338:	4789                	li	a5,2
ffffffffc020233a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020233e:	0000f697          	auipc	a3,0xf
ffffffffc0202342:	da268693          	addi	a3,a3,-606 # ffffffffc02110e0 <free_area>
ffffffffc0202346:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202348:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020234a:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc020234e:	9db9                	addw	a1,a1,a4
ffffffffc0202350:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0202352:	0ad78863          	beq	a5,a3,ffffffffc0202402 <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0202356:	fe078713          	addi	a4,a5,-32
ffffffffc020235a:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020235e:	4581                	li	a1,0
            if (base < page) {
ffffffffc0202360:	00e56a63          	bltu	a0,a4,ffffffffc0202374 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0202364:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202366:	06d70263          	beq	a4,a3,ffffffffc02023ca <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc020236a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020236c:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0202370:	fee57ae3          	bgeu	a0,a4,ffffffffc0202364 <default_free_pages+0x6c>
ffffffffc0202374:	c199                	beqz	a1,ffffffffc020237a <default_free_pages+0x82>
ffffffffc0202376:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020237a:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020237c:	e390                	sd	a2,0(a5)
ffffffffc020237e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0202380:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0202382:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc0202384:	02d70063          	beq	a4,a3,ffffffffc02023a4 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0202388:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020238c:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc0202390:	02081613          	slli	a2,a6,0x20
ffffffffc0202394:	9201                	srli	a2,a2,0x20
ffffffffc0202396:	00261793          	slli	a5,a2,0x2
ffffffffc020239a:	97b2                	add	a5,a5,a2
ffffffffc020239c:	0792                	slli	a5,a5,0x4
ffffffffc020239e:	97ae                	add	a5,a5,a1
ffffffffc02023a0:	02f50f63          	beq	a0,a5,ffffffffc02023de <default_free_pages+0xe6>
    return listelm->next;
ffffffffc02023a4:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc02023a6:	00d70f63          	beq	a4,a3,ffffffffc02023c4 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc02023aa:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc02023ac:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc02023b0:	02059613          	slli	a2,a1,0x20
ffffffffc02023b4:	9201                	srli	a2,a2,0x20
ffffffffc02023b6:	00261793          	slli	a5,a2,0x2
ffffffffc02023ba:	97b2                	add	a5,a5,a2
ffffffffc02023bc:	0792                	slli	a5,a5,0x4
ffffffffc02023be:	97aa                	add	a5,a5,a0
ffffffffc02023c0:	04f68863          	beq	a3,a5,ffffffffc0202410 <default_free_pages+0x118>
}
ffffffffc02023c4:	60a2                	ld	ra,8(sp)
ffffffffc02023c6:	0141                	addi	sp,sp,16
ffffffffc02023c8:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02023ca:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02023cc:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02023ce:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02023d0:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023d2:	02d70563          	beq	a4,a3,ffffffffc02023fc <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc02023d6:	8832                	mv	a6,a2
ffffffffc02023d8:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02023da:	87ba                	mv	a5,a4
ffffffffc02023dc:	bf41                	j	ffffffffc020236c <default_free_pages+0x74>
            p->property += base->property;
ffffffffc02023de:	4d1c                	lw	a5,24(a0)
ffffffffc02023e0:	0107883b          	addw	a6,a5,a6
ffffffffc02023e4:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02023e8:	57f5                	li	a5,-3
ffffffffc02023ea:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02023ee:	7110                	ld	a2,32(a0)
ffffffffc02023f0:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc02023f2:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02023f4:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02023f6:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02023f8:	e390                	sd	a2,0(a5)
ffffffffc02023fa:	b775                	j	ffffffffc02023a6 <default_free_pages+0xae>
ffffffffc02023fc:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02023fe:	873e                	mv	a4,a5
ffffffffc0202400:	b761                	j	ffffffffc0202388 <default_free_pages+0x90>
}
ffffffffc0202402:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0202404:	e390                	sd	a2,0(a5)
ffffffffc0202406:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0202408:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020240a:	f11c                	sd	a5,32(a0)
ffffffffc020240c:	0141                	addi	sp,sp,16
ffffffffc020240e:	8082                	ret
            base->property += p->property;
ffffffffc0202410:	ff872783          	lw	a5,-8(a4)
ffffffffc0202414:	fe870693          	addi	a3,a4,-24
ffffffffc0202418:	9dbd                	addw	a1,a1,a5
ffffffffc020241a:	cd0c                	sw	a1,24(a0)
ffffffffc020241c:	57f5                	li	a5,-3
ffffffffc020241e:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0202422:	6314                	ld	a3,0(a4)
ffffffffc0202424:	671c                	ld	a5,8(a4)
}
ffffffffc0202426:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0202428:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020242a:	e394                	sd	a3,0(a5)
ffffffffc020242c:	0141                	addi	sp,sp,16
ffffffffc020242e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202430:	00003697          	auipc	a3,0x3
ffffffffc0202434:	4b068693          	addi	a3,a3,1200 # ffffffffc02058e0 <commands+0x1180>
ffffffffc0202438:	00003617          	auipc	a2,0x3
ffffffffc020243c:	a5060613          	addi	a2,a2,-1456 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202440:	08300593          	li	a1,131
ffffffffc0202444:	00003517          	auipc	a0,0x3
ffffffffc0202448:	18450513          	addi	a0,a0,388 # ffffffffc02055c8 <commands+0xe68>
ffffffffc020244c:	cb7fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc0202450:	00003697          	auipc	a3,0x3
ffffffffc0202454:	48868693          	addi	a3,a3,1160 # ffffffffc02058d8 <commands+0x1178>
ffffffffc0202458:	00003617          	auipc	a2,0x3
ffffffffc020245c:	a3060613          	addi	a2,a2,-1488 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202460:	08000593          	li	a1,128
ffffffffc0202464:	00003517          	auipc	a0,0x3
ffffffffc0202468:	16450513          	addi	a0,a0,356 # ffffffffc02055c8 <commands+0xe68>
ffffffffc020246c:	c97fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202470 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0202470:	c959                	beqz	a0,ffffffffc0202506 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0202472:	0000f597          	auipc	a1,0xf
ffffffffc0202476:	c6e58593          	addi	a1,a1,-914 # ffffffffc02110e0 <free_area>
ffffffffc020247a:	0105a803          	lw	a6,16(a1)
ffffffffc020247e:	862a                	mv	a2,a0
ffffffffc0202480:	02081793          	slli	a5,a6,0x20
ffffffffc0202484:	9381                	srli	a5,a5,0x20
ffffffffc0202486:	00a7ee63          	bltu	a5,a0,ffffffffc02024a2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc020248a:	87ae                	mv	a5,a1
ffffffffc020248c:	a801                	j	ffffffffc020249c <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020248e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202492:	02071693          	slli	a3,a4,0x20
ffffffffc0202496:	9281                	srli	a3,a3,0x20
ffffffffc0202498:	00c6f763          	bgeu	a3,a2,ffffffffc02024a6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc020249c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020249e:	feb798e3          	bne	a5,a1,ffffffffc020248e <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02024a2:	4501                	li	a0,0
}
ffffffffc02024a4:	8082                	ret
    return listelm->prev;
ffffffffc02024a6:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02024aa:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc02024ae:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc02024b2:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc02024b6:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02024ba:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02024be:	02d67b63          	bgeu	a2,a3,ffffffffc02024f4 <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc02024c2:	00261693          	slli	a3,a2,0x2
ffffffffc02024c6:	96b2                	add	a3,a3,a2
ffffffffc02024c8:	0692                	slli	a3,a3,0x4
ffffffffc02024ca:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02024cc:	41c7073b          	subw	a4,a4,t3
ffffffffc02024d0:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02024d2:	00868613          	addi	a2,a3,8
ffffffffc02024d6:	4709                	li	a4,2
ffffffffc02024d8:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02024dc:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02024e0:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc02024e4:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc02024e8:	e310                	sd	a2,0(a4)
ffffffffc02024ea:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02024ee:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02024f0:	0316b023          	sd	a7,32(a3)
ffffffffc02024f4:	41c8083b          	subw	a6,a6,t3
ffffffffc02024f8:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02024fc:	5775                	li	a4,-3
ffffffffc02024fe:	17a1                	addi	a5,a5,-24
ffffffffc0202500:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202504:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0202506:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0202508:	00003697          	auipc	a3,0x3
ffffffffc020250c:	3d068693          	addi	a3,a3,976 # ffffffffc02058d8 <commands+0x1178>
ffffffffc0202510:	00003617          	auipc	a2,0x3
ffffffffc0202514:	97860613          	addi	a2,a2,-1672 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202518:	06200593          	li	a1,98
ffffffffc020251c:	00003517          	auipc	a0,0x3
ffffffffc0202520:	0ac50513          	addi	a0,a0,172 # ffffffffc02055c8 <commands+0xe68>
default_alloc_pages(size_t n) {
ffffffffc0202524:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0202526:	bddfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020252a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020252a:	1141                	addi	sp,sp,-16
ffffffffc020252c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020252e:	c9e1                	beqz	a1,ffffffffc02025fe <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0202530:	00259693          	slli	a3,a1,0x2
ffffffffc0202534:	96ae                	add	a3,a3,a1
ffffffffc0202536:	0692                	slli	a3,a3,0x4
ffffffffc0202538:	96aa                	add	a3,a3,a0
ffffffffc020253a:	87aa                	mv	a5,a0
ffffffffc020253c:	00d50f63          	beq	a0,a3,ffffffffc020255a <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202540:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0202542:	8b05                	andi	a4,a4,1
ffffffffc0202544:	cf49                	beqz	a4,ffffffffc02025de <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0202546:	0007ac23          	sw	zero,24(a5)
ffffffffc020254a:	0007b423          	sd	zero,8(a5)
ffffffffc020254e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0202552:	05078793          	addi	a5,a5,80
ffffffffc0202556:	fed795e3          	bne	a5,a3,ffffffffc0202540 <default_init_memmap+0x16>
    base->property = n;
ffffffffc020255a:	2581                	sext.w	a1,a1
ffffffffc020255c:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020255e:	4789                	li	a5,2
ffffffffc0202560:	00850713          	addi	a4,a0,8
ffffffffc0202564:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0202568:	0000f697          	auipc	a3,0xf
ffffffffc020256c:	b7868693          	addi	a3,a3,-1160 # ffffffffc02110e0 <free_area>
ffffffffc0202570:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0202572:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0202574:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc0202578:	9db9                	addw	a1,a1,a4
ffffffffc020257a:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020257c:	04d78a63          	beq	a5,a3,ffffffffc02025d0 <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0202580:	fe078713          	addi	a4,a5,-32
ffffffffc0202584:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0202588:	4581                	li	a1,0
            if (base < page) {
ffffffffc020258a:	00e56a63          	bltu	a0,a4,ffffffffc020259e <default_init_memmap+0x74>
    return listelm->next;
ffffffffc020258e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0202590:	02d70263          	beq	a4,a3,ffffffffc02025b4 <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0202594:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0202596:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc020259a:	fee57ae3          	bgeu	a0,a4,ffffffffc020258e <default_init_memmap+0x64>
ffffffffc020259e:	c199                	beqz	a1,ffffffffc02025a4 <default_init_memmap+0x7a>
ffffffffc02025a0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02025a4:	6398                	ld	a4,0(a5)
}
ffffffffc02025a6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02025a8:	e390                	sd	a2,0(a5)
ffffffffc02025aa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02025ac:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025ae:	f118                	sd	a4,32(a0)
ffffffffc02025b0:	0141                	addi	sp,sp,16
ffffffffc02025b2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02025b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025b6:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc02025b8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02025ba:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02025bc:	00d70663          	beq	a4,a3,ffffffffc02025c8 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02025c0:	8832                	mv	a6,a2
ffffffffc02025c2:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02025c4:	87ba                	mv	a5,a4
ffffffffc02025c6:	bfc1                	j	ffffffffc0202596 <default_init_memmap+0x6c>
}
ffffffffc02025c8:	60a2                	ld	ra,8(sp)
ffffffffc02025ca:	e290                	sd	a2,0(a3)
ffffffffc02025cc:	0141                	addi	sp,sp,16
ffffffffc02025ce:	8082                	ret
ffffffffc02025d0:	60a2                	ld	ra,8(sp)
ffffffffc02025d2:	e390                	sd	a2,0(a5)
ffffffffc02025d4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02025d6:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02025d8:	f11c                	sd	a5,32(a0)
ffffffffc02025da:	0141                	addi	sp,sp,16
ffffffffc02025dc:	8082                	ret
        assert(PageReserved(p));
ffffffffc02025de:	00003697          	auipc	a3,0x3
ffffffffc02025e2:	32a68693          	addi	a3,a3,810 # ffffffffc0205908 <commands+0x11a8>
ffffffffc02025e6:	00003617          	auipc	a2,0x3
ffffffffc02025ea:	8a260613          	addi	a2,a2,-1886 # ffffffffc0204e88 <commands+0x728>
ffffffffc02025ee:	04900593          	li	a1,73
ffffffffc02025f2:	00003517          	auipc	a0,0x3
ffffffffc02025f6:	fd650513          	addi	a0,a0,-42 # ffffffffc02055c8 <commands+0xe68>
ffffffffc02025fa:	b09fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0);
ffffffffc02025fe:	00003697          	auipc	a3,0x3
ffffffffc0202602:	2da68693          	addi	a3,a3,730 # ffffffffc02058d8 <commands+0x1178>
ffffffffc0202606:	00003617          	auipc	a2,0x3
ffffffffc020260a:	88260613          	addi	a2,a2,-1918 # ffffffffc0204e88 <commands+0x728>
ffffffffc020260e:	04600593          	li	a1,70
ffffffffc0202612:	00003517          	auipc	a0,0x3
ffffffffc0202616:	fb650513          	addi	a0,a0,-74 # ffffffffc02055c8 <commands+0xe68>
ffffffffc020261a:	ae9fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020261e <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020261e:	0000f797          	auipc	a5,0xf
ffffffffc0202622:	ab278793          	addi	a5,a5,-1358 # ffffffffc02110d0 <pra_list_head>
     // 初始化当前指针curr_ptr2指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);//初始化
     curr_ptr2=&pra_list_head;//curr_ptr2指向当前页面替换的位置（初始值为链表头部）
     mm->sm_priv=&pra_list_head;
ffffffffc0202626:	f51c                	sd	a5,40(a0)
ffffffffc0202628:	e79c                	sd	a5,8(a5)
ffffffffc020262a:	e39c                	sd	a5,0(a5)
     curr_ptr2=&pra_list_head;//curr_ptr2指向当前页面替换的位置（初始值为链表头部）
ffffffffc020262c:	0000f717          	auipc	a4,0xf
ffffffffc0202630:	f0f73623          	sd	a5,-244(a4) # ffffffffc0211538 <curr_ptr2>
     return 0;
}
ffffffffc0202634:	4501                	li	a0,0
ffffffffc0202636:	8082                	ret

ffffffffc0202638 <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc0202638:	4501                	li	a0,0
ffffffffc020263a:	8082                	ret

ffffffffc020263c <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020263c:	4501                	li	a0,0
ffffffffc020263e:	8082                	ret

ffffffffc0202640 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0202640:	4501                	li	a0,0
ffffffffc0202642:	8082                	ret

ffffffffc0202644 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0202644:	711d                	addi	sp,sp,-96
    cprintf("_lru_check_swap开始\n");
ffffffffc0202646:	00003517          	auipc	a0,0x3
ffffffffc020264a:	32250513          	addi	a0,a0,802 # ffffffffc0205968 <default_pmm_manager+0x38>
_lru_check_swap(void) {
ffffffffc020264e:	ec86                	sd	ra,88(sp)
ffffffffc0202650:	e0ca                	sd	s2,64(sp)
ffffffffc0202652:	f852                	sd	s4,48(sp)
ffffffffc0202654:	f456                	sd	s5,40(sp)
ffffffffc0202656:	e8a2                	sd	s0,80(sp)
ffffffffc0202658:	e4a6                	sd	s1,72(sp)
ffffffffc020265a:	fc4e                	sd	s3,56(sp)
ffffffffc020265c:	f05a                	sd	s6,32(sp)
ffffffffc020265e:	ec5e                	sd	s7,24(sp)
ffffffffc0202660:	e862                	sd	s8,16(sp)
ffffffffc0202662:	e466                	sd	s9,8(sp)
ffffffffc0202664:	e06a                	sd	s10,0(sp)
    cprintf("_lru_check_swap开始\n");
ffffffffc0202666:	a55fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("下一条是*(unsigned char *)0x3000 = 0x0c;\n");
ffffffffc020266a:	00003517          	auipc	a0,0x3
ffffffffc020266e:	31650513          	addi	a0,a0,790 # ffffffffc0205980 <default_pmm_manager+0x50>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202672:	6a0d                	lui	s4,0x3
ffffffffc0202674:	4ab1                	li	s5,12
    cprintf("下一条是*(unsigned char *)0x3000 = 0x0c;\n");
ffffffffc0202676:	a45fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020267a:	015a0023          	sb	s5,0(s4) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc020267e:	0000f917          	auipc	s2,0xf
ffffffffc0202682:	e9a92903          	lw	s2,-358(s2) # ffffffffc0211518 <pgfault_num>
ffffffffc0202686:	4791                	li	a5,4
ffffffffc0202688:	14f91163          	bne	s2,a5,ffffffffc02027ca <_lru_check_swap+0x186>
    cprintf("下一条是*(unsigned char *)0x1000 = 0x0a;\n");
ffffffffc020268c:	00003517          	auipc	a0,0x3
ffffffffc0202690:	33c50513          	addi	a0,a0,828 # ffffffffc02059c8 <default_pmm_manager+0x98>
ffffffffc0202694:	a27fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202698:	6785                	lui	a5,0x1
ffffffffc020269a:	4729                	li	a4,10
ffffffffc020269c:	0000f417          	auipc	s0,0xf
ffffffffc02026a0:	e7c40413          	addi	s0,s0,-388 # ffffffffc0211518 <pgfault_num>
ffffffffc02026a4:	00e78023          	sb	a4,0(a5) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02026a8:	4004                	lw	s1,0(s0)
ffffffffc02026aa:	2481                	sext.w	s1,s1
ffffffffc02026ac:	27249f63          	bne	s1,s2,ffffffffc020292a <_lru_check_swap+0x2e6>
    cprintf("下一条是*(unsigned char *)0x4000 = 0x0d;\n");
ffffffffc02026b0:	00003517          	auipc	a0,0x3
ffffffffc02026b4:	34850513          	addi	a0,a0,840 # ffffffffc02059f8 <default_pmm_manager+0xc8>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026b8:	6b11                	lui	s6,0x4
ffffffffc02026ba:	4bb5                	li	s7,13
    cprintf("下一条是*(unsigned char *)0x4000 = 0x0d;\n");
ffffffffc02026bc:	9fffd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02026c0:	017b0023          	sb	s7,0(s6) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02026c4:	00042903          	lw	s2,0(s0)
ffffffffc02026c8:	2901                	sext.w	s2,s2
ffffffffc02026ca:	24991063          	bne	s2,s1,ffffffffc020290a <_lru_check_swap+0x2c6>
    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
ffffffffc02026ce:	00003517          	auipc	a0,0x3
ffffffffc02026d2:	35a50513          	addi	a0,a0,858 # ffffffffc0205a28 <default_pmm_manager+0xf8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026d6:	6989                	lui	s3,0x2
ffffffffc02026d8:	4c2d                	li	s8,11
    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
ffffffffc02026da:	9e1fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02026de:	01898023          	sb	s8,0(s3) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02026e2:	401c                	lw	a5,0(s0)
ffffffffc02026e4:	2781                	sext.w	a5,a5
ffffffffc02026e6:	21279263          	bne	a5,s2,ffffffffc02028ea <_lru_check_swap+0x2a6>
    cprintf("下一条是*(unsigned char *)0x5000 = 0x0e;\n");
ffffffffc02026ea:	00003517          	auipc	a0,0x3
ffffffffc02026ee:	36e50513          	addi	a0,a0,878 # ffffffffc0205a58 <default_pmm_manager+0x128>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026f2:	6c95                	lui	s9,0x5
ffffffffc02026f4:	4d39                	li	s10,14
    cprintf("下一条是*(unsigned char *)0x5000 = 0x0e;\n");
ffffffffc02026f6:	9c5fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02026fa:	01ac8023          	sb	s10,0(s9) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02026fe:	4004                	lw	s1,0(s0)
ffffffffc0202700:	4795                	li	a5,5
ffffffffc0202702:	2481                	sext.w	s1,s1
ffffffffc0202704:	1cf49363          	bne	s1,a5,ffffffffc02028ca <_lru_check_swap+0x286>
    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
ffffffffc0202708:	00003517          	auipc	a0,0x3
ffffffffc020270c:	32050513          	addi	a0,a0,800 # ffffffffc0205a28 <default_pmm_manager+0xf8>
ffffffffc0202710:	9abfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202714:	01898023          	sb	s8,0(s3)
    assert(pgfault_num==5);
ffffffffc0202718:	00042903          	lw	s2,0(s0)
ffffffffc020271c:	2901                	sext.w	s2,s2
ffffffffc020271e:	18991663          	bne	s2,s1,ffffffffc02028aa <_lru_check_swap+0x266>
    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
ffffffffc0202722:	00003517          	auipc	a0,0x3
ffffffffc0202726:	30650513          	addi	a0,a0,774 # ffffffffc0205a28 <default_pmm_manager+0xf8>
ffffffffc020272a:	991fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020272e:	01898023          	sb	s8,0(s3)
    assert(pgfault_num==5);
ffffffffc0202732:	4004                	lw	s1,0(s0)
ffffffffc0202734:	2481                	sext.w	s1,s1
ffffffffc0202736:	15249a63          	bne	s1,s2,ffffffffc020288a <_lru_check_swap+0x246>
    cprintf("下一条是*(unsigned char *)0x3000 = 0x0c;\n");
ffffffffc020273a:	00003517          	auipc	a0,0x3
ffffffffc020273e:	24650513          	addi	a0,a0,582 # ffffffffc0205980 <default_pmm_manager+0x50>
ffffffffc0202742:	979fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202746:	015a0023          	sb	s5,0(s4)
    assert(pgfault_num==5);
ffffffffc020274a:	401c                	lw	a5,0(s0)
ffffffffc020274c:	2781                	sext.w	a5,a5
ffffffffc020274e:	10979e63          	bne	a5,s1,ffffffffc020286a <_lru_check_swap+0x226>
    cprintf("下一条是*(unsigned char *)0x4000 = 0x0d;\n");
ffffffffc0202752:	00003517          	auipc	a0,0x3
ffffffffc0202756:	2a650513          	addi	a0,a0,678 # ffffffffc02059f8 <default_pmm_manager+0xc8>
ffffffffc020275a:	961fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020275e:	017b0023          	sb	s7,0(s6)
    assert(pgfault_num==6);
ffffffffc0202762:	401c                	lw	a5,0(s0)
ffffffffc0202764:	4719                	li	a4,6
ffffffffc0202766:	2781                	sext.w	a5,a5
ffffffffc0202768:	0ee79163          	bne	a5,a4,ffffffffc020284a <_lru_check_swap+0x206>
    cprintf("下一条是*(unsigned char *)0x5000 = 0x0e;\n");
ffffffffc020276c:	00003517          	auipc	a0,0x3
ffffffffc0202770:	2ec50513          	addi	a0,a0,748 # ffffffffc0205a58 <default_pmm_manager+0x128>
ffffffffc0202774:	947fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0202778:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc020277c:	401c                	lw	a5,0(s0)
ffffffffc020277e:	471d                	li	a4,7
ffffffffc0202780:	2781                	sext.w	a5,a5
ffffffffc0202782:	0ae79463          	bne	a5,a4,ffffffffc020282a <_lru_check_swap+0x1e6>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0202786:	6485                	lui	s1,0x1
ffffffffc0202788:	0004c903          	lbu	s2,0(s1) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc020278c:	47a9                	li	a5,10
ffffffffc020278e:	06f91e63          	bne	s2,a5,ffffffffc020280a <_lru_check_swap+0x1c6>
    cprintf("下一条是*(unsigned char *)0x1000 = 0x0a;\n");
ffffffffc0202792:	00003517          	auipc	a0,0x3
ffffffffc0202796:	23650513          	addi	a0,a0,566 # ffffffffc02059c8 <default_pmm_manager+0x98>
ffffffffc020279a:	921fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020279e:	01248023          	sb	s2,0(s1)
    assert(pgfault_num==7);
ffffffffc02027a2:	401c                	lw	a5,0(s0)
ffffffffc02027a4:	471d                	li	a4,7
ffffffffc02027a6:	2781                	sext.w	a5,a5
ffffffffc02027a8:	04e79163          	bne	a5,a4,ffffffffc02027ea <_lru_check_swap+0x1a6>
}
ffffffffc02027ac:	60e6                	ld	ra,88(sp)
ffffffffc02027ae:	6446                	ld	s0,80(sp)
ffffffffc02027b0:	64a6                	ld	s1,72(sp)
ffffffffc02027b2:	6906                	ld	s2,64(sp)
ffffffffc02027b4:	79e2                	ld	s3,56(sp)
ffffffffc02027b6:	7a42                	ld	s4,48(sp)
ffffffffc02027b8:	7aa2                	ld	s5,40(sp)
ffffffffc02027ba:	7b02                	ld	s6,32(sp)
ffffffffc02027bc:	6be2                	ld	s7,24(sp)
ffffffffc02027be:	6c42                	ld	s8,16(sp)
ffffffffc02027c0:	6ca2                	ld	s9,8(sp)
ffffffffc02027c2:	6d02                	ld	s10,0(sp)
ffffffffc02027c4:	4501                	li	a0,0
ffffffffc02027c6:	6125                	addi	sp,sp,96
ffffffffc02027c8:	8082                	ret
    assert(pgfault_num==4);
ffffffffc02027ca:	00003697          	auipc	a3,0x3
ffffffffc02027ce:	c1668693          	addi	a3,a3,-1002 # ffffffffc02053e0 <commands+0xc80>
ffffffffc02027d2:	00002617          	auipc	a2,0x2
ffffffffc02027d6:	6b660613          	addi	a2,a2,1718 # ffffffffc0204e88 <commands+0x728>
ffffffffc02027da:	09e00593          	li	a1,158
ffffffffc02027de:	00003517          	auipc	a0,0x3
ffffffffc02027e2:	1d250513          	addi	a0,a0,466 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc02027e6:	91dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==7);
ffffffffc02027ea:	00003697          	auipc	a3,0x3
ffffffffc02027ee:	2be68693          	addi	a3,a3,702 # ffffffffc0205aa8 <default_pmm_manager+0x178>
ffffffffc02027f2:	00002617          	auipc	a2,0x2
ffffffffc02027f6:	69660613          	addi	a2,a2,1686 # ffffffffc0204e88 <commands+0x728>
ffffffffc02027fa:	0c300593          	li	a1,195
ffffffffc02027fe:	00003517          	auipc	a0,0x3
ffffffffc0202802:	1b250513          	addi	a0,a0,434 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202806:	8fdfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020280a:	00003697          	auipc	a3,0x3
ffffffffc020280e:	2ae68693          	addi	a3,a3,686 # ffffffffc0205ab8 <default_pmm_manager+0x188>
ffffffffc0202812:	00002617          	auipc	a2,0x2
ffffffffc0202816:	67660613          	addi	a2,a2,1654 # ffffffffc0204e88 <commands+0x728>
ffffffffc020281a:	0bf00593          	li	a1,191
ffffffffc020281e:	00003517          	auipc	a0,0x3
ffffffffc0202822:	19250513          	addi	a0,a0,402 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202826:	8ddfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==7);
ffffffffc020282a:	00003697          	auipc	a3,0x3
ffffffffc020282e:	27e68693          	addi	a3,a3,638 # ffffffffc0205aa8 <default_pmm_manager+0x178>
ffffffffc0202832:	00002617          	auipc	a2,0x2
ffffffffc0202836:	65660613          	addi	a2,a2,1622 # ffffffffc0204e88 <commands+0x728>
ffffffffc020283a:	0be00593          	li	a1,190
ffffffffc020283e:	00003517          	auipc	a0,0x3
ffffffffc0202842:	17250513          	addi	a0,a0,370 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202846:	8bdfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==6);
ffffffffc020284a:	00003697          	auipc	a3,0x3
ffffffffc020284e:	24e68693          	addi	a3,a3,590 # ffffffffc0205a98 <default_pmm_manager+0x168>
ffffffffc0202852:	00002617          	auipc	a2,0x2
ffffffffc0202856:	63660613          	addi	a2,a2,1590 # ffffffffc0204e88 <commands+0x728>
ffffffffc020285a:	0bb00593          	li	a1,187
ffffffffc020285e:	00003517          	auipc	a0,0x3
ffffffffc0202862:	15250513          	addi	a0,a0,338 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202866:	89dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc020286a:	00003697          	auipc	a3,0x3
ffffffffc020286e:	21e68693          	addi	a3,a3,542 # ffffffffc0205a88 <default_pmm_manager+0x158>
ffffffffc0202872:	00002617          	auipc	a2,0x2
ffffffffc0202876:	61660613          	addi	a2,a2,1558 # ffffffffc0204e88 <commands+0x728>
ffffffffc020287a:	0b700593          	li	a1,183
ffffffffc020287e:	00003517          	auipc	a0,0x3
ffffffffc0202882:	13250513          	addi	a0,a0,306 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202886:	87dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc020288a:	00003697          	auipc	a3,0x3
ffffffffc020288e:	1fe68693          	addi	a3,a3,510 # ffffffffc0205a88 <default_pmm_manager+0x158>
ffffffffc0202892:	00002617          	auipc	a2,0x2
ffffffffc0202896:	5f660613          	addi	a2,a2,1526 # ffffffffc0204e88 <commands+0x728>
ffffffffc020289a:	0b300593          	li	a1,179
ffffffffc020289e:	00003517          	auipc	a0,0x3
ffffffffc02028a2:	11250513          	addi	a0,a0,274 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc02028a6:	85dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02028aa:	00003697          	auipc	a3,0x3
ffffffffc02028ae:	1de68693          	addi	a3,a3,478 # ffffffffc0205a88 <default_pmm_manager+0x158>
ffffffffc02028b2:	00002617          	auipc	a2,0x2
ffffffffc02028b6:	5d660613          	addi	a2,a2,1494 # ffffffffc0204e88 <commands+0x728>
ffffffffc02028ba:	0af00593          	li	a1,175
ffffffffc02028be:	00003517          	auipc	a0,0x3
ffffffffc02028c2:	0f250513          	addi	a0,a0,242 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc02028c6:	83dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==5);
ffffffffc02028ca:	00003697          	auipc	a3,0x3
ffffffffc02028ce:	1be68693          	addi	a3,a3,446 # ffffffffc0205a88 <default_pmm_manager+0x158>
ffffffffc02028d2:	00002617          	auipc	a2,0x2
ffffffffc02028d6:	5b660613          	addi	a2,a2,1462 # ffffffffc0204e88 <commands+0x728>
ffffffffc02028da:	0ab00593          	li	a1,171
ffffffffc02028de:	00003517          	auipc	a0,0x3
ffffffffc02028e2:	0d250513          	addi	a0,a0,210 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc02028e6:	81dfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc02028ea:	00003697          	auipc	a3,0x3
ffffffffc02028ee:	af668693          	addi	a3,a3,-1290 # ffffffffc02053e0 <commands+0xc80>
ffffffffc02028f2:	00002617          	auipc	a2,0x2
ffffffffc02028f6:	59660613          	addi	a2,a2,1430 # ffffffffc0204e88 <commands+0x728>
ffffffffc02028fa:	0a700593          	li	a1,167
ffffffffc02028fe:	00003517          	auipc	a0,0x3
ffffffffc0202902:	0b250513          	addi	a0,a0,178 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202906:	ffcfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc020290a:	00003697          	auipc	a3,0x3
ffffffffc020290e:	ad668693          	addi	a3,a3,-1322 # ffffffffc02053e0 <commands+0xc80>
ffffffffc0202912:	00002617          	auipc	a2,0x2
ffffffffc0202916:	57660613          	addi	a2,a2,1398 # ffffffffc0204e88 <commands+0x728>
ffffffffc020291a:	0a400593          	li	a1,164
ffffffffc020291e:	00003517          	auipc	a0,0x3
ffffffffc0202922:	09250513          	addi	a0,a0,146 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202926:	fdcfd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pgfault_num==4);
ffffffffc020292a:	00003697          	auipc	a3,0x3
ffffffffc020292e:	ab668693          	addi	a3,a3,-1354 # ffffffffc02053e0 <commands+0xc80>
ffffffffc0202932:	00002617          	auipc	a2,0x2
ffffffffc0202936:	55660613          	addi	a2,a2,1366 # ffffffffc0204e88 <commands+0x728>
ffffffffc020293a:	0a100593          	li	a1,161
ffffffffc020293e:	00003517          	auipc	a0,0x3
ffffffffc0202942:	07250513          	addi	a0,a0,114 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202946:	fbcfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc020294a <_lru_swap_out_victim>:
{
ffffffffc020294a:	7139                	addi	sp,sp,-64
ffffffffc020294c:	f426                	sd	s1,40(sp)
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
ffffffffc020294e:	7504                	ld	s1,40(a0)
{
ffffffffc0202950:	fc06                	sd	ra,56(sp)
ffffffffc0202952:	f822                	sd	s0,48(sp)
ffffffffc0202954:	f04a                	sd	s2,32(sp)
ffffffffc0202956:	ec4e                	sd	s3,24(sp)
ffffffffc0202958:	e852                	sd	s4,16(sp)
ffffffffc020295a:	e456                	sd	s5,8(sp)
    assert(head != NULL);
ffffffffc020295c:	cce9                	beqz	s1,ffffffffc0202a36 <_lru_swap_out_victim+0xec>
    assert(in_tick == 0);
ffffffffc020295e:	ee45                	bnez	a2,ffffffffc0202a16 <_lru_swap_out_victim+0xcc>
    return listelm->next;
ffffffffc0202960:	6480                	ld	s0,8(s1)
ffffffffc0202962:	8a2e                	mv	s4,a1
    while (entry != head) {
ffffffffc0202964:	08848d63          	beq	s1,s0,ffffffffc02029fe <_lru_swap_out_victim+0xb4>
ffffffffc0202968:	8aaa                	mv	s5,a0
    uint32_t min_access_count = 4294967295;
ffffffffc020296a:	597d                	li	s2,-1
    struct Page *least_used_page = NULL;
ffffffffc020296c:	4981                	li	s3,0
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc020296e:	680c                	ld	a1,16(s0)
ffffffffc0202970:	018ab503          	ld	a0,24(s5)
ffffffffc0202974:	4601                	li	a2,0
ffffffffc0202976:	26e000ef          	jal	ra,ffffffffc0202be4 <get_pte>
        if (ptep && (*ptep & PTE_A)) { // 检查页表项的 Accessed 位
ffffffffc020297a:	c141                	beqz	a0,ffffffffc02029fa <_lru_swap_out_victim+0xb0>
ffffffffc020297c:	6118                	ld	a4,0(a0)
            page->access_count++;
ffffffffc020297e:	4c1c                	lw	a5,24(s0)
        if (ptep && (*ptep & PTE_A)) { // 检查页表项的 Accessed 位
ffffffffc0202980:	04077693          	andi	a3,a4,64
ffffffffc0202984:	c691                	beqz	a3,ffffffffc0202990 <_lru_swap_out_victim+0x46>
            page->access_count++;
ffffffffc0202986:	2785                	addiw	a5,a5,1
ffffffffc0202988:	cc1c                	sw	a5,24(s0)
            *ptep &= ~PTE_A; // 清除 Accessed 位
ffffffffc020298a:	fbf77713          	andi	a4,a4,-65
ffffffffc020298e:	e118                	sd	a4,0(a0)
        if (page->access_count <= min_access_count) {
ffffffffc0202990:	00f96563          	bltu	s2,a5,ffffffffc020299a <_lru_swap_out_victim+0x50>
        struct Page *page = le2page(entry, pra_page_link);
ffffffffc0202994:	fd040993          	addi	s3,s0,-48
ffffffffc0202998:	893e                	mv	s2,a5
ffffffffc020299a:	6400                	ld	s0,8(s0)
    while (entry != head) {
ffffffffc020299c:	fc8499e3          	bne	s1,s0,ffffffffc020296e <_lru_swap_out_victim+0x24>
    cprintf("List state before swapping out:\n");
ffffffffc02029a0:	00003517          	auipc	a0,0x3
ffffffffc02029a4:	16050513          	addi	a0,a0,352 # ffffffffc0205b00 <default_pmm_manager+0x1d0>
ffffffffc02029a8:	f12fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029ac:	6480                	ld	s0,8(s1)
    while (entry != head) {
ffffffffc02029ae:	00848e63          	beq	s1,s0,ffffffffc02029ca <_lru_swap_out_victim+0x80>
        cprintf("Page at %p has access count: %d\n", page->pra_vaddr, page->access_count);
ffffffffc02029b2:	00003917          	auipc	s2,0x3
ffffffffc02029b6:	17690913          	addi	s2,s2,374 # ffffffffc0205b28 <default_pmm_manager+0x1f8>
ffffffffc02029ba:	4c10                	lw	a2,24(s0)
ffffffffc02029bc:	680c                	ld	a1,16(s0)
ffffffffc02029be:	854a                	mv	a0,s2
ffffffffc02029c0:	efafd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02029c4:	6400                	ld	s0,8(s0)
    while (entry != head) {
ffffffffc02029c6:	fe849ae3          	bne	s1,s0,ffffffffc02029ba <_lru_swap_out_victim+0x70>
    if (least_used_page != NULL) {
ffffffffc02029ca:	04098463          	beqz	s3,ffffffffc0202a12 <_lru_swap_out_victim+0xc8>
        cprintf("Swapping out page at %p with access count: %d\n", least_used_page->pra_vaddr, least_used_page->access_count);
ffffffffc02029ce:	0489a603          	lw	a2,72(s3)
ffffffffc02029d2:	0409b583          	ld	a1,64(s3)
ffffffffc02029d6:	00003517          	auipc	a0,0x3
ffffffffc02029da:	17a50513          	addi	a0,a0,378 # ffffffffc0205b50 <default_pmm_manager+0x220>
        *ptr_page = least_used_page;
ffffffffc02029de:	013a3023          	sd	s3,0(s4)
        cprintf("Swapping out page at %p with access count: %d\n", least_used_page->pra_vaddr, least_used_page->access_count);
ffffffffc02029e2:	ed8fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
        return 0;
ffffffffc02029e6:	4501                	li	a0,0
}
ffffffffc02029e8:	70e2                	ld	ra,56(sp)
ffffffffc02029ea:	7442                	ld	s0,48(sp)
ffffffffc02029ec:	74a2                	ld	s1,40(sp)
ffffffffc02029ee:	7902                	ld	s2,32(sp)
ffffffffc02029f0:	69e2                	ld	s3,24(sp)
ffffffffc02029f2:	6a42                	ld	s4,16(sp)
ffffffffc02029f4:	6aa2                	ld	s5,8(sp)
ffffffffc02029f6:	6121                	addi	sp,sp,64
ffffffffc02029f8:	8082                	ret
        if (page->access_count <= min_access_count) {
ffffffffc02029fa:	4c1c                	lw	a5,24(s0)
ffffffffc02029fc:	bf51                	j	ffffffffc0202990 <_lru_swap_out_victim+0x46>
    cprintf("List state before swapping out:\n");
ffffffffc02029fe:	00003517          	auipc	a0,0x3
ffffffffc0202a02:	10250513          	addi	a0,a0,258 # ffffffffc0205b00 <default_pmm_manager+0x1d0>
ffffffffc0202a06:	eb4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202a0a:	6480                	ld	s0,8(s1)
    struct Page *least_used_page = NULL;
ffffffffc0202a0c:	4981                	li	s3,0
    while (entry != head) {
ffffffffc0202a0e:	fa8492e3          	bne	s1,s0,ffffffffc02029b2 <_lru_swap_out_victim+0x68>
    return -1; // 如果没有找到合适的页面，返回错误码
ffffffffc0202a12:	557d                	li	a0,-1
ffffffffc0202a14:	bfd1                	j	ffffffffc02029e8 <_lru_swap_out_victim+0x9e>
    assert(in_tick == 0);
ffffffffc0202a16:	00003697          	auipc	a3,0x3
ffffffffc0202a1a:	0da68693          	addi	a3,a3,218 # ffffffffc0205af0 <default_pmm_manager+0x1c0>
ffffffffc0202a1e:	00002617          	auipc	a2,0x2
ffffffffc0202a22:	46a60613          	addi	a2,a2,1130 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202a26:	04b00593          	li	a1,75
ffffffffc0202a2a:	00003517          	auipc	a0,0x3
ffffffffc0202a2e:	f8650513          	addi	a0,a0,-122 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202a32:	ed0fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(head != NULL);
ffffffffc0202a36:	00003697          	auipc	a3,0x3
ffffffffc0202a3a:	0aa68693          	addi	a3,a3,170 # ffffffffc0205ae0 <default_pmm_manager+0x1b0>
ffffffffc0202a3e:	00002617          	auipc	a2,0x2
ffffffffc0202a42:	44a60613          	addi	a2,a2,1098 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202a46:	04a00593          	li	a1,74
ffffffffc0202a4a:	00003517          	auipc	a0,0x3
ffffffffc0202a4e:	f6650513          	addi	a0,a0,-154 # ffffffffc02059b0 <default_pmm_manager+0x80>
ffffffffc0202a52:	eb0fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202a56 <_lru_map_swappable>:
    assert(entry != NULL && curr_ptr2 != NULL);
ffffffffc0202a56:	0000f797          	auipc	a5,0xf
ffffffffc0202a5a:	ae27b783          	ld	a5,-1310(a5) # ffffffffc0211538 <curr_ptr2>
ffffffffc0202a5e:	cf99                	beqz	a5,ffffffffc0202a7c <_lru_map_swappable+0x26>
    return listelm->prev;
ffffffffc0202a60:	639c                	ld	a5,0(a5)
ffffffffc0202a62:	03060713          	addi	a4,a2,48
}
ffffffffc0202a66:	4501                	li	a0,0
    __list_add(elm, listelm, listelm->next);
ffffffffc0202a68:	6794                	ld	a3,8(a5)
    prev->next = next->prev = elm;
ffffffffc0202a6a:	e298                	sd	a4,0(a3)
ffffffffc0202a6c:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0202a6e:	fa1c                	sd	a5,48(a2)
    page->visited=1;
ffffffffc0202a70:	4785                	li	a5,1
    elm->next = next;
ffffffffc0202a72:	fe14                	sd	a3,56(a2)
ffffffffc0202a74:	ea1c                	sd	a5,16(a2)
    page->access_count = 0;  // 初始化访问计数器
ffffffffc0202a76:	04062423          	sw	zero,72(a2)
}
ffffffffc0202a7a:	8082                	ret
{
ffffffffc0202a7c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr2 != NULL);
ffffffffc0202a7e:	00003697          	auipc	a3,0x3
ffffffffc0202a82:	10268693          	addi	a3,a3,258 # ffffffffc0205b80 <default_pmm_manager+0x250>
ffffffffc0202a86:	00002617          	auipc	a2,0x2
ffffffffc0202a8a:	40260613          	addi	a2,a2,1026 # ffffffffc0204e88 <commands+0x728>
ffffffffc0202a8e:	03600593          	li	a1,54
ffffffffc0202a92:	00003517          	auipc	a0,0x3
ffffffffc0202a96:	f1e50513          	addi	a0,a0,-226 # ffffffffc02059b0 <default_pmm_manager+0x80>
{
ffffffffc0202a9a:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr2 != NULL);
ffffffffc0202a9c:	e66fd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202aa0 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202aa0:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0202aa2:	00002617          	auipc	a2,0x2
ffffffffc0202aa6:	63660613          	addi	a2,a2,1590 # ffffffffc02050d8 <commands+0x978>
ffffffffc0202aaa:	06500593          	li	a1,101
ffffffffc0202aae:	00002517          	auipc	a0,0x2
ffffffffc0202ab2:	64a50513          	addi	a0,a0,1610 # ffffffffc02050f8 <commands+0x998>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0202ab6:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0202ab8:	e4afd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202abc <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202abc:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0202abe:	00003617          	auipc	a2,0x3
ffffffffc0202ac2:	95a60613          	addi	a2,a2,-1702 # ffffffffc0205418 <commands+0xcb8>
ffffffffc0202ac6:	07000593          	li	a1,112
ffffffffc0202aca:	00002517          	auipc	a0,0x2
ffffffffc0202ace:	62e50513          	addi	a0,a0,1582 # ffffffffc02050f8 <commands+0x998>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc0202ad2:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0202ad4:	e2efd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202ad8 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0202ad8:	7139                	addi	sp,sp,-64
ffffffffc0202ada:	f426                	sd	s1,40(sp)
ffffffffc0202adc:	f04a                	sd	s2,32(sp)
ffffffffc0202ade:	ec4e                	sd	s3,24(sp)
ffffffffc0202ae0:	e852                	sd	s4,16(sp)
ffffffffc0202ae2:	e456                	sd	s5,8(sp)
ffffffffc0202ae4:	e05a                	sd	s6,0(sp)
ffffffffc0202ae6:	fc06                	sd	ra,56(sp)
ffffffffc0202ae8:	f822                	sd	s0,48(sp)
ffffffffc0202aea:	84aa                	mv	s1,a0
ffffffffc0202aec:	0000f917          	auipc	s2,0xf
ffffffffc0202af0:	a7490913          	addi	s2,s2,-1420 # ffffffffc0211560 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202af4:	4a05                	li	s4,1
ffffffffc0202af6:	0000fa97          	auipc	s5,0xf
ffffffffc0202afa:	a3aa8a93          	addi	s5,s5,-1478 # ffffffffc0211530 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0202afe:	0005099b          	sext.w	s3,a0
ffffffffc0202b02:	0000fb17          	auipc	s6,0xf
ffffffffc0202b06:	a0eb0b13          	addi	s6,s6,-1522 # ffffffffc0211510 <check_mm_struct>
ffffffffc0202b0a:	a01d                	j	ffffffffc0202b30 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202b0c:	00093783          	ld	a5,0(s2)
ffffffffc0202b10:	6f9c                	ld	a5,24(a5)
ffffffffc0202b12:	9782                	jalr	a5
ffffffffc0202b14:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b16:	4601                	li	a2,0
ffffffffc0202b18:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b1a:	ec0d                	bnez	s0,ffffffffc0202b54 <alloc_pages+0x7c>
ffffffffc0202b1c:	029a6c63          	bltu	s4,s1,ffffffffc0202b54 <alloc_pages+0x7c>
ffffffffc0202b20:	000aa783          	lw	a5,0(s5)
ffffffffc0202b24:	2781                	sext.w	a5,a5
ffffffffc0202b26:	c79d                	beqz	a5,ffffffffc0202b54 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b28:	000b3503          	ld	a0,0(s6)
ffffffffc0202b2c:	e8dfe0ef          	jal	ra,ffffffffc02019b8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b30:	100027f3          	csrr	a5,sstatus
ffffffffc0202b34:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0202b36:	8526                	mv	a0,s1
ffffffffc0202b38:	dbf1                	beqz	a5,ffffffffc0202b0c <alloc_pages+0x34>
        intr_disable();
ffffffffc0202b3a:	9b5fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202b3e:	00093783          	ld	a5,0(s2)
ffffffffc0202b42:	8526                	mv	a0,s1
ffffffffc0202b44:	6f9c                	ld	a5,24(a5)
ffffffffc0202b46:	9782                	jalr	a5
ffffffffc0202b48:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b4a:	99ffd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0202b4e:	4601                	li	a2,0
ffffffffc0202b50:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202b52:	d469                	beqz	s0,ffffffffc0202b1c <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0202b54:	70e2                	ld	ra,56(sp)
ffffffffc0202b56:	8522                	mv	a0,s0
ffffffffc0202b58:	7442                	ld	s0,48(sp)
ffffffffc0202b5a:	74a2                	ld	s1,40(sp)
ffffffffc0202b5c:	7902                	ld	s2,32(sp)
ffffffffc0202b5e:	69e2                	ld	s3,24(sp)
ffffffffc0202b60:	6a42                	ld	s4,16(sp)
ffffffffc0202b62:	6aa2                	ld	s5,8(sp)
ffffffffc0202b64:	6b02                	ld	s6,0(sp)
ffffffffc0202b66:	6121                	addi	sp,sp,64
ffffffffc0202b68:	8082                	ret

ffffffffc0202b6a <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202b6a:	100027f3          	csrr	a5,sstatus
ffffffffc0202b6e:	8b89                	andi	a5,a5,2
ffffffffc0202b70:	e799                	bnez	a5,ffffffffc0202b7e <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b72:	0000f797          	auipc	a5,0xf
ffffffffc0202b76:	9ee7b783          	ld	a5,-1554(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202b7a:	739c                	ld	a5,32(a5)
ffffffffc0202b7c:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0202b7e:	1101                	addi	sp,sp,-32
ffffffffc0202b80:	ec06                	sd	ra,24(sp)
ffffffffc0202b82:	e822                	sd	s0,16(sp)
ffffffffc0202b84:	e426                	sd	s1,8(sp)
ffffffffc0202b86:	842a                	mv	s0,a0
ffffffffc0202b88:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202b8a:	965fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202b8e:	0000f797          	auipc	a5,0xf
ffffffffc0202b92:	9d27b783          	ld	a5,-1582(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202b96:	739c                	ld	a5,32(a5)
ffffffffc0202b98:	85a6                	mv	a1,s1
ffffffffc0202b9a:	8522                	mv	a0,s0
ffffffffc0202b9c:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0202b9e:	6442                	ld	s0,16(sp)
ffffffffc0202ba0:	60e2                	ld	ra,24(sp)
ffffffffc0202ba2:	64a2                	ld	s1,8(sp)
ffffffffc0202ba4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0202ba6:	943fd06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc0202baa <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202baa:	100027f3          	csrr	a5,sstatus
ffffffffc0202bae:	8b89                	andi	a5,a5,2
ffffffffc0202bb0:	e799                	bnez	a5,ffffffffc0202bbe <nr_free_pages+0x14>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202bb2:	0000f797          	auipc	a5,0xf
ffffffffc0202bb6:	9ae7b783          	ld	a5,-1618(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202bba:	779c                	ld	a5,40(a5)
ffffffffc0202bbc:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0202bbe:	1141                	addi	sp,sp,-16
ffffffffc0202bc0:	e406                	sd	ra,8(sp)
ffffffffc0202bc2:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202bc4:	92bfd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202bc8:	0000f797          	auipc	a5,0xf
ffffffffc0202bcc:	9987b783          	ld	a5,-1640(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202bd0:	779c                	ld	a5,40(a5)
ffffffffc0202bd2:	9782                	jalr	a5
ffffffffc0202bd4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bd6:	913fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202bda:	60a2                	ld	ra,8(sp)
ffffffffc0202bdc:	8522                	mv	a0,s0
ffffffffc0202bde:	6402                	ld	s0,0(sp)
ffffffffc0202be0:	0141                	addi	sp,sp,16
ffffffffc0202be2:	8082                	ret

ffffffffc0202be4 <get_pte>:
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202be4:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202be8:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202bec:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202bee:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202bf0:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0202bf2:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202bf6:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202bf8:	f84a                	sd	s2,48(sp)
ffffffffc0202bfa:	f44e                	sd	s3,40(sp)
ffffffffc0202bfc:	f052                	sd	s4,32(sp)
ffffffffc0202bfe:	e486                	sd	ra,72(sp)
ffffffffc0202c00:	e0a2                	sd	s0,64(sp)
ffffffffc0202c02:	ec56                	sd	s5,24(sp)
ffffffffc0202c04:	e85a                	sd	s6,16(sp)
ffffffffc0202c06:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c08:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0202c0c:	892e                	mv	s2,a1
ffffffffc0202c0e:	8a32                	mv	s4,a2
ffffffffc0202c10:	0000f997          	auipc	s3,0xf
ffffffffc0202c14:	94098993          	addi	s3,s3,-1728 # ffffffffc0211550 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0202c18:	efb5                	bnez	a5,ffffffffc0202c94 <get_pte+0xb0>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202c1a:	14060c63          	beqz	a2,ffffffffc0202d72 <get_pte+0x18e>
ffffffffc0202c1e:	4505                	li	a0,1
ffffffffc0202c20:	eb9ff0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0202c24:	842a                	mv	s0,a0
ffffffffc0202c26:	14050663          	beqz	a0,ffffffffc0202d72 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c2a:	0000fb97          	auipc	s7,0xf
ffffffffc0202c2e:	92eb8b93          	addi	s7,s7,-1746 # ffffffffc0211558 <pages>
ffffffffc0202c32:	000bb503          	ld	a0,0(s7)
ffffffffc0202c36:	00004b17          	auipc	s6,0x4
ffffffffc0202c3a:	822b3b03          	ld	s6,-2014(s6) # ffffffffc0206458 <error_string+0x38>
ffffffffc0202c3e:	00080ab7          	lui	s5,0x80
ffffffffc0202c42:	40a40533          	sub	a0,s0,a0
ffffffffc0202c46:	8511                	srai	a0,a0,0x4
ffffffffc0202c48:	03650533          	mul	a0,a0,s6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202c4c:	0000f997          	auipc	s3,0xf
ffffffffc0202c50:	90498993          	addi	s3,s3,-1788 # ffffffffc0211550 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202c54:	4785                	li	a5,1
ffffffffc0202c56:	0009b703          	ld	a4,0(s3)
ffffffffc0202c5a:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c5c:	9556                	add	a0,a0,s5
ffffffffc0202c5e:	00c51793          	slli	a5,a0,0xc
ffffffffc0202c62:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202c64:	0532                	slli	a0,a0,0xc
ffffffffc0202c66:	14e7fd63          	bgeu	a5,a4,ffffffffc0202dc0 <get_pte+0x1dc>
ffffffffc0202c6a:	0000f797          	auipc	a5,0xf
ffffffffc0202c6e:	8fe7b783          	ld	a5,-1794(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0202c72:	6605                	lui	a2,0x1
ffffffffc0202c74:	4581                	li	a1,0
ffffffffc0202c76:	953e                	add	a0,a0,a5
ffffffffc0202c78:	3a2010ef          	jal	ra,ffffffffc020401a <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202c7c:	000bb683          	ld	a3,0(s7)
ffffffffc0202c80:	40d406b3          	sub	a3,s0,a3
ffffffffc0202c84:	8691                	srai	a3,a3,0x4
ffffffffc0202c86:	036686b3          	mul	a3,a3,s6
ffffffffc0202c8a:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202c8c:	06aa                	slli	a3,a3,0xa
ffffffffc0202c8e:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202c92:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202c94:	77fd                	lui	a5,0xfffff
ffffffffc0202c96:	068a                	slli	a3,a3,0x2
ffffffffc0202c98:	0009b703          	ld	a4,0(s3)
ffffffffc0202c9c:	8efd                	and	a3,a3,a5
ffffffffc0202c9e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202ca2:	0ce7fa63          	bgeu	a5,a4,ffffffffc0202d76 <get_pte+0x192>
ffffffffc0202ca6:	0000fa97          	auipc	s5,0xf
ffffffffc0202caa:	8c2a8a93          	addi	s5,s5,-1854 # ffffffffc0211568 <va_pa_offset>
ffffffffc0202cae:	000ab403          	ld	s0,0(s5)
ffffffffc0202cb2:	01595793          	srli	a5,s2,0x15
ffffffffc0202cb6:	1ff7f793          	andi	a5,a5,511
ffffffffc0202cba:	96a2                	add	a3,a3,s0
ffffffffc0202cbc:	00379413          	slli	s0,a5,0x3
ffffffffc0202cc0:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202cc2:	6014                	ld	a3,0(s0)
ffffffffc0202cc4:	0016f793          	andi	a5,a3,1
ffffffffc0202cc8:	ebad                	bnez	a5,ffffffffc0202d3a <get_pte+0x156>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202cca:	0a0a0463          	beqz	s4,ffffffffc0202d72 <get_pte+0x18e>
ffffffffc0202cce:	4505                	li	a0,1
ffffffffc0202cd0:	e09ff0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0202cd4:	84aa                	mv	s1,a0
ffffffffc0202cd6:	cd51                	beqz	a0,ffffffffc0202d72 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202cd8:	0000fb97          	auipc	s7,0xf
ffffffffc0202cdc:	880b8b93          	addi	s7,s7,-1920 # ffffffffc0211558 <pages>
ffffffffc0202ce0:	000bb503          	ld	a0,0(s7)
ffffffffc0202ce4:	00003b17          	auipc	s6,0x3
ffffffffc0202ce8:	774b3b03          	ld	s6,1908(s6) # ffffffffc0206458 <error_string+0x38>
ffffffffc0202cec:	00080a37          	lui	s4,0x80
ffffffffc0202cf0:	40a48533          	sub	a0,s1,a0
ffffffffc0202cf4:	8511                	srai	a0,a0,0x4
ffffffffc0202cf6:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0202cfa:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202cfc:	0009b703          	ld	a4,0(s3)
ffffffffc0202d00:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d02:	9552                	add	a0,a0,s4
ffffffffc0202d04:	00c51793          	slli	a5,a0,0xc
ffffffffc0202d08:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d0a:	0532                	slli	a0,a0,0xc
ffffffffc0202d0c:	08e7fd63          	bgeu	a5,a4,ffffffffc0202da6 <get_pte+0x1c2>
ffffffffc0202d10:	000ab783          	ld	a5,0(s5)
ffffffffc0202d14:	6605                	lui	a2,0x1
ffffffffc0202d16:	4581                	li	a1,0
ffffffffc0202d18:	953e                	add	a0,a0,a5
ffffffffc0202d1a:	300010ef          	jal	ra,ffffffffc020401a <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202d1e:	000bb683          	ld	a3,0(s7)
ffffffffc0202d22:	40d486b3          	sub	a3,s1,a3
ffffffffc0202d26:	8691                	srai	a3,a3,0x4
ffffffffc0202d28:	036686b3          	mul	a3,a3,s6
ffffffffc0202d2c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202d2e:	06aa                	slli	a3,a3,0xa
ffffffffc0202d30:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202d34:	e014                	sd	a3,0(s0)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202d36:	0009b703          	ld	a4,0(s3)
ffffffffc0202d3a:	068a                	slli	a3,a3,0x2
ffffffffc0202d3c:	757d                	lui	a0,0xfffff
ffffffffc0202d3e:	8ee9                	and	a3,a3,a0
ffffffffc0202d40:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202d44:	04e7f563          	bgeu	a5,a4,ffffffffc0202d8e <get_pte+0x1aa>
ffffffffc0202d48:	000ab503          	ld	a0,0(s5)
ffffffffc0202d4c:	00c95913          	srli	s2,s2,0xc
ffffffffc0202d50:	1ff97913          	andi	s2,s2,511
ffffffffc0202d54:	96aa                	add	a3,a3,a0
ffffffffc0202d56:	00391513          	slli	a0,s2,0x3
ffffffffc0202d5a:	9536                	add	a0,a0,a3
}
ffffffffc0202d5c:	60a6                	ld	ra,72(sp)
ffffffffc0202d5e:	6406                	ld	s0,64(sp)
ffffffffc0202d60:	74e2                	ld	s1,56(sp)
ffffffffc0202d62:	7942                	ld	s2,48(sp)
ffffffffc0202d64:	79a2                	ld	s3,40(sp)
ffffffffc0202d66:	7a02                	ld	s4,32(sp)
ffffffffc0202d68:	6ae2                	ld	s5,24(sp)
ffffffffc0202d6a:	6b42                	ld	s6,16(sp)
ffffffffc0202d6c:	6ba2                	ld	s7,8(sp)
ffffffffc0202d6e:	6161                	addi	sp,sp,80
ffffffffc0202d70:	8082                	ret
            return NULL;
ffffffffc0202d72:	4501                	li	a0,0
ffffffffc0202d74:	b7e5                	j	ffffffffc0202d5c <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202d76:	00003617          	auipc	a2,0x3
ffffffffc0202d7a:	e4a60613          	addi	a2,a2,-438 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0202d7e:	10200593          	li	a1,258
ffffffffc0202d82:	00003517          	auipc	a0,0x3
ffffffffc0202d86:	e6650513          	addi	a0,a0,-410 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0202d8a:	b78fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202d8e:	00003617          	auipc	a2,0x3
ffffffffc0202d92:	e3260613          	addi	a2,a2,-462 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0202d96:	10f00593          	li	a1,271
ffffffffc0202d9a:	00003517          	auipc	a0,0x3
ffffffffc0202d9e:	e4e50513          	addi	a0,a0,-434 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0202da2:	b60fd0ef          	jal	ra,ffffffffc0200102 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202da6:	86aa                	mv	a3,a0
ffffffffc0202da8:	00003617          	auipc	a2,0x3
ffffffffc0202dac:	e1860613          	addi	a2,a2,-488 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0202db0:	10b00593          	li	a1,267
ffffffffc0202db4:	00003517          	auipc	a0,0x3
ffffffffc0202db8:	e3450513          	addi	a0,a0,-460 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0202dbc:	b46fd0ef          	jal	ra,ffffffffc0200102 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202dc0:	86aa                	mv	a3,a0
ffffffffc0202dc2:	00003617          	auipc	a2,0x3
ffffffffc0202dc6:	dfe60613          	addi	a2,a2,-514 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0202dca:	0ff00593          	li	a1,255
ffffffffc0202dce:	00003517          	auipc	a0,0x3
ffffffffc0202dd2:	e1a50513          	addi	a0,a0,-486 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0202dd6:	b2cfd0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0202dda <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202dda:	1141                	addi	sp,sp,-16
ffffffffc0202ddc:	e022                	sd	s0,0(sp)
ffffffffc0202dde:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202de0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202de2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202de4:	e01ff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202de8:	c011                	beqz	s0,ffffffffc0202dec <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202dea:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202dec:	c511                	beqz	a0,ffffffffc0202df8 <get_page+0x1e>
ffffffffc0202dee:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202df0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202df2:	0017f713          	andi	a4,a5,1
ffffffffc0202df6:	e709                	bnez	a4,ffffffffc0202e00 <get_page+0x26>
}
ffffffffc0202df8:	60a2                	ld	ra,8(sp)
ffffffffc0202dfa:	6402                	ld	s0,0(sp)
ffffffffc0202dfc:	0141                	addi	sp,sp,16
ffffffffc0202dfe:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e00:	078a                	slli	a5,a5,0x2
ffffffffc0202e02:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e04:	0000e717          	auipc	a4,0xe
ffffffffc0202e08:	74c73703          	ld	a4,1868(a4) # ffffffffc0211550 <npage>
ffffffffc0202e0c:	02e7f263          	bgeu	a5,a4,ffffffffc0202e30 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e10:	fff80537          	lui	a0,0xfff80
ffffffffc0202e14:	97aa                	add	a5,a5,a0
ffffffffc0202e16:	60a2                	ld	ra,8(sp)
ffffffffc0202e18:	6402                	ld	s0,0(sp)
ffffffffc0202e1a:	00279513          	slli	a0,a5,0x2
ffffffffc0202e1e:	97aa                	add	a5,a5,a0
ffffffffc0202e20:	0792                	slli	a5,a5,0x4
ffffffffc0202e22:	0000e517          	auipc	a0,0xe
ffffffffc0202e26:	73653503          	ld	a0,1846(a0) # ffffffffc0211558 <pages>
ffffffffc0202e2a:	953e                	add	a0,a0,a5
ffffffffc0202e2c:	0141                	addi	sp,sp,16
ffffffffc0202e2e:	8082                	ret
ffffffffc0202e30:	c71ff0ef          	jal	ra,ffffffffc0202aa0 <pa2page.part.0>

ffffffffc0202e34 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202e34:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e36:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202e38:	ec06                	sd	ra,24(sp)
ffffffffc0202e3a:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202e3c:	da9ff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
    if (ptep != NULL) {
ffffffffc0202e40:	c511                	beqz	a0,ffffffffc0202e4c <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202e42:	611c                	ld	a5,0(a0)
ffffffffc0202e44:	842a                	mv	s0,a0
ffffffffc0202e46:	0017f713          	andi	a4,a5,1
ffffffffc0202e4a:	e709                	bnez	a4,ffffffffc0202e54 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0202e4c:	60e2                	ld	ra,24(sp)
ffffffffc0202e4e:	6442                	ld	s0,16(sp)
ffffffffc0202e50:	6105                	addi	sp,sp,32
ffffffffc0202e52:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e54:	078a                	slli	a5,a5,0x2
ffffffffc0202e56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e58:	0000e717          	auipc	a4,0xe
ffffffffc0202e5c:	6f873703          	ld	a4,1784(a4) # ffffffffc0211550 <npage>
ffffffffc0202e60:	06e7f563          	bgeu	a5,a4,ffffffffc0202eca <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e64:	fff80737          	lui	a4,0xfff80
ffffffffc0202e68:	97ba                	add	a5,a5,a4
ffffffffc0202e6a:	00279513          	slli	a0,a5,0x2
ffffffffc0202e6e:	97aa                	add	a5,a5,a0
ffffffffc0202e70:	0792                	slli	a5,a5,0x4
ffffffffc0202e72:	0000e517          	auipc	a0,0xe
ffffffffc0202e76:	6e653503          	ld	a0,1766(a0) # ffffffffc0211558 <pages>
ffffffffc0202e7a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202e7c:	411c                	lw	a5,0(a0)
ffffffffc0202e7e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202e82:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202e84:	cb09                	beqz	a4,ffffffffc0202e96 <page_remove+0x62>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202e86:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202e8a:	12000073          	sfence.vma
}
ffffffffc0202e8e:	60e2                	ld	ra,24(sp)
ffffffffc0202e90:	6442                	ld	s0,16(sp)
ffffffffc0202e92:	6105                	addi	sp,sp,32
ffffffffc0202e94:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202e96:	100027f3          	csrr	a5,sstatus
ffffffffc0202e9a:	8b89                	andi	a5,a5,2
ffffffffc0202e9c:	eb89                	bnez	a5,ffffffffc0202eae <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202e9e:	0000e797          	auipc	a5,0xe
ffffffffc0202ea2:	6c27b783          	ld	a5,1730(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ea6:	739c                	ld	a5,32(a5)
ffffffffc0202ea8:	4585                	li	a1,1
ffffffffc0202eaa:	9782                	jalr	a5
    if (flag) {
ffffffffc0202eac:	bfe9                	j	ffffffffc0202e86 <page_remove+0x52>
        intr_disable();
ffffffffc0202eae:	e42a                	sd	a0,8(sp)
ffffffffc0202eb0:	e3efd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202eb4:	0000e797          	auipc	a5,0xe
ffffffffc0202eb8:	6ac7b783          	ld	a5,1708(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202ebc:	739c                	ld	a5,32(a5)
ffffffffc0202ebe:	6522                	ld	a0,8(sp)
ffffffffc0202ec0:	4585                	li	a1,1
ffffffffc0202ec2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ec4:	e24fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202ec8:	bf7d                	j	ffffffffc0202e86 <page_remove+0x52>
ffffffffc0202eca:	bd7ff0ef          	jal	ra,ffffffffc0202aa0 <pa2page.part.0>

ffffffffc0202ece <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202ece:	7179                	addi	sp,sp,-48
ffffffffc0202ed0:	87b2                	mv	a5,a2
ffffffffc0202ed2:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202ed4:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202ed6:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202ed8:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202eda:	ec26                	sd	s1,24(sp)
ffffffffc0202edc:	f406                	sd	ra,40(sp)
ffffffffc0202ede:	e84a                	sd	s2,16(sp)
ffffffffc0202ee0:	e44e                	sd	s3,8(sp)
ffffffffc0202ee2:	e052                	sd	s4,0(sp)
ffffffffc0202ee4:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202ee6:	cffff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
    if (ptep == NULL) {
ffffffffc0202eea:	cd71                	beqz	a0,ffffffffc0202fc6 <page_insert+0xf8>
    page->ref += 1;
ffffffffc0202eec:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0202eee:	611c                	ld	a5,0(a0)
ffffffffc0202ef0:	89aa                	mv	s3,a0
ffffffffc0202ef2:	0016871b          	addiw	a4,a3,1
ffffffffc0202ef6:	c018                	sw	a4,0(s0)
ffffffffc0202ef8:	0017f713          	andi	a4,a5,1
ffffffffc0202efc:	e331                	bnez	a4,ffffffffc0202f40 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202efe:	0000e797          	auipc	a5,0xe
ffffffffc0202f02:	65a7b783          	ld	a5,1626(a5) # ffffffffc0211558 <pages>
ffffffffc0202f06:	40f407b3          	sub	a5,s0,a5
ffffffffc0202f0a:	8791                	srai	a5,a5,0x4
ffffffffc0202f0c:	00003417          	auipc	s0,0x3
ffffffffc0202f10:	54c43403          	ld	s0,1356(s0) # ffffffffc0206458 <error_string+0x38>
ffffffffc0202f14:	028787b3          	mul	a5,a5,s0
ffffffffc0202f18:	00080437          	lui	s0,0x80
ffffffffc0202f1c:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202f1e:	07aa                	slli	a5,a5,0xa
ffffffffc0202f20:	8cdd                	or	s1,s1,a5
ffffffffc0202f22:	0014e493          	ori	s1,s1,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202f26:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f2a:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0202f2e:	4501                	li	a0,0
}
ffffffffc0202f30:	70a2                	ld	ra,40(sp)
ffffffffc0202f32:	7402                	ld	s0,32(sp)
ffffffffc0202f34:	64e2                	ld	s1,24(sp)
ffffffffc0202f36:	6942                	ld	s2,16(sp)
ffffffffc0202f38:	69a2                	ld	s3,8(sp)
ffffffffc0202f3a:	6a02                	ld	s4,0(sp)
ffffffffc0202f3c:	6145                	addi	sp,sp,48
ffffffffc0202f3e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202f40:	00279713          	slli	a4,a5,0x2
ffffffffc0202f44:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202f46:	0000e797          	auipc	a5,0xe
ffffffffc0202f4a:	60a7b783          	ld	a5,1546(a5) # ffffffffc0211550 <npage>
ffffffffc0202f4e:	06f77e63          	bgeu	a4,a5,ffffffffc0202fca <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0202f52:	fff807b7          	lui	a5,0xfff80
ffffffffc0202f56:	973e                	add	a4,a4,a5
ffffffffc0202f58:	0000ea17          	auipc	s4,0xe
ffffffffc0202f5c:	600a0a13          	addi	s4,s4,1536 # ffffffffc0211558 <pages>
ffffffffc0202f60:	000a3783          	ld	a5,0(s4)
ffffffffc0202f64:	00271913          	slli	s2,a4,0x2
ffffffffc0202f68:	993a                	add	s2,s2,a4
ffffffffc0202f6a:	0912                	slli	s2,s2,0x4
ffffffffc0202f6c:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0202f6e:	03240063          	beq	s0,s2,ffffffffc0202f8e <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0202f72:	00092783          	lw	a5,0(s2)
ffffffffc0202f76:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202f7a:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) ==
ffffffffc0202f7e:	cb11                	beqz	a4,ffffffffc0202f92 <page_insert+0xc4>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202f80:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202f84:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202f88:	000a3783          	ld	a5,0(s4)
}
ffffffffc0202f8c:	bfad                	j	ffffffffc0202f06 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0202f8e:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202f90:	bf9d                	j	ffffffffc0202f06 <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202f92:	100027f3          	csrr	a5,sstatus
ffffffffc0202f96:	8b89                	andi	a5,a5,2
ffffffffc0202f98:	eb91                	bnez	a5,ffffffffc0202fac <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202f9a:	0000e797          	auipc	a5,0xe
ffffffffc0202f9e:	5c67b783          	ld	a5,1478(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202fa2:	739c                	ld	a5,32(a5)
ffffffffc0202fa4:	4585                	li	a1,1
ffffffffc0202fa6:	854a                	mv	a0,s2
ffffffffc0202fa8:	9782                	jalr	a5
    if (flag) {
ffffffffc0202faa:	bfd9                	j	ffffffffc0202f80 <page_insert+0xb2>
        intr_disable();
ffffffffc0202fac:	d42fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202fb0:	0000e797          	auipc	a5,0xe
ffffffffc0202fb4:	5b07b783          	ld	a5,1456(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0202fb8:	739c                	ld	a5,32(a5)
ffffffffc0202fba:	4585                	li	a1,1
ffffffffc0202fbc:	854a                	mv	a0,s2
ffffffffc0202fbe:	9782                	jalr	a5
        intr_enable();
ffffffffc0202fc0:	d28fd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202fc4:	bf75                	j	ffffffffc0202f80 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0202fc6:	5571                	li	a0,-4
ffffffffc0202fc8:	b7a5                	j	ffffffffc0202f30 <page_insert+0x62>
ffffffffc0202fca:	ad7ff0ef          	jal	ra,ffffffffc0202aa0 <pa2page.part.0>

ffffffffc0202fce <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202fce:	00003797          	auipc	a5,0x3
ffffffffc0202fd2:	96278793          	addi	a5,a5,-1694 # ffffffffc0205930 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202fd6:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202fd8:	7159                	addi	sp,sp,-112
ffffffffc0202fda:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202fdc:	00003517          	auipc	a0,0x3
ffffffffc0202fe0:	c1c50513          	addi	a0,a0,-996 # ffffffffc0205bf8 <default_pmm_manager+0x2c8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202fe4:	0000eb97          	auipc	s7,0xe
ffffffffc0202fe8:	57cb8b93          	addi	s7,s7,1404 # ffffffffc0211560 <pmm_manager>
void pmm_init(void) {
ffffffffc0202fec:	f486                	sd	ra,104(sp)
ffffffffc0202fee:	f0a2                	sd	s0,96(sp)
ffffffffc0202ff0:	eca6                	sd	s1,88(sp)
ffffffffc0202ff2:	e8ca                	sd	s2,80(sp)
ffffffffc0202ff4:	e4ce                	sd	s3,72(sp)
ffffffffc0202ff6:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202ff8:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0202ffc:	e0d2                	sd	s4,64(sp)
ffffffffc0202ffe:	fc56                	sd	s5,56(sp)
ffffffffc0203000:	f062                	sd	s8,32(sp)
ffffffffc0203002:	ec66                	sd	s9,24(sp)
ffffffffc0203004:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0203006:	8b4fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc020300a:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020300e:	4445                	li	s0,17
ffffffffc0203010:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0203014:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203016:	0000e997          	auipc	s3,0xe
ffffffffc020301a:	55298993          	addi	s3,s3,1362 # ffffffffc0211568 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc020301e:	0000e497          	auipc	s1,0xe
ffffffffc0203022:	53248493          	addi	s1,s1,1330 # ffffffffc0211550 <npage>
    pmm_manager->init();
ffffffffc0203026:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203028:	57f5                	li	a5,-3
ffffffffc020302a:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc020302c:	07e006b7          	lui	a3,0x7e00
ffffffffc0203030:	01b41613          	slli	a2,s0,0x1b
ffffffffc0203034:	01591593          	slli	a1,s2,0x15
ffffffffc0203038:	00003517          	auipc	a0,0x3
ffffffffc020303c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0205c10 <default_pmm_manager+0x2e0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0203040:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0203044:	876fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0203048:	00003517          	auipc	a0,0x3
ffffffffc020304c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0205c40 <default_pmm_manager+0x310>
ffffffffc0203050:	86afd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0203054:	01b41693          	slli	a3,s0,0x1b
ffffffffc0203058:	16fd                	addi	a3,a3,-1
ffffffffc020305a:	07e005b7          	lui	a1,0x7e00
ffffffffc020305e:	01591613          	slli	a2,s2,0x15
ffffffffc0203062:	00003517          	auipc	a0,0x3
ffffffffc0203066:	bf650513          	addi	a0,a0,-1034 # ffffffffc0205c58 <default_pmm_manager+0x328>
ffffffffc020306a:	850fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020306e:	777d                	lui	a4,0xfffff
ffffffffc0203070:	0000f797          	auipc	a5,0xf
ffffffffc0203074:	4ff78793          	addi	a5,a5,1279 # ffffffffc021256f <end+0xfff>
ffffffffc0203078:	8ff9                	and	a5,a5,a4
ffffffffc020307a:	0000eb17          	auipc	s6,0xe
ffffffffc020307e:	4deb0b13          	addi	s6,s6,1246 # ffffffffc0211558 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0203082:	00088737          	lui	a4,0x88
ffffffffc0203086:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0203088:	00fb3023          	sd	a5,0(s6)
ffffffffc020308c:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020308e:	4701                	li	a4,0
ffffffffc0203090:	4505                	li	a0,1
ffffffffc0203092:	fff805b7          	lui	a1,0xfff80
ffffffffc0203096:	a019                	j	ffffffffc020309c <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0203098:	000b3783          	ld	a5,0(s6)
ffffffffc020309c:	97b6                	add	a5,a5,a3
ffffffffc020309e:	07a1                	addi	a5,a5,8
ffffffffc02030a0:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02030a4:	609c                	ld	a5,0(s1)
ffffffffc02030a6:	0705                	addi	a4,a4,1
ffffffffc02030a8:	05068693          	addi	a3,a3,80 # 7e00050 <kern_entry-0xffffffffb83fffb0>
ffffffffc02030ac:	00b78633          	add	a2,a5,a1
ffffffffc02030b0:	fec764e3          	bltu	a4,a2,ffffffffc0203098 <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02030b4:	000b3503          	ld	a0,0(s6)
ffffffffc02030b8:	00279693          	slli	a3,a5,0x2
ffffffffc02030bc:	96be                	add	a3,a3,a5
ffffffffc02030be:	fd800737          	lui	a4,0xfd800
ffffffffc02030c2:	972a                	add	a4,a4,a0
ffffffffc02030c4:	0692                	slli	a3,a3,0x4
ffffffffc02030c6:	96ba                	add	a3,a3,a4
ffffffffc02030c8:	c0200737          	lui	a4,0xc0200
ffffffffc02030cc:	64e6e463          	bltu	a3,a4,ffffffffc0203714 <pmm_init+0x746>
ffffffffc02030d0:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc02030d4:	4645                	li	a2,17
ffffffffc02030d6:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02030d8:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02030da:	4ec6e263          	bltu	a3,a2,ffffffffc02035be <pmm_init+0x5f0>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02030de:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02030e2:	0000e917          	auipc	s2,0xe
ffffffffc02030e6:	46690913          	addi	s2,s2,1126 # ffffffffc0211548 <boot_pgdir>
    pmm_manager->check();
ffffffffc02030ea:	7b9c                	ld	a5,48(a5)
ffffffffc02030ec:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02030ee:	00003517          	auipc	a0,0x3
ffffffffc02030f2:	bba50513          	addi	a0,a0,-1094 # ffffffffc0205ca8 <default_pmm_manager+0x378>
ffffffffc02030f6:	fc5fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc02030fa:	00006697          	auipc	a3,0x6
ffffffffc02030fe:	f0668693          	addi	a3,a3,-250 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0203102:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203106:	c02007b7          	lui	a5,0xc0200
ffffffffc020310a:	62f6e163          	bltu	a3,a5,ffffffffc020372c <pmm_init+0x75e>
ffffffffc020310e:	0009b783          	ld	a5,0(s3)
ffffffffc0203112:	8e9d                	sub	a3,a3,a5
ffffffffc0203114:	0000e797          	auipc	a5,0xe
ffffffffc0203118:	42d7b623          	sd	a3,1068(a5) # ffffffffc0211540 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020311c:	100027f3          	csrr	a5,sstatus
ffffffffc0203120:	8b89                	andi	a5,a5,2
ffffffffc0203122:	4c079763          	bnez	a5,ffffffffc02035f0 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203126:	000bb783          	ld	a5,0(s7)
ffffffffc020312a:	779c                	ld	a5,40(a5)
ffffffffc020312c:	9782                	jalr	a5
ffffffffc020312e:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203130:	6098                	ld	a4,0(s1)
ffffffffc0203132:	c80007b7          	lui	a5,0xc8000
ffffffffc0203136:	83b1                	srli	a5,a5,0xc
ffffffffc0203138:	62e7e663          	bltu	a5,a4,ffffffffc0203764 <pmm_init+0x796>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020313c:	00093503          	ld	a0,0(s2)
ffffffffc0203140:	60050263          	beqz	a0,ffffffffc0203744 <pmm_init+0x776>
ffffffffc0203144:	03451793          	slli	a5,a0,0x34
ffffffffc0203148:	5e079e63          	bnez	a5,ffffffffc0203744 <pmm_init+0x776>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020314c:	4601                	li	a2,0
ffffffffc020314e:	4581                	li	a1,0
ffffffffc0203150:	c8bff0ef          	jal	ra,ffffffffc0202dda <get_page>
ffffffffc0203154:	66051a63          	bnez	a0,ffffffffc02037c8 <pmm_init+0x7fa>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0203158:	4505                	li	a0,1
ffffffffc020315a:	97fff0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc020315e:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0203160:	00093503          	ld	a0,0(s2)
ffffffffc0203164:	4681                	li	a3,0
ffffffffc0203166:	4601                	li	a2,0
ffffffffc0203168:	85d2                	mv	a1,s4
ffffffffc020316a:	d65ff0ef          	jal	ra,ffffffffc0202ece <page_insert>
ffffffffc020316e:	62051d63          	bnez	a0,ffffffffc02037a8 <pmm_init+0x7da>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203172:	00093503          	ld	a0,0(s2)
ffffffffc0203176:	4601                	li	a2,0
ffffffffc0203178:	4581                	li	a1,0
ffffffffc020317a:	a6bff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
ffffffffc020317e:	60050563          	beqz	a0,ffffffffc0203788 <pmm_init+0x7ba>
    assert(pte2page(*ptep) == p1);
ffffffffc0203182:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203184:	0017f713          	andi	a4,a5,1
ffffffffc0203188:	5e070e63          	beqz	a4,ffffffffc0203784 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020318c:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020318e:	078a                	slli	a5,a5,0x2
ffffffffc0203190:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203192:	56c7ff63          	bgeu	a5,a2,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203196:	fff80737          	lui	a4,0xfff80
ffffffffc020319a:	97ba                	add	a5,a5,a4
ffffffffc020319c:	000b3683          	ld	a3,0(s6)
ffffffffc02031a0:	00279713          	slli	a4,a5,0x2
ffffffffc02031a4:	97ba                	add	a5,a5,a4
ffffffffc02031a6:	0792                	slli	a5,a5,0x4
ffffffffc02031a8:	97b6                	add	a5,a5,a3
ffffffffc02031aa:	14fa18e3          	bne	s4,a5,ffffffffc0203afa <pmm_init+0xb2c>
    assert(page_ref(p1) == 1);
ffffffffc02031ae:	000a2703          	lw	a4,0(s4)
ffffffffc02031b2:	4785                	li	a5,1
ffffffffc02031b4:	16f71fe3          	bne	a4,a5,ffffffffc0203b32 <pmm_init+0xb64>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02031b8:	00093503          	ld	a0,0(s2)
ffffffffc02031bc:	77fd                	lui	a5,0xfffff
ffffffffc02031be:	6114                	ld	a3,0(a0)
ffffffffc02031c0:	068a                	slli	a3,a3,0x2
ffffffffc02031c2:	8efd                	and	a3,a3,a5
ffffffffc02031c4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02031c8:	14c779e3          	bgeu	a4,a2,ffffffffc0203b1a <pmm_init+0xb4c>
ffffffffc02031cc:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02031d0:	96e2                	add	a3,a3,s8
ffffffffc02031d2:	0006ba83          	ld	s5,0(a3)
ffffffffc02031d6:	0a8a                	slli	s5,s5,0x2
ffffffffc02031d8:	00fafab3          	and	s5,s5,a5
ffffffffc02031dc:	00cad793          	srli	a5,s5,0xc
ffffffffc02031e0:	66c7f463          	bgeu	a5,a2,ffffffffc0203848 <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02031e4:	4601                	li	a2,0
ffffffffc02031e6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02031e8:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02031ea:	9fbff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02031ee:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02031f0:	63551c63          	bne	a0,s5,ffffffffc0203828 <pmm_init+0x85a>

    p2 = alloc_page();
ffffffffc02031f4:	4505                	li	a0,1
ffffffffc02031f6:	8e3ff0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc02031fa:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02031fc:	00093503          	ld	a0,0(s2)
ffffffffc0203200:	46d1                	li	a3,20
ffffffffc0203202:	6605                	lui	a2,0x1
ffffffffc0203204:	85d6                	mv	a1,s5
ffffffffc0203206:	cc9ff0ef          	jal	ra,ffffffffc0202ece <page_insert>
ffffffffc020320a:	5c051f63          	bnez	a0,ffffffffc02037e8 <pmm_init+0x81a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020320e:	00093503          	ld	a0,0(s2)
ffffffffc0203212:	4601                	li	a2,0
ffffffffc0203214:	6585                	lui	a1,0x1
ffffffffc0203216:	9cfff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
ffffffffc020321a:	12050ce3          	beqz	a0,ffffffffc0203b52 <pmm_init+0xb84>
    assert(*ptep & PTE_U);
ffffffffc020321e:	611c                	ld	a5,0(a0)
ffffffffc0203220:	0107f713          	andi	a4,a5,16
ffffffffc0203224:	72070f63          	beqz	a4,ffffffffc0203962 <pmm_init+0x994>
    assert(*ptep & PTE_W);
ffffffffc0203228:	8b91                	andi	a5,a5,4
ffffffffc020322a:	6e078c63          	beqz	a5,ffffffffc0203922 <pmm_init+0x954>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020322e:	00093503          	ld	a0,0(s2)
ffffffffc0203232:	611c                	ld	a5,0(a0)
ffffffffc0203234:	8bc1                	andi	a5,a5,16
ffffffffc0203236:	6c078663          	beqz	a5,ffffffffc0203902 <pmm_init+0x934>
    assert(page_ref(p2) == 1);
ffffffffc020323a:	000aa703          	lw	a4,0(s5)
ffffffffc020323e:	4785                	li	a5,1
ffffffffc0203240:	5cf71463          	bne	a4,a5,ffffffffc0203808 <pmm_init+0x83a>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203244:	4681                	li	a3,0
ffffffffc0203246:	6605                	lui	a2,0x1
ffffffffc0203248:	85d2                	mv	a1,s4
ffffffffc020324a:	c85ff0ef          	jal	ra,ffffffffc0202ece <page_insert>
ffffffffc020324e:	66051a63          	bnez	a0,ffffffffc02038c2 <pmm_init+0x8f4>
    assert(page_ref(p1) == 2);
ffffffffc0203252:	000a2703          	lw	a4,0(s4)
ffffffffc0203256:	4789                	li	a5,2
ffffffffc0203258:	64f71563          	bne	a4,a5,ffffffffc02038a2 <pmm_init+0x8d4>
    assert(page_ref(p2) == 0);
ffffffffc020325c:	000aa783          	lw	a5,0(s5)
ffffffffc0203260:	62079163          	bnez	a5,ffffffffc0203882 <pmm_init+0x8b4>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203264:	00093503          	ld	a0,0(s2)
ffffffffc0203268:	4601                	li	a2,0
ffffffffc020326a:	6585                	lui	a1,0x1
ffffffffc020326c:	979ff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
ffffffffc0203270:	5e050963          	beqz	a0,ffffffffc0203862 <pmm_init+0x894>
    assert(pte2page(*ptep) == p1);
ffffffffc0203274:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203276:	00177793          	andi	a5,a4,1
ffffffffc020327a:	50078563          	beqz	a5,ffffffffc0203784 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc020327e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203280:	00271793          	slli	a5,a4,0x2
ffffffffc0203284:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203286:	48d7f563          	bgeu	a5,a3,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020328a:	fff806b7          	lui	a3,0xfff80
ffffffffc020328e:	97b6                	add	a5,a5,a3
ffffffffc0203290:	000b3603          	ld	a2,0(s6)
ffffffffc0203294:	00279693          	slli	a3,a5,0x2
ffffffffc0203298:	97b6                	add	a5,a5,a3
ffffffffc020329a:	0792                	slli	a5,a5,0x4
ffffffffc020329c:	97b2                	add	a5,a5,a2
ffffffffc020329e:	72fa1263          	bne	s4,a5,ffffffffc02039c2 <pmm_init+0x9f4>
    assert((*ptep & PTE_U) == 0);
ffffffffc02032a2:	8b41                	andi	a4,a4,16
ffffffffc02032a4:	6e071f63          	bnez	a4,ffffffffc02039a2 <pmm_init+0x9d4>

    page_remove(boot_pgdir, 0x0);
ffffffffc02032a8:	00093503          	ld	a0,0(s2)
ffffffffc02032ac:	4581                	li	a1,0
ffffffffc02032ae:	b87ff0ef          	jal	ra,ffffffffc0202e34 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02032b2:	000a2703          	lw	a4,0(s4)
ffffffffc02032b6:	4785                	li	a5,1
ffffffffc02032b8:	6cf71563          	bne	a4,a5,ffffffffc0203982 <pmm_init+0x9b4>
    assert(page_ref(p2) == 0);
ffffffffc02032bc:	000aa783          	lw	a5,0(s5)
ffffffffc02032c0:	78079d63          	bnez	a5,ffffffffc0203a5a <pmm_init+0xa8c>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02032c4:	00093503          	ld	a0,0(s2)
ffffffffc02032c8:	6585                	lui	a1,0x1
ffffffffc02032ca:	b6bff0ef          	jal	ra,ffffffffc0202e34 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02032ce:	000a2783          	lw	a5,0(s4)
ffffffffc02032d2:	76079463          	bnez	a5,ffffffffc0203a3a <pmm_init+0xa6c>
    assert(page_ref(p2) == 0);
ffffffffc02032d6:	000aa783          	lw	a5,0(s5)
ffffffffc02032da:	74079063          	bnez	a5,ffffffffc0203a1a <pmm_init+0xa4c>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02032de:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02032e2:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02032e4:	000a3783          	ld	a5,0(s4)
ffffffffc02032e8:	078a                	slli	a5,a5,0x2
ffffffffc02032ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02032ec:	42c7f263          	bgeu	a5,a2,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02032f0:	fff80737          	lui	a4,0xfff80
ffffffffc02032f4:	973e                	add	a4,a4,a5
ffffffffc02032f6:	00271793          	slli	a5,a4,0x2
ffffffffc02032fa:	000b3503          	ld	a0,0(s6)
ffffffffc02032fe:	97ba                	add	a5,a5,a4
ffffffffc0203300:	0792                	slli	a5,a5,0x4
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0203302:	00f50733          	add	a4,a0,a5
ffffffffc0203306:	4314                	lw	a3,0(a4)
ffffffffc0203308:	4705                	li	a4,1
ffffffffc020330a:	6ee69863          	bne	a3,a4,ffffffffc02039fa <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020330e:	4047d693          	srai	a3,a5,0x4
ffffffffc0203312:	00003c97          	auipc	s9,0x3
ffffffffc0203316:	146cbc83          	ld	s9,326(s9) # ffffffffc0206458 <error_string+0x38>
ffffffffc020331a:	039686b3          	mul	a3,a3,s9
ffffffffc020331e:	000805b7          	lui	a1,0x80
ffffffffc0203322:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203324:	00c69713          	slli	a4,a3,0xc
ffffffffc0203328:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020332a:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020332c:	6ac77b63          	bgeu	a4,a2,ffffffffc02039e2 <pmm_init+0xa14>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0203330:	0009b703          	ld	a4,0(s3)
ffffffffc0203334:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0203336:	629c                	ld	a5,0(a3)
ffffffffc0203338:	078a                	slli	a5,a5,0x2
ffffffffc020333a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020333c:	3cc7fa63          	bgeu	a5,a2,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203340:	8f8d                	sub	a5,a5,a1
ffffffffc0203342:	00279713          	slli	a4,a5,0x2
ffffffffc0203346:	97ba                	add	a5,a5,a4
ffffffffc0203348:	0792                	slli	a5,a5,0x4
ffffffffc020334a:	953e                	add	a0,a0,a5
ffffffffc020334c:	100027f3          	csrr	a5,sstatus
ffffffffc0203350:	8b89                	andi	a5,a5,2
ffffffffc0203352:	2e079963          	bnez	a5,ffffffffc0203644 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203356:	000bb783          	ld	a5,0(s7)
ffffffffc020335a:	4585                	li	a1,1
ffffffffc020335c:	739c                	ld	a5,32(a5)
ffffffffc020335e:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203360:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203364:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203366:	078a                	slli	a5,a5,0x2
ffffffffc0203368:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020336a:	3ae7f363          	bgeu	a5,a4,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020336e:	fff80737          	lui	a4,0xfff80
ffffffffc0203372:	97ba                	add	a5,a5,a4
ffffffffc0203374:	000b3503          	ld	a0,0(s6)
ffffffffc0203378:	00279713          	slli	a4,a5,0x2
ffffffffc020337c:	97ba                	add	a5,a5,a4
ffffffffc020337e:	0792                	slli	a5,a5,0x4
ffffffffc0203380:	953e                	add	a0,a0,a5
ffffffffc0203382:	100027f3          	csrr	a5,sstatus
ffffffffc0203386:	8b89                	andi	a5,a5,2
ffffffffc0203388:	2a079263          	bnez	a5,ffffffffc020362c <pmm_init+0x65e>
ffffffffc020338c:	000bb783          	ld	a5,0(s7)
ffffffffc0203390:	4585                	li	a1,1
ffffffffc0203392:	739c                	ld	a5,32(a5)
ffffffffc0203394:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203396:	00093783          	ld	a5,0(s2)
ffffffffc020339a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc020339e:	100027f3          	csrr	a5,sstatus
ffffffffc02033a2:	8b89                	andi	a5,a5,2
ffffffffc02033a4:	26079a63          	bnez	a5,ffffffffc0203618 <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02033a8:	000bb783          	ld	a5,0(s7)
ffffffffc02033ac:	779c                	ld	a5,40(a5)
ffffffffc02033ae:	9782                	jalr	a5
ffffffffc02033b0:	8a2a                	mv	s4,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc02033b2:	73441463          	bne	s0,s4,ffffffffc0203ada <pmm_init+0xb0c>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02033b6:	00003517          	auipc	a0,0x3
ffffffffc02033ba:	bda50513          	addi	a0,a0,-1062 # ffffffffc0205f90 <default_pmm_manager+0x660>
ffffffffc02033be:	cfdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02033c2:	100027f3          	csrr	a5,sstatus
ffffffffc02033c6:	8b89                	andi	a5,a5,2
ffffffffc02033c8:	22079e63          	bnez	a5,ffffffffc0203604 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02033cc:	000bb783          	ld	a5,0(s7)
ffffffffc02033d0:	779c                	ld	a5,40(a5)
ffffffffc02033d2:	9782                	jalr	a5
ffffffffc02033d4:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02033d6:	6098                	ld	a4,0(s1)
ffffffffc02033d8:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02033dc:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02033de:	00c71793          	slli	a5,a4,0xc
ffffffffc02033e2:	6a05                	lui	s4,0x1
ffffffffc02033e4:	02f47c63          	bgeu	s0,a5,ffffffffc020341c <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02033e8:	00c45793          	srli	a5,s0,0xc
ffffffffc02033ec:	00093503          	ld	a0,0(s2)
ffffffffc02033f0:	30e7f363          	bgeu	a5,a4,ffffffffc02036f6 <pmm_init+0x728>
ffffffffc02033f4:	0009b583          	ld	a1,0(s3)
ffffffffc02033f8:	4601                	li	a2,0
ffffffffc02033fa:	95a2                	add	a1,a1,s0
ffffffffc02033fc:	fe8ff0ef          	jal	ra,ffffffffc0202be4 <get_pte>
ffffffffc0203400:	2c050b63          	beqz	a0,ffffffffc02036d6 <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0203404:	611c                	ld	a5,0(a0)
ffffffffc0203406:	078a                	slli	a5,a5,0x2
ffffffffc0203408:	0157f7b3          	and	a5,a5,s5
ffffffffc020340c:	2a879563          	bne	a5,s0,ffffffffc02036b6 <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0203410:	6098                	ld	a4,0(s1)
ffffffffc0203412:	9452                	add	s0,s0,s4
ffffffffc0203414:	00c71793          	slli	a5,a4,0xc
ffffffffc0203418:	fcf468e3          	bltu	s0,a5,ffffffffc02033e8 <pmm_init+0x41a>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc020341c:	00093783          	ld	a5,0(s2)
ffffffffc0203420:	639c                	ld	a5,0(a5)
ffffffffc0203422:	68079c63          	bnez	a5,ffffffffc0203aba <pmm_init+0xaec>

    struct Page *p;
    p = alloc_page();
ffffffffc0203426:	4505                	li	a0,1
ffffffffc0203428:	eb0ff0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc020342c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020342e:	00093503          	ld	a0,0(s2)
ffffffffc0203432:	4699                	li	a3,6
ffffffffc0203434:	10000613          	li	a2,256
ffffffffc0203438:	85d6                	mv	a1,s5
ffffffffc020343a:	a95ff0ef          	jal	ra,ffffffffc0202ece <page_insert>
ffffffffc020343e:	64051e63          	bnez	a0,ffffffffc0203a9a <pmm_init+0xacc>
    assert(page_ref(p) == 1);
ffffffffc0203442:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda90>
ffffffffc0203446:	4785                	li	a5,1
ffffffffc0203448:	62f71963          	bne	a4,a5,ffffffffc0203a7a <pmm_init+0xaac>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020344c:	00093503          	ld	a0,0(s2)
ffffffffc0203450:	6405                	lui	s0,0x1
ffffffffc0203452:	4699                	li	a3,6
ffffffffc0203454:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0203458:	85d6                	mv	a1,s5
ffffffffc020345a:	a75ff0ef          	jal	ra,ffffffffc0202ece <page_insert>
ffffffffc020345e:	48051263          	bnez	a0,ffffffffc02038e2 <pmm_init+0x914>
    assert(page_ref(p) == 2);
ffffffffc0203462:	000aa703          	lw	a4,0(s5)
ffffffffc0203466:	4789                	li	a5,2
ffffffffc0203468:	74f71563          	bne	a4,a5,ffffffffc0203bb2 <pmm_init+0xbe4>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020346c:	00003597          	auipc	a1,0x3
ffffffffc0203470:	c5c58593          	addi	a1,a1,-932 # ffffffffc02060c8 <default_pmm_manager+0x798>
ffffffffc0203474:	10000513          	li	a0,256
ffffffffc0203478:	35d000ef          	jal	ra,ffffffffc0203fd4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020347c:	10040593          	addi	a1,s0,256
ffffffffc0203480:	10000513          	li	a0,256
ffffffffc0203484:	363000ef          	jal	ra,ffffffffc0203fe6 <strcmp>
ffffffffc0203488:	70051563          	bnez	a0,ffffffffc0203b92 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020348c:	000b3683          	ld	a3,0(s6)
ffffffffc0203490:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203494:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203496:	40da86b3          	sub	a3,s5,a3
ffffffffc020349a:	8691                	srai	a3,a3,0x4
ffffffffc020349c:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034a0:	609c                	ld	a5,0(s1)
ffffffffc02034a2:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034a4:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034a6:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc02034aa:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034ac:	52f77b63          	bgeu	a4,a5,ffffffffc02039e2 <pmm_init+0xa14>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02034b0:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc02034b4:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02034b8:	96be                	add	a3,a3,a5
ffffffffc02034ba:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb90>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02034be:	2e1000ef          	jal	ra,ffffffffc0203f9e <strlen>
ffffffffc02034c2:	6a051863          	bnez	a0,ffffffffc0203b72 <pmm_init+0xba4>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02034c6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02034ca:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02034cc:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02034d0:	078a                	slli	a5,a5,0x2
ffffffffc02034d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02034d4:	22e7fe63          	bgeu	a5,a4,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02034d8:	41a787b3          	sub	a5,a5,s10
ffffffffc02034dc:	00279693          	slli	a3,a5,0x2
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02034e0:	96be                	add	a3,a3,a5
ffffffffc02034e2:	03968cb3          	mul	s9,a3,s9
ffffffffc02034e6:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034ea:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02034ec:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02034ee:	4ee47a63          	bgeu	s0,a4,ffffffffc02039e2 <pmm_init+0xa14>
ffffffffc02034f2:	0009b403          	ld	s0,0(s3)
ffffffffc02034f6:	9436                	add	s0,s0,a3
ffffffffc02034f8:	100027f3          	csrr	a5,sstatus
ffffffffc02034fc:	8b89                	andi	a5,a5,2
ffffffffc02034fe:	1a079163          	bnez	a5,ffffffffc02036a0 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203502:	000bb783          	ld	a5,0(s7)
ffffffffc0203506:	4585                	li	a1,1
ffffffffc0203508:	8556                	mv	a0,s5
ffffffffc020350a:	739c                	ld	a5,32(a5)
ffffffffc020350c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc020350e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203510:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203512:	078a                	slli	a5,a5,0x2
ffffffffc0203514:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203516:	1ee7fd63          	bgeu	a5,a4,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020351a:	fff80737          	lui	a4,0xfff80
ffffffffc020351e:	97ba                	add	a5,a5,a4
ffffffffc0203520:	000b3503          	ld	a0,0(s6)
ffffffffc0203524:	00279713          	slli	a4,a5,0x2
ffffffffc0203528:	97ba                	add	a5,a5,a4
ffffffffc020352a:	0792                	slli	a5,a5,0x4
ffffffffc020352c:	953e                	add	a0,a0,a5
ffffffffc020352e:	100027f3          	csrr	a5,sstatus
ffffffffc0203532:	8b89                	andi	a5,a5,2
ffffffffc0203534:	14079a63          	bnez	a5,ffffffffc0203688 <pmm_init+0x6ba>
ffffffffc0203538:	000bb783          	ld	a5,0(s7)
ffffffffc020353c:	4585                	li	a1,1
ffffffffc020353e:	739c                	ld	a5,32(a5)
ffffffffc0203540:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203542:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0203546:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203548:	078a                	slli	a5,a5,0x2
ffffffffc020354a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020354c:	1ce7f263          	bgeu	a5,a4,ffffffffc0203710 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0203550:	fff80737          	lui	a4,0xfff80
ffffffffc0203554:	97ba                	add	a5,a5,a4
ffffffffc0203556:	000b3503          	ld	a0,0(s6)
ffffffffc020355a:	00279713          	slli	a4,a5,0x2
ffffffffc020355e:	97ba                	add	a5,a5,a4
ffffffffc0203560:	0792                	slli	a5,a5,0x4
ffffffffc0203562:	953e                	add	a0,a0,a5
ffffffffc0203564:	100027f3          	csrr	a5,sstatus
ffffffffc0203568:	8b89                	andi	a5,a5,2
ffffffffc020356a:	10079363          	bnez	a5,ffffffffc0203670 <pmm_init+0x6a2>
ffffffffc020356e:	000bb783          	ld	a5,0(s7)
ffffffffc0203572:	4585                	li	a1,1
ffffffffc0203574:	739c                	ld	a5,32(a5)
ffffffffc0203576:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0203578:	00093783          	ld	a5,0(s2)
ffffffffc020357c:	0007b023          	sd	zero,0(a5)
ffffffffc0203580:	100027f3          	csrr	a5,sstatus
ffffffffc0203584:	8b89                	andi	a5,a5,2
ffffffffc0203586:	0c079b63          	bnez	a5,ffffffffc020365c <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020358a:	000bb783          	ld	a5,0(s7)
ffffffffc020358e:	779c                	ld	a5,40(a5)
ffffffffc0203590:	9782                	jalr	a5
ffffffffc0203592:	842a                	mv	s0,a0

    assert(nr_free_store==nr_free_pages());
ffffffffc0203594:	3a8c1763          	bne	s8,s0,ffffffffc0203942 <pmm_init+0x974>
}
ffffffffc0203598:	7406                	ld	s0,96(sp)
ffffffffc020359a:	70a6                	ld	ra,104(sp)
ffffffffc020359c:	64e6                	ld	s1,88(sp)
ffffffffc020359e:	6946                	ld	s2,80(sp)
ffffffffc02035a0:	69a6                	ld	s3,72(sp)
ffffffffc02035a2:	6a06                	ld	s4,64(sp)
ffffffffc02035a4:	7ae2                	ld	s5,56(sp)
ffffffffc02035a6:	7b42                	ld	s6,48(sp)
ffffffffc02035a8:	7ba2                	ld	s7,40(sp)
ffffffffc02035aa:	7c02                	ld	s8,32(sp)
ffffffffc02035ac:	6ce2                	ld	s9,24(sp)
ffffffffc02035ae:	6d42                	ld	s10,16(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02035b0:	00003517          	auipc	a0,0x3
ffffffffc02035b4:	b9050513          	addi	a0,a0,-1136 # ffffffffc0206140 <default_pmm_manager+0x810>
}
ffffffffc02035b8:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02035ba:	b01fc06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02035be:	6705                	lui	a4,0x1
ffffffffc02035c0:	177d                	addi	a4,a4,-1
ffffffffc02035c2:	96ba                	add	a3,a3,a4
ffffffffc02035c4:	777d                	lui	a4,0xfffff
ffffffffc02035c6:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02035c8:	00c75693          	srli	a3,a4,0xc
ffffffffc02035cc:	14f6f263          	bgeu	a3,a5,ffffffffc0203710 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02035d0:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02035d4:	95b6                	add	a1,a1,a3
ffffffffc02035d6:	00259793          	slli	a5,a1,0x2
ffffffffc02035da:	97ae                	add	a5,a5,a1
ffffffffc02035dc:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02035e0:	40e60733          	sub	a4,a2,a4
ffffffffc02035e4:	0792                	slli	a5,a5,0x4
    pmm_manager->init_memmap(base, n);
ffffffffc02035e6:	00c75593          	srli	a1,a4,0xc
ffffffffc02035ea:	953e                	add	a0,a0,a5
ffffffffc02035ec:	9682                	jalr	a3
}
ffffffffc02035ee:	bcc5                	j	ffffffffc02030de <pmm_init+0x110>
        intr_disable();
ffffffffc02035f0:	efffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02035f4:	000bb783          	ld	a5,0(s7)
ffffffffc02035f8:	779c                	ld	a5,40(a5)
ffffffffc02035fa:	9782                	jalr	a5
ffffffffc02035fc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02035fe:	eebfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203602:	b63d                	j	ffffffffc0203130 <pmm_init+0x162>
        intr_disable();
ffffffffc0203604:	eebfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203608:	000bb783          	ld	a5,0(s7)
ffffffffc020360c:	779c                	ld	a5,40(a5)
ffffffffc020360e:	9782                	jalr	a5
ffffffffc0203610:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0203612:	ed7fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203616:	b3c1                	j	ffffffffc02033d6 <pmm_init+0x408>
        intr_disable();
ffffffffc0203618:	ed7fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020361c:	000bb783          	ld	a5,0(s7)
ffffffffc0203620:	779c                	ld	a5,40(a5)
ffffffffc0203622:	9782                	jalr	a5
ffffffffc0203624:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0203626:	ec3fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020362a:	b361                	j	ffffffffc02033b2 <pmm_init+0x3e4>
ffffffffc020362c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020362e:	ec1fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203632:	000bb783          	ld	a5,0(s7)
ffffffffc0203636:	6522                	ld	a0,8(sp)
ffffffffc0203638:	4585                	li	a1,1
ffffffffc020363a:	739c                	ld	a5,32(a5)
ffffffffc020363c:	9782                	jalr	a5
        intr_enable();
ffffffffc020363e:	eabfc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203642:	bb91                	j	ffffffffc0203396 <pmm_init+0x3c8>
ffffffffc0203644:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203646:	ea9fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020364a:	000bb783          	ld	a5,0(s7)
ffffffffc020364e:	6522                	ld	a0,8(sp)
ffffffffc0203650:	4585                	li	a1,1
ffffffffc0203652:	739c                	ld	a5,32(a5)
ffffffffc0203654:	9782                	jalr	a5
        intr_enable();
ffffffffc0203656:	e93fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020365a:	b319                	j	ffffffffc0203360 <pmm_init+0x392>
        intr_disable();
ffffffffc020365c:	e93fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0203660:	000bb783          	ld	a5,0(s7)
ffffffffc0203664:	779c                	ld	a5,40(a5)
ffffffffc0203666:	9782                	jalr	a5
ffffffffc0203668:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020366a:	e7ffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020366e:	b71d                	j	ffffffffc0203594 <pmm_init+0x5c6>
ffffffffc0203670:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203672:	e7dfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203676:	000bb783          	ld	a5,0(s7)
ffffffffc020367a:	6522                	ld	a0,8(sp)
ffffffffc020367c:	4585                	li	a1,1
ffffffffc020367e:	739c                	ld	a5,32(a5)
ffffffffc0203680:	9782                	jalr	a5
        intr_enable();
ffffffffc0203682:	e67fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203686:	bdcd                	j	ffffffffc0203578 <pmm_init+0x5aa>
ffffffffc0203688:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020368a:	e65fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020368e:	000bb783          	ld	a5,0(s7)
ffffffffc0203692:	6522                	ld	a0,8(sp)
ffffffffc0203694:	4585                	li	a1,1
ffffffffc0203696:	739c                	ld	a5,32(a5)
ffffffffc0203698:	9782                	jalr	a5
        intr_enable();
ffffffffc020369a:	e4ffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020369e:	b555                	j	ffffffffc0203542 <pmm_init+0x574>
        intr_disable();
ffffffffc02036a0:	e4ffc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02036a4:	000bb783          	ld	a5,0(s7)
ffffffffc02036a8:	4585                	li	a1,1
ffffffffc02036aa:	8556                	mv	a0,s5
ffffffffc02036ac:	739c                	ld	a5,32(a5)
ffffffffc02036ae:	9782                	jalr	a5
        intr_enable();
ffffffffc02036b0:	e39fc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02036b4:	bda9                	j	ffffffffc020350e <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02036b6:	00003697          	auipc	a3,0x3
ffffffffc02036ba:	93a68693          	addi	a3,a3,-1734 # ffffffffc0205ff0 <default_pmm_manager+0x6c0>
ffffffffc02036be:	00001617          	auipc	a2,0x1
ffffffffc02036c2:	7ca60613          	addi	a2,a2,1994 # ffffffffc0204e88 <commands+0x728>
ffffffffc02036c6:	1ce00593          	li	a1,462
ffffffffc02036ca:	00002517          	auipc	a0,0x2
ffffffffc02036ce:	51e50513          	addi	a0,a0,1310 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02036d2:	a31fc0ef          	jal	ra,ffffffffc0200102 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02036d6:	00003697          	auipc	a3,0x3
ffffffffc02036da:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205fb0 <default_pmm_manager+0x680>
ffffffffc02036de:	00001617          	auipc	a2,0x1
ffffffffc02036e2:	7aa60613          	addi	a2,a2,1962 # ffffffffc0204e88 <commands+0x728>
ffffffffc02036e6:	1cd00593          	li	a1,461
ffffffffc02036ea:	00002517          	auipc	a0,0x2
ffffffffc02036ee:	4fe50513          	addi	a0,a0,1278 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02036f2:	a11fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc02036f6:	86a2                	mv	a3,s0
ffffffffc02036f8:	00002617          	auipc	a2,0x2
ffffffffc02036fc:	4c860613          	addi	a2,a2,1224 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0203700:	1cd00593          	li	a1,461
ffffffffc0203704:	00002517          	auipc	a0,0x2
ffffffffc0203708:	4e450513          	addi	a0,a0,1252 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020370c:	9f7fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203710:	b90ff0ef          	jal	ra,ffffffffc0202aa0 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203714:	00002617          	auipc	a2,0x2
ffffffffc0203718:	56c60613          	addi	a2,a2,1388 # ffffffffc0205c80 <default_pmm_manager+0x350>
ffffffffc020371c:	07700593          	li	a1,119
ffffffffc0203720:	00002517          	auipc	a0,0x2
ffffffffc0203724:	4c850513          	addi	a0,a0,1224 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203728:	9dbfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020372c:	00002617          	auipc	a2,0x2
ffffffffc0203730:	55460613          	addi	a2,a2,1364 # ffffffffc0205c80 <default_pmm_manager+0x350>
ffffffffc0203734:	0bd00593          	li	a1,189
ffffffffc0203738:	00002517          	auipc	a0,0x2
ffffffffc020373c:	4b050513          	addi	a0,a0,1200 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203740:	9c3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203744:	00002697          	auipc	a3,0x2
ffffffffc0203748:	5a468693          	addi	a3,a3,1444 # ffffffffc0205ce8 <default_pmm_manager+0x3b8>
ffffffffc020374c:	00001617          	auipc	a2,0x1
ffffffffc0203750:	73c60613          	addi	a2,a2,1852 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203754:	19300593          	li	a1,403
ffffffffc0203758:	00002517          	auipc	a0,0x2
ffffffffc020375c:	49050513          	addi	a0,a0,1168 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203760:	9a3fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203764:	00002697          	auipc	a3,0x2
ffffffffc0203768:	56468693          	addi	a3,a3,1380 # ffffffffc0205cc8 <default_pmm_manager+0x398>
ffffffffc020376c:	00001617          	auipc	a2,0x1
ffffffffc0203770:	71c60613          	addi	a2,a2,1820 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203774:	19200593          	li	a1,402
ffffffffc0203778:	00002517          	auipc	a0,0x2
ffffffffc020377c:	47050513          	addi	a0,a0,1136 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203780:	983fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203784:	b38ff0ef          	jal	ra,ffffffffc0202abc <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0203788:	00002697          	auipc	a3,0x2
ffffffffc020378c:	5f068693          	addi	a3,a3,1520 # ffffffffc0205d78 <default_pmm_manager+0x448>
ffffffffc0203790:	00001617          	auipc	a2,0x1
ffffffffc0203794:	6f860613          	addi	a2,a2,1784 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203798:	19a00593          	li	a1,410
ffffffffc020379c:	00002517          	auipc	a0,0x2
ffffffffc02037a0:	44c50513          	addi	a0,a0,1100 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02037a4:	95ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02037a8:	00002697          	auipc	a3,0x2
ffffffffc02037ac:	5a068693          	addi	a3,a3,1440 # ffffffffc0205d48 <default_pmm_manager+0x418>
ffffffffc02037b0:	00001617          	auipc	a2,0x1
ffffffffc02037b4:	6d860613          	addi	a2,a2,1752 # ffffffffc0204e88 <commands+0x728>
ffffffffc02037b8:	19800593          	li	a1,408
ffffffffc02037bc:	00002517          	auipc	a0,0x2
ffffffffc02037c0:	42c50513          	addi	a0,a0,1068 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02037c4:	93ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02037c8:	00002697          	auipc	a3,0x2
ffffffffc02037cc:	55868693          	addi	a3,a3,1368 # ffffffffc0205d20 <default_pmm_manager+0x3f0>
ffffffffc02037d0:	00001617          	auipc	a2,0x1
ffffffffc02037d4:	6b860613          	addi	a2,a2,1720 # ffffffffc0204e88 <commands+0x728>
ffffffffc02037d8:	19400593          	li	a1,404
ffffffffc02037dc:	00002517          	auipc	a0,0x2
ffffffffc02037e0:	40c50513          	addi	a0,a0,1036 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02037e4:	91ffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02037e8:	00002697          	auipc	a3,0x2
ffffffffc02037ec:	61868693          	addi	a3,a3,1560 # ffffffffc0205e00 <default_pmm_manager+0x4d0>
ffffffffc02037f0:	00001617          	auipc	a2,0x1
ffffffffc02037f4:	69860613          	addi	a2,a2,1688 # ffffffffc0204e88 <commands+0x728>
ffffffffc02037f8:	1a300593          	li	a1,419
ffffffffc02037fc:	00002517          	auipc	a0,0x2
ffffffffc0203800:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203804:	8fffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203808:	00002697          	auipc	a3,0x2
ffffffffc020380c:	69868693          	addi	a3,a3,1688 # ffffffffc0205ea0 <default_pmm_manager+0x570>
ffffffffc0203810:	00001617          	auipc	a2,0x1
ffffffffc0203814:	67860613          	addi	a2,a2,1656 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203818:	1a800593          	li	a1,424
ffffffffc020381c:	00002517          	auipc	a0,0x2
ffffffffc0203820:	3cc50513          	addi	a0,a0,972 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203824:	8dffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0203828:	00002697          	auipc	a3,0x2
ffffffffc020382c:	5b068693          	addi	a3,a3,1456 # ffffffffc0205dd8 <default_pmm_manager+0x4a8>
ffffffffc0203830:	00001617          	auipc	a2,0x1
ffffffffc0203834:	65860613          	addi	a2,a2,1624 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203838:	1a000593          	li	a1,416
ffffffffc020383c:	00002517          	auipc	a0,0x2
ffffffffc0203840:	3ac50513          	addi	a0,a0,940 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203844:	8bffc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203848:	86d6                	mv	a3,s5
ffffffffc020384a:	00002617          	auipc	a2,0x2
ffffffffc020384e:	37660613          	addi	a2,a2,886 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0203852:	19f00593          	li	a1,415
ffffffffc0203856:	00002517          	auipc	a0,0x2
ffffffffc020385a:	39250513          	addi	a0,a0,914 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020385e:	8a5fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203862:	00002697          	auipc	a3,0x2
ffffffffc0203866:	5d668693          	addi	a3,a3,1494 # ffffffffc0205e38 <default_pmm_manager+0x508>
ffffffffc020386a:	00001617          	auipc	a2,0x1
ffffffffc020386e:	61e60613          	addi	a2,a2,1566 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203872:	1ad00593          	li	a1,429
ffffffffc0203876:	00002517          	auipc	a0,0x2
ffffffffc020387a:	37250513          	addi	a0,a0,882 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020387e:	885fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203882:	00002697          	auipc	a3,0x2
ffffffffc0203886:	67e68693          	addi	a3,a3,1662 # ffffffffc0205f00 <default_pmm_manager+0x5d0>
ffffffffc020388a:	00001617          	auipc	a2,0x1
ffffffffc020388e:	5fe60613          	addi	a2,a2,1534 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203892:	1ac00593          	li	a1,428
ffffffffc0203896:	00002517          	auipc	a0,0x2
ffffffffc020389a:	35250513          	addi	a0,a0,850 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020389e:	865fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02038a2:	00002697          	auipc	a3,0x2
ffffffffc02038a6:	64668693          	addi	a3,a3,1606 # ffffffffc0205ee8 <default_pmm_manager+0x5b8>
ffffffffc02038aa:	00001617          	auipc	a2,0x1
ffffffffc02038ae:	5de60613          	addi	a2,a2,1502 # ffffffffc0204e88 <commands+0x728>
ffffffffc02038b2:	1ab00593          	li	a1,427
ffffffffc02038b6:	00002517          	auipc	a0,0x2
ffffffffc02038ba:	33250513          	addi	a0,a0,818 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02038be:	845fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02038c2:	00002697          	auipc	a3,0x2
ffffffffc02038c6:	5f668693          	addi	a3,a3,1526 # ffffffffc0205eb8 <default_pmm_manager+0x588>
ffffffffc02038ca:	00001617          	auipc	a2,0x1
ffffffffc02038ce:	5be60613          	addi	a2,a2,1470 # ffffffffc0204e88 <commands+0x728>
ffffffffc02038d2:	1aa00593          	li	a1,426
ffffffffc02038d6:	00002517          	auipc	a0,0x2
ffffffffc02038da:	31250513          	addi	a0,a0,786 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02038de:	825fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02038e2:	00002697          	auipc	a3,0x2
ffffffffc02038e6:	78e68693          	addi	a3,a3,1934 # ffffffffc0206070 <default_pmm_manager+0x740>
ffffffffc02038ea:	00001617          	auipc	a2,0x1
ffffffffc02038ee:	59e60613          	addi	a2,a2,1438 # ffffffffc0204e88 <commands+0x728>
ffffffffc02038f2:	1d800593          	li	a1,472
ffffffffc02038f6:	00002517          	auipc	a0,0x2
ffffffffc02038fa:	2f250513          	addi	a0,a0,754 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02038fe:	805fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203902:	00002697          	auipc	a3,0x2
ffffffffc0203906:	58668693          	addi	a3,a3,1414 # ffffffffc0205e88 <default_pmm_manager+0x558>
ffffffffc020390a:	00001617          	auipc	a2,0x1
ffffffffc020390e:	57e60613          	addi	a2,a2,1406 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203912:	1a700593          	li	a1,423
ffffffffc0203916:	00002517          	auipc	a0,0x2
ffffffffc020391a:	2d250513          	addi	a0,a0,722 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020391e:	fe4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203922:	00002697          	auipc	a3,0x2
ffffffffc0203926:	55668693          	addi	a3,a3,1366 # ffffffffc0205e78 <default_pmm_manager+0x548>
ffffffffc020392a:	00001617          	auipc	a2,0x1
ffffffffc020392e:	55e60613          	addi	a2,a2,1374 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203932:	1a600593          	li	a1,422
ffffffffc0203936:	00002517          	auipc	a0,0x2
ffffffffc020393a:	2b250513          	addi	a0,a0,690 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020393e:	fc4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203942:	00002697          	auipc	a3,0x2
ffffffffc0203946:	62e68693          	addi	a3,a3,1582 # ffffffffc0205f70 <default_pmm_manager+0x640>
ffffffffc020394a:	00001617          	auipc	a2,0x1
ffffffffc020394e:	53e60613          	addi	a2,a2,1342 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203952:	1e800593          	li	a1,488
ffffffffc0203956:	00002517          	auipc	a0,0x2
ffffffffc020395a:	29250513          	addi	a0,a0,658 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020395e:	fa4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203962:	00002697          	auipc	a3,0x2
ffffffffc0203966:	50668693          	addi	a3,a3,1286 # ffffffffc0205e68 <default_pmm_manager+0x538>
ffffffffc020396a:	00001617          	auipc	a2,0x1
ffffffffc020396e:	51e60613          	addi	a2,a2,1310 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203972:	1a500593          	li	a1,421
ffffffffc0203976:	00002517          	auipc	a0,0x2
ffffffffc020397a:	27250513          	addi	a0,a0,626 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020397e:	f84fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203982:	00002697          	auipc	a3,0x2
ffffffffc0203986:	43e68693          	addi	a3,a3,1086 # ffffffffc0205dc0 <default_pmm_manager+0x490>
ffffffffc020398a:	00001617          	auipc	a2,0x1
ffffffffc020398e:	4fe60613          	addi	a2,a2,1278 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203992:	1b200593          	li	a1,434
ffffffffc0203996:	00002517          	auipc	a0,0x2
ffffffffc020399a:	25250513          	addi	a0,a0,594 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc020399e:	f64fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02039a2:	00002697          	auipc	a3,0x2
ffffffffc02039a6:	57668693          	addi	a3,a3,1398 # ffffffffc0205f18 <default_pmm_manager+0x5e8>
ffffffffc02039aa:	00001617          	auipc	a2,0x1
ffffffffc02039ae:	4de60613          	addi	a2,a2,1246 # ffffffffc0204e88 <commands+0x728>
ffffffffc02039b2:	1af00593          	li	a1,431
ffffffffc02039b6:	00002517          	auipc	a0,0x2
ffffffffc02039ba:	23250513          	addi	a0,a0,562 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02039be:	f44fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02039c2:	00002697          	auipc	a3,0x2
ffffffffc02039c6:	3e668693          	addi	a3,a3,998 # ffffffffc0205da8 <default_pmm_manager+0x478>
ffffffffc02039ca:	00001617          	auipc	a2,0x1
ffffffffc02039ce:	4be60613          	addi	a2,a2,1214 # ffffffffc0204e88 <commands+0x728>
ffffffffc02039d2:	1ae00593          	li	a1,430
ffffffffc02039d6:	00002517          	auipc	a0,0x2
ffffffffc02039da:	21250513          	addi	a0,a0,530 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc02039de:	f24fc0ef          	jal	ra,ffffffffc0200102 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02039e2:	00002617          	auipc	a2,0x2
ffffffffc02039e6:	1de60613          	addi	a2,a2,478 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc02039ea:	06a00593          	li	a1,106
ffffffffc02039ee:	00001517          	auipc	a0,0x1
ffffffffc02039f2:	70a50513          	addi	a0,a0,1802 # ffffffffc02050f8 <commands+0x998>
ffffffffc02039f6:	f0cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02039fa:	00002697          	auipc	a3,0x2
ffffffffc02039fe:	54e68693          	addi	a3,a3,1358 # ffffffffc0205f48 <default_pmm_manager+0x618>
ffffffffc0203a02:	00001617          	auipc	a2,0x1
ffffffffc0203a06:	48660613          	addi	a2,a2,1158 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203a0a:	1b900593          	li	a1,441
ffffffffc0203a0e:	00002517          	auipc	a0,0x2
ffffffffc0203a12:	1da50513          	addi	a0,a0,474 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203a16:	eecfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203a1a:	00002697          	auipc	a3,0x2
ffffffffc0203a1e:	4e668693          	addi	a3,a3,1254 # ffffffffc0205f00 <default_pmm_manager+0x5d0>
ffffffffc0203a22:	00001617          	auipc	a2,0x1
ffffffffc0203a26:	46660613          	addi	a2,a2,1126 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203a2a:	1b700593          	li	a1,439
ffffffffc0203a2e:	00002517          	auipc	a0,0x2
ffffffffc0203a32:	1ba50513          	addi	a0,a0,442 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203a36:	eccfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203a3a:	00002697          	auipc	a3,0x2
ffffffffc0203a3e:	4f668693          	addi	a3,a3,1270 # ffffffffc0205f30 <default_pmm_manager+0x600>
ffffffffc0203a42:	00001617          	auipc	a2,0x1
ffffffffc0203a46:	44660613          	addi	a2,a2,1094 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203a4a:	1b600593          	li	a1,438
ffffffffc0203a4e:	00002517          	auipc	a0,0x2
ffffffffc0203a52:	19a50513          	addi	a0,a0,410 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203a56:	eacfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203a5a:	00002697          	auipc	a3,0x2
ffffffffc0203a5e:	4a668693          	addi	a3,a3,1190 # ffffffffc0205f00 <default_pmm_manager+0x5d0>
ffffffffc0203a62:	00001617          	auipc	a2,0x1
ffffffffc0203a66:	42660613          	addi	a2,a2,1062 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203a6a:	1b300593          	li	a1,435
ffffffffc0203a6e:	00002517          	auipc	a0,0x2
ffffffffc0203a72:	17a50513          	addi	a0,a0,378 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203a76:	e8cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203a7a:	00002697          	auipc	a3,0x2
ffffffffc0203a7e:	5de68693          	addi	a3,a3,1502 # ffffffffc0206058 <default_pmm_manager+0x728>
ffffffffc0203a82:	00001617          	auipc	a2,0x1
ffffffffc0203a86:	40660613          	addi	a2,a2,1030 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203a8a:	1d700593          	li	a1,471
ffffffffc0203a8e:	00002517          	auipc	a0,0x2
ffffffffc0203a92:	15a50513          	addi	a0,a0,346 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203a96:	e6cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203a9a:	00002697          	auipc	a3,0x2
ffffffffc0203a9e:	58668693          	addi	a3,a3,1414 # ffffffffc0206020 <default_pmm_manager+0x6f0>
ffffffffc0203aa2:	00001617          	auipc	a2,0x1
ffffffffc0203aa6:	3e660613          	addi	a2,a2,998 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203aaa:	1d600593          	li	a1,470
ffffffffc0203aae:	00002517          	auipc	a0,0x2
ffffffffc0203ab2:	13a50513          	addi	a0,a0,314 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203ab6:	e4cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203aba:	00002697          	auipc	a3,0x2
ffffffffc0203abe:	54e68693          	addi	a3,a3,1358 # ffffffffc0206008 <default_pmm_manager+0x6d8>
ffffffffc0203ac2:	00001617          	auipc	a2,0x1
ffffffffc0203ac6:	3c660613          	addi	a2,a2,966 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203aca:	1d200593          	li	a1,466
ffffffffc0203ace:	00002517          	auipc	a0,0x2
ffffffffc0203ad2:	11a50513          	addi	a0,a0,282 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203ad6:	e2cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203ada:	00002697          	auipc	a3,0x2
ffffffffc0203ade:	49668693          	addi	a3,a3,1174 # ffffffffc0205f70 <default_pmm_manager+0x640>
ffffffffc0203ae2:	00001617          	auipc	a2,0x1
ffffffffc0203ae6:	3a660613          	addi	a2,a2,934 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203aea:	1c000593          	li	a1,448
ffffffffc0203aee:	00002517          	auipc	a0,0x2
ffffffffc0203af2:	0fa50513          	addi	a0,a0,250 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203af6:	e0cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203afa:	00002697          	auipc	a3,0x2
ffffffffc0203afe:	2ae68693          	addi	a3,a3,686 # ffffffffc0205da8 <default_pmm_manager+0x478>
ffffffffc0203b02:	00001617          	auipc	a2,0x1
ffffffffc0203b06:	38660613          	addi	a2,a2,902 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203b0a:	19b00593          	li	a1,411
ffffffffc0203b0e:	00002517          	auipc	a0,0x2
ffffffffc0203b12:	0da50513          	addi	a0,a0,218 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203b16:	decfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203b1a:	00002617          	auipc	a2,0x2
ffffffffc0203b1e:	0a660613          	addi	a2,a2,166 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0203b22:	19e00593          	li	a1,414
ffffffffc0203b26:	00002517          	auipc	a0,0x2
ffffffffc0203b2a:	0c250513          	addi	a0,a0,194 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203b2e:	dd4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203b32:	00002697          	auipc	a3,0x2
ffffffffc0203b36:	28e68693          	addi	a3,a3,654 # ffffffffc0205dc0 <default_pmm_manager+0x490>
ffffffffc0203b3a:	00001617          	auipc	a2,0x1
ffffffffc0203b3e:	34e60613          	addi	a2,a2,846 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203b42:	19c00593          	li	a1,412
ffffffffc0203b46:	00002517          	auipc	a0,0x2
ffffffffc0203b4a:	0a250513          	addi	a0,a0,162 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203b4e:	db4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203b52:	00002697          	auipc	a3,0x2
ffffffffc0203b56:	2e668693          	addi	a3,a3,742 # ffffffffc0205e38 <default_pmm_manager+0x508>
ffffffffc0203b5a:	00001617          	auipc	a2,0x1
ffffffffc0203b5e:	32e60613          	addi	a2,a2,814 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203b62:	1a400593          	li	a1,420
ffffffffc0203b66:	00002517          	auipc	a0,0x2
ffffffffc0203b6a:	08250513          	addi	a0,a0,130 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203b6e:	d94fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203b72:	00002697          	auipc	a3,0x2
ffffffffc0203b76:	5a668693          	addi	a3,a3,1446 # ffffffffc0206118 <default_pmm_manager+0x7e8>
ffffffffc0203b7a:	00001617          	auipc	a2,0x1
ffffffffc0203b7e:	30e60613          	addi	a2,a2,782 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203b82:	1e000593          	li	a1,480
ffffffffc0203b86:	00002517          	auipc	a0,0x2
ffffffffc0203b8a:	06250513          	addi	a0,a0,98 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203b8e:	d74fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203b92:	00002697          	auipc	a3,0x2
ffffffffc0203b96:	54e68693          	addi	a3,a3,1358 # ffffffffc02060e0 <default_pmm_manager+0x7b0>
ffffffffc0203b9a:	00001617          	auipc	a2,0x1
ffffffffc0203b9e:	2ee60613          	addi	a2,a2,750 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203ba2:	1dd00593          	li	a1,477
ffffffffc0203ba6:	00002517          	auipc	a0,0x2
ffffffffc0203baa:	04250513          	addi	a0,a0,66 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203bae:	d54fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0203bb2:	00002697          	auipc	a3,0x2
ffffffffc0203bb6:	4fe68693          	addi	a3,a3,1278 # ffffffffc02060b0 <default_pmm_manager+0x780>
ffffffffc0203bba:	00001617          	auipc	a2,0x1
ffffffffc0203bbe:	2ce60613          	addi	a2,a2,718 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203bc2:	1d900593          	li	a1,473
ffffffffc0203bc6:	00002517          	auipc	a0,0x2
ffffffffc0203bca:	02250513          	addi	a0,a0,34 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203bce:	d34fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203bd2 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0203bd2:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0203bd6:	8082                	ret

ffffffffc0203bd8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203bd8:	7179                	addi	sp,sp,-48
ffffffffc0203bda:	e84a                	sd	s2,16(sp)
ffffffffc0203bdc:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203bde:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203be0:	f022                	sd	s0,32(sp)
ffffffffc0203be2:	ec26                	sd	s1,24(sp)
ffffffffc0203be4:	e44e                	sd	s3,8(sp)
ffffffffc0203be6:	f406                	sd	ra,40(sp)
ffffffffc0203be8:	84ae                	mv	s1,a1
ffffffffc0203bea:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203bec:	eedfe0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
ffffffffc0203bf0:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203bf2:	cd09                	beqz	a0,ffffffffc0203c0c <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203bf4:	85aa                	mv	a1,a0
ffffffffc0203bf6:	86ce                	mv	a3,s3
ffffffffc0203bf8:	8626                	mv	a2,s1
ffffffffc0203bfa:	854a                	mv	a0,s2
ffffffffc0203bfc:	ad2ff0ef          	jal	ra,ffffffffc0202ece <page_insert>
ffffffffc0203c00:	ed21                	bnez	a0,ffffffffc0203c58 <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc0203c02:	0000e797          	auipc	a5,0xe
ffffffffc0203c06:	92e7a783          	lw	a5,-1746(a5) # ffffffffc0211530 <swap_init_ok>
ffffffffc0203c0a:	eb89                	bnez	a5,ffffffffc0203c1c <pgdir_alloc_page+0x44>
}
ffffffffc0203c0c:	70a2                	ld	ra,40(sp)
ffffffffc0203c0e:	8522                	mv	a0,s0
ffffffffc0203c10:	7402                	ld	s0,32(sp)
ffffffffc0203c12:	64e2                	ld	s1,24(sp)
ffffffffc0203c14:	6942                	ld	s2,16(sp)
ffffffffc0203c16:	69a2                	ld	s3,8(sp)
ffffffffc0203c18:	6145                	addi	sp,sp,48
ffffffffc0203c1a:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203c1c:	4681                	li	a3,0
ffffffffc0203c1e:	8622                	mv	a2,s0
ffffffffc0203c20:	85a6                	mv	a1,s1
ffffffffc0203c22:	0000e517          	auipc	a0,0xe
ffffffffc0203c26:	8ee53503          	ld	a0,-1810(a0) # ffffffffc0211510 <check_mm_struct>
ffffffffc0203c2a:	d83fd0ef          	jal	ra,ffffffffc02019ac <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0203c2e:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0203c30:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0203c32:	4785                	li	a5,1
ffffffffc0203c34:	fcf70ce3          	beq	a4,a5,ffffffffc0203c0c <pgdir_alloc_page+0x34>
ffffffffc0203c38:	00002697          	auipc	a3,0x2
ffffffffc0203c3c:	52868693          	addi	a3,a3,1320 # ffffffffc0206160 <default_pmm_manager+0x830>
ffffffffc0203c40:	00001617          	auipc	a2,0x1
ffffffffc0203c44:	24860613          	addi	a2,a2,584 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203c48:	17a00593          	li	a1,378
ffffffffc0203c4c:	00002517          	auipc	a0,0x2
ffffffffc0203c50:	f9c50513          	addi	a0,a0,-100 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203c54:	caefc0ef          	jal	ra,ffffffffc0200102 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203c58:	100027f3          	csrr	a5,sstatus
ffffffffc0203c5c:	8b89                	andi	a5,a5,2
ffffffffc0203c5e:	eb99                	bnez	a5,ffffffffc0203c74 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c60:	0000e797          	auipc	a5,0xe
ffffffffc0203c64:	9007b783          	ld	a5,-1792(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203c68:	739c                	ld	a5,32(a5)
ffffffffc0203c6a:	8522                	mv	a0,s0
ffffffffc0203c6c:	4585                	li	a1,1
ffffffffc0203c6e:	9782                	jalr	a5
            return NULL;
ffffffffc0203c70:	4401                	li	s0,0
ffffffffc0203c72:	bf69                	j	ffffffffc0203c0c <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0203c74:	87bfc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203c78:	0000e797          	auipc	a5,0xe
ffffffffc0203c7c:	8e87b783          	ld	a5,-1816(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203c80:	739c                	ld	a5,32(a5)
ffffffffc0203c82:	8522                	mv	a0,s0
ffffffffc0203c84:	4585                	li	a1,1
ffffffffc0203c86:	9782                	jalr	a5
            return NULL;
ffffffffc0203c88:	4401                	li	s0,0
        intr_enable();
ffffffffc0203c8a:	85ffc0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0203c8e:	bfbd                	j	ffffffffc0203c0c <pgdir_alloc_page+0x34>

ffffffffc0203c90 <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc0203c90:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c92:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0203c94:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203c96:	fff50713          	addi	a4,a0,-1
ffffffffc0203c9a:	17f9                	addi	a5,a5,-2
ffffffffc0203c9c:	04e7ea63          	bltu	a5,a4,ffffffffc0203cf0 <kmalloc+0x60>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203ca0:	6785                	lui	a5,0x1
ffffffffc0203ca2:	17fd                	addi	a5,a5,-1
ffffffffc0203ca4:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0203ca6:	8131                	srli	a0,a0,0xc
ffffffffc0203ca8:	e31fe0ef          	jal	ra,ffffffffc0202ad8 <alloc_pages>
    assert(base != NULL);
ffffffffc0203cac:	cd3d                	beqz	a0,ffffffffc0203d2a <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cae:	0000e797          	auipc	a5,0xe
ffffffffc0203cb2:	8aa7b783          	ld	a5,-1878(a5) # ffffffffc0211558 <pages>
ffffffffc0203cb6:	8d1d                	sub	a0,a0,a5
ffffffffc0203cb8:	00002697          	auipc	a3,0x2
ffffffffc0203cbc:	7a06b683          	ld	a3,1952(a3) # ffffffffc0206458 <error_string+0x38>
ffffffffc0203cc0:	8511                	srai	a0,a0,0x4
ffffffffc0203cc2:	02d50533          	mul	a0,a0,a3
ffffffffc0203cc6:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cca:	0000e717          	auipc	a4,0xe
ffffffffc0203cce:	88673703          	ld	a4,-1914(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cd2:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cd4:	00c51793          	slli	a5,a0,0xc
ffffffffc0203cd8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cda:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cdc:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d10 <kmalloc+0x80>
    ptr = page2kva(base);
    return ptr;
}
ffffffffc0203ce0:	60a2                	ld	ra,8(sp)
ffffffffc0203ce2:	0000e797          	auipc	a5,0xe
ffffffffc0203ce6:	8867b783          	ld	a5,-1914(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203cea:	953e                	add	a0,a0,a5
ffffffffc0203cec:	0141                	addi	sp,sp,16
ffffffffc0203cee:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203cf0:	00002697          	auipc	a3,0x2
ffffffffc0203cf4:	48868693          	addi	a3,a3,1160 # ffffffffc0206178 <default_pmm_manager+0x848>
ffffffffc0203cf8:	00001617          	auipc	a2,0x1
ffffffffc0203cfc:	19060613          	addi	a2,a2,400 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203d00:	1f000593          	li	a1,496
ffffffffc0203d04:	00002517          	auipc	a0,0x2
ffffffffc0203d08:	ee450513          	addi	a0,a0,-284 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203d0c:	bf6fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203d10:	86aa                	mv	a3,a0
ffffffffc0203d12:	00002617          	auipc	a2,0x2
ffffffffc0203d16:	eae60613          	addi	a2,a2,-338 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0203d1a:	06a00593          	li	a1,106
ffffffffc0203d1e:	00001517          	auipc	a0,0x1
ffffffffc0203d22:	3da50513          	addi	a0,a0,986 # ffffffffc02050f8 <commands+0x998>
ffffffffc0203d26:	bdcfc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(base != NULL);
ffffffffc0203d2a:	00002697          	auipc	a3,0x2
ffffffffc0203d2e:	46e68693          	addi	a3,a3,1134 # ffffffffc0206198 <default_pmm_manager+0x868>
ffffffffc0203d32:	00001617          	auipc	a2,0x1
ffffffffc0203d36:	15660613          	addi	a2,a2,342 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203d3a:	1f300593          	li	a1,499
ffffffffc0203d3e:	00002517          	auipc	a0,0x2
ffffffffc0203d42:	eaa50513          	addi	a0,a0,-342 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203d46:	bbcfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203d4a <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc0203d4a:	1101                	addi	sp,sp,-32
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d4c:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0203d4e:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203d50:	fff58713          	addi	a4,a1,-1
ffffffffc0203d54:	17f9                	addi	a5,a5,-2
ffffffffc0203d56:	0ae7ee63          	bltu	a5,a4,ffffffffc0203e12 <kfree+0xc8>
    assert(ptr != NULL);
ffffffffc0203d5a:	cd41                	beqz	a0,ffffffffc0203df2 <kfree+0xa8>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0203d5c:	6785                	lui	a5,0x1
ffffffffc0203d5e:	17fd                	addi	a5,a5,-1
ffffffffc0203d60:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203d62:	c02007b7          	lui	a5,0xc0200
ffffffffc0203d66:	81b1                	srli	a1,a1,0xc
ffffffffc0203d68:	06f56863          	bltu	a0,a5,ffffffffc0203dd8 <kfree+0x8e>
ffffffffc0203d6c:	0000d697          	auipc	a3,0xd
ffffffffc0203d70:	7fc6b683          	ld	a3,2044(a3) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203d74:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc0203d76:	8131                	srli	a0,a0,0xc
ffffffffc0203d78:	0000d797          	auipc	a5,0xd
ffffffffc0203d7c:	7d87b783          	ld	a5,2008(a5) # ffffffffc0211550 <npage>
ffffffffc0203d80:	04f57a63          	bgeu	a0,a5,ffffffffc0203dd4 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0203d84:	fff806b7          	lui	a3,0xfff80
ffffffffc0203d88:	9536                	add	a0,a0,a3
ffffffffc0203d8a:	00251793          	slli	a5,a0,0x2
ffffffffc0203d8e:	953e                	add	a0,a0,a5
ffffffffc0203d90:	0512                	slli	a0,a0,0x4
ffffffffc0203d92:	0000d797          	auipc	a5,0xd
ffffffffc0203d96:	7c67b783          	ld	a5,1990(a5) # ffffffffc0211558 <pages>
ffffffffc0203d9a:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203d9c:	100027f3          	csrr	a5,sstatus
ffffffffc0203da0:	8b89                	andi	a5,a5,2
ffffffffc0203da2:	eb89                	bnez	a5,ffffffffc0203db4 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0203da4:	0000d797          	auipc	a5,0xd
ffffffffc0203da8:	7bc7b783          	ld	a5,1980(a5) # ffffffffc0211560 <pmm_manager>
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0203dac:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc0203dae:	739c                	ld	a5,32(a5)
}
ffffffffc0203db0:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc0203db2:	8782                	jr	a5
        intr_disable();
ffffffffc0203db4:	e42a                	sd	a0,8(sp)
ffffffffc0203db6:	e02e                	sd	a1,0(sp)
ffffffffc0203db8:	f36fc0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0203dbc:	0000d797          	auipc	a5,0xd
ffffffffc0203dc0:	7a47b783          	ld	a5,1956(a5) # ffffffffc0211560 <pmm_manager>
ffffffffc0203dc4:	6582                	ld	a1,0(sp)
ffffffffc0203dc6:	6522                	ld	a0,8(sp)
ffffffffc0203dc8:	739c                	ld	a5,32(a5)
ffffffffc0203dca:	9782                	jalr	a5
}
ffffffffc0203dcc:	60e2                	ld	ra,24(sp)
ffffffffc0203dce:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203dd0:	f18fc06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc0203dd4:	ccdfe0ef          	jal	ra,ffffffffc0202aa0 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0203dd8:	86aa                	mv	a3,a0
ffffffffc0203dda:	00002617          	auipc	a2,0x2
ffffffffc0203dde:	ea660613          	addi	a2,a2,-346 # ffffffffc0205c80 <default_pmm_manager+0x350>
ffffffffc0203de2:	06c00593          	li	a1,108
ffffffffc0203de6:	00001517          	auipc	a0,0x1
ffffffffc0203dea:	31250513          	addi	a0,a0,786 # ffffffffc02050f8 <commands+0x998>
ffffffffc0203dee:	b14fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(ptr != NULL);
ffffffffc0203df2:	00002697          	auipc	a3,0x2
ffffffffc0203df6:	3b668693          	addi	a3,a3,950 # ffffffffc02061a8 <default_pmm_manager+0x878>
ffffffffc0203dfa:	00001617          	auipc	a2,0x1
ffffffffc0203dfe:	08e60613          	addi	a2,a2,142 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203e02:	1fa00593          	li	a1,506
ffffffffc0203e06:	00002517          	auipc	a0,0x2
ffffffffc0203e0a:	de250513          	addi	a0,a0,-542 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203e0e:	af4fc0ef          	jal	ra,ffffffffc0200102 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0203e12:	00002697          	auipc	a3,0x2
ffffffffc0203e16:	36668693          	addi	a3,a3,870 # ffffffffc0206178 <default_pmm_manager+0x848>
ffffffffc0203e1a:	00001617          	auipc	a2,0x1
ffffffffc0203e1e:	06e60613          	addi	a2,a2,110 # ffffffffc0204e88 <commands+0x728>
ffffffffc0203e22:	1f900593          	li	a1,505
ffffffffc0203e26:	00002517          	auipc	a0,0x2
ffffffffc0203e2a:	dc250513          	addi	a0,a0,-574 # ffffffffc0205be8 <default_pmm_manager+0x2b8>
ffffffffc0203e2e:	ad4fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e32 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203e32:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e34:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203e36:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e38:	d9afc0ef          	jal	ra,ffffffffc02003d2 <ide_device_valid>
ffffffffc0203e3c:	cd01                	beqz	a0,ffffffffc0203e54 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e3e:	4505                	li	a0,1
ffffffffc0203e40:	d98fc0ef          	jal	ra,ffffffffc02003d8 <ide_device_size>
}
ffffffffc0203e44:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203e46:	810d                	srli	a0,a0,0x3
ffffffffc0203e48:	0000d797          	auipc	a5,0xd
ffffffffc0203e4c:	6ca7bc23          	sd	a0,1752(a5) # ffffffffc0211520 <max_swap_offset>
}
ffffffffc0203e50:	0141                	addi	sp,sp,16
ffffffffc0203e52:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e54:	00002617          	auipc	a2,0x2
ffffffffc0203e58:	36460613          	addi	a2,a2,868 # ffffffffc02061b8 <default_pmm_manager+0x888>
ffffffffc0203e5c:	45b5                	li	a1,13
ffffffffc0203e5e:	00002517          	auipc	a0,0x2
ffffffffc0203e62:	37a50513          	addi	a0,a0,890 # ffffffffc02061d8 <default_pmm_manager+0x8a8>
ffffffffc0203e66:	a9cfc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203e6a <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e6a:	1141                	addi	sp,sp,-16
ffffffffc0203e6c:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e6e:	00855793          	srli	a5,a0,0x8
ffffffffc0203e72:	c3a5                	beqz	a5,ffffffffc0203ed2 <swapfs_read+0x68>
ffffffffc0203e74:	0000d717          	auipc	a4,0xd
ffffffffc0203e78:	6ac73703          	ld	a4,1708(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203e7c:	04e7fb63          	bgeu	a5,a4,ffffffffc0203ed2 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203e80:	0000d617          	auipc	a2,0xd
ffffffffc0203e84:	6d863603          	ld	a2,1752(a2) # ffffffffc0211558 <pages>
ffffffffc0203e88:	8d91                	sub	a1,a1,a2
ffffffffc0203e8a:	4045d613          	srai	a2,a1,0x4
ffffffffc0203e8e:	00002597          	auipc	a1,0x2
ffffffffc0203e92:	5ca5b583          	ld	a1,1482(a1) # ffffffffc0206458 <error_string+0x38>
ffffffffc0203e96:	02b60633          	mul	a2,a2,a1
ffffffffc0203e9a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203e9e:	00002797          	auipc	a5,0x2
ffffffffc0203ea2:	5c27b783          	ld	a5,1474(a5) # ffffffffc0206460 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ea6:	0000d717          	auipc	a4,0xd
ffffffffc0203eaa:	6aa73703          	ld	a4,1706(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203eae:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eb0:	00c61793          	slli	a5,a2,0xc
ffffffffc0203eb4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203eb6:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203eb8:	02e7f963          	bgeu	a5,a4,ffffffffc0203eea <swapfs_read+0x80>
}
ffffffffc0203ebc:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ebe:	0000d797          	auipc	a5,0xd
ffffffffc0203ec2:	6aa7b783          	ld	a5,1706(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203ec6:	46a1                	li	a3,8
ffffffffc0203ec8:	963e                	add	a2,a2,a5
ffffffffc0203eca:	4505                	li	a0,1
}
ffffffffc0203ecc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ece:	d10fc06f          	j	ffffffffc02003de <ide_read_secs>
ffffffffc0203ed2:	86aa                	mv	a3,a0
ffffffffc0203ed4:	00002617          	auipc	a2,0x2
ffffffffc0203ed8:	31c60613          	addi	a2,a2,796 # ffffffffc02061f0 <default_pmm_manager+0x8c0>
ffffffffc0203edc:	45d1                	li	a1,20
ffffffffc0203ede:	00002517          	auipc	a0,0x2
ffffffffc0203ee2:	2fa50513          	addi	a0,a0,762 # ffffffffc02061d8 <default_pmm_manager+0x8a8>
ffffffffc0203ee6:	a1cfc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203eea:	86b2                	mv	a3,a2
ffffffffc0203eec:	06a00593          	li	a1,106
ffffffffc0203ef0:	00002617          	auipc	a2,0x2
ffffffffc0203ef4:	cd060613          	addi	a2,a2,-816 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0203ef8:	00001517          	auipc	a0,0x1
ffffffffc0203efc:	20050513          	addi	a0,a0,512 # ffffffffc02050f8 <commands+0x998>
ffffffffc0203f00:	a02fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f04 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f04:	1141                	addi	sp,sp,-16
ffffffffc0203f06:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f08:	00855793          	srli	a5,a0,0x8
ffffffffc0203f0c:	c3a5                	beqz	a5,ffffffffc0203f6c <swapfs_write+0x68>
ffffffffc0203f0e:	0000d717          	auipc	a4,0xd
ffffffffc0203f12:	61273703          	ld	a4,1554(a4) # ffffffffc0211520 <max_swap_offset>
ffffffffc0203f16:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f6c <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f1a:	0000d617          	auipc	a2,0xd
ffffffffc0203f1e:	63e63603          	ld	a2,1598(a2) # ffffffffc0211558 <pages>
ffffffffc0203f22:	8d91                	sub	a1,a1,a2
ffffffffc0203f24:	4045d613          	srai	a2,a1,0x4
ffffffffc0203f28:	00002597          	auipc	a1,0x2
ffffffffc0203f2c:	5305b583          	ld	a1,1328(a1) # ffffffffc0206458 <error_string+0x38>
ffffffffc0203f30:	02b60633          	mul	a2,a2,a1
ffffffffc0203f34:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f38:	00002797          	auipc	a5,0x2
ffffffffc0203f3c:	5287b783          	ld	a5,1320(a5) # ffffffffc0206460 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f40:	0000d717          	auipc	a4,0xd
ffffffffc0203f44:	61073703          	ld	a4,1552(a4) # ffffffffc0211550 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f48:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f4a:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f4e:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f50:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f52:	02e7f963          	bgeu	a5,a4,ffffffffc0203f84 <swapfs_write+0x80>
}
ffffffffc0203f56:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f58:	0000d797          	auipc	a5,0xd
ffffffffc0203f5c:	6107b783          	ld	a5,1552(a5) # ffffffffc0211568 <va_pa_offset>
ffffffffc0203f60:	46a1                	li	a3,8
ffffffffc0203f62:	963e                	add	a2,a2,a5
ffffffffc0203f64:	4505                	li	a0,1
}
ffffffffc0203f66:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f68:	c9afc06f          	j	ffffffffc0200402 <ide_write_secs>
ffffffffc0203f6c:	86aa                	mv	a3,a0
ffffffffc0203f6e:	00002617          	auipc	a2,0x2
ffffffffc0203f72:	28260613          	addi	a2,a2,642 # ffffffffc02061f0 <default_pmm_manager+0x8c0>
ffffffffc0203f76:	45e5                	li	a1,25
ffffffffc0203f78:	00002517          	auipc	a0,0x2
ffffffffc0203f7c:	26050513          	addi	a0,a0,608 # ffffffffc02061d8 <default_pmm_manager+0x8a8>
ffffffffc0203f80:	982fc0ef          	jal	ra,ffffffffc0200102 <__panic>
ffffffffc0203f84:	86b2                	mv	a3,a2
ffffffffc0203f86:	06a00593          	li	a1,106
ffffffffc0203f8a:	00002617          	auipc	a2,0x2
ffffffffc0203f8e:	c3660613          	addi	a2,a2,-970 # ffffffffc0205bc0 <default_pmm_manager+0x290>
ffffffffc0203f92:	00001517          	auipc	a0,0x1
ffffffffc0203f96:	16650513          	addi	a0,a0,358 # ffffffffc02050f8 <commands+0x998>
ffffffffc0203f9a:	968fc0ef          	jal	ra,ffffffffc0200102 <__panic>

ffffffffc0203f9e <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203f9e:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0203fa2:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0203fa4:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0203fa6:	cb81                	beqz	a5,ffffffffc0203fb6 <strlen+0x18>
        cnt ++;
ffffffffc0203fa8:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0203faa:	00a707b3          	add	a5,a4,a0
ffffffffc0203fae:	0007c783          	lbu	a5,0(a5)
ffffffffc0203fb2:	fbfd                	bnez	a5,ffffffffc0203fa8 <strlen+0xa>
ffffffffc0203fb4:	8082                	ret
    }
    return cnt;
}
ffffffffc0203fb6:	8082                	ret

ffffffffc0203fb8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203fb8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203fba:	e589                	bnez	a1,ffffffffc0203fc4 <strnlen+0xc>
ffffffffc0203fbc:	a811                	j	ffffffffc0203fd0 <strnlen+0x18>
        cnt ++;
ffffffffc0203fbe:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203fc0:	00f58863          	beq	a1,a5,ffffffffc0203fd0 <strnlen+0x18>
ffffffffc0203fc4:	00f50733          	add	a4,a0,a5
ffffffffc0203fc8:	00074703          	lbu	a4,0(a4)
ffffffffc0203fcc:	fb6d                	bnez	a4,ffffffffc0203fbe <strnlen+0x6>
ffffffffc0203fce:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203fd0:	852e                	mv	a0,a1
ffffffffc0203fd2:	8082                	ret

ffffffffc0203fd4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203fd4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203fd6:	0005c703          	lbu	a4,0(a1)
ffffffffc0203fda:	0785                	addi	a5,a5,1
ffffffffc0203fdc:	0585                	addi	a1,a1,1
ffffffffc0203fde:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203fe2:	fb75                	bnez	a4,ffffffffc0203fd6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203fe4:	8082                	ret

ffffffffc0203fe6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203fe6:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203fea:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203fee:	cb89                	beqz	a5,ffffffffc0204000 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0203ff0:	0505                	addi	a0,a0,1
ffffffffc0203ff2:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203ff4:	fee789e3          	beq	a5,a4,ffffffffc0203fe6 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ff8:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203ffc:	9d19                	subw	a0,a0,a4
ffffffffc0203ffe:	8082                	ret
ffffffffc0204000:	4501                	li	a0,0
ffffffffc0204002:	bfed                	j	ffffffffc0203ffc <strcmp+0x16>

ffffffffc0204004 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204004:	00054783          	lbu	a5,0(a0)
ffffffffc0204008:	c799                	beqz	a5,ffffffffc0204016 <strchr+0x12>
        if (*s == c) {
ffffffffc020400a:	00f58763          	beq	a1,a5,ffffffffc0204018 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020400e:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0204012:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204014:	fbfd                	bnez	a5,ffffffffc020400a <strchr+0x6>
    }
    return NULL;
ffffffffc0204016:	4501                	li	a0,0
}
ffffffffc0204018:	8082                	ret

ffffffffc020401a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020401a:	ca01                	beqz	a2,ffffffffc020402a <memset+0x10>
ffffffffc020401c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020401e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204020:	0785                	addi	a5,a5,1
ffffffffc0204022:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204026:	fec79de3          	bne	a5,a2,ffffffffc0204020 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020402a:	8082                	ret

ffffffffc020402c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020402c:	ca19                	beqz	a2,ffffffffc0204042 <memcpy+0x16>
ffffffffc020402e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204030:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204032:	0005c703          	lbu	a4,0(a1)
ffffffffc0204036:	0585                	addi	a1,a1,1
ffffffffc0204038:	0785                	addi	a5,a5,1
ffffffffc020403a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020403e:	fec59ae3          	bne	a1,a2,ffffffffc0204032 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204042:	8082                	ret

ffffffffc0204044 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0204044:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204048:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020404a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020404e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204050:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204054:	f022                	sd	s0,32(sp)
ffffffffc0204056:	ec26                	sd	s1,24(sp)
ffffffffc0204058:	e84a                	sd	s2,16(sp)
ffffffffc020405a:	f406                	sd	ra,40(sp)
ffffffffc020405c:	e44e                	sd	s3,8(sp)
ffffffffc020405e:	84aa                	mv	s1,a0
ffffffffc0204060:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204062:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0204066:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0204068:	03067e63          	bgeu	a2,a6,ffffffffc02040a4 <printnum+0x60>
ffffffffc020406c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020406e:	00805763          	blez	s0,ffffffffc020407c <printnum+0x38>
ffffffffc0204072:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0204074:	85ca                	mv	a1,s2
ffffffffc0204076:	854e                	mv	a0,s3
ffffffffc0204078:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020407a:	fc65                	bnez	s0,ffffffffc0204072 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020407c:	1a02                	slli	s4,s4,0x20
ffffffffc020407e:	00002797          	auipc	a5,0x2
ffffffffc0204082:	19278793          	addi	a5,a5,402 # ffffffffc0206210 <default_pmm_manager+0x8e0>
ffffffffc0204086:	020a5a13          	srli	s4,s4,0x20
ffffffffc020408a:	9a3e                	add	s4,s4,a5
}
ffffffffc020408c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020408e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204092:	70a2                	ld	ra,40(sp)
ffffffffc0204094:	69a2                	ld	s3,8(sp)
ffffffffc0204096:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204098:	85ca                	mv	a1,s2
ffffffffc020409a:	87a6                	mv	a5,s1
}
ffffffffc020409c:	6942                	ld	s2,16(sp)
ffffffffc020409e:	64e2                	ld	s1,24(sp)
ffffffffc02040a0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02040a2:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02040a4:	03065633          	divu	a2,a2,a6
ffffffffc02040a8:	8722                	mv	a4,s0
ffffffffc02040aa:	f9bff0ef          	jal	ra,ffffffffc0204044 <printnum>
ffffffffc02040ae:	b7f9                	j	ffffffffc020407c <printnum+0x38>

ffffffffc02040b0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02040b0:	7119                	addi	sp,sp,-128
ffffffffc02040b2:	f4a6                	sd	s1,104(sp)
ffffffffc02040b4:	f0ca                	sd	s2,96(sp)
ffffffffc02040b6:	ecce                	sd	s3,88(sp)
ffffffffc02040b8:	e8d2                	sd	s4,80(sp)
ffffffffc02040ba:	e4d6                	sd	s5,72(sp)
ffffffffc02040bc:	e0da                	sd	s6,64(sp)
ffffffffc02040be:	fc5e                	sd	s7,56(sp)
ffffffffc02040c0:	f06a                	sd	s10,32(sp)
ffffffffc02040c2:	fc86                	sd	ra,120(sp)
ffffffffc02040c4:	f8a2                	sd	s0,112(sp)
ffffffffc02040c6:	f862                	sd	s8,48(sp)
ffffffffc02040c8:	f466                	sd	s9,40(sp)
ffffffffc02040ca:	ec6e                	sd	s11,24(sp)
ffffffffc02040cc:	892a                	mv	s2,a0
ffffffffc02040ce:	84ae                	mv	s1,a1
ffffffffc02040d0:	8d32                	mv	s10,a2
ffffffffc02040d2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040d4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02040d8:	5b7d                	li	s6,-1
ffffffffc02040da:	00002a97          	auipc	s5,0x2
ffffffffc02040de:	16aa8a93          	addi	s5,s5,362 # ffffffffc0206244 <default_pmm_manager+0x914>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02040e2:	00002b97          	auipc	s7,0x2
ffffffffc02040e6:	33eb8b93          	addi	s7,s7,830 # ffffffffc0206420 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040ea:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc02040ee:	001d0413          	addi	s0,s10,1
ffffffffc02040f2:	01350a63          	beq	a0,s3,ffffffffc0204106 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02040f6:	c121                	beqz	a0,ffffffffc0204136 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02040f8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040fa:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02040fc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02040fe:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204102:	ff351ae3          	bne	a0,s3,ffffffffc02040f6 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204106:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020410a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020410e:	4c81                	li	s9,0
ffffffffc0204110:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204112:	5c7d                	li	s8,-1
ffffffffc0204114:	5dfd                	li	s11,-1
ffffffffc0204116:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020411a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020411c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204120:	0ff5f593          	zext.b	a1,a1
ffffffffc0204124:	00140d13          	addi	s10,s0,1
ffffffffc0204128:	04b56263          	bltu	a0,a1,ffffffffc020416c <vprintfmt+0xbc>
ffffffffc020412c:	058a                	slli	a1,a1,0x2
ffffffffc020412e:	95d6                	add	a1,a1,s5
ffffffffc0204130:	4194                	lw	a3,0(a1)
ffffffffc0204132:	96d6                	add	a3,a3,s5
ffffffffc0204134:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204136:	70e6                	ld	ra,120(sp)
ffffffffc0204138:	7446                	ld	s0,112(sp)
ffffffffc020413a:	74a6                	ld	s1,104(sp)
ffffffffc020413c:	7906                	ld	s2,96(sp)
ffffffffc020413e:	69e6                	ld	s3,88(sp)
ffffffffc0204140:	6a46                	ld	s4,80(sp)
ffffffffc0204142:	6aa6                	ld	s5,72(sp)
ffffffffc0204144:	6b06                	ld	s6,64(sp)
ffffffffc0204146:	7be2                	ld	s7,56(sp)
ffffffffc0204148:	7c42                	ld	s8,48(sp)
ffffffffc020414a:	7ca2                	ld	s9,40(sp)
ffffffffc020414c:	7d02                	ld	s10,32(sp)
ffffffffc020414e:	6de2                	ld	s11,24(sp)
ffffffffc0204150:	6109                	addi	sp,sp,128
ffffffffc0204152:	8082                	ret
            padc = '0';
ffffffffc0204154:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0204156:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020415a:	846a                	mv	s0,s10
ffffffffc020415c:	00140d13          	addi	s10,s0,1
ffffffffc0204160:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0204164:	0ff5f593          	zext.b	a1,a1
ffffffffc0204168:	fcb572e3          	bgeu	a0,a1,ffffffffc020412c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020416c:	85a6                	mv	a1,s1
ffffffffc020416e:	02500513          	li	a0,37
ffffffffc0204172:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204174:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204178:	8d22                	mv	s10,s0
ffffffffc020417a:	f73788e3          	beq	a5,s3,ffffffffc02040ea <vprintfmt+0x3a>
ffffffffc020417e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204182:	1d7d                	addi	s10,s10,-1
ffffffffc0204184:	ff379de3          	bne	a5,s3,ffffffffc020417e <vprintfmt+0xce>
ffffffffc0204188:	b78d                	j	ffffffffc02040ea <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020418a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020418e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204192:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204194:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204198:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020419c:	02d86463          	bltu	a6,a3,ffffffffc02041c4 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02041a0:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02041a4:	002c169b          	slliw	a3,s8,0x2
ffffffffc02041a8:	0186873b          	addw	a4,a3,s8
ffffffffc02041ac:	0017171b          	slliw	a4,a4,0x1
ffffffffc02041b0:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02041b2:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02041b6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02041b8:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02041bc:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02041c0:	fed870e3          	bgeu	a6,a3,ffffffffc02041a0 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02041c4:	f40ddce3          	bgez	s11,ffffffffc020411c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02041c8:	8de2                	mv	s11,s8
ffffffffc02041ca:	5c7d                	li	s8,-1
ffffffffc02041cc:	bf81                	j	ffffffffc020411c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02041ce:	fffdc693          	not	a3,s11
ffffffffc02041d2:	96fd                	srai	a3,a3,0x3f
ffffffffc02041d4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d8:	00144603          	lbu	a2,1(s0)
ffffffffc02041dc:	2d81                	sext.w	s11,s11
ffffffffc02041de:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041e0:	bf35                	j	ffffffffc020411c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02041e2:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041e6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02041ea:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041ec:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02041ee:	bfd9                	j	ffffffffc02041c4 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02041f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041f6:	01174463          	blt	a4,a7,ffffffffc02041fe <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02041fa:	1a088e63          	beqz	a7,ffffffffc02043b6 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02041fe:	000a3603          	ld	a2,0(s4)
ffffffffc0204202:	46c1                	li	a3,16
ffffffffc0204204:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204206:	2781                	sext.w	a5,a5
ffffffffc0204208:	876e                	mv	a4,s11
ffffffffc020420a:	85a6                	mv	a1,s1
ffffffffc020420c:	854a                	mv	a0,s2
ffffffffc020420e:	e37ff0ef          	jal	ra,ffffffffc0204044 <printnum>
            break;
ffffffffc0204212:	bde1                	j	ffffffffc02040ea <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204214:	000a2503          	lw	a0,0(s4)
ffffffffc0204218:	85a6                	mv	a1,s1
ffffffffc020421a:	0a21                	addi	s4,s4,8
ffffffffc020421c:	9902                	jalr	s2
            break;
ffffffffc020421e:	b5f1                	j	ffffffffc02040ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204220:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204222:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0204226:	01174463          	blt	a4,a7,ffffffffc020422e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020422a:	18088163          	beqz	a7,ffffffffc02043ac <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020422e:	000a3603          	ld	a2,0(s4)
ffffffffc0204232:	46a9                	li	a3,10
ffffffffc0204234:	8a2e                	mv	s4,a1
ffffffffc0204236:	bfc1                	j	ffffffffc0204206 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204238:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020423c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020423e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204240:	bdf1                	j	ffffffffc020411c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0204242:	85a6                	mv	a1,s1
ffffffffc0204244:	02500513          	li	a0,37
ffffffffc0204248:	9902                	jalr	s2
            break;
ffffffffc020424a:	b545                	j	ffffffffc02040ea <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020424c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0204250:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204252:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204254:	b5e1                	j	ffffffffc020411c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0204256:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204258:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020425c:	01174463          	blt	a4,a7,ffffffffc0204264 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0204260:	14088163          	beqz	a7,ffffffffc02043a2 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0204264:	000a3603          	ld	a2,0(s4)
ffffffffc0204268:	46a1                	li	a3,8
ffffffffc020426a:	8a2e                	mv	s4,a1
ffffffffc020426c:	bf69                	j	ffffffffc0204206 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020426e:	03000513          	li	a0,48
ffffffffc0204272:	85a6                	mv	a1,s1
ffffffffc0204274:	e03e                	sd	a5,0(sp)
ffffffffc0204276:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204278:	85a6                	mv	a1,s1
ffffffffc020427a:	07800513          	li	a0,120
ffffffffc020427e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204280:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204282:	6782                	ld	a5,0(sp)
ffffffffc0204284:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204286:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020428a:	bfb5                	j	ffffffffc0204206 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020428c:	000a3403          	ld	s0,0(s4)
ffffffffc0204290:	008a0713          	addi	a4,s4,8
ffffffffc0204294:	e03a                	sd	a4,0(sp)
ffffffffc0204296:	14040263          	beqz	s0,ffffffffc02043da <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020429a:	0fb05763          	blez	s11,ffffffffc0204388 <vprintfmt+0x2d8>
ffffffffc020429e:	02d00693          	li	a3,45
ffffffffc02042a2:	0cd79163          	bne	a5,a3,ffffffffc0204364 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042a6:	00044783          	lbu	a5,0(s0)
ffffffffc02042aa:	0007851b          	sext.w	a0,a5
ffffffffc02042ae:	cf85                	beqz	a5,ffffffffc02042e6 <vprintfmt+0x236>
ffffffffc02042b0:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042b4:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042b8:	000c4563          	bltz	s8,ffffffffc02042c2 <vprintfmt+0x212>
ffffffffc02042bc:	3c7d                	addiw	s8,s8,-1
ffffffffc02042be:	036c0263          	beq	s8,s6,ffffffffc02042e2 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02042c2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02042c4:	0e0c8e63          	beqz	s9,ffffffffc02043c0 <vprintfmt+0x310>
ffffffffc02042c8:	3781                	addiw	a5,a5,-32
ffffffffc02042ca:	0ef47b63          	bgeu	s0,a5,ffffffffc02043c0 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02042ce:	03f00513          	li	a0,63
ffffffffc02042d2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02042d4:	000a4783          	lbu	a5,0(s4)
ffffffffc02042d8:	3dfd                	addiw	s11,s11,-1
ffffffffc02042da:	0a05                	addi	s4,s4,1
ffffffffc02042dc:	0007851b          	sext.w	a0,a5
ffffffffc02042e0:	ffe1                	bnez	a5,ffffffffc02042b8 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02042e2:	01b05963          	blez	s11,ffffffffc02042f4 <vprintfmt+0x244>
ffffffffc02042e6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02042e8:	85a6                	mv	a1,s1
ffffffffc02042ea:	02000513          	li	a0,32
ffffffffc02042ee:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02042f0:	fe0d9be3          	bnez	s11,ffffffffc02042e6 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02042f4:	6a02                	ld	s4,0(sp)
ffffffffc02042f6:	bbd5                	j	ffffffffc02040ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02042f8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02042fa:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02042fe:	01174463          	blt	a4,a7,ffffffffc0204306 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204302:	08088d63          	beqz	a7,ffffffffc020439c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0204306:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020430a:	0a044d63          	bltz	s0,ffffffffc02043c4 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020430e:	8622                	mv	a2,s0
ffffffffc0204310:	8a66                	mv	s4,s9
ffffffffc0204312:	46a9                	li	a3,10
ffffffffc0204314:	bdcd                	j	ffffffffc0204206 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0204316:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020431a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020431c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020431e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0204322:	8fb5                	xor	a5,a5,a3
ffffffffc0204324:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204328:	02d74163          	blt	a4,a3,ffffffffc020434a <vprintfmt+0x29a>
ffffffffc020432c:	00369793          	slli	a5,a3,0x3
ffffffffc0204330:	97de                	add	a5,a5,s7
ffffffffc0204332:	639c                	ld	a5,0(a5)
ffffffffc0204334:	cb99                	beqz	a5,ffffffffc020434a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0204336:	86be                	mv	a3,a5
ffffffffc0204338:	00002617          	auipc	a2,0x2
ffffffffc020433c:	f0860613          	addi	a2,a2,-248 # ffffffffc0206240 <default_pmm_manager+0x910>
ffffffffc0204340:	85a6                	mv	a1,s1
ffffffffc0204342:	854a                	mv	a0,s2
ffffffffc0204344:	0ce000ef          	jal	ra,ffffffffc0204412 <printfmt>
ffffffffc0204348:	b34d                	j	ffffffffc02040ea <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020434a:	00002617          	auipc	a2,0x2
ffffffffc020434e:	ee660613          	addi	a2,a2,-282 # ffffffffc0206230 <default_pmm_manager+0x900>
ffffffffc0204352:	85a6                	mv	a1,s1
ffffffffc0204354:	854a                	mv	a0,s2
ffffffffc0204356:	0bc000ef          	jal	ra,ffffffffc0204412 <printfmt>
ffffffffc020435a:	bb41                	j	ffffffffc02040ea <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020435c:	00002417          	auipc	s0,0x2
ffffffffc0204360:	ecc40413          	addi	s0,s0,-308 # ffffffffc0206228 <default_pmm_manager+0x8f8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204364:	85e2                	mv	a1,s8
ffffffffc0204366:	8522                	mv	a0,s0
ffffffffc0204368:	e43e                	sd	a5,8(sp)
ffffffffc020436a:	c4fff0ef          	jal	ra,ffffffffc0203fb8 <strnlen>
ffffffffc020436e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204372:	01b05b63          	blez	s11,ffffffffc0204388 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0204376:	67a2                	ld	a5,8(sp)
ffffffffc0204378:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020437c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020437e:	85a6                	mv	a1,s1
ffffffffc0204380:	8552                	mv	a0,s4
ffffffffc0204382:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204384:	fe0d9ce3          	bnez	s11,ffffffffc020437c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204388:	00044783          	lbu	a5,0(s0)
ffffffffc020438c:	00140a13          	addi	s4,s0,1
ffffffffc0204390:	0007851b          	sext.w	a0,a5
ffffffffc0204394:	d3a5                	beqz	a5,ffffffffc02042f4 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204396:	05e00413          	li	s0,94
ffffffffc020439a:	bf39                	j	ffffffffc02042b8 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020439c:	000a2403          	lw	s0,0(s4)
ffffffffc02043a0:	b7ad                	j	ffffffffc020430a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02043a2:	000a6603          	lwu	a2,0(s4)
ffffffffc02043a6:	46a1                	li	a3,8
ffffffffc02043a8:	8a2e                	mv	s4,a1
ffffffffc02043aa:	bdb1                	j	ffffffffc0204206 <vprintfmt+0x156>
ffffffffc02043ac:	000a6603          	lwu	a2,0(s4)
ffffffffc02043b0:	46a9                	li	a3,10
ffffffffc02043b2:	8a2e                	mv	s4,a1
ffffffffc02043b4:	bd89                	j	ffffffffc0204206 <vprintfmt+0x156>
ffffffffc02043b6:	000a6603          	lwu	a2,0(s4)
ffffffffc02043ba:	46c1                	li	a3,16
ffffffffc02043bc:	8a2e                	mv	s4,a1
ffffffffc02043be:	b5a1                	j	ffffffffc0204206 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02043c0:	9902                	jalr	s2
ffffffffc02043c2:	bf09                	j	ffffffffc02042d4 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02043c4:	85a6                	mv	a1,s1
ffffffffc02043c6:	02d00513          	li	a0,45
ffffffffc02043ca:	e03e                	sd	a5,0(sp)
ffffffffc02043cc:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02043ce:	6782                	ld	a5,0(sp)
ffffffffc02043d0:	8a66                	mv	s4,s9
ffffffffc02043d2:	40800633          	neg	a2,s0
ffffffffc02043d6:	46a9                	li	a3,10
ffffffffc02043d8:	b53d                	j	ffffffffc0204206 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02043da:	03b05163          	blez	s11,ffffffffc02043fc <vprintfmt+0x34c>
ffffffffc02043de:	02d00693          	li	a3,45
ffffffffc02043e2:	f6d79de3          	bne	a5,a3,ffffffffc020435c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02043e6:	00002417          	auipc	s0,0x2
ffffffffc02043ea:	e4240413          	addi	s0,s0,-446 # ffffffffc0206228 <default_pmm_manager+0x8f8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02043ee:	02800793          	li	a5,40
ffffffffc02043f2:	02800513          	li	a0,40
ffffffffc02043f6:	00140a13          	addi	s4,s0,1
ffffffffc02043fa:	bd6d                	j	ffffffffc02042b4 <vprintfmt+0x204>
ffffffffc02043fc:	00002a17          	auipc	s4,0x2
ffffffffc0204400:	e2da0a13          	addi	s4,s4,-467 # ffffffffc0206229 <default_pmm_manager+0x8f9>
ffffffffc0204404:	02800513          	li	a0,40
ffffffffc0204408:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020440c:	05e00413          	li	s0,94
ffffffffc0204410:	b565                	j	ffffffffc02042b8 <vprintfmt+0x208>

ffffffffc0204412 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204412:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204414:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204418:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020441a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020441c:	ec06                	sd	ra,24(sp)
ffffffffc020441e:	f83a                	sd	a4,48(sp)
ffffffffc0204420:	fc3e                	sd	a5,56(sp)
ffffffffc0204422:	e0c2                	sd	a6,64(sp)
ffffffffc0204424:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204426:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204428:	c89ff0ef          	jal	ra,ffffffffc02040b0 <vprintfmt>
}
ffffffffc020442c:	60e2                	ld	ra,24(sp)
ffffffffc020442e:	6161                	addi	sp,sp,80
ffffffffc0204430:	8082                	ret

ffffffffc0204432 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204432:	715d                	addi	sp,sp,-80
ffffffffc0204434:	e486                	sd	ra,72(sp)
ffffffffc0204436:	e0a6                	sd	s1,64(sp)
ffffffffc0204438:	fc4a                	sd	s2,56(sp)
ffffffffc020443a:	f84e                	sd	s3,48(sp)
ffffffffc020443c:	f452                	sd	s4,40(sp)
ffffffffc020443e:	f056                	sd	s5,32(sp)
ffffffffc0204440:	ec5a                	sd	s6,24(sp)
ffffffffc0204442:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc0204444:	c901                	beqz	a0,ffffffffc0204454 <readline+0x22>
ffffffffc0204446:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0204448:	00002517          	auipc	a0,0x2
ffffffffc020444c:	df850513          	addi	a0,a0,-520 # ffffffffc0206240 <default_pmm_manager+0x910>
ffffffffc0204450:	c6bfb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc0204454:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204456:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204458:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020445a:	4aa9                	li	s5,10
ffffffffc020445c:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020445e:	0000db97          	auipc	s7,0xd
ffffffffc0204462:	c9ab8b93          	addi	s7,s7,-870 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204466:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020446a:	c89fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020446e:	00054a63          	bltz	a0,ffffffffc0204482 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204472:	00a95a63          	bge	s2,a0,ffffffffc0204486 <readline+0x54>
ffffffffc0204476:	029a5263          	bge	s4,s1,ffffffffc020449a <readline+0x68>
        c = getchar();
ffffffffc020447a:	c79fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc020447e:	fe055ae3          	bgez	a0,ffffffffc0204472 <readline+0x40>
            return NULL;
ffffffffc0204482:	4501                	li	a0,0
ffffffffc0204484:	a091                	j	ffffffffc02044c8 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0204486:	03351463          	bne	a0,s3,ffffffffc02044ae <readline+0x7c>
ffffffffc020448a:	e8a9                	bnez	s1,ffffffffc02044dc <readline+0xaa>
        c = getchar();
ffffffffc020448c:	c67fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204490:	fe0549e3          	bltz	a0,ffffffffc0204482 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204494:	fea959e3          	bge	s2,a0,ffffffffc0204486 <readline+0x54>
ffffffffc0204498:	4481                	li	s1,0
            cputchar(c);
ffffffffc020449a:	e42a                	sd	a0,8(sp)
ffffffffc020449c:	c55fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc02044a0:	6522                	ld	a0,8(sp)
ffffffffc02044a2:	009b87b3          	add	a5,s7,s1
ffffffffc02044a6:	2485                	addiw	s1,s1,1
ffffffffc02044a8:	00a78023          	sb	a0,0(a5)
ffffffffc02044ac:	bf7d                	j	ffffffffc020446a <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02044ae:	01550463          	beq	a0,s5,ffffffffc02044b6 <readline+0x84>
ffffffffc02044b2:	fb651ce3          	bne	a0,s6,ffffffffc020446a <readline+0x38>
            cputchar(c);
ffffffffc02044b6:	c3bfb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc02044ba:	0000d517          	auipc	a0,0xd
ffffffffc02044be:	c3e50513          	addi	a0,a0,-962 # ffffffffc02110f8 <buf>
ffffffffc02044c2:	94aa                	add	s1,s1,a0
ffffffffc02044c4:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02044c8:	60a6                	ld	ra,72(sp)
ffffffffc02044ca:	6486                	ld	s1,64(sp)
ffffffffc02044cc:	7962                	ld	s2,56(sp)
ffffffffc02044ce:	79c2                	ld	s3,48(sp)
ffffffffc02044d0:	7a22                	ld	s4,40(sp)
ffffffffc02044d2:	7a82                	ld	s5,32(sp)
ffffffffc02044d4:	6b62                	ld	s6,24(sp)
ffffffffc02044d6:	6bc2                	ld	s7,16(sp)
ffffffffc02044d8:	6161                	addi	sp,sp,80
ffffffffc02044da:	8082                	ret
            cputchar(c);
ffffffffc02044dc:	4521                	li	a0,8
ffffffffc02044de:	c13fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc02044e2:	34fd                	addiw	s1,s1,-1
ffffffffc02044e4:	b759                	j	ffffffffc020446a <readline+0x38>
