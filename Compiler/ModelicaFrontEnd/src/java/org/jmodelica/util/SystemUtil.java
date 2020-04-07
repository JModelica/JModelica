package org.jmodelica.util;

import java.util.Locale;

/**
 * Utility class for system-related functions.
 */
public final class SystemUtil {

    private static final OperatingSystem OS = OperatingSystem.get();

    private enum OperatingSystem {
        WINDOWS,
        MAC,
        LINUX,
        OTHER;

        static OperatingSystem get() {

            String osName = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);
            if (osName.indexOf("win") >= 0) {
                return WINDOWS;
            }
            if (osName.indexOf("nux") >= 0) {
                return LINUX;
            }
            if ((osName.indexOf("mac") >= 0) || (osName.indexOf("darwin") >= 0)) {
                return MAC;
            }

            return OTHER;
        }
    }

    /**
     * Hide default constructor; utility class.
     */
    private SystemUtil() {}

    /**
     * @return a string describing what operating system this is.
     */
    public static String getOS() {
        return OS.name().toLowerCase();
    }

    /**
     * @return {@code true} if the current operating system is Mac.
     */
    public static boolean isMac() {
        return OS == OperatingSystem.MAC;
    }

    /**
     * @return {@code true} if the current operating system is Linux.
     */
    public static boolean isLinux() {
        return OS == OperatingSystem.LINUX;
    }

    /**
     * @return {@code true} if the current operating system is Windows.
     */
    public static boolean isWindows() {
        return OS == OperatingSystem.WINDOWS;
    }

    /**
     * @return the relevant file extension for the current operating system.
     */
    public static String executableExtension() {
        return isLinux() ? "" : ".exe";
    }

    /**
     * @param fileName The string to which to append the relevant file extension.
     * @return {@code string} with the proper file extension for the operating
     *         system.
     */
    public static String executableExtension(String fileName) {
        return fileName + executableExtension();
    }
}
