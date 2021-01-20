import 'dart:collection' show Queue;

import '../../betascript/source/interpreter/token.dart';

//represents what we are currently "parsing"
//(but only for things that will change the behavior)
enum Parsing { setExpr, blockStmt, forclause, nothing }

class Tagger {
  static const _indent = "&emsp;";

  final List<Token> _tokens;
  int _indentLevel = 0;
  int _index = 0;
  List<String> result = <String>[];
  String _retStr = "";
  String _currentLine = "";
  Queue<Parsing> _stack = Queue();
  //represents last thing we finished parsing. Used to check if a '-' after a '}' is binary or unary
  Parsing _lastParsed = Parsing.nothing;
  int _unclosedParenthesesInForClause;

  Tagger(this._tokens) {
    _stack.add(Parsing.nothing);
  }

  String tag() {
    for (; _index < _tokens.length; ++_index) {
      Token token = _tokens[_index];
      if (token.type == TokenType.lineBreak) {
        _processLinebreak();
        continue;
      }
      if (token.type == TokenType.EOF) break;
      _currentLine += _formattedToken(token);
      _whitespaceFollowing(token);

      if (_tokens[_index].type == TokenType.leftBrace &&
          _index + 1 < _tokens.length &&
          _tokens[_index + 1].type == TokenType.rightBrace &&
          _stack.last == Parsing.blockStmt) {
        _retStr += '\n';
      }
    }

    return _retStr +
        _currentLine +
        ((_currentLine != _indent * _indentLevel) ? '\n' : '');
  }

  Token get _next =>
      (_index + 1 < _tokens.length) ? _tokens[_index + 1] : _tokens.last;

  // Token get _previous => _tokens[_index - 1];

  void _whitespaceFollowing(Token token) {
    if (!_doesntWantWhitespace(token)) _currentLine += ' ';
  }

  String _formattedToken(Token t) {
    switch (t.type) {
      case TokenType.identicallyEquals:
      case TokenType.not:
      case TokenType.contained:
      case TokenType.belongs:
      case TokenType.union:
      case TokenType.intersection:
      case TokenType.and:
      case TokenType.or:
      case TokenType.del:
      case TokenType.identicallyEquals:
      case TokenType.minus:
      case TokenType.plus:
      case TokenType.slash:
      case TokenType.invertedSlash:
      case TokenType.star:
      case TokenType.factorial:
      case TokenType.apostrophe:
      case TokenType.approx:
      case TokenType.exp:
      case TokenType.verticalBar:
      case TokenType.assigment:
      case TokenType.equals:
      case TokenType.disjoined:
        return '<span class="operator">${t.lexeme}</span>';
      case TokenType.leftBrace:
        ++_indentLevel;
        _stack.add(_leftBraceType());
        return '{';
      case TokenType.rightBrace:
        if (_stack.last != Parsing.nothing) {
          _lastParsed = _stack.removeLast();
        }
        --_indentLevel;
        return '}';
      case TokenType.forToken:
        _stack.add(Parsing.forclause);
        _unclosedParenthesesInForClause = 0;
        return '<span class="keyword">for</span>';
      case TokenType.leftParentheses:
        if (_stack.last == Parsing.forclause) ++_unclosedParenthesesInForClause;
        return '(';
      case TokenType.rightParentheses:
        if (_stack.last == Parsing.forclause &&
            --_unclosedParenthesesInForClause == 0) {
          _lastParsed = _stack.removeLast();
        }
        return ')';
      case TokenType.greater:
        return '<span class="operator">&gt;</span>';
      case TokenType.greaterEqual:
        return '<span class="operator">&gt;=</span>';
      case TokenType.less:
        return '<span class="operator">&lt;</span>';
      case TokenType.lessEqual:
        return '<span class="operator">&lt;=</span>';
      case TokenType.identifier:
        return '<span class="identifier">${t.lexeme}</span>';
      case TokenType.string:
        return '<span class="stringLiteral">${t.lexeme}</span>';
      case TokenType.number:
        return '<span class="numericLiteral">${t.lexeme}</span>';
      case TokenType.hash:
        return '<span class="comment">${t.lexeme}</span>';
      case TokenType.classToken:
        return '<span class="keyword">class</span>';
      case TokenType.elseToken:
        return '<span class="keyword">else</span>';
      case TokenType.falseToken:
        return '<span class="identifier">false</span>';
      case TokenType.ifToken:
        return '<span class="keyword">if</span>';
      case TokenType.let:
        return '<span class="keyword">let</span>';
      case TokenType.nil:
        return '<span class="identifier">nil</span>';
      case TokenType.print:
        return '<span class="keyword">print</span>';
      case TokenType.returnToken:
        return '<span class="keyword">return</span>';
      case TokenType.routine:
        return '<span class="keyword">routine</span>';
      case TokenType.setToken:
        return '<span class="keyword">set</span>';
      case TokenType.superToken:
        return '<span class="identifier">super</span>';
      case TokenType.thisToken:
        return '<span class="identifier">this</span>';
      case TokenType.trueToken:
        return '<span class="identifier">true</span>';
      case TokenType.unknown:
        return '<span class="identifier">unknown</span>';
      case TokenType.whileToken:
        return '<span class="keyword">while</span>';
      case TokenType.multilineComment:
        return '<span class="comment">${t.lexeme.replaceAll('\n', "<br>\n")}</span>';
      case TokenType.comment:
      case TokenType.wordComment:
        return '<span class="comment">${t.lexeme}</span>';
      default:
        return t.lexeme;
    }
  }

