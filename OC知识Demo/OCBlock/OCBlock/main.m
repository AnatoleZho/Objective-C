//
//  main.m
//  OCBlock
//
//  Created by EastElsoft on 2017/10/19.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyObject.h"
#import "OtherObject.h"

static NSInteger num3 = 300;
NSInteger num4 = 3000;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
   
        
        // 1.Block 截获自动变量值, 值截获，在block里如果修改变量val的值也是无效的；
        int dmy = 256;
        int val = 10;
        const char *fmt = "val = %d\n";
        void (^blk)(void) = ^{
            printf(fmt, val);
        };
        
        val = 2;
        fmt = "These values were changed. val = %d\n";
        
        blk();
        

        NSMutableArray *arrM = [NSMutableArray arrayWithObjects:@"1", @"2", nil];
        void(^block)(void) = ^{
            NSLog(@"%@", arrM);
            [arrM addObject:@"4"];
        };
        
        [arrM addObject:@"3"];
        
        arrM = nil;
        NSLog(@"%@", arrM);

        block();
        // 局部对象变量也是一样，截获的是值，而不是指针，在外部对其置为nil，对block没有影响，而对该对象调用方法会有影响
        
        // 局部静态变量截获，是指针截获。
        static NSInteger num = 3;
        NSInteger(^blockA)(NSInteger) = ^NSInteger(NSInteger n){
            return n * num;
        };
        
        num = 1;
        NSLog(@"%zd", blockA(2));
        // 输出为 2， 意味着 num = 1 这里修改 num 的值是有效的，即是指针截获，同样，在block里去修改变量num，也是有效的
        
        // 全局变量，静态全局变量截获：不截获，直接取值
        __block NSInteger num5 = 30000;
        void(^blockB)(void) = ^{
            NSLog(@"%d", val); //局部变量
            NSLog(@"%zd", num); // 局部静态变量
            NSLog(@"%zd", num4); // 全局变量
            NSLog(@"%zd", num3); // 全局静态变量
            NSLog(@"%zd", num5); // __block修饰变量
        };
        blockB();
        
        // 2.使用 __block 说明符的自动变量可在 Block 中赋值
        // __block 说明符更准确的表述方式是：__block 存储域类说明符（__block storage-class-specifier）
        __block int a = 0;
        void (^blkA)(void) = ^{
            a = 1;
        };
        
        blkA();
        printf("a = %d\n", a);
        
        
        __block int valB = 0;
        // 此时调用 copy 和 不调用是没有区别的
        void (^blkB)(void) = [^{++valB;} copy];
        
        ++valB;
        NSLog(@"valB==%d",valB);

        blkB();
        NSLog(@"valB==%d",valB);
        /*
         使用 __block 变量的 Block 持有 __block 变量，如果 Block 被废弃，它所持有的 __block 变量也就被释放。
         通过上面的例子，无论是在 Block 语法中、Block 语法外使用 __block 变量，还是 __block 变量配置在堆上或栈上，都可以顺序的访问同一个 __block 变量。
         */
        
        
        // 3. 捕获对象
        /* 以下源代码生成并持有 NSMutableArray 类的对象，由于附有 __strong 修饰符的赋值目标变量的作用域立即结束，因此对象被立即释放并废弃*/
        {
            id array = [[NSMutableArray alloc] init];
        }
        
        // 接下来在 Block 语法中使用该变量 array
        typedef void (^blk_t) (id);
        blk_t blkC;
        {
            id arrayM = [[NSMutableArray alloc] init];
            blkC = [^(id obj){
                [arrayM addObject:obj];
                NSLog(@"arrayM count = %ld", [arrayM count]);
            } copy];
            
            /*
             blkC = ^(id obj){
                [arrayM addObject:obj];
                NSLog(@"arrayM count = %ld", [arrayM count]);
             };
             若是去掉 copy 程序将会报错。
             因为 只有调用 __block_copy 函数才能持有截获的 附有 __strong 修饰符的对象类型的自动变量值，所以像上面源码中这样不调用 __Block_copy 函数的情况下，即使截获了对象，它也会随着变量作用域的结束而被废弃。
             */
        }
        
        blkC([[NSObject alloc] init]);
        blkC([[NSObject alloc] init]);
        blkC([[NSObject alloc] init]);
        /*
         变量作用域结束的同时，变量 arrayM 被废弃，其强引用失效，因此赋值给变量 arrayM 的 NAMutableArray 类的对象必定被释放并废弃。但是该代码运行正常。
             arrayM count = 1
             arrayM count = 2
             arrayM count = 3
   
         这一结果意味着赋值给变量 arrayM 的 NSMutableArray 类的对象在该代码的最后 Block 的执行部分超出其变量作用域而存在。
         由于该源代码的 Block 用结构体中，含有附有 __strong 修饰符的对象类型变量 array，所以恰当管理赋值给变量 array 对象。
         */
        
        /*
         Block 的存储域：
         Block 转换为 Block 的结构体类型的自动变量，__block 变量转换为 __block 变量的结构体类型的自动变量。所谓结构体类型的自动变量，即栈上生成的该结构体的实例。另外 Block 也是 OC 对象，该 Block 的类为 _NSConcreteStackBlock,虽然该类没有出现在已转换代码中，但有很多与之类似的类，如：_NSConcreteStackBlock, _NSConcreteGlobalBlock, _NSConcreteMallocBlock.  分别对应的存储区域： 栈， 程序的数据区域(.data区), 堆。
         
         实际上大多数 Block 都设置在 栈 上，当在记述全局变量的地方使用 Block 语法时，生成的 Block 为 _NSConcreteGlobalBlock 类对象。例如：
         void (^blk)(void) = ^{ printf("Global Block \n");};
         
         int main(){
         
         }
         
         
         Block 从栈上复制到堆上的情况：
           1.调用 Block 的 copy 实例方法
           2.Block 作为函数返回值返回
           3.将 Block 赋值给 附有 __strong 修饰符 id 类型的类或 Block 类型的成员变量
           4.在方法中含有 usingBlock 的 Cocoa 框架方法或 Grand Central Dispatch 的 API 中传递 Block
         
            在调用 Block 的 copy实例方法是，如果 Block 配置在栈上，那么该 Block 会从栈复制到堆。Block 作为函数返回值返回时，将 Block 赋值给附有 __strong 修饰符 id 类型的类 或 Block 类型成员变量时，编译器会自动的将对象的 Block 作为参数并调用 __Block_copy 函数，这与调用 block 的 copy 实例方法效果相同。在方法中 含有 usingBlock 的 Cocoa 框架方法或 GCD 的 API 中传递 Block 时，在该方法或函数内部对传递过来的 Block 调用 Block 的 copy 实例方法或者 __block_copy 函数。
            也就是说，上面的情况下栈上的 Block 被复制到堆上，其实质可归结为 __Block_copy 函数被调用时，block 从栈上复制到堆，相对的，在释放复制到堆上的 Block 后，谁都不持有 Block 而使其被弃用时调用 dispose 函数。这相当于对象的 delloc 实例方法。
         */
        
        /*
         Block 中使用对象类型自动变量时，出了以下情形外，建议调用 Block 的 copy 实例方法。
           1. Block 作为函数返回值返回时
           2. 将 Block 赋值给类的附有 __strong 修饰符的 id 类型或 Block 类型成员变量时
           3. 向方法名中含有 usingBlock 的 Cocoa 框架方法或 Grand Central Dispatch 的 API 中传递 Block 时
         
         */
        
        /*
         __ block 变量和对象
         
            __block 说明符可指定任何类型的自变量
         */
        
        __block id obj = [[NSObject alloc] init];
        // 其实该代码等价于 __block id __strong obj = [[NSObject alloc] init];
        /*
          在 __block 变量为附有 __strong 修饰符的 id 类型或对象类型自动变量的情形下：当 __block 变量从栈上复制到堆时，使用 __Block_object_assign 函数，持有赋值给 __block 变量的对象。当对上的 __block 变量被废弃时，使用 _Block_object_dispose 函数，释放赋值给 __block 变量的对象。
         由此可知，即使对象赋值复制到堆上的附有 __strong 修饰符的对象类型 __block 变量中，只要 __block 变量在对上继续存在，那么该对象就会继续处于别持有的状态。这与 Block 中使用赋值给附有 __strong 修饰符的对象类型自动变量的对象相同。
         */
        
        blk_t blkD;
        {
            id array = [[NSMutableArray alloc] init];
            id __weak arr2 = array;
            //  __block id __weak arr2 = array;
            // 倘若将 __weak 去掉 obj 可以正常添加到 arr2 中
            blkD = [^(id obj){
                [arr2 addObject:obj];
                NSLog(@"array2 count = %ld",[arr2 count]);
            } copy];
        }
        blkD([[NSObject alloc] init]);
        blkD([[NSObject alloc] init]);
        blkD([[NSObject alloc] init]);
        /*
         执行结果： array2 count = 0
                  array2 count = 0
                  array2 count = 0
         这是由于附有 __strong 修饰符的变量 array 在改变量作用域结束的同时被释放、废弃，nil 被赋值在附有 __weak 修饰符的变量 arr2 中，该代码可正常执行
         即使附加了 __block 说明符，附有 __strong 修饰符的变量 array 也会在 该变量作用域结束的同时被释放废弃，nil 被赋值给 __weak 修饰符的变量 arr2 中。
         */
        
        //循环引用
            //使用 __weak 避免循环引用
        id o = [[MyObject alloc] init];
        NSLog(@"%@",o);
        /*
         在为避免循环引用而使用 __weak 修饰符时，虽说可以确认使用附有 _weak 修饰符的变量时是否为 nil，但更有必要使之生存以使用赋值给附有 __weak 修饰的变量的对象。
         */
        
            // 使用 __block 变量来避免循环引用
        
        id otherO = [[OtherObject alloc] init];

        [otherO execBlock];
