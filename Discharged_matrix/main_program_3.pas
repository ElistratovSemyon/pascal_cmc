program zd3;

uses index_generation;

var
  root, root1: link;
  count: integer;
  m, n: integer;
  s: string;
  i: integer;

begin
  Name(s);
  Read_From_File(root, count, m, n, s );
  root1 := root;
  count := 0;
  Obhod_Spec_0(root, count);
  Name(s);
  Index_File(s, root);
  writeln('Выводить в поток ввода. Введите 1 если да');
  readln(i);
  if i = 1 then Print_Output(s);
end.