unit calculation_discharged_matrix;

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
                         var m, n: longint;
                         s: string );
{ 
  Supporting procedure. Give value to node.
}
procedure Create_Node(var tr: link; i, j: integer; l: double);
{ 
  Create nodes. Insert value to tree from matrix. 
  Main generation tree procedure.
} 
procedure Insert_To_Tree(var  root: link; i, j: longint; l: double);
{
  This procedure define height of node.
}  
function Height(var tr: link): longint;
{
 Rotation.
} 
function Left_Rotation(var x: link): link;
function Right_Rotation(var x: link): link;
{
  This procedure balancing 
}  
procedure Balance_Tree(var tr: link);
{
  This procedure determines whether you need a rotate
}  
procedure Spec_Balance(var tr: link);
{ 
  This function read matrix from index file and automaticaly create tree.
}  
procedure Read_From_Index(var rooti_1: link; var f: text );
{ 
  This procedure looking for node 
  with specifed key to give 
  this node value row, column, element.
}  
procedure Find(p: link; k: integer; var flag: integer; var x: link);
{ 
Supporting procedure. Give value to node of index tree.
}
procedure Create_Node_Index(var p: link; a1: integer);
{ 
  Create nodes. Insert value to tree from matrix. 
  Main generation tree procedure.
} 
procedure InsertIndex(var rooti_1: link; a1, a2: integer; s: string);
{
 Ask epsilon.
} 
procedure Epsilon(var e: double);
{
  Comparing index tree and matrix tree.
}  
procedure Sravn(root, rooti: link; var b: boolean);
{
  First procedure of calculation.

  Traverse first tree.
}  
procedure Obhod_1(root1, root2: link; var root3: link);
{
  Second procedure of calculation.

  Traverse second tree.
}  
procedure Obhod_2(root2, root1: link; var root3: link);
{ 
  This procedure looking for node 
  with specifed row and column.

  This procedure need to know summarize elements 
  or create new node.
}   
procedure FindIJ(p: link; i, j: longint; var flag: integer; var x: link);
{
Third procedure of calculation.

Give values to new tree.
}
procedure Calculation(var root3: link; i, j: longint; pr: double);
{
  Special traverse. Assign node nubmers.
}    
procedure Obhod_Spec_0(tr: link; var count: longint);
{
  Special procedures to create index file.
}  
procedure Obhod_Spec_1(tr: link; f: text);
procedure Obhod_Spec_2(tr: link; f: text);
{
  Create index file.
}  
procedure Index_File(s: string; root: link);
{
  Traverse on the resulting matrix.
}  
procedure Obhod_Result(root3: link; var root_r: link; e: double);
{
  Output the resulting matrix.
}  
procedure Output_Matrix(root_r: link; m, n: longint; s: string);
implementation

procedure Name(var s: string);
begin
  writeln('Please, input file name: ');
  readln(s);
end;

