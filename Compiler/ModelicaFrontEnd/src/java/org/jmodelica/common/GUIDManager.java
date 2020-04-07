package org.jmodelica.common;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.Writer;
import java.math.BigInteger;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class GUIDManager {

    private final Token guidToken = new Token("$GUID_TOKEN$");
    private final Token dateToken = new Token("$DATE_TOKEN$");
    private final Token generationToolToken = new Token("$GENERATION_TOOL$");
    private final Token toolNameToken = new Token("$TOOL_NAME$");
    private final Token versionToken = new Token("$COMPILER_VERSION$");

    private final Token[] tokens = {guidToken, dateToken, generationToolToken, toolNameToken, versionToken};
    private final SimpleDateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

    private final List<Openable> dependentFiles = new ArrayList<>();
    private Openable source;


    public GUIDManager(String vendorName, String compilerVersion) {
        generationToolToken.setValue(vendorName);
        toolNameToken.setValue(vendorName);
        versionToken.setValue(compilerVersion);
    }

    public String getGuidToken() {
        return guidToken.getString();
    }

    public String getDateToken() {
        return dateToken.getString();
    }

    public String getGenerationToolToken() {
        return generationToolToken.getString();
    }

    public String getToolNameToken() {
        return toolNameToken.getString();
    }
    
    public String getCompilerVersionToken() {
        return versionToken.getString();
    }

    public void setSourceFile(File source) {
        this.source = new FileOpenable(source);
    }

    public void setSourceString(String source) {
        this.source = new StringOpenable(source, null);
    }

    public void addDependentFile(File dependentFile) {
        dependentFiles.add(new FileOpenable(dependentFile));
    }

    public void addDependentString(String input, StringBuilder output) {
        dependentFiles.add(new StringOpenable(input, output));
    }

    private String getGuid() {
        String guid;
        try {
            final MessageDigest md5 = MessageDigest.getInstance("MD5");

            try (final BufferedReader reader = new BufferedReader(source.openInput())) {
                String line = reader.readLine();
                while (line != null) {
                    // A naive implementation that is expected to create a digest different from what a command
                    // line tool would create. No lines breaks are included in the digest, and no
                    // character encodings are specified.
                    md5.update(line.getBytes(Charset.forName("UTF-8")));
                    line = reader.readLine();
                }
            }

            guid = new BigInteger(1,md5.digest()).toString(16);
        }  catch (IOException | NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
        for (Token token : tokens) {
            token.resetFoundFirst();
        }

        return guid;
    }

    private String getDate() {
        return dateformat.format(new Date());
    }

    public void processDependentFiles() {
        guidToken.setValue(getGuid());
        dateToken.setValue(getDate());
        
        for (final Openable openable : dependentFiles) {
            try {
                ByteArrayOutputStream os = new ByteArrayOutputStream();
                try (final Writer tmp = new OutputStreamWriter(os)) {
                    processFiles(openable.openInput(), tmp);
                }

                try (BufferedWriter writer = new BufferedWriter(openable.openOutput())) {
                    writer.append(os.toString());
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private void processFiles(Reader source, Writer destination) throws IOException {
        try (final BufferedReader reader = new BufferedReader(source);
                final BufferedWriter writer = new BufferedWriter(destination)) {

            String line =  reader.readLine();
            while (line != null) {
                for (Token token : tokens) {
                    if (!token.hasfoundFirst() && line.contains(token.getString())) {
                        token.foundFirst();
                        line = line.replaceFirst(token.getRegex(), token.getValue());
                    }
                }

                writer.write(line);
                writer.write('\n');
                line = reader.readLine();
            }
        }
        for (Token token : tokens) {
            token.resetFoundFirst();
        }
    }

    private static class Token {
        private String string;
        private String regex;
        private String value;
        private boolean foundFirst;
        
        public Token(String string) {
            this.string = string;
            regex = string.replace("$", "\\$");
        }
        
        public String getString() {
            return string;
        }
        
        public String getRegex() {
            return regex;
        }
        
        public String getValue() {
            return value;
        }
        
        public void setValue(String value) {
            this.value = value;
        }
        
        public boolean hasfoundFirst() {
            return foundFirst;
        }
        
        public void foundFirst() {
            foundFirst = true;
        }
        
        public void resetFoundFirst() {
            foundFirst = false;
        }
    }

    private static interface Openable {
        public Reader openInput();
        public Writer openOutput();
    }
    
    private static class FileOpenable implements Openable{
        private File file;
        
        public FileOpenable(File file) {
            this.file = file;
        }
        
        @Override
        public Reader openInput() {
            try {
                return new FileReader(file);
            } catch (FileNotFoundException e) {
                throw new RuntimeException(e);
            }
        }
        
        @Override
        public Writer openOutput() {
            try {
                return new FileWriter(file);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
        
        @Override
        public String toString() {
            return file.toString();
        }
    }
    
    private static class StringOpenable implements Openable {
        
        private String input;
        private StringBuilder output;
        
        public StringOpenable(String input, StringBuilder output) {
            this.input = input;
            this.output = output;
        }
        
        @Override
        public Reader openInput() {
            return new StringReader(input);
        }
        
        @Override
        public Writer openOutput() {
            return new Writer() {
                
                @Override
                public void write(char[] cbuf, int off, int len) throws IOException {
                    output.append(cbuf, off, len);
                }
                
                @Override
                public void flush() throws IOException {
                    // Do nothing
                }
                
                @Override
                public void close() throws IOException {
                    // Do nothing
                }
            };
        }
    }
}
