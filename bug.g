gap> F := FreeSemigroup(2);;
gap> rels := [[F.1^2, F.1],
>             [F.1*F.2*F.1, F.2*F.1],
>             [F.2^2*F.1, F.2*F.1],
>             [F.2^3, F.2],
>             [F.2*F.1*F.2^2, F.2*F.1]];;
gap> S := F / rels;;
gap> D := DClasses(S);;
gap> Splash(DotString(S, rec(maximal := true)));

# D[4] > D[2] > D[1]

# Consider the elements of D[4]
gap> elms := Elements(D[4]);
[ s2, s2^2 ]

# Each elm * S.1 is BELOW D[2]
gap> elms[1] * S.1 in D[1];    elms[2] * S.1 in D[1];
true
true

# Multiplying by S.2 just flips between the two elms
gap> elms[1] * S.2 = elms[2];   elms[2] * S.2 = elms[1];
true
true

#
# So why is D[4] above D[2]?
#

# Solved this - you have to left-multiply!
