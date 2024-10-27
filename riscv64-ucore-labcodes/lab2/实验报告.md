在 Challenge 1 中，我们实现了一个基于伙伴系统（Buddy System）的物理内存管理器，将系统中的可用存储空间划分为存储块（Block）进行管理。每个存储块的大小必须是2的n次幂，这种设计使得内存的分配和释放更加高效，避免了内存碎片化问题。通过这种方式，内存管理器能够动态地分配和回收存储块，确保内存的有效利用，并支持不同大小内存请求的处理。同时，伙伴系统允许将相邻的空闲块合并，从而进一步提高了内存管理的灵活性和效率。
以下是代码的主要模块和功能的分解：
### 1. **辅助函数**

---

#### 1. `IS_POWER_OF_2`

```c
static int IS_POWER_OF_2(size_t n)
```

- **功能**：判断一个数是否是2的幂。



---

#### 2. `getOrderOf2`

```c
static unsigned int getOrderOf2(size_t n)
```

- **功能**：获取不大于 `n` 的最大2的幂的阶次。



---

#### 3. `ROUNDDOWN2`

```c
static size_t ROUNDDOWN2(size_t n)
```

- **功能**：将 `n` 向下舍入到最近的2的幂。
- **逻辑**：
  - 通过不断右移 `n` 直到只剩1位1，然后将结果左移回原位数，以获得比 `n` 小的最大2的幂。
  - 若 `n` 已是2的幂，直接返回 `n`。

---

#### 4. `ROUNDUP2`

```c
static size_t ROUNDUP2(size_t n)
```

- **功能**：将 `n` 向上舍入到最近的2的幂。


---

#### 5. `get_buddy`

```c
struct Page *get_buddy(struct Page *block_addr, unsigned int block_size)
```

- **功能**：根据当前块的地址和大小计算并返回它的伙伴块。
- **逻辑**：
  - 通过 `block_addr` 按块大小偏移的异或运算得到伙伴块地址。
  - 若 `block_size` 为 `n`，将 `block_addr` 与 `1 << n`（块大小的偏移）异或，可以找到该块的伙伴地址。


---

### 2. **初始化函数**

---

####  1.`buddy_system_init`

- **功能**：负责伙伴系统的整体初始化，设定系统初始状态。
- **逻辑**：
  1. 使用循环初始化 `buddy_array` 数组，每一个数组项代表一类特定大小的块（即2的幂次方），并将所有空闲链表初始化为空。
  2. 将最大块级别（`max_order`）和当前空闲页总数（`nr_free`）都置为零。
  
该函数的目的是在系统启动时，为伙伴系统做好初步配置。

**代码解释**：
```c
static void buddy_system_init(void) {
    for (int i = 0; i < MAX_BUDDY_ORDER + 1; i++) {
        list_init(buddy_array + i); // 初始化每个块大小对应的空闲链表
    }
    max_order = 0;   // 最大块大小设置为0（即最小）
    nr_free = 0;     // 无空闲页块
    return;
}
```

---

#### 2.`buddy_system_init_memmap`

- **功能**：初始化特定内存页结构，主要是将一段连续的物理内存初始化为可用于分配的块。
- **逻辑**：
  1. 对齐起始地址到最接近的2的幂次方大小，确保伙伴系统的块大小是2的幂次方。
  2. 调用 `ROUNDDOWN2` 函数将请求的页数 `n` 向下舍入到最接近的2的幂次方大小，得到 `pnum`。
  3. 计算 `pnum` 的2的幂次数级（`order`），作为块级别。
  4. 初始化所有页面的属性：
     - 重置页的标记为非保留（标记空闲）。
     - 设置 `flags` 为0，清空属性位。
     - 将 `property` 设置为 -1 表示无效状态。
  5. 初始化空闲链表，将起始页添加到最大级别的空闲链表中。
  6. 设置 `max_order` 为计算得到的 `order`，并设置 `nr_free` 为可用页的数量 `pnum`。
  7. 设置 `base->property` 为最大级别 `max_order`，并将此块标记为空闲块（`SetPageProperty`）。