  Parsing _leftBraceType() {
    var i = _index - 1;

    Token previous;

    //finds the previous token, ignoring comments
    while (i >= 0) {
      Token aux = _tokens[i];
      if (aux.type != TokenType.comment &&
          aux.type != TokenType.hash &&
          aux.type != TokenType.multilineComment &&
          aux.type != TokenType.wordComment) {
        previous = aux;
        break;
      }
      --i;
    }
    if (previous.type == TokenType.setToken) return Parsing.setExpr;
    //if right before the '{' we have a ')', we must be looking at a
    //for, while or if block
    if (previous.type == TokenType.rightParentheses) return Parsing.blockStmt;
    //sets can only have expressions in them, blocks can have expressions and statements
    var unclosedBraces = 1;
    for (var i = _index + 1; i < _tokens.length; ++i) {
      final token = _tokens[i];
      if (token.type == TokenType.rightBrace) --unclosedBraces;
      if (unclosedBraces < 1) break;

      if (token.type == TokenType.leftBrace) return Parsing.blockStmt;
      //break instead of return because this is just returning the assumed default, which
      //is after the for loop

      if ((token.type == TokenType.comma ||
              token.type == TokenType.verticalBar) &&
          unclosedBraces == 1) {
        return Parsing.setExpr;
      }

      if (token.type == TokenType.forToken ||
          token.type == TokenType.whileToken ||
          token.type == TokenType.ifToken ||
          token.type == TokenType.elseToken ||
          token.type == TokenType.classToken ||
          token.type == TokenType.returnToken ||
          token.type == TokenType.routine ||
          token.type == TokenType.print ||
          token.type == TokenType.let) {
        return Parsing.blockStmt;
      }
    }

    return Parsing.setExpr;
  }

  bool _doesntWantWhitespace(Token token) {
    final next = _next.type;

    //';', ''' and ',' shouldn't have whitespace before, only after
    if (next == TokenType.semicolon ||
        next == TokenType.comma ||
        next == TokenType.apostrophe) return true;

    //calls and derivative expressions
    if ((token.type == TokenType.identifier || token.type == TokenType.del) &&
        next == TokenType.leftParentheses) return true;

    if (token.type == TokenType.leftParentheses ||
        token.type == TokenType.leftSquare ||
        token.type == TokenType.leftBrace) return true;
    if (next == TokenType.rightBrace ||
        next == TokenType.rightParentheses ||
        next == TokenType.rightSquare) return true;

    //unary left operators shouldn't have whitespace following
    //thing is, '-' can be both unary and binary, which is a major pain in the ass
    if (token.type == TokenType.not || token.type == TokenType.approx)
      return true;

    if (token.type == TokenType.minus) return _isUnaryMinus();
    return false;
  }

