unit index_generation;

interface

type
  link = ^tree_node_t;
  tree_node_t = record
    node_number: longint;
    row, column: longint;
    element: double;
    left, right: link;
    height: integer;
  end ;
{
  Ask name of file.
}
procedure Name(var s: string);
{
  Read matrix from file and automatically create tree.
}  
procedure Read_From_File(var root: link;
                         var count: longint;
                         var m, n: integer;
                         s: string );
{ 
  Create nodes. Insert value to tree from matrix. 
  Main generation tree procedure.
} 
procedure Add_To_Tree(var x, root: link;
                       i, j: longint;
                       l: double;
                       var count: longint);
                       
procedure Obhod_Spec_0(tr: link; var count: longint);

procedure Obhod_Spec_1(tr: link; f: text);
procedure Obhod_Spec_2(tr: link; f: text);
procedure Index_File(s: string; root: link);
procedure Balance_Tree(var tr: link);
procedure Spec_Balance(var tr: link);
function Left_Rotation(var x: link): link;
function Right_Rotation(var x: link): link;
function Height(var tr: link): longint;
procedure Print_Output(s: string);

implementation

procedure Name(var s: string);
begin
  writeln('Введите название файла: ');
  readln(s);
end;

procedure Read_From_File(var root: link; var count: longint; var m, n: integer; s: string );

var
  f: text;
  c: char;
  x: link;
  flag, l1, l2: integer;
  l: double;
  i, j: longint;
  s1: string;

begin
  count := 0;
  assign(f, s);
  reset(f);
  s := '';
  repeat
    read(f, c);
    if c = ' ' then continue;
    if c = '#' then
    begin
      readln(f, c);
      continue;
    end;
    if (s = '') and (c <> ' ') and (Ord(c) <> 10) and (Ord(c) <> 13) and (Ord(c) <> 9) and (c <> 'm') 
    then
    begin
      writeln('Неправильный ввод');
      break;
    end; 
    if c = 'm' then  
      repeat
        s := s + c;
        read(f, c);
      until (c = ' ') or eoln(f);
    if s <> 'matrix' then begin
      writeln('Неправильный ввод');
      break;
    end
    else break;
  until eoln(f);
  {
    Input amount of rows.
  }  
  s := '';
  repeat
    read(f, c);
    if c = ' ' then continue;
    if c in ['0'..'9'] then
      repeat
        s := s + c;
        read(f, c);
      until c = ' ';
    val(s, m, flag);
    if flag = 1 then
    begin
      writeln('Неправильный ввод');
      break
    end;
  until true;
  {
    Input amount of columns.
  }  
  flag := 0;
  s := '';
  repeat
    read(f, c);
    if c = ' ' then continue;  
    if c in ['0'..'9'] then
      repeat
        s := s + c;
        read(f, c);      
      until (c = ' ') or eoln(f);
    val(s, n, flag);
    if flag = 1 then
    begin
      writeln('Неправильный ввод');    
      break
    end;
  until true;
  while (not eof(f)) and (not eoln(f)) do
  begin
    read(f, c);
    if (c <> ' ') then
    begin
      writeln('Неправильный ввод');
      break
    end;
  end;
  flag := 0;
  count := count + 1;
  if eoln(f) then readln(f); 
  {
    Loop input elements.
  }  
  s := '';
  while not eof(f) do 
  begin
    flag := 0;
    i := 0; j := 0; l := 0; s := ''; s1 := '';
    l1 := 0; l2 := 0;
    read(f, c);
    if c = ' ' then continue;
    if (c <> ' ') and (not (c in ['0'..'9'])) then 
    begin
      writeln('Неправильный ввод');    
      break
    end;
    if c in ['0'..'9'] then
      repeat
        s := s + c;
        read(f, c);      
      until c = ' ';
    val(s, i, flag);
    if flag = 1 then
    begin
      writeln('Неправильный ввод');     
      break
    end;
    flag := 0;
    repeat
      read(f, c);
      if c = ' ' then continue;
    until true;
    if (c <> ' ') and (not (c in ['0'..'9'])) then 
    begin
      writeln('Неправильный ввод');  
      break
    end;
    s := '';
    if c in ['0'..'9'] then
      repeat
        s := s + c;
        read(f, c);      
      until c = ' ';
    val(s, j, flag);
    if flag = 1 then
    begin
      writeln('Неправильный ввод');    
      break
    end;
    flag := 0;
    s := '';
    s1 := '';
    repeat
      read(f, c);
      if c = ' ' then continue;
    until true;
    if (c <> ' ') and (not (c in ['0'..'9'])) and (c <> '-')  then 
    begin
      writeln('Неправильный ввод');
      break
    end;
    if (c in ['0'..'9']) or (c = '-') or (c = '.') then
      repeat
        if flag = 0 then s := s + c;
        read(f, c);
        if flag = 1 then s1 := s1 + c;
        if (c = '.') and (flag = 0) then flag := 1;
      until (c = ' ') or eoln(f) or (length(s1) > 4);
    flag := 0;
    val(s, l1, flag);
    if flag = 1 then
    begin
      writeln('Неправильный ввод');
      break
    end;
    flag := 0;
    val(s1, l2, flag);
    if s1 = '' then flag := 0;
    if flag = 1 then
    begin
      writeln('Неправильный ввод');
      break
    end;
    if length(s1) <> 0 then
      l := l1 + l2 / exp((ln(10) * length(s1)))
    else
      l := l1;
    readln(f);
    if ((i + j) <> 0) and ((i * j) = 0) then
    begin
      writeln('Неправильный ввод');
      break
    end;
    Add_To_Tree(x, root, i, j, l, count);
  end;
  close(f);
