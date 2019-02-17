-module(pmap_any_tagged_max_time).
-compile(export_all).

smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

pmap_any_tagged_max_time(F, L, MaxTime) ->
  S = self(),
  Pids = smap(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              end, L),
%% gather the results
  gather(Pids,length(L),[], MaxTime).


do_f(Parent, F, I) ->
  io:format("I = ~p~n",[I]),
  Parent ! {self(), I, (catch F(I))}.


gather(_,0,L,_) ->
  lists:reverse(L);

gather(Pids,N,L,MaxTime) ->

  receive
    {_Pid,Tag,Ret} ->
      gather(Pids,N-1,[{Tag,Ret}|L],MaxTime)

  after MaxTime ->
  lists:foreach(fun(X) -> exit(X,kill) end, Pids),
  lists:reverse(L)

end.



