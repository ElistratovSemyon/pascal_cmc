program tree;

uses generation_discharged_matrix;

var
  type_of_work, type_of_output: integer;
  m, n: longint;
  s: string;
  density: density_t;

begin
  Ask_Type(type_of_work); 
  if type_of_work = 3 then  
  begin
    Ask_Dimension_Type_3(n);
    Name_Of_File(s);
    Ask_Output(type_of_output);
    Generation_type_3(n, s, type_of_output);
  end
  else
  begin
    Ask_Dimension(m, n);
    Ask_Density(density);
    Name_Of_File(s);
    Ask_Output(type_of_output);
    if type_of_work = 1 then Generation_type_1(m, n, s, density, type_of_output)
    else
      Generation_type_2(m, n, s, density, type_of_output)
  end;
  
end.