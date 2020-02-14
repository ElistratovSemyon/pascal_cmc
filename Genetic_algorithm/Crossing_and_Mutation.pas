 unit Crossing_and_Mutation;
interface
const
  GENS = 16;
  

type
  mas_t = array of word;
  mas_mask = array [1..16] of byte;


 

procedure Double_Point_Crossover(var check_file:text; var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 left_point, right_point:word);
                                 
procedure Real_Double_Point_Crossover(var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 left_point, right_point:word);
                                 
procedure Single_Point_Crossover(var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 point:word);
procedure Versatile_Point_Crossover(var new_1:word;
                                    first_indiv, second_indiv:word;
                                    mask:word);                                   
procedure Homogeneous_Point_Crossover(var new_1:word;
                                    first_indiv, second_indiv:word;
                                    mask:mas_mask);   
procedure Bit_Mutation(var new_1:word; indiv:word; point:word);
procedure Replace_Mutation(var new_1:word; indiv:word; first_point,
                               second_point:word);
procedure Reverse_Mutation(var new_1:word; indiv:word; point:word);
                           
implementation
{
    First and second indivs is parents.
    Points - random gen.
    New - new individuals in population.
    Mask - random word (Versatile)
    or array of random byte values (Homogeneous).
}
procedure Double_Point_Crossover(var check_file:text; var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 left_point, right_point:word);
begin
    writeln(check_file,'Double_Point_Crossover enter new_1= ',new_1,' new_2= ',new_2, ' indiv_1= ', first_indiv, ' indiv_2=', second_indiv, ' left= ', left_point, ' right= ', right_point );
    Real_Double_Point_Crossover(new_1, new_2, first_indiv, second_indiv, left_point, right_point);
writeln(check_file,'Double_Point_Crossover leave new_1= ',new_1,' new_2= ',new_2, ' indiv_1= ', first_indiv, ' indiv_2=', second_indiv, ' left= ', left_point, ' right= ', right_point );



end;

procedure Real_Double_Point_Crossover(var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 left_point, right_point:word);
var
  i:word;

begin
  new_1 := first_indiv;
  new_2 := second_indiv;
  for i := left_point to right_point do
  begin
    if (first_indiv and (1 shl (GENS - i))) <> 
      (second_indiv and (1 shl (GENS - i))) then
    begin
      new_1 := new_1 xor (1 shl (GENS - i));
      new_2 := new_2 xor (1 shl (GENS - i));   
 end; 
  end;
end;

procedure Single_Point_Crossover(var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 point:word);
var
    i:word;
begin
  new_1 := first_indiv;
  new_2 := second_indiv;
  for i := point to GENS do
  begin
    if (new_1 and (1 shl (GENS - i))) <> (new_2 and (1 shl (GENS - i))) then
    begin
      new_1 := new_1 xor (1 shl (GENS - i));
      new_2 := new_2 xor (1 shl (GENS - i));
    end; 
  end;
end;

procedure Versatile_Point_Crossover(var new_1:word;
                                    first_indiv, second_indiv:word;
                                    mask:word);
var
  i: byte;
begin
  new_1:=(mask and second_indiv) or ((not mask) and first_indiv);
 
 {new_1 := first_indiv;
  
  for i := 1 to GENS do
  begin
    if (mask and (1 shl (GENS - i))) = 1 then
    begin
      if (first_indiv and (1 shl (GENS - i))) <>
        (second_indiv and (1 shl (GENS - i))) then
      begin
        new_1 := new_1 xor (1 shl (GENS - i));
      end;
    end;   
  end;}

end;

procedure Homogeneous_Point_Crossover(var new_1:word;
                                    first_indiv, second_indiv:word;
                                    mask:mas_mask);
var
  i: byte;
begin
  new_1 := first_indiv;
  for i := 1 to GENS do
  begin
    if mask[i] = 1 then 
    begin 
      if (first_indiv and (1 shl (GENS - i))) <>
        (second_indiv and (1 shl (GENS - i))) then
      begin
        new_1:= new_1 xor (1 shl (GENS - i));
      end;
    end;   
  end; 
end;  


procedure Bit_Mutation(var new_1:word; indiv:word; point:word);  
begin
  new_1 := indiv xor (1 shl (GENS - point));
end;

procedure Replace_Mutation(var new_1:word; indiv:word; first_point,
                                second_point:word);
var
  spec_1, spec_2: word;
begin
  new_1:=indiv;
  spec_1 := 1 shl (GENS - first_point);
  spec_2 := 1 shl (GENS - second_point);
  if (indiv and spec_1)  <> (indiv and spec_2)
  then
  begin
    new_1 := indiv xor spec_1;
    new_1 := new_1 xor spec_2;
  end;
end;

procedure Reverse_Mutation(var new_1:word; indiv:word; point:word);
var
  spec_1, spec_2, mask, indiv_spec: word;
  i:word;
begin
  {$R-}
  spec_2:=0;
  indiv_spec:=indiv;
  for i:=0 to 16-point do
  begin
    spec_1:=indiv_spec and 1;
    indiv_spec:=indiv_spec shr 1;
    spec_2:=spec_2 or spec_1;
    spec_2:=spec_2 shl 1
  end;
  mask:=1 shl (17-point);
  mask:=mask-1;
  new_1:=(indiv and (not mask)) or spec_2;
  {$R+}
end;

end.                   