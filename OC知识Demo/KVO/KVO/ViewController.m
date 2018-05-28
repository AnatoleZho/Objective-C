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

#import <objc/runtime.h>

PersonInfo PersonInfoMake(float height, float weight){
    PersonInfo info;
    info.height = height;
    info.weight = weight;
    return info;
}

NSString* NSStringFromPersonInfo(PersonInfo info){
    return [NSString stringWithFormat:@"PersonInfo: {\n height: %.1f,\n weight: %.1f\n}\n", info.height, info.weight];
}

@interface ViewController ()
{
    Nation *_nation;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
     KVC (Key-Value-Coding) 提供一种通过使用字符串而不是访问方法间接地对对象实例进行赋值和取值的方法
     
        First: 点语法与 KVC
             在实现访问器方法的类中,使用点语法和 KVC 访问对象其实差别不大,二者可以混用.但是在没有访问器方法的类中,点语法无法起作用,这时 KVC 就有优势.
        Second: 一对多关系(To-Many)
              Person 类中的 name 属性是 一对一的关系
              Person 类中的 friendsName 属性 是一个集合 一对多的关系
              当操作一堆所属性中的内容时,有两种选择:
                1> 间接操作
                   先通过 KVC 方法取得集合属性,然后通过集合属性操作集合中的元素
                2> 直接操作
                   Apple 中为我们提供了一些方法模板,可以依规定的格式实现这些方法来达到访问集合属性中元素的目的
     
         1.常用方法
           Key 和 Key Path 赋值和访问
           Key 是要访问属性名对应的字符串
           KeyPath 是被点操作符隔开的用于访问对象的指定属性的字符串序列
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
            (4)修改一些控件的内部属性
               一般情况下可以运用runtime来获取Apple不想开放的属性名
            (5)操作集合
               Apple对KVC的valueForKey:方法作了一些特殊的实现，比如说NSArray和NSSet这样的容器类就实现了这些方法。所以可以用KVC很方便地操作集合
    
               用KVC实现高阶消息传递
               用KVC中的函数操作集合

     */
// 简单属性赋值
    Person *p = [[Person alloc] init];
    [p setValue:@"Rose" forKey:@"name"];
    [p setValue:@"22.2" forKey:@"money"];
    
    // KVC 对数值和结构体类属性的支持
    //  通过将数值或结构体打包或解包成 NSNumber 或 NSValue 对象已达到适配目的
    // 赋值给 age 的是一个 NSNumber 对象, KVC 会自动的将 NSNumber 对象转换成 NSInteger 对象,然后再调用响应的访问器方法设置 age 的值.
    [p setValue:[NSNumber numberWithInteger:20] forKey:@"age"];
    // 以 NSNumber 的形式返回 age 值
    NSNumber *age = [p valueForKey:@"age"];
// NSNumber 是 NSValue 的子类
// 将任意类型非对象类型转换成 NSValue
    int putInt = 90;
    NSValue *intValue = [NSValue valueWithBytes:&putInt objCType:@encode(int)];
    int outInt;
    [intValue getValue:&outInt];
    CLog(@"outInt=== %d", outInt);
    
    
//    NSStringFromCGRect(<#CGRect rect#>)
//    CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
    PersonInfo putInfo = PersonInfoMake(57.5, 178.5);
//    putInfo.weight = 57.0;
//    putInfo.height = 175.5;
    
    NSValue *infoValue = [NSValue valueWithBytes:&putInfo objCType:@encode(PersonInfo)];
    [p setValue:infoValue forKey:@"info"];
    PersonInfo outInfo;
    NSValue *outValue = [p valueForKey:@"info"];
    [outValue getValue:&outInfo];
    
    CLog(@"%@", outValue);
    CLog(@"name: %@, money: %@, age: %ld, info: %@", [p valueForKey:@"name"], [p valueForKey:@"money"], (long)[age integerValue], NSStringFromPersonInfo(outInfo));
    
    
//复杂属性赋值
    p.dog = [[Dog alloc] init];
    [p.dog setValue:@"阿黄" forKey:@"name"];
    CLog(@"dog.name: %@", [p.dog valueForKey:@"name"]);
    [p setValue:@"阿花" forKeyPath:@"dog.name"];
    CLog(@"dog.name: %@", [p valueForKeyPath:@"dog.name"]);

//直接修改私有成员变量
    [p setValue:@"男" forKeyPath:@"_gender"];
    CLog(@"_gender: %@", [p valueForKeyPath:@"_gender"]);

//添加私有成员变量(此时对象的类要重写 setValue: forUndefinedKey:)
    [p setValue:@"22" forKeyPath:@"_age"];
    //但是不能读取
    //CLog(@"_age: %@", [p valueForKeyPath:@"_age"]);

//简单字典转模型
    NSDictionary *perDic = @{@"name" : @"jack",
                             @"money": @"22.2"};
    Person *dicPer = [[Person alloc] init];
    [dicPer setValuesForKeysWithDictionary:perDic];

    CLog(@"name: %@, money: %@, dog.name: %@ , %p", [dicPer valueForKey:@"name"], [dicPer valueForKey:@"money"], [dicPer valueForKeyPath:@"dog.name"], p.dog);

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
    CLog(@"name: %@, money: %@, dog.name: %@ , %p", [dicPer valueForKey:@"name"], [dicPer valueForKey:@"money"], [dicPer valueForKeyPath:@"dog.name"], p.dog);
 
//取值 模型转字典
    NSDictionary *readDic = [dicPer dictionaryWithValuesForKeys:@[@"name", @"money"]];
    CLog(@"readDic==%@", readDic);

// 访问数组中元素的属性值
    Book *book1 = [[Book alloc] init];
    book1.name = @"5分钟突破iOS开发";
    book1.price = 55.5;
    
