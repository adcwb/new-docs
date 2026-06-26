---
title: "unittest 单元测试"
weight: 3
date: 2026-06-23
tags: ["Python", "测试", "unittest"]
---

## unittest

unittest是Python内置的单元测试框架（模块），不仅可以完成单元测试，也适用于自动化测试中。

unittest提供了丰富的断言方法，判断测试用例是否通过，然后生成测试结果报告。



### 环境准备

首先，我们准备这样一个目录：

```bash
M:\tests\  # 我的是M盘的tests目录，所有操作都在tests目录内完成
    ├─discover   
    │  ├─son
    │  │  ├─test_dict.py 
    │  │  └─__init__.py
    │  ├─test_list.py
    │  ├─test_str.py
    │  └─__init__.py
    ├─loadTestsFromTestCaseDemo
    │  └─loadTestsFromTestCaseDemo.py
    ├─case_set.py
    ├─main.py   # 代码演示文件，所有演示脚本文件
    ├─test_tuple.py
    └─__init__.py
```

如果你跟我的流程走， 请务必建立和理解这样的一个目录，目前这些文件都是空的，后续会一一建立，各目录内的`__init__.py`也必须建立，虽然它是空的，但是它无比重要，因为它标明它所在目录是Python的包。

`case_set.py`有4个函数，分别计算加减乘除，并且代码不变：

```python
# case_set.py
"""
    测试用例集, 以下4个函数将成为我们的测试用例。
"""

def add(x, y):
    """ 两数相加 """
    return x + y


def sub(x, y):
    """ 两数相减 """
    return x - y


def mul(x, y):
    """ 两数相乘 """
    return x * y


def div(x, y):
    """ 两数相除 """
    return x / y


if __name__ == '__main__':
    print(div(10, 5))
    print(div(10, 0))

```

### 基本使用

#### 单个用例的执行

以下案例在`main.py`中，调用我们上面的测试用例

```python
# main.py

import unittest  # 导入unittest框架
import case_set  # 导入用例集


class myUnitTest(unittest.TestCase):
    
    def setUp(self):
        """
            用例初始化, 固定函数，处理一些基本的初始化操作
        :return:
        """
        print("用例初始化 setup")

    def runTest(self):
        """
            执行测试用例
        :return:
        """
        print(case_set.add(2, 3) == 5)

    def tearDown(self):
        """
            用例执行完，收尾
        :return:
        """
        print("用例执行完毕，收尾")


if __name__ == '__main__':
    demo = myUnitTest()
    demo.run()  # 固定的调用方法run

# 执行结果
Ran 1 test in 0.002s

OK

Process finished with exit code 0
用例初始化 setup
True
用例执行完毕，收尾

```

说明

```text
myUnitTest类名可以自定义，但是必须继承unittest.TestCase

示例中的setUp和tearDown方法名是固定的

但如果，我们测试用例时，没有初始化和收尾的工作，setUp和tearDown方法可以省略不写

至于runTest方法名叫什么，取决于在实例化myUnitTest类时，是否传参
    根据阅读源码可知，methodName='runTest'
    因此，若想自定义runTest方法名，在初始化自定义类时，指定名字即可
        demo = myUnitTest(methodName='add_test') add_test即为自定义的runTest名
```



`unittest.TestCase` 源码

```python
class TestCase(object):

    def __init__(self, methodName='runTest'):
        self._testMethodName = methodName
        self._outcome = None
        self._testMethodDoc = 'No test'  # 也请留意这个鬼东西 No test
    
    def run(self, result=None):
        # run方法反射了methodName
        testMethod = getattr(self, self._testMethodName)

```

从上面的源码中可以看到，在实例化的时候，其实有个`methodName`默认参数，正好也叫runTest。而在实例化后，实例化对象调用run方法的时候，反射了那个`methodName`值，然后用例正常执行了。

所以，runTest方法名可以自定义：

```python
# main.py

import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def add_test(self):
        """ 执行用例 """
        print(case_set.add(2, 3) == 5)

if __name__ == '__main__':
    demo = myUnitTest(methodName='add_test')
    demo.run()

```



#### 多个用例的执行

执行多个用例的时候，既可以自定义多个测试类，也可以在同一个类中定义多个测试方法

```python
# main.py

import unittest
import case_set

class myUnitTestAdd(unittest.TestCase):

    def runTest(self):
        """ 执行用例 """
        print(case_set.add(2, 3) == 5)

class myUnitTestSub(unittest.TestCase):

    def runTest(self):
        """ 执行用例 """
        print(case_set.sub(2, 3) == 5)  # 用例结果不符合预期

if __name__ == '__main__':
    demo1 = myUnitTestAdd()
    demo2 = myUnitTestSub()
    demo1.run()
    demo2.run()

# 上面的代码可以简化成以下格式
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def add_test(self):
        """ 执行用例 """
        print(case_set.add(2, 3) == 5)

    def sub_test(self):
        """ 执行用例"""
        print(case_set.sub(10, 5) == 2)

if __name__ == '__main__':
    demo1 = myUnitTest('add_test')
    demo2 = myUnitTest('sub_test')
    demo1.run()
    demo2.run()

```

如上方式，每个用例都要实例化一次，虽然可以执行多个用例，但是这么写实在是太low了，反倒没有之前测试除法用例来的简单。

此外，用print打印也不符合真实的测试环境。



### 断言

`unittet.TestCase`提供了一些断言方法用来检查并报告故障。

此处列出了一些最常用的方法：

