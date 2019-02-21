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



smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

pmap_max(F, L, MaxWorkers) ->
  S = self(),
  Pids = smap(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              %separates out the different sublists and sends them to be evaluated
              end, [X || X <- part(L,MaxWorkers)]),
%% gather the results
gather(Pids).

%splits the list into a list containing sublists
part(L, MaxWorkers) ->
    Length = length(L),

    %N is used to calculate how many elements a sublist should have.
    %the last sublist usually has less elements
    %MaxWorkers only gives the max amount of process that can be used but often less than max are used
    %Example: If the Length = 10 and MaxWorkers = 3 N = 1 + 3 which means we get two sublists of 4 elements and one with 2
    N = (Length rem MaxWorkers) + (Length div MaxWorkers),
    %lists:seq will return the starting element of each sublist and lists:sublist will create sublists from the starting point to N elements
    [lists:sublist(L,X,N)|| X <- lists:seq(1,Length,N)].

%evaluates the function F on the LIST I
do_f(Parent, F, I) ->
  %evaluates the function F on all elements in I
  Parent ! {lists:map(fun(X) -> catch F(X) end, I)}.

gather([_|T] ) ->
  receive
    %receives the return from each process and makes sure it ends up in the correct order
    {Ret} ->
      lists:append(Ret, gather(T))
  end;

gather([]) ->
  [].




