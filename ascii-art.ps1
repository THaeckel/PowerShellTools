## This script prints a random ASCII art to the console

Function Print-Hardware-Info {
    $alignment = 40
    $row = 0
    $Position=$HOST.UI.RawUI.CursorPosition
    $oldrow = $Position.Y
    $Position.X=$alignment
    $Position.Y=$row
    $row = $row+1
    $HOST.UI.RawUI.CursorPosition=$Position
    echo (get-wmiobject Win32_PhysicalMemory)[0].PSComputerName
    $Position.X=$alignment
    $Position.Y=$row
    $row = $row+1
    $HOST.UI.RawUI.CursorPosition=$Position
    echo (get-wmiobject win32_bios).Manufacturer
    $Position.X=$alignment
    $Position.Y=$row
    $row = $row+1
    $HOST.UI.RawUI.CursorPosition=$Position
    echo (get-wmiobject win32_processor).Name
    $memory = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
    $memoryspeed = (get-wmiobject Win32_PhysicalMemory)[0].ConfiguredClockSpeed
    $Position.X=$alignment
    $Position.Y=$row
    $row = $row+1
    $HOST.UI.RawUI.CursorPosition=$Position
    Write-Host "$memory GB $memoryspeed"
    $gpus = Get-WmiObject Win32_VideoController
    $qwMemorySizes = (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -Name HardwareInformation.qwMemorySize -ErrorAction SilentlyContinue)."HardwareInformation.qwMemorySize"
    $qwmscnt = 0
    foreach ($gpu in $gpus) {
        $caption = $gpu.Caption
        $vram = ($gpu | Measure-Object -Property AdapterRAM -Sum).sum /1Gb
        $vramstring = ""
        $type = $gpu.AdapterDACType
        if ($type -ne "Internal") {
            $vram = $qwMemorySizes[$qwmscnt] /1Gb
            $qwmscnt = $qwmscnt+1
            $vramstring = "$vram GB"
        }
        $Position.X=$alignment
        $Position.Y=$row
        $row = $row+1
        $HOST.UI.RawUI.CursorPosition=$Position
        Write-Host "$caption $vramstring"
       
    }
    $disks = Get-Disk
    $diskssize = ($disks | Measure-Object -Property Size -Sum).sum /1Gb
    # Write-Host "$diskssize GB"
    foreach ($disk in $disks) {
        $diskno = $disk.Number
        $diskname = $disk.FriendlyName
        $bustype = $disk.BusType
        $disksize = (($disk | Measure-Object -Property Size -Sum).sum) /1Gb
        $Position.X=$alignment
        $Position.Y=$row
        $row = $row+1
        $HOST.UI.RawUI.CursorPosition=$Position
        Write-Host "$diskname $bustype $disksize GB"
    }
    $cinterfaces = (Get-NetAdapter | Where-Object Status -eq "Up")
    foreach($interface in $cinterfaces) {
        $idesc = $interface.InterfaceDescription
        $speed = $interface.LinkSpeed
        $Position.X=$alignment
        $Position.Y=$row
        $row = $row+1
        $HOST.UI.RawUI.CursorPosition=$Position
        Write-Host "$idesc $speed"
    }
    $row = $row+1
    if ($row -lt $oldrow) {
        $row = $oldrow
    }
    $Position.X=0
    $Position.Y=$row
    $HOST.UI.RawUI.CursorPosition=$Position
}

Function Get-PC-Type {
	# check if this pc is a tablet (<13" screen), a laptop (13"-20" screen) or a desktop (>20" screen)
	# monitor count 
	$screens = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams)
	$count = $screens.Count
	if (-not $count) {
		$count = 1
	}
	$active = ($screens | Where-Object Active -eq $true).Count
	if (-not $active) {
		$active = 1
	}
	# get screen sizes of each monitor 
	$screensizes = @()
	foreach ($screen in $screens) {
		$inches = [math]::Sqrt($screen.MaxHorizontalImageSize * $screen.MaxHorizontalImageSize + $screen.MaxVerticalImageSize * $screen.MaxVerticalImageSize) / 2.54
		# save in an array
		$screensizes += $inches
	}
	if ($count -eq 1) {
		# if only one screen, check if it is a tablet or a laptop
		$size = $screensizes[0]
		if ($size -lt 13) {
			$type = "tablet"
		}
		elseif ($size -lt 20) {
			$type = "laptop"
		}
		else {
			$type = "desktop"
		}
	}
	else {
		# if multiple screens, check the smallest
		$smallest = $screensizes | Measure-Object -Minimum
		if ($smallest.Minimum -lt 13) {
			$type = "tablet-multi-$active"
		}
		elseif ($smallest.Minimum -lt 20) {
			$laptopOff = ($count-$active) > 0
			if ($laptopOff) {
				$type = "laptop-multi-$active-off"
			}
			else {
				$type = "laptop-multi-$active"
			}
		}
		else {
			$type = "desktop-multi-$active"
		}
	}
	return $type
}

