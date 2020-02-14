program zd_4;

uses print_index;

var
  f: text;
  s, o: string;
  root: link;

begin
  {if not} 
  File_With_Matrix(s);
  {
  For FreePascal.
  then
  begin
    writeln('Sorry');
    halt(1);
  end;
  }
  Assign(f, s);
  Read_From_Index(root, f);
  {$M+}
  Print_Tree(o, root);
  read(s);
end.
