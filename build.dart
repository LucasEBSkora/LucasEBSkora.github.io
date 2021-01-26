import 'dart:io' show Directory, File, FileSystemEntity;

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

import './tagger.dart';
import './tagger_scanner.dart';

const String currentVersion = "0.3 - The Unicode Update";

int main() {
  buildTour();
  buildDiary();
  return 0;
}

Future<void> buildTour() async {
  Document document =
      parse(await File('./src/language_tour.html').readAsString());

  document.getElementById("pageTitle").innerHtml += currentVersion;

  final contents = document.getElementById("contents");

  final files = Directory('./src/language_tour/').listSync(followLinks: false);
  files.sort((f1, f2) => f1.path.compareTo(f2.path));

  for (FileSystemEntity entity in files) {
    if (entity is File) {
      final element = document.createElement('div');
      element.className = "documentation_part";
      element.innerHtml = await entity.readAsString();
      final version = element.firstChild.attributes["content"];
      element.firstChild.remove();
      if (version != currentVersion) {
        final warning = document.createElement("p");
        warning.innerHtml =
            "<b>Warning! the next section of documentation wasn't updated to version  $currentVersion!."
            "Last update was to version $version. This might mean this section is wrong, or just that the developer forgot to"
            " change the version in the html file.</b>";
        element.insertBefore(warning, element.firstChild);
      }
      contents.append(element);
    }
  }

  document.querySelectorAll(".code_block").forEach((element) {
    element.innerHtml = tag(element.attributes["code"]);
    element.attributes.remove("code");
  });

  await File('./build/language_tour.html').writeAsString(document.outerHtml);
}

Future<void> buildDiary() async {
  Document document = parse(await File('./src/dev_diary.html').readAsString());

  final contents = document.getElementById("contents");

  final files = Directory('./src/dev_diary/').listSync(followLinks: false);
  files.sort((f1, f2) => f1.path.compareTo(f2.path));

  for (FileSystemEntity entity in files) {
    if (entity is File) {
      final element = document.createElement('div');
      element.className = "diary_entry";
      element.innerHtml = await entity.readAsString();
      contents.append(element);
    }
  }

  document.querySelectorAll(".code_block").forEach((element) {
    element.innerHtml = tag(element.attributes["code"]);
    element.attributes.remove("code");
  });

  await File('./build/dev_diary.html').writeAsString(document.outerHtml);
}

String tag(String source) =>
    Tagger(TaggerScanner(source, print).scanTokens()).tag();
