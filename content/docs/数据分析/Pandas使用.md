---
title: "Pandas使用"
weight: 30
date: 2026-06-05
---

## Pandas



## 为什么学习pandas

- numpy已经可以帮助我们进行数据的处理了，那么学习pandas的目的是什么呢？
    - numpy能够帮助我们处理的是数值型的数据，当然在数据分析中除了数值型的数据还有好多其他类型的数据（字符串，时间序列），那么pandas就可以帮我们很好的处理除了数值型的其他数据！



## 什么是pandas？

- 首先先来认识pandas中的两个常用的类
    - Series
    - DataFrame



## Series

- Series是一种类似与一维数组的对象，由下面两个部分组成：
    - values：一组数据（ndarray类型）
    - index：相关的数据索引标签

- Series的创建
    - 由列表或numpy数组创建
    - 由字典创建



```python
import pandas as pd
import numpy as np
from pandas import Series,DataFrame

# 使用列表作为数据源
>>> Series(data=[1, 2, 3])		# 默认的索引叫做隐式索引
0    1
1    2
2    3
dtype: int64

# 使用numpy生成数据源
>>> Series(data=np.random.randint(0,100,size=(5,)))
0     8
1    18
2    23
3    76
4    30
dtype: int64

# 使用字典作为数据源
>>> dic = { '语文':100, '数学':60, '英语': 30 } 
>>> Series(data=dic)	# 自定义的索引叫做显式索引
语文    100
数学     60
英语     30
dtype: int64

# 可以使用index指定显式索引，但是要求索引的个数和数据个数必须一致
>>> s = Series(data=[1,2,3],index=['a','b','c'])
>>> s
a    1
b    2
c    3
dtype: int64

```



- Series的索引
    - 隐式索引：默认形式的索引（0，1，2....）
    - 显式索引:  自定义的索引,可以通过index参数设置显示索引



- Series的索引取值和切片

```python
# 索引取值可以按照显式索引取值和隐式索引，若有自定义的显式索引，可以直接点索引取值

s[0]	# 隐式索引取值
s['a']	# 显式索引取值
s.a		# 等同于上面的写法


# 索引的切片，隐式索引取值等同与列表的切片
>>> s[0:2]
a    1
b    2
dtype: int64

>>> s['a':'c']
a    1
b    2
c    3
dtype: int64
    
```



- Series的常用属性
    - shape
    - size
    - index
    - values

```python
# 取索引
s.index		# Index(['a', 'b', 'c'], dtype='object')

# 取值
s.values	# array([1, 2, 3], dtype=int64)

# 返回基础数据形状的元组
s.shape		# (3,)

# 返回基础数据中的元素个数
s.size		# 3


```



- Series的常用方法
    - head()
    - tail()
    - unique()
    - isnull()
    - notnull()
    - add()
    - sub()
    - mul()
    - div()

```python
s = Series(data=[1,1,1,2,2,3,4,5,6,6,6,6,7,8])

s.head(3)		# 取前几个数据
s.tail(3)		# 取后几个数据
s.unique() 		# 将Series元素进行去重
s.nunique() 	# 统计去重之后的元素个数
s.value_counts() # 统计Seris中每个元素出现的次数
s.isnull()		# 判断是否为空
s.notnull()		# 是否非空

```



- Series的算术运算
    - 法则：索引一致的元素进行算数运算否则补空

```python
>>> s1 = Series(data=[1,2,3],index=['a','b','c'])
>>> s2 = Series(data=[4,5,6],index=['a','d','c'])

>>> s = s1 + s2
>>> s
a    5.0
b    NaN
c    9.0
d    NaN
dtype: float64

# 可以将布尔值作为Series的索引
>>> s[[True,False,True,False]]
a    5.0
c    9.0
dtype: float64
>>> s[s.notnull()]	# 等同于上面的

```



## DataFrame

- DataFrame是一个【表格型】的数据结构。
- DataFrame由按一定顺序排列的多列数据组成。
- 设计初衷是将Series的使用场景从一维拓展到多维。
- DataFrame既有行索引，也有列索引。
    - 行索引：index
    - 列索引：columns
    - 值：values

