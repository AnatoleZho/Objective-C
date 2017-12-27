//
//  ViewController.m
//  KVO
//
//  Created by EastElsoft on 2017/9/6.
//  Copyright © 2017年 XiFeng. All rights reserved.
//

#import "ViewController.h"

#import "Person.h"

#import "Nation.h"


@interface ViewController ()
{
    Nation *_nation;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     KVC (Key-Value-Coding) 间接赋值和取值的方法
          1.常用方法
            （1）赋值
               - (void)setValue:(nullable id)value forKey:(NSString *)key;
               - (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;
               - (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;
               - (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues;
             (2)取值（能取得到私有成员变量的值）
               - (id)valueForKey:(NSString *)key;
               - (id)valueForKeyPath:(NSString *)keyPath;
               - (NSDictionary *)dictionaryWithValuesForKeys:(NSArray *)keys;
         2.底层实现原理
          当一个对象调用 setValue: forKey: 方法时，方法内部会做以下操作：
            1.判断有没有指定 key 的 set 方法，如果有 set 方法，就会调用 set 方法，给该属性赋值。
            2.如果没有 set 方法，判断有没有和 key 值相同且带有下划线的成员属性 (_key) ,如果有，直接给该成员属性进行赋值。
            3.如果没有成员属性 _key, 判断有没有和 key 相同名称的属性。如果有，直接给该属性赋值。
            4.如果都没有，就会调用 valueForUndefinedKey 和 setValue: forUndefinedKey: 方法。
         
        3. 使用场景
     
            (1)赋值
                简单属性赋值
                复杂属性赋值
                直接修改私有成员变量
                添加私有成员变量
     
            (2)字典转模型
                简单字典转模型
                复杂字典转模型
     
            (3)取值
                模型转字典
                访问数组中元素的属性
     */
// 简单属性赋值
    Person *p = [[Person alloc] init];
    [p setValue:@"Rose" forKey:@"name"];
    [p setValue:@"22.2" forKey:@"money"];
    NSLog(@"name: %@, money: %@", [p valueForKey:@"name"], [p valueForKey:@"money"]);
    
//复杂属性赋值
    p.dog = [[Dog alloc] init];
    [p.dog setValue:@"阿黄" forKey:@"name"];
    NSLog(@"dog.name: %@", [p.dog valueForKey:@"name"]);
    [p setValue:@"阿花" forKeyPath:@"dog.name"];
    NSLog(@"dog.name: %@", [p valueForKeyPath:@"dog.name"]);

//直接修改私有成员变量
    [p setValue:@"男" forKeyPath:@"_gender"];
    NSLog(@"_gender: %@", [p valueForKeyPath:@"_gender"]);

//添加私有成员变量(此时对象的类要重写 setValue: forUndefinedKey:)
    [p setValue:@"22" forKeyPath:@"_age"];
    //但是不能读取
    //NSLog(@"_age: %@", [p valueForKeyPath:@"_age"]);

//简单字典转模型
    NSDictionary *perDic = @{@"name" : @"jack",
                             @"money": @"22.2"};
    Person *dicPer = [[Person alloc] init];
    [dicPer setValuesForKeysWithDictionary:perDic];
    NSLog(@"name: %@, money: %@, dog.name: %@ , %p", [dicPer valueForKey:@"name"], [dicPer valueForKey:@"money"], [dicPer valueForKeyPath:@"dog.name"], p.dog);

//复杂的字典转模型
    NSDictionary *dict = @{
                           @"name" : @"杰克",
                           @"money": @"23.2",
                           @"dog" : @{
                                   @"name" : @"wangcai",
                                   }
                           };
    //
    [dicPer setValuesForKeysWithDictionary:dict];
    NSLog(@"name: %@, money: %@, dog.name: %@ , %p", [dicPer valueForKey:@"name"], [dicPer valueForKey:@"money"], [dicPer valueForKeyPath:@"dog.name"], p.dog);
 
//取值 模型转字典
    NSDictionary *readDic = [dicPer dictionaryWithValuesForKeys:@[@"name", @"money"]];
    NSLog(@"readDic==%@", readDic);

// 访问数组中元素的属性值
    Book *book1 = [[Book alloc] init];
    book1.name = @"5分钟突破iOS开发";
    
    Book *book2 = [[Book alloc] init];
    book2.name = @"4分钟突破iOS开发";
    
    Book *book3 = [[Book alloc] init];
    book3.name = @"1分钟突破iOS开发";
    
   //如果 ValueForKeyPath: 方法的调用者是是数组，那么就去访问数组元素的属性值
   //取得 books 数组中所有 Book 对象的 name 属性值，放回到新的数组中返回
    NSArray *books = @[book1, book2, book3];
    NSArray *bookNames = [books valueForKeyPath:@"name"];
    NSLog(@"booksNames: %@", bookNames);
    dicPer.books = books;
    NSArray *arr = [dicPer valueForKeyPath:@"books.name"];
    NSLog(@"arr: %@", arr);
    
    /*
     KVO (Key Value Observing)
        1. KVO 底层实现原理
          (1) KVO 是基于 runtime 机制实现的
          (2) 添加监听对象属性
          (3) 对一个对象（假设 person 对象，对应的类 Person）的属性值name发生改变时，系统会自动生成一个继承自 Person的类 NSKVONotifiying_Person，在这个类的 setAge 方法里面调用
              [super setAge: age];
              [self willChangeValueForKey: @"age"];
              [self didChangeValueForKey: @"age"];
              三个方法，而后面两个发内部会主动调用
           (4)实现  - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context 方法，在该方法中可以拿到属性变化前后的值
       2. 作用 使用场景
        能够监听某个对象属性值的改变
     */
    
// 利用 KVO 监听 nation 对象 name 属性的改变
    _nation = [[Nation alloc] init];
    /*
     对 nation 对象添加一个观察者（监听器）
     Observer： 观察者（监听器）
     KeyPath： 属性名（需要坚挺哪个属性）
     */
    [_nation addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:@"123"];

    [_nation setValue:@"中华" forKey:@"name"];
    // or
    // _nation.name = @"中华";
   
    
    [_nation setValue:@"大中华" forKey:@"name"];
    // or
    //_nation.name = @"大中华";
    

}

/**
 利用 KVO 监听到对象属性值改变后，就会调用这个方法

 @param keyPath 哪一个属性被改变
 @param object 哪个对象的属性被改变了
 @param change 改成了什么样
 @param context <#context description#>
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"context===%@", context);
    
    NSString *new = change[NSKeyValueChangeNewKey];
    NSString *old = change[NSKeyValueChangeOldKey];
    
    NSLog(@"new:%@ -- old:%@",new, old);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
