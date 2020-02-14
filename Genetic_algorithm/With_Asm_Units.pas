program genetic;
{$R-}

uses
  Crossing_and_Mutation_asm,
    dos;
const
  LEFT_EDGE = 0;
  RIGHT_EDGE = 4;
  BEGIN_N = 30;
  eps = 1 / 16384;
  spec_eps = 0.00001;
  GENS = 16;
  MIN_INT = -32768;
  MAX_INT = 32767;
  MAX_WORD = 65535;
  SPEC_INT = 16384;


type
  mas_t = array of word;
  mas_mask = array [1..16] of byte;
  config_t = record
    crossing_type: 1..4;
    mutation_type: 1..3;
    preserved_high_positions: byte;
    preserved_low_positions: byte;
    max_iters: word;
    max_valueless_iters: word;
    enough_function_value: real;
    variability: real;
    crossing_volume: real;
    selection_coefficient: real;
    type_of_work: integer;
  end;
{
	For free pascal.
}
function Random_range(min: integer; max: integer): integer;
begin
  Random_range := Random(max - min + 1) + min;
end;
{
	The function which extremum we try to find.
}

function Target_function(x: real): real;
var
  i: integer;
  res: real;
begin
  res := 1;
  for i := 1 to 5 do
    res := res * (x - 1.1);
  for i := 1 to 4 do
    res := res * (x - 1.2);
  for i := 1 to 3 do
    res := res * (x - 1.3);
  res := res * x * cos(x + 100);
  Target_function := res;
end;

{
	Input configuration file.
}
function Configuration_file(var config: config_t): boolean;
var
  f: text;
  c: char;
  s, s1: string;
  flag: integer;
  l1, l2, i: integer;
  l: real;
  spec: array [1..10] of real;
begin
  Configuration_file := false;
  {$I-}
  assign(f, 'Configuration.txt');
  if IOResult = 1 then
  begin
    writeln ('not assign configuration file');
    halt(1);
  end;
  reset(f);
  if IOResult = 1 then
  begin
    writeln ('not reset configuration file');
    halt(1);
  end;
  {$I+}
  {
	Cycle reading integer parametrs.
  }
  for i := 1 to 6 do
  begin
    s := '';
    l := 0;
    repeat
      read(f, c);
      if c = '#' then readln(f);
    until c in ['0'..'9'];
    repeat
      s := s + c;
      read(f, c);
    until c = ';';
    val(s, l, flag);
    if flag = 1 then exit;
    spec[i] := l;
    while not eoln(f) do
      read(f, c);
  end;
  {
	Cycle reading float parametrs.
  }
  for i := 7 to 10 do
  begin
    flag := 0;
    l1 := 0;
    l2 := 0;
    l := 0;
    s1 := '';
    s := '';
    l := 0;
    repeat
      read(f, c);
      if c = '#' then readln(f);
    until c in ['0'..'9'];
    repeat
      if (flag = 0) and (c <> ';') then s := s + c;
      read(f, c);
      if (flag = 1) and (c <> ';') then s1 := s1 + c;
      if (c = '.') and (flag = 0) then flag := 1;
    until c = ';';
    flag := 0;
    val(s, l1, flag);
    if flag = 1 then
    begin
      exit
    end;
    flag := 0;
    val(s1, l2, flag);
    if s1 = '' then flag := 0;
    if flag = 1 then exit;
    if length(s1) <> 0 then
      l := l1 + l2 / exp((ln(10) * length(s1)))
    else
      l := l1;
    spec[i] := l;
    while not eoln(f) do
      read(f, c);
  end;
  s := '';
  l := 0;
  repeat
    read(f, c);
    if c = '#' then readln(f);
  until c in ['0'..'9'];
  repeat
    s := s + c;
    read(f, c);
  until c = ';';
  val(s, l, flag);
  if flag = 1 then exit;
  if l <> round(l) then exit;
  config.type_of_work := round(l);
  while not eoln(f) do
    read(f, c);
{
	Check all parametrs.
}  
  if (spec[1] > 4) or (spec[1] < 1) or (spec[1] <> round(spec[1])) then exit;
  if (spec[2] > 3) or (spec[2] < 1) or (spec[2] <> round(spec[2])) then exit;
  if (spec[3] < 1) or (spec[4] < 0) or (spec[5] < 1) or (spec[6] < 1)
    or (spec[3] <> round(spec[3])) or (spec[4] <> round(spec[4])) or
      (spec[5] <> round(spec[5])) or (spec[6] <> round(spec[6]))
    then
    exit;
  if (spec[7] > 0.231) then
  begin
    writeln('senselessly :( . too enough big value');
  end;
  if not config.type_of_work in [1..2] then exit;
  with config do
  begin
    crossing_type := round(spec[1]);
    mutation_type := round(spec[2]);
    preserved_high_positions := round(spec[3]);
    preserved_low_positions := round(spec[4]);
    max_iters := round(spec[5]);
    max_valueless_iters := round(spec[6]);
    enough_function_value := spec[7];
    variability := spec[8];
    crossing_volume := spec[9];
    selection_coefficient := spec[10];
  end;
  Configuration_file := true;
  close(f);