| Method                         | Checks that          | description                    | New in |
| ------------------------------ | -------------------- | ------------------------------ | ------ |
| assertEqual(a, b, msg)         | a == b               | 如果a不等于b，断言失败         |        |
| assertNotEqual(a, b, msg)      | a != b               | 如果a等于b，断言失败           |        |
| assertTrue(x, msg)             | bool(x) is True      | 如果表达式x不为True，断言失败  |        |
| assertFalse(x, msg)            | bool(x) is False     | 如果表达式x不为False，断言失败 |        |
| assertIs(a, b, msg)            | a is b               | 如果a is not 2，断言失败       | 3.1    |
| assertIsNot(a, b, msg)         | a is not b           | 如果a is b，断言失败           | 3.1    |
| assertIsNone(x, msg)           | x is not None        | 如果x不是None，断言失败        | 3.1    |
| assertIn(a, b, msg)            | a in b               | 如果a not in b，断言失败       | 3.1    |
| assertNotIn(a, b, msg)         | a not in b           | 如果a in b，断言失败           | 3.1    |
| assertIsInstance(a, b, msg)    | isinstance(a, b)     | 如果a不是b类型，断言失败       | 3.2    |
| assertNotIsInstance(a, b, msg) | not isinstance(a, b) | 如果a是b类型，断言失败         | 3.2    |



代码示例：

```python
# test.py

import unittest


class TestStringMethods(unittest.TestCase):

    def test_assertEqual(self):
        """
        assertEqual 如果a不等于b，断言失败
        :return:
        """
        self.assertEqual(1, 2, msg='1 != 2')  # AssertionError: 1 != 2 : 1 != 2

    def test_assertTrue(self):
        """
        assertTrue 如果表达式不为True，断言失败
        :return:
        """
        self.assertTrue('')

    def test_assertFalse(self):
        """
        test_assertFalse 如果表达式不为False，断言失败
        :return: 
        """
        self.assertFalse('')


if __name__ == '__main__':
    unittest.main()

```

所有的assert方法都接收一个msg参数，如果指定，该参数将用作失败时的错误提示。

结果示例：

```bash
$ python test.py 
F.F
======================================================================
FAIL: test_assertEqual (__main__.TestStringMethods)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "test.py", line 7, in test_assertEqual
    self.assertEqual(1, 2, msg='1 != 2')  # AssertionError: 1 != 2 : 1 != 2
AssertionError: 1 != 2 : 1 != 2

======================================================================
FAIL: test_assertTrue (__main__.TestStringMethods)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "test.py", line 10, in test_assertTrue
    self.assertTrue('')
AssertionError: '' is not true

----------------------------------------------------------------------
Ran 3 tests in 0.000s

FAILED (failures=2)

# 结果中，F.F表示，如果用例通过返回.，失败返回F，所以结果告诉我们执行了3个用例，成功1个，失败两个FAILED (failures=2)，AssertionError是错误信息。
```



测试成功案例：

```python
import unittest


class TestStringMethods(unittest.TestCase):

    def test_assertEqual(self):
        """
        assertEqual 如果a不等于b，断言失败
        :return:
        """
        self.assertEqual(1, 1, msg='两个值不相等')  # AssertionError: 1 != 2 : 1 != 2

    def test_assertTrue(self):
        """
        assertTrue 如果表达式不为True，断言失败
        :return:
        """
        self.assertTrue(True)

    def test_assertFalse(self):
        """
        test_assertFalse 如果表达式不为False，断言失败
        :return:
        """
        self.assertFalse(False)


if __name__ == '__main__':
    unittest.main()

# 输出结果
$ python test.py 
...
----------------------------------------------------------------------
Ran 3 tests in 0.000s

OK

```



### 测试套件

测试套件（TestSuite）是由许多测试用例组成的复合测试，也可以理解为承载多个用例集合的容器。
使用时需要创建一个TestSuite实例对象，然后使用该对象添加用例：

- suite_obj.addTest(self, test)，添加一个测试用例。
- suite_obj.addTests(self, tests)，添加多个测试用例。
- 在实例化方法中添加测试用例。

当添加完所有用例后，该测试套件将被交给测试执行（运行）器，如TextTestRunner，该执行器会按照用例的添加顺序执行各用例，并聚合结果。

TestSuite有效的解决了：

- 因为是顺序执行，当多个用例组成一个链式测试操作时，谁先谁后的问题就不存在了。
- 有效地将多个用例组织到一起进行集中测试，解决了之前一个一个测试的问题。

使用示例

```python
# main.py
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def add_test(self):
        """ 执行用例 """
        self.assertEqual(case_set.add(2, 3), 5)

    def sub_test(self):
        """ 执行用例"""
        self.assertEqual(case_set.sub(10, 5), 5)

def create_suite():
    """ 创建用例集 """
    # 拿到两个用例对象
    add = myUnitTest('add_test')
    sub = myUnitTest('sub_test')
    # 实例化suite对象
    suite_obj = unittest.TestSuite()
    # 添加单个用例
    suite_obj.addTest(add)
    suite_obj.addTest(sub)
    return suite_obj
    
if __name__ == '__main__':
    suite = create_suite()
    # 可以查看suite中的用例数量
    print(suite.countTestCases())  # 2
    # 拿到执行器对象
    runner = unittest.TextTestRunner()
    # 你想用执行器执行谁？就把它传进去
    runner.run(suite)


```



一个一个往suite中添加用例比较麻烦，所以以上代码可以简化为以下写法

```python
import unittest
import case_set


class myUnitTest(unittest.TestCase):

    def add_test(self):
        """ 执行用例 """
        self.assertEqual(case_set.add(2, 3), 5)

    def sub_test(self):
        """ 执行用例"""
        self.assertEqual(case_set.sub(10, 5), 5)


def create_suite():
    """ 创建用例集 """
    '''
        # 拿到两个用例对象
        add = myUnitTest('add_test')
        sub = myUnitTest('sub_test')
        # 实例化suite对象
        suite_obj = unittest.TestSuite()
        # 添加用例
        suite_obj.addTests([add, sub])
    '''
    
    # 上面的代码也可以这么写
    map_obj = map(myUnitTest, ['add_test', 'sub_test'])
    suite_obj = unittest.TestSuite()
    suite_obj.addTests(map_obj)
    return suite_obj


if __name__ == '__main__':
    suite = create_suite()
    # 拿到执行器对象
    runner = unittest.TextTestRunner()
    # 你想用执行器执行谁？就把它传进去
    runner.run(suite)

```

