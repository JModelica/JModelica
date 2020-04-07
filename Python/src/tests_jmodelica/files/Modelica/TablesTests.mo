package TablesTest
 model Table1DfromArray
  Modelica.Blocks.Sources.Sine sine(freqHz=1, amplitude=2);
  Modelica.Blocks.Tables.CombiTable1D modelicaTable1D(
    table=[0.0,0.0; 1,1; 3,5]);
 equation
  connect(sine.y, modelicaTable1D.u[1]);
 end Table1DfromArray;
 
 model Table2DfromArray
  parameter Real table1[:, :]=
        [0,0,10,20,30,40,50,60,70,80,90,100;
        0,0,0,0,0,0,0,0,0,0,0,0;
        0.1,0.2,2,4,6,8,10,12,14,16,18,20;
        0.2,0.4,4,8,12,16,20,24,28,32,36,40;
        0.3,0.6,6,12,18,24,30,36,42,48,54,60;
        0.4,0.8,8,16,24,32,40,48,56,64,72,80;
        0.5,1,10,20,30,40,50,60,70,80,90,100;
        0.6,1.2,12,24,36,48,60,72,84,96,108,120;
        0.7,1.4,14,28,42,56,70,84,98,112,126,140;
        0.8,1.6,16,32,48,64,80,96,112,128,144,160;
        0.9,1.8,18,36,54,72,90,108,126,144,162,180;
        1,2,20,40,60,80,100,120,140,160,180,200; 1.1,2.2,
        22,44,66,88,110,132,154,176,198,220;
        1.2,2.4,24,48,72,96,120,144,168,192,216,240;
        1.3,2.6,26,52,78,104,130,156,182,208,234,260;
        1.4,2.8,28,56,84,112,140,168,196,224,252,280;
        1.5,3,30,60,90,120,150,180,210,240,270,300;
        1.6,3.2,32,64,96,128,160,192,224,256,288,320;
        1.7,3.4,34,68,102,136,170,204,238,272,306,340;
        1.8,3.6,36,72,108,144,180,216,252,288,324,360;
        1.9,3.8,38,76,114,152,190,228,266,304,342,380;
        2.0,4,40,80,120,160,200,240,280,320,360,400];

  Modelica.Blocks.Sources.Sine src1(freqHz=1, amplitude=2);
  Modelica.Blocks.Sources.Constant src2(k=0);
  Modelica.Blocks.Tables.CombiTable2D modelicaTable2D(
    table=table1);
 equation
  connect(src1.y, modelicaTable2D.u1);
  connect(src2.y, modelicaTable2D.u2);
 end Table2DfromArray;
 
 model Table1DfromFile
  Modelica.Blocks.Sources.Sine sine(freqHz=1, amplitude=2);
  Modelica.Blocks.Tables.CombiTable1D modelicaTable1D(
    tableOnFile=true,
    tableName="spring_data",
    fileName="../Data/spring.tab");
 equation
  connect(sine.y, modelicaTable1D.u[1]);
 end Table1DfromFile;
 
 model Table2DfromFile
  Modelica.Blocks.Sources.Sine sine(freqHz=1, amplitude=2);
  Modelica.Blocks.Sources.Constant const(k=0.25);
  Modelica.Blocks.Tables.CombiTable2D modelicaTable2D(
    tableOnFile=true,
    tableName="table2D",
    fileName="../Data/table2.txt");
 equation 
  connect(sine.y, modelicaTable2D.u1);
  connect(const.y, modelicaTable2D.u2);
 end Table2DfromFile;
end TablesTest;