**代码解释**：
```c
static void buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);  // 保证初始化页数大于0

    size_t pnum = ROUNDDOWN2(n);  // 向下舍入到2的幂次方大小
    unsigned int order = getOrderOf2(pnum); // 计算块的2的幂次数级

    // 初始化每一页的属性
    for (struct Page *p = base; p != base + pnum; p++) {
        assert(PageReserved(p)); // 确认该页为保留状态
        p->flags = 0;            // 重置标志
        p->property = -1;        // 设置属性为无效
        set_page_ref(p, 0);      // 设置引用计数为0
    }

    max_order = order;           // 更新最大块级别
    nr_free = pnum;              // 可用页数更新为 pnum
    list_add(&(buddy_array[max_order]), &(base->page_link)); // 将最大块加入空闲链表

    base->property = max_order;  // 设置最大块的属性
    SetPageProperty(base);       // 将块标记为空闲块

    return;
}
```



在整个 `buddy_system_init` 和 `buddy_system_init_memmap` 的过程中，关键在于：
- 确保块大小为2的幂次方；
- 按大小分类，方便分配和回收。



























### 3. **内存分配与释放**:


#### 1. `buddy_system_free_pages(struct Page *base, size_t n)` 
`buddy_system_free_pages` 函数的功能是释放一块内存并根据需要合并相邻的空闲块。这是伙伴系统内存管理的一部分，通过合并空闲块来高效利用内存。

#### 代码分析

```c
static void buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);  // 确保释放的页数 n 大于 0。
    unsigned int pnum = 1 << (base->property);  // 块中页的数目
    assert(ROUNDUP2(n) == pnum);  // 检查释放的页数是否等于块中的页数。
    cprintf("buddy system分配释放第NO.%d页开始共%d页\n", page2ppn(base), pnum);  // 输出释放信息。

    struct Page *left_block = base;  // 当前释放块的头页
    struct Page *buddy = NULL;  // 伙伴块指针
    struct Page *tmp = NULL;  // 临时变量用于交换指针

    // 将当前块插入对应的链表中
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));  

    // 获取与 left_block 相关的伙伴块
    buddy = get_buddy(left_block, left_block->property);
    
    // 当伙伴块空闲且当前块不为最大块时，执行合并
    while (PageProperty(buddy) && left_block->property < max_order) {
        if (left_block > buddy) {  // 若当前块为更大块的右块
            left_block->property = -1;  // 将左块的属性置为无效
            SetPageProperty(base);  // 标记为空闲块的第一个页面
            
            // 交换左右块，使其位置正确
            tmp = left_block;  // 保存左块到临时变量
            left_block = buddy;  // 使左块指向较小的伙伴块
            buddy = tmp;  // 使伙伴块指向较大的左块
        }
        
        // 删除链表中的两个小块
        list_del(&(left_block->page_link));  // 从链表中删除左块
        list_del(&(buddy->page_link));  // 从链表中删除伙伴块
        
        left_block->property += 1;  // 左块属性加一，表示块大小加倍
        
        // 将合并后的块插入到相应链表中
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
        
        // 重置伙伴块指针，准备下一轮合并
        buddy = get_buddy(left_block, left_block->property);
    }
    
    SetPageProperty(left_block);  // 将回收块的头页设置为空闲
    nr_free += pnum;  // 增加空闲页数

    return;  // 函数结束
}
```

#### 具体步骤

1. **参数检查**:
   - `assert(n > 0);`：确保释放的页数 `n` 大于 0。如果不满足条件，程序会在调试模式下终止执行。
   - `assert(ROUNDUP2(n) == pnum);`：检查释放的页数是否等于块中的页数，以确保释放的页数和块大小一致。

2. **输出释放信息**:
   - `cprintf("buddy system分配释放第NO.%d页开始共%d页\n", page2ppn(base), pnum);`：输出当前释放操作的信息，包括页号和释放的页数，有助于调试和内存管理的追踪。

