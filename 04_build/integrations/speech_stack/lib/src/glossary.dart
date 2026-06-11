import 'transcript_contract.dart';

enum GlossaryLayer {
  foundation,
  company,
  session;

  int get priority => switch (this) {
    GlossaryLayer.foundation => 0,
    GlossaryLayer.company => 1,
    GlossaryLayer.session => 2,
  };
}

class GlossaryTerm {
  GlossaryTerm({
    required this.canonical,
    required this.layer,
    Iterable<String> aliases = const <String>[],
  }) : aliases = Set<String>.unmodifiable(<String>{canonical, ...aliases});

  final String canonical;
  final GlossaryLayer layer;
  final Set<String> aliases;
}

class JargonGlossary {
  JargonGlossary(Iterable<GlossaryTerm> terms)
    : _terms = List<GlossaryTerm>.unmodifiable(terms) {
    _validate();
  }

  factory JargonGlossary.empty() => JargonGlossary(const <GlossaryTerm>[]);

  factory JargonGlossary.threeLayer({
    Iterable<GlossaryTerm> foundation = const <GlossaryTerm>[],
    Iterable<GlossaryTerm> company = const <GlossaryTerm>[],
    Iterable<GlossaryTerm> session = const <GlossaryTerm>[],
  }) {
    return JargonGlossary(<GlossaryTerm>[
      ...foundation.map(
        (term) => term._copyWithLayer(GlossaryLayer.foundation),
      ),
      ...company.map((term) => term._copyWithLayer(GlossaryLayer.company)),
      ...session.map((term) => term._copyWithLayer(GlossaryLayer.session)),
    ]);
  }

  final List<GlossaryTerm> _terms;

  List<GlossaryTerm> get terms => _terms;

  List<GlossaryHit> findHits(String text) {
    return _selectMatches(text)
        .map(
          (match) => GlossaryHit(
            term: match.term.canonical,
            normalizedTerm: match.matchedText,
            source: match.term.layer.name,
          ),
        )
        .toList(growable: false);
  }

  String repairText(String text) {
    final matches = _selectMatches(text);
    if (matches.isEmpty) {
      return text.trim();
    }

    final buffer = StringBuffer();
    var cursor = 0;
    for (final match in matches) {
      if (match.start > cursor) {
        buffer.write(text.substring(cursor, match.start));
      }
      buffer.write(match.term.canonical);
      cursor = match.end;
    }
    if (cursor < text.length) {
      buffer.write(text.substring(cursor));
    }
    return _collapseWhitespace(buffer.toString());
  }

  List<_GlossaryMatch> _selectMatches(String text) {
    final candidates = <_GlossaryMatch>[];
    for (final term in _terms) {
      for (final alias in term.aliases) {
        if (alias.trim().isEmpty) {
          continue;
        }
        final pattern = RegExp(RegExp.escape(alias), caseSensitive: false);
        for (final match in pattern.allMatches(text)) {
          if (!_hasTokenBoundary(text, match.start, match.end)) {
            continue;
          }
          candidates.add(
            _GlossaryMatch(
              term: term,
              matchedText: text.substring(match.start, match.end),
              start: match.start,
              end: match.end,
            ),
          );
        }
      }
    }

    candidates.sort((left, right) {
      final start = left.start.compareTo(right.start);
      if (start != 0) {
        return start;
      }
      final length = (right.end - right.start).compareTo(left.end - left.start);
      if (length != 0) {
        return length;
      }
      return right.term.layer.priority.compareTo(left.term.layer.priority);
    });

    final selected = <_GlossaryMatch>[];
    var cursor = -1;
    for (final candidate in candidates) {
      if (candidate.start < cursor) {
        continue;
      }
      selected.add(candidate);
      cursor = candidate.end;
    }
    return selected;
  }

  void _validate() {
    final seen = <String, GlossaryLayer>{};
    for (final term in _terms) {
      for (final alias in term.aliases) {
        final key = alias.toLowerCase().trim();
        final existing = seen[key];
        if (existing != null && existing.priority > term.layer.priority) {
          continue;
        }
        seen[key] = term.layer;
      }
    }
  }

  static bool _hasTokenBoundary(String text, int start, int end) {
    final before = start == 0 ? null : text.codeUnitAt(start - 1);
    final after = end == text.length ? null : text.codeUnitAt(end);
    return !_isAsciiToken(before) && !_isAsciiToken(after);
  }

  static bool _isAsciiToken(int? unit) {
    if (unit == null) {
      return false;
    }
    return (unit >= 48 && unit <= 57) ||
        (unit >= 65 && unit <= 90) ||
        (unit >= 97 && unit <= 122) ||
        unit == 95;
  }

  static String _collapseWhitespace(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

extension on GlossaryTerm {
  GlossaryTerm _copyWithLayer(GlossaryLayer layer) {
    return GlossaryTerm(
      canonical: canonical,
      layer: layer,
      aliases: aliases.where((alias) => alias != canonical),
    );
  }
}

class _GlossaryMatch {
  const _GlossaryMatch({
    required this.term,
    required this.matchedText,
    required this.start,
    required this.end,
  });

  final GlossaryTerm term;
  final String matchedText;
  final int start;
  final int end;
}
