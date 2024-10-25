#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

#define MAX_ORDER 10   // 假设最大阶数为10, 即最大块大小为2^10页

typedef struct {
    list_entry_t free_list[MAX_ORDER + 1];
    size_t nr_free[MAX_ORDER + 1];
} buddy_free_area_t;

buddy_free_area_t buddy_free_area;

#define free_list(order) (buddy_free_area.free_list[order])
#define nr_free(order) (buddy_free_area.nr_free[order])

static void
buddy_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&free_list(i));
        nr_free(i) = 0;
    }
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    int order;
    
    // 将整个内存块按2的幂次方对齐初始化
    while (n > 0) {
        order = 0;
        size_t block_size = 1;
        
        // 找到最大的对齐块
        while (block_size * 2 <= n) {
            block_size *= 2;
            order++;
        }

        struct Page *p = base;
        p->property = order;
        SetPageProperty(p);
        list_add(&free_list(order), &(p->page_link));
        nr_free(order)++;

        n -= block_size;
        base += block_size;
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    int order = 0;
    size_t block_size = 1;

    // 查找合适的块
    while (block_size < n) {
        block_size *= 2;
        order++;
    }
    
    if (order > MAX_ORDER) {
        return NULL;  // 请求的块大小超过最大块
    }

    int curr_order = order;
    while (curr_order <= MAX_ORDER && list_empty(&free_list(curr_order))) {
        curr_order++;
    }

    if (curr_order > MAX_ORDER) {
        return NULL;  // 没有足够大的空闲块
    }

    // 分裂块直到匹配请求的大小
    while (curr_order > order) {
        struct Page *p = le2page(list_next(&free_list(curr_order)), page_link);
        list_del(&(p->page_link));
        nr_free(curr_order)--;

        curr_order--;
        struct Page *buddy = p + (1 << curr_order);
        buddy->property = curr_order;
        SetPageProperty(buddy);
        list_add(&free_list(curr_order), &(buddy->page_link));
        nr_free(curr_order)++;
    }

    // 分配最终的块
    struct Page *page = le2page(list_next(&free_list(order)), page_link);
    list_del(&(page->page_link));
    nr_free(order)--;

    ClearPageProperty(page);
    return page;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    int order = 0;
    size_t block_size = 1;

    while (block_size < n) {
        block_size *= 2;
        order++;
    }

    base->property = order;
    SetPageProperty(base);

    // 合并相邻的伙伴块
    while (order < MAX_ORDER) {
        struct Page *buddy = base + (base - mem_start) / (1 << order) % 2 * (1 << order) - (base - mem_start) % (2 * (1 << order));
        
        if (!PageProperty(buddy) || buddy->property != order) {
            break;  // 伙伴不可合并
        }

        list_del(&(buddy->page_link));
        nr_free(order)--;
        
        if (buddy < base) {
            base = buddy;
        }
        
        order++;
        base->property = order;
    }

    list_add(&free_list(order), &(base->page_link));
    nr_free(order)++;
}

static size_t
buddy_nr_free_pages(void) {
    size_t total = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        total += nr_free(i) * (1 << i);
    }
    return total;
}

static void
buddy_basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = buddy_alloc_pages(1)) != NULL);
    assert((p1 = buddy_alloc_pages(2)) != NULL);
    assert((p2 = buddy_alloc_pages(3)) != NULL);
    buddy_free_pages(p0, 1);
    buddy_free_pages(p1, 2);
    buddy_free_pages(p2, 3);
    assert(buddy_nr_free_pages() == 6);
}
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_basic_check,
};

