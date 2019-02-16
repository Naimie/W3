-module(pmap_any_tagged).
-compile(export_all).


smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

pmap_any_tagged(F, L) ->
  S = self(),
  Ref = erlang:make_ref(),
  lists:foreach(fun(I) ->
    spawn(fun() -> do_f(S, Ref, F, I) end)
                end, L),
%% gather the results
 % io:format("Hello ~p~n",[L]),
  report(length(L),Ref,[],L).


do_f(Parent, Ref, F, I) ->
  Parent ! { Ref, (catch F(I))}.

report(0, _, L1, L2)->
  %the first computed function will be put in the list and the next value will be attached at the beginning. To get it in computation order it needs to be reversed.
  Input_list = lists:sort(L2),
  Fib_list = lists:reverse(L1),
  io:format("~p~n",[{Input_list, Fib_list}]),
  L3 = lists:zip(Input_list,Fib_list),
  L3;

report(N,Ref,L1, L2)->
  receive
    {Ref,Ret} ->
      io:format("~p~n",[{Ref,Ret,L1}]),
      report(N-1,Ref, [Ret|L1], L2)
  end.