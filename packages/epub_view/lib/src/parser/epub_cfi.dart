import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

class CfiFragment {
  CfiFragment({@required this.type, @required this.cfiString});

  final String type;
  final String cfiString;
}

class ErrorPosition {
  ErrorPosition({@required this.line, @required this.column});

  final int line;
  final int column;
}

class EpubCfiParser {
  String quote(String s) {
    /*
     * ECMA-262, 5th ed., 7.8.4: All characters may appear literally in a
     * string literal except for the closing quote character, backslash,
     * carriage return, line separator, paragraph separator, and line feed.
     * Any character may appear in the form of an escape sequence.
     *
     * For portability, we also escape escape all control and non-ASCII
     * characters. Note that "\0" and "\v" escape sequences are not used
     * because JSHint does not like the first and IE the second.
     */
    return '"' +
        s
            .replaceAll(RegExp(r'\\'), '\\\\') // backslash
            .replaceAll(RegExp(r'"'), '\\"') // closing quote character
            .replaceAll(RegExp(r'\x08'), '\\b') // backspace
            .replaceAll(RegExp(r'\t'), '\\t') // horizontal tab
            .replaceAll(RegExp(r'\n'), '\\n') // line feed
            .replaceAll(RegExp(r'\f'), '\\f') // form feed
            .replaceAll(RegExp(r'\r'), '\\r') // carriage return
            .replaceAllMapped(RegExp(r'[\x00-\x07\x0B\x0E-\x1F\x80-\uFFFF]'),
                (Match m) => Uri.encodeFull(m[0])) +
        '"';
  }

