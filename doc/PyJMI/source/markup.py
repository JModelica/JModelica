
def mark_examples():
    import pyjmi.examples as examples
    
    exclude = [""]
    
    for ex in examples.__all__:
        
        if ex in exclude:
            continue
            
        file = open("EXAMPLE_"+ex+".rst",'w')
        
        file.write(ex + '.py\n')
        file.write('===================================================================\n\n')
        file.write('.. autofunction:: pyjmi.examples.'+ex+'.run_demo\n\n')
        file.write('.. note::\n\n')
        file.write('    Press [source] (to the right) to view the example.\n')
        file.close()


mark_examples()