在实例化的时候添加测试用例

```python
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def add_test(self):
        """ 执行用例 """
        self.assertEqual(case_set.add(2, 3), 5)

    def sub_test(self):
        """ 执行用例"""
        self.assertEqual(case_set.sub(10, 5), 5)

def create_suite():
    """ 创建用例集 """
    map_obj = map(myUnitTest, ['add_test', 'sub_test'])
    suite_obj = unittest.TestSuite(tests=map_obj)
    return suite_obj

"""
在实例化的时候添加测试用例的具体实现方法
class myUnitTestSuite(unittest.TestSuite):
    def __init__(self):
        # 当实例化suite对象时，传递用例
        map_obj = map(myUnitTest, ['add_test', 'sub_test'])
        # 调用父类的 __init__ 方法
        super().__init__(tests=map_obj)

if __name__ == '__main__':
    suite_obj = myUnitTestSuite()
    runner = unittest.TextTestRunner()
    runner.run(suite_obj)
"""

if __name__ == '__main__':
    suite = create_suite()
    runner = unittest.TextTestRunner()
    runner.run(suite)

```

虽然在一定程度上，我们优化了代码，但是还不够，因为，我们还需要手动的将用例添加到suite的中。接下来，我们来学习，如何自动添加。



### 自动添加任务

想要自动添加，需要使用`unittest.makeSuite`类来完成

在实例化`unittest.makeSuite(testCaseClass, prefix='test')`时，需要告诉makeSuite添加用例的类名，上例是myUnitTest，然后makeSuite将myUnitTest类中所有以prefix参数指定开头的用例，自动添加到suite中。

```python
# main.py

import unittest
import case_set


class myUnitTest(unittest.TestCase):

    def add_test(self):
        self.assertEqual(case_set.add(2, 3), 5)

    def sub_test(self):
        self.assertEqual(case_set.sub(10, 5), 2)

    def test_mul(self):
        self.assertEqual(case_set.mul(10, 5), 50)

    def test_div(self):
        self.assertEqual(case_set.div(10, 5), 2)


def create_suite():
    """ 创建用例集 """
    # prefix参数默认读取以test开头的用例
    suite_obj = unittest.makeSuite(testCaseClass=myUnitTest, prefix='test')
    return suite_obj


if __name__ == '__main__':
    suite_obj = create_suite()
    print(suite_obj.countTestCases())  # 2
    runner = unittest.TextTestRunner()
    runner.run(suite_obj)

```

prefix参数默认读取以test开头的用例，也可以自己指定：

```python
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def my_add_test(self):
        self.assertEqual(case_set.add(2, 3), 5)

    def my_sub_test(self):
        self.assertEqual(case_set.sub(10, 5), 2)  # AssertionError: 5 != 2

    def test_mul(self):
        self.assertEqual(case_set.mul(10, 5), 50)

    def test_div(self):
        self.assertEqual(case_set.div(10, 5), 2)

def create_suite():
    """ 创建用例集 """
    suite_obj = unittest.makeSuite(myUnitTest, prefix='my')
    return suite_obj

if __name__ == '__main__':
    suite_obj = create_suite()
    print(suite_obj.countTestCases())  # 2
    runner = unittest.TextTestRunner()
    runner.run(suite_obj)

```

如上例示例，读取myUnitTest类中所有以`my`开头的用例方法。但建议还是按照人家默认的test就好了。

我们不仅仅可以让他自动添加任务，还可以在自动添加任务的时候，手动再指定任务，如下所示

```python
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def my_add_test(self):
        self.assertEqual(case_set.add(2, 3), 5)

    def my_sub_test(self):
        self.assertEqual(case_set.sub(10, 5), 2)  # AssertionError: 5 != 2

    def test_mul(self):
        self.assertEqual(case_set.mul(10, 5), 50)

    def test_div(self):
        self.assertEqual(case_set.div(10, 5), 2)

def create_suite():
    """ 创建用例集 """
    # 自动添加任务
    suite_obj = unittest.makeSuite(myUnitTest, prefix='my')、
    
    # 手动追加任务
    suite_obj.addTests(map(myUnitTest, ['test_mul', 'test_div']))
    return suite_obj

if __name__ == '__main__':
    suite_obj = create_suite()
    print(suite_obj.countTestCases())  # 4
    runner = unittest.TextTestRunner()
    runner.run(suite_obj)

```



### TestLoader

到目前为止，我们所有的用例方法都封装在一个用例类中，但是有的时候，我们会根据不同的功能编写不同的测试用例文件，甚至是存放在不同的目录内。

这个时候在用addTest添加就非常的麻烦了。
unittest提供了TestLoader类来解决这个问题。先看提供了哪些方法：

- TestLoader.loadTestsFromTestCase，返回testCaseClass中包含的所有测试用例的suite。
- TestLoader.loadTestsFromModule，返回包含在给定模块中的所有测试用例的suite。
- TestLoader.loadTestsFromName，返回指定字符串的所有测试用例的suite。
- TestLoader.loadTestsFromNames，返回指定序列中的所有测试用例suite。
- TestLoader.discover，从指定的目录开始递归查找所有测试模块。

#### loadTestsFromTestCase

