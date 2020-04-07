/*
    Copyright (C) 2015 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package org.jmodelica.junit;

import org.jmodelica.util.test.Assert;

public class JUnitAssert implements Assert {
    @Override
    public void fail(String msg) {
        org.junit.Assert.fail(msg);
    }

    @Override
    public void assertEquals(String msg, String expected, String actual) {
        org.junit.Assert.assertEquals(msg, expected, actual);
    }
}
