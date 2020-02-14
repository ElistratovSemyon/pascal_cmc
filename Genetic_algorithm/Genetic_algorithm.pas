program genetic;
{$R-}

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
function Random_Range(min: integer; max: integer): integer;
begin
  Random_Range := Random(max - min + 1) + min;
end;

{
  Input configuration file.
}
function Configuration_File(var config: config_t): boolean;
var
  f: text;
  c: char;
  s, s1: string;
  flag: integer;
  l1, l2, i: integer;
  l: real;
  spec: array [1..10] of real;
begin
  {$I-}  
  Configuration_File := false;
  assign(f, 'Configuration.txt');
  reset(f);
  if IOResult = 1 then writeln ('bad file');
  {$I+}
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
  
  if (spec[1] > 4) or (spec[1] < 1) or (spec[1] <> round(spec[1])) then exit;
  if (spec[2] > 3) or (spec[2] < 1) or (spec[2] <> round(spec[2])) then exit;
  if (spec[3] < 1) or (spec[4] < 1) or (spec[5] < 1) or (spec[6] < 1)
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
  Configuration_File := true;
  close(f);
end;



function Target_Function(x: real): real;
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
  Target_Function := res;
end;

procedure Spec_Shift(var a: mas_t; j, N: integer);
var
  i: integer;
begin
  for i := j to N - 1 do
    a[i] := a[i + 1];
  a[N] := 0;
end;

function Cleaner(var a: mas_t; N: integer; var count_n: integer): boolean;
var
  i, j, point: integer;
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

procedure Sorting(var a: mas_t; N: integer);
var
  i, j: integer;
  buf_l: integer;
  res_1, res_2: real;
begin
  for i := 1 to N - 1 do
    for j := i + 1 to N do
    begin
      res_1 := Target_Function((a[i] / SPEC_INT));
      res_2 := Target_Function((a[j] / SPEC_INT));
      if res_1 < res_2 then
      begin
        buf_l := a[i];
        a[i] := a[j];
        a[j] := buf_l;
      end;
    end;  
end;