```python
# loadTestsFromTestCaseDemo.loadTestsFromTestCaseDemo.py
import unittest


class LoadTestsFromTestCaseDemo(unittest.TestCase):

    def test_is_upper(self):
        """判断字符串是否是纯大写"""
        self.assertTrue('FOO'.isupper())

    def test_is_lower(self):
        """判断字符串是否是纯小写"""
        self.assertTrue('foo'.islower())

# main.py
import unittest
from loadTestsFromTestCaseDemo.loadTestsFromTestCaseDemo import LoadTestsFromTestCaseDemo


class MyTestCase(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('FOO', 'foo'.upper())


if __name__ == '__main__':
    # 使用loadTestsFromTestCase获取当前脚本和loadTestsFromTestCaseDemo脚本中的用例类
    test_case1 = unittest.TestLoader().loadTestsFromTestCase(MyTestCase)
    test_case2 = unittest.TestLoader().loadTestsFromTestCase(LoadTestsFromTestCaseDemo)
    # 创建suite并添加用例类
    suite = unittest.TestSuite()
    suite.addTests([test_case1, test_case2])
    unittest.TextTestRunner(verbosity=2).run(suite)

```

#### loadTestsFromModule

```python
# loadTestsFromTestCaseDemo.loadTestsFromTestCaseDemo.py
import unittest

class LoadTestsFromTestCaseDemo1(unittest.TestCase):

    def test_is_upper(self):
        self.assertTrue('FOO'.isupper())

    def test_is_lower(self):
        self.assertTrue('foo'.islower())

class LoadTestsFromTestCaseDemo2(unittest.TestCase):

    def test_startswith(self):
        self.assertTrue('FOO'.startswith('F'))

    def test_endswith(self):
        self.assertTrue('foo'.endswith('o'))


# main.py
import unittest
from loadTestsFromTestCaseDemo import loadTestsFromTestCaseDemo

class MyTestCase(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('FOO', 'foo'.upper())

if __name__ == '__main__':
    # 使用 loadTestsFromTestCase 获取当前脚本的用例类
    test_case1 = unittest.TestLoader().loadTestsFromTestCase(MyTestCase)
    # 使用 loadTestsFromModule 获取 loadTestsFromTestCaseDemo 脚本中的用例类
    test_case2 = unittest.TestLoader().loadTestsFromModule(loadTestsFromTestCaseDemo)
    # 创建suite并添加用例类
    suite = unittest.TestSuite()
    suite.addTests([test_case1, test_case2])
    unittest.TextTestRunner(verbosity=2).run(suite)

```

#### loadTestsFromName && loadTestsFromNames

```python
# main.py
import unittest
from loadTestsFromTestCaseDemo import loadTestsFromTestCaseDemo


class MyTestCase(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('FOO', 'foo'.upper())

if __name__ == '__main__':
    # 使用 loadTestsFromName 获取当前脚本用例类的用例方法名称
    test_case1 = unittest.TestLoader().loadTestsFromName(name='MyTestCase.test_upper', module=__import__(__name__))
    # 使用 loadTestsFromNames 获取 loadTestsFromTestCaseDemo脚本中的LoadTestsFromTestCaseDemo1用例类的用例方法名
    test_case2 = unittest.TestLoader().loadTestsFromNames(
        names=['LoadTestsFromTestCaseDemo1.test_is_upper',
               'LoadTestsFromTestCaseDemo1.test_is_lower'
               ],
        module=loadTestsFromTestCaseDemo
    )
    # 创建suite并添加用例类
    suite = unittest.TestSuite()
    suite.addTests([test_case1, test_case2])
    unittest.TextTestRunner(verbosity=2).run(suite)

```

切记，无论是`loadTestsFromName`还是`loadTestsFromNames`，name参数都必须传递的是用例类下的方法名字，并且，方法名必须是全名。module参数就是脚本名字。

```python
unittest.TestLoader().loadTestsFromNames(
	name="ClassName.MethodName",   # 类名点方法名
	module=ModuleName			   # 脚本名
)
```



#### discover

创建目录`discover`, 并新增测试案例

```python
# test_list.py
import unittest


class TextCaseList(unittest.TestCase):

    def test_list_append(self):
        l = ['a']
        self.assertEqual(l, ['a'])  # 判断 l 是否等于 ['a']

    def test_list_remove(self):
        l = ['a']
        l.remove('a')
        self.assertEqual(l, [])

        
# test_str.py
import unittest


class TextCaseStr(unittest.TestCase):

    def test_str_index(self):
        self.assertEqual('abc'.index('a'), 0)

    def test_str_find(self):
        self.assertEqual('abc'.find('a'), 0)

        
# test_tuple.py
import unittest


class TextCaseTuple(unittest.TestCase):

    def test_tuple_count(self):
        t = ('a', 'b')
        self.assertEqual(t.count('a'), 1)

    def test_tuple_index(self):
        t = ('a', 'b')
        self.assertEqual(t.index('a'), 0)


# test_dict.py
import unittest


class TextCaseDict(unittest.TestCase):

    def test_dict_get(self):
        d = {'a': 1}
        self.assertEqual(d.get('a'), 1)

    def test_dict_pop(self):
        d = {'a': 1}
        self.assertEqual(d.pop('a'), 1)

```



discover的基本语法

```python
discover = unittest.TestLoader().discover(
	start_dir=base_dir,   # 该参必传
	pattern='test*.py',   # 保持默认即可。
	top_level_dir=None
	)
unittest.TextTestRunner(verbosity=2).run(discover)
```

通过`TestLoader()`实例化对象，然后通过实例化对象调用discover方法，discover根据给定目录，递归找到子目录下的所有符合规则的测试模块，然后交给TestSuit生成用例集suite。完事交给TextTestRunner执行用例。
该discover方法接收三个参数：

- start_dir：要测试的模块名或者测试用例的目录。
- pattern="test*.py"：表示用例文件名的匹配原则，默认匹配以`test`开头的文件名，星号表示后续的多个字符。
- top_level_dir=None：测试模块的顶层目录，如果没有顶层目录，默认为None。

**需要注意！！！**

