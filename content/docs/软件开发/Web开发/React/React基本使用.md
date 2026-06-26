---
title: "React 基本使用"
weight: 10
date: 2026-06-05
tags: ["Web", "React", "前端", "JSX", "组件"]
---

## 简介

React 是一个声明式，高效且灵活的用于构建用户界面的 JavaScript 库。

使用 React 可以将一些简短、独立的代码片段组合成复杂的 `UI 界面`，这些代码片段被称作`组件`。

React 主要用于构建 UI，很多人认为 React 是 MVC 中的 V（视图）。

React 起源于 Facebook 的内部项目，用来架设 Instagram 的网站，并于 2013 年 5 月开源。

React 拥有较高的性能，代码逻辑非常简单，越来越多的人已开始关注和使用它。

- 特点
    - 声明式设计
        - React采用声明范式，可以轻松描述应用。
    - 高效
        - React通过对DOM的模拟，最大限度地减少与DOM的交互。
    - 灵活
        - React可以与已知的库或框架很好地配合。
    - JSX
        - JSX 是 JavaScript 语法的扩展。React 开发不一定使用 JSX ，但我们建议使用它。
    - 组件
        - 通过 React 构建组件，使得代码更加容易得到复用，能够很好的应用在大项目的开发中。
    - 单向响应的数据流
        - React 实现了单向响应的数据流，从而减少了重复代码，这也是它为什么比传统数据绑定更简单。





- 安装

```react
方法一：在现有html页面中引入
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Add React in One Minute</title>
  </head>
  <body>

    <h2>Add React in One Minute</h2>
    <p>This page demonstrates using React with no build tooling.</p>
    <p>React is loaded as a script tag.</p>

    <!-- We will put our React component inside this div. -->
    <div id="like_button_container"></div>

    <!-- Load React. -->
    <!-- Note: when deploying, replace "development.js" with "production.min.js". -->
    <script src="https://unpkg.com/react@17/umd/react.development.js" crossorigin></script>
    <script src="https://unpkg.com/react-dom@17/umd/react-dom.development.js" crossorigin></script>

    <!-- Load our React component. -->
    <script src="like_button.js"></script>

  </body>
</html>
	

方法二：通过 npm 使用 React
    npm install -g create-react-app
    create-react-app reactdemo

    // 使用create-react-app创建react项目的时候，需要注意，node版本在14.x.x以上
    // 项目名称中不可以出现大写字母，默认监听3000端口
```

默认页面效果如下所示

