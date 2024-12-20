
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200024:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200032:	000a7517          	auipc	a0,0xa7
ffffffffc0200036:	5fe50513          	addi	a0,a0,1534 # ffffffffc02a7630 <buf>
ffffffffc020003a:	000b3617          	auipc	a2,0xb3
ffffffffc020003e:	b5260613          	addi	a2,a2,-1198 # ffffffffc02b2b8c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	644060ef          	jal	ra,ffffffffc020668e <memset>
    cons_init();                // init the console
ffffffffc020004e:	52a000ef          	jal	ra,ffffffffc0200578 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00006597          	auipc	a1,0x6
ffffffffc0200056:	66658593          	addi	a1,a1,1638 # ffffffffc02066b8 <etext>
ffffffffc020005a:	00006517          	auipc	a0,0x6
ffffffffc020005e:	67e50513          	addi	a0,a0,1662 # ffffffffc02066d8 <etext+0x20>
ffffffffc0200062:	11e000ef          	jal	ra,ffffffffc0200180 <cprintf>

    print_kerninfo();
ffffffffc0200066:	1a2000ef          	jal	ra,ffffffffc0200208 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	512020ef          	jal	ra,ffffffffc020257c <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc020006e:	5de000ef          	jal	ra,ffffffffc020064c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200072:	5dc000ef          	jal	ra,ffffffffc020064e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200076:	494040ef          	jal	ra,ffffffffc020450a <vmm_init>
    proc_init();                // init process table
ffffffffc020007a:	58d050ef          	jal	ra,ffffffffc0205e06 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc020007e:	56c000ef          	jal	ra,ffffffffc02005ea <ide_init>
    swap_init();                // init swap
ffffffffc0200082:	3d6030ef          	jal	ra,ffffffffc0203458 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc0200086:	4a0000ef          	jal	ra,ffffffffc0200526 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008a:	5b6000ef          	jal	ra,ffffffffc0200640 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc020008e:	711050ef          	jal	ra,ffffffffc0205f9e <cpu_idle>

ffffffffc0200092 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200092:	715d                	addi	sp,sp,-80
ffffffffc0200094:	e486                	sd	ra,72(sp)
ffffffffc0200096:	e0a6                	sd	s1,64(sp)
ffffffffc0200098:	fc4a                	sd	s2,56(sp)
ffffffffc020009a:	f84e                	sd	s3,48(sp)
ffffffffc020009c:	f452                	sd	s4,40(sp)
ffffffffc020009e:	f056                	sd	s5,32(sp)
ffffffffc02000a0:	ec5a                	sd	s6,24(sp)
ffffffffc02000a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02000a4:	c901                	beqz	a0,ffffffffc02000b4 <readline+0x22>
ffffffffc02000a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02000a8:	00006517          	auipc	a0,0x6
ffffffffc02000ac:	63850513          	addi	a0,a0,1592 # ffffffffc02066e0 <etext+0x28>
ffffffffc02000b0:	0d0000ef          	jal	ra,ffffffffc0200180 <cprintf>
readline(const char *prompt) {
ffffffffc02000b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000ba:	4aa9                	li	s5,10
ffffffffc02000bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000be:	000a7b97          	auipc	s7,0xa7
ffffffffc02000c2:	572b8b93          	addi	s7,s7,1394 # ffffffffc02a7630 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000ca:	12e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000ce:	00054a63          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d2:	00a95a63          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000d6:	029a5263          	bge	s4,s1,ffffffffc02000fa <readline+0x68>
        c = getchar();
ffffffffc02000da:	11e000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000de:	fe055ae3          	bgez	a0,ffffffffc02000d2 <readline+0x40>
            return NULL;
ffffffffc02000e2:	4501                	li	a0,0
ffffffffc02000e4:	a091                	j	ffffffffc0200128 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02000e6:	03351463          	bne	a0,s3,ffffffffc020010e <readline+0x7c>
ffffffffc02000ea:	e8a9                	bnez	s1,ffffffffc020013c <readline+0xaa>
        c = getchar();
ffffffffc02000ec:	10c000ef          	jal	ra,ffffffffc02001f8 <getchar>
        if (c < 0) {
ffffffffc02000f0:	fe0549e3          	bltz	a0,ffffffffc02000e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000f4:	fea959e3          	bge	s2,a0,ffffffffc02000e6 <readline+0x54>
ffffffffc02000f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02000fa:	e42a                	sd	a0,8(sp)
ffffffffc02000fc:	0ba000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i ++] = c;
ffffffffc0200100:	6522                	ld	a0,8(sp)
ffffffffc0200102:	009b87b3          	add	a5,s7,s1
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	00a78023          	sb	a0,0(a5)
ffffffffc020010c:	bf7d                	j	ffffffffc02000ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	01550463          	beq	a0,s5,ffffffffc0200116 <readline+0x84>
ffffffffc0200112:	fb651ce3          	bne	a0,s6,ffffffffc02000ca <readline+0x38>
            cputchar(c);
ffffffffc0200116:	0a0000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            buf[i] = '\0';
ffffffffc020011a:	000a7517          	auipc	a0,0xa7
ffffffffc020011e:	51650513          	addi	a0,a0,1302 # ffffffffc02a7630 <buf>
ffffffffc0200122:	94aa                	add	s1,s1,a0
ffffffffc0200124:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
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
            cputchar(c);
ffffffffc020013c:	4521                	li	a0,8
ffffffffc020013e:	078000ef          	jal	ra,ffffffffc02001b6 <cputchar>
            i --;
ffffffffc0200142:	34fd                	addiw	s1,s1,-1
ffffffffc0200144:	b759                	j	ffffffffc02000ca <readline+0x38>

ffffffffc0200146 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200146:	1141                	addi	sp,sp,-16
ffffffffc0200148:	e022                	sd	s0,0(sp)
ffffffffc020014a:	e406                	sd	ra,8(sp)
ffffffffc020014c:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020014e:	42c000ef          	jal	ra,ffffffffc020057a <cons_putc>
    (*cnt) ++;
ffffffffc0200152:	401c                	lw	a5,0(s0)
}
ffffffffc0200154:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200156:	2785                	addiw	a5,a5,1
ffffffffc0200158:	c01c                	sw	a5,0(s0)
}
ffffffffc020015a:	6402                	ld	s0,0(sp)
ffffffffc020015c:	0141                	addi	sp,sp,16
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	862a                	mv	a2,a0
ffffffffc0200164:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200166:	00000517          	auipc	a0,0x0
ffffffffc020016a:	fe050513          	addi	a0,a0,-32 # ffffffffc0200146 <cputch>
ffffffffc020016e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200170:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200172:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200174:	11c060ef          	jal	ra,ffffffffc0206290 <vprintfmt>
    return cnt;
}
ffffffffc0200178:	60e2                	ld	ra,24(sp)
ffffffffc020017a:	4532                	lw	a0,12(sp)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200180:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200182:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200186:	8e2a                	mv	t3,a0
ffffffffc0200188:	f42e                	sd	a1,40(sp)
ffffffffc020018a:	f832                	sd	a2,48(sp)
ffffffffc020018c:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020018e:	00000517          	auipc	a0,0x0
ffffffffc0200192:	fb850513          	addi	a0,a0,-72 # ffffffffc0200146 <cputch>
ffffffffc0200196:	004c                	addi	a1,sp,4
ffffffffc0200198:	869a                	mv	a3,t1
ffffffffc020019a:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc020019c:	ec06                	sd	ra,24(sp)
ffffffffc020019e:	e0ba                	sd	a4,64(sp)
ffffffffc02001a0:	e4be                	sd	a5,72(sp)
ffffffffc02001a2:	e8c2                	sd	a6,80(sp)
ffffffffc02001a4:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001a6:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001a8:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001aa:	0e6060ef          	jal	ra,ffffffffc0206290 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ae:	60e2                	ld	ra,24(sp)
ffffffffc02001b0:	4512                	lw	a0,4(sp)
ffffffffc02001b2:	6125                	addi	sp,sp,96
ffffffffc02001b4:	8082                	ret

ffffffffc02001b6 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001b6:	a6d1                	j	ffffffffc020057a <cons_putc>

ffffffffc02001b8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001b8:	1101                	addi	sp,sp,-32
ffffffffc02001ba:	e822                	sd	s0,16(sp)
ffffffffc02001bc:	ec06                	sd	ra,24(sp)
ffffffffc02001be:	e426                	sd	s1,8(sp)
ffffffffc02001c0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001c2:	00054503          	lbu	a0,0(a0)
ffffffffc02001c6:	c51d                	beqz	a0,ffffffffc02001f4 <cputs+0x3c>
ffffffffc02001c8:	0405                	addi	s0,s0,1
ffffffffc02001ca:	4485                	li	s1,1
ffffffffc02001cc:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001ce:	3ac000ef          	jal	ra,ffffffffc020057a <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001d2:	00044503          	lbu	a0,0(s0)
ffffffffc02001d6:	008487bb          	addw	a5,s1,s0
ffffffffc02001da:	0405                	addi	s0,s0,1
ffffffffc02001dc:	f96d                	bnez	a0,ffffffffc02001ce <cputs+0x16>
    (*cnt) ++;
ffffffffc02001de:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001e2:	4529                	li	a0,10
ffffffffc02001e4:	396000ef          	jal	ra,ffffffffc020057a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001e8:	60e2                	ld	ra,24(sp)
ffffffffc02001ea:	8522                	mv	a0,s0
ffffffffc02001ec:	6442                	ld	s0,16(sp)
ffffffffc02001ee:	64a2                	ld	s1,8(sp)
ffffffffc02001f0:	6105                	addi	sp,sp,32
ffffffffc02001f2:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc02001f4:	4405                	li	s0,1
ffffffffc02001f6:	b7f5                	j	ffffffffc02001e2 <cputs+0x2a>

ffffffffc02001f8 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001f8:	1141                	addi	sp,sp,-16
ffffffffc02001fa:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001fc:	3b2000ef          	jal	ra,ffffffffc02005ae <cons_getc>
ffffffffc0200200:	dd75                	beqz	a0,ffffffffc02001fc <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200202:	60a2                	ld	ra,8(sp)
ffffffffc0200204:	0141                	addi	sp,sp,16
ffffffffc0200206:	8082                	ret

ffffffffc0200208 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200208:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020020a:	00006517          	auipc	a0,0x6
ffffffffc020020e:	4de50513          	addi	a0,a0,1246 # ffffffffc02066e8 <etext+0x30>
void print_kerninfo(void) {
ffffffffc0200212:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200214:	f6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200218:	00000597          	auipc	a1,0x0
ffffffffc020021c:	e1a58593          	addi	a1,a1,-486 # ffffffffc0200032 <kern_init>
ffffffffc0200220:	00006517          	auipc	a0,0x6
ffffffffc0200224:	4e850513          	addi	a0,a0,1256 # ffffffffc0206708 <etext+0x50>
ffffffffc0200228:	f59ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020022c:	00006597          	auipc	a1,0x6
ffffffffc0200230:	48c58593          	addi	a1,a1,1164 # ffffffffc02066b8 <etext>
ffffffffc0200234:	00006517          	auipc	a0,0x6
ffffffffc0200238:	4f450513          	addi	a0,a0,1268 # ffffffffc0206728 <etext+0x70>
ffffffffc020023c:	f45ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200240:	000a7597          	auipc	a1,0xa7
ffffffffc0200244:	3f058593          	addi	a1,a1,1008 # ffffffffc02a7630 <buf>
ffffffffc0200248:	00006517          	auipc	a0,0x6
ffffffffc020024c:	50050513          	addi	a0,a0,1280 # ffffffffc0206748 <etext+0x90>
ffffffffc0200250:	f31ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200254:	000b3597          	auipc	a1,0xb3
ffffffffc0200258:	93858593          	addi	a1,a1,-1736 # ffffffffc02b2b8c <end>
ffffffffc020025c:	00006517          	auipc	a0,0x6
ffffffffc0200260:	50c50513          	addi	a0,a0,1292 # ffffffffc0206768 <etext+0xb0>
ffffffffc0200264:	f1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200268:	000b3597          	auipc	a1,0xb3
ffffffffc020026c:	d2358593          	addi	a1,a1,-733 # ffffffffc02b2f8b <end+0x3ff>
ffffffffc0200270:	00000797          	auipc	a5,0x0
ffffffffc0200274:	dc278793          	addi	a5,a5,-574 # ffffffffc0200032 <kern_init>
ffffffffc0200278:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020027c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200280:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200282:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200286:	95be                	add	a1,a1,a5
ffffffffc0200288:	85a9                	srai	a1,a1,0xa
ffffffffc020028a:	00006517          	auipc	a0,0x6
ffffffffc020028e:	4fe50513          	addi	a0,a0,1278 # ffffffffc0206788 <etext+0xd0>
}
ffffffffc0200292:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200294:	b5f5                	j	ffffffffc0200180 <cprintf>

ffffffffc0200296 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200296:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200298:	00006617          	auipc	a2,0x6
ffffffffc020029c:	52060613          	addi	a2,a2,1312 # ffffffffc02067b8 <etext+0x100>
ffffffffc02002a0:	04d00593          	li	a1,77
ffffffffc02002a4:	00006517          	auipc	a0,0x6
ffffffffc02002a8:	52c50513          	addi	a0,a0,1324 # ffffffffc02067d0 <etext+0x118>
void print_stackframe(void) {
ffffffffc02002ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ae:	1cc000ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02002b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002b4:	00006617          	auipc	a2,0x6
ffffffffc02002b8:	53460613          	addi	a2,a2,1332 # ffffffffc02067e8 <etext+0x130>
ffffffffc02002bc:	00006597          	auipc	a1,0x6
ffffffffc02002c0:	54c58593          	addi	a1,a1,1356 # ffffffffc0206808 <etext+0x150>
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	54c50513          	addi	a0,a0,1356 # ffffffffc0206810 <etext+0x158>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ce:	eb3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002d2:	00006617          	auipc	a2,0x6
ffffffffc02002d6:	54e60613          	addi	a2,a2,1358 # ffffffffc0206820 <etext+0x168>
ffffffffc02002da:	00006597          	auipc	a1,0x6
ffffffffc02002de:	56e58593          	addi	a1,a1,1390 # ffffffffc0206848 <etext+0x190>
ffffffffc02002e2:	00006517          	auipc	a0,0x6
ffffffffc02002e6:	52e50513          	addi	a0,a0,1326 # ffffffffc0206810 <etext+0x158>
ffffffffc02002ea:	e97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02002ee:	00006617          	auipc	a2,0x6
ffffffffc02002f2:	56a60613          	addi	a2,a2,1386 # ffffffffc0206858 <etext+0x1a0>
ffffffffc02002f6:	00006597          	auipc	a1,0x6
ffffffffc02002fa:	58258593          	addi	a1,a1,1410 # ffffffffc0206878 <etext+0x1c0>
ffffffffc02002fe:	00006517          	auipc	a0,0x6
ffffffffc0200302:	51250513          	addi	a0,a0,1298 # ffffffffc0206810 <etext+0x158>
ffffffffc0200306:	e7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    }
    return 0;
}
ffffffffc020030a:	60a2                	ld	ra,8(sp)
ffffffffc020030c:	4501                	li	a0,0
ffffffffc020030e:	0141                	addi	sp,sp,16
ffffffffc0200310:	8082                	ret

ffffffffc0200312 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200312:	1141                	addi	sp,sp,-16
ffffffffc0200314:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200316:	ef3ff0ef          	jal	ra,ffffffffc0200208 <print_kerninfo>
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200326:	f71ff0ef          	jal	ra,ffffffffc0200296 <print_stackframe>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200332:	7115                	addi	sp,sp,-224
ffffffffc0200334:	ed5e                	sd	s7,152(sp)
ffffffffc0200336:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200338:	00006517          	auipc	a0,0x6
ffffffffc020033c:	55050513          	addi	a0,a0,1360 # ffffffffc0206888 <etext+0x1d0>
kmonitor(struct trapframe *tf) {
ffffffffc0200340:	ed86                	sd	ra,216(sp)
ffffffffc0200342:	e9a2                	sd	s0,208(sp)
ffffffffc0200344:	e5a6                	sd	s1,200(sp)
ffffffffc0200346:	e1ca                	sd	s2,192(sp)
ffffffffc0200348:	fd4e                	sd	s3,184(sp)
ffffffffc020034a:	f952                	sd	s4,176(sp)
ffffffffc020034c:	f556                	sd	s5,168(sp)
ffffffffc020034e:	f15a                	sd	s6,160(sp)
ffffffffc0200350:	e962                	sd	s8,144(sp)
ffffffffc0200352:	e566                	sd	s9,136(sp)
ffffffffc0200354:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200356:	e2bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020035a:	00006517          	auipc	a0,0x6
ffffffffc020035e:	55650513          	addi	a0,a0,1366 # ffffffffc02068b0 <etext+0x1f8>
ffffffffc0200362:	e1fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    if (tf != NULL) {
ffffffffc0200366:	000b8563          	beqz	s7,ffffffffc0200370 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020036a:	855e                	mv	a0,s7
ffffffffc020036c:	4c8000ef          	jal	ra,ffffffffc0200834 <print_trapframe>
ffffffffc0200370:	00006c17          	auipc	s8,0x6
ffffffffc0200374:	5b0c0c13          	addi	s8,s8,1456 # ffffffffc0206920 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	00006917          	auipc	s2,0x6
ffffffffc020037c:	56090913          	addi	s2,s2,1376 # ffffffffc02068d8 <etext+0x220>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	00006497          	auipc	s1,0x6
ffffffffc0200384:	56048493          	addi	s1,s1,1376 # ffffffffc02068e0 <etext+0x228>
        if (argc == MAXARGS - 1) {
ffffffffc0200388:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038a:	00006b17          	auipc	s6,0x6
ffffffffc020038e:	55eb0b13          	addi	s6,s6,1374 # ffffffffc02068e8 <etext+0x230>
        argv[argc ++] = buf;
ffffffffc0200392:	00006a17          	auipc	s4,0x6
ffffffffc0200396:	476a0a13          	addi	s4,s4,1142 # ffffffffc0206808 <etext+0x150>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020039c:	854a                	mv	a0,s2
ffffffffc020039e:	cf5ff0ef          	jal	ra,ffffffffc0200092 <readline>
ffffffffc02003a2:	842a                	mv	s0,a0
ffffffffc02003a4:	dd65                	beqz	a0,ffffffffc020039c <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003aa:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ac:	e1bd                	bnez	a1,ffffffffc0200412 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02003ae:	fe0c87e3          	beqz	s9,ffffffffc020039c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003b2:	6582                	ld	a1,0(sp)
ffffffffc02003b4:	00006d17          	auipc	s10,0x6
ffffffffc02003b8:	56cd0d13          	addi	s10,s10,1388 # ffffffffc0206920 <commands>
        argv[argc ++] = buf;
ffffffffc02003bc:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003be:	4401                	li	s0,0
ffffffffc02003c0:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c2:	298060ef          	jal	ra,ffffffffc020665a <strcmp>
ffffffffc02003c6:	c919                	beqz	a0,ffffffffc02003dc <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003c8:	2405                	addiw	s0,s0,1
ffffffffc02003ca:	0b540063          	beq	s0,s5,ffffffffc020046a <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ce:	000d3503          	ld	a0,0(s10)
ffffffffc02003d2:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003d4:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d6:	284060ef          	jal	ra,ffffffffc020665a <strcmp>
ffffffffc02003da:	f57d                	bnez	a0,ffffffffc02003c8 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003dc:	00141793          	slli	a5,s0,0x1
ffffffffc02003e0:	97a2                	add	a5,a5,s0
ffffffffc02003e2:	078e                	slli	a5,a5,0x3
ffffffffc02003e4:	97e2                	add	a5,a5,s8
ffffffffc02003e6:	6b9c                	ld	a5,16(a5)
ffffffffc02003e8:	865e                	mv	a2,s7
ffffffffc02003ea:	002c                	addi	a1,sp,8
ffffffffc02003ec:	fffc851b          	addiw	a0,s9,-1
ffffffffc02003f0:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f2:	fa0555e3          	bgez	a0,ffffffffc020039c <kmonitor+0x6a>
}
ffffffffc02003f6:	60ee                	ld	ra,216(sp)
ffffffffc02003f8:	644e                	ld	s0,208(sp)
ffffffffc02003fa:	64ae                	ld	s1,200(sp)
ffffffffc02003fc:	690e                	ld	s2,192(sp)
ffffffffc02003fe:	79ea                	ld	s3,184(sp)
ffffffffc0200400:	7a4a                	ld	s4,176(sp)
ffffffffc0200402:	7aaa                	ld	s5,168(sp)
ffffffffc0200404:	7b0a                	ld	s6,160(sp)
ffffffffc0200406:	6bea                	ld	s7,152(sp)
ffffffffc0200408:	6c4a                	ld	s8,144(sp)
ffffffffc020040a:	6caa                	ld	s9,136(sp)
ffffffffc020040c:	6d0a                	ld	s10,128(sp)
ffffffffc020040e:	612d                	addi	sp,sp,224
ffffffffc0200410:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200412:	8526                	mv	a0,s1
ffffffffc0200414:	264060ef          	jal	ra,ffffffffc0206678 <strchr>
ffffffffc0200418:	c901                	beqz	a0,ffffffffc0200428 <kmonitor+0xf6>
ffffffffc020041a:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020041e:	00040023          	sb	zero,0(s0)
ffffffffc0200422:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200424:	d5c9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200426:	b7f5                	j	ffffffffc0200412 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200428:	00044783          	lbu	a5,0(s0)
ffffffffc020042c:	d3c9                	beqz	a5,ffffffffc02003ae <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020042e:	033c8963          	beq	s9,s3,ffffffffc0200460 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200432:	003c9793          	slli	a5,s9,0x3
ffffffffc0200436:	0118                	addi	a4,sp,128
ffffffffc0200438:	97ba                	add	a5,a5,a4
ffffffffc020043a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020043e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200442:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200444:	e591                	bnez	a1,ffffffffc0200450 <kmonitor+0x11e>
ffffffffc0200446:	b7b5                	j	ffffffffc02003b2 <kmonitor+0x80>
ffffffffc0200448:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020044c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044e:	d1a5                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc0200450:	8526                	mv	a0,s1
ffffffffc0200452:	226060ef          	jal	ra,ffffffffc0206678 <strchr>
ffffffffc0200456:	d96d                	beqz	a0,ffffffffc0200448 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200458:	00044583          	lbu	a1,0(s0)
ffffffffc020045c:	d9a9                	beqz	a1,ffffffffc02003ae <kmonitor+0x7c>
ffffffffc020045e:	bf55                	j	ffffffffc0200412 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200460:	45c1                	li	a1,16
ffffffffc0200462:	855a                	mv	a0,s6
ffffffffc0200464:	d1dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0200468:	b7e9                	j	ffffffffc0200432 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020046a:	6582                	ld	a1,0(sp)
ffffffffc020046c:	00006517          	auipc	a0,0x6
ffffffffc0200470:	49c50513          	addi	a0,a0,1180 # ffffffffc0206908 <etext+0x250>
ffffffffc0200474:	d0dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
ffffffffc0200478:	b715                	j	ffffffffc020039c <kmonitor+0x6a>

ffffffffc020047a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020047a:	000b2317          	auipc	t1,0xb2
ffffffffc020047e:	67e30313          	addi	t1,t1,1662 # ffffffffc02b2af8 <is_panic>
ffffffffc0200482:	00033e03          	ld	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200486:	715d                	addi	sp,sp,-80
ffffffffc0200488:	ec06                	sd	ra,24(sp)
ffffffffc020048a:	e822                	sd	s0,16(sp)
ffffffffc020048c:	f436                	sd	a3,40(sp)
ffffffffc020048e:	f83a                	sd	a4,48(sp)
ffffffffc0200490:	fc3e                	sd	a5,56(sp)
ffffffffc0200492:	e0c2                	sd	a6,64(sp)
ffffffffc0200494:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200496:	020e1a63          	bnez	t3,ffffffffc02004ca <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc020049a:	4785                	li	a5,1
ffffffffc020049c:	00f33023          	sd	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004a0:	8432                	mv	s0,a2
ffffffffc02004a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004a4:	862e                	mv	a2,a1
ffffffffc02004a6:	85aa                	mv	a1,a0
ffffffffc02004a8:	00006517          	auipc	a0,0x6
ffffffffc02004ac:	4c050513          	addi	a0,a0,1216 # ffffffffc0206968 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02004b0:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b2:	ccfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004b6:	65a2                	ld	a1,8(sp)
ffffffffc02004b8:	8522                	mv	a0,s0
ffffffffc02004ba:	ca7ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc02004be:	00007517          	auipc	a0,0x7
ffffffffc02004c2:	46250513          	addi	a0,a0,1122 # ffffffffc0207920 <default_pmm_manager+0x518>
ffffffffc02004c6:	cbbff0ef          	jal	ra,ffffffffc0200180 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004ca:	4501                	li	a0,0
ffffffffc02004cc:	4581                	li	a1,0
ffffffffc02004ce:	4601                	li	a2,0
ffffffffc02004d0:	48a1                	li	a7,8
ffffffffc02004d2:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004d6:	170000ef          	jal	ra,ffffffffc0200646 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004da:	4501                	li	a0,0
ffffffffc02004dc:	e57ff0ef          	jal	ra,ffffffffc0200332 <kmonitor>
    while (1) {
ffffffffc02004e0:	bfed                	j	ffffffffc02004da <__panic+0x60>

ffffffffc02004e2 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004e2:	715d                	addi	sp,sp,-80
ffffffffc02004e4:	832e                	mv	t1,a1
ffffffffc02004e6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004e8:	85aa                	mv	a1,a0
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ea:	8432                	mv	s0,a2
ffffffffc02004ec:	fc3e                	sd	a5,56(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ee:	861a                	mv	a2,t1
    va_start(ap, fmt);
ffffffffc02004f0:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f2:	00006517          	auipc	a0,0x6
ffffffffc02004f6:	49650513          	addi	a0,a0,1174 # ffffffffc0206988 <commands+0x68>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004fa:	ec06                	sd	ra,24(sp)
ffffffffc02004fc:	f436                	sd	a3,40(sp)
ffffffffc02004fe:	f83a                	sd	a4,48(sp)
ffffffffc0200500:	e0c2                	sd	a6,64(sp)
ffffffffc0200502:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200504:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200506:	c7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    vcprintf(fmt, ap);
ffffffffc020050a:	65a2                	ld	a1,8(sp)
ffffffffc020050c:	8522                	mv	a0,s0
ffffffffc020050e:	c53ff0ef          	jal	ra,ffffffffc0200160 <vcprintf>
    cprintf("\n");
ffffffffc0200512:	00007517          	auipc	a0,0x7
ffffffffc0200516:	40e50513          	addi	a0,a0,1038 # ffffffffc0207920 <default_pmm_manager+0x518>
ffffffffc020051a:	c67ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    va_end(ap);
}
ffffffffc020051e:	60e2                	ld	ra,24(sp)
ffffffffc0200520:	6442                	ld	s0,16(sp)
ffffffffc0200522:	6161                	addi	sp,sp,80
ffffffffc0200524:	8082                	ret

ffffffffc0200526 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200526:	67e1                	lui	a5,0x18
ffffffffc0200528:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xd548>
ffffffffc020052c:	000b2717          	auipc	a4,0xb2
ffffffffc0200530:	5cf73e23          	sd	a5,1500(a4) # ffffffffc02b2b08 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200534:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200538:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020053a:	953e                	add	a0,a0,a5
ffffffffc020053c:	4601                	li	a2,0
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200544:	02000793          	li	a5,32
ffffffffc0200548:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020054c:	00006517          	auipc	a0,0x6
ffffffffc0200550:	45c50513          	addi	a0,a0,1116 # ffffffffc02069a8 <commands+0x88>
    ticks = 0;
ffffffffc0200554:	000b2797          	auipc	a5,0xb2
ffffffffc0200558:	5a07b623          	sd	zero,1452(a5) # ffffffffc02b2b00 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020055c:	b115                	j	ffffffffc0200180 <cprintf>

ffffffffc020055e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020055e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200562:	000b2797          	auipc	a5,0xb2
ffffffffc0200566:	5a67b783          	ld	a5,1446(a5) # ffffffffc02b2b08 <timebase>
ffffffffc020056a:	953e                	add	a0,a0,a5
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4881                	li	a7,0
ffffffffc0200572:	00000073          	ecall
ffffffffc0200576:	8082                	ret

ffffffffc0200578 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200578:	8082                	ret

ffffffffc020057a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020057a:	100027f3          	csrr	a5,sstatus
ffffffffc020057e:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200580:	0ff57513          	zext.b	a0,a0
ffffffffc0200584:	e799                	bnez	a5,ffffffffc0200592 <cons_putc+0x18>
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4885                	li	a7,1
ffffffffc020058c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200590:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200592:	1101                	addi	sp,sp,-32
ffffffffc0200594:	ec06                	sd	ra,24(sp)
ffffffffc0200596:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200598:	0ae000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020059c:	6522                	ld	a0,8(sp)
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4885                	li	a7,1
ffffffffc02005a4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005a8:	60e2                	ld	ra,24(sp)
ffffffffc02005aa:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005ac:	a851                	j	ffffffffc0200640 <intr_enable>

ffffffffc02005ae <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005ae:	100027f3          	csrr	a5,sstatus
ffffffffc02005b2:	8b89                	andi	a5,a5,2
ffffffffc02005b4:	eb89                	bnez	a5,ffffffffc02005c6 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005b6:	4501                	li	a0,0
ffffffffc02005b8:	4581                	li	a1,0
ffffffffc02005ba:	4601                	li	a2,0
ffffffffc02005bc:	4889                	li	a7,2
ffffffffc02005be:	00000073          	ecall
ffffffffc02005c2:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005c4:	8082                	ret
int cons_getc(void) {
ffffffffc02005c6:	1101                	addi	sp,sp,-32
ffffffffc02005c8:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005ca:	07c000ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc02005ce:	4501                	li	a0,0
ffffffffc02005d0:	4581                	li	a1,0
ffffffffc02005d2:	4601                	li	a2,0
ffffffffc02005d4:	4889                	li	a7,2
ffffffffc02005d6:	00000073          	ecall
ffffffffc02005da:	2501                	sext.w	a0,a0
ffffffffc02005dc:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005de:	062000ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc02005e2:	60e2                	ld	ra,24(sp)
ffffffffc02005e4:	6522                	ld	a0,8(sp)
ffffffffc02005e6:	6105                	addi	sp,sp,32
ffffffffc02005e8:	8082                	ret

ffffffffc02005ea <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005ea:	8082                	ret

ffffffffc02005ec <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005ec:	00253513          	sltiu	a0,a0,2
ffffffffc02005f0:	8082                	ret

ffffffffc02005f2 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005f2:	03800513          	li	a0,56
ffffffffc02005f6:	8082                	ret

ffffffffc02005f8 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02005f8:	000a7797          	auipc	a5,0xa7
ffffffffc02005fc:	43878793          	addi	a5,a5,1080 # ffffffffc02a7a30 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc0200600:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200604:	1141                	addi	sp,sp,-16
ffffffffc0200606:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200608:	95be                	add	a1,a1,a5
ffffffffc020060a:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc020060e:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200610:	090060ef          	jal	ra,ffffffffc02066a0 <memcpy>
    return 0;
}
ffffffffc0200614:	60a2                	ld	ra,8(sp)
ffffffffc0200616:	4501                	li	a0,0
ffffffffc0200618:	0141                	addi	sp,sp,16
ffffffffc020061a:	8082                	ret

ffffffffc020061c <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
ffffffffc020061c:	0095979b          	slliw	a5,a1,0x9
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200620:	000a7517          	auipc	a0,0xa7
ffffffffc0200624:	41050513          	addi	a0,a0,1040 # ffffffffc02a7a30 <ide>
                   size_t nsecs) {
ffffffffc0200628:	1141                	addi	sp,sp,-16
ffffffffc020062a:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020062c:	953e                	add	a0,a0,a5
ffffffffc020062e:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc0200632:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200634:	06c060ef          	jal	ra,ffffffffc02066a0 <memcpy>
    return 0;
}
ffffffffc0200638:	60a2                	ld	ra,8(sp)
ffffffffc020063a:	4501                	li	a0,0
ffffffffc020063c:	0141                	addi	sp,sp,16
ffffffffc020063e:	8082                	ret

ffffffffc0200640 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200640:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200644:	8082                	ret

ffffffffc0200646 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200646:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020064a:	8082                	ret

ffffffffc020064c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020064c:	8082                	ret

ffffffffc020064e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020064e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200652:	00000797          	auipc	a5,0x0
ffffffffc0200656:	65a78793          	addi	a5,a5,1626 # ffffffffc0200cac <__alltraps>
ffffffffc020065a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020065e:	000407b7          	lui	a5,0x40
ffffffffc0200662:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200666:	8082                	ret

ffffffffc0200668 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200668:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020066a:	1141                	addi	sp,sp,-16
ffffffffc020066c:	e022                	sd	s0,0(sp)
ffffffffc020066e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	35850513          	addi	a0,a0,856 # ffffffffc02069c8 <commands+0xa8>
void print_regs(struct pushregs* gpr) {
ffffffffc0200678:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067a:	b07ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020067e:	640c                	ld	a1,8(s0)
ffffffffc0200680:	00006517          	auipc	a0,0x6
ffffffffc0200684:	36050513          	addi	a0,a0,864 # ffffffffc02069e0 <commands+0xc0>
ffffffffc0200688:	af9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020068c:	680c                	ld	a1,16(s0)
ffffffffc020068e:	00006517          	auipc	a0,0x6
ffffffffc0200692:	36a50513          	addi	a0,a0,874 # ffffffffc02069f8 <commands+0xd8>
ffffffffc0200696:	aebff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020069a:	6c0c                	ld	a1,24(s0)
ffffffffc020069c:	00006517          	auipc	a0,0x6
ffffffffc02006a0:	37450513          	addi	a0,a0,884 # ffffffffc0206a10 <commands+0xf0>
ffffffffc02006a4:	addff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006a8:	700c                	ld	a1,32(s0)
ffffffffc02006aa:	00006517          	auipc	a0,0x6
ffffffffc02006ae:	37e50513          	addi	a0,a0,894 # ffffffffc0206a28 <commands+0x108>
ffffffffc02006b2:	acfff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006b6:	740c                	ld	a1,40(s0)
ffffffffc02006b8:	00006517          	auipc	a0,0x6
ffffffffc02006bc:	38850513          	addi	a0,a0,904 # ffffffffc0206a40 <commands+0x120>
ffffffffc02006c0:	ac1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006c4:	780c                	ld	a1,48(s0)
ffffffffc02006c6:	00006517          	auipc	a0,0x6
ffffffffc02006ca:	39250513          	addi	a0,a0,914 # ffffffffc0206a58 <commands+0x138>
ffffffffc02006ce:	ab3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006d2:	7c0c                	ld	a1,56(s0)
ffffffffc02006d4:	00006517          	auipc	a0,0x6
ffffffffc02006d8:	39c50513          	addi	a0,a0,924 # ffffffffc0206a70 <commands+0x150>
ffffffffc02006dc:	aa5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006e0:	602c                	ld	a1,64(s0)
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	3a650513          	addi	a0,a0,934 # ffffffffc0206a88 <commands+0x168>
ffffffffc02006ea:	a97ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ee:	642c                	ld	a1,72(s0)
ffffffffc02006f0:	00006517          	auipc	a0,0x6
ffffffffc02006f4:	3b050513          	addi	a0,a0,944 # ffffffffc0206aa0 <commands+0x180>
ffffffffc02006f8:	a89ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006fc:	682c                	ld	a1,80(s0)
ffffffffc02006fe:	00006517          	auipc	a0,0x6
ffffffffc0200702:	3ba50513          	addi	a0,a0,954 # ffffffffc0206ab8 <commands+0x198>
ffffffffc0200706:	a7bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020070a:	6c2c                	ld	a1,88(s0)
ffffffffc020070c:	00006517          	auipc	a0,0x6
ffffffffc0200710:	3c450513          	addi	a0,a0,964 # ffffffffc0206ad0 <commands+0x1b0>
ffffffffc0200714:	a6dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200718:	702c                	ld	a1,96(s0)
ffffffffc020071a:	00006517          	auipc	a0,0x6
ffffffffc020071e:	3ce50513          	addi	a0,a0,974 # ffffffffc0206ae8 <commands+0x1c8>
ffffffffc0200722:	a5fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200726:	742c                	ld	a1,104(s0)
ffffffffc0200728:	00006517          	auipc	a0,0x6
ffffffffc020072c:	3d850513          	addi	a0,a0,984 # ffffffffc0206b00 <commands+0x1e0>
ffffffffc0200730:	a51ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200734:	782c                	ld	a1,112(s0)
ffffffffc0200736:	00006517          	auipc	a0,0x6
ffffffffc020073a:	3e250513          	addi	a0,a0,994 # ffffffffc0206b18 <commands+0x1f8>
ffffffffc020073e:	a43ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200742:	7c2c                	ld	a1,120(s0)
ffffffffc0200744:	00006517          	auipc	a0,0x6
ffffffffc0200748:	3ec50513          	addi	a0,a0,1004 # ffffffffc0206b30 <commands+0x210>
ffffffffc020074c:	a35ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200750:	604c                	ld	a1,128(s0)
ffffffffc0200752:	00006517          	auipc	a0,0x6
ffffffffc0200756:	3f650513          	addi	a0,a0,1014 # ffffffffc0206b48 <commands+0x228>
ffffffffc020075a:	a27ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020075e:	644c                	ld	a1,136(s0)
ffffffffc0200760:	00006517          	auipc	a0,0x6
ffffffffc0200764:	40050513          	addi	a0,a0,1024 # ffffffffc0206b60 <commands+0x240>
ffffffffc0200768:	a19ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020076c:	684c                	ld	a1,144(s0)
ffffffffc020076e:	00006517          	auipc	a0,0x6
ffffffffc0200772:	40a50513          	addi	a0,a0,1034 # ffffffffc0206b78 <commands+0x258>
ffffffffc0200776:	a0bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020077a:	6c4c                	ld	a1,152(s0)
ffffffffc020077c:	00006517          	auipc	a0,0x6
ffffffffc0200780:	41450513          	addi	a0,a0,1044 # ffffffffc0206b90 <commands+0x270>
ffffffffc0200784:	9fdff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200788:	704c                	ld	a1,160(s0)
ffffffffc020078a:	00006517          	auipc	a0,0x6
ffffffffc020078e:	41e50513          	addi	a0,a0,1054 # ffffffffc0206ba8 <commands+0x288>
ffffffffc0200792:	9efff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200796:	744c                	ld	a1,168(s0)
ffffffffc0200798:	00006517          	auipc	a0,0x6
ffffffffc020079c:	42850513          	addi	a0,a0,1064 # ffffffffc0206bc0 <commands+0x2a0>
ffffffffc02007a0:	9e1ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007a4:	784c                	ld	a1,176(s0)
ffffffffc02007a6:	00006517          	auipc	a0,0x6
ffffffffc02007aa:	43250513          	addi	a0,a0,1074 # ffffffffc0206bd8 <commands+0x2b8>
ffffffffc02007ae:	9d3ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007b2:	7c4c                	ld	a1,184(s0)
ffffffffc02007b4:	00006517          	auipc	a0,0x6
ffffffffc02007b8:	43c50513          	addi	a0,a0,1084 # ffffffffc0206bf0 <commands+0x2d0>
ffffffffc02007bc:	9c5ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007c0:	606c                	ld	a1,192(s0)
ffffffffc02007c2:	00006517          	auipc	a0,0x6
ffffffffc02007c6:	44650513          	addi	a0,a0,1094 # ffffffffc0206c08 <commands+0x2e8>
ffffffffc02007ca:	9b7ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ce:	646c                	ld	a1,200(s0)
ffffffffc02007d0:	00006517          	auipc	a0,0x6
ffffffffc02007d4:	45050513          	addi	a0,a0,1104 # ffffffffc0206c20 <commands+0x300>
ffffffffc02007d8:	9a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007dc:	686c                	ld	a1,208(s0)
ffffffffc02007de:	00006517          	auipc	a0,0x6
ffffffffc02007e2:	45a50513          	addi	a0,a0,1114 # ffffffffc0206c38 <commands+0x318>
ffffffffc02007e6:	99bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ea:	6c6c                	ld	a1,216(s0)
ffffffffc02007ec:	00006517          	auipc	a0,0x6
ffffffffc02007f0:	46450513          	addi	a0,a0,1124 # ffffffffc0206c50 <commands+0x330>
ffffffffc02007f4:	98dff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007f8:	706c                	ld	a1,224(s0)
ffffffffc02007fa:	00006517          	auipc	a0,0x6
ffffffffc02007fe:	46e50513          	addi	a0,a0,1134 # ffffffffc0206c68 <commands+0x348>
ffffffffc0200802:	97fff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200806:	746c                	ld	a1,232(s0)
ffffffffc0200808:	00006517          	auipc	a0,0x6
ffffffffc020080c:	47850513          	addi	a0,a0,1144 # ffffffffc0206c80 <commands+0x360>
ffffffffc0200810:	971ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200814:	786c                	ld	a1,240(s0)
ffffffffc0200816:	00006517          	auipc	a0,0x6
ffffffffc020081a:	48250513          	addi	a0,a0,1154 # ffffffffc0206c98 <commands+0x378>
ffffffffc020081e:	963ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200824:	6402                	ld	s0,0(sp)
ffffffffc0200826:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200828:	00006517          	auipc	a0,0x6
ffffffffc020082c:	48850513          	addi	a0,a0,1160 # ffffffffc0206cb0 <commands+0x390>
}
ffffffffc0200830:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200832:	b2b9                	j	ffffffffc0200180 <cprintf>

ffffffffc0200834 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200834:	1141                	addi	sp,sp,-16
ffffffffc0200836:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020083a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	48c50513          	addi	a0,a0,1164 # ffffffffc0206cc8 <commands+0x3a8>
print_trapframe(struct trapframe *tf) {
ffffffffc0200844:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200846:	93bff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    print_regs(&tf->gpr);
ffffffffc020084a:	8522                	mv	a0,s0
ffffffffc020084c:	e1dff0ef          	jal	ra,ffffffffc0200668 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200850:	10043583          	ld	a1,256(s0)
ffffffffc0200854:	00006517          	auipc	a0,0x6
ffffffffc0200858:	48c50513          	addi	a0,a0,1164 # ffffffffc0206ce0 <commands+0x3c0>
ffffffffc020085c:	925ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200860:	10843583          	ld	a1,264(s0)
ffffffffc0200864:	00006517          	auipc	a0,0x6
ffffffffc0200868:	49450513          	addi	a0,a0,1172 # ffffffffc0206cf8 <commands+0x3d8>
ffffffffc020086c:	915ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200870:	11043583          	ld	a1,272(s0)
ffffffffc0200874:	00006517          	auipc	a0,0x6
ffffffffc0200878:	49c50513          	addi	a0,a0,1180 # ffffffffc0206d10 <commands+0x3f0>
ffffffffc020087c:	905ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200880:	11843583          	ld	a1,280(s0)
}
ffffffffc0200884:	6402                	ld	s0,0(sp)
ffffffffc0200886:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200888:	00006517          	auipc	a0,0x6
ffffffffc020088c:	49850513          	addi	a0,a0,1176 # ffffffffc0206d20 <commands+0x400>
}
ffffffffc0200890:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200892:	8efff06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0200896 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200896:	1101                	addi	sp,sp,-32
ffffffffc0200898:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089a:	000b2497          	auipc	s1,0xb2
ffffffffc020089e:	2c648493          	addi	s1,s1,710 # ffffffffc02b2b60 <check_mm_struct>
ffffffffc02008a2:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a4:	e822                	sd	s0,16(sp)
ffffffffc02008a6:	ec06                	sd	ra,24(sp)
ffffffffc02008a8:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008aa:	cbad                	beqz	a5,ffffffffc020091c <pgfault_handler+0x86>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ac:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008b0:	11053583          	ld	a1,272(a0)
ffffffffc02008b4:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	c7b1                	beqz	a5,ffffffffc0200908 <pgfault_handler+0x72>
ffffffffc02008be:	11843703          	ld	a4,280(s0)
ffffffffc02008c2:	47bd                	li	a5,15
ffffffffc02008c4:	05700693          	li	a3,87
ffffffffc02008c8:	00f70463          	beq	a4,a5,ffffffffc02008d0 <pgfault_handler+0x3a>
ffffffffc02008cc:	05200693          	li	a3,82
ffffffffc02008d0:	00006517          	auipc	a0,0x6
ffffffffc02008d4:	46850513          	addi	a0,a0,1128 # ffffffffc0206d38 <commands+0x418>
ffffffffc02008d8:	8a9ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008dc:	6088                	ld	a0,0(s1)
ffffffffc02008de:	cd1d                	beqz	a0,ffffffffc020091c <pgfault_handler+0x86>
        assert(current == idleproc);
ffffffffc02008e0:	000b2717          	auipc	a4,0xb2
ffffffffc02008e4:	29073703          	ld	a4,656(a4) # ffffffffc02b2b70 <current>
ffffffffc02008e8:	000b2797          	auipc	a5,0xb2
ffffffffc02008ec:	2907b783          	ld	a5,656(a5) # ffffffffc02b2b78 <idleproc>
ffffffffc02008f0:	04f71663          	bne	a4,a5,ffffffffc020093c <pgfault_handler+0xa6>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008f4:	11043603          	ld	a2,272(s0)
ffffffffc02008f8:	11843583          	ld	a1,280(s0)
}
ffffffffc02008fc:	6442                	ld	s0,16(sp)
ffffffffc02008fe:	60e2                	ld	ra,24(sp)
ffffffffc0200900:	64a2                	ld	s1,8(sp)
ffffffffc0200902:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	1320406f          	j	ffffffffc0204a36 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200908:	11843703          	ld	a4,280(s0)
ffffffffc020090c:	47bd                	li	a5,15
ffffffffc020090e:	05500613          	li	a2,85
ffffffffc0200912:	05700693          	li	a3,87
ffffffffc0200916:	faf71be3          	bne	a4,a5,ffffffffc02008cc <pgfault_handler+0x36>
ffffffffc020091a:	bf5d                	j	ffffffffc02008d0 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020091c:	000b2797          	auipc	a5,0xb2
ffffffffc0200920:	2547b783          	ld	a5,596(a5) # ffffffffc02b2b70 <current>
ffffffffc0200924:	cf85                	beqz	a5,ffffffffc020095c <pgfault_handler+0xc6>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200926:	11043603          	ld	a2,272(s0)
ffffffffc020092a:	11843583          	ld	a1,280(s0)
}
ffffffffc020092e:	6442                	ld	s0,16(sp)
ffffffffc0200930:	60e2                	ld	ra,24(sp)
ffffffffc0200932:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200934:	7788                	ld	a0,40(a5)
}
ffffffffc0200936:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	0fe0406f          	j	ffffffffc0204a36 <do_pgfault>
        assert(current == idleproc);
ffffffffc020093c:	00006697          	auipc	a3,0x6
ffffffffc0200940:	41c68693          	addi	a3,a3,1052 # ffffffffc0206d58 <commands+0x438>
ffffffffc0200944:	00006617          	auipc	a2,0x6
ffffffffc0200948:	42c60613          	addi	a2,a2,1068 # ffffffffc0206d70 <commands+0x450>
ffffffffc020094c:	06b00593          	li	a1,107
ffffffffc0200950:	00006517          	auipc	a0,0x6
ffffffffc0200954:	43850513          	addi	a0,a0,1080 # ffffffffc0206d88 <commands+0x468>
ffffffffc0200958:	b23ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc020095c:	8522                	mv	a0,s0
ffffffffc020095e:	ed7ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200962:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200966:	11043583          	ld	a1,272(s0)
ffffffffc020096a:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020096e:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200972:	e399                	bnez	a5,ffffffffc0200978 <pgfault_handler+0xe2>
ffffffffc0200974:	05500613          	li	a2,85
ffffffffc0200978:	11843703          	ld	a4,280(s0)
ffffffffc020097c:	47bd                	li	a5,15
ffffffffc020097e:	02f70663          	beq	a4,a5,ffffffffc02009aa <pgfault_handler+0x114>
ffffffffc0200982:	05200693          	li	a3,82
ffffffffc0200986:	00006517          	auipc	a0,0x6
ffffffffc020098a:	3b250513          	addi	a0,a0,946 # ffffffffc0206d38 <commands+0x418>
ffffffffc020098e:	ff2ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc0200992:	00006617          	auipc	a2,0x6
ffffffffc0200996:	40e60613          	addi	a2,a2,1038 # ffffffffc0206da0 <commands+0x480>
ffffffffc020099a:	07200593          	li	a1,114
ffffffffc020099e:	00006517          	auipc	a0,0x6
ffffffffc02009a2:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206d88 <commands+0x468>
ffffffffc02009a6:	ad5ff0ef          	jal	ra,ffffffffc020047a <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009aa:	05700693          	li	a3,87
ffffffffc02009ae:	bfe1                	j	ffffffffc0200986 <pgfault_handler+0xf0>

ffffffffc02009b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009b0:	11853783          	ld	a5,280(a0)
ffffffffc02009b4:	472d                	li	a4,11
ffffffffc02009b6:	0786                	slli	a5,a5,0x1
ffffffffc02009b8:	8385                	srli	a5,a5,0x1
ffffffffc02009ba:	08f76363          	bltu	a4,a5,ffffffffc0200a40 <interrupt_handler+0x90>
ffffffffc02009be:	00006717          	auipc	a4,0x6
ffffffffc02009c2:	49a70713          	addi	a4,a4,1178 # ffffffffc0206e58 <commands+0x538>
ffffffffc02009c6:	078a                	slli	a5,a5,0x2
ffffffffc02009c8:	97ba                	add	a5,a5,a4
ffffffffc02009ca:	439c                	lw	a5,0(a5)
ffffffffc02009cc:	97ba                	add	a5,a5,a4
ffffffffc02009ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009d0:	00006517          	auipc	a0,0x6
ffffffffc02009d4:	44850513          	addi	a0,a0,1096 # ffffffffc0206e18 <commands+0x4f8>
ffffffffc02009d8:	fa8ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009dc:	00006517          	auipc	a0,0x6
ffffffffc02009e0:	41c50513          	addi	a0,a0,1052 # ffffffffc0206df8 <commands+0x4d8>
ffffffffc02009e4:	f9cff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e8:	00006517          	auipc	a0,0x6
ffffffffc02009ec:	3d050513          	addi	a0,a0,976 # ffffffffc0206db8 <commands+0x498>
ffffffffc02009f0:	f90ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009f4:	00006517          	auipc	a0,0x6
ffffffffc02009f8:	3e450513          	addi	a0,a0,996 # ffffffffc0206dd8 <commands+0x4b8>
ffffffffc02009fc:	f84ff06f          	j	ffffffffc0200180 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a00:	1141                	addi	sp,sp,-16
ffffffffc0200a02:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200a04:	b5bff0ef          	jal	ra,ffffffffc020055e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a08:	000b2697          	auipc	a3,0xb2
ffffffffc0200a0c:	0f868693          	addi	a3,a3,248 # ffffffffc02b2b00 <ticks>
ffffffffc0200a10:	629c                	ld	a5,0(a3)
ffffffffc0200a12:	06400713          	li	a4,100
ffffffffc0200a16:	0785                	addi	a5,a5,1
ffffffffc0200a18:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a1c:	e29c                	sd	a5,0(a3)
ffffffffc0200a1e:	eb01                	bnez	a4,ffffffffc0200a2e <interrupt_handler+0x7e>
ffffffffc0200a20:	000b2797          	auipc	a5,0xb2
ffffffffc0200a24:	1507b783          	ld	a5,336(a5) # ffffffffc02b2b70 <current>
ffffffffc0200a28:	c399                	beqz	a5,ffffffffc0200a2e <interrupt_handler+0x7e>
                // print_ticks();
                current->need_resched = 1;
ffffffffc0200a2a:	4705                	li	a4,1
ffffffffc0200a2c:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a2e:	60a2                	ld	ra,8(sp)
ffffffffc0200a30:	0141                	addi	sp,sp,16
ffffffffc0200a32:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a34:	00006517          	auipc	a0,0x6
ffffffffc0200a38:	40450513          	addi	a0,a0,1028 # ffffffffc0206e38 <commands+0x518>
ffffffffc0200a3c:	f44ff06f          	j	ffffffffc0200180 <cprintf>
            print_trapframe(tf);
ffffffffc0200a40:	bbd5                	j	ffffffffc0200834 <print_trapframe>

ffffffffc0200a42 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a42:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a46:	1101                	addi	sp,sp,-32
ffffffffc0200a48:	e822                	sd	s0,16(sp)
ffffffffc0200a4a:	ec06                	sd	ra,24(sp)
ffffffffc0200a4c:	e426                	sd	s1,8(sp)
ffffffffc0200a4e:	473d                	li	a4,15
ffffffffc0200a50:	842a                	mv	s0,a0
ffffffffc0200a52:	18f76563          	bltu	a4,a5,ffffffffc0200bdc <exception_handler+0x19a>
ffffffffc0200a56:	00006717          	auipc	a4,0x6
ffffffffc0200a5a:	5ca70713          	addi	a4,a4,1482 # ffffffffc0207020 <commands+0x700>
ffffffffc0200a5e:	078a                	slli	a5,a5,0x2
ffffffffc0200a60:	97ba                	add	a5,a5,a4
ffffffffc0200a62:	439c                	lw	a5,0(a5)
ffffffffc0200a64:	97ba                	add	a5,a5,a4
ffffffffc0200a66:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a68:	00006517          	auipc	a0,0x6
ffffffffc0200a6c:	51050513          	addi	a0,a0,1296 # ffffffffc0206f78 <commands+0x658>
ffffffffc0200a70:	f10ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            tf->epc += 4;
ffffffffc0200a74:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a78:	60e2                	ld	ra,24(sp)
ffffffffc0200a7a:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a7c:	0791                	addi	a5,a5,4
ffffffffc0200a7e:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a82:	6442                	ld	s0,16(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a86:	7080506f          	j	ffffffffc020618e <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8a:	00006517          	auipc	a0,0x6
ffffffffc0200a8e:	50e50513          	addi	a0,a0,1294 # ffffffffc0206f98 <commands+0x678>
}
ffffffffc0200a92:	6442                	ld	s0,16(sp)
ffffffffc0200a94:	60e2                	ld	ra,24(sp)
ffffffffc0200a96:	64a2                	ld	s1,8(sp)
ffffffffc0200a98:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9a:	ee6ff06f          	j	ffffffffc0200180 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a9e:	00006517          	auipc	a0,0x6
ffffffffc0200aa2:	51a50513          	addi	a0,a0,1306 # ffffffffc0206fb8 <commands+0x698>
ffffffffc0200aa6:	b7f5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aa8:	00006517          	auipc	a0,0x6
ffffffffc0200aac:	53050513          	addi	a0,a0,1328 # ffffffffc0206fd8 <commands+0x6b8>
ffffffffc0200ab0:	b7cd                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	53e50513          	addi	a0,a0,1342 # ffffffffc0206ff0 <commands+0x6d0>
ffffffffc0200aba:	ec6ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200abe:	8522                	mv	a0,s0
ffffffffc0200ac0:	dd7ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ac4:	84aa                	mv	s1,a0
ffffffffc0200ac6:	12051d63          	bnez	a0,ffffffffc0200c00 <exception_handler+0x1be>
}
ffffffffc0200aca:	60e2                	ld	ra,24(sp)
ffffffffc0200acc:	6442                	ld	s0,16(sp)
ffffffffc0200ace:	64a2                	ld	s1,8(sp)
ffffffffc0200ad0:	6105                	addi	sp,sp,32
ffffffffc0200ad2:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad4:	00006517          	auipc	a0,0x6
ffffffffc0200ad8:	53450513          	addi	a0,a0,1332 # ffffffffc0207008 <commands+0x6e8>
ffffffffc0200adc:	ea4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae0:	8522                	mv	a0,s0
ffffffffc0200ae2:	db5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200ae6:	84aa                	mv	s1,a0
ffffffffc0200ae8:	d16d                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aea:	8522                	mv	a0,s0
ffffffffc0200aec:	d49ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af0:	86a6                	mv	a3,s1
ffffffffc0200af2:	00006617          	auipc	a2,0x6
ffffffffc0200af6:	43660613          	addi	a2,a2,1078 # ffffffffc0206f28 <commands+0x608>
ffffffffc0200afa:	0f800593          	li	a1,248
ffffffffc0200afe:	00006517          	auipc	a0,0x6
ffffffffc0200b02:	28a50513          	addi	a0,a0,650 # ffffffffc0206d88 <commands+0x468>
ffffffffc0200b06:	975ff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0a:	00006517          	auipc	a0,0x6
ffffffffc0200b0e:	37e50513          	addi	a0,a0,894 # ffffffffc0206e88 <commands+0x568>
ffffffffc0200b12:	b741                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b14:	00006517          	auipc	a0,0x6
ffffffffc0200b18:	39450513          	addi	a0,a0,916 # ffffffffc0206ea8 <commands+0x588>
ffffffffc0200b1c:	bf9d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	3aa50513          	addi	a0,a0,938 # ffffffffc0206ec8 <commands+0x5a8>
ffffffffc0200b26:	b7b5                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b28:	00006517          	auipc	a0,0x6
ffffffffc0200b2c:	3b850513          	addi	a0,a0,952 # ffffffffc0206ee0 <commands+0x5c0>
ffffffffc0200b30:	e50ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b34:	6458                	ld	a4,136(s0)
ffffffffc0200b36:	47a9                	li	a5,10
ffffffffc0200b38:	f8f719e3          	bne	a4,a5,ffffffffc0200aca <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b3c:	10843783          	ld	a5,264(s0)
ffffffffc0200b40:	0791                	addi	a5,a5,4
ffffffffc0200b42:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b46:	648050ef          	jal	ra,ffffffffc020618e <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4a:	000b2797          	auipc	a5,0xb2
ffffffffc0200b4e:	0267b783          	ld	a5,38(a5) # ffffffffc02b2b70 <current>
ffffffffc0200b52:	6b9c                	ld	a5,16(a5)
ffffffffc0200b54:	8522                	mv	a0,s0
}
ffffffffc0200b56:	6442                	ld	s0,16(sp)
ffffffffc0200b58:	60e2                	ld	ra,24(sp)
ffffffffc0200b5a:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6589                	lui	a1,0x2
ffffffffc0200b5e:	95be                	add	a1,a1,a5
}
ffffffffc0200b60:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b62:	ac21                	j	ffffffffc0200d7a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b64:	00006517          	auipc	a0,0x6
ffffffffc0200b68:	38c50513          	addi	a0,a0,908 # ffffffffc0206ef0 <commands+0x5d0>
ffffffffc0200b6c:	b71d                	j	ffffffffc0200a92 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b6e:	00006517          	auipc	a0,0x6
ffffffffc0200b72:	3a250513          	addi	a0,a0,930 # ffffffffc0206f10 <commands+0x5f0>
ffffffffc0200b76:	e0aff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b7a:	8522                	mv	a0,s0
ffffffffc0200b7c:	d1bff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200b80:	84aa                	mv	s1,a0
ffffffffc0200b82:	d521                	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b84:	8522                	mv	a0,s0
ffffffffc0200b86:	cafff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b8a:	86a6                	mv	a3,s1
ffffffffc0200b8c:	00006617          	auipc	a2,0x6
ffffffffc0200b90:	39c60613          	addi	a2,a2,924 # ffffffffc0206f28 <commands+0x608>
ffffffffc0200b94:	0cd00593          	li	a1,205
ffffffffc0200b98:	00006517          	auipc	a0,0x6
ffffffffc0200b9c:	1f050513          	addi	a0,a0,496 # ffffffffc0206d88 <commands+0x468>
ffffffffc0200ba0:	8dbff0ef          	jal	ra,ffffffffc020047a <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200ba4:	00006517          	auipc	a0,0x6
ffffffffc0200ba8:	3bc50513          	addi	a0,a0,956 # ffffffffc0206f60 <commands+0x640>
ffffffffc0200bac:	dd4ff0ef          	jal	ra,ffffffffc0200180 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	ce5ff0ef          	jal	ra,ffffffffc0200896 <pgfault_handler>
ffffffffc0200bb6:	84aa                	mv	s1,a0
ffffffffc0200bb8:	f00509e3          	beqz	a0,ffffffffc0200aca <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bbc:	8522                	mv	a0,s0
ffffffffc0200bbe:	c77ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bc2:	86a6                	mv	a3,s1
ffffffffc0200bc4:	00006617          	auipc	a2,0x6
ffffffffc0200bc8:	36460613          	addi	a2,a2,868 # ffffffffc0206f28 <commands+0x608>
ffffffffc0200bcc:	0d700593          	li	a1,215
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	1b850513          	addi	a0,a0,440 # ffffffffc0206d88 <commands+0x468>
ffffffffc0200bd8:	8a3ff0ef          	jal	ra,ffffffffc020047a <__panic>
            print_trapframe(tf);
ffffffffc0200bdc:	8522                	mv	a0,s0
}
ffffffffc0200bde:	6442                	ld	s0,16(sp)
ffffffffc0200be0:	60e2                	ld	ra,24(sp)
ffffffffc0200be2:	64a2                	ld	s1,8(sp)
ffffffffc0200be4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200be6:	b1b9                	j	ffffffffc0200834 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200be8:	00006617          	auipc	a2,0x6
ffffffffc0200bec:	36060613          	addi	a2,a2,864 # ffffffffc0206f48 <commands+0x628>
ffffffffc0200bf0:	0d100593          	li	a1,209
ffffffffc0200bf4:	00006517          	auipc	a0,0x6
ffffffffc0200bf8:	19450513          	addi	a0,a0,404 # ffffffffc0206d88 <commands+0x468>
ffffffffc0200bfc:	87fff0ef          	jal	ra,ffffffffc020047a <__panic>
                print_trapframe(tf);
ffffffffc0200c00:	8522                	mv	a0,s0
ffffffffc0200c02:	c33ff0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c06:	86a6                	mv	a3,s1
ffffffffc0200c08:	00006617          	auipc	a2,0x6
ffffffffc0200c0c:	32060613          	addi	a2,a2,800 # ffffffffc0206f28 <commands+0x608>
ffffffffc0200c10:	0f100593          	li	a1,241
ffffffffc0200c14:	00006517          	auipc	a0,0x6
ffffffffc0200c18:	17450513          	addi	a0,a0,372 # ffffffffc0206d88 <commands+0x468>
ffffffffc0200c1c:	85fff0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0200c20 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c20:	1101                	addi	sp,sp,-32
ffffffffc0200c22:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c24:	000b2417          	auipc	s0,0xb2
ffffffffc0200c28:	f4c40413          	addi	s0,s0,-180 # ffffffffc02b2b70 <current>
ffffffffc0200c2c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c2e:	ec06                	sd	ra,24(sp)
ffffffffc0200c30:	e426                	sd	s1,8(sp)
ffffffffc0200c32:	e04a                	sd	s2,0(sp)
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c34:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c38:	cf1d                	beqz	a4,ffffffffc0200c76 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c3a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c3e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c42:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c44:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c48:	0206c463          	bltz	a3,ffffffffc0200c70 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c4c:	df7ff0ef          	jal	ra,ffffffffc0200a42 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c50:	601c                	ld	a5,0(s0)
ffffffffc0200c52:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c56:	e499                	bnez	s1,ffffffffc0200c64 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c58:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c5c:	8b05                	andi	a4,a4,1
ffffffffc0200c5e:	e329                	bnez	a4,ffffffffc0200ca0 <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c60:	6f9c                	ld	a5,24(a5)
ffffffffc0200c62:	eb85                	bnez	a5,ffffffffc0200c92 <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
ffffffffc0200c66:	6442                	ld	s0,16(sp)
ffffffffc0200c68:	64a2                	ld	s1,8(sp)
ffffffffc0200c6a:	6902                	ld	s2,0(sp)
ffffffffc0200c6c:	6105                	addi	sp,sp,32
ffffffffc0200c6e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c70:	d41ff0ef          	jal	ra,ffffffffc02009b0 <interrupt_handler>
ffffffffc0200c74:	bff1                	j	ffffffffc0200c50 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c76:	0006c863          	bltz	a3,ffffffffc0200c86 <trap+0x66>
}
ffffffffc0200c7a:	6442                	ld	s0,16(sp)
ffffffffc0200c7c:	60e2                	ld	ra,24(sp)
ffffffffc0200c7e:	64a2                	ld	s1,8(sp)
ffffffffc0200c80:	6902                	ld	s2,0(sp)
ffffffffc0200c82:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c84:	bb7d                	j	ffffffffc0200a42 <exception_handler>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c90:	b305                	j	ffffffffc02009b0 <interrupt_handler>
}
ffffffffc0200c92:	6442                	ld	s0,16(sp)
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	64a2                	ld	s1,8(sp)
ffffffffc0200c98:	6902                	ld	s2,0(sp)
ffffffffc0200c9a:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200c9c:	4060506f          	j	ffffffffc02060a2 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200ca0:	555d                	li	a0,-9
ffffffffc0200ca2:	746040ef          	jal	ra,ffffffffc02053e8 <do_exit>
            if (current->need_resched) {
ffffffffc0200ca6:	601c                	ld	a5,0(s0)
ffffffffc0200ca8:	bf65                	j	ffffffffc0200c60 <trap+0x40>
	...

ffffffffc0200cac <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cac:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cb0:	00011463          	bnez	sp,ffffffffc0200cb8 <__alltraps+0xc>
ffffffffc0200cb4:	14002173          	csrr	sp,sscratch
ffffffffc0200cb8:	712d                	addi	sp,sp,-288
ffffffffc0200cba:	e002                	sd	zero,0(sp)
ffffffffc0200cbc:	e406                	sd	ra,8(sp)
ffffffffc0200cbe:	ec0e                	sd	gp,24(sp)
ffffffffc0200cc0:	f012                	sd	tp,32(sp)
ffffffffc0200cc2:	f416                	sd	t0,40(sp)
ffffffffc0200cc4:	f81a                	sd	t1,48(sp)
ffffffffc0200cc6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cc8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cca:	e4a6                	sd	s1,72(sp)
ffffffffc0200ccc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cce:	ecae                	sd	a1,88(sp)
ffffffffc0200cd0:	f0b2                	sd	a2,96(sp)
ffffffffc0200cd2:	f4b6                	sd	a3,104(sp)
ffffffffc0200cd4:	f8ba                	sd	a4,112(sp)
ffffffffc0200cd6:	fcbe                	sd	a5,120(sp)
ffffffffc0200cd8:	e142                	sd	a6,128(sp)
ffffffffc0200cda:	e546                	sd	a7,136(sp)
ffffffffc0200cdc:	e94a                	sd	s2,144(sp)
ffffffffc0200cde:	ed4e                	sd	s3,152(sp)
ffffffffc0200ce0:	f152                	sd	s4,160(sp)
ffffffffc0200ce2:	f556                	sd	s5,168(sp)
ffffffffc0200ce4:	f95a                	sd	s6,176(sp)
ffffffffc0200ce6:	fd5e                	sd	s7,184(sp)
ffffffffc0200ce8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cea:	e5e6                	sd	s9,200(sp)
ffffffffc0200cec:	e9ea                	sd	s10,208(sp)
ffffffffc0200cee:	edee                	sd	s11,216(sp)
ffffffffc0200cf0:	f1f2                	sd	t3,224(sp)
ffffffffc0200cf2:	f5f6                	sd	t4,232(sp)
ffffffffc0200cf4:	f9fa                	sd	t5,240(sp)
ffffffffc0200cf6:	fdfe                	sd	t6,248(sp)
ffffffffc0200cf8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200cfc:	100024f3          	csrr	s1,sstatus
ffffffffc0200d00:	14102973          	csrr	s2,sepc
ffffffffc0200d04:	143029f3          	csrr	s3,stval
ffffffffc0200d08:	14202a73          	csrr	s4,scause
ffffffffc0200d0c:	e822                	sd	s0,16(sp)
ffffffffc0200d0e:	e226                	sd	s1,256(sp)
ffffffffc0200d10:	e64a                	sd	s2,264(sp)
ffffffffc0200d12:	ea4e                	sd	s3,272(sp)
ffffffffc0200d14:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d16:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d18:	f09ff0ef          	jal	ra,ffffffffc0200c20 <trap>

ffffffffc0200d1c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d1c:	6492                	ld	s1,256(sp)
ffffffffc0200d1e:	6932                	ld	s2,264(sp)
ffffffffc0200d20:	1004f413          	andi	s0,s1,256
ffffffffc0200d24:	e401                	bnez	s0,ffffffffc0200d2c <__trapret+0x10>
ffffffffc0200d26:	1200                	addi	s0,sp,288
ffffffffc0200d28:	14041073          	csrw	sscratch,s0
ffffffffc0200d2c:	10049073          	csrw	sstatus,s1
ffffffffc0200d30:	14191073          	csrw	sepc,s2
ffffffffc0200d34:	60a2                	ld	ra,8(sp)
ffffffffc0200d36:	61e2                	ld	gp,24(sp)
ffffffffc0200d38:	7202                	ld	tp,32(sp)
ffffffffc0200d3a:	72a2                	ld	t0,40(sp)
ffffffffc0200d3c:	7342                	ld	t1,48(sp)
ffffffffc0200d3e:	73e2                	ld	t2,56(sp)
ffffffffc0200d40:	6406                	ld	s0,64(sp)
ffffffffc0200d42:	64a6                	ld	s1,72(sp)
ffffffffc0200d44:	6546                	ld	a0,80(sp)
ffffffffc0200d46:	65e6                	ld	a1,88(sp)
ffffffffc0200d48:	7606                	ld	a2,96(sp)
ffffffffc0200d4a:	76a6                	ld	a3,104(sp)
ffffffffc0200d4c:	7746                	ld	a4,112(sp)
ffffffffc0200d4e:	77e6                	ld	a5,120(sp)
ffffffffc0200d50:	680a                	ld	a6,128(sp)
ffffffffc0200d52:	68aa                	ld	a7,136(sp)
ffffffffc0200d54:	694a                	ld	s2,144(sp)
ffffffffc0200d56:	69ea                	ld	s3,152(sp)
ffffffffc0200d58:	7a0a                	ld	s4,160(sp)
ffffffffc0200d5a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d5c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d5e:	7bea                	ld	s7,184(sp)
ffffffffc0200d60:	6c0e                	ld	s8,192(sp)
ffffffffc0200d62:	6cae                	ld	s9,200(sp)
ffffffffc0200d64:	6d4e                	ld	s10,208(sp)
ffffffffc0200d66:	6dee                	ld	s11,216(sp)
ffffffffc0200d68:	7e0e                	ld	t3,224(sp)
ffffffffc0200d6a:	7eae                	ld	t4,232(sp)
ffffffffc0200d6c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d6e:	7fee                	ld	t6,248(sp)
ffffffffc0200d70:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d72:	10200073          	sret

ffffffffc0200d76 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d76:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d78:	b755                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200d7a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d7a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7d00>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d7e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d82:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d86:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d8a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d8e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200d92:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200d96:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200d9a:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200d9e:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200da0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200da2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200da4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200da6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200da8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200daa:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dac:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dae:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200db0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200db2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200db4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200db6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200db8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dba:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dbc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dbe:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dc0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dc2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dc4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dc6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dc8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dca:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200dcc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dce:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dd0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dd2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200dd4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dd6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dd8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dda:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ddc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dde:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200de0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200de2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200de4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200de6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200de8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dea:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dec:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dee:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200df0:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200df2:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200df4:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200df6:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200df8:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200dfa:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200dfc:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200dfe:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e00:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e02:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e04:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e06:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e08:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e0a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e0c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e0e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e10:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e12:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e14:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e16:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e18:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e1a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e1c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e1e:	812e                	mv	sp,a1
ffffffffc0200e20:	bdf5                	j	ffffffffc0200d1c <__trapret>

ffffffffc0200e22 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e22:	000ae797          	auipc	a5,0xae
ffffffffc0200e26:	c0e78793          	addi	a5,a5,-1010 # ffffffffc02aea30 <free_area>
ffffffffc0200e2a:	e79c                	sd	a5,8(a5)
ffffffffc0200e2c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e2e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e32:	8082                	ret

ffffffffc0200e34 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e34:	000ae517          	auipc	a0,0xae
ffffffffc0200e38:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc02aea40 <free_area+0x10>
ffffffffc0200e3c:	8082                	ret

ffffffffc0200e3e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e3e:	715d                	addi	sp,sp,-80
ffffffffc0200e40:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e42:	000ae417          	auipc	s0,0xae
ffffffffc0200e46:	bee40413          	addi	s0,s0,-1042 # ffffffffc02aea30 <free_area>
ffffffffc0200e4a:	641c                	ld	a5,8(s0)
ffffffffc0200e4c:	e486                	sd	ra,72(sp)
ffffffffc0200e4e:	fc26                	sd	s1,56(sp)
ffffffffc0200e50:	f84a                	sd	s2,48(sp)
ffffffffc0200e52:	f44e                	sd	s3,40(sp)
ffffffffc0200e54:	f052                	sd	s4,32(sp)
ffffffffc0200e56:	ec56                	sd	s5,24(sp)
ffffffffc0200e58:	e85a                	sd	s6,16(sp)
ffffffffc0200e5a:	e45e                	sd	s7,8(sp)
ffffffffc0200e5c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e5e:	2a878d63          	beq	a5,s0,ffffffffc0201118 <default_check+0x2da>
    int count = 0, total = 0;
ffffffffc0200e62:	4481                	li	s1,0
ffffffffc0200e64:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e66:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e6a:	8b09                	andi	a4,a4,2
ffffffffc0200e6c:	2a070a63          	beqz	a4,ffffffffc0201120 <default_check+0x2e2>
        count ++, total += p->property;
ffffffffc0200e70:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e74:	679c                	ld	a5,8(a5)
ffffffffc0200e76:	2905                	addiw	s2,s2,1
ffffffffc0200e78:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7a:	fe8796e3          	bne	a5,s0,ffffffffc0200e66 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200e7e:	89a6                	mv	s3,s1
ffffffffc0200e80:	733000ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0200e84:	6f351e63          	bne	a0,s3,ffffffffc0201580 <default_check+0x742>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e88:	4505                	li	a0,1
ffffffffc0200e8a:	657000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200e8e:	8aaa                	mv	s5,a0
ffffffffc0200e90:	42050863          	beqz	a0,ffffffffc02012c0 <default_check+0x482>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e94:	4505                	li	a0,1
ffffffffc0200e96:	64b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200e9a:	89aa                	mv	s3,a0
ffffffffc0200e9c:	70050263          	beqz	a0,ffffffffc02015a0 <default_check+0x762>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ea0:	4505                	li	a0,1
ffffffffc0200ea2:	63f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200ea6:	8a2a                	mv	s4,a0
ffffffffc0200ea8:	48050c63          	beqz	a0,ffffffffc0201340 <default_check+0x502>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200eac:	293a8a63          	beq	s5,s3,ffffffffc0201140 <default_check+0x302>
ffffffffc0200eb0:	28aa8863          	beq	s5,a0,ffffffffc0201140 <default_check+0x302>
ffffffffc0200eb4:	28a98663          	beq	s3,a0,ffffffffc0201140 <default_check+0x302>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb8:	000aa783          	lw	a5,0(s5)
ffffffffc0200ebc:	2a079263          	bnez	a5,ffffffffc0201160 <default_check+0x322>
ffffffffc0200ec0:	0009a783          	lw	a5,0(s3)
ffffffffc0200ec4:	28079e63          	bnez	a5,ffffffffc0201160 <default_check+0x322>
ffffffffc0200ec8:	411c                	lw	a5,0(a0)
ffffffffc0200eca:	28079b63          	bnez	a5,ffffffffc0201160 <default_check+0x322>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200ece:	000b2797          	auipc	a5,0xb2
ffffffffc0200ed2:	c627b783          	ld	a5,-926(a5) # ffffffffc02b2b30 <pages>
ffffffffc0200ed6:	40fa8733          	sub	a4,s5,a5
ffffffffc0200eda:	00008617          	auipc	a2,0x8
ffffffffc0200ede:	e9663603          	ld	a2,-362(a2) # ffffffffc0208d70 <nbase>
ffffffffc0200ee2:	8719                	srai	a4,a4,0x6
ffffffffc0200ee4:	9732                	add	a4,a4,a2
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ee6:	000b2697          	auipc	a3,0xb2
ffffffffc0200eea:	c426b683          	ld	a3,-958(a3) # ffffffffc02b2b28 <npage>
ffffffffc0200eee:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ef0:	0732                	slli	a4,a4,0xc
ffffffffc0200ef2:	28d77763          	bgeu	a4,a3,ffffffffc0201180 <default_check+0x342>
    return page - pages + nbase;
ffffffffc0200ef6:	40f98733          	sub	a4,s3,a5
ffffffffc0200efa:	8719                	srai	a4,a4,0x6
ffffffffc0200efc:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200efe:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f00:	4cd77063          	bgeu	a4,a3,ffffffffc02013c0 <default_check+0x582>
    return page - pages + nbase;
ffffffffc0200f04:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f08:	8799                	srai	a5,a5,0x6
ffffffffc0200f0a:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f0c:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f0e:	30d7f963          	bgeu	a5,a3,ffffffffc0201220 <default_check+0x3e2>
    assert(alloc_page() == NULL);
ffffffffc0200f12:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f14:	00043c03          	ld	s8,0(s0)
ffffffffc0200f18:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f1c:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200f20:	e400                	sd	s0,8(s0)
ffffffffc0200f22:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200f24:	000ae797          	auipc	a5,0xae
ffffffffc0200f28:	b007ae23          	sw	zero,-1252(a5) # ffffffffc02aea40 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f2c:	5b5000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f30:	2c051863          	bnez	a0,ffffffffc0201200 <default_check+0x3c2>
    free_page(p0);
ffffffffc0200f34:	4585                	li	a1,1
ffffffffc0200f36:	8556                	mv	a0,s5
ffffffffc0200f38:	63b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p1);
ffffffffc0200f3c:	4585                	li	a1,1
ffffffffc0200f3e:	854e                	mv	a0,s3
ffffffffc0200f40:	633000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc0200f44:	4585                	li	a1,1
ffffffffc0200f46:	8552                	mv	a0,s4
ffffffffc0200f48:	62b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f4c:	4818                	lw	a4,16(s0)
ffffffffc0200f4e:	478d                	li	a5,3
ffffffffc0200f50:	28f71863          	bne	a4,a5,ffffffffc02011e0 <default_check+0x3a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f54:	4505                	li	a0,1
ffffffffc0200f56:	58b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f5a:	89aa                	mv	s3,a0
ffffffffc0200f5c:	26050263          	beqz	a0,ffffffffc02011c0 <default_check+0x382>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f60:	4505                	li	a0,1
ffffffffc0200f62:	57f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f66:	8aaa                	mv	s5,a0
ffffffffc0200f68:	3a050c63          	beqz	a0,ffffffffc0201320 <default_check+0x4e2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f6c:	4505                	li	a0,1
ffffffffc0200f6e:	573000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f72:	8a2a                	mv	s4,a0
ffffffffc0200f74:	38050663          	beqz	a0,ffffffffc0201300 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200f78:	4505                	li	a0,1
ffffffffc0200f7a:	567000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f7e:	36051163          	bnez	a0,ffffffffc02012e0 <default_check+0x4a2>
    free_page(p0);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	854e                	mv	a0,s3
ffffffffc0200f86:	5ed000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f8a:	641c                	ld	a5,8(s0)
ffffffffc0200f8c:	20878a63          	beq	a5,s0,ffffffffc02011a0 <default_check+0x362>
    assert((p = alloc_page()) == p0);
ffffffffc0200f90:	4505                	li	a0,1
ffffffffc0200f92:	54f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200f96:	30a99563          	bne	s3,a0,ffffffffc02012a0 <default_check+0x462>
    assert(alloc_page() == NULL);
ffffffffc0200f9a:	4505                	li	a0,1
ffffffffc0200f9c:	545000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200fa0:	2e051063          	bnez	a0,ffffffffc0201280 <default_check+0x442>
    assert(nr_free == 0);
ffffffffc0200fa4:	481c                	lw	a5,16(s0)
ffffffffc0200fa6:	2a079d63          	bnez	a5,ffffffffc0201260 <default_check+0x422>
    free_page(p);
ffffffffc0200faa:	854e                	mv	a0,s3
ffffffffc0200fac:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fae:	01843023          	sd	s8,0(s0)
ffffffffc0200fb2:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200fb6:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200fba:	5b9000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p1);
ffffffffc0200fbe:	4585                	li	a1,1
ffffffffc0200fc0:	8556                	mv	a0,s5
ffffffffc0200fc2:	5b1000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc0200fc6:	4585                	li	a1,1
ffffffffc0200fc8:	8552                	mv	a0,s4
ffffffffc0200fca:	5a9000ef          	jal	ra,ffffffffc0201d72 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fce:	4515                	li	a0,5
ffffffffc0200fd0:	511000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200fd4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fd6:	26050563          	beqz	a0,ffffffffc0201240 <default_check+0x402>
ffffffffc0200fda:	651c                	ld	a5,8(a0)
ffffffffc0200fdc:	8385                	srli	a5,a5,0x1
ffffffffc0200fde:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0200fe0:	54079063          	bnez	a5,ffffffffc0201520 <default_check+0x6e2>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fe6:	00043b03          	ld	s6,0(s0)
ffffffffc0200fea:	00843a83          	ld	s5,8(s0)
ffffffffc0200fee:	e000                	sd	s0,0(s0)
ffffffffc0200ff0:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200ff2:	4ef000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0200ff6:	50051563          	bnez	a0,ffffffffc0201500 <default_check+0x6c2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ffa:	08098a13          	addi	s4,s3,128
ffffffffc0200ffe:	8552                	mv	a0,s4
ffffffffc0201000:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201002:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0201006:	000ae797          	auipc	a5,0xae
ffffffffc020100a:	a207ad23          	sw	zero,-1478(a5) # ffffffffc02aea40 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020100e:	565000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201012:	4511                	li	a0,4
ffffffffc0201014:	4cd000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201018:	4c051463          	bnez	a0,ffffffffc02014e0 <default_check+0x6a2>
ffffffffc020101c:	0889b783          	ld	a5,136(s3)
ffffffffc0201020:	8385                	srli	a5,a5,0x1
ffffffffc0201022:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201024:	48078e63          	beqz	a5,ffffffffc02014c0 <default_check+0x682>
ffffffffc0201028:	0909a703          	lw	a4,144(s3)
ffffffffc020102c:	478d                	li	a5,3
ffffffffc020102e:	48f71963          	bne	a4,a5,ffffffffc02014c0 <default_check+0x682>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201032:	450d                	li	a0,3
ffffffffc0201034:	4ad000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201038:	8c2a                	mv	s8,a0
ffffffffc020103a:	46050363          	beqz	a0,ffffffffc02014a0 <default_check+0x662>
    assert(alloc_page() == NULL);
ffffffffc020103e:	4505                	li	a0,1
ffffffffc0201040:	4a1000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201044:	42051e63          	bnez	a0,ffffffffc0201480 <default_check+0x642>
    assert(p0 + 2 == p1);
ffffffffc0201048:	418a1c63          	bne	s4,s8,ffffffffc0201460 <default_check+0x622>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020104c:	4585                	li	a1,1
ffffffffc020104e:	854e                	mv	a0,s3
ffffffffc0201050:	523000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_pages(p1, 3);
ffffffffc0201054:	458d                	li	a1,3
ffffffffc0201056:	8552                	mv	a0,s4
ffffffffc0201058:	51b000ef          	jal	ra,ffffffffc0201d72 <free_pages>
ffffffffc020105c:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201060:	04098c13          	addi	s8,s3,64
ffffffffc0201064:	8385                	srli	a5,a5,0x1
ffffffffc0201066:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201068:	3c078c63          	beqz	a5,ffffffffc0201440 <default_check+0x602>
ffffffffc020106c:	0109a703          	lw	a4,16(s3)
ffffffffc0201070:	4785                	li	a5,1
ffffffffc0201072:	3cf71763          	bne	a4,a5,ffffffffc0201440 <default_check+0x602>
ffffffffc0201076:	008a3783          	ld	a5,8(s4)
ffffffffc020107a:	8385                	srli	a5,a5,0x1
ffffffffc020107c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020107e:	3a078163          	beqz	a5,ffffffffc0201420 <default_check+0x5e2>
ffffffffc0201082:	010a2703          	lw	a4,16(s4)
ffffffffc0201086:	478d                	li	a5,3
ffffffffc0201088:	38f71c63          	bne	a4,a5,ffffffffc0201420 <default_check+0x5e2>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020108c:	4505                	li	a0,1
ffffffffc020108e:	453000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201092:	36a99763          	bne	s3,a0,ffffffffc0201400 <default_check+0x5c2>
    free_page(p0);
ffffffffc0201096:	4585                	li	a1,1
ffffffffc0201098:	4db000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020109c:	4509                	li	a0,2
ffffffffc020109e:	443000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010a2:	32aa1f63          	bne	s4,a0,ffffffffc02013e0 <default_check+0x5a2>

    free_pages(p0, 2);
ffffffffc02010a6:	4589                	li	a1,2
ffffffffc02010a8:	4cb000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    free_page(p2);
ffffffffc02010ac:	4585                	li	a1,1
ffffffffc02010ae:	8562                	mv	a0,s8
ffffffffc02010b0:	4c3000ef          	jal	ra,ffffffffc0201d72 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010b4:	4515                	li	a0,5
ffffffffc02010b6:	42b000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010ba:	89aa                	mv	s3,a0
ffffffffc02010bc:	48050263          	beqz	a0,ffffffffc0201540 <default_check+0x702>
    assert(alloc_page() == NULL);
ffffffffc02010c0:	4505                	li	a0,1
ffffffffc02010c2:	41f000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02010c6:	2c051d63          	bnez	a0,ffffffffc02013a0 <default_check+0x562>

    assert(nr_free == 0);
ffffffffc02010ca:	481c                	lw	a5,16(s0)
ffffffffc02010cc:	2a079a63          	bnez	a5,ffffffffc0201380 <default_check+0x542>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc02010d0:	4595                	li	a1,5
ffffffffc02010d2:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc02010d4:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc02010d8:	01643023          	sd	s6,0(s0)
ffffffffc02010dc:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc02010e0:	493000ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return listelm->next;
ffffffffc02010e4:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010e6:	00878963          	beq	a5,s0,ffffffffc02010f8 <default_check+0x2ba>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010ea:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010ee:	679c                	ld	a5,8(a5)
ffffffffc02010f0:	397d                	addiw	s2,s2,-1
ffffffffc02010f2:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010f4:	fe879be3          	bne	a5,s0,ffffffffc02010ea <default_check+0x2ac>
    }
    assert(count == 0);
ffffffffc02010f8:	26091463          	bnez	s2,ffffffffc0201360 <default_check+0x522>
    assert(total == 0);
ffffffffc02010fc:	46049263          	bnez	s1,ffffffffc0201560 <default_check+0x722>
}
ffffffffc0201100:	60a6                	ld	ra,72(sp)
ffffffffc0201102:	6406                	ld	s0,64(sp)
ffffffffc0201104:	74e2                	ld	s1,56(sp)
ffffffffc0201106:	7942                	ld	s2,48(sp)
ffffffffc0201108:	79a2                	ld	s3,40(sp)
ffffffffc020110a:	7a02                	ld	s4,32(sp)
ffffffffc020110c:	6ae2                	ld	s5,24(sp)
ffffffffc020110e:	6b42                	ld	s6,16(sp)
ffffffffc0201110:	6ba2                	ld	s7,8(sp)
ffffffffc0201112:	6c02                	ld	s8,0(sp)
ffffffffc0201114:	6161                	addi	sp,sp,80
ffffffffc0201116:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201118:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020111a:	4481                	li	s1,0
ffffffffc020111c:	4901                	li	s2,0
ffffffffc020111e:	b38d                	j	ffffffffc0200e80 <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0201120:	00006697          	auipc	a3,0x6
ffffffffc0201124:	f4068693          	addi	a3,a3,-192 # ffffffffc0207060 <commands+0x740>
ffffffffc0201128:	00006617          	auipc	a2,0x6
ffffffffc020112c:	c4860613          	addi	a2,a2,-952 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201130:	0f000593          	li	a1,240
ffffffffc0201134:	00006517          	auipc	a0,0x6
ffffffffc0201138:	f3c50513          	addi	a0,a0,-196 # ffffffffc0207070 <commands+0x750>
ffffffffc020113c:	b3eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201140:	00006697          	auipc	a3,0x6
ffffffffc0201144:	fc868693          	addi	a3,a3,-56 # ffffffffc0207108 <commands+0x7e8>
ffffffffc0201148:	00006617          	auipc	a2,0x6
ffffffffc020114c:	c2860613          	addi	a2,a2,-984 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201150:	0bd00593          	li	a1,189
ffffffffc0201154:	00006517          	auipc	a0,0x6
ffffffffc0201158:	f1c50513          	addi	a0,a0,-228 # ffffffffc0207070 <commands+0x750>
ffffffffc020115c:	b1eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201160:	00006697          	auipc	a3,0x6
ffffffffc0201164:	fd068693          	addi	a3,a3,-48 # ffffffffc0207130 <commands+0x810>
ffffffffc0201168:	00006617          	auipc	a2,0x6
ffffffffc020116c:	c0860613          	addi	a2,a2,-1016 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201170:	0be00593          	li	a1,190
ffffffffc0201174:	00006517          	auipc	a0,0x6
ffffffffc0201178:	efc50513          	addi	a0,a0,-260 # ffffffffc0207070 <commands+0x750>
ffffffffc020117c:	afeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	ff068693          	addi	a3,a3,-16 # ffffffffc0207170 <commands+0x850>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	be860613          	addi	a2,a2,-1048 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201190:	0c000593          	li	a1,192
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	edc50513          	addi	a0,a0,-292 # ffffffffc0207070 <commands+0x750>
ffffffffc020119c:	adeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!list_empty(&free_list));
ffffffffc02011a0:	00006697          	auipc	a3,0x6
ffffffffc02011a4:	05868693          	addi	a3,a3,88 # ffffffffc02071f8 <commands+0x8d8>
ffffffffc02011a8:	00006617          	auipc	a2,0x6
ffffffffc02011ac:	bc860613          	addi	a2,a2,-1080 # ffffffffc0206d70 <commands+0x450>
ffffffffc02011b0:	0d900593          	li	a1,217
ffffffffc02011b4:	00006517          	auipc	a0,0x6
ffffffffc02011b8:	ebc50513          	addi	a0,a0,-324 # ffffffffc0207070 <commands+0x750>
ffffffffc02011bc:	abeff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011c0:	00006697          	auipc	a3,0x6
ffffffffc02011c4:	ee868693          	addi	a3,a3,-280 # ffffffffc02070a8 <commands+0x788>
ffffffffc02011c8:	00006617          	auipc	a2,0x6
ffffffffc02011cc:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206d70 <commands+0x450>
ffffffffc02011d0:	0d200593          	li	a1,210
ffffffffc02011d4:	00006517          	auipc	a0,0x6
ffffffffc02011d8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0207070 <commands+0x750>
ffffffffc02011dc:	a9eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 3);
ffffffffc02011e0:	00006697          	auipc	a3,0x6
ffffffffc02011e4:	00868693          	addi	a3,a3,8 # ffffffffc02071e8 <commands+0x8c8>
ffffffffc02011e8:	00006617          	auipc	a2,0x6
ffffffffc02011ec:	b8860613          	addi	a2,a2,-1144 # ffffffffc0206d70 <commands+0x450>
ffffffffc02011f0:	0d000593          	li	a1,208
ffffffffc02011f4:	00006517          	auipc	a0,0x6
ffffffffc02011f8:	e7c50513          	addi	a0,a0,-388 # ffffffffc0207070 <commands+0x750>
ffffffffc02011fc:	a7eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201200:	00006697          	auipc	a3,0x6
ffffffffc0201204:	fd068693          	addi	a3,a3,-48 # ffffffffc02071d0 <commands+0x8b0>
ffffffffc0201208:	00006617          	auipc	a2,0x6
ffffffffc020120c:	b6860613          	addi	a2,a2,-1176 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201210:	0cb00593          	li	a1,203
ffffffffc0201214:	00006517          	auipc	a0,0x6
ffffffffc0201218:	e5c50513          	addi	a0,a0,-420 # ffffffffc0207070 <commands+0x750>
ffffffffc020121c:	a5eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201220:	00006697          	auipc	a3,0x6
ffffffffc0201224:	f9068693          	addi	a3,a3,-112 # ffffffffc02071b0 <commands+0x890>
ffffffffc0201228:	00006617          	auipc	a2,0x6
ffffffffc020122c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201230:	0c200593          	li	a1,194
ffffffffc0201234:	00006517          	auipc	a0,0x6
ffffffffc0201238:	e3c50513          	addi	a0,a0,-452 # ffffffffc0207070 <commands+0x750>
ffffffffc020123c:	a3eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 != NULL);
ffffffffc0201240:	00006697          	auipc	a3,0x6
ffffffffc0201244:	00068693          	mv	a3,a3
ffffffffc0201248:	00006617          	auipc	a2,0x6
ffffffffc020124c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201250:	0f800593          	li	a1,248
ffffffffc0201254:	00006517          	auipc	a0,0x6
ffffffffc0201258:	e1c50513          	addi	a0,a0,-484 # ffffffffc0207070 <commands+0x750>
ffffffffc020125c:	a1eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc0201260:	00006697          	auipc	a3,0x6
ffffffffc0201264:	fd068693          	addi	a3,a3,-48 # ffffffffc0207230 <commands+0x910>
ffffffffc0201268:	00006617          	auipc	a2,0x6
ffffffffc020126c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201270:	0df00593          	li	a1,223
ffffffffc0201274:	00006517          	auipc	a0,0x6
ffffffffc0201278:	dfc50513          	addi	a0,a0,-516 # ffffffffc0207070 <commands+0x750>
ffffffffc020127c:	9feff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201280:	00006697          	auipc	a3,0x6
ffffffffc0201284:	f5068693          	addi	a3,a3,-176 # ffffffffc02071d0 <commands+0x8b0>
ffffffffc0201288:	00006617          	auipc	a2,0x6
ffffffffc020128c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201290:	0dd00593          	li	a1,221
ffffffffc0201294:	00006517          	auipc	a0,0x6
ffffffffc0201298:	ddc50513          	addi	a0,a0,-548 # ffffffffc0207070 <commands+0x750>
ffffffffc020129c:	9deff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02012a0:	00006697          	auipc	a3,0x6
ffffffffc02012a4:	f7068693          	addi	a3,a3,-144 # ffffffffc0207210 <commands+0x8f0>
ffffffffc02012a8:	00006617          	auipc	a2,0x6
ffffffffc02012ac:	ac860613          	addi	a2,a2,-1336 # ffffffffc0206d70 <commands+0x450>
ffffffffc02012b0:	0dc00593          	li	a1,220
ffffffffc02012b4:	00006517          	auipc	a0,0x6
ffffffffc02012b8:	dbc50513          	addi	a0,a0,-580 # ffffffffc0207070 <commands+0x750>
ffffffffc02012bc:	9beff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02012c0:	00006697          	auipc	a3,0x6
ffffffffc02012c4:	de868693          	addi	a3,a3,-536 # ffffffffc02070a8 <commands+0x788>
ffffffffc02012c8:	00006617          	auipc	a2,0x6
ffffffffc02012cc:	aa860613          	addi	a2,a2,-1368 # ffffffffc0206d70 <commands+0x450>
ffffffffc02012d0:	0b900593          	li	a1,185
ffffffffc02012d4:	00006517          	auipc	a0,0x6
ffffffffc02012d8:	d9c50513          	addi	a0,a0,-612 # ffffffffc0207070 <commands+0x750>
ffffffffc02012dc:	99eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e0:	00006697          	auipc	a3,0x6
ffffffffc02012e4:	ef068693          	addi	a3,a3,-272 # ffffffffc02071d0 <commands+0x8b0>
ffffffffc02012e8:	00006617          	auipc	a2,0x6
ffffffffc02012ec:	a8860613          	addi	a2,a2,-1400 # ffffffffc0206d70 <commands+0x450>
ffffffffc02012f0:	0d600593          	li	a1,214
ffffffffc02012f4:	00006517          	auipc	a0,0x6
ffffffffc02012f8:	d7c50513          	addi	a0,a0,-644 # ffffffffc0207070 <commands+0x750>
ffffffffc02012fc:	97eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201300:	00006697          	auipc	a3,0x6
ffffffffc0201304:	de868693          	addi	a3,a3,-536 # ffffffffc02070e8 <commands+0x7c8>
ffffffffc0201308:	00006617          	auipc	a2,0x6
ffffffffc020130c:	a6860613          	addi	a2,a2,-1432 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201310:	0d400593          	li	a1,212
ffffffffc0201314:	00006517          	auipc	a0,0x6
ffffffffc0201318:	d5c50513          	addi	a0,a0,-676 # ffffffffc0207070 <commands+0x750>
ffffffffc020131c:	95eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201320:	00006697          	auipc	a3,0x6
ffffffffc0201324:	da868693          	addi	a3,a3,-600 # ffffffffc02070c8 <commands+0x7a8>
ffffffffc0201328:	00006617          	auipc	a2,0x6
ffffffffc020132c:	a4860613          	addi	a2,a2,-1464 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201330:	0d300593          	li	a1,211
ffffffffc0201334:	00006517          	auipc	a0,0x6
ffffffffc0201338:	d3c50513          	addi	a0,a0,-708 # ffffffffc0207070 <commands+0x750>
ffffffffc020133c:	93eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201340:	00006697          	auipc	a3,0x6
ffffffffc0201344:	da868693          	addi	a3,a3,-600 # ffffffffc02070e8 <commands+0x7c8>
ffffffffc0201348:	00006617          	auipc	a2,0x6
ffffffffc020134c:	a2860613          	addi	a2,a2,-1496 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201350:	0bb00593          	li	a1,187
ffffffffc0201354:	00006517          	auipc	a0,0x6
ffffffffc0201358:	d1c50513          	addi	a0,a0,-740 # ffffffffc0207070 <commands+0x750>
ffffffffc020135c:	91eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(count == 0);
ffffffffc0201360:	00006697          	auipc	a3,0x6
ffffffffc0201364:	03068693          	addi	a3,a3,48 # ffffffffc0207390 <commands+0xa70>
ffffffffc0201368:	00006617          	auipc	a2,0x6
ffffffffc020136c:	a0860613          	addi	a2,a2,-1528 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201370:	12500593          	li	a1,293
ffffffffc0201374:	00006517          	auipc	a0,0x6
ffffffffc0201378:	cfc50513          	addi	a0,a0,-772 # ffffffffc0207070 <commands+0x750>
ffffffffc020137c:	8feff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free == 0);
ffffffffc0201380:	00006697          	auipc	a3,0x6
ffffffffc0201384:	eb068693          	addi	a3,a3,-336 # ffffffffc0207230 <commands+0x910>
ffffffffc0201388:	00006617          	auipc	a2,0x6
ffffffffc020138c:	9e860613          	addi	a2,a2,-1560 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201390:	11a00593          	li	a1,282
ffffffffc0201394:	00006517          	auipc	a0,0x6
ffffffffc0201398:	cdc50513          	addi	a0,a0,-804 # ffffffffc0207070 <commands+0x750>
ffffffffc020139c:	8deff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013a0:	00006697          	auipc	a3,0x6
ffffffffc02013a4:	e3068693          	addi	a3,a3,-464 # ffffffffc02071d0 <commands+0x8b0>
ffffffffc02013a8:	00006617          	auipc	a2,0x6
ffffffffc02013ac:	9c860613          	addi	a2,a2,-1592 # ffffffffc0206d70 <commands+0x450>
ffffffffc02013b0:	11800593          	li	a1,280
ffffffffc02013b4:	00006517          	auipc	a0,0x6
ffffffffc02013b8:	cbc50513          	addi	a0,a0,-836 # ffffffffc0207070 <commands+0x750>
ffffffffc02013bc:	8beff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02013c0:	00006697          	auipc	a3,0x6
ffffffffc02013c4:	dd068693          	addi	a3,a3,-560 # ffffffffc0207190 <commands+0x870>
ffffffffc02013c8:	00006617          	auipc	a2,0x6
ffffffffc02013cc:	9a860613          	addi	a2,a2,-1624 # ffffffffc0206d70 <commands+0x450>
ffffffffc02013d0:	0c100593          	li	a1,193
ffffffffc02013d4:	00006517          	auipc	a0,0x6
ffffffffc02013d8:	c9c50513          	addi	a0,a0,-868 # ffffffffc0207070 <commands+0x750>
ffffffffc02013dc:	89eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02013e0:	00006697          	auipc	a3,0x6
ffffffffc02013e4:	f7068693          	addi	a3,a3,-144 # ffffffffc0207350 <commands+0xa30>
ffffffffc02013e8:	00006617          	auipc	a2,0x6
ffffffffc02013ec:	98860613          	addi	a2,a2,-1656 # ffffffffc0206d70 <commands+0x450>
ffffffffc02013f0:	11200593          	li	a1,274
ffffffffc02013f4:	00006517          	auipc	a0,0x6
ffffffffc02013f8:	c7c50513          	addi	a0,a0,-900 # ffffffffc0207070 <commands+0x750>
ffffffffc02013fc:	87eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201400:	00006697          	auipc	a3,0x6
ffffffffc0201404:	f3068693          	addi	a3,a3,-208 # ffffffffc0207330 <commands+0xa10>
ffffffffc0201408:	00006617          	auipc	a2,0x6
ffffffffc020140c:	96860613          	addi	a2,a2,-1688 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201410:	11000593          	li	a1,272
ffffffffc0201414:	00006517          	auipc	a0,0x6
ffffffffc0201418:	c5c50513          	addi	a0,a0,-932 # ffffffffc0207070 <commands+0x750>
ffffffffc020141c:	85eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201420:	00006697          	auipc	a3,0x6
ffffffffc0201424:	ee868693          	addi	a3,a3,-280 # ffffffffc0207308 <commands+0x9e8>
ffffffffc0201428:	00006617          	auipc	a2,0x6
ffffffffc020142c:	94860613          	addi	a2,a2,-1720 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201430:	10e00593          	li	a1,270
ffffffffc0201434:	00006517          	auipc	a0,0x6
ffffffffc0201438:	c3c50513          	addi	a0,a0,-964 # ffffffffc0207070 <commands+0x750>
ffffffffc020143c:	83eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201440:	00006697          	auipc	a3,0x6
ffffffffc0201444:	ea068693          	addi	a3,a3,-352 # ffffffffc02072e0 <commands+0x9c0>
ffffffffc0201448:	00006617          	auipc	a2,0x6
ffffffffc020144c:	92860613          	addi	a2,a2,-1752 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201450:	10d00593          	li	a1,269
ffffffffc0201454:	00006517          	auipc	a0,0x6
ffffffffc0201458:	c1c50513          	addi	a0,a0,-996 # ffffffffc0207070 <commands+0x750>
ffffffffc020145c:	81eff0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201460:	00006697          	auipc	a3,0x6
ffffffffc0201464:	e7068693          	addi	a3,a3,-400 # ffffffffc02072d0 <commands+0x9b0>
ffffffffc0201468:	00006617          	auipc	a2,0x6
ffffffffc020146c:	90860613          	addi	a2,a2,-1784 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201470:	10800593          	li	a1,264
ffffffffc0201474:	00006517          	auipc	a0,0x6
ffffffffc0201478:	bfc50513          	addi	a0,a0,-1028 # ffffffffc0207070 <commands+0x750>
ffffffffc020147c:	ffffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201480:	00006697          	auipc	a3,0x6
ffffffffc0201484:	d5068693          	addi	a3,a3,-688 # ffffffffc02071d0 <commands+0x8b0>
ffffffffc0201488:	00006617          	auipc	a2,0x6
ffffffffc020148c:	8e860613          	addi	a2,a2,-1816 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201490:	10700593          	li	a1,263
ffffffffc0201494:	00006517          	auipc	a0,0x6
ffffffffc0201498:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0207070 <commands+0x750>
ffffffffc020149c:	fdffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02014a0:	00006697          	auipc	a3,0x6
ffffffffc02014a4:	e1068693          	addi	a3,a3,-496 # ffffffffc02072b0 <commands+0x990>
ffffffffc02014a8:	00006617          	auipc	a2,0x6
ffffffffc02014ac:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206d70 <commands+0x450>
ffffffffc02014b0:	10600593          	li	a1,262
ffffffffc02014b4:	00006517          	auipc	a0,0x6
ffffffffc02014b8:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0207070 <commands+0x750>
ffffffffc02014bc:	fbffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02014c0:	00006697          	auipc	a3,0x6
ffffffffc02014c4:	dc068693          	addi	a3,a3,-576 # ffffffffc0207280 <commands+0x960>
ffffffffc02014c8:	00006617          	auipc	a2,0x6
ffffffffc02014cc:	8a860613          	addi	a2,a2,-1880 # ffffffffc0206d70 <commands+0x450>
ffffffffc02014d0:	10500593          	li	a1,261
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	b9c50513          	addi	a0,a0,-1124 # ffffffffc0207070 <commands+0x750>
ffffffffc02014dc:	f9ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	d8868693          	addi	a3,a3,-632 # ffffffffc0207268 <commands+0x948>
ffffffffc02014e8:	00006617          	auipc	a2,0x6
ffffffffc02014ec:	88860613          	addi	a2,a2,-1912 # ffffffffc0206d70 <commands+0x450>
ffffffffc02014f0:	10400593          	li	a1,260
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207070 <commands+0x750>
ffffffffc02014fc:	f7ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201500:	00006697          	auipc	a3,0x6
ffffffffc0201504:	cd068693          	addi	a3,a3,-816 # ffffffffc02071d0 <commands+0x8b0>
ffffffffc0201508:	00006617          	auipc	a2,0x6
ffffffffc020150c:	86860613          	addi	a2,a2,-1944 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201510:	0fe00593          	li	a1,254
ffffffffc0201514:	00006517          	auipc	a0,0x6
ffffffffc0201518:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0207070 <commands+0x750>
ffffffffc020151c:	f5ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(!PageProperty(p0));
ffffffffc0201520:	00006697          	auipc	a3,0x6
ffffffffc0201524:	d3068693          	addi	a3,a3,-720 # ffffffffc0207250 <commands+0x930>
ffffffffc0201528:	00006617          	auipc	a2,0x6
ffffffffc020152c:	84860613          	addi	a2,a2,-1976 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201530:	0f900593          	li	a1,249
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0207070 <commands+0x750>
ffffffffc020153c:	f3ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201540:	00006697          	auipc	a3,0x6
ffffffffc0201544:	e3068693          	addi	a3,a3,-464 # ffffffffc0207370 <commands+0xa50>
ffffffffc0201548:	00006617          	auipc	a2,0x6
ffffffffc020154c:	82860613          	addi	a2,a2,-2008 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201550:	11700593          	li	a1,279
ffffffffc0201554:	00006517          	auipc	a0,0x6
ffffffffc0201558:	b1c50513          	addi	a0,a0,-1252 # ffffffffc0207070 <commands+0x750>
ffffffffc020155c:	f1ffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == 0);
ffffffffc0201560:	00006697          	auipc	a3,0x6
ffffffffc0201564:	e4068693          	addi	a3,a3,-448 # ffffffffc02073a0 <commands+0xa80>
ffffffffc0201568:	00006617          	auipc	a2,0x6
ffffffffc020156c:	80860613          	addi	a2,a2,-2040 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201570:	12600593          	li	a1,294
ffffffffc0201574:	00006517          	auipc	a0,0x6
ffffffffc0201578:	afc50513          	addi	a0,a0,-1284 # ffffffffc0207070 <commands+0x750>
ffffffffc020157c:	efffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(total == nr_free_pages());
ffffffffc0201580:	00006697          	auipc	a3,0x6
ffffffffc0201584:	b0868693          	addi	a3,a3,-1272 # ffffffffc0207088 <commands+0x768>
ffffffffc0201588:	00005617          	auipc	a2,0x5
ffffffffc020158c:	7e860613          	addi	a2,a2,2024 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201590:	0f300593          	li	a1,243
ffffffffc0201594:	00006517          	auipc	a0,0x6
ffffffffc0201598:	adc50513          	addi	a0,a0,-1316 # ffffffffc0207070 <commands+0x750>
ffffffffc020159c:	edffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015a0:	00006697          	auipc	a3,0x6
ffffffffc02015a4:	b2868693          	addi	a3,a3,-1240 # ffffffffc02070c8 <commands+0x7a8>
ffffffffc02015a8:	00005617          	auipc	a2,0x5
ffffffffc02015ac:	7c860613          	addi	a2,a2,1992 # ffffffffc0206d70 <commands+0x450>
ffffffffc02015b0:	0ba00593          	li	a1,186
ffffffffc02015b4:	00006517          	auipc	a0,0x6
ffffffffc02015b8:	abc50513          	addi	a0,a0,-1348 # ffffffffc0207070 <commands+0x750>
ffffffffc02015bc:	ebffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02015c0 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02015c0:	1141                	addi	sp,sp,-16
ffffffffc02015c2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015c4:	14058463          	beqz	a1,ffffffffc020170c <default_free_pages+0x14c>
    for (; p != base + n; p ++) {
ffffffffc02015c8:	00659693          	slli	a3,a1,0x6
ffffffffc02015cc:	96aa                	add	a3,a3,a0
ffffffffc02015ce:	87aa                	mv	a5,a0
ffffffffc02015d0:	02d50263          	beq	a0,a3,ffffffffc02015f4 <default_free_pages+0x34>
ffffffffc02015d4:	6798                	ld	a4,8(a5)
ffffffffc02015d6:	8b05                	andi	a4,a4,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015d8:	10071a63          	bnez	a4,ffffffffc02016ec <default_free_pages+0x12c>
ffffffffc02015dc:	6798                	ld	a4,8(a5)
ffffffffc02015de:	8b09                	andi	a4,a4,2
ffffffffc02015e0:	10071663          	bnez	a4,ffffffffc02016ec <default_free_pages+0x12c>
        p->flags = 0;
ffffffffc02015e4:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02015e8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ec:	04078793          	addi	a5,a5,64
ffffffffc02015f0:	fed792e3          	bne	a5,a3,ffffffffc02015d4 <default_free_pages+0x14>
    base->property = n;
ffffffffc02015f4:	2581                	sext.w	a1,a1
ffffffffc02015f6:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02015f8:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fc:	4789                	li	a5,2
ffffffffc02015fe:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201602:	000ad697          	auipc	a3,0xad
ffffffffc0201606:	42e68693          	addi	a3,a3,1070 # ffffffffc02aea30 <free_area>
ffffffffc020160a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020160c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc020160e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0201612:	9db9                	addw	a1,a1,a4
ffffffffc0201614:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201616:	0ad78463          	beq	a5,a3,ffffffffc02016be <default_free_pages+0xfe>
            struct Page* page = le2page(le, page_link);
ffffffffc020161a:	fe878713          	addi	a4,a5,-24
ffffffffc020161e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201622:	4581                	li	a1,0
            if (base < page) {
ffffffffc0201624:	00e56a63          	bltu	a0,a4,ffffffffc0201638 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201628:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020162a:	04d70c63          	beq	a4,a3,ffffffffc0201682 <default_free_pages+0xc2>
    for (; p != base + n; p ++) {
ffffffffc020162e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201630:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201634:	fee57ae3          	bgeu	a0,a4,ffffffffc0201628 <default_free_pages+0x68>
ffffffffc0201638:	c199                	beqz	a1,ffffffffc020163e <default_free_pages+0x7e>
ffffffffc020163a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020163e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201640:	e390                	sd	a2,0(a5)
ffffffffc0201642:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201644:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201646:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0201648:	00d70d63          	beq	a4,a3,ffffffffc0201662 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc020164c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201650:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201654:	02059813          	slli	a6,a1,0x20
ffffffffc0201658:	01a85793          	srli	a5,a6,0x1a
ffffffffc020165c:	97b2                	add	a5,a5,a2
ffffffffc020165e:	02f50c63          	beq	a0,a5,ffffffffc0201696 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201662:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201664:	00d78c63          	beq	a5,a3,ffffffffc020167c <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc0201668:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020166a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc020166e:	02061593          	slli	a1,a2,0x20
ffffffffc0201672:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201676:	972a                	add	a4,a4,a0
ffffffffc0201678:	04e68a63          	beq	a3,a4,ffffffffc02016cc <default_free_pages+0x10c>
}
ffffffffc020167c:	60a2                	ld	ra,8(sp)
ffffffffc020167e:	0141                	addi	sp,sp,16
ffffffffc0201680:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201682:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201684:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201686:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201688:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020168a:	02d70763          	beq	a4,a3,ffffffffc02016b8 <default_free_pages+0xf8>
    prev->next = next->prev = elm;
ffffffffc020168e:	8832                	mv	a6,a2
ffffffffc0201690:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201692:	87ba                	mv	a5,a4
ffffffffc0201694:	bf71                	j	ffffffffc0201630 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201696:	491c                	lw	a5,16(a0)
ffffffffc0201698:	9dbd                	addw	a1,a1,a5
ffffffffc020169a:	feb72c23          	sw	a1,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020169e:	57f5                	li	a5,-3
ffffffffc02016a0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016a4:	01853803          	ld	a6,24(a0)
ffffffffc02016a8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02016aa:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016ac:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02016b0:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02016b2:	0105b023          	sd	a6,0(a1)
ffffffffc02016b6:	b77d                	j	ffffffffc0201664 <default_free_pages+0xa4>
ffffffffc02016b8:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ba:	873e                	mv	a4,a5
ffffffffc02016bc:	bf41                	j	ffffffffc020164c <default_free_pages+0x8c>
}
ffffffffc02016be:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016c0:	e390                	sd	a2,0(a5)
ffffffffc02016c2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016c4:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016c6:	ed1c                	sd	a5,24(a0)
ffffffffc02016c8:	0141                	addi	sp,sp,16
ffffffffc02016ca:	8082                	ret
            base->property += p->property;
ffffffffc02016cc:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016d0:	ff078693          	addi	a3,a5,-16
ffffffffc02016d4:	9e39                	addw	a2,a2,a4
ffffffffc02016d6:	c910                	sw	a2,16(a0)
ffffffffc02016d8:	5775                	li	a4,-3
ffffffffc02016da:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016de:	6398                	ld	a4,0(a5)
ffffffffc02016e0:	679c                	ld	a5,8(a5)
}
ffffffffc02016e2:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02016e4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02016e6:	e398                	sd	a4,0(a5)
ffffffffc02016e8:	0141                	addi	sp,sp,16
ffffffffc02016ea:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016ec:	00006697          	auipc	a3,0x6
ffffffffc02016f0:	ccc68693          	addi	a3,a3,-820 # ffffffffc02073b8 <commands+0xa98>
ffffffffc02016f4:	00005617          	auipc	a2,0x5
ffffffffc02016f8:	67c60613          	addi	a2,a2,1660 # ffffffffc0206d70 <commands+0x450>
ffffffffc02016fc:	08300593          	li	a1,131
ffffffffc0201700:	00006517          	auipc	a0,0x6
ffffffffc0201704:	97050513          	addi	a0,a0,-1680 # ffffffffc0207070 <commands+0x750>
ffffffffc0201708:	d73fe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc020170c:	00006697          	auipc	a3,0x6
ffffffffc0201710:	ca468693          	addi	a3,a3,-860 # ffffffffc02073b0 <commands+0xa90>
ffffffffc0201714:	00005617          	auipc	a2,0x5
ffffffffc0201718:	65c60613          	addi	a2,a2,1628 # ffffffffc0206d70 <commands+0x450>
ffffffffc020171c:	08000593          	li	a1,128
ffffffffc0201720:	00006517          	auipc	a0,0x6
ffffffffc0201724:	95050513          	addi	a0,a0,-1712 # ffffffffc0207070 <commands+0x750>
ffffffffc0201728:	d53fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020172c <default_alloc_pages>:
    assert(n > 0);
ffffffffc020172c:	c941                	beqz	a0,ffffffffc02017bc <default_alloc_pages+0x90>
    if (n > nr_free) {
ffffffffc020172e:	000ad597          	auipc	a1,0xad
ffffffffc0201732:	30258593          	addi	a1,a1,770 # ffffffffc02aea30 <free_area>
ffffffffc0201736:	0105a803          	lw	a6,16(a1)
ffffffffc020173a:	872a                	mv	a4,a0
ffffffffc020173c:	02081793          	slli	a5,a6,0x20
ffffffffc0201740:	9381                	srli	a5,a5,0x20
ffffffffc0201742:	00a7ee63          	bltu	a5,a0,ffffffffc020175e <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201746:	87ae                	mv	a5,a1
ffffffffc0201748:	a801                	j	ffffffffc0201758 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc020174a:	ff87a683          	lw	a3,-8(a5)
ffffffffc020174e:	02069613          	slli	a2,a3,0x20
ffffffffc0201752:	9201                	srli	a2,a2,0x20
ffffffffc0201754:	00e67763          	bgeu	a2,a4,ffffffffc0201762 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201758:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020175a:	feb798e3          	bne	a5,a1,ffffffffc020174a <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020175e:	4501                	li	a0,0
}
ffffffffc0201760:	8082                	ret
    return listelm->prev;
ffffffffc0201762:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201766:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020176a:	fe878513          	addi	a0,a5,-24
            p->property = page->property - n;
ffffffffc020176e:	00070e1b          	sext.w	t3,a4
    prev->next = next;
ffffffffc0201772:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201776:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020177a:	02c77863          	bgeu	a4,a2,ffffffffc02017aa <default_alloc_pages+0x7e>
            struct Page *p = page + n;
ffffffffc020177e:	071a                	slli	a4,a4,0x6
ffffffffc0201780:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201782:	41c686bb          	subw	a3,a3,t3
ffffffffc0201786:	cb14                	sw	a3,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201788:	00870613          	addi	a2,a4,8
ffffffffc020178c:	4689                	li	a3,2
ffffffffc020178e:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201792:	0088b683          	ld	a3,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201796:	01870613          	addi	a2,a4,24
        nr_free -= n;
ffffffffc020179a:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc020179e:	e290                	sd	a2,0(a3)
ffffffffc02017a0:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02017a4:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02017a6:	01173c23          	sd	a7,24(a4)
ffffffffc02017aa:	41c8083b          	subw	a6,a6,t3
ffffffffc02017ae:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02017b2:	5775                	li	a4,-3
ffffffffc02017b4:	17c1                	addi	a5,a5,-16
ffffffffc02017b6:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02017ba:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02017bc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02017be:	00006697          	auipc	a3,0x6
ffffffffc02017c2:	bf268693          	addi	a3,a3,-1038 # ffffffffc02073b0 <commands+0xa90>
ffffffffc02017c6:	00005617          	auipc	a2,0x5
ffffffffc02017ca:	5aa60613          	addi	a2,a2,1450 # ffffffffc0206d70 <commands+0x450>
ffffffffc02017ce:	06200593          	li	a1,98
ffffffffc02017d2:	00006517          	auipc	a0,0x6
ffffffffc02017d6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207070 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc02017da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017dc:	c9ffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02017e0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02017e0:	1141                	addi	sp,sp,-16
ffffffffc02017e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02017e4:	c5f1                	beqz	a1,ffffffffc02018b0 <default_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc02017e6:	00659693          	slli	a3,a1,0x6
ffffffffc02017ea:	96aa                	add	a3,a3,a0
ffffffffc02017ec:	87aa                	mv	a5,a0
ffffffffc02017ee:	00d50f63          	beq	a0,a3,ffffffffc020180c <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02017f2:	6798                	ld	a4,8(a5)
ffffffffc02017f4:	8b05                	andi	a4,a4,1
        assert(PageReserved(p));
ffffffffc02017f6:	cf49                	beqz	a4,ffffffffc0201890 <default_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc02017f8:	0007a823          	sw	zero,16(a5)
ffffffffc02017fc:	0007b423          	sd	zero,8(a5)
ffffffffc0201800:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201804:	04078793          	addi	a5,a5,64
ffffffffc0201808:	fed795e3          	bne	a5,a3,ffffffffc02017f2 <default_init_memmap+0x12>
    base->property = n;
ffffffffc020180c:	2581                	sext.w	a1,a1
ffffffffc020180e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201810:	4789                	li	a5,2
ffffffffc0201812:	00850713          	addi	a4,a0,8
ffffffffc0201816:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020181a:	000ad697          	auipc	a3,0xad
ffffffffc020181e:	21668693          	addi	a3,a3,534 # ffffffffc02aea30 <free_area>
ffffffffc0201822:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201824:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201826:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020182a:	9db9                	addw	a1,a1,a4
ffffffffc020182c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020182e:	04d78a63          	beq	a5,a3,ffffffffc0201882 <default_init_memmap+0xa2>
            struct Page* page = le2page(le, page_link);
ffffffffc0201832:	fe878713          	addi	a4,a5,-24
ffffffffc0201836:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020183a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020183c:	00e56a63          	bltu	a0,a4,ffffffffc0201850 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201840:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201842:	02d70263          	beq	a4,a3,ffffffffc0201866 <default_init_memmap+0x86>
    for (; p != base + n; p ++) {
ffffffffc0201846:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201848:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020184c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201840 <default_init_memmap+0x60>
ffffffffc0201850:	c199                	beqz	a1,ffffffffc0201856 <default_init_memmap+0x76>
ffffffffc0201852:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201856:	6398                	ld	a4,0(a5)
}
ffffffffc0201858:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020185a:	e390                	sd	a2,0(a5)
ffffffffc020185c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020185e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201860:	ed18                	sd	a4,24(a0)
ffffffffc0201862:	0141                	addi	sp,sp,16
ffffffffc0201864:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201866:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201868:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020186a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020186c:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020186e:	00d70663          	beq	a4,a3,ffffffffc020187a <default_init_memmap+0x9a>
    prev->next = next->prev = elm;
ffffffffc0201872:	8832                	mv	a6,a2
ffffffffc0201874:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201876:	87ba                	mv	a5,a4
ffffffffc0201878:	bfc1                	j	ffffffffc0201848 <default_init_memmap+0x68>
}
ffffffffc020187a:	60a2                	ld	ra,8(sp)
ffffffffc020187c:	e290                	sd	a2,0(a3)
ffffffffc020187e:	0141                	addi	sp,sp,16
ffffffffc0201880:	8082                	ret
ffffffffc0201882:	60a2                	ld	ra,8(sp)
ffffffffc0201884:	e390                	sd	a2,0(a5)
ffffffffc0201886:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201888:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020188a:	ed1c                	sd	a5,24(a0)
ffffffffc020188c:	0141                	addi	sp,sp,16
ffffffffc020188e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201890:	00006697          	auipc	a3,0x6
ffffffffc0201894:	b5068693          	addi	a3,a3,-1200 # ffffffffc02073e0 <commands+0xac0>
ffffffffc0201898:	00005617          	auipc	a2,0x5
ffffffffc020189c:	4d860613          	addi	a2,a2,1240 # ffffffffc0206d70 <commands+0x450>
ffffffffc02018a0:	04900593          	li	a1,73
ffffffffc02018a4:	00005517          	auipc	a0,0x5
ffffffffc02018a8:	7cc50513          	addi	a0,a0,1996 # ffffffffc0207070 <commands+0x750>
ffffffffc02018ac:	bcffe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(n > 0);
ffffffffc02018b0:	00006697          	auipc	a3,0x6
ffffffffc02018b4:	b0068693          	addi	a3,a3,-1280 # ffffffffc02073b0 <commands+0xa90>
ffffffffc02018b8:	00005617          	auipc	a2,0x5
ffffffffc02018bc:	4b860613          	addi	a2,a2,1208 # ffffffffc0206d70 <commands+0x450>
ffffffffc02018c0:	04600593          	li	a1,70
ffffffffc02018c4:	00005517          	auipc	a0,0x5
ffffffffc02018c8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0207070 <commands+0x750>
ffffffffc02018cc:	baffe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02018d0 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02018d0:	c94d                	beqz	a0,ffffffffc0201982 <slob_free+0xb2>
{
ffffffffc02018d2:	1141                	addi	sp,sp,-16
ffffffffc02018d4:	e022                	sd	s0,0(sp)
ffffffffc02018d6:	e406                	sd	ra,8(sp)
ffffffffc02018d8:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc02018da:	e9c1                	bnez	a1,ffffffffc020196a <slob_free+0x9a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018dc:	100027f3          	csrr	a5,sstatus
ffffffffc02018e0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02018e2:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018e4:	ebd9                	bnez	a5,ffffffffc020197a <slob_free+0xaa>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018e6:	000a6617          	auipc	a2,0xa6
ffffffffc02018ea:	d3a60613          	addi	a2,a2,-710 # ffffffffc02a7620 <slobfree>
ffffffffc02018ee:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018f0:	873e                	mv	a4,a5
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02018f2:	679c                	ld	a5,8(a5)
ffffffffc02018f4:	02877a63          	bgeu	a4,s0,ffffffffc0201928 <slob_free+0x58>
ffffffffc02018f8:	00f46463          	bltu	s0,a5,ffffffffc0201900 <slob_free+0x30>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02018fc:	fef76ae3          	bltu	a4,a5,ffffffffc02018f0 <slob_free+0x20>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201900:	400c                	lw	a1,0(s0)
ffffffffc0201902:	00459693          	slli	a3,a1,0x4
ffffffffc0201906:	96a2                	add	a3,a3,s0
ffffffffc0201908:	02d78a63          	beq	a5,a3,ffffffffc020193c <slob_free+0x6c>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020190c:	4314                	lw	a3,0(a4)
		b->next = cur->next;
ffffffffc020190e:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201910:	00469793          	slli	a5,a3,0x4
ffffffffc0201914:	97ba                	add	a5,a5,a4
ffffffffc0201916:	02f40e63          	beq	s0,a5,ffffffffc0201952 <slob_free+0x82>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc020191a:	e700                	sd	s0,8(a4)

	slobfree = cur;
ffffffffc020191c:	e218                	sd	a4,0(a2)
    if (flag) {
ffffffffc020191e:	e129                	bnez	a0,ffffffffc0201960 <slob_free+0x90>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201920:	60a2                	ld	ra,8(sp)
ffffffffc0201922:	6402                	ld	s0,0(sp)
ffffffffc0201924:	0141                	addi	sp,sp,16
ffffffffc0201926:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201928:	fcf764e3          	bltu	a4,a5,ffffffffc02018f0 <slob_free+0x20>
ffffffffc020192c:	fcf472e3          	bgeu	s0,a5,ffffffffc02018f0 <slob_free+0x20>
	if (b + b->units == cur->next) {
ffffffffc0201930:	400c                	lw	a1,0(s0)
ffffffffc0201932:	00459693          	slli	a3,a1,0x4
ffffffffc0201936:	96a2                	add	a3,a3,s0
ffffffffc0201938:	fcd79ae3          	bne	a5,a3,ffffffffc020190c <slob_free+0x3c>
		b->units += cur->next->units;
ffffffffc020193c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020193e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201940:	9db5                	addw	a1,a1,a3
ffffffffc0201942:	c00c                	sw	a1,0(s0)
	if (cur + cur->units == b) {
ffffffffc0201944:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201946:	e41c                	sd	a5,8(s0)
	if (cur + cur->units == b) {
ffffffffc0201948:	00469793          	slli	a5,a3,0x4
ffffffffc020194c:	97ba                	add	a5,a5,a4
ffffffffc020194e:	fcf416e3          	bne	s0,a5,ffffffffc020191a <slob_free+0x4a>
		cur->units += b->units;
ffffffffc0201952:	401c                	lw	a5,0(s0)
		cur->next = b->next;
ffffffffc0201954:	640c                	ld	a1,8(s0)
	slobfree = cur;
ffffffffc0201956:	e218                	sd	a4,0(a2)
		cur->units += b->units;
ffffffffc0201958:	9ebd                	addw	a3,a3,a5
ffffffffc020195a:	c314                	sw	a3,0(a4)
		cur->next = b->next;
ffffffffc020195c:	e70c                	sd	a1,8(a4)
ffffffffc020195e:	d169                	beqz	a0,ffffffffc0201920 <slob_free+0x50>
}
ffffffffc0201960:	6402                	ld	s0,0(sp)
ffffffffc0201962:	60a2                	ld	ra,8(sp)
ffffffffc0201964:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0201966:	cdbfe06f          	j	ffffffffc0200640 <intr_enable>
		b->units = SLOB_UNITS(size);
ffffffffc020196a:	25bd                	addiw	a1,a1,15
ffffffffc020196c:	8191                	srli	a1,a1,0x4
ffffffffc020196e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201970:	100027f3          	csrr	a5,sstatus
ffffffffc0201974:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201976:	4501                	li	a0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201978:	d7bd                	beqz	a5,ffffffffc02018e6 <slob_free+0x16>
        intr_disable();
ffffffffc020197a:	ccdfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc020197e:	4505                	li	a0,1
ffffffffc0201980:	b79d                	j	ffffffffc02018e6 <slob_free+0x16>
ffffffffc0201982:	8082                	ret

ffffffffc0201984 <__slob_get_free_pages.constprop.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201984:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201986:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201988:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020198c:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc020198e:	352000ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
  if(!page)
ffffffffc0201992:	c91d                	beqz	a0,ffffffffc02019c8 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201994:	000b1697          	auipc	a3,0xb1
ffffffffc0201998:	19c6b683          	ld	a3,412(a3) # ffffffffc02b2b30 <pages>
ffffffffc020199c:	8d15                	sub	a0,a0,a3
ffffffffc020199e:	8519                	srai	a0,a0,0x6
ffffffffc02019a0:	00007697          	auipc	a3,0x7
ffffffffc02019a4:	3d06b683          	ld	a3,976(a3) # ffffffffc0208d70 <nbase>
ffffffffc02019a8:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc02019aa:	00c51793          	slli	a5,a0,0xc
ffffffffc02019ae:	83b1                	srli	a5,a5,0xc
ffffffffc02019b0:	000b1717          	auipc	a4,0xb1
ffffffffc02019b4:	17873703          	ld	a4,376(a4) # ffffffffc02b2b28 <npage>
    return page2ppn(page) << PGSHIFT;
ffffffffc02019b8:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02019ba:	00e7fa63          	bgeu	a5,a4,ffffffffc02019ce <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02019be:	000b1697          	auipc	a3,0xb1
ffffffffc02019c2:	1826b683          	ld	a3,386(a3) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc02019c6:	9536                	add	a0,a0,a3
}
ffffffffc02019c8:	60a2                	ld	ra,8(sp)
ffffffffc02019ca:	0141                	addi	sp,sp,16
ffffffffc02019cc:	8082                	ret
ffffffffc02019ce:	86aa                	mv	a3,a0
ffffffffc02019d0:	00006617          	auipc	a2,0x6
ffffffffc02019d4:	a7060613          	addi	a2,a2,-1424 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc02019d8:	06900593          	li	a1,105
ffffffffc02019dc:	00006517          	auipc	a0,0x6
ffffffffc02019e0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc02019e4:	a97fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02019e8 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02019e8:	1101                	addi	sp,sp,-32
ffffffffc02019ea:	ec06                	sd	ra,24(sp)
ffffffffc02019ec:	e822                	sd	s0,16(sp)
ffffffffc02019ee:	e426                	sd	s1,8(sp)
ffffffffc02019f0:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc02019f2:	01050713          	addi	a4,a0,16
ffffffffc02019f6:	6785                	lui	a5,0x1
ffffffffc02019f8:	0cf77363          	bgeu	a4,a5,ffffffffc0201abe <slob_alloc.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02019fc:	00f50493          	addi	s1,a0,15
ffffffffc0201a00:	8091                	srli	s1,s1,0x4
ffffffffc0201a02:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a04:	10002673          	csrr	a2,sstatus
ffffffffc0201a08:	8a09                	andi	a2,a2,2
ffffffffc0201a0a:	e25d                	bnez	a2,ffffffffc0201ab0 <slob_alloc.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201a0c:	000a6917          	auipc	s2,0xa6
ffffffffc0201a10:	c1490913          	addi	s2,s2,-1004 # ffffffffc02a7620 <slobfree>
ffffffffc0201a14:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a18:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a1a:	4398                	lw	a4,0(a5)
ffffffffc0201a1c:	08975e63          	bge	a4,s1,ffffffffc0201ab8 <slob_alloc.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201a20:	00f68b63          	beq	a3,a5,ffffffffc0201a36 <slob_alloc.constprop.0+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a24:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a26:	4018                	lw	a4,0(s0)
ffffffffc0201a28:	02975a63          	bge	a4,s1,ffffffffc0201a5c <slob_alloc.constprop.0+0x74>
		if (cur == slobfree) {
ffffffffc0201a2c:	00093683          	ld	a3,0(s2)
ffffffffc0201a30:	87a2                	mv	a5,s0
ffffffffc0201a32:	fef699e3          	bne	a3,a5,ffffffffc0201a24 <slob_alloc.constprop.0+0x3c>
    if (flag) {
ffffffffc0201a36:	ee31                	bnez	a2,ffffffffc0201a92 <slob_alloc.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201a38:	4501                	li	a0,0
ffffffffc0201a3a:	f4bff0ef          	jal	ra,ffffffffc0201984 <__slob_get_free_pages.constprop.0>
ffffffffc0201a3e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201a40:	cd05                	beqz	a0,ffffffffc0201a78 <slob_alloc.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201a42:	6585                	lui	a1,0x1
ffffffffc0201a44:	e8dff0ef          	jal	ra,ffffffffc02018d0 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a48:	10002673          	csrr	a2,sstatus
ffffffffc0201a4c:	8a09                	andi	a2,a2,2
ffffffffc0201a4e:	ee05                	bnez	a2,ffffffffc0201a86 <slob_alloc.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201a50:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201a54:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201a56:	4018                	lw	a4,0(s0)
ffffffffc0201a58:	fc974ae3          	blt	a4,s1,ffffffffc0201a2c <slob_alloc.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201a5c:	04e48763          	beq	s1,a4,ffffffffc0201aaa <slob_alloc.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201a60:	00449693          	slli	a3,s1,0x4
ffffffffc0201a64:	96a2                	add	a3,a3,s0
ffffffffc0201a66:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201a68:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201a6a:	9f05                	subw	a4,a4,s1
ffffffffc0201a6c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201a6e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201a70:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201a72:	00f93023          	sd	a5,0(s2)
    if (flag) {
ffffffffc0201a76:	e20d                	bnez	a2,ffffffffc0201a98 <slob_alloc.constprop.0+0xb0>
}
ffffffffc0201a78:	60e2                	ld	ra,24(sp)
ffffffffc0201a7a:	8522                	mv	a0,s0
ffffffffc0201a7c:	6442                	ld	s0,16(sp)
ffffffffc0201a7e:	64a2                	ld	s1,8(sp)
ffffffffc0201a80:	6902                	ld	s2,0(sp)
ffffffffc0201a82:	6105                	addi	sp,sp,32
ffffffffc0201a84:	8082                	ret
        intr_disable();
ffffffffc0201a86:	bc1fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
			cur = slobfree;
ffffffffc0201a8a:	00093783          	ld	a5,0(s2)
        return 1;
ffffffffc0201a8e:	4605                	li	a2,1
ffffffffc0201a90:	b7d1                	j	ffffffffc0201a54 <slob_alloc.constprop.0+0x6c>
        intr_enable();
ffffffffc0201a92:	baffe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201a96:	b74d                	j	ffffffffc0201a38 <slob_alloc.constprop.0+0x50>
ffffffffc0201a98:	ba9fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
}
ffffffffc0201a9c:	60e2                	ld	ra,24(sp)
ffffffffc0201a9e:	8522                	mv	a0,s0
ffffffffc0201aa0:	6442                	ld	s0,16(sp)
ffffffffc0201aa2:	64a2                	ld	s1,8(sp)
ffffffffc0201aa4:	6902                	ld	s2,0(sp)
ffffffffc0201aa6:	6105                	addi	sp,sp,32
ffffffffc0201aa8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201aaa:	6418                	ld	a4,8(s0)
ffffffffc0201aac:	e798                	sd	a4,8(a5)
ffffffffc0201aae:	b7d1                	j	ffffffffc0201a72 <slob_alloc.constprop.0+0x8a>
        intr_disable();
ffffffffc0201ab0:	b97fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0201ab4:	4605                	li	a2,1
ffffffffc0201ab6:	bf99                	j	ffffffffc0201a0c <slob_alloc.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201ab8:	843e                	mv	s0,a5
ffffffffc0201aba:	87b6                	mv	a5,a3
ffffffffc0201abc:	b745                	j	ffffffffc0201a5c <slob_alloc.constprop.0+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201abe:	00006697          	auipc	a3,0x6
ffffffffc0201ac2:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0207478 <default_pmm_manager+0x70>
ffffffffc0201ac6:	00005617          	auipc	a2,0x5
ffffffffc0201aca:	2aa60613          	addi	a2,a2,682 # ffffffffc0206d70 <commands+0x450>
ffffffffc0201ace:	06400593          	li	a1,100
ffffffffc0201ad2:	00006517          	auipc	a0,0x6
ffffffffc0201ad6:	9c650513          	addi	a0,a0,-1594 # ffffffffc0207498 <default_pmm_manager+0x90>
ffffffffc0201ada:	9a1fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ade <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201ade:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201ae0:	00006517          	auipc	a0,0x6
ffffffffc0201ae4:	9d050513          	addi	a0,a0,-1584 # ffffffffc02074b0 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc0201ae8:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201aea:	e96fe0ef          	jal	ra,ffffffffc0200180 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201af0:	00006517          	auipc	a0,0x6
ffffffffc0201af4:	9d850513          	addi	a0,a0,-1576 # ffffffffc02074c8 <default_pmm_manager+0xc0>
}
ffffffffc0201af8:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201afa:	e86fe06f          	j	ffffffffc0200180 <cprintf>

ffffffffc0201afe <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201afe:	4501                	li	a0,0
ffffffffc0201b00:	8082                	ret

ffffffffc0201b02 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201b02:	1101                	addi	sp,sp,-32
ffffffffc0201b04:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b06:	6905                	lui	s2,0x1
{
ffffffffc0201b08:	e822                	sd	s0,16(sp)
ffffffffc0201b0a:	ec06                	sd	ra,24(sp)
ffffffffc0201b0c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b0e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8bf1>
{
ffffffffc0201b12:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201b14:	04a7f963          	bgeu	a5,a0,ffffffffc0201b66 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201b18:	4561                	li	a0,24
ffffffffc0201b1a:	ecfff0ef          	jal	ra,ffffffffc02019e8 <slob_alloc.constprop.0>
ffffffffc0201b1e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201b20:	c929                	beqz	a0,ffffffffc0201b72 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201b22:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201b26:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b28:	00f95763          	bge	s2,a5,ffffffffc0201b36 <kmalloc+0x34>
ffffffffc0201b2c:	6705                	lui	a4,0x1
ffffffffc0201b2e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201b30:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201b32:	fef74ee3          	blt	a4,a5,ffffffffc0201b2e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201b36:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201b38:	e4dff0ef          	jal	ra,ffffffffc0201984 <__slob_get_free_pages.constprop.0>
ffffffffc0201b3c:	e488                	sd	a0,8(s1)
ffffffffc0201b3e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201b40:	c525                	beqz	a0,ffffffffc0201ba8 <kmalloc+0xa6>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b42:	100027f3          	csrr	a5,sstatus
ffffffffc0201b46:	8b89                	andi	a5,a5,2
ffffffffc0201b48:	ef8d                	bnez	a5,ffffffffc0201b82 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201b4a:	000b1797          	auipc	a5,0xb1
ffffffffc0201b4e:	fc678793          	addi	a5,a5,-58 # ffffffffc02b2b10 <bigblocks>
ffffffffc0201b52:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b54:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b56:	e898                	sd	a4,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201b58:	60e2                	ld	ra,24(sp)
ffffffffc0201b5a:	8522                	mv	a0,s0
ffffffffc0201b5c:	6442                	ld	s0,16(sp)
ffffffffc0201b5e:	64a2                	ld	s1,8(sp)
ffffffffc0201b60:	6902                	ld	s2,0(sp)
ffffffffc0201b62:	6105                	addi	sp,sp,32
ffffffffc0201b64:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201b66:	0541                	addi	a0,a0,16
ffffffffc0201b68:	e81ff0ef          	jal	ra,ffffffffc02019e8 <slob_alloc.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201b6c:	01050413          	addi	s0,a0,16
ffffffffc0201b70:	f565                	bnez	a0,ffffffffc0201b58 <kmalloc+0x56>
ffffffffc0201b72:	4401                	li	s0,0
}
ffffffffc0201b74:	60e2                	ld	ra,24(sp)
ffffffffc0201b76:	8522                	mv	a0,s0
ffffffffc0201b78:	6442                	ld	s0,16(sp)
ffffffffc0201b7a:	64a2                	ld	s1,8(sp)
ffffffffc0201b7c:	6902                	ld	s2,0(sp)
ffffffffc0201b7e:	6105                	addi	sp,sp,32
ffffffffc0201b80:	8082                	ret
        intr_disable();
ffffffffc0201b82:	ac5fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201b86:	000b1797          	auipc	a5,0xb1
ffffffffc0201b8a:	f8a78793          	addi	a5,a5,-118 # ffffffffc02b2b10 <bigblocks>
ffffffffc0201b8e:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201b90:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201b92:	e898                	sd	a4,16(s1)
        intr_enable();
ffffffffc0201b94:	aadfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
		return bb->pages;
ffffffffc0201b98:	6480                	ld	s0,8(s1)
}
ffffffffc0201b9a:	60e2                	ld	ra,24(sp)
ffffffffc0201b9c:	64a2                	ld	s1,8(sp)
ffffffffc0201b9e:	8522                	mv	a0,s0
ffffffffc0201ba0:	6442                	ld	s0,16(sp)
ffffffffc0201ba2:	6902                	ld	s2,0(sp)
ffffffffc0201ba4:	6105                	addi	sp,sp,32
ffffffffc0201ba6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ba8:	45e1                	li	a1,24
ffffffffc0201baa:	8526                	mv	a0,s1
ffffffffc0201bac:	d25ff0ef          	jal	ra,ffffffffc02018d0 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201bb0:	b765                	j	ffffffffc0201b58 <kmalloc+0x56>

ffffffffc0201bb2 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201bb2:	c169                	beqz	a0,ffffffffc0201c74 <kfree+0xc2>
{
ffffffffc0201bb4:	1101                	addi	sp,sp,-32
ffffffffc0201bb6:	e822                	sd	s0,16(sp)
ffffffffc0201bb8:	ec06                	sd	ra,24(sp)
ffffffffc0201bba:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201bbc:	03451793          	slli	a5,a0,0x34
ffffffffc0201bc0:	842a                	mv	s0,a0
ffffffffc0201bc2:	e3d9                	bnez	a5,ffffffffc0201c48 <kfree+0x96>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc8:	8b89                	andi	a5,a5,2
ffffffffc0201bca:	e7d9                	bnez	a5,ffffffffc0201c58 <kfree+0xa6>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201bcc:	000b1797          	auipc	a5,0xb1
ffffffffc0201bd0:	f447b783          	ld	a5,-188(a5) # ffffffffc02b2b10 <bigblocks>
    return 0;
ffffffffc0201bd4:	4601                	li	a2,0
ffffffffc0201bd6:	cbad                	beqz	a5,ffffffffc0201c48 <kfree+0x96>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201bd8:	000b1697          	auipc	a3,0xb1
ffffffffc0201bdc:	f3868693          	addi	a3,a3,-200 # ffffffffc02b2b10 <bigblocks>
ffffffffc0201be0:	a021                	j	ffffffffc0201be8 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201be2:	01048693          	addi	a3,s1,16
ffffffffc0201be6:	c3a5                	beqz	a5,ffffffffc0201c46 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201be8:	6798                	ld	a4,8(a5)
ffffffffc0201bea:	84be                	mv	s1,a5
				*last = bb->next;
ffffffffc0201bec:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {
ffffffffc0201bee:	fe871ae3          	bne	a4,s0,ffffffffc0201be2 <kfree+0x30>
				*last = bb->next;
ffffffffc0201bf2:	e29c                	sd	a5,0(a3)
    if (flag) {
ffffffffc0201bf4:	ee2d                	bnez	a2,ffffffffc0201c6e <kfree+0xbc>
    return pa2page(PADDR(kva));
ffffffffc0201bf6:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201bfa:	4098                	lw	a4,0(s1)
ffffffffc0201bfc:	08f46963          	bltu	s0,a5,ffffffffc0201c8e <kfree+0xdc>
ffffffffc0201c00:	000b1697          	auipc	a3,0xb1
ffffffffc0201c04:	f406b683          	ld	a3,-192(a3) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0201c08:	8c15                	sub	s0,s0,a3
    if (PPN(pa) >= npage) {
ffffffffc0201c0a:	8031                	srli	s0,s0,0xc
ffffffffc0201c0c:	000b1797          	auipc	a5,0xb1
ffffffffc0201c10:	f1c7b783          	ld	a5,-228(a5) # ffffffffc02b2b28 <npage>
ffffffffc0201c14:	06f47163          	bgeu	s0,a5,ffffffffc0201c76 <kfree+0xc4>
    return &pages[PPN(pa) - nbase];
ffffffffc0201c18:	00007517          	auipc	a0,0x7
ffffffffc0201c1c:	15853503          	ld	a0,344(a0) # ffffffffc0208d70 <nbase>
ffffffffc0201c20:	8c09                	sub	s0,s0,a0
ffffffffc0201c22:	041a                	slli	s0,s0,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201c24:	000b1517          	auipc	a0,0xb1
ffffffffc0201c28:	f0c53503          	ld	a0,-244(a0) # ffffffffc02b2b30 <pages>
ffffffffc0201c2c:	4585                	li	a1,1
ffffffffc0201c2e:	9522                	add	a0,a0,s0
ffffffffc0201c30:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201c34:	13e000ef          	jal	ra,ffffffffc0201d72 <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201c38:	6442                	ld	s0,16(sp)
ffffffffc0201c3a:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c3c:	8526                	mv	a0,s1
}
ffffffffc0201c3e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c40:	45e1                	li	a1,24
}
ffffffffc0201c42:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c44:	b171                	j	ffffffffc02018d0 <slob_free>
ffffffffc0201c46:	e20d                	bnez	a2,ffffffffc0201c68 <kfree+0xb6>
ffffffffc0201c48:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201c4c:	6442                	ld	s0,16(sp)
ffffffffc0201c4e:	60e2                	ld	ra,24(sp)
ffffffffc0201c50:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c52:	4581                	li	a1,0
}
ffffffffc0201c54:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201c56:	b9ad                	j	ffffffffc02018d0 <slob_free>
        intr_disable();
ffffffffc0201c58:	9effe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201c5c:	000b1797          	auipc	a5,0xb1
ffffffffc0201c60:	eb47b783          	ld	a5,-332(a5) # ffffffffc02b2b10 <bigblocks>
        return 1;
ffffffffc0201c64:	4605                	li	a2,1
ffffffffc0201c66:	fbad                	bnez	a5,ffffffffc0201bd8 <kfree+0x26>
        intr_enable();
ffffffffc0201c68:	9d9fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c6c:	bff1                	j	ffffffffc0201c48 <kfree+0x96>
ffffffffc0201c6e:	9d3fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0201c72:	b751                	j	ffffffffc0201bf6 <kfree+0x44>
ffffffffc0201c74:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201c76:	00006617          	auipc	a2,0x6
ffffffffc0201c7a:	89a60613          	addi	a2,a2,-1894 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0201c7e:	06200593          	li	a1,98
ffffffffc0201c82:	00005517          	auipc	a0,0x5
ffffffffc0201c86:	7e650513          	addi	a0,a0,2022 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0201c8a:	ff0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201c8e:	86a2                	mv	a3,s0
ffffffffc0201c90:	00006617          	auipc	a2,0x6
ffffffffc0201c94:	85860613          	addi	a2,a2,-1960 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0201c98:	06e00593          	li	a1,110
ffffffffc0201c9c:	00005517          	auipc	a0,0x5
ffffffffc0201ca0:	7cc50513          	addi	a0,a0,1996 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0201ca4:	fd6fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ca8 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0201ca8:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201caa:	00006617          	auipc	a2,0x6
ffffffffc0201cae:	86660613          	addi	a2,a2,-1946 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0201cb2:	06200593          	li	a1,98
ffffffffc0201cb6:	00005517          	auipc	a0,0x5
ffffffffc0201cba:	7b250513          	addi	a0,a0,1970 # ffffffffc0207468 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0201cbe:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201cc0:	fbafe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201cc4 <pte2page.part.0>:
pte2page(pte_t pte) {
ffffffffc0201cc4:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc0201cc6:	00006617          	auipc	a2,0x6
ffffffffc0201cca:	86a60613          	addi	a2,a2,-1942 # ffffffffc0207530 <default_pmm_manager+0x128>
ffffffffc0201cce:	07400593          	li	a1,116
ffffffffc0201cd2:	00005517          	auipc	a0,0x5
ffffffffc0201cd6:	79650513          	addi	a0,a0,1942 # ffffffffc0207468 <default_pmm_manager+0x60>
pte2page(pte_t pte) {
ffffffffc0201cda:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc0201cdc:	f9efe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201ce0 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201ce0:	7139                	addi	sp,sp,-64
ffffffffc0201ce2:	f426                	sd	s1,40(sp)
ffffffffc0201ce4:	f04a                	sd	s2,32(sp)
ffffffffc0201ce6:	ec4e                	sd	s3,24(sp)
ffffffffc0201ce8:	e852                	sd	s4,16(sp)
ffffffffc0201cea:	e456                	sd	s5,8(sp)
ffffffffc0201cec:	e05a                	sd	s6,0(sp)
ffffffffc0201cee:	fc06                	sd	ra,56(sp)
ffffffffc0201cf0:	f822                	sd	s0,48(sp)
ffffffffc0201cf2:	84aa                	mv	s1,a0
ffffffffc0201cf4:	000b1917          	auipc	s2,0xb1
ffffffffc0201cf8:	e4490913          	addi	s2,s2,-444 # ffffffffc02b2b38 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201cfc:	4a05                	li	s4,1
ffffffffc0201cfe:	000b1a97          	auipc	s5,0xb1
ffffffffc0201d02:	e5aa8a93          	addi	s5,s5,-422 # ffffffffc02b2b58 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d06:	0005099b          	sext.w	s3,a0
ffffffffc0201d0a:	000b1b17          	auipc	s6,0xb1
ffffffffc0201d0e:	e56b0b13          	addi	s6,s6,-426 # ffffffffc02b2b60 <check_mm_struct>
ffffffffc0201d12:	a01d                	j	ffffffffc0201d38 <alloc_pages+0x58>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d14:	00093783          	ld	a5,0(s2)
ffffffffc0201d18:	6f9c                	ld	a5,24(a5)
ffffffffc0201d1a:	9782                	jalr	a5
ffffffffc0201d1c:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d1e:	4601                	li	a2,0
ffffffffc0201d20:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d22:	ec0d                	bnez	s0,ffffffffc0201d5c <alloc_pages+0x7c>
ffffffffc0201d24:	029a6c63          	bltu	s4,s1,ffffffffc0201d5c <alloc_pages+0x7c>
ffffffffc0201d28:	000aa783          	lw	a5,0(s5)
ffffffffc0201d2c:	2781                	sext.w	a5,a5
ffffffffc0201d2e:	c79d                	beqz	a5,ffffffffc0201d5c <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d30:	000b3503          	ld	a0,0(s6)
ffffffffc0201d34:	683010ef          	jal	ra,ffffffffc0203bb6 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d38:	100027f3          	csrr	a5,sstatus
ffffffffc0201d3c:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201d3e:	8526                	mv	a0,s1
ffffffffc0201d40:	dbf1                	beqz	a5,ffffffffc0201d14 <alloc_pages+0x34>
        intr_disable();
ffffffffc0201d42:	905fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0201d46:	00093783          	ld	a5,0(s2)
ffffffffc0201d4a:	8526                	mv	a0,s1
ffffffffc0201d4c:	6f9c                	ld	a5,24(a5)
ffffffffc0201d4e:	9782                	jalr	a5
ffffffffc0201d50:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201d52:	8effe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201d56:	4601                	li	a2,0
ffffffffc0201d58:	85ce                	mv	a1,s3
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201d5a:	d469                	beqz	s0,ffffffffc0201d24 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201d5c:	70e2                	ld	ra,56(sp)
ffffffffc0201d5e:	8522                	mv	a0,s0
ffffffffc0201d60:	7442                	ld	s0,48(sp)
ffffffffc0201d62:	74a2                	ld	s1,40(sp)
ffffffffc0201d64:	7902                	ld	s2,32(sp)
ffffffffc0201d66:	69e2                	ld	s3,24(sp)
ffffffffc0201d68:	6a42                	ld	s4,16(sp)
ffffffffc0201d6a:	6aa2                	ld	s5,8(sp)
ffffffffc0201d6c:	6b02                	ld	s6,0(sp)
ffffffffc0201d6e:	6121                	addi	sp,sp,64
ffffffffc0201d70:	8082                	ret

ffffffffc0201d72 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d72:	100027f3          	csrr	a5,sstatus
ffffffffc0201d76:	8b89                	andi	a5,a5,2
ffffffffc0201d78:	e799                	bnez	a5,ffffffffc0201d86 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201d7a:	000b1797          	auipc	a5,0xb1
ffffffffc0201d7e:	dbe7b783          	ld	a5,-578(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc0201d82:	739c                	ld	a5,32(a5)
ffffffffc0201d84:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201d86:	1101                	addi	sp,sp,-32
ffffffffc0201d88:	ec06                	sd	ra,24(sp)
ffffffffc0201d8a:	e822                	sd	s0,16(sp)
ffffffffc0201d8c:	e426                	sd	s1,8(sp)
ffffffffc0201d8e:	842a                	mv	s0,a0
ffffffffc0201d90:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201d92:	8b5fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201d96:	000b1797          	auipc	a5,0xb1
ffffffffc0201d9a:	da27b783          	ld	a5,-606(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc0201d9e:	739c                	ld	a5,32(a5)
ffffffffc0201da0:	85a6                	mv	a1,s1
ffffffffc0201da2:	8522                	mv	a0,s0
ffffffffc0201da4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201da6:	6442                	ld	s0,16(sp)
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
ffffffffc0201dac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201dae:	893fe06f          	j	ffffffffc0200640 <intr_enable>

ffffffffc0201db2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db2:	100027f3          	csrr	a5,sstatus
ffffffffc0201db6:	8b89                	andi	a5,a5,2
ffffffffc0201db8:	e799                	bnez	a5,ffffffffc0201dc6 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dba:	000b1797          	auipc	a5,0xb1
ffffffffc0201dbe:	d7e7b783          	ld	a5,-642(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc0201dc2:	779c                	ld	a5,40(a5)
ffffffffc0201dc4:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc0201dc6:	1141                	addi	sp,sp,-16
ffffffffc0201dc8:	e406                	sd	ra,8(sp)
ffffffffc0201dca:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201dcc:	87bfe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201dd0:	000b1797          	auipc	a5,0xb1
ffffffffc0201dd4:	d687b783          	ld	a5,-664(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc0201dd8:	779c                	ld	a5,40(a5)
ffffffffc0201dda:	9782                	jalr	a5
ffffffffc0201ddc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201dde:	863fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201de2:	60a2                	ld	ra,8(sp)
ffffffffc0201de4:	8522                	mv	a0,s0
ffffffffc0201de6:	6402                	ld	s0,0(sp)
ffffffffc0201de8:	0141                	addi	sp,sp,16
ffffffffc0201dea:	8082                	ret

ffffffffc0201dec <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dec:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201df0:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df4:	7139                	addi	sp,sp,-64
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201df6:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201df8:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201dfa:	00f504b3          	add	s1,a0,a5
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201dfe:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e00:	f04a                	sd	s2,32(sp)
ffffffffc0201e02:	ec4e                	sd	s3,24(sp)
ffffffffc0201e04:	e852                	sd	s4,16(sp)
ffffffffc0201e06:	fc06                	sd	ra,56(sp)
ffffffffc0201e08:	f822                	sd	s0,48(sp)
ffffffffc0201e0a:	e456                	sd	s5,8(sp)
ffffffffc0201e0c:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e0e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201e12:	892e                	mv	s2,a1
ffffffffc0201e14:	89b2                	mv	s3,a2
ffffffffc0201e16:	000b1a17          	auipc	s4,0xb1
ffffffffc0201e1a:	d12a0a13          	addi	s4,s4,-750 # ffffffffc02b2b28 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201e1e:	e7b5                	bnez	a5,ffffffffc0201e8a <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201e20:	12060b63          	beqz	a2,ffffffffc0201f56 <get_pte+0x16a>
ffffffffc0201e24:	4505                	li	a0,1
ffffffffc0201e26:	ebbff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201e2a:	842a                	mv	s0,a0
ffffffffc0201e2c:	12050563          	beqz	a0,ffffffffc0201f56 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201e30:	000b1b17          	auipc	s6,0xb1
ffffffffc0201e34:	d00b0b13          	addi	s6,s6,-768 # ffffffffc02b2b30 <pages>
ffffffffc0201e38:	000b3503          	ld	a0,0(s6)
ffffffffc0201e3c:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e40:	000b1a17          	auipc	s4,0xb1
ffffffffc0201e44:	ce8a0a13          	addi	s4,s4,-792 # ffffffffc02b2b28 <npage>
ffffffffc0201e48:	40a40533          	sub	a0,s0,a0
ffffffffc0201e4c:	8519                	srai	a0,a0,0x6
ffffffffc0201e4e:	9556                	add	a0,a0,s5
ffffffffc0201e50:	000a3703          	ld	a4,0(s4)
ffffffffc0201e54:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201e58:	4685                	li	a3,1
ffffffffc0201e5a:	c014                	sw	a3,0(s0)
ffffffffc0201e5c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e5e:	0532                	slli	a0,a0,0xc
ffffffffc0201e60:	14e7f263          	bgeu	a5,a4,ffffffffc0201fa4 <get_pte+0x1b8>
ffffffffc0201e64:	000b1797          	auipc	a5,0xb1
ffffffffc0201e68:	cdc7b783          	ld	a5,-804(a5) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0201e6c:	6605                	lui	a2,0x1
ffffffffc0201e6e:	4581                	li	a1,0
ffffffffc0201e70:	953e                	add	a0,a0,a5
ffffffffc0201e72:	01d040ef          	jal	ra,ffffffffc020668e <memset>
    return page - pages + nbase;
ffffffffc0201e76:	000b3683          	ld	a3,0(s6)
ffffffffc0201e7a:	40d406b3          	sub	a3,s0,a3
ffffffffc0201e7e:	8699                	srai	a3,a3,0x6
ffffffffc0201e80:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201e82:	06aa                	slli	a3,a3,0xa
ffffffffc0201e84:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201e88:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e8a:	77fd                	lui	a5,0xfffff
ffffffffc0201e8c:	068a                	slli	a3,a3,0x2
ffffffffc0201e8e:	000a3703          	ld	a4,0(s4)
ffffffffc0201e92:	8efd                	and	a3,a3,a5
ffffffffc0201e94:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201e98:	0ce7f163          	bgeu	a5,a4,ffffffffc0201f5a <get_pte+0x16e>
ffffffffc0201e9c:	000b1a97          	auipc	s5,0xb1
ffffffffc0201ea0:	ca4a8a93          	addi	s5,s5,-860 # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0201ea4:	000ab403          	ld	s0,0(s5)
ffffffffc0201ea8:	01595793          	srli	a5,s2,0x15
ffffffffc0201eac:	1ff7f793          	andi	a5,a5,511
ffffffffc0201eb0:	96a2                	add	a3,a3,s0
ffffffffc0201eb2:	00379413          	slli	s0,a5,0x3
ffffffffc0201eb6:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201eb8:	6014                	ld	a3,0(s0)
ffffffffc0201eba:	0016f793          	andi	a5,a3,1
ffffffffc0201ebe:	e3ad                	bnez	a5,ffffffffc0201f20 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201ec0:	08098b63          	beqz	s3,ffffffffc0201f56 <get_pte+0x16a>
ffffffffc0201ec4:	4505                	li	a0,1
ffffffffc0201ec6:	e1bff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0201eca:	84aa                	mv	s1,a0
ffffffffc0201ecc:	c549                	beqz	a0,ffffffffc0201f56 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201ece:	000b1b17          	auipc	s6,0xb1
ffffffffc0201ed2:	c62b0b13          	addi	s6,s6,-926 # ffffffffc02b2b30 <pages>
ffffffffc0201ed6:	000b3503          	ld	a0,0(s6)
ffffffffc0201eda:	000809b7          	lui	s3,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201ede:	000a3703          	ld	a4,0(s4)
ffffffffc0201ee2:	40a48533          	sub	a0,s1,a0
ffffffffc0201ee6:	8519                	srai	a0,a0,0x6
ffffffffc0201ee8:	954e                	add	a0,a0,s3
ffffffffc0201eea:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201eee:	4685                	li	a3,1
ffffffffc0201ef0:	c094                	sw	a3,0(s1)
ffffffffc0201ef2:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ef4:	0532                	slli	a0,a0,0xc
ffffffffc0201ef6:	08e7fa63          	bgeu	a5,a4,ffffffffc0201f8a <get_pte+0x19e>
ffffffffc0201efa:	000ab783          	ld	a5,0(s5)
ffffffffc0201efe:	6605                	lui	a2,0x1
ffffffffc0201f00:	4581                	li	a1,0
ffffffffc0201f02:	953e                	add	a0,a0,a5
ffffffffc0201f04:	78a040ef          	jal	ra,ffffffffc020668e <memset>
    return page - pages + nbase;
ffffffffc0201f08:	000b3683          	ld	a3,0(s6)
ffffffffc0201f0c:	40d486b3          	sub	a3,s1,a3
ffffffffc0201f10:	8699                	srai	a3,a3,0x6
ffffffffc0201f12:	96ce                	add	a3,a3,s3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f14:	06aa                	slli	a3,a3,0xa
ffffffffc0201f16:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f1a:	e014                	sd	a3,0(s0)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f1c:	000a3703          	ld	a4,0(s4)
ffffffffc0201f20:	068a                	slli	a3,a3,0x2
ffffffffc0201f22:	757d                	lui	a0,0xfffff
ffffffffc0201f24:	8ee9                	and	a3,a3,a0
ffffffffc0201f26:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f2a:	04e7f463          	bgeu	a5,a4,ffffffffc0201f72 <get_pte+0x186>
ffffffffc0201f2e:	000ab503          	ld	a0,0(s5)
ffffffffc0201f32:	00c95913          	srli	s2,s2,0xc
ffffffffc0201f36:	1ff97913          	andi	s2,s2,511
ffffffffc0201f3a:	96aa                	add	a3,a3,a0
ffffffffc0201f3c:	00391513          	slli	a0,s2,0x3
ffffffffc0201f40:	9536                	add	a0,a0,a3
}
ffffffffc0201f42:	70e2                	ld	ra,56(sp)
ffffffffc0201f44:	7442                	ld	s0,48(sp)
ffffffffc0201f46:	74a2                	ld	s1,40(sp)
ffffffffc0201f48:	7902                	ld	s2,32(sp)
ffffffffc0201f4a:	69e2                	ld	s3,24(sp)
ffffffffc0201f4c:	6a42                	ld	s4,16(sp)
ffffffffc0201f4e:	6aa2                	ld	s5,8(sp)
ffffffffc0201f50:	6b02                	ld	s6,0(sp)
ffffffffc0201f52:	6121                	addi	sp,sp,64
ffffffffc0201f54:	8082                	ret
            return NULL;
ffffffffc0201f56:	4501                	li	a0,0
ffffffffc0201f58:	b7ed                	j	ffffffffc0201f42 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f5a:	00005617          	auipc	a2,0x5
ffffffffc0201f5e:	4e660613          	addi	a2,a2,1254 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0201f62:	0e300593          	li	a1,227
ffffffffc0201f66:	00005517          	auipc	a0,0x5
ffffffffc0201f6a:	5f250513          	addi	a0,a0,1522 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0201f6e:	d0cfe0ef          	jal	ra,ffffffffc020047a <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f72:	00005617          	auipc	a2,0x5
ffffffffc0201f76:	4ce60613          	addi	a2,a2,1230 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0201f7a:	0ee00593          	li	a1,238
ffffffffc0201f7e:	00005517          	auipc	a0,0x5
ffffffffc0201f82:	5da50513          	addi	a0,a0,1498 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0201f86:	cf4fe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f8a:	86aa                	mv	a3,a0
ffffffffc0201f8c:	00005617          	auipc	a2,0x5
ffffffffc0201f90:	4b460613          	addi	a2,a2,1204 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0201f94:	0eb00593          	li	a1,235
ffffffffc0201f98:	00005517          	auipc	a0,0x5
ffffffffc0201f9c:	5c050513          	addi	a0,a0,1472 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0201fa0:	cdafe0ef          	jal	ra,ffffffffc020047a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fa4:	86aa                	mv	a3,a0
ffffffffc0201fa6:	00005617          	auipc	a2,0x5
ffffffffc0201faa:	49a60613          	addi	a2,a2,1178 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0201fae:	0df00593          	li	a1,223
ffffffffc0201fb2:	00005517          	auipc	a0,0x5
ffffffffc0201fb6:	5a650513          	addi	a0,a0,1446 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0201fba:	cc0fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0201fbe <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fbe:	1141                	addi	sp,sp,-16
ffffffffc0201fc0:	e022                	sd	s0,0(sp)
ffffffffc0201fc2:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fc4:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201fc6:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201fc8:	e25ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201fcc:	c011                	beqz	s0,ffffffffc0201fd0 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201fce:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fd0:	c511                	beqz	a0,ffffffffc0201fdc <get_page+0x1e>
ffffffffc0201fd2:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201fd4:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201fd6:	0017f713          	andi	a4,a5,1
ffffffffc0201fda:	e709                	bnez	a4,ffffffffc0201fe4 <get_page+0x26>
}
ffffffffc0201fdc:	60a2                	ld	ra,8(sp)
ffffffffc0201fde:	6402                	ld	s0,0(sp)
ffffffffc0201fe0:	0141                	addi	sp,sp,16
ffffffffc0201fe2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201fe4:	078a                	slli	a5,a5,0x2
ffffffffc0201fe6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fe8:	000b1717          	auipc	a4,0xb1
ffffffffc0201fec:	b4073703          	ld	a4,-1216(a4) # ffffffffc02b2b28 <npage>
ffffffffc0201ff0:	00e7ff63          	bgeu	a5,a4,ffffffffc020200e <get_page+0x50>
ffffffffc0201ff4:	60a2                	ld	ra,8(sp)
ffffffffc0201ff6:	6402                	ld	s0,0(sp)
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff8:	fff80537          	lui	a0,0xfff80
ffffffffc0201ffc:	97aa                	add	a5,a5,a0
ffffffffc0201ffe:	079a                	slli	a5,a5,0x6
ffffffffc0202000:	000b1517          	auipc	a0,0xb1
ffffffffc0202004:	b3053503          	ld	a0,-1232(a0) # ffffffffc02b2b30 <pages>
ffffffffc0202008:	953e                	add	a0,a0,a5
ffffffffc020200a:	0141                	addi	sp,sp,16
ffffffffc020200c:	8082                	ret
ffffffffc020200e:	c9bff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202012 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202012:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202014:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202018:	f486                	sd	ra,104(sp)
ffffffffc020201a:	f0a2                	sd	s0,96(sp)
ffffffffc020201c:	eca6                	sd	s1,88(sp)
ffffffffc020201e:	e8ca                	sd	s2,80(sp)
ffffffffc0202020:	e4ce                	sd	s3,72(sp)
ffffffffc0202022:	e0d2                	sd	s4,64(sp)
ffffffffc0202024:	fc56                	sd	s5,56(sp)
ffffffffc0202026:	f85a                	sd	s6,48(sp)
ffffffffc0202028:	f45e                	sd	s7,40(sp)
ffffffffc020202a:	f062                	sd	s8,32(sp)
ffffffffc020202c:	ec66                	sd	s9,24(sp)
ffffffffc020202e:	e86a                	sd	s10,16(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202030:	17d2                	slli	a5,a5,0x34
ffffffffc0202032:	e3ed                	bnez	a5,ffffffffc0202114 <unmap_range+0x102>
    assert(USER_ACCESS(start, end));
ffffffffc0202034:	002007b7          	lui	a5,0x200
ffffffffc0202038:	842e                	mv	s0,a1
ffffffffc020203a:	0ef5ed63          	bltu	a1,a5,ffffffffc0202134 <unmap_range+0x122>
ffffffffc020203e:	8932                	mv	s2,a2
ffffffffc0202040:	0ec5fa63          	bgeu	a1,a2,ffffffffc0202134 <unmap_range+0x122>
ffffffffc0202044:	4785                	li	a5,1
ffffffffc0202046:	07fe                	slli	a5,a5,0x1f
ffffffffc0202048:	0ec7e663          	bltu	a5,a2,ffffffffc0202134 <unmap_range+0x122>
ffffffffc020204c:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc020204e:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202050:	000b1c97          	auipc	s9,0xb1
ffffffffc0202054:	ad8c8c93          	addi	s9,s9,-1320 # ffffffffc02b2b28 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202058:	000b1c17          	auipc	s8,0xb1
ffffffffc020205c:	ad8c0c13          	addi	s8,s8,-1320 # ffffffffc02b2b30 <pages>
ffffffffc0202060:	fff80bb7          	lui	s7,0xfff80
        pmm_manager->free_pages(base, n);
ffffffffc0202064:	000b1d17          	auipc	s10,0xb1
ffffffffc0202068:	ad4d0d13          	addi	s10,s10,-1324 # ffffffffc02b2b38 <pmm_manager>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020206c:	00200b37          	lui	s6,0x200
ffffffffc0202070:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202074:	4601                	li	a2,0
ffffffffc0202076:	85a2                	mv	a1,s0
ffffffffc0202078:	854e                	mv	a0,s3
ffffffffc020207a:	d73ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020207e:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc0202080:	cd29                	beqz	a0,ffffffffc02020da <unmap_range+0xc8>
        if (*ptep != 0) {
ffffffffc0202082:	611c                	ld	a5,0(a0)
ffffffffc0202084:	e395                	bnez	a5,ffffffffc02020a8 <unmap_range+0x96>
        start += PGSIZE;
ffffffffc0202086:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202088:	ff2466e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x62>
}
ffffffffc020208c:	70a6                	ld	ra,104(sp)
ffffffffc020208e:	7406                	ld	s0,96(sp)
ffffffffc0202090:	64e6                	ld	s1,88(sp)
ffffffffc0202092:	6946                	ld	s2,80(sp)
ffffffffc0202094:	69a6                	ld	s3,72(sp)
ffffffffc0202096:	6a06                	ld	s4,64(sp)
ffffffffc0202098:	7ae2                	ld	s5,56(sp)
ffffffffc020209a:	7b42                	ld	s6,48(sp)
ffffffffc020209c:	7ba2                	ld	s7,40(sp)
ffffffffc020209e:	7c02                	ld	s8,32(sp)
ffffffffc02020a0:	6ce2                	ld	s9,24(sp)
ffffffffc02020a2:	6d42                	ld	s10,16(sp)
ffffffffc02020a4:	6165                	addi	sp,sp,112
ffffffffc02020a6:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02020a8:	0017f713          	andi	a4,a5,1
ffffffffc02020ac:	df69                	beqz	a4,ffffffffc0202086 <unmap_range+0x74>
    if (PPN(pa) >= npage) {
ffffffffc02020ae:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02020b2:	078a                	slli	a5,a5,0x2
ffffffffc02020b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020b6:	08e7ff63          	bgeu	a5,a4,ffffffffc0202154 <unmap_range+0x142>
    return &pages[PPN(pa) - nbase];
ffffffffc02020ba:	000c3503          	ld	a0,0(s8)
ffffffffc02020be:	97de                	add	a5,a5,s7
ffffffffc02020c0:	079a                	slli	a5,a5,0x6
ffffffffc02020c2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02020c4:	411c                	lw	a5,0(a0)
ffffffffc02020c6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02020ca:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02020cc:	cf11                	beqz	a4,ffffffffc02020e8 <unmap_range+0xd6>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02020ce:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02020d2:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02020d6:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02020d8:	bf45                	j	ffffffffc0202088 <unmap_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02020da:	945a                	add	s0,s0,s6
ffffffffc02020dc:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02020e0:	d455                	beqz	s0,ffffffffc020208c <unmap_range+0x7a>
ffffffffc02020e2:	f92469e3          	bltu	s0,s2,ffffffffc0202074 <unmap_range+0x62>
ffffffffc02020e6:	b75d                	j	ffffffffc020208c <unmap_range+0x7a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020e8:	100027f3          	csrr	a5,sstatus
ffffffffc02020ec:	8b89                	andi	a5,a5,2
ffffffffc02020ee:	e799                	bnez	a5,ffffffffc02020fc <unmap_range+0xea>
        pmm_manager->free_pages(base, n);
ffffffffc02020f0:	000d3783          	ld	a5,0(s10)
ffffffffc02020f4:	4585                	li	a1,1
ffffffffc02020f6:	739c                	ld	a5,32(a5)
ffffffffc02020f8:	9782                	jalr	a5
    if (flag) {
ffffffffc02020fa:	bfd1                	j	ffffffffc02020ce <unmap_range+0xbc>
ffffffffc02020fc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02020fe:	d48fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202102:	000d3783          	ld	a5,0(s10)
ffffffffc0202106:	6522                	ld	a0,8(sp)
ffffffffc0202108:	4585                	li	a1,1
ffffffffc020210a:	739c                	ld	a5,32(a5)
ffffffffc020210c:	9782                	jalr	a5
        intr_enable();
ffffffffc020210e:	d32fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202112:	bf75                	j	ffffffffc02020ce <unmap_range+0xbc>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202114:	00005697          	auipc	a3,0x5
ffffffffc0202118:	45468693          	addi	a3,a3,1108 # ffffffffc0207568 <default_pmm_manager+0x160>
ffffffffc020211c:	00005617          	auipc	a2,0x5
ffffffffc0202120:	c5460613          	addi	a2,a2,-940 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202124:	10f00593          	li	a1,271
ffffffffc0202128:	00005517          	auipc	a0,0x5
ffffffffc020212c:	43050513          	addi	a0,a0,1072 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202130:	b4afe0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202134:	00005697          	auipc	a3,0x5
ffffffffc0202138:	46468693          	addi	a3,a3,1124 # ffffffffc0207598 <default_pmm_manager+0x190>
ffffffffc020213c:	00005617          	auipc	a2,0x5
ffffffffc0202140:	c3460613          	addi	a2,a2,-972 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202144:	11000593          	li	a1,272
ffffffffc0202148:	00005517          	auipc	a0,0x5
ffffffffc020214c:	41050513          	addi	a0,a0,1040 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202150:	b2afe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202154:	b55ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202158 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202158:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020215a:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020215e:	fc86                	sd	ra,120(sp)
ffffffffc0202160:	f8a2                	sd	s0,112(sp)
ffffffffc0202162:	f4a6                	sd	s1,104(sp)
ffffffffc0202164:	f0ca                	sd	s2,96(sp)
ffffffffc0202166:	ecce                	sd	s3,88(sp)
ffffffffc0202168:	e8d2                	sd	s4,80(sp)
ffffffffc020216a:	e4d6                	sd	s5,72(sp)
ffffffffc020216c:	e0da                	sd	s6,64(sp)
ffffffffc020216e:	fc5e                	sd	s7,56(sp)
ffffffffc0202170:	f862                	sd	s8,48(sp)
ffffffffc0202172:	f466                	sd	s9,40(sp)
ffffffffc0202174:	f06a                	sd	s10,32(sp)
ffffffffc0202176:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202178:	17d2                	slli	a5,a5,0x34
ffffffffc020217a:	20079a63          	bnez	a5,ffffffffc020238e <exit_range+0x236>
    assert(USER_ACCESS(start, end));
ffffffffc020217e:	002007b7          	lui	a5,0x200
ffffffffc0202182:	24f5e463          	bltu	a1,a5,ffffffffc02023ca <exit_range+0x272>
ffffffffc0202186:	8ab2                	mv	s5,a2
ffffffffc0202188:	24c5f163          	bgeu	a1,a2,ffffffffc02023ca <exit_range+0x272>
ffffffffc020218c:	4785                	li	a5,1
ffffffffc020218e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202190:	22c7ed63          	bltu	a5,a2,ffffffffc02023ca <exit_range+0x272>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202194:	c00009b7          	lui	s3,0xc0000
ffffffffc0202198:	0135f9b3          	and	s3,a1,s3
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020219c:	ffe00937          	lui	s2,0xffe00
ffffffffc02021a0:	400007b7          	lui	a5,0x40000
    return KADDR(page2pa(page));
ffffffffc02021a4:	5cfd                	li	s9,-1
ffffffffc02021a6:	8c2a                	mv	s8,a0
ffffffffc02021a8:	0125f933          	and	s2,a1,s2
ffffffffc02021ac:	99be                	add	s3,s3,a5
    if (PPN(pa) >= npage) {
ffffffffc02021ae:	000b1d17          	auipc	s10,0xb1
ffffffffc02021b2:	97ad0d13          	addi	s10,s10,-1670 # ffffffffc02b2b28 <npage>
    return KADDR(page2pa(page));
ffffffffc02021b6:	00ccdc93          	srli	s9,s9,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02021ba:	000b1717          	auipc	a4,0xb1
ffffffffc02021be:	97670713          	addi	a4,a4,-1674 # ffffffffc02b2b30 <pages>
        pmm_manager->free_pages(base, n);
ffffffffc02021c2:	000b1d97          	auipc	s11,0xb1
ffffffffc02021c6:	976d8d93          	addi	s11,s11,-1674 # ffffffffc02b2b38 <pmm_manager>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02021ca:	c0000437          	lui	s0,0xc0000
ffffffffc02021ce:	944e                	add	s0,s0,s3
ffffffffc02021d0:	8079                	srli	s0,s0,0x1e
ffffffffc02021d2:	1ff47413          	andi	s0,s0,511
ffffffffc02021d6:	040e                	slli	s0,s0,0x3
ffffffffc02021d8:	9462                	add	s0,s0,s8
ffffffffc02021da:	00043a03          	ld	s4,0(s0) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ea8>
        if (pde1&PTE_V){
ffffffffc02021de:	001a7793          	andi	a5,s4,1
ffffffffc02021e2:	eb99                	bnez	a5,ffffffffc02021f8 <exit_range+0xa0>
    } while (d1start != 0 && d1start < end);
ffffffffc02021e4:	12098463          	beqz	s3,ffffffffc020230c <exit_range+0x1b4>
ffffffffc02021e8:	400007b7          	lui	a5,0x40000
ffffffffc02021ec:	97ce                	add	a5,a5,s3
ffffffffc02021ee:	894e                	mv	s2,s3
ffffffffc02021f0:	1159fe63          	bgeu	s3,s5,ffffffffc020230c <exit_range+0x1b4>
ffffffffc02021f4:	89be                	mv	s3,a5
ffffffffc02021f6:	bfd1                	j	ffffffffc02021ca <exit_range+0x72>
    if (PPN(pa) >= npage) {
ffffffffc02021f8:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02021fc:	0a0a                	slli	s4,s4,0x2
ffffffffc02021fe:	00ca5a13          	srli	s4,s4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202202:	1cfa7263          	bgeu	s4,a5,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202206:	fff80637          	lui	a2,0xfff80
ffffffffc020220a:	9652                	add	a2,a2,s4
    return page - pages + nbase;
ffffffffc020220c:	000806b7          	lui	a3,0x80
ffffffffc0202210:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc0202212:	0196f5b3          	and	a1,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202216:	061a                	slli	a2,a2,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202218:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020221a:	18f5fa63          	bgeu	a1,a5,ffffffffc02023ae <exit_range+0x256>
ffffffffc020221e:	000b1817          	auipc	a6,0xb1
ffffffffc0202222:	92280813          	addi	a6,a6,-1758 # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0202226:	00083b03          	ld	s6,0(a6)
            free_pd0 = 1;
ffffffffc020222a:	4b85                	li	s7,1
    return &pages[PPN(pa) - nbase];
ffffffffc020222c:	fff80e37          	lui	t3,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202230:	9b36                	add	s6,s6,a3
    return page - pages + nbase;
ffffffffc0202232:	00080337          	lui	t1,0x80
ffffffffc0202236:	6885                	lui	a7,0x1
ffffffffc0202238:	a819                	j	ffffffffc020224e <exit_range+0xf6>
                    free_pd0 = 0;
ffffffffc020223a:	4b81                	li	s7,0
                d0start += PTSIZE;
ffffffffc020223c:	002007b7          	lui	a5,0x200
ffffffffc0202240:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202242:	08090c63          	beqz	s2,ffffffffc02022da <exit_range+0x182>
ffffffffc0202246:	09397a63          	bgeu	s2,s3,ffffffffc02022da <exit_range+0x182>
ffffffffc020224a:	0f597063          	bgeu	s2,s5,ffffffffc020232a <exit_range+0x1d2>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020224e:	01595493          	srli	s1,s2,0x15
ffffffffc0202252:	1ff4f493          	andi	s1,s1,511
ffffffffc0202256:	048e                	slli	s1,s1,0x3
ffffffffc0202258:	94da                	add	s1,s1,s6
ffffffffc020225a:	609c                	ld	a5,0(s1)
                if (pde0&PTE_V) {
ffffffffc020225c:	0017f693          	andi	a3,a5,1
ffffffffc0202260:	dee9                	beqz	a3,ffffffffc020223a <exit_range+0xe2>
    if (PPN(pa) >= npage) {
ffffffffc0202262:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202266:	078a                	slli	a5,a5,0x2
ffffffffc0202268:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020226a:	14b7fe63          	bgeu	a5,a1,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc020226e:	97f2                	add	a5,a5,t3
    return page - pages + nbase;
ffffffffc0202270:	006786b3          	add	a3,a5,t1
    return KADDR(page2pa(page));
ffffffffc0202274:	0196feb3          	and	t4,a3,s9
    return &pages[PPN(pa) - nbase];
ffffffffc0202278:	00679513          	slli	a0,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020227c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020227e:	12bef863          	bgeu	t4,a1,ffffffffc02023ae <exit_range+0x256>
ffffffffc0202282:	00083783          	ld	a5,0(a6)
ffffffffc0202286:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202288:	011685b3          	add	a1,a3,a7
                        if (pt[i]&PTE_V){
ffffffffc020228c:	629c                	ld	a5,0(a3)
ffffffffc020228e:	8b85                	andi	a5,a5,1
ffffffffc0202290:	f7d5                	bnez	a5,ffffffffc020223c <exit_range+0xe4>
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202292:	06a1                	addi	a3,a3,8
ffffffffc0202294:	fed59ce3          	bne	a1,a3,ffffffffc020228c <exit_range+0x134>
    return &pages[PPN(pa) - nbase];
ffffffffc0202298:	631c                	ld	a5,0(a4)
ffffffffc020229a:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020229c:	100027f3          	csrr	a5,sstatus
ffffffffc02022a0:	8b89                	andi	a5,a5,2
ffffffffc02022a2:	e7d9                	bnez	a5,ffffffffc0202330 <exit_range+0x1d8>
        pmm_manager->free_pages(base, n);
ffffffffc02022a4:	000db783          	ld	a5,0(s11)
ffffffffc02022a8:	4585                	li	a1,1
ffffffffc02022aa:	e032                	sd	a2,0(sp)
ffffffffc02022ac:	739c                	ld	a5,32(a5)
ffffffffc02022ae:	9782                	jalr	a5
    if (flag) {
ffffffffc02022b0:	6602                	ld	a2,0(sp)
ffffffffc02022b2:	000b1817          	auipc	a6,0xb1
ffffffffc02022b6:	88e80813          	addi	a6,a6,-1906 # ffffffffc02b2b40 <va_pa_offset>
ffffffffc02022ba:	fff80e37          	lui	t3,0xfff80
ffffffffc02022be:	00080337          	lui	t1,0x80
ffffffffc02022c2:	6885                	lui	a7,0x1
ffffffffc02022c4:	000b1717          	auipc	a4,0xb1
ffffffffc02022c8:	86c70713          	addi	a4,a4,-1940 # ffffffffc02b2b30 <pages>
                        pd0[PDX0(d0start)] = 0;
ffffffffc02022cc:	0004b023          	sd	zero,0(s1)
                d0start += PTSIZE;
ffffffffc02022d0:	002007b7          	lui	a5,0x200
ffffffffc02022d4:	993e                	add	s2,s2,a5
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02022d6:	f60918e3          	bnez	s2,ffffffffc0202246 <exit_range+0xee>
            if (free_pd0) {
ffffffffc02022da:	f00b85e3          	beqz	s7,ffffffffc02021e4 <exit_range+0x8c>
    if (PPN(pa) >= npage) {
ffffffffc02022de:	000d3783          	ld	a5,0(s10)
ffffffffc02022e2:	0efa7263          	bgeu	s4,a5,ffffffffc02023c6 <exit_range+0x26e>
    return &pages[PPN(pa) - nbase];
ffffffffc02022e6:	6308                	ld	a0,0(a4)
ffffffffc02022e8:	9532                	add	a0,a0,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022ea:	100027f3          	csrr	a5,sstatus
ffffffffc02022ee:	8b89                	andi	a5,a5,2
ffffffffc02022f0:	efad                	bnez	a5,ffffffffc020236a <exit_range+0x212>
        pmm_manager->free_pages(base, n);
ffffffffc02022f2:	000db783          	ld	a5,0(s11)
ffffffffc02022f6:	4585                	li	a1,1
ffffffffc02022f8:	739c                	ld	a5,32(a5)
ffffffffc02022fa:	9782                	jalr	a5
ffffffffc02022fc:	000b1717          	auipc	a4,0xb1
ffffffffc0202300:	83470713          	addi	a4,a4,-1996 # ffffffffc02b2b30 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202304:	00043023          	sd	zero,0(s0)
    } while (d1start != 0 && d1start < end);
ffffffffc0202308:	ee0990e3          	bnez	s3,ffffffffc02021e8 <exit_range+0x90>
}
ffffffffc020230c:	70e6                	ld	ra,120(sp)
ffffffffc020230e:	7446                	ld	s0,112(sp)
ffffffffc0202310:	74a6                	ld	s1,104(sp)
ffffffffc0202312:	7906                	ld	s2,96(sp)
ffffffffc0202314:	69e6                	ld	s3,88(sp)
ffffffffc0202316:	6a46                	ld	s4,80(sp)
ffffffffc0202318:	6aa6                	ld	s5,72(sp)
ffffffffc020231a:	6b06                	ld	s6,64(sp)
ffffffffc020231c:	7be2                	ld	s7,56(sp)
ffffffffc020231e:	7c42                	ld	s8,48(sp)
ffffffffc0202320:	7ca2                	ld	s9,40(sp)
ffffffffc0202322:	7d02                	ld	s10,32(sp)
ffffffffc0202324:	6de2                	ld	s11,24(sp)
ffffffffc0202326:	6109                	addi	sp,sp,128
ffffffffc0202328:	8082                	ret
            if (free_pd0) {
ffffffffc020232a:	ea0b8fe3          	beqz	s7,ffffffffc02021e8 <exit_range+0x90>
ffffffffc020232e:	bf45                	j	ffffffffc02022de <exit_range+0x186>
ffffffffc0202330:	e032                	sd	a2,0(sp)
        intr_disable();
ffffffffc0202332:	e42a                	sd	a0,8(sp)
ffffffffc0202334:	b12fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202338:	000db783          	ld	a5,0(s11)
ffffffffc020233c:	6522                	ld	a0,8(sp)
ffffffffc020233e:	4585                	li	a1,1
ffffffffc0202340:	739c                	ld	a5,32(a5)
ffffffffc0202342:	9782                	jalr	a5
        intr_enable();
ffffffffc0202344:	afcfe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202348:	6602                	ld	a2,0(sp)
ffffffffc020234a:	000b0717          	auipc	a4,0xb0
ffffffffc020234e:	7e670713          	addi	a4,a4,2022 # ffffffffc02b2b30 <pages>
ffffffffc0202352:	6885                	lui	a7,0x1
ffffffffc0202354:	00080337          	lui	t1,0x80
ffffffffc0202358:	fff80e37          	lui	t3,0xfff80
ffffffffc020235c:	000b0817          	auipc	a6,0xb0
ffffffffc0202360:	7e480813          	addi	a6,a6,2020 # ffffffffc02b2b40 <va_pa_offset>
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202364:	0004b023          	sd	zero,0(s1)
ffffffffc0202368:	b7a5                	j	ffffffffc02022d0 <exit_range+0x178>
ffffffffc020236a:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020236c:	adafe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202370:	000db783          	ld	a5,0(s11)
ffffffffc0202374:	6502                	ld	a0,0(sp)
ffffffffc0202376:	4585                	li	a1,1
ffffffffc0202378:	739c                	ld	a5,32(a5)
ffffffffc020237a:	9782                	jalr	a5
        intr_enable();
ffffffffc020237c:	ac4fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202380:	000b0717          	auipc	a4,0xb0
ffffffffc0202384:	7b070713          	addi	a4,a4,1968 # ffffffffc02b2b30 <pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202388:	00043023          	sd	zero,0(s0)
ffffffffc020238c:	bfb5                	j	ffffffffc0202308 <exit_range+0x1b0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020238e:	00005697          	auipc	a3,0x5
ffffffffc0202392:	1da68693          	addi	a3,a3,474 # ffffffffc0207568 <default_pmm_manager+0x160>
ffffffffc0202396:	00005617          	auipc	a2,0x5
ffffffffc020239a:	9da60613          	addi	a2,a2,-1574 # ffffffffc0206d70 <commands+0x450>
ffffffffc020239e:	12000593          	li	a1,288
ffffffffc02023a2:	00005517          	auipc	a0,0x5
ffffffffc02023a6:	1b650513          	addi	a0,a0,438 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc02023aa:	8d0fe0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02023ae:	00005617          	auipc	a2,0x5
ffffffffc02023b2:	09260613          	addi	a2,a2,146 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc02023b6:	06900593          	li	a1,105
ffffffffc02023ba:	00005517          	auipc	a0,0x5
ffffffffc02023be:	0ae50513          	addi	a0,a0,174 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc02023c2:	8b8fe0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02023c6:	8e3ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02023ca:	00005697          	auipc	a3,0x5
ffffffffc02023ce:	1ce68693          	addi	a3,a3,462 # ffffffffc0207598 <default_pmm_manager+0x190>
ffffffffc02023d2:	00005617          	auipc	a2,0x5
ffffffffc02023d6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0206d70 <commands+0x450>
ffffffffc02023da:	12100593          	li	a1,289
ffffffffc02023de:	00005517          	auipc	a0,0x5
ffffffffc02023e2:	17a50513          	addi	a0,a0,378 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc02023e6:	894fe0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02023ea <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ea:	7179                	addi	sp,sp,-48
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023ec:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02023ee:	ec26                	sd	s1,24(sp)
ffffffffc02023f0:	f406                	sd	ra,40(sp)
ffffffffc02023f2:	f022                	sd	s0,32(sp)
ffffffffc02023f4:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02023f6:	9f7ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep != NULL) {
ffffffffc02023fa:	c511                	beqz	a0,ffffffffc0202406 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02023fc:	611c                	ld	a5,0(a0)
ffffffffc02023fe:	842a                	mv	s0,a0
ffffffffc0202400:	0017f713          	andi	a4,a5,1
ffffffffc0202404:	e711                	bnez	a4,ffffffffc0202410 <page_remove+0x26>
}
ffffffffc0202406:	70a2                	ld	ra,40(sp)
ffffffffc0202408:	7402                	ld	s0,32(sp)
ffffffffc020240a:	64e2                	ld	s1,24(sp)
ffffffffc020240c:	6145                	addi	sp,sp,48
ffffffffc020240e:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0202410:	078a                	slli	a5,a5,0x2
ffffffffc0202412:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202414:	000b0717          	auipc	a4,0xb0
ffffffffc0202418:	71473703          	ld	a4,1812(a4) # ffffffffc02b2b28 <npage>
ffffffffc020241c:	06e7f363          	bgeu	a5,a4,ffffffffc0202482 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202420:	fff80537          	lui	a0,0xfff80
ffffffffc0202424:	97aa                	add	a5,a5,a0
ffffffffc0202426:	079a                	slli	a5,a5,0x6
ffffffffc0202428:	000b0517          	auipc	a0,0xb0
ffffffffc020242c:	70853503          	ld	a0,1800(a0) # ffffffffc02b2b30 <pages>
ffffffffc0202430:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202432:	411c                	lw	a5,0(a0)
ffffffffc0202434:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202438:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020243a:	cb11                	beqz	a4,ffffffffc020244e <page_remove+0x64>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020243c:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202440:	12048073          	sfence.vma	s1
}
ffffffffc0202444:	70a2                	ld	ra,40(sp)
ffffffffc0202446:	7402                	ld	s0,32(sp)
ffffffffc0202448:	64e2                	ld	s1,24(sp)
ffffffffc020244a:	6145                	addi	sp,sp,48
ffffffffc020244c:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020244e:	100027f3          	csrr	a5,sstatus
ffffffffc0202452:	8b89                	andi	a5,a5,2
ffffffffc0202454:	eb89                	bnez	a5,ffffffffc0202466 <page_remove+0x7c>
        pmm_manager->free_pages(base, n);
ffffffffc0202456:	000b0797          	auipc	a5,0xb0
ffffffffc020245a:	6e27b783          	ld	a5,1762(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc020245e:	739c                	ld	a5,32(a5)
ffffffffc0202460:	4585                	li	a1,1
ffffffffc0202462:	9782                	jalr	a5
    if (flag) {
ffffffffc0202464:	bfe1                	j	ffffffffc020243c <page_remove+0x52>
        intr_disable();
ffffffffc0202466:	e42a                	sd	a0,8(sp)
ffffffffc0202468:	9defe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc020246c:	000b0797          	auipc	a5,0xb0
ffffffffc0202470:	6cc7b783          	ld	a5,1740(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc0202474:	739c                	ld	a5,32(a5)
ffffffffc0202476:	6522                	ld	a0,8(sp)
ffffffffc0202478:	4585                	li	a1,1
ffffffffc020247a:	9782                	jalr	a5
        intr_enable();
ffffffffc020247c:	9c4fe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202480:	bf75                	j	ffffffffc020243c <page_remove+0x52>
ffffffffc0202482:	827ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc0202486 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202486:	7139                	addi	sp,sp,-64
ffffffffc0202488:	e852                	sd	s4,16(sp)
ffffffffc020248a:	8a32                	mv	s4,a2
ffffffffc020248c:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020248e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202490:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202492:	85d2                	mv	a1,s4
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202494:	f426                	sd	s1,40(sp)
ffffffffc0202496:	fc06                	sd	ra,56(sp)
ffffffffc0202498:	f04a                	sd	s2,32(sp)
ffffffffc020249a:	ec4e                	sd	s3,24(sp)
ffffffffc020249c:	e456                	sd	s5,8(sp)
ffffffffc020249e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02024a0:	94dff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    if (ptep == NULL) {
ffffffffc02024a4:	c961                	beqz	a0,ffffffffc0202574 <page_insert+0xee>
    page->ref += 1;
ffffffffc02024a6:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc02024a8:	611c                	ld	a5,0(a0)
ffffffffc02024aa:	89aa                	mv	s3,a0
ffffffffc02024ac:	0016871b          	addiw	a4,a3,1
ffffffffc02024b0:	c018                	sw	a4,0(s0)
ffffffffc02024b2:	0017f713          	andi	a4,a5,1
ffffffffc02024b6:	ef05                	bnez	a4,ffffffffc02024ee <page_insert+0x68>
    return page - pages + nbase;
ffffffffc02024b8:	000b0717          	auipc	a4,0xb0
ffffffffc02024bc:	67873703          	ld	a4,1656(a4) # ffffffffc02b2b30 <pages>
ffffffffc02024c0:	8c19                	sub	s0,s0,a4
ffffffffc02024c2:	000807b7          	lui	a5,0x80
ffffffffc02024c6:	8419                	srai	s0,s0,0x6
ffffffffc02024c8:	943e                	add	s0,s0,a5
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02024ca:	042a                	slli	s0,s0,0xa
ffffffffc02024cc:	8cc1                	or	s1,s1,s0
ffffffffc02024ce:	0014e493          	ori	s1,s1,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02024d2:	0099b023          	sd	s1,0(s3) # ffffffffc0000000 <_binary_obj___user_exit_out_size+0xffffffffbfff4ea8>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02024d6:	120a0073          	sfence.vma	s4
    return 0;
ffffffffc02024da:	4501                	li	a0,0
}
ffffffffc02024dc:	70e2                	ld	ra,56(sp)
ffffffffc02024de:	7442                	ld	s0,48(sp)
ffffffffc02024e0:	74a2                	ld	s1,40(sp)
ffffffffc02024e2:	7902                	ld	s2,32(sp)
ffffffffc02024e4:	69e2                	ld	s3,24(sp)
ffffffffc02024e6:	6a42                	ld	s4,16(sp)
ffffffffc02024e8:	6aa2                	ld	s5,8(sp)
ffffffffc02024ea:	6121                	addi	sp,sp,64
ffffffffc02024ec:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02024ee:	078a                	slli	a5,a5,0x2
ffffffffc02024f0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024f2:	000b0717          	auipc	a4,0xb0
ffffffffc02024f6:	63673703          	ld	a4,1590(a4) # ffffffffc02b2b28 <npage>
ffffffffc02024fa:	06e7ff63          	bgeu	a5,a4,ffffffffc0202578 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02024fe:	000b0a97          	auipc	s5,0xb0
ffffffffc0202502:	632a8a93          	addi	s5,s5,1586 # ffffffffc02b2b30 <pages>
ffffffffc0202506:	000ab703          	ld	a4,0(s5)
ffffffffc020250a:	fff80937          	lui	s2,0xfff80
ffffffffc020250e:	993e                	add	s2,s2,a5
ffffffffc0202510:	091a                	slli	s2,s2,0x6
ffffffffc0202512:	993a                	add	s2,s2,a4
        if (p == page) {
ffffffffc0202514:	01240c63          	beq	s0,s2,ffffffffc020252c <page_insert+0xa6>
    page->ref -= 1;
ffffffffc0202518:	00092783          	lw	a5,0(s2) # fffffffffff80000 <end+0x3fccd474>
ffffffffc020251c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202520:	00d92023          	sw	a3,0(s2)
        if (page_ref(page) ==
ffffffffc0202524:	c691                	beqz	a3,ffffffffc0202530 <page_insert+0xaa>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202526:	120a0073          	sfence.vma	s4
}
ffffffffc020252a:	bf59                	j	ffffffffc02024c0 <page_insert+0x3a>
ffffffffc020252c:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020252e:	bf49                	j	ffffffffc02024c0 <page_insert+0x3a>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202530:	100027f3          	csrr	a5,sstatus
ffffffffc0202534:	8b89                	andi	a5,a5,2
ffffffffc0202536:	ef91                	bnez	a5,ffffffffc0202552 <page_insert+0xcc>
        pmm_manager->free_pages(base, n);
ffffffffc0202538:	000b0797          	auipc	a5,0xb0
ffffffffc020253c:	6007b783          	ld	a5,1536(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc0202540:	739c                	ld	a5,32(a5)
ffffffffc0202542:	4585                	li	a1,1
ffffffffc0202544:	854a                	mv	a0,s2
ffffffffc0202546:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202548:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254c:	120a0073          	sfence.vma	s4
ffffffffc0202550:	bf85                	j	ffffffffc02024c0 <page_insert+0x3a>
        intr_disable();
ffffffffc0202552:	8f4fe0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202556:	000b0797          	auipc	a5,0xb0
ffffffffc020255a:	5e27b783          	ld	a5,1506(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc020255e:	739c                	ld	a5,32(a5)
ffffffffc0202560:	4585                	li	a1,1
ffffffffc0202562:	854a                	mv	a0,s2
ffffffffc0202564:	9782                	jalr	a5
        intr_enable();
ffffffffc0202566:	8dafe0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020256a:	000ab703          	ld	a4,0(s5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020256e:	120a0073          	sfence.vma	s4
ffffffffc0202572:	b7b9                	j	ffffffffc02024c0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202574:	5571                	li	a0,-4
ffffffffc0202576:	b79d                	j	ffffffffc02024dc <page_insert+0x56>
ffffffffc0202578:	f30ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>

ffffffffc020257c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020257c:	00005797          	auipc	a5,0x5
ffffffffc0202580:	e8c78793          	addi	a5,a5,-372 # ffffffffc0207408 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202584:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202586:	711d                	addi	sp,sp,-96
ffffffffc0202588:	ec5e                	sd	s7,24(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020258a:	00005517          	auipc	a0,0x5
ffffffffc020258e:	02650513          	addi	a0,a0,38 # ffffffffc02075b0 <default_pmm_manager+0x1a8>
    pmm_manager = &default_pmm_manager;
ffffffffc0202592:	000b0b97          	auipc	s7,0xb0
ffffffffc0202596:	5a6b8b93          	addi	s7,s7,1446 # ffffffffc02b2b38 <pmm_manager>
void pmm_init(void) {
ffffffffc020259a:	ec86                	sd	ra,88(sp)
ffffffffc020259c:	e4a6                	sd	s1,72(sp)
ffffffffc020259e:	fc4e                	sd	s3,56(sp)
ffffffffc02025a0:	f05a                	sd	s6,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02025a2:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc02025a6:	e8a2                	sd	s0,80(sp)
ffffffffc02025a8:	e0ca                	sd	s2,64(sp)
ffffffffc02025aa:	f852                	sd	s4,48(sp)
ffffffffc02025ac:	f456                	sd	s5,40(sp)
ffffffffc02025ae:	e862                	sd	s8,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02025b0:	bd1fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pmm_manager->init();
ffffffffc02025b4:	000bb783          	ld	a5,0(s7)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025b8:	000b0997          	auipc	s3,0xb0
ffffffffc02025bc:	58898993          	addi	s3,s3,1416 # ffffffffc02b2b40 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc02025c0:	000b0497          	auipc	s1,0xb0
ffffffffc02025c4:	56848493          	addi	s1,s1,1384 # ffffffffc02b2b28 <npage>
    pmm_manager->init();
ffffffffc02025c8:	679c                	ld	a5,8(a5)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02025ca:	000b0b17          	auipc	s6,0xb0
ffffffffc02025ce:	566b0b13          	addi	s6,s6,1382 # ffffffffc02b2b30 <pages>
    pmm_manager->init();
ffffffffc02025d2:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025d4:	57f5                	li	a5,-3
ffffffffc02025d6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02025d8:	00005517          	auipc	a0,0x5
ffffffffc02025dc:	ff050513          	addi	a0,a0,-16 # ffffffffc02075c8 <default_pmm_manager+0x1c0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc02025e0:	00f9b023          	sd	a5,0(s3)
    cprintf("physcial memory map:\n");
ffffffffc02025e4:	b9dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02025e8:	46c5                	li	a3,17
ffffffffc02025ea:	06ee                	slli	a3,a3,0x1b
ffffffffc02025ec:	40100613          	li	a2,1025
ffffffffc02025f0:	07e005b7          	lui	a1,0x7e00
ffffffffc02025f4:	16fd                	addi	a3,a3,-1
ffffffffc02025f6:	0656                	slli	a2,a2,0x15
ffffffffc02025f8:	00005517          	auipc	a0,0x5
ffffffffc02025fc:	fe850513          	addi	a0,a0,-24 # ffffffffc02075e0 <default_pmm_manager+0x1d8>
ffffffffc0202600:	b81fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202604:	777d                	lui	a4,0xfffff
ffffffffc0202606:	000b1797          	auipc	a5,0xb1
ffffffffc020260a:	58578793          	addi	a5,a5,1413 # ffffffffc02b3b8b <end+0xfff>
ffffffffc020260e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202610:	00088737          	lui	a4,0x88
ffffffffc0202614:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202616:	00fb3023          	sd	a5,0(s6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020261a:	4701                	li	a4,0
ffffffffc020261c:	4585                	li	a1,1
ffffffffc020261e:	fff80837          	lui	a6,0xfff80
ffffffffc0202622:	a019                	j	ffffffffc0202628 <pmm_init+0xac>
        SetPageReserved(pages + i);
ffffffffc0202624:	000b3783          	ld	a5,0(s6)
ffffffffc0202628:	00671693          	slli	a3,a4,0x6
ffffffffc020262c:	97b6                	add	a5,a5,a3
ffffffffc020262e:	07a1                	addi	a5,a5,8
ffffffffc0202630:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202634:	6090                	ld	a2,0(s1)
ffffffffc0202636:	0705                	addi	a4,a4,1
ffffffffc0202638:	010607b3          	add	a5,a2,a6
ffffffffc020263c:	fef764e3          	bltu	a4,a5,ffffffffc0202624 <pmm_init+0xa8>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202640:	000b3503          	ld	a0,0(s6)
ffffffffc0202644:	079a                	slli	a5,a5,0x6
ffffffffc0202646:	c0200737          	lui	a4,0xc0200
ffffffffc020264a:	00f506b3          	add	a3,a0,a5
ffffffffc020264e:	60e6e563          	bltu	a3,a4,ffffffffc0202c58 <pmm_init+0x6dc>
ffffffffc0202652:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202656:	4745                	li	a4,17
ffffffffc0202658:	076e                	slli	a4,a4,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020265a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020265c:	4ae6e563          	bltu	a3,a4,ffffffffc0202b06 <pmm_init+0x58a>
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202660:	00005517          	auipc	a0,0x5
ffffffffc0202664:	fa850513          	addi	a0,a0,-88 # ffffffffc0207608 <default_pmm_manager+0x200>
ffffffffc0202668:	b19fd0ef          	jal	ra,ffffffffc0200180 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020266c:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202670:	000b0917          	auipc	s2,0xb0
ffffffffc0202674:	4b090913          	addi	s2,s2,1200 # ffffffffc02b2b20 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202678:	7b9c                	ld	a5,48(a5)
ffffffffc020267a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020267c:	00005517          	auipc	a0,0x5
ffffffffc0202680:	fa450513          	addi	a0,a0,-92 # ffffffffc0207620 <default_pmm_manager+0x218>
ffffffffc0202684:	afdfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202688:	00009697          	auipc	a3,0x9
ffffffffc020268c:	97868693          	addi	a3,a3,-1672 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202690:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202694:	c02007b7          	lui	a5,0xc0200
ffffffffc0202698:	5cf6ec63          	bltu	a3,a5,ffffffffc0202c70 <pmm_init+0x6f4>
ffffffffc020269c:	0009b783          	ld	a5,0(s3)
ffffffffc02026a0:	8e9d                	sub	a3,a3,a5
ffffffffc02026a2:	000b0797          	auipc	a5,0xb0
ffffffffc02026a6:	46d7bb23          	sd	a3,1142(a5) # ffffffffc02b2b18 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026aa:	100027f3          	csrr	a5,sstatus
ffffffffc02026ae:	8b89                	andi	a5,a5,2
ffffffffc02026b0:	48079263          	bnez	a5,ffffffffc0202b34 <pmm_init+0x5b8>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026b4:	000bb783          	ld	a5,0(s7)
ffffffffc02026b8:	779c                	ld	a5,40(a5)
ffffffffc02026ba:	9782                	jalr	a5
ffffffffc02026bc:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02026be:	6098                	ld	a4,0(s1)
ffffffffc02026c0:	c80007b7          	lui	a5,0xc8000
ffffffffc02026c4:	83b1                	srli	a5,a5,0xc
ffffffffc02026c6:	5ee7e163          	bltu	a5,a4,ffffffffc0202ca8 <pmm_init+0x72c>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02026ca:	00093503          	ld	a0,0(s2)
ffffffffc02026ce:	5a050d63          	beqz	a0,ffffffffc0202c88 <pmm_init+0x70c>
ffffffffc02026d2:	03451793          	slli	a5,a0,0x34
ffffffffc02026d6:	5a079963          	bnez	a5,ffffffffc0202c88 <pmm_init+0x70c>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02026da:	4601                	li	a2,0
ffffffffc02026dc:	4581                	li	a1,0
ffffffffc02026de:	8e1ff0ef          	jal	ra,ffffffffc0201fbe <get_page>
ffffffffc02026e2:	62051563          	bnez	a0,ffffffffc0202d0c <pmm_init+0x790>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02026e6:	4505                	li	a0,1
ffffffffc02026e8:	df8ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02026ec:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02026ee:	00093503          	ld	a0,0(s2)
ffffffffc02026f2:	4681                	li	a3,0
ffffffffc02026f4:	4601                	li	a2,0
ffffffffc02026f6:	85d2                	mv	a1,s4
ffffffffc02026f8:	d8fff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02026fc:	5e051863          	bnez	a0,ffffffffc0202cec <pmm_init+0x770>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202700:	00093503          	ld	a0,0(s2)
ffffffffc0202704:	4601                	li	a2,0
ffffffffc0202706:	4581                	li	a1,0
ffffffffc0202708:	ee4ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc020270c:	5c050063          	beqz	a0,ffffffffc0202ccc <pmm_init+0x750>
    assert(pte2page(*ptep) == p1);
ffffffffc0202710:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202712:	0017f713          	andi	a4,a5,1
ffffffffc0202716:	5a070963          	beqz	a4,ffffffffc0202cc8 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc020271a:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc020271c:	078a                	slli	a5,a5,0x2
ffffffffc020271e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202720:	52e7fa63          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202724:	000b3683          	ld	a3,0(s6)
ffffffffc0202728:	fff80637          	lui	a2,0xfff80
ffffffffc020272c:	97b2                	add	a5,a5,a2
ffffffffc020272e:	079a                	slli	a5,a5,0x6
ffffffffc0202730:	97b6                	add	a5,a5,a3
ffffffffc0202732:	10fa16e3          	bne	s4,a5,ffffffffc020303e <pmm_init+0xac2>
    assert(page_ref(p1) == 1);
ffffffffc0202736:	000a2683          	lw	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8be0>
ffffffffc020273a:	4785                	li	a5,1
ffffffffc020273c:	12f69de3          	bne	a3,a5,ffffffffc0203076 <pmm_init+0xafa>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202740:	00093503          	ld	a0,0(s2)
ffffffffc0202744:	77fd                	lui	a5,0xfffff
ffffffffc0202746:	6114                	ld	a3,0(a0)
ffffffffc0202748:	068a                	slli	a3,a3,0x2
ffffffffc020274a:	8efd                	and	a3,a3,a5
ffffffffc020274c:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202750:	10e677e3          	bgeu	a2,a4,ffffffffc020305e <pmm_init+0xae2>
ffffffffc0202754:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202758:	96e2                	add	a3,a3,s8
ffffffffc020275a:	0006ba83          	ld	s5,0(a3)
ffffffffc020275e:	0a8a                	slli	s5,s5,0x2
ffffffffc0202760:	00fafab3          	and	s5,s5,a5
ffffffffc0202764:	00cad793          	srli	a5,s5,0xc
ffffffffc0202768:	62e7f263          	bgeu	a5,a4,ffffffffc0202d8c <pmm_init+0x810>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020276c:	4601                	li	a2,0
ffffffffc020276e:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202770:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202772:	e7aff0ef          	jal	ra,ffffffffc0201dec <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202776:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202778:	5f551a63          	bne	a0,s5,ffffffffc0202d6c <pmm_init+0x7f0>

    p2 = alloc_page();
ffffffffc020277c:	4505                	li	a0,1
ffffffffc020277e:	d62ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0202782:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202784:	00093503          	ld	a0,0(s2)
ffffffffc0202788:	46d1                	li	a3,20
ffffffffc020278a:	6605                	lui	a2,0x1
ffffffffc020278c:	85d6                	mv	a1,s5
ffffffffc020278e:	cf9ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc0202792:	58051d63          	bnez	a0,ffffffffc0202d2c <pmm_init+0x7b0>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202796:	00093503          	ld	a0,0(s2)
ffffffffc020279a:	4601                	li	a2,0
ffffffffc020279c:	6585                	lui	a1,0x1
ffffffffc020279e:	e4eff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02027a2:	0e050ae3          	beqz	a0,ffffffffc0203096 <pmm_init+0xb1a>
    assert(*ptep & PTE_U);
ffffffffc02027a6:	611c                	ld	a5,0(a0)
ffffffffc02027a8:	0107f713          	andi	a4,a5,16
ffffffffc02027ac:	6e070d63          	beqz	a4,ffffffffc0202ea6 <pmm_init+0x92a>
    assert(*ptep & PTE_W);
ffffffffc02027b0:	8b91                	andi	a5,a5,4
ffffffffc02027b2:	6a078a63          	beqz	a5,ffffffffc0202e66 <pmm_init+0x8ea>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02027b6:	00093503          	ld	a0,0(s2)
ffffffffc02027ba:	611c                	ld	a5,0(a0)
ffffffffc02027bc:	8bc1                	andi	a5,a5,16
ffffffffc02027be:	68078463          	beqz	a5,ffffffffc0202e46 <pmm_init+0x8ca>
    assert(page_ref(p2) == 1);
ffffffffc02027c2:	000aa703          	lw	a4,0(s5)
ffffffffc02027c6:	4785                	li	a5,1
ffffffffc02027c8:	58f71263          	bne	a4,a5,ffffffffc0202d4c <pmm_init+0x7d0>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02027cc:	4681                	li	a3,0
ffffffffc02027ce:	6605                	lui	a2,0x1
ffffffffc02027d0:	85d2                	mv	a1,s4
ffffffffc02027d2:	cb5ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02027d6:	62051863          	bnez	a0,ffffffffc0202e06 <pmm_init+0x88a>
    assert(page_ref(p1) == 2);
ffffffffc02027da:	000a2703          	lw	a4,0(s4)
ffffffffc02027de:	4789                	li	a5,2
ffffffffc02027e0:	60f71363          	bne	a4,a5,ffffffffc0202de6 <pmm_init+0x86a>
    assert(page_ref(p2) == 0);
ffffffffc02027e4:	000aa783          	lw	a5,0(s5)
ffffffffc02027e8:	5c079f63          	bnez	a5,ffffffffc0202dc6 <pmm_init+0x84a>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02027ec:	00093503          	ld	a0,0(s2)
ffffffffc02027f0:	4601                	li	a2,0
ffffffffc02027f2:	6585                	lui	a1,0x1
ffffffffc02027f4:	df8ff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02027f8:	5a050763          	beqz	a0,ffffffffc0202da6 <pmm_init+0x82a>
    assert(pte2page(*ptep) == p1);
ffffffffc02027fc:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027fe:	00177793          	andi	a5,a4,1
ffffffffc0202802:	4c078363          	beqz	a5,ffffffffc0202cc8 <pmm_init+0x74c>
    if (PPN(pa) >= npage) {
ffffffffc0202806:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202808:	00271793          	slli	a5,a4,0x2
ffffffffc020280c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020280e:	44d7f363          	bgeu	a5,a3,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202812:	000b3683          	ld	a3,0(s6)
ffffffffc0202816:	fff80637          	lui	a2,0xfff80
ffffffffc020281a:	97b2                	add	a5,a5,a2
ffffffffc020281c:	079a                	slli	a5,a5,0x6
ffffffffc020281e:	97b6                	add	a5,a5,a3
ffffffffc0202820:	6efa1363          	bne	s4,a5,ffffffffc0202f06 <pmm_init+0x98a>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202824:	8b41                	andi	a4,a4,16
ffffffffc0202826:	6c071063          	bnez	a4,ffffffffc0202ee6 <pmm_init+0x96a>

    page_remove(boot_pgdir, 0x0);
ffffffffc020282a:	00093503          	ld	a0,0(s2)
ffffffffc020282e:	4581                	li	a1,0
ffffffffc0202830:	bbbff0ef          	jal	ra,ffffffffc02023ea <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202834:	000a2703          	lw	a4,0(s4)
ffffffffc0202838:	4785                	li	a5,1
ffffffffc020283a:	68f71663          	bne	a4,a5,ffffffffc0202ec6 <pmm_init+0x94a>
    assert(page_ref(p2) == 0);
ffffffffc020283e:	000aa783          	lw	a5,0(s5)
ffffffffc0202842:	74079e63          	bnez	a5,ffffffffc0202f9e <pmm_init+0xa22>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202846:	00093503          	ld	a0,0(s2)
ffffffffc020284a:	6585                	lui	a1,0x1
ffffffffc020284c:	b9fff0ef          	jal	ra,ffffffffc02023ea <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202850:	000a2783          	lw	a5,0(s4)
ffffffffc0202854:	72079563          	bnez	a5,ffffffffc0202f7e <pmm_init+0xa02>
    assert(page_ref(p2) == 0);
ffffffffc0202858:	000aa783          	lw	a5,0(s5)
ffffffffc020285c:	70079163          	bnez	a5,ffffffffc0202f5e <pmm_init+0x9e2>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202860:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202864:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202866:	000a3683          	ld	a3,0(s4)
ffffffffc020286a:	068a                	slli	a3,a3,0x2
ffffffffc020286c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020286e:	3ee6f363          	bgeu	a3,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202872:	fff807b7          	lui	a5,0xfff80
ffffffffc0202876:	000b3503          	ld	a0,0(s6)
ffffffffc020287a:	96be                	add	a3,a3,a5
ffffffffc020287c:	069a                	slli	a3,a3,0x6
    return page->ref;
ffffffffc020287e:	00d507b3          	add	a5,a0,a3
ffffffffc0202882:	4390                	lw	a2,0(a5)
ffffffffc0202884:	4785                	li	a5,1
ffffffffc0202886:	6af61c63          	bne	a2,a5,ffffffffc0202f3e <pmm_init+0x9c2>
    return page - pages + nbase;
ffffffffc020288a:	8699                	srai	a3,a3,0x6
ffffffffc020288c:	000805b7          	lui	a1,0x80
ffffffffc0202890:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0202892:	00c69613          	slli	a2,a3,0xc
ffffffffc0202896:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202898:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020289a:	68e67663          	bgeu	a2,a4,ffffffffc0202f26 <pmm_init+0x9aa>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020289e:	0009b603          	ld	a2,0(s3)
ffffffffc02028a2:	96b2                	add	a3,a3,a2
    return pa2page(PDE_ADDR(pde));
ffffffffc02028a4:	629c                	ld	a5,0(a3)
ffffffffc02028a6:	078a                	slli	a5,a5,0x2
ffffffffc02028a8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028aa:	3ae7f563          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028ae:	8f8d                	sub	a5,a5,a1
ffffffffc02028b0:	079a                	slli	a5,a5,0x6
ffffffffc02028b2:	953e                	add	a0,a0,a5
ffffffffc02028b4:	100027f3          	csrr	a5,sstatus
ffffffffc02028b8:	8b89                	andi	a5,a5,2
ffffffffc02028ba:	2c079763          	bnez	a5,ffffffffc0202b88 <pmm_init+0x60c>
        pmm_manager->free_pages(base, n);
ffffffffc02028be:	000bb783          	ld	a5,0(s7)
ffffffffc02028c2:	4585                	li	a1,1
ffffffffc02028c4:	739c                	ld	a5,32(a5)
ffffffffc02028c6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02028c8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc02028cc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028ce:	078a                	slli	a5,a5,0x2
ffffffffc02028d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028d2:	38e7f163          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc02028d6:	000b3503          	ld	a0,0(s6)
ffffffffc02028da:	fff80737          	lui	a4,0xfff80
ffffffffc02028de:	97ba                	add	a5,a5,a4
ffffffffc02028e0:	079a                	slli	a5,a5,0x6
ffffffffc02028e2:	953e                	add	a0,a0,a5
ffffffffc02028e4:	100027f3          	csrr	a5,sstatus
ffffffffc02028e8:	8b89                	andi	a5,a5,2
ffffffffc02028ea:	28079363          	bnez	a5,ffffffffc0202b70 <pmm_init+0x5f4>
ffffffffc02028ee:	000bb783          	ld	a5,0(s7)
ffffffffc02028f2:	4585                	li	a1,1
ffffffffc02028f4:	739c                	ld	a5,32(a5)
ffffffffc02028f6:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc02028f8:	00093783          	ld	a5,0(s2)
ffffffffc02028fc:	0007b023          	sd	zero,0(a5) # fffffffffff80000 <end+0x3fccd474>
  asm volatile("sfence.vma");
ffffffffc0202900:	12000073          	sfence.vma
ffffffffc0202904:	100027f3          	csrr	a5,sstatus
ffffffffc0202908:	8b89                	andi	a5,a5,2
ffffffffc020290a:	24079963          	bnez	a5,ffffffffc0202b5c <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc020290e:	000bb783          	ld	a5,0(s7)
ffffffffc0202912:	779c                	ld	a5,40(a5)
ffffffffc0202914:	9782                	jalr	a5
ffffffffc0202916:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202918:	71441363          	bne	s0,s4,ffffffffc020301e <pmm_init+0xaa2>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020291c:	00005517          	auipc	a0,0x5
ffffffffc0202920:	fec50513          	addi	a0,a0,-20 # ffffffffc0207908 <default_pmm_manager+0x500>
ffffffffc0202924:	85dfd0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0202928:	100027f3          	csrr	a5,sstatus
ffffffffc020292c:	8b89                	andi	a5,a5,2
ffffffffc020292e:	20079d63          	bnez	a5,ffffffffc0202b48 <pmm_init+0x5cc>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202932:	000bb783          	ld	a5,0(s7)
ffffffffc0202936:	779c                	ld	a5,40(a5)
ffffffffc0202938:	9782                	jalr	a5
ffffffffc020293a:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020293c:	6098                	ld	a4,0(s1)
ffffffffc020293e:	c0200437          	lui	s0,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202942:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202944:	00c71793          	slli	a5,a4,0xc
ffffffffc0202948:	6a05                	lui	s4,0x1
ffffffffc020294a:	02f47c63          	bgeu	s0,a5,ffffffffc0202982 <pmm_init+0x406>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020294e:	00c45793          	srli	a5,s0,0xc
ffffffffc0202952:	00093503          	ld	a0,0(s2)
ffffffffc0202956:	2ee7f263          	bgeu	a5,a4,ffffffffc0202c3a <pmm_init+0x6be>
ffffffffc020295a:	0009b583          	ld	a1,0(s3)
ffffffffc020295e:	4601                	li	a2,0
ffffffffc0202960:	95a2                	add	a1,a1,s0
ffffffffc0202962:	c8aff0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0202966:	2a050a63          	beqz	a0,ffffffffc0202c1a <pmm_init+0x69e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020296a:	611c                	ld	a5,0(a0)
ffffffffc020296c:	078a                	slli	a5,a5,0x2
ffffffffc020296e:	0157f7b3          	and	a5,a5,s5
ffffffffc0202972:	28879463          	bne	a5,s0,ffffffffc0202bfa <pmm_init+0x67e>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202976:	6098                	ld	a4,0(s1)
ffffffffc0202978:	9452                	add	s0,s0,s4
ffffffffc020297a:	00c71793          	slli	a5,a4,0xc
ffffffffc020297e:	fcf468e3          	bltu	s0,a5,ffffffffc020294e <pmm_init+0x3d2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202982:	00093783          	ld	a5,0(s2)
ffffffffc0202986:	639c                	ld	a5,0(a5)
ffffffffc0202988:	66079b63          	bnez	a5,ffffffffc0202ffe <pmm_init+0xa82>

    struct Page *p;
    p = alloc_page();
ffffffffc020298c:	4505                	li	a0,1
ffffffffc020298e:	b52ff0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0202992:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	4699                	li	a3,6
ffffffffc020299a:	10000613          	li	a2,256
ffffffffc020299e:	85d6                	mv	a1,s5
ffffffffc02029a0:	ae7ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02029a4:	62051d63          	bnez	a0,ffffffffc0202fde <pmm_init+0xa62>
    assert(page_ref(p) == 1);
ffffffffc02029a8:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fd4c474>
ffffffffc02029ac:	4785                	li	a5,1
ffffffffc02029ae:	60f71863          	bne	a4,a5,ffffffffc0202fbe <pmm_init+0xa42>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02029b2:	00093503          	ld	a0,0(s2)
ffffffffc02029b6:	6405                	lui	s0,0x1
ffffffffc02029b8:	4699                	li	a3,6
ffffffffc02029ba:	10040613          	addi	a2,s0,256 # 1100 <_binary_obj___user_faultread_out_size-0x8ae0>
ffffffffc02029be:	85d6                	mv	a1,s5
ffffffffc02029c0:	ac7ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02029c4:	46051163          	bnez	a0,ffffffffc0202e26 <pmm_init+0x8aa>
    assert(page_ref(p) == 2);
ffffffffc02029c8:	000aa703          	lw	a4,0(s5)
ffffffffc02029cc:	4789                	li	a5,2
ffffffffc02029ce:	72f71463          	bne	a4,a5,ffffffffc02030f6 <pmm_init+0xb7a>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc02029d2:	00005597          	auipc	a1,0x5
ffffffffc02029d6:	06e58593          	addi	a1,a1,110 # ffffffffc0207a40 <default_pmm_manager+0x638>
ffffffffc02029da:	10000513          	li	a0,256
ffffffffc02029de:	46b030ef          	jal	ra,ffffffffc0206648 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02029e2:	10040593          	addi	a1,s0,256
ffffffffc02029e6:	10000513          	li	a0,256
ffffffffc02029ea:	471030ef          	jal	ra,ffffffffc020665a <strcmp>
ffffffffc02029ee:	6e051463          	bnez	a0,ffffffffc02030d6 <pmm_init+0xb5a>
    return page - pages + nbase;
ffffffffc02029f2:	000b3683          	ld	a3,0(s6)
ffffffffc02029f6:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc02029fa:	547d                	li	s0,-1
    return page - pages + nbase;
ffffffffc02029fc:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a00:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a02:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a04:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a06:	8031                	srli	s0,s0,0xc
ffffffffc0202a08:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a0c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a0e:	50f77c63          	bgeu	a4,a5,ffffffffc0202f26 <pmm_init+0x9aa>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a12:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a16:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a1a:	96be                	add	a3,a3,a5
ffffffffc0202a1c:	10068023          	sb	zero,256(a3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a20:	3f3030ef          	jal	ra,ffffffffc0206612 <strlen>
ffffffffc0202a24:	68051963          	bnez	a0,ffffffffc02030b6 <pmm_init+0xb3a>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a28:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0202a2c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a2e:	000a3683          	ld	a3,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8be0>
ffffffffc0202a32:	068a                	slli	a3,a3,0x2
ffffffffc0202a34:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a36:	20f6ff63          	bgeu	a3,a5,ffffffffc0202c54 <pmm_init+0x6d8>
    return KADDR(page2pa(page));
ffffffffc0202a3a:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a3c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a3e:	4ef47463          	bgeu	s0,a5,ffffffffc0202f26 <pmm_init+0x9aa>
ffffffffc0202a42:	0009b403          	ld	s0,0(s3)
ffffffffc0202a46:	9436                	add	s0,s0,a3
ffffffffc0202a48:	100027f3          	csrr	a5,sstatus
ffffffffc0202a4c:	8b89                	andi	a5,a5,2
ffffffffc0202a4e:	18079b63          	bnez	a5,ffffffffc0202be4 <pmm_init+0x668>
        pmm_manager->free_pages(base, n);
ffffffffc0202a52:	000bb783          	ld	a5,0(s7)
ffffffffc0202a56:	4585                	li	a1,1
ffffffffc0202a58:	8556                	mv	a0,s5
ffffffffc0202a5a:	739c                	ld	a5,32(a5)
ffffffffc0202a5c:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a5e:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a60:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a62:	078a                	slli	a5,a5,0x2
ffffffffc0202a64:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a66:	1ee7f763          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a6a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a6e:	fff80737          	lui	a4,0xfff80
ffffffffc0202a72:	97ba                	add	a5,a5,a4
ffffffffc0202a74:	079a                	slli	a5,a5,0x6
ffffffffc0202a76:	953e                	add	a0,a0,a5
ffffffffc0202a78:	100027f3          	csrr	a5,sstatus
ffffffffc0202a7c:	8b89                	andi	a5,a5,2
ffffffffc0202a7e:	14079763          	bnez	a5,ffffffffc0202bcc <pmm_init+0x650>
ffffffffc0202a82:	000bb783          	ld	a5,0(s7)
ffffffffc0202a86:	4585                	li	a1,1
ffffffffc0202a88:	739c                	ld	a5,32(a5)
ffffffffc0202a8a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a8c:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0202a90:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a92:	078a                	slli	a5,a5,0x2
ffffffffc0202a94:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a96:	1ae7ff63          	bgeu	a5,a4,ffffffffc0202c54 <pmm_init+0x6d8>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a9a:	000b3503          	ld	a0,0(s6)
ffffffffc0202a9e:	fff80737          	lui	a4,0xfff80
ffffffffc0202aa2:	97ba                	add	a5,a5,a4
ffffffffc0202aa4:	079a                	slli	a5,a5,0x6
ffffffffc0202aa6:	953e                	add	a0,a0,a5
ffffffffc0202aa8:	100027f3          	csrr	a5,sstatus
ffffffffc0202aac:	8b89                	andi	a5,a5,2
ffffffffc0202aae:	10079363          	bnez	a5,ffffffffc0202bb4 <pmm_init+0x638>
ffffffffc0202ab2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ab6:	4585                	li	a1,1
ffffffffc0202ab8:	739c                	ld	a5,32(a5)
ffffffffc0202aba:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir[0] = 0;
ffffffffc0202abc:	00093783          	ld	a5,0(s2)
ffffffffc0202ac0:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202ac4:	12000073          	sfence.vma
ffffffffc0202ac8:	100027f3          	csrr	a5,sstatus
ffffffffc0202acc:	8b89                	andi	a5,a5,2
ffffffffc0202ace:	0c079963          	bnez	a5,ffffffffc0202ba0 <pmm_init+0x624>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ad2:	000bb783          	ld	a5,0(s7)
ffffffffc0202ad6:	779c                	ld	a5,40(a5)
ffffffffc0202ad8:	9782                	jalr	a5
ffffffffc0202ada:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202adc:	3a8c1563          	bne	s8,s0,ffffffffc0202e86 <pmm_init+0x90a>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202ae0:	00005517          	auipc	a0,0x5
ffffffffc0202ae4:	fd850513          	addi	a0,a0,-40 # ffffffffc0207ab8 <default_pmm_manager+0x6b0>
ffffffffc0202ae8:	e98fd0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0202aec:	6446                	ld	s0,80(sp)
ffffffffc0202aee:	60e6                	ld	ra,88(sp)
ffffffffc0202af0:	64a6                	ld	s1,72(sp)
ffffffffc0202af2:	6906                	ld	s2,64(sp)
ffffffffc0202af4:	79e2                	ld	s3,56(sp)
ffffffffc0202af6:	7a42                	ld	s4,48(sp)
ffffffffc0202af8:	7aa2                	ld	s5,40(sp)
ffffffffc0202afa:	7b02                	ld	s6,32(sp)
ffffffffc0202afc:	6be2                	ld	s7,24(sp)
ffffffffc0202afe:	6c42                	ld	s8,16(sp)
ffffffffc0202b00:	6125                	addi	sp,sp,96
    kmalloc_init();
ffffffffc0202b02:	fddfe06f          	j	ffffffffc0201ade <kmalloc_init>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202b06:	6785                	lui	a5,0x1
ffffffffc0202b08:	17fd                	addi	a5,a5,-1
ffffffffc0202b0a:	96be                	add	a3,a3,a5
ffffffffc0202b0c:	77fd                	lui	a5,0xfffff
ffffffffc0202b0e:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage) {
ffffffffc0202b10:	00c7d693          	srli	a3,a5,0xc
ffffffffc0202b14:	14c6f063          	bgeu	a3,a2,ffffffffc0202c54 <pmm_init+0x6d8>
    pmm_manager->init_memmap(base, n);
ffffffffc0202b18:	000bb603          	ld	a2,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc0202b1c:	96c2                	add	a3,a3,a6
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202b1e:	40f707b3          	sub	a5,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202b22:	6a10                	ld	a2,16(a2)
ffffffffc0202b24:	069a                	slli	a3,a3,0x6
ffffffffc0202b26:	00c7d593          	srli	a1,a5,0xc
ffffffffc0202b2a:	9536                	add	a0,a0,a3
ffffffffc0202b2c:	9602                	jalr	a2
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202b2e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202b32:	b63d                	j	ffffffffc0202660 <pmm_init+0xe4>
        intr_disable();
ffffffffc0202b34:	b13fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202b38:	000bb783          	ld	a5,0(s7)
ffffffffc0202b3c:	779c                	ld	a5,40(a5)
ffffffffc0202b3e:	9782                	jalr	a5
ffffffffc0202b40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202b42:	afffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b46:	bea5                	j	ffffffffc02026be <pmm_init+0x142>
        intr_disable();
ffffffffc0202b48:	afffd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b4c:	000bb783          	ld	a5,0(s7)
ffffffffc0202b50:	779c                	ld	a5,40(a5)
ffffffffc0202b52:	9782                	jalr	a5
ffffffffc0202b54:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202b56:	aebfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b5a:	b3cd                	j	ffffffffc020293c <pmm_init+0x3c0>
        intr_disable();
ffffffffc0202b5c:	aebfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b60:	000bb783          	ld	a5,0(s7)
ffffffffc0202b64:	779c                	ld	a5,40(a5)
ffffffffc0202b66:	9782                	jalr	a5
ffffffffc0202b68:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202b6a:	ad7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b6e:	b36d                	j	ffffffffc0202918 <pmm_init+0x39c>
ffffffffc0202b70:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b72:	ad5fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202b76:	000bb783          	ld	a5,0(s7)
ffffffffc0202b7a:	6522                	ld	a0,8(sp)
ffffffffc0202b7c:	4585                	li	a1,1
ffffffffc0202b7e:	739c                	ld	a5,32(a5)
ffffffffc0202b80:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b82:	abffd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b86:	bb8d                	j	ffffffffc02028f8 <pmm_init+0x37c>
ffffffffc0202b88:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202b8a:	abdfd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202b8e:	000bb783          	ld	a5,0(s7)
ffffffffc0202b92:	6522                	ld	a0,8(sp)
ffffffffc0202b94:	4585                	li	a1,1
ffffffffc0202b96:	739c                	ld	a5,32(a5)
ffffffffc0202b98:	9782                	jalr	a5
        intr_enable();
ffffffffc0202b9a:	aa7fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202b9e:	b32d                	j	ffffffffc02028c8 <pmm_init+0x34c>
        intr_disable();
ffffffffc0202ba0:	aa7fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ba4:	000bb783          	ld	a5,0(s7)
ffffffffc0202ba8:	779c                	ld	a5,40(a5)
ffffffffc0202baa:	9782                	jalr	a5
ffffffffc0202bac:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202bae:	a93fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bb2:	b72d                	j	ffffffffc0202adc <pmm_init+0x560>
ffffffffc0202bb4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bb6:	a91fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202bba:	000bb783          	ld	a5,0(s7)
ffffffffc0202bbe:	6522                	ld	a0,8(sp)
ffffffffc0202bc0:	4585                	li	a1,1
ffffffffc0202bc2:	739c                	ld	a5,32(a5)
ffffffffc0202bc4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bc6:	a7bfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bca:	bdcd                	j	ffffffffc0202abc <pmm_init+0x540>
ffffffffc0202bcc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202bce:	a79fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202bd2:	000bb783          	ld	a5,0(s7)
ffffffffc0202bd6:	6522                	ld	a0,8(sp)
ffffffffc0202bd8:	4585                	li	a1,1
ffffffffc0202bda:	739c                	ld	a5,32(a5)
ffffffffc0202bdc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bde:	a63fd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202be2:	b56d                	j	ffffffffc0202a8c <pmm_init+0x510>
        intr_disable();
ffffffffc0202be4:	a63fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
ffffffffc0202be8:	000bb783          	ld	a5,0(s7)
ffffffffc0202bec:	4585                	li	a1,1
ffffffffc0202bee:	8556                	mv	a0,s5
ffffffffc0202bf0:	739c                	ld	a5,32(a5)
ffffffffc0202bf2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202bf4:	a4dfd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc0202bf8:	b59d                	j	ffffffffc0202a5e <pmm_init+0x4e2>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202bfa:	00005697          	auipc	a3,0x5
ffffffffc0202bfe:	d6e68693          	addi	a3,a3,-658 # ffffffffc0207968 <default_pmm_manager+0x560>
ffffffffc0202c02:	00004617          	auipc	a2,0x4
ffffffffc0202c06:	16e60613          	addi	a2,a2,366 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202c0a:	22f00593          	li	a1,559
ffffffffc0202c0e:	00005517          	auipc	a0,0x5
ffffffffc0202c12:	94a50513          	addi	a0,a0,-1718 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202c16:	865fd0ef          	jal	ra,ffffffffc020047a <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c1a:	00005697          	auipc	a3,0x5
ffffffffc0202c1e:	d0e68693          	addi	a3,a3,-754 # ffffffffc0207928 <default_pmm_manager+0x520>
ffffffffc0202c22:	00004617          	auipc	a2,0x4
ffffffffc0202c26:	14e60613          	addi	a2,a2,334 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202c2a:	22e00593          	li	a1,558
ffffffffc0202c2e:	00005517          	auipc	a0,0x5
ffffffffc0202c32:	92a50513          	addi	a0,a0,-1750 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202c36:	845fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c3a:	86a2                	mv	a3,s0
ffffffffc0202c3c:	00005617          	auipc	a2,0x5
ffffffffc0202c40:	80460613          	addi	a2,a2,-2044 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0202c44:	22e00593          	li	a1,558
ffffffffc0202c48:	00005517          	auipc	a0,0x5
ffffffffc0202c4c:	91050513          	addi	a0,a0,-1776 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202c50:	82bfd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202c54:	854ff0ef          	jal	ra,ffffffffc0201ca8 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c58:	00005617          	auipc	a2,0x5
ffffffffc0202c5c:	89060613          	addi	a2,a2,-1904 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0202c60:	07f00593          	li	a1,127
ffffffffc0202c64:	00005517          	auipc	a0,0x5
ffffffffc0202c68:	8f450513          	addi	a0,a0,-1804 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202c6c:	80ffd0ef          	jal	ra,ffffffffc020047a <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202c70:	00005617          	auipc	a2,0x5
ffffffffc0202c74:	87860613          	addi	a2,a2,-1928 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0202c78:	0c100593          	li	a1,193
ffffffffc0202c7c:	00005517          	auipc	a0,0x5
ffffffffc0202c80:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202c84:	ff6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202c88:	00005697          	auipc	a3,0x5
ffffffffc0202c8c:	9d868693          	addi	a3,a3,-1576 # ffffffffc0207660 <default_pmm_manager+0x258>
ffffffffc0202c90:	00004617          	auipc	a2,0x4
ffffffffc0202c94:	0e060613          	addi	a2,a2,224 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202c98:	1f200593          	li	a1,498
ffffffffc0202c9c:	00005517          	auipc	a0,0x5
ffffffffc0202ca0:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202ca4:	fd6fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202ca8:	00005697          	auipc	a3,0x5
ffffffffc0202cac:	99868693          	addi	a3,a3,-1640 # ffffffffc0207640 <default_pmm_manager+0x238>
ffffffffc0202cb0:	00004617          	auipc	a2,0x4
ffffffffc0202cb4:	0c060613          	addi	a2,a2,192 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202cb8:	1f100593          	li	a1,497
ffffffffc0202cbc:	00005517          	auipc	a0,0x5
ffffffffc0202cc0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202cc4:	fb6fd0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0202cc8:	ffdfe0ef          	jal	ra,ffffffffc0201cc4 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202ccc:	00005697          	auipc	a3,0x5
ffffffffc0202cd0:	a2468693          	addi	a3,a3,-1500 # ffffffffc02076f0 <default_pmm_manager+0x2e8>
ffffffffc0202cd4:	00004617          	auipc	a2,0x4
ffffffffc0202cd8:	09c60613          	addi	a2,a2,156 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202cdc:	1fa00593          	li	a1,506
ffffffffc0202ce0:	00005517          	auipc	a0,0x5
ffffffffc0202ce4:	87850513          	addi	a0,a0,-1928 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202ce8:	f92fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202cec:	00005697          	auipc	a3,0x5
ffffffffc0202cf0:	9d468693          	addi	a3,a3,-1580 # ffffffffc02076c0 <default_pmm_manager+0x2b8>
ffffffffc0202cf4:	00004617          	auipc	a2,0x4
ffffffffc0202cf8:	07c60613          	addi	a2,a2,124 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202cfc:	1f700593          	li	a1,503
ffffffffc0202d00:	00005517          	auipc	a0,0x5
ffffffffc0202d04:	85850513          	addi	a0,a0,-1960 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202d08:	f72fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202d0c:	00005697          	auipc	a3,0x5
ffffffffc0202d10:	98c68693          	addi	a3,a3,-1652 # ffffffffc0207698 <default_pmm_manager+0x290>
ffffffffc0202d14:	00004617          	auipc	a2,0x4
ffffffffc0202d18:	05c60613          	addi	a2,a2,92 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202d1c:	1f300593          	li	a1,499
ffffffffc0202d20:	00005517          	auipc	a0,0x5
ffffffffc0202d24:	83850513          	addi	a0,a0,-1992 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202d28:	f52fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d2c:	00005697          	auipc	a3,0x5
ffffffffc0202d30:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0207778 <default_pmm_manager+0x370>
ffffffffc0202d34:	00004617          	auipc	a2,0x4
ffffffffc0202d38:	03c60613          	addi	a2,a2,60 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202d3c:	20300593          	li	a1,515
ffffffffc0202d40:	00005517          	auipc	a0,0x5
ffffffffc0202d44:	81850513          	addi	a0,a0,-2024 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202d48:	f32fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202d4c:	00005697          	auipc	a3,0x5
ffffffffc0202d50:	acc68693          	addi	a3,a3,-1332 # ffffffffc0207818 <default_pmm_manager+0x410>
ffffffffc0202d54:	00004617          	auipc	a2,0x4
ffffffffc0202d58:	01c60613          	addi	a2,a2,28 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202d5c:	20800593          	li	a1,520
ffffffffc0202d60:	00004517          	auipc	a0,0x4
ffffffffc0202d64:	7f850513          	addi	a0,a0,2040 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202d68:	f12fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d6c:	00005697          	auipc	a3,0x5
ffffffffc0202d70:	9e468693          	addi	a3,a3,-1564 # ffffffffc0207750 <default_pmm_manager+0x348>
ffffffffc0202d74:	00004617          	auipc	a2,0x4
ffffffffc0202d78:	ffc60613          	addi	a2,a2,-4 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202d7c:	20000593          	li	a1,512
ffffffffc0202d80:	00004517          	auipc	a0,0x4
ffffffffc0202d84:	7d850513          	addi	a0,a0,2008 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202d88:	ef2fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d8c:	86d6                	mv	a3,s5
ffffffffc0202d8e:	00004617          	auipc	a2,0x4
ffffffffc0202d92:	6b260613          	addi	a2,a2,1714 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0202d96:	1ff00593          	li	a1,511
ffffffffc0202d9a:	00004517          	auipc	a0,0x4
ffffffffc0202d9e:	7be50513          	addi	a0,a0,1982 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202da2:	ed8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202da6:	00005697          	auipc	a3,0x5
ffffffffc0202daa:	a0a68693          	addi	a3,a3,-1526 # ffffffffc02077b0 <default_pmm_manager+0x3a8>
ffffffffc0202dae:	00004617          	auipc	a2,0x4
ffffffffc0202db2:	fc260613          	addi	a2,a2,-62 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202db6:	20d00593          	li	a1,525
ffffffffc0202dba:	00004517          	auipc	a0,0x4
ffffffffc0202dbe:	79e50513          	addi	a0,a0,1950 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202dc2:	eb8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dc6:	00005697          	auipc	a3,0x5
ffffffffc0202dca:	ab268693          	addi	a3,a3,-1358 # ffffffffc0207878 <default_pmm_manager+0x470>
ffffffffc0202dce:	00004617          	auipc	a2,0x4
ffffffffc0202dd2:	fa260613          	addi	a2,a2,-94 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202dd6:	20c00593          	li	a1,524
ffffffffc0202dda:	00004517          	auipc	a0,0x4
ffffffffc0202dde:	77e50513          	addi	a0,a0,1918 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202de2:	e98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202de6:	00005697          	auipc	a3,0x5
ffffffffc0202dea:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0207860 <default_pmm_manager+0x458>
ffffffffc0202dee:	00004617          	auipc	a2,0x4
ffffffffc0202df2:	f8260613          	addi	a2,a2,-126 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202df6:	20b00593          	li	a1,523
ffffffffc0202dfa:	00004517          	auipc	a0,0x4
ffffffffc0202dfe:	75e50513          	addi	a0,a0,1886 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202e02:	e78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202e06:	00005697          	auipc	a3,0x5
ffffffffc0202e0a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0207830 <default_pmm_manager+0x428>
ffffffffc0202e0e:	00004617          	auipc	a2,0x4
ffffffffc0202e12:	f6260613          	addi	a2,a2,-158 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202e16:	20a00593          	li	a1,522
ffffffffc0202e1a:	00004517          	auipc	a0,0x4
ffffffffc0202e1e:	73e50513          	addi	a0,a0,1854 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202e22:	e58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e26:	00005697          	auipc	a3,0x5
ffffffffc0202e2a:	bc268693          	addi	a3,a3,-1086 # ffffffffc02079e8 <default_pmm_manager+0x5e0>
ffffffffc0202e2e:	00004617          	auipc	a2,0x4
ffffffffc0202e32:	f4260613          	addi	a2,a2,-190 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202e36:	23900593          	li	a1,569
ffffffffc0202e3a:	00004517          	auipc	a0,0x4
ffffffffc0202e3e:	71e50513          	addi	a0,a0,1822 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202e42:	e38fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202e46:	00005697          	auipc	a3,0x5
ffffffffc0202e4a:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0207800 <default_pmm_manager+0x3f8>
ffffffffc0202e4e:	00004617          	auipc	a2,0x4
ffffffffc0202e52:	f2260613          	addi	a2,a2,-222 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202e56:	20700593          	li	a1,519
ffffffffc0202e5a:	00004517          	auipc	a0,0x4
ffffffffc0202e5e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202e62:	e18fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202e66:	00005697          	auipc	a3,0x5
ffffffffc0202e6a:	98a68693          	addi	a3,a3,-1654 # ffffffffc02077f0 <default_pmm_manager+0x3e8>
ffffffffc0202e6e:	00004617          	auipc	a2,0x4
ffffffffc0202e72:	f0260613          	addi	a2,a2,-254 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202e76:	20600593          	li	a1,518
ffffffffc0202e7a:	00004517          	auipc	a0,0x4
ffffffffc0202e7e:	6de50513          	addi	a0,a0,1758 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202e82:	df8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202e86:	00005697          	auipc	a3,0x5
ffffffffc0202e8a:	a6268693          	addi	a3,a3,-1438 # ffffffffc02078e8 <default_pmm_manager+0x4e0>
ffffffffc0202e8e:	00004617          	auipc	a2,0x4
ffffffffc0202e92:	ee260613          	addi	a2,a2,-286 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202e96:	24a00593          	li	a1,586
ffffffffc0202e9a:	00004517          	auipc	a0,0x4
ffffffffc0202e9e:	6be50513          	addi	a0,a0,1726 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202ea2:	dd8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ea6:	00005697          	auipc	a3,0x5
ffffffffc0202eaa:	93a68693          	addi	a3,a3,-1734 # ffffffffc02077e0 <default_pmm_manager+0x3d8>
ffffffffc0202eae:	00004617          	auipc	a2,0x4
ffffffffc0202eb2:	ec260613          	addi	a2,a2,-318 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202eb6:	20500593          	li	a1,517
ffffffffc0202eba:	00004517          	auipc	a0,0x4
ffffffffc0202ebe:	69e50513          	addi	a0,a0,1694 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202ec2:	db8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ec6:	00005697          	auipc	a3,0x5
ffffffffc0202eca:	87268693          	addi	a3,a3,-1934 # ffffffffc0207738 <default_pmm_manager+0x330>
ffffffffc0202ece:	00004617          	auipc	a2,0x4
ffffffffc0202ed2:	ea260613          	addi	a2,a2,-350 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202ed6:	21200593          	li	a1,530
ffffffffc0202eda:	00004517          	auipc	a0,0x4
ffffffffc0202ede:	67e50513          	addi	a0,a0,1662 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202ee2:	d98fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ee6:	00005697          	auipc	a3,0x5
ffffffffc0202eea:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0207890 <default_pmm_manager+0x488>
ffffffffc0202eee:	00004617          	auipc	a2,0x4
ffffffffc0202ef2:	e8260613          	addi	a2,a2,-382 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202ef6:	20f00593          	li	a1,527
ffffffffc0202efa:	00004517          	auipc	a0,0x4
ffffffffc0202efe:	65e50513          	addi	a0,a0,1630 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202f02:	d78fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f06:	00005697          	auipc	a3,0x5
ffffffffc0202f0a:	81a68693          	addi	a3,a3,-2022 # ffffffffc0207720 <default_pmm_manager+0x318>
ffffffffc0202f0e:	00004617          	auipc	a2,0x4
ffffffffc0202f12:	e6260613          	addi	a2,a2,-414 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202f16:	20e00593          	li	a1,526
ffffffffc0202f1a:	00004517          	auipc	a0,0x4
ffffffffc0202f1e:	63e50513          	addi	a0,a0,1598 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202f22:	d58fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202f26:	00004617          	auipc	a2,0x4
ffffffffc0202f2a:	51a60613          	addi	a2,a2,1306 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0202f2e:	06900593          	li	a1,105
ffffffffc0202f32:	00004517          	auipc	a0,0x4
ffffffffc0202f36:	53650513          	addi	a0,a0,1334 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0202f3a:	d40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202f3e:	00005697          	auipc	a3,0x5
ffffffffc0202f42:	98268693          	addi	a3,a3,-1662 # ffffffffc02078c0 <default_pmm_manager+0x4b8>
ffffffffc0202f46:	00004617          	auipc	a2,0x4
ffffffffc0202f4a:	e2a60613          	addi	a2,a2,-470 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202f4e:	21900593          	li	a1,537
ffffffffc0202f52:	00004517          	auipc	a0,0x4
ffffffffc0202f56:	60650513          	addi	a0,a0,1542 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202f5a:	d20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f5e:	00005697          	auipc	a3,0x5
ffffffffc0202f62:	91a68693          	addi	a3,a3,-1766 # ffffffffc0207878 <default_pmm_manager+0x470>
ffffffffc0202f66:	00004617          	auipc	a2,0x4
ffffffffc0202f6a:	e0a60613          	addi	a2,a2,-502 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202f6e:	21700593          	li	a1,535
ffffffffc0202f72:	00004517          	auipc	a0,0x4
ffffffffc0202f76:	5e650513          	addi	a0,a0,1510 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202f7a:	d00fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202f7e:	00005697          	auipc	a3,0x5
ffffffffc0202f82:	92a68693          	addi	a3,a3,-1750 # ffffffffc02078a8 <default_pmm_manager+0x4a0>
ffffffffc0202f86:	00004617          	auipc	a2,0x4
ffffffffc0202f8a:	dea60613          	addi	a2,a2,-534 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202f8e:	21600593          	li	a1,534
ffffffffc0202f92:	00004517          	auipc	a0,0x4
ffffffffc0202f96:	5c650513          	addi	a0,a0,1478 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202f9a:	ce0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f9e:	00005697          	auipc	a3,0x5
ffffffffc0202fa2:	8da68693          	addi	a3,a3,-1830 # ffffffffc0207878 <default_pmm_manager+0x470>
ffffffffc0202fa6:	00004617          	auipc	a2,0x4
ffffffffc0202faa:	dca60613          	addi	a2,a2,-566 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202fae:	21300593          	li	a1,531
ffffffffc0202fb2:	00004517          	auipc	a0,0x4
ffffffffc0202fb6:	5a650513          	addi	a0,a0,1446 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202fba:	cc0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202fbe:	00005697          	auipc	a3,0x5
ffffffffc0202fc2:	a1268693          	addi	a3,a3,-1518 # ffffffffc02079d0 <default_pmm_manager+0x5c8>
ffffffffc0202fc6:	00004617          	auipc	a2,0x4
ffffffffc0202fca:	daa60613          	addi	a2,a2,-598 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202fce:	23800593          	li	a1,568
ffffffffc0202fd2:	00004517          	auipc	a0,0x4
ffffffffc0202fd6:	58650513          	addi	a0,a0,1414 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202fda:	ca0fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202fde:	00005697          	auipc	a3,0x5
ffffffffc0202fe2:	9ba68693          	addi	a3,a3,-1606 # ffffffffc0207998 <default_pmm_manager+0x590>
ffffffffc0202fe6:	00004617          	auipc	a2,0x4
ffffffffc0202fea:	d8a60613          	addi	a2,a2,-630 # ffffffffc0206d70 <commands+0x450>
ffffffffc0202fee:	23700593          	li	a1,567
ffffffffc0202ff2:	00004517          	auipc	a0,0x4
ffffffffc0202ff6:	56650513          	addi	a0,a0,1382 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0202ffa:	c80fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202ffe:	00005697          	auipc	a3,0x5
ffffffffc0203002:	98268693          	addi	a3,a3,-1662 # ffffffffc0207980 <default_pmm_manager+0x578>
ffffffffc0203006:	00004617          	auipc	a2,0x4
ffffffffc020300a:	d6a60613          	addi	a2,a2,-662 # ffffffffc0206d70 <commands+0x450>
ffffffffc020300e:	23300593          	li	a1,563
ffffffffc0203012:	00004517          	auipc	a0,0x4
ffffffffc0203016:	54650513          	addi	a0,a0,1350 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc020301a:	c60fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020301e:	00005697          	auipc	a3,0x5
ffffffffc0203022:	8ca68693          	addi	a3,a3,-1846 # ffffffffc02078e8 <default_pmm_manager+0x4e0>
ffffffffc0203026:	00004617          	auipc	a2,0x4
ffffffffc020302a:	d4a60613          	addi	a2,a2,-694 # ffffffffc0206d70 <commands+0x450>
ffffffffc020302e:	22100593          	li	a1,545
ffffffffc0203032:	00004517          	auipc	a0,0x4
ffffffffc0203036:	52650513          	addi	a0,a0,1318 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc020303a:	c40fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020303e:	00004697          	auipc	a3,0x4
ffffffffc0203042:	6e268693          	addi	a3,a3,1762 # ffffffffc0207720 <default_pmm_manager+0x318>
ffffffffc0203046:	00004617          	auipc	a2,0x4
ffffffffc020304a:	d2a60613          	addi	a2,a2,-726 # ffffffffc0206d70 <commands+0x450>
ffffffffc020304e:	1fb00593          	li	a1,507
ffffffffc0203052:	00004517          	auipc	a0,0x4
ffffffffc0203056:	50650513          	addi	a0,a0,1286 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc020305a:	c20fd0ef          	jal	ra,ffffffffc020047a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020305e:	00004617          	auipc	a2,0x4
ffffffffc0203062:	3e260613          	addi	a2,a2,994 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0203066:	1fe00593          	li	a1,510
ffffffffc020306a:	00004517          	auipc	a0,0x4
ffffffffc020306e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203072:	c08fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203076:	00004697          	auipc	a3,0x4
ffffffffc020307a:	6c268693          	addi	a3,a3,1730 # ffffffffc0207738 <default_pmm_manager+0x330>
ffffffffc020307e:	00004617          	auipc	a2,0x4
ffffffffc0203082:	cf260613          	addi	a2,a2,-782 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203086:	1fc00593          	li	a1,508
ffffffffc020308a:	00004517          	auipc	a0,0x4
ffffffffc020308e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203092:	be8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0203096:	00004697          	auipc	a3,0x4
ffffffffc020309a:	71a68693          	addi	a3,a3,1818 # ffffffffc02077b0 <default_pmm_manager+0x3a8>
ffffffffc020309e:	00004617          	auipc	a2,0x4
ffffffffc02030a2:	cd260613          	addi	a2,a2,-814 # ffffffffc0206d70 <commands+0x450>
ffffffffc02030a6:	20400593          	li	a1,516
ffffffffc02030aa:	00004517          	auipc	a0,0x4
ffffffffc02030ae:	4ae50513          	addi	a0,a0,1198 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc02030b2:	bc8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02030b6:	00005697          	auipc	a3,0x5
ffffffffc02030ba:	9da68693          	addi	a3,a3,-1574 # ffffffffc0207a90 <default_pmm_manager+0x688>
ffffffffc02030be:	00004617          	auipc	a2,0x4
ffffffffc02030c2:	cb260613          	addi	a2,a2,-846 # ffffffffc0206d70 <commands+0x450>
ffffffffc02030c6:	24100593          	li	a1,577
ffffffffc02030ca:	00004517          	auipc	a0,0x4
ffffffffc02030ce:	48e50513          	addi	a0,a0,1166 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc02030d2:	ba8fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02030d6:	00005697          	auipc	a3,0x5
ffffffffc02030da:	98268693          	addi	a3,a3,-1662 # ffffffffc0207a58 <default_pmm_manager+0x650>
ffffffffc02030de:	00004617          	auipc	a2,0x4
ffffffffc02030e2:	c9260613          	addi	a2,a2,-878 # ffffffffc0206d70 <commands+0x450>
ffffffffc02030e6:	23e00593          	li	a1,574
ffffffffc02030ea:	00004517          	auipc	a0,0x4
ffffffffc02030ee:	46e50513          	addi	a0,a0,1134 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc02030f2:	b88fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02030f6:	00005697          	auipc	a3,0x5
ffffffffc02030fa:	93268693          	addi	a3,a3,-1742 # ffffffffc0207a28 <default_pmm_manager+0x620>
ffffffffc02030fe:	00004617          	auipc	a2,0x4
ffffffffc0203102:	c7260613          	addi	a2,a2,-910 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203106:	23a00593          	li	a1,570
ffffffffc020310a:	00004517          	auipc	a0,0x4
ffffffffc020310e:	44e50513          	addi	a0,a0,1102 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203112:	b68fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203116 <copy_range>:
               bool share) {
ffffffffc0203116:	7119                	addi	sp,sp,-128
ffffffffc0203118:	f4a6                	sd	s1,104(sp)
ffffffffc020311a:	84b6                	mv	s1,a3
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020311c:	8ed1                	or	a3,a3,a2
               bool share) {
ffffffffc020311e:	fc86                	sd	ra,120(sp)
ffffffffc0203120:	f8a2                	sd	s0,112(sp)
ffffffffc0203122:	f0ca                	sd	s2,96(sp)
ffffffffc0203124:	ecce                	sd	s3,88(sp)
ffffffffc0203126:	e8d2                	sd	s4,80(sp)
ffffffffc0203128:	e4d6                	sd	s5,72(sp)
ffffffffc020312a:	e0da                	sd	s6,64(sp)
ffffffffc020312c:	fc5e                	sd	s7,56(sp)
ffffffffc020312e:	f862                	sd	s8,48(sp)
ffffffffc0203130:	f466                	sd	s9,40(sp)
ffffffffc0203132:	f06a                	sd	s10,32(sp)
ffffffffc0203134:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203136:	16d2                	slli	a3,a3,0x34
               bool share) {
ffffffffc0203138:	e03a                	sd	a4,0(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020313a:	22069163          	bnez	a3,ffffffffc020335c <copy_range+0x246>
    assert(USER_ACCESS(start, end));
ffffffffc020313e:	00200737          	lui	a4,0x200
ffffffffc0203142:	8db2                	mv	s11,a2
ffffffffc0203144:	18e66363          	bltu	a2,a4,ffffffffc02032ca <copy_range+0x1b4>
ffffffffc0203148:	18967163          	bgeu	a2,s1,ffffffffc02032ca <copy_range+0x1b4>
ffffffffc020314c:	4705                	li	a4,1
ffffffffc020314e:	077e                	slli	a4,a4,0x1f
ffffffffc0203150:	16976d63          	bltu	a4,s1,ffffffffc02032ca <copy_range+0x1b4>
ffffffffc0203154:	5bfd                	li	s7,-1
ffffffffc0203156:	8a2a                	mv	s4,a0
ffffffffc0203158:	842e                	mv	s0,a1
        start += PGSIZE;
ffffffffc020315a:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc020315c:	000b0b17          	auipc	s6,0xb0
ffffffffc0203160:	9ccb0b13          	addi	s6,s6,-1588 # ffffffffc02b2b28 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203164:	000b0a97          	auipc	s5,0xb0
ffffffffc0203168:	9cca8a93          	addi	s5,s5,-1588 # ffffffffc02b2b30 <pages>
ffffffffc020316c:	fff80d37          	lui	s10,0xfff80
    return page - pages + nbase;
ffffffffc0203170:	00080cb7          	lui	s9,0x80
    return KADDR(page2pa(page));
ffffffffc0203174:	00cbdb93          	srli	s7,s7,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0203178:	4601                	li	a2,0
ffffffffc020317a:	85ee                	mv	a1,s11
ffffffffc020317c:	8522                	mv	a0,s0
ffffffffc020317e:	c6ffe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203182:	892a                	mv	s2,a0
        if (ptep == NULL) {
ffffffffc0203184:	c95d                	beqz	a0,ffffffffc020323a <copy_range+0x124>
        if (*ptep & PTE_V) {
ffffffffc0203186:	6118                	ld	a4,0(a0)
ffffffffc0203188:	8b05                	andi	a4,a4,1
ffffffffc020318a:	e705                	bnez	a4,ffffffffc02031b2 <copy_range+0x9c>
        start += PGSIZE;
ffffffffc020318c:	9dce                	add	s11,s11,s3
    } while (start != 0 && start < end);
ffffffffc020318e:	fe9de5e3          	bltu	s11,s1,ffffffffc0203178 <copy_range+0x62>
    return 0;
ffffffffc0203192:	4501                	li	a0,0
}
ffffffffc0203194:	70e6                	ld	ra,120(sp)
ffffffffc0203196:	7446                	ld	s0,112(sp)
ffffffffc0203198:	74a6                	ld	s1,104(sp)
ffffffffc020319a:	7906                	ld	s2,96(sp)
ffffffffc020319c:	69e6                	ld	s3,88(sp)
ffffffffc020319e:	6a46                	ld	s4,80(sp)
ffffffffc02031a0:	6aa6                	ld	s5,72(sp)
ffffffffc02031a2:	6b06                	ld	s6,64(sp)
ffffffffc02031a4:	7be2                	ld	s7,56(sp)
ffffffffc02031a6:	7c42                	ld	s8,48(sp)
ffffffffc02031a8:	7ca2                	ld	s9,40(sp)
ffffffffc02031aa:	7d02                	ld	s10,32(sp)
ffffffffc02031ac:	6de2                	ld	s11,24(sp)
ffffffffc02031ae:	6109                	addi	sp,sp,128
ffffffffc02031b0:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02031b2:	4605                	li	a2,1
ffffffffc02031b4:	85ee                	mv	a1,s11
ffffffffc02031b6:	8552                	mv	a0,s4
ffffffffc02031b8:	c35fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02031bc:	0e050963          	beqz	a0,ffffffffc02032ae <copy_range+0x198>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02031c0:	00093703          	ld	a4,0(s2)
    if (!(pte & PTE_V)) {
ffffffffc02031c4:	00177693          	andi	a3,a4,1
ffffffffc02031c8:	0007091b          	sext.w	s2,a4
ffffffffc02031cc:	12068c63          	beqz	a3,ffffffffc0203304 <copy_range+0x1ee>
    if (PPN(pa) >= npage) {
ffffffffc02031d0:	000b3683          	ld	a3,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc02031d4:	070a                	slli	a4,a4,0x2
ffffffffc02031d6:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc02031d8:	0cd77d63          	bgeu	a4,a3,ffffffffc02032b2 <copy_range+0x19c>
    return &pages[PPN(pa) - nbase];
ffffffffc02031dc:	000ab583          	ld	a1,0(s5)
ffffffffc02031e0:	976a                	add	a4,a4,s10
ffffffffc02031e2:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc02031e4:	4505                	li	a0,1
ffffffffc02031e6:	00e58c33          	add	s8,a1,a4
ffffffffc02031ea:	af7fe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02031ee:	882a                	mv	a6,a0
            assert(page != NULL);
ffffffffc02031f0:	120c0663          	beqz	s8,ffffffffc020331c <copy_range+0x206>
            assert(npage != NULL);
ffffffffc02031f4:	14050463          	beqz	a0,ffffffffc020333c <copy_range+0x226>
            if(share) {
ffffffffc02031f8:	6782                	ld	a5,0(sp)
ffffffffc02031fa:	cfa9                	beqz	a5,ffffffffc0203254 <copy_range+0x13e>
                page_insert(from, page, start, perm &(~PTE_W));
ffffffffc02031fc:	01b97913          	andi	s2,s2,27
ffffffffc0203200:	86ca                	mv	a3,s2
ffffffffc0203202:	866e                	mv	a2,s11
ffffffffc0203204:	85e2                	mv	a1,s8
ffffffffc0203206:	8522                	mv	a0,s0
ffffffffc0203208:	a7eff0ef          	jal	ra,ffffffffc0202486 <page_insert>
                ret = page_insert(to, page, start, perm &(~PTE_W));
ffffffffc020320c:	86ca                	mv	a3,s2
ffffffffc020320e:	866e                	mv	a2,s11
ffffffffc0203210:	85e2                	mv	a1,s8
ffffffffc0203212:	8552                	mv	a0,s4
ffffffffc0203214:	a72ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
            assert(ret == 0);
ffffffffc0203218:	d935                	beqz	a0,ffffffffc020318c <copy_range+0x76>
ffffffffc020321a:	00005697          	auipc	a3,0x5
ffffffffc020321e:	8de68693          	addi	a3,a3,-1826 # ffffffffc0207af8 <default_pmm_manager+0x6f0>
ffffffffc0203222:	00004617          	auipc	a2,0x4
ffffffffc0203226:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0206d70 <commands+0x450>
ffffffffc020322a:	19300593          	li	a1,403
ffffffffc020322e:	00004517          	auipc	a0,0x4
ffffffffc0203232:	32a50513          	addi	a0,a0,810 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203236:	a44fd0ef          	jal	ra,ffffffffc020047a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020323a:	00200637          	lui	a2,0x200
ffffffffc020323e:	00cd87b3          	add	a5,s11,a2
ffffffffc0203242:	ffe00637          	lui	a2,0xffe00
ffffffffc0203246:	00c7fdb3          	and	s11,a5,a2
    } while (start != 0 && start < end);
ffffffffc020324a:	f40d84e3          	beqz	s11,ffffffffc0203192 <copy_range+0x7c>
ffffffffc020324e:	f29de5e3          	bltu	s11,s1,ffffffffc0203178 <copy_range+0x62>
ffffffffc0203252:	b781                	j	ffffffffc0203192 <copy_range+0x7c>
    return page - pages + nbase;
ffffffffc0203254:	000ab703          	ld	a4,0(s5)
    return KADDR(page2pa(page));
ffffffffc0203258:	000b3603          	ld	a2,0(s6)
    return page - pages + nbase;
ffffffffc020325c:	40ec06b3          	sub	a3,s8,a4
ffffffffc0203260:	8699                	srai	a3,a3,0x6
ffffffffc0203262:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0203264:	0176f5b3          	and	a1,a3,s7
    return page2ppn(page) << PGSHIFT;
ffffffffc0203268:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020326a:	08c5f163          	bgeu	a1,a2,ffffffffc02032ec <copy_range+0x1d6>
    return page - pages + nbase;
ffffffffc020326e:	40e50733          	sub	a4,a0,a4
    return KADDR(page2pa(page));
ffffffffc0203272:	000b0797          	auipc	a5,0xb0
ffffffffc0203276:	8ce78793          	addi	a5,a5,-1842 # ffffffffc02b2b40 <va_pa_offset>
ffffffffc020327a:	6388                	ld	a0,0(a5)
    return page - pages + nbase;
ffffffffc020327c:	8719                	srai	a4,a4,0x6
ffffffffc020327e:	9766                	add	a4,a4,s9
    return KADDR(page2pa(page));
ffffffffc0203280:	017778b3          	and	a7,a4,s7
ffffffffc0203284:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203288:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc020328a:	06c8f063          	bgeu	a7,a2,ffffffffc02032ea <copy_range+0x1d4>
                memcpy(dst_kvaddr, src_kvaddr, PGSIZE);//内存拷贝，从src_kvaddr到dst_kvaddr，大小为PGSIZE
ffffffffc020328e:	6605                	lui	a2,0x1
ffffffffc0203290:	953a                	add	a0,a0,a4
ffffffffc0203292:	e442                	sd	a6,8(sp)
ffffffffc0203294:	40c030ef          	jal	ra,ffffffffc02066a0 <memcpy>
                ret = page_insert(to, npage, start, perm);//建立npage的物理地址和线性地址start的映射
ffffffffc0203298:	6822                	ld	a6,8(sp)
ffffffffc020329a:	01f97693          	andi	a3,s2,31
ffffffffc020329e:	866e                	mv	a2,s11
ffffffffc02032a0:	85c2                	mv	a1,a6
ffffffffc02032a2:	8552                	mv	a0,s4
ffffffffc02032a4:	9e2ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
            assert(ret == 0);
ffffffffc02032a8:	ee0502e3          	beqz	a0,ffffffffc020318c <copy_range+0x76>
ffffffffc02032ac:	b7bd                	j	ffffffffc020321a <copy_range+0x104>
                return -E_NO_MEM;
ffffffffc02032ae:	5571                	li	a0,-4
ffffffffc02032b0:	b5d5                	j	ffffffffc0203194 <copy_range+0x7e>
        panic("pa2page called with invalid pa");
ffffffffc02032b2:	00004617          	auipc	a2,0x4
ffffffffc02032b6:	25e60613          	addi	a2,a2,606 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc02032ba:	06200593          	li	a1,98
ffffffffc02032be:	00004517          	auipc	a0,0x4
ffffffffc02032c2:	1aa50513          	addi	a0,a0,426 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc02032c6:	9b4fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02032ca:	00004697          	auipc	a3,0x4
ffffffffc02032ce:	2ce68693          	addi	a3,a3,718 # ffffffffc0207598 <default_pmm_manager+0x190>
ffffffffc02032d2:	00004617          	auipc	a2,0x4
ffffffffc02032d6:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0206d70 <commands+0x450>
ffffffffc02032da:	15e00593          	li	a1,350
ffffffffc02032de:	00004517          	auipc	a0,0x4
ffffffffc02032e2:	27a50513          	addi	a0,a0,634 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc02032e6:	994fd0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02032ea:	86ba                	mv	a3,a4
ffffffffc02032ec:	00004617          	auipc	a2,0x4
ffffffffc02032f0:	15460613          	addi	a2,a2,340 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc02032f4:	06900593          	li	a1,105
ffffffffc02032f8:	00004517          	auipc	a0,0x4
ffffffffc02032fc:	17050513          	addi	a0,a0,368 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0203300:	97afd0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203304:	00004617          	auipc	a2,0x4
ffffffffc0203308:	22c60613          	addi	a2,a2,556 # ffffffffc0207530 <default_pmm_manager+0x128>
ffffffffc020330c:	07400593          	li	a1,116
ffffffffc0203310:	00004517          	auipc	a0,0x4
ffffffffc0203314:	15850513          	addi	a0,a0,344 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0203318:	962fd0ef          	jal	ra,ffffffffc020047a <__panic>
            assert(page != NULL);
ffffffffc020331c:	00004697          	auipc	a3,0x4
ffffffffc0203320:	7bc68693          	addi	a3,a3,1980 # ffffffffc0207ad8 <default_pmm_manager+0x6d0>
ffffffffc0203324:	00004617          	auipc	a2,0x4
ffffffffc0203328:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0206d70 <commands+0x450>
ffffffffc020332c:	17200593          	li	a1,370
ffffffffc0203330:	00004517          	auipc	a0,0x4
ffffffffc0203334:	22850513          	addi	a0,a0,552 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203338:	942fd0ef          	jal	ra,ffffffffc020047a <__panic>
            assert(npage != NULL);
ffffffffc020333c:	00004697          	auipc	a3,0x4
ffffffffc0203340:	7ac68693          	addi	a3,a3,1964 # ffffffffc0207ae8 <default_pmm_manager+0x6e0>
ffffffffc0203344:	00004617          	auipc	a2,0x4
ffffffffc0203348:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0206d70 <commands+0x450>
ffffffffc020334c:	17300593          	li	a1,371
ffffffffc0203350:	00004517          	auipc	a0,0x4
ffffffffc0203354:	20850513          	addi	a0,a0,520 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203358:	922fd0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020335c:	00004697          	auipc	a3,0x4
ffffffffc0203360:	20c68693          	addi	a3,a3,524 # ffffffffc0207568 <default_pmm_manager+0x160>
ffffffffc0203364:	00004617          	auipc	a2,0x4
ffffffffc0203368:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0206d70 <commands+0x450>
ffffffffc020336c:	15d00593          	li	a1,349
ffffffffc0203370:	00004517          	auipc	a0,0x4
ffffffffc0203374:	1e850513          	addi	a0,a0,488 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203378:	902fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020337c <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020337c:	12058073          	sfence.vma	a1
}
ffffffffc0203380:	8082                	ret

ffffffffc0203382 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203382:	7179                	addi	sp,sp,-48
ffffffffc0203384:	e84a                	sd	s2,16(sp)
ffffffffc0203386:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0203388:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020338a:	f022                	sd	s0,32(sp)
ffffffffc020338c:	ec26                	sd	s1,24(sp)
ffffffffc020338e:	e44e                	sd	s3,8(sp)
ffffffffc0203390:	f406                	sd	ra,40(sp)
ffffffffc0203392:	84ae                	mv	s1,a1
ffffffffc0203394:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0203396:	94bfe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc020339a:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc020339c:	cd05                	beqz	a0,ffffffffc02033d4 <pgdir_alloc_page+0x52>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc020339e:	85aa                	mv	a1,a0
ffffffffc02033a0:	86ce                	mv	a3,s3
ffffffffc02033a2:	8626                	mv	a2,s1
ffffffffc02033a4:	854a                	mv	a0,s2
ffffffffc02033a6:	8e0ff0ef          	jal	ra,ffffffffc0202486 <page_insert>
ffffffffc02033aa:	ed0d                	bnez	a0,ffffffffc02033e4 <pgdir_alloc_page+0x62>
        if (swap_init_ok) {
ffffffffc02033ac:	000af797          	auipc	a5,0xaf
ffffffffc02033b0:	7ac7a783          	lw	a5,1964(a5) # ffffffffc02b2b58 <swap_init_ok>
ffffffffc02033b4:	c385                	beqz	a5,ffffffffc02033d4 <pgdir_alloc_page+0x52>
            if (check_mm_struct != NULL) {
ffffffffc02033b6:	000af517          	auipc	a0,0xaf
ffffffffc02033ba:	7aa53503          	ld	a0,1962(a0) # ffffffffc02b2b60 <check_mm_struct>
ffffffffc02033be:	c919                	beqz	a0,ffffffffc02033d4 <pgdir_alloc_page+0x52>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc02033c0:	4681                	li	a3,0
ffffffffc02033c2:	8622                	mv	a2,s0
ffffffffc02033c4:	85a6                	mv	a1,s1
ffffffffc02033c6:	7e4000ef          	jal	ra,ffffffffc0203baa <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc02033ca:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc02033cc:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc02033ce:	4785                	li	a5,1
ffffffffc02033d0:	04f71663          	bne	a4,a5,ffffffffc020341c <pgdir_alloc_page+0x9a>
}
ffffffffc02033d4:	70a2                	ld	ra,40(sp)
ffffffffc02033d6:	8522                	mv	a0,s0
ffffffffc02033d8:	7402                	ld	s0,32(sp)
ffffffffc02033da:	64e2                	ld	s1,24(sp)
ffffffffc02033dc:	6942                	ld	s2,16(sp)
ffffffffc02033de:	69a2                	ld	s3,8(sp)
ffffffffc02033e0:	6145                	addi	sp,sp,48
ffffffffc02033e2:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02033e4:	100027f3          	csrr	a5,sstatus
ffffffffc02033e8:	8b89                	andi	a5,a5,2
ffffffffc02033ea:	eb99                	bnez	a5,ffffffffc0203400 <pgdir_alloc_page+0x7e>
        pmm_manager->free_pages(base, n);
ffffffffc02033ec:	000af797          	auipc	a5,0xaf
ffffffffc02033f0:	74c7b783          	ld	a5,1868(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc02033f4:	739c                	ld	a5,32(a5)
ffffffffc02033f6:	8522                	mv	a0,s0
ffffffffc02033f8:	4585                	li	a1,1
ffffffffc02033fa:	9782                	jalr	a5
            return NULL;
ffffffffc02033fc:	4401                	li	s0,0
ffffffffc02033fe:	bfd9                	j	ffffffffc02033d4 <pgdir_alloc_page+0x52>
        intr_disable();
ffffffffc0203400:	a46fd0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203404:	000af797          	auipc	a5,0xaf
ffffffffc0203408:	7347b783          	ld	a5,1844(a5) # ffffffffc02b2b38 <pmm_manager>
ffffffffc020340c:	739c                	ld	a5,32(a5)
ffffffffc020340e:	8522                	mv	a0,s0
ffffffffc0203410:	4585                	li	a1,1
ffffffffc0203412:	9782                	jalr	a5
            return NULL;
ffffffffc0203414:	4401                	li	s0,0
        intr_enable();
ffffffffc0203416:	a2afd0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc020341a:	bf6d                	j	ffffffffc02033d4 <pgdir_alloc_page+0x52>
                assert(page_ref(page) == 1);
ffffffffc020341c:	00004697          	auipc	a3,0x4
ffffffffc0203420:	6ec68693          	addi	a3,a3,1772 # ffffffffc0207b08 <default_pmm_manager+0x700>
ffffffffc0203424:	00004617          	auipc	a2,0x4
ffffffffc0203428:	94c60613          	addi	a2,a2,-1716 # ffffffffc0206d70 <commands+0x450>
ffffffffc020342c:	1d200593          	li	a1,466
ffffffffc0203430:	00004517          	auipc	a0,0x4
ffffffffc0203434:	12850513          	addi	a0,a0,296 # ffffffffc0207558 <default_pmm_manager+0x150>
ffffffffc0203438:	842fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020343c <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc020343c:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020343e:	00004617          	auipc	a2,0x4
ffffffffc0203442:	0d260613          	addi	a2,a2,210 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0203446:	06200593          	li	a1,98
ffffffffc020344a:	00004517          	auipc	a0,0x4
ffffffffc020344e:	01e50513          	addi	a0,a0,30 # ffffffffc0207468 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc0203452:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0203454:	826fd0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203458 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0203458:	7135                	addi	sp,sp,-160
ffffffffc020345a:	ed06                	sd	ra,152(sp)
ffffffffc020345c:	e922                	sd	s0,144(sp)
ffffffffc020345e:	e526                	sd	s1,136(sp)
ffffffffc0203460:	e14a                	sd	s2,128(sp)
ffffffffc0203462:	fcce                	sd	s3,120(sp)
ffffffffc0203464:	f8d2                	sd	s4,112(sp)
ffffffffc0203466:	f4d6                	sd	s5,104(sp)
ffffffffc0203468:	f0da                	sd	s6,96(sp)
ffffffffc020346a:	ecde                	sd	s7,88(sp)
ffffffffc020346c:	e8e2                	sd	s8,80(sp)
ffffffffc020346e:	e4e6                	sd	s9,72(sp)
ffffffffc0203470:	e0ea                	sd	s10,64(sp)
ffffffffc0203472:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203474:	7fa010ef          	jal	ra,ffffffffc0204c6e <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0203478:	000af697          	auipc	a3,0xaf
ffffffffc020347c:	6d06b683          	ld	a3,1744(a3) # ffffffffc02b2b48 <max_swap_offset>
ffffffffc0203480:	010007b7          	lui	a5,0x1000
ffffffffc0203484:	ff968713          	addi	a4,a3,-7
ffffffffc0203488:	17e1                	addi	a5,a5,-8
ffffffffc020348a:	42e7e663          	bltu	a5,a4,ffffffffc02038b6 <swap_init+0x45e>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc020348e:	000a4797          	auipc	a5,0xa4
ffffffffc0203492:	15278793          	addi	a5,a5,338 # ffffffffc02a75e0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203496:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0203498:	000afb97          	auipc	s7,0xaf
ffffffffc020349c:	6b8b8b93          	addi	s7,s7,1720 # ffffffffc02b2b50 <sm>
ffffffffc02034a0:	00fbb023          	sd	a5,0(s7)
     int r = sm->init();
ffffffffc02034a4:	9702                	jalr	a4
ffffffffc02034a6:	892a                	mv	s2,a0
     
     if (r == 0)
ffffffffc02034a8:	c10d                	beqz	a0,ffffffffc02034ca <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02034aa:	60ea                	ld	ra,152(sp)
ffffffffc02034ac:	644a                	ld	s0,144(sp)
ffffffffc02034ae:	64aa                	ld	s1,136(sp)
ffffffffc02034b0:	79e6                	ld	s3,120(sp)
ffffffffc02034b2:	7a46                	ld	s4,112(sp)
ffffffffc02034b4:	7aa6                	ld	s5,104(sp)
ffffffffc02034b6:	7b06                	ld	s6,96(sp)
ffffffffc02034b8:	6be6                	ld	s7,88(sp)
ffffffffc02034ba:	6c46                	ld	s8,80(sp)
ffffffffc02034bc:	6ca6                	ld	s9,72(sp)
ffffffffc02034be:	6d06                	ld	s10,64(sp)
ffffffffc02034c0:	7de2                	ld	s11,56(sp)
ffffffffc02034c2:	854a                	mv	a0,s2
ffffffffc02034c4:	690a                	ld	s2,128(sp)
ffffffffc02034c6:	610d                	addi	sp,sp,160
ffffffffc02034c8:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034ca:	000bb783          	ld	a5,0(s7)
ffffffffc02034ce:	00004517          	auipc	a0,0x4
ffffffffc02034d2:	68250513          	addi	a0,a0,1666 # ffffffffc0207b50 <default_pmm_manager+0x748>
    return listelm->next;
ffffffffc02034d6:	000ab417          	auipc	s0,0xab
ffffffffc02034da:	55a40413          	addi	s0,s0,1370 # ffffffffc02aea30 <free_area>
ffffffffc02034de:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02034e0:	4785                	li	a5,1
ffffffffc02034e2:	000af717          	auipc	a4,0xaf
ffffffffc02034e6:	66f72b23          	sw	a5,1654(a4) # ffffffffc02b2b58 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02034ea:	c97fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc02034ee:	641c                	ld	a5,8(s0)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc02034f0:	4d01                	li	s10,0
ffffffffc02034f2:	4d81                	li	s11,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02034f4:	34878163          	beq	a5,s0,ffffffffc0203836 <swap_init+0x3de>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02034f8:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02034fc:	8b09                	andi	a4,a4,2
ffffffffc02034fe:	32070e63          	beqz	a4,ffffffffc020383a <swap_init+0x3e2>
        count ++, total += p->property;
ffffffffc0203502:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203506:	679c                	ld	a5,8(a5)
ffffffffc0203508:	2d85                	addiw	s11,s11,1
ffffffffc020350a:	01a70d3b          	addw	s10,a4,s10
     while ((le = list_next(le)) != &free_list) {
ffffffffc020350e:	fe8795e3          	bne	a5,s0,ffffffffc02034f8 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0203512:	84ea                	mv	s1,s10
ffffffffc0203514:	89ffe0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc0203518:	42951763          	bne	a0,s1,ffffffffc0203946 <swap_init+0x4ee>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020351c:	866a                	mv	a2,s10
ffffffffc020351e:	85ee                	mv	a1,s11
ffffffffc0203520:	00004517          	auipc	a0,0x4
ffffffffc0203524:	64850513          	addi	a0,a0,1608 # ffffffffc0207b68 <default_pmm_manager+0x760>
ffffffffc0203528:	c59fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020352c:	447000ef          	jal	ra,ffffffffc0204172 <mm_create>
ffffffffc0203530:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0203532:	46050a63          	beqz	a0,ffffffffc02039a6 <swap_init+0x54e>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203536:	000af797          	auipc	a5,0xaf
ffffffffc020353a:	62a78793          	addi	a5,a5,1578 # ffffffffc02b2b60 <check_mm_struct>
ffffffffc020353e:	6398                	ld	a4,0(a5)
ffffffffc0203540:	3e071363          	bnez	a4,ffffffffc0203926 <swap_init+0x4ce>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203544:	000af717          	auipc	a4,0xaf
ffffffffc0203548:	5dc70713          	addi	a4,a4,1500 # ffffffffc02b2b20 <boot_pgdir>
ffffffffc020354c:	00073b03          	ld	s6,0(a4)
     check_mm_struct = mm;
ffffffffc0203550:	e388                	sd	a0,0(a5)
     assert(pgdir[0] == 0);
ffffffffc0203552:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203556:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc020355a:	42079663          	bnez	a5,ffffffffc0203986 <swap_init+0x52e>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020355e:	6599                	lui	a1,0x6
ffffffffc0203560:	460d                	li	a2,3
ffffffffc0203562:	6505                	lui	a0,0x1
ffffffffc0203564:	457000ef          	jal	ra,ffffffffc02041ba <vma_create>
ffffffffc0203568:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc020356a:	52050a63          	beqz	a0,ffffffffc0203a9e <swap_init+0x646>

     insert_vma_struct(mm, vma);
ffffffffc020356e:	8556                	mv	a0,s5
ffffffffc0203570:	4b9000ef          	jal	ra,ffffffffc0204228 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203574:	00004517          	auipc	a0,0x4
ffffffffc0203578:	66450513          	addi	a0,a0,1636 # ffffffffc0207bd8 <default_pmm_manager+0x7d0>
ffffffffc020357c:	c05fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203580:	018ab503          	ld	a0,24(s5)
ffffffffc0203584:	4605                	li	a2,1
ffffffffc0203586:	6585                	lui	a1,0x1
ffffffffc0203588:	865fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020358c:	4c050963          	beqz	a0,ffffffffc0203a5e <swap_init+0x606>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203590:	00004517          	auipc	a0,0x4
ffffffffc0203594:	69850513          	addi	a0,a0,1688 # ffffffffc0207c28 <default_pmm_manager+0x820>
ffffffffc0203598:	000ab497          	auipc	s1,0xab
ffffffffc020359c:	4d048493          	addi	s1,s1,1232 # ffffffffc02aea68 <check_rp>
ffffffffc02035a0:	be1fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035a4:	000ab997          	auipc	s3,0xab
ffffffffc02035a8:	4e498993          	addi	s3,s3,1252 # ffffffffc02aea88 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02035ac:	8a26                	mv	s4,s1
          check_rp[i] = alloc_page();
ffffffffc02035ae:	4505                	li	a0,1
ffffffffc02035b0:	f30fe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02035b4:	00aa3023          	sd	a0,0(s4)
          assert(check_rp[i] != NULL );
ffffffffc02035b8:	2c050f63          	beqz	a0,ffffffffc0203896 <swap_init+0x43e>
ffffffffc02035bc:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02035be:	8b89                	andi	a5,a5,2
ffffffffc02035c0:	34079363          	bnez	a5,ffffffffc0203906 <swap_init+0x4ae>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035c4:	0a21                	addi	s4,s4,8
ffffffffc02035c6:	ff3a14e3          	bne	s4,s3,ffffffffc02035ae <swap_init+0x156>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02035ca:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02035cc:	000aba17          	auipc	s4,0xab
ffffffffc02035d0:	49ca0a13          	addi	s4,s4,1180 # ffffffffc02aea68 <check_rp>
    elm->prev = elm->next = elm;
ffffffffc02035d4:	e000                	sd	s0,0(s0)
     list_entry_t free_list_store = free_list;
ffffffffc02035d6:	ec3e                	sd	a5,24(sp)
ffffffffc02035d8:	641c                	ld	a5,8(s0)
ffffffffc02035da:	e400                	sd	s0,8(s0)
ffffffffc02035dc:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02035de:	481c                	lw	a5,16(s0)
ffffffffc02035e0:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc02035e2:	000ab797          	auipc	a5,0xab
ffffffffc02035e6:	4407af23          	sw	zero,1118(a5) # ffffffffc02aea40 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02035ea:	000a3503          	ld	a0,0(s4)
ffffffffc02035ee:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035f0:	0a21                	addi	s4,s4,8
        free_pages(check_rp[i],1);
ffffffffc02035f2:	f80fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02035f6:	ff3a1ae3          	bne	s4,s3,ffffffffc02035ea <swap_init+0x192>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02035fa:	01042a03          	lw	s4,16(s0)
ffffffffc02035fe:	4791                	li	a5,4
ffffffffc0203600:	42fa1f63          	bne	s4,a5,ffffffffc0203a3e <swap_init+0x5e6>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203604:	00004517          	auipc	a0,0x4
ffffffffc0203608:	6ac50513          	addi	a0,a0,1708 # ffffffffc0207cb0 <default_pmm_manager+0x8a8>
ffffffffc020360c:	b75fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203610:	6705                	lui	a4,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203612:	000af797          	auipc	a5,0xaf
ffffffffc0203616:	5407ab23          	sw	zero,1366(a5) # ffffffffc02b2b68 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020361a:	4629                	li	a2,10
ffffffffc020361c:	00c70023          	sb	a2,0(a4) # 1000 <_binary_obj___user_faultread_out_size-0x8be0>
     assert(pgfault_num==1);
ffffffffc0203620:	000af697          	auipc	a3,0xaf
ffffffffc0203624:	5486a683          	lw	a3,1352(a3) # ffffffffc02b2b68 <pgfault_num>
ffffffffc0203628:	4585                	li	a1,1
ffffffffc020362a:	000af797          	auipc	a5,0xaf
ffffffffc020362e:	53e78793          	addi	a5,a5,1342 # ffffffffc02b2b68 <pgfault_num>
ffffffffc0203632:	54b69663          	bne	a3,a1,ffffffffc0203b7e <swap_init+0x726>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203636:	00c70823          	sb	a2,16(a4)
     assert(pgfault_num==1);
ffffffffc020363a:	4398                	lw	a4,0(a5)
ffffffffc020363c:	2701                	sext.w	a4,a4
ffffffffc020363e:	3ed71063          	bne	a4,a3,ffffffffc0203a1e <swap_init+0x5c6>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203642:	6689                	lui	a3,0x2
ffffffffc0203644:	462d                	li	a2,11
ffffffffc0203646:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7be0>
     assert(pgfault_num==2);
ffffffffc020364a:	4398                	lw	a4,0(a5)
ffffffffc020364c:	4589                	li	a1,2
ffffffffc020364e:	2701                	sext.w	a4,a4
ffffffffc0203650:	4ab71763          	bne	a4,a1,ffffffffc0203afe <swap_init+0x6a6>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203654:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203658:	4394                	lw	a3,0(a5)
ffffffffc020365a:	2681                	sext.w	a3,a3
ffffffffc020365c:	4ce69163          	bne	a3,a4,ffffffffc0203b1e <swap_init+0x6c6>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203660:	668d                	lui	a3,0x3
ffffffffc0203662:	4631                	li	a2,12
ffffffffc0203664:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6be0>
     assert(pgfault_num==3);
ffffffffc0203668:	4398                	lw	a4,0(a5)
ffffffffc020366a:	458d                	li	a1,3
ffffffffc020366c:	2701                	sext.w	a4,a4
ffffffffc020366e:	4cb71863          	bne	a4,a1,ffffffffc0203b3e <swap_init+0x6e6>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203672:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203676:	4394                	lw	a3,0(a5)
ffffffffc0203678:	2681                	sext.w	a3,a3
ffffffffc020367a:	4ee69263          	bne	a3,a4,ffffffffc0203b5e <swap_init+0x706>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020367e:	6691                	lui	a3,0x4
ffffffffc0203680:	4635                	li	a2,13
ffffffffc0203682:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5be0>
     assert(pgfault_num==4);
ffffffffc0203686:	4398                	lw	a4,0(a5)
ffffffffc0203688:	2701                	sext.w	a4,a4
ffffffffc020368a:	43471a63          	bne	a4,s4,ffffffffc0203abe <swap_init+0x666>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc020368e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203692:	439c                	lw	a5,0(a5)
ffffffffc0203694:	2781                	sext.w	a5,a5
ffffffffc0203696:	44e79463          	bne	a5,a4,ffffffffc0203ade <swap_init+0x686>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020369a:	481c                	lw	a5,16(s0)
ffffffffc020369c:	2c079563          	bnez	a5,ffffffffc0203966 <swap_init+0x50e>
ffffffffc02036a0:	000ab797          	auipc	a5,0xab
ffffffffc02036a4:	3e878793          	addi	a5,a5,1000 # ffffffffc02aea88 <swap_in_seq_no>
ffffffffc02036a8:	000ab717          	auipc	a4,0xab
ffffffffc02036ac:	40870713          	addi	a4,a4,1032 # ffffffffc02aeab0 <swap_out_seq_no>
ffffffffc02036b0:	000ab617          	auipc	a2,0xab
ffffffffc02036b4:	40060613          	addi	a2,a2,1024 # ffffffffc02aeab0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02036b8:	56fd                	li	a3,-1
ffffffffc02036ba:	c394                	sw	a3,0(a5)
ffffffffc02036bc:	c314                	sw	a3,0(a4)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02036be:	0791                	addi	a5,a5,4
ffffffffc02036c0:	0711                	addi	a4,a4,4
ffffffffc02036c2:	fec79ce3          	bne	a5,a2,ffffffffc02036ba <swap_init+0x262>
ffffffffc02036c6:	000ab717          	auipc	a4,0xab
ffffffffc02036ca:	38270713          	addi	a4,a4,898 # ffffffffc02aea48 <check_ptep>
ffffffffc02036ce:	000ab697          	auipc	a3,0xab
ffffffffc02036d2:	39a68693          	addi	a3,a3,922 # ffffffffc02aea68 <check_rp>
ffffffffc02036d6:	6585                	lui	a1,0x1
    if (PPN(pa) >= npage) {
ffffffffc02036d8:	000afc17          	auipc	s8,0xaf
ffffffffc02036dc:	450c0c13          	addi	s8,s8,1104 # ffffffffc02b2b28 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02036e0:	000afc97          	auipc	s9,0xaf
ffffffffc02036e4:	450c8c93          	addi	s9,s9,1104 # ffffffffc02b2b30 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc02036e8:	00073023          	sd	zero,0(a4)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036ec:	4601                	li	a2,0
ffffffffc02036ee:	855a                	mv	a0,s6
ffffffffc02036f0:	e836                	sd	a3,16(sp)
ffffffffc02036f2:	e42e                	sd	a1,8(sp)
         check_ptep[i]=0;
ffffffffc02036f4:	e03a                	sd	a4,0(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc02036f6:	ef6fe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc02036fa:	6702                	ld	a4,0(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc02036fc:	65a2                	ld	a1,8(sp)
ffffffffc02036fe:	66c2                	ld	a3,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203700:	e308                	sd	a0,0(a4)
         assert(check_ptep[i] != NULL);
ffffffffc0203702:	1c050663          	beqz	a0,ffffffffc02038ce <swap_init+0x476>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203706:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203708:	0017f613          	andi	a2,a5,1
ffffffffc020370c:	1e060163          	beqz	a2,ffffffffc02038ee <swap_init+0x496>
    if (PPN(pa) >= npage) {
ffffffffc0203710:	000c3603          	ld	a2,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203714:	078a                	slli	a5,a5,0x2
ffffffffc0203716:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203718:	14c7f363          	bgeu	a5,a2,ffffffffc020385e <swap_init+0x406>
    return &pages[PPN(pa) - nbase];
ffffffffc020371c:	00005617          	auipc	a2,0x5
ffffffffc0203720:	65460613          	addi	a2,a2,1620 # ffffffffc0208d70 <nbase>
ffffffffc0203724:	00063a03          	ld	s4,0(a2)
ffffffffc0203728:	000cb603          	ld	a2,0(s9)
ffffffffc020372c:	6288                	ld	a0,0(a3)
ffffffffc020372e:	414787b3          	sub	a5,a5,s4
ffffffffc0203732:	079a                	slli	a5,a5,0x6
ffffffffc0203734:	97b2                	add	a5,a5,a2
ffffffffc0203736:	14f51063          	bne	a0,a5,ffffffffc0203876 <swap_init+0x41e>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020373a:	6785                	lui	a5,0x1
ffffffffc020373c:	95be                	add	a1,a1,a5
ffffffffc020373e:	6795                	lui	a5,0x5
ffffffffc0203740:	0721                	addi	a4,a4,8
ffffffffc0203742:	06a1                	addi	a3,a3,8
ffffffffc0203744:	faf592e3          	bne	a1,a5,ffffffffc02036e8 <swap_init+0x290>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203748:	00004517          	auipc	a0,0x4
ffffffffc020374c:	61050513          	addi	a0,a0,1552 # ffffffffc0207d58 <default_pmm_manager+0x950>
ffffffffc0203750:	a31fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203754:	000bb783          	ld	a5,0(s7)
ffffffffc0203758:	7f9c                	ld	a5,56(a5)
ffffffffc020375a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc020375c:	32051163          	bnez	a0,ffffffffc0203a7e <swap_init+0x626>

     nr_free = nr_free_store;
ffffffffc0203760:	77a2                	ld	a5,40(sp)
ffffffffc0203762:	c81c                	sw	a5,16(s0)
     free_list = free_list_store;
ffffffffc0203764:	67e2                	ld	a5,24(sp)
ffffffffc0203766:	e01c                	sd	a5,0(s0)
ffffffffc0203768:	7782                	ld	a5,32(sp)
ffffffffc020376a:	e41c                	sd	a5,8(s0)

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020376c:	6088                	ld	a0,0(s1)
ffffffffc020376e:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203770:	04a1                	addi	s1,s1,8
         free_pages(check_rp[i],1);
ffffffffc0203772:	e00fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203776:	ff349be3          	bne	s1,s3,ffffffffc020376c <swap_init+0x314>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc020377a:	000abc23          	sd	zero,24(s5)
     mm_destroy(mm);
ffffffffc020377e:	8556                	mv	a0,s5
ffffffffc0203780:	379000ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203784:	000af797          	auipc	a5,0xaf
ffffffffc0203788:	39c78793          	addi	a5,a5,924 # ffffffffc02b2b20 <boot_pgdir>
ffffffffc020378c:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020378e:	000c3703          	ld	a4,0(s8)
     check_mm_struct = NULL;
ffffffffc0203792:	000af697          	auipc	a3,0xaf
ffffffffc0203796:	3c06b723          	sd	zero,974(a3) # ffffffffc02b2b60 <check_mm_struct>
    return pa2page(PDE_ADDR(pde));
ffffffffc020379a:	639c                	ld	a5,0(a5)
ffffffffc020379c:	078a                	slli	a5,a5,0x2
ffffffffc020379e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037a0:	0ae7fd63          	bgeu	a5,a4,ffffffffc020385a <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02037a4:	414786b3          	sub	a3,a5,s4
ffffffffc02037a8:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02037aa:	8699                	srai	a3,a3,0x6
ffffffffc02037ac:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02037ae:	00c69793          	slli	a5,a3,0xc
ffffffffc02037b2:	83b1                	srli	a5,a5,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02037b4:	000cb503          	ld	a0,0(s9)
    return page2ppn(page) << PGSHIFT;
ffffffffc02037b8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02037ba:	22e7f663          	bgeu	a5,a4,ffffffffc02039e6 <swap_init+0x58e>
     free_page(pde2page(pd0[0]));
ffffffffc02037be:	000af797          	auipc	a5,0xaf
ffffffffc02037c2:	3827b783          	ld	a5,898(a5) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc02037c6:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02037c8:	629c                	ld	a5,0(a3)
ffffffffc02037ca:	078a                	slli	a5,a5,0x2
ffffffffc02037cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037ce:	08e7f663          	bgeu	a5,a4,ffffffffc020385a <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02037d2:	414787b3          	sub	a5,a5,s4
ffffffffc02037d6:	079a                	slli	a5,a5,0x6
ffffffffc02037d8:	953e                	add	a0,a0,a5
ffffffffc02037da:	4585                	li	a1,1
ffffffffc02037dc:	d96fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02037e0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc02037e4:	000c3703          	ld	a4,0(s8)
    return pa2page(PDE_ADDR(pde));
ffffffffc02037e8:	078a                	slli	a5,a5,0x2
ffffffffc02037ea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02037ec:	06e7f763          	bgeu	a5,a4,ffffffffc020385a <swap_init+0x402>
    return &pages[PPN(pa) - nbase];
ffffffffc02037f0:	000cb503          	ld	a0,0(s9)
ffffffffc02037f4:	414787b3          	sub	a5,a5,s4
ffffffffc02037f8:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc02037fa:	4585                	li	a1,1
ffffffffc02037fc:	953e                	add	a0,a0,a5
ffffffffc02037fe:	d74fe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
     pgdir[0] = 0;
ffffffffc0203802:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203806:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020380a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020380c:	00878a63          	beq	a5,s0,ffffffffc0203820 <swap_init+0x3c8>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203810:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203814:	679c                	ld	a5,8(a5)
ffffffffc0203816:	3dfd                	addiw	s11,s11,-1
ffffffffc0203818:	40ed0d3b          	subw	s10,s10,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020381c:	fe879ae3          	bne	a5,s0,ffffffffc0203810 <swap_init+0x3b8>
     }
     assert(count==0);
ffffffffc0203820:	1c0d9f63          	bnez	s11,ffffffffc02039fe <swap_init+0x5a6>
     assert(total==0);
ffffffffc0203824:	1a0d1163          	bnez	s10,ffffffffc02039c6 <swap_init+0x56e>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203828:	00004517          	auipc	a0,0x4
ffffffffc020382c:	58050513          	addi	a0,a0,1408 # ffffffffc0207da8 <default_pmm_manager+0x9a0>
ffffffffc0203830:	951fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203834:	b99d                	j	ffffffffc02034aa <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203836:	4481                	li	s1,0
ffffffffc0203838:	b9f1                	j	ffffffffc0203514 <swap_init+0xbc>
        assert(PageProperty(p));
ffffffffc020383a:	00004697          	auipc	a3,0x4
ffffffffc020383e:	82668693          	addi	a3,a3,-2010 # ffffffffc0207060 <commands+0x740>
ffffffffc0203842:	00003617          	auipc	a2,0x3
ffffffffc0203846:	52e60613          	addi	a2,a2,1326 # ffffffffc0206d70 <commands+0x450>
ffffffffc020384a:	0bc00593          	li	a1,188
ffffffffc020384e:	00004517          	auipc	a0,0x4
ffffffffc0203852:	2f250513          	addi	a0,a0,754 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203856:	c25fc0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc020385a:	be3ff0ef          	jal	ra,ffffffffc020343c <pa2page.part.0>
        panic("pa2page called with invalid pa");
ffffffffc020385e:	00004617          	auipc	a2,0x4
ffffffffc0203862:	cb260613          	addi	a2,a2,-846 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0203866:	06200593          	li	a1,98
ffffffffc020386a:	00004517          	auipc	a0,0x4
ffffffffc020386e:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0203872:	c09fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203876:	00004697          	auipc	a3,0x4
ffffffffc020387a:	4ba68693          	addi	a3,a3,1210 # ffffffffc0207d30 <default_pmm_manager+0x928>
ffffffffc020387e:	00003617          	auipc	a2,0x3
ffffffffc0203882:	4f260613          	addi	a2,a2,1266 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203886:	0fc00593          	li	a1,252
ffffffffc020388a:	00004517          	auipc	a0,0x4
ffffffffc020388e:	2b650513          	addi	a0,a0,694 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203892:	be9fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203896:	00004697          	auipc	a3,0x4
ffffffffc020389a:	3ba68693          	addi	a3,a3,954 # ffffffffc0207c50 <default_pmm_manager+0x848>
ffffffffc020389e:	00003617          	auipc	a2,0x3
ffffffffc02038a2:	4d260613          	addi	a2,a2,1234 # ffffffffc0206d70 <commands+0x450>
ffffffffc02038a6:	0dc00593          	li	a1,220
ffffffffc02038aa:	00004517          	auipc	a0,0x4
ffffffffc02038ae:	29650513          	addi	a0,a0,662 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc02038b2:	bc9fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc02038b6:	00004617          	auipc	a2,0x4
ffffffffc02038ba:	26a60613          	addi	a2,a2,618 # ffffffffc0207b20 <default_pmm_manager+0x718>
ffffffffc02038be:	02800593          	li	a1,40
ffffffffc02038c2:	00004517          	auipc	a0,0x4
ffffffffc02038c6:	27e50513          	addi	a0,a0,638 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc02038ca:	bb1fc0ef          	jal	ra,ffffffffc020047a <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc02038ce:	00004697          	auipc	a3,0x4
ffffffffc02038d2:	44a68693          	addi	a3,a3,1098 # ffffffffc0207d18 <default_pmm_manager+0x910>
ffffffffc02038d6:	00003617          	auipc	a2,0x3
ffffffffc02038da:	49a60613          	addi	a2,a2,1178 # ffffffffc0206d70 <commands+0x450>
ffffffffc02038de:	0fb00593          	li	a1,251
ffffffffc02038e2:	00004517          	auipc	a0,0x4
ffffffffc02038e6:	25e50513          	addi	a0,a0,606 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc02038ea:	b91fc0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02038ee:	00004617          	auipc	a2,0x4
ffffffffc02038f2:	c4260613          	addi	a2,a2,-958 # ffffffffc0207530 <default_pmm_manager+0x128>
ffffffffc02038f6:	07400593          	li	a1,116
ffffffffc02038fa:	00004517          	auipc	a0,0x4
ffffffffc02038fe:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0203902:	b79fc0ef          	jal	ra,ffffffffc020047a <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203906:	00004697          	auipc	a3,0x4
ffffffffc020390a:	36268693          	addi	a3,a3,866 # ffffffffc0207c68 <default_pmm_manager+0x860>
ffffffffc020390e:	00003617          	auipc	a2,0x3
ffffffffc0203912:	46260613          	addi	a2,a2,1122 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203916:	0dd00593          	li	a1,221
ffffffffc020391a:	00004517          	auipc	a0,0x4
ffffffffc020391e:	22650513          	addi	a0,a0,550 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203922:	b59fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203926:	00004697          	auipc	a3,0x4
ffffffffc020392a:	27a68693          	addi	a3,a3,634 # ffffffffc0207ba0 <default_pmm_manager+0x798>
ffffffffc020392e:	00003617          	auipc	a2,0x3
ffffffffc0203932:	44260613          	addi	a2,a2,1090 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203936:	0c700593          	li	a1,199
ffffffffc020393a:	00004517          	auipc	a0,0x4
ffffffffc020393e:	20650513          	addi	a0,a0,518 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203942:	b39fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total == nr_free_pages());
ffffffffc0203946:	00003697          	auipc	a3,0x3
ffffffffc020394a:	74268693          	addi	a3,a3,1858 # ffffffffc0207088 <commands+0x768>
ffffffffc020394e:	00003617          	auipc	a2,0x3
ffffffffc0203952:	42260613          	addi	a2,a2,1058 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203956:	0bf00593          	li	a1,191
ffffffffc020395a:	00004517          	auipc	a0,0x4
ffffffffc020395e:	1e650513          	addi	a0,a0,486 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203962:	b19fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert( nr_free == 0);         
ffffffffc0203966:	00004697          	auipc	a3,0x4
ffffffffc020396a:	8ca68693          	addi	a3,a3,-1846 # ffffffffc0207230 <commands+0x910>
ffffffffc020396e:	00003617          	auipc	a2,0x3
ffffffffc0203972:	40260613          	addi	a2,a2,1026 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203976:	0f300593          	li	a1,243
ffffffffc020397a:	00004517          	auipc	a0,0x4
ffffffffc020397e:	1c650513          	addi	a0,a0,454 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203982:	af9fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203986:	00004697          	auipc	a3,0x4
ffffffffc020398a:	23268693          	addi	a3,a3,562 # ffffffffc0207bb8 <default_pmm_manager+0x7b0>
ffffffffc020398e:	00003617          	auipc	a2,0x3
ffffffffc0203992:	3e260613          	addi	a2,a2,994 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203996:	0cc00593          	li	a1,204
ffffffffc020399a:	00004517          	auipc	a0,0x4
ffffffffc020399e:	1a650513          	addi	a0,a0,422 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc02039a2:	ad9fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(mm != NULL);
ffffffffc02039a6:	00004697          	auipc	a3,0x4
ffffffffc02039aa:	1ea68693          	addi	a3,a3,490 # ffffffffc0207b90 <default_pmm_manager+0x788>
ffffffffc02039ae:	00003617          	auipc	a2,0x3
ffffffffc02039b2:	3c260613          	addi	a2,a2,962 # ffffffffc0206d70 <commands+0x450>
ffffffffc02039b6:	0c400593          	li	a1,196
ffffffffc02039ba:	00004517          	auipc	a0,0x4
ffffffffc02039be:	18650513          	addi	a0,a0,390 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc02039c2:	ab9fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(total==0);
ffffffffc02039c6:	00004697          	auipc	a3,0x4
ffffffffc02039ca:	3d268693          	addi	a3,a3,978 # ffffffffc0207d98 <default_pmm_manager+0x990>
ffffffffc02039ce:	00003617          	auipc	a2,0x3
ffffffffc02039d2:	3a260613          	addi	a2,a2,930 # ffffffffc0206d70 <commands+0x450>
ffffffffc02039d6:	11e00593          	li	a1,286
ffffffffc02039da:	00004517          	auipc	a0,0x4
ffffffffc02039de:	16650513          	addi	a0,a0,358 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc02039e2:	a99fc0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02039e6:	00004617          	auipc	a2,0x4
ffffffffc02039ea:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc02039ee:	06900593          	li	a1,105
ffffffffc02039f2:	00004517          	auipc	a0,0x4
ffffffffc02039f6:	a7650513          	addi	a0,a0,-1418 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc02039fa:	a81fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(count==0);
ffffffffc02039fe:	00004697          	auipc	a3,0x4
ffffffffc0203a02:	38a68693          	addi	a3,a3,906 # ffffffffc0207d88 <default_pmm_manager+0x980>
ffffffffc0203a06:	00003617          	auipc	a2,0x3
ffffffffc0203a0a:	36a60613          	addi	a2,a2,874 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203a0e:	11d00593          	li	a1,285
ffffffffc0203a12:	00004517          	auipc	a0,0x4
ffffffffc0203a16:	12e50513          	addi	a0,a0,302 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203a1a:	a61fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203a1e:	00004697          	auipc	a3,0x4
ffffffffc0203a22:	2ba68693          	addi	a3,a3,698 # ffffffffc0207cd8 <default_pmm_manager+0x8d0>
ffffffffc0203a26:	00003617          	auipc	a2,0x3
ffffffffc0203a2a:	34a60613          	addi	a2,a2,842 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203a2e:	09500593          	li	a1,149
ffffffffc0203a32:	00004517          	auipc	a0,0x4
ffffffffc0203a36:	10e50513          	addi	a0,a0,270 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203a3a:	a41fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a3e:	00004697          	auipc	a3,0x4
ffffffffc0203a42:	24a68693          	addi	a3,a3,586 # ffffffffc0207c88 <default_pmm_manager+0x880>
ffffffffc0203a46:	00003617          	auipc	a2,0x3
ffffffffc0203a4a:	32a60613          	addi	a2,a2,810 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203a4e:	0ea00593          	li	a1,234
ffffffffc0203a52:	00004517          	auipc	a0,0x4
ffffffffc0203a56:	0ee50513          	addi	a0,a0,238 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203a5a:	a21fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203a5e:	00004697          	auipc	a3,0x4
ffffffffc0203a62:	1b268693          	addi	a3,a3,434 # ffffffffc0207c10 <default_pmm_manager+0x808>
ffffffffc0203a66:	00003617          	auipc	a2,0x3
ffffffffc0203a6a:	30a60613          	addi	a2,a2,778 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203a6e:	0d700593          	li	a1,215
ffffffffc0203a72:	00004517          	auipc	a0,0x4
ffffffffc0203a76:	0ce50513          	addi	a0,a0,206 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203a7a:	a01fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(ret==0);
ffffffffc0203a7e:	00004697          	auipc	a3,0x4
ffffffffc0203a82:	30268693          	addi	a3,a3,770 # ffffffffc0207d80 <default_pmm_manager+0x978>
ffffffffc0203a86:	00003617          	auipc	a2,0x3
ffffffffc0203a8a:	2ea60613          	addi	a2,a2,746 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203a8e:	10200593          	li	a1,258
ffffffffc0203a92:	00004517          	auipc	a0,0x4
ffffffffc0203a96:	0ae50513          	addi	a0,a0,174 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203a9a:	9e1fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(vma != NULL);
ffffffffc0203a9e:	00004697          	auipc	a3,0x4
ffffffffc0203aa2:	12a68693          	addi	a3,a3,298 # ffffffffc0207bc8 <default_pmm_manager+0x7c0>
ffffffffc0203aa6:	00003617          	auipc	a2,0x3
ffffffffc0203aaa:	2ca60613          	addi	a2,a2,714 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203aae:	0cf00593          	li	a1,207
ffffffffc0203ab2:	00004517          	auipc	a0,0x4
ffffffffc0203ab6:	08e50513          	addi	a0,a0,142 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203aba:	9c1fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203abe:	00004697          	auipc	a3,0x4
ffffffffc0203ac2:	24a68693          	addi	a3,a3,586 # ffffffffc0207d08 <default_pmm_manager+0x900>
ffffffffc0203ac6:	00003617          	auipc	a2,0x3
ffffffffc0203aca:	2aa60613          	addi	a2,a2,682 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203ace:	09f00593          	li	a1,159
ffffffffc0203ad2:	00004517          	auipc	a0,0x4
ffffffffc0203ad6:	06e50513          	addi	a0,a0,110 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203ada:	9a1fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==4);
ffffffffc0203ade:	00004697          	auipc	a3,0x4
ffffffffc0203ae2:	22a68693          	addi	a3,a3,554 # ffffffffc0207d08 <default_pmm_manager+0x900>
ffffffffc0203ae6:	00003617          	auipc	a2,0x3
ffffffffc0203aea:	28a60613          	addi	a2,a2,650 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203aee:	0a100593          	li	a1,161
ffffffffc0203af2:	00004517          	auipc	a0,0x4
ffffffffc0203af6:	04e50513          	addi	a0,a0,78 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203afa:	981fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203afe:	00004697          	auipc	a3,0x4
ffffffffc0203b02:	1ea68693          	addi	a3,a3,490 # ffffffffc0207ce8 <default_pmm_manager+0x8e0>
ffffffffc0203b06:	00003617          	auipc	a2,0x3
ffffffffc0203b0a:	26a60613          	addi	a2,a2,618 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203b0e:	09700593          	li	a1,151
ffffffffc0203b12:	00004517          	auipc	a0,0x4
ffffffffc0203b16:	02e50513          	addi	a0,a0,46 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203b1a:	961fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==2);
ffffffffc0203b1e:	00004697          	auipc	a3,0x4
ffffffffc0203b22:	1ca68693          	addi	a3,a3,458 # ffffffffc0207ce8 <default_pmm_manager+0x8e0>
ffffffffc0203b26:	00003617          	auipc	a2,0x3
ffffffffc0203b2a:	24a60613          	addi	a2,a2,586 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203b2e:	09900593          	li	a1,153
ffffffffc0203b32:	00004517          	auipc	a0,0x4
ffffffffc0203b36:	00e50513          	addi	a0,a0,14 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203b3a:	941fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203b3e:	00004697          	auipc	a3,0x4
ffffffffc0203b42:	1ba68693          	addi	a3,a3,442 # ffffffffc0207cf8 <default_pmm_manager+0x8f0>
ffffffffc0203b46:	00003617          	auipc	a2,0x3
ffffffffc0203b4a:	22a60613          	addi	a2,a2,554 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203b4e:	09b00593          	li	a1,155
ffffffffc0203b52:	00004517          	auipc	a0,0x4
ffffffffc0203b56:	fee50513          	addi	a0,a0,-18 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203b5a:	921fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==3);
ffffffffc0203b5e:	00004697          	auipc	a3,0x4
ffffffffc0203b62:	19a68693          	addi	a3,a3,410 # ffffffffc0207cf8 <default_pmm_manager+0x8f0>
ffffffffc0203b66:	00003617          	auipc	a2,0x3
ffffffffc0203b6a:	20a60613          	addi	a2,a2,522 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203b6e:	09d00593          	li	a1,157
ffffffffc0203b72:	00004517          	auipc	a0,0x4
ffffffffc0203b76:	fce50513          	addi	a0,a0,-50 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203b7a:	901fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(pgfault_num==1);
ffffffffc0203b7e:	00004697          	auipc	a3,0x4
ffffffffc0203b82:	15a68693          	addi	a3,a3,346 # ffffffffc0207cd8 <default_pmm_manager+0x8d0>
ffffffffc0203b86:	00003617          	auipc	a2,0x3
ffffffffc0203b8a:	1ea60613          	addi	a2,a2,490 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203b8e:	09300593          	li	a1,147
ffffffffc0203b92:	00004517          	auipc	a0,0x4
ffffffffc0203b96:	fae50513          	addi	a0,a0,-82 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203b9a:	8e1fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203b9e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203b9e:	000af797          	auipc	a5,0xaf
ffffffffc0203ba2:	fb27b783          	ld	a5,-78(a5) # ffffffffc02b2b50 <sm>
ffffffffc0203ba6:	6b9c                	ld	a5,16(a5)
ffffffffc0203ba8:	8782                	jr	a5

ffffffffc0203baa <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203baa:	000af797          	auipc	a5,0xaf
ffffffffc0203bae:	fa67b783          	ld	a5,-90(a5) # ffffffffc02b2b50 <sm>
ffffffffc0203bb2:	739c                	ld	a5,32(a5)
ffffffffc0203bb4:	8782                	jr	a5

ffffffffc0203bb6 <swap_out>:
{
ffffffffc0203bb6:	711d                	addi	sp,sp,-96
ffffffffc0203bb8:	ec86                	sd	ra,88(sp)
ffffffffc0203bba:	e8a2                	sd	s0,80(sp)
ffffffffc0203bbc:	e4a6                	sd	s1,72(sp)
ffffffffc0203bbe:	e0ca                	sd	s2,64(sp)
ffffffffc0203bc0:	fc4e                	sd	s3,56(sp)
ffffffffc0203bc2:	f852                	sd	s4,48(sp)
ffffffffc0203bc4:	f456                	sd	s5,40(sp)
ffffffffc0203bc6:	f05a                	sd	s6,32(sp)
ffffffffc0203bc8:	ec5e                	sd	s7,24(sp)
ffffffffc0203bca:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203bcc:	cde9                	beqz	a1,ffffffffc0203ca6 <swap_out+0xf0>
ffffffffc0203bce:	8a2e                	mv	s4,a1
ffffffffc0203bd0:	892a                	mv	s2,a0
ffffffffc0203bd2:	8ab2                	mv	s5,a2
ffffffffc0203bd4:	4401                	li	s0,0
ffffffffc0203bd6:	000af997          	auipc	s3,0xaf
ffffffffc0203bda:	f7a98993          	addi	s3,s3,-134 # ffffffffc02b2b50 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bde:	00004b17          	auipc	s6,0x4
ffffffffc0203be2:	24ab0b13          	addi	s6,s6,586 # ffffffffc0207e28 <default_pmm_manager+0xa20>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203be6:	00004b97          	auipc	s7,0x4
ffffffffc0203bea:	22ab8b93          	addi	s7,s7,554 # ffffffffc0207e10 <default_pmm_manager+0xa08>
ffffffffc0203bee:	a825                	j	ffffffffc0203c26 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bf0:	67a2                	ld	a5,8(sp)
ffffffffc0203bf2:	8626                	mv	a2,s1
ffffffffc0203bf4:	85a2                	mv	a1,s0
ffffffffc0203bf6:	7f94                	ld	a3,56(a5)
ffffffffc0203bf8:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203bfa:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203bfc:	82b1                	srli	a3,a3,0xc
ffffffffc0203bfe:	0685                	addi	a3,a3,1
ffffffffc0203c00:	d80fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c04:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203c06:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203c08:	7d1c                	ld	a5,56(a0)
ffffffffc0203c0a:	83b1                	srli	a5,a5,0xc
ffffffffc0203c0c:	0785                	addi	a5,a5,1
ffffffffc0203c0e:	07a2                	slli	a5,a5,0x8
ffffffffc0203c10:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203c14:	95efe0ef          	jal	ra,ffffffffc0201d72 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203c18:	01893503          	ld	a0,24(s2)
ffffffffc0203c1c:	85a6                	mv	a1,s1
ffffffffc0203c1e:	f5eff0ef          	jal	ra,ffffffffc020337c <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203c22:	048a0d63          	beq	s4,s0,ffffffffc0203c7c <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203c26:	0009b783          	ld	a5,0(s3)
ffffffffc0203c2a:	8656                	mv	a2,s5
ffffffffc0203c2c:	002c                	addi	a1,sp,8
ffffffffc0203c2e:	7b9c                	ld	a5,48(a5)
ffffffffc0203c30:	854a                	mv	a0,s2
ffffffffc0203c32:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203c34:	e12d                	bnez	a0,ffffffffc0203c96 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203c36:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c38:	01893503          	ld	a0,24(s2)
ffffffffc0203c3c:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203c3e:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c40:	85a6                	mv	a1,s1
ffffffffc0203c42:	9aafe0ef          	jal	ra,ffffffffc0201dec <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c46:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203c48:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c4a:	8b85                	andi	a5,a5,1
ffffffffc0203c4c:	cfb9                	beqz	a5,ffffffffc0203caa <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203c4e:	65a2                	ld	a1,8(sp)
ffffffffc0203c50:	7d9c                	ld	a5,56(a1)
ffffffffc0203c52:	83b1                	srli	a5,a5,0xc
ffffffffc0203c54:	0785                	addi	a5,a5,1
ffffffffc0203c56:	00879513          	slli	a0,a5,0x8
ffffffffc0203c5a:	0da010ef          	jal	ra,ffffffffc0204d34 <swapfs_write>
ffffffffc0203c5e:	d949                	beqz	a0,ffffffffc0203bf0 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203c60:	855e                	mv	a0,s7
ffffffffc0203c62:	d1efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c66:	0009b783          	ld	a5,0(s3)
ffffffffc0203c6a:	6622                	ld	a2,8(sp)
ffffffffc0203c6c:	4681                	li	a3,0
ffffffffc0203c6e:	739c                	ld	a5,32(a5)
ffffffffc0203c70:	85a6                	mv	a1,s1
ffffffffc0203c72:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203c74:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203c76:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203c78:	fa8a17e3          	bne	s4,s0,ffffffffc0203c26 <swap_out+0x70>
}
ffffffffc0203c7c:	60e6                	ld	ra,88(sp)
ffffffffc0203c7e:	8522                	mv	a0,s0
ffffffffc0203c80:	6446                	ld	s0,80(sp)
ffffffffc0203c82:	64a6                	ld	s1,72(sp)
ffffffffc0203c84:	6906                	ld	s2,64(sp)
ffffffffc0203c86:	79e2                	ld	s3,56(sp)
ffffffffc0203c88:	7a42                	ld	s4,48(sp)
ffffffffc0203c8a:	7aa2                	ld	s5,40(sp)
ffffffffc0203c8c:	7b02                	ld	s6,32(sp)
ffffffffc0203c8e:	6be2                	ld	s7,24(sp)
ffffffffc0203c90:	6c42                	ld	s8,16(sp)
ffffffffc0203c92:	6125                	addi	sp,sp,96
ffffffffc0203c94:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203c96:	85a2                	mv	a1,s0
ffffffffc0203c98:	00004517          	auipc	a0,0x4
ffffffffc0203c9c:	13050513          	addi	a0,a0,304 # ffffffffc0207dc8 <default_pmm_manager+0x9c0>
ffffffffc0203ca0:	ce0fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
                  break;
ffffffffc0203ca4:	bfe1                	j	ffffffffc0203c7c <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203ca6:	4401                	li	s0,0
ffffffffc0203ca8:	bfd1                	j	ffffffffc0203c7c <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203caa:	00004697          	auipc	a3,0x4
ffffffffc0203cae:	14e68693          	addi	a3,a3,334 # ffffffffc0207df8 <default_pmm_manager+0x9f0>
ffffffffc0203cb2:	00003617          	auipc	a2,0x3
ffffffffc0203cb6:	0be60613          	addi	a2,a2,190 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203cba:	06800593          	li	a1,104
ffffffffc0203cbe:	00004517          	auipc	a0,0x4
ffffffffc0203cc2:	e8250513          	addi	a0,a0,-382 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203cc6:	fb4fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203cca <swap_in>:
{
ffffffffc0203cca:	7179                	addi	sp,sp,-48
ffffffffc0203ccc:	e84a                	sd	s2,16(sp)
ffffffffc0203cce:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203cd0:	4505                	li	a0,1
{
ffffffffc0203cd2:	ec26                	sd	s1,24(sp)
ffffffffc0203cd4:	e44e                	sd	s3,8(sp)
ffffffffc0203cd6:	f406                	sd	ra,40(sp)
ffffffffc0203cd8:	f022                	sd	s0,32(sp)
ffffffffc0203cda:	84ae                	mv	s1,a1
ffffffffc0203cdc:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203cde:	802fe0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203ce2:	c129                	beqz	a0,ffffffffc0203d24 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203ce4:	842a                	mv	s0,a0
ffffffffc0203ce6:	01893503          	ld	a0,24(s2)
ffffffffc0203cea:	4601                	li	a2,0
ffffffffc0203cec:	85a6                	mv	a1,s1
ffffffffc0203cee:	8fefe0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0203cf2:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203cf4:	6108                	ld	a0,0(a0)
ffffffffc0203cf6:	85a2                	mv	a1,s0
ffffffffc0203cf8:	7af000ef          	jal	ra,ffffffffc0204ca6 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203cfc:	00093583          	ld	a1,0(s2)
ffffffffc0203d00:	8626                	mv	a2,s1
ffffffffc0203d02:	00004517          	auipc	a0,0x4
ffffffffc0203d06:	17650513          	addi	a0,a0,374 # ffffffffc0207e78 <default_pmm_manager+0xa70>
ffffffffc0203d0a:	81a1                	srli	a1,a1,0x8
ffffffffc0203d0c:	c74fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc0203d10:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203d12:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203d16:	7402                	ld	s0,32(sp)
ffffffffc0203d18:	64e2                	ld	s1,24(sp)
ffffffffc0203d1a:	6942                	ld	s2,16(sp)
ffffffffc0203d1c:	69a2                	ld	s3,8(sp)
ffffffffc0203d1e:	4501                	li	a0,0
ffffffffc0203d20:	6145                	addi	sp,sp,48
ffffffffc0203d22:	8082                	ret
     assert(result!=NULL);
ffffffffc0203d24:	00004697          	auipc	a3,0x4
ffffffffc0203d28:	14468693          	addi	a3,a3,324 # ffffffffc0207e68 <default_pmm_manager+0xa60>
ffffffffc0203d2c:	00003617          	auipc	a2,0x3
ffffffffc0203d30:	04460613          	addi	a2,a2,68 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203d34:	07e00593          	li	a1,126
ffffffffc0203d38:	00004517          	auipc	a0,0x4
ffffffffc0203d3c:	e0850513          	addi	a0,a0,-504 # ffffffffc0207b40 <default_pmm_manager+0x738>
ffffffffc0203d40:	f3afc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0203d44 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203d44:	000ab797          	auipc	a5,0xab
ffffffffc0203d48:	d9478793          	addi	a5,a5,-620 # ffffffffc02aead8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203d4c:	f51c                	sd	a5,40(a0)
ffffffffc0203d4e:	e79c                	sd	a5,8(a5)
ffffffffc0203d50:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203d52:	4501                	li	a0,0
ffffffffc0203d54:	8082                	ret

ffffffffc0203d56 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203d56:	4501                	li	a0,0
ffffffffc0203d58:	8082                	ret

ffffffffc0203d5a <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203d5a:	4501                	li	a0,0
ffffffffc0203d5c:	8082                	ret

ffffffffc0203d5e <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203d5e:	4501                	li	a0,0
ffffffffc0203d60:	8082                	ret

ffffffffc0203d62 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203d62:	711d                	addi	sp,sp,-96
ffffffffc0203d64:	fc4e                	sd	s3,56(sp)
ffffffffc0203d66:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d68:	00004517          	auipc	a0,0x4
ffffffffc0203d6c:	15050513          	addi	a0,a0,336 # ffffffffc0207eb8 <default_pmm_manager+0xab0>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d70:	698d                	lui	s3,0x3
ffffffffc0203d72:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203d74:	e0ca                	sd	s2,64(sp)
ffffffffc0203d76:	ec86                	sd	ra,88(sp)
ffffffffc0203d78:	e8a2                	sd	s0,80(sp)
ffffffffc0203d7a:	e4a6                	sd	s1,72(sp)
ffffffffc0203d7c:	f456                	sd	s5,40(sp)
ffffffffc0203d7e:	f05a                	sd	s6,32(sp)
ffffffffc0203d80:	ec5e                	sd	s7,24(sp)
ffffffffc0203d82:	e862                	sd	s8,16(sp)
ffffffffc0203d84:	e466                	sd	s9,8(sp)
ffffffffc0203d86:	e06a                	sd	s10,0(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d88:	bf8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d8c:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6be0>
    assert(pgfault_num==4);
ffffffffc0203d90:	000af917          	auipc	s2,0xaf
ffffffffc0203d94:	dd892903          	lw	s2,-552(s2) # ffffffffc02b2b68 <pgfault_num>
ffffffffc0203d98:	4791                	li	a5,4
ffffffffc0203d9a:	14f91e63          	bne	s2,a5,ffffffffc0203ef6 <_fifo_check_swap+0x194>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d9e:	00004517          	auipc	a0,0x4
ffffffffc0203da2:	15a50513          	addi	a0,a0,346 # ffffffffc0207ef8 <default_pmm_manager+0xaf0>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203da6:	6a85                	lui	s5,0x1
ffffffffc0203da8:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203daa:	bd6fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0203dae:	000af417          	auipc	s0,0xaf
ffffffffc0203db2:	dba40413          	addi	s0,s0,-582 # ffffffffc02b2b68 <pgfault_num>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203db6:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8be0>
    assert(pgfault_num==4);
ffffffffc0203dba:	4004                	lw	s1,0(s0)
ffffffffc0203dbc:	2481                	sext.w	s1,s1
ffffffffc0203dbe:	2b249c63          	bne	s1,s2,ffffffffc0204076 <_fifo_check_swap+0x314>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203dc2:	00004517          	auipc	a0,0x4
ffffffffc0203dc6:	15e50513          	addi	a0,a0,350 # ffffffffc0207f20 <default_pmm_manager+0xb18>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dca:	6b91                	lui	s7,0x4
ffffffffc0203dcc:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203dce:	bb2fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dd2:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5be0>
    assert(pgfault_num==4);
ffffffffc0203dd6:	00042903          	lw	s2,0(s0)
ffffffffc0203dda:	2901                	sext.w	s2,s2
ffffffffc0203ddc:	26991d63          	bne	s2,s1,ffffffffc0204056 <_fifo_check_swap+0x2f4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203de0:	00004517          	auipc	a0,0x4
ffffffffc0203de4:	16850513          	addi	a0,a0,360 # ffffffffc0207f48 <default_pmm_manager+0xb40>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203de8:	6c89                	lui	s9,0x2
ffffffffc0203dea:	4d2d                	li	s10,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dec:	b94fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203df0:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_faultread_out_size-0x7be0>
    assert(pgfault_num==4);
ffffffffc0203df4:	401c                	lw	a5,0(s0)
ffffffffc0203df6:	2781                	sext.w	a5,a5
ffffffffc0203df8:	23279f63          	bne	a5,s2,ffffffffc0204036 <_fifo_check_swap+0x2d4>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dfc:	00004517          	auipc	a0,0x4
ffffffffc0203e00:	17450513          	addi	a0,a0,372 # ffffffffc0207f70 <default_pmm_manager+0xb68>
ffffffffc0203e04:	b7cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e08:	6795                	lui	a5,0x5
ffffffffc0203e0a:	4739                	li	a4,14
ffffffffc0203e0c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4be0>
    assert(pgfault_num==5);
ffffffffc0203e10:	4004                	lw	s1,0(s0)
ffffffffc0203e12:	4795                	li	a5,5
ffffffffc0203e14:	2481                	sext.w	s1,s1
ffffffffc0203e16:	20f49063          	bne	s1,a5,ffffffffc0204016 <_fifo_check_swap+0x2b4>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e1a:	00004517          	auipc	a0,0x4
ffffffffc0203e1e:	12e50513          	addi	a0,a0,302 # ffffffffc0207f48 <default_pmm_manager+0xb40>
ffffffffc0203e22:	b5efc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e26:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==5);
ffffffffc0203e2a:	401c                	lw	a5,0(s0)
ffffffffc0203e2c:	2781                	sext.w	a5,a5
ffffffffc0203e2e:	1c979463          	bne	a5,s1,ffffffffc0203ff6 <_fifo_check_swap+0x294>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e32:	00004517          	auipc	a0,0x4
ffffffffc0203e36:	0c650513          	addi	a0,a0,198 # ffffffffc0207ef8 <default_pmm_manager+0xaf0>
ffffffffc0203e3a:	b46fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203e3e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203e42:	401c                	lw	a5,0(s0)
ffffffffc0203e44:	4719                	li	a4,6
ffffffffc0203e46:	2781                	sext.w	a5,a5
ffffffffc0203e48:	18e79763          	bne	a5,a4,ffffffffc0203fd6 <_fifo_check_swap+0x274>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203e4c:	00004517          	auipc	a0,0x4
ffffffffc0203e50:	0fc50513          	addi	a0,a0,252 # ffffffffc0207f48 <default_pmm_manager+0xb40>
ffffffffc0203e54:	b2cfc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203e58:	01ac8023          	sb	s10,0(s9)
    assert(pgfault_num==7);
ffffffffc0203e5c:	401c                	lw	a5,0(s0)
ffffffffc0203e5e:	471d                	li	a4,7
ffffffffc0203e60:	2781                	sext.w	a5,a5
ffffffffc0203e62:	14e79a63          	bne	a5,a4,ffffffffc0203fb6 <_fifo_check_swap+0x254>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203e66:	00004517          	auipc	a0,0x4
ffffffffc0203e6a:	05250513          	addi	a0,a0,82 # ffffffffc0207eb8 <default_pmm_manager+0xab0>
ffffffffc0203e6e:	b12fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203e72:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203e76:	401c                	lw	a5,0(s0)
ffffffffc0203e78:	4721                	li	a4,8
ffffffffc0203e7a:	2781                	sext.w	a5,a5
ffffffffc0203e7c:	10e79d63          	bne	a5,a4,ffffffffc0203f96 <_fifo_check_swap+0x234>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203e80:	00004517          	auipc	a0,0x4
ffffffffc0203e84:	0a050513          	addi	a0,a0,160 # ffffffffc0207f20 <default_pmm_manager+0xb18>
ffffffffc0203e88:	af8fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203e8c:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203e90:	401c                	lw	a5,0(s0)
ffffffffc0203e92:	4725                	li	a4,9
ffffffffc0203e94:	2781                	sext.w	a5,a5
ffffffffc0203e96:	0ee79063          	bne	a5,a4,ffffffffc0203f76 <_fifo_check_swap+0x214>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203e9a:	00004517          	auipc	a0,0x4
ffffffffc0203e9e:	0d650513          	addi	a0,a0,214 # ffffffffc0207f70 <default_pmm_manager+0xb68>
ffffffffc0203ea2:	adefc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203ea6:	6795                	lui	a5,0x5
ffffffffc0203ea8:	4739                	li	a4,14
ffffffffc0203eaa:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4be0>
    assert(pgfault_num==10);
ffffffffc0203eae:	4004                	lw	s1,0(s0)
ffffffffc0203eb0:	47a9                	li	a5,10
ffffffffc0203eb2:	2481                	sext.w	s1,s1
ffffffffc0203eb4:	0af49163          	bne	s1,a5,ffffffffc0203f56 <_fifo_check_swap+0x1f4>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203eb8:	00004517          	auipc	a0,0x4
ffffffffc0203ebc:	04050513          	addi	a0,a0,64 # ffffffffc0207ef8 <default_pmm_manager+0xaf0>
ffffffffc0203ec0:	ac0fc0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203ec4:	6785                	lui	a5,0x1
ffffffffc0203ec6:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8be0>
ffffffffc0203eca:	06979663          	bne	a5,s1,ffffffffc0203f36 <_fifo_check_swap+0x1d4>
    assert(pgfault_num==11);
ffffffffc0203ece:	401c                	lw	a5,0(s0)
ffffffffc0203ed0:	472d                	li	a4,11
ffffffffc0203ed2:	2781                	sext.w	a5,a5
ffffffffc0203ed4:	04e79163          	bne	a5,a4,ffffffffc0203f16 <_fifo_check_swap+0x1b4>
}
ffffffffc0203ed8:	60e6                	ld	ra,88(sp)
ffffffffc0203eda:	6446                	ld	s0,80(sp)
ffffffffc0203edc:	64a6                	ld	s1,72(sp)
ffffffffc0203ede:	6906                	ld	s2,64(sp)
ffffffffc0203ee0:	79e2                	ld	s3,56(sp)
ffffffffc0203ee2:	7a42                	ld	s4,48(sp)
ffffffffc0203ee4:	7aa2                	ld	s5,40(sp)
ffffffffc0203ee6:	7b02                	ld	s6,32(sp)
ffffffffc0203ee8:	6be2                	ld	s7,24(sp)
ffffffffc0203eea:	6c42                	ld	s8,16(sp)
ffffffffc0203eec:	6ca2                	ld	s9,8(sp)
ffffffffc0203eee:	6d02                	ld	s10,0(sp)
ffffffffc0203ef0:	4501                	li	a0,0
ffffffffc0203ef2:	6125                	addi	sp,sp,96
ffffffffc0203ef4:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203ef6:	00004697          	auipc	a3,0x4
ffffffffc0203efa:	e1268693          	addi	a3,a3,-494 # ffffffffc0207d08 <default_pmm_manager+0x900>
ffffffffc0203efe:	00003617          	auipc	a2,0x3
ffffffffc0203f02:	e7260613          	addi	a2,a2,-398 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203f06:	05100593          	li	a1,81
ffffffffc0203f0a:	00004517          	auipc	a0,0x4
ffffffffc0203f0e:	fd650513          	addi	a0,a0,-42 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203f12:	d68fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==11);
ffffffffc0203f16:	00004697          	auipc	a3,0x4
ffffffffc0203f1a:	10a68693          	addi	a3,a3,266 # ffffffffc0208020 <default_pmm_manager+0xc18>
ffffffffc0203f1e:	00003617          	auipc	a2,0x3
ffffffffc0203f22:	e5260613          	addi	a2,a2,-430 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203f26:	07300593          	li	a1,115
ffffffffc0203f2a:	00004517          	auipc	a0,0x4
ffffffffc0203f2e:	fb650513          	addi	a0,a0,-74 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203f32:	d48fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203f36:	00004697          	auipc	a3,0x4
ffffffffc0203f3a:	0c268693          	addi	a3,a3,194 # ffffffffc0207ff8 <default_pmm_manager+0xbf0>
ffffffffc0203f3e:	00003617          	auipc	a2,0x3
ffffffffc0203f42:	e3260613          	addi	a2,a2,-462 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203f46:	07100593          	li	a1,113
ffffffffc0203f4a:	00004517          	auipc	a0,0x4
ffffffffc0203f4e:	f9650513          	addi	a0,a0,-106 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203f52:	d28fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==10);
ffffffffc0203f56:	00004697          	auipc	a3,0x4
ffffffffc0203f5a:	09268693          	addi	a3,a3,146 # ffffffffc0207fe8 <default_pmm_manager+0xbe0>
ffffffffc0203f5e:	00003617          	auipc	a2,0x3
ffffffffc0203f62:	e1260613          	addi	a2,a2,-494 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203f66:	06f00593          	li	a1,111
ffffffffc0203f6a:	00004517          	auipc	a0,0x4
ffffffffc0203f6e:	f7650513          	addi	a0,a0,-138 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203f72:	d08fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==9);
ffffffffc0203f76:	00004697          	auipc	a3,0x4
ffffffffc0203f7a:	06268693          	addi	a3,a3,98 # ffffffffc0207fd8 <default_pmm_manager+0xbd0>
ffffffffc0203f7e:	00003617          	auipc	a2,0x3
ffffffffc0203f82:	df260613          	addi	a2,a2,-526 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203f86:	06c00593          	li	a1,108
ffffffffc0203f8a:	00004517          	auipc	a0,0x4
ffffffffc0203f8e:	f5650513          	addi	a0,a0,-170 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203f92:	ce8fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==8);
ffffffffc0203f96:	00004697          	auipc	a3,0x4
ffffffffc0203f9a:	03268693          	addi	a3,a3,50 # ffffffffc0207fc8 <default_pmm_manager+0xbc0>
ffffffffc0203f9e:	00003617          	auipc	a2,0x3
ffffffffc0203fa2:	dd260613          	addi	a2,a2,-558 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203fa6:	06900593          	li	a1,105
ffffffffc0203faa:	00004517          	auipc	a0,0x4
ffffffffc0203fae:	f3650513          	addi	a0,a0,-202 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203fb2:	cc8fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==7);
ffffffffc0203fb6:	00004697          	auipc	a3,0x4
ffffffffc0203fba:	00268693          	addi	a3,a3,2 # ffffffffc0207fb8 <default_pmm_manager+0xbb0>
ffffffffc0203fbe:	00003617          	auipc	a2,0x3
ffffffffc0203fc2:	db260613          	addi	a2,a2,-590 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203fc6:	06600593          	li	a1,102
ffffffffc0203fca:	00004517          	auipc	a0,0x4
ffffffffc0203fce:	f1650513          	addi	a0,a0,-234 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203fd2:	ca8fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==6);
ffffffffc0203fd6:	00004697          	auipc	a3,0x4
ffffffffc0203fda:	fd268693          	addi	a3,a3,-46 # ffffffffc0207fa8 <default_pmm_manager+0xba0>
ffffffffc0203fde:	00003617          	auipc	a2,0x3
ffffffffc0203fe2:	d9260613          	addi	a2,a2,-622 # ffffffffc0206d70 <commands+0x450>
ffffffffc0203fe6:	06300593          	li	a1,99
ffffffffc0203fea:	00004517          	auipc	a0,0x4
ffffffffc0203fee:	ef650513          	addi	a0,a0,-266 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0203ff2:	c88fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0203ff6:	00004697          	auipc	a3,0x4
ffffffffc0203ffa:	fa268693          	addi	a3,a3,-94 # ffffffffc0207f98 <default_pmm_manager+0xb90>
ffffffffc0203ffe:	00003617          	auipc	a2,0x3
ffffffffc0204002:	d7260613          	addi	a2,a2,-654 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204006:	06000593          	li	a1,96
ffffffffc020400a:	00004517          	auipc	a0,0x4
ffffffffc020400e:	ed650513          	addi	a0,a0,-298 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0204012:	c68fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==5);
ffffffffc0204016:	00004697          	auipc	a3,0x4
ffffffffc020401a:	f8268693          	addi	a3,a3,-126 # ffffffffc0207f98 <default_pmm_manager+0xb90>
ffffffffc020401e:	00003617          	auipc	a2,0x3
ffffffffc0204022:	d5260613          	addi	a2,a2,-686 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204026:	05d00593          	li	a1,93
ffffffffc020402a:	00004517          	auipc	a0,0x4
ffffffffc020402e:	eb650513          	addi	a0,a0,-330 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0204032:	c48fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0204036:	00004697          	auipc	a3,0x4
ffffffffc020403a:	cd268693          	addi	a3,a3,-814 # ffffffffc0207d08 <default_pmm_manager+0x900>
ffffffffc020403e:	00003617          	auipc	a2,0x3
ffffffffc0204042:	d3260613          	addi	a2,a2,-718 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204046:	05a00593          	li	a1,90
ffffffffc020404a:	00004517          	auipc	a0,0x4
ffffffffc020404e:	e9650513          	addi	a0,a0,-362 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0204052:	c28fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0204056:	00004697          	auipc	a3,0x4
ffffffffc020405a:	cb268693          	addi	a3,a3,-846 # ffffffffc0207d08 <default_pmm_manager+0x900>
ffffffffc020405e:	00003617          	auipc	a2,0x3
ffffffffc0204062:	d1260613          	addi	a2,a2,-750 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204066:	05700593          	li	a1,87
ffffffffc020406a:	00004517          	auipc	a0,0x4
ffffffffc020406e:	e7650513          	addi	a0,a0,-394 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0204072:	c08fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgfault_num==4);
ffffffffc0204076:	00004697          	auipc	a3,0x4
ffffffffc020407a:	c9268693          	addi	a3,a3,-878 # ffffffffc0207d08 <default_pmm_manager+0x900>
ffffffffc020407e:	00003617          	auipc	a2,0x3
ffffffffc0204082:	cf260613          	addi	a2,a2,-782 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204086:	05400593          	li	a1,84
ffffffffc020408a:	00004517          	auipc	a0,0x4
ffffffffc020408e:	e5650513          	addi	a0,a0,-426 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc0204092:	be8fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204096 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204096:	751c                	ld	a5,40(a0)
{
ffffffffc0204098:	1141                	addi	sp,sp,-16
ffffffffc020409a:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020409c:	cf91                	beqz	a5,ffffffffc02040b8 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc020409e:	ee0d                	bnez	a2,ffffffffc02040d8 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc02040a0:	679c                	ld	a5,8(a5)
}
ffffffffc02040a2:	60a2                	ld	ra,8(sp)
ffffffffc02040a4:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc02040a6:	6394                	ld	a3,0(a5)
ffffffffc02040a8:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc02040aa:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc02040ae:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02040b0:	e314                	sd	a3,0(a4)
ffffffffc02040b2:	e19c                	sd	a5,0(a1)
}
ffffffffc02040b4:	0141                	addi	sp,sp,16
ffffffffc02040b6:	8082                	ret
         assert(head != NULL);
ffffffffc02040b8:	00004697          	auipc	a3,0x4
ffffffffc02040bc:	f7868693          	addi	a3,a3,-136 # ffffffffc0208030 <default_pmm_manager+0xc28>
ffffffffc02040c0:	00003617          	auipc	a2,0x3
ffffffffc02040c4:	cb060613          	addi	a2,a2,-848 # ffffffffc0206d70 <commands+0x450>
ffffffffc02040c8:	04100593          	li	a1,65
ffffffffc02040cc:	00004517          	auipc	a0,0x4
ffffffffc02040d0:	e1450513          	addi	a0,a0,-492 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc02040d4:	ba6fc0ef          	jal	ra,ffffffffc020047a <__panic>
     assert(in_tick==0);
ffffffffc02040d8:	00004697          	auipc	a3,0x4
ffffffffc02040dc:	f6868693          	addi	a3,a3,-152 # ffffffffc0208040 <default_pmm_manager+0xc38>
ffffffffc02040e0:	00003617          	auipc	a2,0x3
ffffffffc02040e4:	c9060613          	addi	a2,a2,-880 # ffffffffc0206d70 <commands+0x450>
ffffffffc02040e8:	04200593          	li	a1,66
ffffffffc02040ec:	00004517          	auipc	a0,0x4
ffffffffc02040f0:	df450513          	addi	a0,a0,-524 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
ffffffffc02040f4:	b86fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02040f8 <_fifo_map_swappable>:
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02040f8:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02040fa:	cb91                	beqz	a5,ffffffffc020410e <_fifo_map_swappable+0x16>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02040fc:	6394                	ld	a3,0(a5)
ffffffffc02040fe:	02860713          	addi	a4,a2,40
    prev->next = next->prev = elm;
ffffffffc0204102:	e398                	sd	a4,0(a5)
ffffffffc0204104:	e698                	sd	a4,8(a3)
}
ffffffffc0204106:	4501                	li	a0,0
    elm->next = next;
ffffffffc0204108:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020410a:	f614                	sd	a3,40(a2)
ffffffffc020410c:	8082                	ret
{
ffffffffc020410e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204110:	00004697          	auipc	a3,0x4
ffffffffc0204114:	f4068693          	addi	a3,a3,-192 # ffffffffc0208050 <default_pmm_manager+0xc48>
ffffffffc0204118:	00003617          	auipc	a2,0x3
ffffffffc020411c:	c5860613          	addi	a2,a2,-936 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204120:	03200593          	li	a1,50
ffffffffc0204124:	00004517          	auipc	a0,0x4
ffffffffc0204128:	dbc50513          	addi	a0,a0,-580 # ffffffffc0207ee0 <default_pmm_manager+0xad8>
{
ffffffffc020412c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020412e:	b4cfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204132 <check_vma_overlap.part.0>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204132:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204134:	00004697          	auipc	a3,0x4
ffffffffc0204138:	f5468693          	addi	a3,a3,-172 # ffffffffc0208088 <default_pmm_manager+0xc80>
ffffffffc020413c:	00003617          	auipc	a2,0x3
ffffffffc0204140:	c3460613          	addi	a2,a2,-972 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204144:	06d00593          	li	a1,109
ffffffffc0204148:	00004517          	auipc	a0,0x4
ffffffffc020414c:	f6050513          	addi	a0,a0,-160 # ffffffffc02080a8 <default_pmm_manager+0xca0>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204150:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204152:	b28fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204156 <pa2page.part.0>:
pa2page(uintptr_t pa) {
ffffffffc0204156:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0204158:	00003617          	auipc	a2,0x3
ffffffffc020415c:	3b860613          	addi	a2,a2,952 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0204160:	06200593          	li	a1,98
ffffffffc0204164:	00003517          	auipc	a0,0x3
ffffffffc0204168:	30450513          	addi	a0,a0,772 # ffffffffc0207468 <default_pmm_manager+0x60>
pa2page(uintptr_t pa) {
ffffffffc020416c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020416e:	b0cfc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204172 <mm_create>:
mm_create(void) {
ffffffffc0204172:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204174:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0204178:	e022                	sd	s0,0(sp)
ffffffffc020417a:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020417c:	987fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204180:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204182:	c505                	beqz	a0,ffffffffc02041aa <mm_create+0x38>
    elm->prev = elm->next = elm;
ffffffffc0204184:	e408                	sd	a0,8(s0)
ffffffffc0204186:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204188:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020418c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204190:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204194:	000af797          	auipc	a5,0xaf
ffffffffc0204198:	9c47a783          	lw	a5,-1596(a5) # ffffffffc02b2b58 <swap_init_ok>
ffffffffc020419c:	ef81                	bnez	a5,ffffffffc02041b4 <mm_create+0x42>
        else mm->sm_priv = NULL;
ffffffffc020419e:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02041a2:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02041a6:	02043c23          	sd	zero,56(s0)
}
ffffffffc02041aa:	60a2                	ld	ra,8(sp)
ffffffffc02041ac:	8522                	mv	a0,s0
ffffffffc02041ae:	6402                	ld	s0,0(sp)
ffffffffc02041b0:	0141                	addi	sp,sp,16
ffffffffc02041b2:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02041b4:	9ebff0ef          	jal	ra,ffffffffc0203b9e <swap_init_mm>
ffffffffc02041b8:	b7ed                	j	ffffffffc02041a2 <mm_create+0x30>

ffffffffc02041ba <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02041ba:	1101                	addi	sp,sp,-32
ffffffffc02041bc:	e04a                	sd	s2,0(sp)
ffffffffc02041be:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02041c0:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02041c4:	e822                	sd	s0,16(sp)
ffffffffc02041c6:	e426                	sd	s1,8(sp)
ffffffffc02041c8:	ec06                	sd	ra,24(sp)
ffffffffc02041ca:	84ae                	mv	s1,a1
ffffffffc02041cc:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02041ce:	935fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
    if (vma != NULL) {
ffffffffc02041d2:	c509                	beqz	a0,ffffffffc02041dc <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02041d4:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02041d8:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02041da:	cd00                	sw	s0,24(a0)
}
ffffffffc02041dc:	60e2                	ld	ra,24(sp)
ffffffffc02041de:	6442                	ld	s0,16(sp)
ffffffffc02041e0:	64a2                	ld	s1,8(sp)
ffffffffc02041e2:	6902                	ld	s2,0(sp)
ffffffffc02041e4:	6105                	addi	sp,sp,32
ffffffffc02041e6:	8082                	ret

ffffffffc02041e8 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc02041e8:	86aa                	mv	a3,a0
    if (mm != NULL) {
ffffffffc02041ea:	c505                	beqz	a0,ffffffffc0204212 <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc02041ec:	6908                	ld	a0,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02041ee:	c501                	beqz	a0,ffffffffc02041f6 <find_vma+0xe>
ffffffffc02041f0:	651c                	ld	a5,8(a0)
ffffffffc02041f2:	02f5f263          	bgeu	a1,a5,ffffffffc0204216 <find_vma+0x2e>
    return listelm->next;
ffffffffc02041f6:	669c                	ld	a5,8(a3)
                while ((le = list_next(le)) != list) {
ffffffffc02041f8:	00f68d63          	beq	a3,a5,ffffffffc0204212 <find_vma+0x2a>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02041fc:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204200:	00e5e663          	bltu	a1,a4,ffffffffc020420c <find_vma+0x24>
ffffffffc0204204:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204208:	00e5ec63          	bltu	a1,a4,ffffffffc0204220 <find_vma+0x38>
ffffffffc020420c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020420e:	fef697e3          	bne	a3,a5,ffffffffc02041fc <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc0204212:	4501                	li	a0,0
}
ffffffffc0204214:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204216:	691c                	ld	a5,16(a0)
ffffffffc0204218:	fcf5ffe3          	bgeu	a1,a5,ffffffffc02041f6 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc020421c:	ea88                	sd	a0,16(a3)
ffffffffc020421e:	8082                	ret
                    vma = le2vma(le, list_link);
ffffffffc0204220:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc0204224:	ea88                	sd	a0,16(a3)
ffffffffc0204226:	8082                	ret

ffffffffc0204228 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204228:	6590                	ld	a2,8(a1)
ffffffffc020422a:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8bd0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020422e:	1141                	addi	sp,sp,-16
ffffffffc0204230:	e406                	sd	ra,8(sp)
ffffffffc0204232:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204234:	01066763          	bltu	a2,a6,ffffffffc0204242 <insert_vma_struct+0x1a>
ffffffffc0204238:	a085                	j	ffffffffc0204298 <insert_vma_struct+0x70>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc020423a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020423e:	04e66863          	bltu	a2,a4,ffffffffc020428e <insert_vma_struct+0x66>
ffffffffc0204242:	86be                	mv	a3,a5
ffffffffc0204244:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204246:	fef51ae3          	bne	a0,a5,ffffffffc020423a <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc020424a:	02a68463          	beq	a3,a0,ffffffffc0204272 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020424e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204252:	fe86b883          	ld	a7,-24(a3)
ffffffffc0204256:	08e8f163          	bgeu	a7,a4,ffffffffc02042d8 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020425a:	04e66f63          	bltu	a2,a4,ffffffffc02042b8 <insert_vma_struct+0x90>
    }
    if (le_next != list) {
ffffffffc020425e:	00f50a63          	beq	a0,a5,ffffffffc0204272 <insert_vma_struct+0x4a>
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204262:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204266:	05076963          	bltu	a4,a6,ffffffffc02042b8 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc020426a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020426e:	02c77363          	bgeu	a4,a2,ffffffffc0204294 <insert_vma_struct+0x6c>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc0204272:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0204274:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0204276:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020427a:	e390                	sd	a2,0(a5)
ffffffffc020427c:	e690                	sd	a2,8(a3)
}
ffffffffc020427e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204280:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0204282:	f194                	sd	a3,32(a1)
    mm->map_count ++;
ffffffffc0204284:	0017079b          	addiw	a5,a4,1
ffffffffc0204288:	d11c                	sw	a5,32(a0)
}
ffffffffc020428a:	0141                	addi	sp,sp,16
ffffffffc020428c:	8082                	ret
    if (le_prev != list) {
ffffffffc020428e:	fca690e3          	bne	a3,a0,ffffffffc020424e <insert_vma_struct+0x26>
ffffffffc0204292:	bfd1                	j	ffffffffc0204266 <insert_vma_struct+0x3e>
ffffffffc0204294:	e9fff0ef          	jal	ra,ffffffffc0204132 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204298:	00004697          	auipc	a3,0x4
ffffffffc020429c:	e2068693          	addi	a3,a3,-480 # ffffffffc02080b8 <default_pmm_manager+0xcb0>
ffffffffc02042a0:	00003617          	auipc	a2,0x3
ffffffffc02042a4:	ad060613          	addi	a2,a2,-1328 # ffffffffc0206d70 <commands+0x450>
ffffffffc02042a8:	07400593          	li	a1,116
ffffffffc02042ac:	00004517          	auipc	a0,0x4
ffffffffc02042b0:	dfc50513          	addi	a0,a0,-516 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02042b4:	9c6fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02042b8:	00004697          	auipc	a3,0x4
ffffffffc02042bc:	e4068693          	addi	a3,a3,-448 # ffffffffc02080f8 <default_pmm_manager+0xcf0>
ffffffffc02042c0:	00003617          	auipc	a2,0x3
ffffffffc02042c4:	ab060613          	addi	a2,a2,-1360 # ffffffffc0206d70 <commands+0x450>
ffffffffc02042c8:	06c00593          	li	a1,108
ffffffffc02042cc:	00004517          	auipc	a0,0x4
ffffffffc02042d0:	ddc50513          	addi	a0,a0,-548 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02042d4:	9a6fc0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02042d8:	00004697          	auipc	a3,0x4
ffffffffc02042dc:	e0068693          	addi	a3,a3,-512 # ffffffffc02080d8 <default_pmm_manager+0xcd0>
ffffffffc02042e0:	00003617          	auipc	a2,0x3
ffffffffc02042e4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0206d70 <commands+0x450>
ffffffffc02042e8:	06b00593          	li	a1,107
ffffffffc02042ec:	00004517          	auipc	a0,0x4
ffffffffc02042f0:	dbc50513          	addi	a0,a0,-580 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02042f4:	986fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02042f8 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc02042f8:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02042fa:	1141                	addi	sp,sp,-16
ffffffffc02042fc:	e406                	sd	ra,8(sp)
ffffffffc02042fe:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204300:	e78d                	bnez	a5,ffffffffc020432a <mm_destroy+0x32>
ffffffffc0204302:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204304:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204306:	00a40c63          	beq	s0,a0,ffffffffc020431e <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020430a:	6118                	ld	a4,0(a0)
ffffffffc020430c:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc020430e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204310:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204312:	e398                	sd	a4,0(a5)
ffffffffc0204314:	89ffd0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    return listelm->next;
ffffffffc0204318:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020431a:	fea418e3          	bne	s0,a0,ffffffffc020430a <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc020431e:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204320:	6402                	ld	s0,0(sp)
ffffffffc0204322:	60a2                	ld	ra,8(sp)
ffffffffc0204324:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204326:	88dfd06f          	j	ffffffffc0201bb2 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020432a:	00004697          	auipc	a3,0x4
ffffffffc020432e:	dee68693          	addi	a3,a3,-530 # ffffffffc0208118 <default_pmm_manager+0xd10>
ffffffffc0204332:	00003617          	auipc	a2,0x3
ffffffffc0204336:	a3e60613          	addi	a2,a2,-1474 # ffffffffc0206d70 <commands+0x450>
ffffffffc020433a:	09400593          	li	a1,148
ffffffffc020433e:	00004517          	auipc	a0,0x4
ffffffffc0204342:	d6a50513          	addi	a0,a0,-662 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204346:	934fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020434a <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
ffffffffc020434a:	7139                	addi	sp,sp,-64
ffffffffc020434c:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020434e:	6405                	lui	s0,0x1
ffffffffc0204350:	147d                	addi	s0,s0,-1
ffffffffc0204352:	77fd                	lui	a5,0xfffff
ffffffffc0204354:	9622                	add	a2,a2,s0
ffffffffc0204356:	962e                	add	a2,a2,a1
       struct vma_struct **vma_store) {
ffffffffc0204358:	f426                	sd	s1,40(sp)
ffffffffc020435a:	fc06                	sd	ra,56(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020435c:	00f5f4b3          	and	s1,a1,a5
       struct vma_struct **vma_store) {
ffffffffc0204360:	f04a                	sd	s2,32(sp)
ffffffffc0204362:	ec4e                	sd	s3,24(sp)
ffffffffc0204364:	e852                	sd	s4,16(sp)
ffffffffc0204366:	e456                	sd	s5,8(sp)
    if (!USER_ACCESS(start, end)) {
ffffffffc0204368:	002005b7          	lui	a1,0x200
ffffffffc020436c:	00f67433          	and	s0,a2,a5
ffffffffc0204370:	06b4e363          	bltu	s1,a1,ffffffffc02043d6 <mm_map+0x8c>
ffffffffc0204374:	0684f163          	bgeu	s1,s0,ffffffffc02043d6 <mm_map+0x8c>
ffffffffc0204378:	4785                	li	a5,1
ffffffffc020437a:	07fe                	slli	a5,a5,0x1f
ffffffffc020437c:	0487ed63          	bltu	a5,s0,ffffffffc02043d6 <mm_map+0x8c>
ffffffffc0204380:	89aa                	mv	s3,a0
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0204382:	cd21                	beqz	a0,ffffffffc02043da <mm_map+0x90>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc0204384:	85a6                	mv	a1,s1
ffffffffc0204386:	8ab6                	mv	s5,a3
ffffffffc0204388:	8a3a                	mv	s4,a4
ffffffffc020438a:	e5fff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
ffffffffc020438e:	c501                	beqz	a0,ffffffffc0204396 <mm_map+0x4c>
ffffffffc0204390:	651c                	ld	a5,8(a0)
ffffffffc0204392:	0487e263          	bltu	a5,s0,ffffffffc02043d6 <mm_map+0x8c>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204396:	03000513          	li	a0,48
ffffffffc020439a:	f68fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc020439e:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02043a0:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02043a2:	02090163          	beqz	s2,ffffffffc02043c4 <mm_map+0x7a>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02043a6:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02043a8:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02043ac:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02043b0:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02043b4:	85ca                	mv	a1,s2
ffffffffc02043b6:	e73ff0ef          	jal	ra,ffffffffc0204228 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02043ba:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02043bc:	000a0463          	beqz	s4,ffffffffc02043c4 <mm_map+0x7a>
        *vma_store = vma;
ffffffffc02043c0:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02043c4:	70e2                	ld	ra,56(sp)
ffffffffc02043c6:	7442                	ld	s0,48(sp)
ffffffffc02043c8:	74a2                	ld	s1,40(sp)
ffffffffc02043ca:	7902                	ld	s2,32(sp)
ffffffffc02043cc:	69e2                	ld	s3,24(sp)
ffffffffc02043ce:	6a42                	ld	s4,16(sp)
ffffffffc02043d0:	6aa2                	ld	s5,8(sp)
ffffffffc02043d2:	6121                	addi	sp,sp,64
ffffffffc02043d4:	8082                	ret
        return -E_INVAL;
ffffffffc02043d6:	5575                	li	a0,-3
ffffffffc02043d8:	b7f5                	j	ffffffffc02043c4 <mm_map+0x7a>
    assert(mm != NULL);
ffffffffc02043da:	00003697          	auipc	a3,0x3
ffffffffc02043de:	7b668693          	addi	a3,a3,1974 # ffffffffc0207b90 <default_pmm_manager+0x788>
ffffffffc02043e2:	00003617          	auipc	a2,0x3
ffffffffc02043e6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0206d70 <commands+0x450>
ffffffffc02043ea:	0a700593          	li	a1,167
ffffffffc02043ee:	00004517          	auipc	a0,0x4
ffffffffc02043f2:	cba50513          	addi	a0,a0,-838 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02043f6:	884fc0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02043fa <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02043fa:	7139                	addi	sp,sp,-64
ffffffffc02043fc:	fc06                	sd	ra,56(sp)
ffffffffc02043fe:	f822                	sd	s0,48(sp)
ffffffffc0204400:	f426                	sd	s1,40(sp)
ffffffffc0204402:	f04a                	sd	s2,32(sp)
ffffffffc0204404:	ec4e                	sd	s3,24(sp)
ffffffffc0204406:	e852                	sd	s4,16(sp)
ffffffffc0204408:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc020440a:	c52d                	beqz	a0,ffffffffc0204474 <dup_mmap+0x7a>
ffffffffc020440c:	892a                	mv	s2,a0
ffffffffc020440e:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204410:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204412:	e595                	bnez	a1,ffffffffc020443e <dup_mmap+0x44>
ffffffffc0204414:	a085                	j	ffffffffc0204474 <dup_mmap+0x7a>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204416:	854a                	mv	a0,s2
        vma->vm_start = vm_start;
ffffffffc0204418:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_exit_out_size+0x1f4eb0>
        vma->vm_end = vm_end;
ffffffffc020441c:	0145b823          	sd	s4,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0204420:	0135ac23          	sw	s3,24(a1)
        insert_vma_struct(to, nvma);
ffffffffc0204424:	e05ff0ef          	jal	ra,ffffffffc0204228 <insert_vma_struct>

        // cow: 启用共享
        bool share = 1;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204428:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_faultread_out_size-0x8bf0>
ffffffffc020442c:	fe843603          	ld	a2,-24(s0)
ffffffffc0204430:	6c8c                	ld	a1,24(s1)
ffffffffc0204432:	01893503          	ld	a0,24(s2)
ffffffffc0204436:	4705                	li	a4,1
ffffffffc0204438:	cdffe0ef          	jal	ra,ffffffffc0203116 <copy_range>
ffffffffc020443c:	e105                	bnez	a0,ffffffffc020445c <dup_mmap+0x62>
    return listelm->prev;
ffffffffc020443e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0204440:	02848863          	beq	s1,s0,ffffffffc0204470 <dup_mmap+0x76>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204444:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204448:	fe843a83          	ld	s5,-24(s0)
ffffffffc020444c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204450:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204454:	eaefd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204458:	85aa                	mv	a1,a0
    if (vma != NULL) {
ffffffffc020445a:	fd55                	bnez	a0,ffffffffc0204416 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc020445c:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020445e:	70e2                	ld	ra,56(sp)
ffffffffc0204460:	7442                	ld	s0,48(sp)
ffffffffc0204462:	74a2                	ld	s1,40(sp)
ffffffffc0204464:	7902                	ld	s2,32(sp)
ffffffffc0204466:	69e2                	ld	s3,24(sp)
ffffffffc0204468:	6a42                	ld	s4,16(sp)
ffffffffc020446a:	6aa2                	ld	s5,8(sp)
ffffffffc020446c:	6121                	addi	sp,sp,64
ffffffffc020446e:	8082                	ret
    return 0;
ffffffffc0204470:	4501                	li	a0,0
ffffffffc0204472:	b7f5                	j	ffffffffc020445e <dup_mmap+0x64>
    assert(to != NULL && from != NULL);
ffffffffc0204474:	00004697          	auipc	a3,0x4
ffffffffc0204478:	cbc68693          	addi	a3,a3,-836 # ffffffffc0208130 <default_pmm_manager+0xd28>
ffffffffc020447c:	00003617          	auipc	a2,0x3
ffffffffc0204480:	8f460613          	addi	a2,a2,-1804 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204484:	0c000593          	li	a1,192
ffffffffc0204488:	00004517          	auipc	a0,0x4
ffffffffc020448c:	c2050513          	addi	a0,a0,-992 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204490:	febfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204494 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc0204494:	1101                	addi	sp,sp,-32
ffffffffc0204496:	ec06                	sd	ra,24(sp)
ffffffffc0204498:	e822                	sd	s0,16(sp)
ffffffffc020449a:	e426                	sd	s1,8(sp)
ffffffffc020449c:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020449e:	c531                	beqz	a0,ffffffffc02044ea <exit_mmap+0x56>
ffffffffc02044a0:	591c                	lw	a5,48(a0)
ffffffffc02044a2:	84aa                	mv	s1,a0
ffffffffc02044a4:	e3b9                	bnez	a5,ffffffffc02044ea <exit_mmap+0x56>
    return listelm->next;
ffffffffc02044a6:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02044a8:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02044ac:	02850663          	beq	a0,s0,ffffffffc02044d8 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044b0:	ff043603          	ld	a2,-16(s0)
ffffffffc02044b4:	fe843583          	ld	a1,-24(s0)
ffffffffc02044b8:	854a                	mv	a0,s2
ffffffffc02044ba:	b59fd0ef          	jal	ra,ffffffffc0202012 <unmap_range>
ffffffffc02044be:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02044c0:	fe8498e3          	bne	s1,s0,ffffffffc02044b0 <exit_mmap+0x1c>
ffffffffc02044c4:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02044c6:	00848c63          	beq	s1,s0,ffffffffc02044de <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02044ca:	ff043603          	ld	a2,-16(s0)
ffffffffc02044ce:	fe843583          	ld	a1,-24(s0)
ffffffffc02044d2:	854a                	mv	a0,s2
ffffffffc02044d4:	c85fd0ef          	jal	ra,ffffffffc0202158 <exit_range>
ffffffffc02044d8:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02044da:	fe8498e3          	bne	s1,s0,ffffffffc02044ca <exit_mmap+0x36>
    }
}
ffffffffc02044de:	60e2                	ld	ra,24(sp)
ffffffffc02044e0:	6442                	ld	s0,16(sp)
ffffffffc02044e2:	64a2                	ld	s1,8(sp)
ffffffffc02044e4:	6902                	ld	s2,0(sp)
ffffffffc02044e6:	6105                	addi	sp,sp,32
ffffffffc02044e8:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02044ea:	00004697          	auipc	a3,0x4
ffffffffc02044ee:	c6668693          	addi	a3,a3,-922 # ffffffffc0208150 <default_pmm_manager+0xd48>
ffffffffc02044f2:	00003617          	auipc	a2,0x3
ffffffffc02044f6:	87e60613          	addi	a2,a2,-1922 # ffffffffc0206d70 <commands+0x450>
ffffffffc02044fa:	0d700593          	li	a1,215
ffffffffc02044fe:	00004517          	auipc	a0,0x4
ffffffffc0204502:	baa50513          	addi	a0,a0,-1110 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204506:	f75fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020450a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020450a:	7139                	addi	sp,sp,-64
ffffffffc020450c:	f822                	sd	s0,48(sp)
ffffffffc020450e:	f426                	sd	s1,40(sp)
ffffffffc0204510:	fc06                	sd	ra,56(sp)
ffffffffc0204512:	f04a                	sd	s2,32(sp)
ffffffffc0204514:	ec4e                	sd	s3,24(sp)
ffffffffc0204516:	e852                	sd	s4,16(sp)
ffffffffc0204518:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc020451a:	c59ff0ef          	jal	ra,ffffffffc0204172 <mm_create>
    assert(mm != NULL);
ffffffffc020451e:	84aa                	mv	s1,a0
ffffffffc0204520:	03200413          	li	s0,50
ffffffffc0204524:	e919                	bnez	a0,ffffffffc020453a <vmm_init+0x30>
ffffffffc0204526:	a991                	j	ffffffffc020497a <vmm_init+0x470>
        vma->vm_start = vm_start;
ffffffffc0204528:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020452a:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020452c:	00052c23          	sw	zero,24(a0)

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
ffffffffc0204530:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204532:	8526                	mv	a0,s1
ffffffffc0204534:	cf5ff0ef          	jal	ra,ffffffffc0204228 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204538:	c80d                	beqz	s0,ffffffffc020456a <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020453a:	03000513          	li	a0,48
ffffffffc020453e:	dc4fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204542:	85aa                	mv	a1,a0
ffffffffc0204544:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0204548:	f165                	bnez	a0,ffffffffc0204528 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc020454a:	00003697          	auipc	a3,0x3
ffffffffc020454e:	67e68693          	addi	a3,a3,1662 # ffffffffc0207bc8 <default_pmm_manager+0x7c0>
ffffffffc0204552:	00003617          	auipc	a2,0x3
ffffffffc0204556:	81e60613          	addi	a2,a2,-2018 # ffffffffc0206d70 <commands+0x450>
ffffffffc020455a:	11400593          	li	a1,276
ffffffffc020455e:	00004517          	auipc	a0,0x4
ffffffffc0204562:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204566:	f15fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc020456a:	03700413          	li	s0,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020456e:	1f900913          	li	s2,505
ffffffffc0204572:	a819                	j	ffffffffc0204588 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0204574:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204576:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204578:	00052c23          	sw	zero,24(a0)
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020457c:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020457e:	8526                	mv	a0,s1
ffffffffc0204580:	ca9ff0ef          	jal	ra,ffffffffc0204228 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204584:	03240a63          	beq	s0,s2,ffffffffc02045b8 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204588:	03000513          	li	a0,48
ffffffffc020458c:	d76fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204590:	85aa                	mv	a1,a0
ffffffffc0204592:	00240793          	addi	a5,s0,2
    if (vma != NULL) {
ffffffffc0204596:	fd79                	bnez	a0,ffffffffc0204574 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204598:	00003697          	auipc	a3,0x3
ffffffffc020459c:	63068693          	addi	a3,a3,1584 # ffffffffc0207bc8 <default_pmm_manager+0x7c0>
ffffffffc02045a0:	00002617          	auipc	a2,0x2
ffffffffc02045a4:	7d060613          	addi	a2,a2,2000 # ffffffffc0206d70 <commands+0x450>
ffffffffc02045a8:	11a00593          	li	a1,282
ffffffffc02045ac:	00004517          	auipc	a0,0x4
ffffffffc02045b0:	afc50513          	addi	a0,a0,-1284 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02045b4:	ec7fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc02045b8:	649c                	ld	a5,8(s1)
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));
ffffffffc02045ba:	471d                	li	a4,7
    for (i = 1; i <= step2; i ++) {
ffffffffc02045bc:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02045c0:	2cf48d63          	beq	s1,a5,ffffffffc020489a <vmm_init+0x390>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02045c4:	fe87b683          	ld	a3,-24(a5) # ffffffffffffefe8 <end+0x3fd4c45c>
ffffffffc02045c8:	ffe70613          	addi	a2,a4,-2
ffffffffc02045cc:	24d61763          	bne	a2,a3,ffffffffc020481a <vmm_init+0x310>
ffffffffc02045d0:	ff07b683          	ld	a3,-16(a5)
ffffffffc02045d4:	24d71363          	bne	a4,a3,ffffffffc020481a <vmm_init+0x310>
    for (i = 1; i <= step2; i ++) {
ffffffffc02045d8:	0715                	addi	a4,a4,5
ffffffffc02045da:	679c                	ld	a5,8(a5)
ffffffffc02045dc:	feb712e3          	bne	a4,a1,ffffffffc02045c0 <vmm_init+0xb6>
ffffffffc02045e0:	4a1d                	li	s4,7
ffffffffc02045e2:	4415                	li	s0,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02045e4:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02045e8:	85a2                	mv	a1,s0
ffffffffc02045ea:	8526                	mv	a0,s1
ffffffffc02045ec:	bfdff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
ffffffffc02045f0:	892a                	mv	s2,a0
        assert(vma1 != NULL);
ffffffffc02045f2:	30050463          	beqz	a0,ffffffffc02048fa <vmm_init+0x3f0>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02045f6:	00140593          	addi	a1,s0,1
ffffffffc02045fa:	8526                	mv	a0,s1
ffffffffc02045fc:	bedff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
ffffffffc0204600:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0204602:	2c050c63          	beqz	a0,ffffffffc02048da <vmm_init+0x3d0>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204606:	85d2                	mv	a1,s4
ffffffffc0204608:	8526                	mv	a0,s1
ffffffffc020460a:	bdfff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
        assert(vma3 == NULL);
ffffffffc020460e:	2a051663          	bnez	a0,ffffffffc02048ba <vmm_init+0x3b0>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0204612:	00340593          	addi	a1,s0,3
ffffffffc0204616:	8526                	mv	a0,s1
ffffffffc0204618:	bd1ff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
        assert(vma4 == NULL);
ffffffffc020461c:	30051f63          	bnez	a0,ffffffffc020493a <vmm_init+0x430>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204620:	00440593          	addi	a1,s0,4
ffffffffc0204624:	8526                	mv	a0,s1
ffffffffc0204626:	bc3ff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
        assert(vma5 == NULL);
ffffffffc020462a:	2e051863          	bnez	a0,ffffffffc020491a <vmm_init+0x410>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020462e:	00893783          	ld	a5,8(s2)
ffffffffc0204632:	20f41463          	bne	s0,a5,ffffffffc020483a <vmm_init+0x330>
ffffffffc0204636:	01093783          	ld	a5,16(s2)
ffffffffc020463a:	21479063          	bne	a5,s4,ffffffffc020483a <vmm_init+0x330>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020463e:	0089b783          	ld	a5,8(s3)
ffffffffc0204642:	20f41c63          	bne	s0,a5,ffffffffc020485a <vmm_init+0x350>
ffffffffc0204646:	0109b783          	ld	a5,16(s3)
ffffffffc020464a:	21479863          	bne	a5,s4,ffffffffc020485a <vmm_init+0x350>
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020464e:	0415                	addi	s0,s0,5
ffffffffc0204650:	0a15                	addi	s4,s4,5
ffffffffc0204652:	f9541be3          	bne	s0,s5,ffffffffc02045e8 <vmm_init+0xde>
ffffffffc0204656:	4411                	li	s0,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204658:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc020465a:	85a2                	mv	a1,s0
ffffffffc020465c:	8526                	mv	a0,s1
ffffffffc020465e:	b8bff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
ffffffffc0204662:	0004059b          	sext.w	a1,s0
        if (vma_below_5 != NULL ) {
ffffffffc0204666:	c90d                	beqz	a0,ffffffffc0204698 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204668:	6914                	ld	a3,16(a0)
ffffffffc020466a:	6510                	ld	a2,8(a0)
ffffffffc020466c:	00004517          	auipc	a0,0x4
ffffffffc0204670:	c0450513          	addi	a0,a0,-1020 # ffffffffc0208270 <default_pmm_manager+0xe68>
ffffffffc0204674:	b0dfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0204678:	00004697          	auipc	a3,0x4
ffffffffc020467c:	c2068693          	addi	a3,a3,-992 # ffffffffc0208298 <default_pmm_manager+0xe90>
ffffffffc0204680:	00002617          	auipc	a2,0x2
ffffffffc0204684:	6f060613          	addi	a2,a2,1776 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204688:	13c00593          	li	a1,316
ffffffffc020468c:	00004517          	auipc	a0,0x4
ffffffffc0204690:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204694:	de7fb0ef          	jal	ra,ffffffffc020047a <__panic>
    for (i =4; i>=0; i--) {
ffffffffc0204698:	147d                	addi	s0,s0,-1
ffffffffc020469a:	fd2410e3          	bne	s0,s2,ffffffffc020465a <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc020469e:	8526                	mv	a0,s1
ffffffffc02046a0:	c59ff0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02046a4:	00004517          	auipc	a0,0x4
ffffffffc02046a8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc02082b0 <default_pmm_manager+0xea8>
ffffffffc02046ac:	ad5fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02046b0:	f02fd0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc02046b4:	892a                	mv	s2,a0

    check_mm_struct = mm_create();
ffffffffc02046b6:	abdff0ef          	jal	ra,ffffffffc0204172 <mm_create>
ffffffffc02046ba:	000ae797          	auipc	a5,0xae
ffffffffc02046be:	4aa7b323          	sd	a0,1190(a5) # ffffffffc02b2b60 <check_mm_struct>
ffffffffc02046c2:	842a                	mv	s0,a0
    assert(check_mm_struct != NULL);
ffffffffc02046c4:	28050b63          	beqz	a0,ffffffffc020495a <vmm_init+0x450>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046c8:	000ae497          	auipc	s1,0xae
ffffffffc02046cc:	4584b483          	ld	s1,1112(s1) # ffffffffc02b2b20 <boot_pgdir>
    assert(pgdir[0] == 0);
ffffffffc02046d0:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02046d2:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02046d4:	2e079f63          	bnez	a5,ffffffffc02049d2 <vmm_init+0x4c8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02046d8:	03000513          	li	a0,48
ffffffffc02046dc:	c26fd0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc02046e0:	89aa                	mv	s3,a0
    if (vma != NULL) {
ffffffffc02046e2:	18050c63          	beqz	a0,ffffffffc020487a <vmm_init+0x370>
        vma->vm_end = vm_end;
ffffffffc02046e6:	002007b7          	lui	a5,0x200
ffffffffc02046ea:	00f9b823          	sd	a5,16(s3)
        vma->vm_flags = vm_flags;
ffffffffc02046ee:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02046f0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02046f2:	00f9ac23          	sw	a5,24(s3)
    insert_vma_struct(mm, vma);
ffffffffc02046f6:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02046f8:	0009b423          	sd	zero,8(s3)
    insert_vma_struct(mm, vma);
ffffffffc02046fc:	b2dff0ef          	jal	ra,ffffffffc0204228 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204700:	10000593          	li	a1,256
ffffffffc0204704:	8522                	mv	a0,s0
ffffffffc0204706:	ae3ff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
ffffffffc020470a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020470e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204712:	2ea99063          	bne	s3,a0,ffffffffc02049f2 <vmm_init+0x4e8>
        *(char *)(addr + i) = i;
ffffffffc0204716:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f4ea8>
    for (i = 0; i < 100; i ++) {
ffffffffc020471a:	0785                	addi	a5,a5,1
ffffffffc020471c:	fee79de3          	bne	a5,a4,ffffffffc0204716 <vmm_init+0x20c>
        sum += i;
ffffffffc0204720:	6705                	lui	a4,0x1
ffffffffc0204722:	10000793          	li	a5,256
ffffffffc0204726:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x888a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020472a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020472e:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i ++) {
ffffffffc0204732:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0204734:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204736:	fec79ce3          	bne	a5,a2,ffffffffc020472e <vmm_init+0x224>
    }

    assert(sum == 0);
ffffffffc020473a:	2c071e63          	bnez	a4,ffffffffc0204a16 <vmm_init+0x50c>
    return pa2page(PDE_ADDR(pde));
ffffffffc020473e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0204740:	000aea97          	auipc	s5,0xae
ffffffffc0204744:	3e8a8a93          	addi	s5,s5,1000 # ffffffffc02b2b28 <npage>
ffffffffc0204748:	000ab603          	ld	a2,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020474c:	078a                	slli	a5,a5,0x2
ffffffffc020474e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204750:	2cc7f163          	bgeu	a5,a2,ffffffffc0204a12 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204754:	00004a17          	auipc	s4,0x4
ffffffffc0204758:	61ca3a03          	ld	s4,1564(s4) # ffffffffc0208d70 <nbase>
ffffffffc020475c:	414787b3          	sub	a5,a5,s4
ffffffffc0204760:	079a                	slli	a5,a5,0x6
    return page - pages + nbase;
ffffffffc0204762:	8799                	srai	a5,a5,0x6
ffffffffc0204764:	97d2                	add	a5,a5,s4
    return KADDR(page2pa(page));
ffffffffc0204766:	00c79713          	slli	a4,a5,0xc
ffffffffc020476a:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020476c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204770:	24c77563          	bgeu	a4,a2,ffffffffc02049ba <vmm_init+0x4b0>
ffffffffc0204774:	000ae997          	auipc	s3,0xae
ffffffffc0204778:	3cc9b983          	ld	s3,972(s3) # ffffffffc02b2b40 <va_pa_offset>

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc020477c:	4581                	li	a1,0
ffffffffc020477e:	8526                	mv	a0,s1
ffffffffc0204780:	99b6                	add	s3,s3,a3
ffffffffc0204782:	c69fd0ef          	jal	ra,ffffffffc02023ea <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204786:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020478a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020478e:	078a                	slli	a5,a5,0x2
ffffffffc0204790:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204792:	28e7f063          	bgeu	a5,a4,ffffffffc0204a12 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc0204796:	000ae997          	auipc	s3,0xae
ffffffffc020479a:	39a98993          	addi	s3,s3,922 # ffffffffc02b2b30 <pages>
ffffffffc020479e:	0009b503          	ld	a0,0(s3)
ffffffffc02047a2:	414787b3          	sub	a5,a5,s4
ffffffffc02047a6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02047a8:	953e                	add	a0,a0,a5
ffffffffc02047aa:	4585                	li	a1,1
ffffffffc02047ac:	dc6fd0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02047b0:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02047b2:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02047b6:	078a                	slli	a5,a5,0x2
ffffffffc02047b8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02047ba:	24e7fc63          	bgeu	a5,a4,ffffffffc0204a12 <vmm_init+0x508>
    return &pages[PPN(pa) - nbase];
ffffffffc02047be:	0009b503          	ld	a0,0(s3)
ffffffffc02047c2:	414787b3          	sub	a5,a5,s4
ffffffffc02047c6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02047c8:	4585                	li	a1,1
ffffffffc02047ca:	953e                	add	a0,a0,a5
ffffffffc02047cc:	da6fd0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    pgdir[0] = 0;
ffffffffc02047d0:	0004b023          	sd	zero,0(s1)
  asm volatile("sfence.vma");
ffffffffc02047d4:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02047d8:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02047da:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02047de:	b1bff0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02047e2:	000ae797          	auipc	a5,0xae
ffffffffc02047e6:	3607bf23          	sd	zero,894(a5) # ffffffffc02b2b60 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02047ea:	dc8fd0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
ffffffffc02047ee:	1aa91663          	bne	s2,a0,ffffffffc020499a <vmm_init+0x490>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02047f2:	00004517          	auipc	a0,0x4
ffffffffc02047f6:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0208340 <default_pmm_manager+0xf38>
ffffffffc02047fa:	987fb0ef          	jal	ra,ffffffffc0200180 <cprintf>
}
ffffffffc02047fe:	7442                	ld	s0,48(sp)
ffffffffc0204800:	70e2                	ld	ra,56(sp)
ffffffffc0204802:	74a2                	ld	s1,40(sp)
ffffffffc0204804:	7902                	ld	s2,32(sp)
ffffffffc0204806:	69e2                	ld	s3,24(sp)
ffffffffc0204808:	6a42                	ld	s4,16(sp)
ffffffffc020480a:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020480c:	00004517          	auipc	a0,0x4
ffffffffc0204810:	b5450513          	addi	a0,a0,-1196 # ffffffffc0208360 <default_pmm_manager+0xf58>
}
ffffffffc0204814:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204816:	96bfb06f          	j	ffffffffc0200180 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020481a:	00004697          	auipc	a3,0x4
ffffffffc020481e:	96e68693          	addi	a3,a3,-1682 # ffffffffc0208188 <default_pmm_manager+0xd80>
ffffffffc0204822:	00002617          	auipc	a2,0x2
ffffffffc0204826:	54e60613          	addi	a2,a2,1358 # ffffffffc0206d70 <commands+0x450>
ffffffffc020482a:	12300593          	li	a1,291
ffffffffc020482e:	00004517          	auipc	a0,0x4
ffffffffc0204832:	87a50513          	addi	a0,a0,-1926 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204836:	c45fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020483a:	00004697          	auipc	a3,0x4
ffffffffc020483e:	9d668693          	addi	a3,a3,-1578 # ffffffffc0208210 <default_pmm_manager+0xe08>
ffffffffc0204842:	00002617          	auipc	a2,0x2
ffffffffc0204846:	52e60613          	addi	a2,a2,1326 # ffffffffc0206d70 <commands+0x450>
ffffffffc020484a:	13300593          	li	a1,307
ffffffffc020484e:	00004517          	auipc	a0,0x4
ffffffffc0204852:	85a50513          	addi	a0,a0,-1958 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204856:	c25fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020485a:	00004697          	auipc	a3,0x4
ffffffffc020485e:	9e668693          	addi	a3,a3,-1562 # ffffffffc0208240 <default_pmm_manager+0xe38>
ffffffffc0204862:	00002617          	auipc	a2,0x2
ffffffffc0204866:	50e60613          	addi	a2,a2,1294 # ffffffffc0206d70 <commands+0x450>
ffffffffc020486a:	13400593          	li	a1,308
ffffffffc020486e:	00004517          	auipc	a0,0x4
ffffffffc0204872:	83a50513          	addi	a0,a0,-1990 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204876:	c05fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(vma != NULL);
ffffffffc020487a:	00003697          	auipc	a3,0x3
ffffffffc020487e:	34e68693          	addi	a3,a3,846 # ffffffffc0207bc8 <default_pmm_manager+0x7c0>
ffffffffc0204882:	00002617          	auipc	a2,0x2
ffffffffc0204886:	4ee60613          	addi	a2,a2,1262 # ffffffffc0206d70 <commands+0x450>
ffffffffc020488a:	15300593          	li	a1,339
ffffffffc020488e:	00004517          	auipc	a0,0x4
ffffffffc0204892:	81a50513          	addi	a0,a0,-2022 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204896:	be5fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020489a:	00004697          	auipc	a3,0x4
ffffffffc020489e:	8d668693          	addi	a3,a3,-1834 # ffffffffc0208170 <default_pmm_manager+0xd68>
ffffffffc02048a2:	00002617          	auipc	a2,0x2
ffffffffc02048a6:	4ce60613          	addi	a2,a2,1230 # ffffffffc0206d70 <commands+0x450>
ffffffffc02048aa:	12100593          	li	a1,289
ffffffffc02048ae:	00003517          	auipc	a0,0x3
ffffffffc02048b2:	7fa50513          	addi	a0,a0,2042 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02048b6:	bc5fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma3 == NULL);
ffffffffc02048ba:	00004697          	auipc	a3,0x4
ffffffffc02048be:	92668693          	addi	a3,a3,-1754 # ffffffffc02081e0 <default_pmm_manager+0xdd8>
ffffffffc02048c2:	00002617          	auipc	a2,0x2
ffffffffc02048c6:	4ae60613          	addi	a2,a2,1198 # ffffffffc0206d70 <commands+0x450>
ffffffffc02048ca:	12d00593          	li	a1,301
ffffffffc02048ce:	00003517          	auipc	a0,0x3
ffffffffc02048d2:	7da50513          	addi	a0,a0,2010 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02048d6:	ba5fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma2 != NULL);
ffffffffc02048da:	00004697          	auipc	a3,0x4
ffffffffc02048de:	8f668693          	addi	a3,a3,-1802 # ffffffffc02081d0 <default_pmm_manager+0xdc8>
ffffffffc02048e2:	00002617          	auipc	a2,0x2
ffffffffc02048e6:	48e60613          	addi	a2,a2,1166 # ffffffffc0206d70 <commands+0x450>
ffffffffc02048ea:	12b00593          	li	a1,299
ffffffffc02048ee:	00003517          	auipc	a0,0x3
ffffffffc02048f2:	7ba50513          	addi	a0,a0,1978 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02048f6:	b85fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma1 != NULL);
ffffffffc02048fa:	00004697          	auipc	a3,0x4
ffffffffc02048fe:	8c668693          	addi	a3,a3,-1850 # ffffffffc02081c0 <default_pmm_manager+0xdb8>
ffffffffc0204902:	00002617          	auipc	a2,0x2
ffffffffc0204906:	46e60613          	addi	a2,a2,1134 # ffffffffc0206d70 <commands+0x450>
ffffffffc020490a:	12900593          	li	a1,297
ffffffffc020490e:	00003517          	auipc	a0,0x3
ffffffffc0204912:	79a50513          	addi	a0,a0,1946 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204916:	b65fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma5 == NULL);
ffffffffc020491a:	00004697          	auipc	a3,0x4
ffffffffc020491e:	8e668693          	addi	a3,a3,-1818 # ffffffffc0208200 <default_pmm_manager+0xdf8>
ffffffffc0204922:	00002617          	auipc	a2,0x2
ffffffffc0204926:	44e60613          	addi	a2,a2,1102 # ffffffffc0206d70 <commands+0x450>
ffffffffc020492a:	13100593          	li	a1,305
ffffffffc020492e:	00003517          	auipc	a0,0x3
ffffffffc0204932:	77a50513          	addi	a0,a0,1914 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204936:	b45fb0ef          	jal	ra,ffffffffc020047a <__panic>
        assert(vma4 == NULL);
ffffffffc020493a:	00004697          	auipc	a3,0x4
ffffffffc020493e:	8b668693          	addi	a3,a3,-1866 # ffffffffc02081f0 <default_pmm_manager+0xde8>
ffffffffc0204942:	00002617          	auipc	a2,0x2
ffffffffc0204946:	42e60613          	addi	a2,a2,1070 # ffffffffc0206d70 <commands+0x450>
ffffffffc020494a:	12f00593          	li	a1,303
ffffffffc020494e:	00003517          	auipc	a0,0x3
ffffffffc0204952:	75a50513          	addi	a0,a0,1882 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204956:	b25fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020495a:	00004697          	auipc	a3,0x4
ffffffffc020495e:	97668693          	addi	a3,a3,-1674 # ffffffffc02082d0 <default_pmm_manager+0xec8>
ffffffffc0204962:	00002617          	auipc	a2,0x2
ffffffffc0204966:	40e60613          	addi	a2,a2,1038 # ffffffffc0206d70 <commands+0x450>
ffffffffc020496a:	14c00593          	li	a1,332
ffffffffc020496e:	00003517          	auipc	a0,0x3
ffffffffc0204972:	73a50513          	addi	a0,a0,1850 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204976:	b05fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(mm != NULL);
ffffffffc020497a:	00003697          	auipc	a3,0x3
ffffffffc020497e:	21668693          	addi	a3,a3,534 # ffffffffc0207b90 <default_pmm_manager+0x788>
ffffffffc0204982:	00002617          	auipc	a2,0x2
ffffffffc0204986:	3ee60613          	addi	a2,a2,1006 # ffffffffc0206d70 <commands+0x450>
ffffffffc020498a:	10d00593          	li	a1,269
ffffffffc020498e:	00003517          	auipc	a0,0x3
ffffffffc0204992:	71a50513          	addi	a0,a0,1818 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204996:	ae5fb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020499a:	00004697          	auipc	a3,0x4
ffffffffc020499e:	97e68693          	addi	a3,a3,-1666 # ffffffffc0208318 <default_pmm_manager+0xf10>
ffffffffc02049a2:	00002617          	auipc	a2,0x2
ffffffffc02049a6:	3ce60613          	addi	a2,a2,974 # ffffffffc0206d70 <commands+0x450>
ffffffffc02049aa:	17100593          	li	a1,369
ffffffffc02049ae:	00003517          	auipc	a0,0x3
ffffffffc02049b2:	6fa50513          	addi	a0,a0,1786 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02049b6:	ac5fb0ef          	jal	ra,ffffffffc020047a <__panic>
    return KADDR(page2pa(page));
ffffffffc02049ba:	00003617          	auipc	a2,0x3
ffffffffc02049be:	a8660613          	addi	a2,a2,-1402 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc02049c2:	06900593          	li	a1,105
ffffffffc02049c6:	00003517          	auipc	a0,0x3
ffffffffc02049ca:	aa250513          	addi	a0,a0,-1374 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc02049ce:	aadfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir[0] == 0);
ffffffffc02049d2:	00003697          	auipc	a3,0x3
ffffffffc02049d6:	1e668693          	addi	a3,a3,486 # ffffffffc0207bb8 <default_pmm_manager+0x7b0>
ffffffffc02049da:	00002617          	auipc	a2,0x2
ffffffffc02049de:	39660613          	addi	a2,a2,918 # ffffffffc0206d70 <commands+0x450>
ffffffffc02049e2:	15000593          	li	a1,336
ffffffffc02049e6:	00003517          	auipc	a0,0x3
ffffffffc02049ea:	6c250513          	addi	a0,a0,1730 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc02049ee:	a8dfb0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02049f2:	00004697          	auipc	a3,0x4
ffffffffc02049f6:	8f668693          	addi	a3,a3,-1802 # ffffffffc02082e8 <default_pmm_manager+0xee0>
ffffffffc02049fa:	00002617          	auipc	a2,0x2
ffffffffc02049fe:	37660613          	addi	a2,a2,886 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204a02:	15800593          	li	a1,344
ffffffffc0204a06:	00003517          	auipc	a0,0x3
ffffffffc0204a0a:	6a250513          	addi	a0,a0,1698 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204a0e:	a6dfb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204a12:	f44ff0ef          	jal	ra,ffffffffc0204156 <pa2page.part.0>
    assert(sum == 0);
ffffffffc0204a16:	00004697          	auipc	a3,0x4
ffffffffc0204a1a:	8f268693          	addi	a3,a3,-1806 # ffffffffc0208308 <default_pmm_manager+0xf00>
ffffffffc0204a1e:	00002617          	auipc	a2,0x2
ffffffffc0204a22:	35260613          	addi	a2,a2,850 # ffffffffc0206d70 <commands+0x450>
ffffffffc0204a26:	16400593          	li	a1,356
ffffffffc0204a2a:	00003517          	auipc	a0,0x3
ffffffffc0204a2e:	67e50513          	addi	a0,a0,1662 # ffffffffc02080a8 <default_pmm_manager+0xca0>
ffffffffc0204a32:	a49fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204a36 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a36:	715d                	addi	sp,sp,-80
ffffffffc0204a38:	f84a                	sd	s2,48(sp)
ffffffffc0204a3a:	892e                	mv	s2,a1
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a3c:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204a3e:	e0a2                	sd	s0,64(sp)
ffffffffc0204a40:	fc26                	sd	s1,56(sp)
ffffffffc0204a42:	e486                	sd	ra,72(sp)
ffffffffc0204a44:	f44e                	sd	s3,40(sp)
ffffffffc0204a46:	f052                	sd	s4,32(sp)
ffffffffc0204a48:	ec56                	sd	s5,24(sp)
ffffffffc0204a4a:	8432                	mv	s0,a2
ffffffffc0204a4c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204a4e:	f9aff0ef          	jal	ra,ffffffffc02041e8 <find_vma>

    pgfault_num++;
ffffffffc0204a52:	000ae797          	auipc	a5,0xae
ffffffffc0204a56:	1167a783          	lw	a5,278(a5) # ffffffffc02b2b68 <pgfault_num>
ffffffffc0204a5a:	2785                	addiw	a5,a5,1
ffffffffc0204a5c:	000ae717          	auipc	a4,0xae
ffffffffc0204a60:	10f72623          	sw	a5,268(a4) # ffffffffc02b2b68 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204a64:	12050363          	beqz	a0,ffffffffc0204b8a <do_pgfault+0x154>
ffffffffc0204a68:	651c                	ld	a5,8(a0)
ffffffffc0204a6a:	12f46063          	bltu	s0,a5,ffffffffc0204b8a <do_pgfault+0x154>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a6e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204a70:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204a72:	8b89                	andi	a5,a5,2
ffffffffc0204a74:	e3bd                	bnez	a5,ffffffffc0204ada <do_pgfault+0xa4>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a76:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a78:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204a7a:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204a7c:	85a2                	mv	a1,s0
ffffffffc0204a7e:	4605                	li	a2,1
ffffffffc0204a80:	b6cfd0ef          	jal	ra,ffffffffc0201dec <get_pte>
ffffffffc0204a84:	12050463          	beqz	a0,ffffffffc0204bac <do_pgfault+0x176>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204a88:	610c                	ld	a1,0(a0)
ffffffffc0204a8a:	c1e5                	beqz	a1,ffffffffc0204b6a <do_pgfault+0x134>
            goto failed;
        }
    } 

    // 添加cow处理代码
    else if ((*ptep & PTE_V) && (error_code & 3 == 3)) {
ffffffffc0204a8c:	0015f793          	andi	a5,a1,1
ffffffffc0204a90:	e7b9                	bnez	a5,ffffffffc0204ade <do_pgfault+0xa8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204a92:	000ae797          	auipc	a5,0xae
ffffffffc0204a96:	0c67a783          	lw	a5,198(a5) # ffffffffc02b2b58 <swap_init_ok>
ffffffffc0204a9a:	10078163          	beqz	a5,ffffffffc0204b9c <do_pgfault+0x166>
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm, addr, &page); 
ffffffffc0204a9e:	85a2                	mv	a1,s0
ffffffffc0204aa0:	0030                	addi	a2,sp,8
ffffffffc0204aa2:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204aa4:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page); 
ffffffffc0204aa6:	a24ff0ef          	jal	ra,ffffffffc0203cca <swap_in>

            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir, page, addr, perm); //更新页表，插入新的页表项
ffffffffc0204aaa:	65a2                	ld	a1,8(sp)
ffffffffc0204aac:	6c88                	ld	a0,24(s1)
ffffffffc0204aae:	86ce                	mv	a3,s3
ffffffffc0204ab0:	8622                	mv	a2,s0
ffffffffc0204ab2:	9d5fd0ef          	jal	ra,ffffffffc0202486 <page_insert>

            //(3) make the page swappable.
            swap_map_swappable(mm, addr, page, 1); //标记这个页面将来是可以再换出的
ffffffffc0204ab6:	6622                	ld	a2,8(sp)
ffffffffc0204ab8:	4685                	li	a3,1
ffffffffc0204aba:	85a2                	mv	a1,s0
ffffffffc0204abc:	8526                	mv	a0,s1
ffffffffc0204abe:	8ecff0ef          	jal	ra,ffffffffc0203baa <swap_map_swappable>
            
            page->pra_vaddr = addr;
ffffffffc0204ac2:	67a2                	ld	a5,8(sp)
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0204ac4:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0204ac6:	ff80                	sd	s0,56(a5)
failed:
    return ret;
}
ffffffffc0204ac8:	60a6                	ld	ra,72(sp)
ffffffffc0204aca:	6406                	ld	s0,64(sp)
ffffffffc0204acc:	74e2                	ld	s1,56(sp)
ffffffffc0204ace:	7942                	ld	s2,48(sp)
ffffffffc0204ad0:	79a2                	ld	s3,40(sp)
ffffffffc0204ad2:	7a02                	ld	s4,32(sp)
ffffffffc0204ad4:	6ae2                	ld	s5,24(sp)
ffffffffc0204ad6:	6161                	addi	sp,sp,80
ffffffffc0204ad8:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204ada:	49dd                	li	s3,23
ffffffffc0204adc:	bf69                	j	ffffffffc0204a76 <do_pgfault+0x40>
    else if ((*ptep & PTE_V) && (error_code & 3 == 3)) {
ffffffffc0204ade:	00197913          	andi	s2,s2,1
ffffffffc0204ae2:	fa0908e3          	beqz	s2,ffffffffc0204a92 <do_pgfault+0x5c>
    if (PPN(pa) >= npage) {
ffffffffc0204ae6:	000aea17          	auipc	s4,0xae
ffffffffc0204aea:	042a0a13          	addi	s4,s4,66 # ffffffffc02b2b28 <npage>
ffffffffc0204aee:	000a3783          	ld	a5,0(s4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0204af2:	058a                	slli	a1,a1,0x2
ffffffffc0204af4:	81b1                	srli	a1,a1,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204af6:	0ef5f063          	bgeu	a1,a5,ffffffffc0204bd6 <do_pgfault+0x1a0>
    return &pages[PPN(pa) - nbase];
ffffffffc0204afa:	000aea97          	auipc	s5,0xae
ffffffffc0204afe:	036a8a93          	addi	s5,s5,54 # ffffffffc02b2b30 <pages>
ffffffffc0204b02:	000ab683          	ld	a3,0(s5)
ffffffffc0204b06:	00004917          	auipc	s2,0x4
ffffffffc0204b0a:	26a93903          	ld	s2,618(s2) # ffffffffc0208d70 <nbase>
        struct Page *npage = pgdir_alloc_page(mm->pgdir, addr, perm);
ffffffffc0204b0e:	6c88                	ld	a0,24(s1)
ffffffffc0204b10:	412585b3          	sub	a1,a1,s2
ffffffffc0204b14:	00659793          	slli	a5,a1,0x6
ffffffffc0204b18:	864e                	mv	a2,s3
ffffffffc0204b1a:	85a2                	mv	a1,s0
ffffffffc0204b1c:	00f68433          	add	s0,a3,a5
ffffffffc0204b20:	863fe0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
    return page - pages + nbase;
ffffffffc0204b24:	000ab783          	ld	a5,0(s5)
    return KADDR(page2pa(page));
ffffffffc0204b28:	577d                	li	a4,-1
ffffffffc0204b2a:	000a3603          	ld	a2,0(s4)
    return page - pages + nbase;
ffffffffc0204b2e:	40f406b3          	sub	a3,s0,a5
ffffffffc0204b32:	8699                	srai	a3,a3,0x6
ffffffffc0204b34:	96ca                	add	a3,a3,s2
    return KADDR(page2pa(page));
ffffffffc0204b36:	8331                	srli	a4,a4,0xc
ffffffffc0204b38:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b3c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b3e:	08c5f063          	bgeu	a1,a2,ffffffffc0204bbe <do_pgfault+0x188>
    return page - pages + nbase;
ffffffffc0204b42:	40f507b3          	sub	a5,a0,a5
ffffffffc0204b46:	8799                	srai	a5,a5,0x6
ffffffffc0204b48:	97ca                	add	a5,a5,s2
    return KADDR(page2pa(page));
ffffffffc0204b4a:	000ae517          	auipc	a0,0xae
ffffffffc0204b4e:	ff653503          	ld	a0,-10(a0) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0204b52:	8f7d                	and	a4,a4,a5
ffffffffc0204b54:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b58:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0204b5a:	06c77163          	bgeu	a4,a2,ffffffffc0204bbc <do_pgfault+0x186>
        memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc0204b5e:	6605                	lui	a2,0x1
ffffffffc0204b60:	953e                	add	a0,a0,a5
ffffffffc0204b62:	33f010ef          	jal	ra,ffffffffc02066a0 <memcpy>
   ret = 0;
ffffffffc0204b66:	4501                	li	a0,0
    else if ((*ptep & PTE_V) && (error_code & 3 == 3)) {
ffffffffc0204b68:	b785                	j	ffffffffc0204ac8 <do_pgfault+0x92>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b6a:	6c88                	ld	a0,24(s1)
ffffffffc0204b6c:	864e                	mv	a2,s3
ffffffffc0204b6e:	85a2                	mv	a1,s0
ffffffffc0204b70:	813fe0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc0204b74:	87aa                	mv	a5,a0
   ret = 0;
ffffffffc0204b76:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204b78:	fba1                	bnez	a5,ffffffffc0204ac8 <do_pgfault+0x92>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204b7a:	00004517          	auipc	a0,0x4
ffffffffc0204b7e:	84e50513          	addi	a0,a0,-1970 # ffffffffc02083c8 <default_pmm_manager+0xfc0>
ffffffffc0204b82:	dfefb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204b86:	5571                	li	a0,-4
            goto failed;
ffffffffc0204b88:	b781                	j	ffffffffc0204ac8 <do_pgfault+0x92>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204b8a:	85a2                	mv	a1,s0
ffffffffc0204b8c:	00003517          	auipc	a0,0x3
ffffffffc0204b90:	7ec50513          	addi	a0,a0,2028 # ffffffffc0208378 <default_pmm_manager+0xf70>
ffffffffc0204b94:	decfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204b98:	5575                	li	a0,-3
        goto failed;
ffffffffc0204b9a:	b73d                	j	ffffffffc0204ac8 <do_pgfault+0x92>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204b9c:	00004517          	auipc	a0,0x4
ffffffffc0204ba0:	85450513          	addi	a0,a0,-1964 # ffffffffc02083f0 <default_pmm_manager+0xfe8>
ffffffffc0204ba4:	ddcfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204ba8:	5571                	li	a0,-4
            goto failed;
ffffffffc0204baa:	bf39                	j	ffffffffc0204ac8 <do_pgfault+0x92>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204bac:	00003517          	auipc	a0,0x3
ffffffffc0204bb0:	7fc50513          	addi	a0,a0,2044 # ffffffffc02083a8 <default_pmm_manager+0xfa0>
ffffffffc0204bb4:	dccfb0ef          	jal	ra,ffffffffc0200180 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204bb8:	5571                	li	a0,-4
        goto failed;
ffffffffc0204bba:	b739                	j	ffffffffc0204ac8 <do_pgfault+0x92>
ffffffffc0204bbc:	86be                	mv	a3,a5
ffffffffc0204bbe:	00003617          	auipc	a2,0x3
ffffffffc0204bc2:	88260613          	addi	a2,a2,-1918 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0204bc6:	06900593          	li	a1,105
ffffffffc0204bca:	00003517          	auipc	a0,0x3
ffffffffc0204bce:	89e50513          	addi	a0,a0,-1890 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0204bd2:	8a9fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204bd6:	d80ff0ef          	jal	ra,ffffffffc0204156 <pa2page.part.0>

ffffffffc0204bda <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204bda:	7179                	addi	sp,sp,-48
ffffffffc0204bdc:	f022                	sd	s0,32(sp)
ffffffffc0204bde:	f406                	sd	ra,40(sp)
ffffffffc0204be0:	ec26                	sd	s1,24(sp)
ffffffffc0204be2:	e84a                	sd	s2,16(sp)
ffffffffc0204be4:	e44e                	sd	s3,8(sp)
ffffffffc0204be6:	e052                	sd	s4,0(sp)
ffffffffc0204be8:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204bea:	c135                	beqz	a0,ffffffffc0204c4e <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204bec:	002007b7          	lui	a5,0x200
ffffffffc0204bf0:	04f5e663          	bltu	a1,a5,ffffffffc0204c3c <user_mem_check+0x62>
ffffffffc0204bf4:	00c584b3          	add	s1,a1,a2
ffffffffc0204bf8:	0495f263          	bgeu	a1,s1,ffffffffc0204c3c <user_mem_check+0x62>
ffffffffc0204bfc:	4785                	li	a5,1
ffffffffc0204bfe:	07fe                	slli	a5,a5,0x1f
ffffffffc0204c00:	0297ee63          	bltu	a5,s1,ffffffffc0204c3c <user_mem_check+0x62>
ffffffffc0204c04:	892a                	mv	s2,a0
ffffffffc0204c06:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c08:	6a05                	lui	s4,0x1
ffffffffc0204c0a:	a821                	j	ffffffffc0204c22 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c0c:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c10:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204c12:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c14:	c685                	beqz	a3,ffffffffc0204c3c <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204c16:	c399                	beqz	a5,ffffffffc0204c1c <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204c18:	02e46263          	bltu	s0,a4,ffffffffc0204c3c <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204c1c:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204c1e:	04947663          	bgeu	s0,s1,ffffffffc0204c6a <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204c22:	85a2                	mv	a1,s0
ffffffffc0204c24:	854a                	mv	a0,s2
ffffffffc0204c26:	dc2ff0ef          	jal	ra,ffffffffc02041e8 <find_vma>
ffffffffc0204c2a:	c909                	beqz	a0,ffffffffc0204c3c <user_mem_check+0x62>
ffffffffc0204c2c:	6518                	ld	a4,8(a0)
ffffffffc0204c2e:	00e46763          	bltu	s0,a4,ffffffffc0204c3c <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204c32:	4d1c                	lw	a5,24(a0)
ffffffffc0204c34:	fc099ce3          	bnez	s3,ffffffffc0204c0c <user_mem_check+0x32>
ffffffffc0204c38:	8b85                	andi	a5,a5,1
ffffffffc0204c3a:	f3ed                	bnez	a5,ffffffffc0204c1c <user_mem_check+0x42>
            return 0;
ffffffffc0204c3c:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204c3e:	70a2                	ld	ra,40(sp)
ffffffffc0204c40:	7402                	ld	s0,32(sp)
ffffffffc0204c42:	64e2                	ld	s1,24(sp)
ffffffffc0204c44:	6942                	ld	s2,16(sp)
ffffffffc0204c46:	69a2                	ld	s3,8(sp)
ffffffffc0204c48:	6a02                	ld	s4,0(sp)
ffffffffc0204c4a:	6145                	addi	sp,sp,48
ffffffffc0204c4c:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204c4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c52:	4501                	li	a0,0
ffffffffc0204c54:	fef5e5e3          	bltu	a1,a5,ffffffffc0204c3e <user_mem_check+0x64>
ffffffffc0204c58:	962e                	add	a2,a2,a1
ffffffffc0204c5a:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204c3e <user_mem_check+0x64>
ffffffffc0204c5e:	c8000537          	lui	a0,0xc8000
ffffffffc0204c62:	0505                	addi	a0,a0,1
ffffffffc0204c64:	00a63533          	sltu	a0,a2,a0
ffffffffc0204c68:	bfd9                	j	ffffffffc0204c3e <user_mem_check+0x64>
        return 1;
ffffffffc0204c6a:	4505                	li	a0,1
ffffffffc0204c6c:	bfc9                	j	ffffffffc0204c3e <user_mem_check+0x64>

ffffffffc0204c6e <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204c6e:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c70:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204c72:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204c74:	979fb0ef          	jal	ra,ffffffffc02005ec <ide_device_valid>
ffffffffc0204c78:	cd01                	beqz	a0,ffffffffc0204c90 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204c7a:	4505                	li	a0,1
ffffffffc0204c7c:	977fb0ef          	jal	ra,ffffffffc02005f2 <ide_device_size>
}
ffffffffc0204c80:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204c82:	810d                	srli	a0,a0,0x3
ffffffffc0204c84:	000ae797          	auipc	a5,0xae
ffffffffc0204c88:	eca7b223          	sd	a0,-316(a5) # ffffffffc02b2b48 <max_swap_offset>
}
ffffffffc0204c8c:	0141                	addi	sp,sp,16
ffffffffc0204c8e:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204c90:	00003617          	auipc	a2,0x3
ffffffffc0204c94:	78860613          	addi	a2,a2,1928 # ffffffffc0208418 <default_pmm_manager+0x1010>
ffffffffc0204c98:	45b5                	li	a1,13
ffffffffc0204c9a:	00003517          	auipc	a0,0x3
ffffffffc0204c9e:	79e50513          	addi	a0,a0,1950 # ffffffffc0208438 <default_pmm_manager+0x1030>
ffffffffc0204ca2:	fd8fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204ca6 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204ca6:	1141                	addi	sp,sp,-16
ffffffffc0204ca8:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204caa:	00855793          	srli	a5,a0,0x8
ffffffffc0204cae:	cbb1                	beqz	a5,ffffffffc0204d02 <swapfs_read+0x5c>
ffffffffc0204cb0:	000ae717          	auipc	a4,0xae
ffffffffc0204cb4:	e9873703          	ld	a4,-360(a4) # ffffffffc02b2b48 <max_swap_offset>
ffffffffc0204cb8:	04e7f563          	bgeu	a5,a4,ffffffffc0204d02 <swapfs_read+0x5c>
    return page - pages + nbase;
ffffffffc0204cbc:	000ae617          	auipc	a2,0xae
ffffffffc0204cc0:	e7463603          	ld	a2,-396(a2) # ffffffffc02b2b30 <pages>
ffffffffc0204cc4:	8d91                	sub	a1,a1,a2
ffffffffc0204cc6:	4065d613          	srai	a2,a1,0x6
ffffffffc0204cca:	00004717          	auipc	a4,0x4
ffffffffc0204cce:	0a673703          	ld	a4,166(a4) # ffffffffc0208d70 <nbase>
ffffffffc0204cd2:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204cd4:	00c61713          	slli	a4,a2,0xc
ffffffffc0204cd8:	8331                	srli	a4,a4,0xc
ffffffffc0204cda:	000ae697          	auipc	a3,0xae
ffffffffc0204cde:	e4e6b683          	ld	a3,-434(a3) # ffffffffc02b2b28 <npage>
ffffffffc0204ce2:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ce6:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204ce8:	02d77963          	bgeu	a4,a3,ffffffffc0204d1a <swapfs_read+0x74>
}
ffffffffc0204cec:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cee:	000ae797          	auipc	a5,0xae
ffffffffc0204cf2:	e527b783          	ld	a5,-430(a5) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0204cf6:	46a1                	li	a3,8
ffffffffc0204cf8:	963e                	add	a2,a2,a5
ffffffffc0204cfa:	4505                	li	a0,1
}
ffffffffc0204cfc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204cfe:	8fbfb06f          	j	ffffffffc02005f8 <ide_read_secs>
ffffffffc0204d02:	86aa                	mv	a3,a0
ffffffffc0204d04:	00003617          	auipc	a2,0x3
ffffffffc0204d08:	74c60613          	addi	a2,a2,1868 # ffffffffc0208450 <default_pmm_manager+0x1048>
ffffffffc0204d0c:	45d1                	li	a1,20
ffffffffc0204d0e:	00003517          	auipc	a0,0x3
ffffffffc0204d12:	72a50513          	addi	a0,a0,1834 # ffffffffc0208438 <default_pmm_manager+0x1030>
ffffffffc0204d16:	f64fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204d1a:	86b2                	mv	a3,a2
ffffffffc0204d1c:	06900593          	li	a1,105
ffffffffc0204d20:	00002617          	auipc	a2,0x2
ffffffffc0204d24:	72060613          	addi	a2,a2,1824 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0204d28:	00002517          	auipc	a0,0x2
ffffffffc0204d2c:	74050513          	addi	a0,a0,1856 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0204d30:	f4afb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204d34 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204d34:	1141                	addi	sp,sp,-16
ffffffffc0204d36:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d38:	00855793          	srli	a5,a0,0x8
ffffffffc0204d3c:	cbb1                	beqz	a5,ffffffffc0204d90 <swapfs_write+0x5c>
ffffffffc0204d3e:	000ae717          	auipc	a4,0xae
ffffffffc0204d42:	e0a73703          	ld	a4,-502(a4) # ffffffffc02b2b48 <max_swap_offset>
ffffffffc0204d46:	04e7f563          	bgeu	a5,a4,ffffffffc0204d90 <swapfs_write+0x5c>
    return page - pages + nbase;
ffffffffc0204d4a:	000ae617          	auipc	a2,0xae
ffffffffc0204d4e:	de663603          	ld	a2,-538(a2) # ffffffffc02b2b30 <pages>
ffffffffc0204d52:	8d91                	sub	a1,a1,a2
ffffffffc0204d54:	4065d613          	srai	a2,a1,0x6
ffffffffc0204d58:	00004717          	auipc	a4,0x4
ffffffffc0204d5c:	01873703          	ld	a4,24(a4) # ffffffffc0208d70 <nbase>
ffffffffc0204d60:	963a                	add	a2,a2,a4
    return KADDR(page2pa(page));
ffffffffc0204d62:	00c61713          	slli	a4,a2,0xc
ffffffffc0204d66:	8331                	srli	a4,a4,0xc
ffffffffc0204d68:	000ae697          	auipc	a3,0xae
ffffffffc0204d6c:	dc06b683          	ld	a3,-576(a3) # ffffffffc02b2b28 <npage>
ffffffffc0204d70:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d74:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204d76:	02d77963          	bgeu	a4,a3,ffffffffc0204da8 <swapfs_write+0x74>
}
ffffffffc0204d7a:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d7c:	000ae797          	auipc	a5,0xae
ffffffffc0204d80:	dc47b783          	ld	a5,-572(a5) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0204d84:	46a1                	li	a3,8
ffffffffc0204d86:	963e                	add	a2,a2,a5
ffffffffc0204d88:	4505                	li	a0,1
}
ffffffffc0204d8a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204d8c:	891fb06f          	j	ffffffffc020061c <ide_write_secs>
ffffffffc0204d90:	86aa                	mv	a3,a0
ffffffffc0204d92:	00003617          	auipc	a2,0x3
ffffffffc0204d96:	6be60613          	addi	a2,a2,1726 # ffffffffc0208450 <default_pmm_manager+0x1048>
ffffffffc0204d9a:	45e5                	li	a1,25
ffffffffc0204d9c:	00003517          	auipc	a0,0x3
ffffffffc0204da0:	69c50513          	addi	a0,a0,1692 # ffffffffc0208438 <default_pmm_manager+0x1030>
ffffffffc0204da4:	ed6fb0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0204da8:	86b2                	mv	a3,a2
ffffffffc0204daa:	06900593          	li	a1,105
ffffffffc0204dae:	00002617          	auipc	a2,0x2
ffffffffc0204db2:	69260613          	addi	a2,a2,1682 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0204db6:	00002517          	auipc	a0,0x2
ffffffffc0204dba:	6b250513          	addi	a0,a0,1714 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0204dbe:	ebcfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204dc2 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204dc2:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204dc4:	9402                	jalr	s0

	jal do_exit
ffffffffc0204dc6:	622000ef          	jal	ra,ffffffffc02053e8 <do_exit>

ffffffffc0204dca <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204dca:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204dcc:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204dd0:	e022                	sd	s0,0(sp)
ffffffffc0204dd2:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204dd4:	d2ffc0ef          	jal	ra,ffffffffc0201b02 <kmalloc>
ffffffffc0204dd8:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204dda:	c12d                	beqz	a0,ffffffffc0204e3c <alloc_proc+0x72>
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
        memset(proc, 0, sizeof(struct proc_struct));//初始化proc_struct结构体
ffffffffc0204ddc:	10800613          	li	a2,264
ffffffffc0204de0:	4581                	li	a1,0
ffffffffc0204de2:	0ad010ef          	jal	ra,ffffffffc020668e <memset>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204de6:	57fd                	li	a5,-1
ffffffffc0204de8:	1782                	slli	a5,a5,0x20
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204dea:	07000613          	li	a2,112
ffffffffc0204dee:	4581                	li	a1,0
        proc->state = PROC_UNINIT;
ffffffffc0204df0:	e01c                	sd	a5,0(s0)
        proc->runs = 0;
ffffffffc0204df2:	00042423          	sw	zero,8(s0)
        proc->kstack = 0;
ffffffffc0204df6:	00043823          	sd	zero,16(s0)
        proc->need_resched = 0;
ffffffffc0204dfa:	00043c23          	sd	zero,24(s0)
        proc->parent = NULL;
ffffffffc0204dfe:	02043023          	sd	zero,32(s0)
        proc->mm = NULL;
ffffffffc0204e02:	02043423          	sd	zero,40(s0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204e06:	03040513          	addi	a0,s0,48
ffffffffc0204e0a:	085010ef          	jal	ra,ffffffffc020668e <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204e0e:	000ae797          	auipc	a5,0xae
ffffffffc0204e12:	d0a7b783          	ld	a5,-758(a5) # ffffffffc02b2b18 <boot_cr3>
        proc->tf = NULL;
ffffffffc0204e16:	0a043023          	sd	zero,160(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204e1a:	f45c                	sd	a5,168(s0)
        proc->flags = 0;
ffffffffc0204e1c:	0a042823          	sw	zero,176(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204e20:	463d                	li	a2,15
ffffffffc0204e22:	4581                	li	a1,0
ffffffffc0204e24:	0b440513          	addi	a0,s0,180
ffffffffc0204e28:	067010ef          	jal	ra,ffffffffc020668e <memset>
        proc->wait_state = 0;
ffffffffc0204e2c:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0204e30:	0e043c23          	sd	zero,248(s0)
ffffffffc0204e34:	10043023          	sd	zero,256(s0)
ffffffffc0204e38:	0e043823          	sd	zero,240(s0)

    }
    return proc;
}
ffffffffc0204e3c:	60a2                	ld	ra,8(sp)
ffffffffc0204e3e:	8522                	mv	a0,s0
ffffffffc0204e40:	6402                	ld	s0,0(sp)
ffffffffc0204e42:	0141                	addi	sp,sp,16
ffffffffc0204e44:	8082                	ret

ffffffffc0204e46 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204e46:	000ae797          	auipc	a5,0xae
ffffffffc0204e4a:	d2a7b783          	ld	a5,-726(a5) # ffffffffc02b2b70 <current>
ffffffffc0204e4e:	73c8                	ld	a0,160(a5)
ffffffffc0204e50:	f27fb06f          	j	ffffffffc0200d76 <forkrets>

ffffffffc0204e54 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e54:	000ae797          	auipc	a5,0xae
ffffffffc0204e58:	d1c7b783          	ld	a5,-740(a5) # ffffffffc02b2b70 <current>
ffffffffc0204e5c:	43cc                	lw	a1,4(a5)
user_main(void *arg) {
ffffffffc0204e5e:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e60:	00003617          	auipc	a2,0x3
ffffffffc0204e64:	61060613          	addi	a2,a2,1552 # ffffffffc0208470 <default_pmm_manager+0x1068>
ffffffffc0204e68:	00003517          	auipc	a0,0x3
ffffffffc0204e6c:	61850513          	addi	a0,a0,1560 # ffffffffc0208480 <default_pmm_manager+0x1078>
user_main(void *arg) {
ffffffffc0204e70:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204e72:	b0efb0ef          	jal	ra,ffffffffc0200180 <cprintf>
ffffffffc0204e76:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204e7a:	b2a78793          	addi	a5,a5,-1238 # a9a0 <_binary_obj___user_forktest_out_size>
ffffffffc0204e7e:	e43e                	sd	a5,8(sp)
ffffffffc0204e80:	00003517          	auipc	a0,0x3
ffffffffc0204e84:	5f050513          	addi	a0,a0,1520 # ffffffffc0208470 <default_pmm_manager+0x1068>
ffffffffc0204e88:	00046797          	auipc	a5,0x46
ffffffffc0204e8c:	9b878793          	addi	a5,a5,-1608 # ffffffffc024a840 <_binary_obj___user_forktest_out_start>
ffffffffc0204e90:	f03e                	sd	a5,32(sp)
ffffffffc0204e92:	f42a                	sd	a0,40(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204e94:	e802                	sd	zero,16(sp)
ffffffffc0204e96:	77c010ef          	jal	ra,ffffffffc0206612 <strlen>
ffffffffc0204e9a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204e9c:	4511                	li	a0,4
ffffffffc0204e9e:	55a2                	lw	a1,40(sp)
ffffffffc0204ea0:	4662                	lw	a2,24(sp)
ffffffffc0204ea2:	5682                	lw	a3,32(sp)
ffffffffc0204ea4:	4722                	lw	a4,8(sp)
ffffffffc0204ea6:	48a9                	li	a7,10
ffffffffc0204ea8:	9002                	ebreak
ffffffffc0204eaa:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204eac:	65c2                	ld	a1,16(sp)
ffffffffc0204eae:	00003517          	auipc	a0,0x3
ffffffffc0204eb2:	5fa50513          	addi	a0,a0,1530 # ffffffffc02084a8 <default_pmm_manager+0x10a0>
ffffffffc0204eb6:	acafb0ef          	jal	ra,ffffffffc0200180 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204eba:	00003617          	auipc	a2,0x3
ffffffffc0204ebe:	5fe60613          	addi	a2,a2,1534 # ffffffffc02084b8 <default_pmm_manager+0x10b0>
ffffffffc0204ec2:	36200593          	li	a1,866
ffffffffc0204ec6:	00003517          	auipc	a0,0x3
ffffffffc0204eca:	61250513          	addi	a0,a0,1554 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0204ece:	dacfb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204ed2 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204ed2:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204ed4:	1141                	addi	sp,sp,-16
ffffffffc0204ed6:	e406                	sd	ra,8(sp)
ffffffffc0204ed8:	c02007b7          	lui	a5,0xc0200
ffffffffc0204edc:	02f6ee63          	bltu	a3,a5,ffffffffc0204f18 <put_pgdir+0x46>
ffffffffc0204ee0:	000ae517          	auipc	a0,0xae
ffffffffc0204ee4:	c6053503          	ld	a0,-928(a0) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0204ee8:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204eea:	82b1                	srli	a3,a3,0xc
ffffffffc0204eec:	000ae797          	auipc	a5,0xae
ffffffffc0204ef0:	c3c7b783          	ld	a5,-964(a5) # ffffffffc02b2b28 <npage>
ffffffffc0204ef4:	02f6fe63          	bgeu	a3,a5,ffffffffc0204f30 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0204ef8:	00004517          	auipc	a0,0x4
ffffffffc0204efc:	e7853503          	ld	a0,-392(a0) # ffffffffc0208d70 <nbase>
}
ffffffffc0204f00:	60a2                	ld	ra,8(sp)
ffffffffc0204f02:	8e89                	sub	a3,a3,a0
ffffffffc0204f04:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204f06:	000ae517          	auipc	a0,0xae
ffffffffc0204f0a:	c2a53503          	ld	a0,-982(a0) # ffffffffc02b2b30 <pages>
ffffffffc0204f0e:	4585                	li	a1,1
ffffffffc0204f10:	9536                	add	a0,a0,a3
}
ffffffffc0204f12:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204f14:	e5ffc06f          	j	ffffffffc0201d72 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204f18:	00002617          	auipc	a2,0x2
ffffffffc0204f1c:	5d060613          	addi	a2,a2,1488 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0204f20:	06e00593          	li	a1,110
ffffffffc0204f24:	00002517          	auipc	a0,0x2
ffffffffc0204f28:	54450513          	addi	a0,a0,1348 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0204f2c:	d4efb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204f30:	00002617          	auipc	a2,0x2
ffffffffc0204f34:	5e060613          	addi	a2,a2,1504 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0204f38:	06200593          	li	a1,98
ffffffffc0204f3c:	00002517          	auipc	a0,0x2
ffffffffc0204f40:	52c50513          	addi	a0,a0,1324 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0204f44:	d36fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0204f48 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f48:	7179                	addi	sp,sp,-48
ffffffffc0204f4a:	ec4a                	sd	s2,24(sp)
    if (proc != current) {
ffffffffc0204f4c:	000ae917          	auipc	s2,0xae
ffffffffc0204f50:	c2490913          	addi	s2,s2,-988 # ffffffffc02b2b70 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f54:	f026                	sd	s1,32(sp)
    if (proc != current) {
ffffffffc0204f56:	00093483          	ld	s1,0(s2)
proc_run(struct proc_struct *proc) {
ffffffffc0204f5a:	f406                	sd	ra,40(sp)
ffffffffc0204f5c:	e84e                	sd	s3,16(sp)
    if (proc != current) {
ffffffffc0204f5e:	02a48863          	beq	s1,a0,ffffffffc0204f8e <proc_run+0x46>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f62:	100027f3          	csrr	a5,sstatus
ffffffffc0204f66:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f68:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f6a:	ef9d                	bnez	a5,ffffffffc0204fa8 <proc_run+0x60>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f6c:	755c                	ld	a5,168(a0)
ffffffffc0204f6e:	577d                	li	a4,-1
ffffffffc0204f70:	177e                	slli	a4,a4,0x3f
ffffffffc0204f72:	83b1                	srli	a5,a5,0xc
            current = proc; //当前进程设为待调度的进程
ffffffffc0204f74:	00a93023          	sd	a0,0(s2)
ffffffffc0204f78:	8fd9                	or	a5,a5,a4
ffffffffc0204f7a:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));//switch_to进行上下文切换
ffffffffc0204f7e:	03050593          	addi	a1,a0,48
ffffffffc0204f82:	03048513          	addi	a0,s1,48
ffffffffc0204f86:	032010ef          	jal	ra,ffffffffc0205fb8 <switch_to>
    if (flag) {
ffffffffc0204f8a:	00099863          	bnez	s3,ffffffffc0204f9a <proc_run+0x52>
}
ffffffffc0204f8e:	70a2                	ld	ra,40(sp)
ffffffffc0204f90:	7482                	ld	s1,32(sp)
ffffffffc0204f92:	6962                	ld	s2,24(sp)
ffffffffc0204f94:	69c2                	ld	s3,16(sp)
ffffffffc0204f96:	6145                	addi	sp,sp,48
ffffffffc0204f98:	8082                	ret
ffffffffc0204f9a:	70a2                	ld	ra,40(sp)
ffffffffc0204f9c:	7482                	ld	s1,32(sp)
ffffffffc0204f9e:	6962                	ld	s2,24(sp)
ffffffffc0204fa0:	69c2                	ld	s3,16(sp)
ffffffffc0204fa2:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0204fa4:	e9cfb06f          	j	ffffffffc0200640 <intr_enable>
ffffffffc0204fa8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0204faa:	e9cfb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0204fae:	6522                	ld	a0,8(sp)
ffffffffc0204fb0:	4985                	li	s3,1
ffffffffc0204fb2:	bf6d                	j	ffffffffc0204f6c <proc_run+0x24>

ffffffffc0204fb4 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fb4:	7159                	addi	sp,sp,-112
ffffffffc0204fb6:	e8ca                	sd	s2,80(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fb8:	000ae917          	auipc	s2,0xae
ffffffffc0204fbc:	bd090913          	addi	s2,s2,-1072 # ffffffffc02b2b88 <nr_process>
ffffffffc0204fc0:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fc4:	f486                	sd	ra,104(sp)
ffffffffc0204fc6:	f0a2                	sd	s0,96(sp)
ffffffffc0204fc8:	eca6                	sd	s1,88(sp)
ffffffffc0204fca:	e4ce                	sd	s3,72(sp)
ffffffffc0204fcc:	e0d2                	sd	s4,64(sp)
ffffffffc0204fce:	fc56                	sd	s5,56(sp)
ffffffffc0204fd0:	f85a                	sd	s6,48(sp)
ffffffffc0204fd2:	f45e                	sd	s7,40(sp)
ffffffffc0204fd4:	f062                	sd	s8,32(sp)
ffffffffc0204fd6:	ec66                	sd	s9,24(sp)
ffffffffc0204fd8:	e86a                	sd	s10,16(sp)
ffffffffc0204fda:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fdc:	6785                	lui	a5,0x1
ffffffffc0204fde:	32f75b63          	bge	a4,a5,ffffffffc0205314 <do_fork+0x360>
ffffffffc0204fe2:	8a2a                	mv	s4,a0
ffffffffc0204fe4:	89ae                	mv	s3,a1
ffffffffc0204fe6:	8432                	mv	s0,a2
    proc = alloc_proc();    // 调用alloc_proc函数分配一个proc_struct结构体
ffffffffc0204fe8:	de3ff0ef          	jal	ra,ffffffffc0204dca <alloc_proc>
ffffffffc0204fec:	84aa                	mv	s1,a0
    if (proc == NULL) { // 如果分配失败，返回错误码
ffffffffc0204fee:	2c050363          	beqz	a0,ffffffffc02052b4 <do_fork+0x300>
    proc->parent = current; // 设置父进程为当前进程
ffffffffc0204ff2:	000aea97          	auipc	s5,0xae
ffffffffc0204ff6:	b7ea8a93          	addi	s5,s5,-1154 # ffffffffc02b2b70 <current>
ffffffffc0204ffa:	000ab783          	ld	a5,0(s5)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204ffe:	4509                	li	a0,2
    proc->parent = current; // 设置父进程为当前进程
ffffffffc0205000:	f09c                	sd	a5,32(s1)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205002:	cdffc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
    if (page != NULL) {
ffffffffc0205006:	2c050663          	beqz	a0,ffffffffc02052d2 <do_fork+0x31e>
    return page - pages + nbase;
ffffffffc020500a:	000aed97          	auipc	s11,0xae
ffffffffc020500e:	b26d8d93          	addi	s11,s11,-1242 # ffffffffc02b2b30 <pages>
ffffffffc0205012:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0205016:	000aed17          	auipc	s10,0xae
ffffffffc020501a:	b12d0d13          	addi	s10,s10,-1262 # ffffffffc02b2b28 <npage>
    return page - pages + nbase;
ffffffffc020501e:	00004c97          	auipc	s9,0x4
ffffffffc0205022:	d52cbc83          	ld	s9,-686(s9) # ffffffffc0208d70 <nbase>
ffffffffc0205026:	40d506b3          	sub	a3,a0,a3
ffffffffc020502a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020502c:	5c7d                	li	s8,-1
ffffffffc020502e:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc0205032:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0205034:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0205038:	0186f733          	and	a4,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc020503c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020503e:	2ef77063          	bgeu	a4,a5,ffffffffc020531e <do_fork+0x36a>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205042:	000ab703          	ld	a4,0(s5)
ffffffffc0205046:	000aea97          	auipc	s5,0xae
ffffffffc020504a:	afaa8a93          	addi	s5,s5,-1286 # ffffffffc02b2b40 <va_pa_offset>
ffffffffc020504e:	000ab783          	ld	a5,0(s5)
ffffffffc0205052:	02873b83          	ld	s7,40(a4)
ffffffffc0205056:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205058:	e894                	sd	a3,16(s1)
    if (oldmm == NULL) {
ffffffffc020505a:	020b8863          	beqz	s7,ffffffffc020508a <do_fork+0xd6>
    if (clone_flags & CLONE_VM) {
ffffffffc020505e:	100a7a13          	andi	s4,s4,256
ffffffffc0205062:	1c0a0163          	beqz	s4,ffffffffc0205224 <do_fork+0x270>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205066:	030ba703          	lw	a4,48(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020506a:	018bb783          	ld	a5,24(s7)
ffffffffc020506e:	c02006b7          	lui	a3,0xc0200
ffffffffc0205072:	2705                	addiw	a4,a4,1
ffffffffc0205074:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0205078:	0374b423          	sd	s7,40(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020507c:	2ad7ed63          	bltu	a5,a3,ffffffffc0205336 <do_fork+0x382>
ffffffffc0205080:	000ab703          	ld	a4,0(s5)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205084:	6894                	ld	a3,16(s1)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205086:	8f99                	sub	a5,a5,a4
ffffffffc0205088:	f4dc                	sd	a5,168(s1)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020508a:	6789                	lui	a5,0x2
ffffffffc020508c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7d00>
ffffffffc0205090:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0205092:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205094:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;
ffffffffc0205096:	87b6                	mv	a5,a3
ffffffffc0205098:	12040893          	addi	a7,s0,288
ffffffffc020509c:	00063803          	ld	a6,0(a2)
ffffffffc02050a0:	6608                	ld	a0,8(a2)
ffffffffc02050a2:	6a0c                	ld	a1,16(a2)
ffffffffc02050a4:	6e18                	ld	a4,24(a2)
ffffffffc02050a6:	0107b023          	sd	a6,0(a5)
ffffffffc02050aa:	e788                	sd	a0,8(a5)
ffffffffc02050ac:	eb8c                	sd	a1,16(a5)
ffffffffc02050ae:	ef98                	sd	a4,24(a5)
ffffffffc02050b0:	02060613          	addi	a2,a2,32
ffffffffc02050b4:	02078793          	addi	a5,a5,32
ffffffffc02050b8:	ff1612e3          	bne	a2,a7,ffffffffc020509c <do_fork+0xe8>
    proc->tf->gpr.a0 = 0;
ffffffffc02050bc:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050c0:	12098f63          	beqz	s3,ffffffffc02051fe <do_fork+0x24a>
ffffffffc02050c4:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050c8:	00000797          	auipc	a5,0x0
ffffffffc02050cc:	d7e78793          	addi	a5,a5,-642 # ffffffffc0204e46 <forkret>
ffffffffc02050d0:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050d2:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050d4:	100027f3          	csrr	a5,sstatus
ffffffffc02050d8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050da:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050dc:	14079063          	bnez	a5,ffffffffc020521c <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050e0:	000a2817          	auipc	a6,0xa2
ffffffffc02050e4:	54880813          	addi	a6,a6,1352 # ffffffffc02a7628 <last_pid.1>
ffffffffc02050e8:	00082783          	lw	a5,0(a6)
ffffffffc02050ec:	6709                	lui	a4,0x2
ffffffffc02050ee:	0017851b          	addiw	a0,a5,1
ffffffffc02050f2:	00a82023          	sw	a0,0(a6)
ffffffffc02050f6:	08e55d63          	bge	a0,a4,ffffffffc0205190 <do_fork+0x1dc>
    if (last_pid >= next_safe) {
ffffffffc02050fa:	000a2317          	auipc	t1,0xa2
ffffffffc02050fe:	53230313          	addi	t1,t1,1330 # ffffffffc02a762c <next_safe.0>
ffffffffc0205102:	00032783          	lw	a5,0(t1)
ffffffffc0205106:	000ae417          	auipc	s0,0xae
ffffffffc020510a:	9e240413          	addi	s0,s0,-1566 # ffffffffc02b2ae8 <proc_list>
ffffffffc020510e:	08f55963          	bge	a0,a5,ffffffffc02051a0 <do_fork+0x1ec>
    proc->pid = get_pid();  // 为子进程分配pid
ffffffffc0205112:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205114:	45a9                	li	a1,10
ffffffffc0205116:	2501                	sext.w	a0,a0
ffffffffc0205118:	0f6010ef          	jal	ra,ffffffffc020620e <hash32>
ffffffffc020511c:	02051793          	slli	a5,a0,0x20
ffffffffc0205120:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205124:	000aa797          	auipc	a5,0xaa
ffffffffc0205128:	9c478793          	addi	a5,a5,-1596 # ffffffffc02aeae8 <hash_list>
ffffffffc020512c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020512e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205130:	7094                	ld	a3,32(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205132:	0d848793          	addi	a5,s1,216
    prev->next = next->prev = elm;
ffffffffc0205136:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205138:	6410                	ld	a2,8(s0)
    prev->next = next->prev = elm;
ffffffffc020513a:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020513c:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020513e:	0c848793          	addi	a5,s1,200
    elm->next = next;
ffffffffc0205142:	f0ec                	sd	a1,224(s1)
    elm->prev = prev;
ffffffffc0205144:	ece8                	sd	a0,216(s1)
    prev->next = next->prev = elm;
ffffffffc0205146:	e21c                	sd	a5,0(a2)
ffffffffc0205148:	e41c                	sd	a5,8(s0)
    elm->next = next;
ffffffffc020514a:	e8f0                	sd	a2,208(s1)
    elm->prev = prev;
ffffffffc020514c:	e4e0                	sd	s0,200(s1)
    proc->yptr = NULL;
ffffffffc020514e:	0e04bc23          	sd	zero,248(s1)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205152:	10e4b023          	sd	a4,256(s1)
ffffffffc0205156:	c311                	beqz	a4,ffffffffc020515a <do_fork+0x1a6>
        proc->optr->yptr = proc;
ffffffffc0205158:	ff64                	sd	s1,248(a4)
    nr_process ++;
ffffffffc020515a:	00092783          	lw	a5,0(s2)
    proc->parent->cptr = proc;
ffffffffc020515e:	fae4                	sd	s1,240(a3)
    nr_process ++;
ffffffffc0205160:	2785                	addiw	a5,a5,1
ffffffffc0205162:	00f92023          	sw	a5,0(s2)
    if (flag) {
ffffffffc0205166:	14099963          	bnez	s3,ffffffffc02052b8 <do_fork+0x304>
    wakeup_proc(proc);  // 唤醒子进程
ffffffffc020516a:	8526                	mv	a0,s1
ffffffffc020516c:	6b7000ef          	jal	ra,ffffffffc0206022 <wakeup_proc>
    ret = proc->pid;    // 设置返回值为子进程的pid
ffffffffc0205170:	40c8                	lw	a0,4(s1)
}
ffffffffc0205172:	70a6                	ld	ra,104(sp)
ffffffffc0205174:	7406                	ld	s0,96(sp)
ffffffffc0205176:	64e6                	ld	s1,88(sp)
ffffffffc0205178:	6946                	ld	s2,80(sp)
ffffffffc020517a:	69a6                	ld	s3,72(sp)
ffffffffc020517c:	6a06                	ld	s4,64(sp)
ffffffffc020517e:	7ae2                	ld	s5,56(sp)
ffffffffc0205180:	7b42                	ld	s6,48(sp)
ffffffffc0205182:	7ba2                	ld	s7,40(sp)
ffffffffc0205184:	7c02                	ld	s8,32(sp)
ffffffffc0205186:	6ce2                	ld	s9,24(sp)
ffffffffc0205188:	6d42                	ld	s10,16(sp)
ffffffffc020518a:	6da2                	ld	s11,8(sp)
ffffffffc020518c:	6165                	addi	sp,sp,112
ffffffffc020518e:	8082                	ret
        last_pid = 1;
ffffffffc0205190:	4785                	li	a5,1
ffffffffc0205192:	00f82023          	sw	a5,0(a6)
        goto inside;
ffffffffc0205196:	4505                	li	a0,1
ffffffffc0205198:	000a2317          	auipc	t1,0xa2
ffffffffc020519c:	49430313          	addi	t1,t1,1172 # ffffffffc02a762c <next_safe.0>
    return listelm->next;
ffffffffc02051a0:	000ae417          	auipc	s0,0xae
ffffffffc02051a4:	94840413          	addi	s0,s0,-1720 # ffffffffc02b2ae8 <proc_list>
ffffffffc02051a8:	00843e03          	ld	t3,8(s0)
        next_safe = MAX_PID;
ffffffffc02051ac:	6789                	lui	a5,0x2
ffffffffc02051ae:	00f32023          	sw	a5,0(t1)
ffffffffc02051b2:	86aa                	mv	a3,a0
ffffffffc02051b4:	4581                	li	a1,0
        while ((le = list_next(le)) != list) {
ffffffffc02051b6:	6e89                	lui	t4,0x2
ffffffffc02051b8:	108e0863          	beq	t3,s0,ffffffffc02052c8 <do_fork+0x314>
ffffffffc02051bc:	88ae                	mv	a7,a1
ffffffffc02051be:	87f2                	mv	a5,t3
ffffffffc02051c0:	6609                	lui	a2,0x2
ffffffffc02051c2:	a811                	j	ffffffffc02051d6 <do_fork+0x222>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc02051c4:	00e6d663          	bge	a3,a4,ffffffffc02051d0 <do_fork+0x21c>
ffffffffc02051c8:	00c75463          	bge	a4,a2,ffffffffc02051d0 <do_fork+0x21c>
ffffffffc02051cc:	863a                	mv	a2,a4
ffffffffc02051ce:	4885                	li	a7,1
ffffffffc02051d0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02051d2:	00878d63          	beq	a5,s0,ffffffffc02051ec <do_fork+0x238>
            if (proc->pid == last_pid) {
ffffffffc02051d6:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_faultread_out_size-0x7ca4>
ffffffffc02051da:	fed715e3          	bne	a4,a3,ffffffffc02051c4 <do_fork+0x210>
                if (++ last_pid >= next_safe) {
ffffffffc02051de:	2685                	addiw	a3,a3,1
ffffffffc02051e0:	0cc6df63          	bge	a3,a2,ffffffffc02052be <do_fork+0x30a>
ffffffffc02051e4:	679c                	ld	a5,8(a5)
ffffffffc02051e6:	4585                	li	a1,1
        while ((le = list_next(le)) != list) {
ffffffffc02051e8:	fe8797e3          	bne	a5,s0,ffffffffc02051d6 <do_fork+0x222>
ffffffffc02051ec:	c581                	beqz	a1,ffffffffc02051f4 <do_fork+0x240>
ffffffffc02051ee:	00d82023          	sw	a3,0(a6)
ffffffffc02051f2:	8536                	mv	a0,a3
ffffffffc02051f4:	f0088fe3          	beqz	a7,ffffffffc0205112 <do_fork+0x15e>
ffffffffc02051f8:	00c32023          	sw	a2,0(t1)
ffffffffc02051fc:	bf19                	j	ffffffffc0205112 <do_fork+0x15e>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051fe:	89b6                	mv	s3,a3
ffffffffc0205200:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205204:	00000797          	auipc	a5,0x0
ffffffffc0205208:	c4278793          	addi	a5,a5,-958 # ffffffffc0204e46 <forkret>
ffffffffc020520c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020520e:	fc94                	sd	a3,56(s1)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205210:	100027f3          	csrr	a5,sstatus
ffffffffc0205214:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205216:	4981                	li	s3,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205218:	ec0784e3          	beqz	a5,ffffffffc02050e0 <do_fork+0x12c>
        intr_disable();
ffffffffc020521c:	c2afb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205220:	4985                	li	s3,1
ffffffffc0205222:	bd7d                	j	ffffffffc02050e0 <do_fork+0x12c>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205224:	f4ffe0ef          	jal	ra,ffffffffc0204172 <mm_create>
ffffffffc0205228:	8b2a                	mv	s6,a0
ffffffffc020522a:	c151                	beqz	a0,ffffffffc02052ae <do_fork+0x2fa>
    if ((page = alloc_page()) == NULL) {
ffffffffc020522c:	4505                	li	a0,1
ffffffffc020522e:	ab3fc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc0205232:	c93d                	beqz	a0,ffffffffc02052a8 <do_fork+0x2f4>
    return page - pages + nbase;
ffffffffc0205234:	000db683          	ld	a3,0(s11)
    return KADDR(page2pa(page));
ffffffffc0205238:	000d3783          	ld	a5,0(s10)
    return page - pages + nbase;
ffffffffc020523c:	40d506b3          	sub	a3,a0,a3
ffffffffc0205240:	8699                	srai	a3,a3,0x6
ffffffffc0205242:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0205244:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc0205248:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020524a:	0cfc7a63          	bgeu	s8,a5,ffffffffc020531e <do_fork+0x36a>
ffffffffc020524e:	000aba03          	ld	s4,0(s5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205252:	6605                	lui	a2,0x1
ffffffffc0205254:	000ae597          	auipc	a1,0xae
ffffffffc0205258:	8cc5b583          	ld	a1,-1844(a1) # ffffffffc02b2b20 <boot_pgdir>
ffffffffc020525c:	9a36                	add	s4,s4,a3
ffffffffc020525e:	8552                	mv	a0,s4
ffffffffc0205260:	440010ef          	jal	ra,ffffffffc02066a0 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205264:	038b8c13          	addi	s8,s7,56
    mm->pgdir = pgdir;
ffffffffc0205268:	014b3c23          	sd	s4,24(s6)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020526c:	4785                	li	a5,1
ffffffffc020526e:	40fc37af          	amoor.d	a5,a5,(s8)
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205272:	8b85                	andi	a5,a5,1
ffffffffc0205274:	4a05                	li	s4,1
ffffffffc0205276:	c799                	beqz	a5,ffffffffc0205284 <do_fork+0x2d0>
        schedule();
ffffffffc0205278:	62b000ef          	jal	ra,ffffffffc02060a2 <schedule>
ffffffffc020527c:	414c37af          	amoor.d	a5,s4,(s8)
    while (!try_lock(lock)) {
ffffffffc0205280:	8b85                	andi	a5,a5,1
ffffffffc0205282:	fbfd                	bnez	a5,ffffffffc0205278 <do_fork+0x2c4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205284:	85de                	mv	a1,s7
ffffffffc0205286:	855a                	mv	a0,s6
ffffffffc0205288:	972ff0ef          	jal	ra,ffffffffc02043fa <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020528c:	57f9                	li	a5,-2
ffffffffc020528e:	60fc37af          	amoand.d	a5,a5,(s8)
ffffffffc0205292:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205294:	cfd5                	beqz	a5,ffffffffc0205350 <do_fork+0x39c>
good_mm:
ffffffffc0205296:	8bda                	mv	s7,s6
    if (ret != 0) {
ffffffffc0205298:	dc0507e3          	beqz	a0,ffffffffc0205066 <do_fork+0xb2>
    exit_mmap(mm);
ffffffffc020529c:	855a                	mv	a0,s6
ffffffffc020529e:	9f6ff0ef          	jal	ra,ffffffffc0204494 <exit_mmap>
    put_pgdir(mm);
ffffffffc02052a2:	855a                	mv	a0,s6
ffffffffc02052a4:	c2fff0ef          	jal	ra,ffffffffc0204ed2 <put_pgdir>
    mm_destroy(mm);
ffffffffc02052a8:	855a                	mv	a0,s6
ffffffffc02052aa:	84eff0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
    kfree(proc);
ffffffffc02052ae:	8526                	mv	a0,s1
ffffffffc02052b0:	903fc0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    ret = -E_NO_MEM;
ffffffffc02052b4:	5571                	li	a0,-4
    return ret;
ffffffffc02052b6:	bd75                	j	ffffffffc0205172 <do_fork+0x1be>
        intr_enable();
ffffffffc02052b8:	b88fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02052bc:	b57d                	j	ffffffffc020516a <do_fork+0x1b6>
                    if (last_pid >= MAX_PID) {
ffffffffc02052be:	01d6c363          	blt	a3,t4,ffffffffc02052c4 <do_fork+0x310>
                        last_pid = 1;
ffffffffc02052c2:	4685                	li	a3,1
                    goto repeat;
ffffffffc02052c4:	4585                	li	a1,1
ffffffffc02052c6:	bdcd                	j	ffffffffc02051b8 <do_fork+0x204>
ffffffffc02052c8:	c9a1                	beqz	a1,ffffffffc0205318 <do_fork+0x364>
ffffffffc02052ca:	00d82023          	sw	a3,0(a6)
    return last_pid;
ffffffffc02052ce:	8536                	mv	a0,a3
ffffffffc02052d0:	b589                	j	ffffffffc0205112 <do_fork+0x15e>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052d2:	6894                	ld	a3,16(s1)
    return pa2page(PADDR(kva));
ffffffffc02052d4:	c02007b7          	lui	a5,0xc0200
ffffffffc02052d8:	0af6e463          	bltu	a3,a5,ffffffffc0205380 <do_fork+0x3cc>
ffffffffc02052dc:	000ae797          	auipc	a5,0xae
ffffffffc02052e0:	8647b783          	ld	a5,-1948(a5) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc02052e4:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052e8:	83b1                	srli	a5,a5,0xc
ffffffffc02052ea:	000ae717          	auipc	a4,0xae
ffffffffc02052ee:	83e73703          	ld	a4,-1986(a4) # ffffffffc02b2b28 <npage>
ffffffffc02052f2:	06e7fb63          	bgeu	a5,a4,ffffffffc0205368 <do_fork+0x3b4>
    return &pages[PPN(pa) - nbase];
ffffffffc02052f6:	00004717          	auipc	a4,0x4
ffffffffc02052fa:	a7a73703          	ld	a4,-1414(a4) # ffffffffc0208d70 <nbase>
ffffffffc02052fe:	8f99                	sub	a5,a5,a4
ffffffffc0205300:	079a                	slli	a5,a5,0x6
ffffffffc0205302:	000ae517          	auipc	a0,0xae
ffffffffc0205306:	82e53503          	ld	a0,-2002(a0) # ffffffffc02b2b30 <pages>
ffffffffc020530a:	4589                	li	a1,2
ffffffffc020530c:	953e                	add	a0,a0,a5
ffffffffc020530e:	a65fc0ef          	jal	ra,ffffffffc0201d72 <free_pages>
}
ffffffffc0205312:	bf71                	j	ffffffffc02052ae <do_fork+0x2fa>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205314:	556d                	li	a0,-5
ffffffffc0205316:	bdb1                	j	ffffffffc0205172 <do_fork+0x1be>
    return last_pid;
ffffffffc0205318:	00082503          	lw	a0,0(a6)
ffffffffc020531c:	bbdd                	j	ffffffffc0205112 <do_fork+0x15e>
    return KADDR(page2pa(page));
ffffffffc020531e:	00002617          	auipc	a2,0x2
ffffffffc0205322:	12260613          	addi	a2,a2,290 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0205326:	06900593          	li	a1,105
ffffffffc020532a:	00002517          	auipc	a0,0x2
ffffffffc020532e:	13e50513          	addi	a0,a0,318 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0205332:	948fb0ef          	jal	ra,ffffffffc020047a <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205336:	86be                	mv	a3,a5
ffffffffc0205338:	00002617          	auipc	a2,0x2
ffffffffc020533c:	1b060613          	addi	a2,a2,432 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0205340:	16b00593          	li	a1,363
ffffffffc0205344:	00003517          	auipc	a0,0x3
ffffffffc0205348:	19450513          	addi	a0,a0,404 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc020534c:	92efb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("Unlock failed.\n");
ffffffffc0205350:	00003617          	auipc	a2,0x3
ffffffffc0205354:	1a060613          	addi	a2,a2,416 # ffffffffc02084f0 <default_pmm_manager+0x10e8>
ffffffffc0205358:	03100593          	li	a1,49
ffffffffc020535c:	00003517          	auipc	a0,0x3
ffffffffc0205360:	1a450513          	addi	a0,a0,420 # ffffffffc0208500 <default_pmm_manager+0x10f8>
ffffffffc0205364:	916fb0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205368:	00002617          	auipc	a2,0x2
ffffffffc020536c:	1a860613          	addi	a2,a2,424 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc0205370:	06200593          	li	a1,98
ffffffffc0205374:	00002517          	auipc	a0,0x2
ffffffffc0205378:	0f450513          	addi	a0,a0,244 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc020537c:	8fefb0ef          	jal	ra,ffffffffc020047a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205380:	00002617          	auipc	a2,0x2
ffffffffc0205384:	16860613          	addi	a2,a2,360 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0205388:	06e00593          	li	a1,110
ffffffffc020538c:	00002517          	auipc	a0,0x2
ffffffffc0205390:	0dc50513          	addi	a0,a0,220 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0205394:	8e6fb0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205398 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205398:	7129                	addi	sp,sp,-320
ffffffffc020539a:	fa22                	sd	s0,304(sp)
ffffffffc020539c:	f626                	sd	s1,296(sp)
ffffffffc020539e:	f24a                	sd	s2,288(sp)
ffffffffc02053a0:	84ae                	mv	s1,a1
ffffffffc02053a2:	892a                	mv	s2,a0
ffffffffc02053a4:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053a6:	4581                	li	a1,0
ffffffffc02053a8:	12000613          	li	a2,288
ffffffffc02053ac:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053ae:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053b0:	2de010ef          	jal	ra,ffffffffc020668e <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053b4:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053b6:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053b8:	100027f3          	csrr	a5,sstatus
ffffffffc02053bc:	edd7f793          	andi	a5,a5,-291
ffffffffc02053c0:	1207e793          	ori	a5,a5,288
ffffffffc02053c4:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053c6:	860a                	mv	a2,sp
ffffffffc02053c8:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053cc:	00000797          	auipc	a5,0x0
ffffffffc02053d0:	9f678793          	addi	a5,a5,-1546 # ffffffffc0204dc2 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d4:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053d6:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d8:	bddff0ef          	jal	ra,ffffffffc0204fb4 <do_fork>
}
ffffffffc02053dc:	70f2                	ld	ra,312(sp)
ffffffffc02053de:	7452                	ld	s0,304(sp)
ffffffffc02053e0:	74b2                	ld	s1,296(sp)
ffffffffc02053e2:	7912                	ld	s2,288(sp)
ffffffffc02053e4:	6131                	addi	sp,sp,320
ffffffffc02053e6:	8082                	ret

ffffffffc02053e8 <do_exit>:
do_exit(int error_code) {
ffffffffc02053e8:	7179                	addi	sp,sp,-48
ffffffffc02053ea:	f022                	sd	s0,32(sp)
    if (current == idleproc) {
ffffffffc02053ec:	000ad417          	auipc	s0,0xad
ffffffffc02053f0:	78440413          	addi	s0,s0,1924 # ffffffffc02b2b70 <current>
ffffffffc02053f4:	601c                	ld	a5,0(s0)
do_exit(int error_code) {
ffffffffc02053f6:	f406                	sd	ra,40(sp)
ffffffffc02053f8:	ec26                	sd	s1,24(sp)
ffffffffc02053fa:	e84a                	sd	s2,16(sp)
ffffffffc02053fc:	e44e                	sd	s3,8(sp)
ffffffffc02053fe:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc0205400:	000ad717          	auipc	a4,0xad
ffffffffc0205404:	77873703          	ld	a4,1912(a4) # ffffffffc02b2b78 <idleproc>
ffffffffc0205408:	0ce78c63          	beq	a5,a4,ffffffffc02054e0 <do_exit+0xf8>
    if (current == initproc) {
ffffffffc020540c:	000ad497          	auipc	s1,0xad
ffffffffc0205410:	77448493          	addi	s1,s1,1908 # ffffffffc02b2b80 <initproc>
ffffffffc0205414:	6098                	ld	a4,0(s1)
ffffffffc0205416:	0ee78b63          	beq	a5,a4,ffffffffc020550c <do_exit+0x124>
    struct mm_struct *mm = current->mm;
ffffffffc020541a:	0287b983          	ld	s3,40(a5)
ffffffffc020541e:	892a                	mv	s2,a0
    if (mm != NULL) {
ffffffffc0205420:	02098663          	beqz	s3,ffffffffc020544c <do_exit+0x64>
ffffffffc0205424:	000ad797          	auipc	a5,0xad
ffffffffc0205428:	6f47b783          	ld	a5,1780(a5) # ffffffffc02b2b18 <boot_cr3>
ffffffffc020542c:	577d                	li	a4,-1
ffffffffc020542e:	177e                	slli	a4,a4,0x3f
ffffffffc0205430:	83b1                	srli	a5,a5,0xc
ffffffffc0205432:	8fd9                	or	a5,a5,a4
ffffffffc0205434:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205438:	0309a783          	lw	a5,48(s3)
ffffffffc020543c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205440:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205444:	cb55                	beqz	a4,ffffffffc02054f8 <do_exit+0x110>
        current->mm = NULL;
ffffffffc0205446:	601c                	ld	a5,0(s0)
ffffffffc0205448:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020544c:	601c                	ld	a5,0(s0)
ffffffffc020544e:	470d                	li	a4,3
ffffffffc0205450:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205452:	0f27a423          	sw	s2,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205456:	100027f3          	csrr	a5,sstatus
ffffffffc020545a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020545c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020545e:	e3f9                	bnez	a5,ffffffffc0205524 <do_exit+0x13c>
        proc = current->parent;
ffffffffc0205460:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205462:	800007b7          	lui	a5,0x80000
ffffffffc0205466:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc0205468:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020546a:	0ec52703          	lw	a4,236(a0)
ffffffffc020546e:	0af70f63          	beq	a4,a5,ffffffffc020552c <do_exit+0x144>
        while (current->cptr != NULL) {
ffffffffc0205472:	6018                	ld	a4,0(s0)
ffffffffc0205474:	7b7c                	ld	a5,240(a4)
ffffffffc0205476:	c3a1                	beqz	a5,ffffffffc02054b6 <do_exit+0xce>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205478:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020547c:	490d                	li	s2,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020547e:	0985                	addi	s3,s3,1
ffffffffc0205480:	a021                	j	ffffffffc0205488 <do_exit+0xa0>
        while (current->cptr != NULL) {
ffffffffc0205482:	6018                	ld	a4,0(s0)
ffffffffc0205484:	7b7c                	ld	a5,240(a4)
ffffffffc0205486:	cb85                	beqz	a5,ffffffffc02054b6 <do_exit+0xce>
            current->cptr = proc->optr;
ffffffffc0205488:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff4fa8>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020548c:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020548e:	fb74                	sd	a3,240(a4)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205490:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205492:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205496:	10e7b023          	sd	a4,256(a5)
ffffffffc020549a:	c311                	beqz	a4,ffffffffc020549e <do_exit+0xb6>
                initproc->cptr->yptr = proc;
ffffffffc020549c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020549e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054a0:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054a2:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054a4:	fd271fe3          	bne	a4,s2,ffffffffc0205482 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054a8:	0ec52783          	lw	a5,236(a0)
ffffffffc02054ac:	fd379be3          	bne	a5,s3,ffffffffc0205482 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054b0:	373000ef          	jal	ra,ffffffffc0206022 <wakeup_proc>
ffffffffc02054b4:	b7f9                	j	ffffffffc0205482 <do_exit+0x9a>
    if (flag) {
ffffffffc02054b6:	020a1263          	bnez	s4,ffffffffc02054da <do_exit+0xf2>
    schedule();
ffffffffc02054ba:	3e9000ef          	jal	ra,ffffffffc02060a2 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054be:	601c                	ld	a5,0(s0)
ffffffffc02054c0:	00003617          	auipc	a2,0x3
ffffffffc02054c4:	07860613          	addi	a2,a2,120 # ffffffffc0208538 <default_pmm_manager+0x1130>
ffffffffc02054c8:	21500593          	li	a1,533
ffffffffc02054cc:	43d4                	lw	a3,4(a5)
ffffffffc02054ce:	00003517          	auipc	a0,0x3
ffffffffc02054d2:	00a50513          	addi	a0,a0,10 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc02054d6:	fa5fa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_enable();
ffffffffc02054da:	966fb0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02054de:	bff1                	j	ffffffffc02054ba <do_exit+0xd2>
        panic("idleproc exit.\n");
ffffffffc02054e0:	00003617          	auipc	a2,0x3
ffffffffc02054e4:	03860613          	addi	a2,a2,56 # ffffffffc0208518 <default_pmm_manager+0x1110>
ffffffffc02054e8:	1e900593          	li	a1,489
ffffffffc02054ec:	00003517          	auipc	a0,0x3
ffffffffc02054f0:	fec50513          	addi	a0,a0,-20 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc02054f4:	f87fa0ef          	jal	ra,ffffffffc020047a <__panic>
            exit_mmap(mm);
ffffffffc02054f8:	854e                	mv	a0,s3
ffffffffc02054fa:	f9bfe0ef          	jal	ra,ffffffffc0204494 <exit_mmap>
            put_pgdir(mm);
ffffffffc02054fe:	854e                	mv	a0,s3
ffffffffc0205500:	9d3ff0ef          	jal	ra,ffffffffc0204ed2 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205504:	854e                	mv	a0,s3
ffffffffc0205506:	df3fe0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
ffffffffc020550a:	bf35                	j	ffffffffc0205446 <do_exit+0x5e>
        panic("initproc exit.\n");
ffffffffc020550c:	00003617          	auipc	a2,0x3
ffffffffc0205510:	01c60613          	addi	a2,a2,28 # ffffffffc0208528 <default_pmm_manager+0x1120>
ffffffffc0205514:	1ec00593          	li	a1,492
ffffffffc0205518:	00003517          	auipc	a0,0x3
ffffffffc020551c:	fc050513          	addi	a0,a0,-64 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205520:	f5bfa0ef          	jal	ra,ffffffffc020047a <__panic>
        intr_disable();
ffffffffc0205524:	922fb0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0205528:	4a05                	li	s4,1
ffffffffc020552a:	bf1d                	j	ffffffffc0205460 <do_exit+0x78>
            wakeup_proc(proc);
ffffffffc020552c:	2f7000ef          	jal	ra,ffffffffc0206022 <wakeup_proc>
ffffffffc0205530:	b789                	j	ffffffffc0205472 <do_exit+0x8a>

ffffffffc0205532 <do_wait.part.0>:
do_wait(int pid, int *code_store) {
ffffffffc0205532:	715d                	addi	sp,sp,-80
ffffffffc0205534:	f84a                	sd	s2,48(sp)
ffffffffc0205536:	f44e                	sd	s3,40(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205538:	80000937          	lui	s2,0x80000
    if (0 < pid && pid < MAX_PID) {
ffffffffc020553c:	6989                	lui	s3,0x2
do_wait(int pid, int *code_store) {
ffffffffc020553e:	fc26                	sd	s1,56(sp)
ffffffffc0205540:	f052                	sd	s4,32(sp)
ffffffffc0205542:	ec56                	sd	s5,24(sp)
ffffffffc0205544:	e85a                	sd	s6,16(sp)
ffffffffc0205546:	e45e                	sd	s7,8(sp)
ffffffffc0205548:	e486                	sd	ra,72(sp)
ffffffffc020554a:	e0a2                	sd	s0,64(sp)
ffffffffc020554c:	84aa                	mv	s1,a0
ffffffffc020554e:	8a2e                	mv	s4,a1
        proc = current->cptr;
ffffffffc0205550:	000adb97          	auipc	s7,0xad
ffffffffc0205554:	620b8b93          	addi	s7,s7,1568 # ffffffffc02b2b70 <current>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205558:	00050b1b          	sext.w	s6,a0
ffffffffc020555c:	fff50a9b          	addiw	s5,a0,-1
ffffffffc0205560:	19f9                	addi	s3,s3,-2
        current->wait_state = WT_CHILD;
ffffffffc0205562:	0905                	addi	s2,s2,1
    if (pid != 0) {
ffffffffc0205564:	ccbd                	beqz	s1,ffffffffc02055e2 <do_wait.part.0+0xb0>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205566:	0359e863          	bltu	s3,s5,ffffffffc0205596 <do_wait.part.0+0x64>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020556a:	45a9                	li	a1,10
ffffffffc020556c:	855a                	mv	a0,s6
ffffffffc020556e:	4a1000ef          	jal	ra,ffffffffc020620e <hash32>
ffffffffc0205572:	02051793          	slli	a5,a0,0x20
ffffffffc0205576:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020557a:	000a9797          	auipc	a5,0xa9
ffffffffc020557e:	56e78793          	addi	a5,a5,1390 # ffffffffc02aeae8 <hash_list>
ffffffffc0205582:	953e                	add	a0,a0,a5
ffffffffc0205584:	842a                	mv	s0,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205586:	a029                	j	ffffffffc0205590 <do_wait.part.0+0x5e>
            if (proc->pid == pid) {
ffffffffc0205588:	f2c42783          	lw	a5,-212(s0)
ffffffffc020558c:	02978163          	beq	a5,s1,ffffffffc02055ae <do_wait.part.0+0x7c>
ffffffffc0205590:	6400                	ld	s0,8(s0)
        while ((le = list_next(le)) != list) {
ffffffffc0205592:	fe851be3          	bne	a0,s0,ffffffffc0205588 <do_wait.part.0+0x56>
    return -E_BAD_PROC;
ffffffffc0205596:	5579                	li	a0,-2
}
ffffffffc0205598:	60a6                	ld	ra,72(sp)
ffffffffc020559a:	6406                	ld	s0,64(sp)
ffffffffc020559c:	74e2                	ld	s1,56(sp)
ffffffffc020559e:	7942                	ld	s2,48(sp)
ffffffffc02055a0:	79a2                	ld	s3,40(sp)
ffffffffc02055a2:	7a02                	ld	s4,32(sp)
ffffffffc02055a4:	6ae2                	ld	s5,24(sp)
ffffffffc02055a6:	6b42                	ld	s6,16(sp)
ffffffffc02055a8:	6ba2                	ld	s7,8(sp)
ffffffffc02055aa:	6161                	addi	sp,sp,80
ffffffffc02055ac:	8082                	ret
        if (proc != NULL && proc->parent == current) {
ffffffffc02055ae:	000bb683          	ld	a3,0(s7)
ffffffffc02055b2:	f4843783          	ld	a5,-184(s0)
ffffffffc02055b6:	fed790e3          	bne	a5,a3,ffffffffc0205596 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055ba:	f2842703          	lw	a4,-216(s0)
ffffffffc02055be:	478d                	li	a5,3
ffffffffc02055c0:	0ef70b63          	beq	a4,a5,ffffffffc02056b6 <do_wait.part.0+0x184>
        current->state = PROC_SLEEPING;
ffffffffc02055c4:	4785                	li	a5,1
ffffffffc02055c6:	c29c                	sw	a5,0(a3)
        current->wait_state = WT_CHILD;
ffffffffc02055c8:	0f26a623          	sw	s2,236(a3)
        schedule();
ffffffffc02055cc:	2d7000ef          	jal	ra,ffffffffc02060a2 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02055d0:	000bb783          	ld	a5,0(s7)
ffffffffc02055d4:	0b07a783          	lw	a5,176(a5)
ffffffffc02055d8:	8b85                	andi	a5,a5,1
ffffffffc02055da:	d7c9                	beqz	a5,ffffffffc0205564 <do_wait.part.0+0x32>
            do_exit(-E_KILLED);
ffffffffc02055dc:	555d                	li	a0,-9
ffffffffc02055de:	e0bff0ef          	jal	ra,ffffffffc02053e8 <do_exit>
        proc = current->cptr;
ffffffffc02055e2:	000bb683          	ld	a3,0(s7)
ffffffffc02055e6:	7ae0                	ld	s0,240(a3)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055e8:	d45d                	beqz	s0,ffffffffc0205596 <do_wait.part.0+0x64>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055ea:	470d                	li	a4,3
ffffffffc02055ec:	a021                	j	ffffffffc02055f4 <do_wait.part.0+0xc2>
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055ee:	10043403          	ld	s0,256(s0)
ffffffffc02055f2:	d869                	beqz	s0,ffffffffc02055c4 <do_wait.part.0+0x92>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055f4:	401c                	lw	a5,0(s0)
ffffffffc02055f6:	fee79ce3          	bne	a5,a4,ffffffffc02055ee <do_wait.part.0+0xbc>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055fa:	000ad797          	auipc	a5,0xad
ffffffffc02055fe:	57e7b783          	ld	a5,1406(a5) # ffffffffc02b2b78 <idleproc>
ffffffffc0205602:	0c878963          	beq	a5,s0,ffffffffc02056d4 <do_wait.part.0+0x1a2>
ffffffffc0205606:	000ad797          	auipc	a5,0xad
ffffffffc020560a:	57a7b783          	ld	a5,1402(a5) # ffffffffc02b2b80 <initproc>
ffffffffc020560e:	0cf40363          	beq	s0,a5,ffffffffc02056d4 <do_wait.part.0+0x1a2>
    if (code_store != NULL) {
ffffffffc0205612:	000a0663          	beqz	s4,ffffffffc020561e <do_wait.part.0+0xec>
        *code_store = proc->exit_code;
ffffffffc0205616:	0e842783          	lw	a5,232(s0)
ffffffffc020561a:	00fa2023          	sw	a5,0(s4) # 1000 <_binary_obj___user_faultread_out_size-0x8be0>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020561e:	100027f3          	csrr	a5,sstatus
ffffffffc0205622:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205624:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205626:	e7c1                	bnez	a5,ffffffffc02056ae <do_wait.part.0+0x17c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205628:	6c70                	ld	a2,216(s0)
ffffffffc020562a:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020562c:	10043703          	ld	a4,256(s0)
        proc->optr->yptr = proc->yptr;
ffffffffc0205630:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205632:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205634:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205636:	6470                	ld	a2,200(s0)
ffffffffc0205638:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc020563a:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020563c:	e290                	sd	a2,0(a3)
    if (proc->optr != NULL) {
ffffffffc020563e:	c319                	beqz	a4,ffffffffc0205644 <do_wait.part.0+0x112>
        proc->optr->yptr = proc->yptr;
ffffffffc0205640:	ff7c                	sd	a5,248(a4)
    if (proc->yptr != NULL) {
ffffffffc0205642:	7c7c                	ld	a5,248(s0)
ffffffffc0205644:	c3b5                	beqz	a5,ffffffffc02056a8 <do_wait.part.0+0x176>
        proc->yptr->optr = proc->optr;
ffffffffc0205646:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc020564a:	000ad717          	auipc	a4,0xad
ffffffffc020564e:	53e70713          	addi	a4,a4,1342 # ffffffffc02b2b88 <nr_process>
ffffffffc0205652:	431c                	lw	a5,0(a4)
ffffffffc0205654:	37fd                	addiw	a5,a5,-1
ffffffffc0205656:	c31c                	sw	a5,0(a4)
    if (flag) {
ffffffffc0205658:	e5a9                	bnez	a1,ffffffffc02056a2 <do_wait.part.0+0x170>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020565a:	6814                	ld	a3,16(s0)
ffffffffc020565c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205660:	04f6ee63          	bltu	a3,a5,ffffffffc02056bc <do_wait.part.0+0x18a>
ffffffffc0205664:	000ad797          	auipc	a5,0xad
ffffffffc0205668:	4dc7b783          	ld	a5,1244(a5) # ffffffffc02b2b40 <va_pa_offset>
ffffffffc020566c:	8e9d                	sub	a3,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020566e:	82b1                	srli	a3,a3,0xc
ffffffffc0205670:	000ad797          	auipc	a5,0xad
ffffffffc0205674:	4b87b783          	ld	a5,1208(a5) # ffffffffc02b2b28 <npage>
ffffffffc0205678:	06f6fa63          	bgeu	a3,a5,ffffffffc02056ec <do_wait.part.0+0x1ba>
    return &pages[PPN(pa) - nbase];
ffffffffc020567c:	00003517          	auipc	a0,0x3
ffffffffc0205680:	6f453503          	ld	a0,1780(a0) # ffffffffc0208d70 <nbase>
ffffffffc0205684:	8e89                	sub	a3,a3,a0
ffffffffc0205686:	069a                	slli	a3,a3,0x6
ffffffffc0205688:	000ad517          	auipc	a0,0xad
ffffffffc020568c:	4a853503          	ld	a0,1192(a0) # ffffffffc02b2b30 <pages>
ffffffffc0205690:	9536                	add	a0,a0,a3
ffffffffc0205692:	4589                	li	a1,2
ffffffffc0205694:	edefc0ef          	jal	ra,ffffffffc0201d72 <free_pages>
    kfree(proc);
ffffffffc0205698:	8522                	mv	a0,s0
ffffffffc020569a:	d18fc0ef          	jal	ra,ffffffffc0201bb2 <kfree>
    return 0;
ffffffffc020569e:	4501                	li	a0,0
ffffffffc02056a0:	bde5                	j	ffffffffc0205598 <do_wait.part.0+0x66>
        intr_enable();
ffffffffc02056a2:	f9ffa0ef          	jal	ra,ffffffffc0200640 <intr_enable>
ffffffffc02056a6:	bf55                	j	ffffffffc020565a <do_wait.part.0+0x128>
       proc->parent->cptr = proc->optr;
ffffffffc02056a8:	701c                	ld	a5,32(s0)
ffffffffc02056aa:	fbf8                	sd	a4,240(a5)
ffffffffc02056ac:	bf79                	j	ffffffffc020564a <do_wait.part.0+0x118>
        intr_disable();
ffffffffc02056ae:	f99fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc02056b2:	4585                	li	a1,1
ffffffffc02056b4:	bf95                	j	ffffffffc0205628 <do_wait.part.0+0xf6>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02056b6:	f2840413          	addi	s0,s0,-216
ffffffffc02056ba:	b781                	j	ffffffffc02055fa <do_wait.part.0+0xc8>
    return pa2page(PADDR(kva));
ffffffffc02056bc:	00002617          	auipc	a2,0x2
ffffffffc02056c0:	e2c60613          	addi	a2,a2,-468 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc02056c4:	06e00593          	li	a1,110
ffffffffc02056c8:	00002517          	auipc	a0,0x2
ffffffffc02056cc:	da050513          	addi	a0,a0,-608 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc02056d0:	dabfa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("wait idleproc or initproc.\n");
ffffffffc02056d4:	00003617          	auipc	a2,0x3
ffffffffc02056d8:	e8460613          	addi	a2,a2,-380 # ffffffffc0208558 <default_pmm_manager+0x1150>
ffffffffc02056dc:	31000593          	li	a1,784
ffffffffc02056e0:	00003517          	auipc	a0,0x3
ffffffffc02056e4:	df850513          	addi	a0,a0,-520 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc02056e8:	d93fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056ec:	00002617          	auipc	a2,0x2
ffffffffc02056f0:	e2460613          	addi	a2,a2,-476 # ffffffffc0207510 <default_pmm_manager+0x108>
ffffffffc02056f4:	06200593          	li	a1,98
ffffffffc02056f8:	00002517          	auipc	a0,0x2
ffffffffc02056fc:	d7050513          	addi	a0,a0,-656 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0205700:	d7bfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205704 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205704:	1141                	addi	sp,sp,-16
ffffffffc0205706:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205708:	eaafc0ef          	jal	ra,ffffffffc0201db2 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020570c:	bf2fc0ef          	jal	ra,ffffffffc0201afe <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0205710:	4601                	li	a2,0
ffffffffc0205712:	4581                	li	a1,0
ffffffffc0205714:	fffff517          	auipc	a0,0xfffff
ffffffffc0205718:	74050513          	addi	a0,a0,1856 # ffffffffc0204e54 <user_main>
ffffffffc020571c:	c7dff0ef          	jal	ra,ffffffffc0205398 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205720:	00a04563          	bgtz	a0,ffffffffc020572a <init_main+0x26>
ffffffffc0205724:	a071                	j	ffffffffc02057b0 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205726:	17d000ef          	jal	ra,ffffffffc02060a2 <schedule>
    if (code_store != NULL) {
ffffffffc020572a:	4581                	li	a1,0
ffffffffc020572c:	4501                	li	a0,0
ffffffffc020572e:	e05ff0ef          	jal	ra,ffffffffc0205532 <do_wait.part.0>
    while (do_wait(0, NULL) == 0) {
ffffffffc0205732:	d975                	beqz	a0,ffffffffc0205726 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205734:	00003517          	auipc	a0,0x3
ffffffffc0205738:	e6450513          	addi	a0,a0,-412 # ffffffffc0208598 <default_pmm_manager+0x1190>
ffffffffc020573c:	a45fa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205740:	000ad797          	auipc	a5,0xad
ffffffffc0205744:	4407b783          	ld	a5,1088(a5) # ffffffffc02b2b80 <initproc>
ffffffffc0205748:	7bf8                	ld	a4,240(a5)
ffffffffc020574a:	e339                	bnez	a4,ffffffffc0205790 <init_main+0x8c>
ffffffffc020574c:	7ff8                	ld	a4,248(a5)
ffffffffc020574e:	e329                	bnez	a4,ffffffffc0205790 <init_main+0x8c>
ffffffffc0205750:	1007b703          	ld	a4,256(a5)
ffffffffc0205754:	ef15                	bnez	a4,ffffffffc0205790 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0205756:	000ad697          	auipc	a3,0xad
ffffffffc020575a:	4326a683          	lw	a3,1074(a3) # ffffffffc02b2b88 <nr_process>
ffffffffc020575e:	4709                	li	a4,2
ffffffffc0205760:	0ae69463          	bne	a3,a4,ffffffffc0205808 <init_main+0x104>
    return listelm->next;
ffffffffc0205764:	000ad697          	auipc	a3,0xad
ffffffffc0205768:	38468693          	addi	a3,a3,900 # ffffffffc02b2ae8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020576c:	6698                	ld	a4,8(a3)
ffffffffc020576e:	0c878793          	addi	a5,a5,200
ffffffffc0205772:	06f71b63          	bne	a4,a5,ffffffffc02057e8 <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205776:	629c                	ld	a5,0(a3)
ffffffffc0205778:	04f71863          	bne	a4,a5,ffffffffc02057c8 <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc020577c:	00003517          	auipc	a0,0x3
ffffffffc0205780:	f0450513          	addi	a0,a0,-252 # ffffffffc0208680 <default_pmm_manager+0x1278>
ffffffffc0205784:	9fdfa0ef          	jal	ra,ffffffffc0200180 <cprintf>
    return 0;
}
ffffffffc0205788:	60a2                	ld	ra,8(sp)
ffffffffc020578a:	4501                	li	a0,0
ffffffffc020578c:	0141                	addi	sp,sp,16
ffffffffc020578e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205790:	00003697          	auipc	a3,0x3
ffffffffc0205794:	e3068693          	addi	a3,a3,-464 # ffffffffc02085c0 <default_pmm_manager+0x11b8>
ffffffffc0205798:	00001617          	auipc	a2,0x1
ffffffffc020579c:	5d860613          	addi	a2,a2,1496 # ffffffffc0206d70 <commands+0x450>
ffffffffc02057a0:	37500593          	li	a1,885
ffffffffc02057a4:	00003517          	auipc	a0,0x3
ffffffffc02057a8:	d3450513          	addi	a0,a0,-716 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc02057ac:	ccffa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("create user_main failed.\n");
ffffffffc02057b0:	00003617          	auipc	a2,0x3
ffffffffc02057b4:	dc860613          	addi	a2,a2,-568 # ffffffffc0208578 <default_pmm_manager+0x1170>
ffffffffc02057b8:	36d00593          	li	a1,877
ffffffffc02057bc:	00003517          	auipc	a0,0x3
ffffffffc02057c0:	d1c50513          	addi	a0,a0,-740 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc02057c4:	cb7fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057c8:	00003697          	auipc	a3,0x3
ffffffffc02057cc:	e8868693          	addi	a3,a3,-376 # ffffffffc0208650 <default_pmm_manager+0x1248>
ffffffffc02057d0:	00001617          	auipc	a2,0x1
ffffffffc02057d4:	5a060613          	addi	a2,a2,1440 # ffffffffc0206d70 <commands+0x450>
ffffffffc02057d8:	37800593          	li	a1,888
ffffffffc02057dc:	00003517          	auipc	a0,0x3
ffffffffc02057e0:	cfc50513          	addi	a0,a0,-772 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc02057e4:	c97fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057e8:	00003697          	auipc	a3,0x3
ffffffffc02057ec:	e3868693          	addi	a3,a3,-456 # ffffffffc0208620 <default_pmm_manager+0x1218>
ffffffffc02057f0:	00001617          	auipc	a2,0x1
ffffffffc02057f4:	58060613          	addi	a2,a2,1408 # ffffffffc0206d70 <commands+0x450>
ffffffffc02057f8:	37700593          	li	a1,887
ffffffffc02057fc:	00003517          	auipc	a0,0x3
ffffffffc0205800:	cdc50513          	addi	a0,a0,-804 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205804:	c77fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(nr_process == 2);
ffffffffc0205808:	00003697          	auipc	a3,0x3
ffffffffc020580c:	e0868693          	addi	a3,a3,-504 # ffffffffc0208610 <default_pmm_manager+0x1208>
ffffffffc0205810:	00001617          	auipc	a2,0x1
ffffffffc0205814:	56060613          	addi	a2,a2,1376 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205818:	37600593          	li	a1,886
ffffffffc020581c:	00003517          	auipc	a0,0x3
ffffffffc0205820:	cbc50513          	addi	a0,a0,-836 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205824:	c57fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205828 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205828:	7171                	addi	sp,sp,-176
ffffffffc020582a:	e4ee                	sd	s11,72(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020582c:	000add97          	auipc	s11,0xad
ffffffffc0205830:	344d8d93          	addi	s11,s11,836 # ffffffffc02b2b70 <current>
ffffffffc0205834:	000db783          	ld	a5,0(s11)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205838:	e54e                	sd	s3,136(sp)
ffffffffc020583a:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020583c:	0287b983          	ld	s3,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205840:	e94a                	sd	s2,144(sp)
ffffffffc0205842:	f4de                	sd	s7,104(sp)
ffffffffc0205844:	892a                	mv	s2,a0
ffffffffc0205846:	8bb2                	mv	s7,a2
ffffffffc0205848:	84ae                	mv	s1,a1
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020584a:	862e                	mv	a2,a1
ffffffffc020584c:	4681                	li	a3,0
ffffffffc020584e:	85aa                	mv	a1,a0
ffffffffc0205850:	854e                	mv	a0,s3
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205852:	f506                	sd	ra,168(sp)
ffffffffc0205854:	f122                	sd	s0,160(sp)
ffffffffc0205856:	e152                	sd	s4,128(sp)
ffffffffc0205858:	fcd6                	sd	s5,120(sp)
ffffffffc020585a:	f8da                	sd	s6,112(sp)
ffffffffc020585c:	f0e2                	sd	s8,96(sp)
ffffffffc020585e:	ece6                	sd	s9,88(sp)
ffffffffc0205860:	e8ea                	sd	s10,80(sp)
ffffffffc0205862:	f05e                	sd	s7,32(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205864:	b76ff0ef          	jal	ra,ffffffffc0204bda <user_mem_check>
ffffffffc0205868:	40050a63          	beqz	a0,ffffffffc0205c7c <do_execve+0x454>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020586c:	4641                	li	a2,16
ffffffffc020586e:	4581                	li	a1,0
ffffffffc0205870:	1808                	addi	a0,sp,48
ffffffffc0205872:	61d000ef          	jal	ra,ffffffffc020668e <memset>
    memcpy(local_name, name, len);
ffffffffc0205876:	47bd                	li	a5,15
ffffffffc0205878:	8626                	mv	a2,s1
ffffffffc020587a:	1e97e263          	bltu	a5,s1,ffffffffc0205a5e <do_execve+0x236>
ffffffffc020587e:	85ca                	mv	a1,s2
ffffffffc0205880:	1808                	addi	a0,sp,48
ffffffffc0205882:	61f000ef          	jal	ra,ffffffffc02066a0 <memcpy>
    if (mm != NULL) {
ffffffffc0205886:	1e098363          	beqz	s3,ffffffffc0205a6c <do_execve+0x244>
        cputs("mm != NULL");
ffffffffc020588a:	00002517          	auipc	a0,0x2
ffffffffc020588e:	30650513          	addi	a0,a0,774 # ffffffffc0207b90 <default_pmm_manager+0x788>
ffffffffc0205892:	927fa0ef          	jal	ra,ffffffffc02001b8 <cputs>
ffffffffc0205896:	000ad797          	auipc	a5,0xad
ffffffffc020589a:	2827b783          	ld	a5,642(a5) # ffffffffc02b2b18 <boot_cr3>
ffffffffc020589e:	577d                	li	a4,-1
ffffffffc02058a0:	177e                	slli	a4,a4,0x3f
ffffffffc02058a2:	83b1                	srli	a5,a5,0xc
ffffffffc02058a4:	8fd9                	or	a5,a5,a4
ffffffffc02058a6:	18079073          	csrw	satp,a5
ffffffffc02058aa:	0309a783          	lw	a5,48(s3) # 2030 <_binary_obj___user_faultread_out_size-0x7bb0>
ffffffffc02058ae:	fff7871b          	addiw	a4,a5,-1
ffffffffc02058b2:	02e9a823          	sw	a4,48(s3)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058b6:	2c070463          	beqz	a4,ffffffffc0205b7e <do_execve+0x356>
        current->mm = NULL;
ffffffffc02058ba:	000db783          	ld	a5,0(s11)
ffffffffc02058be:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058c2:	8b1fe0ef          	jal	ra,ffffffffc0204172 <mm_create>
ffffffffc02058c6:	84aa                	mv	s1,a0
ffffffffc02058c8:	1c050d63          	beqz	a0,ffffffffc0205aa2 <do_execve+0x27a>
    if ((page = alloc_page()) == NULL) {
ffffffffc02058cc:	4505                	li	a0,1
ffffffffc02058ce:	c12fc0ef          	jal	ra,ffffffffc0201ce0 <alloc_pages>
ffffffffc02058d2:	3a050963          	beqz	a0,ffffffffc0205c84 <do_execve+0x45c>
    return page - pages + nbase;
ffffffffc02058d6:	000adc97          	auipc	s9,0xad
ffffffffc02058da:	25ac8c93          	addi	s9,s9,602 # ffffffffc02b2b30 <pages>
ffffffffc02058de:	000cb683          	ld	a3,0(s9)
    return KADDR(page2pa(page));
ffffffffc02058e2:	000adc17          	auipc	s8,0xad
ffffffffc02058e6:	246c0c13          	addi	s8,s8,582 # ffffffffc02b2b28 <npage>
    return page - pages + nbase;
ffffffffc02058ea:	00003717          	auipc	a4,0x3
ffffffffc02058ee:	48673703          	ld	a4,1158(a4) # ffffffffc0208d70 <nbase>
ffffffffc02058f2:	40d506b3          	sub	a3,a0,a3
ffffffffc02058f6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058f8:	5afd                	li	s5,-1
ffffffffc02058fa:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc02058fe:	96ba                	add	a3,a3,a4
ffffffffc0205900:	e83a                	sd	a4,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205902:	00cad713          	srli	a4,s5,0xc
ffffffffc0205906:	ec3a                	sd	a4,24(sp)
ffffffffc0205908:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020590a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020590c:	38f77063          	bgeu	a4,a5,ffffffffc0205c8c <do_execve+0x464>
ffffffffc0205910:	000adb17          	auipc	s6,0xad
ffffffffc0205914:	230b0b13          	addi	s6,s6,560 # ffffffffc02b2b40 <va_pa_offset>
ffffffffc0205918:	000b3903          	ld	s2,0(s6)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc020591c:	6605                	lui	a2,0x1
ffffffffc020591e:	000ad597          	auipc	a1,0xad
ffffffffc0205922:	2025b583          	ld	a1,514(a1) # ffffffffc02b2b20 <boot_pgdir>
ffffffffc0205926:	9936                	add	s2,s2,a3
ffffffffc0205928:	854a                	mv	a0,s2
ffffffffc020592a:	577000ef          	jal	ra,ffffffffc02066a0 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020592e:	7782                	ld	a5,32(sp)
ffffffffc0205930:	4398                	lw	a4,0(a5)
ffffffffc0205932:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205936:	0124bc23          	sd	s2,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc020593a:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9427>
ffffffffc020593e:	14f71863          	bne	a4,a5,ffffffffc0205a8e <do_execve+0x266>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205942:	7682                	ld	a3,32(sp)
ffffffffc0205944:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205948:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020594c:	00371793          	slli	a5,a4,0x3
ffffffffc0205950:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205952:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205954:	078e                	slli	a5,a5,0x3
ffffffffc0205956:	97ce                	add	a5,a5,s3
ffffffffc0205958:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc020595a:	00f9fc63          	bgeu	s3,a5,ffffffffc0205972 <do_execve+0x14a>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc020595e:	0009a783          	lw	a5,0(s3)
ffffffffc0205962:	4705                	li	a4,1
ffffffffc0205964:	14e78163          	beq	a5,a4,ffffffffc0205aa6 <do_execve+0x27e>
    for (; ph < ph_end; ph ++) {
ffffffffc0205968:	77a2                	ld	a5,40(sp)
ffffffffc020596a:	03898993          	addi	s3,s3,56
ffffffffc020596e:	fef9e8e3          	bltu	s3,a5,ffffffffc020595e <do_execve+0x136>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205972:	4701                	li	a4,0
ffffffffc0205974:	46ad                	li	a3,11
ffffffffc0205976:	00100637          	lui	a2,0x100
ffffffffc020597a:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020597e:	8526                	mv	a0,s1
ffffffffc0205980:	9cbfe0ef          	jal	ra,ffffffffc020434a <mm_map>
ffffffffc0205984:	8a2a                	mv	s4,a0
ffffffffc0205986:	1e051263          	bnez	a0,ffffffffc0205b6a <do_execve+0x342>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc020598a:	6c88                	ld	a0,24(s1)
ffffffffc020598c:	467d                	li	a2,31
ffffffffc020598e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205992:	9f1fd0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc0205996:	38050363          	beqz	a0,ffffffffc0205d1c <do_execve+0x4f4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc020599a:	6c88                	ld	a0,24(s1)
ffffffffc020599c:	467d                	li	a2,31
ffffffffc020599e:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02059a2:	9e1fd0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc02059a6:	34050b63          	beqz	a0,ffffffffc0205cfc <do_execve+0x4d4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059aa:	6c88                	ld	a0,24(s1)
ffffffffc02059ac:	467d                	li	a2,31
ffffffffc02059ae:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059b2:	9d1fd0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc02059b6:	32050363          	beqz	a0,ffffffffc0205cdc <do_execve+0x4b4>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059ba:	6c88                	ld	a0,24(s1)
ffffffffc02059bc:	467d                	li	a2,31
ffffffffc02059be:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059c2:	9c1fd0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc02059c6:	2e050b63          	beqz	a0,ffffffffc0205cbc <do_execve+0x494>
    mm->mm_count += 1;
ffffffffc02059ca:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc02059cc:	000db603          	ld	a2,0(s11)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d0:	6c94                	ld	a3,24(s1)
ffffffffc02059d2:	2785                	addiw	a5,a5,1
ffffffffc02059d4:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc02059d6:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02059dc:	2cf6e463          	bltu	a3,a5,ffffffffc0205ca4 <do_execve+0x47c>
ffffffffc02059e0:	000b3783          	ld	a5,0(s6)
ffffffffc02059e4:	577d                	li	a4,-1
ffffffffc02059e6:	177e                	slli	a4,a4,0x3f
ffffffffc02059e8:	8e9d                	sub	a3,a3,a5
ffffffffc02059ea:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059ee:	f654                	sd	a3,168(a2)
ffffffffc02059f0:	8fd9                	or	a5,a5,a4
ffffffffc02059f2:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059f6:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059f8:	4581                	li	a1,0
ffffffffc02059fa:	12000613          	li	a2,288
ffffffffc02059fe:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a00:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a04:	48b000ef          	jal	ra,ffffffffc020668e <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a08:	7782                	ld	a5,32(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a0a:	000db903          	ld	s2,0(s11)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a0e:	edf4f493          	andi	s1,s1,-289
    tf->epc = elf->e_entry;
ffffffffc0205a12:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a14:	4785                	li	a5,1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a16:	0b490913          	addi	s2,s2,180 # ffffffff800000b4 <_binary_obj___user_exit_out_size+0xffffffff7fff4f5c>
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a1a:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a1c:	0204e493          	ori	s1,s1,32
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a20:	4641                	li	a2,16
ffffffffc0205a22:	4581                	li	a1,0
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a24:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a26:	10e43423          	sd	a4,264(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205a2a:	10943023          	sd	s1,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a2e:	854a                	mv	a0,s2
ffffffffc0205a30:	45f000ef          	jal	ra,ffffffffc020668e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205a34:	463d                	li	a2,15
ffffffffc0205a36:	180c                	addi	a1,sp,48
ffffffffc0205a38:	854a                	mv	a0,s2
ffffffffc0205a3a:	467000ef          	jal	ra,ffffffffc02066a0 <memcpy>
}
ffffffffc0205a3e:	70aa                	ld	ra,168(sp)
ffffffffc0205a40:	740a                	ld	s0,160(sp)
ffffffffc0205a42:	64ea                	ld	s1,152(sp)
ffffffffc0205a44:	694a                	ld	s2,144(sp)
ffffffffc0205a46:	69aa                	ld	s3,136(sp)
ffffffffc0205a48:	7ae6                	ld	s5,120(sp)
ffffffffc0205a4a:	7b46                	ld	s6,112(sp)
ffffffffc0205a4c:	7ba6                	ld	s7,104(sp)
ffffffffc0205a4e:	7c06                	ld	s8,96(sp)
ffffffffc0205a50:	6ce6                	ld	s9,88(sp)
ffffffffc0205a52:	6d46                	ld	s10,80(sp)
ffffffffc0205a54:	6da6                	ld	s11,72(sp)
ffffffffc0205a56:	8552                	mv	a0,s4
ffffffffc0205a58:	6a0a                	ld	s4,128(sp)
ffffffffc0205a5a:	614d                	addi	sp,sp,176
ffffffffc0205a5c:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205a5e:	463d                	li	a2,15
ffffffffc0205a60:	85ca                	mv	a1,s2
ffffffffc0205a62:	1808                	addi	a0,sp,48
ffffffffc0205a64:	43d000ef          	jal	ra,ffffffffc02066a0 <memcpy>
    if (mm != NULL) {
ffffffffc0205a68:	e20991e3          	bnez	s3,ffffffffc020588a <do_execve+0x62>
    if (current->mm != NULL) {
ffffffffc0205a6c:	000db783          	ld	a5,0(s11)
ffffffffc0205a70:	779c                	ld	a5,40(a5)
ffffffffc0205a72:	e40788e3          	beqz	a5,ffffffffc02058c2 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205a76:	00003617          	auipc	a2,0x3
ffffffffc0205a7a:	c2a60613          	addi	a2,a2,-982 # ffffffffc02086a0 <default_pmm_manager+0x1298>
ffffffffc0205a7e:	21f00593          	li	a1,543
ffffffffc0205a82:	00003517          	auipc	a0,0x3
ffffffffc0205a86:	a5650513          	addi	a0,a0,-1450 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205a8a:	9f1fa0ef          	jal	ra,ffffffffc020047a <__panic>
    put_pgdir(mm);
ffffffffc0205a8e:	8526                	mv	a0,s1
ffffffffc0205a90:	c42ff0ef          	jal	ra,ffffffffc0204ed2 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205a94:	8526                	mv	a0,s1
ffffffffc0205a96:	863fe0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205a9a:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205a9c:	8552                	mv	a0,s4
ffffffffc0205a9e:	94bff0ef          	jal	ra,ffffffffc02053e8 <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205aa2:	5a71                	li	s4,-4
ffffffffc0205aa4:	bfe5                	j	ffffffffc0205a9c <do_execve+0x274>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205aa6:	0289b603          	ld	a2,40(s3)
ffffffffc0205aaa:	0209b783          	ld	a5,32(s3)
ffffffffc0205aae:	1cf66d63          	bltu	a2,a5,ffffffffc0205c88 <do_execve+0x460>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205ab2:	0049a783          	lw	a5,4(s3)
ffffffffc0205ab6:	0017f693          	andi	a3,a5,1
ffffffffc0205aba:	c291                	beqz	a3,ffffffffc0205abe <do_execve+0x296>
ffffffffc0205abc:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205abe:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ac2:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ac4:	e779                	bnez	a4,ffffffffc0205b92 <do_execve+0x36a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205ac6:	4d45                	li	s10,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ac8:	c781                	beqz	a5,ffffffffc0205ad0 <do_execve+0x2a8>
ffffffffc0205aca:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205ace:	4d4d                	li	s10,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205ad0:	0026f793          	andi	a5,a3,2
ffffffffc0205ad4:	e3f1                	bnez	a5,ffffffffc0205b98 <do_execve+0x370>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205ad6:	0046f793          	andi	a5,a3,4
ffffffffc0205ada:	c399                	beqz	a5,ffffffffc0205ae0 <do_execve+0x2b8>
ffffffffc0205adc:	008d6d13          	ori	s10,s10,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205ae0:	0109b583          	ld	a1,16(s3)
ffffffffc0205ae4:	4701                	li	a4,0
ffffffffc0205ae6:	8526                	mv	a0,s1
ffffffffc0205ae8:	863fe0ef          	jal	ra,ffffffffc020434a <mm_map>
ffffffffc0205aec:	8a2a                	mv	s4,a0
ffffffffc0205aee:	ed35                	bnez	a0,ffffffffc0205b6a <do_execve+0x342>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205af0:	0109bb83          	ld	s7,16(s3)
ffffffffc0205af4:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205af6:	0209ba03          	ld	s4,32(s3)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205afa:	0089b903          	ld	s2,8(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205afe:	00fbfab3          	and	s5,s7,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b02:	7782                	ld	a5,32(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205b04:	9a5e                	add	s4,s4,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205b06:	993e                	add	s2,s2,a5
        while (start < end) {
ffffffffc0205b08:	054be963          	bltu	s7,s4,ffffffffc0205b5a <do_execve+0x332>
ffffffffc0205b0c:	aa95                	j	ffffffffc0205c80 <do_execve+0x458>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b0e:	6785                	lui	a5,0x1
ffffffffc0205b10:	415b8533          	sub	a0,s7,s5
ffffffffc0205b14:	9abe                	add	s5,s5,a5
ffffffffc0205b16:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205b1a:	015a7463          	bgeu	s4,s5,ffffffffc0205b22 <do_execve+0x2fa>
                size -= la - end;
ffffffffc0205b1e:	417a0633          	sub	a2,s4,s7
    return page - pages + nbase;
ffffffffc0205b22:	000cb683          	ld	a3,0(s9)
ffffffffc0205b26:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205b28:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205b2c:	40d406b3          	sub	a3,s0,a3
ffffffffc0205b30:	8699                	srai	a3,a3,0x6
ffffffffc0205b32:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205b34:	67e2                	ld	a5,24(sp)
ffffffffc0205b36:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b3a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b3c:	14b87863          	bgeu	a6,a1,ffffffffc0205c8c <do_execve+0x464>
ffffffffc0205b40:	000b3803          	ld	a6,0(s6)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b44:	85ca                	mv	a1,s2
            start += size, from += size;
ffffffffc0205b46:	9bb2                	add	s7,s7,a2
ffffffffc0205b48:	96c2                	add	a3,a3,a6
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b4a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b4c:	e432                	sd	a2,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b4e:	353000ef          	jal	ra,ffffffffc02066a0 <memcpy>
            start += size, from += size;
ffffffffc0205b52:	6622                	ld	a2,8(sp)
ffffffffc0205b54:	9932                	add	s2,s2,a2
        while (start < end) {
ffffffffc0205b56:	054bf363          	bgeu	s7,s4,ffffffffc0205b9c <do_execve+0x374>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b5a:	6c88                	ld	a0,24(s1)
ffffffffc0205b5c:	866a                	mv	a2,s10
ffffffffc0205b5e:	85d6                	mv	a1,s5
ffffffffc0205b60:	823fd0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc0205b64:	842a                	mv	s0,a0
ffffffffc0205b66:	f545                	bnez	a0,ffffffffc0205b0e <do_execve+0x2e6>
        ret = -E_NO_MEM;
ffffffffc0205b68:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205b6a:	8526                	mv	a0,s1
ffffffffc0205b6c:	929fe0ef          	jal	ra,ffffffffc0204494 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b70:	8526                	mv	a0,s1
ffffffffc0205b72:	b60ff0ef          	jal	ra,ffffffffc0204ed2 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b76:	8526                	mv	a0,s1
ffffffffc0205b78:	f80fe0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
    return ret;
ffffffffc0205b7c:	b705                	j	ffffffffc0205a9c <do_execve+0x274>
            exit_mmap(mm);
ffffffffc0205b7e:	854e                	mv	a0,s3
ffffffffc0205b80:	915fe0ef          	jal	ra,ffffffffc0204494 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b84:	854e                	mv	a0,s3
ffffffffc0205b86:	b4cff0ef          	jal	ra,ffffffffc0204ed2 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b8a:	854e                	mv	a0,s3
ffffffffc0205b8c:	f6cfe0ef          	jal	ra,ffffffffc02042f8 <mm_destroy>
ffffffffc0205b90:	b32d                	j	ffffffffc02058ba <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b92:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b96:	fb95                	bnez	a5,ffffffffc0205aca <do_execve+0x2a2>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b98:	4d5d                	li	s10,23
ffffffffc0205b9a:	bf35                	j	ffffffffc0205ad6 <do_execve+0x2ae>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b9c:	0109b683          	ld	a3,16(s3)
ffffffffc0205ba0:	0289b903          	ld	s2,40(s3)
ffffffffc0205ba4:	9936                	add	s2,s2,a3
        if (start < la) {
ffffffffc0205ba6:	075bfd63          	bgeu	s7,s5,ffffffffc0205c20 <do_execve+0x3f8>
            if (start == end) {
ffffffffc0205baa:	db790fe3          	beq	s2,s7,ffffffffc0205968 <do_execve+0x140>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205bae:	6785                	lui	a5,0x1
ffffffffc0205bb0:	00fb8533          	add	a0,s7,a5
ffffffffc0205bb4:	41550533          	sub	a0,a0,s5
                size -= la - end;
ffffffffc0205bb8:	41790a33          	sub	s4,s2,s7
            if (end < la) {
ffffffffc0205bbc:	0b597d63          	bgeu	s2,s5,ffffffffc0205c76 <do_execve+0x44e>
    return page - pages + nbase;
ffffffffc0205bc0:	000cb683          	ld	a3,0(s9)
ffffffffc0205bc4:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205bc6:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0205bca:	40d406b3          	sub	a3,s0,a3
ffffffffc0205bce:	8699                	srai	a3,a3,0x6
ffffffffc0205bd0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205bd2:	67e2                	ld	a5,24(sp)
ffffffffc0205bd4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bd8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bda:	0ac5f963          	bgeu	a1,a2,ffffffffc0205c8c <do_execve+0x464>
ffffffffc0205bde:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205be2:	8652                	mv	a2,s4
ffffffffc0205be4:	4581                	li	a1,0
ffffffffc0205be6:	96c2                	add	a3,a3,a6
ffffffffc0205be8:	9536                	add	a0,a0,a3
ffffffffc0205bea:	2a5000ef          	jal	ra,ffffffffc020668e <memset>
            start += size;
ffffffffc0205bee:	017a0733          	add	a4,s4,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bf2:	03597463          	bgeu	s2,s5,ffffffffc0205c1a <do_execve+0x3f2>
ffffffffc0205bf6:	d6e909e3          	beq	s2,a4,ffffffffc0205968 <do_execve+0x140>
ffffffffc0205bfa:	00003697          	auipc	a3,0x3
ffffffffc0205bfe:	ace68693          	addi	a3,a3,-1330 # ffffffffc02086c8 <default_pmm_manager+0x12c0>
ffffffffc0205c02:	00001617          	auipc	a2,0x1
ffffffffc0205c06:	16e60613          	addi	a2,a2,366 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205c0a:	27400593          	li	a1,628
ffffffffc0205c0e:	00003517          	auipc	a0,0x3
ffffffffc0205c12:	8ca50513          	addi	a0,a0,-1846 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205c16:	865fa0ef          	jal	ra,ffffffffc020047a <__panic>
ffffffffc0205c1a:	ff5710e3          	bne	a4,s5,ffffffffc0205bfa <do_execve+0x3d2>
ffffffffc0205c1e:	8bd6                	mv	s7,s5
        while (start < end) {
ffffffffc0205c20:	d52bf4e3          	bgeu	s7,s2,ffffffffc0205968 <do_execve+0x140>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c24:	6c88                	ld	a0,24(s1)
ffffffffc0205c26:	866a                	mv	a2,s10
ffffffffc0205c28:	85d6                	mv	a1,s5
ffffffffc0205c2a:	f58fd0ef          	jal	ra,ffffffffc0203382 <pgdir_alloc_page>
ffffffffc0205c2e:	842a                	mv	s0,a0
ffffffffc0205c30:	dd05                	beqz	a0,ffffffffc0205b68 <do_execve+0x340>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c32:	6785                	lui	a5,0x1
ffffffffc0205c34:	415b8533          	sub	a0,s7,s5
ffffffffc0205c38:	9abe                	add	s5,s5,a5
ffffffffc0205c3a:	417a8633          	sub	a2,s5,s7
            if (end < la) {
ffffffffc0205c3e:	01597463          	bgeu	s2,s5,ffffffffc0205c46 <do_execve+0x41e>
                size -= la - end;
ffffffffc0205c42:	41790633          	sub	a2,s2,s7
    return page - pages + nbase;
ffffffffc0205c46:	000cb683          	ld	a3,0(s9)
ffffffffc0205c4a:	67c2                	ld	a5,16(sp)
    return KADDR(page2pa(page));
ffffffffc0205c4c:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0205c50:	40d406b3          	sub	a3,s0,a3
ffffffffc0205c54:	8699                	srai	a3,a3,0x6
ffffffffc0205c56:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c58:	67e2                	ld	a5,24(sp)
ffffffffc0205c5a:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c5e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c60:	02b87663          	bgeu	a6,a1,ffffffffc0205c8c <do_execve+0x464>
ffffffffc0205c64:	000b3803          	ld	a6,0(s6)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c68:	4581                	li	a1,0
            start += size;
ffffffffc0205c6a:	9bb2                	add	s7,s7,a2
ffffffffc0205c6c:	96c2                	add	a3,a3,a6
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c6e:	9536                	add	a0,a0,a3
ffffffffc0205c70:	21f000ef          	jal	ra,ffffffffc020668e <memset>
ffffffffc0205c74:	b775                	j	ffffffffc0205c20 <do_execve+0x3f8>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c76:	417a8a33          	sub	s4,s5,s7
ffffffffc0205c7a:	b799                	j	ffffffffc0205bc0 <do_execve+0x398>
        return -E_INVAL;
ffffffffc0205c7c:	5a75                	li	s4,-3
ffffffffc0205c7e:	b3c1                	j	ffffffffc0205a3e <do_execve+0x216>
        while (start < end) {
ffffffffc0205c80:	86de                	mv	a3,s7
ffffffffc0205c82:	bf39                	j	ffffffffc0205ba0 <do_execve+0x378>
    int ret = -E_NO_MEM;
ffffffffc0205c84:	5a71                	li	s4,-4
ffffffffc0205c86:	bdc5                	j	ffffffffc0205b76 <do_execve+0x34e>
            ret = -E_INVAL_ELF;
ffffffffc0205c88:	5a61                	li	s4,-8
ffffffffc0205c8a:	b5c5                	j	ffffffffc0205b6a <do_execve+0x342>
ffffffffc0205c8c:	00001617          	auipc	a2,0x1
ffffffffc0205c90:	7b460613          	addi	a2,a2,1972 # ffffffffc0207440 <default_pmm_manager+0x38>
ffffffffc0205c94:	06900593          	li	a1,105
ffffffffc0205c98:	00001517          	auipc	a0,0x1
ffffffffc0205c9c:	7d050513          	addi	a0,a0,2000 # ffffffffc0207468 <default_pmm_manager+0x60>
ffffffffc0205ca0:	fdafa0ef          	jal	ra,ffffffffc020047a <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205ca4:	00002617          	auipc	a2,0x2
ffffffffc0205ca8:	84460613          	addi	a2,a2,-1980 # ffffffffc02074e8 <default_pmm_manager+0xe0>
ffffffffc0205cac:	28f00593          	li	a1,655
ffffffffc0205cb0:	00003517          	auipc	a0,0x3
ffffffffc0205cb4:	82850513          	addi	a0,a0,-2008 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205cb8:	fc2fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cbc:	00003697          	auipc	a3,0x3
ffffffffc0205cc0:	b2468693          	addi	a3,a3,-1244 # ffffffffc02087e0 <default_pmm_manager+0x13d8>
ffffffffc0205cc4:	00001617          	auipc	a2,0x1
ffffffffc0205cc8:	0ac60613          	addi	a2,a2,172 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205ccc:	28a00593          	li	a1,650
ffffffffc0205cd0:	00003517          	auipc	a0,0x3
ffffffffc0205cd4:	80850513          	addi	a0,a0,-2040 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205cd8:	fa2fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cdc:	00003697          	auipc	a3,0x3
ffffffffc0205ce0:	abc68693          	addi	a3,a3,-1348 # ffffffffc0208798 <default_pmm_manager+0x1390>
ffffffffc0205ce4:	00001617          	auipc	a2,0x1
ffffffffc0205ce8:	08c60613          	addi	a2,a2,140 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205cec:	28900593          	li	a1,649
ffffffffc0205cf0:	00002517          	auipc	a0,0x2
ffffffffc0205cf4:	7e850513          	addi	a0,a0,2024 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205cf8:	f82fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cfc:	00003697          	auipc	a3,0x3
ffffffffc0205d00:	a5468693          	addi	a3,a3,-1452 # ffffffffc0208750 <default_pmm_manager+0x1348>
ffffffffc0205d04:	00001617          	auipc	a2,0x1
ffffffffc0205d08:	06c60613          	addi	a2,a2,108 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205d0c:	28800593          	li	a1,648
ffffffffc0205d10:	00002517          	auipc	a0,0x2
ffffffffc0205d14:	7c850513          	addi	a0,a0,1992 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205d18:	f62fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205d1c:	00003697          	auipc	a3,0x3
ffffffffc0205d20:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0208708 <default_pmm_manager+0x1300>
ffffffffc0205d24:	00001617          	auipc	a2,0x1
ffffffffc0205d28:	04c60613          	addi	a2,a2,76 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205d2c:	28700593          	li	a1,647
ffffffffc0205d30:	00002517          	auipc	a0,0x2
ffffffffc0205d34:	7a850513          	addi	a0,a0,1960 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205d38:	f42fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205d3c <do_yield>:
    current->need_resched = 1;
ffffffffc0205d3c:	000ad797          	auipc	a5,0xad
ffffffffc0205d40:	e347b783          	ld	a5,-460(a5) # ffffffffc02b2b70 <current>
ffffffffc0205d44:	4705                	li	a4,1
ffffffffc0205d46:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d48:	4501                	li	a0,0
ffffffffc0205d4a:	8082                	ret

ffffffffc0205d4c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d4c:	1101                	addi	sp,sp,-32
ffffffffc0205d4e:	e822                	sd	s0,16(sp)
ffffffffc0205d50:	e426                	sd	s1,8(sp)
ffffffffc0205d52:	ec06                	sd	ra,24(sp)
ffffffffc0205d54:	842e                	mv	s0,a1
ffffffffc0205d56:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d58:	c999                	beqz	a1,ffffffffc0205d6e <do_wait+0x22>
    struct mm_struct *mm = current->mm;
ffffffffc0205d5a:	000ad797          	auipc	a5,0xad
ffffffffc0205d5e:	e167b783          	ld	a5,-490(a5) # ffffffffc02b2b70 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d62:	7788                	ld	a0,40(a5)
ffffffffc0205d64:	4685                	li	a3,1
ffffffffc0205d66:	4611                	li	a2,4
ffffffffc0205d68:	e73fe0ef          	jal	ra,ffffffffc0204bda <user_mem_check>
ffffffffc0205d6c:	c909                	beqz	a0,ffffffffc0205d7e <do_wait+0x32>
ffffffffc0205d6e:	85a2                	mv	a1,s0
}
ffffffffc0205d70:	6442                	ld	s0,16(sp)
ffffffffc0205d72:	60e2                	ld	ra,24(sp)
ffffffffc0205d74:	8526                	mv	a0,s1
ffffffffc0205d76:	64a2                	ld	s1,8(sp)
ffffffffc0205d78:	6105                	addi	sp,sp,32
ffffffffc0205d7a:	fb8ff06f          	j	ffffffffc0205532 <do_wait.part.0>
ffffffffc0205d7e:	60e2                	ld	ra,24(sp)
ffffffffc0205d80:	6442                	ld	s0,16(sp)
ffffffffc0205d82:	64a2                	ld	s1,8(sp)
ffffffffc0205d84:	5575                	li	a0,-3
ffffffffc0205d86:	6105                	addi	sp,sp,32
ffffffffc0205d88:	8082                	ret

ffffffffc0205d8a <do_kill>:
do_kill(int pid) {
ffffffffc0205d8a:	1141                	addi	sp,sp,-16
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d8c:	6789                	lui	a5,0x2
do_kill(int pid) {
ffffffffc0205d8e:	e406                	sd	ra,8(sp)
ffffffffc0205d90:	e022                	sd	s0,0(sp)
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205d92:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205d96:	17f9                	addi	a5,a5,-2
ffffffffc0205d98:	02e7e963          	bltu	a5,a4,ffffffffc0205dca <do_kill+0x40>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205d9c:	842a                	mv	s0,a0
ffffffffc0205d9e:	45a9                	li	a1,10
ffffffffc0205da0:	2501                	sext.w	a0,a0
ffffffffc0205da2:	46c000ef          	jal	ra,ffffffffc020620e <hash32>
ffffffffc0205da6:	02051793          	slli	a5,a0,0x20
ffffffffc0205daa:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205dae:	000a9797          	auipc	a5,0xa9
ffffffffc0205db2:	d3a78793          	addi	a5,a5,-710 # ffffffffc02aeae8 <hash_list>
ffffffffc0205db6:	953e                	add	a0,a0,a5
ffffffffc0205db8:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list) {
ffffffffc0205dba:	a029                	j	ffffffffc0205dc4 <do_kill+0x3a>
            if (proc->pid == pid) {
ffffffffc0205dbc:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205dc0:	00870b63          	beq	a4,s0,ffffffffc0205dd6 <do_kill+0x4c>
ffffffffc0205dc4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205dc6:	fef51be3          	bne	a0,a5,ffffffffc0205dbc <do_kill+0x32>
    return -E_INVAL;
ffffffffc0205dca:	5475                	li	s0,-3
}
ffffffffc0205dcc:	60a2                	ld	ra,8(sp)
ffffffffc0205dce:	8522                	mv	a0,s0
ffffffffc0205dd0:	6402                	ld	s0,0(sp)
ffffffffc0205dd2:	0141                	addi	sp,sp,16
ffffffffc0205dd4:	8082                	ret
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205dd6:	fd87a703          	lw	a4,-40(a5)
ffffffffc0205dda:	00177693          	andi	a3,a4,1
ffffffffc0205dde:	e295                	bnez	a3,ffffffffc0205e02 <do_kill+0x78>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205de0:	4bd4                	lw	a3,20(a5)
            proc->flags |= PF_EXITING;
ffffffffc0205de2:	00176713          	ori	a4,a4,1
ffffffffc0205de6:	fce7ac23          	sw	a4,-40(a5)
            return 0;
ffffffffc0205dea:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205dec:	fe06d0e3          	bgez	a3,ffffffffc0205dcc <do_kill+0x42>
                wakeup_proc(proc);
ffffffffc0205df0:	f2878513          	addi	a0,a5,-216
ffffffffc0205df4:	22e000ef          	jal	ra,ffffffffc0206022 <wakeup_proc>
}
ffffffffc0205df8:	60a2                	ld	ra,8(sp)
ffffffffc0205dfa:	8522                	mv	a0,s0
ffffffffc0205dfc:	6402                	ld	s0,0(sp)
ffffffffc0205dfe:	0141                	addi	sp,sp,16
ffffffffc0205e00:	8082                	ret
        return -E_KILLED;
ffffffffc0205e02:	545d                	li	s0,-9
ffffffffc0205e04:	b7e1                	j	ffffffffc0205dcc <do_kill+0x42>

ffffffffc0205e06 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205e06:	1101                	addi	sp,sp,-32
ffffffffc0205e08:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205e0a:	000ad797          	auipc	a5,0xad
ffffffffc0205e0e:	cde78793          	addi	a5,a5,-802 # ffffffffc02b2ae8 <proc_list>
ffffffffc0205e12:	ec06                	sd	ra,24(sp)
ffffffffc0205e14:	e822                	sd	s0,16(sp)
ffffffffc0205e16:	e04a                	sd	s2,0(sp)
ffffffffc0205e18:	000a9497          	auipc	s1,0xa9
ffffffffc0205e1c:	cd048493          	addi	s1,s1,-816 # ffffffffc02aeae8 <hash_list>
ffffffffc0205e20:	e79c                	sd	a5,8(a5)
ffffffffc0205e22:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205e24:	000ad717          	auipc	a4,0xad
ffffffffc0205e28:	cc470713          	addi	a4,a4,-828 # ffffffffc02b2ae8 <proc_list>
ffffffffc0205e2c:	87a6                	mv	a5,s1
ffffffffc0205e2e:	e79c                	sd	a5,8(a5)
ffffffffc0205e30:	e39c                	sd	a5,0(a5)
ffffffffc0205e32:	07c1                	addi	a5,a5,16
ffffffffc0205e34:	fef71de3          	bne	a4,a5,ffffffffc0205e2e <proc_init+0x28>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205e38:	f93fe0ef          	jal	ra,ffffffffc0204dca <alloc_proc>
ffffffffc0205e3c:	000ad917          	auipc	s2,0xad
ffffffffc0205e40:	d3c90913          	addi	s2,s2,-708 # ffffffffc02b2b78 <idleproc>
ffffffffc0205e44:	00a93023          	sd	a0,0(s2)
ffffffffc0205e48:	0e050f63          	beqz	a0,ffffffffc0205f46 <proc_init+0x140>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205e4c:	4789                	li	a5,2
ffffffffc0205e4e:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e50:	00003797          	auipc	a5,0x3
ffffffffc0205e54:	1b078793          	addi	a5,a5,432 # ffffffffc0209000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e58:	0b450413          	addi	s0,a0,180
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e5c:	e91c                	sd	a5,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e5e:	4785                	li	a5,1
ffffffffc0205e60:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205e62:	4641                	li	a2,16
ffffffffc0205e64:	4581                	li	a1,0
ffffffffc0205e66:	8522                	mv	a0,s0
ffffffffc0205e68:	027000ef          	jal	ra,ffffffffc020668e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205e6c:	463d                	li	a2,15
ffffffffc0205e6e:	00003597          	auipc	a1,0x3
ffffffffc0205e72:	9d258593          	addi	a1,a1,-1582 # ffffffffc0208840 <default_pmm_manager+0x1438>
ffffffffc0205e76:	8522                	mv	a0,s0
ffffffffc0205e78:	029000ef          	jal	ra,ffffffffc02066a0 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process ++;
ffffffffc0205e7c:	000ad717          	auipc	a4,0xad
ffffffffc0205e80:	d0c70713          	addi	a4,a4,-756 # ffffffffc02b2b88 <nr_process>
ffffffffc0205e84:	431c                	lw	a5,0(a4)

    current = idleproc;
ffffffffc0205e86:	00093683          	ld	a3,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e8a:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e8c:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e8e:	4581                	li	a1,0
ffffffffc0205e90:	00000517          	auipc	a0,0x0
ffffffffc0205e94:	87450513          	addi	a0,a0,-1932 # ffffffffc0205704 <init_main>
    nr_process ++;
ffffffffc0205e98:	c31c                	sw	a5,0(a4)
    current = idleproc;
ffffffffc0205e9a:	000ad797          	auipc	a5,0xad
ffffffffc0205e9e:	ccd7bb23          	sd	a3,-810(a5) # ffffffffc02b2b70 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ea2:	cf6ff0ef          	jal	ra,ffffffffc0205398 <kernel_thread>
ffffffffc0205ea6:	842a                	mv	s0,a0
    if (pid <= 0) {
ffffffffc0205ea8:	08a05363          	blez	a0,ffffffffc0205f2e <proc_init+0x128>
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205eac:	6789                	lui	a5,0x2
ffffffffc0205eae:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205eb2:	17f9                	addi	a5,a5,-2
ffffffffc0205eb4:	2501                	sext.w	a0,a0
ffffffffc0205eb6:	02e7e363          	bltu	a5,a4,ffffffffc0205edc <proc_init+0xd6>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205eba:	45a9                	li	a1,10
ffffffffc0205ebc:	352000ef          	jal	ra,ffffffffc020620e <hash32>
ffffffffc0205ec0:	02051793          	slli	a5,a0,0x20
ffffffffc0205ec4:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205ec8:	96a6                	add	a3,a3,s1
ffffffffc0205eca:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0205ecc:	a029                	j	ffffffffc0205ed6 <proc_init+0xd0>
            if (proc->pid == pid) {
ffffffffc0205ece:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7cb4>
ffffffffc0205ed2:	04870b63          	beq	a4,s0,ffffffffc0205f28 <proc_init+0x122>
    return listelm->next;
ffffffffc0205ed6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0205ed8:	fef69be3          	bne	a3,a5,ffffffffc0205ece <proc_init+0xc8>
    return NULL;
ffffffffc0205edc:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ede:	0b478493          	addi	s1,a5,180
ffffffffc0205ee2:	4641                	li	a2,16
ffffffffc0205ee4:	4581                	li	a1,0
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ee6:	000ad417          	auipc	s0,0xad
ffffffffc0205eea:	c9a40413          	addi	s0,s0,-870 # ffffffffc02b2b80 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205eee:	8526                	mv	a0,s1
    initproc = find_proc(pid);
ffffffffc0205ef0:	e01c                	sd	a5,0(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205ef2:	79c000ef          	jal	ra,ffffffffc020668e <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205ef6:	463d                	li	a2,15
ffffffffc0205ef8:	00003597          	auipc	a1,0x3
ffffffffc0205efc:	97058593          	addi	a1,a1,-1680 # ffffffffc0208868 <default_pmm_manager+0x1460>
ffffffffc0205f00:	8526                	mv	a0,s1
ffffffffc0205f02:	79e000ef          	jal	ra,ffffffffc02066a0 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f06:	00093783          	ld	a5,0(s2)
ffffffffc0205f0a:	cbb5                	beqz	a5,ffffffffc0205f7e <proc_init+0x178>
ffffffffc0205f0c:	43dc                	lw	a5,4(a5)
ffffffffc0205f0e:	eba5                	bnez	a5,ffffffffc0205f7e <proc_init+0x178>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f10:	601c                	ld	a5,0(s0)
ffffffffc0205f12:	c7b1                	beqz	a5,ffffffffc0205f5e <proc_init+0x158>
ffffffffc0205f14:	43d8                	lw	a4,4(a5)
ffffffffc0205f16:	4785                	li	a5,1
ffffffffc0205f18:	04f71363          	bne	a4,a5,ffffffffc0205f5e <proc_init+0x158>
}
ffffffffc0205f1c:	60e2                	ld	ra,24(sp)
ffffffffc0205f1e:	6442                	ld	s0,16(sp)
ffffffffc0205f20:	64a2                	ld	s1,8(sp)
ffffffffc0205f22:	6902                	ld	s2,0(sp)
ffffffffc0205f24:	6105                	addi	sp,sp,32
ffffffffc0205f26:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205f28:	f2878793          	addi	a5,a5,-216
ffffffffc0205f2c:	bf4d                	j	ffffffffc0205ede <proc_init+0xd8>
        panic("create init_main failed.\n");
ffffffffc0205f2e:	00003617          	auipc	a2,0x3
ffffffffc0205f32:	91a60613          	addi	a2,a2,-1766 # ffffffffc0208848 <default_pmm_manager+0x1440>
ffffffffc0205f36:	39800593          	li	a1,920
ffffffffc0205f3a:	00002517          	auipc	a0,0x2
ffffffffc0205f3e:	59e50513          	addi	a0,a0,1438 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205f42:	d38fa0ef          	jal	ra,ffffffffc020047a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205f46:	00003617          	auipc	a2,0x3
ffffffffc0205f4a:	8e260613          	addi	a2,a2,-1822 # ffffffffc0208828 <default_pmm_manager+0x1420>
ffffffffc0205f4e:	38a00593          	li	a1,906
ffffffffc0205f52:	00002517          	auipc	a0,0x2
ffffffffc0205f56:	58650513          	addi	a0,a0,1414 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205f5a:	d20fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205f5e:	00003697          	auipc	a3,0x3
ffffffffc0205f62:	93a68693          	addi	a3,a3,-1734 # ffffffffc0208898 <default_pmm_manager+0x1490>
ffffffffc0205f66:	00001617          	auipc	a2,0x1
ffffffffc0205f6a:	e0a60613          	addi	a2,a2,-502 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205f6e:	39f00593          	li	a1,927
ffffffffc0205f72:	00002517          	auipc	a0,0x2
ffffffffc0205f76:	56650513          	addi	a0,a0,1382 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205f7a:	d00fa0ef          	jal	ra,ffffffffc020047a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205f7e:	00003697          	auipc	a3,0x3
ffffffffc0205f82:	8f268693          	addi	a3,a3,-1806 # ffffffffc0208870 <default_pmm_manager+0x1468>
ffffffffc0205f86:	00001617          	auipc	a2,0x1
ffffffffc0205f8a:	dea60613          	addi	a2,a2,-534 # ffffffffc0206d70 <commands+0x450>
ffffffffc0205f8e:	39e00593          	li	a1,926
ffffffffc0205f92:	00002517          	auipc	a0,0x2
ffffffffc0205f96:	54650513          	addi	a0,a0,1350 # ffffffffc02084d8 <default_pmm_manager+0x10d0>
ffffffffc0205f9a:	ce0fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc0205f9e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205f9e:	1141                	addi	sp,sp,-16
ffffffffc0205fa0:	e022                	sd	s0,0(sp)
ffffffffc0205fa2:	e406                	sd	ra,8(sp)
ffffffffc0205fa4:	000ad417          	auipc	s0,0xad
ffffffffc0205fa8:	bcc40413          	addi	s0,s0,-1076 # ffffffffc02b2b70 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205fac:	6018                	ld	a4,0(s0)
ffffffffc0205fae:	6f1c                	ld	a5,24(a4)
ffffffffc0205fb0:	dffd                	beqz	a5,ffffffffc0205fae <cpu_idle+0x10>
            schedule();
ffffffffc0205fb2:	0f0000ef          	jal	ra,ffffffffc02060a2 <schedule>
ffffffffc0205fb6:	bfdd                	j	ffffffffc0205fac <cpu_idle+0xe>

ffffffffc0205fb8 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205fb8:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205fbc:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205fc0:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205fc2:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205fc4:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205fc8:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205fcc:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205fd0:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205fd4:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205fd8:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205fdc:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205fe0:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205fe4:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205fe8:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205fec:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205ff0:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205ff4:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205ff6:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205ff8:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205ffc:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0206000:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0206004:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0206008:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc020600c:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0206010:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0206014:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0206018:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc020601c:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0206020:	8082                	ret

ffffffffc0206022 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206022:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0206024:	1101                	addi	sp,sp,-32
ffffffffc0206026:	ec06                	sd	ra,24(sp)
ffffffffc0206028:	e822                	sd	s0,16(sp)
ffffffffc020602a:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc020602c:	478d                	li	a5,3
ffffffffc020602e:	04f70b63          	beq	a4,a5,ffffffffc0206084 <wakeup_proc+0x62>
ffffffffc0206032:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206034:	100027f3          	csrr	a5,sstatus
ffffffffc0206038:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020603a:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020603c:	ef9d                	bnez	a5,ffffffffc020607a <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc020603e:	4789                	li	a5,2
ffffffffc0206040:	02f70163          	beq	a4,a5,ffffffffc0206062 <wakeup_proc+0x40>
            proc->state = PROC_RUNNABLE;
ffffffffc0206044:	c01c                	sw	a5,0(s0)
            proc->wait_state = 0;
ffffffffc0206046:	0e042623          	sw	zero,236(s0)
    if (flag) {
ffffffffc020604a:	e491                	bnez	s1,ffffffffc0206056 <wakeup_proc+0x34>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc020604c:	60e2                	ld	ra,24(sp)
ffffffffc020604e:	6442                	ld	s0,16(sp)
ffffffffc0206050:	64a2                	ld	s1,8(sp)
ffffffffc0206052:	6105                	addi	sp,sp,32
ffffffffc0206054:	8082                	ret
ffffffffc0206056:	6442                	ld	s0,16(sp)
ffffffffc0206058:	60e2                	ld	ra,24(sp)
ffffffffc020605a:	64a2                	ld	s1,8(sp)
ffffffffc020605c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020605e:	de2fa06f          	j	ffffffffc0200640 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0206062:	00003617          	auipc	a2,0x3
ffffffffc0206066:	89660613          	addi	a2,a2,-1898 # ffffffffc02088f8 <default_pmm_manager+0x14f0>
ffffffffc020606a:	45c9                	li	a1,18
ffffffffc020606c:	00003517          	auipc	a0,0x3
ffffffffc0206070:	87450513          	addi	a0,a0,-1932 # ffffffffc02088e0 <default_pmm_manager+0x14d8>
ffffffffc0206074:	c6efa0ef          	jal	ra,ffffffffc02004e2 <__warn>
ffffffffc0206078:	bfc9                	j	ffffffffc020604a <wakeup_proc+0x28>
        intr_disable();
ffffffffc020607a:	dccfa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc020607e:	4018                	lw	a4,0(s0)
        return 1;
ffffffffc0206080:	4485                	li	s1,1
ffffffffc0206082:	bf75                	j	ffffffffc020603e <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206084:	00003697          	auipc	a3,0x3
ffffffffc0206088:	83c68693          	addi	a3,a3,-1988 # ffffffffc02088c0 <default_pmm_manager+0x14b8>
ffffffffc020608c:	00001617          	auipc	a2,0x1
ffffffffc0206090:	ce460613          	addi	a2,a2,-796 # ffffffffc0206d70 <commands+0x450>
ffffffffc0206094:	45a5                	li	a1,9
ffffffffc0206096:	00003517          	auipc	a0,0x3
ffffffffc020609a:	84a50513          	addi	a0,a0,-1974 # ffffffffc02088e0 <default_pmm_manager+0x14d8>
ffffffffc020609e:	bdcfa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc02060a2 <schedule>:

void
schedule(void) {
ffffffffc02060a2:	1141                	addi	sp,sp,-16
ffffffffc02060a4:	e406                	sd	ra,8(sp)
ffffffffc02060a6:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060a8:	100027f3          	csrr	a5,sstatus
ffffffffc02060ac:	8b89                	andi	a5,a5,2
ffffffffc02060ae:	4401                	li	s0,0
ffffffffc02060b0:	efbd                	bnez	a5,ffffffffc020612e <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02060b2:	000ad897          	auipc	a7,0xad
ffffffffc02060b6:	abe8b883          	ld	a7,-1346(a7) # ffffffffc02b2b70 <current>
ffffffffc02060ba:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02060be:	000ad517          	auipc	a0,0xad
ffffffffc02060c2:	aba53503          	ld	a0,-1350(a0) # ffffffffc02b2b78 <idleproc>
ffffffffc02060c6:	04a88e63          	beq	a7,a0,ffffffffc0206122 <schedule+0x80>
ffffffffc02060ca:	0c888693          	addi	a3,a7,200
ffffffffc02060ce:	000ad617          	auipc	a2,0xad
ffffffffc02060d2:	a1a60613          	addi	a2,a2,-1510 # ffffffffc02b2ae8 <proc_list>
        le = last;
ffffffffc02060d6:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02060d8:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02060da:	4809                	li	a6,2
ffffffffc02060dc:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02060de:	00c78863          	beq	a5,a2,ffffffffc02060ee <schedule+0x4c>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02060e2:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02060e6:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02060ea:	03070163          	beq	a4,a6,ffffffffc020610c <schedule+0x6a>
                    break;
                }
            }
        } while (le != last);
ffffffffc02060ee:	fef697e3          	bne	a3,a5,ffffffffc02060dc <schedule+0x3a>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02060f2:	ed89                	bnez	a1,ffffffffc020610c <schedule+0x6a>
            next = idleproc;
        }
        next->runs ++;
ffffffffc02060f4:	451c                	lw	a5,8(a0)
ffffffffc02060f6:	2785                	addiw	a5,a5,1
ffffffffc02060f8:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02060fa:	00a88463          	beq	a7,a0,ffffffffc0206102 <schedule+0x60>
            proc_run(next);
ffffffffc02060fe:	e4bfe0ef          	jal	ra,ffffffffc0204f48 <proc_run>
    if (flag) {
ffffffffc0206102:	e819                	bnez	s0,ffffffffc0206118 <schedule+0x76>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206104:	60a2                	ld	ra,8(sp)
ffffffffc0206106:	6402                	ld	s0,0(sp)
ffffffffc0206108:	0141                	addi	sp,sp,16
ffffffffc020610a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020610c:	4198                	lw	a4,0(a1)
ffffffffc020610e:	4789                	li	a5,2
ffffffffc0206110:	fef712e3          	bne	a4,a5,ffffffffc02060f4 <schedule+0x52>
ffffffffc0206114:	852e                	mv	a0,a1
ffffffffc0206116:	bff9                	j	ffffffffc02060f4 <schedule+0x52>
}
ffffffffc0206118:	6402                	ld	s0,0(sp)
ffffffffc020611a:	60a2                	ld	ra,8(sp)
ffffffffc020611c:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020611e:	d22fa06f          	j	ffffffffc0200640 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206122:	000ad617          	auipc	a2,0xad
ffffffffc0206126:	9c660613          	addi	a2,a2,-1594 # ffffffffc02b2ae8 <proc_list>
ffffffffc020612a:	86b2                	mv	a3,a2
ffffffffc020612c:	b76d                	j	ffffffffc02060d6 <schedule+0x34>
        intr_disable();
ffffffffc020612e:	d18fa0ef          	jal	ra,ffffffffc0200646 <intr_disable>
        return 1;
ffffffffc0206132:	4405                	li	s0,1
ffffffffc0206134:	bfbd                	j	ffffffffc02060b2 <schedule+0x10>

ffffffffc0206136 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206136:	000ad797          	auipc	a5,0xad
ffffffffc020613a:	a3a7b783          	ld	a5,-1478(a5) # ffffffffc02b2b70 <current>
}
ffffffffc020613e:	43c8                	lw	a0,4(a5)
ffffffffc0206140:	8082                	ret

ffffffffc0206142 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206142:	4501                	li	a0,0
ffffffffc0206144:	8082                	ret

ffffffffc0206146 <sys_putc>:
    cputchar(c);
ffffffffc0206146:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206148:	1141                	addi	sp,sp,-16
ffffffffc020614a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020614c:	86afa0ef          	jal	ra,ffffffffc02001b6 <cputchar>
}
ffffffffc0206150:	60a2                	ld	ra,8(sp)
ffffffffc0206152:	4501                	li	a0,0
ffffffffc0206154:	0141                	addi	sp,sp,16
ffffffffc0206156:	8082                	ret

ffffffffc0206158 <sys_kill>:
    return do_kill(pid);
ffffffffc0206158:	4108                	lw	a0,0(a0)
ffffffffc020615a:	c31ff06f          	j	ffffffffc0205d8a <do_kill>

ffffffffc020615e <sys_yield>:
    return do_yield();
ffffffffc020615e:	bdfff06f          	j	ffffffffc0205d3c <do_yield>

ffffffffc0206162 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206162:	6d14                	ld	a3,24(a0)
ffffffffc0206164:	6910                	ld	a2,16(a0)
ffffffffc0206166:	650c                	ld	a1,8(a0)
ffffffffc0206168:	6108                	ld	a0,0(a0)
ffffffffc020616a:	ebeff06f          	j	ffffffffc0205828 <do_execve>

ffffffffc020616e <sys_wait>:
    return do_wait(pid, store);
ffffffffc020616e:	650c                	ld	a1,8(a0)
ffffffffc0206170:	4108                	lw	a0,0(a0)
ffffffffc0206172:	bdbff06f          	j	ffffffffc0205d4c <do_wait>

ffffffffc0206176 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206176:	000ad797          	auipc	a5,0xad
ffffffffc020617a:	9fa7b783          	ld	a5,-1542(a5) # ffffffffc02b2b70 <current>
ffffffffc020617e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206180:	4501                	li	a0,0
ffffffffc0206182:	6a0c                	ld	a1,16(a2)
ffffffffc0206184:	e31fe06f          	j	ffffffffc0204fb4 <do_fork>

ffffffffc0206188 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206188:	4108                	lw	a0,0(a0)
ffffffffc020618a:	a5eff06f          	j	ffffffffc02053e8 <do_exit>

ffffffffc020618e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020618e:	715d                	addi	sp,sp,-80
ffffffffc0206190:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206192:	000ad497          	auipc	s1,0xad
ffffffffc0206196:	9de48493          	addi	s1,s1,-1570 # ffffffffc02b2b70 <current>
ffffffffc020619a:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020619c:	e0a2                	sd	s0,64(sp)
ffffffffc020619e:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02061a0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02061a2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061a4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02061a6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02061aa:	0327ee63          	bltu	a5,s2,ffffffffc02061e6 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02061ae:	00391713          	slli	a4,s2,0x3
ffffffffc02061b2:	00002797          	auipc	a5,0x2
ffffffffc02061b6:	7ae78793          	addi	a5,a5,1966 # ffffffffc0208960 <syscalls>
ffffffffc02061ba:	97ba                	add	a5,a5,a4
ffffffffc02061bc:	639c                	ld	a5,0(a5)
ffffffffc02061be:	c785                	beqz	a5,ffffffffc02061e6 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02061c0:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02061c2:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02061c4:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02061c6:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02061c8:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02061ca:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02061cc:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02061ce:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02061d0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02061d2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02061d4:	0028                	addi	a0,sp,8
ffffffffc02061d6:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02061d8:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02061da:	e828                	sd	a0,80(s0)
}
ffffffffc02061dc:	6406                	ld	s0,64(sp)
ffffffffc02061de:	74e2                	ld	s1,56(sp)
ffffffffc02061e0:	7942                	ld	s2,48(sp)
ffffffffc02061e2:	6161                	addi	sp,sp,80
ffffffffc02061e4:	8082                	ret
    print_trapframe(tf);
ffffffffc02061e6:	8522                	mv	a0,s0
ffffffffc02061e8:	e4cfa0ef          	jal	ra,ffffffffc0200834 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02061ec:	609c                	ld	a5,0(s1)
ffffffffc02061ee:	86ca                	mv	a3,s2
ffffffffc02061f0:	00002617          	auipc	a2,0x2
ffffffffc02061f4:	72860613          	addi	a2,a2,1832 # ffffffffc0208918 <default_pmm_manager+0x1510>
ffffffffc02061f8:	43d8                	lw	a4,4(a5)
ffffffffc02061fa:	06200593          	li	a1,98
ffffffffc02061fe:	0b478793          	addi	a5,a5,180
ffffffffc0206202:	00002517          	auipc	a0,0x2
ffffffffc0206206:	74650513          	addi	a0,a0,1862 # ffffffffc0208948 <default_pmm_manager+0x1540>
ffffffffc020620a:	a70fa0ef          	jal	ra,ffffffffc020047a <__panic>

ffffffffc020620e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020620e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206212:	2785                	addiw	a5,a5,1
ffffffffc0206214:	02a7853b          	mulw	a0,a5,a0
    return (hash >> (32 - bits));
ffffffffc0206218:	02000793          	li	a5,32
ffffffffc020621c:	9f8d                	subw	a5,a5,a1
}
ffffffffc020621e:	00f5553b          	srlw	a0,a0,a5
ffffffffc0206222:	8082                	ret

ffffffffc0206224 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206224:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206228:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020622a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020622e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206230:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206234:	f022                	sd	s0,32(sp)
ffffffffc0206236:	ec26                	sd	s1,24(sp)
ffffffffc0206238:	e84a                	sd	s2,16(sp)
ffffffffc020623a:	f406                	sd	ra,40(sp)
ffffffffc020623c:	e44e                	sd	s3,8(sp)
ffffffffc020623e:	84aa                	mv	s1,a0
ffffffffc0206240:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206242:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206246:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0206248:	03067e63          	bgeu	a2,a6,ffffffffc0206284 <printnum+0x60>
ffffffffc020624c:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020624e:	00805763          	blez	s0,ffffffffc020625c <printnum+0x38>
ffffffffc0206252:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206254:	85ca                	mv	a1,s2
ffffffffc0206256:	854e                	mv	a0,s3
ffffffffc0206258:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020625a:	fc65                	bnez	s0,ffffffffc0206252 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020625c:	1a02                	slli	s4,s4,0x20
ffffffffc020625e:	00003797          	auipc	a5,0x3
ffffffffc0206262:	80278793          	addi	a5,a5,-2046 # ffffffffc0208a60 <syscalls+0x100>
ffffffffc0206266:	020a5a13          	srli	s4,s4,0x20
ffffffffc020626a:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020626c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020626e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206272:	70a2                	ld	ra,40(sp)
ffffffffc0206274:	69a2                	ld	s3,8(sp)
ffffffffc0206276:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206278:	85ca                	mv	a1,s2
ffffffffc020627a:	87a6                	mv	a5,s1
}
ffffffffc020627c:	6942                	ld	s2,16(sp)
ffffffffc020627e:	64e2                	ld	s1,24(sp)
ffffffffc0206280:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206282:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206284:	03065633          	divu	a2,a2,a6
ffffffffc0206288:	8722                	mv	a4,s0
ffffffffc020628a:	f9bff0ef          	jal	ra,ffffffffc0206224 <printnum>
ffffffffc020628e:	b7f9                	j	ffffffffc020625c <printnum+0x38>

ffffffffc0206290 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206290:	7119                	addi	sp,sp,-128
ffffffffc0206292:	f4a6                	sd	s1,104(sp)
ffffffffc0206294:	f0ca                	sd	s2,96(sp)
ffffffffc0206296:	ecce                	sd	s3,88(sp)
ffffffffc0206298:	e8d2                	sd	s4,80(sp)
ffffffffc020629a:	e4d6                	sd	s5,72(sp)
ffffffffc020629c:	e0da                	sd	s6,64(sp)
ffffffffc020629e:	fc5e                	sd	s7,56(sp)
ffffffffc02062a0:	f06a                	sd	s10,32(sp)
ffffffffc02062a2:	fc86                	sd	ra,120(sp)
ffffffffc02062a4:	f8a2                	sd	s0,112(sp)
ffffffffc02062a6:	f862                	sd	s8,48(sp)
ffffffffc02062a8:	f466                	sd	s9,40(sp)
ffffffffc02062aa:	ec6e                	sd	s11,24(sp)
ffffffffc02062ac:	892a                	mv	s2,a0
ffffffffc02062ae:	84ae                	mv	s1,a1
ffffffffc02062b0:	8d32                	mv	s10,a2
ffffffffc02062b2:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062b4:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02062b8:	5b7d                	li	s6,-1
ffffffffc02062ba:	00002a97          	auipc	s5,0x2
ffffffffc02062be:	7d2a8a93          	addi	s5,s5,2002 # ffffffffc0208a8c <syscalls+0x12c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062c2:	00003b97          	auipc	s7,0x3
ffffffffc02062c6:	9e6b8b93          	addi	s7,s7,-1562 # ffffffffc0208ca8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062ca:	000d4503          	lbu	a0,0(s10)
ffffffffc02062ce:	001d0413          	addi	s0,s10,1
ffffffffc02062d2:	01350a63          	beq	a0,s3,ffffffffc02062e6 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc02062d6:	c121                	beqz	a0,ffffffffc0206316 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc02062d8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062da:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02062dc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02062de:	fff44503          	lbu	a0,-1(s0)
ffffffffc02062e2:	ff351ae3          	bne	a0,s3,ffffffffc02062d6 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062e6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02062ea:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02062ee:	4c81                	li	s9,0
ffffffffc02062f0:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02062f2:	5c7d                	li	s8,-1
ffffffffc02062f4:	5dfd                	li	s11,-1
ffffffffc02062f6:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02062fa:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02062fc:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206300:	0ff5f593          	zext.b	a1,a1
ffffffffc0206304:	00140d13          	addi	s10,s0,1
ffffffffc0206308:	04b56263          	bltu	a0,a1,ffffffffc020634c <vprintfmt+0xbc>
ffffffffc020630c:	058a                	slli	a1,a1,0x2
ffffffffc020630e:	95d6                	add	a1,a1,s5
ffffffffc0206310:	4194                	lw	a3,0(a1)
ffffffffc0206312:	96d6                	add	a3,a3,s5
ffffffffc0206314:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206316:	70e6                	ld	ra,120(sp)
ffffffffc0206318:	7446                	ld	s0,112(sp)
ffffffffc020631a:	74a6                	ld	s1,104(sp)
ffffffffc020631c:	7906                	ld	s2,96(sp)
ffffffffc020631e:	69e6                	ld	s3,88(sp)
ffffffffc0206320:	6a46                	ld	s4,80(sp)
ffffffffc0206322:	6aa6                	ld	s5,72(sp)
ffffffffc0206324:	6b06                	ld	s6,64(sp)
ffffffffc0206326:	7be2                	ld	s7,56(sp)
ffffffffc0206328:	7c42                	ld	s8,48(sp)
ffffffffc020632a:	7ca2                	ld	s9,40(sp)
ffffffffc020632c:	7d02                	ld	s10,32(sp)
ffffffffc020632e:	6de2                	ld	s11,24(sp)
ffffffffc0206330:	6109                	addi	sp,sp,128
ffffffffc0206332:	8082                	ret
            padc = '0';
ffffffffc0206334:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0206336:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020633a:	846a                	mv	s0,s10
ffffffffc020633c:	00140d13          	addi	s10,s0,1
ffffffffc0206340:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0206344:	0ff5f593          	zext.b	a1,a1
ffffffffc0206348:	fcb572e3          	bgeu	a0,a1,ffffffffc020630c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc020634c:	85a6                	mv	a1,s1
ffffffffc020634e:	02500513          	li	a0,37
ffffffffc0206352:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0206354:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206358:	8d22                	mv	s10,s0
ffffffffc020635a:	f73788e3          	beq	a5,s3,ffffffffc02062ca <vprintfmt+0x3a>
ffffffffc020635e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0206362:	1d7d                	addi	s10,s10,-1
ffffffffc0206364:	ff379de3          	bne	a5,s3,ffffffffc020635e <vprintfmt+0xce>
ffffffffc0206368:	b78d                	j	ffffffffc02062ca <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020636a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020636e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206372:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206374:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206378:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020637c:	02d86463          	bltu	a6,a3,ffffffffc02063a4 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0206380:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206384:	002c169b          	slliw	a3,s8,0x2
ffffffffc0206388:	0186873b          	addw	a4,a3,s8
ffffffffc020638c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0206390:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0206392:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206396:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206398:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020639c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02063a0:	fed870e3          	bgeu	a6,a3,ffffffffc0206380 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02063a4:	f40ddce3          	bgez	s11,ffffffffc02062fc <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02063a8:	8de2                	mv	s11,s8
ffffffffc02063aa:	5c7d                	li	s8,-1
ffffffffc02063ac:	bf81                	j	ffffffffc02062fc <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02063ae:	fffdc693          	not	a3,s11
ffffffffc02063b2:	96fd                	srai	a3,a3,0x3f
ffffffffc02063b4:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063b8:	00144603          	lbu	a2,1(s0)
ffffffffc02063bc:	2d81                	sext.w	s11,s11
ffffffffc02063be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063c0:	bf35                	j	ffffffffc02062fc <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02063c2:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063c6:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02063ca:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063cc:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc02063ce:	bfd9                	j	ffffffffc02063a4 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc02063d0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02063d2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02063d6:	01174463          	blt	a4,a7,ffffffffc02063de <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc02063da:	1a088e63          	beqz	a7,ffffffffc0206596 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc02063de:	000a3603          	ld	a2,0(s4)
ffffffffc02063e2:	46c1                	li	a3,16
ffffffffc02063e4:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063e6:	2781                	sext.w	a5,a5
ffffffffc02063e8:	876e                	mv	a4,s11
ffffffffc02063ea:	85a6                	mv	a1,s1
ffffffffc02063ec:	854a                	mv	a0,s2
ffffffffc02063ee:	e37ff0ef          	jal	ra,ffffffffc0206224 <printnum>
            break;
ffffffffc02063f2:	bde1                	j	ffffffffc02062ca <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02063f4:	000a2503          	lw	a0,0(s4)
ffffffffc02063f8:	85a6                	mv	a1,s1
ffffffffc02063fa:	0a21                	addi	s4,s4,8
ffffffffc02063fc:	9902                	jalr	s2
            break;
ffffffffc02063fe:	b5f1                	j	ffffffffc02062ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206400:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206402:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206406:	01174463          	blt	a4,a7,ffffffffc020640e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020640a:	18088163          	beqz	a7,ffffffffc020658c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020640e:	000a3603          	ld	a2,0(s4)
ffffffffc0206412:	46a9                	li	a3,10
ffffffffc0206414:	8a2e                	mv	s4,a1
ffffffffc0206416:	bfc1                	j	ffffffffc02063e6 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206418:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020641c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020641e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206420:	bdf1                	j	ffffffffc02062fc <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0206422:	85a6                	mv	a1,s1
ffffffffc0206424:	02500513          	li	a0,37
ffffffffc0206428:	9902                	jalr	s2
            break;
ffffffffc020642a:	b545                	j	ffffffffc02062ca <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020642c:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0206430:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206432:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206434:	b5e1                	j	ffffffffc02062fc <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0206436:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0206438:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020643c:	01174463          	blt	a4,a7,ffffffffc0206444 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0206440:	14088163          	beqz	a7,ffffffffc0206582 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0206444:	000a3603          	ld	a2,0(s4)
ffffffffc0206448:	46a1                	li	a3,8
ffffffffc020644a:	8a2e                	mv	s4,a1
ffffffffc020644c:	bf69                	j	ffffffffc02063e6 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc020644e:	03000513          	li	a0,48
ffffffffc0206452:	85a6                	mv	a1,s1
ffffffffc0206454:	e03e                	sd	a5,0(sp)
ffffffffc0206456:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206458:	85a6                	mv	a1,s1
ffffffffc020645a:	07800513          	li	a0,120
ffffffffc020645e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206460:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0206462:	6782                	ld	a5,0(sp)
ffffffffc0206464:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206466:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020646a:	bfb5                	j	ffffffffc02063e6 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020646c:	000a3403          	ld	s0,0(s4)
ffffffffc0206470:	008a0713          	addi	a4,s4,8
ffffffffc0206474:	e03a                	sd	a4,0(sp)
ffffffffc0206476:	14040263          	beqz	s0,ffffffffc02065ba <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020647a:	0fb05763          	blez	s11,ffffffffc0206568 <vprintfmt+0x2d8>
ffffffffc020647e:	02d00693          	li	a3,45
ffffffffc0206482:	0cd79163          	bne	a5,a3,ffffffffc0206544 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206486:	00044783          	lbu	a5,0(s0)
ffffffffc020648a:	0007851b          	sext.w	a0,a5
ffffffffc020648e:	cf85                	beqz	a5,ffffffffc02064c6 <vprintfmt+0x236>
ffffffffc0206490:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206494:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206498:	000c4563          	bltz	s8,ffffffffc02064a2 <vprintfmt+0x212>
ffffffffc020649c:	3c7d                	addiw	s8,s8,-1
ffffffffc020649e:	036c0263          	beq	s8,s6,ffffffffc02064c2 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02064a2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064a4:	0e0c8e63          	beqz	s9,ffffffffc02065a0 <vprintfmt+0x310>
ffffffffc02064a8:	3781                	addiw	a5,a5,-32
ffffffffc02064aa:	0ef47b63          	bgeu	s0,a5,ffffffffc02065a0 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02064ae:	03f00513          	li	a0,63
ffffffffc02064b2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064b4:	000a4783          	lbu	a5,0(s4)
ffffffffc02064b8:	3dfd                	addiw	s11,s11,-1
ffffffffc02064ba:	0a05                	addi	s4,s4,1
ffffffffc02064bc:	0007851b          	sext.w	a0,a5
ffffffffc02064c0:	ffe1                	bnez	a5,ffffffffc0206498 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02064c2:	01b05963          	blez	s11,ffffffffc02064d4 <vprintfmt+0x244>
ffffffffc02064c6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc02064c8:	85a6                	mv	a1,s1
ffffffffc02064ca:	02000513          	li	a0,32
ffffffffc02064ce:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02064d0:	fe0d9be3          	bnez	s11,ffffffffc02064c6 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064d4:	6a02                	ld	s4,0(sp)
ffffffffc02064d6:	bbd5                	j	ffffffffc02062ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02064d8:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064da:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc02064de:	01174463          	blt	a4,a7,ffffffffc02064e6 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc02064e2:	08088d63          	beqz	a7,ffffffffc020657c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc02064e6:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02064ea:	0a044d63          	bltz	s0,ffffffffc02065a4 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc02064ee:	8622                	mv	a2,s0
ffffffffc02064f0:	8a66                	mv	s4,s9
ffffffffc02064f2:	46a9                	li	a3,10
ffffffffc02064f4:	bdcd                	j	ffffffffc02063e6 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02064f6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02064fa:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02064fc:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02064fe:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206502:	8fb5                	xor	a5,a5,a3
ffffffffc0206504:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206508:	02d74163          	blt	a4,a3,ffffffffc020652a <vprintfmt+0x29a>
ffffffffc020650c:	00369793          	slli	a5,a3,0x3
ffffffffc0206510:	97de                	add	a5,a5,s7
ffffffffc0206512:	639c                	ld	a5,0(a5)
ffffffffc0206514:	cb99                	beqz	a5,ffffffffc020652a <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206516:	86be                	mv	a3,a5
ffffffffc0206518:	00000617          	auipc	a2,0x0
ffffffffc020651c:	1c860613          	addi	a2,a2,456 # ffffffffc02066e0 <etext+0x28>
ffffffffc0206520:	85a6                	mv	a1,s1
ffffffffc0206522:	854a                	mv	a0,s2
ffffffffc0206524:	0ce000ef          	jal	ra,ffffffffc02065f2 <printfmt>
ffffffffc0206528:	b34d                	j	ffffffffc02062ca <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020652a:	00002617          	auipc	a2,0x2
ffffffffc020652e:	55660613          	addi	a2,a2,1366 # ffffffffc0208a80 <syscalls+0x120>
ffffffffc0206532:	85a6                	mv	a1,s1
ffffffffc0206534:	854a                	mv	a0,s2
ffffffffc0206536:	0bc000ef          	jal	ra,ffffffffc02065f2 <printfmt>
ffffffffc020653a:	bb41                	j	ffffffffc02062ca <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020653c:	00002417          	auipc	s0,0x2
ffffffffc0206540:	53c40413          	addi	s0,s0,1340 # ffffffffc0208a78 <syscalls+0x118>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206544:	85e2                	mv	a1,s8
ffffffffc0206546:	8522                	mv	a0,s0
ffffffffc0206548:	e43e                	sd	a5,8(sp)
ffffffffc020654a:	0e2000ef          	jal	ra,ffffffffc020662c <strnlen>
ffffffffc020654e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206552:	01b05b63          	blez	s11,ffffffffc0206568 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0206556:	67a2                	ld	a5,8(sp)
ffffffffc0206558:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020655c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020655e:	85a6                	mv	a1,s1
ffffffffc0206560:	8552                	mv	a0,s4
ffffffffc0206562:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206564:	fe0d9ce3          	bnez	s11,ffffffffc020655c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206568:	00044783          	lbu	a5,0(s0)
ffffffffc020656c:	00140a13          	addi	s4,s0,1
ffffffffc0206570:	0007851b          	sext.w	a0,a5
ffffffffc0206574:	d3a5                	beqz	a5,ffffffffc02064d4 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206576:	05e00413          	li	s0,94
ffffffffc020657a:	bf39                	j	ffffffffc0206498 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020657c:	000a2403          	lw	s0,0(s4)
ffffffffc0206580:	b7ad                	j	ffffffffc02064ea <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0206582:	000a6603          	lwu	a2,0(s4)
ffffffffc0206586:	46a1                	li	a3,8
ffffffffc0206588:	8a2e                	mv	s4,a1
ffffffffc020658a:	bdb1                	j	ffffffffc02063e6 <vprintfmt+0x156>
ffffffffc020658c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206590:	46a9                	li	a3,10
ffffffffc0206592:	8a2e                	mv	s4,a1
ffffffffc0206594:	bd89                	j	ffffffffc02063e6 <vprintfmt+0x156>
ffffffffc0206596:	000a6603          	lwu	a2,0(s4)
ffffffffc020659a:	46c1                	li	a3,16
ffffffffc020659c:	8a2e                	mv	s4,a1
ffffffffc020659e:	b5a1                	j	ffffffffc02063e6 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02065a0:	9902                	jalr	s2
ffffffffc02065a2:	bf09                	j	ffffffffc02064b4 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02065a4:	85a6                	mv	a1,s1
ffffffffc02065a6:	02d00513          	li	a0,45
ffffffffc02065aa:	e03e                	sd	a5,0(sp)
ffffffffc02065ac:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02065ae:	6782                	ld	a5,0(sp)
ffffffffc02065b0:	8a66                	mv	s4,s9
ffffffffc02065b2:	40800633          	neg	a2,s0
ffffffffc02065b6:	46a9                	li	a3,10
ffffffffc02065b8:	b53d                	j	ffffffffc02063e6 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02065ba:	03b05163          	blez	s11,ffffffffc02065dc <vprintfmt+0x34c>
ffffffffc02065be:	02d00693          	li	a3,45
ffffffffc02065c2:	f6d79de3          	bne	a5,a3,ffffffffc020653c <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02065c6:	00002417          	auipc	s0,0x2
ffffffffc02065ca:	4b240413          	addi	s0,s0,1202 # ffffffffc0208a78 <syscalls+0x118>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065ce:	02800793          	li	a5,40
ffffffffc02065d2:	02800513          	li	a0,40
ffffffffc02065d6:	00140a13          	addi	s4,s0,1
ffffffffc02065da:	bd6d                	j	ffffffffc0206494 <vprintfmt+0x204>
ffffffffc02065dc:	00002a17          	auipc	s4,0x2
ffffffffc02065e0:	49da0a13          	addi	s4,s4,1181 # ffffffffc0208a79 <syscalls+0x119>
ffffffffc02065e4:	02800513          	li	a0,40
ffffffffc02065e8:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02065ec:	05e00413          	li	s0,94
ffffffffc02065f0:	b565                	j	ffffffffc0206498 <vprintfmt+0x208>

ffffffffc02065f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02065f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02065fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02065fc:	ec06                	sd	ra,24(sp)
ffffffffc02065fe:	f83a                	sd	a4,48(sp)
ffffffffc0206600:	fc3e                	sd	a5,56(sp)
ffffffffc0206602:	e0c2                	sd	a6,64(sp)
ffffffffc0206604:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206606:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206608:	c89ff0ef          	jal	ra,ffffffffc0206290 <vprintfmt>
}
ffffffffc020660c:	60e2                	ld	ra,24(sp)
ffffffffc020660e:	6161                	addi	sp,sp,80
ffffffffc0206610:	8082                	ret

ffffffffc0206612 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206612:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc0206616:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0206618:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc020661a:	cb81                	beqz	a5,ffffffffc020662a <strlen+0x18>
        cnt ++;
ffffffffc020661c:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc020661e:	00a707b3          	add	a5,a4,a0
ffffffffc0206622:	0007c783          	lbu	a5,0(a5)
ffffffffc0206626:	fbfd                	bnez	a5,ffffffffc020661c <strlen+0xa>
ffffffffc0206628:	8082                	ret
    }
    return cnt;
}
ffffffffc020662a:	8082                	ret

ffffffffc020662c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020662c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020662e:	e589                	bnez	a1,ffffffffc0206638 <strnlen+0xc>
ffffffffc0206630:	a811                	j	ffffffffc0206644 <strnlen+0x18>
        cnt ++;
ffffffffc0206632:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206634:	00f58863          	beq	a1,a5,ffffffffc0206644 <strnlen+0x18>
ffffffffc0206638:	00f50733          	add	a4,a0,a5
ffffffffc020663c:	00074703          	lbu	a4,0(a4)
ffffffffc0206640:	fb6d                	bnez	a4,ffffffffc0206632 <strnlen+0x6>
ffffffffc0206642:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0206644:	852e                	mv	a0,a1
ffffffffc0206646:	8082                	ret

ffffffffc0206648 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206648:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020664a:	0005c703          	lbu	a4,0(a1)
ffffffffc020664e:	0785                	addi	a5,a5,1
ffffffffc0206650:	0585                	addi	a1,a1,1
ffffffffc0206652:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206656:	fb75                	bnez	a4,ffffffffc020664a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206658:	8082                	ret

ffffffffc020665a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020665a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020665e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206662:	cb89                	beqz	a5,ffffffffc0206674 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0206664:	0505                	addi	a0,a0,1
ffffffffc0206666:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206668:	fee789e3          	beq	a5,a4,ffffffffc020665a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020666c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206670:	9d19                	subw	a0,a0,a4
ffffffffc0206672:	8082                	ret
ffffffffc0206674:	4501                	li	a0,0
ffffffffc0206676:	bfed                	j	ffffffffc0206670 <strcmp+0x16>

ffffffffc0206678 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206678:	00054783          	lbu	a5,0(a0)
ffffffffc020667c:	c799                	beqz	a5,ffffffffc020668a <strchr+0x12>
        if (*s == c) {
ffffffffc020667e:	00f58763          	beq	a1,a5,ffffffffc020668c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0206682:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0206686:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206688:	fbfd                	bnez	a5,ffffffffc020667e <strchr+0x6>
    }
    return NULL;
ffffffffc020668a:	4501                	li	a0,0
}
ffffffffc020668c:	8082                	ret

ffffffffc020668e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020668e:	ca01                	beqz	a2,ffffffffc020669e <memset+0x10>
ffffffffc0206690:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206692:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206694:	0785                	addi	a5,a5,1
ffffffffc0206696:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020669a:	fec79de3          	bne	a5,a2,ffffffffc0206694 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020669e:	8082                	ret

ffffffffc02066a0 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02066a0:	ca19                	beqz	a2,ffffffffc02066b6 <memcpy+0x16>
ffffffffc02066a2:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02066a4:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02066a6:	0005c703          	lbu	a4,0(a1)
ffffffffc02066aa:	0585                	addi	a1,a1,1
ffffffffc02066ac:	0785                	addi	a5,a5,1
ffffffffc02066ae:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02066b2:	fec59ae3          	bne	a1,a2,ffffffffc02066a6 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02066b6:	8082                	ret
