-module(pmap_any).
-compile(export_all).


smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

pmap(F, L) ->
  S = self(),
  Pids = smap(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              end, L),
%% gather the results
  gather(Pids).

do_f(Parent, F, I) ->
  Parent ! {self(), (catch F(I))}.

gather([Pid|T]) ->
  receive
    {Pid, Ret} -> [Ret|gather(T)]
  end;


gather([]) ->
  [].