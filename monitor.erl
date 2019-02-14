-module(monitor).
-compile(export_all).

start(Pid) ->
  %Pid = spawn_monitor(double, double:loop(),[]),
  spawn(fun() -> watch(Pid)end).



watch(Pid) ->
  process_flag(trap_exit, true),
  link(Pid),
  monitor1(Pid).


monitor1(Pid) ->

  receive
    X ->
      io:format("Something died ~p~n",[X]),
      %Pid2 = spawn(fun(X) ->double1:loop()end),
      double1:start(),
      monitor1(Pid)
  end.