  bool _isUnaryMinus() {
    var i = _index - 1;

    Token previous;

    //finds the previous token, ignoring comments
    while (i >= 0) {
      Token aux = _tokens[i];
      if (aux.type != TokenType.comment &&
          aux.type != TokenType.hash &&
          aux.type != TokenType.multilineComment &&
          aux.type != TokenType.wordComment) {
        previous = aux;
        break;
      }
      --i;
    }

    //if there is no previous non-comment token, this is necessarily unary
    if (previous == null) return true;

    //if the minus character is unary, the character that precedes it won't
    //be something that could be part of a previous expression:
    if (previous.type == TokenType.lineBreak ||
        previous.type == TokenType.leftBrace ||
        previous.type == TokenType.leftParentheses ||
        previous.type == TokenType.leftSquare ||
        previous.type == TokenType.semicolon ||
        previous.type == TokenType.lineBreak ||
        previous.type == TokenType.comma ||
        previous.type == TokenType.verticalBar ||
        previous.type == TokenType.plus ||
        previous.type == TokenType.minus ||
        previous.type == TokenType.star ||
        previous.type == TokenType.slash ||
        previous.type == TokenType.exp ||
        previous.type == TokenType.invertedSlash ||
        previous.type == TokenType.approx ||
        previous.type == TokenType.not ||
        previous.type == TokenType.and ||
        previous.type == TokenType.or ||
        previous.type == TokenType.identicallyEquals ||
        previous.type == TokenType.equals ||
        previous.type == TokenType.assigment ||
        previous.type == TokenType.less ||
        previous.type == TokenType.lessEqual ||
        previous.type == TokenType.greater ||
        previous.type == TokenType.greaterEqual ||
        previous.type == TokenType.belongs ||
        previous.type == TokenType.contained ||
        previous.type == TokenType.disjoined ||
        previous.type == TokenType.elseToken ||
        previous.type == TokenType.intersection ||
        previous.type == TokenType.print ||
        previous.type == TokenType.returnToken ||
        previous.type == TokenType.union) return true;

    //these first two guarantee binary because they apply
    //to the expression that precedes then
    if (previous.type == TokenType.apostrophe ||
        previous.type == TokenType.factorial ||
        //for now guarantees binary because it only shows up
        //on interval definitions
        previous.type == TokenType.rightSquare ||
        previous.type == TokenType.identifier ||
        previous.type == TokenType.number ||
        previous.type == TokenType.thisToken ||
        //doesn't make sense, because you can't subtract from these things,
        //but we can format it to look pretty anyway
        previous.type == TokenType.string ||
        previous.type == TokenType.falseToken ||
        previous.type == TokenType.nil ||
        previous.type == TokenType.trueToken ||
        previous.type == TokenType.unknown) return false;

    // ')' and '}' are a special kind of hell because of these things:
    // if(variable)-otherVariable; -> unary
    // BUT
    // (variable)-otherVariable; -> binary
    //and
    // if(variable){variable=variable+1}-otherVariable; -> unary
    //BUT
    // {1,2,3}-(1.5, 2.5) -> binary

    //the easy way, since the unary case for both is kinda meaningless, would be to assume binary
    //however, since it is not invalid, and i might add operator overloads sometime, we can't assume
    //no one will ever write it.

    //for this, the token right before the parentheses was opened (excluding comments)
    //will determine wheter it was unary or binary: if it is 'if', 'while' or 'for', it is unary
    //and if it is anything else, it is binary. it is also binary if the parentheses actually is closing a
    //left square bracket, because then it is an left-closed right-open interval definition
    if (previous.type == TokenType.rightParentheses) {
      var unopenedBrackets = 1;
      --i;
      while (i >= 0) {
        final type = _tokens[i].type;
        if (type == TokenType.rightParentheses ||
            type == TokenType.rightSquare) {
          ++unopenedBrackets;
        } else if (type == TokenType.leftParentheses ||
            type == TokenType.leftSquare) --unopenedBrackets;
        //found start of group/parenthesized clause
        if (unopenedBrackets == 0) {
          //was interval!
          if (type == TokenType.leftSquare) return false;
          break;
        }
        --i;
      }
      --i;
      //ignore comments
      while (i >= 0) {
        TokenType aux = _tokens[i].type;
        if (aux != TokenType.comment &&
            aux != TokenType.hash &&
            aux != TokenType.multilineComment &&
            aux != TokenType.wordComment) {
          break;
        }
        --i;
      }
      //parentheses is unopened/opened right at the beggining -> binary
      if (i <= 0) return false;

      TokenType typeBeforeOpening = _tokens[i].type;
      return typeBeforeOpening == TokenType.ifToken ||
          typeBeforeOpening == TokenType.whileToken ||
          typeBeforeOpening == TokenType.forToken;
      //need to make sure we're not taking a comment
    }

    //if we were parsing a block, it's unary
    //if it was a set, it's binary
    if (previous.type == TokenType.rightBrace) {
      return _lastParsed == Parsing.blockStmt;
    }

    //the token types which would reach this point are:
    //  dot ('.')
    //  classToken ('class')
    //  del ('del' or '∂')
    //  ifToken('if')
    //  forToken('for')
    //  let('let')
    //  routine('routine')
    //  setToken('set')
    //  superToken('super')
    //  whileToken('while')
    //  EOF(end of file)
    //which are all syntax errors anyway, so who cares
    return true;
  }

  void _processLinebreak() {
    _retStr += _currentLine + "<br>\n";

    _currentLine = (_next.type == TokenType.rightBrace)
        ? _indent * (_indentLevel - 1)
        : _indent * _indentLevel;
  }
}
