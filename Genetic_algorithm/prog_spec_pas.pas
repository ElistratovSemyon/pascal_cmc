program semyon;

uses
  Crossing_and_Mutation;


function Random_Range(min: integer; max: integer): integer;
begin
  Random_Range := Random(max - min + 1) + min;
end;

var
  i:word;
  x,y:word;
  a,c:word;
  l,r:byte;
  f:text;
  mask:word;
begin
  Randseed:=300;
  assign (f, 'spec_pas.txt');
  rewrite (f);
  for i:=1 to 500 do begin 
  
  x:=random (65535);
  y:=random (65535);
  l:=Random_Range (1, 15);
  r:=Random_Range (l, 16);
  mask:=Random (65535);
  Double_Point_Crossover (a, c, x, y, l, r);// 1110 0101 -- 1101 0110 -- 13 6 
  //Replace_Mutation (a, x, l,r);
  //Bit_Mutation (a, x, l);
  //Reverse_Mutation (a, x, l);
  //Single_Point_Crossover (a, c, x, y, l);
  //Versatile_Point_Crossover (a, x, y,  mask);
  write (f, 'indiv_1 = ', x, 'indiv_2 = ', y,'new_1 = ', a, 'new_2 = ', c, 'left = ', l,'right = ', r); 
  writeln (f);
  
  end;
  close (f);
end.  
