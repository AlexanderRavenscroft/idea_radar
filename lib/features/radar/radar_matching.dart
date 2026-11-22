import 'radar_models.dart';

typedef SimilarIdea = ({RadarIdea idea, List<String> shared, int score});

String normalized(String text) {
  const polish = 'ąćęłńóśźż';
  const ascii = 'acelnoszz';
  var result = text.toLowerCase();
  for (var index = 0; index < polish.length; index++) {
    result = result.replaceAll(polish[index], ascii[index]);
  }
  return result;
}

Set<String> _terms(String value) {
  const common = {
    'oraz',
    'przez',
    'ktore',
    'ktory',
    'ktora',
    'moga',
    'jest',
    'tego',
    'zeby',
    'dzieki',
    'pomysl',
    'rozwiazanie',
    'korzystac',
    'system',
  };
  return RegExp(r'[a-z0-9]{4,}')
      .allMatches(normalized(value))
      .map((match) => match.group(0)!)
      .where((word) => !common.contains(word))
      .toSet();
}

List<SimilarIdea> similarIdeas(RadarIdea source, Iterable<RadarIdea> corpus) {
  final titleTerms = _terms(source.title);
  final sourceTerms = _terms(
    '${source.title} ${source.problem} ${source.solution}',
  );
  final matches = <SimilarIdea>[];
  for (final idea in corpus) {
    if (idea.id == source.id) continue;
    final shared = sourceTerms.intersection(
      _terms('${idea.title} ${idea.problem} ${idea.solution}'),
    );
    final titleOverlap = titleTerms.intersection(_terms(idea.title)).length;
    if (shared.length < 2 && titleOverlap == 0) continue;
    final score =
        shared.length +
        2 * titleOverlap +
        (source.categoryId == idea.categoryId ? 2 : 0);
    matches.add((idea: idea, shared: shared.take(5).toList(), score: score));
  }
  return matches..sort((a, b) => b.score.compareTo(a.score));
}
