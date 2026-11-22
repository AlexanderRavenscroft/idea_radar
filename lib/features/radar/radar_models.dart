import 'dart:math';

import 'package:idea_radar/features/profiles/profile_category.dart';

enum Institution {
  school('Szkoła'),
  university('Uczelnia'),
  council('Samorząd'),
  publicBody('Instytucja publiczna');

  final String label;
  const Institution(this.label);
}

enum IdeaStage {
  concept('Koncepcja'),
  prototype('Prototyp'),
  pilot('Pilotaż'),
  deployed('W użyciu');

  final String label;
  const IdeaStage(this.label);
}

enum Support {
  mentor('Ekspertyza', 'Konsultacja pomysłu, pomiarów lub planu rozwoju.'),
  technical(
    'Pomoc techniczna',
    'Wsparcie w budowie, integracji lub testach rozwiązania.',
  ),
  pilot(
    'Miejsce do pilotażu',
    'Instytucja, w której można sprawdzić rozwiązanie w praktyce.',
  ),
  deployment(
    'Pomoc we wdrożeniu',
    'Wsparcie w dostosowaniu i uruchomieniu rozwiązania.',
  ),
  funding(
    'Dofinansowanie',
    'Środki na rozwój, sprawdzenie lub wdrożenie rozwiązania.',
  );

  final String label;
  final String description;

  const Support(this.label, this.description);
}

enum InnovationType {
  process('Procesowa'),
  social('Społeczna'),
  education('Edukacyjna'),
  technology('Technologiczna'),
  organization('Organizacyjna');

  final String label;
  const InnovationType(this.label);
}

enum Criterion {
  impact('Wpływ', 30, [
    'Brak opisu',
    'Problem opisany',
    'Znany odbiorca',
    'Zdefiniowano miernik',
  ]),
  evidence('Dowody', 20, [
    'Brak danych',
    'Obserwacja',
    'Próba z odbiorcami',
    'Wyniki porównane',
  ]),
  readiness('Gotowość', 20, [
    'Sam pomysł',
    'Zarys rozwiązania',
    'Działa prototyp',
    'Sprawdzono w praktyce',
  ]),
  transfer('Transfer', 30, [
    'Zależy od miejsca',
    'Możliwa adaptacja',
    'Znane warunki',
    'Gotowa instrukcja',
  ]);

  final String label;
  final int weight;
  final List<String> levels;

  const Criterion(this.label, this.weight, this.levels);
}

class RadarIdea {
  final String id;
  final String ownerId;
  final String author;
  final String title;
  final int categoryId;
  final Institution institution;
  final String organization;
  final String city;
  final InnovationType type;
  final IdeaStage stage;
  final Support support;
  final String supportDetails;
  final String contactEmail;
  final String problem;
  final String solution;
  final String evidence;
  final String metric;
  final List<int> ratings;
  final bool published;

  const RadarIdea({
    required this.id,
    required this.ownerId,
    required this.author,
    required this.title,
    required this.categoryId,
    required this.institution,
    required this.organization,
    required this.city,
    required this.type,
    required this.stage,
    required this.support,
    required this.contactEmail,
    this.supportDetails = '',
    required this.problem,
    required this.solution,
    required this.evidence,
    required this.metric,
    required this.ratings,
    required this.published,
  });

  factory RadarIdea.fromRow(Map<String, dynamic> row) {
    return RadarIdea(
      id: row['id'] as String,
      ownerId: row['owner_id'] as String,
      author: row['author'] as String,
      title: row['title'] as String,
      categoryId: row['category_id'] as int,
      institution: Institution.values.byName(row['institution'] as String),
      organization: row['organization'] as String,
      city: row['city'] as String,
      type: InnovationType.values.byName(row['innovation_type'] as String),
      stage: IdeaStage.values.byName(row['stage'] as String),
      support: Support.values.byName(row['support'] as String),
      supportDetails: (row['support_details'] as String? ?? '').trim(),
      contactEmail: (row['contact_email'] as String? ?? '').trim(),
      problem: row['problem'] as String,
      solution: row['solution'] as String,
      evidence: row['evidence'] as String,
      metric: row['metric'] as String,
      ratings: List<int>.unmodifiable(row['ratings'] as List),
      published: row['published'] as bool,
    );
  }