  dynamic parse(String input, String startRule) {
      int pos = 0;
      final int reportFailures = 0;
      int rightmostFailuresPos = 0;
      List<String> rightmostFailuresExpected = [];
      
      void matchFailed(String failure) {
        if (pos < rightmostFailuresPos) {
          return;
        }
        
        if (pos > rightmostFailuresPos) {
          rightmostFailuresPos = pos;
          rightmostFailuresExpected = [];
        }
        
        rightmostFailuresExpected.add(failure);
      }

      CfiFragment parse_fragment() {
        var result0, result1, result2;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        if (input.substring(pos, 8) == 'epubcfi(') {
          result0 = 'epubcfi(';
          pos += 8;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"epubcfi(\"');
          }
        }
        if (result0 != null) {
          result1 = parse_range();
          if (result1 == null) {
            result1 = parse_path();
          }
          if (result1 != null) {
            if (input.charCodeAt(pos) == 41) {
              result2 = ')';
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('\")\"');
              }
            }
            if (result2 != null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, fragmentVal) {
                return CfiFragment(type: 'CFIAST', cfiString: fragmentVal);
            })(pos0, result0[1]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      String padLeft(String input, String padding, int length) {
        var result = input;
        
        final padLength = length - input.length;
        for (var i = 0; i < padLength; i++) {
          result = padding + result;
        }
        
        return result;
      }
      
      String escape(String ch) {
        final charCode = ch.codeUnitAt(0);
        var escapeChar = 'u';
        var length = 4;
        
        if (charCode <= 0xFF) {
          escapeChar = 'x';
          length = 2;
        }
        
        return '\\' + escapeChar + padLeft(charCode.toRadixString(16).toUpperCase(), '0', length);
      }
      
      Map<String, dynamic> parse_range() {
        var result0, result1, result2, result3, result4, result5;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_indexStep();
        if (result0 != null) {
          result1 = parse_local_path();
          if (result1 != null) {
            if (input.charCodeAt(pos) == 44) {
              result2 = ',';
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('\",\"');
              }
            }
            if (result2 != null) {
              result3 = parse_local_path();
              if (result3 != null) {
                if (input.charCodeAt(pos) == 44) {
                  result4 = ',';
                  pos++;
                } else {
                  result4 = null;
                  if (reportFailures == 0) {
                    matchFailed('\",\"');
                  }
                }
                if (result4 != null) {
                  result5 = parse_local_path();
                  if (result5 != null) {
                    result0 = [result0, result1, result2, result3, result4, result5];
                  } else {
                    result0 = null;
                    pos = pos1;
                  }
                } else {
                  result0 = null;
                  pos = pos1;
                }
              } else {
                result0 = null;
                pos = pos1;
              }
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, stepVal, localPathVal, rangeLocalPath1Val, rangeLocalPath2Val) {
                return { type:'range', path:stepVal, localPath:localPathVal, range1:rangeLocalPath1Val, range2:rangeLocalPath2Val };
          })(pos0, result0[0], result0[1], result0[3], result0[5]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_path() {
        var result0, result1;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_indexStep();
        if (result0 != null) {
          result1 = parse_local_path();
          if (result1 != null) {
            result0 = [result0, result1];
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, stepVal, localPathVal) {
                return { type:'path', path:stepVal, localPath:localPathVal };
            })(pos0, result0[0], result0[1]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_local_path() {
        var result0, result1;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result1 = parse_indexStep();
        if (result1 == null) {
          result1 = parse_indirectionStep();
        }
        if (result1 != null) {
          result0 = [];
          while (result1 != null) {
            result0.push(result1);
            result1 = parse_indexStep();
            if (result1 == null) {
              result1 = parse_indirectionStep();
            }
          }
        } else {
          result0 = null;
        }
        if (result0 != null) {
          result1 = parse_terminus();
          result1 = result1 != null ? result1 : '';
          if (result1 != null) {
            result0 = [result0, result1];
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, localPathStepVal, termStepVal) { 
        
                return { steps:localPathStepVal, termStep:termStepVal }; 
            })(pos0, result0[0], result0[1]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_indexStep() {
        var result0, result1, result2, result3, result4;
        var pos0, pos1, pos2;
        
        pos0 = pos;
        pos1 = pos;
        if (input.charCodeAt(pos) == 47) {
          result0 = '/';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"/\"');
          }
        }
        if (result0 != null) {
          result1 = parse_integer();
          if (result1 != null) {
            pos2 = pos;
            if (input.charCodeAt(pos) == 91) {
              result2 = '[';
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('\"[\"');
              }
            }
            if (result2 != null) {
              result3 = parse_idAssertion();
              if (result3 != null) {
                if (input.charCodeAt(pos) == 93) {
                  result4 = ']';
                  pos++;
                } else {
                  result4 = null;
                  if (reportFailures == 0) {
                    matchFailed('\"]\"');
                  }
                }
                if (result4 != null) {
                  result2 = [result2, result3, result4];
                } else {
                  result2 = null;
                  pos = pos2;
                }
              } else {
                result2 = null;
                pos = pos2;
              }
            } else {
              result2 = null;
              pos = pos2;
            }
            result2 = result2 != null ? result2 : '';
            if (result2 != null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, stepLengthVal, assertVal) { 
                return { type:'indexStep', stepLength:stepLengthVal, idAssertion:assertVal[1] };
            })(pos0, result0[1], result0[2]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_indirectionStep() {
        var result0, result1, result2, result3, result4;
        var pos0, pos1, pos2;
        
        pos0 = pos;
        pos1 = pos;
        if (input.substring(pos, 2) == '!/') {
          result0 = '!/';
          pos += 2;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"!/\"');
          }
        }
        if (result0 != null) {
          result1 = parse_integer();
          if (result1 != null) {
            pos2 = pos;
            if (input.charCodeAt(pos) == 91) {
              result2 = '[';
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('\"[\"');
              }
            }
            if (result2 != null) {
              result3 = parse_idAssertion();
              if (result3 != null) {
                if (input.charCodeAt(pos) == 93) {
                  result4 = ']';
                  pos++;
                } else {
                  result4 = null;
                  if (reportFailures == 0) {
                    matchFailed('\"]\"');
                  }
                }
                if (result4 != null) {
                  result2 = [result2, result3, result4];
                } else {
                  result2 = null;
                  pos = pos2;
                }
              } else {
                result2 = null;
                pos = pos2;
              }
            } else {
              result2 = null;
              pos = pos2;
            }
            result2 = result2 != null ? result2 : '';
            if (result2 != null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, stepLengthVal, assertVal) { 
                return { type:'indirectionStep', stepLength:stepLengthVal, idAssertion:assertVal[1] };
            })(pos0, result0[1], result0[2]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_terminus() {
        var result0, result1, result2, result3, result4;
        var pos0, pos1, pos2;
        
        pos0 = pos;
        pos1 = pos;
        if (input.charCodeAt(pos) == 58) {
          result0 = ':';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\":\"');
          }
        }
        if (result0 != null) {
          result1 = parse_integer();
          if (result1 != null) {
            pos2 = pos;
            if (input.charCodeAt(pos) == 91) {
              result2 = '[';
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('\"[\"');
              }
            }
            if (result2 != null) {
              result3 = parse_textLocationAssertion();
              if (result3 != null) {
                if (input.charCodeAt(pos) == 93) {
                  result4 = ']';
                  pos++;
                } else {
                  result4 = null;
                  if (reportFailures == 0) {
                    matchFailed('\"]\"');
                  }
                }
                if (result4 != null) {
                  result2 = [result2, result3, result4];
                } else {
                  result2 = null;
                  pos = pos2;
                }
              } else {
                result2 = null;
                pos = pos2;
              }
            } else {
              result2 = null;
              pos = pos2;
            }
            result2 = result2 != null ? result2 : '';
            if (result2 != null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, textOffsetValue, textLocAssertVal) { 
                return { type:'textTerminus', offsetValue:textOffsetValue, textAssertion:textLocAssertVal[1] };
            })(pos0, result0[1], result0[2]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_idAssertion() {
        var result0;
        var pos0;
        
        pos0 = pos;
        result0 = parse_value();
        if (result0 != null) {
          result0 = ((offset, idVal) {
                return idVal; 
            })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_textLocationAssertion() {
        var result0, result1;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_csv();
        result0 = result0 != null ? result0 : '';
        if (result0 != null) {
          result1 = parse_parameter();
          result1 = result1 != null ? result1 : '';
          if (result1 != null) {
            result0 = [result0, result1];
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = ((offset, csvVal, paramVal) {
                return { type:'textLocationAssertion', csv:csvVal, parameter:paramVal }; 
            })(pos0, result0[0], result0[1]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_parameter() {
        var result0, result1, result2, result3;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        if (input.charCodeAt(pos) == 59) {
          result0 = ';';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\";\"');
          }
        }
        if (result0 != null) {
          result1 = parse_valueNoSpace();
          if (result1 != null) {
            if (input.charCodeAt(pos) == 61) {
              result2 = '=';
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('\"=\"');
              }
            }
            if (result2 != null) {
              result3 = parse_valueNoSpace();
              if (result3 != null) {
                result0 = [result0, result1, result2, result3];
              } else {
                result0 = null;
                pos = pos1;
              }
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = (function(offset, paramLHSVal, paramRHSVal) { 
        
                return { type:'parameter', LHSValue:paramLHSVal, RHSValue:paramRHSVal }; 
            })(pos0, result0[1], result0[3]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_csv() {
        var result0, result1, result2;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_value();
        result0 = result0 != null ? result0 : '';
        if (result0 != null) {
          if (input.charCodeAt(pos) == 44) {
            result1 = ',';
            pos++;
          } else {
            result1 = null;
            if (reportFailures == 0) {
              matchFailed('\",\"');
            }
          }
          if (result1 != null) {
            result2 = parse_value();
            result2 = result2 != null ? result2 : '';
            if (result2 != null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = (function(offset, preAssertionVal, postAssertionVal) { 
        
                return { type:'csv', preAssertion:preAssertionVal, postAssertion:postAssertionVal }; 
            })(pos0, result0[0], result0[2]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_valueNoSpace() {
        var result0, result1;
        var pos0;
        
        pos0 = pos;
        result1 = parse_escapedSpecialChars();
        if (result1 == null) {
          result1 = parse_character();
        }
        if (result1 != null) {
          result0 = [];
          while (result1 != null) {
            result0.push(result1);
            result1 = parse_escapedSpecialChars();
            if (result1 == null) {
              result1 = parse_character();
            }
          }
        } else {
          result0 = null;
        }
        if (result0 != null) {
          result0 = (function(offset, stringVal) { 
        
                return stringVal.join(''); 
            })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_value() {
        var result0, result1;
        var pos0;
        
        pos0 = pos;
        result1 = parse_escapedSpecialChars();
        if (result1 == null) {
          result1 = parse_character();
          if (result1 == null) {
            result1 = parse_space();
          }
        }
        if (result1 != null) {
          result0 = [];
          while (result1 != null) {
            result0.push(result1);
            result1 = parse_escapedSpecialChars();
            if (result1 == null) {
              result1 = parse_character();
              if (result1 == null) {
                result1 = parse_space();
              }
            }
          }
        } else {
          result0 = null;
        }
        if (result0 != null) {
          result0 = (function(offset, stringVal) { 
        
                return stringVal.join(''); 
            })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_escapedSpecialChars() {
        var result0, result1;
        var pos0, pos1;
        
        pos0 = pos;
        pos1 = pos;
        result0 = parse_circumflex();
        if (result0 != null) {
          result1 = parse_circumflex();
          if (result1 != null) {
            result0 = [result0, result1];
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 == null) {
          pos1 = pos;
          result0 = parse_circumflex();
          if (result0 != null) {
            result1 = parse_squareBracket();
            if (result1 != null) {
              result0 = [result0, result1];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
          if (result0 == null) {
            pos1 = pos;
            result0 = parse_circumflex();
            if (result0 != null) {
              result1 = parse_parentheses();
              if (result1 != null) {
                result0 = [result0, result1];
              } else {
                result0 = null;
                pos = pos1;
              }
            } else {
              result0 = null;
              pos = pos1;
            }
            if (result0 == null) {
              pos1 = pos;
              result0 = parse_circumflex();
              if (result0 != null) {
                result1 = parse_comma();
                if (result1 != null) {
                  result0 = [result0, result1];
                } else {
                  result0 = null;
                  pos = pos1;
                }
              } else {
                result0 = null;
                pos = pos1;
              }
              if (result0 == null) {
                pos1 = pos;
                result0 = parse_circumflex();
                if (result0 != null) {
                  result1 = parse_semicolon();
                  if (result1 != null) {
                    result0 = [result0, result1];
                  } else {
                    result0 = null;
                    pos = pos1;
                  }
                } else {
                  result0 = null;
                  pos = pos1;
                }
                if (result0 == null) {
                  pos1 = pos;
                  result0 = parse_circumflex();
                  if (result0 != null) {
                    result1 = parse_equal();
                    if (result1 != null) {
                      result0 = [result0, result1];
                    } else {
                      result0 = null;
                      pos = pos1;
                    }
                  } else {
                    result0 = null;
                    pos = pos1;
                  }
                }
              }
            }
          }
        }
        if (result0 != null) {
          result0 = (function(offset, escSpecCharVal) { 
                
                return escSpecCharVal[1]; 
            })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_number() {
        var result0, result1, result2, result3;
        var pos0, pos1, pos2;
        
        pos0 = pos;
        pos1 = pos;
        pos2 = pos;
        if (/^[1-9]/.test(input.charAt(pos))) {
          result0 = input.charAt(pos);
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('[1-9]');
          }
        }
        if (result0 != null) {
          if (/^[0-9]/.test(input.charAt(pos))) {
            result2 = input.charAt(pos);
            pos++;
          } else {
            result2 = null;
            if (reportFailures == 0) {
              matchFailed('[0-9]');
            }
          }
          if (result2 != null) {
            result1 = [];
            while (result2 != null) {
              result1.push(result2);
              if (/^[0-9]/.test(input.charAt(pos))) {
                result2 = input.charAt(pos);
                pos++;
              } else {
                result2 = null;
                if (reportFailures == 0) {
                  matchFailed('[0-9]');
                }
              }
            }
          } else {
            result1 = null;
          }
          if (result1 != null) {
            result0 = [result0, result1];
          } else {
            result0 = null;
            pos = pos2;
          }
        } else {
          result0 = null;
          pos = pos2;
        }
        if (result0 != null) {
          if (input.charCodeAt(pos) == 46) {
            result1 = '.';
            pos++;
          } else {
            result1 = null;
            if (reportFailures == 0) {
              matchFailed('\".\"');
            }
          }
          if (result1 != null) {
            pos2 = pos;
            result2 = [];
            if (/^[0-9]/.test(input.charAt(pos))) {
              result3 = input.charAt(pos);
              pos++;
            } else {
              result3 = null;
              if (reportFailures == 0) {
                matchFailed('[0-9]');
              }
            }
            while (result3 != null) {
              result2.push(result3);
              if (/^[0-9]/.test(input.charAt(pos))) {
                result3 = input.charAt(pos);
                pos++;
              } else {
                result3 = null;
                if (reportFailures == 0) {
                  matchFailed('[0-9]');
                }
              }
            }
            if (result2 != null) {
              if (/^[1-9]/.test(input.charAt(pos))) {
                result3 = input.charAt(pos);
                pos++;
              } else {
                result3 = null;
                if (reportFailures == 0) {
                  matchFailed('[1-9]');
                }
              }
              if (result3 != null) {
                result2 = [result2, result3];
              } else {
                result2 = null;
                pos = pos2;
              }
            } else {
              result2 = null;
              pos = pos2;
            }
            if (result2 != null) {
              result0 = [result0, result1, result2];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        } else {
          result0 = null;
          pos = pos1;
        }
        if (result0 != null) {
          result0 = (function(offset, intPartVal, fracPartVal) { 
        
                return intPartVal.join('') + '.' + fracPartVal.join(''); 
            })(pos0, result0[0], result0[2]);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_integer() {
        var result0, result1, result2;
        var pos0, pos1;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 48) {
          result0 = '0';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"0\"');
          }
        }
        if (result0 == null) {
          pos1 = pos;
          if (/^[1-9]/.test(input.charAt(pos))) {
            result0 = input.charAt(pos);
            pos++;
          } else {
            result0 = null;
            if (reportFailures == 0) {
              matchFailed('[1-9]');
            }
          }
          if (result0 != null) {
            result1 = [];
            if (/^[0-9]/.test(input.charAt(pos))) {
              result2 = input.charAt(pos);
              pos++;
            } else {
              result2 = null;
              if (reportFailures == 0) {
                matchFailed('[0-9]');
              }
            }
            while (result2 != null) {
              result1.push(result2);
              if (/^[0-9]/.test(input.charAt(pos))) {
                result2 = input.charAt(pos);
                pos++;
              } else {
                result2 = null;
                if (reportFailures == 0) {
                  matchFailed('[0-9]');
                }
              }
            }
            if (result1 != null) {
              result0 = [result0, result1];
            } else {
              result0 = null;
              pos = pos1;
            }
          } else {
            result0 = null;
            pos = pos1;
          }
        }
        if (result0 != null) {
          result0 = (function(offset, integerVal) { 
        
                if (integerVal == '0') { 
                  return '0';
                } 
                else { 
                  return integerVal[0].concat(integerVal[1].join(''));
                }
            })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_space() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 32) {
          result0 = ' ';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\" \"');
          }
        }
        if (result0 != null) {
          result0 = (function(offset) { return ' '; })(pos0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_circumflex() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 94) {
          result0 = '^';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"^\"');
          }
        }
        if (result0 != null) {
          result0 = (function(offset) { return '^'; })(pos0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_doubleQuote() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 34) {
          result0 = '\"';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"\\\"\"');
          }
        }
        if (result0 != null) {
          result0 = (function(offset) { return '"'; })(pos0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_squareBracket() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 91) {
          result0 = '[';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"[\"');
          }
        }
        if (result0 == null) {
          if (input.charCodeAt(pos) == 93) {
            result0 = ']';
            pos++;
          } else {
            result0 = null;
            if (reportFailures == 0) {
              matchFailed('\"]\"');
            }
          }
        }
        if (result0 != null) {
          result0 = (function(offset, bracketVal) { return bracketVal; })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_parentheses() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 40) {
          result0 = '(';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"(\"');
          }
        }
        if (result0 == null) {
          if (input.charCodeAt(pos) == 41) {
            result0 = ')';
            pos++;
          } else {
            result0 = null;
            if (reportFailures == 0) {
              matchFailed('\")\"');
            }
          }
        }
        if (result0 != null) {
          result0 = (function(offset, paraVal) { return paraVal; })(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_comma() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 44) {
          result0 = ',';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\",\"');
          }
        }
        if (result0 != null) {
          result0 = (function(offset) { return ','; })(pos0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_semicolon() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 59) {
          result0 = ';';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\";\"');
          }
        }
        if (result0 != null) {
          result0 = (function(offset) { return ';'; })(pos0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      Map<String, dynamic> parse_equal() {
        var result0;
        var pos0;
        
        pos0 = pos;
        if (input.charCodeAt(pos) == 61) {
          result0 = '=';
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('\"=\"');
          }
        }
        if (result0 != null) {
          result0 = (function(offset) { return '='; })(pos0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      String parse_character() {
        String result0;
        final int pos0 = pos;
        
        if (RegExp(r'^[a-z]').hasMatch(input[pos])) {
          result0 = input[pos];
          pos++;
        } else {
          result0 = null;
          if (reportFailures == 0) {
            matchFailed('[a-z]');
          }
        }
        if (result0 == null) {
          if (RegExp(r'^[A-Z]').hasMatch(input[pos])) {
            result0 = input[pos];
            pos++;
          } else {
            result0 = null;
            if (reportFailures == 0) {
              matchFailed('[A-Z]');
            }
          }
          if (result0 == null) {
            if (RegExp(r'^[0-9]').hasMatch(input[pos])) {
              result0 = input[pos];
              pos++;
            } else {
              result0 = null;
              if (reportFailures == 0) {
                matchFailed('[0-9]');
              }
            }
            if (result0 == null) {
              if (input.codeUnitAt(pos) == 45) {
                result0 = '-';
                pos++;
              } else {
                result0 = null;
                if (reportFailures == 0) {
                  matchFailed('\"-\"');
                }
              }
              if (result0 == null) {
                if (input.codeUnitAt(pos) == 95) {
                  result0 = '_';
                  pos++;
                } else {
                  result0 = null;
                  if (reportFailures == 0) {
                    matchFailed('\"_\"');
                  }
                }
                if (result0 == null) {
                  if (input.codeUnitAt(pos) == 46) {
                    result0 = '.';
                    pos++;
                  } else {
                    result0 = null;
                    if (reportFailures == 0) {
                      matchFailed('\".\"');
                    }
                  }
                }
              }
            }
          }
        }
        if (result0 != null) {
          result0 = ((offset, charVal) => charVal)(pos0, result0);
        }
        if (result0 == null) {
          pos = pos0;
        }
        return result0;
      }
      
      
      List<String> cleanupExpected(List<String> expected) {
        expected.sort();
        
        String lastExpected;
        final List<String> cleanExpected = [];
        for (var i = 0; i < expected.length; i++) {
          if (expected[i] != lastExpected) {
            cleanExpected.add(expected[i]);
            lastExpected = expected[i];
          }
        }
        return cleanExpected;
      }
      
      ErrorPosition computeErrorPosition() {
        /*
         * The first idea was to use |String.split| to break the input up to the
         * error position along newlines and derive the line and column from
         * there. However IE's |split| implementation is so broken that it was
         * enough to prevent it.
         */
        
        var line = 1;
        var column = 1;
        var seenCR = false;
        
        for (var i = 0; i < max(pos, rightmostFailuresPos); i++) {
          final ch = input[i];
          if (ch == '\n') {
            if (!seenCR) {
              line++;
            }
            column = 1;
            seenCR = false;
          } else if (ch == '\r' || ch == '\u2028' || ch == '\u2029') {
            line++;
            column = 1;
            seenCR = true;
          } else {
            column++;
            seenCR = false;
          }
        }
        
        return ErrorPosition(line: line, column: column);
      }
      
      final parseFunctions = {
        'fragment': parse_fragment,
        'range': parse_range,
        'path': parse_path,
        'local_path': parse_local_path,
        'indexStep': parse_indexStep,
        'indirectionStep': parse_indirectionStep,
        'terminus': parse_terminus,
        'idAssertion': parse_idAssertion,
        'textLocationAssertion': parse_textLocationAssertion,
        'parameter': parse_parameter,
        'csv': parse_csv,
        'valueNoSpace': parse_valueNoSpace,
        'value': parse_value,
        'escapedSpecialChars': parse_escapedSpecialChars,
        'number': parse_number,
        'integer': parse_integer,
        'space': parse_space,
        'circumflex': parse_circumflex,
        'doubleQuote': parse_doubleQuote,
        'squareBracket': parse_squareBracket,
        'parentheses': parse_parentheses,
        'comma': parse_comma,
        'semicolon': parse_semicolon,
        'equal': parse_equal,
        'character': parse_character
      };
      
      var _startRule = startRule;
      if (_startRule != null) {
        if (parseFunctions[_startRule] == null) {
          throw FlutterError('Invalid rule name: ' + quote(_startRule) + '.');
        }
      } else {
        _startRule = 'fragment';
      }
      
      final result = parseFunctions[_startRule]();
      
      /*
       * The parser is now in one of the following three states:
       *
       * 1. The parser successfully parsed the whole input.
       *
       *    - |result != null|
       *    - |pos == input.length|
       *    - |rightmostFailuresExpected| may or may not contain something
       *
       * 2. The parser successfully parsed only a part of the input.
       *
       *    - |result != null|
       *    - |pos < input.length|
       *    - |rightmostFailuresExpected| may or may not contain something
       *
       * 3. The parser did not successfully parse any part of the input.
       *
       *   - |result == null|
       *   - |pos == 0|
       *   - |rightmostFailuresExpected| contains at least one failure
       *
       * All code following this comment (including called functions) must
       * handle these states.
       */
      if (result == null || pos != input.length) {
        // var offset = max(pos, rightmostFailuresPos);
        // var found = offset < input.length ? input[offset] : null;
        // var errorPosition = computeErrorPosition();
        
        // throw this.SyntaxError(
        //   cleanupExpected(rightmostFailuresExpected),
        //   found,
        //   offset,
        //   errorPosition.line,
        //   errorPosition.column
        // );
      }
      
      return result;
    }
}
