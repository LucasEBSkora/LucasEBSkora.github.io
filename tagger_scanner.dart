import '../betascript/source/interpreter/scanner.dart';
import '../betascript/source/interpreter/token.dart';

class TaggerScanner extends BSScanner {
  TaggerScanner(String source, Function errorCallback)
      : super(source, errorCallback) {
    charToLexeme['/'] = () {
      //if the slash is followed by another slash, it's actually a comment, and the rest of the line should be ignored
      if (match('/')) {
        while (peek() != '\$'  && !isAtEnd()) {
          advance();
        }
        //the token will include the slashes but not the linebreak
        addToken(TokenType.comment);
      }

      //if it's followed by a star, it's a multiline comment, and everything up to the next */ should be ignored
      else if (match('*')) {
        while (!match('*') || peek() != '/') {
          if (isAtEnd()) {
            errorCallback(line, "unterminated multiline comment");
            break;
          }
          advance();
        }
        //consumes those last  '*/' characters
        advance();
        addToken(TokenType.multilineComment);
      } else //in any other case we just have a normal slash
        addToken(TokenType.slash);
    };
    charToLexeme['@'] = () {
      //word comments ignore everything up to the next character of whitespace (but can be used normally inside strings)
      while (peek() != '\n' &&
          peek() != ' ' &&
          peek() != '\r' &&
          peek() != '\t' &&
          !isAtEnd()) advance();

      addToken(TokenType.wordComment);
    };
    charToLexeme['\n'] = () {
      addToken(TokenType.lineBreak);
      ++line;
    };
    //using $ as an impromptu linebreak character
    charToLexeme['\$'] = () {
      addToken(TokenType.lineBreak);
      ++line;
    };
  }

  @override
  void removeLinebreaks() {}
}
