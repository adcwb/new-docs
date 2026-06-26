---
title: "Numpy使用"
weight: 20
date: 2026-06-05
---

Numpy

NumPy(Numerical Python) 是 Python 语言中做科学计算的基础库。

重在于数值计算，也是大部分Python科学计算库的基础，多用于在大型、多维数组上执行的数值运算。





## numpy的创建

- 使用array()创建一个多维数组

```python
import numpy as np

# 创建一维数组
>>> np.array([1, 2, 3, 4, 5])
array([1, 2, 3, 4, 5])


# 创建多维数组
>>> np.array([[1,2,3],[4,5,6]])
array([[1, 2, 3],
       [4, 5, 6]])


# 数组和列表之前的区别
	- 数组中存储的数据元素类型必须是统一的，若不统一，则按照优先级强制转换
    - 元素优先级：字符串 > 浮点型 > 整型
>>> np.array([1, "a", 2])
array(['1', 'a', '2'], dtype='<U21')

```

- 使用plt将外部的一张图片导入

```python
# 将外部的一张图片读取加载到numpy数组中，然后尝试改变数组元素的数值查看对原始图片的影响
# 此处只是简单的使用一下matplotlib模块，具体使用请参考文档
import matplotlib.pyplot as plt

img_arr = plt.imread('./test.jpg') #读取图片到numpy数组中

#将numpy数组的数据显示成一张图片
plt.imshow(img_arr)

# 尝试修改读取图片获取到的numpy数组
plt.imshow(img_arr - 100)

```

- 使用np的routines函数创建

```python 
# zeros()	返回一个全0的n维数组， shape指定维度
np.zeros(shape=[3,4,5])

# ones()	返回一个全1的n维数组
np.ones(shape=[3,4,5])	

# linespace()	在指定的范围内返回均匀分布的数字
np.linspace(0,10,num=20)
array([ 0.        ,  0.52631579,  1.05263158,  1.57894737,  2.10526316,
        2.63157895,  3.15789474,  3.68421053,  4.21052632,  4.73684211,
        5.26315789,  5.78947368,  6.31578947,  6.84210526,  7.36842105,
        7.89473684,  8.42105263,  8.94736842,  9.47368421, 10.        ])

# arange()	在给定的间隔内返回均匀间隔的值
np.arange(0,100,step=5)
array([ 0,  5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80,
       85, 90, 95])

# random系列
numpy.random.rand(d0,d1,...,dn)
	rand函数根据给定维度生成[0,1)之间的数据，包含0，不包含1
	dn表格每个维度
	返回值为指定维度的array


numpy.random.randn(d0,d1,...,dn)
	randn函数返回一个或一组样本，具有标准正态分布。
	标准正态分布介绍:
		- 标准正态分布---standard normal distribution
		- 标准正态分布又称为u分布，是以0为均值、以1为标准差的正态分布，记为N（0，1）。

numpy.random.randint(low, high=None, size=None, dtype='l')

	返回随机整数，范围区间为[low,high），包含low，不包含high
	参数：low为最小值，high为最大值，size为数组维度大小，dtype为数据类型，默认的数据类型是np.int
	high没有填写时，默认生成随机数的范围是[0，low)


numpy.random.choice(a, size=None, replace=True, p=None)
	从给定的一维数组中生成随机数
	参数： a为一维数组类似数据或整数；size为数组维度；p为数组中的数据出现的概率
	a为整数时，对应的一维数组为np.arange(a)
                          
# 生成[0,1)之间的浮点数
    numpy.random.random_sample(size=None)
    numpy.random.random(size=None)
    numpy.random.ranf(size=None)
    numpy.random.sample(size=None)
```



## numpy的常用属性

1. numpy.shape 	返回一个元组，里面是各个维度的size
2. numpy.ndim       返回数组的维度
3. numpy.dtype      返回数组数据的类型
3. numpy.size          返回数组的大小
3. numpy.iinfo         计算不同类型存储最大最小的数值

