package backend;

#if (windows && cpp)
@:buildXml('
    <target id="haxe"> 
        <lib name="dwmapi.lib" if="windows" /> 
        <lib name="Shell32.lib" if="windows" /> 
    </target>
')
@:cppFileCode('
	#include <stdio.h>
    #include <windows.h>
    #include <winuser.h>
    #include <dwmapi.h>
    #include <strsafe.h>
    #include <shellapi.h>
    #include <iostream>
    #include <string>
')
#end

class SystemUtil
{
    public static var windowOpacityTween:FlxTween = null;

    #if windows
    @:functionCode('
        int isDark = mode;
        HWND window = GetActiveWindow();
        if (S_OK != DwmSetWindowAttribute(window, 19, &isDark, sizeof(isDark))) {
            DwmSetWindowAttribute(window, 20, &isDark, sizeof(isDark));
        }
        UpdateWindow(window);
    ')
    #end
	@:noCompletion
	static function _darkTitle(mode:Int) {}

	public static function darkTitle(isDark:Bool)
    {
        _darkTitle((isDark) ? 1 : 0);
    }

    /**
     * Tweens the window opacity to 0 then closes the game.
     *
     * @param time How long it takes to tween the window opacity.
     */
    public static function tweenClose(time:Float = 1):Void
    {
        if (windowOpacityTween == null || !windowOpacityTween.active)
        {
            windowOpacityTween = FlxTween.tween(FlxG.stage.window, { opacity: 0 }, time, { ease: FlxEase.sineOut, onComplete: function (twn:FlxTween) {
                Sys.exit(0);
            }});
        }
    }

    #if windows
    @:functionCode('
        NOTIFYICONDATA m_NID;

        memset(&m_NID, 0, sizeof(m_NID));
        m_NID.cbSize = sizeof(m_NID);
        m_NID.hWnd = GetForegroundWindow();
        m_NID.uFlags = NIF_MESSAGE | NIIF_WARNING | NIS_HIDDEN;

        m_NID.uVersion = NOTIFYICON_VERSION_4;

        if (!Shell_NotifyIcon(NIM_ADD, &m_NID))
            return FALSE;
    
        Shell_NotifyIcon(NIM_SETVERSION, &m_NID);

        m_NID.uFlags |= NIF_INFO;
        m_NID.uTimeout = 1000;
        m_NID.dwInfoFlags = NULL;

        LPCTSTR lTitle = title.c_str();
        LPCTSTR lDesc = desc.c_str();

        if (StringCchCopy(m_NID.szInfoTitle, sizeof(m_NID.szInfoTitle), lTitle) != S_OK)
            return FALSE;

        if (StringCchCopy(m_NID.szInfo, sizeof(m_NID.szInfo), lDesc) != S_OK)
            return FALSE;

        return Shell_NotifyIcon(NIM_MODIFY, &m_NID);
    ')
    #end
    public static function sendWindowsNotification(title:String = "", desc:String = "", res:Int = 0)
    {
        return res;
    }
}