end;


{
	Special procedure which shift array when selection.
}

procedure Spec_shift(var a: mas_t; j, N: integer);
var
  i: integer;
begin
  for i := j to N - 1 do
    a[i] := a[i + 1];
  a[N] := 0;
end;
{
	Kill repeated individuals.
}
function Cleaner(var a: mas_t; N: integer; var count_n: integer): boolean;
var
  i, j: integer;
begin
  Cleaner := true;
  for i := 1 to N - 1 do
    for j := i + 1 to N do
      if a[i] = a[j] then
      begin
        a[j] := random(MAX_WORD);
        Cleaner := false;
      end;
end;
{
	Bubble sorting.
}
procedure Sorting(var a: mas_t; N: integer);
var
  i, j: integer;
  buf_l: integer;
  res_1, res_2: real;
begin
  for i := 1 to N - 1 do
    for j := i + 1 to N do
    begin
      res_1 := Target_function((a[i] / SPEC_INT));
      res_2 := Target_function((a[j] / SPEC_INT));
      if res_1 < res_2 then
      begin
        buf_l := a[i];
        a[i] := a[j];
        a[j] := buf_l;
      end;
    end;  
end;
{
	Selection with random values.
}
procedure Random_selection(var a: mas_t; N: integer;
                            high, low: integer;
                            selection_coefficient: real;
                            var count_n: integer
                            );
var
  i, j, n_spec: integer;
begin
  n_spec := round((N - high - low) * selection_coefficient);
  for i := 1 to n_spec do
  begin
    j := Random_range(1 + high, N - low);
    a[j] := 0;
    Spec_shift(a, j, N);
    count_n := count_n - 1;
    
  end;
  
end;


var
  N, i, n_spec, index_1, index_2, count, count_valueless: integer;
  population: mas_t;
  max, max_1, last_max: real;
  config: config_t;
  q: char;
  count_n: integer;
  f: text;
  flag: boolean;
  first_point, second_point:word;
  mask_1:word;
  mask_2:mas_mask; //????
  j:byte;
  H1 , M1 , S1 , ms1,
  H2 , M2 , S2 , ms2 :word;
  type_of_output: byte;
  check_file:text;