- DataFrame的创建
    - ndarray创建
    - 字典创建



```python
# ndarray创建
>>> DataFrame(data=np.random.randint(0,100,size=(5,6)))
    0	1	2	3	4	5
0	88	50	4	57	69	88
1	21	9	54	93	12	77
2	18	14	40	52	43	19
3	57	82	46	37	32	45
4	33	42	73	65	89	21


# 字典创建
>>> dic = {
    'name':['jay','tom','bobo'],
    'salary':[1000,2000,3000]
}
>>> df = DataFrame(data=dic,index=['a','c','c'])
>>> df
name	salary
a	jay	1000
c	tom	2000
c	bobo	3000
```



- DataFrame的属性

    - values
    - columns
    - index
    - shape


```python
>>> df
name	salary
a	jay	1000
c	tom	2000
c	bobo	3000

# 返回维度
>>> df.shape	# (3, 2)

# 获取值
>>> df.values
array([['jay', 1000],
       ['tom', 2000],
       ['bobo', 3000]], dtype=object)

# 获取索引
>>> df.index
Index(['a', 'c', 'c'], dtype='object')

# 获取列索引
>>> df.columns
Index(['name', 'salary'], dtype='object')


"""
============================================

练习：

根据以下考试成绩表，创建一个DataFrame，命名为df：

    张三  李四  
语文 150  0
数学 150  0
英语 150  0
理综 300  0
============================================
"""

>>> dic = {
    
    '张三':[150,150,150,150],
    '李四':[0,0,0,0]
}
>>> df = DataFrame(data=dic,index=['语文','数学','英语','理综'])
	张三	李四
语文	150	0
数学	150	0
英语	150	0
理综	150	0
```



- DataFrame索引操作
    - 对行进行索引
    - 队列进行索引
    - 对元素进行索引

```python
>>> df['张三']		# 取列
语文    150
数学    150
英语    150
理综    150
Name: 张三, dtype: int64

>>> df.loc['英语'] 	# 取行
张三    150
李四      0
Name: 英语, dtype: int64

>>> df.iloc[0]		# 按照索引进行取值
张三    150
李四      0
Name: 语文, dtype: int64

>>> df.loc['英语','张三']	# 索引取元素
150

>>> df.loc['英语',['张三','李四']]
张三    150
李四      0
Name: 英语, dtype: int64

        
注意：
    iloc: 通过隐式索引取行
    loc: 通过显示索引取行
```



- DataFrame的切片操作
    - 对行进行切片
    - 对列进行切片

```python
>>> df[0:2] #中括号中直接作用的切片是行切片
	张三	李四
语文	150	0
数学	150	0

>>> df.iloc[:,0:1]
	张三
语文	150
数学	150
英语	150
理综	150

索引：
    df[col]:取列
    df.loc[index]:取行
    df.iloc[index,col]:取元素
切片：
    df[index1:index3]:切行
    df.iloc[:,col1:col3]:切列
```

- DataFrame的运算
    - 同Series



```python
"""
============================================

练习：

假设ddd是期中考试成绩，ddd2是期末考试成绩，请自由创建ddd2，并将其与ddd相加，求期中期末平均值。

假设张三期中考试数学被发现作弊，要记为0分，如何实现？

李四因为举报张三作弊立功，期中考试所有科目加100分，如何实现？

后来老师发现有一道题出错了，为了安抚学生情绪，给每位学生每个科目都加10分，如何实现？

============================================
"""

qizhong = df.copy()
qimo = df.copy()

# 求期中期末平局值
(qizhong + qimo) / 2

# 张三期中考试数据零分
qizhong.iloc[1,0] = 0

# 李四举报有功，所有科目成绩加100
qizhong['李四'] += 100

# 所有人成绩加10
qizhong += 10
```





## 案例：股票分析

```bash
# 需求： 股票分析
    - 使用tushare包获取某股票的历史行情数据。
    - 输出该股票所有收盘比开盘上涨3%以上的日期。
    - 输出该股票所有开盘比前日收盘跌幅超过2%的日期。
    - 假如我从2010年1月1日开始，每月第一个交易日买入1手股票，每年最后一个交易日卖出所有股票，到今天为止，我的收益如何？
```



