program semyon;
{$L newmod.obj}
{uses
  Crossing_and_Mutation;}
  procedure Double_Point_Crossover(var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 left_point, right_point:word);
pascal;
external name '_DOUBLE_POINT_CROSSOVER@0';                                 
procedure Single_Point_Crossover(var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 point:word);
pascal;
external name '_SINGLE_POINT_CROSSOVER@0';
procedure Versatile_Point_Crossover(var new_1:word;
                                    first_indiv, second_indiv:word;
                                    mask:word); 
pascal;
external name '_VERSATILE_POINT_CROSSOVER@0';  

procedure Bit_Mutation(var new_1:word; indiv:word; point:word);
pascal;
external name '_BIT_MUTATION@0';
procedure Replace_Mutation(var new_1:word; indiv:word; first_point, second_point:word);
pascal;
external name '_REPLACE_MUTATION@0';
procedure Reverse_Mutation(var new_1:word; indiv:word; first_point:word);
pascal;
external name '_REVERSE_MUTATION@0';


function Random_Range(min: integer; max: integer): integer;
begin
  Random_Range := Random(max - min + 1) + min;
end;

var
  i,j:integer;
  x,y:word;
  a,c:word;
  l,r:integer;
  f:text;
  mask:word;
begin
  Randseed:=300;
  assign (f, 'spec_asm.txt');
  rewrite (f);
  for i:=1 to 500 do begin 
  
  x:=random (65535);
  y:=random (65535);
  l:=Random_Range (1, 15);
  r:=Random_Range (l, 16);
  mask:=Random (65535);
  {for j:=l to r do
  begin
  mask:=mask shl 1;
  mask:=mask or 1;
  end;}
  
   Double_Point_Crossover (a, c, x, y, l, r);// 1110 0101 -- 1101 0110 -- 13 6 
  //Bit_Mutation (a, x, l);
  //Replace_Mutation (a, x, l,r);
  //Reverse_Mutation (a, x, l);
  //Single_Point_Crossover (a, c, x, y, l);
  //Versatile_Point_Crossover (a, x, y,  mask);
 write (f, 'indiv_1 = ', x, 'indiv_2 = ', y,'new_1 = ', a, 'new_2 = ', c, 'left = ', l,'right = ', r); 
 writeln(f);
  {Double_Point_Crossover (a,c, 10, 5, 14, 16);
  writeln (f, a);
  writeln (f, c);}
  
  end;
  close (f);
end.  
