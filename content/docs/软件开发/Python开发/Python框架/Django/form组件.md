---
title: "form组件"
weight: 15
date: 2026-06-23
tags: ["Python", "Django", "Web框架"]
---

## form表单上传文件及后端如何操作

```python
"""
form表单上传文件类型的数据
	1.method必须指定成post
	2.enctype必须换成formdata

"""
def ab_file(request):
    if request.method == 'POST':
        # print(request.POST)  # 只能获取普通的简直对数据 文件不行
        print(request.FILES)  # 获取文件数据
        # <MultiValueDict: {'file': [<InMemoryUploadedFile: u=1288812541,1979816195&fm=26&gp=0.jpg (image/jpeg)>]}>
        file_obj = request.FILES.get('file')  # 文件对象
        print(file_obj.name)
        with open(file_obj.name,'wb') as f:
            for line in file_obj.chunks():  
                	# 推荐加上chunks方法，默认读取65536B？？？ 其实跟不加是一样的都是一行行的读取。
                f.write(line)

    return render(request,'form.html')


前端：
	<form action="" method="post" enctype="multipart/form-data">
        {% csrf_token %}
        <p>username: <input type="text" name="username"></p>
        <p>file: <input type="file" name="file"></p>
        <input type="submit">
    </form>
```

## 