```python
import tushare as ts
import pandas as pd
from pandas import Series,DataFrame
import numpy as np

#获取茅台股票的历史交易数据
>>> df = ts.get_k_data(code='600519',start='1980-01-01')
>>> df.head()
本接口即将停止更新，请尽快使用Pro版接口：https://tushare.pro/document/2
date	open	close	high	low	volume	code
0	2001-08-27	5.392	5.554	5.902	5.132	406318.00	600519
1	2001-08-28	5.467	5.759	5.781	5.407	129647.79	600519
2	2001-08-29	5.777	5.684	5.781	5.640	53252.75	600519
3	2001-08-30	5.668	5.796	5.860	5.624	48013.06	600519
4	2001-08-31	5.804	5.782	5.877	5.749	23231.48	600519

# 将数据进行本地保存
>>> df.to_csv('./maotai.csv')

# 将本地存储的文本数据使用pandas进行读取, 会默认将索引也读取为一行，需要手动删除掉
>>> df = pd.read_csv('./maotai.csv')
>>> df.head()

Unnamed: 0	date	open	close	high	low	volume	code
0	0	2001-08-27	5.392	5.554	5.902	5.132	406318.00	600519
1	1	2001-08-28	5.467	5.759	5.781	5.407	129647.79	600519
2	2	2001-08-29	5.777	5.684	5.781	5.640	53252.75	600519
3	3	2001-08-30	5.668	5.796	5.860	5.624	48013.06	600519
4	4	2001-08-31	5.804	5.782	5.877	5.749	23231.48	600519

# 数据清洗，删除没有意义的行 inplace指是否作用与原表格，axis指定删除的是行或列，1为列， 0为行
>>> df.drop(labels='Unnamed: 0',axis=1,inplace=True)
>>> df.head()
date	open	close	high	low	volume	code
0	2001-08-27	5.392	5.554	5.902	5.132	406318.00	600519
1	2001-08-28	5.467	5.759	5.781	5.407	129647.79	600519
2	2001-08-29	5.777	5.684	5.781	5.640	53252.75	600519
3	2001-08-30	5.668	5.796	5.860	5.624	48013.06	600519
4	2001-08-31	5.804	5.782	5.877	5.749	23231.48	600519

info返回值的信息
	- 每一列元素的数据类型
	- 每一列中非空元素的个数
    
>>> df.info()
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 4886 entries, 0 to 4885
Data columns (total 7 columns):
 #   Column  Non-Null Count  Dtype  
---  ------  --------------  -----  
 0   date    4886 non-null   object 
 1   open    4886 non-null   float64
 2   close   4886 non-null   float64
 3   high    4886 non-null   float64
 4   low     4886 non-null   float64
 5   volume  4886 non-null   float64
 6   code    4886 non-null   int64  
dtypes: float64(5), int64(1), object(1)
memory usage: 267.3+ KB
    

# 将date列由字符串类型转换成时间序列类型
>>> df['date'] = pd.to_datetime(df['date'])

# 将date列作为原始数据的行索引
>>> df.set_index('date',inplace=True)
>>> df.head()
            open	close	high	low	    volume	code
date						
2001-08-27	5.392	5.554	5.902	5.132	406318.00	600519
2001-08-28	5.467	5.759	5.781	5.407	129647.79	600519
2001-08-29	5.777	5.684	5.781	5.640	53252.75	600519
2001-08-30	5.668	5.796	5.860	5.624	48013.06	600519
2001-08-31	5.804	5.782	5.877	5.749	23231.48	600519

>>> df.index
DatetimeIndex(['2001-08-27', '2001-08-28', '2001-08-29', '2001-08-30',
               '2001-08-31', '2001-09-03', '2001-09-04', '2001-09-05',
               '2001-09-06', '2001-09-07',
               ...
               '2022-01-20', '2022-01-21', '2022-01-24', '2022-01-25',
               '2022-01-26', '2022-01-27', '2022-01-28', '2022-02-07',
               '2022-02-08', '2022-02-09'],
              dtype='datetime64[ns]', name='date', length=4886, freq=None)


# 输出该股票所有收盘比开盘上涨3%以上的日期
# 计算公式：(收盘-开盘) / 开盘 > 0.03
>>> (df['close']-df['open']) / df['open'] > 0.03
date
2001-08-27     True
2001-08-28     True
2001-08-29    False
2001-08-30    False
2001-08-31    False
              ...  
2022-01-27    False
2022-01-28    False
2022-02-07    False
2022-02-08    False
2022-02-09     True
Length: 4886, dtype: bool
        
# 由于返回的是bool值，所以可以直接根据索引取值
#获取了(df['close']-df['open'])/df['open'] > 0.03返回True对应的行数据
>>> df.loc[(df['close']-df['open'])/df['open'] > 0.03]

            open	close	high	low	    volume	code
date						
2001-08-27	5.392	5.554	5.902	5.132	406318.00	600519
2001-08-28	5.467	5.759	5.781	5.407	129647.79	600519
2001-09-10	5.531	5.734	5.757	5.470	18878.89	600519
2001-12-21	5.421	5.604	5.620	5.421	8135.04	600519
2002-01-18	5.437	5.726	5.762	5.421	32262.08	600519
...	...	...	...	...	...	...
2021-09-27	1750.000	1855.000	1863.400	1750.000	126869.00	600519
2021-10-13	1870.000	1929.900	1949.950	1862.000	50143.00	600519
2021-12-08	1964.880	2043.000	2045.000	1950.000	61048.00	600519
2021-12-23	2053.000	2120.000	2120.000	2025.000	39099.00	600519
2022-02-09	1839.090	1895.980	1908.000	1826.970	33885.00	600519
340 rows × 6 columns

>>> df.loc[(df['close']-df['open'])/df['open'] > 0.03].index
DatetimeIndex(['2001-08-27', '2001-08-28', '2001-09-10', '2001-12-21',
               '2002-01-18', '2002-01-31', '2003-01-14', '2003-10-29',
               '2004-01-05', '2004-01-14',
               ...
               '2021-08-10', '2021-08-24', '2021-09-01', '2021-09-17',
               '2021-09-24', '2021-09-27', '2021-10-13', '2021-12-08',
               '2021-12-23', '2022-02-09'],
              dtype='datetime64[ns]', name='date', length=340, freq=None)

# 输出该股票所有开盘比前日收盘跌幅超过2%的日期
# 计算公式：(开盘-前日收盘) / 前日收盘 < -0.02
# shift(1) 数据整体下移一位
>>> (df['open'] - df['close'].shift(1)) / df['close'].shift(1) < -0.02
>>> df.loc[(df['open'] - df['close'].shift(1)) / df['close'].shift(1) < -0.02].index
DatetimeIndex(['2001-09-12', '2002-06-26', '2002-12-13', '2004-07-01',
               '2007-05-30', '2007-06-05', '2007-07-27', '2007-09-05',
				............................................
               '2018-02-09', '2018-03-23', '2018-03-28', '2018-07-11',
               '2020-10-26', '2021-02-26', '2021-03-04', '2021-04-28',
               '2021-08-20', '2021-11-01'],
              dtype='datetime64[ns]', name='date', freq=None)
```