3. **插入到空闲链表**:
   - `list_add(&(buddy_array[left_block->property]), &(left_block->page_link));`：将当前块插入到对应的伙伴链表中，为后续的内存分配提供可用块。

4. **伙伴块合并逻辑**:
   - 在 `while` 循环中，不断检查 `buddy` 块是否空闲，并执行合并操作。如果当前块是伙伴块的右块，进行位置交换并更新属性，然后从链表中删除两个小块。

5. **更新空闲链表**:
   - 每次合并后，更新链表，以确保内存管理的完整性和高效性。将合并后的块插入到其新的大小对应的链表中。

6. **更新空闲页数**:
   - `nr_free += pnum;`：在完成合并和释放操作后，更新空闲页数，以确保内存管理的数据一致性。

这段代码实现了伙伴内存管理中的释放和合并功能，确保内存能够高效地被使用和回收。



### 2. `buddy_system_alloc_pages(size_t requested_pages)` 
`buddy_system_alloc_pages` 函数的功能是根据请求的页数分配内存。如果请求的页数超过可用页数，函数会返回 `NULL`。否则，它会在空闲链表中寻找合适的内存块进行分配，并在必要时对大块进行分割。

#### 代码分析

```c
static struct Page *buddy_system_alloc_pages(size_t requested_pages) {
    assert(requested_pages > 0);  // 确保请求的页数大于0

    // 检查请求的页数是否超过可用页数
    if (requested_pages > nr_free) {
        return NULL; // 如果请求页数大于可用页数，返回NULL
    }

    struct Page *allocated_page = NULL;
    size_t adjusted_pages = ROUNDUP2(requested_pages); 
    size_t order_of_2 = getOrderOf2(adjusted_pages);  

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
```

#### 具体步骤

1. **参数检查**:
   - `assert(requested_pages > 0);`：确保请求的页数大于 0。如果不满足条件，程序会在调试模式下终止执行。

2. **可用页数检查**:
   - `if (requested_pages > nr_free) { return NULL; }`：检查请求的页数是否超过当前可用页数 `nr_free`。如果超过，则返回 `NULL`，表示内存分配失败。

3. **调整请求的页数**:
   - `size_t adjusted_pages = ROUNDUP2(requested_pages);`：将请求的页数向上取整为最接近的 2 的幂，以适应伙伴系统的内存分配策略。

4. **获取块的订单**:
   - `size_t order_of_2 = getOrderOf2(adjusted_pages);`：计算调整后的页数对应的块的订单。

5. **查找合适的空闲块**:
   - `while (1)` 循环：持续查找合适的空闲块。
   - `if (!list_empty(&(buddy_array[order_of_2])))`：检查当前订单的空闲链表是否为空。如果不为空，说明有合适的内存块可供分配。
   - `allocated_page = le2page(list_next(&(buddy_array[order_of_2])), page_link);`：获取空闲链表中的第一个块并将其分配给 `allocated_page`。
   - `list_del(list_next(&(buddy_array[order_of_2])));`：从空闲链表中删除该块，标记为已分配。
   - `ClearPageProperty(allocated_page);`：清除所分配块的标记，表示该块现在已被使用。

6. **查找更大的块并进行分割**:
   - `if (!list_empty(&(buddy_array[order_of_2])))` 失败时，进入 `for` 循环：
   - `for (int i = order_of_2 + 1; i <= max_order; ++i)`：查找比当前订单更大的块。如果找到，则调用 `buddy_split(i)` 将其分割为两个较小的块。
   - 设置 `found_larger_block` 为 1，表示找到了可用的较大块。

7. **更新可用页数**:
   - `if (allocated_page != NULL) { nr_free -= adjusted_pages; }`：如果成功分配了块，减少可用页数 `nr_free`。

8. **返回分配的页面**:
   - 最后，返回分配的页面指针 `allocated_page`，若分配失败则为 `NULL`。








