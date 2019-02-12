-module(simple_processes).
-compile(export_all).


double(X)->
  if
      is_integer(X)->
        Y =X*2,
        Y;
    true ->
      io:format("Input is ~p~n is not valid",[X])
  end.


start() ->
  %spawn(double, loop, X).
register(double, spawn(fun() -> loop() end)).

rpc(Pid, Request) ->
  Pid ! {self(), Request},
  receive
    {Pid, Response} ->
      Response
  end.
loop(X) ->
  receive
    cancel ->
      void;
    X when is_integer(X) ->
      Y =X*2,
      Y;
     X when not is_integer(X)  ->
       io:format("Input is ~p~n is not valid",[X]),
       erlang:badarg,
      loop(X)
  end.