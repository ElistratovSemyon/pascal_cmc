unit Crossing_and_Mutation_asm;
{$L newmod.obj}
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

procedure Homogeneous_Point_Crossover(var new_1:word;
                                    first_indiv, second_indiv:word;
                                    mask:mas_mask); 
pascal;
external name '_HOMOGENEOUS_POINT_CROSSOVER@0';  
procedure Bit_Mutation(var new_1:word; indiv:word; point:word);
pascal;
external name '_BIT_MUTATION@0';
procedure Replace_Mutation(var new_1:word; indiv:word; first_point, second_point:word);
pascal;
external name '_REPLACE_MUTATION@0';
procedure Reverse_Mutation(var new_1:word; indiv:word; first_point:word);
pascal;
external name '_REVERSE_MUTATION@0';
implementation                           

procedure Double_Point_Crossover(var check_file:text; var new_1, new_2:word;
                                 first_indiv, second_indiv:word;
                                 left_point, right_point:word);
begin
writeln(check_file,'Double_Point_Crossover enter new_1= ',new_1,' new_2= ',new_2, ' indiv_1= ', first_indiv, ' indiv_2=', second_indiv, ' left= ', left_point, ' right= ', right_point );
    Real_Double_Point_Crossover(new_1, new_2, first_indiv, second_indiv, left_point, right_point);
writeln(check_file,'Double_Point_Crossover leave new_1= ',new_1,' new_2= ',new_2, ' indiv_1= ', first_indiv, ' indiv_2=', second_indiv, ' left= ', left_point, ' right= ', right_point );


end;


end.
