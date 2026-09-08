
import os
import re

def parse_options_file(filepath):
    options = []
    with open(filepath, 'r') as f:
        content = f.read()

    # Split by ******* separator lines
    blocks = re.split(r'\*+', content)

    for block in blocks:
        lines = block.strip().split('\n')
        if not lines:
            continue

        # First line usually contains the definition
        # TYPE NAME CATEGORY VISIBILITY DEFAULT ...
        # But sometimes it's multiline? No, usually first line.

        definition_line = lines[0].strip()
        if not definition_line:
            continue

        parts = definition_line.split()
        if len(parts) < 4:
            continue

        opt_type = parts[0]
        opt_name = parts[1]
        # category = parts[2] # e.g. compiler, runtime
        # visibility = parts[3] # e.g. user, uncommon, internal

        # Default value is tricky. It starts at index 4.
        # If string, it might be quoted.

        default_val_str = " ".join(parts[4:])

        # Handle string quotes
        if opt_type == 'STRING':
            # Extract content inside first quotes
            match = re.match(r'"(.*?)"', default_val_str)
            if match:
                default_val = match.group(1)
            else:
                default_val = ""
        else:
            # Take the first token as default
            default_val = parts[4]

        options.append({
            'type': opt_type,
            'name': opt_name,
            'default': default_val
        })
    return options

files = [
    'Compiler/ModelicaCompiler/module.options',
    'Compiler/ModelicaCompiler/runtime.options',
    'Compiler/ModelicaMiddleEnd/module.options',
    'Compiler/ModelicaCBackEnd/module.options'
]

all_options = []
seen_names = set()

for fp in files:
    if os.path.exists(fp):
        opts = parse_options_file(fp)
        for o in opts:
            if o['name'] not in seen_names:
                all_options.append(o)
                seen_names.add(o['name'])

# Generate Groovy code
print("""
task generateDummyOptions {
    def outputDir = layout.buildDirectory.dir("generated/java").get().asFile
    def packageDir = new File(outputDir, "org/jmodelica/modelica/compiler/generated")
    def outputFile = new File(packageDir, "OptionRegistry.java")

    outputs.file outputFile

    doLast {
        packageDir.mkdirs()
        outputFile.text = \"\"\"
package org.jmodelica.modelica.compiler.generated;

import org.jmodelica.common.options.AbstractOptionRegistry;
import org.jmodelica.common.options.StringOption;
import org.jmodelica.common.options.BooleanOption;
import org.jmodelica.common.options.IntegerOption;
import org.jmodelica.common.options.RealOption;

public class OptionRegistry extends AbstractOptionRegistry {
""")

# Declare fields
for o in all_options:
    java_type = ""
    if o['type'] == 'STRING': java_type = "StringOption"
    elif o['type'] == 'INTEGER': java_type = "IntegerOption"
    elif o['type'] == 'BOOLEAN': java_type = "BooleanOption"
    elif o['type'] == 'REAL': java_type = "RealOption"

    if java_type:
        print(f"    public final {java_type} {o['name'].upper()};")

print("""
    public OptionRegistry() {
""")

# Initialize fields
for o in all_options:
    name = o['name']
    upper = name.upper()
    default = o['default']

    if o['type'] == 'STRING':
        print(f"        {upper} = new StringOption(\"{name}\", OptionType.compiler, Category.common, \"\", new DefaultValue<String>(\"{default}\"), null);")
        print(f"        optionsMap.put(\"{name}\", {upper});")
    elif o['type'] == 'INTEGER':
        print(f"        {upper} = new IntegerOption(\"{name}\", OptionType.compiler, Category.common, \"\", new DefaultValue<Integer>({default}));")
        print(f"        optionsMap.put(\"{name}\", {upper});")
    elif o['type'] == 'BOOLEAN':
        print(f"        {upper} = new BooleanOption(\"{name}\", OptionType.compiler, Category.common, \"\", new DefaultValue<Boolean>({default}));")
        print(f"        optionsMap.put(\"{name}\", {upper});")
    elif o['type'] == 'REAL':
        print(f"        {upper} = new RealOption(\"{name}\", OptionType.compiler, Category.common, \"\", new DefaultValue<Double>({default}));")
        print(f"        optionsMap.put(\"{name}\", {upper});")

print("""
    }

    @Override
    public OptionRegistry copy() {
        OptionRegistry res = new OptionRegistry();
        res.copyAllOptions(this);
        return res;
    }

    public static OptionRegistry buildOptions() {
        return new OptionRegistry();
    }

    public static OptionRegistry buildTestOptions() {
        return new OptionRegistry();
    }
}
\"\"\"
    }
}
""")
