import re

path = r'C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\ZipTrix\ZipTrix.lua'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace CreateFrame global names
# CreateFrame("Type", "Name", ...) -> CreateFrame("Type", nil, ...)
content = re.sub(r'CreateFrame\("([^"]+)",\s*"[^"]+"', r'CreateFrame("\1", nil', content)

# Update OnUpdate throttling for model
content = re.sub(r'model:SetScript\("OnUpdate", function\(self, elapsed\)\n(.*?)end\)', r'''model:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed_accum = (self.elapsed_accum or 0) + elapsed
    if self.elapsed_accum >= 0.1 then
        self.elapsed_accum = 0
\1    end
end)''', content, flags=re.DOTALL)

# Update OnUpdate throttling for GameTooltip
content = re.sub(r'GameTooltip:HookScript\("OnUpdate", function\(self\)\n(.*?)end\)', r'''GameTooltip:HookScript("OnUpdate", function(self, elapsed)
    self.elapsed_accum = (self.elapsed_accum or 0) + (elapsed or 0.05)
    if self.elapsed_accum >= 0.1 then
        self.elapsed_accum = 0
\1    end
end)''', content, flags=re.DOTALL)

# Update OnUpdate throttling for maelstromFrame
content = re.sub(r'maelstromFrame:SetScript\("OnUpdate", function\(self, elapsed\)\n(.*?)end\)', r'''maelstromFrame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed_accum = (self.elapsed_accum or 0) + elapsed
    if self.elapsed_accum >= 0.1 then
        self.elapsed_accum = 0
\1    end
end)''', content, flags=re.DOTALL)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)
