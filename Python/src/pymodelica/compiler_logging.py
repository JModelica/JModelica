#!/usr/bin/env python
# -*- coding: utf-8 -*-

#    Copyright (C) 2014 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
Internal module, handles log output from the compiler
"""
import xml.sax
from threading import Thread
from compiler_exceptions import *
import sys
import traceback
import os
import tempfile

class LogErrorParser(xml.sax.ContentHandler):
    """
    Implementation of the xml.sax.ContentHandler class. This class looks for
    warnings and errors in the provided xml stream.
    
    parameters::
        result --
            A _CompilerResultHolder that stores the result
    """
    def __init__(self, result):
        xml.sax.ContentHandler.__init__(self)
        self.result = result
        self.node = None
        self.state = None
        self.attribute = None
    def startElement(self, name, attrs):
        if self.state == 'error' or self.state == 'warning' or \
                self.state == 'exception' or self.state == 'unit':
            if name == 'value':
                self.attribute = attrs['name'].encode('utf-8')
                self.node[self.attribute] = '';
        else:
            if name == "Error":
                self.state = 'error'
                self.node = {'type':'error'}
            elif name == "Warning":
                self.state = 'warning'
                self.node = {'type':'warning'}
            elif name == "Exception":
                self.state = 'exception'
                self.node = {'type':'exception'}
            elif name == "CompilationUnit":
                self.state = 'unit'
                self.node = {'type':'unit', 'file':None}

    def endElement(self, name):
        if self.state == 'error' and name == "Error" or \
                self.state == 'warning' and name == "Warning" or \
                self.state == 'exception' and name == "Exception":
            problem = self._construct_problem_node(self.node)
            self.result.problems.append(problem)
            self.state = None
            self.node = None
        elif self.state == 'unit' and name == "CompilationUnit":
            self.result.name = self.node['file']
            self.state = None
            self.node = None
        elif name == 'value':
            self.attribute = None
    
    def characters(self, content):
        if self.node is not None and self.attribute is not None:
            self.node[self.attribute] += content;
    
    def _construct_problem_node(self, node):
        if node['type'] == 'exception':
            return CompilationException(node['kind'], node['message'], node['stacktrace'])
        elif node['type'] == 'error':
            return CompilationError(node['identifier'], node['kind'], node['file'], node['line'], \
                node['column'], node['message'])
        elif node['type'] == 'warning':
            return CompilationWarning(node['identifier'], node['kind'], node['file'], node['line'], \
                node['column'], node['message'])

class KeepLastStream():
    """
    Internal class that records the last contents sent to the SAX parser.
    It is necessary so that we can recover from SAX parser errors that is
    thrown when the compiler fail to start properly. For example when the
    JVM is unable to allocate enough memory.
    """
    def __init__(self, stream):
        self.stream = stream
        self.last = None
        self.secondLastLine = None
        self.lastLine = ''
        self.line = 1 # Number of lines that has been read read
        self.errorMessage = None
    def read(self, num = -1):
        """
        Reads num bytes from the underlying stream and preserves the latest
        read contents internally. It also preserves the last two lines of the
        previously read contents.
        """
        if self.last is not None:
            # Count the number of lines in the previous contents
            self.line += self.last.count('\n')
            # Get the two last lines
            lines = self.last.rsplit('\n', 2)
            # Update lastLine and secondLastLine depending on how many
            # rows we got
            if len(lines) == 1:
                self.lastLine = self.lastLine + lines[0]
            elif len(lines) == 2:
                self.secondLastLine = self.lastLine + lines[0]
                self.lastLine = lines[1]
            else:
                self.secondLastLine = lines[1]
                self.lastLine = lines[2]
        # Replace the old contents
        self.last = self.stream.read(num)
        return self.last
    
    def close(self):
        """
        Closes the underlying stream.
        """
        self.stream.close()
    
    def genErrorMsg(self, e):
        column = e.getColumnNumber()
        localLine = e.getLineNumber() - self.line
        
        dump_file = tempfile.NamedTemporaryFile(prefix='JM_LOG_DUMP_', delete=False)
        dump_file.write(self.last)
        
        lines = self.last.split('\n')
        lines[0] = self.lastLine + lines[0]
        
        # Add lines before...
        if self.secondLastLine is not None:
            lines = [self.secondLastLine] + lines
            localLine += 1
        # ... and after (if possible)
        if localLine + 2 >= len(lines):
            more = self.stream.read()
            dump_file.write(more)
            while localLine + 2 >= len(lines) and more:
                pos = more.find('\n')
                if pos == -1:
                    lines[-1] = lines[-1] + more
                    more = self.stream.read()
                    dump_file.write(more)
                else:
                    lines[-1] = lines[-1] + more[0:pos]
                    lines.append('')
                    more = more[pos + 1:]
                    if not more:
                        more = self.stream.read()
                        dump_file.write(more)
        
        #Construct message
        message = []
        if e.getLineNumber() > 2:
            message.append('...' + os.linesep)
        if localLine > 0:
            message.append(lines[localLine - 1] + os.linesep)
        message.append(lines[localLine])
        if localLine + 1 < len(lines):
            message.append(os.linesep + lines[localLine + 1])
            if localLine + 2 < len(lines):
                message.append(os.linesep + '...')
        message = ''.join(message)
        
        if localLine + 1 >= len(lines) and column >= len(lines[localLine]):
            message = "Unexpected end of output from the compiler:%s%s" \
                % (os.linesep, message)
        else:
            message = "Unexpected output from the compiler, got '%s' in:%s%s" \
                % (lines[localLine][column], os.linesep, message)
        
        # Discard remaining data.
        data = self.stream.read()
        dump_file.write(data)
        while data is None or data != '':
            data = self.stream.read()
            dump_file.write(data)
        dump_file.close()
        
        message += "%sDump of the log has been saved in %s" % (os.linesep, dump_file.name)
        return message
    
class LogHandlerThread(Thread):
    """
    A thread for reading the log stream
    Contains two attributes, errors and warnings that will be propagated with
    errors and warnings during the compilation.
    """
    def __init__(self, stream):
        """
        Creates the new LogHandlerThread
        
        Parameters::
            stream --
                An output stream that the logger can parse.
        
        """
        Thread.__init__(self)
        self.stream = KeepLastStream(stream)
        self.result = _CompilerResultHolder()

    def run(self):
        """
        The thread.run() method that delegates to a SAX parser. 
        """
        try:
            xml.sax.parse(self.stream, LogErrorParser(self.result))
        except xml.sax.SAXParseException, e:
            self.result.problems.append(CompilationException('xml.sax.SAXParseException', self.stream.genErrorMsg(e),""))

class _CompilerResultHolder:
    """
    Holds the result of the compilation while log is read.
    """
    def __init__(self):
        self.problems = []
        self.name = None

class CompilerLogHandler:
    def __init__(self):
        """
        Create a compiler log handler. It will parse the xml stream that is
        output by the JModelica.org compiler.
        
        Normal call flow is as follows:
        stream = <<<an output stream from the compiler>>>
        log = CompilerLogHandler()
        log.start(stream)
        try:
            compiler.do_something()
        finally:
            stream.close()
            log.end()
        """
        self.loggerThread = None
    
    def _create_log_handler_thread(self, stream):
        """
        An internal util method for creating the log handling thread.
        
        Returns::
        
            A LogHandlerThread object.
        """
        return LogHandlerThread(stream);
    
    def start(self, stream):
        """
        Starts a new logging session. A new thread is started internaly that
        will monitor the log stream that was given as argument. It will
        continously echo output and parse for warnings and errors.
        
        Parameters::
            stream --
                An output stream that the logger can parse.
        """
        self.loggerThread = self._create_log_handler_thread(stream)
        self.loggerThread.start()

    def end(self):
        """ 
        End the current logging session. It is important that the log stream
        has been closed before calling this method. Otherwise this method will
        block indefinitely. The reason for this is that this method will wait
        for the the log parser thread to finish. It only does so when the log
        stream is closed.
        
        This method will proccess the errors and warnings that are given in the
        log stream. An appropriate Python error is raised if an exception was
        given by the compiler process.
        """
        if (self.loggerThread is None):
            print "Invalid call order!"
        self.loggerThread.join()
        problems = self.loggerThread.result.problems
        name = self.loggerThread.result.name
        self.loggerThread = None
        
        exceptions = []
        errors = []
        warnings = []
        
        for problem in problems:
            if isinstance(problem, CompilationException):
                exceptions.append(problem)
            elif isinstance(problem, CompilationError):
                errors.append(problem)
            elif isinstance(problem, CompilationWarning):
                warnings.append(problem)
        if not exceptions:
            if not errors:
                from compiler import CompilerResult
                return CompilerResult(name, warnings)
            else:
                raise CompilerError(errors, warnings)
        
        exception = exceptions[0]
        
        if exception.kind == 'org.jmodelica.util.exceptions.ModelicaClassNotFoundException':
            raise ModelicaClassNotFoundError(exception.message)
        
        if exception.kind == 'java.io.FileNotFoundException':
            raise IOError(exception.message)
        
        if exception.kind == 'org.jmodelica.util.logging.IllegalLogStringException':
            raise IllegalLogStringError(exception.message)
        
        if exception.kind == 'org.jmodelica.common.options.AbstractOptionRegistry$UnknownOptionException':
            raise UnknownOptionError(exception.message)

        if exception.kind == 'org.jmodelica.common.options.AbstractOptionRegistry$InvalidOptionValueException':
            raise InvalidOptionValueError(exception.message)
        
        if exception.kind == 'org.jmodelica.util.exceptions.CcodeCompilationException':
            raise CcodeCompilationError(exception.message)
        
        if exception.kind == 'org.jmodelica.util.exceptions.PackingFailedException':
            raise PackingFailedError(exception.message)
        
        if exception.kind == 'xml.sax.SAXParseException':
            raise IOError(exception.message)

        if exception.kind == 'org.jmodelica.util.exceptions.IllegalCompilerArgumentException':
            raise IllegalCompilerArgumentError(exception.message)
        
        raise JError("%s\n%s" % (exception.message, exception.stacktrace))

class CompilationException():
    """
    Temporary container class for exceptions that are thrown by the compiler
    and caught by the SAX parser. This class should only be used internally in
    this module.
    """
    def __init__(self, kind, message, stacktrace):
        self.kind = kind
        self.message = message
        self.stacktrace = stacktrace