- discover对给定的目录是有要求的，它只**识别Python的包，也就是目录内有`__init__.py`文件的才算是Python的包，只要是要读取的目录，都必须是包**。
- 关于start_dir和top_level_dir的几种情况：
    - start_dir目录可以单独指定，这个时候，让top_level_dir保持默认（None）即可。
    - start_dir == top_level_dir， start_dir目录与top_level_dir目录一致，discover寻找start_dir指定目录内的符合规则的模块。
    - start_dir < top_level_dir，start_dir目录是top_level_dir目录的子目录。discover寻找start_dir指定目录内的符合规则的模块。
    - start_dir > top_level_dir，start_dir目录如果大于top_level_dir目录，等待你的是报错`AssertionError: Path must be within the project`。说你指定的路径（start_dir）必须位于项目（top_level_dir）。



我们知道，TestLoader类根据各种标准加载测试用例，并将它们返回给测试套件（suite）。但一般的，我们也可以不需要创建这个类实例（想要用某个类的方法，通常都是通过个该类的实例化对象调用）。unittest已经帮我们实例化好了TestLoader对象————defaultTestLoader，我们可以直接使用defaultTestLoader.discover。

```python
discover = unittest.defaultTestLoader.discover(
	start_dir=base_dir, 
	pattern='test*.py', 
	top_level_dir=base_dir
	)
unittest.TextTestRunner(verbosity=2).run(discover)

```



```python
import os
import unittest

class MyTestCase(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('FOO', 'foo'.upper())

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.abspath(__name__))  # M:\tests
    discover_dir = os.path.join(base_dir, 'discover')  # M:\tests\discover
    son_dir = os.path.join(discover_dir, 'son')  # M:\tests\discover\son
    print(base_dir, discover_dir, son_dir)
    '''
    # start_dir 和top_level_dir 的目录一致，获取该 start_dir 目录及子目录内的所有以 test 开头的 py 文件中的测试用例类
    discover = unittest.defaultTestLoader.discover(start_dir=base_dir, pattern='test*.py', top_level_dir=base_dir)
    unittest.TextTestRunner(verbosity=2).run(discover)  # 8个用例被执行
    '''
    # start_dir 是 top_level_dir 的子目录，获取该 start_dir 目录及子目录内的所有以 test 开头的 py 文件中的测试用例类
    discover = unittest.defaultTestLoader.discover(start_dir=discover_dir, pattern='test*.py', top_level_dir=base_dir)
    unittest.TextTestRunner(verbosity=2).run(discover)  # 6个用例被执行
    
    # discover = unittest.TestLoader().discover(start_dir=base_dir)
    # unittest.TextTestRunner(verbosity=2).run(discover)
```



### unittest.main

现在，makeSuite虽然很好用，但是依然不够，我们需要更加便捷和省事，一般情况下，我们更加倾向专注于编写测试用例，而后直接使用unittest执行即可，希望makeSuite这一步都能由unittest来完成，而不是我们自己来。

```python
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def test_add(self):
        """ 测试加法用例 """
        print(self._testMethodName, self._testMethodDoc)   # test_add 测试加法用例
        self.assertEqual(case_set.add(2, 3), 5)

    def test_sub(self):
        self.assertEqual(case_set.sub(10, 5), 2) # AssertionError: 5 != 2

    def test_mul(self):
        self.assertEqual(case_set.mul(10, 5), 50)

    def test_div(self):
        self.assertEqual(case_set.div(10, 5), 2)

if __name__ == '__main__':
    unittest.main()

```

正如上例，我们只需要在用例类中将用例方法以`test`开头，然后直接`unittest.main()`就可以直接测试了。
我想通过前面的铺垫，这里也能大致的知道`unittest.main()`在内部做了什么了。我们将在最后来剖析它背后的故事。现在还有一些重要的事情等着我们。
另外，你也可以通过`self._testMethodName`来查看用例名称；可以使用`self._testMethodDoc`来查看用例注释(如果你写了注释的话)。

### setUpClass && tearDownClass

在开始，我们学习了在测试某一个用例时，都会对应的执行三个方法：

- setUp，开头一枪的那家伙，它负责该用例之前可能需要的一些准备，比如连接数据库。
- runTest，执行用例逻辑，没的说，干活的长工。
- tearDown，负责打扫战场，比如关闭数据库连接。

在之前的案例可以看到，每一个用例执行前后都触发了setUp和tearDown方法执行。

但是，如果这是由1000甚至更多的用例组成的用例集，并且每一个用例都去操作数据，那么每个用例都会做连接/关闭数据库的操作。因此，我们需要一种方法，让其只执行一次连接数据，所有测试案例执行完毕后统一的再关闭数据库。

```python
import unittest
import case_set

class myUnitTest(unittest.TestCase):

    def test_add(self):
        self.assertEqual(case_set.add(2, 3), 5)

    def test_sub(self):
        self.assertEqual(case_set.sub(10, 5), 5)

    def setUp(self):
        print('敌军还有三十秒到达战场， 碾碎他们....')

    def tearDown(self):
        print('打完收工，阿sir出来洗地了.....')

    @classmethod
    def setUpClass(cls):
        print('在用例集开始执行，我去建立数据库连接......')

    @classmethod
    def tearDownClass(cls):
        print('全军撤退， 我收工.......')

if __name__ == '__main__':
    unittest.main()
    
# 执行结果
在用例集开始执行，我去建立数据库连接......
敌军还有三十秒到达战场， 碾碎他们....
True
打完收工，阿sir出来洗地了.....
.敌军还有三十秒到达战场， 碾碎他们....
False
打完收工，阿sir出来洗地了.....
.全军撤退， 我收工.......

----------------------------------------------------------------------
Ran 2 tests in 0.002s

OK
```



### verbosity参数

上述的断言结果虽然很清晰，但是还不够！我们可以控制错误输出的详细程度。

