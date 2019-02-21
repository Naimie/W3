-module(pmap_any_tagged_max_time).
-compile(export_all).

test()->
  [{2,1},{20,6765},{35,9227465}] = pmap_any_tagged_max_time(fun fib/1,[35,2,456,20],2000),
  hooray.

smap(_, []) -> [];
smap(F, [H|T]) -> [F(H) | smap(F, T)].

fib(0)-> 0;
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

%takes a function and a list along with max computation time and spawns one process for each element in the list
pmap_any_tagged_max_time(F, L, MaxTime) ->
  S = self(),
  Pids = smap(fun(I) ->
    spawn(fun() -> do_f(S, F, I) end)
              end, L),
  %gathers results with pid list, list length, an empty list and max computation time as input
  gather(Pids,length(L),[], MaxTime).

%each function sends back a message with the calculation done with function F on variable I
do_f(Parent, F, I) ->
  %it also sends the variable I as a tag to the parent
  Parent ! {I, (catch F(I))}.

%when the list length variable reaches 0 all the process calculations have been received and the list is complete.
%if it gets to this point all processes have finished before the allowed max computation time.
gather(_,0,L,_) ->
  lists:reverse(L);

%receives the pid list, length of the list (amount of processes), the empty list and max computation time to start with.
%As soon as a function sends a tag and return value it puts that tag and value as a tuple in the list.
%It also decrements the list length variable and calls itself to keep listening for more calculation results
gather(Pids,N,L,MaxTime) ->
  receive
    {Tag,Ret} ->
      gather(Pids,N-1,[{Tag,Ret}|L],MaxTime)

  %if max compuation time is reached all processes are killed and the list in its current state is returned.
  after MaxTime ->
  lists:foreach(fun(X) -> exit(X,kill) end, Pids),
  lists:reverse(L)
end.



