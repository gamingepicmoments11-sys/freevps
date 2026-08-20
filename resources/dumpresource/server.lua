AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        local fxapPath = GetResourcePath(resource) .. '/.fxap'
        local file = LoadResourceFile(resource, '.fxap')
        if file then
            local outPath = GetResourcePath(resource) .. '/bis.luac'
            SaveResourceFile(resource, 'bis.luac', file, #file)
            print('^2[DUMP] Saved .fxap to bis.luac (' .. #file .. ' bytes)^0')
        else
            print('^1[DUMP] Failed to load .fxap^0')
        end
    end
end)
