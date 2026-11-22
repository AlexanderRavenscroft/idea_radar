# Radar Innowacji

Radar Innowacji pomaga zauważyć usprawnienia powstające w szkołach, uczelniach, samorządach i innych instytucjach publicznych. Autor opisuje problem, odbiorców i dowody, a inna instytucja może znaleźć podobny pomysł i skontaktować się z autorem w sprawie pilotażu, wdrożenia lub innego wsparcia.

## Od rozpoznania do kolejnego kroku

1. **Rozpoznanie.** Skan instytucji podpowiada, gdzie szukać pomysłów i jakie pytania zadać. Z wybranego typu instytucji można przejść do zgłoszenia.
2. **Zgłoszenie.** Dwustopniowy formularz zbiera opis problemu, rozwiązania, dowodów i miernika sukcesu. Autor określa potrzebne wsparcie i podaje e-mail kontaktowy. Kartę można zapisać jako prywatny szkic, opublikować, edytować lub wycofać do szkiców.
3. **Ocena.** Autor wybiera poziomy czterech kryteriów. Aplikacja pokazuje wynik, uzasadnienie rekomendowanego kroku i sugerowany miernik.
4. **Katalog.** Zgłoszenia można przeglądać na liście albo przesuwać jako karty. Gest w prawo dodaje kartę do ulubionych. Wyszukiwarka i filtry pozwalają zawęzić katalog według tekstu, dziedziny, etapu i zainteresowań z profilu.
5. **Porównanie i kontakt.** Sekcja podobnych zgłoszeń wskazuje wspólne słowa. W szczegółach widać potrzebne wsparcie i adres autora z opcją kopiowania.

## Reguły oceny i podobieństwa

- **Samoocena potencjału.** Każde kryterium ma opisane poziomy od 0 do 3. Wpływ ma wagę 30%, dowody 20%, gotowość 20%, a transfer 30%. Wynik to ważona suma przeliczona na skalę 0–100.
- **Ścieżka rozwoju.** Reguły sprawdzają kolejno dowody, gotowość i etap, warunki transferu, a następnie typ innowacji i rodzaj wsparcia. Wynikiem jest weryfikacja potrzeby, budowa prototypu, drugi pilotaż, sprawdzenie modelu komercjalizacji albo przygotowanie pakietu wdrożeniowego.
- **Podobne zgłoszenia.** Porównanie obejmuje tytuł, problem i rozwiązanie w opublikowanych kartach. Po uproszczeniu polskich znaków każde wspólne słowo daje punkt, zgodność w obu tytułach daje dodatkowe dwa punkty, a wspólna dziedzina daje dwa punkty. Do rankingu potrzeba dwóch wspólnych słów lub jednego słowa w obu tytułach.

## Uruchomienie

1. Użyj Fluttera 3.47 i Dart 3.13.5.
2. W Supabase przygotuj logowanie Google i schemat opisany poniżej. Identyfikatory klienta OAuth dopasuj do platformy, identyfikatora aplikacji i podpisu buildu.
3. Skopiuj `.env.example` do `.env`. Ustaw `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` oraz identyfikatory Google z przykładu. Plik jest pakowany do aplikacji, więc użyj wartości przeznaczonych dla klienta.
4. Uruchom na urządzeniu lub emulatorze.

```sh
flutter pub get
flutter run
```

### Kontrakt Supabase

| Dane       | Kontrakt                                                                                                                                                                                                                                              |
| ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Kategorie  | `categories` z polami `id` i `name` odczytywanymi przez użytkowników po zalogowaniu.                                                                                                                                                                  |
| Profile    | RPC `get_my_profile` i `complete_profile_setup` odczytują oraz zapisują własny profil. Dane zawierają imię i nazwisko, bio i tablicę identyfikatorów kategorii.                                                                                       |
| Zgłoszenia | `radar_ideas` zawiera autora i właściciela, dziedzinę, opis, etap, rodzaj wsparcia, `support_details`, `contact_email`, cztery oceny i status publikacji. Właściciel odczytuje i edytuje własne szkice. Inni zalogowani odczytują opublikowane karty. |
| Ulubione   | `radar_favorites` wiąże `user_id` z `idea_id`. Zapis jest prywatny, a para jest unikalna.                                                                                                                                                             |

### Diagnostyka Androida

W buildach debug i profile logi `[RADAR]` pokazują etapy uruchamiania, inicjalizację Supabase, odczyt sesji, czasy pobierania danych i pomiary pierwszych klatek.

```sh
"$HOME/Android/Sdk/platform-tools/adb" logcat -v time -s flutter:I AndroidRuntime:E
```

Na linuksowym AVD użytym do nagrania zimny start ze SwiftShader wygląda tak.

```sh
"$HOME/Android/Sdk/emulator/emulator" -avd Medium_Phone_API_37.0 -no-snapshot -gpu swiftshader
```

## Dane i wdrożenie

- Karty i oceny są deklaracjami użytkowników. Dane pokazowe w materiałach są fikcyjne. Autor wpisuje adres widoczny na opublikowanej karcie, a Google obsługuje logowanie.
- Podobieństwo opiera się na zgodności słów. Synonimy i różne formy fleksyjne mogą dać różne wyniki. Aplikacja pobiera do 100 pozycji na każdą listę i porównuje wczytane karty. Źródłem porównań jest katalog Supabase.
- Większy pilotaż może korzystać z API Supabase. Kolejne kroki to wyszukiwanie po stronie serwera, paginacja, moderacja zgłoszeń i weryfikacja organizacji.
- Proponowane miary pilotażu to odsetek kompletnych kart, czas do pierwszego kontaktu zgłoszony przez autora i liczba rozwiązań sprawdzonych w drugiej instytucji.

## Materiały HackNation 2026

- [Prezentacja PDF, 10 slajdów](konkurs/Radar-Innowacji.pdf)
- [Film z działania aplikacji, 1:35](konkurs/Radar-Innowacji-demo.mp4)
