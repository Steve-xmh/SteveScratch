# SteveScratch

SteveScratch is a powerful scratch editor secondary development version from LLK/scratch-flash. This projece has many **new** functions.

## Build
To build this project, you need Lua and Flex Sdk. It's better to use Lua 5.3 and Flex Sdk 4.11 or higher to build this project.

### Build with Flash Develop
At first, you should download the zip file or clone this project by using git.
```bash
git clone https://github.com/Eureka0225/SteveScratch
```
After that, you must do:
1. Open Flash Develop, and creat a `AIR AS3 Projector` on your workspace.
2. Open Project -> Properties -> Sdk, and choose your sdk or input your sdk's path.
3. Open Project -> Properties -> Compiler Options, find `Additional Compiler Options` and input:
```
-define+=SCRATCH::allow3d,false
-define+=SCRATCH::revision,'e267f37'
```
4. open Project -> Properties -> Build, input something to `Pre-Build Command Line`:
```
lua "$(ProjectDir)\build.lua" "$(FlexSDK)" "$(OutputDir)" "$(OutputName)" "$(ProjectDir)" "$(BuildConfig)" "$(TargetPlatform)"
```
5. Include our source, you need move folders to your workspace.
You need to move these folders:
```
icons
libs
src
```
and this file:
```
build.lua
```
6. Open folder `libs` in Flash Develop, choose three swc files, right click them and click `Add To Library`. 
7. Open floder `src`, right click `Scratch.as` and click `Document Class`. 
8. Delete `Main.as`. 
9. Set defines in `build.lua`
10. Run project.