**案例二**

```python
"""
	假如我从2010年1月1日开始，每月第一个交易日买入1手(100支)股票，每年最后一个交易日卖出所有股票，到今天为止，我的收益如何？
		- 买股票
			-- 每月的第一个交易日根据开盘价买入一手股票
			-- 一个完整的年需要买入12次12手1200支股票
		- 卖股票
			-- 每年最后一个交易日根据开盘价(12-31)卖出所有的股票
			-- 一个完整的年需要卖出1200支股票
	注意：2020年这个人只能买入700支股票，无法卖出。
	但是在计算总收益的时候需要将剩余股票的价值也计算在内
		- 股票价值如何计算：
			-- 700 * 买入当日的开盘价
"""

# 截图数据
>>> data = df['2010':'2022']
>>> data
             open	close	high	low	    volume	code
date						
2010-01-04	109.760	108.446	109.760	108.044	44304.88	600519
2010-01-05	109.116	108.127	109.441	107.846	31513.18	600519
2010-01-06	107.840	106.417	108.165	106.129	39889.03	600519
2010-01-07	106.417	104.477	106.691	103.302	48825.55	600519
2010-01-08	104.655	103.379	104.655	102.167	36702.09	600519
...	...	...	...	...	...	...
2022-01-27	2001.010	1965.000	2010.820	1952.000	42665.00	600519
2022-01-28	1955.000	1887.000	1968.000	1880.010	41020.00	600519
2022-02-07	1900.990	1867.960	1913.560	1850.000	35150.00	600519
2022-02-08	1868.880	1839.000	1872.870	1790.000	41713.00	600519
2022-02-09	1839.090	1895.980	1908.000	1826.970	33885.00	600519
2933 rows × 6 columns

# 数据的重新取样, 获取每个月的第一条数据
# 注意，此处数据的索引日期有bug，显示是错误的
>>> data_monthly = data.resample(rule='M').first()
>>> data_monthly.head()
	         open	close	high	low  	volume	code
date						
2010-01-31	109.760	108.446	109.760	108.044	44304.88	600519
2010-02-28	107.769	107.776	108.216	106.576	29655.94	600519
2010-03-31	106.219	106.085	106.857	105.925	21734.74	600519
2010-04-30	101.324	102.141	102.422	101.311	23980.83	600519
2010-05-31	81.676	82.091	82.678	80.974	23975.16	600519

>>> cost = data_monthly['close'].sum()*100
>>> cost
8260465.300000001

# 买入股票花的钱, 数据重取样，
>>> data_yearly = data.resample(rule='A').last()[:-1]
>>> data_yearly.tail()

            open	close	high	low 	volume	code
date						
2017-12-31	707.948	687.725	716.329	681.918	76038.0	600519
2018-12-31	563.300	590.010	596.400	560.000	63678.0	600519
2019-12-31	1183.000	1183.000	1188.000	1176.510	22588.0	600519
2020-12-31	1941.000	1998.000	1998.980	1939.000	38860.0	600519
2021-12-31	2070.000	2050.000	2072.980	2028.000	29665.0	600519

# 卖出股票收到的钱
>>> recv = data_yearly['open'].sum()*1200
>>> recv
9181384.799999999

# 剩余股票的实际价值
>>> price = data['close'][-1]
>>> last_monry = price * 1200

# 总收益
>>> recv + last_monry - cost
3196095.499999998
```



