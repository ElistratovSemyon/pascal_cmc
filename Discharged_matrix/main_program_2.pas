program zd_2;

uses calculation_discharged_matrix;


var
  f1, f2: text;
  s, s1, s2, si1, si2: string;
  root1, root2, rooti_1, rooti_2, root3, root_r: link;
  m1, n1, m2, n2, count1, count2, count3: longint;
  b: boolean;
  e: double;
  a: link;

begin
  b := true;
  Writeln('Input file left matrix');
  Name(s1);
  Read_From_File(root1, count1, m1, n1, s1);
  Writeln('Input file left index');
  Name(s1);
  assign(f1, s1);
  Read_From_Index(rooti_1, f1);
  count1 := 0;
  Obhod_Spec_0(root1, count1);
  Sravn(root1, rooti_1, b);
  if b then writeln('Index file correct') else 
  begin
    writeln('Index file incorrect');  
  end;
  b := true;
  Writeln('Input file right matrix');
  Name(s2);
  Read_From_File(root2, count2, m2, n2, s2);
  Writeln('Input file right index');
  Name(s2);
  assign(f2, s2);
  Read_From_Index(rooti_2, f2);
  count2 := 0;
  Obhod_Spec_0(root2, count2);
  Sravn(root2, rooti_2, b);
  if b then writeln('Index file correct') else 
    writeln('Index file incorrect');
  if n1 <> m2 then writeln('Not According to the size')
  else
  begin
    Obhod_1(root1, root2, root3);
    Epsilon(e);
    Obhod_Result(root3, root_r, e);
    dispose(root3);
    Writeln('Input file result');
    Name(s);
    count3 := 0;
    Obhod_Spec_0(root_r, count3);
    Output_Matrix(root_r, m1, n2, s);
    Writeln('Input file index if you need or 0');
    Name(s);
    if s <> '0' then Index_File(s, root_r); 
    
  end;
end.