-module(double).
-compile(export_all).

test()->
  hooray.

start() ->
  %spawn_link???
  register(double,spawn(fun() -> loop() end)).
  %process_flag(trap_exit, true).

double(X)->
  rpc(X).

rpc(Request) ->
  double ! {self(), Request},
  receive
    {_Pid, Response} ->
      Response
  end.

loop() ->
  receive
    {From, X} when is_integer(X) ->
      From ! {self(), X*2},

      loop();
    {From,Other}   ->
      From ! {self(), {error,Other}},
      io:format("Input is ~p is not valid.~n",[Other]),
      exit(erlang:error(badarg))
      %{'EXIT', double, erlang:error(badarg)}->

  end.