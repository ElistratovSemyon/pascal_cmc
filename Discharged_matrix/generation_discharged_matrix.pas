unit generation_discharged_matrix ;

interface

const
  MAX_INT = 32767;
  MAX_LONGINT = 2147483647;
  MAX_LONGINT_DIGIT = 10;

type
  density_t = double;
procedure Ask_Type(var type_of_work: integer);
procedure Ask_Density(var density: density_t);
procedure Ask_Dimension(var m, n: longint);
procedure Name_Of_File(var s: string);
{
  Distinct procedure for generation matrix,
  because single matrix is square.
}  
procedure Ask_Dimension_Type_3(var n: longint);
procedure Generation_type_3(n: longint; s: string; type_of_output: integer);
procedure Generation_type_1(m, n: longint; s: string; density: density_t; type_of_output: integer);
procedure Generation_type_2(m, n: longint; s: string; density: density_t; type_of_output: integer);
procedure Ask_Output(var type_of_output: integer);
 //
implementation

procedure Ask_Type(var type_of_work: integer);
var
  c_type_of_work: string;
  flag: byte;
  err: integer;
begin
  writeln('Введите режим генерации.');
  writeln('1 - заполненная единицами');
  writeln('2 - со случайными значениями');
  writeln('3 - единичную');
  {repeat}
  repeat
    readln(c_type_of_work);
    val(c_type_of_work, type_of_work, err);
    if err = 1 then
    begin
      writeln('Неправильный ввод');
      c_type_of_work := '';
      continue;
    end;
    if not (type_of_work in [1..3]) then 
    begin
      writeln('Неправильный ввод');
      c_type_of_work := '';
      continue;
    end;
  until true;
  {if (c_type_of_work in ['1'..'3']) and (flag=0)
  then begin
  flag:=1;
  type_of_work:=Ord(c_type_of_work) - Ord('0');
  end
  else writeln ('Неправильный ввод');
  until eoln; }
end;

procedure Ask_Density(var density: density_t);
var
  
  flag: byte;
  err: integer;
begin
  writeln('Введите плотность матрицы');
  repeat
    {
      PascalABC error control.
    }  
    try
      readln(density);
    except
      on System.IO.IOException do
      begin
        writeln('Неправильный ввод');
        continue;
      end;
      on System.FormatException  do
      begin
        writeln('Неправильный ввод');
        continue;
      end;
    end;
    if (density <= 0 ) or (density >= 1 ) then
    begin
      writeln('Неправильный ввод');
      continue;
    end;
  until true;
  
  
  {if (c_density in ['1'..'3']) and (flag=0)
  then begin
  flag:=1;
  density:=Ord(c_density) - Ord('0');
  end
  else writeln ('Неправильный ввод');
  until eoln; }
end;

procedure Ask_Dimension(var m, n: longint);
var
  c_m, c_n: string;
  err: integer;
begin
  writeln('Введите размеры матрицы');
  writeln('Введите кол-во строк: ');
  {repeat} 
  {$I-}
  repeat
    readln(c_m);
    val(c_m, m, err);
    if err = 1 then 
    begin
      writeln('Неправильный ввод');
      c_m := '';
      continue;
    end;
  until true;
  err := 0;
  {if IOResult = 1 then writeln ('Неправильный ввод') else break;}
  {$I+}
  {until false; }
  writeln('Введите кол-во столбцов: ');
  {repeat} 
  {$I-}
  repeat
    readln(c_n);
    val(c_n, n, err);
    if err = 1 then 
    begin
      writeln('Неправильный ввод');
      c_n := '';
      continue;
    end;
  until true;
  {if IOResult = 1 then writeln ('Неправильный ввод') else break;}
  {$I+}
  {until false;}
end;

procedure Name_Of_File(var s: string);
begin
  writeln('Введите название файла: ');
  readln(s);
end;

procedure Ask_Dimension_Type_3(var n: longint);
var
  err: integer;
  c_n: string;
begin
  writeln('Введите порядок матрицы: ');
  repeat
    {$I-}
    readln(c_n);
    val(c_n, n, err);
    if err = 1 then 
    begin
      writeln('Неправильный ввод');
      c_n := '';
      continue;
    end;
    {$I+}
  until true;
end;

procedure Generation_type_3(n: longint; s: string; type_of_output: integer);
var
  f: text;
  i, j: integer;