procedure Read_From_File(var root: link;
                         var count: longint;
                         var m, n: longint;
                         s: string );

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
    if (s = '') and (c <> ' ') and (Ord(c) <> 10) 
      and (Ord(c) <> 13) and (Ord(c) <> 9) and (c <> 'm')
    then
    begin
      writeln('error');
      break;
    end; 
    if c = 'm' then  
      repeat
        s := s + c;
        read(f, c);
      until (c = ' ') or eoln(f);
    if s <> 'matrix' then begin
      writeln('error');
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
      writeln('error');
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
    if eoln(f) then s := s + c;
    val(s, n, flag);
    if flag = 1 then
    begin
      writeln('error');    
      break
    end;
  until true;
  while (not eof(f)) and (not eoln(f)) do
  begin
    read(f, c);
    if (c <> ' ') then
    begin
      writeln('error');
      break
    end;
  end;
  flag := 0;
  count := count + 1;
  if eoln(f) then readln(f); 
  {
    Loop. Input elements.
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
      writeln('error');     
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
      writeln('error');     
      break
    end;
    flag := 0;
    repeat
      read(f, c);
      if c = ' ' then continue;
    until true;
    if (c <> ' ') and (not (c in ['0'..'9'])) then 
    begin
      writeln('error');  
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
      writeln('error');    
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
      writeln('error');
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
      writeln('error');     
      break
    end;
    flag := 0;   
    val(s1, l2, flag);
    if s1 = '' then flag := 0;
    if flag = 1 then
    begin
      writeln('error');     
      break
    end;
    if length(s1) <> 0 then
      l := l1 + l2 / exp((ln(10) * length(s1)))
    else
      l := l1;
    readln(f);
    if ((i + j) <> 0) and ((i * j) = 0) then
    begin
      writeln('error');     
      break
    end;
    Insert_To_Tree(root, i, j, l);    
  end;
  close(f);
end;

procedure Create_Node(var tr: link; i, j: integer; l: double);
begin
  if tr = nil then New(tr);
  tr^.row := i;
  tr^.column := j;
  tr^.element := l + tr^.element;
  tr^.Left := nil;
  tr^.Right := nil;
  tr^.node_number := 0;
  Balance_Tree(tr); 
end;

procedure Insert_To_Tree(var root: link; i, j: longint; l: double);
begin
  if root = nil Then Create_Node(Root, i, j, l) 
  else
  begin
    Balance_Tree(root);
    with root^ do 
    begin
      if (row < i) or ((row = i) and (column < j))  then
        Insert_To_Tree( Right, i, j, l)
      else
      if (row > i) or ((row = i) and (column > j)) Then 
        Insert_To_Tree( left, i, j, l)
      else
    end;
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
  if (Height(tr^.right) - Height(tr^.left) = 2) then
  begin(* Height difference 2*)
    if(Height(tr^.right^.right) - Height(tr^.right^.left) < 0) then 
      tr^.right := Right_Rotation(tr^.right);
    tr := Left_Rotation(tr); (* Then left rotation*)
  end;
  if (Height(tr^.right) - Height(tr^.left) = -2) then
  begin(* Height difference -2 *)
    if(Height(tr^.left^.right) - Height(tr^.left^.left) > 0) then
      tr^.left := Left_Rotation(tr^.left);
    tr := Right_Rotation(tr); (* Then right rotation *)
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

procedure Read_From_Index(var rooti_1: link; var f: text );
  
  procedure spec1(var f: text; var c: char);
  begin
    repeat
      read(f, c);
    until c = '/';
  end;
  
  procedure spec2(var f: text; var s: string; var c: char; var a1, a2: integer);
  var
    flag: integer;
    c1: char;
  begin
    repeat
      read(f, c);
      if c = '}' then flag := 2; 
    until (c in ['0'..'9']) or (eof(f));
    if flag = 2 then exit;
    flag := 0;
    
    repeat
      s := s + c;
      read(f, c);
      
    until c = ' ';
    val(s, a1, flag);
    if flag = 1 then
    begin
      writeln('error');
      exit;
    end;
    repeat
      read(f, c);
      if (c <> ' ') and (c <> '-') then
      begin
        writeln('error');
        exit;
      end;
    until c = '-';
    c1 := c;
    read(f, c);
    if (c <> '>') or (c1 <> '-') then 
    begin
      writeln('error');
      exit;
    end;
    s := '';
    repeat
      read(f, c);
      if (c <> ' ') and not (c in ['0'..'9']) then
      begin
        writeln('error');
        exit;
      end;
    until c in ['0'..'9'];
    repeat
      s := s + c;
      read(f, c);      
    until c = ' ';
    val(s, a2, flag);
    if flag = 1 then
    begin
      writeln('error');
      exit;
    end;
    s := '';
    repeat
      read(f, c);
      if (c <> ' ') and (c <> '[') then
      begin
        writeln('error');
        exit;
      end;
    until c = '[';   
    repeat
      s := s + c;
      read(f, c);      
    until c = ';';    
  end;

var
  c, c1: char;
  x: link;
  flag: integer;
  la: double;
  i, ia, la1, la2, ja, a1, a2, j: longint;
  s1, s: string;

begin
   {$I-} 
  reset(f);  
  s := '';
  spec1(f, c);  
  repeat
    s := s + c;
    read(f, c);    
  until (c = ' ') or eoln(f);  
  s := '';
  flag := 0;
  repeat
    spec2(f, s, c, a1, a2);
    if s = '[label="L"]' then
      InsertIndex(rooti_1, a1, a2, s)
    else
    if s = '[label="R"]' then
      InsertIndex(rooti_1, a1, a2, s)
    else
    if s = '' then break
    else  
    if (s <> '[label="R"]') and (s <> '[label="L"]') then
    begin
      writeln('error');
      break;
    end;
    s := '';
  until false;
  close(f); 
  reset(f);
  s := '';
  repeat
    read(f, c);
    if (c <> 'd') and (c <> ' ') then
    begin
      writeln('err');
      exit;
    end;
  until c = 'd'; 
  repeat
    s := s + c;
    read(f, c);   
  until (eoln(f)) or (c = ' ');
  if c <> ' ' then s := s + c; 
  if s <> 'digraph' then
  begin
    writeln('error');
    exit;
  end;
  s := '';
  repeat
    read(f, c);   
    if (c <> '{') and (c <> ' ') and (c <> chr(13)) and (c <> chr(10)) then
    begin
      writeln('error');
      exit;
    end;
  until c = '{';
  repeat
    repeat
      s := '';
      read(f, c);
      if (c = '/') then exit;
      if (c <> ' ') and (not (c in ['0'..'9'])) and (c <> chr(13))
        and (c <> chr(10)) and not eoln(f) then
      begin
        writeln('error');
        exit;
      end;
    until c in ['0'..'9'];
    repeat
      s := s + c;
      read(f, c);
    until c = ' ';
    val(s, a1, flag);
    if flag = 1 then
    begin
      writeln('error');
      exit;
    end;
    s := '';
    repeat
      read(f, c);
      if (c <> ' ') and (c <> '[') then
      begin
        writeln('error');
        exit;
      end;
    until c = '[';
    s := s + c;
    repeat
      read(f, c);
      s := s + c;
    until c = '"';
    if s <> '[label="' then
    begin
      writeln('error');
      exit;
    end;
    s := '';
    repeat
      read(f, c);
      if c <> ' ' then s := s + c;
    until c = ' ';
    val(s, ia, flag);
    if flag = 1 then
    begin
      writeln('error');
      exit;
    end;
    s := '';
    repeat
      read(f, c);
      if (c <> ' ') and not (c in ['0'..'9']) then
      begin
        writeln('error');
        exit;
      end;
    until c in ['0'..'9'];
    repeat
      s := s + c;
      read(f, c);
    until c = '\';
    val(s, ja, flag);
    if flag = 1 then
    begin
      writeln('error');
      exit;
    end;
    s := '';
    s1 := '';
    repeat
      read(f, c);
    until c in ['0'..'9'];
    flag := 0;
    repeat
      if flag = 0 then s := s + c else 
      if length(s1) < 2 then s1 := s1 + c;
      read(f, c);
      if c = '.' then
      begin
        read(f, c);
        flag := 1;
      end;      
    until c = '"';    
    val(s, la1, flag);
    if flag = 1 then
    begin
      writeln('error');
      exit;
    end;
    flag := 0;   
    val(s1, la2, flag);
    if s1 = '' then flag := 0;
    if flag = 1 then
    begin
      writeln('error');     
      break
    end;
    if length(s1) <> 0 then
      la := la1 + la2 / exp((ln(10) * length(s1)))
    else
      la := la1;
    flag := 0;
    Find(rooti_1, a1, flag, x);
    x^.row := ia; x^.column := ja; x^.element := la;
    read(f, c); read(f, c);
  until false;   
end;

procedure Find(p: link; k: integer; var flag: integer; var x: link);
begin
  if p <> nil then
  begin
    if p^.node_number = k then
    begin
      flag := 1;
      x := p;
    end;
    if flag = 1 then exit;
    Find(p^.left, k, flag, x);
    Find(p^.right, k, flag, x);
  end;
end;

procedure Create_Node_Index(var p: link; a1: integer);
begin
  New(p);
  p^.row := 0;
  p^.column := 0;
  p^.element := 0;
  p^.Left := nil;
  p^.Right := nil;
  p^.node_number := a1;   
end;

procedure InsertIndex(var rooti_1: link; a1, a2: integer; s: string);
var
  x: link;
  flag: integer;
begin
  if rooti_1 = nil then 
  begin
    Create_Node_Index(rooti_1, a1);
    if s = '[label="L"]' then
      Create_Node_Index(rooti_1^.left, a2) else
    if s = '[label="R"]' then
      Create_Node_Index(rooti_1^.right, a2);
  end
  else
  begin
    flag := 0;
    Find(rooti_1, a1, flag, x);
    if s = '[label="L"]' then
      Create_Node_Index(x^.left, a2);
    if s = '[label="R"]' then
      Create_Node_Index(x^.right, a2);    
  end;
end;

procedure Epsilon(var e: double);
var
  s: string;
begin
  writeln('Input epsilon');
  repeat
    {$I-}
    {try}
    readln(e);
    {except
    on System.FormatException do 
    begin
    writeln('error');
    continue;
    end;
    on System.IO.IOException do
    begin
    writeln('error');
    continue;
    end;
    end;}
  until true;
  {$I+}
end;

procedure Sravn(root, rooti: link; var b: boolean);
begin
  if (root <> nil) and (rooti <> nil) then
  begin
    if (root^.row <> rooti^.row) or (root^.column <> rooti^.column) 
       then 
      b := false;
    Sravn(root^.left, rooti^.left, b);
    Sravn(root^.right, rooti^.right, b); 
  end;
end;

procedure Obhod_1(root1, root2: link; var root3: link);
begin
  if root1 <> nil then
  begin
    Obhod_1(root1^.left, root2, root3);
    Obhod_2(root2, root1, root3);      
    Obhod_1(root1^.right, root2, root3);
  end;
end;

procedure Obhod_2(root2, root1: link; var root3: link);
begin
  if root2 <> nil then
  begin
    Obhod_2(root2^.left, root1, root3);
    if (root1^.column = root2^.row) then 
      Calculation(root3, root1^.row, root2^.column, 
        root1^.element * root2^.element);
    Obhod_2(root2^.right, root1, root3);
  end;
end;

procedure FindIJ(p: link; i, j: longint; var flag: integer; var x: link);
begin
  if p <> nil then
  begin
    if (p^.row = i) and (p^.column = j) then
    begin
      flag := 1;
      x := p;
    end;
    if flag = 1 then exit;
    FindIJ(p^.left, i, j, flag, x);
    FindIJ(p^.right, i, j, flag, x);
  end;
end;

procedure Calculation(var root3: link; i, j: longint; pr: double);
var
  x: link;
  flag: integer;
begin
  FindIJ(root3, i, j, flag, x);
  if flag = 0 then Insert_To_Tree(root3, i, j, pr) 
  else
    x^.element := x^.element + pr;
end;

procedure Obhod_Result(root3: link; var root_r: link; e: double);
begin
  if root3 <> nil then
  begin
    Obhod_Result(root3^.left, root_r, e);
    if abs(root3^.element) > e then
      Insert_To_Tree(root_r, root3^.row, root3^.column, root3^.element);
    Obhod_Result(root3^.right, root_r, e);
  end;
end;

procedure Obhod_Spec_0(tr: link; var count: longint);
begin
  if tr <> nil then
  begin
    Obhod_Spec_0(tr^.left, count);
    count := count + 1;
    tr^.node_number := count;
    Obhod_Spec_0(tr^.right, count);
  end;
end;
{
  Simmetric traverse.
}  
procedure Obhod_Spec_1(tr: link; f: text);
begin
  if tr <> nil then
  begin
    Obhod_Spec_1(tr^.left, f);
    with tr^ do
      writeln(f, node_number, ' [label="', row, ' ',
        column, '\n', element, '"];');
    Obhod_Spec_1(tr^.right, f);
  end;
end;
{
  Traverse and write to file.
}  
procedure Obhod_Spec_2(tr: link; f: text);
begin
  if tr <> nil then
  begin
    if tr^.left <> nil then
      writeln(f, tr^.node_number, ' -> ',
        tr^.left^.node_number, ' [label="L"];');
    if tr^.right <> nil then 
      writeln(f, tr^.node_number, ' -> ',
        tr^.right^.node_number, ' [label="R"];');
    Obhod_Spec_2(tr^.left, f);      
    Obhod_Spec_2(tr^.right, f);
  end;
end;

procedure Index_File(s: string; root: link);{создание файла}
var
  f: text;
begin
  Assign(f, s);
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

procedure Output_Matrix(root_r: link; m, n: longint; s: string);
  procedure Obhod_Output(root_r: link; var f: text);
  begin
    if root_r <> nil then
    begin
      Obhod_Output(root_r^.left, f);
      writeln(f, root_r^.row, ' ', root_r^.column, ' ', root_r^.element);
      Obhod_Output(root_r^.right, f);
    end;
  end;

var
  f: text;
begin
  assign(f, s);
  rewrite(f);
  writeln(f, 'matrix', ' ', m, ' ', n);
  Obhod_Output(root_r, f);
  close(f);
end;

end.