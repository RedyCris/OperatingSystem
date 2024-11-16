#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */
extern list_entry_t pra_list_head;
list_entry_t  *curr_ptr2;
/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_lru_init_mm(struct mm_struct *mm)
{     
     /*LAB3 扩展练习 Challenge: 2213904*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr2指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);//初始化
     curr_ptr2=&pra_list_head;//curr_ptr2指向当前页面替换的位置（初始值为链表头部）
     mm->sm_priv=&pra_list_head;
     return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr2 != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2210917*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_entry_t *head=mm->sm_priv;
    list_add(list_prev(curr_ptr2),entry);//将新页面插入到链表中 curr_ptr2 前一个位置（相当于插入到链表末尾）
    page->visited=1;
    page->access_count = 0;  // 初始化访问计数器
    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);

    struct Page *least_used_page = NULL;
    uint32_t min_access_count = 4294967295;

    list_entry_t *entry = list_next(head);


    entry = list_next(head);
    while (entry != head) {
        struct Page *page = le2page(entry, pra_page_link);

        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        if (ptep && (*ptep & PTE_A)) { // 检查页表项的 Accessed 位
            page->access_count++;
            *ptep &= ~PTE_A; // 清除 Accessed 位
        }

        if (page->access_count <= min_access_count) {
            least_used_page = page;
            min_access_count = page->access_count;
        }

        entry = list_next(entry);
    }

    // 输出链表的完整状态
    cprintf("List state before swapping out:\n");
    entry = list_next(head);
    while (entry != head) {
        struct Page *page = le2page(entry, pra_page_link);
        cprintf("Page at %p has access count: %d\n", page->pra_vaddr, page->access_count);
        entry = list_next(entry);
    }

    if (least_used_page != NULL) {
        *ptr_page = least_used_page;
        cprintf("Swapping out page at %p with access count: %d\n", least_used_page->pra_vaddr, least_used_page->access_count);
        return 0;
    }

    return -1; // 如果没有找到合适的页面，返回错误码
}

static int
_lru_check_swap(void) {
#ifdef ucore_test
    int score = 0, totalscore = 5;
    cprintf("%d\n", &score);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    ++ score; cprintf("grading %d/%d points", score, totalscore);
#else 
    cprintf("_lru_check_swap开始\n");
    cprintf("下一条是*(unsigned char *)0x3000 = 0x0c;\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    cprintf("下一条是*(unsigned char *)0x1000 = 0x0a;\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    cprintf("下一条是*(unsigned char *)0x4000 = 0x0d;\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==4);
    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);

    cprintf("下一条是*(unsigned char *)0x5000 = 0x0e;\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);

    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);

    cprintf("下一条是*(unsigned char *)0x2000 = 0x0b;\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);

    cprintf("下一条是*(unsigned char *)0x3000 = 0x0c;\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==5);

    cprintf("下一条是*(unsigned char *)0x4000 = 0x0d;\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==6);
    cprintf("下一条是*(unsigned char *)0x5000 = 0x0e;\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==7);
    assert(*(unsigned char *)0x1000 == 0x0a);

    cprintf("下一条是*(unsigned char *)0x1000 = 0x0a;\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==7);
#endif
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }


struct swap_manager swap_manager_lru = {
    .name            = "lru swap manager",
    .init            = &_lru_init,
    .init_mm         = &_lru_init_mm,
    .tick_event      = &_lru_tick_event,
    .map_swappable   = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap      = &_lru_check_swap,
};
