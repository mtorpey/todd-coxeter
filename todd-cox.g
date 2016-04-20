new_todd_coxeter_table := function(F, rels)
  local gens, nrgens, table, coincidences;
  # Alphabet
  gens := GeneratorsOfSemigroup(F);
  nrgens := Length(gens);

  # Table with one empty row
  table := [ListWithIdenticalEntries(nrgens, -1)];

  # No coincidences yet
  coincidences := [];

  return rec(table := table, gens := gens, rels := rels,
             coincidences := coincidences);
end;

make_definition := function(tc)
  local table, nrrows, nrgens, i, j;
  table := tc.table;
  nrrows := Length(table);
  nrgens := Length(table[1]);
  for i in [1 .. nrrows] do
    for j in [1 .. nrgens] do
      if table[i][j] = -1 then
        table[i][j] := nrrows + 1;
        table[nrrows + 1] := ListWithIdenticalEntries(nrgens, -1);
        return tc;
      fi;
    od;
  od;
  return fail;
end;

apply_word := function(table, rowno, word)
  # RETURNS:
  #  a known number if it's filled in
  #  -1 for an empty space only at the last character
  #  fail if it's undefined 2 characters or more from the end
  if Length(word) = 0 then
    return rowno;
  elif rowno = -1 then
    return fail;
  fi;
  return apply_word(table, table[rowno][word[1]], word{[2..Length(word)]});
end;

apply_relation := function(tc, rowno, relno)
  local rel, rows;
  rel := List(tc.rels[relno], WordToListRWS);
  rows := List(rel, w-> apply_word(tc.table, rowno, w));
  if fail in rows or rows[1] = rows[2] then

  elif rows[1] = -1 then
    tc.table[apply_word(tc.table, rowno, rel[1]{[1..Length(rel[1])-1]})]
            [rel[1][Length(rel[1])]] := rows[2];
  elif rows[2] = -1 then
    tc.table[apply_word(tc.table, rowno, rel[2]{[1..Length(rel[2])-1]})]
            [rel[2][Length(rel[2])]] := rows[1];
  else
    Add(tc.coincidences, rows);
  fi;
  return tc;
end;

solve_table := function(tc)
  local rowno, relno;
  while make_definition(tc) <> fail do
    for rowno in [1 .. Length(tc.table)] do
      for relno in [1 .. Length(tc.rels)] do
        apply_relation(tc, rowno, relno);
      od;
    od;
    if not IsEmpty(tc.coincidences) then
      # Process the coincidences
      return "Coincidences found!";
    fi;
  od;
  return tc;
end;

resolve_coincidence := function(tc)
  # Resolve a single coincidence in tc
  coin := Remove(tc.coincidences, 1);
  keeprow := coin[1];
  delrow := coin[2];
  if delrow < keeprow then
    Add(tc.coincidences, [delrow, keeprow]);
  elif keeprow < delrow then
    for relno in [1 .. Length(tc.rels)] do
      # Combine the two entries
    od;
  fi;
end;