begin
  {$I-}
  assign(f, 'output_asm.txt');
  rewrite(f);
  if IOResult = 1 then halt(222);
  {$I+}
  
  //Randomize;
  if Configuration_file(config) = false then
  begin
    writeln('Error in configuration file');
    halt(500)
 end;
 
 {$I-}  
      assign (check_file, 'check_file_asm.txt');
      rewrite (check_file);
      if IOResult <> 0 then
      begin
          writeln('Can not open file check_file_pas.txt ');
          halt(1000);
      end;
  {$I+}

 
 
    repeat
		{
			Main cycle.
		}
      Randseed:= 300;
      
      with config do
      begin
        count := 0;
        count_valueless := 0;
        writeln ('Input size of population. N > 3');
        readln (N);
        {$I-}
        repeat
          writeln('Plese select output. 1 - file, 2 - console');
          readln(type_of_output);
          if (IOResult = 1) or (type_of_output < 1) or
            (type_of_output > 2) then 
            continue;	   
        until true;
    		{$I+}
    		GetTime(H1 , M1 , S1 , ms1);
        count_n := N;
        SetLength(population, N + 1);
        count := 0;
        for i := 1 to N do
        begin
          population[i] := Random(MAX_WORD);        
        end;
        Sorting(population, N);
        repeat
        
          {
			Start procedures cycle.
		  }
          Random_selection(population, N, preserved_high_positions,
          preserved_low_positions, selection_coefficient, count_n);
          Sorting(population, N);
          n_spec := round(N * crossing_volume);
          
         
          if count_n + 2 < N then
            for i := 1 to n_spec div 2 do
            begin
              repeat
                index_1 := Random_range(1, N);
                index_2 := Random_range(1, N);
              until index_1 <> index_2;
              
              if crossing_type < 3 then first_point:=Random_range (1, GENS-2);
              if crossing_type = 2 then second_point:=Random_range (first_point, GENS);
              if crossing_type = 3 then mask_1:=Random(MAX_WORD);
             if crossing_type = 4
             then
               for j:=1 to 16 do
                 mask_2[j]:=Random (1);
              
             case crossing_type of
                
                1:
                  Single_Point_Crossover(population[count_n+1], population[count_n+2], population[index_1],
                              population[index_2], first_point);
                2:
                  Double_Point_Crossover(check_file, population[count_n+1], population[count_n+2], population[index_1],
                              population[index_2], first_point, second_point);
                3:
                  Versatile_Point_Crossover(population[count_n+1], population[index_1],
                              population[index_2], mask_1);
                4:
                  Homogeneous_Point_Crossover(population[count_n+1], population[index_1],
                              population[index_2], mask_2);
              end;
                case crossing_type of
                
                1, 2: 
                        count_n:=count_n+2;
                3, 4:
                        count_n:=count_n+1;
                
                end;
              if count_n >= N - 1 then break; 
            end;
          Sorting(population, N);
          n_spec := round(N * variability);
          i := 1;
          if count_n < N then
            while count_n <> n do
            begin
              index_1 := Random_range(1, N);
              first_point:=Random_range (1, GENS-2);
              if mutation_type = 2 then second_point:=Random_Range (first_point, GENS);
              case mutation_type of
                1: Bit_Mutation(population[count_n+1], population[index_1], first_point);
                2: Replace_Mutation(population[count_n+1], population[index_1], first_point, second_point);
                3: Reverse_Mutation(population[count_n+1], population[index_1], first_point);
              end;
              count_n:=count_n+1;
              if count_n >= N then break;
            end;
          
          Sorting(population, N);
          repeat
            flag := Cleaner(population, N, count_n);
          until flag;
          Sorting(population, N);
          max_1 := Target_function((population[1] / SPEC_INT));
          if abs(max_1 - last_max) < eps
            then
            count_valueless := count_valueless + 1
          else
            count_valueless := 0;
          count := count + 1;
		  {
			Start output.
		  }
          {if type_of_output = 1 then writeln(f, count, ' population')
          else
            writeln( count, ' population');
          if (type_of_work = 2) then
          begin
            for i := 1 to N do
            begin
              if type_of_output = 1 then
              begin
                writeln(f, 'value = ',
                  Target_function((population[i] / SPEC_INT)):1:10);
                writeln(f, 'gen = ', population[i]);
                writeln(f);
              end
       							else
              begin
                writeln('value = ', 
                  Target_function((population[i] / SPEC_INT)):1:10);
                writeln('gen = ', population[i]);
                writeln;
              end;
            end;
          end
          else
          begin
            if type_of_output = 1 then
            begin
              writeln(f, 'value = ', max_1:1:10);
              writeln(f, 'gen = ', population[1]);
              writeln(f, 'size of populattion = ', count_n);
              writeln(f);
            end
       					else
            begin
              writeln('value = ', max_1:1:10);
              
              writeln('gen = ', population[1]);
              writeln('size of populattion = ', count_n);
            end;
          end;}
          if (abs(max_1 - last_max) < eps)
            and (count_valueless > max_valueless_iters) then
            break
          else
          if (count > max_iters) then break
            else
          if (abs(max_1 - enough_function_value) < eps)
              then
            break;
          last_max := max_1;
        until false;
     
        max := max_1;
        {if type_of_output = 1 then
        begin
          writeln(f, 'Result:');
          writeln(f, 'iteration= ', count);
          writeln(f, 'function value=', max:1:10);
        end
    				else
        begin
          writeln('Result:');
          writeln('iteration= ', count);
          writeln('function value=', max:1:10);
        end}
        
      end;
      close(f);
      writeln;
      GetTime(H2 , M2 , S2 , ms2);
      writeln('Time of the beginning:');
      writeln(H1 ,' : ', M1 ,' : ', S1 ,' : ', ms1);
      writeln('Time of the end:');
      writeln(H2 ,' : ', M2 ,' : ', S2 ,' : ', ms2);
      writeln('Work time (milliseconds):');
      writeln(ms2 + S2*100 + M2*6000 + H2*360000 -
               ms1 - S1*100 - M1*6000 - H1*360000);
      writeln;         
      writeln('input q to exit, r to restart');
      repeat
        readln(q);
        if q = 'q' then break;
        if q = 'r' then
        begin
          for i := 1 to N do
            population[i] := 0;
          
        end;
      until q = 'r';
      if q = 'r' then continue;
    until q = 'q';
  
  close (check_file);
  writeln('By by');
end.
