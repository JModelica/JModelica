package org.jmodelica.util.xml;

public class DocBookColSpec {
    private String title;
    private String align;
    private String name;
    private String width;
    
    public DocBookColSpec(String title, String align, String name, String width) {
        this.title = title;
        this.align = align;
        this.name = name;
        this.width = width;
    }
    
    public void printColspec(DocBookPrinter out) {
        out.single("colspec", "align", align, "colname", "col-" + name, "colwidth", width);
    }
    
    public void printTitle(DocBookPrinter out) {
        out.oneLine("entry", title, "align", "center");
    }
}