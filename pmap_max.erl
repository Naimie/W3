-module(pmap_max).
-compile(export_all).

test()->
  F = fun(X)-> X*2 end,
  L = lists:seq(1,30),
  L1 = smap(F,L),
  L2 = pmap_max(F,L,3),
  L3 = pmap_max(F,L,7),
  true =(L1 == L2),
  true =(L1 == L3),
  hooray.

%%needs comments to explain how this shit works
%% why REF
%% sublists
%%gather

smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

pmap_max(F, L, MaxWorkers) ->

  S = self(),
  Ref = make_ref(),
  Pids = smap(fun(I) ->
    spawn(fun() -> do_f(S, Ref, F, I) end)
              end, [L || L <- part(L,MaxWorkers)]),
%% gather the results
gather(Pids,Ref).

part(L, MaxWorkers) ->
    Length = length(L),
    N = (Length rem MaxWorkers) + (Length div MaxWorkers),
    [lists:sublist(L,X,N)|| X <- lists:seq(1,Length,N)].


do_f(Parent, Ref, F, I) ->
  Parent ! {self(), Ref, lists:map(fun(X) -> catch F(X) end, I)}.

gather([Pid|T], Ref) ->
  receive
    {Pid, Ref, Ret} ->
      lists:append(Ret, gather(T,Ref))

  end;

gather([],_) ->
  [].




