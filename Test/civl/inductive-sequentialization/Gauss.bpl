// RUN: %boogie "%s" > "%t"
// RUN: %diff "%s.expect" "%t"

var {:layer 0,2} x:int;

type {:pending_async}{:datatype} PA;
function {:constructor} ADD(i: int) : PA;

////////////////////////////////////////////////////////////////////////////////

procedure {:atomic}{:layer 1}
{:IS "MAIN'","INV"}{:elim "ADD"}
SUM (n: int)
returns ({:pending_async "ADD"} PAs:[PA]int)
modifies x;
{
  assert {:inst_add "A", 0} n >= 0;
  PAs := (lambda pa: PA :: if is#ADD(pa) && 1 <= i#ADD(pa) && i#ADD(pa) <= n then 1 else 0);
}

procedure {:atomic}{:layer 2}
MAIN' (n: int)
modifies x;
{
  assert n >= 0;
  x := x + (n * (n+1)) div 2;
}

procedure {:IS_invariant}{:layer 1}
INV (n: int)
returns ({:pending_async "ADD"} PAs:[PA]int, {:choice} choice:PA)
modifies x;
{
  var {:inst_at "A"} i: int;

  assert n >= 0;

  assume {:inst_add "A", i} {:inst_add "A", i+1} {:inst_add "B", ADD(n)} 0 <= i && i <= n;
  x := x + (i * (i+1)) div 2;
  PAs := (lambda {:inst_at "B"} pa: PA :: if is#ADD(pa) && i < i#ADD(pa) && i#ADD(pa) <= n then 1 else 0);
  choice := ADD(i+1);
}

////////////////////////////////////////////////////////////////////////////////

procedure {:left}{:layer 1}
ADD (i: int)
modifies x;
{
  x := x + i;
}
