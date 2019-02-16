-module(monitor).
-compile(export_all).

test()->
  %To test 3.2
  % in the console write:
  % c(double).
  % double:start().
  % c(monitor).
  % monitor:start(whereis(double)).
  % whereis(double) ! 5.    = Input times 2 = 10
  % whereis(double) ! j.    = Double process died because of bad input j  | Error message because the double process died.
  % whereis(double) ! 5.    = Input times 2 = 10  | Process has restarted after crashing.

  hooray.

start(Pid) ->
  %Pid = spawn_monitor(double, double:loop(),[]),
  spawn(fun() -> watch(Pid)end).



watch(Pid) ->
  process_flag(trap_exit, true),
  Ref = monitor(process,Pid),
  loop(Pid,Ref).


loop(Pid,Ref) ->

  receive
    {'DOWN', Ref, process, Pid, Why} ->
      io:format("double process died because of bad input "),
      double:start(),
      watch(whereis(double)),
      loop(whereis(double), Ref)
  end.
