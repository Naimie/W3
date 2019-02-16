-module(pmap_any).
-compile(export_all).


smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

pmap(F, L) ->
  S = self(),
  Ref = erlang:make_ref(),
  lists:foreach(fun(I) ->
    spawn(fun() -> do_f(S, Ref, F, I) end)
              end, L),
%% gather the results
  report(length(L),Ref,[]).


do_f(Parent, Ref, F, I) ->
  Parent ! { Ref, (catch F(I))}.

report(0, _, L)->
  %the first computed function will be put in the list and the next value will be attached at the beginning. To get it in computation order it needs to be reversed.
  lists:reverse(L);

report(N,Ref,L)->
  receive
    {Ref,Ret} ->
      io:format("~p~n",[{Ref,Ret}]),
      report(N-1,Ref, [Ret|L])
  end.