```python
import unittest

class TestStringMethods(unittest.TestCase):

    def test_assertFalse(self):
        self.assertFalse('')

if __name__ == '__main__':
    unittest.main(verbosity=1)

```

在执行`unittest.main(verbosity=1)`时，可以通过`verbosity`参数来控制错误信息的详细程度。
`verbosity=0`：

```python
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```

`verbosity=1`：

```text
.
----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```

`verbosity=2`：

```text
test_assertFalse (__main__.TestStringMethods) ... ok

----------------------------------------------------------------------
Ran 1 test in 0.000s

OK
```

由结果可以总结，verbosity有3种的错误信息状态提示报告：

- 0，静默模式，对于测试结果给予简单提示。
- 1，默认模式，与静默模式类似，只是在每个成功的用例前面有个`.`每个失败的用例前面有个`F`，跳过的用例有个`S`。
- 2，详细模式，测试结果会显示每个用例的所有相关的信息。

切记，只有`0、1、2`三种状态。默认的是1。

除此之外，我们在终端执行时也可以输出详细报告，使用-v参数：

```bash
$ python main.py -v
test_assertFalse (__main__.TestStringMethods) ... ok

----------------------------------------------------------------------
Ran 1 test in 0.000s

OK

$ python main.py -p  # 等效于verbosity=0
什么都不加，就是verbosity=1
```



### 跳过测试用例

从Python3.1版本开始，unittest支持跳过单个测试方法甚至整个测试类。
也就是说，某些情况下，我们需要跳过指定的用例。
我们可以使用unittest提供的相关装饰器来完成：

| decorators                                | description                                                  |
| ----------------------------------------- | ------------------------------------------------------------ |
| @unittest.skip(reason)                    | 无条件地跳过装饰测试用例。 *理由*应该描述为什么跳过测试用例。 |
| @unittest.skipIf(condition, reason)       | 如果条件为真，则跳过修饰的测试用例。                         |
| @unittest.skipUnless(condition, *reason*) | 除非条件为真，否则跳过修饰的测试用例。                       |
| @unittest.expectedFailure                 | 将测试标记为预期的失败。如果测试失败，将被视为成功。如果测试用例通过，则认为是失败。 |
| expection unittest.SkipTest(reason)       | 引发此异常以跳过测试测试用例。                               |

示例：

```python
import unittest

class TestCase01(unittest.TestCase):

    def test_assertTrue(self):
        self.assertTrue('')

    @unittest.skip('no test')  # 跳过该条用例
    def test_assertFalse(self):
        self.assertFalse('')

@unittest.skip('no test')  # 跳过这个用例类
class TestCase02(unittest.TestCase):

    def test_assertTrue(self):
        self.assertTrue('')

    def test_assertFalse(self):
        self.assertFalse('')

if __name__ == '__main__':
    unittest.main()

# 执行结果
# python main.py
sFss
======================================================================
FAIL: test_assertTrue (__main__.TestCase01)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "demo0.py", line 27, in test_assertTrue
    self.assertTrue('')
AssertionError: '' is not true

----------------------------------------------------------------------
Ran 4 tests in 0.001s

FAILED (failures=1, skipped=3)
```

### 源码分析




### 自定义删除用例方法

我们之前学习unittest.makeSuite时，学过两个添加用例的方法，但是我讲过删除用的方法了吗？并没有！现在，我们已经剖析了源码，知道了添加用例是`addTest`和`addTests`干的。
**suite.py: BaseTestSuite：**

```python
class BaseTestSuite(object):

    def addTest(self, test):
        # sanity checks
        if not callable(test):
            raise TypeError("{} is not callable".format(repr(test)))
        if isinstance(test, type) and issubclass(test,
                                                 (case.TestCase, TestSuite)):
            raise TypeError("TestCases and TestSuites must be instantiated "
                            "before passing them to addTest()")
        self._tests.append(test)

    def addTests(self, tests):
        if isinstance(tests, str):
            raise TypeError("tests must be an iterable of tests, not a string")
        for test in tests:
            self.addTest(test)
```

可以看到，`addTest`是一个一个添加，而`addTests`则是for循环调用`addTest`添加，本质上一样的。
让我们将目光聚集到`addTest`中，可以看到使用的是`self._test.append(test)`。现在，我们的删除方法也有了——把添加方法复制一份，改几个字即可：

```python
class BaseTestSuite(object):

    def addTest(self, test):
        # sanity checks
        if not callable(test):
            raise TypeError("{} is not callable".format(repr(test)))
        if isinstance(test, type) and issubclass(test,
                                                 (case.TestCase, TestSuite)):
            raise TypeError("TestCases and TestSuites must be instantiated "
                            "before passing them to addTest()")
        self._tests.append(test)

    def removeTest(self, test):
        # sanity checks
        if not callable(test):
            raise TypeError("{} is not callable".format(repr(test)))
        if isinstance(test, type) and issubclass(test,
                                                 (case.TestCase, TestSuite)):
            raise TypeError("TestCases and TestSuites must be instantiated "
                            "before passing them to addTest()")
        self._tests.remove(test)
```

没错，你没看错，就是把`addTest`复制一份，方法名改为`removeTest`，完事把`self._tests.append(test)`改为`self._tests.remove(test)`就行了。

调用也类似：

```python
import unittest


class TestStringMethods(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())

if __name__ == '__main__':
    case = TestStringMethods('test_upper')
    suite = unittest.TestSuite()
    suite.addTest(case)   # suite中有一个test_upper用例
    print(suite.countTestCases())  # 1
    suite.removeTest(case)  # 删除掉它
    print(suite.countTestCases())  # 0
```

### 将执行结果输出到文件

我们尝试着讲用例执行结果输出到文件中。

```python
import unittest
class TestStringMethods(unittest.TestCase):

    def test_upper(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        self.assertTrue('FOO'.isupper())

if __name__ == '__main__':
    f = open(r'M:\tests\t1.txt', 'w', encoding='utf-8')
    suite = unittest.makeSuite(TestStringMethods)
    unittest.TextTestRunner(stream=f).run(suite)
```