```python
import numpy as np

data = np.random.randint(0,100,size=(4,5,6))
data.shape	# -> (4, 5, 6)
data.ndim	# -> 3
data.size	# 120
data.dtype	# dtype('int64')

>>> np.iinfo('int8')
iinfo(min=-128, max=127, dtype=int8)

>>> np.iinfo('int64')
iinfo(min=-9223372036854775808, max=9223372036854775807, dtype=int64)
```



## numpy的数据类型

- array(dtype=?):可以设定数据类型
- arr.dtype = '?':可以修改数据类型

![](https://raw.githubusercontent.com/adcwb/storages/master/1.png)

```python
arr = np.array([1,2,3,4,5])
arr.dtype	# -> dtype('int32')

# 修改数据类型
arr.dtype = 'uint8'
arr.dtype	# -> dtype('uint8')

# numpy数组本身的类型是什么
type(arr)	# -> numpy.ndarray

```



## numpy的索引和切片操作

```python
import numpy as np
arr = np.random.randint(0,100,size=(6,5))
arr
array([[24, 25, 75, 17, 86],
       [27, 20, 54, 92,  2],
       [90, 37, 60, 91, 77],
       [82, 82, 18, 51, 40],
       [52, 23, 73, 24, 62],
       [10, 29, 92, 75,  8]])
```

- 索引操作与列表同理

```python
>>> arr[0]
array([24, 25, 75, 17, 86])
```

- 切片操作

```python
# 切出数组的前两行
>>> arr[0:2]
array([[24, 25, 75, 17, 86],
       [27, 20, 54, 92,  2]])

# 切出数组的前两列
>>> arr[:,0:2] 	# 逗号左侧是行右侧是列
array([[24, 25],
       [27, 20],
       [90, 37],
       [82, 82],
       [52, 23],
       [10, 29]])

# 切出前两行的前两列
>>> arr[0:2,0:2]
array([[24, 25],
       [27, 20]])

# 数组行倒置, 图像上下反转可以以此来实现
>>> arr[::-1]
array([[10, 29, 92, 75,  8],
       [52, 23, 73, 24, 62],
       [82, 82, 18, 51, 40],
       [90, 37, 60, 91, 77],
       [27, 20, 54, 92,  2],
       [24, 25, 75, 17, 86]])

# 数组列倒置， 图像左右反转
>>> arr[:,::-1]
array([[86, 17, 75, 25, 24],
       [ 2, 92, 54, 20, 27],
       [77, 91, 60, 37, 90],
       [40, 51, 18, 82, 82],
       [62, 24, 73, 23, 52],
       [ 8, 75, 92, 29, 10]])

# 数组行列倒置
>>> arr[::-1,::-1]
array([[ 8, 75, 92, 29, 10],
       [62, 24, 73, 23, 52],
       [40, 51, 18, 82, 82],
       [77, 91, 60, 37, 90],
       [ 2, 92, 54, 20, 27],
       [86, 17, 75, 25, 24]])

```



##  数组变形

- 注意：变形前和变形后数组的容量不可以发生变化



| 函数/属性       | 描述                                                         |
| --------------- | ------------------------------------------------------------ |
| arr.reshape()   | 重新将向量 arr 维度进行改变，不修改向量本身                  |
| arr.resize()    | 重新将向量 arr 维度进行改变，修改向量本身                    |
| arr.T           | 对向量 arr 进行转置                                          |
| arr.ravel()     | 对向量 arr 进行展平，即将多维数组变成1维数组，不会产生原数组的副本 |
| arr.flatten()   | 对向量 arr 进行展平，即将多维数组变成1维数组，返回原数组的副本 |
| arr.squeeze()   | 只能对维数为1的维度降维。对多维数组使用时不会报错，但是不会产生任何影响 |
| arr.transpose() | 对高维矩阵进行轴对换                                         |



### reshape() 函数

```python
import numpy as np

>>> arr =np.arange(10)
array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

# 将arr维度变换为2行5列
>>> arr.reshape(2, 5)
array([[0, 1, 2, 3, 4],
       [5, 6, 7, 8, 9]])

# 指定维度时可以只指定行数或列数, 其他用 -1 代替
# 将arr维度变换为5行
>>> arr.reshape(5, -1)
array([[0, 1],
       [2, 3],
       [4, 5],
       [6, 7],
       [8, 9]])

>>> arr.reshape(-1, 5)
array([[0, 1, 2, 3, 4],
       [5, 6, 7, 8, 9]])

值得注意的是，reshape() 函数不支持指定行数或列数，所以 -1 在这里是必要的。
且所指定的行数或列数一定要能被整除，例如上面代码如果修改为 arr.reshape(3,-1) 即为错误的。
```

### resize() 函数

```python
import numpy as np

# 修改的是变量的本身
>>> arr =np.arange(12)
array([ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11])

>>> arr.resize(3, 4)
array([[ 0,  1,  2,  3],
       [ 4,  5,  6,  7],
       [ 8,  9, 10, 11]])

>>> arr.resize(2, 6)
array([[ 0,  1,  2,  3,  4,  5],
       [ 6,  7,  8,  9, 10, 11]])
```



### T 属性

```python
# T 属性用来对向量进行转置，请看下面的的代码：
import numpy as np

# arr为3行4列
>>> arr =np.arange(12).reshape(3,4)	
array([[ 0,  1,  2,  3],
       [ 4,  5,  6,  7],
       [ 8,  9, 10, 11]])

# 将arr进行转置为4行3列
>>> arr.T
array([[ 0,  4,  8],
       [ 1,  5,  9],
       [ 2,  6, 10],
       [ 3,  7, 11]])


# 三维数组转换
>>> arr =np.arange(24).reshape(3,4,2 )
array([[[ 0,  1],
        [ 2,  3],
        [ 4,  5],
        [ 6,  7]],

       [[ 8,  9],
        [10, 11],
        [12, 13],
        [14, 15]],

       [[16, 17],
        [18, 19],
        [20, 21],
        [22, 23]]])

>>> arr.T
array([[[ 0,  8, 16],
        [ 2, 10, 18],
        [ 4, 12, 20],
        [ 6, 14, 22]],

       [[ 1,  9, 17],
        [ 3, 11, 19],
        [ 5, 13, 21],
        [ 7, 15, 23]]])

```



## 级联操作

- 将多个numpy数组进行横向或者纵向的拼接

- axis轴向的理解
    - 0:列
    - 1:行

 

**匹配级联**

```python
import numpy as np

# 样板数据
arr1 = np.random.randint(0,100,size=(3,4))
array([[25, 35, 47, 94],
       [81, 12, 25, 23],
       [75, 39, 57,  9]])

arr2 = np.random.randint(0,100,size=(4,4))
array([[31, 41, 68, 63],
       [44, 99,  1, 51],
       [40, 98, 92, 42],
       [29, 18, 48,  0]])


>>> np.concatenate((arr1,arr1,arr1),axis=1)
array([[25, 35, 47, 94,  25, 35, 47, 94,  25, 35, 47, 94],
       [81, 12, 25, 23,  81, 12, 25, 23,  81, 12, 25, 23],
       [75, 39, 57,  9,  75, 39, 57,  9,  75, 39, 57,  9]])
```

**不匹配级联**

```python
import numpy as np

>>> np.concatenate((arr1,arr2),axis=0)
array([[25, 35, 47, 94],
       [81, 12, 25, 23],
       [75, 39, 57,  9],
       [31, 41, 68, 63],
       [44, 99,  1, 51],
       [40, 98, 92, 42],
       [29, 18, 48,  0]])
```



**制作一个照片九宫格**

```python
import matplotlib.pyplot as plt
import numpy as np

img_arr = plt.imread('./cheng.jpg') #读取图片到numpy数组中
arr_3 = np.concatenate((img_arr,img_arr,img_arr),axis=1)
arr_9 = np.concatenate((arr_3,arr_3,arr_3),axis=0)

#将numpy数组的数据显示成一张图片
plt.imshow(arr_9)
```



## 常用聚合操作

| 函数名称      | 描述                     |
| ------------- | ------------------------ |
| np.sum        | 计算元素的和             |
| np.prod       | 计算元素的积             |
| np.mean       | 计算元素的平局值         |
| np.std        | 计算元素的标准差         |
| np.var        | 计算元素的方差           |
| np.min        | 找出最小值               |
| np.max        | 找出最大值               |
| np.argmin     | 找出最小值的索引         |
| np.argmax     | 找出最大值的索引         |
| np.median     | 计算元素的中位数         |
| np.percentile | 计算基于元素排序的统计值 |
| np.any        | 验证任何一个元素是否为真 |
| np.all        | 验证所有元素是否为真     |



## 常用的数学函数

- NumPy 提供了标准的三角函数：sin()、cos()、tan()
- numpy.around(a,decimals) 函数返回指定数字的四舍五入值。
    - 参数说明：
        - a: 数组
        - decimals: 舍入的小数位数。 默认值为0。 如果为负，整数将四舍五入到小数点左侧的位置

```python
import numpy as np

arr = np.array([1.23,3.76,5.1,27,33])
np.around(arr,decimals=-1)

array([ 0.,  0., 10., 30., 30.])
```

## 常用统计函数

- numpy.amin() 和 numpy.amax()，用于计算数组中的元素沿指定轴的最小、最大值。
- numpy.ptp():计算数组中元素最大值与最小值的差（最大值 - 最小值）。
- numpy.median() 函数用于计算数组 a 中元素的中位数（中值）
- 标准差std():标准差是一组数据平均值分散程度的一种度量。
    - 公式：std = sqrt(mean((x - x.mean())**2))
    - 如果数组是 [1，2，3，4]，则其平均值为 2.5。 因此，差的平方是 [2.25,0.25,0.25,2.25]，并且其平均值的平方根除以 4，即 sqrt(5/4) ，结果为 1.1180339887498949。
- 方差var()：统计中的方差（样本方差）是每个样本值与全体样本值的平均数之差的平方值的平均数，即 mean((x - x.mean())** 2)。换句话说，标准差是方差的平方根。





## 常用的算术函数



## 常用的字符串函数





## 矩阵相关

- NumPy 中包含了一个矩阵库 numpy.matlib，该模块中的函数返回的是一个矩阵，而不是 ndarray 对象。一个 的矩阵是一个由行（row）列（column）元素排列成的矩形阵列。

- numpy.matlib.identity() 函数返回给定大小的单位矩阵。单位矩阵是个方阵，从左上角到右下角的对角线（称为主对角线）上的元素均为 1，除此以外全都为 0。

- 转置矩阵
    - .T
    
    ```python
    arr = np.random.randint(0,100,size=(4,6))
    arr
    array([[28, 43, 75, 24, 99, 17],
           [99, 40, 65, 91, 86, 40],
           [41, 61, 14, 44, 90, 18],
           [65, 25, 22, 84, 33, 97]])
    
    
    arr.T
    array([[28, 99, 41, 65],
           [43, 40, 61, 25],
           [75, 65, 14, 22],
           [24, 91, 44, 84],
           [99, 86, 90, 33],
           [17, 40, 18, 97]])
    ```
    
    
    
- 矩阵相乘
    - numpy.dot(a, b, out=None)
        - a : ndarray 数组
        - b : ndarray 数组
        
        ![numpy矩阵相乘](https://raw.githubusercontent.com/adcwb/storages/master/numpy%E7%9F%A9%E9%98%B5%E7%9B%B8%E4%B9%98.png)
        
    - 第一个矩阵第一行的每个数字（2和1），各自乘以第二个矩阵第一列对应位置的数字（1和1），然后将乘积相加（ 2 x 1 + 1 x 1），得到结果矩阵左上角的那个值3。也就是说，结果矩阵第m行与第n列交叉位置的那个值，等于第一个矩阵第m行与第二个矩阵第n列，对应位置的每个值的乘积之和。
    
    
    
    - 线性代数基于矩阵的推导：
        - https://www.cnblogs.com/alantu2018/p/8528299.html



- 重点：
    - numpy数组的创建
    - numpy索引和切片
    - 级联
    - 变形
    - 矩阵的乘法和转置
    - 常见的聚合函数+统计
