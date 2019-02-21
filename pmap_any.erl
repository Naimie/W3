-module(pmap_any).
-compile(export_all).

test()->
  [1,6765,9227465] = pmap_any(fun fib/1,[35,2,20]),
  hooray.

smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

%takes a function and a list and spawns one process for each element in the list
pmap_any(F, L) ->
  S = self(),
  lists:foreach(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              end, L),
  %gathers results with list length and an empty list as input
  gather(length(L),[]).

%each function sends back a message with the calculation done with function F on variable I
do_f(Parent, F, I) ->
  Parent ! (catch F(I)).

%when the list length variable reaches 0 all the process calculations have been received and the list is complete
gather(0,L)->
  %the first computed function will be put in the list and the next value will be attached at the beginning. To get it in computation order it needs to be reversed.
  %if input values are low and close to each other it might not be the lowest of the two that gets returned first as they are so fast to compute.
  lists:reverse(L);

%receives the length of the list and the empty list to start with.
%As soon as a function sends a return value it puts that value in the list and decrements the list length variable and calls itself to keep listening for more calculation results
gather(N,L)->
  receive
    Ret ->
      gather(N-1,[Ret|L])
  end.