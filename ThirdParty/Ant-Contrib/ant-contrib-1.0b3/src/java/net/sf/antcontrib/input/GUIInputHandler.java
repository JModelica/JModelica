/*
 * Copyright (c) 2001-2004 Ant-Contrib project.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package net.sf.antcontrib.input;

import java.awt.*;
import javax.swing.*;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.input.InputHandler;
import org.apache.tools.ant.input.InputRequest;
import org.apache.tools.ant.input.MultipleChoiceInputRequest;

/**
 * Prompts for user input using a JOptionPane. Developed for use with
 * Antelope, migrated to ant-contrib Oct 2003.
 *
 * @author <a href="mailto:danson@germane-software.com">Dale Anson</a>
 * @version $Revision: 1.3 $
 * @since Ant 1.5
 */
public class GUIInputHandler implements InputHandler {

    private Component parent = null;

    public GUIInputHandler() {}

    /**
     * @param parent the parent component to display the input dialog.
     */
    public GUIInputHandler( Component parent ) {
        this.parent = parent;
    }

    /**
     * Prompts and requests input.  May loop until a valid input has
     * been entered.
     */
    public void handleInput( InputRequest request ) throws BuildException {

        if ( request instanceof MultipleChoiceInputRequest ) {
            String prompt = request.getPrompt();
            String title = "Select Input";
            int optionType = JOptionPane.YES_NO_OPTION;
            int messageType = JOptionPane.QUESTION_MESSAGE;
            Icon icon = null;
            Object[] choices = ( ( MultipleChoiceInputRequest ) request ).getChoices().toArray();
            Object initialChoice = null;
            do {
                Object input = JOptionPane.showInputDialog(parent, prompt, 
                    title, optionType, icon, choices, initialChoice);
                if (input == null)
                   throw new BuildException("User cancelled.");
                request.setInput(input.toString());
            } while (!request.isInputValid());
            
        }
        else {
            do {
                String input = JOptionPane.showInputDialog( parent, request.getPrompt() );
                request.setInput( input );
            } while ( !request.isInputValid() );
        }
    }

}
