import 'dart:io';

import './tagger_scanner.dart';
import './tagger.dart';

//main function for the command line version
int main(List<String> args) {
  if (args.length > 1) {
    print("usage: bs [script]");
    return 1;
  } else if (args.length == 1) {
    final file = File(args[0]);
    String fileContents;
    try {
      fileContents = file.readAsStringSync();
    } on FileSystemException catch (e) {
      if (e.osError.errorCode == 2) {
        //no such file or directory
        print("file $args[0] not found!");
        return 1;
      }
      throw e;
    }
    print(tag(fileContents));
  } else {
    while (true) {
      stdout.write("> ");
      print(tag(stdin.readLineSync()));
    }
  }
  return 0;
}

String tag(String source) =>
    Tagger(TaggerScanner(source, print).scanTokens()).tag();