begin
  randomize;
  assign(f, s);
  rewrite(f);
  writeln(f, 'matrix ', n, ' ', n);
  if type_of_output = 2
  then
  begin
    for i := 1 to n do
      writeln(f, i, ' ', i, ' ', 1)
  end    
  else
  begin
    for i := 1 to n do 
    begin
      for j := 1 to n do
        if i = j then write(f, 1, ' ') else write(f, 0, ' ');
      writeln(f);
    end;
  end;
  close(f);
end;

procedure Generation_type_1(m, n: longint; s: string; density: density_t; type_of_output: integer);
var
  a: array [1..MAX_INT] of integer;
  f: text;
  buf, l, j, k, i, amount_of_numbers: integer;

begin
  randomize;
  assign(f, s);
  rewrite(f);
  writeln(f, 'matrix ', m, ' ', n);
  amount_of_numbers := Trunc(density * n);
  for i := 1 to m do 
  begin
    for j := 1 to amount_of_numbers do
      a[j] := Random(1, n);
    for j := 1 to amount_of_numbers - 1 do
      for l := j + 1 to amount_of_numbers do
        if a[j] = a[l] then a[l] := 0;
    for j := 1 to amount_of_numbers - 1 do 
    begin
      for l := j + 1 to amount_of_numbers do 
      begin
        if a[j] > a[l] then begin
          buf := a[j]; a[j] := a[l]; a[l] := buf;
        end;
      end;
    end;
    if type_of_output = 2
    then
    begin
      for j := 1 to amount_of_numbers do
        if a[j] <> 0 then writeln(f, i, ' ', a[j], ' ', 1)
    end    
    else
    begin
      l := 1;
      while a[l] = 0 do
        l := l + 1;
      for k := 1 to n do 
      begin
        if k = a[l] then
        begin
          write(f, 1, ' ');
          l := l + 1;
      end
        else write(f, 0, ' ');   
      end;
      writeln(f);    
    end;           
  end;  
  close(f);
end;

procedure Generation_type_2(m, n: longint; s: string; density: density_t; type_of_output: integer);
var
  a: array [1..MAX_INT] of integer;
  f: text;
  buf, l, j, k, i, amount_of_numbers: integer;
  x: real;

begin
  
  randomize;
  assign(f, s);
  rewrite(f);
  
  writeln(f, 'matrix ', m, ' ', n);
  
  amount_of_numbers := Trunc(density * n);
  
  for i := 1 to m do 
  begin
    for j := 1 to amount_of_numbers do
      a[j] := Random(1, n);
    for j := 1 to amount_of_numbers - 1 do
      for l := j + 1 to amount_of_numbers do
        if a[j] = a[l] then a[l] := 0;
    for j := 1 to amount_of_numbers - 1 do 
      for l := j + 1 to amount_of_numbers do 
      begin
        if a[j] > a[l] then begin
          buf := a[j]; a[j] := a[l]; a[l] := buf;
        end;
      end;
    
    if type_of_output = 2
    then
    begin
      for j := 1 to amount_of_numbers do 
      begin
        x := Random(-10000.0, 10000.0);
        if a[j] <> 0 then writeln(f, i, ' ', a[j], ' ', x)
      end
    end    
    else
    begin
      l := 1;
      while a[l] = 0 do
        l := l + 1;
      
      for k := 1 to n do 
      begin
        if k = a[l] then
        begin
          x := Random(-10000.0, 10000.0);
          write(f, x, ' ');
          l := l + 1;
          
        end
        else write(f, 0, ' '); 
        
      end;
      writeln(f);    
    end;
    
  end;  
  close(f);
end;

procedure Ask_Output(var type_of_output: integer);
var
  c_type_of_output: string;
  err: integer;
begin
  writeln('Выберите тип вывода');
  writeln('1 - плотная матрица');
  writeln('2 - индекс ненулевого элемента и его значение');
  repeat
    readln(c_type_of_output);
    val(c_type_of_output, type_of_output, err);
    if err = 1 then
    begin
      writeln('Неправильный ввод');
      c_type_of_output := '';
      continue;
    end;
    if not (type_of_output in [1..2]) then 
    begin
      writeln('Неправильный ввод');
      c_type_of_output := '';
      continue;
    end;
  until true;
end;


end.