  Map<String, Object> toRow() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'category_id': categoryId,
      'institution': institution.name,
      'organization': organization,
      'city': city,
      'innovation_type': type.name,
      'stage': stage.name,
      'support': support.name,
      'support_details': supportDetails,
      'contact_email': contactEmail,
      'problem': problem,
      'solution': solution,
      'evidence': evidence,
      'metric': metric,
      'ratings': ratings,
      'published': published,
    };
  }

  int get score {
    final weighted = Criterion.values.fold<int>(
      0,
      (sum, criterion) => sum + criterion.weight * ratings[criterion.index],
    );
    return (weighted / 3).round();
  }

  ({String title, String reason, String measure}) get pathway {
    if (ratings[Criterion.evidence.index] <= 1) {
      return (
        title: 'Zweryfikuj potrzebę',
        reason: 'Poziom dowodów jest niski. Zbierz punkt odniesienia, a potem sprawdź rozwiązanie z odbiorcami.',
        measure: 'Udział odbiorców, którzy potwierdzili potrzebę.',
      );
    }
    if (ratings[Criterion.readiness.index] < 2 || stage == IdeaStage.concept) {
      return (
        title: 'Zbuduj mały prototyp',
        reason: 'Potrzeba jest udokumentowana. Przygotuj najmniejszą wersję, która pozwoli sprawdzić działanie.',
        measure: 'Odsetek osób, które samodzielnie wykonały zadanie.',
      );
    }
    if (ratings[Criterion.transfer.index] < 2 || stage == IdeaStage.prototype) {
      return (
        title: 'Uruchom pilotaż w drugiej instytucji',
        reason: 'Rozwiązanie ma podstawy do próby. Spisz wymagane zasoby i poproś drugą instytucję o odtworzenie procesu.',
        measure: 'Zmiana miernika między stanem wyjściowym a końcem pilotażu.',
      );
    }
    if (support == Support.funding && type == InnovationType.technology) {
      return (
        title: 'Sprawdź model komercjalizacji',
        reason: 'Są dowody, gotowość i warunki transferu. Z partnerem finansującym zweryfikuj koszty, popyt i prawa do rozwiązania.',
        measure:
            'Koszt wdrożenia w jednej organizacji i liczba deklaracji udziału.',
      );
    }
    return (
      title: 'Przygotuj pakiet wdrożeniowy',
      reason: 'Dowody, gotowość i warunki transferu pozwalają przejść do adaptacji. Spisz instrukcję, zasoby i kryteria powodzenia.',
      measure:
          'Liczba instytucji, które powtórzyły wdrożenie według instrukcji.',
    );
  }
}

class RadarData {
  final List<ProfileCategory> categories;
  final List<RadarIdea> ideas;
  final List<RadarIdea> own;
  final List<RadarIdea> favorites;

  const RadarData({
    required this.categories,
    required this.ideas,
    required this.own,
    required this.favorites,
  });

  RadarData withFavorite(RadarIdea idea, bool saved) {
    return RadarData(
      categories: categories,
      ideas: ideas,
      own: own,
      favorites: [
        if (saved) idea,
        ...favorites.where((favorite) => favorite.id != idea.id),
      ],
    );
  }

  String category(int id) {
    return categories
            .where((category) => category.id == id)
            .firstOrNull
            ?.name ??
        'Innowacja';
  }

  Iterable<RadarIdea> get corpus sync* {
    final seen = <String>{};
    for (final idea in [...ideas, ...own, ...favorites]) {
      if (idea.published && seen.add(idea.id)) yield idea;
    }
  }
}

String newRadarId() {
  final random = Random.secure();
  String section(int length) {
    return List.generate(
      length,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }

  return '${section(8)}-${section(4)}-4${section(3)}-'
      '${(8 + random.nextInt(4)).toRadixString(16)}${section(3)}-${section(12)}';
}
