/*
    Copyright (C) 2009-2014 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package $PARSER_PACKAGE$;

import $PARSER_PACKAGE$.ModelicaParser.Terminals;
import org.jmodelica.util.AbstractModelicaScanner;
import org.jmodelica.util.AbstractAdjustableSymbol;
import org.jmodelica.util.formatting.FormattingType;
import $AST_PACKAGE$.ASTNode;
import beaver.Scanner;


%%

%public
%final
%class ModelicaScanner
%extends AbstractModelicaScanner<ASTNode<?>>
%unicode
%function nextTokenInner
%type Symbol
%yylexthrow Scanner.Exception
/* From JFlex manual: "<<EOF>> rules [...] should not be mixed with the %eofval directive." */
//%eofval{
//  return newSymbol(Terminals.EOF);
//%eofval}
%line
%column
%char

%{
    /**
     * Subclass of Symbol that carries extra information. 
     * Used to give error reporting class for parser access to offset & length 
     * of tokens. Start, end, offset and length are extracted from scanner variables
     * in constructors.
     */
    public class Symbol extends AbstractAdjustableSymbol {
    
        private int offset;
        private int length;
        
        public Symbol(short id) {
            this(id, yytext());
        }
        
        public Symbol(short id, Object value) {
            super(id, yyline + 1, yycolumn + 1, yylength(), value);
            offset = yychar;
            length = yylength();
        }
        
        public Symbol(short id, Object value, int lineOffset, int endColumn) {
            super(id, makePosition(yyline + 1,  yycolumn + 1), makePosition(yyline + 1 + lineOffset, endColumn), value);
            offset = yychar;
            length = yylength();
        }
        
        public int getOffset() {
            return offset;
        }
        
        public int getEndOffset() {
            return offset + length - 1;
        }
        
        public int getLength() {
            return length;
        }
    }


    /**
     * Subclass of Scanner.Exception that carries extra information. 
     * Used to give error reporting class for parser access to offset of error. 
     * Offset is extracted from scanner variables in constructors.
     */
    public class Exception extends Scanner.Exception {
        
        public final int offset;
        
        public Exception(String msg) {
            this(yyline + 1, yycolumn + 1, msg);
        }
        
        public Exception(int line, int column, String msg) {
            super(line, column, msg);
            offset = yychar;
        }
        
    }

    private Symbol newSymbol(short id) {
        return new Symbol(id);
    }

    private Symbol newSymbol(short id, Object value) {
        return new Symbol(id, value);
    }
    
    private Symbol newSymbolCountLineBreaks(short id, String value, int numLineBreaks) {
        if (numLineBreaks > 0) {
            int endColumn = value.length() - value.lastIndexOf('\n');
            return new Symbol(id, value, numLineBreaks, endColumn);
        }
        return new Symbol(id, value);
    }
    
    public void reset(java.io.Reader reader) {
        yyreset(reader);
        resetFormatting();
    }

    protected int matchLine()     { return yyline; }
    protected int matchColumn() { return yycolumn; }
    protected int matchOffset() { return yychar; }
    protected int matchLength() { return yylength(); }
    
    public Symbol nextToken() throws java.io.IOException, Scanner.Exception {
        Symbol res = null;
        while (res == null)
            res = nextTokenInner();
        return res;
    }

%}