procedure Random_Selection(var a: mas_t; N: integer;
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
    j := Random_Range(1 + high, N - low);
    a[j] := 0;
    Spec_Shift(a, j, N);
    count_n := count_n - 1;
  end;
end;

procedure Double_Point_Crossover(var mas: mas_t;
                                 first_indiv, second_indiv, N: integer;
                                 var count_n: integer);
var
  left_point, right_point, i: integer;
begin
  left_point := Random_Range(1, GENS - 2);
  right_point := Random_Range(left_point, GENS);
  
  mas[count_n + 1] := first_indiv;
  mas[count_n + 2] := second_indiv;
  for i := left_point to right_point do
  begin
    if (first_indiv and (1 shl (GENS - i))) <> 
      (second_indiv and (1 shl (GENS - i))) then
    begin
      mas[count_n + 1] := mas[count_n + 1] xor (1 shl (GENS - i ));
      mas[count_n + 2] := mas[count_n + 2] xor (1 shl (GENS - i));
    end; 
  end;
  count_n := count_n + 2;  
end;

procedure Single_Point_Crossover(var mas: mas_t;
                                 first_indiv, second_indiv, N: integer;
                                 var count_n: integer);
var
  point, i, res_1, res_2: integer;
begin
  point := Random_Range(2, GENS - 1);
  res_1 := first_indiv and (1 shl point);
  res_2 := second_indiv and (1 shl point);
  mas[count_n + 1] := first_indiv;
  mas[count_n + 2] := second_indiv;
  for i := point to GENS do
  begin
    if res_1 <> res_2 then
    begin
      mas[count_n + 1] := mas[count_n + 1] xor (1 shl i);
      mas[count_n + 2] := mas[count_n + 2] xor (1 shl i);
    end; 
  end;
  count_n := count_n + 2;
  
  
end;

procedure Versatile_Point_Crossover(var mas: mas_t;
                                    first_indiv, second_indiv, N: integer;
                                    var count_n: integer);
var
  i: integer;
begin
  mas[count_n + 1] := first_indiv;
  
  for i := 1 to GENS do
  begin
    if Random_Range(1, 2) = 2 then 
    begin
      if (first_indiv and (1 shl (GENS - i))) <>
        (second_indiv and (1 shl (GENS - i))) then
      begin
        mas[count_n + 1] := mas[count_n + 1] xor (1 shl (GENS - i));
      end;
    end;   
  end;
  count_n := count_n + 1;
end;

procedure Homogeneous_Point_Crossover(var mas: mas_t;
                                      first_indiv, second_indiv, N: integer;
                                      var count_n: integer);
var
  i: integer;
  mask: array [1..GENS] of boolean;
begin
  mas[count_n + 1] := first_indiv;
  for i := 1 to GENS do
  begin
    if Random_Range(0, 1) = 1 then mask[i] := true
    else
      mask[i] := false;
  end;
  for i := 1 to GENS do
  begin
    if mask[i] then 
      if (first_indiv and (1 shl (GENS - i))) <>
          (second_indiv and (1 shl (GENS - i))) then
      begin
        mas[count_n + 1] := mas[count_n + 1] xor (1 shl (GENS - i));
      end;
  end;   
  
  count_n := count_n + 1;
  
end;

procedure Bit_Mutation(var mas: mas_t; indiv, N: integer; var count_n: integer);
var
  point, i: integer;
begin
  point := Random_Range(1, GENS);
  mas[count_n + 1] := indiv xor (1 shl (GENS - point));
  count_n := count_n + 1;
end;

procedure Replace_Mutation(var mas: mas_t; indiv, n: integer; var count_n: integer);
var
  first_point, second_point, i, spec_1, spec_2: integer;
  buf: boolean;
begin
  first_point := random_range(1, GENS);
  second_point := random_range(1, GENS);
  spec_1 := indiv and (1 shl (GENS - first_point));
  spec_2 := indiv and (1 shl (GENS - second_point));
  if spec_1 <> spec_2
  then
  begin
    mas[count_n + 1] := indiv xor (1 shl (GENS - first_point));
    mas[count_n + 1] := mas[count_n + 1] xor (1 shl (GENS - second_point));
    count_n := count_n + 1;
  end;
end;

procedure Reverse_Mutation(var mas: mas_t; indiv, N: integer; var count_n: integer);
var
  point, i, spec_1, spec_2: integer;
begin
  point := Random_Range(1, GENS - 2);
  mas[count_n + 1] := indiv;
  for i := point to GENS do
  begin
    if indiv and (1 shl (i - point)) <>
      indiv and (1 shl (GENS - i)) then
    begin
      mas[count_n + 1] := mas[count_n + 1] xor (1 shl GENS - point);
    end;
  end;   
end;


procedure Annihilation(var mas: mas_t; N: integer);
var
  edge: byte;
  i: integer;
begin
  edge := Random_Range(1, 3);
  for i := edge to N do
    mas[i] := Random(MAX_WORD);  
end;


var
  N, i, j, n_spec, index_1, index_2, count, count_valueless: integer;
  population: mas_t;
  max, max_1, max_2, last_max: real;
  config: config_t;
  q: char;
  f: text;
  count_n: integer;
  flag, annihilation_flag: boolean;
  s: string;
  type_of_output: byte;

begin
  randomize;
  {$I-}
  assign(f, 'output.txt');
  if IOResult = 1 then halt(222);
  {$I+}
  if Configuration_File(config) = false then
  begin
    writeln('Error in configuration file');
  end
  else
  begin
    repeat
      {$I-}  
      rewrite(f);
      if IOResult = 1 then halt(1000);
      {$I+}
      with config do
      begin
        count := 0;
        count_valueless := 0;
        annihilation_flag := false;
        writeln('Input size of population. N > 3');
        readln(N);
    				{$I-}
        repeat
          writeln('Plese select output. 1 - file, 2 - console');
          readln(type_of_output);
          if (IOResult = 1) or (type_of_output < 1) or
            (type_of_output > 2) then 
            continue;	   
        until true;
    				{$I+}
        writeln('CONNECT ANNIHILATION PROCESS? YES or something.');
        readln(s);
        if (s = 'yes') or (s = 'YES') or (s = 'Yes')
        then
        begin
          annihilation_flag := true;
        end;  
        count_n := N;
        SetLength(population, N + 1);
        count := 0;
        for i := 1 to N do
        begin
          population[i] := Random(MAX_WORD);        
        end;
        Sorting(population, N);
        repeat
          Random_Selection(population, N, preserved_high_positions,
          preserved_low_positions, selection_coefficient, count_n);
          Sorting(population, N);
          n_spec := round(N * crossing_volume);
          if count_n + 2 < N then
            for i := 1 to n_spec div 2 do
            begin
              repeat
                index_1 := Random_Range(1, N);
                index_2 := Random_Range(1, N);
              until index_1 <> index_2;
              case crossing_type of
                
                1:
                  Single_Point_Crossover(population, population[index_1],
                              population[index_2], N, count_n);
                2:
                  Double_Point_Crossover(population, population[index_1],
                              population[index_2], N, count_n);
                3:
                  Versatile_Point_Crossover(population, population[index_1],
                              population[index_2], N, count_n);
                4:
                  Homogeneous_Point_Crossover(population, population[index_1],
                              population[index_2], N, count_n);    
              end;
              if count_n >= N - 1 then break; 
            end;
          Sorting(population, N);
          n_spec := round(N * variability);
          i := 1;
          if count_n < N then
            while count_n <> n do
            begin
              index_1 := Random_Range(1, N);
              case mutation_type of
                1: Bit_Mutation(population, population[index_1], N, count_n);
                2: Replace_Mutation(population, population[index_1], N, count_n);
                3: Reverse_Mutation(population, population[index_1], N, count_n);
              end;
              if count_n >= N then break;
            end;
          Sorting(population, N);
          if (Random_Range(0, 100) > 95) and annihilation_flag then
          begin
            count_valueless := 0;
            if type_of_output = 2 then
              writeln('PROCESS OF RANDOM ANNIHILATION IS STARTED.')
            else
              writeln(f, 'PROCESS OF RANDOM ANNIHILATION IS STARTED.');
            Annihilation(population, N);
            writeln;
          end;
          repeat
            flag := Cleaner(population, N, count_n);
          until flag;
          Sorting(population, N);
          max_1 := Target_Function((population[1] / SPEC_INT));
          max_2 := Target_Function((population[2] / SPEC_INT));
          if abs(max_1 - last_max) < eps
            then
            count_valueless := count_valueless + 1
          else
            count_valueless := 0;
          count := count + 1;
          if type_of_output = 1 then writeln(f, count, ' population')
          else
            writeln( count, ' population');
          if (type_of_work = 2) then
          begin
            for i := 1 to N do
            begin
              if type_of_output = 1 then
              begin
                writeln(f, 'value = ',
                  Target_Function((population[i] / SPEC_INT)):1:10);
                writeln(f, 'gen = ', population[i]);
                writeln(f);
              end
       							else
              begin
                writeln('value = ', 
                  Target_Function((population[i] / SPEC_INT)):1:10);
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
          end;
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
        {
          Output
        }
        max := max_1;
        if type_of_output = 1 then
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
        end
        
      end;
      close(f);
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
  end;
end.
