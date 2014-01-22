#Bayesove mreže i njihova primjena u preporučivanju filmova
  
##Što su Bayesove mreže
Bayesova mreža je statistički model u obliku grafa koji predstavlja odnose nasumičnih varijabli. Svaki čvor grafa sadrži u sebi tablicu vjerojatnosti koja opisuje odnose varijabli koje ulaze u čvor i vrijednosti koja izlazi iz čvora. Izračun Bayesove mreže nam daje lagani odgovor na pitanja uvjetne vjerojatnosti poput: Ako znamo da je trava mokra, pada li kiša? Najpoznatiji primjer se odnosi upravo na to, i ovdje je prikazan s ispunjenim vjerojatnosnim tablicama:

![Sprinkler-Rain-Grass](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/SimpleBayesNet.svg/400px-SimpleBayesNet.svg.png "Najpoznatiji primjer Bayesove mreže.")

##Glavni problemi
* Kao što se iz slike vidi, vjerojatnosna tablica u svakom čvoru ovisi o broju ulaznih varijabli, i to `2^n`, gdje je n broj ulaznih varijabli. Za film koji je povezan sa samo 10 filmova tablica bi imala 1024 člana, a ako se uzme da minimalno obrađujemo 16 000 filmova, računanje takvih tablica postaje jako složeni problem.
* Drugi problem koji klasične Bayesove mreže nameću je činjenica da su one usmjereni aciklički grafovi, tj. svaki rub grafa ima strogo zadani smjer u kojem djeluje, što nema smisla za filmove, jer ako se u bazu prvo unese da se korisniku A sviđa film B, nema razloga čekati da se nekom drugom korisniku svidi film B, pa potom film A da bi se ostvarila obostrana veza. Također, takva redundancija udvostručava bazu podataka i usporava izračun.
* Izračun Bayesove mreže postaje sve teži problem što više odnosa dodajemo, postojeći algoritmi koji daju posve točno rješenje zahtjevaju sve kompliciranije izračune, a nama je trebalo nešto što brzo i jednostavno što može izračunati cijelu mrežu relativno brzo, makar imalo pogrešku od 1-2% nakon izračuna.

##Rješenje
Klasična implementacija Bayesove mreže očito ne bi odgovarala onome što smo željeli postići, te smo morali modificirati strukturu podataka i metodu izračuna mreže za naš specifični slučaj. Prilikom izračuna jednostavne ovisnosti, u kojem izlaz čvora ovisi samo o jednoj ulaznoj varijabli primjećuje se da je izlazna vrijednost jednaka matričnom množenju, za graf:  
![Graf](http://i.imgur.com/DKpcVu1.png)  
![Vjerojatnost čvora A](http://i.imgur.com/kFWzKOX.png)  
![Vjerojatnost čvora B je ovisna o A](http://i.imgur.com/RWozMbP.png)  
Rješenje čvora B se dobiva matričnima množenjem A i B:  
![Množenje](http://i.imgur.com/07ECucM.png)  
Ova relacija vrijedi isključivo za slučajeve kada B kao ulaz ima samo jednu varijablu, što vodi do restrikcije na strukturu podataka: sve vjerojatnosne tablice moraju biti dimenzija 2x2.

Ta restrikcija vodi do rješenja strukture podataka. Umjesto da pamtimo veliku tablicu odnosa unutar čvora, rubovi koji vode do čvora će pamtiti tablicu 2x2 koja pamti kako se dva čvora koja povezuje odnose. Čvor treba pamiti samo tablicu 1x2 koja označava koliko se korisniku sviđa taj film, bazirano na direktnoj ocjeni koju je sam zadao. Prilikom izračuna mreže samo se treba pomnožiti vrijednost zapisana u čvoru s vrijednošću u rubu da bi se dobila vjerojatnost da će se korisniku sviđati film s kojim je povezan. Npr.:  
![Graf A,B,C](http://i.imgur.com/txVffTp.png)  
Rub (A,B) ima u sebi zapisanu tablicu:  
![Rub A,B](http://i.imgur.com/RmgLpxK.png)  
Rub (B,C) ima tablicu:  
![Rub B,C](http://i.imgur.com/qE4fygU.png)  

Korisnik se izjasni da mu je film A savršen, tj. vrijednost u čvoru A je:
![A](http://i.imgur.com/31ZqMFs.png)  
množimo tu matricu s matricom u rubu (A,B) i dobivamo:
![B](http://i.imgur.com/iBclk2R.png)  
te tu vrijednost koristimo kao šansu da korisnik voli film B, i njome množimo vrijednost ruba (B,C), te time dobivamo šansu da korisnik voli film C:
![C](http://i.imgur.com/HXsspNL.png)  

Još se pojavljuje problem dvosmjernosti. Ako pogledamo što redci i stupci u tablicama zapravo znače uočavamo da ako transponiramo tablicu dobivamo obrnute ovisnosti, što je metoda koja se primjenjuje u algoritmu eliminacije varijabli prilikom rješavanja klasičnih Bayesovih mreža. Međutim, tu se pojavljuje problem da nakon množenja zbroj vrijednosti u matrici 1x2 nije uvijek nužno 1.0 što bi kao vjerojatnosni odnos trebala biti. Zato se radi normalizacija vrijednosti nakon svakog množenja, da bi osigurali koherentnost sustava. Ovaj dio metode je direktno uzet iz algoritma za eliminaciju varijabli prilikom računanja mreža kada se zna posljedica, a ispituje premisa. 
![Transponiranost](http://i.imgur.com/VIrWIBl.png)  
Do ovog trenutka je riješenje bilo koje mreže savršeno usklađeno s drugim algoritmima, ali se mogu riješavati samo grafovi kod kojih niti jedan čvor nema više od jednog ulaza. Taj problem je eliminiran koristeći superpoziciju filmova za koje se zna korisnička preferenca. Prvo se riješi mreža za prvi od filmova za kojeg se korisnik izjasnio, pa drugi i tako dalje do zadnjeg. Zatim se izračuna nova vjerojatnost za svaki čvor u mreži koji ima više od jednog unosa. Ovaj dio čini ukupni algoritam nepreciznim, ali je greška dovoljno malena da se može zanemariti.  
![Dva unosa](http://i.imgur.com/ptWPahT.png)  
![Izračun](http://i.imgur.com/r7oMMX9.png)  
Međutim ova vrijednost očitno nije u zbroju 1, te se mora normalizirati što nam u konačnici daje: 
![Finalno rješenje](http://i.imgur.com/gRbshnW.png)  
Ova metoda izračuna daje grešku, ali nedovoljno veliku da pomakne rezultate. 