**双均线策略**

- 使用tushare包获取某股票的历史行情数据

```python
import tushare as ts
import pandas as pd
import matplotlib.pyplot as plt

# 获取中国平安的股票数据
df = ts.get_k_data('000001',start='1900-01-01')
df.head()
df['date'] = pd.to_datetime(df['date'])
df.info()
df.set_index('date',inplace=True)
df['code'] = df['code'].astype('int')


```

- 计算该股票历史数据的5日均线和30日均线
    - 什么是均线？
        - 对于每一个交易日，都可以计算出前N天的移动平均值，然后把这些移动平均值连起来，成为一条线，就叫做N日移动平均线。移动平均线常用线有5天、10天、30天、60天、120天和240天的指标。
            - 5天和10天的是短线操作的参照指标，称做日均线指标；
            - 30天和60天的是中期均线指标，称做季均线指标；
            - 120天和240天的是长期均线指标，称做年均线指标。
    - 均线计算方法：MA=（C1+C2+C3+...+Cn)/N C:某日收盘价 N:移动平均周期（天数）

```python
# 五日均线
>>> ma5 = df['close'].rolling(5).mean()

# 30日均线
>>> ma30 = df['close'].rolling(30).mean()

# 数据拼接
>>> df['ma5'] = ma5
>>> df['ma30'] = ma30
>>> df.head()
            open	close	high	low	volume	code	ma5	ma30
date								
1991-01-02	0.185	0.188	0.188	0.185	759.00	1	NaN	NaN
1991-01-03	0.429	0.429	0.429	0.429	212.40	1	NaN	NaN
1991-01-04	0.428	0.428	0.428	0.428	167.90	1	NaN	NaN
1991-01-05	0.426	0.426	0.426	0.426	131.50	1	NaN	NaN
1991-01-07	0.426	0.426	0.426	0.426	161.36	1	0.3794	NaN

# 将空值对应的行数据删除
data = df[30:]

# 数据展示
plt.plot(data['ma5'][100:200],label='ma5')
plt.plot(data['ma30'][100:200],label='ma30')
plt.legend()

data['ma5'].head()
data['ma30'].head()
```