![image-20220110114322493](https://raw.githubusercontent.com/adcwb/storages/master/image-20220110114322493.png)

## 目录结构

```bash
.
├── node_modules				# 项目依赖包
├── .gitignore					# git忽略文件
├── package.json				# npm 依赖
├── package-lock.json
├── public						# 公共文件
│   ├── favicon.ico
│   ├── index.html
│   ├── logo192.png
│   ├── logo512.png
│   ├── manifest.json
│   └── robots.txt
├── README.md					# 项目说明文件
└── src							# 源码文件，包含项目中所有的组件
    ├── App.css					# 跟组件样式
    ├── App.js					# 根组件
    ├── App.test.js				# 跟组件测试文件
    ├── index.css				# 全局样式
    ├── index.js				# 入口文件
    ├── logo.svg
    ├── reportWebVitals.js
    └── setupTests.js

```

## JSX简介

```jsx
const element = <h1>Hello, world!</h1>;
JSX，是一个 JavaScript 的语法扩展。支持js和html混写

在JSX中嵌入表达式
    const name = 'Josh Perez';
    const element = <h1>Hello, {name}</h1>;

    ReactDOM.render(
      element,
      document.getElementById('root')
    );


在 JSX 语法中，你可以在大括号内放置任何有效的 JavaScript 表达式。
例如，2 + 2，user.firstName 或 formatName(user) 都是有效的 JavaScript 表达式。
可以在 if 语句和 for 循环的代码块中使用 JSX，将 JSX 赋值给变量，把 JSX 当作参数传入，以及从函数中返回 JSX：
    function formatName(user) {
      return user.firstName + ' ' + user.lastName;
    }

    const user = {
      firstName: 'Harper',
      lastName: 'Perez'
    };

    const element = (
      <h1>
        Hello, {formatName(user)}!
      </h1>
    );

	function getGreeting(user) {
      if (user) {
        return <h1>Hello, {formatName(user)}!</h1>;
      }
      return <h1>Hello, Stranger.</h1>;
    }

    ReactDOM.render(
      element,
      getGreeting,
      document.getElementById('root')
    );

JSX 中指定属性
	你可以通过使用引号，来将属性值指定为字符串字面量：
    	const element = <a href="https://www.reactjs.org"> link </a>;
    也可以使用大括号，来在属性值中插入一个JavaScript表达式：
		const element = <img src={user.avatarUrl}></img>;

	在属性中嵌入 JavaScript 表达式时，不要在大括号外面加上引号。你应该仅使用引号（对于字符串值）或大括号（对于表达式）中的一个，对于同一属性不能同时使用这两种符号。
    因为 JSX 语法上更接近 JavaScript 而不是 HTML，所以 React DOM 使用 camelCase（小驼峰命名）来定义属性的名称，而不使用 HTML 属性名称的命名约定。
	例如，JSX 里的 class 变成了 className，而 tabindex 则变为 tabIndex。


使用 JSX 指定子元素
	假如一个标签里面没有内容，你可以使用 /> 来闭合标签，就像 XML 语法一样：
    	const element = <img src={user.avatarUrl} />;
	JSX 标签里能够包含很多子元素:
		const element = (
              <div>
                <h1>Hello!</h1>
                <h2>Good to see you here.</h2>
              </div>
            );

JSX 防止注入攻击
	你可以安全地在 JSX 当中插入用户输入内容：
		const title = response.potentiallyMaliciousInput;
        // 直接使用是安全的：
        const element = <h1>{title}</h1>;
	React DOM 在渲染所有输入内容之前，默认会进行转义。它可以确保在你的应用中，永远不会注入那些并非自己明确编写的内容。所有的内容在渲染之前都被转换成了字符串。这样可以有效地防止 XSS（cross-site-scripting, 跨站脚本）攻击。


JSX 表示对象
	Babel 会把 JSX 转译成一个名为 React.createElement() 函数调用。
    以下两种示例代码完全等效：
		const element = (
          <h1 className="greeting">
            Hello, world!
          </h1>
        );
		
        const element = React.createElement(
          'h1',
          {className: 'greeting'},
          'Hello, world!'
        );

	React.createElement() 会预先执行一些检查，以帮助你编写无错代码，但实际上它创建了一个这样的对象：
        // 注意：这是简化过的结构
        const element = {
          type: 'h1',
          props: {
            className: 'greeting',
            children: 'Hello, world!'
          }
        };

	这些对象被称为 “React 元素”。它们描述了你希望在屏幕上看到的内容。React 通过读取这些对象，然后使用它们来构建 DOM 以及保持随时更新。
    
    

```



## 元素渲染

```jsx
元素是构成React应用的最小块，他描述了你在屏幕上想看到的内容
	const element = <h1>Hello, world</h1>;
	与浏览器的 DOM 元素不同，React 元素是创建开销极小的普通对象。React DOM 会负责更新 DOM 来与 React 元素保持一致。
    
将一个元素渲染为DOM
	假设你的 HTML 文件某处有一个 <div>：
		<div id="root"></div>
	我们将其称为“根” DOM 节点，因为该节点内的所有内容都将由 React DOM 管理。

	仅使用 React 构建的应用通常只有单一的根 DOM 节点。如果你在将 React 集成进一个已有应用，那么你可以在应用中包含任意多的独立根 DOM 节点。

	想要将一个 React 元素渲染到根 DOM 节点中，只需把它们一起传入 ReactDOM.render()：
        const element = <h1>Hello, world</h1>;
        ReactDOM.render(element, document.getElementById('root'));



更新已渲染的元素
	React 元素是不可变对象。一旦被创建，你就无法更改它的子元素或者属性。一个元素就像电影的单帧：它代表了某个特定时刻的 UI。
	根据我们已有的知识，更新 UI 唯一的方式是创建一个全新的元素，并将其传入 ReactDOM.render()。
        function tick() {
          const element = (
            <div>
              <h1>Hello, world!</h1>
              <h2>It is {new Date().toLocaleTimeString()}.</h2>
            </div>
          );
          ReactDOM.render(element, document.getElementById('root'));
        }

        setInterval(tick, 1000);
	这个例子会在 setInterval() 回调函数，每秒都调用 ReactDOM.render()。
    在实践中，大多数 React 应用只会调用一次 ReactDOM.render()。
    React 只更新它需要更新的部分
	React DOM 会将元素和它的子元素与它们之前的状态进行比较，并只会进行必要的更新来使 DOM 达到预期的状态。
```





## 组件创建

```bash
调整项目目录结构
    src
    ├── App.js
    ├── App.test.js
    ├── assets				# 静态资源存放目录
    │   ├── css				
    │   │   ├── App.css
    │   │   └── index.css
    │   └── images
    │       └── logo.svg
    ├── components			# 组件存放目录
    ├── index.js
    ├── reportWebVitals.js
    └── setupTests.js

	组件，从概念上类似于 JavaScript 函数。它接受任意的入参（即 “props”），并返回用于描述页面展示内容的 React 元素。
	组件允许你将 UI 拆分为独立可复用的代码片段，并对每个片段进行独立构思。
```



### 新建组件

```react
// 在components目录下创建Home组件，组件名称的首字母必须大写

// 组件的创建必须继承React.Component
import React from 'react';


class Home extends React.Component {
    // 构造函数，props用于父子组件之间传值，固定写即可
    // Es6中的super可以用在类的继承中，super关键字，它指代父类的实例（即父类的this对象）。子类必须在constructor方法中调用super方法，否则新建实例时会报错。这是因为子类没有自己的this对象，而是继承父类的this对象，然后对其进行加工。如果不调用super方法，子类就得不到this对象。
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div>
                <h1>这是Home组件</h1>
            </div>
        )
    }
}

export default Home;
```



### 函数组件与class组件

```JSX
定义组件最简单的方式就是编写 JavaScript 函数：
    function Welcome(props) {
      return <h1>Hello, {props.name}</h1>;
    }

该函数是一个有效的 React 组件，因为它接收唯一带有数据的 “props”（代表属性）对象与并返回一个 React 元素。这类组件被称为“函数组件”，因为它本质上就是 JavaScript 函数。

你同时还可以使用 ES6 的 class 来定义组件：
    class Welcome extends React.Component {
      render() {
        return <h1>Hello, {this.props.name}</h1>;
      }
    }
上述两个组件在 React 里是等效的。

```



### 渲染组件

```jsx
	当 React 元素为用户自定义组件时，它会将 JSX 所接收的属性（attributes）以及子组件（children）转换为单个对象传递给组件，这个对象被称之为 “props”。
    function Welcome(props) {
      return <h1>Hello, {props.name}</h1>;
    }

    const element = <Welcome name="Sara" />;
    ReactDOM.render(
      element,
      document.getElementById('root')
    );
    这段代码会在页面上渲染 “Hello, Sara”：

详细解析：
	我们调用 ReactDOM.render() 函数，并传入 <Welcome name="Sara" /> 作为参数。
    React 调用 Welcome 组件，并将 {name: 'Sara'} 作为 props 传入。
    Welcome 组件将 <h1>Hello, Sara</h1> 元素作为返回值。
    React DOM 将 DOM 高效地更新为 <h1>Hello, Sara</h1>。

注意： 组件名称必须以大写字母开头。
	React 会将以小写字母开头的组件视为原生 DOM 标签。例如，<div /> 代表 HTML 的 div 标签，而 <Welcome /> 则代表一个组件，并且需在作用域内使用 Welcome。
```



### 组合组件

```JSX
	组件可以在其输出中引用其他组件。这就可以让我们用同一组件来抽象出任意层次的细节。按钮，表单，对话框，甚至整个屏幕的内容：在 React 应用程序中，这些通常都会以组件的形式表示。

例如，我们可以创建一个可以多次渲染 Welcome 组件的 App 组件：
    function Welcome(props) {
      return <h1>Hello, {props.name}</h1>;
    }

    function App() {
      return (
        <div>
          <Welcome name="Sara" />
          <Welcome name="Cahal" />
          <Welcome name="Edite" />
        </div>
      );
    }

    ReactDOM.render(
      <App />,
      document.getElementById('root')
    );

	通常来说，每个新的 React 应用程序的顶层组件都是 App 组件。但是，如果你将 React 集成到现有的应用程序中，你可能需要使用像 Button 这样的小组件，并自下而上地将这类组件逐步应用到视图层的每一处。
```

### 提取组件

```jsx
将组件拆分为更小的组件。

例如，参考如下 Comment 组件：
拆分前：
    function Comment(props) {
      return (
        <div className="Comment">
          <div className="UserInfo">
            <img className="Avatar"
              src={props.author.avatarUrl}
              alt={props.author.name}
            />
            <div className="UserInfo-name">
              {props.author.name}
            </div>
          </div>
          <div className="Comment-text">
            {props.text}
          </div>
          <div className="Comment-date">
            {formatDate(props.date)}
          </div>
        </div>
      );
    }


拆分后：
    function formatDate(date) {
      return date.toLocaleDateString();
    }

    function Comment(props) {
      return (
        <div className="Comment">
          <div className="UserInfo">
            <img
              className="Avatar"
              src={props.author.avatarUrl}
              alt={props.author.name}
            />
            <div className="UserInfo-name">
              {props.author.name}
            </div>
          </div>
          <div className="Comment-text">{props.text}</div>
          <div className="Comment-date">
            {formatDate(props.date)}
          </div>
        </div>
      );
    }

    const comment = {
      date: new Date(),
      text: 'I hope you enjoy learning React!',
      author: {
        name: 'Hello Kitty',
        avatarUrl: 'https://placekitten.com/g/64/64',
      },
    };
    ReactDOM.render(
      <Comment
        date={comment.date}
        text={comment.text}
        author={comment.author}
      />,
      document.getElementById('root')
    );

	最初看上去，提取组件可能是一件繁重的工作，但是，在大型应用中，构建可复用组件库是完全值得的。根据经验来看，如果 UI 中有一部分被多次使用（Button，Panel，Avatar），或者组件本身就足够复杂（App，FeedStory，Comment），那么它就是一个可提取出独立组件的候选项。
```

### Props 的只读性

```JSX
组件无论是使用函数声明还是通过 class 声明，都决不能修改自身的 props。
    function sum(a, b) {
      return a + b;
    }
这样的函数被称为“纯函数”，因为该函数不会尝试更改入参，且多次调用下相同的入参始终返回相同的结果。
	相反，下面这个函数则不是纯函数，因为它更改了自己的入参：
		function withdraw(account, amount) {
          account.total -= amount;
        }

	React 非常灵活，但它也有一个严格的规则：
	所有 React 组件都必须像纯函数一样保护它们的 props 不被更改。
	当然，应用程序的 UI 是动态的，并会伴随着时间的推移而变化。在下一章节中，我们将介绍一种新的概念，称之为 “state”。在不违反上述规则的情况下，state 允许 React 组件随用户操作、网络响应或者其他变化而动态更改输出内容。
```



### 绑定数据

```react
import React from 'react';

/*
react绑定属性注意：
    class要换成className
    for要换成 htmlFor
    style:
        <div style={{"color":'red'}}>我是一个红的的 div  行内样式</div>
    其他的属性和以前写法是一样的
*/
class Home extends React.Component {
    constructor(props) {
        // 子类必须在constructor方法中调用super方法，否则新建实例时会报错。这是因为子类没有自己的this对象，
        // 而是继承父类的this对象，然后对其进行加工。如果不调用super方法，子类就得不到this对象
        super(props);
        this.state = {
            msg: "这是Home组件",
            title: "这是一个title",
            color: "red",
            style: {
                color: 'red',
                fontSize: '40px'
            },

            data: {
                name: '小星星',
                age: 18,
                sex: '男',
                messageData: ['aaa', 'bbb', 'ccc']
            }

        }
    }

    render() {
        let listResulr = this.state.data.messageData.map(function (value, key) {
            return <li key={key}> {value} </li>
        })
        return (
            <div>
                <h1>{this.state.msg}</h1>
                <hr/>
                <div title={this.state.title}>绑定title</div>
                <hr/>
                <div id='box' className={this.state.color}>绑定class</div>
                <hr/>
                <div style={this.state.style}>绑定style</div>
                <hr/>
                <p>绑定对象--{this.state.data.name}</p>
                <hr/>
                <ul>
                    {listResulr}
                </ul>
                <hr/>
            </div>
        )
    }
}

export default Home;
```



### 约束性组件与非约束性组件

```JSX
非约束性组:
	<input type="text" defaultValue="a" />   这个 defaultValue 其实就是原生DOM中的 value 属性。
	这样写出的来的组件，其value值就是用户输入的内容，React完全不管理输入的过程。

约束性组件：
    <input value={this.state.username} type="text" onChange={this.handleUsername}  /> 
    这里，value属性不再是一个写死的值，他是 this.state.username, this.state.username 是由 this.handleChange 负责管理的。
	这个时候实际上 input 的 value 根本不是用户输入的内容。而是onChange 事件触发之后，由于 this.setState 导致了一次重新渲染。不过React会优化这个渲染过程。看上去有点类似双休数据绑定

```





## State & 生命周期

```jsx
	在具有许多组件的应用程序中，当组件被销毁时释放所占用的资源是非常重要的。

	当 Clock 组件第一次被渲染到 DOM 中的时候，就为其设置一个计时器。这在 React 中被称为“挂载（mount）”。

	同时，当 DOM 中 Clock 组件被删除的时候，应该清除计时器。这在 React 中被称为“卸载（unmount）”。

	我们可以为 class 组件声明一些特殊的方法，当组件挂载或卸载时就会去执行这些方法，这些方法叫做“生命周期方法”。
	componentDidMount() 方法会在组件已经被渲染到 DOM 中后运行，所以，最好在这里设置计时器：
		  componentDidMount() {
            this.timerID = setInterval(
              () => this.tick(),
              1000
            );
          }

    接下来把计时器的 ID 保存在 this 之中（this.timerID）。

    尽管 this.props 和 this.state 是 React 本身设置的，且都拥有特殊的含义，但是其实你可以向 class 中随意添加不参与数据流（比如计时器 ID）的额外字段。

    我们会在 componentWillUnmount() 生命周期方法中清除计时器：
        componentWillUnmount() {
            clearInterval(this.timerID);
        }

    最后，我们会实现一个叫 tick() 的方法，Clock 组件每秒都会调用它。

    使用 this.setState() 来时刻更新组件 state：
        class Clock extends React.Component {
          constructor(props) {
            super(props);
            this.state = {date: new Date()};
          }

          componentDidMount() {
            this.timerID = setInterval(
              () => this.tick(),
              1000
            );
          }

          componentWillUnmount() {
            clearInterval(this.timerID);
          }

          tick() {
            this.setState({
              date: new Date()
            });
          }

          render() {
            return (
              <div>
                <h1>Hello, world!</h1>
                <h2>It is {this.state.date.toLocaleTimeString()}.</h2>
              </div>
            );
          }
        }

        ReactDOM.render(
          <Clock />,
          document.getElementById('root')
        );

调用顺序：

	当 <Clock /> 被传给 ReactDOM.render()的时候，React 会调用 Clock 组件的构造函数。因为 Clock 需要显示当前的时间，所以它会用一个包含当前时间的对象来初始化 this.state。我们会在之后更新 state。
    
	之后 React 会调用组件的 render() 方法。这就是 React 确定该在页面上展示什么的方式。然后 React 更新 DOM 来匹配 Clock 渲染的输出。
    
	当 Clock 的输出被插入到 DOM 中后，React 就会调用 ComponentDidMount() 生命周期方法。在这个方法中，Clock 组件向浏览器请求设置一个计时器来每秒调用一次组件的 tick() 方法。
    
	浏览器每秒都会调用一次 tick() 方法。 在这方法之中，Clock 组件会通过调用 setState() 来计划进行一次 UI 更新。得益于 setState() 的调用，React 能够知道 state 已经改变了，然后会重新调用 render() 方法来确定页面上该显示什么。这一次，render() 方法中的 this.state.date 就不一样了，如此一来就会渲染输出更新过的时间。React 也会相应的更新 DOM。
    
	一旦 Clock 组件从 DOM 中被移除，React 就会调用 componentWillUnmount() 生命周期方法，这样计时器就停止了。

```

### 正确地使用 State

```jsx
不要直接修改State
	此代码不会重新渲染组件：
		this.state.comment = 'Hello';
	应该使用 setState():
    	this.setState({comment: 'Hello'});
	构造函数是唯一可以给 this.state 赋值的地方。

    
State的更新可能是异步的
	出于性能考虑，React可能会把多个setState()调用合并成一个调用。
	因为this.props和this.state可能会异步更新，所以你不要依赖他们的值来更新下一个状态。
	此代码可能会无法更新计数器：
        this.setState({
          counter: this.state.counter + this.props.increment,
        });
	要解决这个问题，可以让 setState() 接收一个函数而不是一个对象。这个函数用上一个 state 作为第一个参数，将此次更新被应用时的 props 做为第二个参数：
        this.setState((state, props) => ({
          counter: state.counter + props.increment
        }));
	上面使用了箭头函数，不过使用普通的函数也同样可以：
        this.setState(function(state, props) {
          return {
            counter: state.counter + props.increment
          };
        });


State的更新会被合并
	当调用 setState() 的时候，React 会把你提供的对象合并到当前的 state
    例如，state 包含几个独立的变量：
    	  constructor(props) {
            super(props);
            this.state = {
              posts: [],
              comments: []
            };
          }
	可以分别调用 setState() 来单独地更新它们：
    	  componentDidMount() {
            fetchPosts().then(response => {
              this.setState({
                posts: response.posts
              });
            });

            fetchComments().then(response => {
              this.setState({
                comments: response.comments
              });
            });
          }
	这里的合并是浅合并，所以 this.setState({comments}) 完整保留了 this.state.posts， 但是完全替换了 this.state.comments。


数据是向下流动的：
	不管是父组件或是子组件都无法知道某个组件是有状态的还是无状态的，并且它们也并不关心它是函数组件还是 class组件。
	这就是为什么称state为局部的或是封装的的原因。除了拥有并设置了它的组件，其他组件都无法访问。
	组件可以选择把它的state作为props向下传递到它的子组件中：
    	<FormattedDate date={this.state.date} />
		FormattedDate组件会在其props中接收参数date，但是组件本身无法知道它是来自于Clock的state，或是Clock的props，还是手动输入的：
		function FormattedDate(props) {
          return <h2>It is {props.date.toLocaleTimeString()}.</h2>;
        }

这通常会被叫做“自上而下”或是“单向”的数据流。任何的 state 总是所属于特定的组件，而且从该 state 派生的任何数据或 UI 只能影响树中“低于”它们的组件。

如果你把一个以组件构成的树想象成一个 props 的数据瀑布的话，那么每一个组件的 state 就像是在任意一点上给瀑布增加额外的水源，但是它只能向下流动。

为了证明每个组件都是真正独立的，我们可以创建一个渲染三个 Clock 的 App 组件：
	function App() {
      return (
        <div>
          <Clock />
          <Clock />
          <Clock />
        </div>
      );
    }

    ReactDOM.render(
      <App />,
      document.getElementById('root')
    );


每个 Clock 组件都会单独设置它自己的计时器并且更新它。

在 React 应用中，组件是有状态组件还是无状态组件属于组件实现的细节，它可能会随着时间的推移而改变。你可以在有状态的组件中使用无状态的组件，反之亦然。
```



## 事件处理

React 元素的事件处理和 DOM 元素的很相似，但是有一点语法上的不同：

- React 事件的命名采用小驼峰式（camelCase），而不是纯小写。
- 使用 JSX 语法时你需要传入一个函数作为事件处理函数，而不是一个字符串。

```JSX
// 传统的HTML
<button onclick="activateLasers()">
  Activate Lasers
</button>

// React
<button onClick={activateLasers}>
  Activate Lasers
</button>

	在React中另一个不同点是你不能通过返回false的方式阻止默认行为。你必须显式的使用 preventDefault。例如，传统的HTML中阻止表单的默认提交行为，可以这样写：
    <form onsubmit="console.log('You clicked submit.'); return false">
      <button type="submit">Submit</button>
    </form>
	在react中，需要这样写
    	function Form() {
          function handleSubmit(e) {
            e.preventDefault();
            console.log('You clicked submit.');
          }

          return (
            <form onSubmit={handleSubmit}>
              <button type="submit">Submit</button>
            </form>
          );
        }
	此处的e是一个合成事件
    使用 React 时，你一般不需要使用 addEventListener 为已创建的 DOM 元素添加监听器。事实上，你只需要在该元素初始渲染的时候添加监听器即可。

	当你使用 ES6 class语法定义一个组件的时候，通常的做法是将事件处理函数声明为class中的方法。例如，下面的Toggle组件会渲染一个让用户切换开关状态的按钮：
```

### this的三种用法

```jsx
方法一：箭头函数
	run = ()=> {
        alert(this.state.name)
    }
    
    
方式二：构造函数中改变
    // 为了在回调中使用 `this`，这个绑定是必不可少的
    this.handleClick = this.handleClick.bind(this);
	

方式三：事件中绑定
	run() {
        alert(this.state.data.name)
    }
	<button onClick={this.run.bind(this)}>按钮</button>


```



### 事件对象

```jsx
事件对象:
	在触发DOM上的某个事件时,会产生一个事件对象event。这个对象中包含着所有与事件有关的信息

        run=(event)=>{
            // console.log(event);
            // alert(event.target);   /*获取执行事件的dom节点*/
            event.target.style.background='red';	/* 设置背景颜色为红色*/

            //获取dom的属性
            alert(event.target.getAttribute('aid'))
        }
    
        render(){
            return(
                <div>              
                   {/* 事件对象 */}	// 
                   <button aid="123" onClick={this.run}>事件对象</button>
                </div>
            )
        }
```

### 键盘事件

```jsx
onkeydown	某个键盘按键被按下。
onkeypress	某个键盘按键被按下并松开。
onkeyup		某个键盘按键被松开。

	this.setState({
            username:val
    })

    //键盘事件
    inputKeyUp=(e)=>{
        if(e.keyCode==13){
            alert(e.target.value);
        }
    }
    
    inputonKeyDown=(e)=>{
        if(e.keyCode==13){
            alert(e.target.value);
        }
    }

<input onKeyUp={this.inputKeyUp}/>
<input onKeyDown={this.inputonKeyDown}/>
```



### ref获取DOM

```jsx
	getInput=()=>{
        alert(this.state.username);
    }
    
	inputChange=()=>{
        /*
            获取dom节点
                1、给元素定义ref属性
                    <input ref="username" />
                2、通过this.refs.username 获取dom节点

        */

        let val=this.refs.username.value;
        this.setState({
            username:val
        })
    }
    
    <input ref="username" onChange={this.inputChange}/> 
	<button onClick={this.getInput}>获取input的值</button>
    
    
```





### 表单事件

```jsx
获取表单的值：
    1、监听表单的改变事件                         onChange
    2、在改变的事件里面获取表单输入的值             事件对象
    3、把表单输入的值赋值给username               this.setState({})
    4、点击按钮的时候获取 state里面的username      this.state.username
	
	constructor(props){
        super(props);   //固定写法
        this.state={
            username:''
        }
    }
	// 事件
	getInput=()=>{
        alert(this.state.username);
    }
    
    inputChange=(e)=>{
        //获取表单的值
        console.log(e.target.value);
        this.setState({
            username:e.target.value
        })
    }

	// render
	<input onChange={this.inputChange}/> 
    <button onClick={this.getInput}>获取input的值</button>
                
```



### 双向数据绑定

```jsx
inputChange=(e)=>{
    this.setState({
        username:e.target.value
    })
}

setUsername=()=>{
    this.setState({
        username:'李四'
    })
}

<input  value={this.state.username} onChange={this.inputChange}/> 
<p> {this.state.username}</p>           
<button onClick={this.setUsername}>改变username的值</button>


```



### 获取表单数据

```jsx
import React, { Component } from 'react';


class ReactForm extends Component {
    constructor(props) {
        super(props);
        this.state = {

            msg:"react表单",
            name:'',
            sex:'1',
            city:'',
            citys:[

                '北京','上海','深圳'
            ],
            hobby:[
                {
                    'title':"睡觉",
                    'checked':true
                },
                {
                    'title':"吃饭",
                    'checked':false
                },
                {
                    'title':"敲代码",
                    'checked':true
                }
            ],
            info:''

        };

        this.handleInfo=this.handleInfo.bind(this);
    }
    
    handelSubmit=(e)=>{
        //阻止submit的提交事件
        e.preventDefault();
        console.log(this.state.name,this.state.sex,this.state.city,this.state.hobby,this.state.info);
    }
    handelName=(e)=>{
        this.setState({
            name:e.target.value
        })
    }

    handelSex=(e)=>{
        this.setState({
            sex: e.target.value
        })
    }

    handelCity=(e)=>{
        this.setState({
            city:e.target.value
        })
    }
    
    handelHobby=(key)=>{
        var hobby=this.state.hobby;
        hobby[key].checked=!hobby[key].checked;
        this.setState({
            hobby:hobby
        })
    }

    handleInfo(e){
        this.setState({
            info:e.target.value
        })
    }
    
    render() {
        return (
            <div>
                <h2>{this.state.msg}</h2>
                <form onSubmit={this.handelSubmit}>
                    用户名:  <input type="text" value={this.state.name}  onChange={this.handelName}/> <br /><br />
                    性别:    <input type="radio" value="1" checked={this.state.sex==1}  onChange={this.handelSex}/>男
                    <input type="radio"  value="2" checked={this.state.sex==2}  onChange={this.handelSex}/>女 <br /><br />
                    居住城市:
                    <select value={this.state.city} onChange={this.handelCity}>
                        {
                            this.state.citys.map(function(value,key){
                                return <option key={key}>{value}</option>
                            })
                        }

                    </select>
                    <br /><br />
                    爱好:
                    {
                        // 注意this指向
                        this.state.hobby.map((value,key)=>{
                            return (
                                <span key={key}>
                                    <input type="checkbox"  checked={value.checked}  onChange={this.handelHobby.bind(this,key)}/> {value.title}
                               </span>
                            )
                        })
                    }
                    <br /><br />
                    备注：<textarea vlaue={this.state.info}  onChange={this.handleInfo} />
                    <input type="submit"  defaultValue="提交"/>
                    <br /><br /> <br /><br />
                </form>
            </div>
        );
    }
}

export default ReactForm;

```

















## 条件渲染

在 React 中，你可以创建不同的组件来封装各种你需要的行为。然后，依据应用的不同状态，你可以只渲染对应状态下的部分内容。

React 中的条件渲染和 JavaScript 中的一样，使用 JavaScript 运算符 `if` 或者`条件运算符`去创建元素来表现当前的状态，然后让 React 根据它们来更新 UI。







## 请求数据

### Axios

- 安装

```bash
Using npm:
$ npm install axios

Using bower:
$ bower install axios

Using yarn:
$ yarn add axios
```

- 使用

```jsx
import axios from 'axios';
或
const axios = require('axios');


axios.get('/user', {
    params: {
      ID: 12345
    }
  })
  .then(function (response) {
    console.log(response);
  })
  .catch(function (error) {
    console.log(error);
  })
  .then(function () {
    // always executed
  });  

```



### fetchJsonp

```jsx
/*
react获取服务器APi接口的数据：
    react中没有提供专门的请求数据的模块。但是我们可以使用任何第三方请求数据模块实现请求数据

    1、axios          https://github.com/axios/axios       axios的作者觉得jsonp不太友好，推荐用CORS方式更为干净（后端运行跨域）

          1、安装axios模块npm install axios  --save   /  npm install axios  --save

          2、在哪里使用就在哪里引入import axios from 'axios'

          3、看文档使用

            var api='http://www.phonegap100.com/appapi.php?a=getPortalList&catid=20';

            axios.get(api)
            .then(function (response) {
                console.log(response);
            })
            .catch(function (error) {
                console.log(error);
            });



    2、fetch-jsonp    https://github.com/camsong/fetch-jsonp

            1、安装 npm install fetch-jsonp  --save

            2、import fetchJsonp from 'fetch-jsonp'

            3、看文档使用

            fetchJsonp('/users.jsonp')
            .then(function(response) {
              return response.json()
            }).then(function(json) {
              console.log('parsed json', json)
            }).catch(function(ex) {
              console.log('parsing failed', ex)
            })


    3、其他请求数据的方法也可以...自己封装模块用原生js实现数据请求也可以...




远程测试API接口：


get请求：

    http://www.phonegap100.com/appapi.php?a=getPortalList&catid=20


jsonp请求地址:

    http://www.phonegap100.com/appapi.php?a=getPortalList&catid=20&callback=?

  

*/

import React, { Component } from 'react';


import fetchJsonp from 'fetch-jsonp';


class FetchJsonp extends Component {
    constructor(props) {
        super(props);
        this.state = {

            list:[]
        };
    }

    getData=()=>{

         //获取数据

        var api="http://www.phonegap100.com/appapi.php?a=getPortalList&catid=20";
        fetchJsonp(api)
        .then(function(response) {
            return response.json()
        }).then((json)=> {
            // console.log(json);
            
            this.setState({

                list:json.result
            })

        }).catch(function(ex) {
            console.log('parsing failed', ex)
        })
    }
    render() {
        return (

            <div>


                <h2>FetchJsonp 获取服务器jsonp接口的数据</h2>

                <button onClick={this.getData}>获取服务器api接口数据</button>

                <hr />

                <ul>
                    
                    {

                        this.state.list.map((value,key)=>{

                            return <li key={key}>{value.title}</li>
                        })
                    }   

                    
                </ul>

            </div>
            
        );
    }
}

export default FetchJsonp;
```

## 父子组件传值

```jsx
React中的组件: 
	解决html 标签构建应用的不足。

使用组件的好处：
	把公共的功能单独抽离成一个文件作为一个组件，哪里里使用哪里引入。



父子组件：
	组件的相互调用中，我们把调用者称为父组件，被调用者称为子组件



父子组件传值：
    父组件给子组件传值 
		1.在调用子组件的时候定义一个属性  <Header msg='首页'></Header>
		2.子组件里面 this.props.msg          

    说明：父组件不仅可以给子组件传值，还可以给子组件传方法,以及把整个父组件传给子组件。

    父组件主动获取子组件的数据
        1、调用子组件的时候指定ref的值   <Header ref='header'></Header>      
        2、通过this.refs.header  获取整个子组件实例

```

`Home` 组件

```JSX
import Header from './Header';

class Home extends Component {

    constructor(props){
        super(props);        
        this.state={
          msg:'我是一个首页组件',
          title:'首页组件'
        }
    }
    render() {
      return (
        <div>
            <Header title={this.state.title} />
            这是首页组件的内容
        </div>
      );
    }
  }
  
  export default Home;
```



`Header` 组件

```jsx
import React, { Component } from 'react';

class Header extends Component{

    constructor(props){
            super(props);
            this.state={
                msg:'这是一个头部组件'
            }
    }

    getNews=()=>{
            // alert(this.props.news.state.msg);
            this.props.news.getData();
    }

    render(){
        return(
            <div>
                <h2>{this.props.title}</h2>
                <button onClick={this.props.run}>调用news父组件的run方法</button>
                <button onClick={this.props.news.getData}>
                    获取news组件的getData方法
                </button>
                <button onClick={this.getNews}>获取整个news组件实例</button>
                <button onClick={this.props.news.getChildData.bind(this,'我是子组件的数据')}>子组件给父组件传值</button>
            </div>
        )
    }
}

export default Header;
```



`News` 组件

```JSX
import React, { Component } from 'react';
import Header from './Header';
import Footer from './Footer';

class News extends Component {

    constructor(props){
        super(props);        
        this.state={          
          title:'新闻组件',
          msg:'我是新闻组件的msg'
        }
    }

    run=()=>{
      alert('我是父组件的run方法')
    }


    // 获取子组件里面穿过来的数据

    getChildData=(result)=>{
      alert(result);
      this.setState({
        msg:result
      })
    }


    getData=()=>{
      alert(this.state.title+'getData');
    }


    //父组件主动调用子组件的数据和方法
    getFooter=()=>{


      /*
        父组件主动获取子组件的数据

          1、调用子组件的时候指定ref的值 <Header ref='header'></Header>      
          
          2、通过this.refs.header  获取整个子组件实例  (dom（组件）加载完成以后获取 )
      */

      //alert(this.refs.footer.state.msg); //获取子组件的数据

      this.refs.footer.run();

    }
    render() {
      return (
        <div>
            <Header title={this.state.title}  run={this.run}  news={this} />
            这是新闻组件的内容---{this.state.msg}
             <button onClick={this.getFooter}>获取整个底部组件</button>
          <Footer  ref='footer'/>
        </div>
      );
    }
  }
  
  export default News;
  
```

`App` 组件

```jsx
import React, { Component } from 'react';
import Home from './components/Home.js';
import News from './components/News.js';

class App extends Component {

  render() {
    return (
      <div className="App">
         <Home />
         <News />
      </div>
    );
  }
}

export default App;
```

### PropTypes

```jsx
import React, { Component } from 'react';


/*
父组件给子组件传值：


    defaultProps:父子组件传值中，如果父组件调用子组件的时候不给子组件传值，可以在子组件中使用defaultProps定义的默认值

    propTypes：验证父组件传值的类型合法性

            1、引入import PropTypes from 'prop-types';

            2、类.propTypes = {
                name: PropTypes.string
            };


    都是定义在子组件里面


https://reactjs.org/docs/typechecking-with-proptypes.html


*/




import PropTypes from 'prop-types';


class Header extends Component {
    constructor(props) {
        super(props);
        this.state = { 

            msg:"我是一个头部组件"
         };
    }
    render() {
        return (
            <div>
                <h2>---{this.props.title}--- {this.props.num}</h2>
            </div>
        );
    }
}

//defaultProps   如果父组件调用子组件的时候不给子组件传值，可以在子组件中使用defaultProps定义的默认值
Header.defaultProps={

    title:'标题'
}

//同行propTypes定义父组件给子组件传值的类型

Header.propTypes={

    num:PropTypes.number
}


export default Header;
```







## 路由组件

在线 Gitbook 地址：http://react-guide.github.io/react-router-cn/

英文原版：https://github.com/rackt/react-router/tree/master/docs

React Router 是完整的 React 路由解决方案

React Router 保持 UI 与 URL 同步。它拥有简单的 API 与强大的功能例如代码缓冲加载、动态路由匹配、以及建立正确的位置过渡处理。你第一个念头想到的应该是 URL，而不是事后再想起。



### 安装

使用yarn安装

```BASH
$ yarn add react-router-dom@6
yarn add v1.22.17
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
warning " > react-router@6.2.1" has unmet peer dependency "react@>=16.8".
[4/4] Building fresh packages...

success Saved lockfile.
success Saved 4 new dependencies.
info Direct dependencies
└─ react-router@6.2.1
info All dependencies
├─ @babel/runtime@7.16.7
├─ history@5.2.0
├─ react-router@6.2.1
└─ regenerator-runtime@0.13.9
Done in 2.55s.

```

使用npm安装

```BASH
$ npm install --save react-router-dom@6
```



### 基本使用

```JSX
// 在需要使用路由的组件中引入路由以及子组件
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
import Home from './components/Home';
import News from './components/News';
import Product from './components/Product';

class App extends Component {
  render() {
    return (
        <Router>
          <div>           
              <header className="title">
                <Link to="/">首页</Link>
                <Link to="/news">新闻</Link>
                <Link to="/product">商品</Link>
              </header>
              <hr />
              {/* exact表示严格匹配 */}
              <Route exact path="/" component={Home} />
              <Route path="/news" component={News} />    
              <Route path="/product" component={Product} />                 
          </div>
      </Router>
    );
  }
}

export default App;
```



### 动态路由配置

```JSX
import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Link } from "react-router-dom";

import './assets/css/index.css'
import Content from './components/Content';
import ProductContent from './components/ProductContent';

class App extends Component {
  render() {
    return (
        <Router>
          <div>           
              <Route path="/content/:aid" component={Content} />                 
          </div>
      </Router>
    );
  }
}

export default App;
```

`Content`组件

```JSX
import React, { Component } from 'react';


class Content extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    // 生命周期函数
    componentDidMount(){
        // 获取动态路由的传值
        console.log(this.props.match.params.aid);  

    }
    render() {
        return (
            <div>
                我是新闻详情组件
            </div>
        );
    }
}

export default Content;
```



### js跳转路由

```jsx
/*

实现js跳转路由：https://reacttraining.com/react-router/web/example/auth-workflow

1、要引入Redirect
	import {Redirect} from "react-router-dom";

2、定义一个flag
        this.state = { 
                loginFlag:false            
        };

3、render里面判断flag 来决定是否跳转
        if (this.state.loginFlag) {
            return <Redirect to={{ pathname: "/" }} />;
        }

4、要执行js跳转
        通过js改变loginFlag的状态
        改变以后从新render 就可以通过Redirect自己来跳转
*/

import React, { Component } from 'react';

import {Redirect} from "react-router-dom";


class Login extends Component {
    constructor(props) {
        super(props);
        this.state = { 
            loginFlag:false            
        };
    }

    doLogin=(e)=>{
        e.preventDefault();
        let username=this.refs.username.value;
        let password=this.refs.password.value;
        console.log(username,password)

        if (username==='admin' && password==='123456') {
            //登录成功   跳转到首页
            this.setState({
                loginFlag:true
            })
        } else {
            alert('登录失败')
        }
    }
    
    render() {
        
        if (this.state.loginFlag) {
            // return <Redirect to={{ pathname: "/" }} />;
            return <Redirect to='/' />;
        }
        
        return (
            <div>
                <form onSubmit={this.doLogin}>
                        <input type="text"  ref="username" />
                        <input type="password"  ref="password" />
                        <input type="submit"  value="执行登录"/>
                </form>
            </div>
        );
    }
}

export default Login;
```



### 路由组件的嵌套

```JSX
import React, { Component } from 'react';

import { BrowserRouter as Router, Route, Link } from "react-router-dom";

import Info from './User/Info';
import Main from './User/Main';

class User extends Component {
    constructor(props) {
        super(props);
        this.state = {
            msg:'我是一个User组件'
        };
    }
    
    render() {
        return (
            <div className="user">
                <div className="content">
                    <div className="left">
                        <Link to="/user/">个人中心</Link>
                        <Link to="/user/info">用户信息</Link>
                    </div>

                    <div className="right">
                        <Route exact path="/user/" component={Main} />
                        <Route  path="/user/info" component={Info} />
                    </div>
                </div>
            </div>
        );
    }
}

export default User;
```

`User.Info`组件

```jsx
import React, { Component } from 'react';


class Info extends Component {
    constructor(props) {
        super(props);
        this.state = { 
            msg:'我是用户信息'
         };
    }    
    render() {
        return (
            <div className="info">
                我是用户信息组件
            </div>
        );
    }
}

export default Info;
```

`User.Main`组件

```jsx
import React, { Component } from 'react';


class Main extends Component {
    constructor(props) {
        super(props);
        this.state = { 
            msg:'我是个人中心'
         };
    }    
    render() {
        return (
            <div className="main">
                我是个人中心组件
            </div>
        );
    }
}

export default Main;
```



## 生命周期函数

```jsx
/*
https://reactjs.org/docs/react-component.html


React生命周期函数：
    组件加载之前，组件加载完成，以及组件更新数据，组件销毁。
    触发的一系列的方法 ，这就是组件的生命周期函数


组件加载的时候触发的函数： 
    constructor 、componentWillMount、 render 、componentDidMount

组件数据更新的时候触发的生命周期函数：
    shouldComponentUpdate、componentWillUpdate、render、componentDidUpdate


你在父组件里面改变props传值的时候触发的：
    componentWillReceiveProps


组件销毁的时候触发的：
    componentWillUnmount


必须记住的生命周期函数：

    加载的时候：componentWillMount、 render 、componentDidMount（dom操作）
    更新的时候：componentWillUpdate、render、componentDidUpdate
    销毁的时候：componentWillUnmount

*/


```

