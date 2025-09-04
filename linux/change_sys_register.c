#include <linux/module.h>
#include <linux/printk.h>
#include <linux/kobject.h>
#include <linux/sysfs.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/string.h>

#define CMC_MIN_WAYS_MASK                 (7ul << 61)
#define CMC_MIN_WAYS_DEFAULT_MASK         (2ul << 61)
#define CMC_MIN_WAYS_DISABLE_MASK         (7ul << 61)
#define TXREQ_LIMIT_DYNAMIC_MASK          (1ul <<  2)
#define PF_DIS_MASK                       (1ul << 15)

static struct kobject *example_kobject;

static char *enabled = "enabled";
static char *disabled = "disabled";

static void CMC_enable(void* unused)
{
    u64 cr;
    asm volatile("mrs %0, S3_0_C15_C1_4" : "=r"(cr));
    cr |= CMC_MIN_WAYS_DEFAULT_MASK;
    asm volatile("msr S3_0_C15_C1_4, %0" : :"r"(cr));
    isb();
    // pr_info("CMC enabled\n");
}

static void CMC_disable(void* unused)
{
    u64 cr;
    asm volatile("mrs %0, S3_0_C15_C1_4" : "=r"(cr));
    cr &= ~CMC_MIN_WAYS_MASK;
    asm volatile("msr S3_0_C15_C1_4, %0" : :"r"(cr));
    isb();
    // pr_info("CMC disabled\n");
}

#define PF_MODE_SHIFT                     11
#define PF_MODE_MASK                      (0xful << PF_MODE_SHIFT)
#define PF_MODE_1001                      9ul
static void HW_Prefetching_set_PF_MODE(void* info)
{
    u64 cr;
    u64 mode = (u64)info;
    mode <<= PF_MODE_SHIFT;

    asm volatile("mrs %0, S3_0_C15_C1_5" : "=r"(cr));
    isb();
    cr &= ~PF_MODE_MASK;
    cr |= mode;
    asm volatile("msr S3_0_C15_C1_5, %0" : :"r"(cr));
    isb();
}

static void HW_Prefetching_enable(void* unused)
{
    u64 cr;
    asm volatile("mrs %0, S3_0_C15_C1_4" : "=r"(cr));
    isb();
    cr &= ~PF_DIS_MASK;
    asm volatile("msr S3_0_C15_C1_4, %0" : :"r"(cr));
    isb();
    HW_Prefetching_set_PF_MODE((void*)PF_MODE_1001);
    // pr_info("HW_Prefetching enabled\n");
}

static void HW_Prefetching_disable(void* unused)
{
    u64 cr;
    asm volatile("mrs %0, S3_0_C15_C1_4" : "=r"(cr));
    isb();
    cr |= PF_DIS_MASK;
    asm volatile("msr S3_0_C15_C1_4, %0" : :"r"(cr));
    isb();
    // pr_info("HW_Prefetching disabled\n");
}

static void CBUSY_DYNAMIC_enable(void* unused)
{
    u64 cr;
    asm volatile("mrs %0, S3_0_C15_C1_5" : "=r"(cr));
    cr |= TXREQ_LIMIT_DYNAMIC_MASK;
    asm volatile("msr S3_0_C15_C1_5, %0" : :"r"(cr));
    isb();
    // pr_info("CBUSY_DYNAMIC enabled\n");
}

static void CBUSY_DYNAMIC_disable(void* unused)
{
    u64 cr;
    asm volatile("mrs %0, S3_0_C15_C1_5" : "=r"(cr));
    cr &= ~TXREQ_LIMIT_DYNAMIC_MASK;
    asm volatile("msr S3_0_C15_C1_5, %0" : :"r"(cr));
    isb();
    // pr_info("CBUSY_DYNAMIC disabled\n");
}

static void print_IMP_CPUECTLRx_EL1(void* unused)
{
    u64 cr1, cr2;
    isb();
    asm volatile("mrs %0, S3_0_C15_C1_4" : "=r"(cr1));
    asm volatile("mrs %0, S3_0_C15_C1_5" : "=r"(cr2));
    isb();
    pr_info("IMP_CPUECTLR_EL1  : %#llx\n"
            "IMP_CPUECTLR2_EL1 : %#llx\n"
            "HW_Prefetching    : %s\n"
            "PF_MODE           : %#llx\n"
            "CMC               : %s\n"
            "CBUSY_DYNAMIC     : %s\n",
            cr1, cr2,
            (cr1 & PF_DIS_MASK)              ? disabled : enabled,
            ((cr2 & PF_MODE_MASK) >> PF_MODE_SHIFT),
            (cr1 & CMC_MIN_WAYS_MASK)        ? enabled : disabled,
            (cr2 & TXREQ_LIMIT_DYNAMIC_MASK) ? enabled : disabled);

}

