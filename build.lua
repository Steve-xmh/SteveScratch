if #arg ~= 6 then
    error("Please lauch me in FlashDevelop :D")
end
local compiler = arg[1] --Flex SDK 路径
local add = [[G:\ssDev\SteveScratch\bin\SteveScratch.swf]] --生成的 swf 路径
local offAdd = [[\src\util\]] -- 相对于 add 的源码 util 路径（存放bin文件）
local TargetPlatform = arg[6]

local buildConfig = arg[5]
local debug = false
if buildConfig == "debug" then
    debug = true
    print("You have choose debug building...")
end

local srcPath = [["]]..arg[4]..[[\src\"]]
local libPath = [["]]..arg[4]..[[\libs\"]]

local buildProject = [["]]..arg[4]..[[\src\Loader\SB2Loader.as"]]

local configPath = [["]]..arg[4]..[[\obj\SteveScratchConfig.xml"]]
local title = [[ -title="SteveScratch 1.0.8I"]]
local compilerRun = [[\bin\mxmlc.bat]]
os.execute("cls")
print("\n\tBuilding SteveScratchLoader...\n")

local buildCmd = [["]]..
    compiler .. compilerRun ..
    [[" -load-config+=]] ..
    configPath .. title ..
    [[ -incremental=true +configname=]]..TargetPlatform..[[ --compiler.compress=false --debug=]] .. tostring(debug) .. [[ -use-network=false --static-link-runtime-shared-libraries=true -accessible=true -o ]] .. add

--print(buildCmd)
--mxmlc -load-config+=obj\SteveScratchConfig.xml -debug=true -incremental=true +configname=air --compiler.compress=false --static-link-runtime-shared-libraries=true -o obj\SteveScratch636793438897870910

local f = io.open(arg[4] .. offAdd .. [[PartHeader.bin]], "wb")
f:close()
f = io.open(arg[4] .. offAdd .. [[PartChunkBefore.bin]], "wb")
f:close()
f = io.open(arg[4] .. offAdd .. [[PartSB2Header.bin]], "wb")
f:close()
f = io.open(arg[4] .. offAdd .. [[PartChunkBetween.bin]], "wb")
f:close()
f = io.open(arg[4] .. offAdd .. [[PartChunkAfter.bin]], "wb")
f:close()
f = io.open(arg[4] .. offAdd .. [[Order.bin]], "wb")
f:close()

local rxp = [[<file%-specs>.*</file%-specs>]]
local ssRxp = [[<name>SS::isMain</name>.*<value>.*</value><!%-%-SM%-%->]]
local dateRxp = [[<name>SS::timeStamp</name>.*<value>.*</value><!%-%-TS%-%->]]

f = io.open(string.sub(configPath, 2, -2), "rb")
local str = f:read("*a")
--print(str)
str = string.gsub(str, rxp, [[<file-specs>
    <path-element>]] .. arg[4] .. [[\src\Loader\SB2Loader.as</path-element>
  </file-specs>]])

str = string.gsub(str, ssRxp, [[<name>SS::isMain</name>
      <value>false</value><!--SM-->]])
	  
str = string.gsub(str, dateRxp, [[<name>SS::timeStamp</name>
      <value>]] .. os.date("'%Y %x %X'") .. [[</value><!--TS-->]])

f:close()
f = io.open(string.sub(configPath, 2, -2), "wb")
f:write(str)
f:close()

os.remove(add)
os.remove(add .. ".cache")

local ret,err = os.execute("call " .. buildCmd)
if not ret then
	error("ERROR: " .. err,0)
    return
end

print("\n\tMaking bin files...\n")

local swf = io.open(add, "rb")
local size = swf:seek("end")
swf:seek("set")
str = swf:read("*a")
swf:seek("set")

local sb2Offset = string.find(str, "ThisIsTheSB2File")
local settingsOffset = string.find(str, "ThisIsTheSettingsFile")
if not sb2Offset or not settingsOffset then
    error("ERROR: Can't find the sb2 header or the setting header")
    return
end

--print()
--print(string.sub(str, sb2Offset, sb2Offset + 100))
--print(string.sub(str, settingsOffset, settingsOffset + 100))

local smallerOffset, largerOffset, firstBinaryEnd, secondBinaryEnd, orderFile
if sb2Offset < settingsOffset then
    smallerOffset = sb2Offset
    largerOffset = settingsOffset
    firstBinaryEnd = sb2Offset + 80
    secondBinaryEnd = settingsOffset + 21
    orderFile = "1"
else
    smallerOffset = settingsOffset
    largerOffset = sb2Offset
    firstBinaryEnd = settingsOffset + 21
    secondBinaryEnd = sb2Offset + 80
    orderFile = "0"
end

local partChunkBefore, partChunkBetween, partSB2Header, partChunkAfter, partHeader

partHeader = string.sub(str, 1, 4)
partSB2Header = string.sub(str, sb2Offset - 6, sb2Offset - 1)
partChunkAfter = string.sub(str, secondBinaryEnd)

if orderFile == "1" then
    partChunkBefore = string.sub(str, 18, (smallerOffset - 11))
    partChunkBetween = string.sub(str, firstBinaryEnd, largerOffset - 1)
else
    partChunkBefore = string.sub(str, 18, (smallerOffset - 1))
    partChunkBetween = string.sub(str, firstBinaryEnd, largerOffset - 11)
end

local orderFileFixed = orderFile .. "   "

swf:close()

print("\n\tWriting bin files...\n")

f = io.open(arg[4] .. offAdd .. [[PartHeader.bin]], "wb")
f:write(partHeader)
f:close()
f = io.open(arg[4] .. offAdd .. [[PartChunkBefore.bin]], "wb")
f:write(partChunkBefore)
f:close()
f = io.open(arg[4] .. offAdd .. [[PartSB2Header.bin]], "wb")
f:write(partSB2Header)
f:close()
f = io.open(arg[4] .. offAdd .. [[PartChunkBetween.bin]], "wb")
f:write(partChunkBetween)
f:close()
f = io.open(arg[4] .. offAdd .. [[PartChunkAfter.bin]], "wb")
f:write(partChunkAfter)
f:close()
f = io.open(arg[4] .. offAdd .. [[Order.bin]], "wb")
f:write(orderFileFixed)
f:close()

print("\n\tBuilding SteveScratch...\n")

f = io.open(string.sub(configPath, 2, -2), "rb")
local str = f:read("*a")
str = string.gsub(str, rxp, [[<file-specs>
    <path-element>]] .. arg[4] .. [[\src\Scratch.as</path-element>
  </file-specs>]])

str = string.gsub(str, ssRxp, [[<name>SS::isMain</name>
    <value>true</value>]])

  f:close()
f = io.open(string.sub(configPath, 2, -2), "wb")
f:write(str)
f:close()

buildCmd = [["]]..
    compiler .. compilerRun ..
    [[" -load-config+=]] ..
    configPath .. title ..
    [[ -incremental=true +configname=]]..TargetPlatform..[[ --compiler.compress=true --debug=]] .. tostring(debug) .. [[ -use-network=true --static-link-runtime-shared-libraries=true -o ]] .. add


os.remove(add)
os.remove(add .. ".cache")

local ret,err = os.execute("call " .. buildCmd)
if not ret then
    error("ERROR: " .. err)
    return
end

os.remove(add .. ".cache")

print("\n\tBuild Finished.\n")