end;

procedure Create_Node(var tr: link; i, j: integer; l: double; var count: longint);
begin
  New(tr);
  tr^.row := i;
  tr^.column := j;
  tr^.element := l;
  tr^.Left := nil;
  tr^.Right := nil;
  tr^.node_number := count;
  Balance_Tree(tr); 
end;

procedure Add_To_Tree(var x, root: link; i, j: longint; l: double; var count: longint);
begin
  if root = nil Then Create_Node(Root, i, j, l, count) 
  else
    Balance_Tree(root);
  with root^ do 
  begin
    if (row < i) or ((row = i) and (column < j))  then Add_To_Tree(x, Right, i, j, l, count) 
      else
    if (row > i) or ((row = i) and (column > j)) Then Add_To_Tree(x, left, i, j, l, count)
    else
  end;
  Balance_Tree(root);
end;

function Height(var tr: link): longint;
begin
  if tr <> nil then
    Height := tr^.height
  else
    Height := 0;
end;

function Left_Rotation(var x: link): link;
var
  t: link;
begin
  t := x^.right;
  x^.right := t^.left;
  t^.left := x;
  Spec_Balance(x);
  Spec_Balance(t);
  Left_Rotation := t;
end;

function Right_Rotation(var x: link): link;
var
  t: link;
begin
  t := x^.left;
  x^.left := t^.right;
  t^.right := x;
  Spec_Balance(t);
  Spec_Balance(x);
  Right_Rotation := t;
end;

procedure Balance_Tree(var tr: link);
begin
  Spec_Balance(tr);
  if (Height(tr^.right) - Height(tr^.left) = 2) then begin{разность высот 2}
    if(Height(tr^.right^.right) - Height(tr^.right^.left) < 0) then tr^.right := Right_Rotation(tr^.right);
    tr := Left_Rotation(tr); {тогда левый поворот}
  end;
  if (Height(tr^.right) - Height(tr^.left) = -2) then begin{разность высот -2}
    if(Height(tr^.left^.right) - Height(tr^.left^.left) > 0) then tr^.left := Left_Rotation(tr^.left);
    tr := Right_Rotation(tr); {правый поворот}
  end;
end;

procedure Obhod_Spec_0(tr: link; var count: longint);{симметричный обход и присваивание ключей для удобства использования}
begin
  if tr <> nil then
  begin
    Obhod_Spec_0(tr^.left, count);
    count := count + 1;
    tr^.node_number := count;
    
    
    Obhod_Spec_0(tr^.right, count);
  end;
end;

procedure Spec_Balance(var tr: link);
var
  height_left, height_right: longint;
begin
  height_left := Height(tr^.left);
  height_right := Height(tr^.right);
  if (height_left > height_right) then tr^.height := height_left + 1
  else tr^.height := height_right + 1;
end;

procedure Obhod_Spec_1(tr: link; f: text);{Симметричный порядок прохождения}
begin
  if tr <> nil then
  begin
    Obhod_Spec_1(tr^.left, f);
    with tr^ do
      writeln(f, node_number, ' [label="', row, ' ', column, '\n', element, '"];');      
    Obhod_Spec_1(tr^.right, f);
  end;
end;

procedure Obhod_Spec_2(tr: link; f: text);{обход и запись в файл}
begin
  if tr <> nil then
  begin
    if tr^.left <> nil then
      writeln(f, tr^.node_number, ' -> ', tr^.left^.node_number, ' [label="L"];');
    if tr^.right <> nil then 
      writeln(f, tr^.node_number, ' -> ', tr^.right^.node_number, ' [label="R"];');
    Obhod_Spec_2(tr^.left, f);      
    Obhod_Spec_2(tr^.right, f);
  end;
end;

procedure Index_File(s: string; root: link);{создание файла}
var
  f: text;
begin
  assign(f, s);
  rewrite(f);
  writeln(f, 'digraph');
  writeln(f, '{');
  Obhod_Spec_1(root, f);
  writeln(f);
  writeln(f, '//edges');
  writeln(f);
  Obhod_Spec_2(root, f);
  writeln(f, '}');
  close(f);
end;

procedure Print_Output(s: string);
var
  f: text;
  st: string;
begin
  assign(f, s);
  reset(f);
  repeat
    readln(f, st);
    writeln(st);
  until eof(f);
end;

end.
