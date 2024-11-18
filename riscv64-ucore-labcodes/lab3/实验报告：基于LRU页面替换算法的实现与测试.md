### 实验报告：基于LRU页面替换算法的实现与测试

#### 设计思路
​	最初的想法是创建一个独立的线程，周期性地检查每一页的 `Accessed` 位，以获取每一页的访问热度。然而，由于当前操作系统还不支持多线程，因此我们将周期性检查每一页的 `Accessed` 位并获取热度的操作放在了发生页面故障（page fault）时。这样可以在每次页面故障发生时，扫描可用页中的 `Accessed` 位，如果为1则访问热度+1，并把 `Accessed` 位置0，动态地更新页面的访问计数器，从而实现LRU页面替换算法。

​	为了实现这一目标，我们在 `Page` 结构体中增加了一个 `uint32_t access_count` 字段，用于记录每个页面的访问次数。

#### 代码实现

```c
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);

    struct Page *least_used_page = NULL;
    uint32_t min_access_count = 4294967295;

    list_entry_t *entry = list_next(head);
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

    if (least_used_page != NULL) {
        *ptr_page = least_used_page;
        cprintf("Swapping out page at %p with access count: %d\n", least_used_page->pra_vaddr, least_used_page->access_count);
        return 0;
    }

    return -1; // 如果没有找到合适的页面，返回错误码
}
```

​	`_lru_swap_out_victim` 函数的主要任务是在发生页面故障时选择一个最不常使用的页面进行替换。首先，我们从 `mm->sm_priv` 获取页面链表的头部，并确保链表头部不为空。接下来，我们初始化两个变量：`least_used_page` 用于存储访问次数最少的页面，`min_access_count` 用于记录当前最小的访问次数，初始值设为最大值 `4294967295`。

​	然后，我们遍历链表中的每个页面节点。对于每个页面，我们通过 `get_pte` 函数获取其页表项，并检查 `Accessed` 位是否被设置。如果页面被访问过，我们增加其访问计数器并清除 `Accessed` 位。接着，我们比较当前页面的访问计数器与 `min_access_count`，如果当前页面的访问计数器更小或相等，我们就更新 `least_used_page` 和 `min_access_count`。

​	在遍历完成后，如果找到了访问次数最少的页面，我们将其返回；否则，返回错误码 `-1` 表示没有找到合适的页面。

#### 实验运行测试

为进行页面置换算法的测试，我设计了以下内存访问操作：

```c
1    *(unsigned char *)0x3000 = 0x0c;
2    *(unsigned char *)0x1000 = 0x0a;
3    *(unsigned char *)0x4000 = 0x0d;
4    *(unsigned char *)0x2000 = 0x0b;
5    *(unsigned char *)0x5000 = 0x0e;
6    *(unsigned char *)0x2000 = 0x0b;
7    *(unsigned char *)0x2000 = 0x0b;
8    *(unsigned char *)0x3000 = 0x0c;
9    *(unsigned char *)0x4000 = 0x0d;
10   *(unsigned char *)0x5000 = 0x0e;
11   *(unsigned char *)0x1000 = 0x0a;
```

#### 结果分析

运行测试结果如下（我把输出的结果切成片段以便于讲解）：

```
_lru_check_swap开始
下一条是*(unsigned char *)0x3000 = 0x0c;
下一条是*(unsigned char *)0x1000 = 0x0a;
下一条是*(unsigned char *)0x4000 = 0x0d;
下一条是*(unsigned char *)0x2000 = 0x0b;
```

前四次内存访问没有触发页面故障，因为这些页面在之前的测试中已经被加载到内存中。此时，每个页面的访问计数器都增加了一次。

```
下一条是*(unsigned char *)0x5000 = 0x0e;
Store/AMO page fault
page fault at 0x00005000: K/W
List state before swapping out:
Page at 0x1000 has access count: 1
Page at 0x2000 has access count: 1
Page at 0x3000 has access count: 1
Page at 0x4000 has access count: 1
Swapping out page at 0x4000 with access count: 1
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
```

第五次内存访问 `0x5000` 触发了页面故障。此时，所有页面的访问计数器都是 1。根据 LRU 算法，这里选择了 `0x4000` 页面进行替换，并将其存储到磁盘的交换区。

```
下一条是*(unsigned char *)0x2000 = 0x0b;
下一条是*(unsigned char *)0x2000 = 0x0b;
下一条是*(unsigned char *)0x3000 = 0x0c;
下一条是*(unsigned char *)0x4000 = 0x0d;
Store/AMO page fault
page fault at 0x00004000: K/W
List state before swapping out:
Page at 0x1000 has access count: 1
Page at 0x2000 has access count: 2
Page at 0x3000 has access count: 2
Page at 0x5000 has access count: 1
Swapping out page at 0x5000 with access count: 1
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
```

接下来的几次内存访问继续更新页面的访问计数器。当再次访问 `0x4000` 时，触发了页面故障。此时，`0x2000` 和 `0x3000` 的访问计数器为 2（这是因为又对 `0x2000` 和 `0x3000` 分别进行了2次和1次的内存访问，但由于扫描只发生在产生页面故障时，因此，`0x2000` 的访问计数器只为2）而 `0x1000` 和 `0x5000` 的访问计数器为 1（因为没有再对他们进行内存访问）。根据 LRU 算法，选择访问计数器最小的页面进行替换，这里选择了 `0x5000` 页面进行替换，并将其存储到磁盘的交换区，同时将 `0x4000` 页面从磁盘加载回内存。

```
下一条是*(unsigned char *)0x5000 = 0x0e;
Store/AMO page fault
page fault at 0x00005000: K/W
List state before swapping out:
Page at 0x1000 has access count: 1
Page at 0x2000 has access count: 2
Page at 0x3000 has access count: 2
Page at 0x4000 has access count: 1
Swapping out page at 0x4000 with access count: 1
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
下一条是*(unsigned char *)0x1000 = 0x0a;
count is 1, total is 8
check_swap() succeeded!
```

最后一次内存访问 `0x5000` 再次触发了页面故障。此时，`0x2000` 和 `0x3000` 的访问计数器为 2，而 `0x1000` 和 `0x4000` 的访问计数器为 1。根据 LRU 算法，选择访问计数器最小的页面进行替换，这里选择了 `0x4000` 页面进行替换，并将其存储到磁盘的交换区，同时将 `0x5000` 页面从磁盘加载回内存。

#### 改进方向

- 可以考虑优化访问计数器的更新机制，减少对页表项的频繁访问，提高算法的效率。
- 目前的版本中如果没有发生页面故障将无法更新计数器，当操作系统支持多线程时，可以将扫描页面并更新计数器的任务交给一个单独的线程来做。
- 目前LRU算法所设定的追踪访问热度的时间范围是无限长，因此访问热度可能受很久之前的访问影响，可以考虑缩小时间范围。
- 算法为每个物理页都设计了计数器，这样可能会增加开销，可以考虑只为被分配的物理页设置计数器。