- 分析输出所有金叉日期和死叉日期
    - 股票分析技术中的金叉和死叉，可以简单解释为：
        - 分析指标中的两根线，一根为短时间内的指标线，另一根为较长时间的指标线。
        - 如果短时间的指标线方向拐头向上，并且穿过了较长时间的指标线，这种状态叫“金叉”；
        - 如果短时间的指标线方向拐头向下，并且穿过了较长时间的指标线，这种状态叫“死叉”；
        - 一般情况下，出现金叉后，操作趋向买入；死叉则趋向卖出。
        - 当然，金叉和死叉只是分析指标之一，要和其他很多指标配合使用，才能增加操作的准确性。

```python 
s1 = ma5 < ma30
s2 = ma5 > ma30
s3 = s2.shift(1)
death_cross_time = data.loc[s1 & s3].index
golden_cross_time = data.loc[~(s1 | s3)].index
```



- 如果我从假如我从2010年1月1日开始，初始资金为100000元，金叉尽量买入，死叉全部卖出，则到今天为止，我的炒股收益率如何？
- 分析：
    - 买卖股票的单价使用开盘价
    - 买卖股票的时机
    - 最终手里会有剩余的股票没有卖出去
        - 会有。如果最后一天为金叉，则买入股票。估量剩余股票的价值计算到总收益。
            - 剩余股票的单价就是用最后一天的收盘价。

```python
>>> new_df = data['2010':'2022']
>>> new_df.head()
            open	close	high	low	volume	code	ma5	ma30
date								
2010-01-04	8.149	7.880	8.169	7.870	241922.76	1	7.9322	8.123033
2010-01-05	7.893	7.743	7.943	7.560	556499.82	1	7.9334	8.093667
2010-01-06	7.727	7.610	7.727	7.551	412143.13	1	7.8874	8.063633
2010-01-07	7.610	7.527	7.660	7.444	355336.85	1	7.7718	8.031500
2010-01-08	7.477	7.511	7.560	7.428	288543.06	1	7.6542	8.003267
...	...	...	...	...	...	...	...	...
2022-01-27	16.500	16.300	16.540	16.250	1024643.00	1	16.8700	17.027333
2022-01-28	16.390	15.830	16.450	15.820	1675564.00	1	16.5660	16.964333
2022-02-07	16.020	16.390	16.410	15.890	1515476.00	1	16.4040	16.925000
2022-02-08	16.300	16.830	16.970	16.260	1754695.00	1	16.4000	16.902000
2022-02-09	16.920	16.860	17.000	16.710	1051162.00	1	16.4420	16.877667
2869 rows × 8 columns

#获取2010-2022的金叉和死叉
s1 = ma5 < ma30
s2 = ma5 > ma30
s3 = s2.shift(1)
death_cross_time = new_df.loc[s1 & s3].index
golden_cross_time = new_df.loc[~(s1 | s3)].index

first_money = 100000 #本金
cost_monry = 100000 #流动资金
#将金叉和死叉的时间全部整合到一个Series中
#金叉用1表示,死叉用0表示
s1 = pd.Series(data=1,index=golden_cross_time)
s2 = pd.Series(data=0,index=death_cross_time)
s = s1.append(s2)
s = s.sort_index()


first_money = 100000 #本金
cost_monry = 100000 #流动资金
#将金叉和死叉的时间全部整合到一个Series中
#金叉用1表示,死叉用0表示
s1 = pd.Series(data=1,index=golden_cross_time)
s2 = pd.Series(data=0,index=death_cross_time)
s = s1.append(s2)
s = s.sort_index()

hold = 0 #持有股票的数量
for i in range(len(s)):
    if s[i] == 1:#金叉,买入股票
        date = s.index[i]#金叉的日期
        price = new_df.loc[date]['open']#买入股票的单价(开盘)
        hand_count = cost_monry // (100 * price) #可以最多买入多少手股票
        hold = hand_count*100 #持有股票的股数
        cost_monry -= hold * price
    else:#将所有的股票卖出
        death_time = s.index[i] #死叉日期
        cell_price = new_df.loc[death_time]['open']
        cost_monry += (cell_price*hold)
        hold = 0
#考虑最后是否有股票的剩余
last_price = new_df['open'][-1] #剩余股票的单价
last_money = hold * last_price
print('总收益:',cost_monry+last_money-first_money)
总收益: -99768.79999999997
```



