package LoadResourceTest
    model LoadResource
        function fileLength
            input String name;
            output Integer contents;
            external annotation(Include="
#include <stdio.h>
#include <stdlib.h>
int fileLength(const char* name) {
    int i = 0;
    FILE *fp = fopen(name, \"r\");
    if (!fp) {
        return -1;
    } else {
        while((fgetc(fp)) != EOF)
            i++;
    }
    fclose(fp);
    return i;
}
        ");
        end fileLength;

        constant  Integer x = fileLength(Modelica.Utilities.Files.loadResource("modelica://LoadResourceTest/Resources/aFile.txt"));
        parameter Integer y = fileLength(Modelica.Utilities.Files.loadResource("modelica://LoadResourceTest/Resources/aFile.txt"));
        discrete  Integer z = fileLength(ModelicaServices.ExternalReferences.loadResource("modelica://LoadResourceTest/Resources/aFile.txt"));
    end LoadResource;
    
    model LoadResourceError1
        String s1 = Modelica.Utilities.Files.loadResource("modelica://LoadResourceTest/Resources/missing1.txt");
        String s2 = Modelica.Utilities.Files.loadResource("modelica://LoadResourceTest/Resources/missing2.txt");
    end LoadResourceError1;
end LoadResourceTest;