function sound_td, RH, T
; RH passed in as %
; T in C

A = 17.625
B = 243.04

gma = alog(0.01*RH) + a*T/(b+T)

return, b*gma/(a-gma)
end