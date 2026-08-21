print = print
print = mf.printconsole if print==mf.print

F = far.Flags

print "Inspect key presses"
print "Press key ('Esc' to quit)"

tmpl = "ECSNsCcAa"
bitflags = (state) -> tmpl\gsub "().", (i) -> bit64.band(2^(9-i), state)==0 and "·"

--tmpl = "casac - ecns"
--bits = {3,1,4,0,2,nil,nil,nil,8,7,5,6}
--bitflags = (state) ->
--  "casac - ecns"\gsub "()(.)", (i,ch) ->
--    bits[i] and bit64.band(2^bits[i], state)~=0 and ch\upper!

fmtChar = (char) ->
  if char==" "
    '" "'
  elseif char=="\0"
    ""
  elseif char<" " -- C0 control codes
    "\\"..utf8.byte char
  else
    char

--https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
ANSI = Far.GetConfig"Interface.VirtualTerminalRendering"

INTENSE, FAINT, ITALIC, STRIKEDOUT = "1","2","3","9"
c = (str = "", attr) ->
  return str unless ANSI
  "\27[#{attr}m#{str}\27[0m"

local lastdown
last = 0
fmtKey = (rec) ->
  vk,down = rec.VirtualKeyCode, rec.KeyDown
  autorepeat = down and vk==last
  last = down and vk or 0
  name = far.InputRecordToName rec
  if name and not down and not lastdown
    return ""--c(name, "#{FAINT};#{STRIKEDOUT}")
  lastdown = not name and down
  c(name, autorepeat and "#{FAINT};#{ITALIC}" or INTENSE)

vkeys = win.GetVirtualKeys!
fmtVK = (rec) ->
  with rec
    vkey = vkeys[.VirtualKeyCode]
    vkey ..= "\t" if vkey\len!<6
    return .KeyDown and 
      (.RepeatCount==1 and "  " or .RepeatCount.."*")..vkey or
      "↑ "..c(vkey, FAINT) 

VK = win.GetVirtualKeys!
Keys =
  someDown: =>
    for i=0,255
      return true if self[i]
  track: (rec) =>
    with rec
      vk, state = .VirtualKeyCode, .ControlKeyState
      switch vk
        when VK.CONTROL
          vk = 0==bit64.band(state, F.ENHANCED_KEY) and VK.LCONTROL or VK.RCONTROL
        when VK.MENU
          vk = 0==bit64.band(state, F.ENHANCED_KEY) and VK.LMENU or VK.RMENU
      self[vk] = .KeyDown

MODS_MASK = 2^5-1
print "#", "state", tmpl, "vk", "sc", "vkname", "",  "char", "  keyname"
line = "─"\rep 7
print line, line, line..line, line, line, line..line, line, line..line
i = 1
while true
  local rec
  while not rec or rec.EventType~=F.KEY_EVENT
    rec = win.ExtractKeyEx!
    win.Sleep 10
  print "" unless Keys\someDown!
  with rec --https://learn.microsoft.com/en-gb/windows/console/key-event-record-str
    vk, state = .VirtualKeyCode, .ControlKeyState
    print i, state, (bitflags state), vk, .VirtualScanCode,
      fmtVK rec,
      fmtChar .UnicodeChar,
      fmtKey rec
    break if vk==VK.ESCAPE and not .KeyDown and 0==bit64.band state, MODS_MASK
    Keys\track rec
    i += 1