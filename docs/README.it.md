# BatteryInside

[中文](../README.md) · [English](README.en.md) · [日本語](README.ja.md) · [Français](README.fr.md) · [Italiano](README.it.md)

![Anteprima di BatteryInside nella barra dei menu](images/hero.svg)

BatteryInside è un indicatore macOS leggero e di sola lettura che mostra percentuale, livello residuo e stato di alimentazione in un'unica icona compatta.

Autore: Guo Peng (郭鹏)

## Installazione in tre passaggi

![Scaricare il DMG, trascinare l'app in Applicazioni e aprirla](images/install.svg)

1. Scarica l'ultimo file `BatteryInside-versione.dmg` dalla pagina [Releases](/guopengnaivoc/battery-inside/releases/latest).
2. Apri il DMG e trascina BatteryInside in Applicazioni.
3. Apri BatteryInside da Finder → Applicazioni. L'indicatore apparirà nella barra dei menu.

### Se macOS blocca il primo avvio

![Aprire in sicurezza un'app non firmata: non spostarla nel Cestino, quindi usare Apri comunque in Privacy e sicurezza](images/open-anyway.svg)

La versione pubblica attuale usa una firma ad hoc e non è autenticata con Apple Developer ID. Se macOS comunica che lo sviluppatore non può essere verificato:

1. Prova ad aprire l'app una volta e chiudi l'avviso.
2. Apri Impostazioni di Sistema → Privacy e sicurezza.
3. Nella sezione Sicurezza trova il messaggio relativo a BatteryInside e fai clic su Apri comunque.

Fallo solo per un pacchetto scaricato dalla Release GitHub ufficiale e con checksum SHA-256 corrispondente. Non disattivare Gatekeeper globalmente.

Se macOS dichiara esplicitamente che l'app danneggerà il computer, rileva malware o segnala che il file è danneggiato, fermati e scaricalo di nuovo; non fare clic su Apri comunque. Il pulsante è normalmente disponibile per circa un'ora dopo il primo tentativo di avvio.

Riferimento: [guida ufficiale Apple per aprire un'app ignorando le impostazioni di sicurezza](https://support.apple.com/guide/mac-help/open-an-app-by-overriding-security-settings-mh40617/mac).

## Stato a colpo d'occhio

![Colori della batteria e stati di alimentazione](images/status.svg)

- 30% o più: barra di riempimento bianca
- 10%–29%: barra di riempimento arancione
- 9% o meno: barra di riempimento rossa
- In carica: fulmine
- Collegato all'alimentazione ma non in carica: spina
- Dati non disponibili: `--`

La larghezza del riempimento segue continuamente il livello: `20,8 pt × percentuale`. Ogni 1% equivale a circa `0,208 pt`, disegnato in subpixel da Core Graphics, quindi non servono 100 pixel interi. Il numero mostra il valore esatto e la barra offre una stima visiva. Bordo e terminale seguono `labelColor` di macOS; testo e simboli sono neri sopra il riempimento e usano il colore di sistema sopra la zona vuota.

Lo stato di alimentazione viene determinato usando esclusivamente i valori macOS espliciti `Is Charging`, `Power Source State` e `Is Charged`.

## Impostazioni e sostituzione dell'icona di sistema

![Aprire le impostazioni e nascondere facoltativamente l'icona Apple](images/settings.svg)

L'indicatore nella barra dei menu è di sola lettura e non reagisce ai clic. Per modificare le impostazioni, riapri BatteryInside da Finder → Applicazioni. Puoi attivare l'avvio al login, gli avvisi al 20% e al 10%, uscire o disinstallare l'app in sicurezza.

Per mantenere soltanto BatteryInside nella barra dei menu:

- macOS recente: Impostazioni di Sistema → Barra dei menu → Controlli della barra dei menu → Batteria
- macOS 13–15: Impostazioni di Sistema → Centro di Controllo → Batteria → disattiva Mostra nella barra dei menu

Questo non elimina né modifica le funzioni batteria di macOS. Riattiva l'opzione nello stesso punto per ripristinare l'icona Apple.

### Posizionare BatteryInside a destra delle altre icone delle app

![Tenere premuto Command e trascinare BatteryInside](images/position.svg)

1. Tieni premuto `Command (⌘)`.
2. Senza rilasciarlo, trascina BatteryInside nella barra dei menu con il mouse o il trackpad.
3. Rilascialo a destra delle altre icone delle app di terze parti.

BatteryInside usa un identificatore stabile per memorizzare la posizione, quindi macOS ripristina il punto scelto dopo la riapertura dell'app, il riavvio del Mac o un aggiornamento. Esegui questa operazione una volta dopo la prima installazione su ogni Mac. Orologio, Centro di Controllo e indicatori della privacy occupano posizioni riservate al sistema; un'app non può spostarsi alla loro destra.

## Requisiti e privacy

- macOS 13 o successivo
- Mac Apple silicon e Intel
- Nessun accesso alla rete, analisi o raccolta dati

## Copyright

Copyright © 2026 郭鹏. Al momento non è inclusa alcuna licenza open source; la visibilità pubblica non concede il permesso di copiare, modificare o ridistribuire il codice.