### 4. **内存分裂与合并**:

#### 1. `buddy_split(size_t n)` 
`buddy_split` 函数的功能是将一个大小为 \(2^n\) 的内存块分裂成两个大小为 \(2^{n-1}\) 的块。这是伙伴系统管理内存的一部分，通过分裂和合并来高效地使用内存。

#### 代码分析

```c
static void buddy_split(size_t n) {
    assert(n > 0 && n <= max_order);  // 检查n的有效性
    assert(!list_empty(&(buddy_array[n])));  // 确保当前有可用的块

    struct Page *page_a;  // 指向第一个块
    struct Page *page_b;  // 指向第二个块（伙伴块）

    // 获取当前空闲链表中的第一个块
    page_a = le2page(list_next(&(buddy_array[n])), page_link);
    
    // 计算伙伴块的地址，找到page_a的伙伴块page_b
    page_b = page_a + (1 << (n - 1));

    // 设置page_a和page_b的属性，标记为大小n-1
    page_a->property = n - 1;
    page_b->property = n - 1;

    // 从空闲链表中删除page_a
    list_del(list_next(&(buddy_array[n])));

    // 将page_a和page_b插入到大小为n-1的空闲链表中
    list_add(&(buddy_array[n - 1]), &(page_a->page_link));
    list_add(&(page_a->page_link), &(page_b->page_link));

    return;
}
```

#### 具体步骤

1. **参数检查**:
   - `assert(n > 0 && n <= max_order);`：确保输入参数 `n` 大于 0 且小于等于最大订单（`max_order`）。如果不满足条件，程序会在调试模式下终止执行。
   - `assert(!list_empty(&(buddy_array[n])));`：确保当前的伙伴数组 `buddy_array[n]` 中有可用的内存块。如果没有可用块，程序同样会在调试模式下终止。

2. **获取空闲块**:
   - `page_a = le2page(list_next(&(buddy_array[n])), page_link);`：获取当前大小为 \(2^n\) 的空闲链表中的第一个块 `page_a`。`list_next` 函数返回链表中的下一个元素，通过 `le2page` 将其转换为 `struct Page *` 类型。

3. **计算伙伴块地址**:
   - `page_b = page_a + (1 << (n - 1));`：计算 `page_b` 的地址。伙伴块 `page_b` 是 `page_a` 的邻接块，地址为 `page_a` 加上 \(2^{(n-1)}\) 字节。由于内存连续，可以直接通过地址计算得到。

4. **设置块的属性**:
   - `page_a->property = n - 1;`：将 `page_a` 的属性设置为 \(n-1\)，表示它的大小为 \(2^{(n-1)}\)。
   - `page_b->property = n - 1;`：同样将 `page_b` 的属性设置为 \(n-1\)。

5. **更新空闲链表**:
   - `list_del(list_next(&(buddy_array[n])));`：从当前空闲链表中删除 `page_a`。`list_del` 函数用于删除指定的链表节点。
   - `list_add(&(buddy_array[n - 1]), &(page_a->page_link));`：将 `page_a` 插入到大小为 \(2^{(n-1)}\) 的空闲链表中。
   - `list_add(&(page_a->page_link), &(page_b->page_link));`：将 `page_b` 也插入到同样的空闲链表中，确保两个新块都在链表中。

#### 2. `buddy_system_free_pages(struct Page *base, size_t n)` 

#### 功能
`buddy_system_free_pages` 函数的功能是释放由 `base` 指向的内存块，并在可能的情况下将其与其伙伴块合并。它通过伙伴系统管理内存，以提高内存的利用效率。

#### 代码分析