Function Print-Ascii-Art-PC ($type){
	# check if type contains tablet laptop or desktop disregarding the multi monitor part
	if ($type -like "*tablet*") {
		if ($type -eq "tablet") {
			Write-Host "  _______________________"
			Write-Host " | _____________________ |"
			Write-Host " ||                     ||"
			Write-Host " ||                     ||"
			Write-Host " ||                     ||"
			Write-Host " ||                     ||"
			Write-Host " ||                     ||"
			Write-Host " ||_____________________||"
			Write-Host " |___________O___________|"
		} 
		if ($type -like "*multi*") {
			Write-Host "   .---------. "
			Write-Host '   |.-"""""-.| '
			Write-Host "   ||       ||    ________"
			Write-Host "   ||       ||   /       /"
			Write-Host "   |'-.....-'|~~/___o___/"
			Write-Host '   `"")---(""`  '
			Write-Host '  /:::::::::::\  _ '
			Write-Host ' /:::=======:::\ \`\'
			Write-Host ' `""""""""""""""` `-`'
		}
	}
	elseif ($type -like "*laptop*") {
		if ($type -eq "laptop") {
			Write-Host "  __________________     "
			Write-Host " ||                ||    "
			Write-Host " ||                ||    "
			Write-Host " ||                ||    "
			Write-Host " ||                ||    "
			Write-Host " ||                ||    "
			Write-Host " ||________________||    "
			Write-Host "  \\  ############  \\   "
			Write-Host "   \\  ############  \\  "
			Write-Host "    \        ____      \ "
			Write-Host "     \_______\___\______\"	
		}
		elseif ($type -like "*multi*off") {
			Write-Host "   .---------. "
			Write-Host '   |.-"""""-.| '
			Write-Host "   ||       ||  __________"
			Write-Host "   ||       ||  \    ,,   \"
			Write-Host "   |'-.....-'|~~~\_________\"
			Write-Host '   `"")---(""`    ```````````'
			Write-Host '  /:::::::::::\  _ '
			Write-Host ' /:::=======:::\ \`\'
			Write-Host ' `""""""""""""""` `-`'
		}
		elseif ($type -like "*multi*") {
			Write-Host "   .---------. "
			Write-Host '   |.-"""""-.|   _______ '
			Write-Host "   ||       ||  |       |"
			Write-Host "   ||       ||  |_______|  "
			Write-Host "   |'-.....-'|~~\ ##### \"
			Write-Host '   `"")---(""`   \___U___\'
			Write-Host '  /:::::::::::\  _  '
			Write-Host ' /:::=======:::\ \`\'
			Write-Host ' `""""""""""""""` `-`'
		}
	}
	elseif ($type -like "*desktop*") {
		if ($type -eq "desktop") {
			Write-Host "               .----."
			Write-Host "   .---------. | == |"
			Write-Host '   |.-"""""-.| |----|'
			Write-Host "   ||       || | == |"
			Write-Host "   ||       || |----|"
			Write-Host "   |'-.....-'| |::::|"
			Write-Host '   `"")---(""` |___.|'
			Write-Host '               "    "'
			Write-Host '  /:::::::::::\  _ '
			Write-Host ' /:::=======:::\ \`\'
			Write-Host ' `""""""""""""""` `-`'
		}
		elseif ($type -like "*multi*") {
			Write-Host "                         .----."
			Write-Host " .---------. .---------. | == |"
			Write-Host ' |.-"""""-.| |.-"""""-.| |----|'
			Write-Host " ||       || ||       || | == |"
			Write-Host " ||       || ||       || |----|"
			Write-Host " |'-.....-'| |'-.....-'| |::::|"
			Write-Host ' `"")---(""` `"")---(""` |___.|'
			Write-Host '                         "    "'
			Write-Host '         /:::::::::::\  _'
			Write-Host '        /:::=======:::\ \`\'
			Write-Host '        `""""""""""""""` `-`'
		}
	}
}