static ssize_t foo_show(struct kobject *kobj, struct kobj_attribute *attr,
                        char *buf)
{

    u64 cr1, cr2;
    isb();
    asm volatile("mrs %0, S3_0_C15_C1_4" : "=r"(cr1));
    asm volatile("mrs %0, S3_0_C15_C1_5" : "=r"(cr2));
    isb();

    return sprintf(buf,
                   "IMP_CPUECTLR_EL1  : %#llx\n"
                   "IMP_CPUECTLR2_EL1 : %#llx\n"
                   "HW_Prefetching    : %s\n"
                   "PF_MODE           : %#llx\n"
                   "CMC               : %s\n"
                   "CBUSY_DYNAMIC     : %s\n",
                   cr1, cr2,
                   (cr1 & PF_DIS_MASK)              ? disabled : enabled,
                   ((cr2 & PF_MODE_MASK) >> PF_MODE_SHIFT),
                   (cr1 & CMC_MIN_WAYS_MASK)        ? enabled : disabled,
                   (cr2 & TXREQ_LIMIT_DYNAMIC_MASK) ? enabled : disabled);
}

#define SUPPORT_ARG_NUM 4
static ssize_t foo_store(struct kobject *kobj, struct kobj_attribute *attr,
                         const char *buf, size_t count)
{
    char field[SUPPORT_ARG_NUM][20];
    u64  turn_on[SUPPORT_ARG_NUM] = {0};
    int  input_count = sscanf(buf, "%s %llu %s %llu %s %llu %s %llu",
                              field[0], &turn_on[0],
                              field[1], &turn_on[1],
                              field[2], &turn_on[2],
                              field[3], &turn_on[3]);

    if (input_count != 2 && input_count != 4 && input_count != 6 && input_count != 8) {
        print_IMP_CPUECTLRx_EL1(NULL);
        return count;
    }

    for (int i = 0; i < input_count / 2; i++) {
        char* config = field[i];
        u64 on       = turn_on[i];
        if (strcmp(config, "pf") == 0) {
            if (on) on_each_cpu(HW_Prefetching_enable, NULL, 1);
            else    on_each_cpu(HW_Prefetching_disable, NULL, 1);
        } else if (strcmp(config, "pf_mode") == 0) {
            on_each_cpu(HW_Prefetching_set_PF_MODE, (void*)on, 1);
        } else if (strcmp(config, "cmc") == 0) {
            if (on) on_each_cpu(CMC_enable, NULL, 1);
            else    on_each_cpu(CMC_disable, NULL, 1);
        } else if (strcmp(config, "cbusy") == 0) {
            if (on) on_each_cpu(CBUSY_DYNAMIC_enable, NULL, 1);
            else    on_each_cpu(CBUSY_DYNAMIC_disable, NULL, 1);
        } else {
            // TODO: validate config name before actually writting register.
            pr_info("`%s' not recognized, valid value: pf, cmc, cbusy\n", config);
            break;
        }
    }

    print_IMP_CPUECTLRx_EL1(NULL);
    return count;
}


static struct kobj_attribute foo_attribute = __ATTR(foo, 0664, foo_show, foo_store);

static int __init mymodule_init (void)
{
    int error = 0;

    example_kobject = kobject_create_and_add("kobject_example", kernel_kobj);
    if(!example_kobject)
        return -ENOMEM;

    error = sysfs_create_file(example_kobject, &foo_attribute.attr);
    if (error) {
        pr_info("failed to create the foo file in /sys/kernel/kobject_example\n");
        kobject_put(example_kobject);
        return error;
    }

    pr_info("Module initialized successfully\n");

    return error;
}

static void __exit mymodule_exit (void)
{
    pr_info("Module uninitialized successfully\n");
    kobject_put(example_kobject);
}


module_init(mymodule_init);
module_exit(mymodule_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Qi Feng");
