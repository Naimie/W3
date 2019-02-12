-module(monitor).
-compile(export_all).

start() ->
 spawn(fun() ->
   Ref = monitor(process, double),
   process_flag(trap_exit, true),
    receive
      {'DOWN', Ref, process, double, Why} ->
        spawn_monitor(double,start(),[])
    end
 end).

