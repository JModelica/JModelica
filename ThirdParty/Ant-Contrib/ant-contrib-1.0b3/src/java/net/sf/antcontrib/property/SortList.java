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
 package net.sf.antcontrib.property;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Enumeration;
import java.util.StringTokenizer;
import java.util.Vector;
import java.util.Locale;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.Reference;

/****************************************************************************
 * Place class description here.
 *
 * @author <a href='mailto:mattinger@yahoo.com'>Matthew Inger</a>
 * @author		<additional author>
 *
 * @since
 *
 ****************************************************************************/


public class SortList
        extends AbstractPropertySetterTask
{
    private String value;
    private Reference ref;
    private boolean casesensitive = true;
    private boolean numeric = false;
    private String delimiter = ",";
    private File orderPropertyFile;
    private String orderPropertyFilePrefix;

    public SortList()
    {
        super();
    }

    public void setNumeric(boolean numeric)
    {
        this.numeric = numeric;
    }

    public void setValue(String value)
    {
        this.value = value;
    }


    public void setRefid(Reference ref)
    {
        this.ref = ref;
    }


    public void setCasesensitive(boolean casesenstive)
    {
        this.casesensitive = casesenstive;
    }

    public void setDelimiter(String delimiter)
    {
        this.delimiter = delimiter;
    }


    public void setOrderPropertyFile(File orderPropertyFile)
    {
        this.orderPropertyFile = orderPropertyFile;
    }


    public void setOrderPropertyFilePrefix(String orderPropertyFilePrefix)
    {
        this.orderPropertyFilePrefix = orderPropertyFilePrefix;
    }


    private static void mergeSort(String src[],
                                  String dest[],
                                  int low,
                                  int high,
                                  boolean caseSensitive,
                                  boolean numeric) {
        int length = high - low;

        // Insertion sort on smallest arrays
        if (length < 7) {
            for (int i=low; i<high; i++)
                for (int j=i; j>low &&
                        compare(dest[j-1],dest[j], caseSensitive, numeric)>0; j--)
                    swap(dest, j, j-1);
            return;
        }

        // Recursively sort halves of dest into src
        int mid = (low + high)/2;
        mergeSort(dest, src, low, mid, caseSensitive, numeric);
        mergeSort(dest, src, mid, high, caseSensitive, numeric);

        // If list is already sorted, just copy from src to dest.  This is an
        // optimization that results in faster sorts for nearly ordered lists.
        if (compare(src[mid-1], src[mid], caseSensitive, numeric) <= 0) {
            System.arraycopy(src, low, dest, low, length);
            return;
        }

        // Merge sorted halves (now in src) into dest
        for(int i = low, p = low, q = mid; i < high; i++) {
            if (q>=high || p<mid && compare(src[p], src[q], caseSensitive, numeric)<=0)
                dest[i] = src[p++];
            else
                dest[i] = src[q++];
        }
    }

    private static int compare(String s1,
                               String s2,
                               boolean casesensitive,
                               boolean numeric)
    {
        int res = 0;

        if (numeric)
        {
            double d1 = new Double(s1).doubleValue();
            double d2 = new Double(s2).doubleValue();
            if (d1 < d2)
                res = -1;
            else if (d1 == d2)
                res = 0;
            else
                res = 1;
        }
        else if (casesensitive)
        {
            res = s1.compareTo(s2);
        }
        else
        {
            Locale l = Locale.getDefault();
            res = s1.toLowerCase(l).compareTo(s2.toLowerCase(l));
        }

        return res;
    }

    /**
     * Swaps x[a] with x[b].
     */
    private static void swap(Object x[], int a, int b) {
        Object t = x[a];
        x[a] = x[b];
        x[b] = t;
    }


    private Vector sortByOrderPropertyFile(Vector props)
        throws IOException
    {
        FileReader fr = null;
        Vector orderedProps = new Vector();

        try
        {
            fr = new FileReader(orderPropertyFile);
            BufferedReader br = new BufferedReader(fr);
            String line = "";
            String pname = "";
            int pos = 0;
            while ((line = br.readLine()) != null)
            {
                pos = line.indexOf('#');
                if (pos != -1)
                    line = line.substring(0, pos).trim();

                if (line.length() > 0)
                {
                    pos = line.indexOf('=');
                    if (pos != -1)
                        pname = line.substring(0,pos).trim();
                    else
                        pname = line.trim();

                    String prefPname = pname;
                    if (orderPropertyFilePrefix != null)
                        prefPname = orderPropertyFilePrefix + "." + prefPname;

                    if (props.contains(prefPname) &&
                        ! orderedProps.contains(prefPname))
                    {
                        orderedProps.addElement(prefPname);
                    }
                }
            }

            Enumeration e = props.elements();
            while (e.hasMoreElements())
            {
                String prop = (String)(e.nextElement());
                if (! orderedProps.contains(prop))
                    orderedProps.addElement(prop);
            }

            return orderedProps;
        }
        finally
        {
            try
            {
                if (fr != null)
                    fr.close();
            }
            catch (IOException e)
            {
                ; // gulp
            }
        }
    }

    protected void validate()
    {
        super.validate();
    }

    public void execute()
    {
        validate();

        String val = value;
        if (val == null && ref != null)
            val = ref.getReferencedObject(project).toString();

        if (val == null)
            throw new BuildException("Either the 'Value' or 'Refid' attribute must be set.");

        StringTokenizer st = new StringTokenizer(val, delimiter);
        Vector vec = new Vector(st.countTokens());
        while (st.hasMoreTokens())
            vec.addElement(st.nextToken());


        String propList[] = null;

        if (orderPropertyFile != null)
        {
            try
            {
                Vector sorted = sortByOrderPropertyFile(vec);
                propList = new String[sorted.size()];
                sorted.copyInto(propList);
            }
            catch (IOException e)
            {
                throw new BuildException(e);
            }
        }
        else
        {
            String s[] = (String[])(vec.toArray(new String[vec.size()]));
            propList = new String[s.length];
            System.arraycopy(s, 0, propList, 0, s.length);
            mergeSort(s, propList, 0, s.length, casesensitive, numeric);
        }

        StringBuffer sb = new StringBuffer();
        for (int i=0;i<propList.length;i++)
        {
            if (i != 0) sb.append(delimiter);
            sb.append(propList[i]);
        }

        setPropertyValue(sb.toString());
    }
}
