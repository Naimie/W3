
-module(client).
-compile(export_all).

start()->
  spawn(fun()-> loop()end),
  double:start().
  %Pid.

sleep() ->
  T = crypto:rand_uniform(100, 400),
  T,
hooray.

loop(T) ->
  receive
  after T ->
    whereis(double) ! a %Crashes the server
  end.
