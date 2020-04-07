package org.jmodelica.common.evaluation;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.Timer;
import java.util.TimerTask;

import org.jmodelica.common.LogContainer;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Type;
import org.jmodelica.common.evaluation.ExternalProcessMultiCache.Value;
import org.jmodelica.util.values.ConstantEvaluationException;

/**
 * A class for handling communication with an external process during constant
 * evaluation.
 * 
 * Important to always destroy() properly. If process is locked in a waiting
 * call and never GC'd the JVM can't terminate. If process is alive but not
 * waiting it can die without destroy. Still, always destroy()!
 * 
 * Callers which use calls that interact with process have responsibility to
 * start/stop timer. The timer is used to prevent the compiler from hanging due
 * to an error in the process or communication.
 */
public class ProcessCommunicator<V extends Value, T extends Type<V>> {

    private BufferedReader in;
    private BufferedWriter out;
    private Process process;
    private Timer timer;
    private TimerTask task;
    private String buffLine = null;
    private boolean timeOutHappened = false;
    private int timeOut = 0;

    private LogContainer mc;

    public ProcessCommunicator(LogContainer mc, Process proc) {
        this.mc = mc;
        process = proc;
        in = new BufferedReader(new InputStreamReader(process.getInputStream()));
        out = new BufferedWriter(new OutputStreamWriter(process.getOutputStream()));
        timer = new Timer();
    }

    private String getLine() throws IOException {
        String line = buffLine;
        if (line == null)
            line = in.readLine();
        if (line == null) {
            if (timeOutHappened) {
                throw new IOException(String.format("Evaluation timed out, time limit set to %d ms by option %s",
                        timeOut, "external_constant_evaluation"));
            } else {
                throw new IOException("Process halted unexpectedly");
            }
        }
        buffLine = null;
        return line;
    }

    private void buffLine(String line) {
        buffLine = line;
    }

    /**
     * Print <code>val</code>, serialized, to the process
     */
    public void put(V val, T type) throws IOException {
//        mc.log().debug("ProcessCommunicator WRITE: " + val.toString() + " of type:" + type.toString());
        val.serialize(out);
        out.flush();
    }

    /**
     * Read <code>type</code>, serialized, from the process
     */
    public V get(T type) throws IOException {
        V val = type.deserialize(this);
//        mc.log().debug("ProcessCommunicator READ: " + val.toString());
        return val;
    }

    /**
     * Read a line. Check equals to <code>s</code>.
     */
    public void accept(String s) throws IOException {
        log();
        abort();
        String line = getLine();
        if (!line.equals(s)) {
            throw new IOException(String.format("Communication protocol error. Expected '%s', received '%s'", s, line));
        }
    }

    public void check(String s) throws IOException {
        out.write(s);
        out.write("\n");
        out.flush();
    }

    private void log() throws IOException {
        String line = getLine();
        while (line.equals("LOG")) {
            double warning = deserializeReal();
            String name = deserializeString();
            String format = deserializeString();
            String value = deserializeString();
            if (warning != 0)
                mc.log().warning("%s: " + format, name, value);
            else
                mc.log().verbose("%s: " + format, name, value);
            line = getLine();
        }
        buffLine(line);
    }

    private void abort() throws IOException, ConstantEvaluationException {
        String line = getLine();
        if (line.equals("ABORT")) {
            throw new AbortConstantEvaluationException("Evaluation aborted by request of external function");
        }
        buffLine(line);
    }

    static class AbortConstantEvaluationException extends ConstantEvaluationException {
        private static final long serialVersionUID = -2821422352605317014L;

        public AbortConstantEvaluationException(String string) {
            super(null, string);
        }
    }

    /**
     * Wait for and retrieve exit value from process.
     */
    public int end() {
        int res;
        try {
            process.waitFor();
            res = process.exitValue();
        } catch (InterruptedException e) {
            res = -99;
        } catch (IllegalThreadStateException e) {
            res = -100;
        }
        return res;
    }

    /**
     * Tear down everything
     */
    public void destroy() {
        /* Kill timer */
        timer.cancel();
        timer.purge();
        timer = null;

        /* Close streams */
        try {
            in.close();
        } catch (IOException e) {
            // Do nothing
        }
        in = null;
        try {
            out.close();
        } catch (IOException e) {
            // Nothing can be done to recover - ignore
        }
        out = null;

        /* Destroy process */
        process.destroy();
        process = null;
    }

    public double deserializeReal() throws IOException {
        String line = getLine();
        try {
            return Double.parseDouble(line);
        } catch (NumberFormatException e) {
            throw new IOException("Communication protocol error. Failed to parse real number '" + line + "'");
        }
    }

    public String deserializeString() throws IOException {
        String line = getLine();
        int len;
        try {
            len = Integer.parseInt(line);
        } catch (NumberFormatException e) {
            throw new IOException("Communication protocol error. Failed to parse size of string '" + line + "'");
        }
        char[] c = new char[len];
        in.read(c, 0, len);
        in.readLine();
        return new String(c);
    }

    public void startTimer(int timeout) {
        this.timeOut = timeout;
        if (timeout >= 0) {
            if (task != null) {
                // XXX: Throw exception instead?
                task.cancel();
                timer.purge();
            }
            task = new TimerTask() {
                @Override
                public void run() {
                    timeOutHappened = true;
                    process.destroy();
                    cancel();
                }
            };
            timer.schedule(task, timeout);
        }
    }

    public void cancelTimer() {
        if (task != null) {
            task.cancel();
        }
        task = null;
        timer.purge();
    }
}
