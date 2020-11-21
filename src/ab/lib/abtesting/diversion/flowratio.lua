---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by guoguo.
--- DateTime: 2020/11/18 11:01
---

local modulename = "abtestingDiversionFlowRatio"

local _M    = {}
local mt    = { __index = _M }
_M._VERSION = "0.0.1"

local ERRORINFO	= require('abtesting.error.errcode').info

local k_ratio      = 'ratio'
local k_upstream    = 'upstream'

_M.new = function(self, database, policyLib)
    if not database then
        error{ERRORINFO.PARAMETER_NONE, 'need avaliable redis db'}
    end if not policyLib then
        error{ERRORINFO.PARAMETER_NONE, 'need avaliable policy lib'}
    end

    local flowRatiostrategyCache = ngx.shared.api_flow_ratio_strategy

    self.database = database
    self.policyLib = policyLib
    return setmetatable(self, mt)
end

--	policy is in format as {{ratio = '10', upstream = '192.132.23.125'}}
_M.check = function(self, policy)
    for _, v in pairs(policy) do
        local ratio      = v[k_ratio]
        local upstream  = v[k_upstream]


        if not ratio or not upstream then
            local info = ERRORINFO.POLICY_INVALID_ERROR
            local desc = ' need '..k_ratio..' and '..k_upstream
            return {false, info, desc}
        end

    end

    return {true}
end

_M.set = function(self, policy)
    local database  = self.database
    local policyLib = self.policyLib

    database:init_pipeline()
    for _, v in pairs(policy) do
        database:hset(policyLib, v[k_ratio], v[k_upstream])
    end
    local ok, err = database:commit_pipeline()
    if not ok then
        error{ERRORINFO.REDIS_ERROR, err}
    end

end

_M.get = function(self)
    local database  = self.database
    local policyLib = self.policyLib
    ngx.log(ngx.DEBUG,'调用了get方法,policyLib:',policyLib)
    local data, err = database:hgetall(policyLib)
    if not data then
        error{ERRORINFO.REDIS_ERROR, err}
    end

    return data
end

_M.getUpstream = function(self, ratio)

    local database	= self.database
    local policyLib = self.policyLib
    ngx.log(ngx.DEBUG,'调用了getUpstream方法, policyLib:',policyLib)
    local upstream, err = database:hget(policyLib , ratio)
    local hkeys,err = database:hkeys(policyLib);
    if  upstream == ngx.null or upstream == nil then
        for i=1,#hkeys do
            if ratio <= tonumber(hkeys[i]) then
                local tempUpSteam,err = database:hget(policyLib,hkeys[i]);
                if tempUpSteam then
                    upstream = tempUpSteam;
                    break;
                end
                --error{ERRORINFO.REDIS_ERROR, err}
            end
        end
    end

    --error{ERRORINFO.REDIS_ERROR, err}
    if upstream == ngx.null then
        --error{ERRORINFO.REDIS_ERROR, err}
        return nil
    else
        return upstream
    end

end


return _M
