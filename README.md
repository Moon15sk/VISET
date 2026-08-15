Viset — PoC antivirus (project skeleton)

Toto repo obsahuje PoC a sprievodné nástroje pre projekt "Viset": minimálny minifilter driver (driver/), používateľskú službu a skener (user/), Python GUI (gui/) a pomocné inštalačné skripty.

Dôležité upozornenia
- Toto je proof-of-concept (PoC). Kernel driver (minifilter) je iba ukážka a nie je určený pre produkčné nasadenie.
- Nasadzovanie alebo testovanie kernel driverov vyžaduje Test-Signing alebo podpísaný driver a administrátorské práva. Testujte vždy v izolovanom VM.
- Nikdy neposielajte citlivé informácie, súkromné kľúče alebo certifikáty do repozitára.

Obsah priečinka
- driver/         — zdrojový kód minifilter PoC
- user/           — jednoduchý skener a demo služba (C++)
- gui/            — Python GUI (CustomTkinter), build_exe.ps1 pre PyInstaller
- installer/      — inštalačné PowerShell skripty a inštrukcie
- uninstall_viset.py — skript na odinštalovanie komponentov

Rýchly návod na zostavenie GUI EXE
1) Otvorte PowerShell v "gui/" a spustite build skript:
   PowerShell -NoProfile -ExecutionPolicy Bypass -File .\build_exe.ps1
   (Skript vytvorí .venv, nainštaluje dependencie a spustí PyInstaller. Pozrite si výstup v gui\dist.)

2) Ak chcete, aby EXE mal vlastnú ikonu, umiestnite vizuálne logo ako gui/assets/viset_logo.png.
   build_exe.ps1 sa pokúsi vygenerovať gui/assets/viset_icon.ico a použiť ho pre PyInstaller, ak máte Python+Pillow.

Driver a bezpečnosť
- Ak plánujete testovať driver, prečítajte si inštrukcie v installer/ a dodržte Test-Signing postupy. Nepoužívajte unsigned drivery na produkte.
- Podpis bináriek: pre distribúciu podpisujte exe a driver s platným certifikátom.

Ako nahrať na GitHub
1) Vytvorte nový repozitár na GitHub (napr. "viset").
2) Na lokále v priečinku s projektom:
   git init
   echo "venv/" > .gitignore
   echo "build/" >> .gitignore
   echo "dist/" >> .gitignore
   echo "__pycache__/" >> .gitignore
   git add .
   git commit -m "Initial import of Viset PoC"
   git remote add origin https://github.com/YOUR_USERNAME/viset.git
   git branch -M main
   git push -u origin main

Odporúčania pred pushom
- Skontrolujte, či v súboroch nie sú citlivé údaje (heslá, certifikáty, súkromné kľúče).
- Odstráňte veľké binárne súbory a virtuálne prostredia z commitu (.venv, build/, dist/).
- Testujte zostavené EXE v izolovanom VM a podpisujte binárky pred distribúciou.

Licencia
Tento projekt obsahuje priloženú MIT licenciu (LICENSE).

Kontakt
Ak potrebujete pomoc s buildom alebo prípravou release (ikonka, uninstaller EXE), otvorte issue alebo napíšte popis požiadavky v repozitári.
