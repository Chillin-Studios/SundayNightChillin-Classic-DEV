@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib install lime 8.1.2
haxelib install openfl 9.3.3
haxelib install flixel 5.6.1
haxelib install flixel-addons 3.2.2
haxelib install flixel-ui 2.6.1
haxelib install flixel-tools 1.5.1
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib install hxdiscord_rpc 1.2.0
haxelib install hxvlc 1.8.2
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib install SScript 7.7.0
haxelib install tjson 1.4.0
echo Finished!
pause