-module(double).
-compile(export_all).

test()->
  hooray.

start() ->
  %spawn(double, loop, X).
  register(double,spawn_link(fun() -> loop() end)).

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
      io:format("Input is ~p is not valid",[Other]),
      erlang:error(badarg),
      %trap exit
      loop()
  end.