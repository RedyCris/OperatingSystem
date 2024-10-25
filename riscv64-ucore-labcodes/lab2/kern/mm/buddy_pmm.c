#include <pmm.h>
#include <list.h>
#include <stdio.h>
#include <buddy_pmm.h>
#include <string.h>

#define mem_begin 0xffffffffc020f318
#define buddy_array (buddy_s.free_array)
#define nr_free (buddy_s.nr_free)
#define max_order (buddy_s.max_order)


free_buddy_t buddy_s;

static size_t buddy_system_nr_free_pages(void)
{
    return nr_free;
}

static int IS_POWER_OF_2(size_t n)
{
    if (n & (n - 1))//对于 2 的幂次方数 n，n - 1 的二进制表示会把唯一的 1 位变为 0，而其余位变为 1。这样 n & (n - 1) 的结果就是 0
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

static unsigned int getOrderOf2(size_t n)
{
    unsigned int order = 0;
    while (n >> 1)
    {
        n >>= 1;
        order++;
    }
    return order;
}

static size_t ROUNDDOWN2(size_t n)
{
    size_t res = 1;
    if (!IS_POWER_OF_2(n))
    {
        while (n)
        {
            n = n >> 1;
            res = res << 1;
        }
        return res >> 1;
    }
    else
    {
        return n;
    }
}//n向下舍入到最接近的 2 的幂

static size_t ROUNDUP2(size_t n)
{
    size_t res = 1;
    if (!IS_POWER_OF_2(n))
    {
        while (n)
        {
            n = n >> 1;
            res = res << 1;
        }
        return res;
    }
    else
    {
        return n;
    }
}//n 向上舍入到最接近的 2 的幂

static void buddy_split(size_t n)
{
    assert(n > 0 && n <= max_order);
    assert(!list_empty(&(buddy_array[n])));
    struct Page *page_a;
    struct Page *page_b;

    page_a = le2page(list_next(&(buddy_array[n])), page_link);
    page_b = page_a + (1 << (n - 1)); // 找到a的伙伴块b，地址连续，直接加2的n-1次幂就行
    page_a->property = n - 1;
    page_b->property = n - 1;

    //???//
    SetPageProperty(page_a);
    SetPageProperty(page_b);

    list_del(list_next(&(buddy_array[n])));
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
    list_add(&(page_a->page_link), &(page_b->page_link));

    return;
}//将一个大小为 2^n 的内存块分裂成两个大小为 2^(n-1) 的内存块

static void
show_buddy_array(int left, int right) // 左闭右闭
{
    bool empty = 1; // 表示空闲链表数组为空
    assert(left >= 0 && left <= max_order && right >= 0 && right <= max_order);
    for (int i = left; i <= right; i++)
    {
        list_entry_t *le = &buddy_array[i];
        if (list_next(le) != &buddy_array[i])
        {
            empty = 0;

            while ((le = list_next(le)) != &buddy_array[i])
            {
                cprintf("No.%d的空闲链表有", i);
                struct Page *p = le2page(le, page_link);
                cprintf("%d页 ", 1 << (p->property));
                cprintf("【地址为%p】\n", p);
            }
            if (i != right)
            {
                cprintf("\n");
            }
        }
    }
    if (empty)
    {
        cprintf("无空闲块！！！\n");
    }
    return;
}//遍历并打印出指定范围内的伙伴系统空闲链表的信息

static void
buddy_system_init(void)
{
    for (int i = 0; i < MAX_BUDDY_ORDER + 1; i++)
    {
        list_init(buddy_array + i);
    }
    max_order = 0;
    nr_free = 0;
    return;
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    
    size_t pnum = ROUNDDOWN2(n);
    unsigned int order = getOrderOf2(pnum);

   
    for (struct Page *p = base; p != base + pnum; p++) {
        assert(PageReserved(p));
        p->flags = 0;          
        p->property = -1;      
        set_page_ref(p, 0);    
    }

    max_order = order;
    nr_free = pnum;
    list_add(&(buddy_array[max_order]), &(base->page_link));

    
    base->property = max_order;
    SetPageProperty(base); // 初始化

    return;
}


static struct Page *
buddy_system_alloc_pages(size_t requested_pages) {
    assert(requested_pages > 0);

    // 检查请求的页数是否超过可用页数
    if (requested_pages > nr_free) {
        return NULL; // 如果请求页数大于可用页数，返回NULL
    }

    struct Page *allocated_page = NULL;
    size_t adjusted_pages = ROUNDUP2(requested_pages); // 向上取整
    size_t order_of_2 = getOrderOf2(adjusted_pages);   // 计算对应的2的幂

    // 查找合适的空闲块，若没有，则分割大块
    while (1) { // 使用1表示true
        if (!list_empty(&(buddy_array[order_of_2]))) {
            allocated_page = le2page(list_next(&(buddy_array[order_of_2])), page_link);
            list_del(list_next(&(buddy_array[order_of_2]))); // 从空闲链表中删除该块
            ClearPageProperty(allocated_page); // 清除头页的标记
            break; // 找到合适的块，退出循环
        } else {
            // 查找是否有更大的块可供分裂
            int found_larger_block = 0; // 使用整数替代布尔值
            for (int i = order_of_2 + 1; i <= max_order; ++i) {
                if (!list_empty(&(buddy_array[i]))) {
                    buddy_split(i); // 分裂大块
                    found_larger_block = 1; // 设置为1表示找到大块
                    break;
                }
            }
            // 如果没有找到合适的块，分配失败
            if (!found_larger_block) {
                break;
            }
        }
    }

    // 更新可用页数
    if (allocated_page != NULL) {
        nr_free -= adjusted_pages; // 减少可用页数
    }

    return allocated_page; // 返回分配的页面
}


struct Page *get_buddy(struct Page *block_addr, unsigned int block_size)
{
    size_t real_block_size = 1 << block_size;                    
    size_t relative_block_addr = (size_t)block_addr - mem_begin; // 计算对于第一个页的偏移量

    size_t sizeOfPage = real_block_size * sizeof(struct Page);                  
    size_t buddy_relative_addr = (size_t)relative_block_addr ^ sizeOfPage;      // 异或得到伙伴块的相对地址
    struct Page *buddy_page = (struct Page *)(buddy_relative_addr + mem_begin); // 返回伙伴块指针
    return buddy_page;
}

static void buddy_system_free_pages(struct Page *base, size_t n)
{
    assert(n > 0);
    unsigned int pnum = 1 << (base->property); // 块中页的数目
    assert(ROUNDUP2(n) == pnum);
    cprintf("buddy system分配释放第NO.%d页开始共%d页\n", page2ppn(base), pnum);
    struct Page *left_block = base; // 放块的头页
    struct Page *buddy = NULL;
    struct Page *tmp = NULL;

    list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 将当前块先插入对应链表中

    // show_buddy_array(0, MAX_BUDDY_ORDER); // test point
    // 当伙伴块空闲，且当前块不为最大块时，执行合并
    buddy = get_buddy(left_block, left_block->property);
    while (PageProperty(buddy) && left_block->property < max_order)
    {
        if (left_block > buddy)
        {                              // 若当前左块为更大块的右块
            left_block->property = -1; // 将左块幂次置为无效
            SetPageProperty(base);     // 将页面的标志设置为 PG_property，表示这是一个空闲块的第一个页面。
            // 交换左右使得位置正确
            tmp = left_block;
            left_block = buddy;
            buddy = tmp;
        }
        // 删掉原来链表里的两个小块
        list_del(&(left_block->page_link));
        list_del(&(buddy->page_link));
        left_block->property += 1; // 左快头页设置幂次加一
        // cprintf("left_block->property=%d\n", left_block->property); //test point
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); // 头插入相应链表
        // show_buddy_array(0, MAX_BUDDY_ORDER); // test point

        // 重置buddy开启下一轮循环***
        buddy = get_buddy(left_block, left_block->property);
    }
    SetPageProperty(left_block); // 将回收块的头页设置为空闲
    nr_free += pnum;
    // show_buddy_array(); // test point

    return;
}