ID = {NONDIGIT} ({DIGIT}|{NONDIGIT})* | {Q_IDENT}
NONDIGIT = [a-zA-Z_]
S_CHAR = [^\"\\]
Q_IDENT = "\'" ( {Q_CHAR} | {S_ESCAPE} ) ( {Q_CHAR} | {S_ESCAPE} )* "\'"
STRING = "\"" ({S_CHAR}|{S_ESCAPE})* "\""
Q_CHAR = [^\'\\]
S_ESCAPE = "\\" .
DIGIT = [0-9]
UNSIGNED_INTEGER = {DIGIT} {DIGIT}*
UNSIGNED_NUMBER = {DIGIT} {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )? ( ("e"|"E") ( "+" | "-" )? {UNSIGNED_INTEGER} )? | {DIGIT}* ( "." ( {UNSIGNED_INTEGER} )? )?


LineTerminator = \r|\n|\r\n
NonBreakingWhiteSpace = [ \t\f]+
InputCharacter = [^\r\n]

WhiteSpace = ({LineTerminator} | {NonBreakingWhiteSpace})+

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment} 

TraditionalComment = "/*" ~"*/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?


%states NORMAL

%%

<YYINITIAL> {
  "\uFEFF"        { yybegin(NORMAL); }
  .|\n            { yypushback(1); yybegin(NORMAL); }
}

<NORMAL> {
  "within"        { return newSymbol(Terminals.WITHIN); }  
  "class"         { return newSymbol(Terminals.CLASS); }  
  "model"         { return newSymbol(Terminals.MODEL); }
  "block"         { return newSymbol(Terminals.BLOCK); }
  "expandable"    { return newSymbol(Terminals.EXPANDABLE); }
  "connector"     { return newSymbol(Terminals.CONNECTOR); }
  "type"          { return newSymbol(Terminals.TYPE); }
  "package"       { return newSymbol(Terminals.PACKAGE); }
  "function"      { return newSymbol(Terminals.FUNCTION); }
  "record"        { return newSymbol(Terminals.RECORD); }
  "operator"      { return newSymbol(Terminals.OPERATOR); }

  "end"           { return newSymbol(Terminals.END); }
  "external"      { return newSymbol(Terminals.EXTERNAL); }


  "public"        { return newSymbol(Terminals.PUBLIC); }
  "protected"     { return newSymbol(Terminals.PROTECTED); }

  "extends"       { return newSymbol(Terminals.EXTENDS); }
  "constrainedby" { return newSymbol(Terminals.CONSTRAINEDBY); }

  "flow"          { return newSymbol(Terminals.FLOW); }
  "stream"        { return newSymbol(Terminals.STREAM); }

  "discrete"      { return newSymbol(Terminals.DISCRETE); }
  "parameter"     { return newSymbol(Terminals.PARAMETER); }
  "constant"      { return newSymbol(Terminals.CONSTANT); }
  "input"         { return newSymbol(Terminals.INPUT); }
  "output"        { return newSymbol(Terminals.OUTPUT); }

  "equation"      { return newSymbol(Terminals.EQUATION); }
  "algorithm"     { return newSymbol(Terminals.ALGORITHM); }

  "initial" {WhiteSpace} "equation"   { addWhiteSpaces(yytext()); 
                                        addLineBreaks(yytext()); 
                                        return newSymbol(Terminals.INITIAL_EQUATION); }
  "initial" {WhiteSpace} "algorithm"  { addWhiteSpaces(yytext());
                                        addLineBreaks(yytext()); 
                                        return newSymbol(Terminals.INITIAL_ALGORITHM); }

  "end" {WhiteSpace} "for"    { String s = yytext();
                                addWhiteSpaces(s);
                                addLineBreaks(s); 
                                return newSymbol(Terminals.END_FOR); }
  "end" {WhiteSpace} "while"  { String s = yytext();
                                addWhiteSpaces(s);
                                addLineBreaks(s); 
                                return newSymbol(Terminals.END_WHILE); }
  "end" {WhiteSpace} "if"     { String s = yytext();
                                addWhiteSpaces(s);
                                addLineBreaks(s); 
                                return newSymbol(Terminals.END_IF); }
  "end" {WhiteSpace} "when"   { String s = yytext();
                                addWhiteSpaces(s);
                                addLineBreaks(s); 
                                return newSymbol(Terminals.END_WHEN); }
  "end" {WhiteSpace} {ID}     { String s = yytext();
                                addWhiteSpaces(s);
                                addLineBreaks(s); 
                                return newSymbol(Terminals.END_ID, s); }

  "enumeration"     { return newSymbol(Terminals.ENUMERATION); }

  "each"          { return newSymbol(Terminals.EACH); }
  "final"         { return newSymbol(Terminals.FINAL); }   
  "replaceable"   { return newSymbol(Terminals.REPLACEABLE); }
  "redeclare"     { return newSymbol(Terminals.REDECLARE); }
  "annotation"    { return newSymbol(Terminals.ANNOTATION); }
  "import"        { return newSymbol(Terminals.IMPORT); }
  "encapsulated"  { return newSymbol(Terminals.ENCAPSULATED); }
  "partial"       { return newSymbol(Terminals.PARTIAL); }
  "inner"         { return newSymbol(Terminals.INNER); }
  "outer"         { return newSymbol(Terminals.OUTER); }

  "and"           { return newSymbol(Terminals.AND); }
  "or"            { return newSymbol(Terminals.OR); }
  "not"           { return newSymbol(Terminals.NOT); }
  "true"          { return newSymbol(Terminals.TRUE); }
  "false"         { return newSymbol(Terminals.FALSE); }

  "if"            { return newSymbol(Terminals.IF); }
  "then"          { return newSymbol(Terminals.THEN); }
  "else"          { return newSymbol(Terminals.ELSE); }
  "elseif"        { return newSymbol(Terminals.ELSEIF); }

  "for"           { return newSymbol(Terminals.FOR); }
  "loop"          { return newSymbol(Terminals.LOOP); }
  "in"            { return newSymbol(Terminals.IN); }

  "while"         { return newSymbol(Terminals.WHILE); }

  "when"          { return newSymbol(Terminals.WHEN); }
  "elsewhen"      { return newSymbol(Terminals.ELSEWHEN); }

  "break"         { return newSymbol(Terminals.BREAK); }
  "return"        { return newSymbol(Terminals.RETURN); }

  "connect"       { return newSymbol(Terminals.CONNECT); }
  "time"          { return newSymbol(Terminals.TIME); }
  "der"           { return newSymbol(Terminals.DER); }


  "("             { return newSymbol(Terminals.LPAREN); }
  ")"             { return newSymbol(Terminals.RPAREN); }
  "{"             { return newSymbol(Terminals.LBRACE); }
  "}"             { return newSymbol(Terminals.RBRACE); }
  "["             { return newSymbol(Terminals.LBRACK); }
  "]"             { return newSymbol(Terminals.RBRACK); }
  ";"             { return newSymbol(Terminals.SEMICOLON); }
  ":"             { return newSymbol(Terminals.COLON); }
  "."             { return newSymbol(Terminals.DOT); }
  ","             { return newSymbol(Terminals.COMMA); }

  "+"             { return newSymbol(Terminals.PLUS); }
  "-"             { return newSymbol(Terminals.MINUS); }
  "*"             { return newSymbol(Terminals.MULT); }
  "/"             { return newSymbol(Terminals.DIV); }
  "="             { return newSymbol(Terminals.EQUALS); }
  ":="            { return newSymbol(Terminals.ASSIGN); }
  "^"             { return newSymbol(Terminals.POW); }
  ".+"            { return newSymbol(Terminals.DOTPLUS); }  
  ".-"            { return newSymbol(Terminals.DOTMINUS); }
  ".*"            { return newSymbol(Terminals.DOTMULT); }
  "./"            { return newSymbol(Terminals.DOTDIV); }
  ".^"            { return newSymbol(Terminals.DOTPOW); }

  "<"             { return newSymbol(Terminals.LT); }  
  "<="            { return newSymbol(Terminals.LEQ); }
  ">"             { return newSymbol(Terminals.GT); }
  ">="            { return newSymbol(Terminals.GEQ); }
  "=="            { return newSymbol(Terminals.EQ); }
  "<>"            { return newSymbol(Terminals.NEQ); }

  {STRING}  { String s = yytext();
              int numLineBreaks = addLineBreaks(s);
              s = s.substring(1,s.length()-1);
              return newSymbolCountLineBreaks(Terminals.STRING, s, numLineBreaks); }
  {ID}      { String s = yytext();
              int numLineBreaks = addLineBreaks(s);
              return newSymbolCountLineBreaks(Terminals.ID, s, numLineBreaks); }

  {UNSIGNED_INTEGER}       { return newSymbol(Terminals.UNSIGNED_INTEGER, yytext()); }
  {UNSIGNED_NUMBER}        { return newSymbol(Terminals.UNSIGNED_NUMBER, yytext()); }

  {Comment}                { int numberOfLineBreaks = addLineBreaks(yytext());
                             if (yytext().charAt(1) == '/') {
                                 numberOfLineBreaks = 0;
                             }
                             addFormattingInformation(FormattingType.COMMENT, yytext(), numberOfLineBreaks); 
                             return null; }
  {NonBreakingWhiteSpace}  { addFormattingInformation(FormattingType.NON_BREAKING_WHITESPACE, yytext()); 
                             return null; }
  {LineTerminator}         { addLineBreak();
                             addFormattingInformation(FormattingType.LINE_BREAK, yytext()); 
                             return null; }
                             
  .|\n                     { throw new Exception("Character '" + yytext() + "' is not legal in this context"); }
}

<<EOF>>                    { return newSymbol(Terminals.EOF); }
