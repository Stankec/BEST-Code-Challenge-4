
#Razlike u implementaciji algoritma u Pythonu i Rubyu
Prilikom prevođenja algoritma iz Python skripte u web aplikaciju, morali smo promjeniti logički pristup izgradnji odnosa između filmova, što je dovelo do sitnih preinaka algoritma, radi boljeg rada s bazom podataka. Izračun korelacije je sada najskuplji dio učenja baze, zbog velikog broja sql upita koji se moraju obaviti. Upravo iz tog razloga smo se odlučili implementirati višedretvenost prilikom izračuna korelacija. Kako je izračun tablice svakog ruba grafa neovisan o drugim rubovima, takvo rješenje je bilo idealno za višestruko povećanje brzine. Same tablice pamtimo kao obične float vrijednosti, te se time ubrzava množenje, jer algoritam ne mora baratati listama.

##Prikaz dobivenih rezultata
