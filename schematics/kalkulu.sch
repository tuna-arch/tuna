<Qucs Schematic 0.0.15>
<Properties>
  <View=-42,-40,1292,854,1,0,200>
  <Grid=10,10,1>
  <DataSet=kalkulu.dat>
  <DataDisplay=kalkulu.dpl>
  <OpenDisplay=1>
  <showFrame=0>
  <FrameText0=Title>
  <FrameText1=Drawn By:>
  <FrameText2=Date:>
  <FrameText3=Revision:>
</Properties>
<Symbol>
</Symbol>
<Components>
  <VProbe Pr1 1 1120 120 28 -31 0 0>
  <DigiSource S1 1 70 140 -35 16 0 0 "1" 1 "low" 0 "1ns; 1ns" 0 "1 V" 0>
  <GND * 1 1240 140 0 0 0 0>
  <VProbe Pr2 1 1120 280 28 -31 0 0>
  <DigiSource S2 1 70 300 -35 16 0 0 "2" 1 "low" 0 "1ns; 1ns" 0 "1 V" 0>
  <GND * 1 1240 300 0 0 0 0>
  <VProbe Pr3 1 1120 440 28 -31 0 0>
  <GND * 1 1240 460 0 0 0 0>
  <gatedDlatch Y1 1 220 480 -31 48 0 0 "6" 0 "5" 0 "1 ns" 0>
  <gatedDlatch Y2 1 370 480 -31 48 0 0 "6" 0 "5" 0 "1 ns" 0>
  <Inv Y3 1 270 550 -26 27 0 0 "1 V" 0 "0" 0 "10" 0 "old" 0>
  <Vpulse clock 1 140 650 -26 18 1 2 "0 V" 1 "1 V" 1 "0" 1 "1 s" 1 "1 ns" 0 "1 ns" 0>
  <logic_1 S4 1 70 650 -35 18 0 0 "5" 0>
  <DigiSource S3 1 70 460 -35 16 0 0 "3" 1 "low" 0 "5s; 5s" 0 "1 V" 0>
</Components>
<Wires>
  <1130 140 1240 140 "" 0 0 0 "">
  <1130 300 1240 300 "" 0 0 0 "">
  <1130 460 1240 460 "" 0 0 0 "">
  <170 550 240 550 "" 0 0 0 "">
  <170 500 170 550 "" 0 0 0 "">
  <300 500 300 550 "" 0 0 0 "">
  <300 500 320 500 "" 0 0 0 "">
  <270 460 320 460 "" 0 0 0 "">
  <70 460 170 460 "" 0 0 0 "">
  <420 460 1110 460 "" 0 0 0 "">
  <70 650 110 650 "" 0 0 0 "">
  <170 550 170 650 "" 0 0 0 "">
</Wires>
<Diagrams>
</Diagrams>
<Paintings>
</Paintings>
