---
title: "Ubuntu桌面美化"
weight: 170
date: 2026-06-05
---

`.conkyrc`配置文件

```bash

-- vim: ts=4 sw=4 noet ai cindent syntax=lua
--[[
Conky, a system monitor, based on torsmo

Any original torsmo code is licensed under the BSD license

All code written since the fork of torsmo is licensed under the GPL

Please see COPYING for details

Copyright (c) 2004, Hannu Saransaari and Lauri Hakkarainen
Copyright (c) 2005-2012 Brenden Matthews, Philip Kovacs, et. al. (see AUTHORS)
All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
	default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    use_xft = true,
    font = 'simsunb:size=12',
    gap_x = 5,
    gap_y = 60,
    minimum_height = 5,
	minimum_width = 5,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_stderr = false,
    extra_newline = false,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    show_graph_scale = false,
    show_graph_range = false,
    own_window_argb_visual = true,
    own_window_argb_value = 50,
    double_buffer = true,
}

conky.text = [[
${scroll 16 $nodename - $sysname $kernel on $machine | }
$hr
${color CDE0E7}$alignc${font FreeMono:pixelsize=70}${time %H:%M}${font}
$alignc${font FreeMono}${color white}${time %Y}-${time  %m}-${time %d}${font}
$hr
${color grey}系统运行时间:$color $uptime
${color grey}CPU当前频率 (in MHz):$color $freq
#${color grey}CPU当前频率 (in GHz):$color $freq_g
${color grey}CPU 使用情况:$color $cpu% ${cpubar 4}
	${color}Processes:$color $processes  ${color}Running:$color $running_processes
${color grey}RAM 使用情况:
	$color $mem/$memmax - $memperc% ${membar 4}
${color grey}Swap 使用情况:
	$color $swap/$swapmax - $swapperc% ${swapbar 4}
${color grey}GPU:
 	${color1}GPU 频率: $alignr ${color}${font}${nvidia gpufreq} Mhz${voffset 3}
 	${color1}Memory 频率: $alignr ${color}${font}${nvidia memfreq} Mhz${voffset 3}
 	${color1}当前温度: $alignr ${color}${font}${nvidia temp}°C ${voffset 3}
$hr
${color grey}文件系统:
    / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
    /data $color${fs_used /data}/${fs_size /data} ${fs_bar 6 /data}
$hr
${color grey}磁盘 I/O:${color}${font} ${alignr}$diskio
    ${color}读取: ${color}${font} ${goto 80}${color4}${diskiograph_read  15,210 ADFF2F 32CD32 750}${color}
    ${color}写入: ${color}${font} ${goto 80}${color4}${diskiograph_write 15,210 FF0000 8B0000 750}${color}
$hr
${color grey}网卡速率:
    ${color}有线网卡: Up:$color ${upspeed enp7s0} ${color} - Down:$color ${downspeed enp7s0}
    ${color}无线网卡: Up:$color ${upspeed wlp4s0} ${color} - Down:$color ${downspeed wlp4s0}
$hr
${color grey}进程监控:
    ${color}Name              PID   CPU   MEM
    ${color} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
    ${color} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
    ${color} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
    ${color} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
    ${color} ${top name 5} ${top pid 5} ${top cpu 5} ${top mem 5}
]]

```



```bash
tee -a $HOME/.bashrc << EOF
# Go envs
export GOVERSION=go1.17.2 # Go 版本设置
export GO_INSTALL_DIR=$HOME/go # Go 安装目录
export GOROOT=$GO_INSTALL_DIR/$GOVERSION # GOROOT 设置
export GOPATH=$WORKSPACE/golang # GOPATH 设置
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH # 将 Go 语言自带的和通过 go install 安装的二进制文件加入到
export GO111MODULE="on" # 开启 Go moudles 特性
export GOPROXY=https://goproxy.cn,direct # 安装 Go 模块时，代理服务器设置
export GOPRIVATE=
export GOSUMDB=off # 关闭校验 Go 依赖包的哈希值
EOF 


# 第一步：安装 protobuf
$ cd /tmp/
$ git clone --depth=1 https://github.com/protocolbuffers/protobuf
$ cd protobuf
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install
$ protoc --version # 查看 protoc 版本，成功输出版本号，说明安装成功
libprotoc 3.15.6
# 第二步：安装 protoc-gen-go
$ go get -u github.com/golang/protobuf/protoc-gen-go 

cd $IAM_ROOT
source scripts/install/environment.sh
sudo mkdir -p ${IAM_DATA_DIR}/{iam-apiserver,iam-authz-server,iam-pump}
sudo mkdir -p ${IAM_INSTALL_DIR}/bin
sudo mkdir -p ${IAM_CONFIG_DIR}/cert
sudo mkdir -p ${IAM_LOG_DIR}



```

