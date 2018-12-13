##############################################################################################################
##############################################################################################################
# Horoscopo en español (basado en HoroEsp - Realizado por Joan joanlion@yahoo.es) & Modificado por
# _u2pop_ (u2pop@live.com)
#
# actualizado por Arnold_X-P red irc.dal.net canales #lapaz y #tcls mi correo urquizoandrade@hotmail.com
# Cuando me encontre con este script el mismo ya no funcionaba, por lo que
# me dispuse a ponerlo en funcionamiento. Por suerte se realizaron dos
# modificaciones en el codigo fuente y con eso fue suficiente.
# Cualquier consulta me pueden encontrarme en #Republica_Dominicana o #Ayuda_irc en ChatHispano
#
# Para su funcionamiento es necesario contar con http2.3.tcl
#
##############################################################################################################
##############################################################################################################
#
# Versión del script tcl
#
set shver "2.0"
##############################################################################################################
#
# Uso: !horoscopo <signozodiaco> (donde <signozodiaco> es tu signo zodiacal)
#
# También se puede utilizar /msg nickdelbot !horoscopo <signozodiaco>
#
# Nota: La informacion del horoscopo es suministrada por www.horoscopoFree.Com
#
##############################################################################################################
#Configuración:
##########

# Canales donde funcionara la tcl, (lista separada por espacios)
set shorochans "#cremacamba #tcls"

# Sin considerar los canales de arriba, en esta lista de canales
# el bot respondera via PRIVMSG (privado) al usuario
set shoroquiet ""

# Tiempo de espera a obtener la URL (no cambiar):
set shtout "30000"
##############################################################################################################
package require http 2.3
bind pub - !horoscopo shoro
bind pub - .horoscopo shoro
bind pub - ¡horoscopo shoro
bind pub - !signo shoro
bind pub - .signo shoro
bind pub - ¡signo shoro

bind msg - !horoscopo shoromsg
bind msg - .horoscopo shoromsg
bind msg - !signo shoromsg
bind msg - .signo shoromsg

set shorochans [string tolower $shorochans]
set shoroquiet [string tolower $shoroquiet]

proc shoromsg {nick uhost hand text} {
if {![onchan $nick]} {return}
shoro $nick $uhost $hand privmsg $text
return
}

proc shoro {nick uhost hand chan text} {
set chan [string tolower $chan];
if {([lsearch -exact $::shorochans $chan] == -1) && ($chan != "privmsg")} {return}
if {([lsearch -exact $::shoroquiet $chan] != -1) || ($chan == "privmsg")} {set chan $nick}
set signs "Aries Tauro Geminis Cancer Leo Virgo Libra Escorpio Sagitario Capricornio Acuario Piscis"
set signlc [string tolower $signs]
set text [string trim [string tolower $text]]
set sign [split $text]
if {[lsearch -exact $signlc $sign] == -1} {
puthelp "NOTICE $nick :Signo no Valido los signos validos son: $signs Modo de uso: Ejemplo !horoscopo cancer"
return
} else {
set shurl "http://es.horoscopofree.com/object/html/iframe-sign-$sign"
catch {set page [::http::geturl $shurl -timeout $::shtout]} error
if {[string match -nocase "*couldn't open socket*" $error]} {
puthelp "PRIVMSG $chan :Error: No hay conexion a internet..porfa Intenta mas tarde."
::http::cleanup $page
return
}
if { [::http::status $page] == "timeout" } {
puthelp "PRIVMSG $chan :Error: Conexion fuera de Tiempo."
::http::cleanup $page
return
}
set html [::http::data $page]
::http::cleanup $page
set shout ""
if {[regexp {(.*?)<a href=} $html match shout]} {
set shout [string trim $shout]
regsub -all {\n} $shout {} shout
# word wrapper
set j 0
set shct 0
foreach line [split $shout \n] {
if {$line != ""} {
set len 375
set splitChr " "
set out [set cur {}]; set i 0
foreach word [split $line $splitChr] {
if {[incr i [string len $word]]>$len} {
lappend out [join $cur $splitChr]
set cur [list $word]
set i [string len $word]
incr j
} else {
lappend cur $word
}
incr i
}
lappend out [join $cur $splitChr]
foreach line2 $out {
if {$shct == 0} {
set line2 [linsert $line2 0 \002[string totitle $sign]\002:]
incr shct
if {$j >= 1} {
set line2 [linsert $line2 end \002(con't)\002]
set j [expr $j - 1]
}
} else {
set line2 [linsert $line2 0 \002([string totitle $sign] con't)\002]
if {$j >= 1} {
set line2 [linsert $line2 end \002(con't)\002]
set j [expr $j - 1]
}
}
puthelp "PRIVMSG $chan :$line2"
}
}
}
} else {
puthelp "PRIVMSG $chan :Lo siento, no puedo encontrar tu horoscopo, intentalo mas tarde!!!" -next
}
}
}

putlog "\002horoscopo.tcl $shver por _u2pop_ - Cargado...\002"