```c
static void buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);  // 检查n是否大于0
    unsigned int pnum = 1 << (base->property);  // 计算块中页的数目
    assert(ROUNDUP2(n) == pnum);  // 检查释放的页数是否与块数相同
    cprintf("buddy system分配释放第NO.%d页开始共%d页\n", page2ppn(base), pnum);
    struct Page *left_block = base;  // 指向释放块的头页
    struct Page *buddy = NULL;  // 指向伙伴块
    struct Page *tmp = NULL;  // 临时变量用于交换

    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));  // 将当前块插入对应链表中

    // show_buddy_array(0, MAX_BUDDY_ORDER); // test point
    // 当伙伴块空闲，且当前块不为最大块时，执行合并
    buddy = get_buddy(left_block, left_block->property);  // 获取伙伴块
    while (PageProperty(buddy) && left_block->property < max_order) {
        if (left_block > buddy) {  // 若当前块是更大块的右块
            left_block->property = -1;  // 将左块幂次置为无效
            SetPageProperty(base);  // 设置页面的标志为PG_property，表示这是一个空闲块的第一个页面。
            // 交换左右块，使得位置正确
            tmp = left_block;
            left_block = buddy;
            buddy = tmp;
        }
        // 从链表中删除原来链表里的两个小块
        list_del(&(left_block->page_link));
        list_del(&(buddy->page_link));
        left_block->property += 1;  // 左块头页设置幂次加一
        // cprintf("left_block->property=%d\n", left_block->property); // test point
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link));  // 头插入相应链表
        // show_buddy_array(0, MAX_BUDDY_ORDER); // test point

        // 重置buddy开启下一轮循环
        buddy = get_buddy(left_block, left_block->property);  // 获取新的伙伴块
    }
    SetPageProperty(left_block);  // 将回收块的头页设置为空闲
    nr_free += pnum;  // 增加空闲页数
    // show_buddy_array(); // test point

    return;
}
```

#### 具体步骤

1. **参数检查**:
   - `assert(n > 0);`：确保释放的页数 `n` 大于 0。
   - `unsigned int pnum = 1 << (base->property);`：计算 `base` 所指向的内存块中页的数目。`property` 存储当前块的幂次，`1 << (base->property)` 计算出该块包含的页数。
   - `assert(ROUNDUP2(n) == pnum);`：检查释放的页数是否等于块中的页数，确保释放的页数与块的大小一致。

2. **输出调试信息**:
   - `cprintf` 输出当前释放的信息，包括页号和释放的页数。

3. **初始化指针**:
   - `struct Page *left_block = base;`：初始化 `left_block` 指针，指向待释放的块的头页。
   - `struct Page *buddy = NULL;` 和 `struct Page *tmp = NULL;`：初始化伙伴块和临时变量。

4. **将块添加到链表**:
   - `list_add(&(buddy_array[left_block->property]), &(left_block->page_link));`：将当前释放的块插入到相应的伙伴链表中，以便后续的分配操作可以使用。

5. **合并块**:
   - `buddy = get_buddy(left_block, left_block->property);`：获取与 `left_block` 相关的伙伴块。
   - 进入循环，判断伙伴块是否空闲且当前块的属性小于最大块：
     - `if (left_block > buddy)`：如果当前块是更大块的右块，则需要交换它们的位置。
     - `left_block->property = -1;`：将左块的属性设置为无效，表示该块不再有效。
     - `SetPageProperty(base);`：设置该页面的标志为 `PG_property`，表示这是一个空闲块的第一个页面。
     - 交换 `left_block` 和 `buddy` 的位置。
   - `list_del(&(left_block->page_link));` 和 `list_del(&(buddy->page_link));`：从链表中删除原来链表里的两个小块。
   - `left_block->property += 1;`：左块的头页设置幂次加一。
   - `list_add(&(buddy_array[left_block->property]), &(left_block->page_link));`：将合并后的块插入到相应的伙伴链表中。

6. **设置页属性**:
   - `SetPageProperty(left_block);`：将回收块的头页设置为空闲。
   - `nr_free += pnum;`：增加空闲页数。




### 5. **调试与检查**:
   - `show_buddy_array`: 遍历并打印伙伴系统空闲链表中块的信息。
   - `buddy_system_check`: 测试函数，包含一系列内存分配和释放的步骤，用于验证分配器是否工作正常。
