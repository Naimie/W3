-module(pmap_tagged_test).
-compile(export_all).



smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

pmap(F, L) ->
  S = self(),
%  Ref = erlang:make_ref(),
  Pids = smap(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              end, L),
%% gather the results
  %report(length(L),[]).
  io:format("Pids = ~p~n",[Pids]),
  gather(length(L),[]).
%gather(Pids).

do_f(Parent, F, I) ->
  io:format("I = ~p~n",[I]),
  Parent ! {self(), I, (catch F(I))}.


gather(0,L) ->
  lists:reverse(L);

gather(N,L) ->

  receive
    {Pid,Tag,Ret} ->

      io:format("waiting for input from = ~p~n",[{Pid,Tag,Ret}]),
      gather(N-1,[{Tag,Ret}|L])
  end.