## 数据清洗

- 有两种丢失数据：
    - None
    - np.nan(NaN)

- 区别
    - NoneType
    - float
- pandas中如果使用了None,则会被自动转换成NAN



## pandas处理空值操作

```python
# 1.创建一个携带空值的df
df = DataFrame(data=np.random.randint(0,100,size=(5,6)))
df.iloc[1,3] = None
df.iloc[2,4] = np.nan
df.iloc[3,2] = None

df.isnull().any(axis=0) 	# 检测行/列中是否存在空值 0是列 1是行
df.notnull().all(axis=0)	# 检测行/列中是否存在空值
df.isnull().sum(axis=0)		# 计算每一列中存有空值的数量是多少

# 删除对应的空行
# 方式一：
    df.notnull().all(axis=1)
    df.loc[df.notnull().all(axis=1)]

# 方式二：
    df.dropna(axis=0)

df.fillna(value=-999) 		# 使用指定的值对所有的空值进行填充
df.fillna(method='bfill',axis=0) 	# 使用空值的近邻值进行填充

# 使用空值列对应的均值进行填充
cols = df.columns
for col in cols:
    null_counts = df[col].isnull().sum()
    if null_counts > 0:
        mean_value = df[col].mean()
        df[col] = df[col].fillna(value=mean_value)


# 使用中位数进行填充
cols = df.columns
for col in  cols:
    null_counts = df[col].isnull().sum()
    if null_counts > 0:
        median_value = np.median(df[col][df[col].notnull()])
        df[col] = df[col].fillna(value=median_value)

```



## 重复数据处理

```python
df.iloc[1] = [1,1,1,1,1,1]
df.iloc[3] = [1,1,1,1,1,1]

# 检测是否有重复的数据存在
df.duplicated(keep='last')

# 直接检测+删除重复的行数据
df.drop_duplicates()

```

## 处理异常数据

自定义一个1000行3列（A，B，C）取值范围为0-1的数据源，然后将C列中的值大于其两倍标准差的异常值进行清洗

```python
df = DataFrame(data=np.random.random(size=(1000,3)),columns=['A','B','C'])
df.head()
	A	B	C
0	0.754452	0.987042	0.740550
1	0.783144	0.789551	0.219793
2	0.993226	0.852922	0.286008
3	0.748507	0.515411	0.209428
4	0.131658	0.361526	0.724583


twice_std = df['C'].std() * 2
twice_std	# 0.5897425561909269

df.loc[~(df['C'] > twice_std)]

	A	B	C
1	0.783144	0.789551	0.219793
2	0.993226	0.852922	0.286008
3	0.748507	0.515411	0.209428
7	0.002232	0.516962	0.280793
8	0.038544	0.745208	0.480136
...	...	...	...
987	0.885739	0.367560	0.009077
990	0.526008	0.439168	0.517037
993	0.908418	0.872040	0.462688
994	0.514203	0.443419	0.109149
999	0.403759	0.224153	0.067862
595 rows × 3 columns
```



## 级联操作

pandas使用pd.concat函数，与np.concatenate函数类似，只是多了一些参数：

```text
    objs
    axis=0
    keys
    join='outer' / 'inner':表示的是级联的方式，outer会将所有的项进行级联（忽略匹配和不匹配），而inner只会将匹配的项级联到一起，不匹配的不级联
    ignore_index=False
```

