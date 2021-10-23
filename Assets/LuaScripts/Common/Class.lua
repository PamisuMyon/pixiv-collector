function SetMetaTableIndex(t, index)
    if t == nil or index == nil then
        ---error
        return
    end
    local mt = getmetatable(t)
    if not mt then
        mt = {}
    end
    if not mt.__index then
        mt.__index = index
        setmetatable(t, mt)
    elseif mt.__index ~= index then
        SetMetaTableIndex(mt, index)
    end
end


function Class(classname, ...)
    local cls = { __cname = classname }
    local supers = { ... }
    for _, super in ipairs(supers) do
        if type(super) == "table" then
            cls.__supers = cls.__supers or {}
            cls.__supers[#cls.__supers + 1] = super
            if not cls.super then
                cls.super = super
            end
        else
            ---error
            return
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, { __index = cls.super })
    else
        setmetatable(cls, { __index = function(_, key)
            supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then
                    return super[key]
                end
            end
        end })
    end

    if not cls.Ctor then
        cls.Ctor = function()
        end
    end
    cls.New = function(...)
        local instance = {}
        SetMetaTableIndex(instance, cls)
        instance.class = cls
        instance:Ctor(...)
        return instance
    end
    return cls
end