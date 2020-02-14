unit print_index;

interface

type
  link = ^tree_node_t;
  tree_node_t = record
    node_number: longint;
    row, column: longint;
    element: double;
    left, right: link ;
  end ;
  {
    This queue is used for print by levels.
  }  
  queue_t = record starting, ending: word;
    mas: array [word] of link end;
{
  This function read file name from standard input and
  pcace it in 's' parameter.

  If we have unexpected end of input or user does not
  intent to enter file name, then it return false.
}
function File_With_Matrix(var s: string): boolean;
{ 
  This function read from file and automaticaly create tree.
}  
procedure Read_From_Index(var root: link;  var f: text );
{ 
  This procedure looking for node 
  with specifed key to give 
  this node value row, column, element.
}  
procedure Find(p: link; k: integer; var flag: integer; var x: link);
{ 
Supporting procedure. Give value to node.
}
procedure CreateNode(var p: link; a1: integer);
{ 
  Create nodes. Insert value to tree. 
  Main generation tree procedure.
}  
procedure Insert(var root: link; a1, a2: integer; s: string);
{ 
  Ask type of output. And perform selected output.
}  
procedure Print_Tree(var o: string; root: link);
{
  Print tree. Firstly root, then left tree, then right tree.
}  
procedure Print_1(p: link);
{
  Print tree by levels.
}  
procedure Print_Levels(var root: link);

implementation

function File_With_Matrix(var s: string): boolean;
begin
  {$I-}
  writeln('Введите название файла: ');
  readln(s);
  {
  Only for FreePascal:
  
  if IoResult <> 0 then
  begin
  	File_With_Matrix := false;
  end
  else
  
  }
  File_With_Matrix := true;
  {$I+}
end;

procedure Read_From_Index(var root: link; var f: text );
  {
    Special procedures to facilitate debugging.
  }
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
  {f: text;}
  c, c1: char;
  x: link;
  flag: integer;
  la: double;
  i, ia, la1, la2, ja, a1, a2, j: longint;
  s1, s: string;

begin
  
   {$I-} 
   { 
   Only for FreePascal.
  
   assign(f, s);
   if(IoResult <> 0) then
   begin
       writeln('Can not open file: ',s);
       halt(1);
   end;
   }
  reset(f);
  {
  Only for Free Pascal.
  
  if(IoResult <> 0) then
  begin
      writeln('Can not open file: ',s);
      halt(1);
  end;
  }
  {$I+}
  s := '';
  spec1(f, c);
  repeat
    s := s + c;
    read(f, c);  
  until (c = ' ') or eoln(f);
  s := '';
  flag := 0;
  repeat
    {
      Main loop reading position of nodes
    }  
    spec2(f, s, c, a1, a2);
    if s = '[label="L"]' then
      Insert(root, a1, a2, s)
    else
    if s = '[label="R"]' then
      Insert(root, a1, a2, s)
    else
    if s = '' then break {if end of nodes}
    else 
    {
      Check file.
    }        
    if (s <> '[label="R"]') and (s <> '[label="L"]') then
    begin
      writeln('error');
      break;
    end;
    s := '';
  until false;
  close(f);
  {
    Reading value of nodes
  }  
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
      writeln('error9');
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
    Find(root, a1, flag, x);
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

procedure CreateNode(var p: link; a1: integer);
begin
  New(p);
  p^.row := 0;
  p^.column := 0;
  p^.element := 0;
  p^.Left := nil;
  p^.Right := nil;
  p^.node_number := a1;   
end;

procedure Insert(var root: link; a1, a2: integer; s: string);
var
  x: link;
  flag: integer;
begin
  if root = nil then 
  begin
    CreateNode(root, a1);
    if s = '[label="L"]' then
      CreateNode(root^.left, a2) else
    if s = '[label="R"]' then
      CreateNode(root^.right, a2);
  end
  else
  begin
    flag := 0;
    Find(root, a1, flag, x);
    if s = '[label="L"]' then
      CreateNode(x^.left, a2);
    if s = '[label="R"]' then
      CreateNode(x^.right, a2);    
  end;
end;

procedure Print_Tree(var o: string; root: link);
begin
  writeln('Type of output. 1 - simmetric; 2 - levels');
  repeat
    readln(o);
    if o = '1' then 
      Print_1(root)
    else
    if o = '2' then    
      Print_Levels(root)  
    else
      continue;
  until true;
end;

procedure Print_1(p: link);
var
  sl, sr: string;
begin
  if p <> nil then
  begin
    if p^.left = nil then sl := 'NULL' else str(p^.left^.node_number, sl);
    if p^.right = nil then sr := 'NULL' else str(p^.right^.node_number, sr);    
    writeln('Node Number = ', p^.node_number, '; row = ', p^.row,
      '; column = ', p^.column, ' value = ', p^.element, '; left node = ',
          sl, '; right = ', sr);
    Print_1(p^.left);
    Print_1(p^.right);
    
  end;
end;


procedure Print_Levels(var root: link);
var
  i: integer;
  
  procedure Clean_Queue(var q: queue_t);
  begin
    q.starting := 1;
    q.ending := 0;
  end;
  
  function Null_Queue(var q: queue_t): boolean;
  begin
    Null_Queue := q.ending = 0;
  end;
  
  procedure To_Queue(var q: queue_t; x: link; n: integer);
  var
    i: integer;
  begin
    with q do
    begin
      if ending = n then
        if starting = 1 then write('')
        else
          for i := starting to ending do mas[i - starting + 1] := mas[i];
      ending := ending + 1;
      mas[ending] := x;
    end;
  end;
  
  procedure From_Queue(var q: queue_t; var x: link);
  begin
    with q do
    begin
      x := mas[starting];
      if starting = ending then Clean_Queue(q)
      else starting := starting + 1;
    end
  end;

var
  q: queue_t;
  n, k, k1: integer;
  a: link;
  sl, sr: string;
begin
  { 
    Work with queue.
  }  
  a := root;
  if a <> nil then begin
    Clean_Queue(q);
    To_Queue(q, a, n);
    n := 1;
    k := 1;
    repeat
      writeln(n, ' level:');
      k1 := 0;
      for k := 1 to k do
      begin
        From_Queue(q, a);
        if a^.left = nil then sl := 'NULL' else str(a^.left^.node_number, sl);
        if a^.right = nil then sr := 'NULL' else str(a^.right^.node_number, sr);
        writeln('Node number: ', a^.node_number, '; row = ', a^.row,
          '; column = ', a^.column, '; value = ', a^.element, '; left node = ',
          sl, '; right = ', sr);
        if a^.left <> nil then
        begin
          To_Queue(q, a^.left, n);
          k1 := k1 + 1;
        end;
        if a^.right <> nil then
        begin
          To_Queue(q, a^.right, n);
          k1 := k1 + 1;
        end;
      end;
      writeln;
      n := n + 1;
      k := k1;
    until k = 0;
  end;
end;
end.