    Book *book2 = [[Book alloc] init];
    book2.name = @"4分钟突破iOS开发";
    book2.price = 44.4;
    
    Book *book3 = [[Book alloc] init];
    book3.name = @"3分钟突破iOS开发";
    book3.price = 33.3;
    
   //如果 ValueForKeyPath: 方法的调用者是是数组，那么就去访问数组元素的属性值
   //取得 books 数组中所有 Book 对象的 name 属性值，放回到新的数组中返回
    NSMutableArray *books = [NSMutableArray arrayWithArray: @[book1, book2, book3]];
    NSArray *bookNames = [books valueForKeyPath:@"name"];
    CLog(@"booksNames: %@", bookNames);
    dicPer.books = books;
    
    Book *book4 = [[Book alloc] init];
    book3.name = @"2突破iOS开发";
    book4.price = 22.2;
    
    // KVO 本质是系统检测到某个属性的内存地址或常量改变时,会自动添加上 - (void)willChangeValueForKey:(NSString *)key 和 - (void)didChangeValueForKey:(NSString *)key 方法来发送通知.
    // 此时 addObject 方法时, KVO 的回调不会触发. 一种解决方法是可以手动调用 这两个方法,但并不推荐. 另一种便是利用 mutableArrayValueForKey:
    [dicPer.books addObject:book4];
    [[dicPer mutableArrayValueForKey:@"books"] addObject:book4];
    
    NSArray *arr = [dicPer valueForKeyPath:@"books.name"];
    CLog(@"arr: %@", arr);
// 4. 一般情况下可以运用runtime来获取Apple不想开放的属性名
    unsigned int propertyListCount = 0;
    Ivar *ivar = class_copyIvarList([UITextField class], &propertyListCount);
    for (int i = 0; i < propertyListCount; i ++) {
        Ivar iva = ivar[i];
        const char *name = ivar_getName(iva);
        NSString *strName = [NSString stringWithUTF8String:name];
        NSLog(@"%@", strName);
    }
    free(ivar);

// 5. 操作集合
    NSArray *strArr = @[@"english", @"franch", @"chinese"];
    NSArray *capStrArr = [strArr valueForKey:@"capitalizedString"];
    for (NSString *str in capStrArr) {
        NSLog(@"%@", str);
    }
    
    NSArray *capStrLengthArr = [strArr valueForKeyPath:@"capitalizedString.length"];
    for (NSNumber *length in capStrLengthArr) {
        NSLog(@"%ld", length.integerValue);
    }
    /*
     KVC同时还提供了很复杂的函数，主要有下面这些
     ①简单集合运算符
     简单集合运算符共有@avg， @count ， @max ， @min ，@sum 5种， 目前还不支持自定义。
     
     ②对象运算符
     比集合运算符稍微复杂，能以数组的方式返回指定的内容，一共有两种：
     @distinctUnionOfObjects
     @unionOfObjects
     它们的返回值都是NSArray，区别是前者返回的元素都是唯一的，是去重以后的结果；后者返回的元素是全集。

     ③Array和Set操作符
     这种情况更复杂了，说的是集合中包含集合的情况，我们执行了如下的一段代码：
     @distinctUnionOfArrays
     @unionOfArrays
     @distinctUnionOfSets
     @distinctUnionOfArrays：该操作会返回一个数组，这个数组包含不同的对象，不同的对象是在从关键路径到操作器右边的被指定的属性里
     @unionOfArrays 该操作会返回一个数组，这个数组包含的对象是在从关键路径到操作器右边的被指定的属性里和@distinctUnionOfArrays不一样，重复的对象不会被移除
     @distinctUnionOfSets 和@distinctUnionOfArrays类似。因为Set本身就不支持重复。
     */
   
    NSNumber *sum = [dicPer.books valueForKeyPath:@"@sum.price"];
    NSLog(@"sum: %f", sum.floatValue);
    
    NSNumber *avg = [dicPer.books valueForKeyPath:@"@avg.price"];
    NSLog(@"avg: %f", avg.floatValue);

    NSNumber *count = [dicPer.books valueForKeyPath:@"@count"];
    NSLog(@"count: %f", count.floatValue);

    NSNumber *min = [dicPer.books valueForKeyPath:@"@min.price"];
    NSNumber *max = [dicPer.books valueForKeyPath:@"@max.price"];
    NSLog(@"min: %f, max: %f",min.floatValue, max.floatValue);
    
    NSLog(@"@distinctUnionOfObjects");
    NSArray *distinctArr = [dicPer.books valueForKeyPath:@"@distinctUnionOfObjects.price"];
    for (NSNumber *price in distinctArr) {
        NSLog(@"%f", price.floatValue);
    }
    
    NSLog(@"@unionOfObjects");
    NSArray *unionArr = [dicPer.books valueForKeyPath:@"@unionOfObjects.price"];
    for (NSNumber *price in unionArr) {
        NSLog(@"%f", price.floatValue);
    }
    
    /*
     KVO (Key Value Observing)提供一种当其他对象的属性被修改时能够通知当前对象的机制. KVO 很适合 Model 和 Controller类之间的通信
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
    CLog(@"context===%@", context);
    
    NSString *new = change[NSKeyValueChangeNewKey];
    NSString *old = change[NSKeyValueChangeOldKey];
    
    CLog(@"new:%@ -- old:%@",new, old);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
