-module(pmap_any_tagged).
-compile(export_all).

test()->
[{2,1},{20,6765},{35,9227465}] = pmap_any_tagged(fun fib/1,[35,2,20]),
hooray.

smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

%takes a function and a list and spawns one process for each element in the list
pmap_any_tagged(F, L) ->
  S = self(),
  lists:foreach(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              end, L),
  %gathers results with list length and an empty list as input
  gather(length(L),[]).

%each function sends back a message with the calculation done with function F on variable I
do_f(Parent, F, I) ->
  %it also sends the variable I as a tag to the parent
  Parent ! {I, (catch F(I))}.

%when the list length variable reaches 0 all the process calculations have been received and the list is complete
gather(0,L) ->
  lists:reverse(L);

%receives the length of the list and the empty list to start with.
%As soon as a function sends a tag and return value it puts that tag and value as a tuple in the list.
%It also decrements the list length variable and calls itself to keep listening for more calculation results
gather(N,L) ->
  receive
    {Tag,Ret} ->
      gather(N-1,[{Tag,Ret}|L])
  end.
