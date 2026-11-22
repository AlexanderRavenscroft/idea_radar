import 'package:flutter/material.dart';

import 'idea_editor.dart';
import 'radar_models.dart';
import 'radar_scope.dart';
import 'radar_widgets.dart';

class RadarIntake extends StatelessWidget {
  static const _prompts = {
    Institution.school: (
      where: 'Samorząd uczniowski, biblioteka, projekty klasowe i nauczyciele prowadzący zajęcia dodatkowe.',
      ask: 'Co usprawniło naukę, dostępność albo dobrostan? Czy inna klasa może spróbować tego samego?',
    ),
    Institution.university: (
      where: 'Koła naukowe, laboratoria, projekty zaliczeniowe i biuro transferu technologii.',
      ask: 'Jaki prototyp istnieje i na czym go sprawdzono? Kto mógłby go użyć poza uczelnią?',
    ),
    Institution.council: (
      where: 'Punkty obsługi mieszkańca, konsultacje, jednostki komunalne i zespoły usprawniające usługi.',
      ask: 'Która zmiana skróciła obsługę lub zmniejszyła liczbę błędów? Jak zmierzyć efekt w innej gminie?',
    ),
    Institution.publicBody: (
      where: 'Zespoły pierwszego kontaktu, biblioteki, domy kultury i lokalne placówki usługowe.',
      ask: 'Jaki problem pracownicy codziennie obchodzą własnym sposobem? Czy da się ten proces opisać i powtórzyć?',
    ),
  };

  const RadarIntake({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skan instytucji')),
      body: RadarLoad(
        builder: (context, data) {
          return RadarList(
            children: [
              const Text(
                'Wybierz miejsce, w którym szukasz pomysłów do zgłoszenia.',
              ),
              const SizedBox(height: 14),
              for (final institution in Institution.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: RadarPanel(
                    padding: EdgeInsets.zero,
                    child: ExpansionTile(
                      shape: const Border(),
                      leading: Icon(institutionIcon(institution)),
                      title: Text(
                        institution.label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: [
                        Text(_prompts[institution]!.where),
                        const SizedBox(height: 8),
                        Text(_prompts[institution]!.ask),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton(
                            onPressed: data.categories.isEmpty
                                ? null
                                : () => openRadarScreen<void>(
                                    context,
                                    IdeaEditor(institution: institution),
                                  ),
                            child: const Text('Zgłoś znalezisko'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
