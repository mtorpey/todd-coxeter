nrcombs := 1612800;

print_chances := function(nrcombs)
  local chance, nrgames;
  chance := 1.0;
  nrgames := 1;
  while chance >= 0.5 do
    chance := chance * (nrcombs - nrgames + 1) / nrcombs;
    Print(nrgames, ":", chance, "\n");
    nrgames := nrgames + 1;
  od;
end;