//        otherO = nil;

        /*
         该源代码没有引起循环引用。但是如果不调用 execBlock 实例方法，即不执行赋值给成员变量 blk_ 的 Block, 便会循环引用并引起内存泄漏。在生成并持有 OtherObject 类对象的状态下会引起以下循环引用：
              1. OtherObject 类对象持有 Block
              2. Block 持有 __block 变量
              3. __block 变量持有 MyObject 类对象。
         
         如果不执行 execBlock 实例方法，就会持续循环引用从而造成内存泄漏。
         通过执行 execBlock 实例方法， Block 被执行，nil 被赋值在 __block 变量 tmp 中。
         
         blk_ = ^{
             NSLog(@"self = %@", tmp);
             tmp = nil;
         };
         因此，__block 变量 tmp 对 OtherObject 类对象的强引用失效。避免循环引用的过程如下：
           1. OtherObject 类对象持有 Block
           2. Block 持有 __block 变量
         */
        
        
        /*
         使用 __block 变量避免循环引用的方法 和 使用 __weak 修饰符及 __unsage_unretained 修饰符避免循环引用的方法的比较：
          1. 通过 __block 变量可控制对象的持有期间
          2. 在不能使用 __weak 修饰符的环境中使用 __unsafe_unretained 修饰符即可（不必担心悬垂指针）
            在执行 Block 时可以动态的决定是否将 nil 或其他对象赋值在 __block 变量中
         
         使用 __block 变量的缺点如下：
           1.为避免循环引用必须执行 Block
         */
    
    }
    
    
    return 0;
}