Function Start-Marquee ($text) {
	# Clear the console of rubbish
	# CLEAR-HOST
	# Are how much information the user keyed in
	$length=$text.Length
	# Mark our Start end End points for our Marquee loop
	$start=1
	$end=$length
	$zerocharacters=0
	# Get the position of the Cursor on the screen and move it
	$Position=$HOST.UI.RawUI.CursorPosition
	$Position.X=4
	# $Position.Y=5
	# Do this over and repeatedly and over ….
	$runs=0
    	do {
        	foreach ($count in $start .. $end) {
        		# Keep everthing on the same line
        		$HOST.UI.RawUI.CursorPosition=$Position
        		# Remember how many characters for that OTHER loop
        		$characters=($length - $count)
        		# Put exactly WHAT we what WHERE we want WHEN we want
        		$text.Substring(($zerocharacters*$characters),$count).padleft(([int]!$zerocharacters*$length),' ').padright(($zerocharacters*$length),' ')
        		# Time a quick ‘POWER Nap’ – Oh sorry, was that Bad?
        		start-sleep -milliseconds 10
        	}
        	# Flip the counters around
        	$start=($length+1)-$start
        	$end=$length-$end
        	$zerocharacters=1-$zerocharacters
		$runs=$runs+1
    	} Until ($runs -eq 1) # You can change this to wait for a key if you REAAALY want 🙂
}
$artnumber = Get-Random 8
# $artnumber = 7
CLEAR-HOST
if($artnumber -eq 0)
{
	Write-Host "                                     )"
	Write-Host "                                     )"
	Write-Host "                            )      ((     ("
	Write-Host "                           (        ))     )"
	Write-Host "                    )       )      //     ("
	Write-Host "               _   (        __    (     ~->>"
	Write-Host "        ,-----' |__,_~~___<'__`)-~__--__-~->> <"
	Write-Host "        | //  : | -__   ~__ o)____)),__ - '> >-  >"
	Write-Host "        | //  : |- \_ \ -\_\ -\ \ \ ~\_  \ ->> - ,  >>"
	Write-Host "        | //  : |_~_\ -\__\ \~'\ \ \, \__ . -<-  >>"
	Write-Host "        ``-----._| `  -__`-- - ~~ -- ` --~> >"
	Write-Host "         _/___\_    //)_`//  | ||]"
	Write-Host "   _____[_______]_[~~-_ (.L_/  ||"
	Write-Host "  [____________________]' `\_,/'/"
	Write-Host "    ||| /          |||  ,___,'./"
	Write-Host "    ||| \          |||,'______|"
	Write-Host "    ||| /          /|| I==||"
	Write-Host "    ||| \       __/_||  __||__"
	Write-Host "-----||-/------``-._/||-o--o---o---"
	Write-Host "  ~~~~~'"
}
elseif($artnumber -eq 1)
{
	Write-Host "              _"
	Write-Host "             | |"
	Write-Host "             | |===( )   //////"
	Write-Host "             |_|   |||  | o o|"
	Write-Host "                    ||| ( c  )                  ____"
	Write-Host "                     ||| \= /                  ||   \_"
	Write-Host "                      ||||||                   ||     |"
	Write-Host '                      ||||||                ...||__/|-"'
	Write-Host "                      ||||||             __|________|__"
	Write-Host "                        |||             |______________|"
	Write-Host "                        |||             || ||      || ||"
	Write-Host "                        |||             || ||      || ||"
	Write-Host "------------------------|||-------------||-||------||-||-------"
	Write-Host "                        |__>            || ||      || ||"
	Write-Host ""
	Start-Marquee("hit any key to continue")
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
	Write-Host ""
}
elseif($artnumber -eq 2)
{
	Write-Host "         _nnnn_"                      
	Write-Host '        dGGGGMMb     ,""""""""""""""""".'
	Write-Host "       @p~qp~~qMb    | What the fuck!? |"
	Write-Host "       M|@||@) M|   _;.................'"
	Write-Host "       @,----.JM| -'"
	Write-Host "      JS^\__/  qKL"
	Write-Host "     dZP        qKRb"
	Write-Host "    dZP          qKKb"
	Write-Host "   fZP            SMMb"
	Write-Host "   HZM            MMMM"
	Write-Host "   FqM            MMMM"
	Write-Host ' __| ".        |\dS"qML'
	Write-Host " |    ``.       | ``' \Zq"
	Write-Host "_)      \.___.,|     .'"
	Write-Host "\____   )MMMMMM|   .'"
	Write-Host "     ``-'       ``--'"
}
elseif($artnumber -eq 3)
{
	Write-Host "  ___   _      ___   _      ___   _      ___   _      ___   _"
	Write-Host " [(_)] |=|    [(_)] |=|    [(_)] |=|    [(_)] |=|    [(_)] |=|"
	Write-Host "  '-'  |_|     '-'  |_|     '-'  |_|     '-'  |_|     '-'  |_|"
	Write-Host " /mmm/  /     /mmm/  /     /mmm/  /     /mmm/  /     /mmm/  /"
	Write-Host "       |____________|____________|____________|____________|"
	Write-Host "                             |            |            |"
	Write-Host "                         ___  \_      ___  \_      ___  \_"
	Write-Host "                        [(_)] |=|    [(_)] |=|    [(_)] |=|"
	Write-Host "                         '-'  |_|     '-'  |_|     '-'  |_|"
	Write-Host "                        /mmm/        /mmm/        /mmm/"
	Write-Host ""
	Start-Marquee("I'll tell you a UDP joke but you might not get it.")
	Write-Host ""
}
elseif($artnumber -eq 4)
{
	Write-Host " .=====================================================."
	Write-Host " ||                                                   ||"
	Write-Host ' ||   _       _--""--_                                ||'
	Write-Host ' ||     " --""   |    |   .--.           |    ||      ||'
	Write-Host ' ||   " . _|     |    |  |    |          |    ||      ||'
	Write-Host ' ||   _    |  _--""--_|  |----| |.-  .-i |.-. ||      ||'
	Write-Host ' ||     " --""   |    |  |    | |   |  | |  |         ||'
	Write-Host ' ||   " . _|     |    |  |    | |    `-( |  | ()      ||'
	Write-Host ' ||   _    |  _--""--_|             |  |              ||'
	Write-Host ' ||     " --""                      `--`              ||'
	Write-Host " ||                                                   ||"
	Write-Host " '====================================================='"
	Write-Host ""
}
elseif($artnumber -eq 5)
{
	Write-Host '         ___      _                                                                                             '
	Write-Host '"T$$$P"   |  |_| |_                                                                                             '
	Write-Host ' :$$$     |  | | |_                                                                                             '
	Write-Host ' :$$$                                                      "T$$$$$$$b.                                          '
	Write-Host ' :$$$     .g$$$$$p.   T$$$$b.    T$$$$$bp.                   BUG    "Tb      T$b      T$P   .g$P^^T$$  ,gP^^T$$ '
	Write-Host '  $$$    d^"     "^b   $$  "Tb    $$    "Tb    .s^s. :sssp   $$$     :$; T$$P $^b.     $   dP"     `T :$P    `T '
	Write-Host '  :$$   dP         Tb  $$   :$;   $$      Tb  d"   `b $      $$$     :$;  $$  $ `Tp    $  d$           Tbp.     '
	Write-Host '  :$$  :$;         :$; $$   :$;   $$      :$; T.   .P $^^    $$$    .dP   $$  $   ^b.  $ :$;            "T$$p.  '
	Write-Host '  $$$  :$;         :$; $$...dP    $$      :$;  `^s^" .$.     $$$...dP"    $$  $    `Tp $ :$;     "T$$      "T$b '
	Write-Host '  $$$   Tb.       ,dP  $$"""Tb    $$      dP ""$""$" "$"$^^  $$$""T$b     $$  $      ^b$  T$       T$ ;      $$;'
	Write-Host '  $$$    Tp._   _,gP   $$   `Tb.  $$    ,dP    $  $...$ $..  $$$   T$b    :$  $       `$   Tb.     :$ T.    ,dP '
	Write-Host '  $$$;    "^$$$$$^"   d$$     `T.d$$$$$P^"     $  $"""$ $"", $$$    T$b  d$$bd$b      d$b   "^TbsssP" "T$bgd$P  '
	Write-Host '  $$$b.____.dP                                 $ .$. .$.$ss,d$$$b.   T$b.                                       '
	Write-Host '.d$$$$$$$$$$P                                                                                                   '
	Write-Host ""
	& "beep_lotr.ps1"
}
elseif($artnumber -eq 6)
{
	Write-Host "      _______     "
	Write-Host "     |.-----.|    "
	Write-Host "     ||x . x||    "
	Write-Host "     ||_.-._||    "
	Write-Host "     '--)-(--'    "
	Write-Host "   ___[=== o]___  "
	Write-Host "   |:::::::::::|\ "
	Write-Host "   '-=========-'()"
	Write-Host ""	
	Start-Marquee("What is another name for a computer virus?")
	Start-Marquee("> A terminal illness.")
        Write-Host ""	
}
elseif($artnumber -eq 7)
{
	$type = Get-PC-Type
	Print-Ascii-Art-PC ($type)
	Write-Host ""
	Print-Hardware-Info
	Write-Host ""
}
