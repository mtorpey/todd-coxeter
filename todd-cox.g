new_todd_coxeter_table := function(F, rels)
  local gens, nrgens, table, coincidences;
  # Alphabet
  gens := GeneratorsOfSemigroup(F);
  nrgens := Length(gens);

  # Table with one empty row
  table := [ListWithIdenticalEntries(nrgens, -1)];

  # No coincidences yet
  coincidences := Set([]);

  return rec(table := table, gens := gens, nrgens := nrgens, rels := rels,
             coincidences := coincidences);
end;

make_definition := function(tc)
  local table, nrrows, nrgens, row, i;
  table := tc.table;
  nrrows := Length(table);
  nrgens := Length(table[1]);
  for row in table do
    for i in [1 .. nrgens] do
      if row[i] = -1 then
        row[i] := nrrows + 1;
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
    AddSet(tc.coincidences, rows);
  fi;
  return tc;
end;

resolve_coincidence := function(tc)
  local coin, keeprow, delrow, row, i;
  # Resolve a single coincidence in tc
  coin := Remove(tc.coincidences);
  keeprow := coin[1];
  delrow := coin[2];
  if delrow < keeprow then
    AddSet(tc.coincidences, [delrow, keeprow]);
  elif keeprow < delrow then
    # Replace all instances of the second number with the first
    for row in tc.table do
      for i in [1 .. tc.nrgens] do
        if row[i] = delrow then
          row[i] := keeprow;
        fi;
      od;
    od;
    # Combine the two rows
    for i in [1 .. tc.nrgens] do
      if tc.table[keeprow][i] <> tc.table[delrow][i] then
        if tc.table[keeprow][i] = -1 then
          tc.table[keeprow][i] := tc.table[delrow][i];
        elif tc.table[delrow][i] <> -1 then
          AddSet(tc.coincidences, [tc.table[keeprow][i], tc.table[delrow][i]]);
        fi;
      fi;
    od;
    # Delete the second row
    Unbind(tc.table[delrow]);
    tc.coincidences := Filtered(tc.coincidences, p-> not delrow in p);
  fi;
end;

solve_table := function(tc)
  local oldtable, rowno, relno;
  repeat
    make_definition(tc);
    oldtable := tc.table;
    for rowno in [1 .. Length(tc.table)] do
      if IsBound(tc.table[rowno]) then
        for relno in [1 .. Length(tc.rels)] do
          apply_relation(tc, rowno, relno);
        od;
      fi;
    od;
    while not IsEmpty(tc.coincidences) do
      resolve_coincidence(tc);
    od;
  until tc.table = oldtable;
  return tc;
end;

semigroup_congruence_table := function(cong)
  local S, pairs, iso, F, rels;
  S := Range(cong);
  pairs := GeneratingPairsOfSemigroupCongruence(cong);
  if not IsFpSemigroup(S) then
    iso := IsomorphismFpSemigroup(S);
    S := Range(iso);
    pairs := List(pairs, pair-> List(pair, elm-> elm^iso));
  fi;
  F := FreeSemigroupOfFpSemigroup(S);
  rels := RelationsOfFpSemigroup(S);
  rels := Concatenation(rels, List(pairs, p-> [UnderlyingElement(p[1]),
                                               UnderlyingElement(p[2])]));
  return new_todd_coxeter_table(F, rels);
end;

semigroup_congruence_table_cayley := function(cong)
  local S, pairs, iso, F, rels, tc;
  S := Range(cong);
  pairs := GeneratingPairsOfSemigroupCongruence(cong);
  if not IsFpSemigroup(S) then
    iso := IsomorphismFpSemigroup(S);
    S := Range(iso);
    pairs := List(pairs, pair-> List(pair, elm-> elm^iso));
  fi;
  F := FreeSemigroupOfFpSemigroup(S);
  rels := RelationsOfFpSemigroup(S);
  rels := Concatenation(rels, List(pairs, p-> [UnderlyingElement(p[1]),
                                               UnderlyingElement(p[2])]));
  tc := new_todd_coxeter_table(F, rels);
  tc.table := Concatenation([[2 .. tc.nrgens + 1]], List(CayleyGraphSemigroup(Range(cong)) + 1, ShallowCopy));
  return tc;
end;