### 生成用例报告

HTMLTestRunner和BSTestRunner是Python标准库unittest的扩展，用来生成HTML类型的测试报告，两个下载安装和使用基本一致。

#### 安装

首先，Python2和Python3中两个扩展包不兼容（但下载和使用一致），这点是你要注意的。

```python
pip install HTMLTestRunner-Python3
pip install HTMLTestRunner-Python3==0.8.0
```

但经过测试，发现源码有点问题，如果你在使用中遇到报错：

```text
TypeError: a bytes-like object is required, not 'str'
```

就去源码的`691`行，修改：

```python
# 修改前
self.stream.write(output)

# 修改后
self.stream.write(output.encode('utf8'))
```

其实源码中也提到了这点！
其次，从pypi上安装的，导包方式不太一样，pypi上下载的是以包的形式安装的所以，导包方式略有不同：

```python
# 我们自己是直接保存了成了模块，所以直接导入模块
import HTMLTestRunner
HTMLTestRunner.HTMLTestRunner()

# pypi上下载的，多了层马甲，即`HTMLTestRunner.py`外面包了层HTMLTestRunner目录，所以，要从包内导入模块
from HTMLTestRunner import HTMLTestRunner
HTMLTestRunner.HTMLTestRunner()
```



#### HTMLTestRunner for Python3.x

先来说`HTMLTestRunner.py`在python3环境中的使用方式：

```python
import requests   # pip install requests
import unittest
import ddt   # pip install ddt
import HTMLTestRunner3   # 这里我将HTMLTestRunner的Python3版本保存为 HTMLTestRunner3.py


data_list = [
    {"url": "https://cnodejs.org/api/v1/topics", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/topic/5433d5e4e737cbe96dcef312", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/topic_collect/collect", "method": "post"},
    {"url": "https://cnodejs.org/api/v1/topic_collect/de_collect", "method": "post"},
    {"url": "https://cnodejs.org/api/v1/user/alsotang", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/message/mark_all", "method": "post"},
]


@ddt.ddt
class MyCase(unittest.TestCase):
    @ddt.data(*data_list)
    def test_case(self, item):
        response = requests.request(
            url=item['url'],
            method=item['method']
        )
        # print(item['url'])   # HTMLTestRunner 在生成报告时，测试用例中不能有打印，不然报错
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    suite = unittest.makeSuite(testCaseClass=MyCase, prefix='test')
    with open('./report.html', 'wb') as f:
        HTMLTestRunner3.HTMLTestRunner(
            stream=f,
            title='ddt示例报告',
            description='演示ddt和HTMLTestRunner结合用法',
            verbosity=2,
        ).run(suite)
```

效果示例：

[![img](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720212139844-347742288.png)](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720212139844-347742288.png)

#### HTMLTestRunner for Python2.x

在来说`HTMLTestRunner.py`在python2环境中的使用方式，其实，Python2.x和Python3.x的源码不一致之外，使用方式却是一致的，只要注意中文前面加`u`。

```python
import requests   # pip install requests
import unittest
import ddt   # pip install ddt
import HTMLTestRunner3   # 这里我将HTMLTestRunner的Python2版本保存为 HTMLTestRunner2.py


data_list = [
    {"url": "https://cnodejs.org/api/v1/topics", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/topic/5433d5e4e737cbe96dcef312", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/topic_collect/collect", "method": "post"},
    {"url": "https://cnodejs.org/api/v1/topic_collect/de_collect", "method": "post"},
    {"url": "https://cnodejs.org/api/v1/user/alsotang", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/message/mark_all", "method": "post"},
]


@ddt.ddt
class MyCase(unittest.TestCase):
    @ddt.data(*data_list)
    def test_case(self, item):
        response = requests.request(
            url=item['url'],
            method=item['method']
        )
        # print(item['url'])   # HTMLTestRunner 在生成报告时，测试用例中不能有打印，不然报错
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    suite = unittest.makeSuite(testCaseClass=MyCase, prefix='test')
    with open('./report.html', 'wb') as f:
        HTMLTestRunner3.HTMLTestRunner(
            stream=f,
            title=u'ddt示例报告',
            description=u'演示ddt和HTMLTestRunner结合用法',
            verbosity=2,
        ).run(suite)
```

效果示例：

[![img](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720212716648-1895923295.png)](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720212716648-1895923295.png)

#### HTMLTestRunner for Python3.x selenium

在来说`HTMLTestRunner.py`结合selenium在python3环境中的使用方式，主要特点就是如果断言失败，将会带有错误截图。

```python
import unittest
from selenium import webdriver
from HTMLTestRunner3_selenium import HTMLTestRunner   # 这里我将HTMLTestRunner的Python3版本的selenium版本保存为 HTMLTestRunner3_selenium.py


class myTestCase(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.driver = webdriver.Chrome()
        cls.driver.implicitly_wait(10)

    def test_case_01(self):
        title = self.driver.title
        self.assertEqual(title, '百度一下，你就知道')

    def test_case_02(self):
        title = self.driver.title
        self.assertEqual(title, '百度一下， 我不知道')

    def setUp(self):
        self.driver.get('https://www.baidu.com/')

    @classmethod
    def tearDownClass(cls):
        cls.driver.quit()


if __name__ == '__main__':
    suite = unittest.makeSuite(testCaseClass=myTestCase)
    with open('./report.html', 'wb') as f:
        HTMLTestRunner(
            stream=f,
            verbosity=2,
            tester='张开',
            title='selenium测试报告'
        ).run(suite)
```

这里的selenium版本中，只需要关注逻辑即可，当断言失败是，会保存相应的截图。

效果示例：

[![img](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720213153006-739998518.png)](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720213153006-739998518.png)

