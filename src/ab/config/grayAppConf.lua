---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by guoguo.
--- DateTime: 2020/11/18 9:34
---


local modulename = "abtestingAppConf"

local _M = {}

_M._VERSION = '0.0.1'

-- 灰度应用列表 配置
_M.grayApp = {
    "driver","carlife"
}

_M.global_configs = {
    ["divEnable"] = false,  -- 分流开关，true表示开启
    ["newTrafficRate"] = 100,  -- 分流比例，0-1000， 1000表示全部流量，100%

}

-- 局部灰度开关配置
_M.graySwith = {
    ["dirver"]  = "on",
    ["carlife"] = "off"
}



return _M