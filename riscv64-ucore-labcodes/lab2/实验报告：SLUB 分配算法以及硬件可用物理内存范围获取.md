# 实验报告：SLUB 分配算法以及硬件可用物理内存范围获取
## SLUB 分配算法设计

### 实验目的

本实验计划在first_fit内存分配算法的基础上实现一个简单的 SLUB 内存分配算法。SLUB（Simple List of Unused Blocks）是一种高效的内存分配器，旨在减少内存碎片并提高分配和释放的速度。通过本实验，我们将实现 SLUB 分配算法，并对其进行测试和验证。

### 新的管理结构体

在实现 SLUB 分配算法的过程中，我们引入了以下结构体：

#### 1.`object_t` 结构体

```c
struct object_t {
    void *data;            // 指向实际数据的指针
    size_t size;          // 对象的大小
    int ref_count;        // 引用计数，用于管理对象的生命周期
    unsigned int object_id; // 对象的唯一编号
};
```

- **data**: 指向实际存储数据的内存区域。
- **size**: 表示对象的大小，便于在分配和释放时进行内存管理。
- **ref_count**: 用于跟踪对象的引用次数，确保在没有引用时可以安全释放对象。
- **object_id**: 为每个对象分配一个唯一的编号，便于调试和跟踪对象的分配情况。

#### 2.`slab_desc` 结构体
```c
struct slab_desc {
    struct list_entry slab_link;  // 链接到 kmem_cache 的链表
    struct object_t *freelist;     // 空闲对象列表
    size_t object_size;            // 对象大小
    size_t num_objects;            // 每个 Slab 中的对象数量
    unsigned int slab_id;          // Slab 的唯一编号
    struct Page *pages[1];         // 保存分配的页信息
};
```

- **slab_link**: 用于将 slab 描述符链接到 kmem_cache 的链表中，便于管理多个 slab。
- **freelist**: 指向当前 slab 中空闲对象的链表，便于快速分配和释放对象。
- **object_size**: 表示每个对象的大小，便于内存分配。
- **num_objects**: 表示每个 slab 中可以容纳的对象数量。
- **slab_id**: 为每个 slab 分配一个唯一的编号，便于调试和跟踪 slab 的使用情况。
- **pages**: 用于保存分配的页信息，便于管理内存页。

#### 3.`kmem_cache` 结构体
```c
struct kmem_cache {
    struct list_entry slabs_full;      // 已满的 Slab 链表
    struct list_entry slabs_partial;   // 部分使用的 Slab 链表
    struct list_entry slabs_empty;     // 空的 Slab 链表
    int object_size;                   // 对象大小
    size_t num_objects_per_slab;       // 每个 Slab 中的对象数量
};
```

- **slabs_full**: 链接到已满的 slab 的链表，便于管理已分配的 slab。
- **slabs_partial**: 链接到部分使用的 slab 的链表，便于管理未完全使用的 slab。
- **slabs_empty**: 链接到空的 slab 的链表，便于快速分配新的 slab。
- **object_size**: 表示每个对象的大小，便于内存分配。
- **num_objects_per_slab**: 表示每个 slab 中可以容纳的对象数量。
### SLUB 分配算法的实现思路

1. **初始化**:
   - 创建11个 `kmem_cache` 结构体，用于管理不同类型的对象。
2. **创建 Slab**:
   - 在需要分配内存时，首先检查是否有空闲的 slab。
   - 如果没有空闲的 slab，则调用 `alloc_slab` 函数，从first_fit申请一个页的内存，并创建一个新的 slab用来管理这个页。
   - 在创建 slab 时，初始化 slab 描述符和空闲对象列表，并为每个对象分配唯一的编号。
3. **分配对象**:
   - 从 slab 的空闲对象列表中分配对象。
   - 如果 slab 中没有空闲对象，则从空闲 slab 中分配对象。
   - 如果没有可用的 slab，则创建新的 slab。
   - 当一个 slab 满的时候把它链接到已满的slab链表。
4. **释放对象**:
   - 在释放对象时，减少其引用计数。
   - 如果引用计数为零，则将对象放回 slab 的空闲对象列表。
   - 如果 slab 变为空，则将其移动到空闲 slab 链表中。
### 实验中遇到的问题
​	在创建新的slab时，我需要创建一个`slab_desc` 结构体用于管理这个slab，显然这是在alloc_slab函数中创建的，如果使用`struct slab_desc slab`来创建新的slab，他会在函数返回时被销毁，因此这种方法显然不行；我尝试用动态内存分配，使用类似c++中的new，使用malloc的方式来分配内存，但是似乎在目前还不能使用malloc函数；最终我使用了slab池的方法，即在slub_pmm.c中，提前声明几个slab和object_t的全局变量，然后在创建新的slab时，把一个slab指针指向提前创建的slab结构体。

​	但是这种方法显然不符合slub的原始思想，这会造成内存的浪费，我需要进一步研究os的代码，尝试自己实现malloc函数，来解决此问题。

​	并且由于代码量和时间的问题，以及无法熟练使用gdb调试工具等问题，目前的slub分配还存在各种bug，仍然无法正常运行。
## 硬件可用物理内存范围获取

### 1. 使用 BIOS 中断

在基于 BIOS 固件的操作系统中，可以利用 BIOS 提供的中断功能来获取内存信息。具体来说，使用 `0x15` 号中断和 `0xe820` 功能号可以请求 BIOS 返回系统的内存布局信息。以下是实现的步骤：

- **设置寄存器**：将 `di` 寄存器设置为内存中存储信息的地址，`ax` 寄存器设置为 `0xe820`，表示请求内存布局信息。
- **调用中断**：通过 `int 0x15` 触发 BIOS 中断，获取内存信息。
- **处理返回值**：根据返回的 `bx` 寄存器的值判断是否还有更多的内存信息需要获取。

### 2. 直接内存访问

另一种方法是通过直接往内存中写入和读取数据来检测可用内存。这种方法的基本思路是：

- **写入数据**：尝试在某个地址写入数据。
- **读取数据**：然后从该地址读取数据。
- **判断有效性**：如果读取的值为 0，说明该地址超出了可用内存范围。

这种方法虽然简单，但可能不够安全，因为它可能会导致系统崩溃或不稳定。

### 3. 使用 OpenSBI 提供的函数

OpenSBI 还提供了一些函数来获取内存区域的信息：

- **`sbi_domain_memregion_count`**：获取内存区域的数量。
- **`sbi_domain_memregion_get`**：获取特定内存区域的信息。

通过这些函数，操作系统可以确定可用的物理内存范围，并进行相应的内存管理。