[![img](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720213444289-724676511.png)](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720213444289-724676511.png)

#### BSTestRunner for Python3.x

在来说`BSTestRunner.py`在python3环境中的使用方式：

```python
import requests   # pip install requests
import unittest
import ddt   # pip install ddt
import BSTestRunner3   # 这里我将BSTestRunner 的Python3版本保存为 BSTestRunner3.py


data_list = [
    {"url": "https://cnodejs.org/api/v1/topics", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/topic/5433d5e4e737cbe96dcef312", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/topic_collect/collect", "method": "post"},
    {"url": "https://cnodejs.org/api/v1/topic_collect/de_collect", "method": "post"},
    {"url": "https://cnodejs.org/api/v1/user/alsotang", "method": "get"},
    {"url": "https://cnodejs.org/api/v1/message/mark_all", "method": "post"},
]


@ddt.ddt
class MyCase(unittest.TestCase):
    @ddt.data(*data_list)
    def test_case(self, item):
        response = requests.request(
            url=item['url'],
            method=item['method']
        )
        # print(item['url'])   # BSTestRunner 在生成报告时，测试用例中不能有打印，不然报错
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    suite = unittest.makeSuite(testCaseClass=MyCase, prefix='test')
    with open('./report.html', 'wb') as f:
        BSTestRunner3.BSTestRunner(
            stream=f,
            title='ddt示例报告',
            description='演示ddt和HTMLTestRunner结合用法',
            verbosity=2,
        ).run(suite)
```

用法跟HTMLTestRunner一致。

效果示例：

[![img](https://raw.githubusercontent.com/adcwb/storages/master/1168165-20200720213740599-2073082673.png)](https://img2020.cnblogs.com/blog/1168165/202007/1168165-20200720213740599-2073082673.png)

------



### 发送测试邮件

有了测试报告我们就可以发送邮件了。

Python发邮件功能借助`smtplib`和`email`模块。

```python
import unittest
import smtplib
import HTMLTestRunner
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header


class TestStringMethods(unittest.TestCase):

    def test_upper(self):
        """判断 foo.upper() 是否等于 FOO"""
        self.assertEqual('foo'.upper(), 'FOO')

    def test_isupper(self):
        """ 判断 Foo 是否为大写形式 """
        self.assertTrue('Foo'.isupper())


def get_case_result():
    """ 获取测试用例报告 """
    suite = unittest.makeSuite(TestStringMethods)
    file_path = r'M:\tests\result.html'
    with open(file_path, 'wb') as f:
        HTMLTestRunner.HTMLTestRunner(
            stream=f,
            title='HTMLTestRunner版本关于upper的测试报告',
            description='判断upper的测试用例执行情况').run(suite)
    f1 = open(file_path, 'r', encoding='utf-8')
    res = f1.read()
    f1.close()
    return res


def send_email():
    """ 发送邮件 """

    # 第三方 SMTP 服务
    mail_host = "smtp.qq.com"  # 设置服务器
    mail_user = "1206180814@qq.com"  # 用户名
    mail_pass = "chmbpeciazgjgegi"  # 口令

    # 设置收件人和发件人
    sender = '1206180814@qq.com'
    receivers = ['1206180814@qq.com', 'tingyuweilou@163.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱

    # 创建一个带附件的实例对象
    message = MIMEMultipart()

    # 邮件主题、收件人、发件人
    subject = '请查阅--测试报告'  # 邮件主题
    message['Subject'] = Header(subject, 'utf-8')
    message['From'] = Header("{}".format(sender), 'utf-8')  # 发件人
    message['To'] = Header("{}".format(';'.join(receivers)), 'utf-8')  # 收件人

    # 邮件正文内容 html 形式邮件
    send_content = get_case_result()  # 获取测试报告
    html = MIMEText(_text=send_content, _subtype='html', _charset='utf-8')  # 第一个参数为邮件内容

    # 构造附件
    att = MIMEText(_text=send_content, _subtype='base64', _charset='utf-8')
    att["Content-Type"] = 'application/octet-stream'
    file_name = 'result.html'
    att["Content-Disposition"] = 'attachment; filename="{}"'.format(file_name)  # # filename 为邮件附件中显示什么名字
    message.attach(html)
    message.attach(att)

    try:
        smtp_obj = smtplib.SMTP()
        smtp_obj.connect(mail_host, 25)  # 25 为 SMTP 端口号
        smtp_obj.login(mail_user, mail_pass)
        smtp_obj.sendmail(sender, receivers, message.as_string())
        smtp_obj.quit()
        print("邮件发送成功")

    except smtplib.SMTPException:
        print("Error: 无法发送邮件")


if __name__ == '__main__':
    send_email()

```

在使用HTMLTestRunner模板发送测试报告的时候，QQ邮箱和163邮箱或多或少的会存在一些渲染问题。的html内容无法加载CSS样式，但附件没问题。
这说明各家对于邮箱服务器的设置不一样。我们不要在意这些细节，只要附件没有问题就ok啦。



### unittest.mock

在此文档中摘除，参见其他文档



小结：在unittest中，我们需要掌握的几个类：

- unittest.TestCase：所有测试用例的基类，给定一个测试用例方法的名字，就会返回一个测试用例实例。
- unittest.TestSuite：组织测试用例的用例集，支持测试用例的添加和删除。
- unittest.TextTestRunner：测试用例的执行，其中Text是以文本的形式显示测试结果，测试结果会保存到TextTestResult中。
- unittest.TextTestResult：保存测试用例信息，包括运行了多少个测试用例，成功了多少，失败了多少等信息。
- unittest.TestLoader：加载TestCase到TESTSuite中。
- unittest.defaultTestLoader：等于`unittest.TestLoader()`。
- unittest.TestProgram：TestProgram类名被赋值给了main变量，然后通过unittest.main()的形式调用。