# Herr der Ringe Titelmusik mit Beep-Befehlen
# Quelle: [5](https://github.com/Duelr/Play-Notes)

# Die Noten und Frequenzen definieren
# https://pages.mtu.edu/~suits/notefreqs.html
$Notes = @{
    C4 = 261.63
    D4 = 293.66
    E4 = 329.63
    F4 = 349.23
    F4s = 370.00
    G4 = 392.00
    A4 = 440.00
    B4 = 493.88
    C5 = 523.25
    D5 = 587.33
    E5 = 659.25
    F5 = 698.46
    F5s = 739.99
    G5 = 783.99
    A5 = 880.00
    B5 = 987.77
    C6 = 1046.50
    D6 = 1174.66
    E6 = 1318.51
    F6 = 1396.91
    G6 = 1567.98
    A6 = 1760.00
    B6 = 1975.53
    C7 = 2093.00
    R0 = 0
}

# Die Länge der Noten in Millisekunden definieren
$Lengths = @{
    H = 1600 # Halbe Note
    Q = 800 # Viertelnote
    E = 400 # Achtelnote
    S = 200 # Sechzehntelnote
    S3 = 133
}

# Die Melodie als eine Liste von Noten und Längen definieren
# https://flat.io/score/5fa9a56c6b164639a7987e2f-lord-of-the-rings-the-shire-piano
$Melody = @(
    @{ Note = "D5"; Length = "S" }
    @{ Note = "E5"; Length = "S" }
    @{ Note = "F5s"; Length = "Q" }
    @{ Note = "A5"; Length = "Q" }
    @{ Note = "F5s"; Length = "Q" }
    @{ Note = "E5"; Length = "S3" }
    @{ Note = "F5s"; Length = "S3" }
    @{ Note = "E5"; Length = "S3" }
    @{ Note = "D5"; Length = "H" }
)

# Die Melodie abspielen
foreach ($Note in $Melody) {
    # Die Frequenz und die Dauer der Note aus den HashTables abrufen
    $Frequency = $Notes[$Note.Note]
    $Duration = $Lengths[$Note.Length]

    # Die Note mit dem Beep-Befehl abspielen
    [console]::beep($Frequency, $Duration)
}
