# Python code stubs for wxPython GUI
# Tidbits include 
# 1. Adding some basic GUI elements
# 2. Finding directories/paths
# 3. Checking for valid IP Address
# 4. Showing a progress window

import wx
import time
import sys
import json
import urllib2
import os
#---------------------------------------------------------------------------

class UpdatePanel(wx.Panel):
    def __init__(self, parent, log):
        self.log = log
        wx.Panel.__init__(self, parent, -1)

        b = wx.Button(self, -1, "Title", (80,100))
        self.Bind(wx.EVT_BUTTON, self.OnButton, b)

        textbox = wx.TextCtrl(self, -1, "Text box", size=(100,-1), pos = (100,60))
        wx.CallAfter(textbox.SetInsertionPoint, 0)
        self.textbox = textbox

        label = wx.StaticText(self, -1, "Static text", pos = (70,20))

    def OnButton(self, evt):
        max = 100

        def show_error_dialog(message):
            msg_dlg = wx.MessageDialog(self, message, 'Error', wx.OK | wx.ICON_INFORMATION)
            msg_dlg.ShowModal()
            msg_dlg.Destroy()
            return

        def check_update_file_exists(path):
            if not os.path.isfile(path):
                return False

            return True
        
        #Getting paths
        def get_temp_dir_path(relative_path):
            """Pyinstaller temp directory"""
            import win32api
            try:
                base_path = win32api.GetLongPathName(sys._MEIPASS)
            except Exception:
                base_path = win32api.GetLongPathName(os.path.abspath("."))

            return os.path.join(base_path, relative_path)

        firmware_path = get_temp_dir_path('firmware.tar')

        if not check_update_file_exists(firmware_path):
            show_error_dialog('Firmware package firmware.tar not found')
            return

        #Checking if entered IP is valid
        def check_valid_ip(ipaddress):
            octets = ipaddress.split('.')
            if len(octets) != 4:
                return False
            for digits in octets:
                if not digits.isdigit():
                    return False
                number = int(digits)
                if number < 0 or number > 255:
                    return False
            return True

        ip = self.textbox.GetValue()
        if not check_valid_ip(ip):
            show_error_dialog('Invlaid IP address')
            return

        #Check if an IP device is online:
        def check_device_online(ipAddress):
            try:
                urllib2.urlopen("http://"+ipAddress, timeout=1)
                return True
            except urllib2.URLError as err:
                return False
        
        if not check_device_online(ip):
            show_error_dialog( 'Device not available. Check device status or IP address')
            return

        dlg = wx.ProgressDialog("Download progress",
                            "Downloading software onto device...",
                            maximum = max,
                            parent=self,
                            style = 0
                                | wx.PD_APP_MODAL
                                | wx.PD_AUTO_HIDE
                                )       

        def cb(progress, message):
            dlg.Update(progress*100, message)

        dlg.Destroy()
#---------------------------------------------------------------------------


def runTest(frame, nb, log):
    win = UpdatePanel(nb, log)
    return win

#---------------------------------------------------------------------------


overview = """\
<html><body>
This class represents a dialog that shows a short message and a progress bar. 
Optionally, it can display an ABORT button
<p>
This dialog indicates the progress of some event that takes a while to accomplish, 
usually, such as file copy progress, download progress, and so on. The display
is <b>completely</b> under control of the program; you must update the dialog from
within the program creating it. 
<p>
When the dialog closes, you must check to see if the user aborted the process or
not, and act accordingly -- that is, if the PD_CAN_ABORT style flag is set. 
If not then you may progress blissfully onward.
</body></html>
"""

if __name__ == '__main__':
    import sys,os
    import run
    run.main(['', os.path.basename(sys.argv[0])] + sys.argv[1:])
    