- 匹配级联

```python
import numpy as np
import pandas as pd
from pandas import DataFrame

df1 = pd.DataFrame(data=np.random.randint(0,100,size=(4,3)),columns=['A','B','C'])
df2 = pd.DataFrame(data=np.random.randint(0,100,size=(4,3)),columns=['A','B','D'])

# 匹配级联
pd.concat((df1,df1),axis=1)

	A	B	C	A	B	C
0	55	13	68	55	13	68
1	22	84	48	22	84	48
2	85	24	60	85	24	60
3	10	90	95	10	90	95

```



- 不匹配级联
    - 不匹配指的是级联的维度的索引不一致。例如纵向级联时列索引不一致，横向级联时行索引不一致
    - 有2种连接方式：
        - 外连接：补NaN（默认模式）
        - 内连接：只连接匹配的项



```python
# 不匹配级联
pd.concat((df1,df2),axis=0,join='inner')


    A	B
0	55	13
1	22	84
2	85	24
3	10	90
0	66	54
1	62	64
2	46	91
3	50	96
```



## 合并操作

- merge与concat的区别在于，merge需要依据某一共同列来进行合并
- 使用pd.merge()合并时，会自动根据两者相同column名称的那一列，作为key来进行合并。
- 注意每一列元素的顺序不要求一致



一对一合并

```python
# 定义测试数据
df1 = DataFrame({'employee':['Bob','Jake','Lisa'],
                'group':['Accounting','Engineering','Engineering'],
                })

df2 = DataFrame({'employee':['Lisa','Bob','Jake'],
                'hire_date':[200+4,2008,2012],
                })

# 合并
pd.merge(left=df1,right=df2,on='employee')
	employee	group	hire_date
0	Bob	Accounting	2008
1	Jake	Engineering	2012
2	Lisa	Engineering	204


pd.merge(left=df1,right=df2)
    employee	group	hire_date
0	Bob	Accounting	2008
1	Jake	Engineering	2012
2	Lisa	Engineering	204

```

多对多合并

```python
# 定义测试数据
df3 = DataFrame({
    'employee':['Lisa','Jake'],
    'group':['Accounting','Engineering'],
    'hire_date':[2004,2016]})

df4 = DataFrame({'group':['Accounting','Engineering','Engineering'],
                       'supervisor':['Carly','Guido','Steve']
                })

# 合并数据
pd.merge(df3,df4)
	employee	group	hire_date	supervisor
0	Lisa	Accounting	2004	Carly
1	Jake	Engineering	2016	Guido
2	Jake	Engineering	2016	Steve


# 定义测试数据
df1 = DataFrame({'employee':['Bob','Jake','Lisa'],
                 'group':['Accounting','Engineering','Engineering']})

df5 = DataFrame({'group':['Engineering','Engineering','HR'],
                'supervisor':['Carly','Guido','Steve']
                })

pd.merge(df1,df5)
employee	group	supervisor
0	Jake	Engineering	Carly
1	Jake	Engineering	Guido
2	Lisa	Engineering	Carly
3	Lisa	Engineering	Guido


pd.merge(left=df1,right=df5,how='right')
employee	group	supervisor
0	Jake	Engineering	Carly
1	Lisa	Engineering	Carly
2	Jake	Engineering	Guido
3	Lisa	Engineering	Guido
4	NaN	HR	Steve

```

当两张表没有可进行连接的列时，可使用left_on和right_on手动指定merge中左右两边的哪一列列作为连接的列

```python
df1 = DataFrame({'employee':['Bobs','Linda','Bill'],
                'group':['Accounting','Product','Marketing'],
               'hire_date':[1998,2017,2018]})

df5 = DataFrame({'name':['Lisa','Bobs','Bill'],
                'hire_dates':[1998,2016,2007]})

pd.merge(left=df1,right=df5,left_on='employee',right_on='name')

```

内合并与外合并

out取并集 inner取交集

```python
df6 = DataFrame({'name':['Peter','Paul','Mary'],
               'food':['fish','beans','bread']}
               )
df7 = DataFrame({'name':['Mary','Joseph'],
                'drink':['wine','beer']})


```