static void
buddy_system_check(void)
{
    cprintf("总空闲块数目为：%d\n", nr_free);
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;

    cprintf("首先p0请求5页\n");
    p0 = alloc_pages(5);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("然后p1请求5页\n");
    p1 = alloc_pages(5);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("最后p2请求5页\n");
    p2 = alloc_pages(5);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    cprintf("p0的虚拟地址0x%016lx.\n", p0);// 0x8020f318
    cprintf("p1的虚拟地址0x%016lx.\n", p1);// 0x8020f458,和p0相差0x140=0x28*5
    cprintf("p2的虚拟地址0x%016lx.\n", p2);// 0x8020f598,和p1相差0x140=0x28*5

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_pages(p0, 5);
    cprintf("释放p0后，总空闲块数目为：%d\n", nr_free); // 变成了8
    show_buddy_array(0, MAX_BUDDY_ORDER);

    free_pages(p1, 5);
    cprintf("释放p1后，总空闲块数目为：%d\n", nr_free); // 变成了16
    show_buddy_array(0, MAX_BUDDY_ORDER);

    free_pages(p2, 5);
    cprintf("释放p2后，总空闲块数目为：%d\n", nr_free); // 变成了24
    show_buddy_array(0, MAX_BUDDY_ORDER);

    nr_free = 16384;

    struct Page *p3 = alloc_pages(16384);
    show_buddy_array(0, MAX_BUDDY_ORDER);

    // 全部回收
    free_pages(p3, 16384);
    show_buddy_array(0, MAX_BUDDY_ORDER);
}


const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};
