import 'package:meta/meta.dart';

class InlineTagsProcessor {
  final Set<String> tagPrefixes;

  InlineTagsProcessor({@required this.tagPrefixes});

  Set<String> extractTags(String text) {
    var tags = <String>{};

    for (var prefix in tagPrefixes) {
      // FIXME: Do not hardcode this
      var p = prefix;
      if (p == '+') {
        p = '\\+';
      }

      var regexp = RegExp(r'(^|\s)' + p + r'([^ ]+)(\s|$)');
      var matches = regexp.allMatches(text);
      for (var match in matches) {
        var tag = match.group(2);

        if (tag.endsWith('.') || tag.endsWith('!') || tag.endsWith('?')) {
          tag = tag.substring(0, tag.length - 1);
        }

        var all = tag.split(prefix);
        for (var t in all) {
          t = t.trim();
          if (t.isNotEmpty) {
            tags.add(t);
          }
        }
      }
    }

    return tags;
  }
}
